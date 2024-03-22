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
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isIncorrectAnswersEmpty: Bool = true
    @ObservedObject var reward = Reward()
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
                                Text("不正解した問題だけを解くことができます")
                                    .font(.system(size: isIPad() ? 40 : 16))
                                    .foregroundColor(Color("fontGray"))
                                Spacer()
                            }
                            .padding(.leading,30)
//                            .padding(.horizontal,0)
                            .padding(.bottom)
                            .padding(.top)
                            Button(action: {
                                audioManager.playKetteiSound()
                                // 画面遷移のトリガーをオンにする
                                self.isPresentingQuizIncorrectAnswer = true
                            }) {
                                //                        Image("IT基礎知識の問題の初級")
                                if isIncorrectAnswersEmpty == true {
                                Image("白黒選択肢0")
                                    .resizable()
                                    .frame(height: isIPad() ? 200 : 70)
                                }else{
                                    Image("選択肢0")
                                        .resizable()
                                        .frame(height: isIPad() ? 200 : 70)
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
//                            .fullScreenCover(isPresented: $isPresentingQuizAdvanced) {
//                                            QuizAdvancedList(isPresenting: $isPresentingQuizAdvanced)
//                                        }
//                            Button(action: {
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
                        NavigationLink("", destination: ITManagerListView(isPresenting: $isPresentingITView).navigationBarBackButtonHidden(true), isActive: $isPresentingITView)
                        NavigationLink("", destination: InfoManagerListView(isPresenting: $isPresentingInfoView).navigationBarBackButtonHidden(true), isActive: $isPresentingInfoView)
                        NavigationLink("", destination: AppliedManagerListView(isPresenting: $isPresentingAppliedView).navigationBarBackButtonHidden(true), isActive: $isPresentingAppliedView)
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
                fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
//                self.incorrectAnswerCount = count
//                incorrectCount = count
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
            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action: {
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
    let ref = Database.database().reference().child("IncorrectAnswers").child(userId)
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
    ManagerListTabView()
}

