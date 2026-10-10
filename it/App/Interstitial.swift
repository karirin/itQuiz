//
//  Interstitial.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/28.
//

import SwiftUI
import GoogleMobileAds
import FirebaseAnalytics

struct InterstitialOpportunityDecision {
    let shouldShow: Bool
    let reason: String
    let completedLearningSets: Int
    let secondsSinceLastAd: Int
}

/// 通常クイズとストーリーで、全画面広告の頻度と計測を共通化する。
final class InterstitialOpportunityCoordinator {
    static let shared = InterstitialOpportunityCoordinator()

    private enum Key {
        static let appSessionCount = "interstitial.appSessionCount"
        static let completedLearningSets = "interstitial.completedLearningSets"
        static let lastShownAt = "interstitial.lastShownAt"
        static let premiumPurchasedAt = "interstitial.premiumPurchasedAt"
    }

    private let defaults: UserDefaults
    private let postPurchaseGraceInterval: TimeInterval = 10 * 60
    private let isFirstSession: Bool
    private var adsShownInCurrentSession = 0

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let previousSessionCount = defaults.integer(forKey: Key.appSessionCount)
        isFirstSession = previousSessionCount == 0
        defaults.set(previousSessionCount + 1, forKey: Key.appSessionCount)
    }

    @discardableResult
    func recordLearningSetCompleted() -> Int {
        let count = defaults.integer(forKey: Key.completedLearningSets) + 1
        defaults.set(count, forKey: Key.completedLearningSets)
        return count
    }

    func logLearningSetStart(surface: String, quizLevel: QuizLevel, learningContext: LearningEntryContext? = nil) {
        var parameters: [String: Any] = [
            "surface": surface,
            "quiz_level": quizLevel.description,
            "completed_learning_sets": defaults.integer(forKey: Key.completedLearningSets)
        ]
        parameters.merge(learningContext?.parameters ?? [:]) { _, new in new }
        Analytics.logEvent("learning_set_start", parameters: parameters)
    }

    func shouldPreload(
        subscriptionStateResolved: Bool,
        isSubscribed: Bool,
        isConnected: Bool,
        exclusionReason: String? = nil,
        now: Date = Date()
    ) -> Bool {
        decision(
            subscriptionStateResolved: subscriptionStateResolved,
            isSubscribed: isSubscribed,
            isConnected: isConnected,
            isAdReady: true,
            exclusionReason: exclusionReason,
            now: now
        ).shouldShow
    }

    func decision(
        subscriptionStateResolved: Bool,
        isSubscribed: Bool,
        isConnected: Bool,
        isAdReady: Bool,
        exclusionReason: String? = nil,
        now: Date = Date()
    ) -> InterstitialOpportunityDecision {
        let completedSets = defaults.integer(forKey: Key.completedLearningSets)
        let secondsSinceLastAd: Int
        if let lastShownAt = defaults.object(forKey: Key.lastShownAt) as? Date {
            secondsSinceLastAd = max(0, Int(now.timeIntervalSince(lastShownAt)))
        } else {
            secondsSinceLastAd = -1
        }

        let reason: String
        let shouldShow: Bool

        let wasPurchasedRecently: Bool
        if let purchasedAt = defaults.object(forKey: Key.premiumPurchasedAt) as? Date {
            wasPurchasedRecently = now.timeIntervalSince(purchasedAt) < postPurchaseGraceInterval
        } else {
            wasPurchasedRecently = false
        }

        if !subscriptionStateResolved {
            reason = "subscription_state_unresolved"
            shouldShow = false
        } else if isSubscribed {
            reason = "subscribed"
            shouldShow = false
        } else if wasPurchasedRecently {
            // StoreKitの権限反映と画面更新の短い競合でも、購入直後に広告を出さない。
            reason = "recent_purchase"
            shouldShow = false
        } else if let exclusionReason {
            reason = exclusionReason
            shouldShow = false
        } else if !isConnected {
            reason = "offline"
            shouldShow = false
        } else if !isAdReady {
            reason = "ad_not_ready"
            shouldShow = false
        } else {
            reason = "eligible"
            shouldShow = true
        }

        return InterstitialOpportunityDecision(
            shouldShow: shouldShow,
            reason: reason,
            completedLearningSets: completedSets,
            secondsSinceLastAd: secondsSinceLastAd
        )
    }

    /// StoreKitの権限が画面へ伝わるまでの競合を避けるため、購入成功時刻も保持する。
    func recordPremiumPurchase(now: Date = Date()) {
        defaults.set(now, forKey: Key.premiumPurchasedAt)
    }

    func recordOpportunity(
        _ decision: InterstitialOpportunityDecision,
        surface: String,
        action: String,
        didShow: Bool,
        now: Date = Date()
    ) {
        var finalReason = decision.reason
        if decision.shouldShow && !didShow {
            finalReason = "presentation_failed"
        }

        if didShow {
            adsShownInCurrentSession += 1
            defaults.set(now, forKey: Key.lastShownAt)
        }

        Analytics.logEvent("ad_opportunity", parameters: [
            "surface": surface,
            "action": action,
            "outcome": didShow ? "shown" : "not_shown",
            "reason": didShow ? "presented" : finalReason,
            "completed_learning_sets": decision.completedLearningSets,
            "seconds_since_last_ad": decision.secondsSinceLastAd,
            "session_ad_count": adsShownInCurrentSession,
            "first_session": isFirstSession ? 1 : 0
        ])
    }
}

