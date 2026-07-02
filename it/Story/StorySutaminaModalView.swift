//
//  StorySutaminaModalView.swift
//  it
//
//  Created by Apple on 2024/12/01.
//

import SwiftUI

struct StoryRecoveryQuestion: Identifiable {
    let id = UUID()
    let question: String
    let choices: [String]
    let correctAnswerIndex: Int
}

struct StorySutaminaModalView: View {
    @StateObject var reward = Reward()
    @ObservedObject var viewModel: PositionViewModel
    @ObservedObject var audioManager = AudioManager.shared
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool

    @State private var showRewardAlert = false
    @State private var showStudyDrill = false
    @State private var selectedAnswerIndex: Int? = nil
    @State private var currentQuestionIndex = 0
    @State private var studyCorrectCount = 0
    @State private var showStudyResult = false
    @State private var usedPotionMessage = ""
    @State private var showPotionAlert = false

    private let studyRecoveryCooldownKey = "story.studyRecovery.lastUsedAt"

    private let studyQuestions: [StoryRecoveryQuestion] = [
        StoryRecoveryQuestion(
            question: "CPUの主な役割は？",
            choices: ["入出力を物理的に接続する", "計算や制御を行う", "画面を表示する", "データだけを長期保存する"],
            correctAnswerIndex: 1
        ),
        StoryRecoveryQuestion(
            question: "HTTPSの特徴として正しいものは？",
            choices: ["画像だけを圧縮する", "通信を暗号化する", "メールを送信する", "IPアドレスを配布する"],
            correctAnswerIndex: 1
        ),
        StoryRecoveryQuestion(
            question: "データベースの主キーの説明として最も適切なのは？",
            choices: ["重複してよい識別子", "表を結合するためだけの列", "レコードを一意に識別する列", "必ず文字列である列"],
            correctAnswerIndex: 2
        )
    ]

    private var studyRecoveryRemaining: String? {
        guard let lastUsedAt = UserDefaults.standard.object(forKey: studyRecoveryCooldownKey) as? Date else {
            return nil
        }
        let remaining = max(600 - Date().timeIntervalSince(lastUsedAt), 0)
        guard remaining > 0 else { return nil }
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.74)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Image(systemName: "bolt.slash.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("スタミナが足りません")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("次の自然回復まで \(viewModel.nextRecoveryText)\n待つ間も、短い復習やアイテムで冒険を続けられます")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.84))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        recoveryShortcutButton(
                            icon: "cross.case.fill",
                            title: "回復薬",
                            subtitle: "\(authManager.staminaPotionCount)個",
                            accentColors: [Color(hex: "43cea2"), Color(hex: "185a9d")],
                            disabled: authManager.staminaPotionCount == 0,
                            action: usePotion
                        )

