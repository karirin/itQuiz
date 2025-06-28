//
//  QuizInfoIncorrectAnswerListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI
import Firebase

struct QuizInfoIncorrectAnswerListView: View {
    @Binding var isPresenting: Bool
    @State var shuffledQuizList: [QuizQuestion] = []
    @State var isDataLoaded = false // データロード状態の追跡

    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared
    @StateObject var sharedInterstitial = Interstitial()
    
    init(isPresenting: Binding<Bool>) {
            self._isPresenting = isPresenting
            // 初期化処理...
        }

    var body: some View {
        VStack{
            if isDataLoaded {
                // データがロードされたらQuizViewを表示
                QuizView(quizzes: shuffledQuizList, quizLevel: .incorrectInfoAnswer, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
            } else {
                ActivityIndicator()
            }
        }
        .onAppear {
            // ビューが表示された時にデータをフェッチする
            fetchInfoIncorrectAnswers(userId: authManager.currentUserId!) { quizList in
                self.shuffledQuizList = quizList.shuffled()
                print("self.shuffledQuizList")
//                print(self.shuffledQuizList)
                self.isDataLoaded = true // データロード完了
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.isDataLoaded = true
//            }
        }
    }
    }
    
func fetchInfoIncorrectAnswers(userId: String, completion: @escaping ([QuizQuestion]) -> Void) {
    let ref = Database.database().reference().child("IncorrectInfoAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
        var quizList = [QuizQuestion]()
        
        for child in snapshot.children {
            if let childSnapshot = child as? DataSnapshot,
               let dict = childSnapshot.value as? [String: Any],
               let question = dict["quizQuestion"] as? String,
               let choices = dict["choices"] as? [String],
               let correctAnswerIndex = dict["correctAnswerIndex"] as? Int,
               let explanation = dict["explanation"] as? String {
                let quizId = childSnapshot.key // クイズIDを取得
                let quiz = QuizQuestion(id: quizId, question: question, choices: choices, correctAnswerIndex: correctAnswerIndex, explanation: explanation)
                quizList.append(quiz)
            }
        }
        
        completion(quizList)
    }
}


struct QuizInfoIncorrectAnswerListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizInfoIncorrectAnswerListView(isPresenting: .constant(false))
    }
}

