//
//  TestView.swift
//  it
//
//  Created by Apple on 2024/11/12.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine
import UIKit

struct DungeonChapterInfo: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let range: ClosedRange<Int>
    let symbolName: String
    let accentColors: [Color]

    static let chapters: [DungeonChapterInfo] = [
        DungeonChapterInfo(
            id: 1,
            title: "ITパスポートの森",
            subtitle: "基礎をつかんで、冒険のリズムを作るエリア",
            range: 1...51,
            symbolName: "leaf.fill",
            accentColors: [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        ),
        DungeonChapterInfo(
            id: 2,
            title: "基本情報の洞窟",
            subtitle: "アルゴリズムと設計を乗り越える中盤エリア",
            range: 52...100,
            symbolName: "bolt.horizontal.circle.fill",
            accentColors: [Color(hex: "fa709a"), Color(hex: "fee140")]
        ),
        DungeonChapterInfo(
            id: 3,
            title: "応用情報の深層",
            subtitle: "実戦力を磨く高難度エリア",
            range: 101...150,
            symbolName: "sparkles",
            accentColors: [Color(hex: "667eea"), Color(hex: "764ba2")]
        ),
        DungeonChapterInfo(
            id: 4, title: "蒼穹の防衛要塞", subtitle: "通信・認証・運用の力で要塞を奪還する",
            range: 151...200, symbolName: "shield.lefthalf.filled",
            accentColors: [Color(hex: "2575fc"), Color(hex: "6a11cb")]
        ),
        DungeonChapterInfo(
            id: 5, title: "創造の機巧遺跡", subtitle: "データ・設計・開発をつなぎ、遺跡を再起動する",
            range: 201...250, symbolName: "gearshape.2.fill",
            accentColors: [Color(hex: "f7971e"), Color(hex: "c65d35")]
        ),
        DungeonChapterInfo(
            id: 6, title: "天空の総合試練", subtitle: "技術・管理・戦略を結集し、知恵の頂へ",
            range: 251...300, symbolName: "crown.fill",
            accentColors: [Color(hex: "11998e"), Color(hex: "38ef7d")]
        )
    ]

    static func current(for position: Int) -> DungeonChapterInfo {
        chapters.first(where: { $0.range.contains(position) }) ?? chapters[0]
    }
}

enum DungeonBoostType: String, Codable, Hashable, CaseIterable {
    case attackSurge
    case safeShield
    case coinBonus

    var title: String {
        switch self {
        case .attackSurge:
            return "戦闘ブースト"
        case .safeShield:
            return "安全のお守り"
        case .coinBonus:
            return "財宝ボーナス"
        }
    }

    var shortTitle: String {
        switch self {
        case .attackSurge:
            return "ATK+"
        case .safeShield:
            return "シールド"
        case .coinBonus:
            return "COIN+"
        }
    }

    var description: String {
        switch self {
        case .attackSurge:
            return "次の戦闘で3回、与ダメージがアップします"
        case .safeShield:
            return "次に負けてもスタミナ消費を無効化します"
        case .coinBonus:
            return "次のコイン宝箱の獲得量がアップします"
        }
    }

    var symbolName: String {
        switch self {
        case .attackSurge:
            return "flame.fill"
        case .safeShield:
            return "shield.lefthalf.filled"
        case .coinBonus:
            return "bitcoinsign.circle.fill"
        }
    }

    var accentColors: [Color] {
        switch self {
        case .attackSurge:
            return [Color(hex: "ff9a44"), Color(hex: "fc6076")]
        case .safeShield:
            return [Color(hex: "11998e"), Color(hex: "38ef7d")]
        case .coinBonus:
            return [Color(hex: "f7971e"), Color(hex: "ffd200")]
        }
    }

    var defaultMagnitude: Double {
        switch self {
        case .attackSurge:
            return 1.2
        case .safeShield:
            return 1.0
        case .coinBonus:
            return 1.6
        }
    }
}

struct DungeonBoost: Identifiable, Codable, Hashable {
    let id: UUID
    let type: DungeonBoostType
    var charges: Int
    var magnitude: Double

    init(id: UUID = UUID(), type: DungeonBoostType, charges: Int, magnitude: Double? = nil) {
        self.id = id
        self.type = type
        self.charges = charges
        self.magnitude = magnitude ?? type.defaultMagnitude
    }
}

struct DungeonBattleSnapshot: Codable, Hashable {
    let accuracy: Double
    let maxConsecutive: Int
    let correctCount: Int
    let totalCount: Int
    let didWin: Bool
    let winStreak: Int
    let recordedAt: TimeInterval
}

struct QuizStoryData: Identifiable {
    let id = UUID()
    let monsterName: String
    let backgroundName: String
}

