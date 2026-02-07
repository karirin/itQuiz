//
//  ModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/04.
//  Updated with modern design
//

import SwiftUI

struct ModalView: View {
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
    
    // アニメーション用
    @State private var showContent = false
    @State private var buttonScale: [Bool] = [false, false, false]
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // メインモーダル
            VStack(spacing: 0) {
                // ヘッダー
                ZStack {
                    // グラデーション背景
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(spacing: 8) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        
                        Text("一時停止")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 24)
                }
                .frame(height: 120)
                
                // メニューボタン
                VStack(spacing: 12) {
                    // ホームに戻るボタン
                    MenuButton(
                        icon: "house.fill",
                        title: "ホームに戻る",
                        iconColor: Color(hex: "FF6B6B"),
                        action: {
                            generateHapticFeedback()
                            isPresenting = false
                            audioManager.playReturnSound()
                        }
                    )
                    .scaleEffect(buttonScale[0] ? 1 : 0.8)
                    .opacity(buttonScale[0] ? 1 : 0)
                    
                    NavigationLink("", destination: TopView().navigationBarBackButtonHidden(true), isActive: $isContentView)
                    
                    // 解説画面表示/非表示ボタン
                    MenuButton(
                        icon: isSoundOn ? "eye.slash.fill" : "eye.fill",
                        title: isSoundOn ? "解説画面を非表示" : "解説画面を表示",
                        iconColor: Color(hex: "4ECDC4"),
                        action: {
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
                        }
                    )
                    .scaleEffect(buttonScale[1] ? 1 : 0.8)
                    .opacity(buttonScale[1] ? 1 : 0)
                    
                    // ヘルプボタン
                    MenuButton(
                        icon: "questionmark.circle.fill",
                        title: "ヘルプを表示",
                        iconColor: Color(hex: "FFE66D"),
                        action: {
                            generateHapticFeedback()
                            showHomeModal = false
                            tutorialNum = 4
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { _ in }
                            audioManager.playSound()
                        }
                    )
                    .scaleEffect(buttonScale[2] ? 1 : 0.8)
                    .opacity(buttonScale[2] ? 1 : 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                
                // クイズに戻るボタン
                Button(action: dismissModal) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("クイズに戻る")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(showContent ? 1 : 0.9)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            pauseTimer()
            if userFlag == 0 {
                isSoundOn = true
            } else {
                isSoundOn = false
            }
            
            // アニメーション開始
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showContent = true
            }
            
            // ボタンの順次アニメーション
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + Double(i) * 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        buttonScale[i] = true
                    }
                }
            }
        }
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            resumeTimer()
            audioManager.playCancelSound()
        }
    }
}

// MARK: - メニューボタンコンポーネント
struct MenuButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン背景
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "2D3436"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "F8F9FA"))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    ModalView(
        isSoundOn: .constant(true),
        isPresented: .constant(true),
        isPresenting: .constant(true),
        audioManager: AudioManager.shared,
        showHomeModal: .constant(false),
        tutorialNum: .constant(0),
        pauseTimer: {},
        resumeTimer: {},
        userFlag: .constant(0)
    )
}
