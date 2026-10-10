import Foundation

struct AdventurePlayerStats: Codable, Equatable {
    let level: Int
    let companionName: String?
    let companionHP: Int
    let companionAttack: Int

    init(level: Int, companionName: String? = nil, companionHP: Int = 0, companionAttack: Int = 0) {
        self.level = max(1, level)
        self.companionName = companionName
        self.companionHP = max(0, companionHP)
        self.companionAttack = max(0, companionAttack)
    }

    var baseHP: Int { 100 + (level - 1) * 10 }
    var baseAttack: Int { 20 + (level - 1) * 2 }
    var maximumHP: Int { baseHP + companionHP }
    var attack: Int { baseAttack + companionAttack }
    var isValid: Bool { level >= 1 && companionHP >= 0 && companionAttack >= 0 }
}

struct AdventureBattle: Codable, Equatable {
    let nodeID: Int
    let questions: [AdventureQuestion]
    var questionIndex = 0
    var enemyHP: Int
    var selectedAnswer: Int?
    // Missing snapshots belong to an old, interrupted battle. Keep its original balance.
    var enemyMaximumHP: Int?
    var enemyAttack: Int?
    var maximumEnemyHP: Int { enemyMaximumHP ?? (nodeID == 9 ? 90 : 60) }
    var attack: Int { enemyAttack ?? 20 }

    /// Trigger story reactions when crossing a threshold, even with a powerful companion.
    var guardianReaction: Int? {
        guard nodeID == 9, wasCorrect == true else { return nil }
        if enemyHP == 0 { return 0 }
        let previousHP = min(maximumEnemyHP, enemyHP + (playerAttackForReaction ?? 30))
        if enemyHP * 3 <= maximumEnemyHP && previousHP * 3 > maximumEnemyHP { return 1 }
        if enemyHP * 3 <= maximumEnemyHP * 2 && previousHP * 3 > maximumEnemyHP * 2 { return 2 }
        return nil
    }
    var playerAttackForReaction: Int?

    var currentQuestion: AdventureQuestion? {
        guard questions.indices.contains(questionIndex) else { return nil }
        return questions[questionIndex]
    }
    var wasCorrect: Bool? {
        guard let selectedAnswer, let currentQuestion else { return nil }
        return selectedAnswer == currentQuestion.correctAnswerIndex
    }
}

enum AdventureBattleStep: Equatable { case question, victory, defeat, unavailable }

/// Game rules are independent of SwiftUI, authentication and reward delivery.
/// Every action can be encoded before the next screen or network request starts.
struct AdventureProgress: Codable, Equatable {
    var version = 1
    private(set) var currentNodeID = 0
    private(set) var returnNodeID = 0
    private(set) var checkpointID = 0
    private(set) var clearedNodeIDs: Set<Int> = [0]
    private(set) var deliveredRewardIDs: Set<Int> = []
    private(set) var hp = 100
    // Optional for compatibility with saves made before level/companion stats existed.
    private(set) var playerStats: AdventurePlayerStats?
    var maximumHP: Int { playerStats?.maximumHP ?? 100 }
    var playerAttack: Int { playerStats?.attack ?? 30 }
    var potionHealing: Int { max(1, (maximumHP + 1) / 2) }

    @discardableResult
    mutating func updatePlayerStats(_ stats: AdventurePlayerStats) -> Bool {
        guard battle == nil, stats.isValid, playerStats != stats else { return false }
        let missingHP = maximumHP - hp
        // Changing equipment must never revive a defeated player.
        hp = hp == 0 ? 0 : max(0, stats.maximumHP - missingHP)
        playerStats = stats
        return true
    }
    private(set) var potions = 0
    private(set) var hasKey = false
    private(set) var battle: AdventureBattle?
    var course: AdventureCourse = .itPassport
    // Optional so saves created before dialogue was added still decode unchanged.
    var story: AdventureStoryProgress?

