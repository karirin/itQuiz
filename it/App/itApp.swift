//
//  itApp.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleMobileAds
import AppTrackingTransparency
import AVFoundation

/// ATT の選択が確定するまで、広告 SDK の初期化と広告リクエストを保留する。
final class AdvertisingPrivacyCoordinator {
    static let shared = AdvertisingPrivacyCoordinator()

    private enum State {
        case idle
        case requestingAuthorization
        case initializingAds
        case ready
    }

    private var state: State = .idle
    private var pendingActions: [() -> Void] = []
    // 初回の3問と通知案内が終わるまで、ATTで学習を中断しない。
    var isInitialLearningActive = false

    var isReady: Bool {
        state == .ready
    }

    private init() {}

    /// アプリがアクティブになったタイミングで ATT を提示する。
    func prepareIfPossible() {
        guard state == .idle,
              UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
              !UserDefaults.standard.bool(forKey: "onboarding.needsNameRegistration"),
              !isInitialLearningActive,
              !InitialLearningTour.shared.needsPresentation,
              UIApplication.shared.applicationState == .active else {
            return
        }

        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            state = .requestingAuthorization
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.startMobileAds(after: status)
                }
            }
        } else {
            startMobileAds(after: ATTrackingManager.trackingAuthorizationStatus)
        }
    }

    /// ATT と広告 SDK の準備後に、広告リクエストを実行する。
    func performWhenReady(_ action: @escaping () -> Void) {
        guard !isReady else {
            action()
            return
        }

        pendingActions.append(action)
        prepareIfPossible()
    }

    private func startMobileAds(after status: ATTrackingManager.AuthorizationStatus) {
        guard state != .initializingAds, state != .ready else { return }

        state = .initializingAds
        print("ATT authorization status: \(status.rawValue)")

        MobileAds.shared.start { [weak self] _ in
            Task { @MainActor in
                self?.finishPreparation()
            }
        }
    }

    private func finishPreparation() {
        guard state != .ready else { return }

        state = .ready
        let actions = pendingActions
        pendingActions.removeAll()
        actions.forEach { $0() }
    }
}

enum NotificationPermissionCoordinator {
    static func requestAuthorizationAndRegister(source: String = "unknown") {
        PushNotificationService.shared.requestAuthorization(source: source)
    }
}

enum AppIconBadgeCoordinator {
    static func update(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(max(count, 0)) { error in
            if let error {
                print("Failed to update app icon badge: \(error.localizedDescription)")
            }
        }
    }
}

/// Spotifyやミュージックなど、他アプリの再生を止めずに効果音を鳴らす。
enum AppAudioSessionCoordinator {
    static func configure() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // ゲームの短い効果音は環境音として扱い、他アプリの音声と共存させる。
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure the audio session: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
private enum DebugReviewDataSeeder {
    private static var authHandle: AuthStateDidChangeListenerHandle?

    static func startIfRequested() {
        guard CommandLine.arguments.contains("--seed-review-test-data") else { return }

        authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            guard let user else { return }
            ReviewScheduleService.seedDebugQuestions(userId: user.uid) { success in
                print("CODEX_REVIEW_SEED uid=\(user.uid) success=\(success)")
            }
            if let authHandle {
                auth.removeStateDidChangeListener(authHandle)
                self.authHandle = nil
            }
        }
    }
}

#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        if UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
            PushNotificationService.shared.registerForRemoteNotificationsIfAuthorized()
        }

        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                PushNotificationService.shared.register(token: token)
            }
        }
        
        AppAudioSessionCoordinator.configure()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 広告やシステム画面から戻った場合も、他アプリとのミックス設定を復元する。
        AppAudioSessionCoordinator.configure()
        AdvertisingPrivacyCoordinator.shared.prepareIfPossible()
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // デバイストークン自体はログへ出さず、Firebase Messagingへだけ渡す。
        Messaging.messaging().apnsToken = deviceToken
        print("Successfully registered an APNs device token")
    }
}


extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        PushNotificationService.shared.register(token: fcmToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .badge, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let notificationType = userInfo["type"] as? String ?? "unknown"
        GrowthAnalytics.logNotificationOpen(type: notificationType)
        Task { @MainActor in
            AppNotificationRouter.shared.handle(userInfo: userInfo)
        }
        completionHandler()
    }
}

@main
struct itApp: App {
    @ObservedObject var authManager: AuthManager
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var connectivity = ConnectivityMonitor.shared
    
    init() {
        FirebaseApp.configure()
        _ = InterstitialOpportunityCoordinator.shared
        authManager = AuthManager.shared
        PushNotificationService.shared.start()
#if DEBUG
        DebugReviewDataSeeder.startIfRequested()
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            launchContent
                .environmentObject(appState)
                .environmentObject(connectivity)
        }
    }

    @ViewBuilder
    private var launchContent: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-InitialLearningPreview") {
            InitialLearningPreview(startsAtResult: ProcessInfo.processInfo.arguments.contains("-InitialLearningResult"))
        } else if ProcessInfo.processInfo.arguments.contains("-LearningTourAnswersPreview") {
            LearningTourAnswersPreview()
        } else if ProcessInfo.processInfo.arguments.contains("-DeveloperSettingsPreview") {
            SettingView()
        } else if ProcessInfo.processInfo.arguments.contains("-AppUpdatePreview") {
            AppUpdatePreview()
        } else if ProcessInfo.processInfo.arguments.contains("-SlimeLoadingPreview") {
            SlimeLoadingDebugPreview()
        } else if ProcessInfo.processInfo.arguments.contains("-GachaDesignPreview") {
            GachaDesignPreview()
        } else if ProcessInfo.processInfo.arguments.contains("-WeaknessCoursePreview") {
            WeaknessCoursePreview()
        } else if ProcessInfo.processInfo.arguments.contains("-LearningAnalysisPreview") {
            LearningAnalysisPreview()
        } else if ProcessInfo.processInfo.arguments.contains("-ReviewExercisePreview") {
            ReviewExercisePreview()
        } else if ProcessInfo.processInfo.arguments.contains("-StoryDialoguePreview") {
            StoryAdventureView(accountID: "dialogue-preview", isPreview: true,
                               defaults: UserDefaults(suiteName: "story-dialogue-debug") ?? .standard,
                               mapStyle: .storybook)
        } else if ProcessInfo.processInfo.arguments.contains("-StoryImageAdventurePreview") {
            StoryAdventureView(accountID: ProcessInfo.processInfo.arguments.contains("-StoryExpandedAdventurePreview")
                                   ? "simulator-expanded-preview" : "simulator-preview", isPreview: true,
                               defaults: UserDefaults(suiteName: "story-adventure-debug") ?? .standard,
                               mapStyle: .storybook)
        } else if ProcessInfo.processInfo.arguments.contains("-StoryAdventurePreview") {
            StoryAdventureView(accountID: "simulator-preview", isPreview: true,
                               defaults: UserDefaults(suiteName: "story-adventure-debug") ?? .standard)
        } else {
            RootView(authManager: authManager)
        }
#else
        RootView(authManager: authManager)
#endif
    }
}
