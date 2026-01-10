import Foundation
import FirebaseDatabaseInternal
import SwiftUI
import AVKit

enum GachaRarity: String, Codable {
    case normal
    case rare
    case Rrare
    case mekaRare
    case superRare
    case RsuperRare
    case mekaSuperRare
    case ultraRare
    case RultraRare
    case mekaUltraRare
    case legendRare
    case mekaLegendRare
    
    var displayString: String {
        switch self {
        case .normal:
            return "ノーマル"
        case .rare, .Rrare, .mekaRare:
            return "レア"
        case .superRare, .RsuperRare, .mekaSuperRare:
            return "スーパーレア"
        case .ultraRare, .RultraRare, .mekaUltraRare:
            return "ウルトラレア"
        case .legendRare, .mekaLegendRare:
            return "レジェンドレア"
        }
    }
    
    var movieName: String {
        return self.rawValue
    }
    
    var gradientColors: [Color] {
        switch self {
        case .normal:
            return [Color.gray.opacity(0.6), Color.gray.opacity(0.3)]
        case .rare, .Rrare, .mekaRare:
            return [Color.blue.opacity(0.6), Color.cyan.opacity(0.3)]
        case .superRare, .RsuperRare, .mekaSuperRare:
            return [Color.purple.opacity(0.6), Color.pink.opacity(0.3)]
        case .ultraRare, .RultraRare, .mekaUltraRare:
            return [Color.orange.opacity(0.6), Color.yellow.opacity(0.3)]
        case .legendRare, .mekaLegendRare:
            return [Color.red.opacity(0.6), Color.orange.opacity(0.4)]
        }
    }
}

enum GachaMode {
    case normal
    case rare
    case meka
}

class GachaManager {
    struct Item: Codable {
        let name: String
        let attack: Int
        let health: Int
        let probability: Int
        let rarity: GachaRarity
    }
    
    private let mode: GachaMode
    private var items: [Item] = []
    
    init(mode: GachaMode) {
        self.mode = mode
        setupItems()
    }
    
    var gachaCost: Int {
        switch mode {
        case .normal:
            return 300
        case .rare, .meka:
            return 600
        }
    }
    
    private func setupItems() {
        switch mode {
        case .normal:
            items = [
                Item(name: "ネッキー",     attack: 10, health: 20, probability: 25,  rarity: .normal),
                Item(name: "ピョン吉",     attack: 15, health: 15, probability: 25,  rarity: .normal),
                Item(name: "ルイーカ",     attack: 20, health: 10, probability: 25,  rarity: .normal),
                Item(name: "もりこう",     attack: 20, health: 100, probability: 25, rarity: .normal),
                Item(name: "うっさん",     attack: 25, health: 150, probability: 25, rarity: .normal),
                Item(name: "キリキリン",   attack: 30, health: 200, probability: 25, rarity: .normal),
                Item(name: "カゲロウ",     attack: 35, health: 220, probability: 10, rarity: .rare),
                Item(name: "ライム",       attack: 40, health: 240, probability: 10, rarity: .rare),
                Item(name: "ラオン",       attack: 45, health: 260, probability: 10, rarity: .rare),
                Item(name: "レッドドラゴン", attack: 47, health: 280, probability: 5, rarity: .superRare),
                Item(name: "ブルードラゴン", attack: 48, health: 285, probability: 5, rarity: .superRare),
                Item(name: "レインボードラゴン", attack: 50, health: 300, probability: 3, rarity: .ultraRare)
            ]

        case .rare:
            items = [
                Item(name: "忍太",         attack: 20, health: 210, probability: 25, rarity: .Rrare),
                Item(name: "ぴょこん",     attack: 20, health: 215, probability: 25, rarity: .Rrare),
                Item(name: "かみ蔵",       attack: 20, health: 220, probability: 25, rarity: .Rrare),
                Item(name: "キャット夫人", attack: 25, health: 225, probability: 25, rarity: .Rrare),
                Item(name: "ミッチー",     attack: 30, health: 240, probability: 25, rarity: .Rrare),
                Item(name: "ライム兄",     attack: 40, health: 250, probability: 10, rarity: .Rrare),
                Item(name: "幸福のパンダ", attack: 47, health: 260, probability: 5, rarity: .Rrare),
                Item(name: "英雄デル",     attack: 50, health: 300, probability: 10, rarity: .RsuperRare),
                Item(name: "覚醒 ライム",   attack: 56, health: 300, probability: 10, rarity: .RsuperRare),
                Item(name: "七福神 玉",    attack: 72, health: 350, probability: 5, rarity: .RultraRare),
                Item(name: "七福神 福天丸", attack: 75, health: 380, probability: 3, rarity: .RultraRare),
                Item(name: "七福神 金満徳", attack: 100, health: 500, probability: 3, rarity: .legendRare)
            ]

        case .meka:
            items = [
                Item(name: "メカマウス",       attack: 20, health: 210, probability: 25, rarity: .mekaRare),
                Item(name: "メカドック",       attack: 20, health: 215, probability: 25, rarity: .mekaRare),
                Item(name: "メカベアー",       attack: 20, health: 220, probability: 25, rarity: .mekaRare),
                Item(name: "ロボン",           attack: 25, health: 225, probability: 25, rarity: .mekaRare),
                Item(name: "ロボノコ",         attack: 30, health: 240, probability: 25, rarity: .mekaRare),
                Item(name: "ロボカー",         attack: 40, health: 250, probability: 10, rarity: .mekaRare),
                Item(name: "バースト",         attack: 47, health: 260, probability: 5, rarity: .mekaRare),
                Item(name: "古代ロボ マーク",   attack: 30, health: 600, probability: 10, rarity: .mekaSuperRare),
                Item(name: "メカライオネル",   attack: 70, health: 200, probability: 10, rarity: .mekaSuperRare),
                Item(name: "ロボ長 バーグ",     attack: 60, health: 400, probability: 5, rarity: .mekaUltraRare),
                Item(name: "悪意ロボ ルーク",   attack: 70, health: 450, probability: 3, rarity: .mekaUltraRare),
                Item(name: "究極完全体バーグ",   attack: 200, health: 400, probability: 3, rarity: .mekaLegendRare)
            ]
        }
    }
    
