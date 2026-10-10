import Foundation

@main
struct ReviewHomeStateTests {
    static func main() throws {
        var checks = 0
        func check(_ condition: @autoclosure () -> Bool, _ message: String) {
            checks += 1
            precondition(condition(), message)
        }
        let now = Calendar.current.startOfDay(for: Date()).addingTimeInterval(10 * 3600)
        let day: TimeInterval = 86400

        func input(subscribed: Bool = false, session: ReviewThemeResume? = nil, due: Int = 0, available: Int = 0,
                   finalStage: Int = 0, freeRemaining: Int = 5, themes: [ReviewDueTheme] = [],
                   history: Bool = true, themeProgress: Bool = true, today: [ReviewDailyActivity] = []) -> ReviewHomeInput {
            ReviewHomeInput(subscribed: subscribed, activeSession: session, dueReviewCount: due,
                            availableReviewCount: available, availableFinalStageCount: finalStage,
                            freeRemaining: freeRemaining, dueThemes: themes, hasReviewHistory: history,
                            hasThemeProgress: themeProgress, todayActivities: today, upcoming: [])
        }
        let dnsSession = ReviewThemeResume(topicID: "dns", step: .practice, questionIndex: 1, questionCount: 3)
        let dnsCheckup = ReviewDueTheme(topicID: "dns", checkupNumber: 1)
        let memoryCheckup = ReviewDueTheme(topicID: "memory", checkupNumber: 2)
        let reviewDone = ReviewDailyActivity(kind: .review, topicID: nil, answeredCount: 5, correctCount: 4,
                                             masteredCount: 2, completedAt: now)
        let themeDone = ReviewDailyActivity(kind: .themeCheckup, topicID: "memory", answeredCount: 2, correctCount: 2,
                                            masteredCount: 0, completedAt: now, checkupNumber: 1)

        // 1. An unfinished theme session outranks everything.
        var plan = ReviewHomeResolver.resolve(input(session: dnsSession, due: 3, available: 3, themes: [memoryCheckup]))
        check(plan.state == .continueTheme(dnsSession), "Active session is the primary action")
        check(plan.cards == [.continueTheme(dnsSession), .review(count: 3, finalStageCount: 0), .themeCheckup(memoryCheckup)],
              "Other work follows as next cards")
        check(plan.completedCount == 0 && plan.totalCount == 3, "Three items to do today")
        plan = ReviewHomeResolver.resolve(input(session: ReviewThemeResume(topicID: "dns", step: .checkup(1), questionIndex: 0,
                                                                          questionCount: 2), themes: [dnsCheckup]))
        check(plan.cards.count == 1, "A due theme that is already in progress is not listed twice")

        // 2. Due problem reviews within the allowance.
        plan = ReviewHomeResolver.resolve(input(due: 8, available: 5, finalStage: 2, freeRemaining: 5, themes: [dnsCheckup]))
        check(plan.state == .reviewDue(count: 5, finalStageCount: 2), "Free learner reviews the allowed five")
        check(plan.cards.last == .themeCheckup(dnsCheckup), "Theme checkup comes next")
        plan = ReviewHomeResolver.resolve(input(subscribed: true, due: 8, available: 8, freeRemaining: 0))
        check(plan.state == .reviewDue(count: 8, finalStageCount: 0), "Premium reviews every due question")
        check(!plan.cards.contains(.freeLimitReached(remainingCount: 8)), "Premium never sees the free limit")

        // 3. Theme checkup.
        plan = ReviewHomeResolver.resolve(input(themes: [dnsCheckup, memoryCheckup]))
        check(plan.state == .themeCheckup(dnsCheckup, isFreeAlternative: false), "Oldest due theme first")
        check(plan.totalCount == 2, "Each due theme is its own item")

        // 4. Free allowance used up.
        plan = ReviewHomeResolver.resolve(input(due: 3, available: 0, freeRemaining: 0, today: [reviewDone]))
        check(plan.state == .freeLimitReached(remainingCount: 3), "Limit reached without a theme")
        check(plan.completedCount == 1 && plan.totalCount == 1, "Finished free reviews count as done")
        plan = ReviewHomeResolver.resolve(input(due: 3, available: 0, freeRemaining: 0, themes: [dnsCheckup], today: [reviewDone]))
        check(plan.state == .themeCheckup(dnsCheckup, isFreeAlternative: true), "A free theme becomes primary at the limit")
        check(plan.cards == [.themeCheckup(dnsCheckup), .freeLimitReached(remainingCount: 3)], "Limit card follows the theme")
        check(plan.completedCount == 1 && plan.totalCount == 2, "One of two done")
        check(plan.completedResults.isEmpty, "The limit card reports today's reviews, so no done row")
        // Back on the home after reviewing: the review shows as a done row above the theme card.
        plan = ReviewHomeResolver.resolve(input(themes: [dnsCheckup], today: [reviewDone]))
        check(plan.completedResults.map(\.kind) == [.review] && plan.completedCount == 1 && plan.totalCount == 2,
              "Finished reviews move to a done row")
        let practiceDone = ReviewDailyActivity(kind: .themePractice, topicID: "dns", answeredCount: 3, correctCount: 1,
                                               masteredCount: 0, completedAt: now)
        plan = ReviewHomeResolver.resolve(input(session: dnsSession, today: [practiceDone]))
        check(plan.completedResults.isEmpty, "A theme still in progress has no done row")
        // Due questions that were already answered today count against the allowance, not the limit card.
        plan = ReviewHomeResolver.resolve(input(due: 0, available: 0, freeRemaining: 0, today: [reviewDone]))
        check(plan.state == .allClear, "No limit card when nothing is left to review")

        // 5. First run.
        plan = ReviewHomeResolver.resolve(input(history: false, themeProgress: false))
        check(plan.state == .firstRun, "No reviews and no theme progress")
        check(plan.cards.isEmpty && plan.totalCount == 0, "First run has no recommendation cards")
        plan = ReviewHomeResolver.resolve(input(history: false, themeProgress: true))
        check(plan.state == .nothingToday, "Theme progress alone is not a first run")

        // 6 vs 7: something finished today, or nothing at all.
        plan = ReviewHomeResolver.resolve(input(today: [reviewDone, themeDone]))
        check(plan.state == .allClear, "Finished work today is all clear")
        check(plan.completedCount == 2 && plan.totalCount == 2, "Two of two done")
        check(plan.todayResults == [
            ReviewTodayResult(kind: .review, answeredCount: 5, correctCount: 4, masteredCount: 2),
            ReviewTodayResult(kind: .themeCheckup(topicID: "memory", number: 1), answeredCount: 2, correctCount: 2, masteredCount: 0)
        ], "Today's results are summarized")
        check(plan.todayResults.allSatisfy(\.passed) == false, "A review with a miss is not a pass")
        plan = ReviewHomeResolver.resolve(input())
        check(plan.state == .nothingToday, "Nothing done and nothing due")
        check(plan.completedCount == 0 && plan.totalCount == 0, "Nothing counted")
        plan = ReviewHomeResolver.resolve(input(history: false, themeProgress: false, today: [themeDone]))
        check(plan.state == .allClear, "Finishing the first theme today is all clear, not first run")

        // Partially finished reviews stay pending.
        plan = ReviewHomeResolver.resolve(input(subscribed: true, due: 2, available: 2, today: [reviewDone]))
        check(plan.completedCount == 0 && plan.totalCount == 1, "Reviews still due are not complete")
        let twoSessions = ReviewTodayResult.summarize([reviewDone, reviewDone])
        check(twoSessions == [ReviewTodayResult(kind: .review, answeredCount: 10, correctCount: 8, masteredCount: 4)],
              "Review sessions merge into one row")

        // Upcoming items.
        let upcoming = ReviewUpcomingItem.make(
            reviewDates: [now + day, now + day + 3600, now + 3 * day, now - 60],
            themes: [(topicID: "dns", number: 1, date: now + day), (topicID: "memory", number: 2, date: now + 2 * day)],
            now: now)
        check(upcoming.count == 4, "Past dates are dropped and the list is capped")
        check(upcoming[0] == ReviewUpcomingItem(date: now + day, kind: .review(count: 2)), "Same-day reviews merge")
        check(upcoming[1].kind == .themeCheckup(topicID: "dns", number: 1), "Reviews precede themes on the same date")
        check(upcoming[2].kind == .themeCheckup(topicID: "memory", number: 2), "Sorted by date")

        // Session outcome derived from the local schedule.
        let suite = "review-home-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let questions = (0..<3).map {
            QuizQuestion(id: "q\($0)", question: "問題\($0)", choices: ["A", "B"], correctAnswerIndex: 0, explanation: "解説")
        }
        let start = now - 12 * day
        for question in questions { LocalReviewScheduleStore.saveMistake(question, userID: "u", now: start, defaults: defaults) }
        // q0 reaches the final stage; q1 and q2 sit at the first stage.
        LocalReviewScheduleStore.recordAnswer(questions[0], correct: true, userID: "u", now: start + day, defaults: defaults)
        LocalReviewScheduleStore.recordAnswer(questions[0], correct: true, userID: "u", now: start + 4 * day, defaults: defaults)
        let before = LocalReviewScheduleStore.records(userID: "u", defaults: defaults)
        let sessionStart = now
        LocalReviewScheduleStore.recordAnswer(questions[0], correct: true, userID: "u", now: now + 1, defaults: defaults)
        LocalReviewScheduleStore.recordAnswer(questions[1], correct: true, userID: "u", now: now + 2, defaults: defaults)
        LocalReviewScheduleStore.recordAnswer(questions[2], correct: false, userID: "u", now: now + 3, defaults: defaults)
        let after = LocalReviewScheduleStore.records(userID: "u", defaults: defaults)
        let outcome = ReviewSessionOutcome.make(before: before, after: after, sessionStart: sessionStart)
        check(outcome.answeredCount == 3 && outcome.correctCount == 2, "Correct answers counted")
        check(outcome.masteredCount == 1, "Final-stage correct answer is mastered")
        check(outcome.nextReviewDates == [now + 2 + 3 * day], "Correct answer moves three days ahead")
        check(outcome.missedQuestions.map(\.question) == ["問題2"], "Missed question is listed without a date")
        check(outcome.activity(completedAt: now)?.masteredCount == 1, "Outcome becomes today's activity")
        check(ReviewSessionOutcome.make(before: after, after: after, sessionStart: sessionStart).activity(completedAt: now) == nil,
              "An empty session records nothing")

        // Daily activity log resets each day and keeps accounts apart.
        ReviewDailyActivityLog.record(reviewDone, userID: "u", defaults: defaults)
        check(ReviewDailyActivityLog.today(userID: "u", now: now, defaults: defaults) == [reviewDone], "Today's log is read back")
        check(ReviewDailyActivityLog.today(userID: "other", now: now, defaults: defaults).isEmpty, "Accounts are isolated")
        check(ReviewDailyActivityLog.today(userID: "u", now: now + day, defaults: defaults).isEmpty, "A new day starts empty")

        print("Review home state checks passed (\(checks) checks)")
    }
}