// PositionViewModel の定義
class PositionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userPosition: Int = 1
    @Published var coin: Int = 1
    @Published var monster: Int = 1
    @Published var stamina: Int = 100
    @Published var monsterName: String = "モンスタ-1"
    @Published var showStaminaAlert: Bool = false
    @Published var showCoinAlert: Bool = false
    @Published var showMonsterAlert: Bool = false
    @Published var showUserStoryAlert: Bool = false
    @Published var showUserStoryQuiz: Bool = false
    @Published var isPositionFetched: Bool = false
    @Published var showMonsterQuizList = false
    @Published var avatarName: String = ""
    @Published var recoverySecondsRemaining: Int = 0
    @Published var activeBoosts: [DungeonBoost] = []
    @Published var latestBattleSnapshot: DungeonBattleSnapshot? = nil
    private let authManager = AuthManager.shared
    @Published var selectedUser: User? = nil
    
    // MARK: - Private Properties
    private var dbRef: DatabaseReference
    private var handle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    private var staminaRecoveryCancellable: AnyCancellable?
    private var recoveryCountdownCancellable: AnyCancellable?
    @Published var storyUsers: [RankedUser] = []
    
    private var isTimerActive = false
    
    // MARK: - Constants
    struct Constants {
        static let maxStamina: Int = 100
        static let staminaRecoveryInterval: TimeInterval = 60 // 60秒 = 1分
        static let staminaRecoveryAmount: Int = 1
        static let finalFloor: Int = DungeonExpansion.finalFloor
    }

    var dungeonStaminaCost: Int {
#if DEBUG
        return 0
#else
        return 10
#endif
    }

    var canEnterDungeon: Bool {
        stamina >= dungeonStaminaCost
    }

    private let dungeonBoostsKey = "story.dungeon.boosts"
    private let dungeonBattleSnapshotKey = "story.dungeon.battleSnapshot"
    
    // MARK: - Singleton Instance
    static let shared: PositionViewModel = {
        let instance = PositionViewModel()
        return instance
    }()
    
    // MARK: - Initializer
    private init() {
        self.dbRef = Database.database().reference()
        loadDungeonState()
        
        // アバターの監視
        authManager.$avatars
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatars in
                if let firstUsedAvatar = avatars.first(where: { $0.usedFlag == 1 }) {
                    self?.avatarName = firstUsedAvatar.name
                } else {
                    self?.avatarName = "ネッキー" // デフォルト値
                }
            }
            .store(in: &cancellables)
        
        // 認証されたユーザーの監視
        authManager.$user
            .compactMap { $0?.uid }
            .sink { [weak self] userId in
                guard let self = self else { return }
                self.fetchPosition(for: userId)
                self.fetchUserStamina(for: userId)
                self.fetchAvatars(for: userId)
            }
            .store(in: &cancellables)
        
        // スタミナ回復タイマーの設定
        staminaRecoveryCancellable = Timer.publish(every: Constants.staminaRecoveryInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recoverStamina()
            }
        startRecoveryCountdownTimerIfNeeded()
    }
    
    // MARK: - Deinitializer
    deinit {
        staminaRecoveryCancellable?.cancel()
        // Remove observer when the view model is deallocated
        if let userId = authManager.currentUserId, let handle = handle {
            dbRef.child("storys").child(userId).child("position").removeObserver(withHandle: handle)
        }
    }
    
    // MARK: - Stamina Recovery
    private func recoverStamina() {
        guard stamina < Constants.maxStamina else { return }
        
        DispatchQueue.main.async {
            self.stamina += Constants.staminaRecoveryAmount
            // 最大スタミナを超えないようにする
            if self.stamina > Constants.maxStamina {
                self.stamina = Constants.maxStamina
            }
            // 加算後の値を保存する（非同期ブロックの外で保存すると1つ前の値が書き込まれる）
            self.updateStaminaInFirebase()
            self.refreshRecoveryCountdown()
        }
    }
    
    // スタミナ回復のためのメソッド
    func recoverStaminaOnAppLaunch(completion: @escaping (Bool) -> Void) {
        stopStaminaRecoveryTimer()
        authManager.fetchLastActiveTimeFromFirebase { [weak self] lastActiveTimestamp in
            guard let self = self else {
                completion(false)
                return
            }
            // 起動直後は stamina が初期値(100)のままのことがあり、そのまま計算すると回復分が失われる。
            // 保存済みの値を読み込んでから回復量を計算する。
            self.fetchLatestStamina {
                self.applyOfflineRecovery(lastActiveTimestamp: lastActiveTimestamp, completion: completion)
            }
        }
    }

    private func fetchLatestStamina(completion: @escaping () -> Void) {
        guard let userId = authManager.currentUserId else {
            DispatchQueue.main.async { completion() }
            return
        }
        dbRef.child("storys").child(userId).child("stamina").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let staminaValue = snapshot.value as? Int {
                    self.stamina = staminaValue
                }
                completion()
            }
        }, withCancel: { error in
            print("スタミナの取得に失敗しました: \(error.localizedDescription)")
            DispatchQueue.main.async { completion() }
        })
    }

    private func applyOfflineRecovery(lastActiveTimestamp: TimeInterval?, completion: @escaping (Bool) -> Void) {
        let currentTime = Date().timeIntervalSince1970

        if let lastActive = lastActiveTimestamp {
            let elapsedTime = currentTime - lastActive
            let minutesPassed = Int(elapsedTime / Constants.staminaRecoveryInterval)

            guard minutesPassed > 0 else {
                print("スタミナ回復の必要なし。経過時間: \(elapsedTime)秒")
                completion(true)
                self.refreshRecoveryCountdown(elapsedSinceLastActive: elapsedTime)
                self.startStaminaRecoveryTimer()
                return
            }

            let staminaToRecover = minutesPassed * Constants.staminaRecoveryAmount
            let newStamina = min(self.stamina + staminaToRecover, Constants.maxStamina)
            let actualRecovered = newStamina - self.stamina

            if actualRecovered > 0 {
                DispatchQueue.main.async {
                    self.stamina = newStamina
                    self.updateStaminaInFirebase()
                }
                print("\(actualRecovered)スタミナを回復しました。")
            } else {
                print("スタミナの回復が必要ありません。")
            }

            self.refreshRecoveryCountdown(elapsedSinceLastActive: elapsedTime)
        } else {
            print("lastActiveTimeが存在しないため、スタミナ回復をスキップします。")
            self.refreshRecoveryCountdown()
        }

        // 最後のアクティブ時刻を現在時刻に更新
        self.authManager.saveLastActiveTimeToFirebase { success in
            completion(success)
            self.startStaminaRecoveryTimer()
        }
    }
    
    func handleAppBecameActive() {
        recoverStaminaOnAppLaunch { success in
            if success {
                print("アプリ復帰時のスタミナ回復に成功しました。")
            }
        }
        startStaminaRecoveryTimer()
    }
    
    // アプリがバックグラウンドになった時の処理
    func handleAppWentToBackground() {
        saveLastActiveTime { _ in }
        stopStaminaRecoveryTimer()
    }
    
    func recoverStamina(by amount: Int) {
        guard amount > 0 else { return }
        DispatchQueue.main.async {
            self.stamina = min(self.stamina + amount, Constants.maxStamina)
            self.updateStaminaInFirebase()
            self.refreshRecoveryCountdown()
        }
    }
    
    // スタミナを更新するメソッド
    func updateStaminaInFirebase() {
        guard let userId = AuthManager.shared.currentUserId else { return }
        let storyRef = dbRef.child("storys").child(userId)
        let updates = ["stamina": stamina] as [String : Any]
        
        storyRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("スタミナの更新に失敗しました: \(error.localizedDescription)")
                // 必要に応じてエラーハンドリングを追加
            } else {
                print("スタミナが\(self.stamina)に回復しました")
            }
        }
    }
    
    // MARK: - Firebase Fetch Methods
    
    func fetchUserStamina(for userId: String) {
        let staminaRef = Database.database().reference().child("storys").child(userId).child("stamina")
        print("userId:\(userId)")
        staminaRef.observeSingleEvent(of: .value) { snapshot in
            if let staminaValue = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.stamina = staminaValue
                    self.refreshRecoveryCountdown()
                }
            } else {
                // スタミナが存在しない場合は初期値を設定
                self.stamina = 100
                self.saveInitialStamina(for: userId)
                self.refreshRecoveryCountdown()
            }
        }
    }
    
    private func saveInitialStamina(for userId: String) {
        let staminaRef = dbRef.child("storys").child(userId).child("stamina")
        staminaRef.setValue(self.stamina) { error, _ in
            if let error = error {
                print("初期スタミナの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("初期スタミナをFirebaseに保存しました: \(self.stamina)")
            }
        }
    }
    
    /// Fetch the position for a specific userId
    func fetchPosition(for userId: String) {
        // Remove existing observer if any
        if let handle = handle {
            dbRef.child("storys").child(userId).child("position").removeObserver(withHandle: handle)
        }
        
        // Observe the position value in Firebase
        handle = dbRef.child("storys").child(userId).child("position").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let positionValue = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.userPosition = positionValue
                    self.isPositionFetched = true // フラグを設定
                    print("取得した position: \(positionValue)")
                }
            } else if let positionValue = snapshot.value as? Double {
                // FirebaseからDoubleとして取得される場合もあるため
                DispatchQueue.main.async {
                    self.userPosition = Int(positionValue)
                    self.isPositionFetched = true // フラグを設定
                    print("取得した position (Double): \(positionValue)")
                }
            } else {
                // position が存在しない場合は初期値を設定
                self.userPosition = 1
                self.isPositionFetched = true
                self.saveInitialPosition(for: userId)
                print("position が存在しないため、初期値を設定しました。")
            }
        }
    }

    private func saveInitialPosition(for userId: String) {
        let positionRef = dbRef.child("storys").child(userId).child("position")
        positionRef.setValue(self.userPosition) { error, _ in
            if let error = error {
                print("初期 position の保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("初期 position をFirebaseに保存しました: \(self.userPosition)")
            }
        }
    }
    
#if DEBUG
    /// Changes only the dungeon position, without spending stamina or recording steps.
    func setPositionForDebug(_ position: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard (1...Constants.finalFloor).contains(position),
              let userId = authManager.currentUserId else {
            completion(.failure(NSError(domain: "DungeonDebug", code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "ログイン状態とコマ数を確認してください。"])))
            return
        }

        dbRef.child("storys").child(userId).child("position").setValue(position) { [weak self] error, _ in
            DispatchQueue.main.async {
                guard let self, self.authManager.currentUserId == userId else {
                    completion(.failure(NSError(domain: "DungeonDebug", code: 2,
                                                userInfo: [NSLocalizedDescriptionKey: "ユーザーが変更されました。もう一度お試しください。"])))
                    return
                }
                if let error {
                    completion(.failure(error))
                } else {
                    self.userPosition = position
                    self.isPositionFetched = true
                    completion(.success(()))
                }
            }
        }
    }