    func shuffleItems() {
        items.shuffle()
    }
    
    func drawGacha() -> Item? {
        let totalProbability = items.map { $0.probability }.reduce(0, +)
        let randomNumber = Int.random(in: 0..<totalProbability)
        
        var accumulatedProbability = 0
        for item in items {
            accumulatedProbability += item.probability
            if randomNumber < accumulatedProbability {
                // アバターをFirebaseに追加
                let selectedAvatar = Avatar(name: item.name, attack: item.attack, health: item.health, usedFlag: 0, count: 1)
                AuthManager.shared.addAvatarToUser(avatar: selectedAvatar) { success in
                    if success {
                        print("Avatar successfully added!")
                    } else {
                        print("Failed to add avatar.")
                    }
                }
                return item
            }
        }
        
        return items.first
    }
}

struct GachaView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var gachaManager = GachaManager(mode: .normal)
    
    @State private var userMoney: Int = 0
    @State private var isGachaButtonDisabled: Bool = false
    @State private var obtainedRareItem: GachaManager.Item?
    @State private var obtainedItem: GachaManager.Item?
    
    @State private var showAnimation: Bool = false
    @State private var showResult: Bool = false
    @State private var showCoinModal: Bool = false
    @State private var showUnCoinModal: Bool = false
    
    @State private var otomo10flag: Bool = false
    @State private var otomo20flag: Bool = false
    @State private var showTitleModal: Bool = false
    @State private var obtainedTitle: String = ""
    
    @State private var showRewardAlert: Bool = false
    
    @ObservedObject var audioManager = AudioManager.shared
    @StateObject var reward = Reward()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCoinOptionsAlert: Bool = false
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Color2")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !showResult {
                // ガチャ初期画面
                gachaMainView
            } else {
                // 結果画面
                GachaResultView(
                    item: obtainedItem,
                    gachaCost: gachaManager.gachaCost,
                    onClose: {
                        showResult = false
                        obtainedItem = nil
                    },
                    onPlayAgain: {
                        // 結果画面を閉じずにガチャを再実行
                        obtainedItem = nil  // アイテムだけクリア
                        let cost = gachaManager.gachaCost
                        // コインチェック
                        if userMoney >= cost {
                             // コイン減少（複数回）
                             let decreaseCount = cost / 300
                             var completed = 0
                             
                             for _ in 0..<decreaseCount {
                                 authManager.decreaseUserMoney { success in
                                     if success {
                                         completed += 1
                                         if completed == decreaseCount {
                                             fetchUserMoney()
                                         }
                                     }
                                 }
                             }
                             
                             // ガチャ抽選
                             gachaManager.shuffleItems()
                             if let item = gachaManager.drawGacha() {
                                 obtainedRareItem = item
                                 
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                     showAnimation = true
                                 }
                             }
                             
                            // アバター数チェック
                            checkAvatarCount()
                        } else {
                            // コイン不足
                            showUnCoinModal = true
                        }
                    }
                )
            }
            VStack{
                if showCoinModal {
                    if showUnCoinModal {
                        VStack{
                            HStack{
                                Image("コインが無い")
                                    .resizable()
                                    .frame(width:70,height: 70)
                                VStack(alignment: .leading, spacing:15){
                                    HStack{
                                        Text("コインが足りません")
                                        Spacer()
                                    }
                                    Text("ご購入することもできます")
                                        .font(.system(size: isSmallDevice() ? 17 : 18))
                                }
                                
                            }.padding()
                        }.frame(width: isSmallDevice() ? 330: 340, height:120)
                            .background(Color("Color2"))
                            .font(.system(size: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                    CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
                }
            }
        }
        .onAppear {
            fetchUserMoney()
            reward.LoadReward()
        }
        .fullScreenCover(isPresented: $showAnimation) {
            if let rarity = obtainedRareItem?.rarity {
                GachaAnimationView(rarity: rarity) {
                    showAnimation = false
                    obtainedItem = obtainedRareItem
                    showResult = true
                    fetchUserMoney()
                }
            }
        }
        .alert("コインが足りません", isPresented: $showUnCoinModal) {
            Button(action: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                } else {
                    // リワード広告が読み込まれていない場合
                    showCoinModal = true
                }
            }) {
                Text(reward.rewardLoaded ? "広告を見る (300コイン)" : "広告を読み込み中...")
            }
            Button("コインを購入") {
                showCoinModal = true
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ガチャを引くには\(gachaManager.gachaCost)コインが必要です")
        }
        .alert("300コイン獲得しました。", isPresented: $showRewardAlert) {
            Button("OK") {
                fetchUserMoney()
            }
        }
        .alert("称号獲得!", isPresented: $showTitleModal) {
            Button("OK") {}
        } message: {
            Text(obtainedTitle)
        }
        .onChange(of: reward.rewardEarned) { rewardEarned in
            showRewardAlert = rewardEarned
            if rewardEarned {
                fetchUserMoney()
                reward.rewardEarned = false
            }
        }
        .onChange(of: showCoinModal) { _ in
            fetchUserMoney()
        }
    }
    
    private var gachaMainView: some View {
        VStack(spacing: 30) {
            
            // コイン表示（購入ボタン付き）
            HStack {
                Button(action: {
                    generateHapticFeedback()
                    self.presentationMode.wrappedValue.dismiss()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                }.buttonStyle(.plain)
                .padding(.leading)
                Spacer()
                
                Button(action: {
                    showCoinModal = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("\(userMoney)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("コイン")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        // プラスアイコン
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                            )
                    )
                }
            }
            .padding(.trailing)
            
            Image("ガチャ")
                .resizable()
                .scaledToFit()
            
            // ガチャボタン
            Button(action: startGacha) {
                HStack(spacing: 15) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(spacing: 2) {
                        Text("ガチャを引く")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("\(gachaManager.gachaCost)コイン")
                            .font(.system(size: 14, weight: .medium))
                            .opacity(0.9)
                    }
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    Group {
                        if isGachaButtonDisabled {
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(20)
                .shadow(color: isGachaButtonDisabled ? .purple.opacity(0.6) : .clear, radius: 15, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            }
            .disabled(!isGachaButtonDisabled)
            .padding(.horizontal, 30)
            .padding(.bottom, 0)
            
            // ボタングループ（リワード広告・コイン購入）
            VStack(spacing: 12) {
                // リワード広告ボタン
                // GachaView内のリワード広告ボタンを修正

                Button(action: {
                    if reward.rewardLoaded {
                        reward.ShowReward()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 22, weight: .bold))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("広告を見て")
                                .font(.system(size: 14, weight: .medium))
                            Text("300コイン獲得")
                                .font(.system(size: 18, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: reward.rewardLoaded ? [
                                Color(red: 0.95, green: 0.6, blue: 0.2),
                                Color(red: 0.98, green: 0.75, blue: 0.3)
                            ] : [
                                Color.gray.opacity(0.6),
                                Color.gray.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: reward.rewardLoaded ? Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .overlay(
                        // ローディング中のオーバーレイ
                        Group {
                            if !reward.rewardLoaded {
                                ZStack {
                                    Color.black.opacity(0.3)
                                        .cornerRadius(16)
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                }
                            }
                        }
                    )
                }
                .disabled(!reward.rewardLoaded)
                
                // コイン購入ボタン（新規追加）
                Button(action: {
                    showCoinModal = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("コイン購入")
                            .font(.system(size: 18, weight: .bold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.5),
                                Color(red: 0.3, green: 0.8, blue: 0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.2, green: 0.7, blue: 0.5).opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 30)

            Image("卵レア度")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        }
    }
    
    private func startGacha() {
        let cost = gachaManager.gachaCost
        
        if userMoney >= cost {
            // コイン減少（複数回）
            let decreaseCount = cost / 300
            var completed = 0
            
            for _ in 0..<decreaseCount {
                authManager.decreaseUserMoney { success in
                    if success {
                        completed += 1
                        if completed == decreaseCount {
                            fetchUserMoney()
                        }
                    }
                }
            }
            
            // ガチャ抽選
            gachaManager.shuffleItems()
            if let item = gachaManager.drawGacha() {
                obtainedRareItem = item
                
                showResult = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showAnimation = true
                }
            }
            
            checkAvatarCount()
        } else {
            showUnCoinModal = true
        }
    }
    
    private func fetchUserMoney() {
        authManager.getUserMoney { money in
            self.userMoney = money
            // ボタンの有効/無効を更新（コストに応じて）
            let cost = gachaManager.gachaCost
            isGachaButtonDisabled = money >= cost
        }
    }
    
    private func checkAvatarCount() {
        guard let userId = authManager.currentUserId else { return }
        
        countAvatarsForUser(userId: userId) { avatarCount in
            print("ユーザーのアバターの数: \(avatarCount)")
            
            if avatarCount > 9 {
                authManager.checkTitles(userId: userId, title: "おとも１０種類制覇") { exists in
                    if !exists {
                        otomo10flag = true
                        obtainedTitle = "おとも１０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも１０種類制覇")
                    }
                }
            }
            
            if avatarCount > 19 {
                authManager.checkTitles(userId: userId, title: "おとも２０種類制覇") { exists in
                    if !exists {
                        otomo20flag = true
                        obtainedTitle = "おとも２０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも２０種類制覇")
                    }
                }
            }
        }
    }
    
    private func countAvatarsForUser(userId: String, completion: @escaping (Int) -> Void) {
        let avatarsRef = Database.database().reference().child("users").child(userId).child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value, with: { snapshot in
            let avatarCount = snapshot.childrenCount
            completion(Int(avatarCount))
        })
    }
}

// MARK: - Animation View
struct GachaAnimationView: View {
    let rarity: GachaRarity?
    let onFinished: () -> Void
    
    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var showRays: Bool = false
    @State private var particleOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringScale: CGFloat = 0.3
    @State private var showText: Bool = false
    @State private var shimmerOffset: CGFloat = -300
    @State private var hexagonRotation: Double = 0
    @State private var starBurst: Bool = false
    @State private var energyWave: CGFloat = 0
    
    var rarityColors: [Color] {
        rarity?.gradientColors ?? [.gray, .gray]
    }
    
    var body: some View {
        ZStack {
            // 背景グラデーション（アニメーション付き）
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: rarityColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 動的グラデーションオーバーレイ
                RadialGradient(
                    colors: [
                        rarityColors[0].opacity(0.6),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 400
                )
                .scaleEffect(pulseScale)
                .opacity(opacity * 0.5)
            }
            
            // エネルギーウェーブ（複数層）
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .scaleEffect(energyWave + CGFloat(index) * 0.3)
                    .opacity(1 - energyWave)
            }
            
            // 六角形の回転エフェクト
            ForEach(0..<6) { index in
                HexagonShape()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), rarityColors[0].opacity(0.8), .white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: CGFloat(180 + index * 40), height: CGFloat(180 + index * 40))
                    .rotationEffect(.degrees(hexagonRotation + Double(index * 20)))
                    .scaleEffect(ringScale)
                    .opacity(opacity * (0.8 - Double(index) * 0.1))
            }
            
            // スターバーストエフェクト
            if starBurst {
                ForEach(0..<16) { index in
                    DiamondShape()
                        .fill(
                            LinearGradient(
                                colors: [.white, rarityColors[1].opacity(0.6), .clear],
                                startPoint: .center,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200, height: 8)
                        .offset(x: 100)
                        .rotationEffect(.degrees(Double(index) * 22.5 + rotation * 2))
                        .opacity(opacity * 0.9)
                        .blur(radius: 0.5)
                }
            }
            
            // 光線エフェクト（改良版）
            if showRays {
                // メインの光線（太め）
                ForEach(0..<12) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.9),
                                    rarityColors[0].opacity(0.7),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 600, height: 16)
                        .offset(x: 300)
                        .rotationEffect(.degrees(Double(index) * 30 + rotation))
                        .opacity(opacity * 0.85)
                        .blur(radius: 1)
                }
                
                // サブ光線（細め、逆回転）
                ForEach(0..<24) { index in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 400, height: 4)
                        .offset(x: 200)
                        .rotationEffect(.degrees(Double(index) * 15 - rotation * 1.8))
                        .opacity(opacity * 0.6)
                }
            }
            
            // 改良されたパーティクルシステム
            ForEach(0..<80, id: \.self) { index in
                let angle = Double(index) * (360.0 / 80.0)
                let radius = CGFloat.random(in: 120...300)
                let size = CGFloat.random(in: 2...6)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, rarityColors[1].opacity(0.8), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size, height: size)
                    .position(
                        x: UIScreen.main.bounds.width / 2 + cos(angle * .pi / 180) * radius,
                        y: UIScreen.main.bounds.height / 2 + sin(angle * .pi / 180) * radius
                    )
                    .opacity(particleOpacity * Double.random(in: 0.5...1.0))
                    .blur(radius: 0.5)
            }
            
            // 中央のメインエフェクト
            ZStack {
                // 最外側の爆発エフェクト
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.95),
                                rarityColors[0].opacity(0.7),
                                rarityColors[1].opacity(0.4),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 220
                        )
                    )
                    .frame(width: 440, height: 440)
                    .scaleEffect(pulseScale)
                    .opacity(opacity * 0.9)
                    .blur(radius: 8)
                
                // 中間のグロー
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(1.0),
                                rarityColors[1].opacity(0.8),
                                rarityColors[0].opacity(0.4)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .blur(radius: 3)
                
                // メインの光球
                ZStack {
                    // アウターリング
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white, rarityColors[0].opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 6
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: .white.opacity(0.8), radius: 15)
                    
                    // インナーグロー
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.9),
                                    rarityColors[1].opacity(0.6),
                                    rarityColors[0].opacity(0.3)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .shadow(color: rarityColors[0].opacity(0.9), radius: 30)
                
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // フェーズ1: 初期爆発 (0-0.5秒)
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 1.0
            scale = 1.1
            ringScale = 1.0
        }
        
        // エネルギーウェーブ
        withAnimation(.easeOut(duration: 1.2)) {
            energyWave = 2.0
        }
        
        // パルスエフェクト
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        
        // フェーズ2: スターバースト (0.15秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            starBurst = true
        }
        
        // フェーズ3: 光線表示 (0.25秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            showRays = true
            // 回転アニメーション
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            // 六角形回転
            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                hexagonRotation = -360
            }
        }
        
        // フェーズ4: パーティクル爆発 (0.35秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.5)) {
                particleOpacity = 1.0
            }
        }
        
        // フェーズ5: スケール調整 (0.6秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
        
        // フェーズ6: テキスト登場 (0.9秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                showText = true
            }
            
            // シマーエフェクト
            withAnimation(.easeInOut(duration: 1.2)) {
                shimmerOffset = 350
            }
        }
        
        // フェーズ7: 強調バウンス (1.4秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(3, autoreverses: true)) {
                scale = 1.12
            }
        }
        
        // フェーズ8: フェードアウト開始 (2.8秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
                scale = 1.4
                particleOpacity = 0
            }
            
            // 完全終了
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onFinished()
            }
        }
    }
}

