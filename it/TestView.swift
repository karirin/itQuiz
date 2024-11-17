//
//  TestView.swift
//  it
//
//  Created by Apple on 2024/11/12.
//

import SwiftUI
import Firebase
import Combine

struct QuizStoryData: Identifiable {
    let id = UUID()
    let monsterName: String
    let backgroundName: String
}

// PositionViewModel の定義
class PositionViewModel: ObservableObject {
    @Published var userPosition: Int = 1
    @Published var stamina: Int = 100
    @Published var showStaminaAlert: Bool = false
    @Published var showCoinAlert: Bool = false
    
    private var dbRef: DatabaseReference
    private var handle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    
    static let shared: PositionViewModel = {
        let instance = PositionViewModel()
        return instance
    }()
    
    init() {
        self.dbRef = Database.database().reference()
        
        // Observe changes in the authenticated user
        AuthManager.shared.$user
            .compactMap { $0?.uid } // Extract userId if user is logged in
            .sink { [weak self] userId in
                self?.fetchPosition(for: userId)
                self?.fetchUserStamina(for: userId)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        // Remove observer when the view model is deallocated
        if let userId = AuthManager.shared.currentUserId {
            dbRef.child("storys").child(userId).child("position").removeObserver(withHandle: handle!)
        }
    }
    
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
//                self.saveInitialStamina()
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
                    print("取得した position: \(positionValue)")
                }
            } else if let positionValue = snapshot.value as? Double {
                // FirebaseからDoubleとして取得される場合もあるため
                DispatchQueue.main.async {
                    self.userPosition = Int(positionValue)
                    print("取得した position (Double): \(positionValue)")
                }
            } else {
                print("position の取得に失敗しました")
            }
        }
    }
    
    /// Increment the user's position
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
        guard let userId = AuthManager.shared.currentUserId else {
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
}

// TestView の定義
struct TestView: View {
    @StateObject var viewModel = PositionViewModel() // @StateObject として初期化
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationStack {
            ZStack{
                Image("背景1")
                    .resizable()
                // スタミナ表示
                VStack {
                    HStack {
                        Text("スタミナ: \(viewModel.stamina)/100")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    
                    // スタミナゲージ
                    ProgressView(value: Double(viewModel.stamina), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 10)
                    ScrollView{
                        VStack {
                            PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                        }
                    }
                }
                if viewModel.showCoinAlert {
                    StoryCoinModalView(isPresented: $viewModel.showCoinAlert)
                }
            }
        }
        .alert(isPresented: $viewModel.showStaminaAlert) {
            Alert(
                title: Text("スタミナ不足"),
                message: Text("スタミナが不足しています。スタミナを回復するまで先に進むことができません。"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct PlatformData: Identifiable {
    let id = UUID()
    let imageName: String
    let position: Int
    let padding: EdgeInsets?
    let padding1: EdgeInsets?
    let boss: Int?
    let treasure: Int?
    let monster: Int?
    
    init(
        imageName: String,
        position: Int,
        padding: EdgeInsets? = nil,
        padding1: EdgeInsets? = nil,
        boss: Int = 0,
        treasure: Int = 0,
        monster: Int = 0
    ) {
        self.imageName = imageName
        self.position = position
        self.padding = padding
        self.padding1 = padding1
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
                    position: 18,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 17,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 16,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom:30, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 13,
                    padding: EdgeInsets(top: 0, leading: 40, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -33)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 14,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -30),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: -25)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 15,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    boss: 1
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 12,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
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
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 7,
                    padding: EdgeInsets(top: 0, leading: 15, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0),
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 30),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 30)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 6,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil,
                    treasure: 1
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 1,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 2,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 3,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
        ]
    }
    
