//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase
import FirebaseAuth

enum InventoryItemType: String, Codable, CaseIterable {
    case normalGachaTicket
    case rareGachaTicket
    case mekaGachaTicket
    case godGachaTicket
    case guardianGachaTicket
    case staminaPotion
    case boostTicket

    var displayName: String {
        switch self {
        case .normalGachaTicket:
            return "レギュラーガチャチケット"
        case .rareGachaTicket:
            return "幸福ガチャチケット"
        case .mekaGachaTicket:
            return "メカガチャチケット"
        case .godGachaTicket:
            return "神ガチャチケット"
        case .guardianGachaTicket:
            return "四聖獣ガチャチケット"
        case .staminaPotion:
            return "スタミナ回復薬"
        case .boostTicket:
            return "ブースト薬"
        }
    }

    var shortName: String {
        switch self {
        case .normalGachaTicket:
            return "レギュラー"
        case .rareGachaTicket:
            return "幸福"
        case .mekaGachaTicket:
            return "メカ"
        case .godGachaTicket:
            return "神"
        case .guardianGachaTicket:
            return "四聖獣"
        case .staminaPotion:
            return "回復薬"
        case .boostTicket:
            return "ブースト薬"
        }
    }

    var systemImageName: String {
        switch self {
        case .normalGachaTicket:
            return "ticket.fill"
        case .rareGachaTicket:
            return "giftcard.fill"
        case .mekaGachaTicket:
            return "cpu.fill"
        case .godGachaTicket:
            return "sparkles.rectangle.stack.fill"
        case .guardianGachaTicket:
            return "tortoise.fill"
        case .staminaPotion:
            return "cross.case.fill"
        case .boostTicket:
            return "bolt.circle.fill"
        }
    }

    var assetImageName: String {
        switch self {
        case .normalGachaTicket:
            return "レギュラーガチャチケット"
        case .rareGachaTicket:
            return "幸福ガチャチケット"
        case .mekaGachaTicket:
            return "メカガチャチケット"
        case .godGachaTicket:
            return "神ガチャチケット"
        case .guardianGachaTicket:
            return "四聖獣ガチャチケット"
        case .staminaPotion:
            return "スタミナ回復薬"
        case .boostTicket:
            return "ブースト薬"
        }
    }

    var accentColor: Color {
        switch self {
        case .normalGachaTicket:
            return Color(red: 1.0, green: 0.72, blue: 0.24)
        case .rareGachaTicket:
            return Color(red: 1.0, green: 0.42, blue: 0.36)
        case .mekaGachaTicket:
            return Color(red: 0.43, green: 0.49, blue: 0.92)
        case .godGachaTicket:
            return Color(red: 1.0, green: 0.84, blue: 0.22)
        case .guardianGachaTicket:
            return Color(red: 0.2, green: 0.6, blue: 0.45)
        case .staminaPotion:
            return Color(red: 0.24, green: 0.74, blue: 0.48)
        case .boostTicket:
            return Color(red: 1.0, green: 0.45, blue: 0.24)
        }
    }

    var userFieldKey: String {
        rawValue
    }

    var usageDescription: String {
        switch self {
        case .normalGachaTicket:
            return "レギュラーガチャをコインなしで1回引けます。"
        case .rareGachaTicket:
            return "幸福ガチャをコインなしで1回引けます。"
        case .mekaGachaTicket:
            return "メカガチャをコインなしで1回引けます。"
        case .godGachaTicket:
            return "神ガチャをコインなしで1回引けます。"
        case .guardianGachaTicket:
            return "四聖獣ガチャをコインなしで1回引けます。"
        case .staminaPotion:
            return "スタミナを30回復します。"
        case .boostTicket:
            return "1時間、獲得経験値とコインが2倍になります。"
        }
    }
}

struct InventoryReward: Codable, Hashable {
    let type: InventoryItemType
    let amount: Int

    var displayText: String {
        "\(type.displayName) x\(amount)"
    }
}

extension InventoryReward {
    static func merged(_ rewards: [InventoryReward]) -> [InventoryReward] {
        let totals = rewards.reduce(into: [InventoryItemType: Int]()) { partialResult, reward in
            partialResult[reward.type, default: 0] += reward.amount
        }

        return InventoryItemType.allCases.compactMap { type in
            guard let amount = totals[type], amount > 0 else { return nil }
            return InventoryReward(type: type, amount: amount)
        }
    }

    static func summaryText(for rewards: [InventoryReward], useShortNames: Bool = false) -> String {
        merged(rewards)
            .map { reward in
                let itemName = useShortNames ? reward.type.shortName : reward.type.displayName
                return "\(itemName) x\(reward.amount)"
            }
            .joined(separator: " / ")
    }
}

struct InventoryItemArtworkView: View {
    let type: InventoryItemType
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 12

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(type.accentColor.opacity(0.12))

            Image(type.assetImageName)
                .resizable()
                .scaledToFit()
                .padding(6)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(type.accentColor.opacity(0.25), lineWidth: 1)
        )
    }
}

struct DungeonRewardPlanner {
    static func treasureRewards(for treasureID: Int) -> [InventoryReward] {
        if treasureID > 30 { return DungeonExpansion.treasureRewards(for: treasureID) }
        switch treasureID {
        case 8:
            return [InventoryReward(type: .normalGachaTicket, amount: 1)]
        case 13:
            return [InventoryReward(type: .staminaPotion, amount: 1)]
        case 16:
            return [InventoryReward(type: .rareGachaTicket, amount: 1)]
        case 23:
            return [InventoryReward(type: .staminaPotion, amount: 2)]
        case 29:
            return [InventoryReward(type: .boostTicket, amount: 1)]
        case 30:
            return [InventoryReward(type: .mekaGachaTicket, amount: 1)]
        default:
            return []
        }
    }

    static func battleRewards(for monsterName: String) -> [InventoryReward] {
        let expansionRewards = DungeonExpansion.battleRewards(for: monsterName)
        if !expansionRewards.isEmpty { return expansionRewards }
        switch monsterName {
        case "ボス15":
            return [InventoryReward(type: .normalGachaTicket, amount: 1)]
        case "ボス16":
            return [
                InventoryReward(type: .rareGachaTicket, amount: 1),
                InventoryReward(type: .staminaPotion, amount: 1)
            ]
        case "ボス35":
            return [
                InventoryReward(type: .godGachaTicket, amount: 1),
                InventoryReward(type: .boostTicket, amount: 1)
            ]
        default:
            return []
        }
    }
}

struct GuerrillaRewardPlanner {
    static func baseRewards(forDifficulty difficulty: String) -> [InventoryReward] {
        switch GuerrillaDifficulty(rawValue: difficulty) {
        case .beginner:
            return [InventoryReward(type: .normalGachaTicket, amount: 1)]
        case .intermediate:
            return [InventoryReward(type: .rareGachaTicket, amount: 1)]
        case .advanced:
            return [InventoryReward(type: .mekaGachaTicket, amount: 1)]
        case .none:
            return []
        }
    }

    static func bonusRewards(forRank rank: Int) -> [InventoryReward] {
        guard rank > 0 else { return [] }

        var rewards: [InventoryReward] = []

        if rank <= 3 {
            rewards.append(InventoryReward(type: .staminaPotion, amount: 1))
        }
        if rank == 1 {
            rewards.append(InventoryReward(type: .boostTicket, amount: 1))
        }

        return rewards
    }

    static func rewards(forDifficulty difficulty: String, rank: Int, isVictory: Bool) -> [InventoryReward] {
        guard isVictory else { return [] }
        return InventoryReward.merged(baseRewards(forDifficulty: difficulty) + bonusRewards(forRank: rank))
    }
}

struct Avatar: Equatable {
    var name: String
    var attack: Int
    var health: Int
    var usedFlag: Int
    var count: Int
}

enum UserInitializationResult: Equatable {
    case created
    case existing
    case failed
}

enum FeedbackPromptPolicy {
    /// 大幅アップデートなどで全員に再度意見を聞くときは、この値を更新する。
    static let currentCampaign = 202608
    static let optOutField = "feedbackPromptOptOutCampaign"
}

