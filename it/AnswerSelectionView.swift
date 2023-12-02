//
//  AnswerSelectionView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/29.
//

import SwiftUI

func fontSize(for text: String) -> CGFloat {
    let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let textCharacterSet = CharacterSet(charactersIn: text)
    
    if englishAlphabet.isSuperset(of: textCharacterSet) {
        // テキストがアルファベットのみを含む場合、フォントサイズを20にします。
        return 20
    } else {
        if text.count >= 25 {
            return 14
        } else if text.count >= 21 {
            return 14
        } else if text.count >= 17 {
            return 14
        } else {
            return 16
        }
    }
}



struct AnswerSelectionView: View {
    let choices: [String]
    var action: (Int) -> Void
    var correctAnswerIndex: Int? // 正解の選択肢のインデックス
    @EnvironmentObject var appState: AppState
    
    init(choices: [String], correctAnswerIndex: Int?, action: @escaping (Int) -> Void) {
        self.choices = choices
        self.correctAnswerIndex = correctAnswerIndex
        self.action = action
    }

    var body: some View {
            VStack {
                
                Spacer()
                Spacer()
                ForEach(0..<choices.count, id: \.self) { index in
                    
                    Spacer()
                    Button(action: {
                        self.action(index)
                        print("answer correctAnswerIndex:\(correctAnswerIndex)")
                        print("answer index:\(index)")
                    }) {
                        Text(self.choices[index])
                            .font(.system(size: fontSize(for: self.choices[index])))
                        //                        .font(.system(size: 24))
                            .fixedSize(horizontal: false, vertical: true) // これを追加
                            .lineLimit(nil) // テキストを複数行にわたって表示
                        //                        .minimumScaleFactor(0.5) // フォントサイズを小さく調整してテキストをフィットさせます
                            .frame(maxWidth: .infinity)
                        //                        .padding(16)
                            .padding()
                            .background(index == correctAnswerIndex ? Color("lightYelleow") : Color.white)
//                            .background(index == correctAnswerIndex ? Color.red : Color.white)
                        //                        .foregroundColor(.black)
                            .foregroundColor(Color("fontGray"))
                            .cornerRadius(8)
                    }
                    //                .padding(.horizontal,20)
                    //                .padding(.vertical, 5)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                }
                .onAppear{
                    print("answer correctAnswerIndex:\(correctAnswerIndex)")
                    print("answer index:\(index)")
                }
                
                Spacer()
                Spacer()
//                if appState.isBannerVisible {
                    BannerView()
                        .frame(height: 60)
//                }
            }
        }
}

struct AnswerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSelectionView(choices: ["選択肢1あああああああああああああああああああああああああああああああああああああああああああああああああああああああ", "選択肢2", "選択肢3"], correctAnswerIndex: 1) { index in
            print("選択肢 \(index + 1) がタップされました")
        }
    }
}
