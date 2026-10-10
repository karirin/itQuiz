import Foundation

/// Course IDs are independent of the auto-generated IDs in the old incorrect-answer stores.
struct CourseQuestion: Codable, Equatable, Identifiable {
    let id: String
    let prompt: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String

    var isValid: Bool {
        !id.isEmpty && !prompt.isEmpty && choices.count >= 2
            && Set(choices).count == choices.count && choices.indices.contains(correctIndex)
            && !explanation.isEmpty
    }
}

struct WeaknessCourseTopic: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let lesson: String
    /// Append only: the position is part of the stable legacy-source ID.
    let sourcePrompts: [String]
    let practice: [CourseQuestion]
    let checks: [CourseQuestion]
}

enum CourseStage: String, Codable {
    case needsPractice, waiting, mastered
}

struct CourseProgress: Codable, Equatable {
    var stage: CourseStage = .needsPractice
    var sourceQuestion: CourseQuestion?
    var lastSelectedIndex: Int?
    var mistakeCount = 0
    var confirmedCount = 0
    var nextReviewAt: Date?
    var masteredAt: Date?
    var updatedAt: Date
    var questionHistory: [String: CourseQuestionHistory] = [:]

    private enum CodingKeys: String, CodingKey {
        case stage, sourceQuestion, sourceQuestionID, lastSelectedIndex, mistakeCount, confirmedCount
        case nextReviewAt, masteredAt, updatedAt, questionHistory, questionHistoryEntries
    }

    private struct HistoryEntry: Codable {
        let questionID: String
        let history: CourseQuestionHistory
    }

