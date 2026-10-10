import Foundation
import Combine
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics

@MainActor
final class WeaknessCourseStore: ObservableObject {
    static let shared = WeaknessCourseStore()

    @Published private(set) var state = CourseAccountState()
    @Published private(set) var userID: String?
    @Published private(set) var syncMessage: String?
    @Published private(set) var isSyncing = false
    private let defaults: UserDefaults
    private let syncEnabled: Bool
    private var connectionReference: DatabaseReference?
    private var connectionHandle: DatabaseHandle?
    private var needsAnotherSync = false
    private var generation = UUID()
    private var acknowledged = CourseCloudState()
    private var cloudLoaded = false
    private var connected = false
    private var pendingImports: [String: QuizQuestion] = [:]
    private var backgroundObserver: AnyCancellable?
    private var foregroundObserver: AnyCancellable?

    init(defaults: UserDefaults = .standard, syncEnabled: Bool = true) {
        self.defaults = defaults
        self.syncEnabled = syncEnabled
        backgroundObserver = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in Task { @MainActor in self?.sync() } }
        foregroundObserver = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in Task { @MainActor in self?.refresh() } }
    }

    func configure(userID: String?) {
        guard self.userID != userID else { return }
        if let connectionHandle { connectionReference?.removeObserver(withHandle: connectionHandle) }
        connectionHandle = nil
        connectionReference = nil
        generation = UUID()
        isSyncing = false
        needsAnotherSync = false
        syncMessage = nil
        acknowledged = CourseCloudState()
        cloudLoaded = !syncEnabled
        connected = false
        pendingImports = [:]
        self.userID = userID
        state = userID.map { CourseLocalPersistence.load(userID: $0, defaults: defaults) } ?? CourseAccountState()
        guard let userID, syncEnabled else { return }
        importQuestions(LocalIncorrectAnswerStore.questions(userId: userID, category: .itPassport))
        let request = generation
        let connection = Database.database().reference(withPath: ".info/connected")
        connectionReference = connection
        connectionHandle = connection.observe(.value) { [weak self] snapshot in
            let connected = snapshot.value as? Bool == true
            Task { @MainActor in
                guard let self, self.generation == request else { return }
                if connected && !self.connected { self.cloudLoaded = false }
                self.connected = connected
                if connected { self.sync() }
                else { self.syncMessage = "進捗はこの端末に保存されています。接続後に同期します。" }
            }
        }
        fetchITIncorrectAnswers(userId: userID) { [weak self] questions in
            Task { @MainActor in
                guard let self, self.generation == request else { return }
                self.importQuestions(questions)
            }
        }
    }

    func importQuestions(_ questions: [QuizQuestion]) {
        // Load remote progress before importing history, so historical mistakes cannot reopen mastery.
        guard cloudLoaded else {
            for question in questions {
                guard let source = WeaknessCourseCatalog.source(prompt: question.question, choices: question.choices,
                    correctIndex: question.correctAnswerIndex, explanation: question.explanation) else { continue }
                pendingImports[source.question.id] = question
            }
            return
        }
        let before = state
        for question in questions {
            guard let source = WeaknessCourseCatalog.source(prompt: question.question, choices: question.choices,
                correctIndex: question.correctAnswerIndex, explanation: question.explanation) else { continue }
            state.importMistake(topicID: source.topicID, question: source.question, now: Date())
        }
        if before != state { persist(); sync() }
    }

    func recordMistake(question: QuizQuestion, selectedIndex: Int?, userID: String) {
        guard let source = WeaknessCourseCatalog.source(prompt: question.question, choices: question.choices,
            correctIndex: question.correctAnswerIndex, explanation: question.explanation) else { return }
        configure(userID: userID)
        state.recordMistake(topicID: source.topicID, question: source.question, selectedIndex: selectedIndex, now: Date())
        persist()
        // Flush at quiz completion/background/reconnect, not for every wrong answer.
    }

    var recommendedTopics: [WeaknessCourseTopic] {
        let now = Date()
        return WeaknessCourseCatalog.topics.filter { state.cloud.progress[$0.id]?.stage != .mastered && state.cloud.progress[$0.id] != nil }
            .sorted { left, right in
                let lp = state.cloud.progress[left.id]!
                let rp = state.cloud.progress[right.id]!
                let lRank = lp.isDue(at: now) ? 0 : lp.stage == .needsPractice ? 1 : 2
                let rRank = rp.isDue(at: now) ? 0 : rp.stage == .needsPractice ? 1 : 2
                if lRank != rRank { return lRank < rRank }
                if lp.mistakeCount != rp.mistakeCount { return lp.mistakeCount > rp.mistakeCount }
                return left.id < right.id
            }
    }

    var masteredTopics: [WeaknessCourseTopic] {
        WeaknessCourseCatalog.topics.filter { state.cloud.progress[$0.id]?.stage == .mastered }
    }

    func begin(topic: WeaknessCourseTopic, subscribed: Bool) -> CourseSession? {
        guard userID != nil else { return nil }
        let wasUnclaimed = state.cloud.freeClaim == nil
        let previousSessionID = state.activeSession?.id
        guard let session = state.begin(topic: topic, subscribed: subscribed, now: Date()) else { return nil }
        persist()
        sync()
        if session.id != previousSessionID {
            CourseAnalytics.log("course_session_start", topicID: topic.id, parameters: ["kind": session.kind.rawValue, "is_premium": subscribed ? 1 : 0])
        }
        if wasUnclaimed && !subscribed { CourseAnalytics.log("course_trial_start", topicID: topic.id) }
        if subscribed { PremiumAnalytics.logPremiumFirstUseIfNeeded(feature: "weakness_course") }
        return session
    }

    func answer(_ index: Int, sessionID: String) {
        guard state.activeSession?.id == sessionID else { return }
        state.activeSession?.answer(index)
        persist()
    }

    func advance(sessionID: String) -> CourseCompletion? {
        guard state.activeSession?.id == sessionID else { return nil }
        state.activeSession?.advance()
        let result = state.finish(sessionID: sessionID, now: Date())
        persist()
        if let result {
            CourseAnalytics.log("course_session_complete", topicID: result.topicID, parameters: [
                "kind": result.kind.rawValue, "correct_count": result.correctCount,
                "question_count": result.questionCount, "passed": result.passed ? 1 : 0
            ])
            if result.progress.stage == .mastered {
                CourseAnalytics.log("course_mastered", topicID: result.topicID)
                if state.cloud.freeClaim?.topicID == result.topicID {
                    CourseAnalytics.log("course_trial_complete", topicID: result.topicID)
                }
            }
            sync()
        }
        return result
    }

    private func persist() {
        guard let userID else { return }
        CourseLocalPersistence.save(state, userID: userID, defaults: defaults)
    }

    private func refresh() {
        guard syncEnabled, connected else { return }
        cloudLoaded = false
        sync()
    }

    /// Read once on account setup/reconnect, then transact only changed nodes.
    /// Acknowledgement tracks successful writes; local edits made in flight stay dirty.
    func sync() {
        guard syncEnabled, connected, let userID, Auth.auth().currentUser?.uid == userID else { return }
        if isSyncing { needsAnotherSync = true; return }
        let reference = Database.database().reference().child("users").child(userID).child("weaknessCoursesV1")
        let request = generation
        if !cloudLoaded {
            isSyncing = true
            reference.getData { [weak self] error, snapshot in
                let remote: CourseCloudState?
                if error != nil || snapshot == nil { remote = nil }
                else if snapshot?.value == nil || snapshot?.value is NSNull { remote = CourseCloudState() }
                else { remote = CourseCloudCodec.decode(CourseCloudState.self, from: snapshot?.value) }
                Task { @MainActor in
                    guard let self, self.generation == request else { return }
                    self.isSyncing = false
                    guard let remote else { self.reportSyncFailure(); return }
                    self.acknowledged = remote
                    self.state.cloud = self.state.cloud.merging(remote)
                    self.cloudLoaded = true
                    let imports = self.pendingImports.sorted { $0.key < $1.key }.map(\.value)
                    self.pendingImports = [:]
                    self.importQuestions(imports)
                    self.validateActiveSession()
                    self.persist()
                    self.sync()
                }
            }
            return
        }
        let delta = CourseSyncDelta(local: state.cloud, acknowledged: acknowledged)
        guard !delta.isEmpty else { syncMessage = nil; return }
        isSyncing = true
        needsAnotherSync = false
        Task { [weak self] in
            var results: [CourseNodeResult] = []
            // Each transaction reads only its own small node, preserving other themes.
            for (id, progress) in delta.progress.sorted(by: { $0.key < $1.key }) {
                guard self?.canContinueSync(request: request, userID: userID) == true else { return }
                results.append(await Self.write(reference.child("progress").child(id), mutation: .progress(id, progress)))
            }
            if let claim = delta.freeClaim {
                guard self?.canContinueSync(request: request, userID: userID) == true else { return }
                results.append(await Self.write(reference.child("freeClaim"), mutation: .claim(claim)))
            }
            if !delta.importedSourceIDs.isEmpty {
                guard self?.canContinueSync(request: request, userID: userID) == true else { return }
                results.append(await Self.write(reference.child("importedSourceIDs"), mutation: .imports(delta.importedSourceIDs)))
            }
            guard let self, self.generation == request else { return }
            self.isSyncing = false
            var failed = false
            for result in results {
                guard let remote = result.state else { failed = true; continue }
                self.acknowledged = self.acknowledged.merging(remote)
                self.state.cloud = self.state.cloud.merging(remote)
            }
            self.validateActiveSession()
            self.persist()
            if failed { self.reportSyncFailure() }
            else {
                self.syncMessage = nil
                if self.needsAnotherSync { self.sync() }
            }
        }
    }

    private func validateActiveSession() {
        guard let active = state.activeSession else { return }
        if state.cloud.progress[active.topicID]?.updatedAt != active.progressUpdatedAtStart
            || !state.cloud.canAccess(active.topicID, subscribed: AppState.shared.isSubscribed) {
            state.activeSession = nil
        }
    }

    private func canContinueSync(request: UUID, userID: String) -> Bool {
        guard generation == request else { return false }
        guard Auth.auth().currentUser?.uid == userID else {
            isSyncing = false
            reportSyncFailure()
            return false
        }
        return true
    }

    private func reportSyncFailure() {
        syncMessage = "進捗はこの端末に保存済みです。クラウドに同期できませんでした。"
    }

    private enum CourseMutation {
        case progress(String, CourseProgress)
        case claim(CourseFreeClaim)
        case imports([String])
    }

    private struct CourseNodeResult { let state: CourseCloudState? }

    nonisolated private static func write(_ reference: DatabaseReference, mutation: CourseMutation) async -> CourseNodeResult {
        await withCheckedContinuation { continuation in
            reference.runTransactionBlock({ data in
                let isEmpty = data.value == nil || data.value is NSNull
                switch mutation {
                case let .progress(_, incoming):
                    let old = CourseCloudCodec.decode(CourseProgress.self, from: data.value)
                    guard isEmpty || old != nil else { return .abort() }
                    let value = old.map { $0.updatedAt >= incoming.updatedAt ? $0 : incoming } ?? incoming
                    guard let encoded = CourseCloudCodec.encode(value) else { return .abort() }
                    data.value = encoded
                case let .claim(incoming):
                    let old = CourseCloudCodec.decode(CourseFreeClaim.self, from: data.value)
                    guard isEmpty || old != nil else { return .abort() }
                    var left = CourseCloudState(); left.freeClaim = old
                    var right = CourseCloudState(); right.freeClaim = incoming
                    guard let encoded = CourseCloudCodec.encode(left.merging(right).freeClaim) else { return .abort() }
                    data.value = encoded
                case let .imports(incoming):
                    let old = CourseCloudCodec.decode([String].self, from: data.value)
                    guard isEmpty || old != nil else { return .abort() }
                    data.value = Array(Set((old ?? []) + incoming)).sorted()
                }
                return .success(withValue: data)
            }, andCompletionBlock: { error, committed, snapshot in
                guard error == nil, committed else {
                    continuation.resume(returning: CourseNodeResult(state: nil)); return
                }
                var state = CourseCloudState()
                switch mutation {
                case let .progress(id, _):
                    guard let value = CourseCloudCodec.decode(CourseProgress.self, from: snapshot?.value) else {
                        continuation.resume(returning: CourseNodeResult(state: nil)); return
                    }
                    state.progress[id] = value
                case .claim:
                    guard let value = CourseCloudCodec.decode(CourseFreeClaim.self, from: snapshot?.value) else {
                        continuation.resume(returning: CourseNodeResult(state: nil)); return
                    }
                    state.freeClaim = value
                case .imports:
                    guard let value = CourseCloudCodec.decode([String].self, from: snapshot?.value) else {
                        continuation.resume(returning: CourseNodeResult(state: nil)); return
                    }
                    state.importedSourceIDs = value
                }
                continuation.resume(returning: CourseNodeResult(state: state))
            }, withLocalEvents: false)
        }
    }

