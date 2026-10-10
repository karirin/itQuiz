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
    var preservesDisabledAppearance: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tappedIndex: Int? = nil
    @State private var resultPulse = false
    @State private var resultSequence = 0
    @State private var appearAnimation: [Bool] = []

    init(choices: [String], correctAnswerIndex: Int?, preservesDisabledAppearance: Bool = false, action: @escaping (Int) -> Void) {
        self.choices = choices
        self.correctAnswerIndex = correctAnswerIndex
        self.preservesDisabledAppearance = preservesDisabledAppearance
        self.action = action
        self._appearAnimation = State(initialValue: Array(repeating: false, count: choices.count))
    }

    var body: some View {
        VStack(spacing: isIPad() ? 16 : 12) {
            ForEach(0..<choices.count, id: \.self) { index in
                AnswerButton(
                    text: choices[index],
                    isCorrect: index == correctAnswerIndex,
                    isIncorrect: correctAnswerIndex != nil && tappedIndex == index && index != correctAnswerIndex,
                    isTapped: tappedIndex == index,
                    resultPulse: resultPulse && !reduceMotion,
                    hasAnswered: correctAnswerIndex != nil,
                    isVisible: appearAnimation.indices.contains(index) ? appearAnimation[index] : false,
                    preservesDisabledAppearance: preservesDisabledAppearance
                ) {
                    guard correctAnswerIndex == nil, tappedIndex == nil else { return }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.55)) {
                        tappedIndex = index
                    }
                    self.action(index)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onChange(of: correctAnswerIndex) { answerIndex in
            resultSequence += 1
            guard let answerIndex, let tappedIndex else {
                resultPulse = false
                self.tappedIndex = nil
                return
            }

            let sequence = resultSequence
            let isCorrect = tappedIndex == answerIndex
            UINotificationFeedbackGenerator().notificationOccurred(isCorrect ? .error : .success)
            withAnimation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.55)) {
                resultPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                guard resultSequence == sequence else { return }
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7)) {
                    resultPulse = false
                }
            }
        }
        .onAppear {
            // スタガードアニメーション
            for index in 0..<choices.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7)) {
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
    let isCorrect: Bool
    let isIncorrect: Bool
    let isTapped: Bool
    let resultPulse: Bool
    let hasAnswered: Bool
    let isVisible: Bool
    var preservesDisabledAppearance = false
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
                } else if isIncorrect {
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.38, blue: 0.40), Color(red: 0.88, green: 0.19, blue: 0.28)],
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
        if isIncorrect { return Color.red.opacity(0.8) }
        return Color.gray.opacity(0.15)
    }
    
    private var textColor: Color {
        if hasAnswered && (isCorrect || isIncorrect) {
            return .white
        }
        return Color("fontGray")
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // 選択肢テキスト
                Text(text)
                    .font(.system(size: fontSize(for: text, isIPad: isIPad()), weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                
                // 正解アイコン。幅は常に確保しておき、表示時に文字の折り返しが
                // 変わって選択肢の高さが動かないようにする
                Image(systemName: isIncorrect ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .opacity(hasAnswered && (isCorrect || isIncorrect) ? 1 : 0)
                    .scaleEffect(hasAnswered && (isCorrect || isIncorrect) ? 1 : 0.5)
                    .accessibilityHidden(!(hasAnswered && (isCorrect || isIncorrect)))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, text.count >= 40 ? 12 : 14)
            .frame(maxWidth: .infinity, minHeight: isIPad() ? 72 : 56)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: hasAnswered && (isCorrect || isIncorrect) ? 2 : 1)
            )
            .overlay {
                if hasAnswered && isCorrect {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(resultPulse ? 0.9 : 0), lineWidth: 3)
                        .scaleEffect(resultPulse ? 1.06 : 1.0)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: hasAnswered && isCorrect
                    ? Color.green.opacity(resultPulse ? 0.6 : 0.3)
                    : Color.black.opacity(0.06),
                radius: hasAnswered && isCorrect ? (resultPulse ? 20 : 12) : 8,
                x: 0,
                y: hasAnswered && isCorrect ? 6 : 4
            )
            .scaleEffect(hasAnswered && isCorrect && resultPulse ? 1.045 : (isTapped && !hasAnswered ? 0.94 : 1.0))
        }
        .modifier(AnswerButtonAppearance(preservesDisabledAppearance: preservesDisabledAppearance))
        .opacity(isVisible ? 1 : 0)
    }
}

/// 説明中の操作制限を保ったまま、スポットライト内のボタンを薄くしない。
private struct AnswerButtonAppearance: ViewModifier {
    let preservesDisabledAppearance: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if preservesDisabledAppearance {
            content.buttonStyle(UndimmedAnswerButtonStyle())
        } else {
            content.buttonStyle(.plain)
        }
    }
}

private struct UndimmedAnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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
        if text.count >= 70 {
            return baseFontSize - 5
        } else if text.count >= 45 {
            return baseFontSize - 4
        } else if text.count >= 30 {
            return baseFontSize - 3
        } else if text.count >= 21 {
            return baseFontSize - 2
        } else if text.count >= 17 {
            return baseFontSize - 1
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
                    choices: ["これは最初の選択肢です", "二番目の選択肢", "三番目の選択肢", "最後の選択肢"],
                    correctAnswerIndex: 1
                ) { index in
                    print("選択肢 \(index + 1) がタップされました")
                }
            }
        }
    }
}
