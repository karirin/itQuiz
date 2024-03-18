//
//  AnswerSelectionView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/29.
//

import SwiftUI
import StoreKit

// 現在のデバイスがiPadかどうかを判定する関数
func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

struct AnswerSelectionView: View {
    let choices: [String]
    var action: (Int) -> Void
    var correctAnswerIndex: Int? // 正解の選択肢のインデックス

    init(choices: [String], correctAnswerIndex: Int?, action: @escaping (Int) -> Void) {
        self.choices = choices
        self.correctAnswerIndex = correctAnswerIndex
        self.action = action
    }

    var body: some View {
        VStack {
            Spacer()
            ForEach(0..<choices.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    self.action(index)
                }) {
                    Text(self.choices[index])
                        .font(.system(size: fontSize(for: self.choices[index], isIPad: isIPad())))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(index == correctAnswerIndex ? Color("lightYelleow") : Color.white)
                        .foregroundColor(Color("fontGray"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical, isIPad() ? 10 : 2) // iPadでは垂直のパディングを増やす
            }
            Spacer()
                       Spacer()
        }
    }
}

// テキストサイズを決定する関数
func fontSize(for text: String, isIPad: Bool) -> CGFloat {
    let baseFontSize: CGFloat = isIPad ? 24 : 20 // iPad用のベースフォントサイズを大きくする

    let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let textCharacterSet = CharacterSet(charactersIn: text)

    if englishAlphabet.isSuperset(of: textCharacterSet) {
        return baseFontSize
    } else {
        if text.count >= 25 {
            return baseFontSize - 6
        } else if text.count >= 21 {
            return baseFontSize - 6
        } else if text.count >= 17 {
            return baseFontSize - 6
        } else {
            return baseFontSize - 4
        }
    }
}

struct AnswerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSelectionView(choices: ["選択肢1", "選択肢2", "選択肢3"], correctAnswerIndex: 1) { index in
//            print("選択肢 \(index + 1) がタップされました")
        }
    }
}
