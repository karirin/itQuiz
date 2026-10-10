import Foundation

/// All question-review entry points share this daily allowance. Course sessions have their own entitlement.
enum ReviewAccessPolicy {
    static let dailyFreeLimit = DailyReviewStore.dailyQuestionLimit
    private static let lock = NSLock()

    private struct Usage: Codable {
        var day: String
        var answeredKeys: Set<String>
    }

    static func key(_ question: QuizQuestion) -> String {
        DailyReviewStore.questionKey(question: question.question, choices: question.choices,
                                    correctAnswerIndex: question.correctAnswerIndex)
    }

    private static func load(userID: String, now: Date, defaults: UserDefaults) -> Usage {
        let day = DailyReviewStore.dayKey(for: now)
        let data = defaults.data(forKey: "reviewAllowance.v1.\(userID)")
        var usage = data.flatMap { try? JSONDecoder().decode(Usage.self, from: $0) }
        if usage?.day != day { usage = Usage(day: day, answeredKeys: []) }
        // Carry over answers from the former home-only daily plan when upgrading the app.
        if let old = DailyReviewStore.todayState(DailyReviewStore.load(userId: userID, defaults: defaults), now: now) {
            usage?.answeredKeys.formUnion(old.answeredKeys)
        }
        return usage!
    }

    static func remaining(userID: String, now: Date = Date(), defaults: UserDefaults = .standard) -> Int {
        lock.lock(); defer { lock.unlock() }
        return max(0, dailyFreeLimit - load(userID: userID, now: now, defaults: defaults).answeredKeys.count)
    }

    static func available(_ questions: [QuizQuestion], userID: String, subscribed: Bool,
                          now: Date = Date(), defaults: UserDefaults = .standard) -> [QuizQuestion] {
        lock.lock(); defer { lock.unlock() }
        guard !subscribed else { return questions }
        let usage = load(userID: userID, now: now, defaults: defaults)
        var seen = usage.answeredKeys
        return Array(questions.filter { seen.insert(key($0)).inserted }
            .prefix(max(0, dailyFreeLimit - usage.answeredKeys.count)))
    }

    /// Called before any answer side effects, including skipped/timed-out reviews.
    static func record(_ question: QuizQuestion, userID: String, subscribed: Bool,
                       now: Date = Date(), defaults: UserDefaults = .standard) -> Bool {
        lock.lock(); defer { lock.unlock() }
        var usage = load(userID: userID, now: now, defaults: defaults)
        let questionKey = key(question)
        guard subscribed || (!usage.answeredKeys.contains(questionKey) && usage.answeredKeys.count < dailyFreeLimit)
        else { return false }
        usage.answeredKeys.insert(questionKey)
        guard let data = try? JSONEncoder().encode(usage) else { return false }
        defaults.set(data, forKey: "reviewAllowance.v1.\(userID)")
        return true
    }
}

struct LocalReviewProgress: Codable, Equatable {
    var stage = 0
    var nextReviewAt: Date?
    var masteredAt: Date?

    init(nextReviewAt: Date) { self.nextReviewAt = nextReviewAt }

    mutating func answer(correct: Bool, now: Date) -> Bool {
        if !correct {
            stage = 0
            nextReviewAt = now.addingTimeInterval(86400)
            masteredAt = nil
            return false
        }
        guard masteredAt == nil, let due = nextReviewAt, due <= now else { return false }
        stage += 1
        if stage >= 3 {
            masteredAt = now
            nextReviewAt = nil
            return true
        }
        nextReviewAt = now.addingTimeInterval(TimeInterval(stage == 1 ? 3 : 7) * 86400)
        return false
    }
}

struct LocalScheduledReview: Codable, Identifiable {
    var id: String
    var question: QuizQuestion
    var progress: LocalReviewProgress
    var legacyImport: Bool
    var remoteID: String? = nil
    var updatedAt: Date? = nil

    var quizQuestion: QuizQuestion {
        var value = question
        value.id = "scheduled_local_\(id)"
        return value
    }
}

/// Stores schedules for free and premium accounts alike, including while offline.
enum LocalReviewScheduleStore {
    private static let lock = NSLock()

    private static func read(_ userID: String, defaults: UserDefaults) -> [LocalScheduledReview] {
        guard let data = defaults.data(forKey: "localReviewSchedule.v1.\(userID)") else { return [] }
        return (try? JSONDecoder().decode([LocalScheduledReview].self, from: data)) ?? []
    }

