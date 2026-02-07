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
    @State private var isSaving = false
    @State private var appearAnimation = false
    @State private var shakeAnimation = false
    
    @ObservedObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

    // カラーテーマ
    private let primaryGradient = LinearGradient(
        colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.6, green: 0.4, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(appearAnimation ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    if isReturnBtn {
                        dismissWithAnimation()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: appearAnimation)
            
            // メインカード
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
                    if isReturnBtn {
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
                
                // コンテンツ部分
                VStack(spacing: 24) {
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
                                    userName.isEmpty
                                    ? Color.gray.opacity(0.2)
                                    : Color.blue.opacity(0.5),
                                    lineWidth: 1.5
                                )
                        )
                        .offset(x: shakeAnimation ? -5 : 0)
                        .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: shakeAnimation)
                    }
                    
                    // 登録ボタン
                    Button(action: {
                        generateHapticFeedback()
                        isSaving = true
                        
                        authManager.updateUserName(userName: userName) { success in
                            isSaving = false
                            if success {
                                showAlert = true
                            }
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
                                if userName.isEmpty {
                                    Color.gray.opacity(0.4)
                                } else {
                                    primaryGradient
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: userName.isEmpty ? .clear : Color.blue.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(userName.isEmpty || isSaving)
                    .scaleEffect(userName.isEmpty ? 1.0 : 1.0)
                    .animation(.spring(response: 0.3), value: userName.isEmpty)
                }
                .padding(24)
                .background(Color.white)
            }
            .frame(height:400)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
            .padding(.horizontal, 28)
            .scaleEffect(appearAnimation ? 1.0 : 0.9)
            .opacity(appearAnimation ? 1.0 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appearAnimation)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("完了"),
                message: Text("名前が登録されました"),
                dismissButton: .default(Text("OK")) {
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
