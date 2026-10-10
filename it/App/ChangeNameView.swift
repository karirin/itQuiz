//
//  ChangeNameView.swift
//  sukimaKanji
//
//  Created by Apple on 2024/06/23.
//

import SwiftUI
import Firebase
import FirebaseDatabase

struct ChangeNameView: View {
    @Binding var isPresented: Bool
    @Binding var isReturnBtn: Bool
    @Binding var tutorialNum: Int

    @State private var userName: String = ""
    @State private var showAlert = false
    @State private var didSave = false
    @State private var isSaving = false
    @State private var appearAnimation = false
    @State private var shakeAnimation = false

    @ObservedObject var authManager: AuthManager
    var isInitialRegistration = false
    var registrationUnavailableMessage: String? = nil
    var onNameSaved: ((String) -> Void)? = nil
    var saveName: ((String, @escaping (Bool) -> Void) -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode

    private var trimmedUserName: String {
        userName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // カラーテーマ
    private let primaryGradient = LinearGradient(
        colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.6, green: 0.4, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景オーバーレイ
                Color.black.opacity(appearAnimation ? 0.5 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if isInitialRegistration {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        } else if isReturnBtn {
                            dismissWithAnimation()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: appearAnimation)

                // メインカード
                ScrollView {
                    VStack(spacing: 0) {
                        // ヘッダー部分
                        ZStack {
                            // 背景グラデーション
                            primaryGradient

                            VStack(spacing: 8) {
                                // アイコン
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 56, height: 56)

                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(.white)
                                }

                                Text("名前を登録")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            // 閉じるボタン
                            if isReturnBtn && !isInitialRegistration {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            generateHapticFeedback()
                                            dismissWithAnimation()
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(width: 32, height: 32)

                                                Image(systemName: "xmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .disabled(isSaving)
                                        .accessibilityLabel("名前登録を閉じる")
                                        .padding(.trailing, 16)
                                        .padding(.top, 12)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .clipShape(
                            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        )
                        .frame(height: 130)

                        // コンテンツ部分
                        VStack(spacing: 24) {
                            if isInitialRegistration {
                                Text("おともと一緒に冒険する名前を決めましょう。\nランキングなどにも表示されます。")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            // 警告メッセージ
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)

                                Text("一度登録すると変更できません")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )

                            // 入力フィールド
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ユーザー名")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color("fontGray").opacity(0.7))

                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.gray.opacity(0.5))

                                    TextField("例: IT太郎", text: $userName)
                                        .accessibilityIdentifier("nameRegistration.name")
                                        .disabled(isSaving)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color("fontGray"))
                                        .onChange(of: userName) { newValue in
                                            if newValue.count > 10 {
                                                userName = String(newValue.prefix(10))
                                                withAnimation(.default) {
                                                    shakeAnimation = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    shakeAnimation = false
                                                }
                                            }
                                        }

                                    Spacer()

                                    Text("\(userName.count)/10")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(
                                            userName.count >= 10
                                            ? .orange
                                            : Color("fontGray").opacity(0.5)
                                        )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(UIColor.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            trimmedUserName.isEmpty
                                            ? Color.gray.opacity(0.2)
                                            : Color.blue.opacity(0.5),
                                            lineWidth: 1.5
                                        )
                                )
                                .offset(x: shakeAnimation ? -5 : 0)
                                .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: shakeAnimation)
                            }

                            if let registrationUnavailableMessage {
                                Text(registrationUnavailableMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            // 登録ボタン
                            Button(action: {
                                generateHapticFeedback()
                                isSaving = true

                                let name = trimmedUserName
                                let completion: (Bool) -> Void = { success in
                                    DispatchQueue.main.async {
                                        isSaving = false
                                        didSave = success
                                        showAlert = true
                                    }
                                }
                                if let saveName {
                                    saveName(name, completion)
                                } else {
                                    authManager.updateUserName(userName: name, completion: completion)
                                }
                            }) {
                                HStack(spacing: 10) {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                    }

                                    Text(isSaving ? "登録中..." : "登録する")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Group {
                                        if trimmedUserName.isEmpty {
                                            Color.gray.opacity(0.4)
                                        } else {
                                            primaryGradient
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(
                                    color: trimmedUserName.isEmpty ? .clear : Color.blue.opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                            }
                            .disabled(trimmedUserName.isEmpty || isSaving || registrationUnavailableMessage != nil)
                            .accessibilityIdentifier("nameRegistration.save")
                            .scaleEffect(trimmedUserName.isEmpty ? 1.0 : 1.0)
                            .animation(.spring(response: 0.3), value: trimmedUserName.isEmpty)

                            if isInitialRegistration {
                                Button("あとで登録する", action: dismissWithAnimation)
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .disabled(isSaving)
                                    .accessibilityIdentifier("onboarding.skipNameRegistration")
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .frame(maxWidth: 440)
                .frame(height: min(isInitialRegistration ? 560 : 400, max(0, geometry.size.height - 32)))
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
                .padding(.horizontal, 28)
                .scaleEffect(appearAnimation ? 1.0 : 0.9)
                .opacity(appearAnimation ? 1.0 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(didSave ? "完了" : "登録できませんでした"),
                message: Text(didSave ? "名前が登録されました" : "通信状態を確認して、もう一度お試しください。"),
                dismissButton: .default(Text("OK")) {
                    guard didSave else { return }
                    onNameSaved?(trimmedUserName)
                    if !isReturnBtn {
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                            tutorialNum = 1
                            isPresented = false
                        }
                    } else {
                        isPresented = false
                    }
                }
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appearAnimation = true
            }
        }
    }

    private func dismissWithAnimation() {
        guard !isSaving else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            appearAnimation = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// カスタムコーナー用のShape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// プレビュー用
struct ChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()

            ChangeNameView(
                isPresented: .constant(true),
                isReturnBtn: .constant(true),
                tutorialNum: .constant(0),
                authManager: AuthManager.shared
            )
        }
    }
}
