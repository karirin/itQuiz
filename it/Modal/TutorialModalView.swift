//
//  TutorialModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/31.
//  Updated with modern design system
//

import SwiftUI

struct TutorialModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @Binding var isFlag: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var showAlert: Bool
    
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var imageScale: CGFloat = 0.8
    @State private var currentStep: Int = 0
    
    private let steps = [
        TutorialStep(
            icon: "gamecontroller.fill",
            title: "ゲーム感覚で学習",
            description: "ITの知識をクイズ形式で楽しく学べます"
        ),
        TutorialStep(
            icon: "flame.fill",
            title: "モンスターと対戦",
            description: "問題に正解してモンスターを倒そう！"
        ),
        TutorialStep(
            icon: "sparkles",
            title: "仲間を集めよう",
            description: "ガチャで可愛い仲間を増やせます"
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // メインカード
            VStack(spacing: 0) {
                // ヘッダーイメージ
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
                        .frame(width: 120, height: 120)
                        .offset(x: -100, y: -40)
                    
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .offset(x: 120, y: 30)
                    
                    // メインイメージ
                    Image("チュートリアル")
                        .resizable()
                        .scaledToFit()
                        .frame(height: isSmallDevice() ? 130 : 150)
                        .scaleEffect(imageScale)
                }
                .frame(height: isSmallDevice() ? 160 : 180)
                .clipShape(
                    RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                )
                
                // コンテンツ
                VStack(spacing: 20) {
                    // ウェルカムメッセージ
                    VStack(spacing: 8) {
                        Text("ようこそ！")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                        
                        Text("インストールありがとうございます")
                            .font(.system(size: 14))
                            .foregroundColor(Color("fontGray").opacity(0.7))
                    }
                    
                    // ステップインジケーター
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? Color(hex: "667eea") : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }
                    }
                    
                    // 現在のステップ
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: steps[currentStep].icon)
                                .font(.system(size: 26))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text(steps[currentStep].title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                        
                        Text(steps[currentStep].description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("fontGray").opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 130)
                    
                    // スタートボタン
                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        } else {
                            dismissModal()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentStep < steps.count - 1 ? "次へ" : "はじめる")
                                .font(.system(size: 17, weight: .bold))
                            
                            if currentStep == steps.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .bold))
                            }
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
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // スキップボタン
                    if currentStep < steps.count - 1 {
                        Button(action: dismissModal) {
                            Text("スキップ")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("fontGray").opacity(0.6))
                        }
                    }
                }
                .padding(24)
                .background(Color("Color2"))
            }
            .frame(width: isSmallDevice() ? 320 : 350)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 30, y: 15)
            .overlay(
                // 閉じるボタン
                Button(action: dismissModal) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .offset(x: 12, y: -12),
                alignment: .topTrailing
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                imageScale = 1.0
            }
        }
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        isFlag = true
        
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

struct TutorialStep {
    let icon: String
    let title: String
    let description: String
}

func isSmallDevice() -> Bool {
    return UIScreen.main.bounds.width < 390
}

#Preview {
    TutorialModalView(isPresented: .constant(true), isFlag: .constant(false), showAlert: .constant(false))
}
