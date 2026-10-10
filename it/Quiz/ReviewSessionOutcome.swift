import Foundation

/// The result of one problem-review session, derived by comparing the local schedule
/// before and after the quiz. The schedule itself is only read here.
struct ReviewSessionOutcome: Equatable {
    let answeredCount: Int
    let correctCount: Int
    let masteredCount: Int
    /// Next dates for questions answered correctly but not yet mastered, earliest first.
    let nextReviewDates: [Date]
    /// Questions answered incorrectly; they come back after a gap.
    let missedQuestions: [QuizQuestion]

    var retryCount: Int { missedQuestions.count }

    static func make(before: [LocalScheduledReview], after: [LocalScheduledReview], sessionStart: Date) -> ReviewSessionOutcome {
        let previous = Dictionary(before.map { (ReviewAccessPolicy.key($0.question), $0) }, uniquingKeysWith: { first, _ in first })
        var correct = 0
        var mastered = 0
        var dates: [Date] = []
        var missed: [QuizQuestion] = []
        for record in after {
            guard let updatedAt = record.updatedAt, updatedAt >= sessionStart,
                  let old = previous[ReviewAccessPolicy.key(record.question)],
                  old.updatedAt != record.updatedAt else { continue }
            if record.progress.masteredAt != nil && old.progress.masteredAt == nil {
                correct += 1
                mastered += 1
            } else if record.progress.stage > old.progress.stage {
                correct += 1
                if let date = record.progress.nextReviewAt { dates.append(date) }
            } else {
                missed.append(record.question)
            }
        }
        return ReviewSessionOutcome(answeredCount: correct + missed.count, correctCount: correct,
                                    masteredCount: mastered, nextReviewDates: dates.sorted(), missedQuestions: missed)
    }

    func activity(completedAt: Date) -> ReviewDailyActivity? {
        guard answeredCount > 0 else { return nil }
        return ReviewDailyActivity(kind: .review, topicID: nil, answeredCount: answeredCount,
                                   correctCount: correctCount, masteredCount: masteredCount, completedAt: completedAt)
    }
}
