//
//  AnswerSelectionView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/29.
//

import SwiftUI
import StoreKit
import UIKit

// 現在のデバイスがiPadかどうかを判定する関数
func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

struct AnswerSelectionView: View {
    let choices: [String]
    var action: (Int) -> Void
    var correctAnswerIndex: Int?
    @State private var tappedIndex: Int? = nil
    @State private var appearAnimation: [Bool] = []

    init(choices: [String], correctAnswerIndex: Int?, action: @escaping (Int) -> Void) {
        self.choices = choices
        self.correctAnswerIndex = correctAnswerIndex
        self.action = action
        self._appearAnimation = State(initialValue: Array(repeating: false, count: choices.count))
    }

    var body: some View {
        VStack(spacing: isIPad() ? 16 : 12) {
            ForEach(0..<choices.count, id: \.self) { index in
                AnswerButton(
                    text: choices[index],
                    index: index,
                    isCorrect: index == correctAnswerIndex,
                    isTapped: tappedIndex == index,
                    hasAnswered: correctAnswerIndex != nil,
                    isVisible: appearAnimation.indices.contains(index) ? appearAnimation[index] : false
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        tappedIndex = index
                    }
                    
                    if index == correctAnswerIndex {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                    generateHapticFeedback()
                    self.action(index)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring()) {
                            tappedIndex = nil
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            // スタガードアニメーション
            for index in 0..<choices.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        if appearAnimation.indices.contains(index) {
                            appearAnimation[index] = true
                        }
                    }
                }
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let index: Int
    let isCorrect: Bool
    let isTapped: Bool
    let hasAnswered: Bool
    let isVisible: Bool
    let action: () -> Void
    
    private var buttonBackground: some View {
        Group {
            if hasAnswered {
                if isCorrect {
                    // 正解の選択肢 - グリーングラデーション
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.4),
                            Color(red: 0.1, green: 0.7, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // 不正解後の通常選択肢
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color(red: 0.98, green: 0.98, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                // 未回答時
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.98, green: 0.98, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    private var borderColor: Color {
        if hasAnswered && isCorrect {
            return Color(red: 0.1, green: 0.7, blue: 0.3)
        }
        return Color.gray.opacity(0.15)
    }
    
    private var textColor: Color {
        if hasAnswered && isCorrect {
            return .white
        }
        return Color("fontGray")
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                // 選択肢テキスト
                Text(text)
                    .font(.system(size: fontSize(for: text, isIPad: isIPad()), weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                
                Spacer()
                
                // 正解アイコン
                if hasAnswered && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: hasAnswered && isCorrect ? 2 : 1)
            )
            .shadow(
                color: hasAnswered && isCorrect
                    ? Color.green.opacity(0.3)
                    : Color.black.opacity(0.06),
                radius: hasAnswered && isCorrect ? 12 : 8,
                x: 0,
                y: hasAnswered && isCorrect ? 6 : 4
            )
            .scaleEffect(isTapped ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }
}

// テキストサイズを決定する関数
func fontSize(for text: String, isIPad: Bool) -> CGFloat {
    let baseFontSize: CGFloat = isIPad ? 22 : 16

    let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let textCharacterSet = CharacterSet(charactersIn: text)

    if englishAlphabet.isSuperset(of: textCharacterSet) {
        return baseFontSize
    } else {
        if text.count >= 25 {
            return baseFontSize - 4
        } else if text.count >= 21 {
            return baseFontSize - 3
        } else if text.count >= 17 {
            return baseFontSize - 2
        } else {
            return baseFontSize
        }
    }
}

struct AnswerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.98)
                .ignoresSafeArea()
            
            VStack {
                AnswerSelectionView(
                    choices: ["選択肢A: これは最初の選択肢です", "選択肢B: 二番目の選択肢", "選択肢C: 三番目", "選択肢D: 最後の選択肢"],
                    correctAnswerIndex: 1
                ) { index in
                    print("選択肢 \(index + 1) がタップされました")
                }
            }
        }
    }
}
