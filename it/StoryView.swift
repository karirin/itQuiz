//
//  TestView.swift
//  it
//
//  Created by Apple on 2024/11/12.
//

import SwiftUI
import Firebase
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
    @Published var isPositionFetched: Bool = false // フラグを追加
    @Published var showMonsterQuizList = false
    @Published var avatarName: String = ""
    private let authManager = AuthManager.shared
    
    // MARK: - Private Properties
    private var dbRef: DatabaseReference
    private var handle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    private var staminaRecoveryCancellable: AnyCancellable?
    
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
                self?.fetchPosition(for: userId ?? "")
                self?.fetchUserStamina(for: userId ?? "")
                self?.fetchAvatars(for: userId ?? "")
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
        
        staminaRef.observeSingleEvent(of: .value) { snapshot in
            if let staminaValue = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.stamina = staminaValue
                }
            } else {
                // スタミナが存在しない場合は初期値を設定
                self.stamina = 100
                // self.saveInitialStamina()
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
                print("position の取得に失敗しました")
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
        guard staminaRecoveryCancellable == nil else { return } // 既にタイマーが動作中の場合は無視
        
        staminaRecoveryCancellable = Timer.publish(every: Constants.staminaRecoveryInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recoverStamina()
            }
    }
    
    /// スタミナ回復タイマーを停止する
    func stopStaminaRecoveryTimer() {
        staminaRecoveryCancellable?.cancel()
        staminaRecoveryCancellable = nil
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
    private var audioManager = AudioManager.shared
    @Namespace private var animationNamespace
    @State private var initialScrollDone = false
    @State private var isStorySutaminaModal = false
    @State private var isLoading = true
    @State private var position: Int = 1
    @State private var index: Int = 1
    @State private var currentVisiblePosition: Int = 1
    @Environment(\.scenePhase) var scenePhase

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
//                        if userPreFlag != 1 {
                        BannerStoryView()
                            .frame(height: 60)
//                        }
                        VStack {
                            // スタミナ表示
                            HStack{
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
                                Spacer()
                            }
                        }
                        .padding(.leading, 50)
                        
                        // スタミナゲージ
                        ProgressStoryView(progress: .constant((Float(viewModel.stamina) / 100)))
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .padding(.bottom, 10)
                        
                        // スクロールビュー
                        ScrollView {
                            VStack {
                                PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                            }
                            .padding(.top, 100)
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
                        StoryMonsterModalView(monster: $viewModel.monster, isPresented: $viewModel.showMonsterAlert, showQuizList: $viewModel.showMonsterQuizList, audioManager: audioManager)
                    }
                    
                    if isLoading {
                        VStack {
                            ActivityIndicator()
                        }
                        .background(Color("Color2"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .onAppear{
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        position = viewModel.userPosition
                        index = viewModel.userPosition
                        if let userId = AuthManager.shared.currentUserId {
                             viewModel.fetchUserStamina(for: userId)
                        }
//                    }
                    viewModel.recoverStaminaOnAppLaunch { success in
                        if success {
                            print("スタミナ回復に成功しました。")
                        } else {
                            print("スタミナ回復に失敗しました。")
                        }
                    }
                    
                    // タイマーを開始
                    viewModel.startStaminaRecoveryTimer()
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
//                .onPreferenceChange(ViewOffsetKey.self) { offsets in
//                    // 現在のスクリーン中央のY座標
//                    let screenHeight = UIScreen.main.bounds.height
//                    let centerY = screenHeight / 2
//
//                    // 各PlatformViewのmidYとスクリーン中央との距離を計算
//                    let closest = offsets.min { abs($0.value - centerY) < abs($1.value - centerY) }
//
//                    if let closestPosition = closest?.key {
//                        if currentVisiblePosition != closestPosition {
//                            currentVisiblePosition = closestPosition
//                        }
//                    }
//                }
            }
        }
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
    private func updateBackgroundImageBasedOnScroll(offset: CGFloat) {
        if offset < -300 {
            currentVisiblePosition = 21
        } else if offset < -200 {
            currentVisiblePosition = 11
        } else {
            currentVisiblePosition = 1
        }
    }
    
    private func backgroundImageName(for position: Int) -> String {
        switch position {
        case 1...27:
            return "背景1"
        case 28...51:
            return "背景2"
        case 52...60:
            return "背景3"
        default:
            return "背景1" // デフォルトの背景
        }
    }
    /// スクロール処理と isLoading の設定を行う関数
    private func scrollToPosition(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                if viewModel.userPosition < 7 {
                    proxy.scrollTo(14, anchor: .top)
                } else if 7 <= viewModel.userPosition && viewModel.userPosition <= 10 {
                    proxy.scrollTo(14, anchor: .bottom)
                } else if 11 <= viewModel.userPosition && viewModel.userPosition <= 12 {
                    proxy.scrollTo(13, anchor: .bottom)
                } else if 13 <= viewModel.userPosition && viewModel.userPosition <= 15 {
                    proxy.scrollTo(12, anchor: .bottom)
                } else if 16 <= viewModel.userPosition && viewModel.userPosition <= 18 {
                    proxy.scrollTo(11, anchor: .bottom)
                } else if 19 <= viewModel.userPosition && viewModel.userPosition <= 20 {
                    proxy.scrollTo(10, anchor: .bottom)
                } else {
                    if index % 3 == 0  {
                        position = viewModel.userPosition
                        proxy.scrollTo(isSmallDevice() ? viewModel.userPosition : viewModel.userPosition, anchor: .bottom)
                    } else {
                        if viewModel.userPosition == 21 {
                            position = viewModel.userPosition
                            proxy.scrollTo(isSmallDevice() ? viewModel.userPosition : viewModel.userPosition, anchor: .bottom)
                        } else {
                            proxy.scrollTo(isSmallDevice() ? position : position, anchor: .bottom)
                        }
                    }
                    index += 1
                }
            }
//            // アニメーション完了後に isLoading を true に設定
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // アニメーション時間と合わせる
                isLoading = false
            }
        }
    }
}