    var currentNode: AdventureNode { AdventureWorld.node(currentNodeID) ?? AdventureWorld.nodes[0] }
    var hasForestLight: Bool { clearedNodeIDs.contains(9) }
    var isChapterComplete: Bool { clearedNodeIDs.contains(10) }
    var earnedCoins: Int { AdventureWorld.nodes.filter { clearedNodeIDs.contains($0.id) }.reduce(0) { $0 + $1.coins } }
    var pendingRewardIDs: [Int] {
        AdventureWorld.nodes.filter { $0.coins > 0 && clearedNodeIDs.contains($0.id) && !deliveredRewardIDs.contains($0.id) }.map(\.id)
    }

    func blockedReason(for id: Int) -> String? {
        guard AdventureWorld.node(id) != nil else { return "行き先が見つかりません" }
        if id == 8 && !hasKey { return "古い祠で鍵を手に入れよう" }
        if id == 10 && !hasForestLight { return "森の主を倒すと道が開きます" }
        if route(to: id) == nil { return "手前のマスから道をつなごう" }
        return nil
    }

    /// Only cleared intermediate nodes may be crossed. Unresolved encounters
    /// cannot be used as shortcuts, including after restoring a saved game.
    func route(to target: Int) -> [Int]? {
        guard AdventureWorld.node(target) != nil, battle == nil else { return nil }
        if target == currentNodeID { return [currentNodeID] }
        guard target != 8 || hasKey, target != 10 || hasForestLight else { return nil }
        var queue = [[currentNodeID]]
        var seen: Set<Int> = [currentNodeID]
        var cursor = 0
        while cursor < queue.count {
            let path = queue[cursor]
            cursor += 1
            guard let last = path.last else { continue }
            for next in AdventureWorld.neighbors(of: last) where !seen.contains(next) {
                if last == currentNodeID && !clearedNodeIDs.contains(last) && !clearedNodeIDs.contains(next) { continue }
                let newPath = path + [next]
                if next == target { return newPath }
                if clearedNodeIDs.contains(next) {
                    seen.insert(next)
                    queue.append(newPath)
                }
            }
        }
        return nil
    }

    /// Routes presented on the map. Show every immediately actionable branch
    /// by default; selecting a locked or otherwise unreachable stop isolates
    /// the single route that leads to that stop.
    func mapRoutes(selectedNodeID: Int) -> [[Int]] {
        guard battle == nil else { return [] }
        if route(to: selectedNodeID) == nil {
            return AdventureWorld.guidanceRoute(from: currentNodeID, to: selectedNodeID).map { [$0] } ?? []
        }
        return AdventureWorld.nodes.compactMap { node in
            guard node.id != currentNodeID,
                  !clearedNodeIDs.contains(node.id),
                  let route = route(to: node.id),
                  route.count > 1 else { return nil }
            return route
        }
    }

    @discardableResult
    mutating func arrive(at target: Int) -> Bool {
        guard let path = route(to: target) else { return false }
        if path.count > 1 {
            returnNodeID = path[path.count - 2]
            currentNodeID = target
        }
        if currentNode.kind == .road || (currentNode.kind == .bridge && hasKey) || (currentNode.kind == .port && hasForestLight) {
            clearedNodeIDs.insert(target)
        }
        return true
    }

#if DEBUG
    /// Developer builds may visit any stop without resolving the intervening events.
    func routeForDebug(to target: Int) -> [Int]? {
        guard battle == nil else { return nil }
        return AdventureWorld.guidanceRoute(from: currentNodeID, to: target)
    }

    @discardableResult
    mutating func arriveForDebug(at target: Int) -> Bool {
        guard let path = routeForDebug(to: target) else { return false }
        // Keep the save compatible with normal builds, including after a boss victory.
        if [8, 9, 10].contains(target) {
            hasKey = true
            clearedNodeIDs.insert(5)
        }
        if [9, 10].contains(target) { clearedNodeIDs.insert(8) }
        if target == 10, clearedNodeIDs.insert(9).inserted {
            // Skipping the boss is not a victory and must not queue its coin reward.
            deliveredRewardIDs.insert(9)
        }
        if path.count > 1 {
            returnNodeID = path[path.count - 2]
            currentNodeID = target
        }
        if [.road, .bridge, .port].contains(currentNode.kind) {
            clearedNodeIDs.insert(target)
        }
        return true
    }
#endif

