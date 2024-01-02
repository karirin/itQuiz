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
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingGachaView: Bool = false
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingSettingView: Bool = false
    @State private var isPresentingTimeAttakView: Bool = false
    @State private var isPresentingIllustratedView: Bool = false
    @State private var isPresentingPentagonView: Bool = false
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
    
    var body: some View {
        NavigationView {
//            Button(action: {
//                     interstitial.presentInterstitial()
//                 }) {
//                     Text(interstitial.interstitialAdLoaded ? "インタースティシャル広告表示" : "読み込み中...")
//                 }
//                 .onAppear() {
//                     interstitial.loadInterstitial()
//                 }
//                 .disabled(!interstitial.interstitialAdLoaded)
            ZStack{
                if isLoading {
                    // ローディングインジケータの表示
                    Text("")
                        .frame(maxWidth:.infinity,maxHeight:.infinity)
                } else {
                    VStack {
                        HStack{
                            
                            Image(systemName: "person.circle")
                                .foregroundColor(Color("fontGray"))
                            Text("\(userName)")
                                .foregroundColor(Color("fontGray"))
                            Image("コイン")
                                .resizable()
                                .frame(width:20,height:20)
                            Text("+")
                                .foregroundColor(Color("fontGray"))
                            Text(" \(userMoney)")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                            HelpView()
//                            Spacer()
//                            Spacer()
                            
//                            Button(action: {
//                                isPresentingSettingView = true
//                                audioManager.playSound()
//                            }) {
//                                Image(systemName: "gearshape.fill")
//                                    .resizable()
//                                    .frame(width: 40, height: 40)
//                            }
//                            .padding(.leading)
//                            .foregroundColor(Color("gray"))
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        //                ScrollView{
                        VStack{
                            ZStack{
                                
                                Image("image")
                                    .resizable()
                                    .frame(height:200)
                                    .padding(.top,10)
                                    .opacity(0.5)
                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                //                            Image("ぴょん吉")
                                    .resizable()
                                    .frame(width: 140,height:140)
                            }
                            
                            .font(.system(size: 24))
                            VStack{
                                HStack(alignment: .top){
                                    HStack(alignment: .top){
                                        Image("スター")
                                            .resizable()
                                            .frame(width: 25,height:20)
                                        Text("Lv：\(authManager.level)")
                                            .foregroundColor(Color("fontGray"))
                                    }
                                    
                                    HStack(alignment: .top){
                                        Image("ハート")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                        VStack(spacing: 0){
                                            Text("体力：\(userHp + (avatar.first?["health"] as? Int ?? 0))")
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(Color("fontGray"))
                                            HStack{
                                                Text("( + \(avatar.first?["health"] as? Int ?? 0)")
                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                                    .resizable()
                                                    .frame(width: 20,height:20)
                                                Text(")")
                                            }.foregroundColor(Color("fontGray"))
                                        }
                                    }
                                    HStack(alignment: .top){
                                        Image("ソード")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                        VStack(spacing: 0){
                                            Text("攻撃力：\(userAttack + (avatar.first?["attack"] as? Int ?? 0))").foregroundColor(Color("fontGray"))
                                                .multilineTextAlignment(.leading)
                                            HStack{
                                                Text("( + \(avatar.first?["attack"] as? Int ?? 0)")
                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                                    .resizable()
                                                    .frame(width: 20,height:20)
                                                Text(")")
                                            }.foregroundColor(Color("fontGray"))
                                        }
                                    }
                                }
                                HStack{
                                    Text("経験値").foregroundColor(Color("fontGray"))
                                    ProgressBar(value: Float(authManager.experience) / Float(authManager.level * 100))
                                        .frame(height: 20)
                                    Text("\(authManager.experience) / \(authManager.level * 100)")
                                        .foregroundColor(Color("fontGray"))
                                }
                                .padding(.horizontal)
                            }
                            
                            VStack{
                                ScrollView{
//                                    Button(action: {
//                                        if isButtonEnabled {
//                                            if let userId = authManager.currentUserId {
//                                                authManager.saveLastClickedDate(userId: userId) { success in
//                                                    lastClickedDate = Date()
//                                                    isButtonEnabled = false
//                                                }
//                                            }
//                                        }
//                                        audioManager.playKetteiSound()
//                                        // 画面遷移のトリガーをオンにする
//                                        self.isPresentingQuizBeginnerList = true
//                                    }) {
//                                        if isButtonEnabled {
//                                            Image("デイリー")
//                                                .resizable()
//                                                .frame(height:70)
//                                        }else{
//                                            Image("白黒デイリー")
//                                                .resizable()
//                                                .frame(height:70)
//                                        }
//                                        //                                        .foregroundColor(.gray)
//                                    }
//                                    .fullScreenCover(isPresented: $isPresentingQuizBeginnerList) {
//                                        QuizDailyList(isPresenting: $isPresentingQuizBeginnerList)
//                                                }
//                                    .frame(maxWidth: .infinity)
//                                    .disabled(!isButtonEnabled)
//                                    .padding(.horizontal)
//                                    //                            .padding(.bottom)
//                                    
//                                    .shadow(radius: 3)
//                                    .onTapGesture {
//                                        if isButtonEnabled {
//                                            if let userId = authManager.currentUserId {
//                                                authManager.saveLastClickedDate(userId: userId) { success in
//                                                    lastClickedDate = Date()
//                                                    isButtonEnabled = false
//                                                }
//                                            }
//                                        }
//                                    }
                                    Button(action: {
                                        audioManager.playSound()
                                        // 画面遷移のトリガーをオンにする
                                        self.isPresentingQuizList = true
                                    }) {
                                        Image("ダンジョン一覧")
                                            .resizable()
                                            .frame(height:70)
                                            .padding(.horizontal)
                                    }
                                    .background(GeometryReader { geometry in
                                        Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                    })
                                    
                                    .shadow(radius: 3)
                                    
//                                    Button(action: {
//                                        audioManager.playSound()
//                                        // 画面遷移のトリガーをオンにする
//                                        self.isPresentingAvatarList = true
//                                    }) {
//                                        Image("おとも一覧")
//                                            .resizable()
//                                            .frame(height:70)
//                                            .padding(.horizontal)
//                                    }
//                                    
//                                    .shadow(radius: 3)
                                    Button(action: {
                                        // 画面遷移のトリガーをオンにする
                                        self.isPresentingGachaView = true
                                        audioManager.playSound()
                                    }) {
                                        Image("ガチャトップ")
                                            .resizable()
                                            .frame(height:70)
                                            .padding(.horizontal)
                                    }
                                    
                                    .shadow(radius: 3)
                                    .onTapGesture {
                                        audioManager.playSound()
                                    }
//                                    Button(action: {
//                                        // 画面遷移のトリガーをオンにする
//                                        self.isPresentingTimeAttakView = true
//                                        audioManager.playSound()
//                                    }) {
//                                        Image("タイムアタック")
//                                            .resizable()
//                                            .frame(height:70)
//                                            .padding(.horizontal)
//                                    }
                                    
                                    .shadow(radius: 3)
                                    .onTapGesture {
                                        audioManager.playSound()
                                    }
                                    
                                    Button(action: {
                                        // 画面遷移のトリガーをオンにする
                                        self.isPresentingIllustratedView = true
                                        audioManager.playSound()
                                    }) {
                                        Image("おとも図鑑")
                                            .resizable()
                                            .frame(height:70)
                                            .padding(.horizontal)
                                    }
                                    
                                    .shadow(radius: 3)
                                    .onTapGesture {
                                        audioManager.playSound()
                                    }
                                    
//                                    Button(action: {
//                                        // 画面遷移のトリガーをオンにする
//                                        self.isPresentingPentagonView = true
//                                        audioManager.playSound()
//                                    }) {
//                                        Image("おとも図鑑")
//                                            .resizable()
//                                            .frame(height:70)
//                                            .padding(.horizontal)
//                                    }
//                                    
//                                    .shadow(radius: 3)
//                                    .onTapGesture {
//                                        audioManager.playSound()
//                                    }
                                    
                                    Group{
//                                        NavigationLink("", destination: QuizDailyList(isPresenting: $isPresentingQuizList).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginnerList)
                                        NavigationLink("", destination: QuizManagerView(isPresenting: $isPresentingQuizList).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizList)
//                                        NavigationLink("", destination: AvatarListView(isPresenting: .constant(false)), isActive: $isPresentingAvatarList)
                                    }
                                    NavigationLink("", destination: GachaManagerView(isPresenting: .constant(false)), isActive: $isPresentingGachaView)
//                                    NavigationLink("", destination: QuizManagerTimerView(isPresenting: $isPresentingQuizList), isActive: $isPresentingTimeAttakView)
//                                    NavigationLink("", destination: SettingView().navigationBarBackButtonHidden(true), isActive: $isPresentingSettingView)
                                    NavigationLink("", destination: IllustratedView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingIllustratedView)
//                                    NavigationLink("", destination:  PentagonView(authManager: authManager).navigationBarBackButtonHidden(true), isActive: $isPresentingPentagonView)
                                }
                            }
                            //                            .padding(.horizontal,5)
                        }
                    }
                    .onPreferenceChange(ViewPositionKey.self) { positions in
                        self.buttonRect = positions.first ?? .zero
                    }
                }
                if showLoginModal && tutorialNum == 0 {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        LoginModalView(audioManager: audioManager, isPresented: $showLoginModal)
                    }
                }
                if tutorialNum == 1{
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: buttonRect.width - 20, height: buttonRect.height)
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
                            Text("「ダンジョン一覧」をクリックしてください。")
                                .font(.system(size: 24.0))
                                .padding(.all, 16.0)
                                .background(Color.white)
                                .cornerRadius(4.0)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                            Image("下矢印")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 310.0)
                        }
                        //                    .position(x: buttonRect.midX, y: buttonRect.midY-130)
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
                }
            }
            .onTapGesture {
                audioManager.playSound()
                tutorialNum = 0 // タップでチュートリアルを終了
                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                       // データベースのアップデートが成功したかどうかをハンドリング
                   }
            }
                        .background(Color("Color2"))
            }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onAppear {
//            if !interstitial.interstitialAdLoaded {
//                interstitial.loadInterstitial()
//            }
            // 1. lastClickedDateを取得
            authManager.fetchLastClickedDate(userId: authManager.currentUserId ?? "") { lastDate in
                if let lastDate = lastDate {
                    // 2. 現在の日時との差を計算
                    let currentDate = Date()
                    let timeInterval = currentDate.timeIntervalSince(lastDate)
                    
                    // 3. 24時間以上経過しているか確認
                    if timeInterval >= 86400 {  // 86400秒 = 24時間
                        isButtonEnabled = true
                    } else {
                        isButtonEnabled = false
                    }
                } else {
                    isButtonEnabled = true
                }
            }
            if let userId = authManager.currentUserId {
                authManager.fetchLastLoginDate(userId: userId) { lastLoginDate in
                    let currentDate = Date()
                    if let lastLoginDate = lastLoginDate {
                        let timeInterval = currentDate.timeIntervalSince(lastLoginDate)
                        if timeInterval >= 86400 {
                            authManager.saveLastLoginDate(userId: userId) { success in
                                if success {
                                    print("ログインボーナスの日時を保存しました")
                                } else {
                                    print("ログインボーナスの日時の保存に失敗しました")
                                }
                            }
                        }
                    } else {
                        authManager.saveLastLoginDate(userId: userId) { success in
                            if success {
                                self.showLoginModal = true
                                authManager.addMoney(amount: 300)
                                print("ログインボーナスの日時を保存しました")
                            } else {
                                print("ログインボーナスの日時の保存に失敗しました")
                            }
                        }
                    }
                }
            }
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
        .sheet(isPresented: $isShowingLoginBonus) {
            LoginBonusView()
        }
        .onChange(of: showLoginModal) { userMoney in
            print("showLoginModal")
            authManager.getUserMoney { userMoney in
                print(userMoney)
                self.userMoney = userMoney
            }
        }
            .onChange(of: isPresentingQuizList) { isPresenting in
                fetchUserInfoIfNeeded(isPresenting: isPresenting)
                authManager.fetchUserExperienceAndLevel()
            }
            .onChange(of: isPresentingAvatarList) { isPresenting in
                fetchUserInfoIfNeeded(isPresenting: isPresenting)
                authManager.fetchUserExperienceAndLevel()
            }
//            .onChange(of: interstitial.interstitialAdLoaded) { isLoaded in
//                print("isLoaded:\(isLoaded)")
//                if isLoaded {
//                    interstitial.presentInterstitial()
//                }
//            }

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
    func saveLastLoginDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginDate")
    }
    
    func saveLoginBonusReceivedDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginBonusReceivedDate")
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

struct LoginBonusView: View {
    var body: some View {
        VStack {
            Text("おめでとうございます！")
                .font(.largeTitle)
            Text("ログインボーナスを獲得しました！")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProgressBar: View {
    var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .animation(.linear)
            }
        }.cornerRadius(45.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
