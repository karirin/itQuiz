//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//  Updated UI/UX Design 2026
//

import SwiftUI
import AVFoundation

// MARK: - Modern UI Components

/// モダンなユーザー名表示
struct ModernUserNameBar: View {
    let userName: String
    let onTapRegister: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // ユーザーアイコン
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                )
            
            if userName.isEmpty {
                Button(action: onTapRegister) {
                    HStack(spacing: 4) {
                        Text("名前を登録")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            } else {
                Text(userName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("fontGray"))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

/// モダンなコインバー
struct ModernCoinBar: View {
    let coins: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            // コインアイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: .orange.opacity(0.5), radius: 3, x: 0, y: 2)
                
                Text("¢")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text("\(coins)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color("fontGray"))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .onChange(of: coins) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
}

/// モダンなレベル表示と経験値バー
struct ModernLevelBar: View {
    let level: Int
    let experience: Int
    let maxExperience: Int
    
    private var progress: CGFloat {
        guard maxExperience > 0 else { return 0 }
        return CGFloat(experience) / CGFloat(maxExperience)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // レベルバッジ
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .purple.opacity(0.4), radius: 4, x: 0, y: 2)
                
                VStack(spacing: -2) {
                    Text("Lv")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(level)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // 経験値バー
            ProgressExpBar(level: level, experience: experience)
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    Text("経験値")
//                        .font(.system(size: 11, weight: .medium))
//                        .foregroundColor(.secondary)
//                    Spacer()
//                    Text("\(experience) / \(maxExperience)")
//                        .font(.system(size: 11, weight: .semibold, design: .rounded))
//                        .foregroundColor(Color("fontGray"))
//                }
//                
//                GeometryReader { geometry in
//                    ZStack(alignment: .leading) {
//                        // 背景
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(Color.gray.opacity(0.2))
//                        
//                        // プログレス
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(
//                                LinearGradient(
//                                    colors: [Color.blue, Color.purple],
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .frame(width: geometry.size.width * progress)
//                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
//                        
//                        // シャイン効果
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(
//                                LinearGradient(
//                                    colors: [.white.opacity(0.3), .clear],
//                                    startPoint: .top,
//                                    endPoint: .center
//                                )
//                            )
//                            .frame(width: geometry.size.width * progress)
//                    }
//                }
//                .frame(height: 12)
//            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

/// モダンなステータスカード
struct ModernStatusCard: View {
    let avatarName: String
    let hp: Int
    let baseHp: Int
    let bonusHp: Int
    let attack: Int
    let baseAttack: Int
    let bonusAttack: Int
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: isSmallDevice() ? 0 : -20) {
                ZStack{
                    Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isSmallDevice() ? 150 : 200)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 5, y: 5)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: 0)
                }
                .padding(.trailing, isSmallDevice() ? 20 : 20)
                HStack{
                    VStack{
                        VStack(spacing:0){
                            ZStack {
                                Image("ハートバー")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: isSmallDevice() ? 40 : 40)
                                Text("\(baseHp as? Int ?? 0)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 20))
                                    .padding(.leading,45)
                                    .padding(.top,10)
                            }
                            HStack(spacing:3){
                                ZStack{
                                    Image("上昇バー１")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: isSmallDevice() ? 30 : 30)
                                    HStack(spacing: 0){
                                        Text("＋\(bonusHp as? Int ?? 0)")
                                            .padding(.top,3)
                                            .font(.system(size: 18))
                                        Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:isSmallDevice() ? 30 : 40)
                                            .padding(.top,8)
                                    }
                                    .padding(.leading,40)
                                }.padding(.leading,40)
                            }
                        }
                        VStack(spacing:0){
                            ZStack {
                                Image("攻撃バー")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height:isSmallDevice() ? 40 : 40)
                                Text("\(baseAttack as? Int ?? 0)")
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading,45)
                                    .padding(.top,8)
                                    .font(.system(size: 20))
                            }
                            HStack(spacing:3){
                                ZStack{
                                    Image("上昇バー２")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:isSmallDevice() ? 30 : 30)
                                    HStack(spacing: 0){
                                        Text("＋\(bonusAttack as? Int ?? 0)")
                                            .padding(.top,3)
                                            .font(.system(size:18))
                                        Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:isSmallDevice() ? 30 : 40)
                                            .padding(.top,8)
                                    }
                                    .padding(.leading,40)
                                }.padding(.leading,40)
                            }
                        }
                    }
                }
                .padding(.top, isSmallDevice() ? 10 : 0)
            }
        }
    }
}

