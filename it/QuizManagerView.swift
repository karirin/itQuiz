//
//  QuizManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/20.
//

import SwiftUI
import AVFoundation

struct QuizManagerView: View {
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
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    
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
                        self.isPresentingQuizBeginner = true
                    }) {
//                        Image("IT基礎知識の問題の初級")
                        Image("選択肢1")
                            .resizable()
                            .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 5)
                }
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizIntermediate = true
                }) {
//                    Image("IT基礎知識の問題の中級")
                    Image("選択肢2")
                        .resizable()
                        .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
                
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizAdvanced = true
                }) {
//                    Image("IT基礎知識の問題の上級")
                    Image("選択肢3")
                        .resizable()
                        .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
                
                // ネットワーク系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizNetwork = true
                }) {
//                    Image("ネットワーク系の問題")
                    Image("選択肢4")
                        .resizable()
                        .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
                
                // セキュリティ系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizSecurity = true
                }) {
//                    Image("セキュリティ系の問題")
                    Image("選択肢5")
                        .resizable()
                        .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
                
                // データベース系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizDatabase = true
                }) {
//                    Image("データベース系の問題")
                    Image("選択肢6")
                        .resizable()
                        .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
            }
                VStack{
                    Group{
                        NavigationLink("", destination: QuizDatabaseList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizDatabase) // 適切な遷移先に変更してください
                        NavigationLink("", destination: QuizBeginnerList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner) // 適切な遷移先に変更してください
                        NavigationLink("", destination: QuizIntermediateList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
                        NavigationLink("", destination: QuizAdvancedList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)
                        NavigationLink("", destination: QuizSecurityList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizSecurity) // 適切な遷移先に変更してください
                        
                        NavigationLink("", destination: QuizNetworkList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizNetwork)
                    }
                }
                
            }
                if tutorialNum == 2 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: 360, height: 90)
                                    .position(x: geometry.size.width / 2.0, y: geometry.size.height / 14.5) // このオフセットを変更してスポットライトの位置を調整
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                            .background(.clear)
                    }
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
                    }.offset(x: -10, y: -130)
                }
        }.onTapGesture {
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


struct QuizManagerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizManagerView(isPresenting: .constant(false))
    }
}
