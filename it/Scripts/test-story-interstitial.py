#!/usr/bin/env python3
"""Exercise the production story ad transition with a controllable SDK stand-in.

Like test-dungeon-lifecycle.py, this compiles the actual production methods so
callbacks, no-fill and subscription races can be tested without live ads.
"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "App/Interstitial.swift").read_text()


def declaration(marker, source=SOURCE):
    start = source.index(marker)
    opening = source.index("{", start)
    depth, end = 1, opening + 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start:end] + "\n"


probe = """
import Foundation

final class UIViewController {}
final class UIApplication {
    enum State { case active, inactive }
    static let shared = UIApplication()
    var applicationState = State.active
}
@MainActor final class AppState {
    static let shared = AppState()
    var hasResolvedSubscriptionState = true
    var isSubscribed = false
}
final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()
    var isConnected = true
}
final class AdvertisingPrivacyCoordinator {
    static let shared = AdvertisingPrivacyCoordinator()
    var isReady = true
}
"""
probe += declaration("struct InterstitialOpportunityDecision")
probe += """
final class InterstitialOpportunityCoordinator {
    static let shared = InterstitialOpportunityCoordinator()
    let defaults = UserDefaults(suiteName: "story-interstitial-test")!
    let postPurchaseGraceInterval: TimeInterval = 600
    var completedSets = 0
    var outcomes: [(String, String, Bool)] = []
    @discardableResult func recordLearningSetCompleted() -> Int {
        completedSets += 1
        return completedSets
    }
    func recordOpportunity(_ decision: InterstitialOpportunityDecision,
                           surface: String, action: String, didShow: Bool) {
        outcomes.append((surface, decision.reason, didShow))
        assert(action == "battle_completed")
    }
"""
probe += declaration("private enum Key")
probe += declaration("func decision(")
probe += declaration("func shouldPreload(")
probe += """
}
@MainActor final class Interstitial {
    var isReady = true
    var loads = 0
    var presentations = 0
    var presentationAccepted = true
    var failsSynchronously = false
    var callback: ((Bool) -> Void)?
    func preloadIfNeeded() { loads += 1 }
    func presentInterstitial(from: UIViewController, onFinish: ((Bool) -> Void)?) -> Bool {
        presentations += 1
        callback = onFinish
        if failsSynchronously { onFinish?(false) }
        return presentationAccepted
    }
"""
probe += declaration("func preloadStoryBattleAd(")
probe += declaration("func presentAfterStoryBattle(")
probe += """
}
final class Battle {
    var selectedAnswer: Int? = 0
    var enemyHP = 0
}
final class Progress {
    var battle: Battle? = Battle()
    var hp = 100
}
final class Store {
    var progress = Progress()
    var isPreview = false
    var advances = 0
    func nextQuestion() {
        advances += 1
        if progress.hp == 0 || progress.battle?.enemyHP == 0 {
            progress.battle = nil
        } else {
            progress.battle?.selectedAnswer = nil
        }
    }
    func advanceBattle() { nextQuestion() }
}
final class Presenter { let viewController = UIViewController() }
"""
for name, filename in [("ChapterOneViewProbe", "AdventureEventSheet.swift"),
                       ("ChapterTwoViewProbe", "ChapterTwoAdventureView.swift")]:
    source = (ROOT / "Story" / filename).read_text()
    probe += f"""
@MainActor final class {name} {{
    let store = Store()
    let interstitial = Interstitial()
    let adPresenter = Presenter()
    var isFinishingBattle = false
    var isExplanationPresented = true
    var explanationSelection: Int? = 0
    var isAttackEffectVisible = true
    var showsIncorrectTint = true
    var showsDefeatMark = true
    var isResolvingAnswer = false
"""
    probe += declaration("private func advanceBattleAfterExplanation()", source).replace("private func", "func", 1)
    probe += "}\n"
probe += """
@main struct StoryInterstitialTests {
    @MainActor static func reset() {
        AppState.shared.hasResolvedSubscriptionState = true
        AppState.shared.isSubscribed = false
        ConnectivityMonitor.shared.isConnected = true
        AdvertisingPrivacyCoordinator.shared.isReady = true
        UIApplication.shared.applicationState = .active
        let coordinator = InterstitialOpportunityCoordinator.shared
        coordinator.defaults.removePersistentDomain(forName: "story-interstitial-test")
        coordinator.completedSets = 0
        coordinator.outcomes = []
    }

