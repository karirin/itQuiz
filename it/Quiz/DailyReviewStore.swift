import Foundation

/// ホームの「今日の復習」で出題する問題と回答状況。端末のローカル日付ごとに作り直す。
struct DailyReviewState: Codable, Equatable {
    var dayKey: String
    var questionKeys: [String]
    var answeredKeys: [String]
}

/// 誤答ストアの問題から1日最大5問を固定し、途中再開と完了判定を行う。
enum DailyReviewStore {
    static let dailyQuestionLimit = 5

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func questionKey(question: String, choices: [String], correctAnswerIndex: Int) -> String {
        ([question] + choices + [String(correctAnswerIndex)]).joined(separator: "\u{1F}")
    }

    /// 日付が変わった状態は捨て、翌日は新しい5問で再表示する。
    static func todayState(_ state: DailyReviewState?, now: Date, calendar: Calendar = .current) -> DailyReviewState? {
        guard let state, state.dayKey == dayKey(for: now, calendar: calendar) else { return nil }
        return state
    }

    /// ホームのボタン表示用。不正解の問題も今日の出題もない場合は nil。
    static func progress(
        state: DailyReviewState?,
        availableKeys: [String],
        now: Date,
        calendar: Calendar = .current
    ) -> DailyReviewProgress? {
        guard let today = todayState(state, now: now, calendar: calendar) else {
            let questionCount = min(availableKeys.count, dailyQuestionLimit)
            guard questionCount > 0 else { return nil }
            return DailyReviewProgress(
                incorrectCount: availableKeys.count,
                questionCount: questionCount,
                answeredCount: 0
            )
        }

        let available = Set(availableKeys)
        // 正解して誤答ストアから消えた今日の問題も、今日の母数には含める。
        let resolvedTodayCount = today.questionKeys.filter { !available.contains($0) }.count
        return DailyReviewProgress(
            incorrectCount: availableKeys.count + resolvedTodayCount,
            questionCount: today.questionKeys.count,
            answeredCount: today.questionKeys.count - remainingKeys(state: today, availableKeys: availableKeys).count
        )
    }

    /// 今日の出題を固定する。すでに今日の状態があればそのまま返す。
    static func startOrResume(
        state: DailyReviewState?,
        shuffledAvailableKeys: [String],
        now: Date,
        calendar: Calendar = .current,
        questionLimit: Int = dailyQuestionLimit
    ) -> DailyReviewState {
        if let today = todayState(state, now: now, calendar: calendar) {
            return today
        }
        return DailyReviewState(
            dayKey: dayKey(for: now, calendar: calendar),
            questionKeys: Array(shuffledAvailableKeys.prefix(questionLimit)),
            answeredKeys: []
        )
    }

    /// 未回答で、まだ誤答ストアに残っている問題。別の入口で克服済みになった問題は出題しない。
    static func remainingKeys(state: DailyReviewState, availableKeys: [String]) -> [String] {
        let available = Set(availableKeys)
        let answered = Set(state.answeredKeys)
        return state.questionKeys.filter { !answered.contains($0) && available.contains($0) }
    }

    static func recordingAnswer(_ key: String, in state: DailyReviewState?, now: Date, calendar: Calendar = .current) -> DailyReviewState? {
        guard var today = todayState(state, now: now, calendar: calendar),
              today.questionKeys.contains(key),
              !today.answeredKeys.contains(key) else { return state }
        today.answeredKeys.append(key)
        return today
    }

    // MARK: - Persistence

    private static func defaultsKey(userId: String) -> String {
        "dailyReviewState.v1.\(userId)"
    }

    static func load(userId: String, defaults: UserDefaults = .standard) -> DailyReviewState? {
        guard let data = defaults.data(forKey: defaultsKey(userId: userId)) else { return nil }
        return try? JSONDecoder().decode(DailyReviewState.self, from: data)
    }

    static func save(_ state: DailyReviewState, userId: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: defaultsKey(userId: userId))
    }

    @discardableResult
    static func recordAnswer(key: String, userId: String, expectedDayKey: String? = nil, now: Date = Date(), defaults: UserDefaults = .standard) -> Bool {
        let current = load(userId: userId, defaults: defaults)
        guard expectedDayKey == nil || current?.dayKey == expectedDayKey,
              let updated = recordingAnswer(key, in: current, now: now), updated != current else { return false }
        save(updated, userId: userId, defaults: defaults)
        return !updated.questionKeys.isEmpty && Set(updated.questionKeys).isSubset(of: Set(updated.answeredKeys))
    }
}