    var body: some View {
        VStack(spacing: 0){
            // 外側のForEachをインデックスで回す
            ForEach(platformDatas.indices, id: \.self) { index in
                let platformSet = platformDatas[index]
                HStack(spacing: 30) {
                    // 内側のForEachはPlatformDataがIdentifiableなのでid不要
                    ForEach(platformSet) { platformData in
                        PlatformView(
                            imageName: platformData.imageName,
                            position: platformData.position,
                            padding: platformData.padding ?? EdgeInsets(),
                            padding1: platformData.padding1 ?? EdgeInsets(),
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
//        VStack {
//            HStack(spacing: 30) {
//                
//                PlatformView(
//                    imageName: platformImageName,
//                    position: 18,
//                    padding: .bottom(60),
//                    padding1: .bottom(60),
//                    userPosition: viewModel.userPosition,
//                    onArrowTap: (18 == viewModel.userPosition + 1) ? { viewModel.incrementPosition() } : nil,
//                    namespace: namespace
//                )
    }
}

// PlatformView の定義
struct PlatformView: View {
    let imageName: String
    let position: Int
    let padding: EdgeInsets
    let padding1: EdgeInsets?
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
    
    init(imageName: String, position: Int, padding: EdgeInsets = EdgeInsets(), padding1: EdgeInsets? = nil, userPosition: Int, onArrowTap: (() -> Void)? = nil, namespace: Namespace.ID,treasure: Int? = 0,monster: Int? = 0,boss: Int? = 0, viewModel: PositionViewModel) {
        self.imageName = imageName
        self.position = position
        self.padding = padding
        self.padding1 = padding1
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
                Image(imageName)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(padding)
                    .onTapGesture {
                        if position == userPosition + 1 {
                            if viewModel.stamina >= 10 {
                                if treasure == 1 && userPosition < 4 {
                                    AuthManager.shared.addMoney(amount: 100)
                                    viewModel.showCoinAlert = true
                                }
                                if let monster = monster, monster == 1 && userPosition < 7 {
                                    let data = QuizStoryData(monsterName: "モンスター1", backgroundName: "ダンジョン背景1")
                                    quizStoryData = data
                                    isPresentingQuizStory = true
                                } else {
                                    onArrowTap?()
                                }
                            } else {
                                    viewModel.showStaminaAlert = true
                                }
                            }
                        }
                
                if position == userPosition {
                    // 「ライム」に matchedGeometryEffect を適用
                    Image("\(avatarName)")
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
                }
                
                if let treasure = treasure, treasure != 0 {
                    if treasure == 1 && userPosition < 4 {
                        Image("宝箱\(treasure)")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.top, -35)
                            .onTapGesture {
                                if viewModel.stamina >= 10 {
                                    if treasure == 1 && userPosition < 4 {
                                        AuthManager.shared.addMoney(amount: 100)
                                        viewModel.showCoinAlert = true
                                    }
                                } else {
                                    viewModel.showStaminaAlert = true
                                }
                            }
                    }
                }
                
                if let monster = monster, monster != 0 {
                    if monster == 1 && userPosition < 7 {
                        Image("モンスター\(monster)")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .padding(.top, -80)
                            .onTapGesture {
                                if position == userPosition + 1 {
                                    if viewModel.stamina >= 10 {
                                        if monster == 1 && userPosition < 7 {
                                            let data = QuizStoryData(monsterName: "モンスター1", backgroundName: "ダンジョン背景1")
                                            quizStoryData = data
                                            isPresentingQuizStory = true
                                        } else {
                                            onArrowTap?()
                                        }
                                    } else {
                                        viewModel.showStaminaAlert = true
                                    }
                                }
                            }
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .padding(.top, -125)
                    }
                }
                if let boss = boss, boss != 0 {
                    if boss == 1 && userPosition < 15 {
                        Image("ボス\(boss)")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding(.top, -165)
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding(.top, -165)
                    }
                }
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
                            if position == userPosition + 1 {
                                if viewModel.stamina >= 10 {
                                    if treasure == 1 && userPosition < 4 {
                                        AuthManager.shared.addMoney(amount: 100)
                                        viewModel.showCoinAlert = true
                                    }
                                    if monster == 1 && userPosition < 7 {
                                        let data = QuizStoryData(monsterName: "モンスター1", backgroundName: "ダンジョン背景1")
                                        quizStoryData = data
                                        isPresentingQuizStory = true
                                    } else {
                                        onArrowTap?()
                                    }
                                } else {
                                    viewModel.showStaminaAlert = true
                                }
                            }
                        }
                }
                //            Text("\(position)")
                //                .font(.system(size: 50))
            }
        
        
        .fullScreenCover(item: $quizStoryData) { data in
            StoryListView(
                isPresenting: Binding(
                    get: { self.quizStoryData != nil },
                    set: { if !$0 { self.quizStoryData = nil } }
                ),
                monsterName: data.monsterName,
                backgroundName: data.backgroundName,
                viewModel: viewModel
            )
        }
        .onAppear{
            AuthManager.shared.fetchUsedAvatars { usedAvatars in
                if let firstAvatar = usedAvatars.first {
                    self.avatarName = firstAvatar.name
                } else {
                    self.avatarName = "" // デフォルト値を設定
                }
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
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
