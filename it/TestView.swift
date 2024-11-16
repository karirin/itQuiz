//
//  TestView.swift
//  it
//
//  Created by Apple on 2024/11/12.
//

import SwiftUI
import Firebase
import Combine

// PositionViewModel の定義
class PositionViewModel: ObservableObject {
    @Published var userPosition: Int = 1
    
    private var dbRef: DatabaseReference
    private var handle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.dbRef = Database.database().reference()
        
        // Observe changes in the authenticated user
        AuthManager.shared.$user
            .compactMap { $0?.uid } // Extract userId if user is logged in
            .sink { [weak self] userId in
                self?.fetchPosition(for: userId)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        // Remove observer when the view model is deallocated
        if let userId = AuthManager.shared.currentUserId {
            dbRef.child("storys").child(userId).child("position").removeObserver(withHandle: handle!)
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
        
        let newPosition = userPosition + 1
        // ローカルで即時に更新し、アニメーションをトリガー
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) { // アニメーションの調整
                self.userPosition = newPosition
            }
        }
        // Firebase に新しい値を送信
        dbRef.child("storys").child(userId).child("position").setValue(newPosition) { error, _ in
            if let error = error {
                print("position の更新に失敗しました: \(error.localizedDescription)")
                // 必要に応じてローカルの userPosition を元に戻す処理を追加
                DispatchQueue.main.async {
                    withAnimation {
                        self.userPosition = newPosition - 1
                    }
                }
            } else {
                print("position が更新されました: \(newPosition)")
            }
        }
    }
}

// TestView の定義
struct TestView: View {
    @StateObject var viewModel = PositionViewModel() // @StateObject として初期化
    @Namespace private var animationNamespace // 名前空間を追加
    
    var body: some View {
        ZStack{
            Image("背景1")
                .resizable()
            ScrollView{
                VStack {
                    PlatformsContainer(viewModel: viewModel, namespace: animationNamespace)
                }
                .padding(.top,100)
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
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0),
                    padding1: EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 0)
                ),
                PlatformData(
                    imageName: self.platformImageName,
                    position: 16,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: -30, trailing: 0),
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
                            boss: platformData.boss ?? 0
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
    
    init(imageName: String, position: Int, padding: EdgeInsets = EdgeInsets(), padding1: EdgeInsets? = nil, userPosition: Int, onArrowTap: (() -> Void)? = nil, namespace: Namespace.ID,treasure: Int? = 0,monster: Int? = 0,boss: Int? = 0) {
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
    }
    
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(padding)
                .onTapGesture {
                    if position == userPosition + 1 {
                        onArrowTap?() // クロージャを呼び出す
                    }
                }
            
            if position == userPosition {
                // 「ライム」に matchedGeometryEffect を適用
                Image("ライム")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, -45)
                    .padding(padding1 ?? EdgeInsets())
//                    .matchedGeometryEffect(id: "lime", in: namespace)
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
                        .onAppear{
                            print("treasure:\(treasure)")
                        }
                }
            }
            
            if let monster = monster, monster != 0 {
                if monster == 1 && userPosition < 7 {
                    Image("モンスター\(monster)")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.top, -90)
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
                        onArrowTap?()
                    }
            }
//            Text("\(position)")
//                .font(.system(size: 50))
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
