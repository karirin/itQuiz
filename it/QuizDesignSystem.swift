//
//  QuizDesignSystem.swift
//  it
//
//  Created by Apple on 2026/01/09.
//

import SwiftUI

// MARK: - カラーテーマ
struct QuizColors {
    // メインカラー
    static let primaryGradientStart = Color(hex: "667eea")
    static let primaryGradientEnd = Color(hex: "764ba2")
    
    // カテゴリ別カラー
    static let itPassport = LinearGradient(
        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let basicInfo = LinearGradient(
        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let appliedInfo = LinearGradient(
        colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let strategy = LinearGradient(
        colors: [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let es = LinearGradient(
        colors: [Color(hex: "ff9a9e"), Color(hex: "fecfef")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let review = LinearGradient(
        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 背景
    static let background = LinearGradient(
        colors: [Color(hex: "f5f7fa"), Color(hex: "e4e8f0")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = Color.white
    static let disabledOverlay = Color.black.opacity(0.4)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - カスタムボタンスタイル
struct QuizCategoryButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        subtitle: String = "",
        icon: String,
        gradient: LinearGradient,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradient = gradient
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                generateHapticFeedback()
                action()
            }
        }) {
            HStack(spacing: 16) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // テキスト
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // 矢印
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    gradient
                    
                    if isDisabled {
                        QuizColors.disabledOverlay
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - 復習ボタン
struct ReviewButton: View {
    let title: String
    let count: Int
    let isLoading: Bool
    let isPremiumLocked: Bool
    let action: () -> Void
    let premiumAction: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            if isPremiumLocked {
                premiumAction()
            } else if count > 0 {
                action()
            }
        }) {
            HStack(spacing: 16) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !isLoading {
                        Text(count > 0 ? "\(count)問の復習問題" : "復習問題なし")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // バッジまたはロック
                if isPremiumLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                } else if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    QuizColors.review
                    
                    if count == 0 && !isPremiumLocked {
                        QuizColors.disabledOverlay
                    }
                    
                    if isPremiumLocked {
                        Color.black.opacity(0.3)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
            .overlay(
                Group {
                    if isPremiumLocked {
                        VStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                            Text("プレミアム")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(x: 0, y: 0)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(count == 0 && !isPremiumLocked)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - セクションヘッダー
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 4, height: 20)
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "667eea"))
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// MARK: - リワードボタン
struct RewardFloatingButton: View {
    let isLoaded: Bool
    let action: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            if isLoaded {
                generateHapticFeedback()
                action()
            }
        }) {
            ZStack {
                // 外側のグロー
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "ffd700").opacity(0.4),
                                Color(hex: "ffd700").opacity(0)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isLoaded ? 1 : 0)
                
                // メインボタン
                ZStack {
                    Circle()
                        .fill(
                            isLoaded ?
                            LinearGradient(
                                colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: isLoaded ? Color(hex: "ffd700").opacity(0.5) : .clear, radius: 10)
                    
                    VStack(spacing: 2) {
                        Text("×2")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("報酬")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isLoaded)
        .onAppear {
            if isLoaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
        .onChange(of: isLoaded) { loaded in
            if loaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - カスタムナビゲーションバー
struct QuizNavigationBar: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                generateHapticFeedback()
                onBack()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("戻る")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color(hex: "667eea"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // バランス用の空白
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("戻る")
                    .font(.system(size: 16, weight: .medium))
            }
            .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - プレビュー
struct QuizDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "問題カテゴリ", icon: "folder.fill")
                
                QuizCategoryButton(
                    title: "ITパスポート",
                    subtitle: "基礎理解の問題",
                    icon: "doc.text.fill",
                    gradient: QuizColors.itPassport,
                    action: {}
                )
                .padding(.horizontal)
                
                QuizCategoryButton(
                    title: "基本情報技術者",
                    subtitle: "ストラテジの問題",
                    icon: "chart.line.uptrend.xyaxis",
                    gradient: QuizColors.basicInfo,
                    action: {}
                )
                .padding(.horizontal)
                
                SectionHeader(title: "復習", icon: "arrow.counterclockwise")
                
                ReviewButton(
                    title: "復習問題",
                    count: 15,
                    isLoading: false,
                    isPremiumLocked: false,
                    action: {},
                    premiumAction: {}
                )
                .padding(.horizontal)
                
                ReviewButton(
                    title: "復習問題",
                    count: 0,
                    isLoading: false,
                    isPremiumLocked: true,
                    action: {},
                    premiumAction: {}
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(QuizColors.background)
    }
}
