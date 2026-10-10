import CryptoKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import SwiftUI
import UIKit
import UserNotifications

enum AppNotificationDestination: Equatable {
    case review
    case dailyLearning
    case friendRequests
    case weeklyLeague
    case battleInvitations
    case battleResult(String)
    case weeklyLeagueResult
    case guild
}

@MainActor
final class AppNotificationRouter: ObservableObject {
    static let shared = AppNotificationRouter()

    @Published private(set) var pendingDestination: AppNotificationDestination?

    private init() {}

    func handle(userInfo: [AnyHashable: Any]) {
        guard let rawType = userInfo["type"] as? String else { return }

        switch rawType {
        case "initial_learning":
            if let userID = userInfo["userID"] as? String,
               userID != (Auth.auth().currentUser?.uid ?? InitialLearningPlanStore.localGuestID) { return }
            pendingDestination = .dailyLearning
        case "review_due":
            pendingDestination = userInfo["reminderKind"] as? String == "quick_quiz" ? .dailyLearning : .review
        case "friend_request":
            pendingDestination = .friendRequests
        case "battle_invite":
            pendingDestination = .battleInvitations
        case "battle_result":
            let battleId = userInfo["battleId"] as? String ?? ""
            pendingDestination = battleId.isEmpty ? .weeklyLeague : .battleResult(battleId)
        case "weekly_league_warning":
            pendingDestination = .weeklyLeague
        case "weekly_league_result":
            pendingDestination = .weeklyLeagueResult
        case "guild_reward", "guild_raid_started":
            pendingDestination = .guild
        default:
            break
        }
    }

    func consume() -> AppNotificationDestination? {
        defer { pendingDestination = nil }
        return pendingDestination
    }
}

struct PushNotificationPreferences: Equatable {
    var learning = true
    var weeklyLeague = true
    var friends = true
    var battles = true
    var guild = true
    var reminderHour = 20

    init(value: [String: Any] = [:]) {
        learning = value["learning"] as? Bool ?? true
        weeklyLeague = value["weeklyLeague"] as? Bool ?? true
        friends = value["friends"] as? Bool ?? true
        battles = value["battles"] as? Bool ?? true
        guild = value["guild"] as? Bool ?? true
        reminderHour = min(max(value["reminderHour"] as? Int ?? 20, 6), 23)
    }

    var firebaseValue: [String: Any] {
        [
            "learning": learning,
            "weeklyLeague": weeklyLeague,
            "friends": friends,
            "battles": battles,
            "guild": guild,
            "reminderHour": reminderHour,
            "timeZone": TimeZone.current.identifier,
            "updatedAt": ServerValue.timestamp()
        ]
    }
}

final class PushNotificationService: ObservableObject {
    static let shared = PushNotificationService()

    @Published private(set) var preferences = PushNotificationPreferences()
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var isLoadingPreferences = false

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var latestToken: String?
    private var registeredUserId: String?
    private var started = false

    private init() {}