struct AdFreeUpsellToast: View {
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            Text("プレミアムなら、学習中の広告なし")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(.black.opacity(0.86), in: Capsule())
        .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
        .accessibilityElement(children: .combine)
    }
}

class Interstitial: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    @Published var flag: Bool = false
    @Published var wasAdDismissed = false
    
    private var interstitialAd: InterstitialAd?
    @Published private(set) var isLoading = false
    @Published private(set) var isPresenting = false
    private var loadedAt: Date?
    private var pendingCompletions: [(Bool) -> Void] = []
    private var presentationCompletion: ((Bool) -> Void)?
    private var didBeginPresentation = false
    private let maxCacheAge: TimeInterval = 55 * 60

    private var hasValidInterstitial: Bool {
        guard !isPresenting,
              interstitialAd != nil,
              let loadedAt else {
            return false
        }

        return Date().timeIntervalSince(loadedAt) < maxCacheAge
    }

    var isReady: Bool {
        hasValidInterstitial
    }

    /// Load during the battle, never after the result transition has begun.
    @MainActor
    func preloadStoryBattleAd(isPreview: Bool) {
        guard !isPreview else { return }
        let appState = AppState.shared
        guard InterstitialOpportunityCoordinator.shared.shouldPreload(
            subscriptionStateResolved: appState.hasResolvedSubscriptionState,
            isSubscribed: appState.isSubscribed,
            isConnected: ConnectivityMonitor.shared.isConnected
        ) else { return }
        preloadIfNeeded()
    }

    /// The caller holds the completed battle until this callback runs. If an
    /// ad is not already ready, continue immediately rather than showing a
    /// late ad over the result or the next conversation.
    @MainActor
    func presentAfterStoryBattle(
        isPreview: Bool,
        surface: String,
        from viewController: UIViewController,
        onFinish: @escaping () -> Void
    ) {
        guard !isPreview else { onFinish(); return }
        let coordinator = InterstitialOpportunityCoordinator.shared
        coordinator.recordLearningSetCompleted()
        let appState = AppState.shared
        let exclusionReason: String?
        if UIApplication.shared.applicationState != .active {
            exclusionReason = "app_inactive"
        } else if !AdvertisingPrivacyCoordinator.shared.isReady {
            exclusionReason = "privacy_not_ready"
        } else {
            exclusionReason = nil
        }
        let decision = coordinator.decision(
            subscriptionStateResolved: appState.hasResolvedSubscriptionState,
            isSubscribed: appState.isSubscribed,
            isConnected: ConnectivityMonitor.shared.isConnected,
            isAdReady: isReady,
            exclusionReason: exclusionReason
        )
        guard decision.shouldShow else {
            coordinator.recordOpportunity(decision, surface: surface, action: "battle_completed", didShow: false)
            onFinish()
            return
        }

        // A synchronous SDK failure and a false return must not both advance
        // the battle. Also protects the continuation from duplicate callbacks.
        var hasFinished = false
        let finish: (Bool) -> Void = { didShow in
            guard !hasFinished else { return }
            hasFinished = true
            coordinator.recordOpportunity(decision, surface: surface, action: "battle_completed", didShow: didShow)
            onFinish()
        }
        if !presentInterstitial(from: viewController, onFinish: finish) {
            finish(false)
        }
    }
    
    func loadInterstitial(completion: ((Bool) -> Void)? = nil) {
        preloadIfNeeded(completion: completion)
    }

    func preloadIfNeeded(completion: ((Bool) -> Void)? = nil) {
        guard AdvertisingPrivacyCoordinator.shared.isReady else {
            AdvertisingPrivacyCoordinator.shared.performWhenReady { [weak self] in
                self?.preloadIfNeeded(completion: completion)
            }
            return
        }

        if hasValidInterstitial {
            interstitialAdLoaded = true
            completion?(true)
            return
        }

        guard !isPresenting else {
            completion?(false)
            return
        }

        if let completion {
            pendingCompletions.append(completion)
        }

        guard !isLoading else { return }

        isLoading = true
        interstitialAdLoaded = false
        interstitialAd = nil
        loadedAt = nil

#if DEBUG
        let adUnitID = "ca-app-pub-3940256099942544/4411468910"
#else
        let adUnitID = "ca-app-pub-4898800212808837/3001013957"
#endif
        InterstitialAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            self.isLoading = false

            if let error {
                print("loadInterstitial 😭: 読み込みに失敗しました")
                print("loadInterstitial 広告の読み込みに失敗しました: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                self.finishPendingCompletions(success: false)
                return
            }

            print("loadInterstitial 😍: 読み込みに成功しましたああ")
            self.interstitialAdLoaded = true
            self.interstitialAd = ad
            self.loadedAt = Date()
            self.wasAdDismissed = false
            self.interstitialAd?.fullScreenContentDelegate = self
            self.finishPendingCompletions(success: true)
        }
    }

    private func finishPendingCompletions(success: Bool) {
        let completions = pendingCompletions
        pendingCompletions.removeAll()
        completions.forEach { $0(success) }
    }
    
    @discardableResult
    func presentInterstitial(
        from viewController: UIViewController,
        onFinish: ((Bool) -> Void)? = nil
    ) -> Bool {
        guard !isPresenting, hasValidInterstitial, let fullScreenAd = interstitialAd else {
            print("Ad wasn't ready")
            preloadIfNeeded()
            return false
        }
        guard let presenter = AdPresenterResolver.resolve(preferred: viewController) else {
            print("Ad presenter wasn't found")
            return false
        }

        isPresenting = true
        didBeginPresentation = false
        interstitialAdLoaded = false
        presentationCompletion = onFinish
        fullScreenAd.present(from: presenter)
        return true
    }

    private func finishPresentation(didShow: Bool) {
        let completion = presentationCompletion
        presentationCompletion = nil
        completion?(didShow)
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }
    
    // 失敗通知
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.isPresenting = false
        self.interstitialAdLoaded = false
        self.interstitialAd = nil
        self.loadedAt = nil
        self.finishPresentation(didShow: false)
        self.preloadIfNeeded()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        didBeginPresentation = true
