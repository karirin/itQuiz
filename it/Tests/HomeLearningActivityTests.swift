import Foundation

@main
enum HomeLearningActivityTests {
    static func main() {
        var checks = 0
        func check(_ condition: Bool, _ message: String) {
            precondition(condition, message)
            checks += 1
        }

        let fresh = DailyReviewProgress(incorrectCount: 12, questionCount: 5, answeredCount: 0)
        let before = HomeLearningActivity.available(
            dailyReview: fresh, scheduledReviewCount: 0, isSubscribed: false
        )
        let after = HomeLearningActivity.available(
            dailyReview: fresh, scheduledReviewCount: 0, isSubscribed: true
        )
        check(before == [.savedITReview(fresh)], "未着手の今日の復習を表示する")
        check(after == before, "加入しても今日の復習の入口と件数が変わらない")
        check(before[0].title == "今日の復習", "タイトル")
        check(before[0].message(isSubscribed: false) == "不正解した12問から5問を無料復習", "無料の文言")
        check(after[0].message(isSubscribed: true) == "不正解した12問から5問を復習", "加入者の文言")

        let both = HomeLearningActivity.available(
            dailyReview: fresh, scheduledReviewCount: 2, isSubscribed: true
        )
        check(both == [.savedITReview(fresh), .scheduledReview(count: 2)],
              "期限付き復習があっても今日の復習が隠れない")
        check(Set(both.map(\.id)).count == both.count, "各カードを別の遷移先として識別できる")
        check(Set(both.map(\.title)).count == both.count, "同じタイトルのカードが並ばない")

        let completed = DailyReviewProgress(incorrectCount: 12, questionCount: 5, answeredCount: 5)
        check(HomeLearningActivity.available(
            dailyReview: completed, scheduledReviewCount: 2, isSubscribed: true
        ) == [.scheduledReview(count: 2)], "完了した今日の復習を隠し、別の復習入口は残す")
        check(HomeLearningActivity.available(
            dailyReview: completed, scheduledReviewCount: 0, isSubscribed: false
        ).isEmpty, "復習完了後に今日の3問へ切り替えて再表示しない")
        check(HomeLearningActivity.available(
            dailyReview: nil, scheduledReviewCount: 2, isSubscribed: false
        ) == [.quickQuiz(.notStarted)], "未加入時は有料の期限付き復習へ遷移せず3問を出す")
        for isSubscribed in [false, true] {
            check(HomeLearningActivity.available(
                dailyReview: nil, scheduledReviewCount: 0, isSubscribed: isSubscribed
            ) == [.quickQuiz(.notStarted)], "復習が空のときは今日の3問を表示する")
        }

        // MARK: DailyReviewStore
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let day1 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 23, minute: 50))!
        let day2 = calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 0, minute: 5))!
        let keys = (1...12).map { "q\($0)" }

        check(DailyReviewStore.progress(state: nil, availableKeys: [], now: day1, calendar: calendar) == nil,
              "不正解0問ならボタンを表示しない")
        check(DailyReviewStore.progress(state: nil, availableKeys: ["a", "b", "c"], now: day1, calendar: calendar)
              == DailyReviewProgress(incorrectCount: 3, questionCount: 3, answeredCount: 0),
              "不正解が5問未満ならある分だけ出題する")
        check(DailyReviewStore.progress(state: nil, availableKeys: keys, now: day1, calendar: calendar) == fresh,
              "未着手は最大5問")

        var state = DailyReviewStore.startOrResume(state: nil, shuffledAvailableKeys: keys, now: day1, calendar: calendar)
        check(state.questionKeys == Array(keys.prefix(5)), "今日の5問を固定する")
        check(DailyReviewStore.startOrResume(state: state, shuffledAvailableKeys: keys.reversed(), now: day1, calendar: calendar)
              == state, "同じ日に再開しても出題は変わらない")

        // q1 は正解して誤答ストアから消え、q2 は不正解のまま残る
        state = DailyReviewStore.recordingAnswer("q1", in: state, now: day1, calendar: calendar)!
        state = DailyReviewStore.recordingAnswer("q2", in: state, now: day1, calendar: calendar)!
        state = DailyReviewStore.recordingAnswer("q2", in: state, now: day1, calendar: calendar)!
        let remainingStore = keys.filter { $0 != "q1" }
        check(DailyReviewStore.progress(state: state, availableKeys: remainingStore, now: day1, calendar: calendar)
              == DailyReviewProgress(incorrectCount: 12, questionCount: 5, answeredCount: 2),
              "途中でやめたら回答済みの数だけ進捗を表示する")
        check(DailyReviewStore.remainingKeys(state: state, availableKeys: remainingStore) == ["q3", "q4", "q5"],
              "再開時は未回答の問題だけ出題する")

        for key in ["q3", "q4", "q5"] {
            state = DailyReviewStore.recordingAnswer(key, in: state, now: day1, calendar: calendar)!
        }
        check(DailyReviewStore.progress(state: state, availableKeys: remainingStore, now: day1, calendar: calendar)?.isCompleted == true,
              "5問回答で完了")
        check(DailyReviewStore.progress(state: state, availableKeys: remainingStore, now: day2, calendar: calendar)
              == DailyReviewProgress(incorrectCount: 11, questionCount: 5, answeredCount: 0),
              "ローカル日付が変わったら再表示する")
        check(DailyReviewStore.recordingAnswer("q6", in: state, now: day2, calendar: calendar) == state,
              "前日の状態には回答を記録しない")

        // MARK: Quick quiz persistence, resume, day/account boundaries
        let suite = "daily-learning-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let currentDay = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
        let quick = DailyQuickQuizStore.startOrResume(userId: "alice", shuffledAvailableKeys: keys, now: currentDay, defaults: defaults)
        check(quick.questionKeys == ["q1", "q2", "q3"], "今日の3問を固定する")
        check(DailyQuickQuizStore.load(userId: "bob", defaults: defaults) == nil, "別ユーザーに進捗を混ぜない")
        check(!DailyQuickQuizStore.recordAnswer(key: "q1", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "1問では完了しない")
        let resumed = DailyQuickQuizStore.startOrResume(userId: "alice", shuffledAvailableKeys: keys.reversed(), now: currentDay, defaults: defaults)
        check(resumed.questionKeys == quick.questionKeys && resumed.answeredKeys == ["q1"], "再起動相当の再読込でも出題・進捗を保持する")
        check(DailyReviewStore.remainingKeys(state: resumed, availableKeys: keys) == ["q2", "q3"], "未回答から再開する")
        let quickProgress = DailyQuickQuizStore.progress(state: resumed, now: currentDay)!
        check(HomeLearningActivity.available(dailyReview: fresh, quickQuiz: quickProgress, scheduledReviewCount: 0, isSubscribed: false) == [.quickQuiz(quickProgress)], "誤答が増えても今日の3問から復習へ切り替えない")
        check(HomeLearningActivity.quickQuiz(quickProgress).message(isSubscribed: false) == "続きから・残り2問", "途中再開の文言")
        check(!DailyQuickQuizStore.recordAnswer(key: "q1", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "二重回答は無視する")
        check(!DailyQuickQuizStore.recordAnswer(key: "q9", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "今日の出題以外は無視する")
        check(!DailyQuickQuizStore.recordAnswer(key: "q2", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "2問でも完了しない")
        check(DailyQuickQuizStore.recordAnswer(key: "q3", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "最後の1問だけで完了を通知する")
        check(!DailyQuickQuizStore.recordAnswer(key: "q3", userId: "alice", expectedDayKey: quick.dayKey, now: currentDay, defaults: defaults), "完了を二重計測しない")
        let done = DailyQuickQuizStore.progress(state: DailyQuickQuizStore.load(userId: "alice", defaults: defaults), now: currentDay)!
        check(HomeLearningActivity.available(dailyReview: fresh, quickQuiz: done, scheduledReviewCount: 0, isSubscribed: false).isEmpty,
              "3問の完了後に誤答があっても別の入口へ切り替えて再表示しない")
        check(DailyQuickQuizStore.progress(state: quick, now: tomorrow) == nil, "翌日は前日の進捗を表示しない")
        let nextDay = DailyQuickQuizStore.startOrResume(userId: "alice", shuffledAvailableKeys: keys.reversed(), now: tomorrow, defaults: defaults)
        check(nextDay.questionKeys == ["q12", "q11", "q10"] && nextDay.answeredKeys.isEmpty, "翌日は新しい3問になる")
        check(!DailyQuickQuizStore.recordAnswer(key: "q12", userId: "alice", expectedDayKey: quick.dayKey, now: tomorrow, defaults: defaults), "前日の画面から翌日の進捗を書き換えない")
        check(DailyReviewStore.load(userId: "alice", defaults: defaults) == nil, "3問と復習の保存領域を分ける")

        let reviewState = DailyReviewStore.startOrResume(state: nil, shuffledAvailableKeys: ["a", "b"], now: currentDay)
        DailyReviewStore.save(reviewState, userId: "alice", defaults: defaults)
        check(!DailyReviewStore.recordAnswer(key: "a", userId: "alice", expectedDayKey: reviewState.dayKey, now: currentDay, defaults: defaults), "復習の途中では完了しない")
        check(DailyReviewStore.recordAnswer(key: "b", userId: "alice", expectedDayKey: reviewState.dayKey, now: currentDay, defaults: defaults), "復習の最終回答で完了する")
        check(!DailyReviewStore.recordAnswer(key: "b", userId: "alice", expectedDayKey: reviewState.dayKey, now: currentDay, defaults: defaults), "復習も完了を二重計測しない")

        let homeContext = LearningEntryContext(source: .home, activity: .quickQuiz, now: currentDay)
        let notificationContext = LearningEntryContext(source: .notification, activity: .review, now: currentDay)
        check(homeContext.parameters["entry_source"] as? String == "home", "ホームの入口を保持する")
        check(notificationContext.parameters["entry_source"] as? String == "notification", "通知の入口を保持する")
        check(homeContext.flowID != notificationContext.flowID, "別の学習操作を混ぜない")
        check(homeContext.parameters["learning_activity"] as? String == "quick_quiz", "学習種類をイベントで区別できる")

        check(homeContext.interstitialExclusionReason == "daily_learning", "毎日の3問は全画面広告を除外")
        check(notificationContext.interstitialExclusionReason == "daily_learning", "通知からの日課も全画面広告を除外")
        let scheduledContext = LearningEntryContext(source: .notification, activity: .scheduledReview, now: currentDay)
        check(scheduledContext.interstitialExclusionReason == nil, "通常の復習セッションの広告条件を維持")
        print("Home learning regression checks passed (\(checks) checks)")
    }
}