    @discardableResult
    mutating func collectTreasure() -> Bool {
        guard currentNode.kind == .treasure, !clearedNodeIDs.contains(currentNodeID), battle == nil else { return false }
        clearedNodeIDs.insert(currentNodeID)
        if AdventureWorld.treasureGrantsPotion(currentNodeID) { potions += 1 }
        return true
    }

    @discardableResult
    mutating func collectKey() -> Bool {
        guard currentNode.kind == .shrine, battle == nil, !hasKey else { return false }
        hasKey = true
        clearedNodeIDs.insert(currentNodeID)
        return true
    }

    @discardableResult
    mutating func rest() -> Bool {
        guard currentNode.kind == .village, battle == nil else { return false }
        hp = maximumHP
        checkpointID = currentNodeID
        clearedNodeIDs.insert(currentNodeID)
        return true
    }

    /// Saves from the previous map used camps as checkpoints. The revised map
    /// has no mid-route recovery stops, so safely return those players to the
    /// village checkpoint when their progress is loaded.
    mutating func migrateCheckpointToVillage() {
        guard AdventureWorld.node(checkpointID)?.kind != .village else { return }
        checkpointID = 0
    }

    /// Keeps a mid-conversation bookmark readable after the script is rewritten:
    /// a page past the new end resumes on the last line, and the retired
    /// key scene is treated as already read.
    mutating func migrateStoryBookmark() {
        guard let bookmark = story?.bookmark else { return }
        let count = bookmark.scene.lines.count
        if count == 0 {
            story?.completed.insert(bookmark.scene)
            story?.bookmark = nil
        } else if bookmark.page >= count {
            story?.bookmark?.page = count - 1
        }
    }

    /// Maps saves that were written while the removed stream-path detour was
    /// still part of the world. The detour only connected to the first chest,
    /// so returning a player there preserves their reachable route and loot.
    mutating func migrateRemovedStreamPath() {
        let removedNodeID = 11
        let fallbackNodeID = 2

        if currentNodeID == removedNodeID { currentNodeID = fallbackNodeID }
        if returnNodeID == removedNodeID { returnNodeID = fallbackNodeID }
        if checkpointID == removedNodeID { checkpointID = 0 }
        clearedNodeIDs.remove(removedNodeID)
        deliveredRewardIDs.remove(removedNodeID)
        if battle?.nodeID == removedNodeID { battle = nil }
    }

    @discardableResult
    mutating func usePotion() -> Bool {
        guard potions > 0, hp < maximumHP, battle == nil else { return false }
        potions -= 1
        hp = min(maximumHP, hp + potionHealing)
        return true
    }

    @discardableResult
    mutating func startBattle(questions: [AdventureQuestion]) -> Bool {
        guard currentNode.isBattle, !clearedNodeIDs.contains(currentNodeID), hp > 0 else { return false }
        if battle != nil { return battle?.nodeID == currentNodeID }
        let validQuestions = questions.filter(\.isValid)
        guard !validQuestions.isEmpty else { return false }
        battle = AdventureBattle(nodeID: currentNodeID, questions: validQuestions, enemyHP: currentNode.enemyHP,
                                 enemyMaximumHP: currentNode.enemyHP, enemyAttack: currentNode.enemyAttack,
                                 playerAttackForReaction: playerAttack)
        return true
    }

    @discardableResult
    mutating func answer(_ index: Int) -> Bool? {
        guard var next = battle, next.selectedAnswer == nil, next.enemyHP > 0, hp > 0,
              let question = next.currentQuestion, question.choices.indices.contains(index) else { return nil }
        let correct = index == question.correctAnswerIndex
        next.selectedAnswer = index
        if correct { next.enemyHP = max(0, next.enemyHP - playerAttack) } else { hp = max(0, hp - next.attack) }
        battle = next
        return correct
    }