//        self.interstitialAdLoaded = false // 広告表示時に false に設定
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.isPresenting = false
        self.interstitialAdLoaded = false // 広告閉じた時に false に設定
        self.wasAdDismissed = true
        self.interstitialAd = nil
        self.loadedAt = nil
        self.finishPresentation(didShow: didBeginPresentation)
    //        loadInterstitial()  // 新しい広告をロード
    }
}

/// 全画面広告の表示元を決める。
/// SwiftUI の View が作り直されると、プロパティで保持した UIViewController が画面階層から外れ、
/// そこから present すると広告の表示に失敗するため、その場合は最前面の画面を代わりに使う。
enum AdPresenterResolver {
    static func resolve(preferred: UIViewController?) -> UIViewController? {
        if let preferred,
           preferred.view.window != nil,
           preferred.presentedViewController == nil {
            return preferred
        }
        return topViewController()
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController

        if let navigationController = root as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        if let tabBarController = root as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(base: selectedViewController)
        }
        if let presentedViewController = root?.presentedViewController,
           !presentedViewController.isBeingDismissed {
            return topViewController(base: presentedViewController)
        }
        return root
    }
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}

struct Interstitial1: View {
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @StateObject private var interstitial = Interstitial()
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .background {
                        // Add the adViewControllerRepresentable to the background so it
                        // doesn't influence the placement of other views in the view hierarchy.
                        adViewControllerRepresentable
                          .frame(width: .zero, height: .zero)
                      }
        }
        .onAppear {
            interstitial.loadInterstitial()
            interstitial.presentInterstitial(from: adViewControllerRepresentable.viewController)
        }
    }
}

#Preview {
    Interstitial1()
}
