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
    @Published var isStoryRankingModal: Bool = false
    @Published var showMonsterQuizList = false
    @Published var avatarName: String = ""
    private let authManager = AuthManager.shared
    @Published var selectedUser: User? = nil
    
    // MARK: - Private Properties
    private var dbRef: DatabaseReference
    private var handle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    private var staminaRecoveryCancellable: AnyCancellable?
    @Published var storyUsers: [RankedUser] = []
    
    private var isTimerActive = false
    
    // MARK: - Constants
    struct Constants {
        static let maxStamina: Int = 100
        static let staminaRecoveryInterval: TimeInterval = 60 // 60秒 = 1分
        static let staminaRecoveryAmount: Int = 1
    }
    
    // MARK: - Singleton Instance
    static let shared: PositionViewModel = {
        let instance = PositionViewModel()
        return instance
    }()
    
    // MARK: - Initializer
    private init() {
        self.dbRef = Database.database().reference()
        
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
        }
        
        updateStaminaInFirebase()
    }
    
    // スタミナ回復のためのメソッド
    func recoverStaminaOnAppLaunch(completion: @escaping (Bool) -> Void) {
        stopStaminaRecoveryTimer()
        authManager.fetchLastActiveTimeFromFirebase { [weak self] lastActiveTimestamp in
            guard let self = self else {
                completion(false)
                return
            }

            let currentTime = Date().timeIntervalSince1970

            if let lastActive = lastActiveTimestamp {
                let elapsedTime = currentTime - lastActive
                let minutesPassed = Int(elapsedTime / Constants.staminaRecoveryInterval)

                guard minutesPassed > 0 else {
                    print("スタミナ回復の必要なし。経過時間: \(elapsedTime)秒")
                    completion(true)
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
            } else {
                print("lastActiveTimeが存在しないため、スタミナ回復をスキップします。")
            }

            // 最後のアクティブ時刻を現在時刻に更新
            self.authManager.saveLastActiveTimeToFirebase { success in
                completion(success)
                self.startStaminaRecoveryTimer()
            }
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
        }
        updateStaminaInFirebase()
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
                }
            } else {
                // スタミナが存在しない場合は初期値を設定
                self.stamina = 100
                self.saveInitialStamina(for: userId)
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
    
    func fetchAvatars(for userId: String) {
        authManager.fetchAvatars() {}
    }
    
    /// ユーザーのポジションを増加させる
    func incrementPosition() {
        guard let userId = AuthManager.shared.currentUserId else {
            print("User is not logged in.")
            return
        }
        
        // スタミナが十分か確認
        guard self.stamina >= 10 else {
            showStaminaAlert = true
            return
        }
        
        let newPosition = userPosition + 1
        let newStamina = self.stamina - 10
        
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
                        self.stamina = newStamina + 10
                    }
                }
            } else {
                print("position と stamina が更新されました: position=\(newPosition), stamina=\(newStamina)")
            }
        }
    }
    
    func incrementUserPosition() {
        guard let userId = AuthManager.shared.currentUserId else {
            print("User is not logged in.")
            return
        }
        
        // スタミナが十分か確認
        guard self.stamina >= 10 else {
            showStaminaAlert = true
            return
        }
        
        let newPosition = userPosition + 1
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
            }
        }
    }

    /// スタミナを減少させる関数
    func decreaseStamina(by amount: Int = 10) {
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
        if let index = storyUsers.firstIndex(where: { $0.user.id == currentUserID }) {
//            currentUserLevelRank = index + 1
        }
    }
}

// Viewの中心に近いPlatformViewを特定するためのPreferenceKey
struct ViewOffsetKey: PreferenceKey {
    typealias Value = [Int: CGFloat]
    
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
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

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// TestView の定義
struct StoryView: View {
    @StateObject var viewModel = PositionViewModel.shared
    @StateObject var rankingViewModel = RankingViewModel()
    @ObservedObject var audioManager = AudioManager()
    @ObservedObject var authManager = AuthManager()
    @Namespace private var animationNamespace
    @State private var initialScrollDone = false
    @State private var isStorySutaminaModal = false
    @State private var isStoryRankingModal = false
    @State private var isLoading = true
    @State private var position: Int = 1
    @State private var index: Int = 1
    @State private var currentVisiblePosition: Int = 1
    @State private var isSoundOn: Bool = true
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appState = AppState()
    @State private var isStoryFlag: Bool = false
    @State private var isTutorialStart: Bool = false
    @State private var csFlag: Bool = false
    @State private var downArrowPosition: CGPoint? = nil
    @Binding var isReturnActive: Bool
    @Binding var isPresented: Bool
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ZStack {
                    Image(backgroundImageName(for: currentVisiblePosition))
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: currentVisiblePosition)