    mutating func advanceBattle() -> AdventureBattleStep {
        guard var next = battle, next.selectedAnswer != nil else { return .unavailable }
        if hp == 0 {
            battle = nil
            currentNodeID = returnNodeID
            return .defeat
        }
        if next.enemyHP == 0 {
            clearedNodeIDs.insert(next.nodeID)
            battle = nil
            return .victory
        }
        next.questionIndex = (next.questionIndex + 1) % next.questions.count
        next.selectedAnswer = nil
        battle = next
        return .question
    }

    mutating func retreat() {
        guard currentNode.isBattle, !clearedNodeIDs.contains(currentNodeID) else { return }
        battle = nil
        currentNodeID = clearedNodeIDs.contains(returnNodeID) ? returnNodeID : checkpointID
    }

    mutating func acknowledgeReward(_ id: Int) {
        guard clearedNodeIDs.contains(id), (AdventureWorld.node(id)?.coins ?? 0) > 0 else { return }
        deliveredRewardIDs.insert(id)
    }

    /// Treat unknown/corrupt saves as errors instead of silently creating a
    /// fresh run that could discard the player's progress.
    var isValid: Bool {
        let ids = Set(AdventureWorld.nodes.map(\.id))
        guard version == 1, ids.contains(currentNodeID), ids.contains(returnNodeID),
              AdventureWorld.node(checkpointID).map({ [.village, .camp].contains($0.kind) }) == true,
              clearedNodeIDs.contains(checkpointID),
              clearedNodeIDs.contains(0), clearedNodeIDs.isSubset(of: ids),
              deliveredRewardIDs.isSubset(of: clearedNodeIDs), maximumHP > 0, playerStats?.isValid ?? true, (0...maximumHP).contains(hp), potions >= 0,
              hasKey == clearedNodeIDs.contains(5), !clearedNodeIDs.contains(8) || hasKey,
              !clearedNodeIDs.contains(9) || clearedNodeIDs.contains(8),
              !isChapterComplete || hasForestLight,
              story?.bookmark.map({ $0.isValid && $0.scene.isUnlocked(in: self) }) ?? true else { return false }
        if let battle {
            guard battle.nodeID == currentNodeID, currentNode.isBattle, !clearedNodeIDs.contains(currentNodeID),
                  !battle.questions.isEmpty, battle.questions.allSatisfy(\.isValid),
                  let question = battle.currentQuestion, battle.maximumEnemyHP > 0, battle.attack > 0,
                  (0...battle.maximumEnemyHP).contains(battle.enemyHP),
                  battle.selectedAnswer.map({ question.choices.indices.contains($0) }) ?? true else { return false }
        }
        return true
    }
}

enum AdventureSaveError: LocalizedError {
    case unreadable, invalidProgress
    var errorDescription: String? {
        "冒険の記録を読み込めませんでした。記録を残したまま、読み込みをやり直せます。"
    }
}

struct AdventureSaveRepository {
    let defaults: UserDefaults
    let accountID: String
    var key: String { "storyAdventure.progress.v1.\(Data(accountID.utf8).base64EncodedString())" }

    func load() throws -> AdventureProgress {
        guard let data = defaults.data(forKey: key) else { return AdventureProgress() }
        guard var progress = try? JSONDecoder().decode(AdventureProgress.self, from: data) else { throw AdventureSaveError.unreadable }
        let savedProgress = progress
        progress.migrateRemovedStreamPath()
        progress.migrateCheckpointToVillage()
        progress.migrateStoryBookmark()
        guard progress.isValid else { throw AdventureSaveError.invalidProgress }
        if progress != savedProgress { try save(progress) }
        return progress
    }

    func save(_ progress: AdventureProgress) throws {
        guard progress.isValid else { throw AdventureSaveError.invalidProgress }
        defaults.set(try JSONEncoder().encode(progress), forKey: key)
    }
}