struct PlatformData: Identifiable {
    let id = UUID()
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
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 97,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 98,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 99,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 96,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 95,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 94,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 91,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 92,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 93,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 90,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 89,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 88,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 85,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 86,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 87,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 84,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 83,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 82,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 79,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 80,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 81,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 78,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 77,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 76,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 73,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 74,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 75,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 72,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 71,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 70,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 67,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 68,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 69,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 66,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 65,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 64,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 61,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 62,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 63,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position:60,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 59,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 58,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 55,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 56,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 57,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                )
//            ],
//            [
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position:54,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 53,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 52,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
//                    padding1: nil
//                )
//            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 49,
                    padding: EdgeInsets(top: 0, leading: 40, bottom: -60, trailing: -30),
                    padding1: EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 0),
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
                    padding: EdgeInsets(top: 0, leading: -20, bottom: 60, trailing: 30),
                    padding1: EdgeInsets(top: 0, leading: -10, bottom: 120, trailing: 30),
                    boss: 16
                )
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 49,
//                    padding: EdgeInsets(top: 0, leading: 45, bottom: -60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 50,
//                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
//                ),
//                PlatformData(
//                    imageName: self.platformImageName,
//                    position: 51,
//                    padding: EdgeInsets(top: 0, leading: -45, bottom: 60, trailing: 0),
//                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
//                    boss: 2
//                )
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
                    padding1: EdgeInsets(top: 0, leading: -50, bottom: 120, trailing: 0),
                    boss: 15
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
                                .id(platformData.position)
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
    @State private var backgroundName: String = ""
    @State private var quizStoryData: QuizStoryData? = nil
    @State private var coin: Int = 1
    private var audioManager = AudioManager.shared
    
    var imageName: String {
        position >= 28 ? position == 51 ? "ボス足場2" : "足場2" : position == 27 ? "ボス足場1" : "足場1"
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
                .frame(width: 80, height: 80)
                .padding(padding)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ViewOffsetKey.self, value: [position: geometry.frame(in: .global).midY])
                    }
                )