class User: Identifiable {
    var id: String
    var userName: String
    var level: Int
    var experience: Int
    var avatars: [[String: Any]]
    var userMoney: Int
    var userHp: Int
    var userAttack: Int
    var userFlag: Int
    var adminFlag: Int
    var rankMatchPoint: Int
    var rank: Int
    var loginCount: Int

    init(id: String, userName: String, level: Int, experience: Int, avatars: [[String: Any]], userMoney: Int, userHp: Int, userAttack: Int, userFlag: Int, adminFlag: Int,rankMatchPoint: Int,rank: Int, loginCount: Int = 0) {
        self.id = id
        self.userName = userName
        self.level = level
        self.experience = experience
        self.avatars = avatars
        self.userMoney = userMoney
        self.userHp = userHp
        self.userAttack = userAttack
        self.userFlag = userFlag
        self.adminFlag = adminFlag
        self.rankMatchPoint = rankMatchPoint
        self.rank = rank
        self.loginCount = loginCount
    }
}

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var experience: Int = 0
    @Published var rankMatchPoint: Int = 0
    @Published var rank: Int = 0
    @Published var level: Int = 1
    @Published var money: Int = 0
    @Published var userFlag: Int = 0
    @Published var userCsFlag: Int = 0
    @Published var userStoryCsFlag: Int = 0
    @Published var adminFlag: Int = 0
    @Published var avatars: [Avatar] = []
    @Published var rankUp: Bool = false
    @Published var rankDown: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var userAvatars: [Avatar] = []
    @Published var rewardFlag: Int = 1
    @Published var story: Int = 0
    private var selectedAvatar: Avatar?
    @Published var loginCount: Int = 0 // 追加: ログイン回数を保持
    @Published var loginBonus: Int = 0  // 追加: 現在のボーナス額を保持
    @Published var usedAvatars: [Avatar] = []
    @Published var usersWithoutAvatars: [User] = []
    @Published var normalGachaTicketCount: Int = 0
    @Published var rareGachaTicketCount: Int = 0
    @Published var mekaGachaTicketCount: Int = 0
    @Published var godGachaTicketCount: Int = 0
    @Published var guardianGachaTicketCount: Int = 0
    @Published var staminaPotionCount: Int = 0
    @Published var boostTicketCount: Int = 0

    private let rewardBoostDuration: TimeInterval = 3600
    private let rewardBoostDateKey = "rewardAcquiredDate"
    private var rewardBoostResetWorkItem: DispatchWorkItem?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var isSigningInAnonymously = false
    private var pendingSignInCompletions: [() -> Void] = []
    private static let maxAnonymousSignInAttempts = 3
    
    init() {
        user = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
    
    static let shared: AuthManager = {
        let instance = AuthManager()
        return instance
    }()
    
    var onLoginCompleted: (() -> Void)?
    var currentUserId: String? {
        if let uid = user?.uid {
            return uid
        }
        // user がまだセットされていない場合は FirebaseAuth 側から取得
        return Auth.auth().currentUser?.uid
    }
    
    
    func saveLastActiveTimeToFirebase(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let lastActiveRef = Database.database().reference()
            .child("storys")
            .child(userId)
            .child("lastActiveTime")
        
        let currentTime = Date().timeIntervalSince1970 // Unixタイムスタンプ

        lastActiveRef.setValue(currentTime) { error, _ in
            if let error = error {
                print("FirebaseへのlastActiveTimeの保存に失敗しました: \(error.localizedDescription)")
                completion(false)
            } else {
                print("FirebaseにlastActiveTimeを保存しました。時刻: \(currentTime)")
                completion(true)
            }
        }
    }

    // Firebaseから最後のアクティブ時刻を取得
    func fetchLastActiveTimeFromFirebase(completion: @escaping (TimeInterval?) -> Void) {
        guard let userId = currentUserId else {
            completion(nil)
            return
        }

        let lastActiveRef = Database.database().reference()
            .child("storys")
            .child(userId)
            .child("lastActiveTime")

        lastActiveRef.observeSingleEvent(of: .value) { snapshot in
            if let lastActiveTimestamp = snapshot.value as? TimeInterval {
                print("FirebaseからlastActiveTimeを取得しました。時刻: \(lastActiveTimestamp)")
                completion(lastActiveTimestamp)
            } else {
                print("FirebaseからlastActiveTimeの取得に失敗しました。デフォルト値を使用します。")
                completion(nil)
            }
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func fetchUserStory() {
        guard let userId = user?.uid else { return }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.child("story").observeSingleEvent(of: .value) { snapshot in
            if let story = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.story = story
                }
            }
        }
    }
    
    func updateStory(story: Int, completion: @escaping (Bool) -> Void) {
            guard let userId = user?.uid else {
                completion(false) // ユーザーIDがnilの場合は失敗
                return
            }

            let userRef = Database.database().reference().child("users").child(userId)
            userRef.child("story").setValue(story) { error, _ in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to update story:", error.localizedDescription)
                        completion(false) // 更新に失敗した場合
                    } else {
                        print("Successfully updated story.")
                        self.story = story // AuthManagerのstoryプロパティを更新
                        completion(true) // 更新に成功した場合
                    }
                }
            }
        }
    
    /// Firebase 上にユーザーが存在しない場合だけ、初期データを一括作成する。
    /// 既存ユーザーの進捗はトランザクション内で保護する。
    func initializeUserIfNeeded(userName: String, completion: @escaping (UserInitializationResult) -> Void) {
        guard let userId = user?.uid else {
            DispatchQueue.main.async { completion(.failed) }
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        let selectedAvatar = Avatar(name: self.selectedAvatar?.name ?? "ネッキー", attack: 20, health: 20, usedFlag: 1, count: 1)
        let avatarKey = userRef.child("avatars").childByAutoId().key ?? UUID().uuidString
        let avatarData: [String: Any] = [
            "name": selectedAvatar.name,
            "attack": selectedAvatar.attack,
            "health": selectedAvatar.health,
            "usedFlag": selectedAvatar.usedFlag,
            "count": selectedAvatar.count
        ]
        let userData: [String: Any] = [
            "userName": userName,
            "userMoney": 300,
            "userHp": 100,
            "userAttack": 20,
            "tutorialNum": 0,
            "userFlag": 0,
            "loginCount": 0,
            "friendPoints": 0,
            "usedAvatarName": selectedAvatar.name,
            "featuredAvatar": [
                "name": selectedAvatar.name,
                "attack": selectedAvatar.attack,
                "health": selectedAvatar.health
            ],
            InventoryItemType.normalGachaTicket.userFieldKey: 0,
            InventoryItemType.rareGachaTicket.userFieldKey: 0,
            InventoryItemType.mekaGachaTicket.userFieldKey: 0,
            InventoryItemType.godGachaTicket.userFieldKey: 0,
            InventoryItemType.staminaPotion.userFieldKey: 0,
            InventoryItemType.boostTicket.userFieldKey: 0,
            "avatars": [avatarKey: avatarData]
        ]

        userRef.runTransactionBlock({ currentData in
            guard currentData.value == nil || currentData.value is NSNull else {
                return TransactionResult.abort()
            }

            currentData.value = userData
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { error, committed, snapshot in
            DispatchQueue.main.async {
                if let error {
                    print("Failed to initialize user:", error.localizedDescription)
                    completion(.failed)
                } else if committed {
                    print("Successfully initialized user.")
                    completion(.created)
                } else if snapshot?.exists() == true {
                    completion(.existing)
                } else {
                    completion(.failed)
                }
            }
        }, withLocalEvents: false)
    }

    func saveUserToDatabase(userName: String, completion: @escaping (Bool) -> Void) {
        initializeUserIfNeeded(userName: userName) { result in
            completion(result != .failed)
        }
    }
    
    func fetchUsedAvatars(completion: @escaping ([Avatar]) -> Void) {
            guard let userId = user?.uid else {
                completion([])
                return
            }
            
            let avatarsRef = Database.database().reference()
                .child("users")
                .child(userId)
                .child("avatars")
            
            // usedFlag が 1 のアバターのみを取得するクエリ
            let query = avatarsRef.queryOrdered(byChild: "usedFlag").queryEqual(toValue: 1)
            
            query.observeSingleEvent(of: .value) { snapshot in
                var usedAvatars: [Avatar] = []
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let avatarData = childSnapshot.value as? [String: Any],
                       let name = avatarData["name"] as? String,
                       let attack = avatarData["attack"] as? Int,
                       let health = avatarData["health"] as? Int,
                       let usedFlag = avatarData["usedFlag"] as? Int,
                       let count = avatarData["count"] as? Int {
                        let avatar = Avatar(name: name, attack: attack, health: health, usedFlag: usedFlag, count: count)
                        usedAvatars.append(avatar)
                    }
                }
                DispatchQueue.main.async {
                    self.usedAvatars = usedAvatars
                    completion(usedAvatars)
                }
            }
        }
    
    func fetchUserInfo(completion: @escaping (String?, [[String: Any]]?, Int?, Int?, Int?, Int?) -> Void) {
            guard let userId = currentUserId else {
                DispatchQueue.main.async {
                    completion(nil, nil, nil, nil, nil, nil)
                }
                return
            }
            let userRef = Database.database().reference().child("users").child(userId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any],
                   let userName = data["userName"] as? String,
                   let avatarsData = data["avatars"] as? [String:[String: Any]],
                   let userMoney = data["userMoney"] as? Int,
                   let userHp = data["userHp"] as? Int,
                   let userAttack = data["userAttack"] as? Int,
                   let tutorialNum = data["tutorialNum"] as? Int {  // 追加
                    var filteredAvatars: [[String: Any]] = []
                    for (_, avatarData) in avatarsData {
                        if avatarData["usedFlag"] as? Int == 1 {
                            filteredAvatars.append(avatarData)
//                            print("filteredAvatars:\(filteredAvatars)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion(userName, filteredAvatars, userMoney, userHp, userAttack, tutorialNum)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, nil, nil, nil, nil, nil)
                    }
                }
            }, withCancel: { error in
                print("Failed to fetch user info: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, nil, nil, nil, nil, nil)
                }
            })
        }
    
    func fetchCurrentUserAdminFlag() {
        guard let userId = user?.uid else {
            print("User is not logged in")
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self, let data = snapshot.value as? [String: Any], let adminFlag = data["adminFlag"] as? Int else {
                print("Failed to fetch user data or adminFlag is missing")
                return
            }
            DispatchQueue.main.async {
                self.adminFlag = adminFlag
                print("Updated adminFlag to \(adminFlag)")
            }
        })
    }


    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateUserFlag(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateUserName(userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userName": userName]
        
        userRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("Failed to update userName: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully updated userName.")
                completion(true)
            }
        }
    }
    
    func updateUserCsFlag(userId: String, userCsFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userCsFlag": userCsFlag]
        print(updates)
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func fetchFeedbackPromptOptOutCampaign(completion: @escaping (Int?) -> Void) {
        guard let userId = currentUserId else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let campaignRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child(FeedbackPromptPolicy.optOutField)

        campaignRef.observeSingleEvent(of: .value, with: { snapshot in
            let campaign: Int
            if let value = snapshot.value as? Int {
                campaign = value
            } else if let value = snapshot.value as? NSNumber {
                campaign = value.intValue
            } else {
                campaign = 0
            }

            DispatchQueue.main.async {
                completion(campaign)
            }
        }, withCancel: { error in
            print("Failed to fetch feedback prompt opt-out campaign: \(error.localizedDescription)")
            DispatchQueue.main.async { completion(nil) }
        })
    }

    func optOutOfCurrentFeedbackPrompts(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        let updates = [FeedbackPromptPolicy.optOutField: FeedbackPromptPolicy.currentCampaign]
        userRef.updateChildValues(updates) { error, _ in
            DispatchQueue.main.async {
                if let error {
                    print("Failed to save feedback prompt opt-out campaign: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func updateUserStoryCsFlag(userId: String, userCsFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userStoryCsFlag": userCsFlag]
        print(updates)
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateContact(userId: String, newContact: String, completion: @escaping (Bool) -> Void) {
        // contactテーブルの下の指定されたuserIdの参照を取得
        let contactRef = Database.database().reference().child("contacts").child(userId)
        
        // まず現在のcontactの値を読み取る
        contactRef.observeSingleEvent(of: .value, with: { snapshot in
            // 既存の問い合わせ内容を保持する変数を準備
            var contacts: [String] = []
            
            // 現在の問い合わせ内容がある場合、それを読み込む
            if let currentContacts = snapshot.value as? [String] {
                contacts = currentContacts
            }
            
            // 新しい問い合わせ内容をリストに追加
            contacts.append(newContact)
            
            // データベースを更新する
            contactRef.setValue(contacts, withCompletionBlock: { error, _ in
                if let error = error {
                    print("Error updating contact: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func fetchAvatars(completion: @escaping () -> Void) {
        guard let userId = currentUserId else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
        userRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            var newAvatars: [Avatar] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   let attack = avatarData["attack"] as? Int,
                   let health = avatarData["health"] as? Int,
                   let usedFlag = avatarData["usedFlag"] as? Int,
                   let count = avatarData["count"] as? Int {
                    let avatar = Avatar(name: name, attack: attack, health: health, usedFlag: usedFlag, count: count)
                    newAvatars.append(avatar)
                }
            }
            DispatchQueue.main.async {
                self.avatars = newAvatars
                completion()
            }
        }, withCancel: { error in
            print("Failed to fetch avatars: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    func updateUsedFlag(for avatar: Avatar, to newValue: Int) -> Avatar {
        return Avatar(name: avatar.name, attack: avatar.attack, health: avatar.health, usedFlag: newValue, count: avatar.count)
    }
    
    func switchAvatar(to newAvatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilなので、失敗としてfalseを返します。
            return
        }
        
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                let avatarKey = childSnapshot.key
                let avatarRef = avatarsRef.child(avatarKey)
                avatarRef.updateChildValues(["usedFlag": 0])
            }
            
            if let avatarKey = snapshot.children.allObjects.first(where: { (child) -> Bool in
                guard let childSnapshot = child as? DataSnapshot,
                      let avatarData = childSnapshot.value as? [String: Any],
                      let name = avatarData["name"] as? String else { return false }
                return name == newAvatar.name
            }) as? DataSnapshot {
                let avatarRef = avatarsRef.child(avatarKey.key)
                avatarRef.updateChildValues(["usedFlag": 1]) { (error, ref) in
                    if let error = error {
                        print("Failed to update avatar: \(error.localizedDescription)")
                        completion(false) // 更新に失敗したので、falseを返します。
                    } else {
                        print("Successfully updated avatar.")
                        let userRef = Database.database().reference().child("users").child(userId)
                        let profileUpdates: [String: Any] = [
                            "usedAvatarName": newAvatar.name,
                            "featuredAvatar": [
                                "name": newAvatar.name,
                                "attack": newAvatar.attack,
                                "health": newAvatar.health
                            ]
                        ]
                        userRef.updateChildValues(profileUpdates) { profileError, _ in
                            guard profileError == nil else {
                                completion(false)
                                return
                            }
                            GuildManager.shared.updateMyAvatarName(newAvatar.name)
                            self.fetchAvatars {
                                completion(true) // 更新に成功したので、trueを返します。
                            }
                        }
                    }
                }
            } else {
                completion(false) // 新しいアバターが見つからなかったので、falseを返します。
            }
        }
    }
    
    func addRankMatchPoints(for userId: String, points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                // 現在のrankMatchPointとrankを取得、またはデフォルト値として100と1を設定
                var currentRankMatchPoints = data["rankMatchPoint"] as? Int ?? 100
                var currentRank = data["rank"] as? Int ?? 1
                
                // 100の位が変わるかどうかをチェック
                let previousHundred = currentRankMatchPoints / 100
                currentRankMatchPoints += points
                let newHundred = currentRankMatchPoints / 100

                if newHundred > previousHundred {
                    // 100の位が増加した場合、rankをインクリメント
                    currentRank += 1
                    self.rankUp = true
                }

                // 更新されたデータでデータベースを更新
                let updatedData: [String: Any] = ["rankMatchPoint": currentRankMatchPoints, "rank": currentRank]
                userRef.updateChildValues(updatedData) { (error, ref) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }

    
    func subtractRankMatchPoints(for userId: String, points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                // 現在のrankMatchPointとrankを取得、またはデフォルト値として100と1を設定
                var currentRankMatchPoints = data["rankMatchPoint"] as? Int ?? 100
                var currentRank = data["rank"] as? Int ?? 1

                // 100の位が変わるかどうかをチェック
                let previousHundred = currentRankMatchPoints / 100
                currentRankMatchPoints -= points // ポイントを減算
                let newHundred = currentRankMatchPoints / 100

                if newHundred < previousHundred {
                    // 100の位が減少した場合、rankをデクリメント（ただし、rankが1より小さくならないようにする）
                    currentRank = max(currentRank - 1, 1)
                    self.rankDown = true
                }

                // 更新されたデータでデータベースを更新
                let updatedData: [String: Any] = ["rankMatchPoint": currentRankMatchPoints, "rank": currentRank]
                userRef.updateChildValues(updatedData) { (error, _) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }

    
    func addExperience(points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        guard let userId = user?.uid else {
            onFailure(nil)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot, errorString) in
            if let errorString = errorString {
                onFailure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            if let data = snapshot.value as? [String: Any] {
                var currentExperience = data["experience"] as? Int ?? 0
                var currentLevel = data["level"] as? Int ?? 1

                currentExperience += points

                while currentExperience >= currentLevel * 100 {
                    currentExperience -= currentLevel * 100
                    currentLevel += 1
                    self.didLevelUp = true
                    self.updateStatsUponLevelUp()

                    if currentLevel == 3 {
                        // レベル3に達した場合、称号を保存
                        self.saveTitleForUser(userId: userId, title: "レベル３")
                    } else if currentLevel == 5 {
                        self.saveTitleForUser(userId: userId, title: "レベル５")
                    } else if currentLevel == 10 {
                        self.saveTitleForUser(userId: userId, title: "レベル10")
                    }
                }

                let updatedData: [String: Any] = ["experience": currentExperience, "level": currentLevel]
                userRef.updateChildValues(updatedData) { (error, ref) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        self.experience = currentExperience
                        self.level = currentLevel
                        GuildManager.shared.recordExperience(points)
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }
    
    func calculateLevel(experience: Int) -> Int {
        return experience / 100 + 1
    }

    /// Read level and companions together so story battles never start with a partial profile.
    func fetchAdventurePlayerStats(completion: @escaping (AdventurePlayerStats?) -> Void) {
        guard let userId = currentUserId else { completion(nil); return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let data = snapshot.value as? [String: Any] else { completion(nil); return }
            let level = max(1, data["level"] as? Int ?? 1)
            let avatarData = data["avatars"] as? [String: [String: Any]] ?? [:]
            let avatars = avatarData.keys.sorted().compactMap { key -> Avatar? in
                guard let item = avatarData[key], let name = item["name"] as? String,
                      let attack = item["attack"] as? Int, let health = item["health"] as? Int else { return nil }
                return Avatar(name: name, attack: attack, health: health,
                              usedFlag: item["usedFlag"] as? Int ?? 0, count: item["count"] as? Int ?? 1)
            }
            let companion = avatars.first { $0.usedFlag == 1 }
            let stats = AdventurePlayerStats(level: level, companionName: companion?.name,
                                             companionHP: companion?.health ?? 0,
                                             companionAttack: companion?.attack ?? 0)
            DispatchQueue.main.async {
                guard self?.currentUserId == userId else { completion(nil); return }
                self?.level = level
                self?.experience = data["experience"] as? Int ?? 0
                self?.avatars = avatars
                completion(stats)
            }
        }, withCancel: { _ in DispatchQueue.main.async { completion(nil) } })
    }

    func fetchUserExperienceAndLevel() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.experience = data["experience"] as? Int ?? 0
                self.level = data["level"] as? Int ?? 1
            }
        }
    }
    
    func fetchUserRankMatchPoint() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            var rankMatchPoint = 100 // デフォルト値を100に設定
            var rank = 1
            
            if let data = snapshot.value as? [String: Any] {
                // rankMatchPointが存在する場合は取得した値を使用
                if let existingRankMatchPoint = data["rankMatchPoint"] as? Int,
                   let existingRank = data["rank"] as? Int{
                    rankMatchPoint = existingRankMatchPoint
                    rank = existingRank
                    self.rankMatchPoint = existingRankMatchPoint
                    self.rank = existingRank
                } else {
                    // rankMatchPointが存在しない場合は、デフォルト値でデータベースを更新
                    userRef.updateChildValues(["rankMatchPoint": rankMatchPoint,"rank": rank])
                    self.rankMatchPoint = 100
                    self.rank = 1
                }
            }
            
            // rankMatchPointを使用する処理（必要に応じて）
            print("rankMatchPoint: \(self.rank)")
        }
    }

    
    func fetchUserRewardFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.rewardFlag = data["rewardFlag"] as? Int ?? 1
            }
            self.syncRewardBoostState()
        }
    }

    func inventoryCount(for type: InventoryItemType) -> Int {
        switch type {
        case .normalGachaTicket:
            return normalGachaTicketCount
        case .rareGachaTicket:
            return rareGachaTicketCount
        case .mekaGachaTicket:
            return mekaGachaTicketCount
        case .godGachaTicket:
            return godGachaTicketCount
        case .guardianGachaTicket:
            return guardianGachaTicketCount
        case .staminaPotion:
            return staminaPotionCount
        case .boostTicket:
            return boostTicketCount
        }
    }

    private func setInventoryCount(_ count: Int, for type: InventoryItemType) {
        let safeCount = max(0, count)
        switch type {
        case .normalGachaTicket:
            normalGachaTicketCount = safeCount
        case .rareGachaTicket:
            rareGachaTicketCount = safeCount
        case .mekaGachaTicket:
            mekaGachaTicketCount = safeCount
        case .godGachaTicket:
            godGachaTicketCount = safeCount
        case .guardianGachaTicket:
            guardianGachaTicketCount = safeCount
        case .staminaPotion:
            staminaPotionCount = safeCount
        case .boostTicket:
            boostTicketCount = safeCount
        }
    }

    private func intValue(from value: Any?) -> Int {
        if let intValue = value as? Int {
            return intValue
        }
        if let numberValue = value as? NSNumber {
            return numberValue.intValue
        }
        if let doubleValue = value as? Double {
            return Int(doubleValue)
        }
        if let stringValue = value as? String, let intValue = Int(stringValue) {
            return intValue
        }
        return 0
    }

    func fetchInventory(completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            let data = snapshot.value as? [String: Any] ?? [:]
            DispatchQueue.main.async {
                self.normalGachaTicketCount = self.intValue(from: data[InventoryItemType.normalGachaTicket.userFieldKey])
                self.rareGachaTicketCount = self.intValue(from: data[InventoryItemType.rareGachaTicket.userFieldKey])
                self.mekaGachaTicketCount = self.intValue(from: data[InventoryItemType.mekaGachaTicket.userFieldKey])
                self.godGachaTicketCount = self.intValue(from: data[InventoryItemType.godGachaTicket.userFieldKey])
                self.guardianGachaTicketCount = self.intValue(from: data[InventoryItemType.guardianGachaTicket.userFieldKey])
                self.staminaPotionCount = self.intValue(from: data[InventoryItemType.staminaPotion.userFieldKey])
                self.boostTicketCount = self.intValue(from: data[InventoryItemType.boostTicket.userFieldKey])
            }
            completion?(true)
        }
    }

    func addItem(_ type: InventoryItemType, amount: Int = 1, completion: ((Bool) -> Void)? = nil) {
        guard amount > 0 else {
            completion?(false)
            return
        }
        guard let userId = currentUserId else {
            completion?(false)
            return
        }

        let itemRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child(type.userFieldKey)

        itemRef.runTransactionBlock { currentData in
            let current = self.intValue(from: currentData.value)
            currentData.value = current + amount
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            guard error == nil, committed else {
                DispatchQueue.main.async {
                    completion?(false)
                }
                return
            }
            DispatchQueue.main.async {
                self.setInventoryCount(self.intValue(from: snapshot?.value), for: type)
                completion?(true)
            }
        }
    }

    func addItems(_ rewards: [InventoryReward], completion: ((Bool) -> Void)? = nil) {
        let validRewards = rewards.filter { $0.amount > 0 }
        guard !validRewards.isEmpty else {
            completion?(true)
            return
        }

        let group = DispatchGroup()
        var allSucceeded = true

        for reward in validRewards {
            group.enter()
            addItem(reward.type, amount: reward.amount) { success in
                allSucceeded = allSucceeded && success
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion?(allSucceeded)
        }
    }

    func consumeItem(_ type: InventoryItemType, amount: Int = 1, completion: @escaping (Bool) -> Void) {
        guard amount > 0 else {
            completion(false)
            return
        }
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let itemRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child(type.userFieldKey)

        itemRef.observeSingleEvent(of: .value) { snapshot in
            let remoteCount = self.intValue(from: snapshot.value)
            let localCount = self.inventoryCount(for: type)
            let currentCount = max(remoteCount, localCount)

            guard currentCount >= amount else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            let newCount = currentCount - amount
            itemRef.setValue(newCount) { error, _ in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.setInventoryCount(newCount, for: type)
                    completion(true)
                }
            }
        }
    }

    func useStaminaPotion(recoveryAmount: Int = 30, completion: @escaping (Bool) -> Void) {
        consumeItem(.staminaPotion) { success in
            guard success else {
                completion(false)
                return
            }
            PositionViewModel.shared.recoverStamina(by: recoveryAmount)
            completion(true)
        }
    }

    func useBoostTicket(completion: @escaping (Bool) -> Void) {
        consumeItem(.boostTicket) { success in
            guard success else {
                completion(false)
                return
            }
            self.activateOneHourBoost(completion: completion)
        }
    }

    func activateOneHourBoost(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let activatedAt = Date()
        UserDefaults.standard.set(activatedAt, forKey: rewardBoostDateKey)
        updateRewardFlag(userId: userId, userFlag: 2) { success in
            guard success else {
                completion(false)
                return
            }
            DispatchQueue.main.async {
                self.rewardFlag = 2
            }
            self.scheduleRewardBoostReset(from: activatedAt)
            completion(true)
        }
    }

    func syncRewardBoostState() {
        rewardBoostResetWorkItem?.cancel()

        guard let userId = currentUserId else {
            rewardFlag = 1
            return
        }

        guard let activatedAt = UserDefaults.standard.object(forKey: rewardBoostDateKey) as? Date else {
            return
        }

        let elapsed = Date().timeIntervalSince(activatedAt)
        if elapsed >= rewardBoostDuration {
            UserDefaults.standard.removeObject(forKey: rewardBoostDateKey)
            updateRewardFlag(userId: userId, userFlag: 1)
            return
        }

        rewardFlag = 2
        scheduleRewardBoostReset(from: activatedAt)
    }

    private func scheduleRewardBoostReset(from activatedAt: Date) {
        rewardBoostResetWorkItem?.cancel()

        let remaining = max(0, rewardBoostDuration - Date().timeIntervalSince(activatedAt))
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, let userId = self.currentUserId else { return }
            UserDefaults.standard.removeObject(forKey: self.rewardBoostDateKey)
            self.updateRewardFlag(userId: userId, userFlag: 1)
        }

        rewardBoostResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining, execute: workItem)
    }
    
    func fetchUserFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
//                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userFlag = data["userFlag"] as? Int ?? 0
                print("self.userFlag:\(self.userFlag)")
            }
        }
    }
    
    func fetchUserCsFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