                        recoveryShortcutButton(
                            icon: "play.rectangle.fill",
                            title: "広告で回復",
                            subtitle: reward.rewardLoaded ? "+30回復" : "読込中",
                            accentColors: [Color(hex: "f7971e"), Color(hex: "ffd200")],
                            disabled: !reward.rewardLoaded,
                            action: showReward
                        )
                    }

                    actionCard(
                        icon: "book.fill",
                        title: "3問復習して +5回復",
                        subtitle: studyRecoveryRemaining == nil
                            ? "短い学習で再出発。全問正解で次戦ブーストも追加"
                            : "次の挑戦可能まで \(studyRecoveryRemaining!)",
                        accentColors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        disabled: studyRecoveryRemaining != nil,
                        action: startStudyDrill
                    )
                }

                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
                }) {
                    Text("あとで戻る")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white.opacity(0.84))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1f4037"), Color(hex: "99f2c8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
            )
            .padding(24)

            if showStudyDrill {
                studyDrillOverlay
            }
        }
        .alert("報酬獲得！", isPresented: $showRewardAlert) {
            Button("OK") {
                showRewardAlert = false
                reward.rewardEarned = false
                isPresented = false
            }
        } message: {
            Text("30スタミナが回復しました")
        }
        .alert("回復薬を使用しました", isPresented: $showPotionAlert) {
            Button("OK") {
                showPotionAlert = false
                if usedPotionMessage == "success" {
                    isPresented = false
                }
            }
        } message: {
            Text(usedPotionMessage == "success" ? "スタミナが30回復しました" : "回復薬が足りません")
        }
        .onAppear {
            reward.LoadStoryReward()
        }
        .onChange(of: reward.rewardEarned) { rewardEarned in
            showRewardAlert = rewardEarned
        }
    }

    private func actionCard(
        icon: String,
        title: String,
        subtitle: String,
        accentColors: [Color],
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.84))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: disabled
                                ? [Color.black.opacity(0.24), Color.black.opacity(0.16)]
                                : accentColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(disabled ? 0.08 : 0.18), lineWidth: 1)
                    )
            )
            .opacity(disabled ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func recoveryShortcutButton(
        icon: String,
        title: String,
        subtitle: String,
        accentColors: [Color],
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.84))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: disabled
                                ? [Color.black.opacity(0.24), Color.black.opacity(0.16)]
                                : accentColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(disabled ? 0.08 : 0.18), lineWidth: 1)
                    )
            )
            .opacity(disabled ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private var studyDrillOverlay: some View {
        let question = studyQuestions[currentQuestionIndex]

        return ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("復習チャレンジ")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Question \(currentQuestionIndex + 1) / \(studyQuestions.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.72))

                Text(question.question)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(Array(question.choices.enumerated()), id: \.offset) { entry in
                        let index = entry.offset
                        let choice = entry.element
                        Button(action: {
                            answerStudyQuestion(index)
                        }) {
                            HStack {
                                Text(choice)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedAnswerIndex == index ? Color.white.opacity(0.18) : Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedAnswerIndex != nil)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .padding(24)
        }
        .alert("復習完了", isPresented: $showStudyResult) {
            Button("OK") {
                showStudyResult = false
                showStudyDrill = false
                isPresented = false
            }
        } message: {
            Text(studyCorrectCount == studyQuestions.count
                 ? "全問正解です。スタミナを5回復し、次の戦闘ブーストも獲得しました。"
                 : "3問解ききったのでスタミナを5回復しました。")
        }
    }

    private func usePotion() {
        generateHapticFeedback()
        authManager.useStaminaPotion { success in
            usedPotionMessage = success ? "success" : "failed"
            showPotionAlert = true
        }
    }

    private func startStudyDrill() {
        generateHapticFeedback()
        audioManager.playKetteiSound()
        selectedAnswerIndex = nil
        currentQuestionIndex = 0
        studyCorrectCount = 0
        showStudyDrill = true
    }

    private func showReward() {
        generateHapticFeedback()
        reward.ShowSutaminaReward()
    }

    private func answerStudyQuestion(_ index: Int) {
        selectedAnswerIndex = index
        let question = studyQuestions[currentQuestionIndex]
        let isAnswerCorrect = index == question.correctAnswerIndex
        authManager.recordAnswer(isCorrect: isAnswerCorrect)

        if isAnswerCorrect {
            studyCorrectCount += 1
            audioManager.playCorrectSound()
        } else {
            audioManager.playUnCorrectSound()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            if currentQuestionIndex + 1 < studyQuestions.count {
                currentQuestionIndex += 1
                selectedAnswerIndex = nil
            } else {
                finishStudyRecovery()
            }
        }
    }

    private func finishStudyRecovery() {
        UserDefaults.standard.set(Date(), forKey: studyRecoveryCooldownKey)
        viewModel.recoverStamina(by: 5)
        if studyCorrectCount == studyQuestions.count {
            viewModel.addDungeonBoost(type: .attackSurge, charges: 1)
        }
        showStudyResult = true
    }
}

#Preview {
    StorySutaminaModalView(viewModel: PositionViewModel.shared, isPresented: .constant(true))
}
