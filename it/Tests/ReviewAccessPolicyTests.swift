import Foundation

@main
struct ReviewAccessPolicyTests {
    static func main() throws {
        var checks = 0
        func check(_ condition: @autoclosure () -> Bool, _ message: String) {
            checks += 1
            precondition(condition(), message)
        }
        let suite = "review-access-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Calendar.current.startOfDay(for: Date()).addingTimeInterval(3600)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let questions = (0..<12).map {
            QuizQuestion(id: "remote\($0)", question: "Question \($0)", choices: ["A", "B"],
                         correctAnswerIndex: 0, explanation: "Explanation", sourceQuizLevel: "テクノロジ")
        }
        check(ReviewAccessPolicy.available(questions, userID: "alice", subscribed: false, now: now, defaults: defaults).count == 5,
              "Free review starts with five questions")
        for question in questions.prefix(2) {
            check(ReviewAccessPolicy.record(question, userID: "alice", subscribed: false, now: now, defaults: defaults), "Home answers accepted")
        }
        check(ReviewAccessPolicy.remaining(userID: "alice", now: now, defaults: defaults) == 3, "Remaining allowance shared across entry points")
        let resumed = ReviewAccessPolicy.available(questions, userID: "alice", subscribed: false, now: now, defaults: defaults)
        check(resumed.map(\.id) == questions[2..<5].map(\.id), "Resume excludes already answered questions")
        for question in resumed {
            check(ReviewAccessPolicy.record(question, userID: "alice", subscribed: false, now: now, defaults: defaults), "Recovery answers accepted")
        }
        check(!ReviewAccessPolicy.record(questions[5], userID: "alice", subscribed: false, now: now, defaults: defaults), "Sixth free answer rejected")
        check(!ReviewAccessPolicy.record(questions[0], userID: "alice", subscribed: false, now: now, defaults: defaults), "Reentry cannot repeat an answered question")
        check(ReviewAccessPolicy.available(questions.reversed(), userID: "alice", subscribed: false, now: now, defaults: defaults).isEmpty,
              "Reopening or reshuffling does not reset allowance")
        check(ReviewAccessPolicy.remaining(userID: "bob", now: now, defaults: defaults) == 5, "Accounts are isolated")
        check(ReviewAccessPolicy.remaining(userID: "alice", now: tomorrow, defaults: defaults) == 5, "New local day restores five questions")
        check(ReviewAccessPolicy.available(questions, userID: "alice", subscribed: true, now: now, defaults: defaults).count == 12,
              "Premium unlocks all questions immediately")
        check(ReviewAccessPolicy.record(questions[5], userID: "alice", subscribed: true, now: now, defaults: defaults), "Premium can answer beyond five")
        check(ReviewAccessPolicy.remaining(userID: "alice", now: now, defaults: defaults) == 0, "Ending subscription does not reset today's usage")
        let legacy = DailyReviewState(dayKey: DailyReviewStore.dayKey(for: now), questionKeys: questions.prefix(5).map(ReviewAccessPolicy.key),
                                      answeredKeys: questions.prefix(3).map(ReviewAccessPolicy.key))
        DailyReviewStore.save(legacy, userId: "migrated", defaults: defaults)
        check(ReviewAccessPolicy.remaining(userID: "migrated", now: now, defaults: defaults) == 2, "Existing home answers carry into shared quota")
        let reopened = UserDefaults(suiteName: suite)!
        check(ReviewAccessPolicy.remaining(userID: "alice", now: now, defaults: reopened) == 0, "Quota persists after reopening storage")

        var progress = LocalReviewProgress(nextReviewAt: tomorrow)
        check(!progress.answer(correct: true, now: now) && progress.stage == 0, "Early review cannot skip waiting interval")
        check(!progress.answer(correct: true, now: tomorrow) && progress.stage == 1, "First due review advances once")
        let day4 = tomorrow.addingTimeInterval(3 * 86400)
        check(progress.nextReviewAt == day4, "Second review is three days after answer")
        check(!progress.answer(correct: true, now: day4) && progress.stage == 2, "Second due review advances once")
        let day11 = day4.addingTimeInterval(7 * 86400)
        check(progress.nextReviewAt == day11 && progress.answer(correct: true, now: day11), "Third due review masters the question")
        check(progress.masteredAt == day11 && progress.nextReviewAt == nil, "Mastered questions have no pending due date")
        check(!progress.answer(correct: true, now: day11), "Repeated answer cannot grant mastery again")
        check(!progress.answer(correct: false, now: day11) && progress.stage == 0 && progress.masteredAt == nil,
              "Incorrect/unknown/timed-out review restarts schedule")