    @MainActor static func flushMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    @MainActor static func main() async {
        let presenter = UIViewController()
        let coordinator = InterstitialOpportunityCoordinator.shared
        let exclusions: [(String, () -> Void)] = [
            ("subscribed", { AppState.shared.isSubscribed = true }),
            ("subscription_state_unresolved", { AppState.shared.hasResolvedSubscriptionState = false }),
            ("offline", { ConnectivityMonitor.shared.isConnected = false }),
            ("recent_purchase", {
                coordinator.defaults.set(Date(), forKey: "interstitial.premiumPurchasedAt")
            }),
            ("privacy_not_ready", { AdvertisingPrivacyCoordinator.shared.isReady = false }),
            ("app_inactive", { UIApplication.shared.applicationState = .inactive })
        ]
        for (reason, configure) in exclusions {
            reset()
            configure()
            let ad = Interstitial()
            var advances = 0
            ad.presentAfterStoryBattle(isPreview: false, surface: "story_adventure_chapter01", from: presenter) {
                advances += 1
            }
            assert(ad.presentations == 0 && advances == 1, reason)
            assert(coordinator.outcomes.count == 1 && coordinator.outcomes[0].1 == reason)
            assert(coordinator.completedSets == 1)
        }

        reset()
        let preview = Interstitial()
        var previewAdvances = 0
        preview.preloadStoryBattleAd(isPreview: true)
        preview.presentAfterStoryBattle(isPreview: true, surface: "preview", from: presenter) {
            previewAdvances += 1
        }
        assert(preview.loads == 0 && preview.presentations == 0 && previewAdvances == 1)
        assert(coordinator.completedSets == 0 && coordinator.outcomes.isEmpty)

        for (_, configure) in exclusions.prefix(4) {
            reset()
            configure()
            let ad = Interstitial()
            ad.preloadStoryBattleAd(isPreview: false)
            assert(ad.loads == 0)
        }
        reset()
        let preloaded = Interstitial()
        preloaded.preloadStoryBattleAd(isPreview: false)
        assert(preloaded.loads == 1)

        reset()
        let unavailable = Interstitial()
        unavailable.isReady = false
        var skippedAdvances = 0
        unavailable.presentAfterStoryBattle(isPreview: false, surface: "story_adventure_chapter01", from: presenter) {
            skippedAdvances += 1
        }
        assert(skippedAdvances == 1 && unavailable.presentations == 0 && unavailable.loads == 0)
        unavailable.isReady = true
        assert(unavailable.callback == nil, "An ad loading late cannot interrupt the result")
        assert(coordinator.outcomes[0].1 == "ad_not_ready")

        for synchronousFailure in [false, true] {
            reset()
            let rejected = Interstitial()
            rejected.presentationAccepted = false
            rejected.failsSynchronously = synchronousFailure
            var failureAdvances = 0
            rejected.presentAfterStoryBattle(isPreview: false, surface: "story_adventure_chapter02", from: presenter) {
                failureAdvances += 1
            }
            rejected.callback?(false)
            assert(failureAdvances == 1 && coordinator.outcomes.count == 1)
            assert(!coordinator.outcomes[0].2)
        }

        for didShow in [false, true] {
            reset()
            let ready = Interstitial()
            var advances = 0
            ready.presentAfterStoryBattle(isPreview: false, surface: "story_adventure_chapter02", from: presenter) {
                advances += 1
            }
            assert(ready.presentations == 1 && advances == 0 && coordinator.outcomes.isEmpty)
            ready.callback?(didShow)
            ready.callback?(didShow)
            assert(advances == 1 && coordinator.outcomes.count == 1)
            assert(coordinator.outcomes[0].0 == "story_adventure_chapter02")
            assert(coordinator.outcomes[0].2 == didShow)
        }
        // Run both actual screen actions, including their asynchronous UI
        // continuation, to check per-question gating and rapid repeated taps.
        for defeat in [false, true] {
            reset()
            let chapterOne = ChapterOneViewProbe()
            let chapterTwo = ChapterTwoViewProbe()
            if defeat {
                chapterOne.store.progress.hp = 0
                chapterTwo.store.progress.hp = 0
                chapterOne.store.progress.battle?.enemyHP = 100
                chapterTwo.store.progress.battle?.enemyHP = 100
            }
            chapterOne.advanceBattleAfterExplanation()
            chapterOne.advanceBattleAfterExplanation()
            chapterTwo.advanceBattleAfterExplanation()
            chapterTwo.advanceBattleAfterExplanation()
            await flushMainQueue()
            assert(chapterOne.interstitial.presentations == 1 && chapterOne.store.advances == 0)
            assert(chapterTwo.interstitial.presentations == 1 && chapterTwo.store.advances == 0)
            chapterOne.interstitial.callback?(true)
            chapterOne.interstitial.callback?(true)
            chapterTwo.interstitial.callback?(true)
            chapterTwo.interstitial.callback?(true)
            await flushMainQueue()
            assert(chapterOne.store.advances == 1 && chapterOne.store.progress.battle == nil)
            assert(chapterTwo.store.advances == 1 && chapterTwo.store.progress.battle == nil)
            assert(!chapterTwo.isFinishingBattle)
        }
        reset()
        let questionOne = ChapterOneViewProbe()
        let questionTwo = ChapterTwoViewProbe()
        questionOne.store.progress.battle?.enemyHP = 100
        questionTwo.store.progress.battle?.enemyHP = 100
        questionOne.advanceBattleAfterExplanation()
        questionTwo.advanceBattleAfterExplanation()
        await flushMainQueue()
        assert(questionOne.interstitial.presentations == 0 && questionOne.store.advances == 1)
        assert(questionTwo.interstitial.presentations == 0 && questionTwo.store.advances == 1)
        for preview in [false, true] {
            reset()
            let skippedOne = ChapterOneViewProbe()
            let skippedTwo = ChapterTwoViewProbe()
            skippedOne.store.isPreview = preview
            skippedTwo.store.isPreview = preview
            skippedOne.interstitial.isReady = false
            skippedTwo.interstitial.isReady = false
            skippedOne.advanceBattleAfterExplanation()
            skippedTwo.advanceBattleAfterExplanation()
            await flushMainQueue()
            await flushMainQueue()
            assert(skippedOne.store.advances == 1 && skippedTwo.store.advances == 1)
            assert(skippedOne.interstitial.presentations == 0 && skippedTwo.interstitial.presentations == 0)
            assert(!skippedTwo.isFinishingBattle)
        }
        reset()
        print("Story interstitial: eligibility, preload, no-fill, failure, callbacks and both battle screens passed")
    }
}
"""

with tempfile.TemporaryDirectory(prefix="story-interstitial-tests-") as temporary:
    path = Path(temporary)
    (path / "Probe.swift").write_text(probe)
    subprocess.run(["xcrun", "swiftc", "-parse-as-library", str(path / "Probe.swift"),
                    "-o", str(path / "tests")], check=True)
    subprocess.run([str(path / "tests")], check=True)
