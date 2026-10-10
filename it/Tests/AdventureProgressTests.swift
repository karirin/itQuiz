import Foundation

@main
enum AdventureProgressTests {
    static var checks = 0
    static let question = AdventureQuestion(id: "test-memory", question: "RAMの役割は？", choices: ["一時保存", "印刷"], correctAnswerIndex: 0, explanation: "処理中のデータを一時保存します。")

    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        checks += 1
        precondition(condition(), message)
    }

    static func win(_ progress: inout AdventureProgress, wrongFirst: Bool = false) {
        check(progress.startBattle(questions: [question]), "Battle should start at a live enemy")
        if wrongFirst {
            check(progress.answer(1) == false, "Wrong answer should damage player")
            check(progress.advanceBattle() == .question, "Battle should continue after a miss")
        }
        while progress.battle != nil {
            check(progress.answer(0) == true, "Correct answer should damage enemy")
            let step = progress.advanceBattle()
            check(step == .question || step == .victory, "Unexpected battle outcome")
        }
    }

    static func reachMossSlime(_ progress: inout AdventureProgress) -> Bool {
        guard progress.arrive(at: 21), progress.arrive(at: 22) else { return false }
        win(&progress)
        return progress.arrive(at: 3)
    }

    static func reachTravelerChest(_ progress: inout AdventureProgress) -> Bool {
        guard progress.arrive(at: 25), progress.collectTreasure() else { return false }
        return progress.arrive(at: 7)
    }

    static func main() throws {
        check(AdventureWorld.nodes.count == 38, "The map should omit the removed stream-path detour")
        check(Set(AdventureWorld.nodes.map(\.id)) == Set((0..<39).filter { $0 != 11 }), "Stop IDs must remain unique and preserve existing saves")
        check(AdventureWorld.edges.allSatisfy { AdventureWorld.node($0.0) != nil && AdventureWorld.node($0.1) != nil },
              "Every route should connect existing stops")
        check(AdventureWorld.neighbors(of: 0) == [1],
              "The village must have one clear departure through the forest entrance")
        let trails = [
            [1, 21, 22, 3], [12, 23, 13], [13, 24, 6],
            [6, 25, 7], [4, 26, 27, 5], [7, 28, 16], [5, 29, 15]
        ]
        for trail in trails {
            let start = trail.first!, end = trail.last!
            check(!AdventureWorld.neighbors(of: start).contains(end),
                  "A trail must not have a parallel shortcut that skips its intermediate stops")
            check(zip(trail, trail.dropFirst()).allSatisfy { AdventureWorld.neighbors(of: $0).contains($1) },
                  "Every intermediate stop must connect in trail order")
            check(trail.dropFirst().dropLast().allSatisfy { AdventureWorld.neighbors(of: $0).count == 2 },
                  "An intermediate stop on one trail must not add another parallel branch")
            check(AdventureWorld.guidanceRoute(from: start, to: end) == trail,
                  "Guidance must use the nearby trail rather than a longer branch with fewer stops")
            check(AdventureWorld.guidanceRoute(from: end, to: start) == Array(trail.reversed()),
                  "The same nearby trail must remain the guide when returning")
        }
        let edgeKeys = AdventureWorld.edges.map { a, b in "\(min(a, b))-\(max(a, b))" }
        check(Set(edgeKeys).count == edgeKeys.count, "Every trail segment must be drawn only once")
        check(AdventureWorld.nodes.allSatisfy { AdventureWorld.guidanceRoute(from: 0, to: $0.id) != nil },
              "Consolidating trails must keep every stop connected to the village")

        let newStops = AdventureWorld.nodes.filter { $0.id >= 19 }
        check(newStops.count == 20 && newStops.allSatisfy { !$0.name.isEmpty && !$0.detail.isEmpty },
              "Every added stop should have player-facing story copy")
        let treasureIDs = Set(AdventureWorld.nodes.filter { $0.kind == .treasure }.map(\.id))
        check(AdventureWorld.potionTreasureIDs.count == 6
              && AdventureWorld.potionTreasureIDs.isSubset(of: treasureIDs),
              "Exactly six treasure chests should grant recovery potions")

#if DEBUG
        for node in AdventureWorld.nodes {
            var debugProgress = AdventureProgress()
            check(debugProgress.routeForDebug(to: node.id) != nil,
                  "Every stop should be reachable in developer mode")
            check(debugProgress.arriveForDebug(at: node.id), "Developer travel should reach the selected stop")
            check(debugProgress.currentNodeID == node.id && debugProgress.isValid,
                  "Developer travel must preserve a valid save at every stop")
            if let scene = AdventureStoryScene.arriving(at: node.id) {
                debugProgress.story = AdventureStoryProgress(bookmark: AdventureStoryBookmark(scene: scene))
            }
            let roundTrip = try JSONDecoder().decode(AdventureProgress.self, from: JSONEncoder().encode(debugProgress))
            check(roundTrip == debugProgress && roundTrip.isValid,
                  "Developer travel and its arrival dialogue must survive reloading")
        }
        var debugProgress = AdventureProgress()
        check(!debugProgress.arriveForDebug(at: 999) && debugProgress == AdventureProgress(),
              "Developer travel must reject invalid stops without changing progress")
        check(debugProgress.arriveForDebug(at: 9), "Developer mode should allow direct travel to the boss")
        check(!debugProgress.clearedNodeIDs.contains(3) && debugProgress.pendingRewardIDs.isEmpty,
              "Passing intervening encounters must not clear them or grant rewards")
        check(debugProgress.startBattle(questions: [question]), "A directly reached boss should remain playable")
        check(debugProgress.routeForDebug(to: 0) == nil && !debugProgress.arriveForDebug(at: 0),
              "Developer travel must not abandon an active battle")
        win(&debugProgress)
        check(debugProgress.isValid && debugProgress.pendingRewardIDs == [9],
              "Winning a directly reached boss must preserve its real reward and valid save")
        check(debugProgress.arriveForDebug(at: 10) && debugProgress.pendingRewardIDs == [9],
              "Developer travel must not consume an already earned boss reward")
        var skippedBoss = AdventureProgress()
        check(skippedBoss.arriveForDebug(at: 10) && skippedBoss.isChapterComplete
              && skippedBoss.isValid && skippedBoss.pendingRewardIDs.isEmpty,
              "Skipping to the port must keep the save valid without granting the skipped boss reward")
#endif

        var progress = AdventureProgress()
        check(progress.isValid, "Initial state must be valid")
        check(progress.route(to: 1) == [0, 1], "First path should be available")
        check(progress.route(to: 2) == nil, "Uncleared road must not be crossed")
        check(progress.mapRoutes(selectedNodeID: 1) == [[0, 1]],
              "The map should show every currently reachable next route")
        check(progress.mapRoutes(selectedNodeID: 2) == [[0, 1, 2]],
              "An unavailable selection should isolate its one guidance route")
        check(!progress.arrive(at: 9), "Boss cannot be reached from the village")
        check(!progress.arrive(at: 999), "Invalid destination must be rejected")
        check(!progress.collectTreasure() && !progress.collectKey(), "Loot cannot be claimed remotely")
        check(progress.arrive(at: 1), "Road should be reachable")
        check(Set(progress.mapRoutes(selectedNodeID: 1).compactMap(\.last)) == [2, 21],
              "The entrance must show only the west chest and the single eastern trail")
        check(progress.mapRoutes(selectedNodeID: 3) == [[1, 21, 22, 3]],
              "Selecting the first monster must show one guide through the intermediate stops")
        check(progress.arrive(at: 2), "First chest should be reachable")
        check(progress.route(to: 4) == nil, "Unopened chest must not become a shortcut")
        check(progress.collectTreasure(), "Chest should grant loot once")
        check(!progress.collectTreasure(), "Repeated claim must not grant loot")
        check(progress.earnedCoins == 80 && progress.potions == 1, "Chest reward mismatch")
        check(!progress.usePotion(), "Full HP must not consume potion")
        check(progress.route(to: 21) == [2, 1, 21], "Cleared paths should support backtracking")
        check(progress.route(to: 3) == nil, "The first monster must not bypass the birdsong path and vine slime")
        check(reachMossSlime(&progress), "Monster should be reachable through the single eastern trail")
        check(!progress.startBattle(questions: []), "Empty question pool must not start battle")
        check(progress.startBattle(questions: [question]), "Battle should begin")
        check(progress.answer(9) == nil, "Invalid answer must not change battle")
        check(progress.answer(1) == false && progress.hp == 65, "Wrong answer should use the enemy attack")
        check(progress.answer(0) == nil && progress.hp == 65, "Double taps must not apply damage twice")

        let battleData = try JSONEncoder().encode(progress)
        var resumed = try JSONDecoder().decode(AdventureProgress.self, from: battleData)
        check(resumed.isValid && resumed == progress, "Battle snapshot should survive encoding")
        check(resumed.battle?.selectedAnswer == 1, "Answer feedback should survive interruption")
        check(resumed.startBattle(questions: []) && resumed.hp == 65, "Resuming must not reset health or questions")
        check(resumed.route(to: 4) == nil, "Active battle must block travel")
        check(resumed.advanceBattle() == .question, "Restored feedback should advance once")
        check(resumed.advanceBattle() == .unavailable, "Unanswered question cannot be skipped")
        win(&resumed)
        check(resumed.clearedNodeIDs.contains(3) && resumed.earnedCoins == 175, "Victory should clear node and queue coins")
        check(!resumed.startBattle(questions: [question]), "Cleared enemies cannot farm rewards")
        check(resumed.usePotion() && resumed.hp == 100 && resumed.potions == 0, "Potion should heal and be consumed")
        check(!resumed.usePotion(), "Consumed potion must not be reused")
        resumed.acknowledgeReward(2)
        resumed.acknowledgeReward(2)
        resumed.acknowledgeReward(9)
        check(resumed.pendingRewardIDs == [3, 22], "Only earned, undelivered rewards should be retried")
        check(AdventureWorld.rewardKey(for: 2) == "story-adventure.forest-v1.node-2", "Reward identity must be stable")
        check(resumed.arrive(at: 4), "The crossroads should remain passable")
        check(resumed.checkpointID == 0, "Only the village should remain a checkpoint")
        check(resumed.arrive(at: 6), "Second enemy should be reachable")
        check(resumed.route(to: 7) == nil, "Uncleared enemy must block its treasure")
        resumed.retreat()
        check(resumed.currentNodeID == 4, "Retreat should return to previous cleared node")
        check(resumed.arrive(at: 6), "Enemy should remain replayable after retreat")
        win(&resumed)
        let potionsBeforeTravelerChest = resumed.potions
        check(reachTravelerChest(&resumed) && resumed.collectTreasure(), "Traveler chest should be collectable")
        check(resumed.potions == potionsBeforeTravelerChest + 2,
              "The two chests on the traveler trail should each grant a potion")
        check(resumed.route(to: 8) == nil, "Bridge must stay locked without key, even via treasure route")
        check(resumed.arrive(at: 26) && resumed.arrive(at: 27), "The shrine trail should pass the ancient tree and guardian")
        win(&resumed)
        check(resumed.arrive(at: 5) && resumed.collectKey(), "Shrine should grant key")
        check(!resumed.collectKey(), "Key cannot be collected twice")
        check(resumed.arrive(at: 8), "Key should unlock bridge")
        check(resumed.route(to: 10) == nil, "Port must remain locked before boss")
        check(resumed.arrive(at: 9) && resumed.startBattle(questions: [question]), "Boss should be playable")
        check(resumed.battle?.maximumEnemyHP == 1000 && resumed.battle?.attack == 80,
              "A new boss battle should snapshot the increased HP and attack")
        while resumed.hp > 0 {
            check(resumed.answer(1) == false, "Boss miss should be accepted")
            if resumed.hp > 0 { check(resumed.advanceBattle() == .question, "Boss battle should continue while HP remains") }
        }
        check(resumed.hp == 0 && resumed.isValid, "Defeat feedback must remain saveable")
        let defeatedData = try JSONEncoder().encode(resumed)
        resumed = try JSONDecoder().decode(AdventureProgress.self, from: defeatedData)
        let clearedBeforeDefeat = resumed.clearedNodeIDs
        let rewardsBeforeDefeat = resumed.pendingRewardIDs
        let potionsBeforeDefeat = resumed.potions
        check(resumed.advanceBattle() == .defeat, "Saved defeat should resolve once")
        check(resumed.currentNodeID == 8 && resumed.returnNodeID == 8 && resumed.hp == 0 && resumed.battle == nil,
              "Defeat should return exactly one stop to the bridge without healing")
        check(resumed.isValid && resumed.clearedNodeIDs == clearedBeforeDefeat
              && resumed.pendingRewardIDs == rewardsBeforeDefeat && resumed.potions == potionsBeforeDefeat,
              "Defeat must remain saveable without clearing the enemy, granting rewards or consuming a potion")
        check(resumed.advanceBattle() == .unavailable && resumed.currentNodeID == 8,
              "Repeated defeat resolution must not move the player another stop")
        let defeatSuite = "story-adventure-defeat-tests-\(UUID().uuidString)"
        let defeatDefaults = UserDefaults(suiteName: defeatSuite)!
        defer { defeatDefaults.removePersistentDomain(forName: defeatSuite) }
        let defeatRepository = AdventureSaveRepository(defaults: defeatDefaults, accountID: "defeated")
        try defeatRepository.save(resumed)
        let reloadedDefeat = try defeatRepository.load()
        check(reloadedDefeat == resumed, "A zero-HP defeat must survive saving and loading without recovery")
        check(resumed.arrive(at: 0) && resumed.hp == 0,
              "Returning to the village must preserve HP without automatic recovery")
        check(resumed.arrive(at: 8) && resumed.hp == 0,
              "Leaving the village must preserve HP without automatic recovery")
        check(resumed.hasKey && resumed.clearedNodeIDs.contains(7) && resumed.potions == potionsBeforeDefeat,
              "Defeat must preserve loot")
        check(resumed.arrive(at: 9), "Boss should remain available after defeat")
        check(!resumed.startBattle(questions: [question]), "Zero HP must not start a battle")
        check(resumed.usePotion() && resumed.hp == 50 && resumed.potions == potionsBeforeDefeat - 1,
              "A player may explicitly use an owned potion after defeat")
        win(&resumed)
        check(resumed.hasForestLight && resumed.arrive(at: 10), "Boss victory should open port")
        check(resumed.isChapterComplete && resumed.isValid, "Chapter should be complete and valid")
        check(resumed.earnedCoins == 770, "The revised route must grant each intermediate and original reward exactly once")
        check(resumed.arrive(at: 30) && resumed.arrive(at: 31) && resumed.collectTreasure(),
              "The northern extension should open after reaching the port")
        check(resumed.arrive(at: 32), "The northern guardian should follow the new treasure")
        win(&resumed)
        check(resumed.arrive(at: 33), "The northern extension should end at a passable path")

        var westernBranch = AdventureProgress()
        check(westernBranch.arrive(at: 1) && westernBranch.arrive(at: 2) && westernBranch.collectTreasure(),
              "West path should begin through the single forest entrance")
        check(westernBranch.arrive(at: 14), "West guard should be reachable from the first chest")
        win(&westernBranch)
        check(westernBranch.arrive(at: 5) && westernBranch.collectKey(), "West guard should lead to the shrine")
        check(westernBranch.arrive(at: 29) && westernBranch.collectTreasure() && westernBranch.arrive(at: 15) && westernBranch.collectTreasure(), "Waterfall chest should grant its reward")
        check(westernBranch.arrive(at: 18), "Mist slime should be reachable beyond the waterfall chest")
        win(&westernBranch)
        check(westernBranch.earnedCoins == 430 && westernBranch.potions == 3,
              "Optional chests and encounters should grant their own rewards")

        var easternBranch = AdventureProgress()
        check(easternBranch.arrive(at: 1) && reachMossSlime(&easternBranch), "East branch should start through the original path")
        win(&easternBranch)
        check(easternBranch.arrive(at: 12) && easternBranch.collectTreasure(), "Sunlit chest should be collectable")
        check(easternBranch.arrive(at: 23) && easternBranch.arrive(at: 13), "East crossroads should remain passable")
        check(easternBranch.checkpointID == 0 && easternBranch.isValid,
              "A mid-route crossroads must not create a checkpoint")
        check(easternBranch.arrive(at: 17) && easternBranch.startBattle(questions: [question]),
              "Hill guard should be playable from the east camp")
        while easternBranch.hp > 0 {
            check(easternBranch.answer(1) == false, "Hill guard should deal damage on wrong answers")
            if easternBranch.hp > 0 { check(easternBranch.advanceBattle() == .question, "Hill guard battle should continue") }
        }
        check(easternBranch.advanceBattle() == .defeat && easternBranch.currentNodeID == 13 && easternBranch.hp == 0,
              "Defeat on a branch should return to the actual previous stop without healing")
        check(easternBranch.usePotion(), "An owned potion should allow continuing from the branch")
        check(easternBranch.arrive(at: 24) && easternBranch.arrive(at: 6), "East crossroads should reconnect to the original forest path")
        win(&easternBranch)
        check(reachTravelerChest(&easternBranch) && easternBranch.collectTreasure() && easternBranch.arrive(at: 28) && easternBranch.arrive(at: 16),
              "The hill lookout should be reachable through the original treasure")
        check(!easternBranch.arrive(at: 10), "The alternate port route must stay locked until the boss is defeated")
        let easternData = try JSONEncoder().encode(easternBranch)
        let easternReloaded = try JSONDecoder().decode(AdventureProgress.self, from: easternData)
        check(easternReloaded.isValid && easternReloaded == easternBranch,
              "Expanded branch progress should survive a saved-game round trip")

        var addedBranch = AdventureProgress()
        check(addedBranch.arrive(at: 1) && reachMossSlime(&addedBranch),
              "The southern branch should begin through the forest entrance")
        win(&addedBranch)
        check(addedBranch.arrive(at: 12) && addedBranch.collectTreasure() && addedBranch.arrive(at: 20) && addedBranch.collectTreasure() && addedBranch.arrive(at: 19),
              "The new southern branch should merge beyond the entrance")
        check(addedBranch.arrive(at: 12) && addedBranch.arrive(at: 23),
              "The added eastern stops should reconnect to a passable path")

        var valleyBranch = AdventureProgress()
        check(valleyBranch.arrive(at: 1) && reachMossSlime(&valleyBranch),
              "The lower extension should begin through the forest entrance")
        win(&valleyBranch)
        check(valleyBranch.arrive(at: 12) && valleyBranch.collectTreasure() && valleyBranch.arrive(at: 20) && valleyBranch.collectTreasure() && valleyBranch.arrive(at: 19) && valleyBranch.arrive(at: 34),
              "The lower artwork extension should merge beyond the entrance")
        check(valleyBranch.arrive(at: 35) && valleyBranch.collectTreasure(),
              "The lower artwork extension should retain its treasure")
        check(valleyBranch.potions == 1,
              "Later extension chests should grant coins without adding more recovery potions")
        check(valleyBranch.arrive(at: 36), "The valley guardian should follow the lower treasure")
        win(&valleyBranch)
        check(valleyBranch.arrive(at: 37) && valleyBranch.arrive(at: 38),
              "The lower extension should end at a passable path")

        let suite = "story-adventure-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let alice = AdventureSaveRepository(defaults: defaults, accountID: "alice")
        let bob = AdventureSaveRepository(defaults: defaults, accountID: "bob")
        try alice.save(resumed)
        let aliceReloaded = try alice.load(), bobReloaded = try bob.load()
        check(aliceReloaded == resumed, "All progress and reward receipts must persist")
        check(bobReloaded.currentNodeID == 0 && bobReloaded.earnedCoins == 0, "Accounts must have isolated saves")

        var preTrailSave = try JSONSerialization.jsonObject(with: JSONEncoder().encode(AdventureProgress())) as! [String: Any]
        preTrailSave["currentNodeID"] = 3
        preTrailSave["returnNodeID"] = 1
        preTrailSave["clearedNodeIDs"] = [0, 1, 3]
        preTrailSave["deliveredRewardIDs"] = [3]
        defaults.set(try JSONSerialization.data(withJSONObject: preTrailSave), forKey: bob.key)
        let restoredTrailSave = try bob.load()
        check(restoredTrailSave.isValid && restoredTrailSave.currentNodeID == 3
              && restoredTrailSave.clearedNodeIDs == [0, 1, 3]
              && restoredTrailSave.deliveredRewardIDs == [3]
              && restoredTrailSave.earnedCoins == 40,
              "Consolidating trails must preserve existing saves and rewards without auto-clearing encounters")
        check(restoredTrailSave.route(to: 22) == [3, 22],
              "An old save must still be able to explore the newly sequential trail")

        // A save made at the removed stream-path detour must open at the
        // connected chest instead of showing the unreadable-save screen.
        var removedPathSave = try JSONSerialization.jsonObject(with: JSONEncoder().encode(AdventureProgress())) as! [String: Any]
        removedPathSave["currentNodeID"] = 11
        removedPathSave["returnNodeID"] = 2
        removedPathSave["clearedNodeIDs"] = [0, 1, 2, 11]
        defaults.set(try JSONSerialization.data(withJSONObject: removedPathSave), forKey: bob.key)
        let migratedRemovedPath = try bob.load()
        check(migratedRemovedPath.currentNodeID == 2 && migratedRemovedPath.returnNodeID == 2
              && !migratedRemovedPath.clearedNodeIDs.contains(11) && migratedRemovedPath.isValid,
              "Removed stream-path saves must migrate to the connected chest")

        // Installing the story update must preserve pre-dialogue saves, including
        // an interrupted battle and rewards that have not yet been delivered.
        var legacy = try JSONSerialization.jsonObject(with: battleData) as! [String: Any]
        legacy.removeValue(forKey: "story")
        let legacySave = try JSONSerialization.data(withJSONObject: legacy)
        let migrated = try JSONDecoder().decode(AdventureProgress.self, from: legacySave)
        check(migrated == progress && migrated.story == nil && migrated.isValid,
              "Old saves must keep the exact adventure and battle state")

        var retiredHatSave = try JSONSerialization.jsonObject(with: JSONEncoder().encode(resumed)) as! [String: Any]
        retiredHatSave["hasHat"] = true
        retiredHatSave["wearsHat"] = true
        let withoutHat = try JSONDecoder().decode(AdventureProgress.self,
                                                  from: JSONSerialization.data(withJSONObject: retiredHatSave))
        check(withoutHat == resumed && withoutHat.isValid,
              "Existing saves with the retired hat must retain their progress")

        var storyProgress = AdventureProgress()
        storyProgress.story = AdventureStoryProgress(bookmark: .init(scene: .departure, page: 3))
        try bob.save(storyProgress)
        let resumedStory = try bob.load()
        check(resumedStory.story?.bookmark == storyProgress.story?.bookmark,
              "A conversation must resume on its saved page")
        storyProgress.story?.completed.insert(.departure)
        storyProgress.story?.bookmark = nil
        try bob.save(storyProgress)
        let finishedStory = try bob.load()
        check(finishedStory.story?.completed == [.departure] && finishedStory.story?.bookmark == nil,
              "Finished or skipped conversations must not reopen automatically")
        check(finishedStory.currentNodeID == 0 && finishedStory.clearedNodeIDs == [0] && finishedStory.pendingRewardIDs.isEmpty,
              "Reading a story must not move the companion, clear stops, or grant rewards")
        check(AdventureStoryScene.departure.isUnlocked(in: storyProgress) && !AdventureStoryScene.port.isUnlocked(in: storyProgress),
              "The journal must keep future scenes locked")
        check(AdventureStoryScene.port.isUnlocked(in: resumed),
              "Existing chapter-complete saves must be able to read the ending")
        check(AdventureStoryScene.allCases.count == 10
              && AdventureStoryScene.arriving(at: 5) == .shrine
              && AdventureStoryScene.arriving(at: 8) == .bridge
              && AdventureStoryScene.arriving(at: 9) == .guardian,
              "The expanded chapter must keep its ten scenes in the intended map order")
        check(AdventureStoryScene.keyAcquired.isUnlocked(in: westernBranch)
              && AdventureStoryScene.bridge.isUnlocked(in: resumed)
              && AdventureStoryScene.guardianVictory.isUnlocked(in: resumed),
              "Key, bridge, and guardian epilogue scenes must unlock from durable progress")
        check(AdventureStoryScene.departure.lines.count >= 15
              && AdventureStoryScene.guardian.lines.count >= 15
              && AdventureStoryScene.guardianVictory.lines.count >= 15,
              "The main story beats must retain the full chapter-one dialogue")
        check(AdventureStoryScene(rawValue: "departure") == .departure
              && AdventureStoryScene(rawValue: "guardian") == .guardian
              && AdventureStoryScene(rawValue: "port") == .port,
              "Previously saved scene identifiers must remain decodable")
        var retreatedStory = AdventureProgress()
        check(retreatedStory.arrive(at: 1) && reachMossSlime(&retreatedStory), "Reach the first story encounter")
        retreatedStory.story = AdventureStoryProgress(completed: [.departure, .firstEncounter])
        retreatedStory.retreat()
        check(!retreatedStory.clearedNodeIDs.contains(3) && AdventureStoryScene.firstEncounter.isUnlocked(in: retreatedStory),
              "A read conversation must remain replayable after retreating from its encounter")
        var invalidStory = storyProgress
        invalidStory.story?.bookmark = .init(scene: .departure, page: -1)
        check(!invalidStory.isValid, "A negative story page must be rejected before rendering")
        invalidStory.story?.bookmark = .init(scene: .departure, page: AdventureStoryScene.departure.lines.count)
        check(!invalidStory.isValid, "A story page past the end must be rejected before rendering")
        invalidStory.story?.bookmark = .init(scene: .port)
        check(!invalidStory.isValid, "A locked scene cannot be resumed from a bad bookmark")
        let aliceAfterStory = try alice.load()
        check(aliceAfterStory == resumed, "Another account's dialogue history must remain isolated")

        // Level and companion growth must affect combat, recovery and saved state together.
        let starter = AdventurePlayerStats(level: 1, companionName: "ネッキー", companionHP: 20, companionAttack: 20)
        let levelTen = AdventurePlayerStats(level: 10, companionName: "ネッキー", companionHP: 20, companionAttack: 20)
        let dragon = AdventurePlayerStats(level: 10, companionName: "レインボードラゴン", companionHP: 300, companionAttack: 50)
        var grown = AdventureProgress()
        check(grown.updatePlayerStats(starter) && grown.hp == 120 && grown.playerAttack == 40,
              "New adventurers should receive their selected companion bonuses at full HP")
        check(grown.updatePlayerStats(levelTen) && grown.hp == 210 && grown.playerAttack == 58,
              "Level growth should increase maximum HP and attack")
        check(grown.arrive(at: 1) && grown.arrive(at: 2) && grown.collectTreasure(), "Growth fixture should own a potion")
        check(grown.arrive(at: 21) && grown.arrive(at: 22) && grown.startBattle(questions: [question]),
              "Growth fixture should start at the vine slime")
        check(grown.battle?.maximumEnemyHP == 180 && grown.battle?.attack == 35, "New encounters should snapshot the stronger enemy")
        check(grown.answer(1) == false && grown.hp == 175, "Enemy damage must use the encounter's attack")
        check(!grown.updatePlayerStats(dragon) && grown.maximumHP == 210 && grown.playerAttack == 58,
              "Companion changes cannot alter a battle already in progress")
        var grownResume = try JSONDecoder().decode(AdventureProgress.self, from: JSONEncoder().encode(grown))
        check(grownResume.isValid && grownResume == grown, "HP above 100 and frozen combat stats must remain saveable")
        check(grownResume.advanceBattle() == .question && grownResume.answer(0) == true && grownResume.battle?.enemyHP == 122,
              "Resuming a battle must keep the original player attack")
        grownResume.retreat()
        check(grownResume.updatePlayerStats(dragon) && grownResume.hp == 455 && grownResume.playerAttack == 88,
              "Companion changes outside combat should preserve 35 missing HP")
        check(grownResume.potionHealing == 245 && grownResume.usePotion() && grownResume.hp == 490,
              "Potions should heal half of maximum HP without exceeding it")
        check(!grownResume.usePotion(), "Full health must never consume another potion")
        check(grownResume.arrive(at: 22) && grownResume.startBattle(questions: [question]), "A retreated encounter must remain playable")
        while grownResume.hp > 0 {
            check(grownResume.answer(1) == false, "Repeated misses should eventually defeat a high-HP player")
            if grownResume.hp > 0 { _ = grownResume.advanceBattle() }
        }
        check(grownResume.advanceBattle() == .defeat && grownResume.updatePlayerStats(starter) && grownResume.hp == 0,
              "Changing companions after defeat must not resurrect the player")
        check(grownResume.arrive(at: 0) && grownResume.rest() && grownResume.hp == 120,
              "Explicit village rest should restore the current maximum HP")

        // A pre-update battle has no stat snapshots. Resume it with its old HP and damage.
        var legacyJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(grown)) as! [String: Any]
        legacyJSON.removeValue(forKey: "playerStats")
        legacyJSON["hp"] = 100
        var legacyBattle = legacyJSON["battle"] as! [String: Any]
        for key in ["enemyMaximumHP", "enemyAttack", "playerAttackForReaction", "selectedAnswer"] { legacyBattle.removeValue(forKey: key) }
        legacyBattle["enemyHP"] = 60
        legacyJSON["battle"] = legacyBattle
        var legacyCombat = try JSONDecoder().decode(AdventureProgress.self, from: JSONSerialization.data(withJSONObject: legacyJSON))
        check(legacyCombat.isValid && legacyCombat.maximumHP == 100 && legacyCombat.playerAttack == 30 && legacyCombat.battle?.maximumEnemyHP == 60,
              "Old saves must decode without resetting progress or strengthening an interrupted enemy")
        check(!legacyCombat.updatePlayerStats(dragon) && legacyCombat.answer(1) == false && legacyCombat.hp == 80,
              "An old interrupted battle must retain its original damage rules")
        check(legacyCombat.advanceBattle() == .question && legacyCombat.answer(0) == true && legacyCombat.battle?.enemyHP == 30,
              "Old battles must still use the original player attack")
        legacyCombat.retreat()
        check(legacyCombat.updatePlayerStats(dragon) && legacyCombat.hp == 470, "New stats should apply after the legacyCombat battle ends")

        let guardian = AdventureBattle(nodeID: 9, questions: [question], enemyHP: 360, selectedAnswer: 0,
                                       enemyMaximumHP: 600, enemyAttack: 70, playerAttackForReaction: 240)
        check(guardian.guardianReaction == 2, "Boss dialogue must trigger when variable damage crosses its HP threshold")
        var finalGuardian = guardian
        finalGuardian.enemyHP = 0
        check(finalGuardian.guardianReaction == 0, "A one-hit boss victory must still trigger the final dialogue")
        check(AdventureWorld.node(3)?.enemyHP == 180 && AdventureWorld.node(3)?.enemyAttack == 35
              && AdventureWorld.node(32)?.enemyHP == 450 && AdventureWorld.node(32)?.enemyAttack == 55,
              "Changing the boss must not change regular monster balance")
        check(AdventureWorld.nodes.filter(\.isBattle).allSatisfy { $0.enemyHP >= 180 && $0.enemyAttack >= 35 },
              "Every monster should receive stronger HP and attack")

        let corrupt = Data("not a save".utf8)
        defaults.set(corrupt, forKey: alice.key)
        do { _ = try alice.load(); preconditionFailure("Corrupt save must not silently reset") }
        catch { check(defaults.data(forKey: alice.key) == corrupt, "Corrupt save must remain intact") }
        var invalid = try JSONSerialization.jsonObject(with: JSONEncoder().encode(resumed)) as! [String: Any]
        invalid["currentNodeID"] = 999
        let invalidData = try JSONSerialization.data(withJSONObject: invalid)
        defaults.set(invalidData, forKey: alice.key)
        do { _ = try alice.load(); preconditionFailure("Invalid nodes must fail validation") }
        catch { check(defaults.data(forKey: alice.key) == invalidData, "Invalid save must remain intact") }
        print("Adventure progression: \(checks) checks passed")
    }
}
