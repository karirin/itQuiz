import SwiftUI
import Combine

enum AdventurePresentation: Identifiable {
    case encounter(Int), treasure(Int), reward(Int), battle, victory(Int), defeat, world, inventory, menu, journal

    var id: String {
        switch self {
        case .encounter(let id): return "encounter-\(id)"
        case .treasure(let id): return "treasure-\(id)"
        case .reward(let id): return "reward-\(id)"
        case .battle: return "battle"
        case .victory(let id): return "victory-\(id)"
        case .defeat: return "defeat"
        case .world: return "world"
        case .inventory: return "inventory"
        case .menu: return "menu"
        case .journal: return "journal"
        }
    }
}

@MainActor
final class AdventureStore: ObservableObject {
    @Published private(set) var progress = AdventureProgress()
    @Published var selectedNodeID = 1
    @Published var presentation: AdventurePresentation?
    @Published var storyPlayback: AdventureStoryPlayback?
    @Published private(set) var visualNodeID = 0
    @Published private(set) var isMoving = false
    @Published private(set) var loadError: String?
    @Published private(set) var isDeliveringRewards = false
    @Published private(set) var rewardMessage: String?

    let accountID: String
    let isPreview: Bool
    private let repository: AdventureSaveRepository
    private var movement: Task<Void, Never>?
    private var rewardTimeout: Task<Void, Never>?
    private var rewardAttempt = UUID()
    private var queuedStory: AdventureStoryPlayback?
    private var storyContinuation: AdventurePresentation?
    @Published private var latestPlayerStats: AdventurePlayerStats?
    @Published private(set) var playerStatsLoadError: String?
    var hasLoadedPlayerStats: Bool { latestPlayerStats != nil }

    func loadPlayerStats() {
        guard !isPreview, AuthManager.shared.currentUserId == accountID else { return }
        playerStatsLoadError = nil
        AuthManager.shared.fetchAdventurePlayerStats { [weak self] stats in
            Task { @MainActor in
                guard let self, AuthManager.shared.currentUserId == self.accountID else { return }
                if let stats { self.syncPlayerStats(stats) }
                else if let savedStats = self.progress.playerStats { self.syncPlayerStats(savedStats) }
                else { self.playerStatsLoadError = "レベルとオトモを読み込めませんでした。もう一度お試しください。" }
            }
        }
    }

    func syncPlayerStats(_ stats: AdventurePlayerStats) {
        if latestPlayerStats != stats { latestPlayerStats = stats }
        guard loadError == nil else { return }
        if progress.updatePlayerStats(stats) { save() }
    }

    private func applyLatestPlayerStats() {
        if let latestPlayerStats { _ = progress.updatePlayerStats(latestPlayerStats) }
    }

    func rest() {
        guard hasLoadedPlayerStats else { return }
        applyLatestPlayerStats()
        if progress.rest() { save() }
    }

    init(accountID: String, defaults: UserDefaults = .standard, isPreview: Bool = false) {
        self.accountID = accountID
        self.isPreview = isPreview
        repository = AdventureSaveRepository(defaults: defaults, accountID: accountID)
        reload()
    }

    deinit { movement?.cancel(); rewardTimeout?.cancel() }

    var selectedNode: AdventureNode { AdventureWorld.node(selectedNodeID) ?? AdventureWorld.nodes[0] }
    var canMove: Bool { !isMoving && storyPlayback == nil && queuedStory == nil && loadError == nil && route(to: selectedNodeID) != nil }

    func route(to nodeID: Int) -> [Int]? {
#if DEBUG
        return progress.routeForDebug(to: nodeID)
#else
        return progress.route(to: nodeID)
#endif
    }

    func blockedReason(for nodeID: Int) -> String? {
        route(to: nodeID) != nil ? nil : progress.blockedReason(for: nodeID)
    }

