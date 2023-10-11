//
//  QuizResultView.swift main
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI

struct QuizResult {
    var question: String
    var userAnswer: String
    var correctAnswer: String
    var explanation: String
    var isCorrect: Bool  // 正解か不正解かを示すプロパティ
}

struct QuizResultView: View {
    var results: [QuizResult]
    @State private var showModal = true
    @State private var showLevelUpModal = false
    @State private var showMemoView = false
    @State private var currentMemo = ""
    @State private var selectedQuestion = ""
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    // QuizResultView.swift
    @State private var playerExperience: Int
    @State private var playerMoney: Int

    @Binding var isPresenting: Bool
//    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>

    // QuizResultView.swift
    init(results: [QuizResult], authManager: AuthManager, isPresenting: Binding<Bool>, playerExperience: Int,playerMoney: Int) {
        self.results = results
        self.authManager = authManager
        _isPresenting = isPresenting
        _playerExperience = State(initialValue: playerExperience)
        _playerMoney = State(initialValue: playerMoney)
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                VStack{
                    Spacer()
                    HStack{
                        NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                            Button(action: {
                                audioManager.playCancelSound()
                                self.isPresenting = false
//                                self.rootPresentationMode.wrappedValue.dismissToRoot()
                                // ここで画面遷移を行います。
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.gray)
                                    Text("戻る")
                                        .background(Color.white)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.leading)
                        Spacer()
                        Text("クイズ結果")
                        Spacer()
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                            Text("戻る")
                                .background(Color.white)
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                        .opacity(0)
                    }
                    ScrollView{
                        ForEach(results, id: \.question) { result in
                            VStack(alignment: .leading,spacing: 20) {
                                HStack{
                                    Image(systemName:result.isCorrect ? "circle" : "xmark")
                                        .foregroundColor(result.isCorrect ? .red : .blue)
                                        .opacity(0.7)
                                    Text(result.isCorrect ? "正解" : "不正解")
                                }
                                .font(.system(size:24))
                                Text(result.question)
                                Text("あなたの回答: \(result.userAnswer)")
                                Text("正解: \(result.correctAnswer)")
                                Text("解説: \(result.explanation)")
                            }.padding()
                            .frame(maxWidth:.infinity,alignment: .leading)
                            Divider()
                            .onAppear {
                                showModal = true
                            }
                            .frame(maxWidth:.infinity)
                        }
                        .padding(5)
                    }
                }
                .onChange(of: authManager.didLevelUp) { newValue in
                    if newValue {
                        // レベルアップ通知を表示した後、フラグをリセット
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showLevelUpModal = true
                            audioManager.playLevelUpSound()
                        }
                    }
                }
                if showModal {
                    ExperienceModalView(showModal: $showModal, addedExperience: playerExperience, addedMoney: playerMoney, authManager: authManager)
                }
                if showLevelUpModal {
                    LevelUpModalView(showLevelUpModal: $showLevelUpModal, authManager: authManager)
                }
                if showMemoView {
                    MemoView(memo: $currentMemo, question: selectedQuestion)
                }
            }
            .background(Color("Color2"))
        }
    }

}

struct ExperienceModalView: View {
    @Binding var showModal: Bool
    var addedExperience: Int
    var addedMoney: Int
    @State private var currentExperience: Double = 0
    @State private var currentMoney: Double = 0
    let maxExperience: Double = 100
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showModal = false
                }
            VStack{
                VStack(spacing: 20) {
                    if currentExperience != 5{
                        Text("クリア！！")
                            .font(.largeTitle)
                    }else{
                        Text("ゲームオーバー")
                            .font(.largeTitle)
                    }
                    HStack{
                        Image("経験値")
                            .resizable()
                            .frame(width:30,height:30)
                        Text("経験値 ＋\(Int(currentExperience))")
                            .font(.title)
                    }
                    
                    HStack{
                        Image("コイン")
                            .resizable()
                            .frame(width:30,height:30)
                        Text("コイン ＋\(Int(currentMoney))")
                            .font(.title)
                    }
                    // ここでProgressBar1に現在の経験値とmax経験値を渡します。
                    Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                        .font(.system(size: 20))
                    ProgressBar1(value: Double(authManager.experience), maxValue: Double(authManager.level * 100))
                        .padding(.horizontal,20)
                }
            }
            .onAppear {
                withAnimation {
                    currentExperience += Double(addedExperience)
                    currentMoney += Double(addedMoney)
                }
                if currentExperience != 5 {
                    audioManager.playGameClearSound()
                }else{
                    audioManager.playGameOverSound()
                }
                DispatchQueue.global(qos: .background).async {
                    authManager.fetchUserExperienceAndLevel()
                    DispatchQueue.main.async {
                        // ここでUIの更新を行います。
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(30)
        }.overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                showModal = false
                audioManager.playCancelSound()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(30)
                    .padding()
            }
            .offset(x: 150, y: -130)
        )
    }
}

struct LevelUpModalView: View {
    @Binding var showLevelUpModal: Bool
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showLevelUpModal = false
                }

            VStack(spacing: 0) {
                ZStack{
                    Image("レベルアップ")
                        .resizable()
                        .frame(width:250,height:250)
                    Text("\(authManager.level)")
                        .font(.system(size: 100))
                        .fontWeight(.medium)
                        .padding(.bottom,80)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                showLevelUpModal = false
                audioManager.playCancelSound()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(50)
                    .padding()
            }
            .offset(x: 130, y: -140)
        )
        .onAppear{
            authManager.fetchUserExperienceAndLevel()
        }
    }
}

struct ProgressBar1: View {
    var value: Double
    var maxValue: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.3)
                    .foregroundColor(Color.blue)

                Rectangle()
                    .frame(width: CGFloat(self.value / self.maxValue) * geometry.size.width)
                    .foregroundColor(Color.blue)
                    .animation(.linear(duration: 1.0))
            }
        }
        .frame(height: 20)
        .cornerRadius(10)
    }
}


struct QuizResultView_Previews: PreviewProvider {
    @State static private var isPresenting = true
    @State static private var authManager = AuthManager.shared
    static var previews: some View {
        // ダミーデータを作成
        let dummyResults = [
            QuizResult(question: "情報セキュリティの方針やルールを組織全体に明確に伝えるための文章は？", userAnswer: "SLA", correctAnswer: "情報セキュリティポリシー", explanation: "情報セキュリティの３つの基本的な要素として、機密性、完全性に続くものは「可溶性」といいます。", isCorrect: false),
            QuizResult(question: "AIを開発するベンチャー企業のA社が，資金調達を目的に，金融商品取引所に初めて上場することになった。このように，企業の未公開の株式を，新たに公開することを表す用語として，最も適切なものはどれか。", userAnswer: "IPO", correctAnswer: "IPO", explanation: "IPO（Initial Public Offering）は、企業が初めて公開市場で株式を発行することを指します。", isCorrect: true)
        ]
        
        // ダミーデータを使用してQuizResultViewを呼び出す
        QuizResultView(results: dummyResults, authManager: authManager, isPresenting: $isPresenting, playerExperience: 10, playerMoney: 10)
    }
}
