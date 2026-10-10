import Foundation

/// Theme course step, kept independent of `CourseSessionKind` so the decision logic builds without the catalog.
enum ReviewThemeStep: Equatable {
    case practice
    /// 1 = the day after practice, 2 = three days after the first checkup.
    case checkup(Int)
}

struct ReviewThemeResume: Equatable {
    let topicID: String
    let step: ReviewThemeStep
    /// 0-based index of the question the learner will see on resume.
    let questionIndex: Int
    let questionCount: Int
}

struct ReviewDueTheme: Equatable {
    let topicID: String
    let checkupNumber: Int
}

struct ReviewUpcomingItem: Equatable {
    enum Kind: Equatable {
        case review(count: Int)
        case themeCheckup(topicID: String, number: Int)
    }

    let date: Date
    let kind: Kind

    /// Reviews due on the same day collapse into one row; themes stay one row each.
    static func make(reviewDates: [Date], themes: [(topicID: String, number: Int, date: Date)],
                     now: Date, calendar: Calendar = .current, limit: Int = 4) -> [ReviewUpcomingItem] {
        let reviewDays = Dictionary(grouping: reviewDates.filter { $0 > now }) { calendar.startOfDay(for: $0) }
        let reviews = reviewDays.map { day, dates in
            ReviewUpcomingItem(date: dates.min() ?? day, kind: .review(count: dates.count))
        }
        let checkups = themes.filter { $0.date > now }.map {
            ReviewUpcomingItem(date: $0.date, kind: .themeCheckup(topicID: $0.topicID, number: $0.number))
        }
        return Array((reviews + checkups).sorted {
            if $0.date != $1.date { return $0.date < $1.date }
            if case .review = $0.kind { return true }
            return false
        }.prefix(limit))
    }
}

/// One completed piece of work today, written by `ReviewDailyActivityLog`.
struct ReviewDailyActivity: Codable, Equatable {
    enum Kind: String, Codable {
        case review, themePractice, themeCheckup
    }

    var kind: Kind
    var topicID: String?
    var answeredCount: Int
    var correctCount: Int
    /// Questions mastered in a review session, or 1 when a theme was mastered.
    var masteredCount: Int
    var completedAt: Date
    /// For theme checkups: 1 or 2.
    var checkupNumber: Int? = nil
}

/// Today's results as listed on the all-clear card. Review sessions are summed into one row.
struct ReviewTodayResult: Equatable {
    enum Kind: Equatable {
        case review
        case themePractice(topicID: String)
        case themeCheckup(topicID: String, number: Int)
    }

    let kind: Kind
    let answeredCount: Int
    let correctCount: Int
    let masteredCount: Int

    var passed: Bool { answeredCount > 0 && correctCount == answeredCount }

    static func summarize(_ activities: [ReviewDailyActivity]) -> [ReviewTodayResult] {
        var results: [ReviewTodayResult] = []
        let reviews = activities.filter { $0.kind == .review }
        if !reviews.isEmpty {
            results.append(ReviewTodayResult(kind: .review,
                answeredCount: reviews.reduce(0) { $0 + $1.answeredCount },
                correctCount: reviews.reduce(0) { $0 + $1.correctCount },
                masteredCount: reviews.reduce(0) { $0 + $1.masteredCount }))
        }
        for activity in activities.sorted(by: { $0.completedAt < $1.completedAt }) {
            guard let topicID = activity.topicID else { continue }
            switch activity.kind {
            case .review: continue
            case .themePractice:
                results.append(ReviewTodayResult(kind: .themePractice(topicID: topicID), answeredCount: activity.answeredCount,
                    correctCount: activity.correctCount, masteredCount: activity.masteredCount))
            case .themeCheckup:
                results.append(ReviewTodayResult(kind: .themeCheckup(topicID: topicID, number: activity.checkupNumber ?? 1),
                    answeredCount: activity.answeredCount,
                    correctCount: activity.correctCount, masteredCount: activity.masteredCount))
            }
        }
        return results
    }
}

/// Everything the recovery home needs to decide what to recommend. Built by the view from the stores.
struct ReviewHomeInput: Equatable {
    var subscribed: Bool
    var activeSession: ReviewThemeResume?
    /// Problem reviews whose date has come, regardless of the free allowance.
    var dueReviewCount: Int
    /// Problem reviews the learner can answer now (free allowance applied).
    var availableReviewCount: Int
    /// Of `availableReviewCount`, the questions one correct answer away from mastery.
    var availableFinalStageCount: Int
    var freeRemaining: Int
    /// Accessible themes whose checkup date has come, oldest first.
    var dueThemes: [ReviewDueTheme]
    var hasReviewHistory: Bool
    var hasThemeProgress: Bool
    var todayActivities: [ReviewDailyActivity]
    var upcoming: [ReviewUpcomingItem]
}

