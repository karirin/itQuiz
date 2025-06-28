//
//  ITManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//

import SwiftUI
import AVFoundation
import Firebase

struct BossManagerListView: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date = Date()
    @State private var audioPlayerKettei: AVAudioPlayer?
    @State private var isPresentingQuizBeginner: Bool = false
    @State private var isPresentingQuizIntermediate: Bool = false
    @State private var isPresentingQuizAdvanced: Bool = false
    @State private var isPresentingQuizNetwork: Bool = false
    @State private var isPresentingQuizSecurity: Bool = false
    @State private var isPresentingQuizDatabase: Bool = false
    @State private var isPresentingQuizGod: Bool = false
    @State private var isPresentingQuizIncorrectAnswer: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isIncorrectAnswersEmpty: Bool = true
    @ObservedObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showAlert: Bool = false
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
//        NavigationView{
            ZStack{
                    ScrollView{
                        VStack {
                            HStack {
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 15)
                                    .background(.gray)
                                Text("ITパスポートの全ての分野から出題されます")
                                    .font(.system(size: isIPad() ? 40 : isSmallDevice() ? 14 : 16))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.leading,15)
                            if authManager.level > 2 {
                                Button(action: { 
                        generateHapticFeedback()
                                    audioManager.playKetteiSound()
                                    // 画面遷移のトリガーをオンにする
                                    self.isPresentingQuizBeginner = true
                                }) {
                                    Image("ゴブリンボタン")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .shadow(radius: 3)
                                .fullScreenCover(isPresented: $isPresentingQuizBeginner) {
                                    QuizGoburinList(isPresenting: $isPresentingQuizBeginner)
                                }
                            }else{
                                Image("白黒ゴブリンボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                    .shadow(radius: 3)
                            }
                            HStack {
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 15)
                                    .background(.gray)
                                Text("基本情報技術者試験の全ての分野から出題されます")
                                    .font(.system(size: isIPad() ? 40 : 13))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.leading,15)
                            if authManager.level > 4 {
                                Button(action: { 
                        generateHapticFeedback()
                                    audioManager.playKetteiSound()
                                    self.isPresentingQuizIntermediate = true
                                }) {
                                    Image("海獣ボタン")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .shadow(radius: 3)
                                .fullScreenCover(isPresented: $isPresentingQuizIntermediate) {
                                    QuizKaijyuList(isPresenting: $isPresentingQuizIntermediate)
                                }
                            } else{
                                Image("白黒海獣ボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                    .shadow(radius: 3)
                            }
                            HStack {
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 15)
                                    .background(.gray)
                                Text("応用情報技術者試験の全ての分野から出題されます")
                                    .font(.system(size: isIPad() ? 40 : 13))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.leading,15)
                            if authManager.level > 7 {
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playKetteiSound()
                                self.isPresentingQuizGod = true
                            }) {
                                Image("神獣ボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizGod) {
                                QuizShinjyuList(isPresenting: $isPresentingQuizGod)
                            }
                            
                            .padding(.bottom,130)
                        }else{
                               Image("白黒神獣ボタン")
                                   .resizable()
                                   .frame(height: isIPad() ? 200 : 70)
                                   .frame(maxWidth: .infinity)
                                   .padding(.horizontal)
                                   .padding(.bottom)
                                   .shadow(radius: 3)
                           }
                        }
                    }
//                    .overlay(
//                        ZStack {
//                            Spacer()
//                            HStack {
//                                Spacer()
//                                VStack{
//                                    Spacer()
//                                    HStack {
//                                        Button(action: { 
//                        generateHapticFeedback()
//                                            reward.ExAndMoReward()
//                                        }, label: {
//                                            if reward.rewardLoaded{
//                                                Image("倍ボタン")
//                                                    .resizable()
//                                                    .frame(width: 110, height: 110)
//                                            }else{
//                                                Image("倍ボタン白黒")
//                                                    .resizable()
//                                                    .frame(width: 110, height: 110)
//                                            }
//                                        })
//                                            .shadow(radius: 5)
//                                            .disabled(!reward.rewardLoaded)
//                                            .onChange(of: reward.rewardEarned) { rewardEarned in
//                                                showAlert = rewardEarned
//                                                print("onchange reward.rewardEarned:\(showAlert)")
//                                            }
//                                            .alert(isPresented: $showAlert) {
//                                                Alert(
//                                                    title: Text("報酬獲得！"),
//                                                    message: Text("1時間だけ獲得した経験値とコインが2倍"),
//                                                    dismissButton: .default(Text("OK"), action: {
//                                                        showAlert = false
//                                                        reward.rewardEarned = false
//                                                    })
//                                                )
//                                            }
//                                            .padding(.bottom)
////                                                .fullScreenCover(isPresented: $showAnotherView_post, content: {
////                                                    RewardRegistrationView()
////                                                })
//
//                                            Spacer()
//                                    }
//                                }
//                            }
//                        }
//                    )
                .onPreferenceChange(ViewPositionKey.self) { positions in
                    self.buttonRect = positions.first ?? .zero
                }
                if showLoginModal {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        RewardTimesModal(audioManager: audioManager, isPresented: $showLoginModal)
                    }
                }
                if tutorialNum == 3 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: buttonRect.width - 20, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: isSmallDevice() ? buttonRect.midY : buttonRect.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack {
                        Spacer()
                            .frame(height:isSmallDevice() ? buttonRect.minY + bubbleHeight : buttonRect.minY + bubbleHeight)
                        VStack(alignment: .trailing, spacing: .zero) {
//                            Image("上矢印")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                                .padding(.trailing, 306.0)
                            Text("「基礎理解の問題」をクリックしてください。")
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
                                    self.bubbleHeight = geometry.size.height
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
                                    .padding(.leading)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
                    
            }
            
            .onTapGesture {
                if tutorialNum == 3 {
                        audioManager.playSound()
                    tutorialNum = 0
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                        // データベースのアップデートが成功したかどうかをハンドリング
                    }
                }
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color("Color2"))
            .onAppear {
                reward.LoadReward()
//                print("isButtonClickable:\(isButtonClickable)")
//                reward.LoadReward()
                fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
//                self.incorrectAnswerCount = count
//                incorrectCount = count
                }
                authManager.fetchUserExperienceAndLevel()
                print("authManager.level:\(authManager.level)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 1秒後に
                    self.isButtonClickable = true // ボタンをクリック可能に設定
                    
                }
                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                    if let fetchedTutorialNum = tutorialNum {
                        self.tutorialNum = fetchedTutorialNum
                    }
                }
                if let userId = authManager.currentUserId {
                    authManager.fetchLastClickedDate(userId: userId) { date in
                        if let unwrappedDate = date {
                            lastClickedDate = unwrappedDate
                            let calendar = Calendar.current
                            if calendar.isDateInToday(unwrappedDate) {
                                isButtonEnabled = false
                            }
                        } else {
                            print("lastClickedDate is nil")
                        }
                    }
                }
                isIntermediateQuizActive = authManager.level >= 10
                if let soundURL = Bundle.main.url(forResource: "soundKettei", withExtension: "mp3") {
                    do {
                        audioPlayerKettei = try AVAudioPlayer(contentsOf: soundURL)
                    } catch {
                        print("Failed to initialize audio player: \(error)")
                    }
                }
                if audioManager.isMuted {
                    audioPlayerKettei?.volume = 0
                } else {
                    audioPlayerKettei?.volume = 1.0
                }
            }
            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action: { 
//                        generateHapticFeedback()
//                self.presentationMode.wrappedValue.dismiss()
//                audioManager.playCancelSound()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(Color("fontGray"))
//                Text("戻る")
//                    .foregroundColor(Color("fontGray"))
//            }.padding(.top))
//            .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("ダンジョン一覧")
//                            .font(.system(size: 20)) // ここでフォントサイズを指定
//                            .foregroundStyle(Color("fontGray"))
//                    }
//                }
//            }
        .navigationViewStyle(StackNavigationViewStyle())
        }
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectITAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
        
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
        print("count:\(count)")
        self.isIncorrectAnswersEmpty = (count == 0)
    }
    }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    }

#Preview {
    BossManagerListView(isPresenting: .constant(false))
}

