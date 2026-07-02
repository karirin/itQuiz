//
//  ModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/04.
//

import SwiftUI

struct RankModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
    @Binding var tutorialNum: Int
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    @Binding var userFlag: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("メニュー")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("fontGray"))
                    .padding(.top, 4)

                // 解説画面 表示/非表示
                Button(action: {
                    generateHapticFeedback()
                    isSoundOn.toggle()
                    audioManager.playSound()
                    if userFlag == 0 {
                        userFlag = 1
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1)
                    } else {
                        userFlag = 0
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 0)
                    }
                }) {
                    menuRow(
                        icon: isSoundOn ? "eye.slash.fill" : "eye.fill",
                        iconColor: Color(hex: "667eea"),
                        title: isSoundOn ? "解説画面を非表示にする" : "解説画面を表示する"
                    )
                }
                .buttonStyle(PlainButtonStyle())

                // ヘルプ
                Button(action: {
                    generateHapticFeedback()
                    showHomeModal = false
                    tutorialNum = 3
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                    }
                    audioManager.playSound()
                }) {
                    menuRow(
                        icon: "questionmark.circle.fill",
                        iconColor: Color(hex: "11998e"),
                        title: "ヘルプ"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .overlay(
                // 閉じるボタン
                Button(action: {
                    generateHapticFeedback()
                    isPresented = false
                    resumeTimer()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white, Color.black.opacity(0.35))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 8, y: -8),
                alignment: .topTrailing
            )
        }
        .onAppear {
            pauseTimer() // モーダルが表示されたときにタイマーを一時停止
            if userFlag == 0 {
                isSoundOn = true
            } else {
                isSoundOn = false
            }
        }
    }

    private func menuRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("fontGray"))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(12)
        .background(Color(hex: "f5f7fa"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
