#!/usr/bin/env python3
"""Exercise production quiz lifecycle callbacks without Firebase or live ads."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "Quiz/QuizView.swift").read_text()


def block(marker):
    opening = SOURCE.index("{", SOURCE.index(marker))
    depth, end = 1, opening + 1
    while depth:
        depth += (SOURCE[end] == "{") - (SOURCE[end] == "}")
        end += 1
    return SOURCE[opening + 1:end - 1]


appearance = block(".onAppear {\n                isQuizVisible = true")
gate = appearance[:appearance.index("hasInitializedQuiz = true")]
gate += "hasInitializedQuiz = true"

probe = r'''
import Foundation
struct Deadline {
    static func now() -> Deadline { Deadline() }
    static func +(lhs: Deadline, rhs: Double) -> Deadline { lhs }
}
final class DispatchQueue {
    enum QoS { case background }
    static let main = DispatchQueue()
    static func global(qos: QoS) -> DispatchQueue { main }
    var pending: [() -> Void] = []
    func async(execute: () -> Void) { execute() }
    func asyncAfter(deadline: Deadline, execute: @escaping () -> Void) { pending.append(execute) }
    func flush() { let callbacks = pending; pending = []; callbacks.forEach { $0() } }
}
final class Timer {
    static var created = 0
    var valid = true
    var callback: ((Timer) -> Void)?
    static func scheduledTimer(withTimeInterval: Double, repeats: Bool,
                               block: @escaping (Timer) -> Void) -> Timer {
        created += 1
        let timer = Timer(); timer.callback = block; return timer
    }
    func invalidate() { valid = false }
}
struct Question { let question: String; var recommendedTimeLimit: Int { 30 } }
struct Result { let question: String }
enum QuizLevel { case itBasic }
final class AuthManager {
    var rewardFlag = 1
    var experience = 0
    var money = 0
    func addExperience(points: Int, onSuccess: () -> Void, onFailure: (Error) -> Void) { experience += points }
    func addMoney(amount: Int) { money += amount }
}
final class Connectivity { var isConnected = true }
final class InterstitialOpportunityCoordinator {
    static let shared = InterstitialOpportunityCoordinator()
    func logLearningSetStart(surface: String, quizLevel: QuizLevel, learningContext: Int?) {}
}
final class LearningTour { enum Step { case question, explanation }; func advance(from: Step) {} }
final class Probe {
    var hasInitializedQuiz = false
    var isQuizReady = false
    var isQuizVisible = false
    var isPresenting = true
    var showCompletionMessage = false
    var navigateToQuizResultView = false
    var hasHandledCompletion = false
    var hasAnswered = false
    var showExplanationModal = false
    var showHomeModal = false
    var showSubFlag = false
    var showModal = false
    var tutorialNum = 0
    var isUntimedLearningSession = false
    var isInitialDiagnostic = false
    var isLearningTour = false
    var isReviewQuiz = false
    var isDailyLearning = false
    var isInfiniteMode = false
    var userFlag = 0
    var monsterType = 0
    var monsterHP = 0
    var monsterAttack = 10
    var playerHP = 0
    var userMaxHp = 140
    var playerExperience = 20
    var playerMoney = 10
    var currentQuizIndex = 0
    var selectedAnswerIndex: Int?
    var reviewUnansweredReason: Int?
    var timer: Timer?
    var remainingSeconds = 30
    var quizResults: [Result] = []
    var quizzes = [Question(question: "one"), Question(question: "two")]
    var replacementQuizzes: [Question]?
    var activeQuizzes: [Question] { replacementQuizzes ?? quizzes }
    var currentQuiz: Question { activeQuizzes[min(currentQuizIndex, activeQuizzes.count - 1)] }
    var answerCount = 0
    var correctAnswerCount = 0
    var hasPersistedQuizStats = false
    var leagueSessionId = UUID().uuidString
    var showMonsterDownImage = false
    var showAttackImage = false
    var attackImpact: Int?
    var showIncorrectBackground = false
    var comboCount = 0
    var startTime = Date()
    var endTime: Date?
    var elapsedTime: TimeInterval?
    var sessionDuration: TimeInterval = 0
    var initializations = 0
    var persisted = 0
    let authManager = AuthManager()
    let connectivity = Connectivity()
    let learningTour = LearningTour()
    let quizLevel = QuizLevel.itBasic
    var learningContext: Int?
    func configureMonster(for type: Int) { monsterHP = type == 1 ? 80 : 120 }
    func persistQuizStatsIfPossible() { persisted += 1 }
    func pauseTimer() { timer?.invalidate() }
    func recordUnansweredReview(_ reason: Reason) {}
    enum Reason { case timedOut }
    func applyTimeoutComboPenalty() {}
    func recordReviewFailureIfNeeded() {}
    func recordDailyQuickQuizTimeout() {}
    func appear() {
'''
probe += gate
probe += r'''
        initializations += 1
        monsterType = 1; configureMonster(for: 1)
        playerHP = userMaxHp; startTime = Date()
    }
    func resolveUserInfo() { isQuizReady = true; startTimer() }
'''
for function in ["resumeTimer", "startTimer", "moveToNextQuiz", "startNewQuestionSet"]:
    probe += f"func {function}() {{\n{block('func ' + function + '()')}\n}}\n"
probe += "func complete(_ newValue: Bool) {\n"
probe += block(".onChange(of: showCompletionMessage)").replace(" newValue in", "", 1)
probe += "\n}\n}\n"
probe += r'''
// Enter twice while the asynchronous user fetch is still pending.
let p = Probe()
p.appear(); p.appear()
assert(p.initializations == 1 && Timer.created == 0)
p.resolveUserInfo()
p.monsterType = 2; p.monsterHP = 52; p.playerHP = 90
p.currentQuizIndex = 1; p.remainingSeconds = 7
let startedAt = p.startTime
p.isQuizVisible = false; p.timer?.invalidate(); p.appear()
assert(p.initializations == 1 && p.monsterType == 2 && p.monsterHP == 52)
assert(p.playerHP == 90 && p.currentQuizIndex == 1 && p.remainingSeconds == 7)
assert(p.startTime == startedAt && p.timer?.valid == true)
for kind in 0..<4 {
    if kind == 0 { p.hasAnswered = true }
    if kind == 1 { p.showExplanationModal = true }
    if kind == 2 { p.showHomeModal = true }
    if kind == 3 { p.showSubFlag = true }
    let before = Timer.created; p.appear()
    assert(Timer.created == before)
    p.hasAnswered = false; p.showExplanationModal = false
    p.showHomeModal = false; p.showSubFlag = false
}
// Win, show the ad, click out of the app, and reappear repeatedly.
p.monsterHP = 0; p.showCompletionMessage = true; p.complete(true)
let earnedExperience = p.authManager.experience
let earnedMoney = p.authManager.money
let timers = Timer.created
for _ in 0..<3 {
    p.isQuizVisible = false; p.navigateToQuizResultView = false; p.appear()
    p.startTimer(); p.resumeTimer(); p.moveToNextQuiz(); p.complete(true)
    assert(p.navigateToQuizResultView && p.showCompletionMessage)
    assert(p.monsterHP == 0 && p.monsterType == 2 && p.playerHP == 90)
    assert(p.remainingSeconds == 7 && Timer.created == timers)
}
assert(p.persisted == 1 && p.authManager.experience == earnedExperience)
assert(p.authManager.money == earnedMoney)
// Only the explicit result action starts another set.
p.isQuizVisible = false
p.startNewQuestionSet(); p.complete(false)
assert(!p.showCompletionMessage && !p.navigateToQuizResultView)
assert(!p.hasHandledCompletion && p.currentQuizIndex == 0)
assert(p.monsterType == 1 && p.monsterHP == 80 && p.playerHP == 140)
assert(p.remainingSeconds == 30)
p.appear()
assert(p.initializations == 1 && p.remainingSeconds == 30 && p.timer?.valid == true)
DispatchQueue.main.flush()
assert(!p.navigateToQuizResultView, "old delayed completion cannot reopen the result")
p.monsterHP = 0; p.showCompletionMessage = true; p.complete(true)
assert(p.persisted == 2 && p.authManager.experience == earnedExperience * 2)
DispatchQueue.main.flush()
assert(p.navigateToQuizResultView)
// A late stats fetch or countdown cannot start a hidden or completed timer.
let hidden = Probe(); hidden.appear(); hidden.isQuizVisible = false
let beforeHidden = Timer.created
hidden.resolveUserInfo(); hidden.resumeTimer()
assert(Timer.created == beforeHidden)
hidden.appear()
assert(Timer.created == beforeHidden + 1 && hidden.initializations == 1)
let completed = Probe(); completed.appear(); completed.showCompletionMessage = true
let beforeCompleted = Timer.created; completed.resolveUserInfo(); completed.resumeTimer()
assert(Timer.created == beforeCompleted)
completed.isPresenting = false; completed.navigateToQuizResultView = false
completed.appear(); completed.complete(true); DispatchQueue.main.flush()
assert(!completed.navigateToQuizResultView)
// Losing and short-set completion use the same terminal state.
for defeat in [false, true] {
    let terminal = Probe(); terminal.appear(); terminal.resolveUserInfo()
    terminal.showCompletionMessage = true
    if defeat { terminal.playerHP = 0 }
    terminal.complete(true); terminal.appear(); terminal.complete(true)
    assert(terminal.persisted == 1 && terminal.navigateToQuizResultView)
    if defeat { assert(terminal.authManager.experience == 5 && terminal.authManager.money == 5) }
}
print("Quiz ad return: lifecycle, terminal state, rewards, late callbacks and explicit retry passed")
'''

# SwiftUI's value-type view permits implicit self in escaping closures. The
# reference-type probe needs an explicit capture while retaining the same body.
probe = probe.replace("repeats: true) { timer in", "repeats: true) { [self] timer in")
probe = probe.replace(".now() + 2.0) {", ".now() + 2.0) { [self] in")

with tempfile.TemporaryDirectory(prefix="quiz-ad-return-") as temporary:
    path = Path(temporary)
    (path / "Probe.swift").write_text(probe)
    subprocess.run(["xcrun", "swiftc", str(path / "Probe.swift"),
                    "-o", str(path / "tests")], check=True)
    subprocess.run([str(path / "tests")], check=True)
