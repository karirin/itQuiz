//
//  TutorialStoryModalView.swift
//  it
//
//  Created by Apple on 2024/12/07.
//

import SwiftUI

struct StoryTutorialStep {
    let title: String
    let body: String
    let iconName: String
    let colors: [Color]
}

struct TutorialStoryModalView: View {
    @Binding var isPresented: Bool
    @Binding var isTutorialStart: Bool
    @State private var currentStep = 0

    private let steps: [StoryTutorialStep] = [
        StoryTutorialStep(
            title: "進む・戦う・報酬を得る",
            body: "ダンジョンでは次のマスを選び、モンスターやライバルと戦いながら少しずつ前進します。",
            iconName: "figure.walk.motion",
            colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        ),
        StoryTutorialStep(
            title: "特殊マスを活かす",
            body: "休憩マス、分岐イベント、学習イベントではスタミナ回復や一時ブーストを獲得できます。",
            iconName: "sparkles.rectangle.stack.fill",
            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")]
        ),
        StoryTutorialStep(
            title: "学習しながら冒険を続ける",
            body: "スタミナが足りない時も、短い復習や回復薬を使ってテンポよく学習を続けられます。",
            iconName: "book.fill",
            colors: [Color(hex: "43cea2"), Color(hex: "185a9d")]
        )
    ]

    var body: some View {
        let step = steps[currentStep]

        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    finishTutorial()
                }

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: step.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: step.iconName)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(step.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(step.body)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                HStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.24))
                            .frame(width: index == currentStep ? 30 : 10, height: 10)
                    }
                }

                Button(action: {
                    if currentStep + 1 < steps.count {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                            currentStep += 1
                        }
                    } else {
                        finishTutorial()
                    }
                }) {
                    Text(currentStep + 1 == steps.count ? "ガイドを始める" : "次へ")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(width: isSmallDevice() ? 330 : 360)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [step.colors.first ?? .black, step.colors.last ?? .black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(24)
        }
    }

    private func finishTutorial() {
        generateHapticFeedback()
        isPresented = false
        isTutorialStart = true
    }

    private func isSmallDevice() -> Bool {
        UIScreen.main.bounds.width < 390
    }
}

#Preview {
    TutorialStoryModalView(isPresented: .constant(true), isTutorialStart: .constant(false))
}