// MARK: - Custom Shapes
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Result View
struct GachaResultView: View {
    let item: GachaManager.Item?
    let gachaCost: Int  // 追加
    let onClose: () -> Void
    let onPlayAgain: () -> Void
    
    @State private var showContent: Bool = false
    @State private var showParticles: Bool = false
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: item?.rarity.gradientColors ?? [.gray, .gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // パーティクルエフェクト
            if showParticles {
                ParticleEffectView()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                if let item = item {
                    // レアリティ表示
                    Text(item.rarity.displayString)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    // キャラクター画像エリア
                    ZStack {
                        // 光の輪
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 250, height: 250)
                            .scaleEffect(showContent ? 1 : 0.3)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.8), value: showContent)
                        
                        // キャラクター画像
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 200, height: 200)
                            
                            Image(item.name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(showContent ? 1 : 0.3)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3), value: showContent)
                    }
                    
                    // キャラクター名
                    Text(item.name)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: showContent)
                    
                    Spacer().frame(height: 30)
                    
                    // ステータス表示
                    HStack(spacing: 40) {
                        HStack(spacing: 8) {
                            VStack{
                                Image("攻撃マーク")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50)
                            }
                            Text("\(item.attack)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                )
                        )
                        
                        HStack(spacing: 8) {
                            VStack{
                                Image("HPマーク")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50)
                            }
                            
                            Text("\(item.health)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                )
                        )
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showContent)
                }
                
                Spacer()
                
                // ボタンエリア（2つのボタン）
                VStack(spacing: 15) {
                    // もう一度引くボタン
                    Button(action: onPlayAgain) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 24))
                            
                            Text("もう一度引く")
                                .font(.system(size: 22, weight: .bold))
                            
                            Text("\(gachaCost)コイン")
                                .font(.system(size: 16, weight: .medium))
                                .opacity(0.9)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    
                    // 閉じるボタン
                    Button(action: onClose) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                            
                            Text("確認")
                                .font(.system(size: 22, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.8), value: showContent)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
                showParticles = true
            }
        }
    }
}