    init(stage: CourseStage = .needsPractice, sourceQuestion: CourseQuestion? = nil,
         lastSelectedIndex: Int? = nil, mistakeCount: Int = 0, confirmedCount: Int = 0,
         nextReviewAt: Date? = nil, masteredAt: Date? = nil, updatedAt: Date,
         questionHistory: [String: CourseQuestionHistory] = [:]) {
        self.stage = stage; self.sourceQuestion = sourceQuestion; self.lastSelectedIndex = lastSelectedIndex
        self.mistakeCount = mistakeCount; self.confirmedCount = confirmedCount
        self.nextReviewAt = nextReviewAt; self.masteredAt = masteredAt; self.updatedAt = updatedAt
        self.questionHistory = questionHistory
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        stage = try c.decode(CourseStage.self, forKey: .stage)
        sourceQuestion = try c.decodeIfPresent(CourseQuestion.self, forKey: .sourceQuestion)
        if sourceQuestion == nil, let id = try c.decodeIfPresent(String.self, forKey: .sourceQuestionID) {
            sourceQuestion = CourseQuestionIndex.question(id)
            guard sourceQuestion != nil else {
                throw DecodingError.dataCorruptedError(forKey: .sourceQuestionID, in: c, debugDescription: "Unknown course source ID")
            }
        }
        lastSelectedIndex = try c.decodeIfPresent(Int.self, forKey: .lastSelectedIndex)
        mistakeCount = try c.decode(Int.self, forKey: .mistakeCount)
        confirmedCount = try c.decode(Int.self, forKey: .confirmedCount)
        nextReviewAt = try c.decodeIfPresent(Date.self, forKey: .nextReviewAt)
        masteredAt = try c.decodeIfPresent(Date.self, forKey: .masteredAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        questionHistory = try c.decodeIfPresent([String: CourseQuestionHistory].self, forKey: .questionHistory) ?? [:]
        if let entries = try c.decodeIfPresent([HistoryEntry].self, forKey: .questionHistoryEntries) {
            for entry in entries { questionHistory[entry.questionID] = entry.history }
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(stage, forKey: .stage)
        if encoder.userInfo[CourseCloudCodec.compactKey] as? Bool == true,
           let sourceQuestion, CourseQuestionIndex.question(sourceQuestion.id) == sourceQuestion {
            try c.encode(sourceQuestion.id, forKey: .sourceQuestionID)
        } else {
            // Retired/edited question editions retain their explanation instead of losing it.
            try c.encodeIfPresent(sourceQuestion, forKey: .sourceQuestion)
        }
        try c.encodeIfPresent(lastSelectedIndex, forKey: .lastSelectedIndex)
        try c.encode(mistakeCount, forKey: .mistakeCount)
        try c.encode(confirmedCount, forKey: .confirmedCount)
        try c.encodeIfPresent(nextReviewAt, forKey: .nextReviewAt)
        try c.encodeIfPresent(masteredAt, forKey: .masteredAt)
        try c.encode(updatedAt, forKey: .updatedAt)
        if encoder.userInfo[CourseCloudCodec.compactKey] as? Bool == true {
            // Firebase rejects dots in dictionary keys. Keep stable IDs as values,
            // while preserving the existing dictionary format in local storage.
            let entries = questionHistory.sorted { $0.key < $1.key }
                .map { HistoryEntry(questionID: $0.key, history: $0.value) }
            try c.encode(entries, forKey: .questionHistoryEntries)
        } else {
            try c.encode(questionHistory, forKey: .questionHistory)
        }
    }

    func isDue(at now: Date) -> Bool {
        stage == .waiting && (nextReviewAt ?? .distantFuture) <= now
    }
}

struct CourseFreeClaim: Codable, Equatable {
    let topicID: String
    let claimedAt: Date
}

struct CourseCloudState: Codable, Equatable {
    var progress: [String: CourseProgress] = [:]
    var freeClaim: CourseFreeClaim?
    var importedSourceIDs: [String] = []

    init() {}

    private enum CodingKeys: String, CodingKey { case progress, freeClaim, importedSourceIDs }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Realtime Database removes empty dictionaries and arrays.
        progress = try container.decodeIfPresent([String: CourseProgress].self, forKey: .progress) ?? [:]
        freeClaim = try container.decodeIfPresent(CourseFreeClaim.self, forKey: .freeClaim)
        importedSourceIDs = try container.decodeIfPresent([String].self, forKey: .importedSourceIDs) ?? []
    }

    /// Merge per theme, not the whole account. A new result on one device must not
    /// overwrite another device's work on a different theme. The earliest free claim wins.
    func merging(_ other: Self) -> Self {
        var merged = self
        for (id, incoming) in other.progress {
            if let current = merged.progress[id], current.updatedAt >= incoming.updatedAt { continue }
            merged.progress[id] = incoming
        }
        if let incoming = other.freeClaim {
            if let current = freeClaim {
                if incoming.claimedAt < current.claimedAt
                    || (incoming.claimedAt == current.claimedAt && incoming.topicID < current.topicID) {
                    merged.freeClaim = incoming
                }
            } else {
                merged.freeClaim = incoming
            }
        }
        merged.importedSourceIDs = Array(Set(importedSourceIDs + other.importedSourceIDs)).sorted()
        return merged
    }

    func canAccess(_ topicID: String, subscribed: Bool) -> Bool {
        subscribed || freeClaim == nil || freeClaim?.topicID == topicID
    }
}

enum CourseSessionKind: String, Codable {
    case practice, confirmation
}

struct CourseSession: Codable, Equatable, Identifiable {
    var id = UUID().uuidString
    let topicID: String
    let kind: CourseSessionKind
    let confirmedCountAtStart: Int
    let progressUpdatedAtStart: Date
    let questions: [CourseQuestion]
    let startedAt: Date
    var answers: [String: Int] = [:]
    /// A separate cursor lets a resumed session keep showing the explanation
    /// until the learner explicitly chooses to continue.
    var questionIndex = 0

    var isComplete: Bool { questionIndex == questions.count && answers.count == questions.count }
    var correctCount: Int { questions.filter { answers[$0.id] == $0.correctIndex }.count }
    var currentQuestion: CourseQuestion? { questions.indices.contains(questionIndex) ? questions[questionIndex] : nil }

