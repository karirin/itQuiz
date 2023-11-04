//
//  QuizManagerTimerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/04.
//

import SwiftUI
import AVFoundation

struct QuizManagerTimerView: View {
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
    
    @State private var isPresentingTimeBeginnerList: Bool = false
    @State private var isPresentingTimeIntermediateList: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
        ZStack{
            ScrollView{
                VStack {
                    Spacer()
                    Group{
                        Button(action: {
                            audioManager.playKetteiSound()
                            // 画面遷移のトリガーをオンにする
                            self.isPresentingTimeBeginnerList = true
                        }) {
                            //                        Image("IT基礎知識の問題の初級")
                            Image("タイムアタック選択肢1")
                                .resizable()
                                .frame(height: 70)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .shadow(radius: 5)
                    }
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                    })
                    Button(action: {
                        audioManager.playKetteiSound()
                        self.isPresentingQuizIntermediate = true
                    }) {
                        //                    Image("IT基礎知識の問題の中級")
                        Image("タイムアタック選択肢2")
                            .resizable()
                            .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 3)

                    Button(action: {
                        audioManager.playKetteiSound()
                        self.isPresentingTimeIntermediateList = true
                    }) {
                        //                    Image("IT基礎知識の問題の上級")
                        Image("タイムアタック選択肢3")
                            .resizable()
                            .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 3)
//                    Button(action: {
//                        audioManager.playKetteiSound()
//                        self.isPresentingQuizGod = true
//                    }) {
//                        //                    Image("データベース系の問題")
//                        Image("選択肢7")
//                            .resizable()
//                            .frame(height: 70)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                    .shadow(radius: 3)
//                    // ネットワーク系の問題
//                    Button(action: {
//                        audioManager.playKetteiSound()
//                        self.isPresentingQuizNetwork = true
//                    }) {
//                        //                    Image("ネットワーク系の問題")
//                        Image("選択肢4")
//                            .resizable()
//                            .frame(height: 70)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                    .shadow(radius: 3)
//
//                    // セキュリティ系の問題
//                    Button(action: {
//                        audioManager.playKetteiSound()
//                        self.isPresentingQuizSecurity = true
//                    }) {
//                        //                    Image("セキュリティ系の問題")
//                        Image("選択肢5")
//                            .resizable()
//                            .frame(height: 70)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                    .shadow(radius: 3)
//
//                    // データベース系の問題
//                    Button(action: {
//                        audioManager.playKetteiSound()
//                        self.isPresentingQuizDatabase = true
//                    }) {
//                        //                    Image("データベース系の問題")
//                        Image("選択肢6")
//                            .resizable()
//                            .frame(height: 70)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                    .shadow(radius: 3)
                    
                }
                VStack{
                    Group{
                        NavigationLink("", destination: TimeBeginnerList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingTimeBeginnerList) // 適切な遷移先に変更してください
                        NavigationLink("", destination: TimeIntermediateList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingTimeIntermediateList) // 適切な遷移先に変更してください
                        NavigationLink("", destination: TimeAdvancedList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
//                        NavigationLink("", destination: QuizAdvancedList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)
//                        NavigationLink("", destination: QuizSecurityList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizSecurity) // 適切な遷移先に変更してください
//
//                        NavigationLink("", destination: QuizNetworkList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizNetwork)
//                        NavigationLink("", destination: QuizGodList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizGod)
                    }
                }
                
            }
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            if tutorialNum == 2 {
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                    // スポットライトの領域をカットアウ
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .frame(width: buttonRect.width - 20, height: buttonRect.height)
                                .position(x: buttonRect.midX, y: buttonRect.midY-10)
                                .blendMode(.destinationOut)
                        )
                        .ignoresSafeArea()
                        .compositingGroup()
                        .background(.clear)
                }
                VStack {
                    Spacer()
                        .frame(height: buttonRect.minY + bubbleHeight)
                    VStack(alignment: .trailing, spacing: .zero) {
                        Image("上矢印")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 306.0)
                        Text("「IT基礎知識の問題（初級）」をクリックしてください。")
                            .font(.system(size: 24.0))
                            .padding(.all, 16.0)
                            .background(Color.white)
                            .cornerRadius(4.0)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
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
            }
        }
        .onTapGesture {
            audioManager.playSound()
            tutorialNum = 0
            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                   // データベースのアップデートが成功したかどうかをハンドリング
               }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
        .onAppear {
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
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("fontGray"))
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        })
    }
}

struct QuizManagerTimerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizManagerTimerView(isPresenting: .constant(false))
    }
}
