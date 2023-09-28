//
//  QuizResultView.swift
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
    @State private var showMemoView = false
    @State private var currentMemo = ""
    @State private var selectedQuestion = ""
    private var authManager = AuthManager()
    
    // 公開イニシャライザ
//    public init(results: [QuizResult]) {
//        self.results = results
//    }

    var body: some View {
        NavigationView{
            ZStack {
                VStack{
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        Text("トップに戻る")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                    ScrollView{
                        ForEach(results, id: \.question) { result in
                            VStack(alignment: .leading) {
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
                            }
                            .frame(maxWidth:.infinity,alignment: .leading)
                            .padding()
                            .onAppear {
                                showModal = true
                            }
                            .frame(maxWidth:.infinity)
                        }
                        .padding(5)
                    }
                }
                
                if showModal {
                    ExperienceModalView(showModal: $showModal, addedExperience: 10, authManager: authManager)
                }
                if showMemoView {
                    MemoView(memo: $currentMemo, question: selectedQuestion)
                }
            }
        }
    }

}

struct ExperienceModalView: View {
    @Binding var showModal: Bool
    var addedExperience: Int
    @State private var currentExperience: Double = 0
    let maxExperience: Double = 100
    @ObservedObject var authManager:AuthManager

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showModal = false
                }

            VStack(spacing: 20) {
                Text("経験値獲得!")
                    .font(.largeTitle)

                Text("+\(Int(currentExperience)) 経験値")
                    .font(.title)
                
                // ここでProgressBar1に現在の経験値とmax経験値を渡します。
                Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                ProgressBar1(value: Double(authManager.experience), maxValue: Double(authManager.level * 100))
                    .padding(.horizontal)

                Button("閉じる") {
                    showModal = false
                }
                .padding()
            }
            .onAppear {
                withAnimation {
                    currentExperience += Double(addedExperience)
                }
                DispatchQueue.global(qos: .background).async {
                    authManager.fetchUserExperienceAndLevel()
                    DispatchQueue.main.async {
                        // ここでUIの更新を行います。
                    }
                }
            }
            .padding()
//            .frame(width: 300, height: 200) // このサイズを調整して好みの大きさにします
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
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

//
//struct QuizResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        // ダミーデータを作成
//        let dummyResults = [
//            QuizResult(question: "情報セキュリティの方針やルールを組織全体に明確に伝えるための文章は？", userAnswer: "SLA", correctAnswer: "情報セキュリティポリシー", explanation: "情報セキュリティの３つの基本的な要素として、機密性、完全性に続くものは「可溶性」といいます。", isCorrect: false),
//            QuizResult(question: "AIを開発するベンチャー企業のA社が，資金調達を目的に，金融商品取引所に初めて上場することになった。このように，企業の未公開の株式を，新たに公開することを表す用語として，最も適切なものはどれか。", userAnswer: "IPO", correctAnswer: "IPO", explanation: "IPO（Initial Public Offering）は、企業が初めて公開市場で株式を発行することを指します。", isCorrect: true)
//        ]
//        
//        // ダミーデータを使用してQuizResultViewを呼び出す
//        QuizResultView(results: dummyResults)
//    }
//}
