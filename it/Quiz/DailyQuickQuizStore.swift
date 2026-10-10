import Foundation

struct DailyQuickQuizProgress: Equatable {
    let questionCount: Int
    let answeredCount: Int

    var isCompleted: Bool { questionCount > 0 && answeredCount >= questionCount }
    static let notStarted = DailyQuickQuizProgress(questionCount: 3, answeredCount: 0)
}

/// 今日の3問を端末・ユーザーごとに固定する。誤答が増えても途中で復習へ切り替えない。
enum DailyQuickQuizStore {
    static let questionLimit = 3

    static func progress(state: DailyReviewState?, now: Date, calendar: Calendar = .current) -> DailyQuickQuizProgress? {
        guard let today = DailyReviewStore.todayState(state, now: now, calendar: calendar),
              !today.questionKeys.isEmpty else { return nil }
        return DailyQuickQuizProgress(
            questionCount: today.questionKeys.count,
            answeredCount: Set(today.questionKeys).intersection(today.answeredKeys).count
        )
    }

    static func startOrResume(userId: String, shuffledAvailableKeys: [String], now: Date = Date(), defaults: UserDefaults = .standard) -> DailyReviewState {
        let state = DailyReviewStore.startOrResume(
            state: load(userId: userId, defaults: defaults),
            shuffledAvailableKeys: shuffledAvailableKeys,
            now: now,
            questionLimit: questionLimit
        )
        save(state, userId: userId, defaults: defaults)
        return state
    }

    /// 最後の未回答が記録されたときだけtrue。再描画・連打で完了を重複計測しない。
    @discardableResult
    static func recordAnswer(key: String, userId: String, expectedDayKey: String, now: Date = Date(), defaults: UserDefaults = .standard) -> Bool {
        let current = load(userId: userId, defaults: defaults)
        guard current?.dayKey == expectedDayKey,
              let updated = DailyReviewStore.recordingAnswer(key, in: current, now: now), updated != current else { return false }
        save(updated, userId: userId, defaults: defaults)
        return progress(state: updated, now: now)?.isCompleted == true
    }

    static func load(userId: String, defaults: UserDefaults = .standard) -> DailyReviewState? {
        guard let data = defaults.data(forKey: "dailyQuickQuizState.v1.\(userId)") else { return nil }
        return try? JSONDecoder().decode(DailyReviewState.self, from: data)
    }

    private static func save(_ state: DailyReviewState, userId: String, defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: "dailyQuickQuizState.v1.\(userId)")
    }
}