    mutating func answer(_ index: Int) {
        guard let question = currentQuestion, answers[question.id] == nil,
              index == -1 || question.choices.indices.contains(index) else { return }
        answers[question.id] = index
    }

    mutating func advance() {
        guard let question = currentQuestion, answers[question.id] != nil else { return }
        questionIndex += 1
    }
}

struct CourseCompletion: Equatable {
    let topicID: String
    let correctCount: Int
    let questionCount: Int
    let kind: CourseSessionKind
    let progress: CourseProgress
    var passed: Bool { correctCount == questionCount }
}

/// Presents problem reviews and theme practice together without changing either progress record.
struct WeaknessRecoveryOverview {
    let dueTopicIDs: [String]
    let practiceTopicIDs: [String]
    let masteredTopicIDs: [String]
    let nextConfirmationAt: Date?

    init(state: CourseCloudState, now: Date) {
        let known = Set(WeaknessCourseCatalog.topics.map(\.id))
        let progress = state.progress.filter { known.contains($0.key) }
        dueTopicIDs = progress.filter { $0.value.isDue(at: now) }.sorted {
            let left = $0.value.nextReviewAt ?? .distantFuture
            let right = $1.value.nextReviewAt ?? .distantFuture
            return left == right ? $0.key < $1.key : left < right
        }.map(\.key)
        practiceTopicIDs = progress.filter { $0.value.stage == .needsPractice }.map(\.key).sorted()
        masteredTopicIDs = progress.filter { $0.value.stage == .mastered }.map(\.key).sorted()
        nextConfirmationAt = progress.values.filter { $0.stage == .waiting }
            .compactMap(\.nextReviewAt).filter { $0 > now }.min()
    }

    static func topic(for question: QuizQuestion) -> WeaknessCourseTopic? {
        guard let source = WeaknessCourseCatalog.source(prompt: question.question, choices: question.choices,
            correctIndex: question.correctAnswerIndex, explanation: question.explanation), source.question.isValid else {
            return nil
        }
        return WeaknessCourseCatalog.topic(source.topicID)
    }
}

struct CourseAccountState: Codable, Equatable {
    var cloud = CourseCloudState()
    var activeSession: CourseSession?
    var completedSessionIDs: [String] = []

    mutating func recordMistake(topicID: String, question: CourseQuestion, selectedIndex: Int?, now: Date) {
        guard question.isValid else { return }
        var progress = cloud.progress[topicID] ?? CourseProgress(updatedAt: now)
        progress.stage = .needsPractice
        progress.sourceQuestion = question
        progress.lastSelectedIndex = selectedIndex
        progress.mistakeCount += 1
        var history = progress.questionHistory[question.id] ?? CourseQuestionHistory(lastSeenAt: now)
        history.lastSeenAt = now
        history.incorrectCount += 1
        progress.questionHistory[question.id] = history
        progress.confirmedCount = 0
        progress.nextReviewAt = nil
        progress.masteredAt = nil
        progress.updatedAt = max(now, progress.updatedAt.addingTimeInterval(0.001))
        cloud.progress[topicID] = progress
        // A subsequent real mistake invalidates an unfinished course on the same theme.
        if activeSession?.topicID == topicID { activeSession = nil }
        if !cloud.importedSourceIDs.contains(question.id) { cloud.importedSourceIDs.append(question.id) }
    }

    mutating func importMistake(topicID: String, question: CourseQuestion, now: Date) {
        guard !cloud.importedSourceIDs.contains(question.id), question.isValid else { return }
        cloud.importedSourceIDs.append(question.id)
        // Importing historical data must never undo a course already in progress.
        guard cloud.progress[topicID] == nil else { return }
        cloud.progress[topicID] = CourseProgress(sourceQuestion: question, mistakeCount: 1, updatedAt: now)
    }

