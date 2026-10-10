import Foundation

struct ChapterTwoBattle: Codable, Equatable {
    let encounter: ChapterTwoEncounter
    let questions: [AdventureQuestion]
    var questionIndex = 0
    var enemyHP: Int
    var selectedAnswer: Int?

    var currentQuestion: AdventureQuestion? {
        guard questions.indices.contains(questionIndex) else { return nil }
        return questions[questionIndex]
    }
    var wasCorrect: Bool? {
        guard let selectedAnswer, let currentQuestion else { return nil }
        return selectedAnswer == currentQuestion.correctAnswerIndex
    }
}

enum ChapterTwoBattleStep { case question, victory, defeat, unavailable }

/// The second chapter has a separate save. Its stage index is durable, and a
/// battle stores its question order so leaving the app never rerolls answers.
struct ChapterTwoProgress: Codable, Equatable {
    var version = 1
    private(set) var stageIndex = 0
    private(set) var page = 0
    private(set) var hp = 100
    private(set) var battle: ChapterTwoBattle?

    var isComplete: Bool { stageIndex == ChapterTwoStage.all.count }
    var stage: ChapterTwoStage? {
        guard ChapterTwoStage.all.indices.contains(stageIndex) else { return nil }
        return ChapterTwoStage.all[stageIndex]
    }
    var scene: ChapterTwoScene? {
        guard case .scene(let scene)? = stage else { return nil }
        return scene
    }
    var encounter: ChapterTwoEncounter? {
        guard case .battle(let encounter)? = stage else { return nil }
        return encounter
    }

    @discardableResult
    mutating func advanceScene() -> Bool {
        guard let scene else { return false }
        if page + 1 < scene.lines.count {
            page += 1
        } else {
            stageIndex += 1
            page = 0
        }
        return true
    }

    @discardableResult
    mutating func previousPage() -> Bool {
        guard scene != nil, page > 0 else { return false }
        page -= 1
        return true
    }

    @discardableResult
    mutating func skipScene() -> Bool {
        guard scene != nil else { return false }
        stageIndex += 1
        page = 0
        return true
    }

    @discardableResult
    mutating func rest() -> Bool {
        guard encounter != nil, battle == nil, hp < 100 else { return false }
        hp = 100
        return true
    }

    @discardableResult
    mutating func startBattle(questions: [AdventureQuestion]) -> Bool {
        guard let encounter, battle == nil, hp > 0 else { return false }
        let validQuestions = questions.filter(\.isValid)
        guard !validQuestions.isEmpty else { return false }
        battle = ChapterTwoBattle(encounter: encounter, questions: validQuestions, enemyHP: encounter.hp)
        return true
    }

    @discardableResult
    mutating func answer(_ index: Int) -> Bool? {
        guard var battle, battle.selectedAnswer == nil, hp > 0, battle.enemyHP > 0,
              let question = battle.currentQuestion, question.choices.indices.contains(index) else { return nil }
        let correct = index == question.correctAnswerIndex
        battle.selectedAnswer = index
        if correct { battle.enemyHP = max(0, battle.enemyHP - 30) }
        else { hp = max(0, hp - battle.encounter.attack) }
        self.battle = battle
        return correct
    }

    mutating func advanceBattle() -> ChapterTwoBattleStep {
        guard var battle, battle.selectedAnswer != nil else { return .unavailable }
        if hp == 0 {
            self.battle = nil
            hp = 100
            return .defeat
        }
        if battle.enemyHP == 0 {
            self.battle = nil
            stageIndex += 1
            page = 0
            return .victory
        }
        battle.questionIndex = (battle.questionIndex + 1) % battle.questions.count
        battle.selectedAnswer = nil
        self.battle = battle
        return .question
    }

    var isValid: Bool {
        guard version == 1, (0...ChapterTwoStage.all.count).contains(stageIndex),
              (0...100).contains(hp) else { return false }
        if let scene {
            return scene.lines.indices.contains(page) && battle == nil
        }
        if let encounter {
            guard page == 0 else { return false }
            guard let battle else { return hp > 0 }
            guard battle.encounter == encounter, !battle.questions.isEmpty,
                  battle.questions.allSatisfy(\.isValid),
                  let question = battle.currentQuestion,
                  (0...encounter.hp).contains(battle.enemyHP),
                  battle.selectedAnswer.map({ question.choices.indices.contains($0) }) ?? true else { return false }
            return hp > 0 || battle.selectedAnswer != nil
        }
        return isComplete && page == 0 && battle == nil
    }
}

enum ChapterTwoSaveError: LocalizedError {
    case unreadable, invalid
    var errorDescription: String? {
        "第2章の記録を読み込めませんでした。記録は残したまま、もう一度読み込めます。"
    }
}

struct ChapterTwoSaveRepository {
    let defaults: UserDefaults
    let accountID: String
    var key: String { "storyAdventure.chapter02.v1.\(Data(accountID.utf8).base64EncodedString())" }

    func load() throws -> ChapterTwoProgress {
        guard let data = defaults.data(forKey: key) else { return ChapterTwoProgress() }
        guard let progress = try? JSONDecoder().decode(ChapterTwoProgress.self, from: data) else {
            throw ChapterTwoSaveError.unreadable
        }
        guard progress.isValid else { throw ChapterTwoSaveError.invalid }
        return progress
    }

    func save(_ progress: ChapterTwoProgress) throws {
        guard progress.isValid else { throw ChapterTwoSaveError.invalid }
        defaults.set(try JSONEncoder().encode(progress), forKey: key)
    }
}
