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
    @Published var coin: Int = 1
    @Published var stamina: Int = 100
    @Published var showStaminaAlert: Bool = false
    @Published var showCoinAlert: Bool = false
    @Published var isPositionFetched: Bool = false // フラグを追加
    
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
        if let userId = AuthManager.shared.currentUserId, let handle = handle {
            dbRef.child("storys").child(userId).child("position").removeObserver(withHandle: handle)
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
    @StateObject var viewModel = PositionViewModel.shared // 共有インスタンスを使用
    @Namespace private var animationNamespace
    @State private var initialScrollDone = false
    @State private var isLoading = false
    @State private var position: Int = 1
    @State private var index: Int = 1

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ZStack {
                    Image("背景1")
                        .resizable()
                        .edgesIgnoringSafeArea(.all) // 背景画像を全体に表示
                    if !isLoading {
                        ActivityIndicator()
                    } else {
                        VStack {
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
                            }.padding(.leading,50)
                            // スタミナゲージ
                            ProgressStoryView(progress: .constant((Float(viewModel.stamina) / 100)))
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .padding(.bottom, 10)
                                .onChange(of: viewModel.userPosition) { newPosition in                                print("viewmodel1:\(viewModel.stamina)")
                                    print("Float(viewModel.stamina / 100):\(Float(viewModel.stamina / 100))")
                                }
                            // スクロールビュー
                            ScrollView {
                                VStack {
                                    PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                                }
                                .padding(.top, 100)
                            }
                            
                        }
                        if viewModel.showCoinAlert {
                            StoryCoinModalView(coin: viewModel.coin, isPresented: $viewModel.showCoinAlert)
                        }
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        position = viewModel.userPosition
                        index = viewModel.userPosition
                        isLoading = true
                        viewModel.fetchUserStamina(for: AuthManager.shared.currentUserId!)
                    }
                }
                // userPosition が取得されたときにスクロール
                .onReceive(viewModel.$isPositionFetched) { fetched in
                    if fetched && !initialScrollDone {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                if viewModel.userPosition < 11 {
                                    proxy.scrollTo(15, anchor: .top)
                                } else if 11 <= viewModel.userPosition && viewModel.userPosition <= 12 {
                                    proxy.scrollTo(15 , anchor: .bottom)
                                } else if 13 <= viewModel.userPosition && viewModel.userPosition <= 15 {
                                    proxy.scrollTo(14 , anchor: .bottom)
                                } else if 16 <= viewModel.userPosition && viewModel.userPosition <= 18 {
                                    proxy.scrollTo(13 , anchor: .bottom)
                                } else if 19 <= viewModel.userPosition && viewModel.userPosition <= 20 {
                                    proxy.scrollTo(12, anchor: .bottom)
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
                        }
                    }
                    initialScrollDone = true
                }
                // userPosition が変更されたときにスクロール
                .onChange(of: viewModel.userPosition) { newPosition in
                    viewModel.fetchUserStamina(for: AuthManager.shared.currentUserId!)
                    if initialScrollDone {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                if viewModel.userPosition < 11 {
                                    proxy.scrollTo(15, anchor: .top)
                                } else if 11 <= viewModel.userPosition && viewModel.userPosition <= 12 {
                                    proxy.scrollTo(15 , anchor: .bottom)
                                } else if 13 <= viewModel.userPosition && viewModel.userPosition <= 15 {
                                    proxy.scrollTo(14 , anchor: .bottom)
                                } else if 16 <= viewModel.userPosition && viewModel.userPosition <= 18 {
                                    proxy.scrollTo(13 , anchor: .bottom)
                                } else if 19 <= viewModel.userPosition && viewModel.userPosition <= 20 {
                                    proxy.scrollTo(12, anchor: .bottom)
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
                        }
                    }
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
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 55,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 56,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 57,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position:54,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 53,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 52,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: nil
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 49,
                    padding: EdgeInsets(top: 0, leading: 40, bottom: -60, trailing: -30),
                    padding1: EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0),
                    treasure: 3
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
                    padding1: EdgeInsets(top: 0, leading: -20, bottom: 120, trailing: 30),
                    boss: 2
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
                    treasure: 10
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
                    treasure: 9
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 37,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
                    treasure: 6
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
                    treasure: 5
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    paddingMonster: EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0),
                    monster: 8
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
                    treasure: 4
                )
            ],
            [
                PlatformData(
                    imageName: self.platformImageName,
                    position: 19,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -60, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
                    padding: EdgeInsets(top: 0, leading: 40, bottom: -60, trailing: -30),
                    padding1: EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 0),
                    paddingTreasure: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0),
                    treasure: 3
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 14,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -30),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: -30)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 15,
                    padding: EdgeInsets(top: 0, leading: -30, bottom: 60, trailing: 30),
                    padding1: EdgeInsets(top: 0, leading: -30, bottom: 120, trailing: 20),
                    boss: 1
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
    let imageName: String
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
    
    init(imageName: String, position: Int, padding: EdgeInsets = EdgeInsets(), padding1: EdgeInsets? = nil, paddingMonster: EdgeInsets? = nil, paddingTreasure: EdgeInsets? = nil, userPosition: Int, onArrowTap: (() -> Void)? = nil, namespace: Namespace.ID, treasure: Int? = 0, monster: Int? = 0, boss: Int? = 0, viewModel: PositionViewModel) {
        self.imageName = imageName
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
                .onTapGesture {
                    if position == userPosition + 1 {
                        if viewModel.stamina >= 10 {
                            if treasure == 1 && userPosition < 4 {
                                AuthManager.shared.addMoney(amount: 100)
                                viewModel.showCoinAlert = true
                            }
                            if let monster = monster, monster != 0 {
                                let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
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
            
            // アバター表示
            if position == userPosition {
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
                                if treasure == 1 && userPosition < 4 {
                                    viewModel.coin = 1
                                    AuthManager.shared.addMoney(amount: 100)
                                }
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
                                if viewModel.stamina >= 10 {
                                    let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
                                    quizStoryData = data
                                    isPresentingQuizStory = true
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
                    .padding(.top,boss == 2 ? -185 : -165)
                    .padding(.leading ,boss == 2 ? 0 : 0)
            } else if boss != 0 {
                Image("")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top,boss == 2 ? -185 : -165)
                    .padding(.leading ,boss == 2 ? 0 : 0)
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
                            if treasure == 1 && userPosition < 4 {
                                AuthManager.shared.addMoney(amount: 100)
                                viewModel.showCoinAlert = true
                            }
                            if let monster = monster, monster != 0 {
                                let data = QuizStoryData(monsterName: "モンスター\(monster)", backgroundName: "ダンジョン背景1")
                                quizStoryData = data
                                isPresentingQuizStory = true
                            } else {
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
