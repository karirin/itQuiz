//
//  ModalReturnView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/18.
//  Updated with modern design
//

import SwiftUI

struct ModalReturnView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var startTimer: () -> Void
    @State private var isButtonActive = true
    
    // アニメーション用
    @State private var showContent = false
    @State private var iconRotation = false
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // メインモーダル
            VStack(spacing: 0) {
                // エラーアイコンエリア
                ZStack {
                    // 背景の円形グラデーション
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "FFF5F5"), Color(hex: "FED7D7")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    // 外側のリング
                    Circle()
                        .stroke(Color(hex: "FC8181").opacity(0.3), lineWidth: 3)
                        .frame(width: 100, height: 100)
                    
                    // エラーアイコン
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FC8181"), Color(hex: "F56565")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: Color(hex: "FC8181").opacity(0.4), radius: 8, y: 4)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(iconRotation ? 0 : -10))
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                // タイトル
                Text("エラーが発生しました")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "2D3436"))
                    .padding(.bottom, 8)
                
                // メッセージ
                Text("申し訳ありません。\n回答結果を取得できませんでした。")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "636E72"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                
                // 区切り線
                Rectangle()
                    .fill(Color(hex: "E2E8F0"))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                
                // ボタンエリア
                HStack(spacing: 12) {
                    // 戻るボタン
                    Button(action: {
                        generateHapticFeedback()
                        if isButtonActive {
                            dismissModal()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .bold))
                            Text("戻る")
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
                        .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(!isButtonActive)
                    .opacity(isButtonActive ? 1 : 0.6)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 24, y: 12)
            .padding(.horizontal, 40)
            .scaleEffect(showContent ? 1 : 0.85)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            pauseTimer()
            
            // モーダル表示アニメーション
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
            
            // アイコンの揺れアニメーション
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.15).repeatCount(3, autoreverses: true)) {
                    iconRotation = true
                }
            }
        }
    }
    
    private func dismissModal() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            startTimer()
        }
    }
}

// MARK: - Preview
#Preview {
    ModalReturnView(
        isPresented: .constant(true),
        pauseTimer: {},
        startTimer: {}
    )
}
