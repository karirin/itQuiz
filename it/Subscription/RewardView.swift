//
//  RewardView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/30.
//

import SwiftUI
import GoogleMobileAds
import Combine

enum RewardAdPlacement: Equatable {
    case standard
    case story
}

/// 広告ユニットごとに1つだけ保持する共有キャッシュ。
///
/// 画面ごとに `Reward` を作っても、実際の広告リクエストはここで重複排除される。
private final class SharedRewardAdStore: NSObject, FullScreenContentDelegate, ObservableObject {
    static let standard = SharedRewardAdStore(placement: .standard)
    static let story = SharedRewardAdStore(placement: .story)

    static func store(for placement: RewardAdPlacement) -> SharedRewardAdStore {
        switch placement {
        case .standard: return .standard
        case .story: return .story
        }
    }

    @Published private(set) var isLoaded = false
    @Published private(set) var isLoading = false

    private let placement: RewardAdPlacement
    private var rewardedAd: RewardedAd?
    private var loadedAt: Date?
    private var isPresenting = false
    private var isWaitingForPrivacyAuthorization = false
    private var retryAttempt = 0
    private var retryWorkItem: DispatchWorkItem?
    private var rewardHandler: (() -> Void)?
    private var dismissHandler: (() -> Void)?
    private var didEarnCurrentReward = false

    private let maxCacheAge: TimeInterval = 55 * 60
    private let maxAutomaticRetryCount = 2

    private var adUnitID: String {
        switch placement {
        case .standard:
            return "ca-app-pub-4898800212808837/5768331457"
        case .story:
            return "ca-app-pub-4898800212808837/6563091309"
        }
    }

    private var placementLabel: String {
        placement == .story ? "LoadStoryReward" : "LoadReward"
    }

    private var hasValidAd: Bool {
        guard !isPresenting,
              rewardedAd != nil,
              let loadedAt else {
            return false
        }

        return Date().timeIntervalSince(loadedAt) < maxCacheAge
    }

    private init(placement: RewardAdPlacement) {
        self.placement = placement
        super.init()
    }

    func loadIfNeeded() {
        loadIfNeeded(isAutomaticRetry: false)
    }

    private func loadIfNeeded(isAutomaticRetry: Bool) {
        guard AdvertisingPrivacyCoordinator.shared.isReady else {
            guard !isWaitingForPrivacyAuthorization else { return }
            isWaitingForPrivacyAuthorization = true
            AdvertisingPrivacyCoordinator.shared.performWhenReady { [weak self] in
                guard let self else { return }
                self.isWaitingForPrivacyAuthorization = false
                self.loadIfNeeded(isAutomaticRetry: isAutomaticRetry)
            }
            return
        }

        if hasValidAd {
            isLoaded = true
            return
        }

        if rewardedAd != nil {
            clearLoadedAd()
        }

        guard !isLoading, !isPresenting else { return }
        guard isAutomaticRetry || retryWorkItem == nil else { return }

        if !isAutomaticRetry {
            retryAttempt = 0
        }

        isLoading = true
        isLoaded = false

        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false

            if let error = error {
                print("\(self.placementLabel) 😭: 読み込みに失敗しました: \(error.localizedDescription)")
                self.isLoaded = false
                self.scheduleRetryIfPossible()
                return
            }

            guard let ad else {
                self.isLoaded = false
                self.scheduleRetryIfPossible()
                return
            }

            print("\(self.placementLabel) 😍: 読み込みに成功しました")
            self.retryWorkItem?.cancel()
            self.retryWorkItem = nil
            self.retryAttempt = 0
            self.rewardedAd = ad
            self.loadedAt = Date()
            self.rewardedAd?.fullScreenContentDelegate = self
            self.isLoaded = true
        }
    }

    @discardableResult
    func present(
        from viewController: UIViewController,
        onReward: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> Bool {
        guard !isPresenting, hasValidAd, let rewardedAd else {
            loadIfNeeded()
            return false
        }

        isPresenting = true
        isLoaded = false
        didEarnCurrentReward = false
        rewardHandler = onReward
        dismissHandler = onDismiss

        rewardedAd.present(from: viewController) { [weak self] in
            guard let self, !self.didEarnCurrentReward else { return }
            self.didEarnCurrentReward = true
            self.rewardHandler?()
        }

        return true
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(placementLabel) 😭: 表示に失敗しました: \(error.localizedDescription)")
        finishPresentation()
        loadIfNeeded()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("リワード広告が閉じられました")
        let onDismiss = dismissHandler
        finishPresentation()
        onDismiss?()
    }

    private func scheduleRetryIfPossible() {
        guard retryAttempt < maxAutomaticRetryCount,
              retryWorkItem == nil else { return }

        retryAttempt += 1
        let delay = TimeInterval(5 * (1 << (retryAttempt - 1)))
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.retryWorkItem = nil
            self.loadIfNeeded(isAutomaticRetry: true)
        }
        retryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func finishPresentation() {
        isPresenting = false
        isLoaded = false
        rewardHandler = nil
        dismissHandler = nil
        clearLoadedAd()
    }

    private func clearLoadedAd() {
        rewardedAd = nil
        loadedAt = nil
    }
}