    /// Returns nil for a locked theme, a future review, or an already mastered theme.
    mutating func begin(topic: WeaknessCourseTopic, subscribed: Bool, now: Date) -> CourseSession? {
        guard cloud.canAccess(topic.id, subscribed: subscribed) else { return nil }
        if let activeSession, activeSession.topicID == topic.id,
           activeSession.progressUpdatedAtStart == cloud.progress[topic.id]?.updatedAt {
            if !subscribed && cloud.freeClaim == nil {
                cloud.freeClaim = CourseFreeClaim(topicID: topic.id, claimedAt: now)
            }
            return activeSession
        }
        let progress = cloud.progress[topic.id] ?? CourseProgress(updatedAt: now)
        guard progress.stage == .needsPractice || progress.isDue(at: now) else { return nil }
        let kind: CourseSessionKind = progress.isDue(at: now) ? .confirmation : .practice
        let questions = CourseQuestionIndex.select(topic: topic, kind: kind,
                                                   original: progress.sourceQuestion, history: progress.questionHistory)
        guard !questions.isEmpty, questions.allSatisfy(\.isValid),
              Set(questions.map(\.id)).count == questions.count else { return nil }
        if !subscribed && cloud.freeClaim == nil {
            cloud.freeClaim = CourseFreeClaim(topicID: topic.id, claimedAt: now)
        }
        cloud.progress[topic.id] = progress
        let session = CourseSession(topicID: topic.id, kind: kind,
                                    confirmedCountAtStart: progress.confirmedCount,
                                    progressUpdatedAtStart: progress.updatedAt,
                                    questions: questions, startedAt: now)
        activeSession = session
        return session
    }

    mutating func finish(sessionID: String, now: Date, calendar: Calendar = .current) -> CourseCompletion? {
        guard let session = activeSession, session.id == sessionID, session.isComplete,
              !completedSessionIDs.contains(session.id),
              var progress = cloud.progress[session.topicID],
              progress.updatedAt == session.progressUpdatedAtStart else { return nil }
        for question in session.questions {
            var history = progress.questionHistory[question.id] ?? CourseQuestionHistory(lastSeenAt: session.startedAt)
            history.lastSeenAt = max(history.lastSeenAt, session.startedAt)
            if session.answers[question.id] == question.correctIndex { history.correctCount += 1 }
            else { history.incorrectCount += 1 }
            progress.questionHistory[question.id] = history
        }
        if session.correctCount < session.questions.count {
            progress.stage = .needsPractice
            progress.confirmedCount = 0
            progress.nextReviewAt = nil
            progress.masteredAt = nil
        } else if session.kind == .practice {
            progress.stage = .waiting
            progress.confirmedCount = 0
            progress.nextReviewAt = calendar.date(byAdding: .day, value: 1, to: now)
        } else {
            progress.confirmedCount = session.confirmedCountAtStart + 1
            if progress.confirmedCount >= 2 {
                progress.stage = .mastered
                progress.nextReviewAt = nil
                progress.masteredAt = now
            } else {
                progress.stage = .waiting
                progress.nextReviewAt = calendar.date(byAdding: .day, value: 3, to: now)
            }
        }
        progress.updatedAt = max(now, progress.updatedAt.addingTimeInterval(0.001))
        cloud.progress[session.topicID] = progress
        completedSessionIDs = Array((completedSessionIDs + [session.id]).suffix(100))
        activeSession = nil
        return CourseCompletion(topicID: session.topicID, correctCount: session.correctCount,
                                questionCount: session.questions.count, kind: session.kind, progress: progress)
    }
}

enum CourseLocalPersistence {
    static func key(userID: String) -> String { "weaknessCourses.v1.\(userID)" }

    static func load(userID: String, defaults: UserDefaults = .standard) -> CourseAccountState {
        guard let data = defaults.data(forKey: key(userID: userID)),
              let state = try? JSONDecoder().decode(CourseAccountState.self, from: data) else { return CourseAccountState() }
        return state
    }

    static func save(_ state: CourseAccountState, userID: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key(userID: userID))
    }
}