        LocalReviewScheduleStore.saveMistake(questions[0], userID: "free", now: now, defaults: defaults)
        check(LocalReviewScheduleStore.dueQuestions(userID: "free", now: now, defaults: defaults).isEmpty, "Free mistakes are scheduled for tomorrow")
        check(LocalReviewScheduleStore.dueQuestions(userID: "free", now: tomorrow, defaults: defaults).count == 1, "Free due question persists")
        check(LocalReviewScheduleStore.records(userID: "other", defaults: defaults).isEmpty, "Schedules are account scoped")
        LocalReviewScheduleStore.recordAnswer(questions[0], correct: true, userID: "free", now: tomorrow, defaults: defaults)
        let saved = LocalReviewScheduleStore.records(userID: "free", defaults: defaults)
        check(saved[0].progress.stage == 1 && saved[0].progress.nextReviewAt == day4, "Stored answer advances schedule")
        LocalReviewScheduleStore.importLegacy([questions[0]], userID: "free", now: tomorrow, defaults: defaults)
        check(LocalReviewScheduleStore.records(userID: "free", defaults: defaults)[0].progress == saved[0].progress,
              "Opening another entry does not restart progress")
        LocalReviewScheduleStore.importRemote(questions[0], progress: LocalReviewProgress(nextReviewAt: now), userID: "free",
                                              updatedAt: now, defaults: defaults)
        check(LocalReviewScheduleStore.records(userID: "free", defaults: defaults)[0].progress == saved[0].progress,
              "Old cloud data cannot roll back a newer local answer")
        var newer = LocalReviewProgress(nextReviewAt: day11)
        newer.stage = 2
        LocalReviewScheduleStore.importRemote(questions[0], progress: newer, userID: "free", updatedAt: day4, defaults: defaults)
        check(LocalReviewScheduleStore.records(userID: "free", defaults: defaults)[0].progress.stage == 2,
              "Newer progress from another device is accepted")
        check(LocalReviewScheduleStore.recordAnswer(questions[0], correct: true, userID: "free", now: day11, defaults: defaults),
              "Free user can master a scheduled question")
        check(LocalReviewScheduleStore.dueQuestions(userID: "free", now: day11, defaults: defaults).isEmpty,
              "Mastered record retained but removed from due queue")
        check(LocalReviewScheduleStore.records(userID: "free", defaults: reopened)[0].progress.masteredAt == day11,
              "Mastery persists in the collection")
        check(LocalReviewScheduleStore.excludingMastered(questions, userID: "free", defaults: defaults).count == 11,
              "Mastered questions cannot reappear through an older incorrect-answer cache")
        LocalReviewScheduleStore.saveMistake(questions[0], userID: "free", now: day11, defaults: defaults)
        check(LocalReviewScheduleStore.excludingMastered(questions, userID: "free", defaults: defaults).count == 12,
              "A new mistake makes a previously mastered question reviewable again")
        check(LocalReviewScheduleStore.records(userID: "free", defaults: defaults).count == 1,
              "Repeating a mistake updates the existing record")
        LocalReviewScheduleStore.importLegacy(questions, userID: "old", now: now, defaults: defaults)
        LocalReviewScheduleStore.importLegacy(questions, userID: "old", now: now, defaults: defaults)
        check(LocalReviewScheduleStore.records(userID: "old", defaults: defaults).count == 12, "Legacy import is idempotent")
        LocalReviewScheduleStore.importRemote(questions[1], progress: newer, userID: "old", updatedAt: now.addingTimeInterval(-1), defaults: defaults)
        check(LocalReviewScheduleStore.records(userID: "old", defaults: defaults).first { $0.question.id == questions[1].id }?.progress.stage == 2,
              "Legacy cache imports preserve existing cloud review stage")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let beforeYesterday = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        LocalReviewScheduleStore.importReviewDays(Set([now, yesterday].map { DailyReviewStore.dayKey(for: $0) }),
                                                 userID: "streak", defaults: defaults)
        LocalReviewScheduleStore.importReviewDays([DailyReviewStore.dayKey(for: beforeYesterday)],
                                                 userID: "streak", defaults: defaults)
        check(LocalReviewScheduleStore.reviewStreak(userID: "streak", now: now, defaults: defaults) == 3,
              "Cloud streak history merges with existing local days")
        check(LocalReviewScheduleStore.reviewStreak(userID: "streak", now: tomorrow, defaults: defaults) == 3,
              "Streak remains visible before tomorrow's review")
        print("Review access and schedule regression checks passed (\(checks) checks)")
    }
}