/// 各画面の報酬通知状態を保持する軽量アダプター。
/// 広告本体は `SharedRewardAdStore` で広告ユニットごとに共有する。
final class Reward: NSObject, ObservableObject {
    @Published private(set) var rewardLoaded = false
    @Published var rewardEarned = false

    private let store: SharedRewardAdStore
    private let authManager = AuthManager.shared
    private let viewModel = PositionViewModel.shared
    private var storeSubscription: AnyCancellable?

    init(placement: RewardAdPlacement = .standard) {
        store = SharedRewardAdStore.store(for: placement)
        super.init()

        rewardLoaded = store.isLoaded
        storeSubscription = store.$isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                self?.rewardLoaded = isLoaded
            }
    }

    func LoadReward() {
        store.loadIfNeeded()
    }

    func LoadStoryReward() {
        store.loadIfNeeded()
    }

    func ShowReward() {
        presentReward(
            onReward: { [weak self] in
                guard let self else { return }
                print("😍: 報酬を獲得しました")
                self.authManager.addMoney(amount: 300)
                self.rewardEarned = true
            },
            // コイン報酬は同じ画面で再度利用できるため、表示後に1枚だけ補充する。
            onDismiss: { [weak self] in
                self?.store.loadIfNeeded()
            }
        )
    }

    func ShowSutaminaReward() {
        presentReward { [weak self] in
            guard let self else { return }
            print("😍: 報酬を獲得しました")
            self.viewModel.recoverStamina(by: 30)
            self.rewardEarned = true
        }
    }

    func ExAndMoReward() {
        presentReward { [weak self] in
            guard let self else { return }
            print("ExAndMoReward 😍: 報酬を獲得しました")
            self.authManager.activateOneHourBoost { [weak self] success in
                guard let self, success else { return }
                self.rewardEarned = true
            }
        }
    }

    func checkRewardReset() {
        print("checkRewardReset")
        authManager.syncRewardBoostState()
    }

    func resetupdateRewardFlag() {
        authManager.syncRewardBoostState()
    }

    private func presentReward(
        onReward: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        guard let viewController = topViewController() else {
            print("😭: 広告の表示先を確認できませんでした")
            store.loadIfNeeded()
            return
        }

        guard store.present(from: viewController, onReward: onReward, onDismiss: onDismiss) else {
            print("😭: 広告の準備ができていませんでした")
            return
        }
    }

    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
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
        if let presentedViewController = root?.presentedViewController {
            return topViewController(base: presentedViewController)
        }
        return root
    }
}

final class QuizResultRewardAd: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published private(set) var isLoaded = false
    @Published private(set) var isLoading = false
    @Published private(set) var isPresenting = false
    @Published private(set) var loadFailed = false

    private var rewardedAd: RewardedAd?
    private var didEarnCurrentReward = false

    private var adUnitID: String {
#if DEBUG
        return "ca-app-pub-3940256099942544/1712485313"
#else
        return "ca-app-pub-4898800212808837/5475518069"
#endif
    }

    func preloadIfNeeded() {
        guard AdvertisingPrivacyCoordinator.shared.isReady else {
            AdvertisingPrivacyCoordinator.shared.performWhenReady { [weak self] in
                self?.preloadIfNeeded()
            }
            return
        }

        guard rewardedAd == nil, !isLoading, !isPresenting else { return }

        isLoading = true
        loadFailed = false

        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            self.isLoading = false

            if let error {
                print("QuizResultRewardAd 😭: 読み込みに失敗しました: \(error.localizedDescription)")
                self.isLoaded = false
                self.loadFailed = true
                return
            }

            guard let ad else {
                self.isLoaded = false
                self.loadFailed = true
                return
            }

            print("QuizResultRewardAd 😍: 読み込みに成功しました")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            self.isLoaded = true
        }
    }

    @discardableResult
    func present(from viewController: UIViewController, onReward: @escaping () -> Void) -> Bool {
        guard !isPresenting, let rewardedAd else {
            preloadIfNeeded()
            return false
        }
        guard let presenter = AdPresenterResolver.resolve(preferred: viewController) else {
            return false
        }

        isPresenting = true
        isLoaded = false
        didEarnCurrentReward = false

        rewardedAd.present(from: presenter) { [weak self] in
            guard let self, !self.didEarnCurrentReward else { return }

            self.didEarnCurrentReward = true
            onReward()
        }

        return true
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("QuizResultRewardAd 😭: 表示に失敗しました: \(error.localizedDescription)")
        isPresenting = false
        isLoaded = false
        rewardedAd = nil
        preloadIfNeeded()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        let shouldReload = !didEarnCurrentReward
        isPresenting = false
        isLoaded = false
        rewardedAd = nil

        if shouldReload {
            preloadIfNeeded()
        }
    }
}

struct RewardView: View {
    @StateObject private var reward = Reward()
    var body: some View {
        Button(action: { 
                        generateHapticFeedback()
            reward.ShowReward()
        }) {
            Text(reward.rewardLoaded ? "リワード広告表示" : "読み込み中...")
        }
        .onAppear() {
            reward.LoadReward()
        }
        .disabled(!reward.rewardLoaded)
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
    }
}
