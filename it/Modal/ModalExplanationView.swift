//
//  ModalExplanationView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/11.
//

import SwiftUI
import Firebase

struct ModalExplanationView: View {
    @Binding var isPresented: Bool
    @Binding var selectedAnswerIndex: Int?
    @ObservedObject var authManager = AuthManager.shared
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @Binding var showAlert: Bool
    @ObservedObject var audioManager: AudioManager
    var question: String
    var userAnswer: String
    var correctAnswer: String
    var explanation: String
    @Binding var currentQuizIndex: Int
    @Binding var userFlag: Int
    var pauseTimer: () -> Void
    var startTimer: () -> Void

    private var isCorrect: Bool {
        userAnswer == correctAnswer
    }

    private var resultGradient: LinearGradient {
        LinearGradient(
            colors: isCorrect
                ? [Color(hex: "11998e"), Color(hex: "38ef7d")]
                : [Color(hex: "eb3349"), Color(hex: "f45c43")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            // 非表示ボタン
            HStack {
                Spacer()
                Button(action: {
                    generateHapticFeedback()
                    currentQuizIndex += 1
                    selectedAnswerIndex = nil
                    startTimer()
                    audioManager.playCancelSound()
                    userFlag = 1
                    if let userId = authManager.currentUserId {
                        authManager.updateUserFlag(userId: userId, userFlag: 1)
                    }
                    showAlert = true
                    isPresented = false
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("解説画面を非表示にする")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)

            // メインカード
            VStack(spacing: 0) {
                // 結果ヘッダー
                HStack(spacing: 10) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text(isCorrect ? "正解！" : "不正解")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(resultGradient)

                // 内容
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        explanationSection(label: "問題内容", icon: "doc.text.fill", text: question)

                        HStack(alignment: .top, spacing: 12) {
                            answerCard(
                                label: "あなたの回答",
                                text: userAnswer,
                                color: isCorrect ? Color(hex: "11998e") : Color(hex: "eb3349")
                            )
                            answerCard(
                                label: "正解",
                                text: correctAnswer,
                                color: Color(hex: "11998e")
                            )
                        }

                        explanationSection(label: "解説", icon: "lightbulb.fill", text: explanation)
                    }
                    .padding(20)
                }

                // 次の問題へボタン
                Button(action: {
                    generateHapticFeedback()
                    currentQuizIndex += 1
                    isPresented = false
                    selectedAnswerIndex = nil
                    startTimer()
                    audioManager.playCancelSound()
                }) {
                    HStack(spacing: 8) {
                        Text("次の問題へ")
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        }
        .padding(16)
        .onAppear {
            pauseTimer()  // モーダルが表示されたときにタイマーを一時停止
        }
    }

    // MARK: - Components

    private func explanationSection(label: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "667eea"))
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("fontGray"))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func answerCard(label: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("fontGray"))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}