#endif

    func fetchAvatars(for userId: String) {
        authManager.fetchAvatars() {}
    }
    
    /// ユーザーのポジションを増加させる
    func incrementPosition() {
        guard userPosition < Constants.finalFloor else { return }
        guard let userId = AuthManager.shared.currentUserId else {
            print("User is not logged in.")
            return
        }
        
        // スタミナが十分か確認
        guard canEnterDungeon else {
            showStaminaAlert = true
            return
        }
        
        let newPosition = min(userPosition + 1, Constants.finalFloor)
        let previousPosition = userPosition
        let previousStamina = stamina
        let newStamina = self.stamina - dungeonStaminaCost
        
        // ローカルの状態を即時に更新し、アニメーションをトリガー
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) { // アニメーションの調整
                self.userPosition = newPosition
                self.stamina = newStamina
            }
        }
        
        let storyRef = dbRef.child("storys").child(userId)
        
        // 複数のフィールドを同時に更新するためのデータ構造
        let updates = [
            "position": newPosition,
            "stamina": newStamina
        ] as [String : Any]
        
        // Firebase に位置とスタミナを同時に更新
        storyRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("position と stamina の更新に失敗しました: \(error.localizedDescription)")
                // 必要に応じてローカルの状態を元に戻す処理を追加
                DispatchQueue.main.async {
                    withAnimation {
                        self.userPosition = previousPosition
                        self.stamina = previousStamina
                    }
                }
            } else {
                print("position と stamina が更新されました: position=\(newPosition), stamina=\(newStamina)")
                AuthManager.shared.recordDungeonStep(position: newPosition)
                GuildManager.shared.recordDungeonStep()
            }
        }
        refreshRecoveryCountdown()
    }

    func incrementUserPosition() {
        guard userPosition < Constants.finalFloor else { return }
        guard let userId = AuthManager.shared.currentUserId else {
            print("User is not logged in.")
            return
        }
        
        // スタミナが十分か確認
        guard canEnterDungeon else {
            showStaminaAlert = true
            return
        }
        
        let newPosition = min(userPosition + 1, Constants.finalFloor)
        let newStamina = self.stamina
        
        // ローカルの状態を即時に更新し、アニメーションをトリガー
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) { // アニメーションの調整
                self.userPosition = newPosition
                self.stamina = newStamina
            }
        }
        
        let storyRef = dbRef.child("storys").child(userId)
        
        // 複数のフィールドを同時に更新するためのデータ構造
        let updates = [
            "position": newPosition,
            "stamina": newStamina
        ] as [String : Any]
        
        // Firebase に位置とスタミナを同時に更新
        storyRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("position と stamina の更新に失敗しました: \(error.localizedDescription)")
                // 必要に応じてローカルの状態を元に戻す処理を追加
                DispatchQueue.main.async {
                    withAnimation {
                        self.userPosition = newPosition - 1
                        self.stamina = newStamina
                    }
                }
            } else {
                print("position と stamina が更新されました: position=\(newPosition), stamina=\(newStamina)")
                AuthManager.shared.recordDungeonStep(position: newPosition)
                GuildManager.shared.recordDungeonStep()
            }
        }
        refreshRecoveryCountdown()
    }

    /// スタミナを減少させる関数
    func decreaseStamina(by amount: Int = 10) {
        guard dungeonStaminaCost > 0 else { return }
        guard let userId = authManager.currentUserId else {
            print("ユーザーがログインしていません。")
            return
        }
        
        // スタミナが十分か確認
        guard self.stamina >= amount else {
            DispatchQueue.main.async {
                self.showStaminaAlert = true
            }
            return
        }
        
        let newStamina = self.stamina - amount
        
        // ローカルの状態を即時に更新し、アニメーションをトリガー
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) { // アニメーションの調整
                self.stamina = newStamina
            }
        }
        
        let storyRef = dbRef.child("storys").child(userId)
        
        // スタミナのみを更新するためのデータ構造
        let updates = [
            "stamina": newStamina
        ] as [String : Any]
        
        // Firebase にスタミナを更新
        storyRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("スタミナの更新に失敗しました: \(error.localizedDescription)")
                // 必要に応じてローカルの状態を元に戻す処理を追加
                DispatchQueue.main.async {
                    withAnimation {
                        self.stamina = newStamina + amount
                    }
                }
            } else {
                print("スタミナが更新されました: stamina=\(newStamina)")
            }
        }
        refreshRecoveryCountdown()
    }
    
    func saveLastActiveTimeToFirebase() {
        guard let userId = authManager.currentUserId else { return }
        let lastActiveRef = dbRef.child("storys").child(userId).child("lastActiveTime")
        let currentTime = Date().timeIntervalSince1970 // Unixタイムスタンプとして保存
        
        lastActiveRef.setValue(currentTime) { error, _ in
            if let error = error {
                print("FirebaseへのlastActiveTimeの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("FirebaseにlastActiveTimeを保存しました")
            }
        }
    }

    // saveLastActiveTime 関数を拡張してFirebaseにも保存
    func saveLastActiveTime(completion: @escaping (Bool) -> Void) {
        authManager.saveLastActiveTimeToFirebase { success in
            if success {
                print("最後のアクティブ時刻を保存しました。")
            } else {
                print("最後のアクティブ時刻の保存に失敗しました。")
            }
            completion(success)
        }
    }
    
    func startStaminaRecoveryTimer() {
        // 既にタイマーが動作中の場合は無視
        guard !isTimerActive else {
            print("タイマーは既に動作中です")
            return
        }
        
        print("スタミナ回復タイマーを開始します")
        isTimerActive = true
        
        staminaRecoveryCancellable = Timer.publish(every: Constants.staminaRecoveryInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recoverStamina()
            }
    }
    
    /// スタミナ回復タイマーを停止する
    func stopStaminaRecoveryTimer() {
        print("スタミナ回復タイマーを停止します")
        staminaRecoveryCancellable?.cancel()
        staminaRecoveryCancellable = nil
        isTimerActive = false
    }

    var currentChapter: DungeonChapterInfo {
        DungeonChapterInfo.current(for: userPosition)
    }

    var nextRecoveryText: String {
        guard stamina < Constants.maxStamina else { return "FULL" }
        let minutes = recoverySecondsRemaining / 60
        let seconds = recoverySecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var battleWinStreak: Int {
        latestBattleSnapshot?.winStreak ?? 0
    }

    func addDungeonBoost(type: DungeonBoostType, charges: Int = 1, magnitude: Double? = nil) {
        guard charges > 0 else { return }
        if let index = activeBoosts.firstIndex(where: { $0.type == type }) {
            activeBoosts[index].charges += charges
            activeBoosts[index].magnitude = max(activeBoosts[index].magnitude, magnitude ?? type.defaultMagnitude)
        } else {
            activeBoosts.append(DungeonBoost(type: type, charges: charges, magnitude: magnitude))
        }
        persistDungeonState()
    }

    func consumeAttackBoostMultiplier() -> Double {
        guard let boost = activeBoosts.first(where: { $0.type == .attackSurge }) else {
            return 1.0
        }
        _ = consumeBoost(.attackSurge)
        return boost.magnitude
    }

    func consumeDefeatShield() -> Bool {
        consumeBoost(.safeShield)
    }

    func applyCoinTreasureBonus(to amount: Int) -> Int {
        guard let boost = activeBoosts.first(where: { $0.type == .coinBonus }) else {
            return amount
        }
        let boosted = Int((Double(amount) * boost.magnitude).rounded())
        _ = consumeBoost(.coinBonus)
        return max(boosted, amount)
    }

    func recordBattleSession(accuracy: Double, maxConsecutiveCorrect: Int, correctCount: Int, totalCount: Int, victory: Bool) {
        let newStreak = victory ? battleWinStreak + 1 : 0
        latestBattleSnapshot = DungeonBattleSnapshot(
            accuracy: accuracy,
            maxConsecutive: maxConsecutiveCorrect,
            correctCount: correctCount,
            totalCount: totalCount,
            didWin: victory,
            winStreak: newStreak,
            recordedAt: Date().timeIntervalSince1970
        )
        persistDungeonState()
    }

    private func consumeBoost(_ type: DungeonBoostType) -> Bool {
        guard let index = activeBoosts.firstIndex(where: { $0.type == type }) else {
            return false
        }
        activeBoosts[index].charges -= 1
        if activeBoosts[index].charges <= 0 {
            activeBoosts.remove(at: index)
        }
        persistDungeonState()
        return true
    }

    private func refreshRecoveryCountdown(elapsedSinceLastActive: TimeInterval? = nil) {
        guard stamina < Constants.maxStamina else {
            recoverySecondsRemaining = 0
            return
        }

        let remaining: Int
        if let elapsedSinceLastActive {
            let remainder = elapsedSinceLastActive.truncatingRemainder(dividingBy: Constants.staminaRecoveryInterval)
            remaining = remainder == 0
                ? Int(Constants.staminaRecoveryInterval)
                : max(Int(ceil(Constants.staminaRecoveryInterval - remainder)), 1)
        } else if recoverySecondsRemaining > 0 && recoverySecondsRemaining <= Int(Constants.staminaRecoveryInterval) {
            remaining = recoverySecondsRemaining
        } else {
            remaining = Int(Constants.staminaRecoveryInterval)
        }

        recoverySecondsRemaining = remaining
        startRecoveryCountdownTimerIfNeeded()
    }

    private func startRecoveryCountdownTimerIfNeeded() {
        guard recoveryCountdownCancellable == nil else { return }
        recoveryCountdownCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard self.stamina < Constants.maxStamina else {
                    self.recoverySecondsRemaining = 0
                    return
                }
                if self.recoverySecondsRemaining > 0 {
                    self.recoverySecondsRemaining -= 1
                } else {
                    self.recoverySecondsRemaining = Int(Constants.staminaRecoveryInterval)
                }
            }
    }

    private func loadDungeonState() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: dungeonBoostsKey),
           let boosts = try? JSONDecoder().decode([DungeonBoost].self, from: data) {
            activeBoosts = boosts
        }
        if let data = defaults.data(forKey: dungeonBattleSnapshotKey),
           let snapshot = try? JSONDecoder().decode(DungeonBattleSnapshot.self, from: data) {
            latestBattleSnapshot = snapshot
        }
    }

    private func persistDungeonState() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(activeBoosts) {
            defaults.set(data, forKey: dungeonBoostsKey)
        }
        if let latestBattleSnapshot,
           let data = try? JSONEncoder().encode(latestBattleSnapshot) {
            defaults.set(data, forKey: dungeonBattleSnapshotKey)
        }
    }

    private var storys: [String: Story] = [:]
    private var users: [User] = []

    struct Story: Codable {
        let lastActiveTime: Double?
        let position: Int
        let stamina: Int
    }

    func fetchUsers(completion: @escaping (Bool) -> Void) {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []

            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Could not parse users data")
                return
            }

            for (userId, data) in usersData {
                if let userName = data["userName"] as? String,
                   let userMoney = data["userMoney"] as? Int,
                   let userHp = data["userHp"] as? Int,
                   let userAttack = data["userAttack"] as? Int,
                   let level = data["level"] as? Int,
                   let experience = data["experience"] as? Int {

                    let rankMatchPoint = data["rankMatchPoint"] as? Int ?? 100
                    let rank = data["rank"] as? Int ?? 1

                    var filteredAvatars: [[String: Any]] = []
                    if let avatarsData = data["avatars"] as? [String: [String: Any]] {
                        for (_, avatarData) in avatarsData {
                            if avatarData["usedFlag"] as? Int == 1 {
                                filteredAvatars.append(avatarData)
                            }
                        }
                    }

                    let user = User(id: userId,
                                    userName: userName,
                                    level: level,
                                    experience: experience,
                                    avatars: filteredAvatars,
                                    userMoney: userMoney,
                                    userHp: userHp,
                                    userAttack: userAttack,
                                    userFlag: 1,
                                    adminFlag: 0,
                                    rankMatchPoint: rankMatchPoint,
                                    rank: rank)
                    users.append(user)
                    
                }
            }

            self.users = users.sorted { $0.level > $1.level }
            completion(true)
//            self.rankedUsers = users.sorted { $0.rankMatchPoint > $1.rankMatchPoint }

            DispatchQueue.main.async {
//                self.calculateLevelRankings()
//                self.calculateRankRankings()
            }