//                .onTapGesture {
//                    self.triggerHaptic()
//                    if viewModel.stamina >= 10 {
//                        if let treasure = treasure, treasure != 0 {
//                            audioManager.playTittleSound()
//                            viewModel.coin = treasure
//                            viewModel.showCoinAlert = true
//                            onArrowTap?()
//                        }
//                        if let boss = boss, boss != 0 {
//                            audioManager.playSound()
//                            let data = QuizStoryData(monsterName: "ボス\(boss)", backgroundName: "ダンジョン背景1")
//                            viewModel.monsterName = "ボス\(boss)"
//                            viewModel.monster = boss
//                            viewModel.showMonsterAlert = true
//                        }
//                        if let monster = monster, monster != 0 {
//                            audioManager.playSound()
//                            let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
////                                quizStoryData = data
//                            viewModel.monsterName = "モンスター\(monster)"
//                            viewModel.monster = monster
//                            viewModel.showMonsterAlert = true
//                        }
//                        if let monster = monster, monster == 0, let boss = boss, boss == 0 {
//                            onArrowTap?()
//                        }
//                    } else {
//                        viewModel.showStaminaAlert = true
//                    }
//                }
            
            // アバター表示
            if position == userPosition {
                Image("\(viewModel.avatarName)")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, -45)
                    .padding(padding1 ?? EdgeInsets())
                    .offset(y: isMovingUp ? -3 : 3)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            isMovingUp.toggle()
                        }
                    }
            } else {
                Image("")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, -45)
                    .padding(padding1 ?? EdgeInsets())
            }
            
            // 宝箱表示
            if let treasure = treasure, treasure != 0 && userPosition < position {
                Image("宝箱\(treasure)")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(paddingTreasure ?? EdgeInsets())
                    .onTapGesture {
                        if viewModel.stamina >= 10 {
                            if position == userPosition + 1 {
                                self.triggerHaptic()
                                audioManager.playTittleSound()
                                viewModel.coin = treasure
                                viewModel.showCoinAlert = true
                                onArrowTap?()
                            }
                        } else {
                            viewModel.showStaminaAlert = true
                        }
                    }
            } else {
                Image("")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(paddingTreasure ?? EdgeInsets())
            }
            
            // モンスター表示
            if let monster = monster, monster != 0 && userPosition < position {
                    Image("モンスター\(monster)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .padding(paddingMonster ?? EdgeInsets())
                        .onTapGesture {
                            if position == userPosition + 1 {
                                self.triggerHaptic()
                                audioManager.playSound()
                                if viewModel.stamina >= 10 {
                                    let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
                                    quizStoryData = data
                                    viewModel.monsterName = "モンスター\(monster)"
                                    viewModel.monster = monster
                                    viewModel.showMonsterAlert = true
                                } else {
                                    viewModel.showStaminaAlert = true
                                }
                            }
                        }
                } else if monster != 0 {
                    Image("")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .padding(paddingMonster ?? EdgeInsets())
                }
            
            // ボス表示
            if let boss = boss, boss != 0 && userPosition < position {
                Image("ボス\(boss)")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top,boss == 16 ? -185 : -165)
                    .padding(.leading ,boss == 16 ? 0 : 0)
                    .onTapGesture {
                        if position == userPosition + 1 {
                            self.triggerHaptic()
                            audioManager.playSound()
                            if viewModel.stamina >= 10 {
                                let data = QuizStoryData(monsterName: "ボス\(boss)", backgroundName: "ダンジョン背景1")
                                quizStoryData = data
                                isPresentingQuizStory = true
                            } else {
                                viewModel.showStaminaAlert = true
                            }
                        }
                    }
            } else if boss != 0 {
                Image("")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top,boss == 16 ? -185 : -165)
                    .padding(.leading ,boss == 16 ? 0 : 0)
            }
            
            // 下矢印表示
            if position == userPosition + 1 {
                Image("下矢印")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.top, -30)
                    .padding(padding1 ?? EdgeInsets())
                    .scaleEffect(isPulsing ? 1.4 : 1.0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            isPulsing.toggle()
                        }
                    }
                    .onTapGesture {
                        if viewModel.stamina >= 10 {
                            if let treasure = treasure, treasure != 0 {
                                audioManager.playTittleSound()
                                viewModel.coin = treasure
                                viewModel.showCoinAlert = true
                                onArrowTap?()
                            }
                            if let boss = boss, boss != 0 {
                                audioManager.playSound()
                                let data = QuizStoryData(monsterName: "ボス\(boss)", backgroundName: "ダンジョン背景1")
                                viewModel.monsterName = "ボス\(boss)"
                                viewModel.monster = boss
                                viewModel.showMonsterAlert = true
                            }
                            if let monster = monster, monster != 0 {
                                audioManager.playSound()
                                let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
//                                quizStoryData = data
                                viewModel.monsterName = "モンスター\(monster)"
                                viewModel.monster = monster
                                viewModel.showMonsterAlert = true
                            }
                            if let monster = monster, monster == 0, let boss = boss, boss == 0 {
                                if let treasure = treasure, treasure == 0 {
                                    audioManager.playSound()
                                }
                                self.triggerHaptic()
                                onArrowTap?()
                            }
                        } else {
                            viewModel.showStaminaAlert = true
                        }
                    }
            } else {
                Image("")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.top, -30)
                    .padding(padding1 ?? EdgeInsets())
            }
            
//            Text("\(position)")
//                .font(.system(size: 50))
        }
        .fullScreenCover(isPresented: $viewModel.showMonsterQuizList) {
            if position < 28 {
                StoryITListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景1",
                    viewModel: viewModel
                )
            } else {
                StoryInfoListView(
                    isPresenting: $viewModel.showMonsterQuizList,
                    monsterName: viewModel.monsterName,
                    backgroundName: "ダンジョン背景1",
                    viewModel: viewModel
                )
            }
        }
    }
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
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
        StoryView()
    }
}
