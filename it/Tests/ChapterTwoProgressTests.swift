import Foundation

@main
enum ChapterTwoProgressTests {
    static var checks = 0
    static let question = AdventureQuestion(id: "chapter-two-test", question: "保存先は？",
                                            choices: ["正しい答え", "誤り"], correctAnswerIndex: 0,
                                            explanation: "正しい答えを確かめます。")

    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        checks += 1
        precondition(condition(), message)
    }

    static func main() throws {
        check(ChapterTwoScene.allCases.count == 12, "Every scripted scene should be present")
        check(ChapterTwoScene.allCases.allSatisfy { !$0.lines.isEmpty && !$0.title.isEmpty },
              "Every scene needs readable dialogue")
        var progress = ChapterTwoProgress()
        check(progress.isValid && progress.scene == .lighthouse, "New journeys start at the lighthouse")
        check(!progress.previousPage(), "The first scene cannot go backward")
        check(progress.advanceScene() && progress.page == 1, "Dialogue advances one page")
        check(progress.previousPage() && progress.page == 0, "Dialogue can be reread")

        let suiteName = "chapter-two-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let alice = ChapterTwoSaveRepository(defaults: defaults, accountID: "alice")
        let bob = ChapterTwoSaveRepository(defaults: defaults, accountID: "bob")
        try alice.save(progress)
        let resumedDialogue = try alice.load()
        let separateAccount = try bob.load()
        check(resumedDialogue == progress, "A dialogue bookmark survives saving")
        check(separateAccount == ChapterTwoProgress(), "Accounts use separate chapter saves")

        while progress.scene != .shellBeach { check(progress.skipScene(), "Scenes can be skipped") }
        check(progress.stageIndex == 3 && progress.isValid, "The beach follows the opening scenes")
        check(progress.skipScene() && progress.encounter == .kelp, "The first battle follows the beach")
        check(!progress.skipScene(), "A battle cannot be skipped as dialogue")
        check(progress.startBattle(questions: [question]), "The first battle starts with valid questions")
        check(progress.answer(1) == false && progress.hp == 80, "Wrong answers damage the player")
        try alice.save(progress)
        progress = try alice.load()
        check(progress.battle?.selectedAnswer == 1, "Selected answers survive an interrupted battle")
        check(progress.advanceBattle() == .question, "A miss continues the battle")
        while progress.encounter != nil {
            check(progress.answer(0) == true, "Correct answers damage the monster")
            let result = progress.advanceBattle()
            check(result == .question || result == .victory, "Winning does not skip the next scene")
        }
        check(progress.scene == .pier && progress.hp == 80, "The pier follows the first victory")

        while !progress.isComplete {
            if progress.scene != nil {
                check(progress.skipScene(), "Scene skipping should remain valid")
            } else if progress.encounter != nil {
                if progress.hp < 100 { check(progress.rest(), "A ship rest recovers HP before a new battle") }
                check(progress.startBattle(questions: [question]), "Each battle starts")
                while progress.encounter != nil {
                    check(progress.answer(0) == true, "Correct quiz answer applies damage")
                    let result = progress.advanceBattle()
                    check(result == .question || result == .victory, "Battle advances or ends")
                }
            }
            check(progress.isValid, "Every step remains saveable")
        }
        check(progress.isComplete && progress.stageIndex == 15, "The ending follows the full chapter")
        try alice.save(progress)
        let resumedEnding = try alice.load()
        check(resumedEnding == progress, "Chapter completion survives relaunch")

        let corrupt = Data("broken".utf8)
        defaults.set(corrupt, forKey: alice.key)
        do { _ = try alice.load(); preconditionFailure("Corrupt data must not reset the chapter") }
        catch { check(defaults.data(forKey: alice.key) == corrupt, "Corrupt data is preserved") }
        print("Chapter 2 progression: \(checks) checks passed")
    }
}