//            self.fetchMonthlyAnswers()
        }) { (error) in
            print("Error getting users: \(error.localizedDescription)")
        }
    }

    func fetchStorys() {
        Database.database().reference().child("storys").observeSingleEvent(of: .value) { [weak self] snapshot in
            var tempStorys: [String: Story] = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let position = value["position"] as? Int,
                   let stamina = value["stamina"] as? Int {
                    let lastActiveTime = value["lastActiveTime"] as? Double

                    let story = Story(lastActiveTime: lastActiveTime, position: position, stamina: stamina)
                    tempStorys[childSnapshot.key] = story
                }
            }
            DispatchQueue.main.async {
                self?.storys = tempStorys
                self?.updateRankedUsers() { success in
                    if success {
                        self!.storyUsers = self!.storyUsers.sorted { $0.position > $1.position }
                        self!.assignRanks()
                    }
                }
            }
        }
    }

    private func assignRanks() {
        var currentRank = 1
        var previousPosition: Int? = nil
        var sameRankCount = 0
        for (index, user) in storyUsers.enumerated() {
            if let prevPos = previousPosition {
                if user.position == prevPos {
                    storyUsers[index].rank = currentRank
                    sameRankCount += 1
                } else {
                    currentRank += sameRankCount + 1
                    storyUsers[index].rank = currentRank
                    sameRankCount = 0
                }
            } else {
                storyUsers[index].rank = currentRank
            }
            previousPosition = user.position
        }
    }

    func updateRankedUsers(completion: @escaping (Bool) -> Void) {
        let ranked = users.compactMap { user -> RankedUser? in
            guard let story = storys[user.id] else { return nil }
            return RankedUser(user: user, position: story.position)
        }
        .sorted { $1.position < $0.position } // positionが小さいほど上位

        DispatchQueue.main.async {
            self.storyUsers = ranked
            self.updateCurrentUserRank()
            completion(true)
        }
    }

    func updateCurrentUserRank() {
        // ここで現在のユーザーIDを取得します。例えば、Firebase Authenticationを使用している場合：
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        if storyUsers.firstIndex(where: { $0.user.id == currentUserID }) != nil {
//            currentUserLevelRank = index + 1
        }
    }
}

struct DownArrowPositionKey: PreferenceKey {
    typealias Value = CGPoint?
    static var defaultValue: CGPoint? = nil

    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        if let next = nextValue() {
            value = next
        }
    }
}

struct StoryBoundaryOffsetKey: PreferenceKey {
    typealias Value = [Int: CGFloat]

    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct StoryMapContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// TestView の定義
struct StoryView: View {
    @StateObject var viewModel = PositionViewModel.shared
    @ObservedObject var audioManager = AudioManager.shared
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject private var missionManager = MissionManager.shared
    @Namespace private var animationNamespace
    @State private var initialScrollDone = false
    @State private var isStorySutaminaModal = false
    @State private var isLoading = true
    @State private var position: Int = 1
    @State private var index: Int = 1
    @State private var currentVisiblePosition: Int = 1
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appState: AppState
    @State private var isStoryFlag: Bool = false
    @State private var isTutorialStart: Bool = false
    @State private var csFlag: Bool = false
    @State private var downArrowPosition: CGPoint? = nil
    @State private var shouldPresentMonsterQuizAfterDismiss = false
    @State private var shouldPresentUserQuizAfterDismiss = false
    @Binding var isReturnActive: Bool
    @Binding var isPresented: Bool
    @State private var hasAppeared = false
    @State private var mapZoom: CGFloat = 1
    @State private var mapContentHeight: CGFloat = 0
    @GestureState private var pinchMagnification: CGFloat = 1

    private let minimumMapZoom: CGFloat = 0.4
    private let maximumMapZoom: CGFloat = 2.0

    private var displayedMapZoom: CGFloat {
        min(max(mapZoom * pinchMagnification, minimumMapZoom), maximumMapZoom)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ZStack {
                    Image(backgroundImageName(for: currentVisiblePosition))
                        .resizable()
                        .overlay(Color.white.opacity(0.24))
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: currentVisiblePosition)

                    VStack(spacing: 0) {
                        if appState.shouldShowAds {
                            BannerStortyView()
                        }
                        adventureHUD
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        // スクロールビュー
                        ScrollView {
                            PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                                // The floor 300 boss rises above its platform. Include that
                                // overhang in the scrollable content so its head stays visible.
                                .padding(.top, 160)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.preference(
                                            key: StoryMapContentHeightKey.self,
                                            value: geometry.size.height
                                        )
                                    }
                                )
                                .scaleEffect(displayedMapZoom, anchor: .top)
                                .frame(
                                    height: mapContentHeight > 0
                                        ? mapContentHeight * displayedMapZoom
                                        : nil,
                                    alignment: .top
                                )
                        }
                        .simultaneousGesture(mapZoomGesture)
                        .accessibilityLabel("ストーリーマップ")
                        .accessibilityValue("拡大率 \(Int((displayedMapZoom * 100).rounded()))パーセント")
                        .accessibilityHint("2本の指を広げると拡大、つまむと縮小します")
                        .onPreferenceChange(StoryMapContentHeightKey.self) { height in
                            mapContentHeight = height
                        }
                        .onPreferenceChange(StoryBoundaryOffsetKey.self) { offsets in
                            updateBackgroundImage(using: offsets)
                        }
                        
                    }
                    
                    if viewModel.showStaminaAlert {
                        StorySutaminaModalView(viewModel: viewModel, isPresented: $viewModel.showStaminaAlert)
                    }
                    
                    if viewModel.showCoinAlert {
                        StoryCoinModalView(coin: viewModel.coin, isPresented: $viewModel.showCoinAlert)
                    }
                    
                    if viewModel.showMonsterAlert {
                        StoryMonsterModalView(
                            monster: $viewModel.monster,
                            isPresented: $viewModel.showMonsterAlert,
                            audioManager: audioManager,
                            viewModel: viewModel,
                            onStartBattle: {
                                shouldPresentMonsterQuizAfterDismiss = true
                            }
                        )
                    }
                    
                    if viewModel.showUserStoryAlert {
                        StoryUserModalView(
                            viewModel: viewModel,
                            isPresented: $viewModel.showUserStoryAlert,
                            audioManager: audioManager,
                            user: viewModel.selectedUser!,
                            onStartBattle: {
                                shouldPresentUserQuizAfterDismiss = true
                            }
                        )
                    }
                    
                    if isStoryFlag {
                        TutorialStoryModalView(isPresented: $isStoryFlag, isTutorialStart: $isTutorialStart)
                    }
                    
                    if csFlag {
                        HelpStoryModalView(audioManager: audioManager, isPresented: $csFlag)
                    }

