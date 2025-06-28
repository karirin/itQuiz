//
//  AppliedManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//

import SwiftUI
import AVFoundation
import Firebase

struct ITStoratagyManagerListView: View {
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
    @StateObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showAlert: Bool = false
    @State private var preFlag: Bool = false
    @State private var userPreFlag: Int = 0
    @State private var isLoading: Bool = true

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
                                Text("不正解した問題だけを解くことができます")
                                    .font(.system(size: isIPad() ? 40 : 15))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
    //                            .padding(.horizontal,0)
                            .padding(.leading,30)
                            .padding(.bottom)
                            .padding(.top)
                            Button(action: {
                                audioManager.playKetteiSound()
                                if userPreFlag != 1 {
                                    preFlag = true
                                } else {
                                    if !isIncorrectAnswersEmpty {
                                        self.isPresentingQuizIncorrectAnswer = true
                                    }
                                }
                            }) {
                                if isLoading {
                                    ZStack{
                                        Image("ITストラテジの復習問題白黒")
                                            .resizable()
                                            .frame(height: isIPad() ? 200 : 70)
                                        ProgressView()
                                            .scaleEffect(2)
                                    }
                                } else {
                                    ZStack{
                                        if isIncorrectAnswersEmpty == true {
                                            Image("ITストラテジの復習問題白黒")
                                                .resizable()
                                                .frame(height: isIPad() ? 200 : 70)
                                        }else{
                                            Image("ITストラテジの復習問題")
                                                .resizable()
                                                .frame(height: isIPad() ? 200 : 70)
                                        }
                                        if userPreFlag != 1 {
                                            ZStack{
                                                Color.black.opacity(0.45)
                                                    .cornerRadius(30)
                                                Text("プレミアムプランを登録すると\n復習機能が開放されます")
                                                    .font(.system(size: isIPad() ? 50 : 20))
                                                    .foregroundStyle(.white)
                                                    .bold()
                                                    .multilineTextAlignment(.center)
                                            }
                                            .onTapGesture {
                                                preFlag = true
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizIncorrectAnswer) {
                                QuizITStrategyIncorrectAnswerListView(isPresenting: $isPresentingQuizIncorrectAnswer)
                                        }
                            .onChange(of: isPresentingQuizBeginner) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizIncorrectAnswer) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizIntermediate) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizAdvanced) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizGod) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizNetwork) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizSecurity) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                            .onChange(of: isPresentingQuizDatabase) { isPresenting in
                                    fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                                }
                            }
                        
                            HStack {
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 15)
                                    .background(.gray)
                                Text("問題の種類を選ぶことができます")
                                    .font(.system(size: isIPad() ? 40 : 16))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.leading,15)
                                Button(action: {
                                    audioManager.playKetteiSound()
                                    // 画面遷移のトリガーをオンにする
                                    self.isPresentingQuizDatabase = true
                                }) {
                                    //                        Image("IT基礎知識の問題の初級")
                                    Image("システム企画の問題")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .shadow(radius: 3)
                                .fullScreenCover(isPresented: $isPresentingQuizDatabase) {
                                    QuizSystemKikakuListView(isPresenting: $isPresentingQuizDatabase)
                                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                            })
                            Button(action: {
                                audioManager.playKetteiSound()
                                self.isPresentingQuizAdvanced = true
                            }) {
                                //                    Image("IT基礎知識の問題の上級")
                                Image("システム開発の問題")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizAdvanced) {
                                QuizSystemKaihatuListView(isPresenting: $isPresentingQuizAdvanced)
                                        }
                            Button(action: {
                                audioManager.playKetteiSound()
                                self.isPresentingQuizIntermediate = true
                            }) {
                                //                    Image("IT基礎知識の問題の中級")
                                Image("システム設計の問題")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizIntermediate) {
                                QuizSystemSekkeiListView(isPresenting: $isPresentingQuizIntermediate)
                                        }
                            Button(action: {
                                audioManager.playKetteiSound()
                                self.isPresentingQuizGod = true
                            }) {
                                //                    Image("データベース系の問題")
                                Image("システム運用・保守の問題")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizGod) {
                                QuizSystemUnyouHoshuListView(isPresenting: $isPresentingQuizGod)
                                        }
                            .padding(.bottom,130)
                        }
                    }
                    .overlay(
                        ZStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack{
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                           reward.ExAndMoReward()
                                       }, label: {
                                           if reward.rewardLoaded{
                                               Image("倍ボタン")
                                                   .resizable()
                                                   .frame(width: 110, height: 110)
                                           }else{
                                               Image("倍ボタン白黒")
                                                   .resizable()
                                                   .frame(width: 110, height: 110)
                                           }
                                       })
                                           .shadow(radius: 5)
                                           .disabled(!reward.rewardLoaded)
                                           .onChange(of: reward.rewardEarned) { rewardEarned in
                                               showAlert = rewardEarned
                                               print("onchange reward.rewardEarned:\(showAlert)")
                                           }
                                           .alert(isPresented: $showAlert) {
                                               Alert(
                                                   title: Text("報酬獲得！"),
                                                   message: Text("1時間だけ獲得した経験値とコインが2倍"),
                                                   dismissButton: .default(Text("OK"), action: {
                                                       showAlert = false
                                                       reward.rewardEarned = false
                                                   })
                                               )
                                           }
                                            .background(GeometryReader { geometry in
                                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                            })
                                            .padding(.bottom)
    //                                                .fullScreenCover(isPresented: $showAnotherView_post, content: {
    //                                                    RewardRegistrationView()
    //                                                })
                                        
                                            Spacer()
                                    }
                                }
                            }
                        }
                    )
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
                if tutorialNum == 2 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: buttonRect.width - 20, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: isSmallDevice() ? buttonRect.midY-120 : buttonRect.midY-155)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack {
                        Spacer()
                            .frame(height:isSmallDevice() ? buttonRect.minY + bubbleHeight-50 : buttonRect.minY + bubbleHeight-90)
                        VStack(alignment: .trailing, spacing: .zero) {
    //                            Image("上矢印")
    //                                .resizable()
    //                                .frame(width: 20, height: 20)
    //                                .padding(.trailing, 306.0)
                            Text("「IT基礎知識の問題（初級）」をクリックしてください。")
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
                                    self.bubbleHeight = geometry.size.height - 40
                                }
                            }
                        })
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack{
                        HStack{
                            Button(action: {
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
                if tutorialNum == 2 {
                        audioManager.playSound()
                    tutorialNum = 0
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                        // データベースのアップデートが成功したかどうかをハンドリング
                    }
                }
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color("Color2"))
            .onAppear {
//                print("isButtonClickable:\(isButtonClickable)")
                reward.LoadReward()
                fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                    authManager.fetchPreFlag()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        userPreFlag = authManager.userPreFlag
                        isLoading = false
                    }
                }
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
            .fullScreenCover(isPresented: $preFlag) {
                PreView(audioManager: audioManager)
            }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                }.padding(.top)).buttonStyle(.plain)
        .navigationViewStyle(StackNavigationViewStyle())
        }
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectITStrategyAnswers").child(userId)
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
    ITStoratagyManagerListView(isPresenting: .constant(false))
}
