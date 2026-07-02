//
//  HelpStoryModalView.swift
//  it
//
//  Created by Apple on 2024/12/07.
//

import SwiftUI

struct HelpStoryModalView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @StateObject var store: Store = Store()
    @State var toggle = false
    @State private var text: String = ""
    @State private var showAlert = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                    if toggle == true {
                        authManager.updateUserStoryCsFlag(userId: authManager.currentUserId!, userCsFlag: 1) { success in
                        }
                    }
                }

            VStack(spacing: 16) {
                // ヘッダー
                ZStack {
                    Circle()
                        .fill(Color(hex: "667eea").opacity(0.12))
                        .frame(width: 56, height: 56)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "667eea"))
                }

                Text("ダンジョンモードで遊んでいただき\nありがとうございます！")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("fontGray"))
                    .multilineTextAlignment(.center)

                Text("今後のアップデートのため\n改善点のご意見をいただけると励みになります")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField(
                    "例）メッセージが送信されない",
                    text: $text,
                    axis: .vertical
                )
                .font(.system(size: 15))
                .padding(14)
                .background(Color(hex: "f5f7fa"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(hex: "667eea").opacity(0.3), lineWidth: 1.5)
                )

                Button(action: {
                    generateHapticFeedback()
                    if toggle == true {
                        authManager.updateUserStoryCsFlag(userId: authManager.currentUserId!, userCsFlag: 1) { success in
                        }
                    }
                    authManager.updateContact(userId: authManager.currentUserId!, newContact: text) { success in
                        if success {
                            self.showAlert = true
                            print("Heart added successfully.")
                        } else {
                            print("Failed to add heart.")
                        }
                    }
                }, label: {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("送信")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color(hex: "667eea").opacity(0.35), radius: 8, y: 4)
                })
                .buttonStyle(PlainButtonStyle())
                .opacity(text.isEmpty ? 0.5 : 1)
                .disabled(text.isEmpty)

                Toggle(isOn: $toggle) {
                    Text("今後は表示しない")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .toggleStyle(SwitchToggleStyle())
                .tint(Color(hex: "667eea"))
            }
            .alert(isPresented: $showAlert) { // アラートを表示する
                Alert(
                    title: Text("送信されました"),
                    message: Text("お問い合わせありがとうございます！"),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
            .padding(24)
            .frame(width: isSmallDevice() ? 300 : 330)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .overlay(
                // 閉じるボタン
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    if toggle == true {
                        authManager.updateUserStoryCsFlag(userId: authManager.currentUserId!, userCsFlag: 1) { success in
                        }
                    }
                    isPresented = false
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                }
            }
        }
    }

    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    HelpStoryModalView(audioManager: AudioManager(), isPresented: .constant(true))
}
