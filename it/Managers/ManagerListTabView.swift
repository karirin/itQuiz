//
//  ManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//

import SwiftUI
import AVFoundation
import Firebase

struct ManagerListTabView: View {
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
    @State private var isPresentingITView: Bool = false
    @State private var isPresentingInfoView: Bool = false
    @State private var isPresentingAppliedView: Bool = false
    @State private var isPresentingESView: Bool = false
    @State private var isPresentingSystemArchitectView: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isIncorrectAnswersEmpty: Bool = true
    @State private var dueReviewCount: Int = 0
    @State private var nextReviewDate: Date?
    @StateObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showAlert: Bool = false
    
    init() {
//        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
        NavigationView{
            ZStack{
                    ScrollView{
                        VStack {
                            HStack{
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 20)
                                    .background(.gray)
                                Text(reviewHeaderText)
                                    .font(.system(size: isIPad() ? 40 : 16))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.leading,30)
//                            .padding(.horizontal,0)
                            .padding(.bottom)
                            .padding(.top)
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playKetteiSound()
                                // 画面遷移のトリガーをオンにする
                                self.isPresentingQuizIncorrectAnswer = true
                            }) {
                                //                        Image("IT基礎知識の問題の初級")
                                ZStack(alignment: .topTrailing) {
                                    Image(isIncorrectAnswersEmpty ? "白黒選択肢0" : "選択肢0")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
                                    if dueReviewCount > 0 {
                                        Text("\(dueReviewCount)")
                                            .font(.system(size: isIPad() ? 30 : 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, isIPad() ? 16 : 9)
                                            .padding(.vertical, isIPad() ? 8 : 4)
                                            .background(Color.red)
                                            .clipShape(Capsule())
                                            .offset(x: -10, y: -8)
                                    }
                                }
                            }
                            .disabled(isIncorrectAnswersEmpty)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            .fullScreenCover(isPresented: $isPresentingQuizIncorrectAnswer) {
                                QuizIncorrectAnswerListView(isPresenting: $isPresentingQuizIncorrectAnswer)
                                        }
                            .onChange(of: isPresentingQuizBeginner) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizIncorrectAnswer) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizIntermediate) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizAdvanced) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizGod) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizNetwork) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizSecurity) { isPresenting in
                                refreshReviewSummary()
                            }
                            .onChange(of: isPresentingQuizDatabase) { isPresenting in
                                refreshReviewSummary()
                            }
                        
                            HStack{
                                Text(" ")
                                    .frame(width:isIPad() ? 10 : 5,height: isIPad() ? 40 : 20)
                                    .background(.gray)
                                Text("問題の種類を選ぶことができます")
                                    .font(.system(size: isIPad() ? 40 : 16))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.leading,30)
                            .padding(.bottom)
                                Button(action: { 
                        generateHapticFeedback()
                                    audioManager.playKetteiSound()
                                    // 画面遷移のトリガーをオンにする
                                    self.isPresentingITView = true
                                }) {
                                    //                        Image("IT基礎知識の問題の初級")
                                    Image("ITパスポートボタン")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .shadow(radius: 3)
//                                .fullScreenCover(isPresented: $isPresentingQuizBeginner) {
//                                                QuizBeginnerList(isPresenting: $isPresentingQuizBeginner)
//                                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                            })
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playKetteiSound()
                                self.isPresentingInfoView = true
                            }) {
                                //                    Image("IT基礎知識の問題の中級")
                                Image("基本情報技術者ボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
//                            .fullScreenCover(isPresented: $isPresentingQuizIntermediate) {
//                                            QuizIntermediateList(isPresenting: $isPresentingQuizIntermediate)
//                                        }
                            
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playKetteiSound()
                                self.isPresentingAppliedView = true
                            }) {
                                //                    Image("IT基礎知識の問題の上級")
                                Image("応用情報技術者ボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playSound()
                                self.isPresentingSystemArchitectView = true
                            }) {
                                Image("ITストラテジの問題")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
                            
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playSound()
                                self.isPresentingESView = true
                            }) {
                                Image("ESボタン")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .shadow(radius: 3)
//                            .fullScreenCover(isPresented: $isPresentingQuizAdvanced) {
//                                            QuizAdvancedList(isPresenting: $isPresentingQuizAdvanced)
//                                        }
//                            Button(action: { 
//                        generateHapticFeedback()
//                                audioManager.playKetteiSound()
//                                self.isPresentingQuizGod = true
//                            }) {
//                                //                    Image("データベース系の問題")
//                                Image("選択肢7")
//                                    .resizable()
//                                    .frame(height: isIPad() ? 200 : 70)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal)
//                            .padding(.bottom)
//                            .shadow(radius: 3)
//                            .fullScreenCover(isPresented: $isPresentingQuizGod) {
//                                            QuizGodList(isPresenting: $isPresentingQuizGod)
//                                        }
                            // ネットワーク系の問題
//                            Button(action: { 
//                        generateHapticFeedback()
//                                audioManager.playKetteiSound()
//                                self.isPresentingQuizNetwork = true
//                            }) {
//                                //                    Image("ネットワーク系の問題")
//                                Image("選択肢4")
//                                    .resizable()
//                                    .frame(height: isIPad() ? 200 : 70)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal)
//                            .padding(.bottom)
//                            .shadow(radius: 1)
//                            .fullScreenCover(isPresented: $isPresentingQuizNetwork) {
//                                            QuizNetworkList(isPresenting: $isPresentingQuizNetwork)
//                                        }
                            
                            // セキュリティ系の問題
//                            Button(action: { 
//                        generateHapticFeedback()
//                                audioManager.playKetteiSound()
//                                self.isPresentingQuizSecurity = true
//                            }) {
//                                //                    Image("セキュリティ系の問題")
//                                Image("選択肢5")
//                                    .resizable()
//                                    .frame(height: isIPad() ? 200 : 70)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal)
//                            .padding(.bottom)
//                            .shadow(radius: 3)
//                            .fullScreenCover(isPresented: $isPresentingQuizSecurity) {
//                                            QuizSecurityList(isPresenting: $isPresentingQuizSecurity)
//                                        }
                            
                            // データベース系の問題
//                            Button(action: { 
//                        generateHapticFeedback()
//                                audioManager.playKetteiSound()
//                                self.isPresentingQuizDatabase = true
//                            }) {
//                                //                    Image("データベース系の問題")
//                                Image("選択肢6")
//                                    .resizable()
//                                    .frame(height: isIPad() ? 200 : 70)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal)
//                            .padding(.bottom,120)
//                            .shadow(radius: 3)
//                            .fullScreenCover(isPresented: $isPresentingQuizDatabase) {
//                                            QuizDatabaseList(isPresenting: $isPresentingQuizDatabase)
//                                        }
                            
                        }
                        .padding(.bottom,70)
                        NavigationLink("", destination: ITManagerListView(isPresenting: $isPresentingITView).navigationBarBackButtonHidden(true), isActive: $isPresentingITView)
                        NavigationLink("", destination: InfoManagerListView(isPresenting: $isPresentingInfoView).navigationBarBackButtonHidden(true), isActive: $isPresentingInfoView)
                        NavigationLink("", destination: AppliedManagerListView(isPresenting: $isPresentingAppliedView).navigationBarBackButtonHidden(true), isActive: $isPresentingAppliedView)
                        NavigationLink("", destination: ESManagerListView(isPresenting: $isPresentingESView).navigationBarBackButtonHidden(true), isActive: $isPresentingESView)
                        NavigationLink("", destination: ITStoratagyManagerListView(isPresenting: $isPresentingSystemArchitectView).navigationBarBackButtonHidden(true), isActive: $isPresentingSystemArchitectView)
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
                        generateHapticFeedback()
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
                                            .shadow(radius: 5)
                                            .disabled(!isButtonClickable)
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
                    
            }