                    if isTutorialStart {
                       if let position = downArrowPosition {
                           Color.black.opacity(0.5)
                               .overlay(
                                Group {
                                    Circle()
                                        .frame(width: 100, height: 100)
                                        .position(x: position.x, y: isSmallDevice() ? position.y : position.y + 30)
                                        .blendMode(.destinationOut)
                                }
                           )
                               .ignoresSafeArea()
                               .compositingGroup()
                               .background(.clear)
                               .onTapGesture {
                                   isTutorialStart = false
                               }
                               VStack {
                                   Spacer()
                                   Spacer()
                                   Spacer()
                                   VStack(alignment: .trailing, spacing: .zero) {
                                       Text("「下矢印」をクリックすると進むことができます")
                                           .font(.callout)
                                           .padding(5)
                                           .font(.system(size: 24.0))
                                           .padding(.all, 16.0)
                                           .background(Color("Color2"))
                                           .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 15)
                                           )
                                           .cornerRadius(20)
                                           .padding(.horizontal, 16)
                                           .padding(.bottom)
                                           .foregroundColor(Color("fontGray"))
                                           .shadow(radius: 10)
                                   }
                                   Spacer()
                               }
                               .onTapGesture {
                                   isTutorialStart = false
                               }
                           }
                       }
                    
                    if isLoading {
                        SlimeFullScreenLoadingView()
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showUserStoryQuiz) {
                    VStack {
                        if let user = viewModel.selectedUser {
                            StoryUserQuizListView(
                                isPresenting: $viewModel.showUserStoryQuiz,
                                viewModel: viewModel,
                                user: user,
                                backgroundName: currentStoryBackgroundName
                            )
                        }
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showMonsterQuizList) {
                    if let area = DungeonExpansion.area(at: nextFloor) {
                        DungeonExpansionQuizView(
                            isPresenting: $viewModel.showMonsterQuizList,
                            viewModel: viewModel, monsterName: viewModel.monsterName, area: area
                        )
                    } else {
                        switch viewModel.userPosition {
                        case 1...51:
                            StoryITListView(
                                isPresenting: $viewModel.showMonsterQuizList,
                                monsterName: viewModel.monsterName,
                                backgroundName: "DungeonStorybookForestBackground",
                                viewModel: viewModel
                            )
                        case 52...100:
                            StoryInfoListView(
                                isPresenting: $viewModel.showMonsterQuizList,
                                monsterName: viewModel.monsterName,
                                backgroundName: "DungeonStorybookLavenderCaveBackground",
                                viewModel: viewModel
                            )
                        case 101...150:
                            StoryAppliedListView(
                                isPresenting: $viewModel.showMonsterQuizList,
                                monsterName: viewModel.monsterName,
                                backgroundName: "DungeonStorybookTerracottaDepthBackground",
                                viewModel: viewModel
                            )
                        default:
                            StoryInfoListView(
                                isPresenting: $viewModel.showMonsterQuizList,
                                monsterName: viewModel.monsterName,
                                backgroundName: "DungeonStorybookForestBackground",
                                viewModel: viewModel
                            )
                        }
                    }
                }
                .coordinateSpace(name: "StoryViewCoordinateSpace") // 名前付き座標空間を設定
                .onPreferenceChange(DownArrowPositionKey.self) { position in
                    self.downArrowPosition = position
                }
                .onChange(of: viewModel.showMonsterAlert) { isPresented in
                    if !isPresented && shouldPresentMonsterQuizAfterDismiss {
                        shouldPresentMonsterQuizAfterDismiss = false
                        viewModel.showMonsterQuizList = true
                    }
                }
                .onChange(of: viewModel.showUserStoryAlert) { isPresented in
                    if !isPresented && shouldPresentUserQuizAfterDismiss {
                        shouldPresentUserQuizAfterDismiss = false
                        viewModel.showUserStoryQuiz = true
                    }
                }
                .onAppear {
                    // 初回のみ実行
                    guard !hasAppeared else { return }
                    hasAppeared = true
                    
                    let userDefaults = UserDefaults.standard
                    if !userDefaults.bool(forKey: "hasLaunchedStoryOnappear") {
                        isStoryFlag = true
                        proxy.scrollTo(14, anchor: .top)
                        isLoading = false
                    }
                    userDefaults.set(true, forKey: "hasLaunchedStoryOnappear")
                    
                    userDefaults.synchronize()
                    authManager.fetchUserStoryCsFlag()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if authManager.userStoryCsFlag == 0 {
                            executeProcessEveryfifTimes()
                        }
                    }
                    position = viewModel.userPosition
                    index = viewModel.userPosition
                    
                    // Firebase関連の処理
                    if let userId = AuthManager.shared.currentUserId {
                        viewModel.fetchUserStamina(for: userId)
                        missionManager.fetchMissions { _ in }
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        isLoading = false
                    }
                    
                    // スタミナ回復は一度だけ
                    viewModel.recoverStaminaOnAppLaunch { success in
                        if success {
                            print("スタミナ回復に成功しました。")
                        } else {
                            print("スタミナ回復に失敗しました。")
                        }
                    }
                    
                    viewModel.startStaminaRecoveryTimer()
                    
                    viewModel.fetchUsers() { success in
                        if success {
                            viewModel.fetchStorys()
                        }
                    }
                }
                .onDisappear {
                    // タブ切り替え時にタイマーを停止
                    viewModel.stopStaminaRecoveryTimer()
                }
                // userPosition が取得されたときにスクロール
                .onReceive(viewModel.$isPositionFetched) { fetched in
                    if fetched && !initialScrollDone {
                        scrollToPosition(proxy: proxy, animated: false)
                        initialScrollDone = true
                    }
                }
                // userPosition が変更されたときにスクロール
                .onChange(of: viewModel.userPosition) { newPosition in
                    currentVisiblePosition = newPosition
                    if let userId = AuthManager.shared.currentUserId {
                        viewModel.fetchUserStamina(for: userId)
                    }
                    if initialScrollDone {
                        scrollToPosition(proxy: proxy, animated: false)
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        isPresented = false
                    }
                }
        )
        // アプリのライフサイクルの変更を監視
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                // アプリがバックグラウンドに移行したとき
                viewModel.saveLastActiveTime { success in
                    if success {
                        print("最後のアクティブ時刻を保存しました。")
                    } else {
                        print("最後のアクティブ時刻の保存に失敗しました。")
                    }
                }
            case .active:
                // アプリがアクティブになったとき
                viewModel.recoverStaminaOnAppLaunch { success in
                    if success {
                        print("スタミナ回復に成功しました。")
                    } else {
                        print("スタミナ回復に失敗しました。")
                    }
                }
                viewModel.startStaminaRecoveryTimer()
            default:
                break
            }
        }
    }

    private var boardPlatforms: [PlatformData] {
        PlatformsContainer(viewModel: viewModel, namespace: animationNamespace).platformDatas.flatMap { $0 }
    }

    private var mapZoomGesture: some Gesture {
        MagnificationGesture(minimumScaleDelta: 0.01)
            .updating($pinchMagnification) { value, state, _ in
                state = value
            }
            .onEnded { value in
                mapZoom = min(max(mapZoom * value, minimumMapZoom), maximumMapZoom)
            }
    }

    private var nextFloor: Int {
        min(viewModel.userPosition + 1, PositionViewModel.Constants.finalFloor)
    }

    private var nextPlatform: PlatformData? {
        boardPlatforms.first(where: { $0.position == nextFloor })
    }

    private var nextRival: RankedUser? {
        viewModel.storyUsers.first(where: {
            $0.position == nextFloor &&
            $0.user.id != AuthManager.shared.currentUserId &&
            $0.position != 2
        })
    }

    private var adventureHUD: some View {
        HStack(spacing: 12) {
            if isReturnActive {
                StoryHudActionButton(
                    title: "戻る",
                    systemImage: "chevron.left",
                    action: {
                        generateHapticFeedback()
                        isPresented = false
                        audioManager.playCancelSound()
                    }
                )
            }


            Spacer(minLength: 0)

            StoryInlineStatusChip(
                iconName: "bolt.fill",
                title: "スタミナ",
                value: "\(viewModel.stamina)/\(PositionViewModel.Constants.maxStamina)",
                colors: [Color(hex: "f7971e"), Color(hex: "ffd200")],
                progress: Double(viewModel.stamina) / Double(PositionViewModel.Constants.maxStamina)
            )
        }
    }


    private var claimableCountText: String? {
        missionManager.totalClaimableCount > 0 ? "受取 \(missionManager.totalClaimableCount)" : nil
    }

    private func nextEncounterPreview() -> (title: String, subtitle: String, rewardText: String, rewardIcon: String, colors: [Color], staminaCostText: String) {
        guard viewModel.userPosition < PositionViewModel.Constants.finalFloor else {
            return (
                title: "最深部を踏破済み",
                subtitle: "新しいダンジョン追加まで、復習やミッションで力を蓄えよう",
                rewardText: "復習タイム",
                rewardIcon: "sparkles",
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                staminaCostText: "0"
            )
        }

        if let rival = nextRival {
            return (
                title: "ライバル遭遇: \(rival.user.userName)",
                subtitle: "勝てばスタミナ消費なしで1マス前進。ランキングが近い相手を意識して学べる",
                rewardText: "0で前進",
                rewardIcon: "person.2.fill",
                colors: [Color(hex: "43cea2"), Color(hex: "185a9d")],
                staminaCostText: "0"
            )
        }

        if let boss = nextPlatform?.boss, boss != 0 {
            let rewardSummary = InventoryReward.summaryText(for: DungeonRewardPlanner.battleRewards(for: "ボス\(boss)"), useShortNames: true)
            return (
                title: "\(DungeonExpansion.displayName(for: "ボス\(boss)"))が待ち受ける",
                subtitle: "章の節目。集中して挑めば大きな成長チャンス",
                rewardText: rewardSummary.isEmpty ? "大量XP" : rewardSummary,
                rewardIcon: "crown.fill",
                colors: [Color(hex: "ff416c"), Color(hex: "ff4b2b")],
                staminaCostText: "10"
            )
        }

        if let treasure = nextPlatform?.treasure, treasure != 0 {
            return (
                title: "宝箱\(treasure)を発見",
                subtitle: "コインかアイテム、そして時には冒険を有利にする一時効果も手に入る",
                rewardText: treasureRewardPreview(for: treasure),
                rewardIcon: "shippingbox.fill",
                colors: [Color(hex: "f7971e"), Color(hex: "ffd200")],
                staminaCostText: "10"
            )
        }

        if let monster = nextPlatform?.monster, monster != 0 {
            return (
                title: "モンスター\(monster)との戦闘",
                subtitle: "連続正解とコンボで一気に押し切ろう",
                rewardText: "XP + コイン",
                rewardIcon: "flame.fill",
                colors: [Color(hex: "ff9a44"), Color(hex: "fc6076")],
                staminaCostText: "10"
            )
        }

        return (
            title: "通常マス",
            subtitle: "次のイベントに向けてテンポよく前進しよう",
            rewardText: "前進",
            rewardIcon: "arrow.up.forward.circle.fill",
            colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            staminaCostText: "10"
        )
    }

    private func treasureRewardPreview(for treasure: Int) -> String {
        let itemRewards = DungeonRewardPlanner.treasureRewards(for: treasure)
        if !itemRewards.isEmpty {
            return InventoryReward.summaryText(for: itemRewards, useShortNames: true)
        }

        switch treasure {
        case 1...3:
            return "100コイン"
        case 4:
            return "300コイン"
        case 5, 7:
            return "200コイン"
        case 6:
            return "300コイン"
        case 8:
            return "500コイン"
        case 9...12:
            return "400コイン"
        case 13:
            return "800コイン"
        case 14, 15:
            return "600コイン"
        case 16...22:
            return "1000コイン"
        case 23...28:
            return "1200コイン"
        case 29:
            return "1500コイン"
        case 30:
            return "2000コイン"
        case 31...60:
            return "\(DungeonExpansion.treasure(for: treasure)?.reward ?? 0)コイン"
        default:
            return "コイン"
        }
    }

    private var currentStoryBackgroundName: String {
        DungeonExpansion.background(at: nextFloor)
    }
    func executeProcessEveryfifTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchStoryCSCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchStoryCSCount")
        
        // 3回に1回の割合で処理を実行
        if count % 10 == 0 {
            csFlag = true
        }
    }
    
    private func updateBackgroundImage(using offsets: [Int: CGFloat]) {
        let switchLine = UIScreen.main.bounds.height * 0.45
        let boundaries = [(51, 1), (101, 52), (151, 101), (201, 151), (251, 201)]
        currentVisiblePosition = boundaries.first(where: { boundary in
            offsets[boundary.0].map { $0 <= switchLine } ?? false
        })?.1 ?? 251
    }

    func backgroundImageName(for position: Int) -> String {
        DungeonExpansion.background(at: position)
    }

    private func scrollToPosition(proxy: ScrollViewProxy, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let scrollAction = {
                proxy.scrollTo("dungeon.floor.\(viewModel.userPosition)", anchor: .bottom)
            }
            if animated {
                withAnimation {
                    scrollAction()
                }
            } else {
                scrollAction()
            }
            // アニメーション完了後に isLoading を false に設定
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // アニメーション時間と合わせる
                isLoading = false
            }
        }
    }
}