enum ReviewRecommendation: Equatable {
    case continueTheme(ReviewThemeResume)
    case review(count: Int, finalStageCount: Int)
    case themeCheckup(ReviewDueTheme)
    /// Informational: today's free problem reviews are used up. Never a filled primary button.
    case freeLimitReached(remainingCount: Int)

    var isActionable: Bool {
        if case .freeLimitReached = self { return false }
        return true
    }
}

/// The seven states of the recovery home, in priority order.
enum ReviewHomeState: Equatable {
    case continueTheme(ReviewThemeResume)
    case reviewDue(count: Int, finalStageCount: Int)
    /// `isFreeAlternative` is true when today's free problem reviews are used up and this theme can still be done free.
    case themeCheckup(ReviewDueTheme, isFreeAlternative: Bool)
    case freeLimitReached(remainingCount: Int)
    case firstRun
    case allClear
    case nothingToday
}

struct ReviewHomePlan: Equatable {
    let state: ReviewHomeState
    /// The first card is the featured one; the rest are shown as "next".
    let cards: [ReviewRecommendation]
    let completedCount: Int
    let totalCount: Int
    let todayResults: [ReviewTodayResult]
    /// Today's results whose item is no longer pending, shown as "完了" rows above the cards.
    let completedResults: [ReviewTodayResult]
    let upcoming: [ReviewUpcomingItem]
}

enum ReviewHomeResolver {
    static func resolve(_ input: ReviewHomeInput) -> ReviewHomePlan {
        var cards: [ReviewRecommendation] = []
        if let session = input.activeSession {
            cards.append(.continueTheme(session))
        }
        if input.availableReviewCount > 0 {
            cards.append(.review(count: input.availableReviewCount, finalStageCount: input.availableFinalStageCount))
        }
        for theme in input.dueThemes where theme.topicID != input.activeSession?.topicID {
            cards.append(.themeCheckup(theme))
        }
        let limitReached = !input.subscribed && input.availableReviewCount == 0 && input.dueReviewCount > 0
        if limitReached {
            cards.append(.freeLimitReached(remainingCount: input.dueReviewCount))
        }

        let state: ReviewHomeState
        switch cards.first {
        case let .continueTheme(session)?:
            state = .continueTheme(session)
        case let .review(count, finalStageCount)?:
            state = .reviewDue(count: count, finalStageCount: finalStageCount)
        case let .themeCheckup(theme)?:
            state = .themeCheckup(theme, isFreeAlternative: limitReached)
        case let .freeLimitReached(remainingCount)?:
            state = .freeLimitReached(remainingCount: remainingCount)
        case nil:
            if !input.todayActivities.isEmpty {
                state = .allClear
            } else if !input.hasReviewHistory && !input.hasThemeProgress {
                state = .firstRun
            } else {
                state = .nothingToday
            }
        }

        let completed = completedItems(input.todayActivities, pending: cards)
        let actionable = cards.filter(\.isActionable).count
        let results = ReviewTodayResult.summarize(input.todayActivities)
        return ReviewHomePlan(state: state, cards: cards, completedCount: completed,
                              totalCount: completed + actionable,
                              todayResults: results,
                              completedResults: completedResults(results, pending: cards),
                              upcoming: input.upcoming)
    }

    private struct PendingItems {
        var review = false
        var topics = Set<String>()

        init(_ cards: [ReviewRecommendation]) {
            for card in cards {
                switch card {
                case .review, .freeLimitReached: review = true
                case let .continueTheme(session): topics.insert(session.topicID)
                case let .themeCheckup(theme): topics.insert(theme.topicID)
                }
            }
        }
    }

    /// Problem review counts as one item; each theme counts once. An item still pending is not complete,
    /// except that reviews count as done once today's free allowance is used up.
    private static func completedItems(_ activities: [ReviewDailyActivity], pending cards: [ReviewRecommendation]) -> Int {
        let pending = PendingItems(cards.filter(\.isActionable))
        var count = 0
        if !pending.review && activities.contains(where: { $0.kind == .review }) { count += 1 }
        let topics = Set(activities.compactMap { $0.kind == .review ? nil : $0.topicID })
        count += topics.subtracting(pending.topics).count
        return count
    }

    /// The limit card already reports today's reviews, so reviews get no separate "完了" row then.
    private static func completedResults(_ results: [ReviewTodayResult], pending cards: [ReviewRecommendation]) -> [ReviewTodayResult] {
        let pending = PendingItems(cards)
        var seenTopics = Set<String>()
        return results.reversed().filter { result in
            switch result.kind {
            case .review: return !pending.review
            case let .themePractice(topicID), let .themeCheckup(topicID, _):
                return !pending.topics.contains(topicID) && seenTopics.insert(topicID).inserted
            }
        }.reversed()
    }
}
