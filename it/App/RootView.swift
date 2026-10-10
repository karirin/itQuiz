//
//  RootView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/17.
//

import SwiftUI
import StoreKit
import Network

final class ConnectivityMonitor: ObservableObject {
    static let shared = ConnectivityMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "itquiz.connectivity-monitor")

    private init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ForceOfflineMode")
            || ProcessInfo.processInfo.arguments.contains("-ReviewExercisePreview") {
            isConnected = false
            return
        }
#endif

        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }
}

struct OfflineStatusBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 15, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text("オフラインモード")
                    .font(.system(size: 14, weight: .bold))
                Text("通常の問題演習を利用できます")
                    .font(.system(size: 11, weight: .medium))
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange)
        .accessibilityElement(children: .combine)
    }
}

struct OfflineUnavailableView: View {
    let featureName: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(.orange)

            Text("\(featureName)は通信が必要です")
                .font(.system(size: 18, weight: .bold))

            Text("インターネットに接続すると自動的に利用できるようになります。")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Color2"))
    }
}

struct OfflineFeatureNotice: View {
    let featureName: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.orange)
            Text("\(featureName)はインターネット接続が必要です")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }
}

struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @State static private var showExperienceModalPreview = false
    @State var isActive = false
    @State private var isUserExists: Bool? = nil
    @State private var isDataReady = false
    @State private var partyPreview: [String] = []
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) var scenePhase
    let viewModel = PositionViewModel.shared
    @State private var isShowingOtherAppsSheet = false
    @State private var hasScheduledOtherAppsSheet = false
    @AppStorage(OtherAppsPromotionPreference.isSuppressedKey)
    private var isOtherAppsPromotionSuppressed = false
    @AppStorage("hasCompletedFirstLaunch")
    private var hasCompletedFirstLaunch = false
    @State private var isFirstLaunchSession = false
    @State private var isStartingInitialLoad = false
    @EnvironmentObject private var connectivity: ConnectivityMonitor

    private static let defaultPartyPreview = ["ネッキー", "ピョン吉", "うっさん", "ライム"]
    private static let startupTimeout: TimeInterval = 8

    var body: some View {
        Group {
            if !isActive {
                SplashScreenView(party: partyPreview)
            } else {
                TopView()
            }
        }
        .sheet(isPresented: $isShowingOtherAppsSheet) {
            OtherAppsPromotionView()
                .presentationDetents([.large,
                                      .fraction(isSmallDevice() ? 0.95 : isiPhone12Or13() ? 0.7 : 0.7)
                ])
        }
        .onAppear {
            // チュートリアルの状態に関係なく、アプリ自体の初回起動を判定する。
            // 初回起動中にチュートリアルを完了しても、このセッションでは他のアプリの案内を表示しない。
            isFirstLaunchSession = !hasCompletedFirstLaunch
            beginInitialLoad()
        }
        .onChange(of: connectivity.isConnected) { isConnected in
            if !isConnected {
                isShowingOtherAppsSheet = false
                hasScheduledOtherAppsSheet = false
                if !isDataReady {
                    completeInitialLoadWithDefaults()
                }
            } else if !isDataReady {
                beginInitialLoad()
            }
        }
    }

    private func beginInitialLoad() {
        guard !isDataReady, !isStartingInitialLoad else { return }
        guard connectivity.isConnected else {
            completeInitialLoadWithDefaults()
            return
        }

        isStartingInitialLoad = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.startupTimeout) {
            guard !isDataReady else { return }
            print("Initial loading timed out. Continuing with cached/default data.")
            completeInitialLoadWithDefaults()
        }

        guard authManager.currentUserId == nil else {
            loadPartyPreviewAndUserStatus()
            return
        }

        authManager.anonymousSignIn {
            DispatchQueue.main.async {
                self.loadPartyPreviewAndUserStatus()
            }
        }
    }

    /// 起動時のアバターおよびユーザー存在チェックをまとめて行い、両方完了したら isDataReady を立てる
    private func loadPartyPreviewAndUserStatus() {
        guard !isDataReady else { return }
        guard connectivity.isConnected, let userId = authManager.currentUserId else {
            completeInitialLoadWithDefaults()
            return
        }

        let group = DispatchGroup()

        group.enter()
        authManager.checkIfUserIdExists(userId: userId) { exists in
            DispatchQueue.main.async {
                self.isUserExists = exists
                group.leave()
            }
        }

        group.enter()
        authManager.fetchAvatars {
            DispatchQueue.main.async {
                self.partyPreview = selectPartyPreview(from: authManager.avatars)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            guard !self.isDataReady else { return }
            self.isStartingInitialLoad = false
            self.isDataReady = true
            tryActivate()
        }
    }

    private func completeInitialLoadWithDefaults() {
        guard !isDataReady else { return }
        isStartingInitialLoad = false
        isUserExists = false
        if partyPreview.isEmpty {
            partyPreview = Self.defaultPartyPreview
        }
        isDataReady = true
        tryActivate()
    }

    /// 所持おともから任意に最大5体を選ぶ（起動ごとに顔ぶれが変わる）。
    /// 演出が成立するよう、所持数が少ない場合は既定のおともで4体まで補完する
    private func selectPartyPreview(from avatars: [Avatar]) -> [String] {
        var seenNames = Set<String>()
        var picked = avatars
            .filter { seenNames.insert($0.name).inserted }
            .shuffled()
            .prefix(5)
            .map { $0.name }

        for fallbackName in Self.defaultPartyPreview.shuffled() where picked.count < 4 {
            guard seenNames.insert(fallbackName).inserted else { continue }
            picked.append(fallbackName)
        }

        return picked
    }

    /// 起動時データの読み込みが完了したら、待ち時間を設けずスプラッシュを終了する
    private func tryActivate() {
        guard isDataReady, !isActive else { return }
        withAnimation {
            self.isActive = true
        }
        if !hasCompletedFirstLaunch {
            hasCompletedFirstLaunch = true
        }
        scheduleOtherAppsSheetIfEligible()
    }

    private func scheduleOtherAppsSheetIfEligible() {
        guard isActive,
              connectivity.isConnected,
              isUserExists == true,
              !isFirstLaunchSession,
              !InitialLearningTour.shared.needsPresentation,
              UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
              !isOtherAppsPromotionSuppressed,
              OtherAppsPromotionPreference.isDue(),
              !hasScheduledOtherAppsSheet else { return }

        hasScheduledOtherAppsSheet = true
        checkLoginBonusThenShowOtherApps()
    }
    
    /// ログインボーナスを表示する日は重ねて出さず、次回以降の起動に回す。
    private func checkLoginBonusThenShowOtherApps() {
        authManager.shouldShowLoginBonus { shouldShow in
            guard !shouldShow else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard connectivity.isConnected,
                      isUserExists == true,
                      LaunchPromptGate.shared.claim() else { return }
                OtherAppsPromotionPreference.recordShown()
                isShowingOtherAppsSheet = true
            }
        }
    }
    
    func isiPhone12Or13() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let width = min(screenSize.width, screenSize.height)
        let height = max(screenSize.width, screenSize.height)
        return abs(width - 390) < 1 && abs(height - 844) < 1
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authManager: AuthManager())
            .environmentObject(ConnectivityMonitor.shared)
    }
}