    func start() {
        guard !started else { return }
        started = true

        refreshAuthorizationStatus()
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            let previousUserId = self.registeredUserId
            if let previousUserId, previousUserId != user?.uid {
                self.removeLatestToken(from: previousUserId)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.initialLearningReminderID])
            }

            if let user {
                self.registeredUserId = user.uid
                self.loadPreferences(userId: user.uid)
                self.refreshRegistrationToken()
            } else {
                self.registeredUserId = nil
            }
        }
    }

    func requestAuthorization(source: String = "settings", completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.refreshAuthorizationStatus()
                GrowthAnalytics.logNotificationPermission(
                    status: granted ? "authorized" : "denied",
                    source: source
                )
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.refreshRegistrationToken()
                }
                completion?(granted)
            }
        }
    }

    /// 起動時はシステム許諾ダイアログを出さず、既に許可済みの端末だけ再登録する。
    func registerForRemoteNotificationsIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.refreshRegistrationToken()
                default:
                    break
                }
            }
        }
    }

    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func refreshRegistrationToken() {
        Messaging.messaging().token { [weak self] token, error in
            guard error == nil, let token, !token.isEmpty else { return }
            self?.register(token: token)
        }
    }

    func register(token: String) {
        if let previousToken = latestToken,
           previousToken != token,
           let registeredUserId {
            remove(token: previousToken, from: registeredUserId)
        }
        latestToken = token
        guard let userId = Auth.auth().currentUser?.uid else { return }
        registeredUserId = userId

        let key = Self.tokenKey(token)
        let value: [String: Any] = [
            "token": token,
            "platform": "ios",
            "bundleId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            "updatedAt": ServerValue.timestamp()
        ]
        Database.database().reference()
            .child("pushTokens")
            .child(userId)
            .child(key)
            .updateChildValues(value)
    }

    private func removeLatestToken(from userId: String) {
        guard let latestToken else { return }
        remove(token: latestToken, from: userId)
    }

    private func remove(token: String, from userId: String) {
        Database.database().reference()
            .child("pushTokens")
            .child(userId)
            .child(Self.tokenKey(token))
            .removeValue()
    }

    func update(_ change: (inout PushNotificationPreferences) -> Void) {
        let previousHour = preferences.reminderHour
        var updated = preferences
        change(&updated)
        preferences = updated
        if !updated.learning {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.initialLearningReminderID])
            if let userId = Auth.auth().currentUser?.uid {
                Database.database().reference().child("notificationPreferences").child(userId)
                    .child("initialLearningReminderAt").removeValue()
            }
        }
        savePreferences()
        if updated.learning, updated.reminderHour != previousHour,
           let plan = InitialLearningPlanStore.load(userID: Auth.auth().currentUser?.uid ?? InitialLearningPlanStore.localGuestID),
           plan.reminderDate(hour: updated.reminderHour) != nil {
            UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
                guard requests.contains(where: { $0.identifier == Self.initialLearningReminderID }) else { return }
                DispatchQueue.main.async {
                    self?.scheduleInitialLearningReminder(plan: plan, hour: updated.reminderHour) { _ in }
                }
            }
        }
    }

    private static let initialLearningReminderID = "initial-learning-next-day"

    /// 今日の学習が終わったら、サーバーのお誘いと当日の初回リマインドを控える。
    func recordLearningActivity(userId: String) {
        guard !userId.isEmpty, userId == Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("notificationPreferences").child(userId)
            .updateChildValues([
                "lastLearnedAt": ServerValue.timestamp(),
                "timeZone": TimeZone.current.identifier
            ])
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            guard let request = requests.first(where: { $0.identifier == Self.initialLearningReminderID }),
                  request.content.userInfo["userID"] as? String == userId,
                  let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let date = trigger.nextTriggerDate(), Calendar.current.isDateInToday(date) else { return }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
        }
    }

    /// 最初の翌日だけ端末で予約する。無料ユーザーにも届き、サーバーの復習件数に依存しない。
    func scheduleInitialLearningReminder(plan: InitialLearningPlan, hour: Int, completion: @escaping (Error?) -> Void) {
        guard let date = plan.reminderDate(hour: hour) else {
            completion(NSError(domain: "InitialLearningReminder", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "翌日の学習日は過ぎています。ホームから学習を続けられます。"]))
            return
        }
        let content = UNMutableNotificationContent()
        let userId = Auth.auth().currentUser?.uid
        content.title = "今日も3問、少しだけ学ぼう"
        content.body = plan.incorrectCount > 0
            ? "最初の3問で間違えた問題を復習しましょう。ホームからすぐに始められます。"
            : "ITパスポートの新しい3問が待っています。ホームからすぐに始められます。"
        content.sound = .default
        content.userInfo = ["type": "initial_learning",
                            "userID": userId ?? InitialLearningPlanStore.localGuestID]
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let request = UNNotificationRequest(identifier: Self.initialLearningReminderID, content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil, userId == Auth.auth().currentUser?.uid {
                    self?.update { $0.learning = true; $0.reminderHour = min(23, max(6, hour)) }
                    // 初回の翌日通知と、火曜・金曜の定期配信を同じ日に重ねない。
                    if let userId {
                        Database.database().reference().child("notificationPreferences").child(userId)
                            .child("initialLearningReminderAt").setValue(date.timeIntervalSince1970 * 1_000)
                    }
                }
                completion(error)
            }
        }
    }

    private func loadPreferences(userId: String) {
        DispatchQueue.main.async { self.isLoadingPreferences = true }
        let ref = Database.database().reference().child("notificationPreferences").child(userId)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let value = snapshot.value as? [String: Any] ?? [:]
            let loaded = PushNotificationPreferences(value: value)
            DispatchQueue.main.async {
                self.preferences = loaded
                self.isLoadingPreferences = false
            }
            if !snapshot.exists() {
                ref.updateChildValues(loaded.firebaseValue)
            }
            if let latestToken = self.latestToken {
                self.register(token: latestToken)
            }
        } withCancel: { [weak self] _ in
            DispatchQueue.main.async { self?.isLoadingPreferences = false }
        }
    }

    private func savePreferences() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Database.database().reference()
            .child("notificationPreferences")
            .child(userId)
            .updateChildValues(preferences.firebaseValue)
    }

    private static func tokenKey(_ token: String) -> String {
        SHA256.hash(data: Data(token.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

struct NotificationSettingsView: View {
    @ObservedObject private var service = PushNotificationService.shared

    var body: some View {
        Form {
            Section {
                authorizationRow
            } footer: {
                Text("通知が届かない場合は、iPhoneの設定から通知を許可してください。")
            }

            Section("通知する内容") {
                preferenceToggle("学習・復習", systemImage: "brain.head.profile", keyPath: \.learning)
                preferenceToggle("週間リーグ", systemImage: "trophy.fill", keyPath: \.weeklyLeague)
                preferenceToggle("フレンド", systemImage: "person.2.fill", keyPath: \.friends)
                preferenceToggle("対戦", systemImage: "flag.checkered", keyPath: \.battles)
                preferenceToggle("ギルド", systemImage: "person.3.fill", keyPath: \.guild)
            }

            Section {
                Picker("通知時刻", selection: reminderHourBinding) {
                    ForEach(6...23, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
                .disabled(!service.preferences.learning)
            } header: {
                Text("学習リマインド")
            } footer: {
                Text("火曜・金曜の週2回、設定した時刻に学習や復習をお知らせします。その日に学習済みの場合や、ほかの通知が直前に届いた場合は控えます。初回は翌日にもお知らせします。")
            }
        }
        .navigationTitle("通知設定")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            service.start()
            service.refreshAuthorizationStatus()
        }
    }

    @ViewBuilder
    private var authorizationRow: some View {
        switch service.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            Label("iPhoneの通知は許可されています", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .denied:
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: {
                Label("iPhoneの設定を開く", systemImage: "gear")
            }
        case .notDetermined:
            Button {
                service.requestAuthorization()
            } label: {
                Label("通知を許可する", systemImage: "bell.badge.fill")
            }
        @unknown default:
            Text("通知設定を確認できません")
        }
    }

    private func preferenceToggle(
        _ title: String,
        systemImage: String,
        keyPath: WritableKeyPath<PushNotificationPreferences, Bool>
    ) -> some View {
        Toggle(isOn: Binding(
            get: { service.preferences[keyPath: keyPath] },
            set: { value in service.update { $0[keyPath: keyPath] = value } }
        )) {
            Label(title, systemImage: systemImage)
        }
    }

    private var reminderHourBinding: Binding<Int> {
        Binding(
            get: { service.preferences.reminderHour },
            set: { value in service.update { $0.reminderHour = value } }
        )
    }
}