//
//            .onTapGesture {
//                if tutorialNum == 2 {
//                        audioManager.playSound()
//                    tutorialNum = 0
//                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
//                        // データベースのアップデートが成功したかどうかをハンドリング
//                    }
//                }
//            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color("Color2"))
            .onAppear {
//                print("isButtonClickable:\(isButtonClickable)")
                reward.LoadReward()
                refreshReviewSummary()
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
//            })
////            .toolbar {
////                    ToolbarItem(placement: .principal) {
////                        Text("ダンジョン一覧")
////                            .font(.system(size: 20)) // ここでフォントサイズを指定
////                            .foregroundStyle(Color("fontGray"))
////                    }
////                }
            }
        .navigationViewStyle(StackNavigationViewStyle())
        }
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
        ReviewScheduleService.fetchSummary(userId: userId) { summary in
            dueReviewCount = summary.dueCount
            nextReviewDate = summary.nextReviewDate
            isIncorrectAnswersEmpty = summary.totalCount == 0
            completion(summary.dueCount)
        }
    }

    private var reviewHeaderText: String {
        if dueReviewCount > 0 {
            return "今日の復習が\(dueReviewCount)問あります"
        }
        if let nextReviewDate {
            return "次の復習は\(nextReviewDate.formatted(date: .abbreviated, time: .omitted))です"
        }
        return "忘れかけた問題を自動で復習します"
    }

    private func refreshReviewSummary() {
        guard let userId = authManager.currentUserId else {
            dueReviewCount = 0
            nextReviewDate = nil
            isIncorrectAnswersEmpty = true
            return
        }
        fetchNumberOfIncorrectAnswers(userId: userId) { _ in }
    }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    }

#Preview {
    ManagerListTabView()
}
