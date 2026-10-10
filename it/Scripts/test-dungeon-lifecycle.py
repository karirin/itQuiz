#!/usr/bin/env python3
"""Run the actual appearance guards and settlement callback with local stand-ins.

This tests state transitions without ads, Firebase writes, or SwiftUI rendering.
"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def block(source, marker):
    opening = source.index("{", source.index(marker))
    depth = 1
    end = opening + 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[opening + 1:end - 1]


stand_ins = """
import Foundation
enum QuizLevel { case itBasic }
final class InterstitialOpportunityCoordinator {
    static let shared = InterstitialOpportunityCoordinator()
    func logLearningSetStart(surface: String, quizLevel: QuizLevel) {}
}
final class AppState { var shouldShowAds = true }
final class Interstitial { func preloadIfNeeded() {} }
final class Progress {
    var position = 2
    var userPosition = 2
    var stamina = 100
    func incrementPosition() { position += 1; stamina -= 10 }
    func incrementUserPosition() { userPosition += 1 }
    func consumeDefeatShield() -> Bool { false }
    func decreaseStamina(by amount: Int) { stamina -= amount }
}
"""

tests = []
for name in ("StoryQuizView", "StoryUserQuizView"):
    source = (ROOT / f"Quiz/{name}.swift").read_text()
    appearance = block(source, ".onAppear {\n            isBattleVisible = true")
    # Run the production guard before the asynchronous user-info initialization.
    gate = appearance[:appearance.index("hasInitializedBattle = true")]
    gate += "hasInitializedBattle = true"
    stand_ins += f"""
final class {name}Probe {{
    var isBattleVisible = false
    var isBattleReady = false
    var isPresenting = true
    var showCompletionMessage = false
    var navigateToQuizResultView = false
    var hasLoggedLearningSetStart = false
    var hasInitializedBattle = false
    var hasAnswered = false
    var showExplanationModal = false
    var showHomeModal = false
    var showSubFlag = false
    var tutorialNum = 0
    var monsterHP = 0
    var playerHP = 0
    var remainingSeconds = 30
    var initializationCount = 0
    var timerResumeCount = 0
    let quizLevel = QuizLevel.itBasic
    let appState = AppState()
    let interstitial = Interstitial()
    func resumeTimer() {{ timerResumeCount += 1 }}
    func appear() {{
        {gate}
        initializationCount += 1
        monsterHP = 100
        playerHP = 140
        isBattleReady = true
    }}
}}
"""
    tests.append(f"""
do {{
    let battle = {name}Probe()
    battle.appear()
    assert(battle.initializationCount == 1 && battle.monsterHP == 100)
    battle.monsterHP = 56
    battle.playerHP = 120
    battle.remainingSeconds = 17
    battle.isBattleVisible = false
    battle.appear()
    assert(battle.monsterHP == 56 && battle.playerHP == 120)
    assert(battle.remainingSeconds == 17 && battle.timerResumeCount == 1)
    assert(battle.initializationCount == 1)
    battle.showExplanationModal = true
    battle.appear()
    assert(battle.timerResumeCount == 1)
    battle.showExplanationModal = false
    battle.monsterHP = 0
    battle.showCompletionMessage = true
    // A full-screen dismissal must restore the result if navigation was reset.
    battle.navigateToQuizResultView = false
    battle.appear()
    battle.appear()
    assert(battle.monsterHP == 0 && battle.playerHP == 120)
    assert(battle.navigateToQuizResultView && battle.showCompletionMessage)
    assert(battle.initializationCount == 1 && battle.timerResumeCount == 1)
    // Explicitly closing the whole battle must not reopen the result.
    battle.isPresenting = false
    battle.navigateToQuizResultView = false
    battle.appear()
    assert(!battle.navigateToQuizResultView && battle.monsterHP == 0)
    // Defeat also remains a completed battle after an ad dismissal.
    let defeat = {name}Probe()
    defeat.appear()
    defeat.playerHP = 0
    defeat.monsterHP = 56
    defeat.showCompletionMessage = true
    defeat.appear()
    assert(defeat.playerHP == 0 && defeat.monsterHP == 56)
    assert(defeat.navigateToQuizResultView && defeat.timerResumeCount == 0)
    print("PASS {name}: reappearance, completed ad return, explicit exit, defeat")
}}
""")

result = (ROOT / "Quiz/StoryQuizResultView.swift").read_text()
settlement = block(result, "private func settleBattleIfNeeded()")
stand_ins += f"""
final class ResultProbe {{
    var hasSettledBattle = false
    var victoryFlag = true
    var isUserStoryFlag = false
    let viewModel = Progress()
    func settleBattleIfNeeded() {{ {settlement} }}
}}
"""
tests.append("""
do {
    let victory = ResultProbe()
    victory.settleBattleIfNeeded()
    victory.settleBattleIfNeeded()
    assert(victory.viewModel.position == 3 && victory.viewModel.stamina == 90)
    let defeat = ResultProbe()
    defeat.victoryFlag = false
    defeat.settleBattleIfNeeded()
    defeat.settleBattleIfNeeded()
    assert(defeat.viewModel.position == 2 && defeat.viewModel.stamina == 90)
    let rival = ResultProbe()
    rival.isUserStoryFlag = true
    rival.settleBattleIfNeeded()
    rival.settleBattleIfNeeded()
    assert(rival.viewModel.userPosition == 3)
    print("PASS result: victory, defeat and rival settle once")
}
""")

with tempfile.TemporaryDirectory(prefix="dungeon-lifecycle-tests-") as directory:
    swift = Path(directory) / "LifecycleTests.swift"
    executable = Path(directory) / "lifecycle-tests"
    swift.write_text(stand_ins + "\n".join(tests))
    subprocess.run(["xcrun", "swiftc", "-swift-version", "5", str(swift),
                    "-o", str(executable)], check=True)
    subprocess.run([str(executable)], check=True)