// MARK: - Particle Effect
struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<30 {
            let particle = Particle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.3...0.8)
            )
            particles.append(particle)
        }
        
        animateParticles()
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            for i in 0..<particles.count {
                particles[i].y -= CGFloat.random(in: 1...3)
                particles[i].opacity -= 0.01
                
                if particles[i].opacity <= 0 || particles[i].y < 0 {
                    particles[i].y = UIScreen.main.bounds.height
                    particles[i].x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                    particles[i].opacity = Double.random(in: 0.3...0.8)
                }
            }
        }
    }
}

// MARK: - Coin Purchase View
struct CoinPurchaseView: View {
    @Environment(\.dismiss) var dismiss
    
    // コインパッケージ定義
    struct CoinPackage {
        let coins: Int
        let price: String
        let bonus: String?
        let isPopular: Bool
        let gradientColors: [Color]
    }
    
    let packages = [
        CoinPackage(coins: 500, price: "¥120", bonus: nil, isPopular: false,
                    gradientColors: [Color(red: 0.4, green: 0.6, blue: 0.9), Color(red: 0.3, green: 0.5, blue: 0.8)]),
        CoinPackage(coins: 1200, price: "¥250", bonus: "+200ボーナス", isPopular: true,
                    gradientColors: [Color(red: 0.9, green: 0.6, blue: 0.2), Color(red: 0.8, green: 0.5, blue: 0.1)]),
        CoinPackage(coins: 2500, price: "¥490", bonus: "+500ボーナス", isPopular: false,
                    gradientColors: [Color(red: 0.7, green: 0.3, blue: 0.9), Color(red: 0.6, green: 0.2, blue: 0.8)]),
        CoinPackage(coins: 6000, price: "¥980", bonus: "+1500ボーナス", isPopular: false,
                    gradientColors: [Color(red: 0.9, green: 0.2, blue: 0.4), Color(red: 0.8, green: 0.1, blue: 0.3)])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Color2"),
                        Color("Color2").opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        VStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                            
                            Text("コイン購入")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("お得なパッケージをお選びください")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // コインパッケージ一覧
                        VStack(spacing: 16) {
                            ForEach(packages.indices, id: \.self) { index in
                                CoinPurchasePackageCard(package: packages[index])
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 注意事項
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                                Text("ご注意")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text("• 購入したコインは返金できません")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("• コインの有効期限はありません")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
}

#Preview {
    GachaView()
}
