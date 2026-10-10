//
//  ReviewScheduleService.swift
//  it
//
//  忘却曲線ベースの復習スケジュールを管理します。
//

import Foundation
import FirebaseDatabase

struct ReviewScheduleSummary {
    let dueCount: Int
    let totalCount: Int
    let nextReviewDate: Date?
    let firstReviewCount: Int
    let secondReviewCount: Int
    let finalReviewCount: Int
    let masteredCount: Int
    let reviewStreak: Int

    init(
        dueCount: Int,
        totalCount: Int,
        nextReviewDate: Date?,
        firstReviewCount: Int = 0,
        secondReviewCount: Int = 0,
        finalReviewCount: Int = 0,
        masteredCount: Int = 0,
        reviewStreak: Int = 0
    ) {
        self.dueCount = dueCount
        self.totalCount = totalCount
        self.nextReviewDate = nextReviewDate
        self.firstReviewCount = firstReviewCount
        self.secondReviewCount = secondReviewCount
        self.finalReviewCount = finalReviewCount
        self.masteredCount = masteredCount
        self.reviewStreak = reviewStreak
    }
}

struct MasteredReviewQuestion: Identifiable {
    let id: String
    let question: String
    let explanation: String
    let masteredAt: Date
    let sourceQuizLevel: String?
}

enum ReviewScheduleService {
    static let incorrectAnswersPath = "IncorrectAnswers"
    static let masteredAnswersPath = "MasteredAnswers"
    static let reviewActivityPath = "ReviewActivity"
    private static let testQuestionIdPrefix = "codexReview"

    private static let day: TimeInterval = 24 * 60 * 60
    private static let firstReviewInterval = day
    private static let nextIntervals: [TimeInterval] = [3 * day, 7 * day]

    static func saveIncorrectAnswer(
        _ answer: IncorrectAnswer,
        now: Date = Date(),
        completion: ((Bool) -> Void)? = nil
    ) {
        let answersRef = Database.database().reference()
            .child(incorrectAnswersPath)
            .child(answer.userId)

        answersRef.observeSingleEvent(of: .value) { snapshot in
            let existing = snapshot.children.compactMap { $0 as? DataSnapshot }.first { child in
                guard let value = child.value as? [String: Any] else { return false }
                return value["quizQuestion"] as? String == answer.quizQuestion
            }
            let answerRef = existing?.ref ?? answersRef.childByAutoId()
            let nowMilliseconds = milliseconds(from: now)

            var values: [String: Any] = [
                "quizQuestion": answer.quizQuestion,
                "choices": answer.choices,
                "correctAnswerIndex": answer.correctAnswerIndex,
                "explanation": answer.explanation,
                "reviewStage": 0,
                "nextReviewAt": nowMilliseconds + Int64(firstReviewInterval * 1_000),
                "lastAnsweredAt": nowMilliseconds
            ]
            if let sourceQuizLevel = answer.sourceQuizLevel {
                values["sourceQuizLevel"] = sourceQuizLevel
            }
            if existing == nil {
                values["createdAt"] = nowMilliseconds
            }

            answerRef.updateChildValues(values) { error, _ in
                completion?(error == nil)
            }
        } withCancel: { _ in
            completion?(false)
        }
    }

