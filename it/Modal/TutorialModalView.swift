//
//  TutorialModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/31.
//  Updated with interactive operation guide
//

import SwiftUI

struct TutorialGuideStep {
    let icon: String
    let title: String
    let description: String
    let buttonImage: String?
    let accentColors: [Color]
    let tips: [String]
}

struct TutorialModalView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @Binding var isFlag: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var showAlert: Bool

    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var currentStep: Int = 0
    @State private var stepOpacity: Double = 1.0
    @State private var stepOffset: CGFloat = 0
    @State private var pulseAnimation = false

    private let steps: [TutorialGuideStep] = [
        TutorialGuideStep(
            icon: "hand.wave.fill",
            title: "ようこそ！",
            description: "アプリの使い方を\nかんたんにご案内します",
            buttonImage: nil,
            accentColors: [Color(hex: "667eea"), Color(hex: "764ba2")],
            tips: []
        ),
        TutorialGuideStep(
            icon: "book.fill",
            title: "学習モード",
            description: "ITの問題をジャンル別に学習できます",
            buttonImage: "トレーニングボタン",
            accentColors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            tips: ["好きなジャンルを選んで挑戦", "正解するとモンスターにダメージ！"]
        ),
        TutorialGuideStep(
            icon: "map.fill",
            title: "ダンジョンモード",
            description: "ストーリーを進めながら学習できます",
            buttonImage: "ダンジョンボタン",
            accentColors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
            tips: ["コマを進めてお宝をゲット", "ボスを倒してクリアを目指そう"]
        ),
        TutorialGuideStep(
            icon: "gift.fill",
            title: "ガチャ",
            description: "コインを使って仲間をゲットしよう",
            buttonImage: "ガチャボタン",
            accentColors: [Color(hex: "ffecd2"), Color(hex: "fcb69f")],
            tips: ["仲間はステータスを強化してくれる", "レアな仲間を集めよう"]
        ),
        TutorialGuideStep(
            icon: "star.fill",
            title: "準備完了！",
            description: "まずは「学習モード」から\n始めてみましょう！",
            buttonImage: nil,
            accentColors: [Color(hex: "667eea"), Color(hex: "764ba2")],
            tips: ["毎日ログインでボーナスコイン獲得", "レベルを上げてどんどん強くなろう"]
        ),
    ]

    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // メインカード
            VStack(spacing: 0) {
                // ヘッダーエリア
                ZStack {
                    // グラデーション背景
                    LinearGradient(
                        colors: steps[currentStep].accentColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .animation(.easeInOut(duration: 0.5), value: currentStep)

                    // デコレーション
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .offset(x: -100, y: -40)

                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .offset(x: 120, y: 30)

                    // ステップ番号
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(currentStep + 1) / \(steps.count)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                        Spacer()
                    }

                    // メインコンテンツ
                    VStack(spacing: 8) {
                        if let buttonImage = steps[currentStep].buttonImage {
                            // ボタン画像を表示
                            Image(buttonImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: isSmallDevice() ? 70 : 80)
                                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        } else if currentStep == 0 {
                            // ウェルカム画面
                            welcomeArtwork
                        } else {
                            // 完了画面アイコン
                            Image(systemName: steps[currentStep].icon)
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(.white)
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        }
                    }
                    .opacity(stepOpacity)
                    .offset(x: stepOffset)
                }
                .frame(height: isSmallDevice() ? 150 : 170)
                .clipShape(
                    RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                )

                // コンテンツエリア
                VStack(spacing: 16) {
                    // アイコン + タイトル
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: steps[currentStep].accentColors.map { $0.opacity(0.2) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: steps[currentStep].icon)
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: steps[currentStep].accentColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .animation(.easeInOut(duration: 0.5), value: currentStep)

                        Text(steps[currentStep].title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                    }

                    // 説明文
                    Text(steps[currentStep].description)
                        .font(.system(size: 15))
                        .foregroundColor(Color("fontGray").opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // 操作ヒント
                    if !steps[currentStep].tips.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(steps[currentStep].tips, id: \.self) { tip in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: steps[currentStep].accentColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    Text(tip)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("fontGray").opacity(0.7))

                                    Spacer()
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("fontGray").opacity(0.05))
                        )
                    }

                    Spacer().frame(height: 4)

                    // プログレスバー
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: steps[currentStep].accentColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(steps.count), height: 6)
                                .animation(.easeInOut(duration: 0.4), value: currentStep)
                        }
                    }
                    .frame(height: 6)

                    // ボタンエリア
                    HStack(spacing: 12) {
                        // 戻るボタン
                        if currentStep > 0 {
                            Button(action: {
                                generateHapticFeedback()
                                goToPreviousStep()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color("fontGray").opacity(0.6))
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(Color("fontGray").opacity(0.08))
                                    )
                            }
                        }

                        // メインボタン
                        Button(action: {
                            generateHapticFeedback()
                            if currentStep < steps.count - 1 {
                                goToNextStep()
                            } else {
                                dismissModal()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(currentStep == 0 ? "案内を見る" : currentStep < steps.count - 1 ? "次へ" : "はじめる！")
                                    .font(.system(size: 17, weight: .bold))

                                Image(systemName: currentStep < steps.count - 1 ? "arrow.right" : "sparkles")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: steps[currentStep].accentColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: steps[currentStep].accentColors.first?.opacity(0.4) ?? .clear, radius: 8, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }

                    // スキップボタン
                    if currentStep < steps.count - 1 {
                        Button(action: dismissModal) {
                            Text("スキップ")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("fontGray").opacity(0.5))
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

            startPulseAnimation()
        }
    }

    private var welcomeArtwork: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: isSmallDevice() ? 88 : 104, height: isSmallDevice() ? 88 : 104)

            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2)
                .frame(width: isSmallDevice() ? 112 : 128, height: isSmallDevice() ? 112 : 128)

            Image(systemName: steps[currentStep].icon)
                .font(.system(size: isSmallDevice() ? 40 : 46, weight: .semibold))
                .foregroundColor(.white)

            Image(systemName: "sparkles")
                .font(.system(size: isSmallDevice() ? 16 : 18, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .offset(x: isSmallDevice() ? 34 : 40, y: isSmallDevice() ? -28 : -32)

            Image(systemName: "book.fill")
                .font(.system(size: isSmallDevice() ? 14 : 16, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .offset(x: isSmallDevice() ? -36 : -42, y: isSmallDevice() ? 26 : 30)
        }
        .frame(height: isSmallDevice() ? 100 : 120)
    }

    private func goToNextStep() {
        withAnimation(.easeOut(duration: 0.15)) {
            stepOpacity = 0
            stepOffset = -30
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep += 1
            stepOffset = 30

            withAnimation(.easeOut(duration: 0.2)) {
                stepOpacity = 1.0
                stepOffset = 0
            }
        }
    }

    private func goToPreviousStep() {
        withAnimation(.easeOut(duration: 0.15)) {
            stepOpacity = 0
            stepOffset = 30
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep -= 1
            stepOffset = -30

            withAnimation(.easeOut(duration: 0.2)) {
                stepOpacity = 1.0
                stepOffset = 0
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseAnimation = true
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