/// ステータス行コンポーネント
struct ModernStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int
    let bonus: Int
    let avatarName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // メインステータス
            HStack(spacing: 8) {
                // アイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(value)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color("fontGray"))
                }
                
                Spacer()
            }
            
            // ボーナス表示
            if bonus > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("+\(bonus)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Image(avatarName.isEmpty ? "defaultIcon" : avatarName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
    }
}

/// モダンなお問い合わせボタン
struct ModernHelpButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("ヘルプ")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preference Key
struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userCsFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isPresentingSettingList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingStoryView: Bool = false
    @State private var isPresentingGachaView: Bool = false
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingContactView: Bool = false
    @State private var isPresentingTimeAttakView: Bool = false
    @State private var isPresentingTittleView: Bool = false
    @State private var isPresentingIllustratedView: Bool = false
    @State private var isPresentingPentagonView: Bool = false
    @State private var isPresentingRankingView: Bool = false
    @State private var audioPlayerKettei: AVAudioPlayer?
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showTutorial = true
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isSoundOn: Bool = true
    @State private var isLoading: Bool = true
    @State private var isShowingLoginBonus = false
    @State private var showLoginModal: Bool = false
    @ObservedObject var interstitial = Interstitial()
    @ObservedObject var reward = Reward()
    @State private var rewardFlag: Int = 0
    @State private var customerFlag: Bool = false
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var appState: AppState
    @State private var preFlag: Bool = false
    @State private var helpFlag: Bool = false
    @State private var csFlag: Bool = false
    @State private var startFlag: Bool = false
    @State private var isFlag: Bool = false
    @State private var selectedAvatar: Avatar?
    @State private var isUserExists: Bool? = nil
    @State private var showLoginBonus: Bool = false
    @State private var isPresentingTraining: Bool = false
    @State private var currentBonus: Int = 0
    @State private var loginCount: Int = 0
    @State private var showCoinAlert: Bool = false
    @State private var isSignUpFlag: Bool = true
    @State private var updateNameFlag: Bool = false
    @State private var isPresentingMissionView: Bool = false
    
    // 経験値の最大値（レベルに応じて変更可能）
    private var maxExperience: Int {
        return 100 // または authManager から取得
    }
    
    private var avatarName: String {
        return avatar.first?["name"] as? String ?? ""
    }
    
    private var avatarBonusHp: Int {
        return avatar.first?["health"] as? Int ?? 0
    }
    
    private var avatarBonusAttack: Int {
        return avatar.first?["attack"] as? Int ?? 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    VStack {
                        ActivityIndicator()
                    }
                    .background(Color("Color2"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // 広告バナー
                        if !appState.isSubscribed && authManager.currentUserId != "dzarHuAdiXXLtDjtwIRvIfVhA1A2" {
                            BannerAdView()
                                .frame(height: 60)
                                .padding(.bottom, -10)
                        }
                        
                        ZStack {
                            // 背景
                            Image("背景IT")
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 12) {
                                    // MARK: - ヘッダーエリア
                                    VStack(spacing: 10) {
                                        // 上部バー：ユーザー名、コイン、ヘルプ
                                        HStack {
                                            ModernUserNameBar(
                                                userName: userName,
                                                onTapRegister: {
                                                    updateNameFlag = true
                                                }
                                            )
                                            .onChange(of: updateNameFlag) { _ in
                                                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                                                    self.userName = name ?? ""
                                                    self.avatar = avatar ?? [[String: Any]]()
                                                    self.userMoney = money ?? 0
                                                    self.userHp = hp ?? 100
                                                    self.userAttack = attack ?? 20
                                                    self.tutorialNum = tutorialNum ?? 0
                                                    self.isLoading = false
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            ModernCoinBar(coins: userMoney)
                                            
                                            ModernHelpButton {
                                                generateHapticFeedback()
                                                helpFlag = true
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        // レベルと経験値バー
                                        ModernLevelBar(
                                            level: authManager.level,
                                            experience: authManager.experience,
                                            maxExperience: maxExperience
                                        )
                                        .padding(.horizontal)
                                    }
                                    
                                    // MARK: - ステータスエリア
                                    ModernStatusCard(
                                        avatarName: avatarName,
                                        hp: userHp + avatarBonusHp,
                                        baseHp: userHp,
                                        bonusHp: avatarBonusHp,
                                        attack: userAttack + avatarBonusAttack,
                                        baseAttack: userAttack,
                                        bonusAttack: avatarBonusAttack
                                    )
                                    .padding(.horizontal)
                                    
                                    // MARK: - メニューボタン
                                    VStack(spacing: -5) {
                                        HStack {
                                            VStack {
                                                HStack {
                                                    Spacer()
                                                    ZStack {
                                                        Button(action: {
                                                            generateHapticFeedback()
                                                            self.isPresentingTraining = true
                                                            audioManager.playSound()
                                                        }) {
                                                            Image("ダンジョンボタン")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 150)
                                                        }
                                                        .shadow(radius: 3)
                                                        .padding(.leading, 10)
                                                        .buttonStyle(PressedEffectStyle())
                                                    }
                                                    Spacer()
                                                    Button(action: {
                                                        generateHapticFeedback()
                                                        self.isPresentingQuizList = true
                                                        audioManager.playSound()
                                                    }) {
                                                        Image("トレーニングボタン")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150)
                                                            .background(GeometryReader { geometry in
                                                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                                            })
                                                            .padding(.leading, 10)
                                                    }
                                                    .shadow(radius: 3)
                                                    .padding(.trailing, 35)
                                                    Spacer()
                                                }
                                                
                                                HStack {
                                                    Button(action: {
                                                        generateHapticFeedback()
                                                        self.isPresentingGachaView = true
                                                        audioManager.playSound()
                                                    }) {
                                                        Image("ガチャボタン")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: isSmallDevice() ? 60 : 60)
                                                    }
                                                    .buttonStyle(PressedEffectStyle())
                                                    .shadow(radius: 3)
                                                    
                                                    Button(action: {
                                                        generateHapticFeedback()
                                                        self.isPresentingRankingView = true
                                                        audioManager.playSound()
                                                    }) {
                                                        Image("ランキングストーリーボタン")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: isSmallDevice() ? 55 : 53)
                                                            .padding(.top, 10)
                                                    }
                                                    .shadow(radius: 3)
                                                }
                                                
                                                HStack {
                                                    Button(action: {
                                                        generateHapticFeedback()
                                                        self.isPresentingIllustratedView = true
                                                        audioManager.playSound()
                                                    }) {
                                                        Image("おとも図鑑ボタン")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: isSmallDevice() ? 65 : 65)
                                                            .padding(.trailing, 10)
                                                    }
                                                    .shadow(radius: 3)
                                                    
                                                    Button(action: {
                                                        generateHapticFeedback()
                                                        self.isPresentingTittleView = true
                                                        audioManager.playSound()
                                                    }) {
                                                        Image("称号ボタン")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: isSmallDevice() ? 60 : 60)
                                                            .padding(.top, 10)
                                                    }
                                                    .shadow(radius: 3)
                                                }
                                            }
                                        }
                                    }
                                    .shadow(radius: 3)
                                    
                                    // Navigation Links
                                    VStack {
                                        Group {
                                            NavigationLink("", destination: ManagerListView(isPresenting: $isPresentingQuizList).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizList)
                                            NavigationLink("", destination: StoryView(isReturnActive: .constant(true), isPresented: $isPresentingTraining).navigationBarBackButtonHidden(true), isActive: $isPresentingTraining)
                                            NavigationLink("", destination: GachaManagerView(isPresenting: $isPresentingGachaView), isActive: $isPresentingGachaView)
                                            NavigationLink("", destination: IllustratedView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingIllustratedView)
                                        }
                                        NavigationLink("", destination: TittlesView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingTittleView)
                                        NavigationLink("", destination: RankingView(audioManager: audioManager).navigationBarBackButtonHidden(true), isActive: $isPresentingRankingView)
                                        NavigationLink("", destination: MissionView().navigationBarBackButtonHidden(true), isActive: $isPresentingMissionView)
                                    }
                                }
                            }
                        }
                    }
                    .onPreferenceChange(ViewPositionKey.self) { positions in
                        self.buttonRect = positions.first ?? .zero
                    }
                }
                
                // MARK: - Overlays
                if showLoginBonus {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showLoginBonus = false
                            showCoinAlert = true
                        }
                    StampAnimationView(loginCount: $loginCount)
                        .onTapGesture {
                            showLoginBonus = false
                            showCoinAlert = true
                        }
                }
                
                if customerFlag {
                    ReviewView(isPresented: $customerFlag, helpFlag: $helpFlag)
                }
                
                if csFlag {
                    HelpModalView(isPresented: $csFlag)
                }
                
                if helpFlag {
                    HelpModalView(isPresented: $helpFlag)
                }
                
                if isFlag {
                    ChangeNameView(isPresented: $isFlag, isReturnBtn: .constant(false), tutorialNum: $tutorialNum, authManager: authManager)
                }
                
                if updateNameFlag {
                    ChangeNameView(isPresented: $updateNameFlag, isReturnBtn: .constant(true), tutorialNum: $tutorialNum, authManager: authManager)
                }
                
                if startFlag {
                    TutorialModalView(isPresented: $startFlag, isFlag: $isFlag, showAlert: $startFlag)
                }
                
                // チュートリアルオーバーレイ
                if tutorialNum == 1 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .padding(.leading)
                                    .frame(width: buttonRect.width, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: buttonRect.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect.minY - bubbleHeight)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("「学習モード」をクリックしてください。")
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
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                        }
                        .background(GeometryReader { geometry in
                            Path { _ in
                                DispatchQueue.main.async {
                                    self.bubbleHeight = geometry.size.height + 16
                                }
                            }
                        })
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack {
                        HStack {
                            Button(action: {
                                generateHapticFeedback()
                                tutorialNum = 0
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                Image("スキップ")
                                    .resizable()
                                    .frame(width: 200, height: 60)
                                    .padding(.top, 20)
                            }
                            Spacer()
                        }
                        .padding(.leading)
                        Spacer()
                    }
                }
            }
            .onTapGesture {
                if tutorialNum == 1 {
                    audioManager.playSound()
                    tutorialNum = 0
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                    }
                }
            }
            .fontWeight(.bold)
            .background(Color("Color2"))
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        )
        .alert(isPresented: $showCoinAlert) {
            Alert(
                title: Text("ログインボーナス！！"),
                message: Text("\(currentBonus)コイン獲得しました"),
                dismissButton: .default(Text("OK")) {
                }
            )
        }
        .onAppear {
            let userDefaults = UserDefaults.standard
            if !userDefaults.bool(forKey: "hasLaunchedBeforeOnappear") {
                isSignUpFlag = false
                isFlag = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    authManager.saveUserToDatabase(userName: userName) { success in
                        if success {
                            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                                self.userName = name ?? ""
                                self.avatar = avatar ?? [[String: Any]]()
                                self.userMoney = money ?? 0
                                self.userHp = hp ?? 100
                                self.userAttack = attack ?? 20
                                self.tutorialNum = tutorialNum ?? 0
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
            userDefaults.set(true, forKey: "hasLaunchedBeforeOnappear")
            userDefaults.synchronize()
            if let userId = authManager.currentUserId {
                authManager.checkIfUserIdExists(userId: userId) { exists in
                    self.isUserExists = exists
                    if isUserExists != nil {
                        appState.checkSubscription()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if !appState.isSubscribed {
                                executeProcessEveryFortyTimes()
                            }
                        }
                        authManager.fetchUserCsFlag()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if authManager.userCsFlag != 2 {
                                executeProcessEveryThreeTimes()
                                executeProcessEveryfifTimes()
                            }
                        }
                        authManager.fetchUserRewardFlag()
                        reward.checkRewardReset()
                        authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                            self.userName = name ?? ""
                            self.avatar = avatar ?? [[String: Any]]()
                            self.userMoney = money ?? 0
                            self.userHp = hp ?? 100
                            self.userAttack = attack ?? 20
                            self.tutorialNum = tutorialNum ?? 0
                            self.isLoading = false
                        }
                        authManager.fetchAvatars {
                            self.avatar = authManager.avatars.map { avatar in
                                return ["name": avatar.name]
                            }
                        }
                        authManager.fetchUserExperienceAndLevel()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager)
        }
        .onChange(of: showCoinAlert) { userMoney in
            authManager.getUserMoney { userMoney in
                self.userMoney = userMoney
            }
        }
        .onChange(of: isPresentingQuizList) { isPresenting in
            fetchUserInfoIfNeeded(isPresenting: isPresenting)
            authManager.fetchUserExperienceAndLevel()
            authManager.fetchUserRewardFlag()
        }
        .onChange(of: isPresentingAvatarList) { isPresenting in
            fetchUserInfoIfNeeded(isPresenting: isPresenting)
            authManager.fetchUserExperienceAndLevel()
            authManager.fetchUserRewardFlag()
        }
        .onChange(of: isPresentingTraining) { isPresenting in
            fetchUserInfoIfNeeded(isPresenting: isPresenting)
            authManager.fetchUserExperienceAndLevel()
            authManager.fetchUserRewardFlag()
        }
        .background(Color("purple2").opacity(0.6))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func fetchUserInfoIfNeeded(isPresenting: Bool) {
        if !isPresenting {
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
            }
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func saveLastLoginDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginDate")
    }
    
    func saveLoginBonusReceivedDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginBonusReceivedDate")
    }
    
    func executeProcessEveryThreeTimes() {
        let count = UserDefaults.standard.integer(forKey: "launchCount") + 1
        UserDefaults.standard.set(count, forKey: "launchCount")
        if count % 15 == 0 {
            customerFlag = true
        }
    }
    
    func executeProcessEveryfifTimes() {
        let count = UserDefaults.standard.integer(forKey: "launchCSCount") + 1
        UserDefaults.standard.set(count, forKey: "launchCSCount")
        if count % 10 == 0 {
            csFlag = true
        }
    }
    
    func executeProcessEveryFortyTimes() {
        let count = UserDefaults.standard.integer(forKey: "launchPreCount") + 1
        UserDefaults.standard.set(count, forKey: "launchPreCount")
        if count % 10 == 0 {
            preFlag = true
        }
    }
    
    func checkForLoginBonus() -> Bool {
        let defaults = UserDefaults.standard
        let lastLoginDate = defaults.object(forKey: "lastLoginDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastLoginDate, to: Date())
        if let days = components.day, days > 0 {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Button Style
struct PressedEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Progress Bar (HP用など)
struct ProgressBar: View {
    var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.green))
                
                Rectangle()
                    .frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(.green))
            }
        }
        .cornerRadius(45.0)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(AppState())
    }
}
