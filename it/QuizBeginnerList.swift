//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizQuestion {
    var question: String
    var choices: [String]
    var correctAnswerIndex: Int
    var explanation: String
}

struct QuizBeginnerList: View {
    @Binding var isPresenting: Bool
    let quizBeginnerList: [QuizQuestion] = [
        QuizQuestion(
            question: "あああああああああああああああああああああああああああああああああああああああああああああああああああああああああ",
            choices: [
                "電源ケーブル",
                "Eメールの添付ファイル",
                "モニター",
                "キーボード"
            ],
            correctAnswerIndex: 1,
            explanation: " Eメールの添付ファイルは、コンピュータウイルスの感染経路として非常に一般的です。不明な送信元からのメールの添付ファイルは開かないよう注意が必要です。"
        )
        ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    @ObservedObject var audioManager : AudioManager

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
        self.audioManager = AudioManager()
    }

    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .beginner, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting)
    }
}

struct QuizList_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList(isPresenting: .constant(false))
    }
}