    static func fetchDueQuestions(
        userId: String,
        now: Date = Date(),
        questionIdPrefix: String? = nil,
        completion: @escaping (Result<[QuizQuestion], Error>) -> Void
    ) {
        answersReference(userId: userId).observeSingleEvent(of: .value) { snapshot in
            let nowMilliseconds = milliseconds(from: now)
            var imports: [(QuizQuestion, LocalReviewProgress, Date)] = []
            let questions = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .compactMap { snapshot -> (QuizQuestion, Int64)? in
                    if let questionIdPrefix,
                       !snapshot.key.hasPrefix(questionIdPrefix) {
                        return nil
                    }
                    if questionIdPrefix == nil,
                       snapshot.key.hasPrefix(testQuestionIdPrefix) {
                        return nil
                    }
                    guard let value = snapshot.value as? [String: Any],
                          let question = quizQuestion(from: value, id: snapshot.key) else {
                        return nil
                    }
                    // reviewStage/nextReviewAt がない旧データは、すぐ復習できる状態として扱う。
                    let nextReviewAt = int64(value["nextReviewAt"]) ?? 0
                    if questionIdPrefix == nil {
                        var progress = LocalReviewProgress(nextReviewAt: Date(timeIntervalSince1970: Double(nextReviewAt) / 1000))
                        progress.stage = int(value["reviewStage"]) ?? 0
                        imports.append((question, progress,
                            Date(timeIntervalSince1970: Double(int64(value["lastAnsweredAt"]) ?? 0) / 1000)))
                    }
                    return (question, nextReviewAt)
                }
                .filter { $0.1 <= nowMilliseconds }
                .sorted { $0.1 < $1.1 }
                .map(\.0)
            if questionIdPrefix == nil { LocalReviewScheduleStore.importRemoteBatch(imports, userID: userId) }
            completion(.success(questionIdPrefix == nil
                ? LocalReviewScheduleStore.dueQuestions(userID: userId, now: now) : questions))
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    static func fetchSummary(
        userId: String,
        now: Date = Date(),
        questionIdPrefix: String? = nil,
        completion: @escaping (ReviewScheduleSummary) -> Void
    ) {
        if questionIdPrefix == nil {
            LocalIncorrectAnswerStore.migrateSchedules(userId: userId)
            fetchDueQuestions(userId: userId, now: now) { _ in
                fetchMasteredQuestions(userId: userId) { _ in
                    fetchReviewStreak(userId: userId, now: now, includeDebugData: false) { _ in
                        completion(localSummary(userId: userId, now: now))
                    }
                }
            }
            return
        }
        answersReference(userId: userId).observeSingleEvent(of: .value) { snapshot in
            let nowMilliseconds = milliseconds(from: now)
            let scheduledItems = snapshot.children.compactMap { child -> (date: Int64, stage: Int)? in
                guard let snapshot = child as? DataSnapshot,
                      let value = snapshot.value as? [String: Any] else { return nil }
                if let questionIdPrefix,
                   !snapshot.key.hasPrefix(questionIdPrefix) {
                    return nil
                }
                if questionIdPrefix == nil,
                   snapshot.key.hasPrefix(testQuestionIdPrefix) {
                    return nil
                }
                return (int64(value["nextReviewAt"]) ?? 0, int(value["reviewStage"]) ?? 0)
            }
            let dueItems = scheduledItems.filter { $0.date <= nowMilliseconds }
            let nextDate = scheduledItems
                .map(\.date)
                .filter { $0 > nowMilliseconds }
                .min()
                .map { Date(timeIntervalSince1970: TimeInterval($0) / 1_000) }

            fetchMasteredCount(userId: userId, questionIdPrefix: questionIdPrefix) { masteredCount in
                fetchReviewStreak(userId: userId, now: now, includeDebugData: questionIdPrefix != nil) { streak in
                    completion(
                        ReviewScheduleSummary(
                            dueCount: dueItems.count,
                            totalCount: scheduledItems.count,
                            nextReviewDate: nextDate,
                            firstReviewCount: dueItems.filter { $0.stage <= 0 }.count,
                            secondReviewCount: dueItems.filter { $0.stage == 1 }.count,
                            finalReviewCount: dueItems.filter { $0.stage >= 2 }.count,
                            masteredCount: masteredCount,
                            reviewStreak: streak
                        )
                    )
                }
            }
        } withCancel: { _ in
            completion(ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil))
        }
    }

    static func recordCorrectReview(
        userId: String,
        questionId: String,
        now: Date = Date(),
        completion: ((Bool) -> Void)? = nil
    ) {
        let answerRef = answersReference(userId: userId).child(questionId)
        let nowMilliseconds = milliseconds(from: now)
        answerRef.observeSingleEvent(of: .value) { snapshot in
            guard var value = snapshot.value as? [String: Any] else {
                completion?(false)
                return
            }

            let currentStage = int(value["reviewStage"]) ?? 0
            if currentStage >= nextIntervals.count {
                value["reviewStage"] = nextIntervals.count + 1
                value["lastAnsweredAt"] = nowMilliseconds
                value["masteredAt"] = nowMilliseconds

                let rootRef = Database.database().reference()
                rootRef.updateChildValues([
                    "\(incorrectAnswersPath)/\(userId)/\(questionId)": NSNull(),
                    "\(masteredAnswersPath)/\(userId)/\(questionId)": value
                ]) { error, _ in
                    guard error == nil else {
                        completion?(false)
                        return
                    }
                    if !questionId.hasPrefix(testQuestionIdPrefix) {
                        MissionManager.shared.updateMissionProgress(type: .review, increment: 1) { _ in }
                        GuildManager.shared.recordReviewCompleted()
                        markReviewDayIfCompleted(userId: userId, now: now)
                    }
                    completion?(true)
                }
            } else {
                let nextStage = currentStage + 1
                value["reviewStage"] = nextStage
                value["lastAnsweredAt"] = nowMilliseconds
                value["nextReviewAt"] = nowMilliseconds + Int64(nextIntervals[currentStage] * 1_000)
                answerRef.setValue(value) { error, _ in
                    if error == nil, !questionId.hasPrefix(testQuestionIdPrefix) {
                        markReviewDayIfCompleted(userId: userId, now: now)
                    }
                    completion?(false)
                }
            }
        } withCancel: { _ in
            completion?(false)
        }
    }

    static func recordIncorrectReview(
        userId: String,
        questionId: String,
        now: Date = Date(),
        completion: ((Bool) -> Void)? = nil
    ) {
        let nowMilliseconds = milliseconds(from: now)
        answersReference(userId: userId).child(questionId).updateChildValues([
            "reviewStage": 0,
            "nextReviewAt": nowMilliseconds + Int64(firstReviewInterval * 1_000),
            "lastAnsweredAt": nowMilliseconds
        ]) { error, _ in
            if error == nil, !questionId.hasPrefix(testQuestionIdPrefix) {
                markReviewDayIfCompleted(userId: userId, now: now)
            }
            completion?(error == nil)
        }
    }

    static func fetchMasteredQuestions(
        userId: String,
        completion: @escaping (Result<[MasteredReviewQuestion], Error>) -> Void
    ) {
        masteredAnswersReference(userId: userId).observeSingleEvent(of: .value) { snapshot in
            var imports: [(QuizQuestion, LocalReviewProgress, Date)] = []
            let questions = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .filter { !$0.key.hasPrefix(testQuestionIdPrefix) }
                .compactMap { snapshot -> MasteredReviewQuestion? in
                    guard let value = snapshot.value as? [String: Any],
                          let question = value["quizQuestion"] as? String,
                          let explanation = value["explanation"] as? String,
                          let masteredAt = int64(value["masteredAt"]) else {
                        return nil
                    }
                    if let source = quizQuestion(from: value, id: snapshot.key) {
                        var progress = LocalReviewProgress(nextReviewAt: .distantPast)
                        progress.stage = 3
                        progress.nextReviewAt = nil
                        progress.masteredAt = Date(timeIntervalSince1970: Double(masteredAt) / 1000)
                        imports.append((source, progress, progress.masteredAt ?? .distantPast))
                    }
                    return MasteredReviewQuestion(
                        id: snapshot.key,
                        question: question,
                        explanation: explanation,
                        masteredAt: Date(timeIntervalSince1970: TimeInterval(masteredAt) / 1_000),
                        sourceQuizLevel: value["sourceQuizLevel"] as? String
                    )
                }
                .sorted { $0.masteredAt > $1.masteredAt }
            LocalReviewScheduleStore.importRemoteBatch(imports, userID: userId)
            var combined = localMasteredQuestions(userId: userId)
            let prompts = Set(combined.map(\.question))
            combined += questions.filter { !prompts.contains($0.question) }
            completion(.success(combined.sorted { $0.masteredAt > $1.masteredAt }))
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    static func localSummary(userId: String, now: Date = Date()) -> ReviewScheduleSummary {
        let records = LocalReviewScheduleStore.records(userID: userId)
        let pending = records.filter { $0.progress.masteredAt == nil }
        let due = pending.filter { ($0.progress.nextReviewAt ?? .distantFuture) <= now }
        let next = pending.compactMap(\.progress.nextReviewAt).filter { $0 > now }.min()
        return ReviewScheduleSummary(dueCount: due.count, totalCount: pending.count, nextReviewDate: next,
            firstReviewCount: due.filter { $0.progress.stage == 0 }.count,
            secondReviewCount: due.filter { $0.progress.stage == 1 }.count,
            finalReviewCount: due.filter { $0.progress.stage >= 2 }.count,
            masteredCount: records.count - pending.count,
            reviewStreak: LocalReviewScheduleStore.reviewStreak(userID: userId, now: now))
    }

    static func syncLocalReview(_ question: QuizQuestion, userId: String, subscribed: Bool) {
        guard let record = LocalReviewScheduleStore.records(userID: userId).first(where: {
            ReviewAccessPolicy.key($0.question) == ReviewAccessPolicy.key(question)
        }), subscribed || record.remoteID != nil else { return }
        let id = record.remoteID ?? "local_\(record.id)"
        var values: [String: Any] = ["quizQuestion": record.question.question,
            "choices": record.question.choices, "correctAnswerIndex": record.question.correctAnswerIndex,
            "explanation": record.question.explanation, "reviewStage": record.progress.stage,
            "lastAnsweredAt": milliseconds(from: record.updatedAt ?? Date())]
        if let source = record.question.sourceQuizLevel { values["sourceQuizLevel"] = source }
        if let date = record.progress.nextReviewAt { values["nextReviewAt"] = milliseconds(from: date) }
        if let date = record.progress.masteredAt { values["masteredAt"] = milliseconds(from: date) }
        let updates: [String: Any]
        if record.progress.masteredAt != nil {
            updates = ["\(incorrectAnswersPath)/\(userId)/\(id)": NSNull(),
                       "\(masteredAnswersPath)/\(userId)/\(id)": values]
        } else {
            updates = ["\(incorrectAnswersPath)/\(userId)/\(id)": values]
        }
        Database.database().reference().updateChildValues(updates) { error, _ in
            if error == nil {
                LocalReviewScheduleStore.attachRemoteID(id, recordID: record.id, userID: userId)
                if LocalReviewScheduleStore.completedToday(userID: userId) {
                    reviewActivityReference(userId: userId).child(activityDateKey(from: Date()))
                        .setValue(["completedAt": milliseconds(from: Date())])
                }
            }
        }
    }

    static func localMasteredQuestions(userId: String) -> [MasteredReviewQuestion] {
        LocalReviewScheduleStore.records(userID: userId).compactMap { record in
            guard let date = record.progress.masteredAt else { return nil }
            return MasteredReviewQuestion(id: record.id, question: record.question.question,
                explanation: record.question.explanation, masteredAt: date, sourceQuizLevel: record.question.sourceQuizLevel)
        }.sorted { $0.masteredAt > $1.masteredAt }
    }

    private static func fetchMasteredCount(
        userId: String,
        questionIdPrefix: String?,
        completion: @escaping (Int) -> Void
    ) {
        masteredAnswersReference(userId: userId).observeSingleEvent(of: .value) { snapshot in
            let count = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .filter { child in
                    if let questionIdPrefix {
                        return child.key.hasPrefix(questionIdPrefix)
                    }
                    return !child.key.hasPrefix(testQuestionIdPrefix)
                }
                .count
            completion(count)
        } withCancel: { _ in
            completion(0)
        }
    }

    private static func markReviewDayIfCompleted(userId: String, now: Date) {
        fetchSummary(userId: userId, now: now) { summary in
            guard summary.dueCount == 0 else { return }
            reviewActivityReference(userId: userId)
                .child(activityDateKey(from: now))
                .setValue(["completedAt": milliseconds(from: now)])
        }
    }

    private static func fetchReviewStreak(
        userId: String,
        now: Date,
        includeDebugData: Bool,
        completion: @escaping (Int) -> Void
    ) {
        guard !includeDebugData else {
            completion(0)
            return
        }

        reviewActivityReference(userId: userId).observeSingleEvent(of: .value) { snapshot in
            let completedDays = Set(snapshot.children.compactMap { ($0 as? DataSnapshot)?.key })
            LocalReviewScheduleStore.importReviewDays(completedDays, userID: userId)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: now)
            var cursor = today

            if !completedDays.contains(activityDateKey(from: cursor)) {
                cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            }

            var streak = 0
            while completedDays.contains(activityDateKey(from: cursor)) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previousDay
            }
            completion(streak)
        } withCancel: { _ in
            completion(0)
        }
    }

    private static func activityDateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

#if DEBUG
    static let debugQuestionIdPrefix = "codexReview"

    enum DebugScenario: String, CaseIterable, Identifiable {
        case allStages
        case firstReview
        case secondReview
        case finalReview
        case waiting
        case legacy
        case empty

        var id: String { rawValue }

        var title: String {
            switch self {
            case .allStages: return "全ステージ"
            case .firstReview: return "1日後の復習"
            case .secondReview: return "3日後の復習"
            case .finalReview: return "7日後・克服直前"
            case .waiting: return "次回待ち"
            case .legacy: return "旧データ"
            case .empty: return "復習問題なし"
            }
        }

        var detail: String {
            switch self {
            case .allStages: return "期限到来3問と期限前1問をまとめて確認"
            case .firstReview: return "正解で次回を3日後に更新"
            case .secondReview: return "正解で次回を7日後に更新"
            case .finalReview: return "正解で克服・ミッション達成を確認"
            case .waiting: return "今日の復習完了と次回日時を確認"
            case .legacy: return "スケジュールがない既存問題を即時出題"
            case .empty: return "まだ復習問題がない状態を確認"
            }
        }

        var systemImage: String {
            switch self {
            case .allStages: return "square.stack.3d.up.fill"
            case .firstReview: return "1.circle.fill"
            case .secondReview: return "3.circle.fill"
            case .finalReview: return "7.circle.fill"
            case .waiting: return "clock.fill"
            case .legacy: return "clock.arrow.circlepath"
            case .empty: return "checkmark.seal.fill"
            }
        }
    }

    /// 実機で復習フローを確認するためのデータを、専用IDだけに投入します。
    static func seedDebugQuestions(
        userId: String,
        now: Date = Date(),
        completion: ((Bool) -> Void)? = nil
    ) {
        applyDebugScenario(.allStages, userId: userId, now: now, completion: completion)
    }

    static func applyDebugScenario(
        _ scenario: DebugScenario,
        userId: String,
        now: Date = Date(),
        completion: ((Bool) -> Void)? = nil
    ) {
        let nowMilliseconds = milliseconds(from: now)
        let hourMilliseconds: Int64 = 60 * 60 * 1_000
        let dayMilliseconds: Int64 = 24 * hourMilliseconds

        func question(
            text: String,
            choices: [String],
            correctAnswerIndex: Int,
            explanation: String,
            reviewStage: Int,
            nextReviewAt: Int64
        ) -> [String: Any] {
            [
                "quizQuestion": text,
                "choices": choices,
                "correctAnswerIndex": correctAnswerIndex,
                "explanation": explanation,
                "sourceQuizLevel": "network",
                "reviewStage": reviewStage,
                "nextReviewAt": nextReviewAt,
                "createdAt": nowMilliseconds,
                "lastAnsweredAt": nowMilliseconds
            ]
        }

        let stage0 = question(
                text: "【動作確認】OSI参照モデルで、ルーティングを担当する層はどれ？",
                choices: ["物理層", "データリンク層", "ネットワーク層", "アプリケーション層"],
                correctAnswerIndex: 2,
                explanation: "ルーティングは第3層のネットワーク層が担当します。正解すると次回は3日後です。",
                reviewStage: 0,
                nextReviewAt: nowMilliseconds - hourMilliseconds
            )
        let stage1 = question(
                text: "【動作確認】2進数の1010を10進数で表すとどれ？",
                choices: ["8", "10", "12", "16"],
                correctAnswerIndex: 1,
                explanation: "1010は8+2なので10です。正解すると次回は7日後です。",
                reviewStage: 1,
                nextReviewAt: nowMilliseconds - 2 * hourMilliseconds
            )
        let stage2 = question(
                text: "【動作確認】SQLでデータを取得する命令はどれ？",
                choices: ["SELECT", "INSERT", "UPDATE", "DELETE"],
                correctAnswerIndex: 0,
                explanation: "SELECTはデータを取得する命令です。正解すると苦手克服になります。",
                reviewStage: 2,
                nextReviewAt: nowMilliseconds - 3 * hourMilliseconds
            )
        let future = question(
                text: "【動作確認・期限前】HTTPの標準ポート番号はどれ？",
                choices: ["21", "25", "80", "443"],
                correctAnswerIndex: 2,
                explanation: "HTTPの標準ポート番号は80です。この問題は期限表示の確認用です。",
                reviewStage: 1,
                nextReviewAt: nowMilliseconds + dayMilliseconds
            )
        let legacy: [String: Any] = [
            "quizQuestion": "【動作確認・旧データ】CPUが直接実行できる言語はどれ？",
            "choices": ["機械語", "HTML", "SQL", "自然言語"],
            "correctAnswerIndex": 0,
            "explanation": "旧形式の問題は復習日時がないため、すぐに出題されます。"
        ]

        var updates: [AnyHashable: Any] = [
            "codexReviewDueStage0": NSNull(),
            "codexReviewDueStage1": NSNull(),
            "codexReviewDueStage2": NSNull(),
            "codexReviewFuture": NSNull(),
            "codexReviewLegacy": NSNull()
        ]

        switch scenario {
        case .allStages:
            updates["codexReviewDueStage0"] = stage0
            updates["codexReviewDueStage1"] = stage1
            updates["codexReviewDueStage2"] = stage2
            updates["codexReviewFuture"] = future
        case .firstReview:
            updates["codexReviewDueStage0"] = stage0
        case .secondReview:
            updates["codexReviewDueStage1"] = stage1
        case .finalReview:
            updates["codexReviewDueStage2"] = stage2
        case .waiting:
            updates["codexReviewFuture"] = future
        case .legacy:
            updates["codexReviewLegacy"] = legacy
        case .empty:
            break
        }

        answersReference(userId: userId).updateChildValues(updates) { error, _ in
            completion?(error == nil)
        }
    }
#endif

    private static func answersReference(userId: String) -> DatabaseReference {
        Database.database().reference().child(incorrectAnswersPath).child(userId)
    }

    private static func masteredAnswersReference(userId: String) -> DatabaseReference {
        Database.database().reference().child(masteredAnswersPath).child(userId)
    }

    private static func reviewActivityReference(userId: String) -> DatabaseReference {
        Database.database().reference().child(reviewActivityPath).child(userId)
    }

    private static func quizQuestion(from value: [String: Any], id: String) -> QuizQuestion? {
        guard let question = value["quizQuestion"] as? String,
              let choices = value["choices"] as? [String],
              let correctAnswerIndex = int(value["correctAnswerIndex"]),
              let explanation = value["explanation"] as? String else {
            return nil
        }
        return QuizQuestion(
            id: id,
            question: question,
            choices: choices,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            sourceQuizLevel: value["sourceQuizLevel"] as? String
        )
    }

    private static func milliseconds(from date: Date) -> Int64 {
        Int64(date.timeIntervalSince1970 * 1_000)
    }

    private static func int(_ value: Any?) -> Int? {
        if let value = value as? Int { return value }
        if let value = value as? NSNumber { return value.intValue }
        return nil
    }

    private static func int64(_ value: Any?) -> Int64? {
        if let value = value as? Int64 { return value }
        if let value = value as? Int { return Int64(value) }
        if let value = value as? NSNumber { return value.int64Value }
        return nil
    }
}