//                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userCsFlag = data["userCsFlag"] as? Int ?? 0
            }
        }
    }
    
    func fetchUserStoryCsFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
//                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userStoryCsFlag = data["userStoryCsFlag"] as? Int ?? 0
            }
        }
    }
    
    /// 複数のゲーム内報酬をキー単位で一度だけ付与する。
    func grantRewardBundle(
        idempotencyKey: String,
        coinAmount: Int,
        itemRewards: [InventoryReward],
        completion: @escaping (Bool) -> Void
    ) {
        guard coinAmount >= 0, let userId = currentUserId else {
            completion(false)
            return
        }

        let rewards = InventoryReward.merged(itemRewards.filter { $0.amount > 0 })
        let userRef = Database.database().reference().child("users").child(userId)
        let receiptKey = firebaseSafeKey(idempotencyKey)

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists(),
                  let fetchedUserData = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            var hasUsedFetchedUserData = false
            userRef.runTransactionBlock { currentData in
                var userData: [String: Any]
                if let currentUserData = currentData.value as? [String: Any] {
                    userData = currentUserData
                } else if !hasUsedFetchedUserData {
                    // The first transaction callback can run before Firebase has
                    // populated its local cache. Seed it from the server snapshot;
                    // retries will still receive the authoritative value.
                    userData = fetchedUserData
                    hasUsedFetchedUserData = true
                } else {
                    return TransactionResult.abort()
                }

                var receipts = userData["rewardGrantReceipts"] as? [String: Any] ?? [:]
                if receipts[receiptKey] != nil {
                    // Preserve the fetched snapshot when the initial local
                    // transaction cache is empty but this reward already exists.
                    currentData.value = userData
                    return TransactionResult.success(withValue: currentData)
                }

                userData["userMoney"] = self.intValue(from: userData["userMoney"]) + coinAmount
                for reward in rewards {
                    userData[reward.type.userFieldKey] =
                        self.intValue(from: userData[reward.type.userFieldKey]) + reward.amount
                }
                receipts[receiptKey] = [
                    "coinAmount": coinAmount,
                    "processedAt": Int64(Date().timeIntervalSince1970 * 1_000)
                ]
                userData["rewardGrantReceipts"] = receipts
                currentData.value = userData
                return TransactionResult.success(withValue: currentData)
            } andCompletionBlock: { error, committed, snapshot in
                DispatchQueue.main.async {
                    guard error == nil,
                          committed,
                          let userData = snapshot?.value as? [String: Any] else {
                        completion(false)
                        return
                    }
                    // The request belongs to the captured account even if the
                    // player signs out while Firebase is committing its receipt.
                    if self.currentUserId == userId {
                        self.money = self.intValue(from: userData["userMoney"])
                        for reward in rewards {
                            self.setInventoryCount(
                                self.intValue(from: userData[reward.type.userFieldKey]),
                                for: reward.type
                            )
                        }
                    }
                    completion(true)
                }
            }
        }, withCancel: { _ in
            DispatchQueue.main.async { completion(false) }
        })
    }

    private func firebaseSafeKey(_ value: String) -> String {
        Data(value.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }


    /// StoreKit の消耗型購入をトランザクションID単位で一度だけ反映する。
    func grantPurchasedCoins(
        transactionId: UInt64,
        productId: String,
        amount: Int,
        completion: @escaping (Bool) -> Void
    ) {
        guard amount > 0, let userId = currentUserId else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        let receiptKey = String(transactionId)

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            userRef.runTransactionBlock { currentData in
                guard var userData = currentData.value as? [String: Any] else {
                    return TransactionResult.abort()
                }

                var receipts = userData["processedCoinTransactions"] as? [String: Any] ?? [:]
                if receipts[receiptKey] != nil {
                    return TransactionResult.success(withValue: currentData)
                }

                let currentMoney: Int
                if let value = userData["userMoney"] as? Int {
                    currentMoney = value
                } else if let value = userData["userMoney"] as? NSNumber {
                    currentMoney = value.intValue
                } else if let value = userData["userMoney"] as? String, let parsed = Int(value) {
                    currentMoney = parsed
                } else {
                    currentMoney = 0
                }

                userData["userMoney"] = currentMoney + amount
                receipts[receiptKey] = [
                    "productId": productId,
                    "amount": amount,
                    "processedAt": Int64(Date().timeIntervalSince1970 * 1_000)
                ]
                userData["processedCoinTransactions"] = receipts
                currentData.value = userData
                return TransactionResult.success(withValue: currentData)
            } andCompletionBlock: { error, committed, snapshot in
                DispatchQueue.main.async {
                    guard error == nil,
                          committed,
                          let userData = snapshot?.value as? [String: Any] else {
                        completion(false)
                        return
                    }
                    if let value = userData["userMoney"] as? Int {
                        self.money = value
                    } else if let value = userData["userMoney"] as? NSNumber {
                        self.money = value.intValue
                    }
                    completion(true)
                }
            }
        }, withCancel: { _ in
            DispatchQueue.main.async { completion(false) }
        })
    }


    func addMoney(amount: Int) {
            guard let userId = user?.uid else { return }
            print("addMoney")
            let userRef = Database.database().reference().child("users").child(userId)
            
            // 現在の所持金を取得
            userRef.observeSingleEvent(of: .value) { (snapshot) in
                if let data = snapshot.value as? [String: Any] {
                    let currentMoney = data["userMoney"] as? Int ?? 0
                    
                    // 新しく獲得するお金を加える
                    let newMoney = currentMoney + amount
                    
                    self.money = newMoney
                    
                    // 更新された所持金をデータベースに保存
                    let userData: [String: Any] = ["userMoney": self.money]
                    userRef.updateChildValues(userData)
                }
            }
        }
    
    func saveLastClickedDate(userId: String, completion: @escaping (Bool) -> Void) {
            let ref = Database.database().reference().child("users").child(userId)
            ref.updateChildValues(["lastClickedDate": "\(Date())"]) { (error, _) in
                if let error = error {
                    print("Error saving last clicked date: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }

    func fetchLastClickedDate(userId: String, completion: @escaping (Date?) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.child("lastClickedDate").observeSingleEvent(of: .value) { (snapshot) in
            
            // DateFormatterのインスタンスを作成
            let dateFormatter = DateFormatter()
            
            // フォーマットを設定
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            // このフォーマッターを使用して、文字列から日付に変換
            if let dateString = snapshot.value as? String, let date = dateFormatter.date(from: dateString) {
                completion(date)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 現在の日時をユーザーの最後のログイン日時として保存する
    func saveLastLoginDate(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let ref = Database.database().reference().child("users").child(userId)
        let currentTimestamp = Date().timeIntervalSince1970
        ref.updateChildValues(["lastLoginDate": currentTimestamp]) { (error, _) in
            if let error = error {
                print("最後のログイン日時の保存に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                print("最後のログイン日時を正常に保存しました。")
                completion(true)
            }
        }
    }

    func addLoginMoney(amount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在の所持金を取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any],
               var currentMoney = data["userMoney"] as? Int {
                // 新しい金額を計算
                currentMoney += amount
                
                // データベースを更新
                userRef.updateChildValues(["userMoney": currentMoney]) { error, _ in
                    if let error = error {
                        print("所持金の更新に失敗: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("所持金を正常に更新しました。新しい金額: \(currentMoney)")
                        completion(true)
                    }
                }
            } else {
                // userMoney が存在しない場合、新しく設定
                userRef.updateChildValues(["userMoney": amount]) { error, _ in
                    if let error = error {
                        print("所持金の初期設定に失敗: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("所持金を初期設定しました。金額: \(amount)")
                        completion(true)
                    }
                }
            }
        }
    }
    
    /// loginCount を取得する
    func fetchLoginCount(completion: @escaping (Int) -> Void) {
        guard let userId = currentUserId else {
            completion(0)
            return
        }

        let loginCountRef = Database.database().reference().child("users").child(userId).child("loginCount")
        loginCountRef.observeSingleEvent(of: .value) { snapshot in
            let count = snapshot.value as? Int ?? 0
            completion(count)
        }
    }

    /// loginCount をインクリメントする
    func incrementLoginCount(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let loginCountRef = Database.database().reference().child("users").child(userId).child("loginCount")
        loginCountRef.runTransactionBlock { currentData in
            var value = currentData.value as? Int ?? 0
            value += 1
            currentData.value = value > 5 ? 1 : value
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print("loginCount のインクリメントに失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                let updatedCount = snapshot?.value as? Int ?? 1
                DispatchQueue.main.async {
                    self.loginCount = updatedCount
                }
                print("loginCount を更新しました。新しい値: \(updatedCount)")
                completion(true)
            }
        }
    }
    
    func updateStatsUponLevelUp() {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        
        // レベルに応じて攻撃力とHPを計算
        let newAttack = 20 + (level - 1) * 2
        let newHp = 100 + (level - 1) * 10
        
        // データベースに新しい攻撃力とHPを保存
        let updatedStats: [String: Any] = ["userAttack": newAttack, "userHp": newHp]
        userRef.updateChildValues(updatedStats) { (error, ref) in
            if let error = error {
                print("Failed to update stats:", error.localizedDescription)
                return
            }
            print("Successfully updated stats.")
        }
    }
    
    /// ログインボーナスをチェックし、付与する
    func checkAndGrantLoginBonus(completion: @escaping (Bool) -> Void) {
        fetchLastLoginDate { lastLoginDate in
            let now = Date()
            if let lastLogin = lastLoginDate {
                let days = self.daysBetween(lastLogin, now)
                var newLoginCount = 1
                if days == 1 {
                    // 連続ログイン
                    self.fetchLoginCount { currentCount in
                        newLoginCount = currentCount + 1
                        // 必要に応じて最大値を設定（例: 5日目まで）
                        if newLoginCount > 5 {
                            newLoginCount = 1
                        }
                        self.loginCount = newLoginCount
                        let bonus = self.getBonusAmount(for: newLoginCount)
                        self.loginBonus = bonus
                        // ボーナスを付与
                        self.grantLoginBonus(amount: bonus) { success in
                            if success {
                                // 最終ログイン日時を保存
                                self.saveLastLoginDate { saveSuccess in
                                    if saveSuccess {
                                        // loginCount をデータベースに更新
                                        self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                            if updateSuccess {
                                                completion(true)
                                            } else {
                                                completion(false)
                                            }
                                        }
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                completion(false)
                            }
                        }
                    }
                } else if days > 1 {
                    // 連続していないログイン（リセット）
                    newLoginCount = 1
                    self.loginCount = newLoginCount
                    let bonus = self.getBonusAmount(for: newLoginCount)
                    self.loginBonus = bonus
                    // ボーナスを付与
                    self.grantLoginBonus(amount: bonus) { success in
                        if success {
                            // 最終ログイン日時を保存
                            self.saveLastLoginDate { saveSuccess in
                                if saveSuccess {
                                    // loginCount をデータベースに更新
                                    self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                        if updateSuccess {
                                            completion(true)
                                        } else {
                                            completion(false)
                                        }
                                    }
                                } else {
                                    completion(false)
                                }
                            }
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    // 同日に複数回ログインした場合はボーナスを付与しない
                    completion(false)
                }
            } else {
                // 初回ログイン
                let newLoginCount = 1
                self.loginCount = newLoginCount
                let bonus = self.getBonusAmount(for: newLoginCount)
                self.loginBonus = bonus
                self.grantLoginBonus(amount: bonus) { success in
                    if success {
                        // 最終ログイン日時を保存
                        self.saveLastLoginDate { saveSuccess in
                            if saveSuccess {
                                // loginCount をデータベースに更新
                                self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                    if updateSuccess {
                                        completion(true)
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                completion(false)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    /// loginCount に基づいてボーナス額を決定
    func getBonusAmount(for count: Int) -> Int {
        // 例として、1日目から10日目まで異なるボーナス額を設定
        let bonuses = [100, 300, 500, 800, 1000]
        return count <= 5 ? bonuses[count - 1] : 100
    }
    
    func updateLoginCount(to newCount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["loginCount": newCount]) { error, _ in
            if let error = error {
                print("loginCount の更新に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.loginCount = newCount
                }
                self.awardLoginStreakTitles(for: userId, streakCount: newCount)
                print("loginCount を \(newCount) に更新しました。")
                completion(true)
            }
        }
    }

    func decreaseUserMoney(by amount: Int = 300, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在のuserMoneyを取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                var currentMoney = data["userMoney"] as? Int ?? 0
                
                // userMoneyからamountを引く
                currentMoney -= amount
                
                // 新しいuserMoneyの値をデータベースに保存
                let userData: [String: Any] = ["userMoney": currentMoney]
                userRef.updateChildValues(userData) { (error, ref) in
                    if let error = error {
                        print("Failed to update userMoney:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully updated userMoney.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func decreaseRareUserMoney(by amount: Int = 600, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在のuserMoneyを取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                var currentMoney = data["userMoney"] as? Int ?? 0
                
                // userMoneyからamountを引く
                currentMoney -= amount
                
                // 新しいuserMoneyの値をデータベースに保存
                let userData: [String: Any] = ["userMoney": currentMoney]
                userRef.updateChildValues(userData) { (error, ref) in
                    if let error = error {
                        print("Failed to update userMoney:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully updated userMoney.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func getUserMoney(completion: @escaping (Int) -> Void) {
        guard let userId = currentUserId else {
            completion(0)   // 少なくとも 0 で返しておく
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let currentMoney: Int
                if let intValue = data["userMoney"] as? Int {
                    currentMoney = intValue
                } else if let numberValue = data["userMoney"] as? NSNumber {
                    currentMoney = numberValue.intValue
                } else {
                    currentMoney = 0
                }
                completion(currentMoney)
            }
        }
    }
    
    func updateUserFlag(userId: String, userFlag: Int) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["userFlag": userFlag]) { error, _ in
            if let error = error {
                print("Error updating userFlag: \(error)")
            } else {
                print("userFlag successfully updated")
            }
        }
    }
    
    func updateRewardFlag(userId: String, userFlag: Int, completion: ((Bool) -> Void)? = nil) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["rewardFlag": userFlag]) { error, _ in
            if let error = error {
                print("Error updating rewardFlag: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            } else {
                print("userFlag successfully updated")
                DispatchQueue.main.async {
                    self.rewardFlag = userFlag
                    completion?(true)
                }
            }
        }
    }
    
    func saveElapsedTime(category: String, elapsedTime: TimeInterval, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // ユーザーIDがnilの場合、失敗としてfalseを返す
            return
        }

        // ユーザーの経過時間データの参照を作成
        let userRef = Database.database().reference().child("users").child(userId)

        // 経過時間を保存する辞書を作成
        let elapsedTimeData: [String: Any] = ["タイム": elapsedTime]

        // カテゴリに応じて保存する場所を指定
        userRef.child(category).setValue(elapsedTimeData) { (error, ref) in
            if let error = error {
                print("Failed to save elapsed time:", error.localizedDescription)
                completion(false) // 保存に失敗した場合、falseを返す
                return
            }
            print("Successfully saved elapsed time.")
            completion(true) // 保存に成功した場合、trueを返す
        }
    }
    
    struct QuizTotal {
        var totalAnswers: Int
    }
    
    func decreaseUserMoneyBy(amount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let currentMoney: Int
            if let intValue = data["userMoney"] as? Int {
                currentMoney = intValue
            } else if let numberValue = data["userMoney"] as? NSNumber {
                currentMoney = numberValue.intValue
            } else if let doubleValue = data["userMoney"] as? Double {
                currentMoney = Int(doubleValue)
            } else if let stringValue = data["userMoney"] as? String, let intValue = Int(stringValue) {
                currentMoney = intValue
            } else {
                completion(false)
                return
            }
            
            guard currentMoney >= amount else {
                completion(false)
                return
            }
            
            userRef.updateChildValues(["userMoney": currentMoney - amount]) { error, _ in
                completion(error == nil)
            }
        }
    }
    
    func decreaseGodUserMoney(completion: @escaping (Bool) -> Void) {
        decreaseUserMoneyBy(amount: 1000, completion: completion)
    }

    func decreaseGuardianUserMoney(completion: @escaping (Bool) -> Void) {
        decreaseUserMoneyBy(amount: 1000, completion: completion)
    }
    
    func fetchTotalAnswersData(userId: String, completion: @escaping ([QuizLevel: QuizTotal], Int) -> Void) {
        let answersRef = Database.database().reference().child("answers").child(userId)

        answersRef.observeSingleEvent(of: .value, with: { snapshot in
            var totalData = [QuizLevel: QuizTotal]()
            var totalAnswers = 0 // 全体の回答数の合計を格納する変数

            // 各クイズレベルでループ
            for level in QuizLevel.allCases {
                var totalAnswersForLevel = 0

                // 指定されたレベルの日付別データにアクセス
                let levelSnapshot = snapshot.childSnapshot(forPath: level.description)
                if levelSnapshot.exists() {
                    for dateChild in levelSnapshot.children {
                        if let dateSnapshot = dateChild as? DataSnapshot,
                           let answersCount = dateSnapshot.value as? Int {
                            totalAnswersForLevel += answersCount
                        }
                    }
                }

                totalData[level] = QuizTotal(totalAnswers: totalAnswersForLevel)
                totalAnswers += totalAnswersForLevel // 合計回答数に加算
            }

//            print("totalData:\(totalData)")
//            print("Total Answers for all levels: \(totalAnswers)") // 全レベルの合計回答数を出力
            completion(totalData, totalAnswers) // コンプリーションハンドラーに合計回答数も渡す
        })
    }

}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: { 
                        generateHapticFeedback()
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn(){}
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}

extension AuthManager {
    /// 匿名サインインを行う。通信エラーなどで失敗しても数回まで再試行し、
    /// 同時に複数回呼ばれた場合は1回のサインインにまとめる。completion はメインスレッドで呼ぶ。
    func anonymousSignIn(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if let currentUser = Auth.auth().currentUser {
                self.user = currentUser
                completion()
                return
            }

            self.pendingSignInCompletions.append(completion)
            guard !self.isSigningInAnonymously else { return }
            self.isSigningInAnonymously = true
            self.attemptAnonymousSignIn(attempt: 1)
        }
    }

    private func attemptAnonymousSignIn(attempt: Int) {
        Auth.auth().signInAnonymously { result, error in
            DispatchQueue.main.async {
                if let result {
                    print("Signed in anonymously with user ID: \(result.user.uid)")
                    self.user = result.user
                    self.onLoginCompleted?()
                    self.finishAnonymousSignIn()
                    return
                }

                print("Anonymous sign-in failed (attempt \(attempt)): \(error?.localizedDescription ?? "unknown")")
                guard attempt < Self.maxAnonymousSignInAttempts else {
                    self.finishAnonymousSignIn()
                    return
                }
                let delay = pow(2.0, Double(attempt - 1))
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.attemptAnonymousSignIn(attempt: attempt + 1)
                }
            }
        }
    }

    private func finishAnonymousSignIn() {
        isSigningInAnonymously = false
        let completions = pendingSignInCompletions
        pendingSignInCompletions.removeAll()
        completions.forEach { $0() }
    }

    /// 残高・アイテム・連続日数・受取日を同じトランザクションで確定する。
    /// 同日の再起動や重複リクエストでも、受け取り済みなら何も書き換えない。
    func checkAndGrantLoginBonus500(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        let now = Date()
        userRef.runTransactionBlock({ currentData in
            guard var userData = currentData.value as? [String: Any] else {
                // 初回の空キャッシュでは初期データを作らない。
                // 変更なしでサーバーと照合し、既存データで再試行させる。
                return TransactionResult.success(withValue: currentData)
            }

            let newCount: Int
            if let timestamp = userData["lastLoginDate"] as? TimeInterval {
                let days = self.daysBetween(Date(timeIntervalSince1970: timestamp), now)
                guard days > 0 else { return TransactionResult.abort() }
                newCount = days == 1
                    ? min(max(self.intValue(from: userData["loginCount"]), 0) + 1, LoginBonusConfig.maxDay)
                    : 1
            } else {
                newCount = 1
            }

            let bonus = LoginBonusConfig.coinAmount(for: newCount)
            userData["userMoney"] = self.intValue(from: userData["userMoney"]) + bonus
            for reward in LoginBonusConfig.itemRewards(for: newCount) {
                userData[reward.type.userFieldKey] =
                    self.intValue(from: userData[reward.type.userFieldKey]) + reward.amount
            }
            userData["loginCount"] = newCount
            userData["lastLoginDate"] = now.timeIntervalSince1970
            currentData.value = userData
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { error, committed, snapshot in
            DispatchQueue.main.async {
                guard error == nil, committed,
                      let userData = snapshot?.value as? [String: Any],
                      self.currentUserId == userId else {
                    completion(false)
                    return
                }

                let count = self.intValue(from: userData["loginCount"])
                self.loginCount = count
                self.loginBonus = LoginBonusConfig.coinAmount(for: count)
                self.money = self.intValue(from: userData["userMoney"])
                for reward in LoginBonusConfig.itemRewards(for: count) {
                    self.setInventoryCount(
                        self.intValue(from: userData[reward.type.userFieldKey]),
                        for: reward.type
                    )
                }
                self.awardLoginStreakTitles(for: userId, streakCount: count)
                MissionManager.shared.updateMissionProgressWithValue(type: .login, currentValue: count) { _ in }
                completion(true)
            }
        }, withLocalEvents: false)
    }

    func fetchLoginCount500(completion: @escaping (Int) -> Void) {
        guard let userId = currentUserId else {
            completion(0)
            return
        }

        let ref = Database.database().reference().child("users").child(userId).child("loginCount")
        ref.observeSingleEvent(of: .value) { snapshot in
            let count = snapshot.value as? Int ?? 0
            DispatchQueue.main.async {
                self.loginCount = count
            }
            self.awardLoginStreakTitles(for: userId, streakCount: count)
            completion(count)
        }
    }

    func updateLoginCount500(to newCount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["loginCount": newCount]) { error, _ in
            if let error = error {
                print("loginCount の更新に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.loginCount = newCount
                }
                self.awardLoginStreakTitles(for: userId, streakCount: newCount)
                print("loginCount を \(newCount) に更新しました。")
                completion(true)
            }
        }
    }

    func fetchCurrentLoginStreak(completion: @escaping (Int) -> Void) {
        fetchLoginCount500(completion: completion)
    }

    func awardLoginStreakTitles(for userId: String, streakCount: Int) {
        let thresholds: [(Int, String)] = [
            (7, "連続ログイン7日"),
            (30, "連続ログイン30日"),
            (100, "連続ログイン100日"),
        ]

        for (threshold, title) in thresholds where streakCount >= threshold {
            saveTitleForUser(userId: userId, title: title)
        }
    }

    /// ガチャの支払いとアバター付与を一つの Firebase transaction で確定する。
    func commitGachaResult(
        avatar: Avatar,
        coinCost: Int = 0,
        ticketType: InventoryItemType? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard coinCost >= 0, let userId = currentUserId else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        let newAvatarKey = userRef.child("avatars").childByAutoId().key ?? UUID().uuidString

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let fetchedUserData = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            var hasUsedFetchedUserData = false
            userRef.runTransactionBlock { currentData in
                var userData: [String: Any]
                if let cachedUserData = currentData.value as? [String: Any] {
                    userData = cachedUserData
                } else if !hasUsedFetchedUserData {
                    // Firebase can invoke the first transaction callback with an
                    // empty local cache. The server retries conflicting writes.
                    userData = fetchedUserData
                    hasUsedFetchedUserData = true
                } else {
                    return TransactionResult.abort()
                }

                if coinCost > 0 {
                    let currentMoney = self.intValue(from: userData["userMoney"])
                    guard currentMoney >= coinCost else { return TransactionResult.abort() }
                    userData["userMoney"] = currentMoney - coinCost
                }

                if let ticketType {
                    let currentCount = self.intValue(from: userData[ticketType.userFieldKey])
                    guard currentCount > 0 else { return TransactionResult.abort() }
                    userData[ticketType.userFieldKey] = currentCount - 1
                }

                var avatars = userData["avatars"] as? [String: Any] ?? [:]
                if let existingEntry = avatars.first(where: { _, value in
                    (value as? [String: Any])?["name"] as? String == avatar.name
                }), var existingAvatar = existingEntry.value as? [String: Any] {
                    existingAvatar["count"] = self.intValue(from: existingAvatar["count"]) + 1
                    avatars[existingEntry.key] = existingAvatar
                } else {
                    avatars[newAvatarKey] = [
                        "name": avatar.name,
                        "attack": avatar.attack,
                        "health": avatar.health,
                        "usedFlag": avatar.usedFlag,
                        "count": 1
                    ]
                }

                userData["avatars"] = avatars
                currentData.value = userData
                return TransactionResult.success(withValue: currentData)
            } andCompletionBlock: { error, committed, snapshot in
                DispatchQueue.main.async {
                    guard error == nil,
                          committed,
                          let userData = snapshot?.value as? [String: Any] else {
                        completion(false)
                        return
                    }

                    self.money = self.intValue(from: userData["userMoney"])
                    if let ticketType {
                        self.setInventoryCount(
                            self.intValue(from: userData[ticketType.userFieldKey]),
                            for: ticketType
                        )
                    }
                    completion(true)
                }
            }
        }, withCancel: { _ in
            DispatchQueue.main.async { completion(false) }
        })
    }


    func addAvatarToUser(avatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")

        avatarsRef.observeSingleEvent(of: .value) { snapshot in
            var avatarExists = false
            var existingRef: DatabaseReference?

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   name == avatar.name {
                    avatarExists = true
                    existingRef = childSnapshot.ref
                    break
                }
            }

            if avatarExists, let existingRef {
                existingRef.child("count").runTransactionBlock { currentData in
                    let count = (currentData.value as? Int ?? 0) + 1
                    currentData.value = count
                    return TransactionResult.success(withValue: currentData)
                } andCompletionBlock: { error, committed, _ in
                    DispatchQueue.main.async {
                        completion(error == nil && committed)
                    }
                }
            } else {
                let avatarRef = avatarsRef.childByAutoId()
                let avatarData: [String: Any] = [
                    "name": avatar.name,
                    "attack": avatar.attack,
                    "health": avatar.health,
                    "usedFlag": avatar.usedFlag,
                    "count": 1,
                ]
                avatarRef.setValue(avatarData) { error, _ in
                    if let error = error {
                        print("Failed to add avatar to database: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Successfully added avatar to database.")
                        completion(true)
                    }
                }
            }
        }
    }

    func checkTitles(userId: String, title: String, completion: @escaping (Bool) -> Void) {
        let titlesRef = Database.database().reference().child("titles").child(userId)
        titlesRef.observeSingleEvent(of: .value) { snapshot in
            if let titlesData = snapshot.value as? [String: Bool] {
                completion(titlesData[title] ?? false)
            } else {
                completion(false)
            }
        }
    }

    func saveTitleForUser(userId: String, title: String) {
        let titleRef = Database.database().reference().child("titles").child(userId)
        titleRef.updateChildValues([title: true]) { error, _ in
            if let error = error {
                print("Error saving title: \(error)")
            }
        }
    }

    func fetchLastLoginDate(completion: @escaping (Date?) -> Void) {
        guard let userId = currentUserId else {
            completion(nil)
            return
        }

        let ref = Database.database().reference().child("users").child(userId).child("lastLoginDate")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let timestamp = snapshot.value as? TimeInterval {
                completion(Date(timeIntervalSince1970: timestamp))
            } else {
                completion(nil)
            }
        }
    }

    func daysBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: from)
        let toDate = calendar.startOfDay(for: to)
        return calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }

    func shouldShowLoginBonus(completion: @escaping (Bool) -> Void) {
        fetchLastLoginDate { lastLoginDate in
            let calendar = Calendar.current
            let now = Date()
            if let lastLogin = lastLoginDate {
                completion(!calendar.isDate(lastLogin, inSameDayAs: now))
            } else {
                completion(true)
            }
        }
    }

    func grantLoginBonus(amount: Int, itemRewards: [InventoryReward] = [], completion: @escaping (Bool) -> Void) {
        addLoginMoney(amount: amount) { success in
            guard success else {
                completion(false)
                return
            }

            self.addItems(itemRewards) { itemSuccess in
                guard itemSuccess else {
                    completion(false)
                    return
                }

                let bonusSummary = itemRewards.isEmpty
                    ? "\(amount)コイン"
                    : "\(amount)コイン, \(itemRewards.map { $0.displayText }.joined(separator: ", "))"
                print("ログインボーナスを付与: +\(bonusSummary)")
                self.saveLastLoginDate(completion: completion)
            }
        }
    }

    func checkIfUserIdExists(userId: String, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                completion(snapshot.exists())
            }
        }, withCancel: { error in
            print("Failed to check user existence: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
        })
    }
}
