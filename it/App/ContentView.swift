//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import AVFoundation

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

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
    @State private var isPresentingSettingView: Bool = false
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
    @State private var currentBonus: Int = 0 // 追加: 現在のボーナス額を保持
    @State private var loginCount: Int = 0
    @State private var showCoinAlert: Bool = false
    @State private var isSignUpFlag: Bool = true
    @State private var updateNameFlag: Bool = false
    
    @State private var isPresentingMissionView: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack{
                if isLoading {
                    VStack{
                        ActivityIndicator()
                    }
                    .background(Color("Color2"))
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                } else {
                    VStack {
                        if !appState.isSubscribed && authManager.currentUserId != "dzarHuAdiXXLtDjtwIRvIfVhA1A2" {
                        BannerAdView()
                            .frame(height: 60)
                            .padding(.bottom, -10)
                    }
                    ZStack{
                        Image("背景IT")
                             .resizable()
                             .edgesIgnoringSafeArea(.all)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing:0) {
                                HStack{
                                    ZStack {
                                        Image("ユーザー名")
                                            .resizable()
                                            .scaledToFit()
                                        Text("\(userName)").padding(.leading,25)
                                        if self.userName.isEmpty {
                                            Color.black.opacity(0.7)
                                                .padding(0)
                                                .cornerRadius(100)
                                                .padding(.vertical,13)
                                                .edgesIgnoringSafeArea(.all)
                                                .onTapGesture {
                                                    updateNameFlag = true
                                                }
                                            Text("名前を登録")
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color(.white))
                                                .onTapGesture {
                                                    updateNameFlag = true
                                                }
                                        }
                                    }
                                    .onChange(of: updateNameFlag) { userMoney in
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
                                    ZStack {
                                        Image("コインバー")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:30)
                                        Text(" \(userMoney)")
                                            .padding(.leading,25)
                                            .padding(.top,3)
                                    }
                                    Button(action: { 
                        generateHapticFeedback()
                                        isPresentingSettingView = true
                                    }) {
                                        Image("お問い合わせバー")
                                            .resizable()
                                            .frame(width:140,height:50)
                                            .shadow(radius: 1)
                                    }
                                    
                                }
                                HStack{
                                    ZStack {
                                        Image("レベルバー")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:30)
                                            .padding(.bottom,5)
                                        Text("\(authManager.level)")
                                            .foregroundColor(Color("fontGray"))
                                            .padding(.leading,25)
                                    }
                                    ProgressExpBar(level: authManager.level, experience: authManager.experience)
                                        .frame(height: 20)
                                }
                            }
                            .padding(.horizontal)
                            VStack(spacing: 10) {
                                ZStack{
                                    HStack(spacing: isSmallDevice() ? 0 : -20) {
                                        ZStack{
                                            Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
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
                                                        Text("\(userHp + (avatar.first?["health"] as? Int ?? 0))")
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
                                                                Text("＋\(avatar.first?["health"] as? Int ?? 0)")
                                                                    .padding(.top,3)
                                                                    .font(.system(size: 18))
                                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
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
                                                        Text("\(userAttack + (avatar.first?["attack"] as? Int ?? 0))")
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
                                                                Text("＋\(avatar.first?["attack"] as? Int ?? 0)")
                                                                    .padding(.top,3)
                                                                    .font(.system(size:18))
                                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
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
                                VStack(spacing:-5){
                                    HStack{
                                        VStack{
                                            HStack{
                                                
//                                                    Button(action: {
//                                                        generateHapticFeedback()
//                                                        self.isPresentingMissionView = true
//                                                        audioManager.playSound()
//                                                    }) {
//                                                        Image("ダンジョンボタン")  // 適切な画像を用意
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(height: 60)
//                                                    }
//                                                    .buttonStyle(PressedEffectStyle())
//                                                    .shadow(radius:3)
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
                                                            .frame(width:150)
                                                    }.shadow(radius:3)
                                                        .padding(.leading ,10)
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
                                                        .frame(width:150)
                                                        .background(GeometryReader { geometry in
                                                            Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                                        })
                                                        .padding(.leading ,10)
                                                }
                                                .shadow(radius:3)
                                                .padding(.trailing,35)
                                                Spacer()
                                            }
                                            HStack{
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
                                                .shadow(radius:3)
                                                Button(action: { 
                        generateHapticFeedback()
                                                    self.isPresentingRankingView = true
                                                    audioManager.playSound()
                                                }) {
                                                    Image("ランキングストーリーボタン")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: isSmallDevice() ? 55 : 53)
                                                        .padding(.top,10)
                                                }.shadow(radius:3)
                                                    
                                            }
                                            HStack{
                                                Button(action: { 
                        generateHapticFeedback()
                                                    // 画面遷移のトリガーをオンにする
                                                    self.isPresentingIllustratedView = true
                                                    audioManager.playSound()
                                                }) {
                                                    Image("おとも図鑑ボタン")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: isSmallDevice() ? 65 : 65)
                                                        .padding(.trailing, 10)
                                                }.shadow(radius:3)
                                                    
                                                Button(action: { 
                        generateHapticFeedback()
                                                    self.isPresentingTittleView = true
                                                    audioManager.playSound()
                                                }) {
                                                    Image("称号ボタン")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: isSmallDevice() ? 60 : 60)
                                                        .padding(.top,10)
                                                }.shadow(radius:3)
                                                    
                                            }
                                        }
                                    }
                                }
                                .shadow(radius: 3)
                                VStack{
                                    Group{
                                        NavigationLink("", destination: ManagerView(audioManager: audioManager,viewModel: RankingViewModel()).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizList)
                                        NavigationLink("", destination: StoryView(isReturnActive: .constant(true), isPresented: $isPresentingTraining).navigationBarBackButtonHidden(true), isActive: $isPresentingTraining)
                                        NavigationLink("", destination: GachaManagerView(isPresenting: $isPresentingGachaView), isActive: $isPresentingGachaView)
                                        
                                        NavigationLink("", destination: IllustratedView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingIllustratedView)
                                    }
                                    NavigationLink("", destination: TittlesView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingTittleView)
                                    NavigationLink("", destination: RankingView(audioManager: audioManager).navigationBarBackButtonHidden(true), isActive: $isPresentingRankingView)
                                    NavigationLink("", destination: ContactView(audioManager: audioManager).navigationBarBackButtonHidden(true), isActive: $isPresentingSettingView)
                                    
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
                    VStack{
                        HStack{
                            Button(action: { 
                        generateHapticFeedback()
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                   }
                            }) {
                                Image("スキップ")
                                    .resizable()
                                    .frame(width:200,height:60)
                                    .padding(.top,20)
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
                    tutorialNum = 0 // タップでチュートリアルを終了
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                        // データベースのアップデートが成功したかどうかをハンドリング
                    }
                }
            }
            .fontWeight(.bold)
                        .background(Color("Color2"))
            }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .simultaneousGesture(               // ← Button と同時認識に変更
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
                    // アラートが閉じられた後のアクションが必要ならここに記述
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
//                        authManager.fetchLastClickedDate(userId: authManager.currentUserId ?? "") { lastDate in
//                            if let lastDate = lastDate {
//                                // 2. 現在の日時との差を計算
//                                let currentDate = Date()
//                                let timeInterval = currentDate.timeIntervalSince(lastDate)
//
//                                // 3. 24時間以上経過しているか確認
//                                if timeInterval >= 86400 {  // 86400秒 = 24時間
//                                    isButtonEnabled = true
//                                } else {
//                                    isButtonEnabled = false
//                                }
//                            } else {
//                                isButtonEnabled = true
//                            }
//                        }
                        authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                            self.userName = name ?? ""
                            self.avatar = avatar ?? [[String: Any]]()
                            self.userMoney = money ?? 0
                            self.userHp = hp ?? 100
                            self.userAttack = attack ?? 20
                            self.tutorialNum = tutorialNum ?? 0
                            self.isLoading = false
                            
//                            if self.userName.isEmpty {
//                                self.isFlag = true
//                            }
                            
//                            authManager.checkAndGrantLoginBonus { granted in
//                                if granted {
//                                    self.currentBonus = self.authManager.loginBonus
//                                    self.loginCount = self.authManager.loginCount
//                                    if isSignUpFlag {
//                                        self.showLoginBonus = true
//                                    }
//                                }
//                            }
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
            .background(Color("purple2").opacity(0.6))  // ここで背景色を設定
            .edgesIgnoringSafeArea(.all)  // 画面の端まで背景色を伸ばす
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
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchCount")
        
        // 3回に1回の割合で処理を実行
        
        if count % 15 == 0 {
            customerFlag = true
        }
    }
    
    func executeProcessEveryfifTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchCSCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchCSCount")
        
        // 3回に1回の割合で処理を実行
        if count % 10 == 0 {
            csFlag = true
        }
    }
    
    func executeProcessEveryFortyTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchPreCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchPreCount")
        
        // 3回に1回の割合で処理を実行
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
            // 1日以上経過している場合はボーナスを付与
            return true
        } else {
            // 1日経過していない場合はボーナスを付与しない
            return false
        }
    }
}

struct PressedEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)   // ちょっと縮む
            .opacity(configuration.isPressed ? 0.7  : 1.0)       // 少し暗く
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ProgressBar: View {
    var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.green))
//                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(.green))
//                    .foregroundColor(Color(UIColor.systemTeal))
//                    .animation(.linear)
            }
        }.cornerRadius(45.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
//        ContentView()
        TopView()
            .environmentObject(AppState())
    }
}
