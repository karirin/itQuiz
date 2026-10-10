import Foundation

@main
struct InitialLearningFlowTests {
    static func main() {
        // スキップはホームへ直行し、後から同じ3問を試せる。
        var skipped = InitialLearningFlow(hasSeenWelcome: false)
        assert(!skipped.allowsHomePrompts)
        skipped.skipWelcome()
        assert(skipped.phase == .home)
        skipped.startPractice()
        assert(!skipped.allowsHomePrompts)

        // 練習中断では通知を要求せず、再開して完了したときにだけ案内する。
        skipped.finishPractice(completed: false, canOfferReminder: true)
        assert(skipped.phase == .home)
        skipped.startPractice()
        skipped.finishPractice(completed: true, canOfferReminder: true)
        assert(skipped.phase == .reminder)
        assert(!skipped.allowsHomePrompts)
        skipped.finishReminder()
        assert(skipped.allowsHomePrompts)

        // 連打・遅いコールバックが現在の案内を飛ばさない。
        var fresh = InitialLearningFlow(hasSeenWelcome: false)
        fresh.startPractice()
        fresh.skipWelcome()
        fresh.startPractice()
        assert(fresh.phase == .practice)
        fresh.finishPractice(completed: true, canOfferReminder: true)
        fresh.finishPractice(completed: false, canOfferReminder: false)
        fresh.startPractice()
        assert(fresh.phase == .reminder)

        // 案内が既読なら完了後ホームへ戻る。
        var returning = InitialLearningFlow(hasSeenWelcome: true)
        assert(returning.allowsHomePrompts)
        returning.startPractice()
        returning.finishPractice(completed: true, canOfferReminder: false)
        assert(returning.phase == .home)
        returning.finishReminder()
        assert(returning.phase == .home)

        // 練習途中で終了しても、案内既読の次回起動はホームから再開できる。
        let relaunched = InitialLearningFlow(hasSeenWelcome: true)
        assert(relaunched.phase == .home)

        // 3問の後は操作案内が優先され、案内中はホームの通知・報酬を割り込ませない。
        var guided = InitialLearningFlow(hasSeenWelcome: false)
        guided.startPractice()
        guided.finishPractice(completed: true, canOfferReminder: true, canOfferSpotlight: true)
        assert(guided.phase == .spotlight && !guided.allowsHomePrompts)
        guided.finishPractice(completed: true, canOfferReminder: true)
        assert(guided.phase == .spotlight)
        guided.finishSpotlight(canOfferReminder: true)
        assert(guided.phase == .reminder)
        guided.finishReminder()
        assert(guided.phase == .home)
        guided.resumeSpotlight()
        guided.finishSpotlight(canOfferReminder: false)
        assert(guided.phase == .home)

        var interrupted = InitialLearningFlow(hasSeenWelcome: false)
        interrupted.startPractice()
        interrupted.finishPractice(completed: false, canOfferReminder: true, canOfferSpotlight: true)
        assert(interrupted.phase == .home)

        // 初回の結果のあとに名前を案内し、登録・後回しのどちらでも操作案内に進む。
        var named = InitialLearningFlow(hasSeenWelcome: false)
        named.startPractice()
        named.finishPractice(completed: true, canOfferReminder: true, canOfferSpotlight: true, canOfferNameRegistration: true)
        assert(named.phase == .nameRegistration && !named.allowsHomePrompts)
        named.finishPractice(completed: true, canOfferReminder: false)
        named.resumeSpotlight()
        assert(named.phase == .nameRegistration)
        named.finishNameRegistration()
        assert(named.phase == .spotlight)
        named.finishNameRegistration() // 遅い閉じる操作で次の案内を飛ばさない。
        assert(named.phase == .spotlight)
        named.finishSpotlight(canOfferReminder: true)
        assert(named.phase == .reminder)

        var skipWithName = InitialLearningFlow(hasSeenWelcome: false)
        skipWithName.skipWelcome(canOfferNameRegistration: true)
        assert(skipWithName.phase == .nameRegistration && !skipWithName.allowsHomePrompts)
        skipWithName.finishNameRegistration()
        assert(skipWithName.phase == .home)

        var nameThenReminder = InitialLearningFlow(hasSeenWelcome: true)
        nameThenReminder.startPractice()
        nameThenReminder.finishPractice(completed: true, canOfferReminder: true, canOfferNameRegistration: true)
        nameThenReminder.finishNameRegistration()
        assert(nameThenReminder.phase == .reminder)

        var interruptedWithName = InitialLearningFlow(hasSeenWelcome: false)
        interruptedWithName.startPractice()
        interruptedWithName.finishPractice(completed: false, canOfferReminder: true, canOfferNameRegistration: true)
        assert(interruptedWithName.phase == .nameRegistration)
        interruptedWithName.finishNameRegistration()
        assert(interruptedWithName.phase == .home)

        var resumedName = InitialLearningFlow(hasSeenWelcome: true, hasPendingNameRegistration: true)
        assert(resumedName.phase == .nameRegistration && !resumedName.allowsHomePrompts)
        resumedName.finishNameRegistration()
        assert(resumedName.phase == .home)

        var tour = InitialLearningTourProgress()
        tour.start()
        tour.advance(from: .qualification) // 別画面からの遅いイベントでは進めない。
        assert(tour.step == .home)
        for step in InitialLearningTourProgress.Step.allCases.dropLast() {
            assert(tour.step == step)
            tour.start() // 重複表示でも進捗を戻さない。
            tour.advance(from: step)
        }
        assert(tour.step == .completion)
        tour.finish()
        tour.advance(from: .explanation)
        assert(tour.step == nil)
        tour.start()
        tour.advance(from: .home)
        tour.finish() // スキップ後に遅いイベントが届いても再開しない。
        tour.advance(from: .qualification)
        assert(tour.step == nil)
        tour.start()
        tour.advance(from: .home)
        tour.advance(from: .qualification)
        tour.advance(from: .category)
        tour.revisit(.qualification) // 選択画面に戻れば、その画面の案内から再開する。
        assert(tour.step == .qualification)
        tour.revisit(.category) // 戻る操作で先の画面には進めない。
        assert(tour.step == .qualification)
        tour.finish()
        assert(InitialPracticeContent.questions.count == 3)
        assert(Set(InitialPracticeContent.questions.compactMap(\.id)).count == 3)
        for question in InitialPracticeContent.questions {
            assert(question.choices.count == 4)
            assert(question.choices.indices.contains(question.correctAnswerIndex))
            assert(!question.explanation.isEmpty)
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 7, hour: 23, minute: 59))!
        let plan = InitialLearningPlan(completedAt: now, incorrectCount: 1)
        let tomorrow = plan.reminderDate(hour: 20, now: now, calendar: calendar)!
        assert(calendar.component(.day, from: tomorrow) == 8)
        assert(calendar.component(.hour, from: tomorrow) == 20)
        assert(plan.reminderDate(hour: 20, now: tomorrow, calendar: calendar) == nil)
        assert(calendar.component(.hour, from: plan.reminderDate(hour: 0, now: now, calendar: calendar)!) == 6)
        assert(calendar.component(.hour, from: plan.reminderDate(hour: 99, now: now, calendar: calendar)!) == 23)
        let suite = "initial-learning-tests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let saved = InitialLearningPlanStore.recordCompletion(userID: "a", incorrectCount: 9, now: now, defaults: defaults)!
        assert(saved.incorrectCount == 3)
        assert(InitialLearningPlanStore.load(userID: "b", defaults: defaults) == nil)
        assert(InitialLearningPlanStore.recordCompletion(userID: "a", incorrectCount: 0, now: tomorrow, defaults: defaults) == saved)
        assert(InitialLearningPlanStore.recordCompletion(userID: "", incorrectCount: 0, defaults: defaults) == nil)
        print("InitialLearningFlow: all scenarios passed")
    }
}
