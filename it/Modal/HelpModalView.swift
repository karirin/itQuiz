//
//  HelpModalView.swift
//  osimono
//
//  Created by Apple on 2025/05/03.
//  Updated with modern design system
//

import SwiftUI
import Foundation

struct HelpModalView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var isSubmitting: Bool = false
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isFocused {
                        dismissModal()
                    } else {
                        isFocused = false
                    }
                }
            
            // メインモーダル
            VStack(spacing: 0) {
                // ヘッダー
                headerView
                
                // コンテンツ
                VStack(spacing: 20) {
                    // 説明テキスト
                    Text("ご意見やご要望がありましたら、お気軽にお知らせください。可能な限り対応いたします。")
                        .font(.system(size: isSmallDevice() ? 14 : 15))
                        .foregroundColor(Color("fontGray").opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    // テキスト入力エリア
                    VStack(alignment: .leading, spacing: 8) {
                        Label("問い合わせ内容", systemImage: "text.bubble")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("fontGray").opacity(0.7))
                        
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty && !isFocused {
                                Text("例）問題画面が表示されない")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }
                            
                            TextEditor(text: $text)
                                .focused($isFocused)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(Color("fontGray"))
                        }
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            isFocused ? Color(hex: "667eea") : Color.gray.opacity(0.2),
                                            lineWidth: isFocused ? 2 : 1
                                        )
                                )
                        )
                        .animation(.easeOut(duration: 0.2), value: isFocused)
                    }
                    
                    // 送信ボタン
                    Button(action: submitFeedback) {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            
                            Text(isSubmitting ? "送信中..." : "送信する")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Group {
                                if text.isEmpty || isSubmitting {
                                    Color.gray.opacity(0.4)
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: text.isEmpty ? .clear : Color(hex: "667eea").opacity(0.3),
                            radius: 8,
                            y: 4
                        )
                    }
                    .disabled(text.isEmpty || isSubmitting)
                    .buttonStyle(ScaleButtonStyle())
                    
                    // トグル
                    HStack {
                        Text("今後は表示しない")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("fontGray").opacity(0.7))
                        
                        Spacer()
                        
                        Toggle("", isOn: $toggle)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "667eea")))
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
                .padding(24)
                .background(Color("Color2"))
            }
            .frame(width: isSmallDevice() ? 320 : 350)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 30, y: 15)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("送信完了"),
                message: Text("お問い合わせいただきありがとうございます🙇"),
                dismissButton: .default(Text("OK")) {
                    dismissModal()
                }
            )
        }
        .onTapGesture {
            isFocused = false
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // デコレーション
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 80, height: 80)
                .offset(x: -100, y: -20)
            
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("お問い合わせ")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // 閉じるボタン
                Button(action: dismissModal) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
        .clipShape(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
        )
    }
    
    // MARK: - Actions
    private func submitFeedback() {
        generateHapticFeedback()
        isSubmitting = true
        
        if toggle {
            authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { _ in }
        }
        
        authManager.updateContact(userId: authManager.currentUserId!, newContact: text) { success in
            isSubmitting = false
            if success {
                showAlert = true
            }
        }
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        
        if toggle {
            authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { _ in }
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    HelpModalView(isPresented: .constant(true))
}
