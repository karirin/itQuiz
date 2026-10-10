"""Run extracted production lifecycle/completion/settlement callbacks with local stand-ins."""
from pathlib import Path
import subprocess, tempfile
ROOT = Path(__file__).resolve().parents[1]

def block(text, marker):
    opening = text.index('{', text.index(marker)); depth = 1; end = opening + 1
    while depth:
        depth += (text[end] == '{') - (text[end] == '}'); end += 1
    return text[opening+1:end-1]

monster = (ROOT/'Quiz/StoryQuizView.swift').read_text()
rival = (ROOT/'Quiz/StoryUserQuizView.swift').read_text()
result = (ROOT/'Quiz/StoryQuizResultView.swift').read_text()
# Settlement must be associated with the user's exit, never a view disappearance.
assert '.onDisappear {' not in result
assert 'settleBattleIfNeeded()' in block(result, 'private func finishResultExit()')
for s in [monster,rival]:
    assert '.disabled(!isBattleReady || showCompletionMessage)' in s
    assert 'guard isBattleReady, !showCompletionMessage, !hasAnswered' in s
    assert 'didClear: victoryFlag' in s
    assert 'navigateToQuizResultView = true' not in block(s,'func moveToNextQuiz()')

support = r'''
import Foundation
@propertyWrapper final class Box<T> { var wrappedValue: T; init(wrappedValue: T) { self.wrappedValue = wrappedValue } }
struct Deadline { static func now() -> Deadline { Deadline() }; static func +(lhs: Deadline, rhs: Double) -> Deadline { lhs } }
struct DispatchQueue {
 enum QoS { case background }; static let main = DispatchQueue()
 static func global(qos: QoS) -> DispatchQueue { DispatchQueue() }
 func async(execute: () -> Void) { execute() }
 func asyncAfter(deadline: Deadline, execute: () -> Void) { execute() }
}
final class Timer {
 static var created = 0
 static func scheduledTimer(withTimeInterval: Double, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer { created += 1; return Timer() }
 func invalidate() {}
}
struct Question { var recommendedTimeLimit: Int { 30 } }
enum QuizLevel { case itBasic, incorrectITAnswer, incorrectInfoAnswer, incorrectAppliedAnswer, incorrectAnswer }
struct User { let id = "rival"; let avatars: [[String:Any]] = [["health":20,"attack":20]] }
struct Helper { let attackBonus = 10 }
final class FriendManager {
 static let shared = FriendManager(); var consumed = 0
 func consumeActiveHelperIfNeeded() -> Helper? { consumed += 1; return Helper() }
}
final class Interstitial { func preloadIfNeeded() {} }
struct AppState { let shouldShowAds = false }
final class InterstitialOpportunityCoordinator {
 static let shared = InterstitialOpportunityCoordinator()
 func logLearningSetStart(surface: String, quizLevel: QuizLevel) {}
}
enum DungeonRewardPlanner { static func battleRewards(for: String) -> [Int] { [42] } }
final class AuthManager {
 static let shared = AuthManager(); let currentUserId: String? = "player"
 var userFlag = 0; var rewardFlag = 1; var fetches = 0; var experience = 0; var money = 0; var items:[Int] = []
 var ranks: [String:Int] = [:]
 var pending: [(String?, [[String:Any]]?, Int?, Int?, Int?, Int?) -> Void] = []
 func fetchUserInfo(completion: @escaping (String?, [[String:Any]]?, Int?, Int?, Int?, Int?) -> Void) { fetches += 1; pending.append(completion) }
 func resolve() { let callbacks = pending; pending.removeAll(); for c in callbacks { c("Player", [["attack":20,"health":20]], 100, 120, 24, 0) } }
 func fetchUserRewardFlag() {}; func fetchUserFlag() {}
 func updateTutorialNum(userId: String, tutorialNum: Int, completion: (Bool) -> Void) {}
 func addRankMatchPoints(for id: String, points: Int, onSuccess: () -> Void, onFailure: (Error) -> Void) { ranks[id,default:0] += points }
 func subtractRankMatchPoints(for id: String, points: Int, onSuccess: () -> Void, onFailure: (Error) -> Void) { ranks[id,default:0] -= points }
 func addExperience(points: Int, onSuccess: () -> Void, onFailure: (Error) -> Void) { experience += points }
 func addMoney(amount: Int) { money += amount }; func addItems(_ rewards:[Int]) { items += rewards }
}
final class Progress {
 var position = 2; var stamina = 100; var shields = 0
 func incrementPosition() { position += 1; stamina -= 10 }
 func incrementUserPosition() { position += 1 }
 func decreaseStamina(by amount: Int) { stamina -= amount }
 func consumeDefeatShield() -> Bool { guard shields > 0 else { return false }; shields -= 1; return true }
}
final class Audio { var cancellations = 0; func playCancelSound() { cancellations += 1 } }
'''
properties = r'''
 @Box var quizzes = Array(repeating: Question(), count: 50)
 @Box var quizLevel = QuizLevel.itBasic
 @Box var hasInitializedBattle = false
 @Box var hasLoggedLearningSetStart = false
 @Box var hasHandledCompletion = false
 @Box var isBattleReady = false
 @Box var isBattleVisible = false
 @Box var isPresenting = true
 @Box var showCompletionMessage = false
 @Box var hasAnswered = false
 @Box var showExplanationModal = false
 @Box var showHomeModal = false
 @Box var showSubFlag = false
 @Box var showModal = false
 @Box var tutorialNum = 0
 @Box var monsterType = 0
 @Box var monsterName = "モンスター2"
 @Box var playerExperience = 0
 @Box var playerMoney = 0
 @Box var monsterHP = 100
 @Box var monsterUnderHP = 100
 @Box var monsterAttack = 10
 @Box var playerHP = 100
 @Box var userHp = 100
 @Box var userMaxHp = 100
 @Box var userAttack = 30
 @Box var userName = ""
 @Box var userMoney = 0
 @Box var avator: [[String:Any]] = []
 @Box var activeHelper: Helper?
 @Box var incorrectAnswerCount = 0
 @Box var incorrectCount = 0
 @Box var userFlag = 0
 @Box var currentQuizIndex = 0
 @Box var remainingSeconds = 30
 @Box var selectedAnswerIndex: Int?
 @Box var startTime = Date()
 @Box var itemRewards: [Int] = []
 @Box var navigateToQuizResultView = false
 @Box var victoryFlag = false
 @Box var timer: Timer?
 @Box var countdownTimer: Timer?
 @Box var savedStats = 0
 @Box var starts = 0
 var resumes: Int { Timer.created }
 @Box var countdowns = 0
 let authManager = AuthManager()
 let interstitial = Interstitial()
 let appState = AppState()
 let user = User()
 let backgroundName = "background"
 func startCountdown() { countdowns += 1 }
 func applyTimeoutComboPenalty() {}
 func applyMonsterDamage() { playerHP -= monsterAttack }
 var currentQuiz: Question { quizzes.first ?? Question() }
 func persistQuizStatsIfPossible() { savedStats += 1 }
 func fetchNumberOfIncorrectAnswers(userId:String, completion:(Int)->Void) { completion(0) }
 func fetchNumberOfIncorrectITAnswers(userId:String, completion:(Int)->Void) { completion(0) }
 func fetchNumberOfIncorrectInfoAnswers(userId:String, completion:(Int)->Void) { completion(0) }
 func fetchNumberOfIncorrectAppliedAnswers(userId:String, completion:(Int)->Void) { completion(0) }
'''
support += 'enum DungeonExpansion { static let monstersByName: [String: Monster] = [:] }\n'
source = support + monster[monster.index('struct Monster:'):monster.index('struct StoryQuizView:')]
for name,text in [('MonsterProbe',monster),('RivalProbe',rival)]:
    source += 'struct '+name+' {\n'+properties
    source += 'func appear() {\n'+block(text,'.onAppear {\n            isBattleVisible = true')+'\n}\n'
    source += 'func moveToNextQuiz() {\n'+block(text,'func moveToNextQuiz()')+'\n}\n'
    for timer_func in ['startTimer', 'resumeTimer']:
        source += 'func '+timer_func+'() {\n'+block(text,'func '+timer_func+'()')+'\n}\n'
    source += 'func complete(_ newValue: Bool) {\n'+block(text,'.onChange(of: showCompletionMessage)').replace(' newValue in', '', 1)+'\n}\n}\n'