    var mapRoutes: [[Int]] {
#if DEBUG
        return route(to: selectedNodeID).map { [$0] } ?? []
#else
        return progress.mapRoutes(selectedNodeID: selectedNodeID)
#endif
    }

    /// Restores a conversation before introducing another scene. A saved battle
    /// retains priority so dialogue never interrupts a quiz or its feedback.
    func presentStoryIfNeeded() {
        guard loadError == nil, progress.battle == nil, presentation == nil,
              storyPlayback == nil, queuedStory == nil, storyContinuation == nil, !isMoving else { return }
        if let bookmark = progress.story?.bookmark {
            storyContinuation = eventAfterStory(bookmark.scene)
            storyPlayback = AdventureStoryPlayback(bookmark: bookmark, isReplay: false)
        } else if !(progress.story?.completed.contains(.departure) ?? false) {
            beginStory(.departure)
        }
    }

    private func beginStory(_ scene: AdventureStoryScene, continuation: AdventurePresentation? = nil) {
        guard scene.isUnlocked(in: progress), progress.battle == nil, loadError == nil else { return }
        var story = progress.story ?? AdventureStoryProgress()
        let bookmark = AdventureStoryBookmark(scene: scene)
        story.bookmark = bookmark
        progress.story = story
        save()
        guard loadError == nil else { return }
        storyContinuation = continuation
        storyPlayback = AdventureStoryPlayback(bookmark: bookmark, isReplay: false)
    }

    /// Starts a new scene only after the currently presented event sheet has
    /// left the hierarchy. Presenting both at once can drop the full-screen
    /// dialogue on iOS, especially after claiming a key or finishing a battle.
    private func queueStory(_ scene: AdventureStoryScene, continuation: AdventurePresentation? = nil) {
        guard scene.isUnlocked(in: progress), progress.battle == nil, loadError == nil else { return }
        var story = progress.story ?? AdventureStoryProgress()
        let bookmark = AdventureStoryBookmark(scene: scene)
        story.bookmark = bookmark
        progress.story = story
        save()
        guard loadError == nil else { return }
        queuedStory = AdventureStoryPlayback(bookmark: bookmark, isReplay: false)
        storyContinuation = continuation
        presentation = nil
    }

    private func eventAfterStory(_ scene: AdventureStoryScene) -> AdventurePresentation? {
        switch scene {
        case .departure, .keyAcquired, .villageReturn:
            return nil
        case .guardianVictory:
            return .victory(scene.nodeID)
        case .entrance:
            // 森の入口は道のマス。会話のあとにシートを重ねず、そのまま地図へ戻す。
            return nil
        case .bridge, .port:
            return .encounter(scene.nodeID)
        case .firstEncounter, .shrine, .guardian:
            return progress.clearedNodeIDs.contains(scene.nodeID) ? nil : .encounter(scene.nodeID)
        }
    }

    func replayStory(_ scene: AdventureStoryScene) {
        guard scene.isUnlocked(in: progress), progress.battle == nil, !isMoving,
              storyPlayback == nil, loadError == nil else { return }
        queuedStory = AdventureStoryPlayback(bookmark: AdventureStoryBookmark(scene: scene), isReplay: true)
        storyContinuation = .journal
        // Wait for the sheet's dismissal before presenting a full-screen scene.
        presentation = nil
    }

    func eventDidDismiss() {
        if let queuedStory {
            self.queuedStory = nil
            storyPlayback = queuedStory
        } else {
            presentStoryIfNeeded()
        }
    }

    func advanceStory() {
        guard let playback = storyPlayback else { return }
        if playback.bookmark.page + 1 < playback.bookmark.scene.lines.count {
            setStoryPage(playback.bookmark.page + 1)
        } else {
            finishStory()
        }
    }

    func previousStoryPage() {
        guard let playback = storyPlayback, playback.bookmark.page > 0 else { return }
        setStoryPage(playback.bookmark.page - 1)
    }