    private static func write(_ records: [LocalScheduledReview], userID: String, defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: "localReviewSchedule.v1.\(userID)")
        }
    }

    static func records(userID: String, defaults: UserDefaults = .standard) -> [LocalScheduledReview] {
        lock.lock(); defer { lock.unlock() }
        return read(userID, defaults: defaults)
    }

    static func saveMistake(_ question: QuizQuestion, userID: String, now: Date = Date(),
                            defaults: UserDefaults = .standard) {
        lock.lock(); defer { lock.unlock() }
        var records = read(userID, defaults: defaults)
        let key = ReviewAccessPolicy.key(question)
        let index = records.firstIndex { ReviewAccessPolicy.key($0.question) == key }
        let record = LocalScheduledReview(id: index.map { records[$0].id } ?? UUID().uuidString,
            question: question, progress: LocalReviewProgress(nextReviewAt: now.addingTimeInterval(86400)),
            legacyImport: false, remoteID: index.flatMap { records[$0].remoteID }, updatedAt: now)
        if let index { records[index] = record } else { records.append(record) }
        write(records, userID: userID, defaults: defaults)
    }

    static func importLegacy(_ questions: [QuizQuestion], userID: String, now: Date = Date(),
                             defaults: UserDefaults = .standard) {
        lock.lock(); defer { lock.unlock() }
        var records = read(userID, defaults: defaults)
        var keys = Set(records.map { ReviewAccessPolicy.key($0.question) })
        let previousCount = records.count
        for question in questions where keys.insert(ReviewAccessPolicy.key(question)).inserted {
            records.append(LocalScheduledReview(id: UUID().uuidString, question: question,
                progress: LocalReviewProgress(nextReviewAt: now), legacyImport: true))
        }
        if records.count != previousCount { write(records, userID: userID, defaults: defaults) }
    }

    static func importRemote(_ question: QuizQuestion, progress: LocalReviewProgress, userID: String,
                             updatedAt: Date = .distantPast, defaults: UserDefaults = .standard) {
        importRemoteBatch([(question, progress, updatedAt)], userID: userID, defaults: defaults)
    }

    static func importRemoteBatch(_ imports: [(QuizQuestion, LocalReviewProgress, Date)], userID: String,
                                  defaults: UserDefaults = .standard) {
        lock.lock(); defer { lock.unlock() }
        var records = read(userID, defaults: defaults)
        var indexes = Dictionary(records.enumerated().map { (ReviewAccessPolicy.key($0.element.question), $0.offset) },
                                 uniquingKeysWith: { first, _ in first })
        var changed = false
        for (question, progress, updatedAt) in imports {
            let key = ReviewAccessPolicy.key(question)
            if let index = indexes[key] {
                if records[index].remoteID == nil { records[index].remoteID = question.id; changed = true }
                if records[index].legacyImport || updatedAt > (records[index].updatedAt ?? .distantPast) {
                    records[index].progress = progress
                    records[index].legacyImport = false
                    records[index].updatedAt = updatedAt
                    records[index].remoteID = question.id
                    changed = true
                }
            } else {
                indexes[key] = records.count
                records.append(LocalScheduledReview(id: UUID().uuidString, question: question,
                    progress: progress, legacyImport: false, remoteID: question.id, updatedAt: updatedAt))
                changed = true
            }
        }
        if changed { write(records, userID: userID, defaults: defaults) }
    }

    static func dueQuestions(userID: String, now: Date = Date(), defaults: UserDefaults = .standard) -> [QuizQuestion] {
        records(userID: userID, defaults: defaults).filter {
            $0.progress.masteredAt == nil && ($0.progress.nextReviewAt ?? .distantFuture) <= now
        }.sorted {
            let left = $0.progress.nextReviewAt ?? .distantFuture
            let right = $1.progress.nextReviewAt ?? .distantFuture
            return left == right ? $0.id < $1.id : left < right
        }.map(\.quizQuestion)
    }

    static func excludingMastered(_ questions: [QuizQuestion], userID: String,
                                  defaults: UserDefaults = .standard) -> [QuizQuestion] {
        let masteredKeys = Set(records(userID: userID, defaults: defaults)
            .filter { $0.progress.masteredAt != nil }.map { ReviewAccessPolicy.key($0.question) })
        return questions.filter { !masteredKeys.contains(ReviewAccessPolicy.key($0)) }
    }

    @discardableResult
    static func recordAnswer(_ question: QuizQuestion, correct: Bool, userID: String, now: Date = Date(),
                             defaults: UserDefaults = .standard) -> Bool {
        lock.lock(); defer { lock.unlock() }
        var records = read(userID, defaults: defaults)
        guard let index = records.firstIndex(where: { ReviewAccessPolicy.key($0.question) == ReviewAccessPolicy.key(question) })
        else { return false }
        records[index].legacyImport = false
        records[index].updatedAt = now
        let mastered = records[index].progress.answer(correct: correct, now: now)
        write(records, userID: userID, defaults: defaults)
        let hasDue = records.contains { $0.progress.masteredAt == nil && ($0.progress.nextReviewAt ?? .distantFuture) <= now }
        if !hasDue || ReviewAccessPolicy.remaining(userID: userID, now: now, defaults: defaults) == 0 {
            let key = "localReviewDays.v1.\(userID)"
            var days = Set(defaults.stringArray(forKey: key) ?? [])
            days.insert(DailyReviewStore.dayKey(for: now))
            defaults.set(days.sorted(), forKey: key)
        }
        return mastered
    }

    static func attachRemoteID(_ remoteID: String, recordID: String, userID: String) {
        lock.lock(); defer { lock.unlock() }
        var records = read(userID, defaults: .standard)
        guard let index = records.firstIndex(where: { $0.id == recordID }) else { return }
        records[index].remoteID = remoteID
        write(records, userID: userID, defaults: .standard)
    }

    static func reviewStreak(userID: String, now: Date = Date(), defaults: UserDefaults = .standard) -> Int {
        let days = Set(defaults.stringArray(forKey: "localReviewDays.v1.\(userID)") ?? [])
        var date = now
        let calendar = Calendar.current
        if !days.contains(DailyReviewStore.dayKey(for: date)) {
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        var count = 0
        while days.contains(DailyReviewStore.dayKey(for: date)), count < days.count {
            count += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return count
    }

    static func importReviewDays(_ days: Set<String>, userID: String, defaults: UserDefaults = .standard) {
        let key = "localReviewDays.v1.\(userID)"
        let existing = Set(defaults.stringArray(forKey: key) ?? [])
        defaults.set(existing.union(days).sorted(), forKey: key)
    }

    static func completedToday(userID: String, now: Date = Date()) -> Bool {
        (UserDefaults.standard.stringArray(forKey: "localReviewDays.v1.\(userID)") ?? [])
            .contains(DailyReviewStore.dayKey(for: now))
    }
}