source += '''
struct ResultProbe {
 @Box var hasSettledBattle = false
 @Box var isHandlingResultExit = false
 @Box var shouldRequestReviewAfterCelebration = false
 @Box var victoryFlag = true
 @Box var isUserStoryFlag = false
 @Box var isPresenting = true
 let viewModel = Progress()
 let audioManager = Audio()
'''
for f in ['settleBattleIfNeeded','finishResultExit']:
    source += 'func '+f+'() {\n'+block(result,'private func '+f+'()')+'\n}\n'
source += 'func handleResultExit(action: String) {\n'+block(result,'private func handleResultExit(action _: String)')+'\n}\n}\n'
source += '''
var checks = 0
func check(_ value: Bool, _ description: String) { checks += 1; precondition(value, description) }
'''
for kind in ['MonsterProbe','RivalProbe']:
    source += f'''
let init{kind} = {kind}()
let helpersBefore{kind} = FriendManager.shared.consumed
init{kind}.appear(); init{kind}.appear()
check(init{kind}.authManager.fetches == 1, "one fetch while initialization is pending")
check(!init{kind}.isBattleReady, "wait for battle stats")
init{kind}.authManager.resolve()
check(init{kind}.isBattleReady, "ready after stats")
init{kind}.monsterHP -= 40; init{kind}.playerHP -= 30
let enemy{kind} = init{kind}.monsterHP; let player{kind} = init{kind}.playerHP
init{kind}.remainingSeconds = 7; init{kind}.appear()
check(init{kind}.monsterHP == enemy{kind} && init{kind}.playerHP == player{kind}, "reappearance retains both HP values")
check(init{kind}.remainingSeconds == 7, "reappearance does not reset time limit")
check(init{kind}.authManager.fetches == 1 && FriendManager.shared.consumed == helpersBefore{kind} + 1, "no extra helper consumption on reappearance")
init{kind}.showCompletionMessage = true; let resumes{kind} = init{kind}.resumes; init{kind}.appear()
check(init{kind}.resumes == resumes{kind}, "completed battle does not resume")
let hidden{kind} = {kind}(); hidden{kind}.appear(); hidden{kind}.isBattleVisible = false
let hiddenTimers{kind} = Timer.created; hidden{kind}.authManager.resolve(); hidden{kind}.startTimer(); hidden{kind}.resumeTimer()
check(Timer.created == hiddenTimers{kind}, "late stat loading cannot restart a hidden battle timer")
hidden{kind}.appear()
check(Timer.created == hiddenTimers{kind} + 1 && hidden{kind}.authManager.fetches == 1, "visible battle resumes once with the loaded stats")
for timedOut in [false,true] {{
 let p = {kind}(); p.quizzes = [Question()]; p.monsterHP = 1000; p.playerHP = 100; p.playerExperience = 500; p.playerMoney = 500; p.itemRewards = {'[42]' if kind == 'MonsterProbe' else '[]'}; p.remainingSeconds = timedOut ? 0 : 20
 p.moveToNextQuiz(); p.complete(true)
 check(p.showCompletionMessage && !p.victoryFlag && p.navigateToQuizResultView, "question exhaustion is not a victory")
 check(p.playerExperience == 5 && p.playerMoney == 5 && p.itemRewards.isEmpty, "no victory rewards on exhaustion")
 let exp = p.authManager.experience; let rank = p.authManager.ranks; p.complete(true); p.complete(false); p.moveToNextQuiz()
 check(p.savedStats == 1 && p.authManager.experience == exp && p.authManager.ranks == rank, "completion callbacks do not duplicate stats or rewards")
 check(p.authManager.ranks["player",default:0] <= 0, "exhaustion does not add player rank points")
}}
let won{kind} = {kind}(); won{kind}.monsterHP = 0; won{kind}.playerHP = 100; won{kind}.playerExperience = 20; won{kind}.playerMoney = 20
won{kind}.moveToNextQuiz(); won{kind}.complete(true)
check(won{kind}.victoryFlag && won{kind}.navigateToQuizResultView, "enemy defeat remains a victory")
if "{kind}" == "MonsterProbe" {{
 check(won{kind}.authManager.experience == 20 && won{kind}.authManager.money == 20 && won{kind}.authManager.items == [42], "normal victory grants its original rewards")
 won{kind}.complete(true)
 check(won{kind}.authManager.experience == 20 && won{kind}.authManager.items == [42], "victory rewards are granted once")
}}
let simultaneous{kind} = {kind}(); simultaneous{kind}.monsterHP = 0; simultaneous{kind}.playerHP = 0; simultaneous{kind}.moveToNextQuiz(); simultaneous{kind}.complete(true)
check(!simultaneous{kind}.victoryFlag, "both HP values at zero are not a victory")
let lost{kind} = {kind}(); lost{kind}.playerHP = 0; lost{kind}.moveToNextQuiz(); lost{kind}.complete(true)
check(!lost{kind}.victoryFlag, "player defeat remains a loss")
let invalid{kind} = {kind}(); invalid{kind}.quizzes = []; invalid{kind}.moveToNextQuiz(); invalid{kind}.complete(true)
check(!invalid{kind}.victoryFlag, "missing questions do not produce a victory")
'''
source += '''
for victory in [false,true] {
 for rival in [false,true] {
  let p = ResultProbe(); p.victoryFlag = victory; p.isUserStoryFlag = rival
  check(p.viewModel.position == 2 && p.viewModel.stamina == 100, "no settlement before exit")
  p.handleResultExit(action:"back_button"); p.handleResultExit(action:"swipe_back"); p.finishResultExit(); p.settleBattleIfNeeded()
  check(p.viewModel.position == (victory ? 3 : 2), "one progress increment per exit")
  check(p.viewModel.stamina == (victory && rival ? 100 : 90), "stamina charged once with rival victory remaining free")
  check(!p.isPresenting, "exit closes the battle")
 }
}
let shield = ResultProbe(); shield.victoryFlag = false; shield.viewModel.shields = 2
shield.finishResultExit(); shield.finishResultExit()
check(shield.viewModel.shields == 1 && shield.viewModel.stamina == 100, "one defeat shield consumed per battle")
print("Dungeon battle regression: \\(checks) checks passed")
'''
with tempfile.TemporaryDirectory(prefix='itquiz-dungeon-tests-') as tmp:
    p=Path(tmp); (p/'Tests.swift').write_text(source)
    subprocess.run(['xcrun','swiftc','-swift-version','5',str(p/'Tests.swift'),'-o',str(p/'tests')],check=True)
    r = subprocess.run([str(p/'tests')],capture_output=True,text=True)
    if r.returncode:
        print(r.stdout)
        print(r.stderr[:2500])
        r.check_returncode()
    print(r.stdout.splitlines()[-1])
