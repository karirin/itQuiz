//
//  MemoView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI

struct QuizMemo {
    var question: String
    var memo: String
}

struct MemoView: View {
    @Binding var memo: String
    var question: String

    var body: some View {
        VStack {
            Text(question)
                .font(.headline)
            TextEditor(text: $memo)
                .padding()
            Button("保存") {
                UserDefaults.standard.set(memo, forKey: question)
            }
            .padding()
        }
    }
}


struct MemoView_Previews: PreviewProvider {
    @State static var dummyMemo = "これはダミーのメモです。"
    static var previews: some View {
        MemoView(memo: $dummyMemo, question: "ダミーの質問")
    }
}