                    VStack {
                        if appState.isBannerVisible {
                            BannerStortyView()
                                .frame(height: 60)
                        }
                        VStack(spacing:5) {
                                HStack{
                                    if isReturnActive {
                                        Button(action: { 
                        generateHapticFeedback()
                                            isPresented = false
                                            audioManager.playCancelSound()
                                        }) {
                                            Image(systemName: "chevron.left")
                                            Text("戻る")
                                        }
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(30).buttonStyle(.plain)
                                    }
                                Spacer()
                                    Button(action: { 
                        generateHapticFeedback()
                                        audioManager.toggleSound()
                                        audioManager.playSound()
                                        isSoundOn.toggle()
                                    }) {
                                        if isSoundOn {
//                                            HStack {
                                                Image("音声オン")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:40)
//                                                Text("音声オン")
//                                                    .font(.system(size: 12))
//                                                    .fontWeight(.bold)
//                                                    .foregroundColor(.white)
//                                            }
//    //                                        .padding(5)
//                                            .padding(.trailing)
//                                            .background(Color.black.opacity(0.5))
//                                            .cornerRadius(30)
                                        } else {
//                                            HStack {
                                                Image("音声オフ")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:40)
//                                                Text("音声オフ")
//                                                    .fontWeight(.bold)
//                                                    .foregroundColor(.white)
//                                            }
//                                            .padding(5)
//                                            .padding(.trailing)
//                                            .background(Color.black.opacity(0.5))
//                                            .cornerRadius(30)
                                        }
                                    }
                                HStack {
                                    Image("スタミナ")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                    Text("スタミナ: \(viewModel.stamina)/100")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                            }
                            // スタミナゲージ
                            ProgressStoryView(progress: .constant((Float(viewModel.stamina) / 100)))
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .padding(.bottom, 10)
                            HStack{
                                Spacer()
                                Button(action: { 
                        generateHapticFeedback()
                                    audioManager.toggleSound()
                                    audioManager.playSound()
                                    isStoryRankingModal = true
                                }) {
                                    Image("ランキングストーリーボタン")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:45)
                                }
                                
                            }
                        }
                        .padding(.horizontal, 50)
                        // スクロールビュー
                        ScrollView {
                            VStack {
                                PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                            }
                            
                            NavigationLink("", destination: StoryRankingView(viewModel: rankingViewModel, isReturnFlag: .constant(true)).navigationBarBackButtonHidden(true), isActive: $isStoryRankingModal)
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetKey.self, value: geometry.frame(in: .global).minY)
                            }
                        )
                        .onPreferenceChange(ScrollOffsetKey.self) { offset in
                            updateBackgroundImageBasedOnScroll(offset: offset)
                        }
                        
                    }
                    
                    if viewModel.showStaminaAlert {
                        StorySutaminaModalView(isPresented: $viewModel.showStaminaAlert)
                    }
                    
                    if viewModel.showCoinAlert {
                        StoryCoinModalView(coin: viewModel.coin, isPresented: $viewModel.showCoinAlert)
                    }
                    
                    if viewModel.showMonsterAlert {
                        StoryMonsterModalView(monster: $viewModel.monster, isPresented: $viewModel.showMonsterAlert, showQuizList: $viewModel.showMonsterQuizList, audioManager: audioManager, viewModel: viewModel)
                    }
                    
                    if viewModel.showUserStoryAlert {
                        StoryUserModalView(viewModel: viewModel, isPresented: $viewModel.showUserStoryAlert, showQuizList: $viewModel.showUserStoryQuiz, audioManager: audioManager, user: viewModel.selectedUser!)
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
                        VStack {
                            ActivityIndicator()
                        }
                        .background(Color("Color2"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .coordinateSpace(name: "StoryViewCoordinateSpace") // 名前付き座標空間を設定
                .onPreferenceChange(DownArrowPositionKey.self) { position in
                    self.downArrowPosition = position
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
                        scrollToPosition(proxy: proxy)
                        initialScrollDone = true
                    }
                }
                // userPosition が変更されたときにスクロール
                .onChange(of: viewModel.userPosition) { newPosition in
                    if let userId = AuthManager.shared.currentUserId {
                        viewModel.fetchUserStamina(for: userId)
                    }
                    if initialScrollDone {
                        scrollToPosition(proxy: proxy)
                    }
                }
                .onPreferenceChange(ViewOffsetKey.self) { offsets in
                    // 現在のスクリーン中央のY座標
                    let screenHeight = UIScreen.main.bounds.height
                    let centerY = screenHeight / 2

                    // 各PlatformViewのmidYとスクリーン中央との距離を計算
                    let closest = offsets.min { abs($0.value - centerY) < abs($1.value - centerY) }

                    if let closestPosition = closest?.key {
                        if currentVisiblePosition != closestPosition {
                            currentVisiblePosition = closestPosition
                        }
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
    
    private func updateBackgroundImageBasedOnScroll(offset: CGFloat) {
        if offset < -300 {
            currentVisiblePosition = 21
        } else if offset < -200 {
            currentVisiblePosition = 11
        } else {
            currentVisiblePosition = 1
        }
    }
    
    func backgroundImageName(for position: Int) -> String {
        switch position {
        case 1...58:
            return "背景1ダンジョン"
        case 59...103:
            return "背景2ダンジョン"
        case 104...150:
            return "背景3ダンジョン"
        default:
            return "背景1ダンジョン"
        }
    }
    
    struct PositionMapping {
        let range: ClosedRange<Int>
        let target: Int
    }

    let positionMappings: [PositionMapping] = [
        PositionMapping(range: 1...3, target: 51),
        PositionMapping(range: 4...6, target: 50),
        PositionMapping(range: 7...9, target: 49),
        PositionMapping(range: 10...12, target: 48),
        PositionMapping(range: 13...15, target: 47),
        PositionMapping(range: 16...18, target: 46),
        PositionMapping(range: 19...21, target: 45),
        PositionMapping(range: 22...24, target: 44),
        PositionMapping(range: 25...27, target: 43),
        PositionMapping(range: 28...30, target: 42),
        PositionMapping(range: 31...33, target: 41),
        PositionMapping(range: 34...36, target: 40),
        PositionMapping(range: 37...39, target: 39),
        PositionMapping(range: 40...42, target: 38),
        PositionMapping(range: 43...45, target: 37),
        PositionMapping(range: 46...48, target: 36),
        PositionMapping(range: 49...51, target: 35),
        PositionMapping(range: 52...52, target: 34),
        PositionMapping(range: 53...55, target: 33),
        PositionMapping(range: 56...58, target: 32),
        PositionMapping(range: 59...61, target: 31),
        PositionMapping(range: 62...64, target: 30),
        PositionMapping(range: 65...67, target: 29),
        PositionMapping(range: 68...70, target: 28),
        PositionMapping(range: 71...73, target: 27),
        PositionMapping(range: 74...76, target: 26),
        PositionMapping(range: 77...79, target: 25),
        PositionMapping(range: 80...82, target: 24),
        PositionMapping(range: 83...85, target: 23),
        PositionMapping(range: 86...88, target: 22),
        PositionMapping(range: 89...91, target: 21),
        PositionMapping(range: 92...94, target: 20),
        PositionMapping(range: 95...97, target: 19),
        PositionMapping(range: 98...100, target: 18),
        PositionMapping(range: 101...101, target: 17),
        PositionMapping(range: 102...104, target: 16),
        PositionMapping(range: 105...107, target: 15),
        PositionMapping(range: 108...110, target: 14),
        PositionMapping(range: 111...113, target: 13),
        PositionMapping(range: 114...116, target: 12),
        PositionMapping(range: 117...119, target: 11),
        PositionMapping(range: 120...122, target: 10),
        PositionMapping(range: 123...125, target: 9),
        PositionMapping(range: 126...128, target: 8),
        PositionMapping(range: 129...131, target: 7),
        PositionMapping(range: 132...134, target: 6),
        PositionMapping(range: 135...137, target: 5),
        PositionMapping(range: 138...140, target: 4),
        PositionMapping(range: 141...143, target: 3),
        PositionMapping(range: 144...146, target: 2),
        PositionMapping(range: 147...150, target: 1)
    ]
    
    private func scrollToPosition(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                let userPos = viewModel.userPosition
                print("userPos      :\(userPos)")
                if let mapping = positionMappings.first(where: { $0.range.contains(userPos) }) {
                    print("Scroll to position: \(mapping.target)")
                    proxy.scrollTo(mapping.target, anchor: .bottom)
                } else {
                    // デフォルトのスクロール先を設定
                    let defaultTarget = 33
                    print("Default scroll to position: \(defaultTarget)")
                    proxy.scrollTo(defaultTarget, anchor: .bottom)
                }
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
        self.platformImageName = "足場1"
        self.platformDatas = [
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
                    padding: EdgeInsets(top: 0, leading: 60, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 0)
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 60),
                    padding1: EdgeInsets(top: 0, leading: -50, bottom: 120, trailing: 0)
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
                            }
                        }
                    }
                }
            }
        }
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
    var otherUser: RankedUser? {
        viewModel.storyUsers.first(where: { $0.position == position && $0.user.id != AuthManager.shared.currentUserId &&  $0.position != 2 })
    }
    
    var imageName: String {
        if position > 101 {
            if position == 150 {
                return "ボス足場3"
            } else {
                return "足場3"
            }
        } else if position >= 53 {
            if position == 101 {
                return "ボス足場2"
            } else {
                return "足場2"
            }
        } else {
            if position == 52 {
                return "ボス足場1"
            } else {
                return "足場1"
            }
        }
    }
    
    var backgroundName: String {
        get {
            switch viewModel.userPosition {
            case 1...51:
                return "ダンジョン背景1"
            case 52...100:
                return "ダンジョン背景2"
            case 101...150:
                return "ダンジョン背景3"
            default:
                return "ダンジョン背景1" // デフォルトの背景
            }
        }
        set {
            // 必要に応じてsetterを実装。今回は動的置き換えのため空でも可。
            // 例: 何もしない場合
        }
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
            // プラットフォーム画像
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: position == 52 ? 400 : position == 101 ? 400 :  position == 150 ? 400 : 80)
                .padding(padding)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ViewOffsetKey.self, value: [position: geometry.frame(in: .global).midY])
                    }
                )
            
            
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
                                                VStack(spacing: -20){
                                                    HStack() {
                                                        Text("\(otherUser.user.userName)")
                                                            .font(.system(size: fontSize(for: otherUser.user.userName, isIPad: true)))
                                                            .padding(5)
                                                            .foregroundColor(.white)
                                                            .fontWeight(.bold)
                                                            .background(Color.black.opacity(0.5))
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
                                                .onTapGesture {
                                                    if position == userPosition + 1 {
                                                        self.triggerHaptic()
                                                        audioManager.playSound()
                                                        if viewModel.stamina >= 10 {
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
                AvatarView(avatarName: viewModel.avatarName, padding1: padding1)
            }
            
            // 宝箱表示
            if let treasure = treasure, treasure != 0 && userPosition < position {
                TreasureView(treasure: treasure, paddingTreasure: paddingTreasure) {
                    handleTreasureTap(treasure: treasure)
                }
            }
            
            // モンスター表示
            if let monster = monster, monster != 0 && userPosition < position {
                MonsterView(monster: monster, paddingMonster: paddingMonster, backgroundName: backgroundName) {
                    handleMonsterTap(monster: monster)
                }
                }
            
            // ボス表示
            if let boss = boss, boss != 0 && userPosition < position {
                BossView(boss: boss, paddingTop: paddingTop(for: boss)) {
                    handleBossTap(boss: boss)
                }
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
        .fullScreenCover(isPresented: $viewModel.showUserStoryQuiz) {
            VStack {
                if let user = viewModel.selectedUser {
                    StoryUserQuizListView(isPresenting: $viewModel.showUserStoryQuiz, viewModel: viewModel, user: user, backgroundName: backgroundName)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showMonsterQuizList) {
            switch viewModel.userPosition {
            case 1...51:
                StoryITListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景1",
                    viewModel: viewModel
                )
                .onAppear{
                    print("StoryITListView")
                }
            case 52...100:
                StoryInfoListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景2",
                    viewModel: viewModel
                )
                .onAppear{
                    print("StoryInfoListView")
                }
            case 101...150:
                StoryAppliedListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景3",
                    viewModel: viewModel
                )
            default:
                // デフォルトのビュー、またはエラーハンドリング
                StoryInfoListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景1",
                    viewModel: viewModel
                )
            }
        }
    }
    
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
        if viewModel.stamina >= 10 {
            if position == userPosition + 1 {
                let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: backgroundName)
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
        if viewModel.stamina >= 10 {
            if position == userPosition + 1 {
                let data = QuizStoryData(monsterName: "ボス\(boss)", backgroundName: backgroundName)
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
        if viewModel.stamina >= 10 {
            if let treasure = treasure, treasure != 0 {
                audioManager.playTittleSound()
                viewModel.coin = treasure
                viewModel.showCoinAlert = true
                onArrowTap?()
            }
            if let boss = boss, boss != 0 {
                audioManager.playSound()
                let data = QuizStoryData(monsterName: "ボス\(boss)", backgroundName: backgroundName)
                viewModel.monsterName = "ボス\(boss)"
                viewModel.monster = boss
                viewModel.showMonsterAlert = true
            }
            if let monster = monster, monster != 0 {
                audioManager.playSound()
                let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: backgroundName)
                viewModel.monsterName = "モンスター\(monster)"
                viewModel.monster = monster
                viewModel.showMonsterAlert = true
            }
            print("monster      :\(monster)")
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
        if viewModel.stamina >= 10 {
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
        Image("宝箱\(treasure)")
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