    private func setStoryPage(_ page: Int) {
        guard var playback = storyPlayback, playback.bookmark.scene.lines.indices.contains(page) else { return }
        playback.bookmark.page = page
        if !playback.isReplay {
            progress.story?.bookmark = playback.bookmark
            save()
        }
        storyPlayback = playback
    }

    /// Skipping records the scene as read, but never grants game rewards or
    /// clears a map stop. Every unlocked scene remains available in the journal.
    func finishStory() {
        guard let playback = storyPlayback else { return }
        if !playback.isReplay {
            progress.story?.completed.insert(playback.bookmark.scene)
            progress.story?.bookmark = nil
            save()
        }
        storyPlayback = nil
    }

    func storyDidDismiss() {
        let continuation = storyContinuation
        storyContinuation = nil
        if loadError == nil { presentation = continuation }
    }

    func reload() {
        do {
            progress = try repository.load()
            loadError = nil
            applyLatestPlayerStats()
            migrateStoryForExistingSave()
            visualNodeID = progress.currentNodeID
            selectedNodeID = progress.currentNodeID == 0 ? 1 : progress.currentNodeID
            if progress.battle != nil { presentation = .battle }
        } catch { loadError = error.localizedDescription }
    }

#if DEBUG
    /// Development-only restart. This resets only the local AdventureProgress
    /// for the current account; quiz results, coins, and other app data stay intact.
    func restartStoryFromBeginningForDebug() {
        movement?.cancel()
        movement = nil
        rewardTimeout?.cancel()
        rewardTimeout = nil
        isMoving = false
        presentation = nil
        storyPlayback = nil
        queuedStory = nil
        storyContinuation = nil
        loadError = nil
        rewardMessage = nil

        let bookmark = AdventureStoryBookmark(scene: .departure)
        var freshProgress = AdventureProgress()
        freshProgress.story = AdventureStoryProgress(bookmark: bookmark)
        progress = freshProgress
        applyLatestPlayerStats()
        visualNodeID = freshProgress.currentNodeID
        selectedNodeID = 1
        save()

        guard loadError == nil else { return }
        queuedStory = AdventureStoryPlayback(bookmark: bookmark, isReplay: false)
    }
#endif

    /// A player who already crossed part of the map should not be forced back
    /// through the opening on update. Reached chapters are placed in the
    /// journal, while future trigger scenes still play normally.
    private func migrateStoryForExistingSave() {
        guard progress.story == nil else { return }
        let isUntouched = progress.currentNodeID == 0
            && progress.clearedNodeIDs == [0]
            && progress.battle == nil
            && !progress.hasKey
            && !progress.hasForestLight
        guard !isUntouched else { return }
        let reached = Set(AdventureStoryScene.allCases.filter { $0.wasReached(in: progress) })
        progress.story = AdventureStoryProgress(completed: reached)
        save()
    }

    private func save() {
        do { try repository.save(progress) }
        catch { loadError = "冒険の記録を保存できませんでした。画面を閉じずに、もう一度お試しください。" }
    }

