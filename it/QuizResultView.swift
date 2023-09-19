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

    var body: some View {
        ZStack{
            List(results, id: \.question) { result in
                VStack(alignment: .leading) {
                    Text(result.question)
                    Text("あなたの回答: \(result.userAnswer)")
                    Text("正解: \(result.correctAnswer)")
                    Text(result.isCorrect ? "正解!" : "不正解")  // 正解か不正解かを表示
                        .foregroundColor(result.isCorrect ? .green : .red)  // 正解なら緑色、不正解なら赤色で表示
                    Text("解説: \(result.explanation)")
//                    Button("メモする") {
//                                            selectedQuestion = result.question
//                                            showMemoView = true
//                                        }
//                                        .padding(.top)
                }
                .padding()
                .onAppear {
                        showModal = true
                }
            }
        if showModal {
                        ExperienceModalView(showModal: $showModal, addedExperience: 10)
                    }
            if showMemoView {
                MemoView(memo: $currentMemo, question: selectedQuestion)
            }
        }
    }
}

struct ExperienceModalView: View {
    @Binding var showModal: Bool
    var addedExperience: Int
    @State private var currentExperience: Double = 0
    let maxExperience: Double = 100
    @ObservedObject var authManager = AuthManager.shared

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
                authManager.fetchUserExperienceAndLevel()
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


struct QuizResultView_Previews: PreviewProvider {
    static var previews: some View {
        // ダミーデータを作成
        let dummyResults = [
            QuizResult(question: "ダミーの質問1", userAnswer: "あなたの回答1", correctAnswer: "正解1", explanation: "解説1", isCorrect: true),
            QuizResult(question: "ダミーの質問2", userAnswer: "あなたの回答2", correctAnswer: "正解2", explanation: "解説2", isCorrect: false)
        ]
        
        // ダミーデータを使用してQuizResultViewを呼び出す
        QuizResultView(results: dummyResults)
    }
}