struct PlatformData: Identifiable {
    var id: Int { position }
    let imageName: String
    let position: Int
    let padding: EdgeInsets?
    let padding1: EdgeInsets?
    let paddingMonster: EdgeInsets?
    let paddingTreasure: EdgeInsets?
    let boss: Int?
    let treasure: Int?
    let monster: Int?
    
    init(
        imageName: String,
        position: Int,
        padding: EdgeInsets? = nil,
        padding1: EdgeInsets? = nil,
        paddingMonster: EdgeInsets? = nil,
        paddingTreasure: EdgeInsets? = nil,
        boss: Int = 0,
        treasure: Int = 0,
        monster: Int = 0
    ) {
        self.imageName = imageName
        self.position = position
        self.padding = padding
        self.padding1 = padding1
        self.paddingMonster = paddingMonster
        self.paddingTreasure = paddingTreasure
        self.boss = boss
        self.treasure = treasure
        self.monster = monster
    }
}

struct StoryHudActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct StoryHudIconButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
                .padding(10)
                .background(Color.black.opacity(0.28))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct StoryHudStatCard: View {
    let title: String
    let value: String
    let iconName: String
    let colors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white.opacity(0.72))

            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(minWidth: 112, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            colors.first?.opacity(0.24) ?? Color.white.opacity(0.1),
                            Color.black.opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct StoryInlineStatusChip: View {
    let iconName: String
    let title: String
    let value: String
    let colors: [Color]
    let progress: Double?

    init(
        iconName: String,
        title: String,
        value: String,
        colors: [Color],
        progress: Double? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.value = value
        self.colors = colors
        self.progress = progress
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.74))

                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            if let progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.22))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: colors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * min(max(progress, 0), 1))
                    }
                }
                .frame(height: 5)
            }
        }
        .frame(minWidth: progress == nil ? nil : 132)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            colors.first?.opacity(0.26) ?? Color.white.opacity(0.14),
                            Color.black.opacity(0.12)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value)")
    }
}

struct StoryCompactInfoChip: View {
    let iconName: String
    let text: String
    var highlight: String? = nil

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            if let highlight {
                Text(highlight)
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Capsule())
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.14))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct MissionProgressStripView: View {
    let mission: Mission
    let claimableCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("今日の注目ミッション")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.74))
                Spacer()
                if claimableCount > 0 {
                    Text("受け取り \(claimableCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "ff416c").opacity(0.9))
                        .clipShape(Capsule())
                }
            }

            Text(mission.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            ProgressView(value: mission.progressPercentage)
                .tint(.white)

            HStack {
                Text("\(mission.currentCount)/\(mission.targetCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.72))
                Spacer()
                Text(mission.isCompleted ? "達成済み" : "進行中")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct DungeonBoostChipView: View {
    let boost: DungeonBoost

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: boost.type.symbolName)
            Text(boost.type.shortTitle)
                .font(.system(size: 12, weight: .bold))
            Text("x\(boost.charges)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.78))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: boost.type.accentColors.map { $0.opacity(0.88) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

struct DungeonSegmentTrackView: View {
    let progress: CGFloat
    let chapter: DungeonChapterInfo

    private let checkpoints: [(title: String, floor: Int)] = [
        ("Start", 1),
        ("Boss 1", 52),
        ("Boss 2", 101),
        ("Boss 3", 150),
        ("Boss 4", 200),
        ("Boss 5", 250),
        ("Final", 300)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("冒険ルート")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(chapter.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.72))
                    .lineLimit(1)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.14))
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: chapter.accentColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * progress, 12), height: 8)

                    HStack {
                        ForEach(Array(checkpoints.enumerated()), id: \.offset) { entry in
                            let index = entry.offset
                            let item = entry.element
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(progress >= checkpointProgress(index: index) ? Color.white : Color.white.opacity(0.32))
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.18), lineWidth: 2)
                                    )
                                Text(item.title)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.72))
                            }
                            if index != checkpoints.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .offset(y: -10)
                }
            }
            .frame(height: 28)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func checkpointProgress(index: Int) -> CGFloat {
        CGFloat(checkpoints[index].floor - 1) / CGFloat(PositionViewModel.Constants.finalFloor - 1)
    }
}

struct TileStatusBadgeView: View {
    let title: String
    let subtitle: String
    let colors: [Color]

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
            Text(subtitle)
                .font(.system(size: 10, weight: .semibold))
                .opacity(0.82)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: colors.first?.opacity(0.28) ?? .clear, radius: 8, y: 4)
    }
}

// PlatformsContainer の定義
struct PlatformsContainer: View {
    let platformImageName: String
    @ObservedObject var viewModel: PositionViewModel
    let namespace: Namespace.ID
    let platformDatas: [[PlatformData]]
    
    // カスタムイニシャライザ
    init(viewModel: PositionViewModel, namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.namespace = namespace
        self.platformImageName = "DungeonStorybookMossPlatform"
        self.platformDatas = DungeonExpansion.platformRows + [
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 150,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    boss: 35
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 147,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 148,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 149,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 146,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingTreasure: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    treasure: 30
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 145,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 144,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 141,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 142,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 143,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 49
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 140,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 48
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 139,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 138,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 25
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 135,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 136,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 137,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 47
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 134,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 46
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 133,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 132,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 129,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 24
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 130,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 131,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 45
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 128,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 44
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 127,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 126,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 43
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 123,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 124,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 23
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 125,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 122,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -150, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 121,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 120,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 41
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 117,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 40
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 118,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 119,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 116,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 115,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 22
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 114,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 111,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0),
                    monster: 39
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 112,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 113,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 150, trailing: 0),
                    monster: 38
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 110,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 109,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 37
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 108,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 21
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 105,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 106,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 107,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 150, trailing: 0),
                    monster: 36
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position:104,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 103,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 20
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 102,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 101,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    boss: 16
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 98,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 99,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 100,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 97,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingTreasure: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    treasure: 19
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 96,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 95,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 92,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 93,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 94,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 34
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 91,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 33
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 90,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 89,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 18
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 86,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 87,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 88,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 30
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 85,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 31
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 84,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 83,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 80,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 17
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 81,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 82,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 29
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 79,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 25
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 78,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 77,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 24
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 74,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 75,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 16
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 76,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 73,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -150, leading: 0, bottom: 0, trailing: 0),
                    monster: 26
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 72,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 71,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    monster: 23
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 68,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    monster: 22
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 69,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 70,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 67,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 66,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 15
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 65,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 62,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0),
                    monster: 20
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 63,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 64,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 150, trailing: 0),
                    monster: 21
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position:61,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 60,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    monster: 19
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 59,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 14
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 56,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0),
                    monster: 17
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 57,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 58,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 150, trailing: 0),
                    monster: 18
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position:55,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 54,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 13
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 53,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 52,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    boss: 15
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 49,
                    padding: EdgeInsets(top: 0, leading: 30, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 0),
                    treasure: 12
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 50,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 51,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 30),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 30)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 48,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -100, leading: 0, bottom: 0, trailing: 0),
                    monster: 14
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 47,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 46,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    monster: 13
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 43,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 44,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    treasure: 11
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 45,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 42,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -150, leading: 0, bottom: 0, trailing: 0),
                    monster: 12
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 41,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 40,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 10
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 37,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 9
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 38,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 11
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 39,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 36,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 35,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 10
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 34,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 8
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 31,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 9
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 32,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 33,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 30,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 29,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingTreasure: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    treasure: 7
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 28,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 25,
                    padding: EdgeInsets(top: 0, leading: 30, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 26,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 27,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 30),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 30)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 24,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 7
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 23,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 22,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 5
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 19,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 4
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 20,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    paddingMonster: EdgeInsets(top: -90, leading: 0, bottom: 0, trailing: 0),
                    monster: 6
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 21,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                
                PlatformData(
                    imageName: self.platformImageName,
                    position: 18,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 5
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 17,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 16,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 13,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 3
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 14,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 15,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    monster: 8
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 12,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    monster: 4
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 11,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 10,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    monster: 3
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 7,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    monster: 1
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 8,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 9,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingTreasure: EdgeInsets(top: -120, leading: 0, bottom: 0, trailing: 0),
                    treasure: 2
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 6,
                    padding: EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 5,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 4,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -30, trailing: 0),
                    padding1: nil,
                    paddingTreasure: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    treasure: 1
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 1,
                    padding: EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 2,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: -40, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 3,
                    padding: EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0),
                    paddingMonster: EdgeInsets(top: -110, leading: 0, bottom: 0, trailing: 0),
                    monster: 2
                )
            ],
        ]
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                // 外側のForEachをインデックスで回す
                ForEach(platformDatas.indices, id: \.self) { index in
                    let platformSet = platformDatas[index]
                    HStack(spacing: 30) {
                        // 内側のForEachはPlatformDataがIdentifiableなのでid不要
                        ForEach(platformSet) { platformData in
                            ZStack{
                                PlatformView(
                                    imageName: platformData.imageName,
                                    position: platformData.position,
                                    padding: platformData.padding ?? EdgeInsets(),
                                    padding1: platformData.padding1 ?? EdgeInsets(),
                                    paddingMonster: platformData.paddingMonster ?? EdgeInsets(),
                                    paddingTreasure: platformData.paddingTreasure ?? EdgeInsets(),
                                    userPosition: viewModel.userPosition,
                                    onArrowTap: (platformData.position == viewModel.userPosition + 1) ? { viewModel.incrementPosition() } : nil,
                                    namespace: namespace,
                                    treasure: platformData.treasure ?? 0,
                                    monster: platformData.monster ?? 0,
                                    boss: platformData.boss ?? 0,
                                    viewModel: viewModel
                                )
                                .id("dungeon.floor.\(platformData.position)")
                            }
                        }
                    }
                }
            }
        }
    }
}