    func move(reduceMotion: Bool) {
        guard canMove, let route = route(to: selectedNodeID) else { return }
        let target = selectedNodeID
        if target == progress.currentNodeID { inspectCurrentNode(); return }
        isMoving = true
        movement = Task { [weak self] in
            guard let self else { return }
            do {
                for id in route.dropFirst() {
                    try Task.checkCancellation()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.38)) { self.visualNodeID = id }
                    if !reduceMotion { try await Task.sleep(nanoseconds: 390_000_000) }
                }
#if DEBUG
                let arrived = self.progress.arriveForDebug(at: target)
#else
                let arrived = self.progress.arrive(at: target)
#endif
                guard arrived else { self.cancelMovement(); return }
                self.isMoving = false
                self.save()
                self.inspectCurrentNode()
            } catch { self.isMoving = false; self.visualNodeID = self.progress.currentNodeID }
        }
    }

    func cancelMovement() {
        movement?.cancel()
        movement = nil
        isMoving = false
        visualNodeID = progress.currentNodeID
    }

    func inspectCurrentNode() {
        let node = progress.currentNode
        if progress.battle != nil { presentation = .battle; return }
        if node.id == 0, progress.hasForestLight,
           !(progress.story?.completed.contains(.villageReturn) ?? false) {
            beginStory(.villageReturn)
            return
        }
        if let scene = AdventureStoryScene.arriving(at: node.id),
           !(progress.story?.completed.contains(scene) ?? false) {
            beginStory(scene, continuation: eventAfterStory(scene))
            return
        }
        // 道のマスは読むだけの内容しか無く、進むたびにシートが挟まると冒険が止まる。
        // マップのフッターに同じ説明が出ているので、シートは開かない。
        if node.kind == .road { return }
        if progress.clearedNodeIDs.contains(node.id), ![.village, .camp, .bridge, .port].contains(node.kind) { return }
        presentation = node.kind == .treasure ? .treasure(node.id) : .encounter(node.id)
    }

    func openTreasure() {
        guard progress.collectTreasure() else { return }
        save()
        presentation = .reward(progress.currentNodeID)
        AudioManager.shared.playTittleSound()
        syncRewards()
    }

    func takeKey() {
        guard progress.collectKey() else { return }
        save()
        presentation = nil
    }
    func usePotion() { if progress.usePotion() { save() } }
    func changeCourse(_ course: AdventureCourse) {
        guard progress.battle == nil else { return }
        progress.course = course
        save()
    }

    func startBattle() {
        guard hasLoadedPlayerStats || progress.battle != nil else { return }
        applyLatestPlayerStats()
        // The current story map is Chapter 1. Encounters in this area always
        // teach IT Passport material; the player never has to choose a quiz
        // category before a battle.
        let course: AdventureCourse = .itPassport
        progress.course = course
        let questions = isPreview ? AdventureQuizBank.preview : AdventureQuizBank.questions(for: course).shuffled()
        if progress.startBattle(questions: Array(questions.prefix(20))) {
            save()
            presentation = .battle
        }
    }

    func answer(_ index: Int, playsFeedbackSound: Bool = true) {
        guard let question = progress.battle?.currentQuestion, let correct = progress.answer(index) else { return }
        save()
        if playsFeedbackSound {
            if correct { AudioManager.shared.playCorrectSound() } else { AudioManager.shared.playUnCorrectSound() }
        }
        guard !isPreview, AuthManager.shared.currentUserId == accountID else { return }
        AuthManager.shared.recordAnswer(isCorrect: correct)
        if !correct {
            let level = AdventureQuizBank.level(for: progress.course)
            let answer = IncorrectAnswer(userId: accountID, quizQuestion: question.question, choices: question.choices,
                                         correctAnswerIndex: question.correctAnswerIndex, explanation: question.explanation,
                                         sourceQuizLevel: level.description)
            _ = LocalIncorrectAnswerStore.save(answer, quizLevel: level)
        }
    }

    func nextQuestion() {
        let nodeID = progress.currentNodeID
        switch progress.advanceBattle() {
        case .question: break
        case .victory:
            AudioManager.shared.playGameClearSound()
            if !isPreview, AuthManager.shared.currentUserId == accountID {
                AuthManager.shared.recordStoryCompleted(isBoss: nodeID == 9)
            }
            if nodeID == 9, !(progress.story?.completed.contains(.guardianVictory) ?? false) {
                queueStory(.guardianVictory, continuation: .victory(nodeID))
            } else {
                presentation = .victory(nodeID)
            }
        case .defeat:
            visualNodeID = progress.currentNodeID
            selectedNodeID = progress.currentNodeID
            presentation = .defeat
        case .unavailable: return
        }
        applyLatestPlayerStats()
        save()
        syncRewards()
    }

    func retreat() {
        progress.retreat()
        applyLatestPlayerStats()
        visualNodeID = progress.currentNodeID
        selectedNodeID = progress.currentNodeID
        save()
        presentation = nil
    }

    /// The durable local receipt is acknowledged only after the app's existing
    /// idempotent Firebase reward transaction succeeds. Offline retries use the
    /// same chapter/node key, so reopening or reinstalling cannot duplicate coins.
    func syncRewards() {
        guard !isPreview, loadError == nil, !isDeliveringRewards,
              AuthManager.shared.currentUserId == accountID,
              ConnectivityMonitor.shared.isConnected,
              let id = progress.pendingRewardIDs.first,
              let node = AdventureWorld.node(id) else { return }
        isDeliveringRewards = true
        rewardMessage = nil
        let attempt = UUID()
        rewardAttempt = attempt
        rewardTimeout?.cancel()
        rewardTimeout = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            guard !Task.isCancelled, let self, self.rewardAttempt == attempt else { return }
            self.isDeliveringRewards = false
            self.rewardMessage = "報酬は保管されています。接続後に受け取れます。"
            self.rewardAttempt = UUID()
        }
        AuthManager.shared.grantRewardBundle(idempotencyKey: AdventureWorld.rewardKey(for: id), coinAmount: node.coins, itemRewards: []) { [weak self] success in
            Task { @MainActor in
                guard let self, self.rewardAttempt == attempt else { return }
                self.rewardTimeout?.cancel()
                self.isDeliveringRewards = false
                guard AuthManager.shared.currentUserId == self.accountID else { return }
                if success {
                    self.progress.acknowledgeReward(id)
                    self.save()
                    self.syncRewards()
                } else {
                    self.rewardMessage = "報酬は保管されています。もう一度受け取れます。"
                }
            }
        }
    }
}