#if DEBUG
    static func preview(_ scenario: ReviewHomePreviewScenario = .reviewDue) -> WeaknessCourseStore {
        let suite = "weakness-course-preview-\(scenario.rawValue)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = WeaknessCourseStore(defaults: defaults, syncEnabled: false)
        store.configure(userID: "course-preview")
        let now = Date()
        let day: TimeInterval = 86400
        func mistake(_ id: String) {
            guard let topic = WeaknessCourseCatalog.topic(id) else { return }
            store.state.recordMistake(topicID: id, question: topic.practice[0], selectedIndex: -1, now: now - 2 * day)
        }
        func waiting(_ id: String, confirmed: Int, next: Date) {
            mistake(id)
            store.state.cloud.progress[id]?.stage = .waiting
            store.state.cloud.progress[id]?.confirmedCount = confirmed
            store.state.cloud.progress[id]?.nextReviewAt = next
            store.state.cloud.freeClaim = store.state.cloud.freeClaim ?? CourseFreeClaim(topicID: id, claimedAt: now - 3 * day)
        }
        switch scenario {
        case .continueTheme:
            mistake("dns"); mistake("memory")
            if let topic = WeaknessCourseCatalog.topic("dns"),
               let session = store.state.begin(topic: topic, subscribed: false, now: now - 600) {
                store.state.activeSession?.answer(session.questions[0].correctIndex)
                store.state.activeSession?.advance()
            }
        case .reviewDue, .themeCheckup, .freeLimitWithTheme, .afterReview:
            waiting("dns", confirmed: 0, next: now - 60); mistake("memory")
        case .freeLimit:
            waiting("dns", confirmed: 0, next: now + day)
        case .firstRun:
            break
        case .allClear, .nothingToday:
            waiting("dns", confirmed: 1, next: now + 3 * day)
        }
        store.persist()
        return store
    }
#endif
}

enum CourseAnalytics {
    static func log(_ event: String, topicID: String? = nil, parameters: [String: Any] = [:]) {
#if !DEBUG
        var values = parameters
        values["qualification"] = "it_passport"
        if let topicID { values["course_topic_id"] = topicID }
        Analytics.logEvent(event, parameters: values)
#endif
    }
}
