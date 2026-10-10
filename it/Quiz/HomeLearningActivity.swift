import Foundation

/// ホームの「今日の復習」ボタンの表示状態。
struct DailyReviewProgress: Equatable {
    /// ユーザーが不正解になった問題の数
    let incorrectCount: Int
    /// 今日出題する問題数（進捗バーの本数）
    let questionCount: Int
    let answeredCount: Int

    var isCompleted: Bool { questionCount > 0 && answeredCount >= questionCount }
}

/// ホームの表示件数と遷移先を、同じ復習データに対応させる。
enum HomeLearningActivity: Equatable, Identifiable {
    case savedITReview(DailyReviewProgress)
    case quickQuiz(DailyQuickQuizProgress)
    case scheduledReview(count: Int)

    var id: String {
        switch self {
        case .savedITReview: return "saved_it_review"
        case .quickQuiz: return "quick_quiz"
        case .scheduledReview: return "scheduled_review"
        }
    }

    var reviewCount: Int {
        switch self {
        case .savedITReview(let progress): return max(0, progress.questionCount - progress.answeredCount)
        case .quickQuiz: return 0
        case .scheduledReview(let count): return count
        }
    }

    var analyticsActivity: LearningEntryContext.Activity {
        switch self {
        case .savedITReview: return .review
        case .quickQuiz: return .quickQuiz
        case .scheduledReview: return .scheduledReview
        }
    }

    var questionCount: Int {
        switch self {
        case .savedITReview(let progress): return progress.questionCount
        case .quickQuiz(let progress): return progress.questionCount
        case .scheduledReview(let count): return count
        }
    }

    var answeredCount: Int {
        switch self {
        case .savedITReview(let progress): return progress.answeredCount
        case .quickQuiz(let progress): return progress.answeredCount
        case .scheduledReview: return 0
        }
    }

    var remainingCount: Int { max(0, questionCount - answeredCount) }
    var isCompleted: Bool { questionCount > 0 && remainingCount == 0 }
    var stateName: String { isCompleted ? "completed" : (answeredCount > 0 ? "in_progress" : "not_started") }

    var title: String {
        if isCompleted { return "今日は達成！" }
        switch self {
        case .savedITReview: return "今日の復習"
        case .quickQuiz: return "今日の3問"
        case .scheduledReview: return "苦手克服"
        }
    }

    func message(isSubscribed: Bool) -> String {
        if isCompleted { return "今日の\(questionCount)問を完了。また明日！" }
        if answeredCount > 0 { return "続きから・残り\(remainingCount)問" }
        switch self {
        case .savedITReview(let progress):
            return isSubscribed
                ? "不正解した\(progress.incorrectCount)問から\(progress.questionCount)問を復習"
                : "不正解した\(progress.incorrectCount)問から\(progress.questionCount)問を無料復習"
        case .quickQuiz:
            return "3問で今日の学習を始めよう"
        case .scheduledReview(let count):
            return "復習タイミングの問題が\(count)問あります"
        }
    }

    static func available(
        dailyReview: DailyReviewProgress?,
        quickQuiz: DailyQuickQuizProgress? = nil,
        scheduledReviewCount: Int,
        isSubscribed: Bool
    ) -> [HomeLearningActivity] {
        var activities: [HomeLearningActivity] = []
        // 今日の3問を始めた後は、そこで誤答が増えても同じ学習を続ける。
        // 完了した入口は翌日まで隠す。別の学習へのフォールバックで再表示しない。
        if let quickQuiz {
            if !quickQuiz.isCompleted {
                activities.append(.quickQuiz(quickQuiz))
            }
        } else if let dailyReview, dailyReview.questionCount > 0 {
            if !dailyReview.isCompleted {
                activities.append(.savedITReview(dailyReview))
            }
        } else {
            activities.append(.quickQuiz(.notStarted))
        }
        if isSubscribed && scheduledReviewCount > 0 {
            activities.append(.scheduledReview(count: scheduledReviewCount))
        }
        return activities
    }
}