private enum DungeonCharacterFootprint {
    private static let bottoms = NSCache<NSString, NSNumber>()

    static func height(of name: String, width: CGFloat) -> CGFloat {
        guard let image = UIImage(named: name), image.size.width > 0 else { return width }
        return width * image.size.height / image.size.width
    }

    static func bottom(of name: String, width: CGFloat) -> CGFloat {
        if let cached = bottoms.object(forKey: name as NSString) {
            return width * CGFloat(cached.doubleValue)
        }
        guard let image = UIImage(named: name)?.cgImage else { return width / 2 }
        let maskWidth = 128
        let maskHeight = max(1, Int((CGFloat(maskWidth) * CGFloat(image.height) / CGFloat(image.width)).rounded()))
        var rgba = [UInt8](repeating: 0, count: maskWidth * maskHeight * 4)
        let bottom = rgba.withUnsafeMutableBytes { bytes -> CGFloat in
            guard let context = CGContext(
                data: bytes.baseAddress, width: maskWidth, height: maskHeight,
                bitsPerComponent: 8, bytesPerRow: maskWidth * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else { return CGFloat(image.height) / CGFloat(image.width) / 2 }
            context.draw(image, in: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight))
            let pixels = bytes.bindMemory(to: UInt8.self)
            for row in stride(from: maskHeight - 1, through: 0, by: -1) {
                // Ignore faint edge pixels when locating the visible feet.
                if (0..<maskWidth).contains(where: { pixels[(row * maskWidth + $0) * 4 + 3] > 32 }) {
                    return (CGFloat(row + 1) / CGFloat(maskHeight) - 0.5)
                        * CGFloat(image.height) / CGFloat(image.width)
                }
            }
            return CGFloat(image.height) / CGFloat(image.width) / 2
        }
        bottoms.setObject(NSNumber(value: Double(bottom)), forKey: name as NSString)
        return width * bottom
    }
}

// PlatformView の定義
struct PlatformView: View {
//    let imageName: String
    let position: Int
    let padding: EdgeInsets
    let padding1: EdgeInsets?
    let paddingMonster: EdgeInsets?
    let paddingTreasure: EdgeInsets?
    let userPosition: Int
    let onArrowTap: (() -> Void)?
    let treasure: Int?
    let monster: Int?
    let boss: Int?
    let namespace: Namespace.ID
    @State private var isMovingUp = false
    @State private var isPulsing = false
    @State private var avatarName: String = ""
    @State private var showStaminaAlert: Bool = false
    @State private var isPresentingQuizStory = false
    @ObservedObject var viewModel: PositionViewModel
    @State private var monsterName: String = ""
    @State private var quizStoryData: QuizStoryData? = nil
    @State private var coin: Int = 1
    private var audioManager = AudioManager.shared
    @State private var isPresentingStoryUserQuiz = false
#if DEBUG
    @State private var isSettingDebugPosition = false
    @State private var debugPositionError: String?
#endif
    var otherUser: RankedUser? {
        viewModel.storyUsers.first(where: { $0.position == position && $0.user.id != AuthManager.shared.currentUserId &&  $0.position != 2 })
    }
    
    var imageName: String {
        DungeonExpansion.platformArtwork(at: position)
    }

    var backgroundName: String {
        DungeonExpansion.background(at: min(userPosition + 1, PositionViewModel.Constants.finalFloor))
    }

    private var isWidePlatform: Bool {
        [52, 101, 150].contains(position) || DungeonExpansion.isBossFloor(position)
    }

    var tileFocusDistance: Int {
        abs(position - userPosition)
    }

    var tileOpacity: Double {
        switch tileFocusDistance {
        case 0...1:
            return 1.0
        case 2...5:
            return 0.88
        case 6...10:
            return 0.66
        default:
            return 0.42
        }
    }

    var tileScale: CGFloat {
        1.0
    }

    var tileLayoutWidth: CGFloat {
        isWidePlatform ? 420 : 100
    }

    var tileLayoutHeight: CGFloat {
        isWidePlatform ? 250 : 190
    }

    var platformArtworkWidth: CGFloat {
        isWidePlatform ? 400 : 80
    }

    init(imageName: String, position: Int, padding: EdgeInsets = EdgeInsets(), padding1: EdgeInsets? = nil, paddingMonster: EdgeInsets? = nil, paddingTreasure: EdgeInsets? = nil, userPosition: Int, onArrowTap: (() -> Void)? = nil, namespace: Namespace.ID, treasure: Int? = 0, monster: Int? = 0, boss: Int? = 0, viewModel: PositionViewModel) {
//        self.imageName = imageName
        self.position = position
        self.padding = padding
        self.padding1 = padding1
        self.paddingMonster = paddingMonster
        self.paddingTreasure = paddingTreasure
        self.userPosition = userPosition
        self.onArrowTap = onArrowTap
        self.namespace = namespace
        self.treasure = treasure
        self.monster = monster
        self.boss = boss
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if position <= userPosition {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "ffd200").opacity(position == userPosition ? 0.35 : 0.18),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 52
                        )
                    )
                    .frame(width: 110, height: 110)
                    .padding(padding)
            }

            // プラットフォーム画像
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: platformArtworkWidth)
                .padding(padding)
                .background(
                    Group {
                        if [51, 101, 151, 201, 251].contains(position) {
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: StoryBoundaryOffsetKey.self,
                                    value: [position: geometry.frame(in: .global).midY]
                                )
                            }
                        }
                    }
                )
#if DEBUG
                .contentShape(Rectangle())
                .onTapGesture { moveToPositionForDebug() }
                .accessibilityLabel("開発者モード：\(position)コマへ移動")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("dungeon.debug.move.\(position)")