enum AdventureQuizBank {
    // Bridge to the app's existing offline question collections; their views
    // are never mounted, so no quiz screens or ad requests are presented here.
    @MainActor static func questions(for course: AdventureCourse) -> [AdventureQuestion] {
        let source: [QuizQuestion]
        switch course {
        case .itPassport: source = QuizITBasicList(isPresenting: .constant(false)).quizBeginnerList
        case .fundamental: source = QuizInfoBasicListView(isPresenting: .constant(false)).quizBeginnerList
        case .applied: source = QuizAppliedBasicListView(isPresenting: .constant(false)).quizBeginnerList
        }
        return source.enumerated().map { index, question in
            AdventureQuestion(id: "\(course.rawValue)-\(index)", question: question.question, choices: question.choices,
                              correctAnswerIndex: question.correctAnswerIndex, explanation: question.explanation)
        }.filter(\.isValid)
    }

    static func level(for course: AdventureCourse) -> QuizLevel {
        switch course { case .itPassport: return .itBasic; case .fundamental: return .infoBasic; case .applied: return .appliedBasic }
    }

    static let preview: [AdventureQuestion] = [
        .init(id: "preview-ram", question: "メモリ（RAM）の主な役割は？", choices: ["作業中のデータを一時的に置く", "紙に文字を印刷する", "電気をためる"], correctAnswerIndex: 0, explanation: "メモリは、処理に使うデータを一時的に保存する作業場所です。"),
        .init(id: "preview-password", question: "アカウントを守る方法は？", choices: ["同じパスワードを使い回す", "サービスごとに別のパスワードを使う", "誕生日をパスワードにする"], correctAnswerIndex: 1, explanation: "使い回しを避けると、1つのサービスから漏れても被害が広がりにくくなります。"),
        .init(id: "preview-backup", question: "バックアップの主な目的は？", choices: ["画面を明るくする", "通信速度を上げる", "失ったデータを復元できるようにする"], correctAnswerIndex: 2, explanation: "別の場所にコピーを保存し、故障や誤操作によるデータの消失に備えます。")
    ]
}
