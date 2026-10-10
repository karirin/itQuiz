import Foundation

/// タップ時の入口を学習開始・結果まで渡す。グローバル状態にせず別の学習への混入を防ぐ。
struct LearningEntryContext: Equatable {
    enum Source: String { case home, notification }
    enum Activity: String { case review, quickQuiz = "quick_quiz", scheduledReview = "scheduled_review" }

    let source: Source
    let activity: Activity
    let flowID: String
    let dayKey: String

    init(source: Source, activity: Activity, now: Date = Date()) {
        self.source = source
        self.activity = activity
        self.flowID = UUID().uuidString
        self.dayKey = DailyReviewStore.dayKey(for: now)
    }

    var isDailyPlan: Bool { activity != .scheduledReview }

    /// ホーム・通知から始める短い日課は、結果まで全画面広告で中断しない。
    var interstitialExclusionReason: String? { isDailyPlan ? "daily_learning" : nil }

    var parameters: [String: Any] {
        ["entry_source": source.rawValue, "learning_activity": activity.rawValue,
         "learning_flow_id": flowID, "learning_day": dayKey]
    }
}