#endif

            if let otherUser = otherUser {
                if let treasure = treasure, treasure == 0 {
                    if let boss = boss, boss == 0 {
                        if let monster = monster, monster == 0 {
                            if position != userPosition {
                                if position != 1 {
                                        ForEach(otherUser.user.avatars.indices, id: \.self) { index in
                                            let avatarData = otherUser.user.avatars[index]
                                            if let name = avatarData["name"] as? String,
                                               let usedFlag = avatarData["usedFlag"] as? Int,
                                               usedFlag == 1 {
                                                Group {
                                                    if imageName.hasPrefix("DungeonStorybook") {
                                                        groundedCharacter(name, userName: otherUser.user.userName)
                                                    } else {
                                                        VStack(spacing: -20){
                                                            HStack() {
                                                                Text("\(otherUser.user.userName)")
                                                                    .font(.system(size: fontSize(for: otherUser.user.userName, isIPad: true)))
                                                                    .padding(5)
                                                                    .foregroundColor(.white)
                                                                    .fontWeight(.bold)
                                                                    .background(Color.black.opacity(position == userPosition + 1 ? 0.72 : 0.45))
                                                                    .cornerRadius(10)
                                                            }
                                                            .zIndex(1)
                                                            HStack(spacing: 10) {
                                                                Image(name)
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 80)
                                                                    .padding(padding1 ?? EdgeInsets())
                                                            }
                                                        }
                                                        .padding(.top, -60)
                                                    }
                                                }
                                                .onTapGesture {
                                                    if position == userPosition + 1 {
                                                        self.triggerHaptic()
                                                        audioManager.playSound()
                                                        if viewModel.canEnterDungeon {
                                                            viewModel.selectedUser = otherUser.user
                                                            viewModel.showUserStoryAlert = true
                                                        } else {
                                                            viewModel.showStaminaAlert = true
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // アバター表示
            if position == userPosition {
                if imageName.hasPrefix("DungeonStorybook") {
                    groundedCharacter(viewModel.avatarName)
                } else {
                    AvatarView(avatarName: viewModel.avatarName, padding1: padding1)
                }
            }

            // 宝箱表示
            if let treasure = treasure, treasure != 0 && userPosition < position {
                if position >= DungeonExpansion.firstFloor {
                    groundedCharacter(DungeonExpansion.treasureArtwork(for: treasure))
                        .onTapGesture { handleTreasureTap(treasure: treasure) }
                } else {
                    TreasureView(treasure: treasure, paddingTreasure: paddingTreasure) {
                        handleTreasureTap(treasure: treasure)
                    }
                }
            }
            
            // モンスター表示
            if let monster = monster, monster != 0 && userPosition < position {
                if imageName.hasPrefix("DungeonStorybook") {
                    groundedCharacter(DungeonExpansion.artworkName(for: "モンスター\(monster)"))
                        .onTapGesture { handleMonsterTap(monster: monster) }
                } else {
                    MonsterView(monster: monster, paddingMonster: paddingMonster, backgroundName: backgroundName) {
                        handleMonsterTap(monster: monster)
                    }
                }
            }
            
            // ボス表示
            if let boss = boss, boss != 0 && userPosition < position {
                groundedCharacter(
                    DungeonExpansion.artworkName(for: "ボス\(boss)"),
                    userName: DungeonExpansion.area(at: position)?.guardian,
                    width: boss == 16 ? 200 : 250, surfaceDepth: 0.40
                )
                    .shadow(radius: 10)
                    .onTapGesture { handleBossTap(boss: boss) }
            }
            
            // 下矢印表示
            if position == userPosition + 1 {
                DownArrowView(isPulsing: $isPulsing, padding1: padding1) {
                    handleDownArrowTap()
                }
            }
            
//            Text("\(position)")
//                .font(.system(size: 50))
        }
        .frame(width: tileLayoutWidth, height: tileLayoutHeight)
        .scaleEffect(tileScale)
        .opacity(tileOpacity)
#if DEBUG
        .alert("現在地を変更できませんでした", isPresented: Binding(
            get: { debugPositionError != nil },
            set: { if !$0 { debugPositionError = nil } }
        )) {
            Button("OK", role: .cancel) { debugPositionError = nil }
        } message: {
            Text(debugPositionError ?? "")
        }
#endif
    }

    private func groundedCharacter(_ name: String, userName: String? = nil, width: CGFloat = 80, surfaceDepth: CGFloat = 0.22) -> some View {
        // Match the visible feet to the platform surface, independent of PNG padding
        // and the legacy per-tile character padding.
        let platformHeight = DungeonCharacterFootprint.height(of: imageName, width: platformArtworkWidth)
        let surfaceY = (padding.top - padding.bottom) / 2 + platformHeight * (surfaceDepth - 0.5)

        return Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .overlay(alignment: .top) {
                if let userName = userName {
                    Text(userName)
                        .font(.system(size: fontSize(for: userName, isIPad: true), weight: .bold))
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(position == userPosition + 1 ? 0.72 : 0.45))
                        .cornerRadius(10)
                        .fixedSize()
                        .offset(y: -12)
                }
            }
            .offset(
                x: (padding.leading - padding.trailing) / 2,
                y: surfaceY - DungeonCharacterFootprint.bottom(of: name, width: width)
            )
    }

#if DEBUG
    private func moveToPositionForDebug() {
        guard position != userPosition, !isSettingDebugPosition, viewModel.isPositionFetched else { return }
        isSettingDebugPosition = true
        viewModel.setPositionForDebug(position) { result in
            isSettingDebugPosition = false
            if case .failure(let error) = result {
                debugPositionError = error.localizedDescription
            }
        }
    }
#endif
    
    func paddingTop(for boss: Int) -> CGFloat {
        switch boss {
        case 15:
            return -100
        case 16:
            return -100
        case 35:
            return -20
        default:
            return -20
        }
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 16 : 16 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)
//print(text)
//        print(baseFontSize)
        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 8 {
                return baseFontSize - 8
            }  else if text.count >= 6 {
                return baseFontSize - 4
            } else if text.count >= 4 {
                return baseFontSize - 2
            } else {
                return baseFontSize
            }
        }
    }
    
    // モンスタータップ時の処理
    func handleMonsterTap(monster: Int) {
        if viewModel.canEnterDungeon {
            if position == userPosition + 1 {
                viewModel.monsterName = "モンスター\(monster)"
                viewModel.monster = monster
                viewModel.showMonsterAlert = true
            }
        } else {
            viewModel.showStaminaAlert = true
        }
    }
    
    // ボスタップ時の処理
    func handleBossTap(boss: Int) {
        if viewModel.canEnterDungeon {
            if position == userPosition + 1 {
                viewModel.monsterName = "ボス\(boss)"
                viewModel.monster = boss
                viewModel.showMonsterAlert = true
            }
        } else {
            viewModel.showStaminaAlert = true
        }
    }
    
    // 下矢印タップ時の処理
    func handleDownArrowTap() {
        if viewModel.canEnterDungeon {
            if let treasure = treasure, treasure != 0 {
                audioManager.playTittleSound()
                viewModel.coin = treasure
                viewModel.showCoinAlert = true
                onArrowTap?()
                return
            }
            if let boss = boss, boss != 0 {
                audioManager.playSound()
                viewModel.monsterName = "ボス\(boss)"
                viewModel.monster = boss
                viewModel.showMonsterAlert = true
            }
            if let monster = monster, monster != 0 {
                audioManager.playSound()
                viewModel.monsterName = "モンスター\(monster)"
                viewModel.monster = monster
                viewModel.showMonsterAlert = true
            }
            print("monster      :\(String(describing: monster))")
            if let otherUser = otherUser, treasure == 0, boss == 0, monster == 0 {
                viewModel.showUserStoryAlert = true
                viewModel.selectedUser = otherUser.user
            } else {
                print("handleDownArrowTap()")
                if let monster = monster, monster == 0, let boss = boss, boss == 0 {
                    audioManager.playSound()
                    triggerHaptic()
                    onArrowTap?()
                }
            }
        } else {
            viewModel.showStaminaAlert = true
        }
    }
    
    func handleTreasureTap(treasure: Int) {
        if viewModel.canEnterDungeon {
            if position == userPosition + 1 {
                audioManager.playTittleSound()
                viewModel.coin = treasure
                viewModel.showCoinAlert = true
                onArrowTap?()
            }
        } else {
            viewModel.showStaminaAlert = true
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct DownArrowView: View {
    @Binding var isPulsing: Bool
    let padding1: EdgeInsets?
    let onTap: () -> Void
    
    var body: some View {
        Image("下矢印")
            .resizable()
            .frame(width: 50, height: 50)
            .padding(padding1 ?? EdgeInsets())
            .scaleEffect(isPulsing ? 1.4 : 1.0)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: DownArrowPositionKey.self, value: CGPoint(
                            x: geometry.frame(in: .named("StoryViewCoordinateSpace")).midX,
                            y: geometry.frame(in: .named("StoryViewCoordinateSpace")).midY
                        ))
                }
            )
            .padding(.top, -30)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing.toggle()
                }
            }
            .onTapGesture {
                onTap()
            }
    }
}


struct BossView: View {
    let boss: Int
    let paddingTop: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Image("ボス\(boss)")
            .resizable()
            .scaledToFit()
            .shadow(radius: 10)
            .frame(width: boss == 15 ? 250 : boss == 16 ? 200 : 250)
            .padding(.top, paddingTop)
            .onTapGesture {
                onTap()
            }
    }
}


struct MonsterView: View {
    let monster: Int
    let paddingMonster: EdgeInsets?
    let backgroundName: String
    let onTap: () -> Void
    
    var body: some View {
        Image("モンスター\(monster)")
            .resizable()
            .scaledToFit()
            .frame(width: 80)
            .padding(paddingMonster ?? EdgeInsets())
            .onTapGesture {
                onTap()
            }
    }
}


struct TreasureView: View {
    let treasure: Int
    let paddingTreasure: EdgeInsets?
    let onTap: () -> Void
    
    var body: some View {
        Image(DungeonExpansion.treasureArtwork(for: treasure))
            .resizable()
            .frame(width: 80, height: 80)
            .padding(paddingTreasure ?? EdgeInsets())
            .onTapGesture {
                onTap()
            }
    }
}


struct AvatarView: View {
    let avatarName: String
    let padding1: EdgeInsets?
    
    @State private var isMovingUp = false
    
    var body: some View {
        Image("\(avatarName)")
            .resizable()
            .scaledToFit()
            .frame(width: 80)
            .padding(.top, -45)
            .padding(padding1 ?? EdgeInsets())
            .offset(y: isMovingUp ? -3 : 3)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isMovingUp.toggle()
                }
            }
    }
}


// EdgeInsets の拡張
extension EdgeInsets {
    static func leading(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: value, bottom: 0, trailing: 0)
    }
    
    static func bottom(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: 0, bottom: value, trailing: 0)
    }
    
    static func trailing(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: value)
    }
    
    static func bottom(_ value: CGFloat, trailing: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: 0, bottom: value, trailing: trailing)
    }
}

// プレビューの定義
struct StoryViewView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(isReturnActive: .constant(true), isPresented: .constant(false))
    }
}
