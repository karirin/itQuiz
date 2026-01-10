//
//  CoinModalView.swift
//  it
//
//  Created by Apple on 2024/02/05.
//  Updated with modern design system
//

import SwiftUI
import StoreKit

struct CoinModalView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @StateObject var store: Store = Store()
    
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // メインカード
            VStack(spacing: 0) {
                // ヘッダー
                headerView
                
                // コインパッケージリスト
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(store.productList.sorted { getPackageInfo(for: $0).sortOrder < getPackageInfo(for: $1).sortOrder }, id: \.self) { product in
                            CoinPackageCard(
                                product: product,
                                packageInfo: getPackageInfo(for: product),
                                isSelected: selectedProduct?.id == product.id,
                                onTap: {
                                    generateHapticFeedback()
                                    audioManager.playSound()
                                    selectedProduct = product
                                    purchaseProduct(product)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color("Color2"))
            }
            .frame(width: isSmallDevice() ? 340 : 360)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.3), radius: 30, y: 15)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
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
                .frame(width: 100, height: 100)
                .offset(x: -120, y: -30)
            
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 60, height: 60)
                .offset(x: 140, y: 20)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("コインを購入")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ゲームをもっと楽しもう")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // 閉じるボタン
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
        .clipShape(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
        )
    }
    
    // MARK: - Package Info
    private func getPackageInfo(for product: Product) -> CoinPackageInfo {
        switch product.displayName {
        case "15000コイン":
            return CoinPackageInfo(
                coinAmount: "15,000",
                price: "¥500",
                bonus: "3倍お得!",
                badge: "人気No.1",
                gradientColors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                iconName: "crown.fill",
                sortOrder: 0
            )
        case "4000コイン":
            return CoinPackageInfo(
                coinAmount: "4,000",
                price: "¥200",
                bonus: "2倍お得!",
                badge: "おすすめ",
                gradientColors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                iconName: "star.fill",
                sortOrder: 1
            )
        default:
            return CoinPackageInfo(
                coinAmount: "1,000",
                price: "¥100",
                bonus: nil,
                badge: nil,
                gradientColors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                iconName: "bolt.fill",
                sortOrder: 2
            )
        }
    }
    
    // MARK: - Actions
    private func dismissWithAnimation() {
        generateHapticFeedback()
        audioManager.playCancelSound()
        
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        Task {
            do {
                try await purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
    
    private func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct CoinPurchasePackageCard: View {
    let package: CoinPurchaseView.CoinPackage

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(package.coins) コイン")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    if let bonus = package.bonus {
                        Text(bonus)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }

                Spacer()

                Text(package.price)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if package.isPopular {
                HStack {
                    Text("人気")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.25)))
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: package.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(radius: 10)
    }
}


// MARK: - Package Info Model

struct CoinPackageInfo {
    let coinAmount: String
    let price: String
    let bonus: String?
    let badge: String?
    let gradientColors: [Color]
    let iconName: String
    let sortOrder: Int
}

// MARK: - Coin Package Card

struct CoinPackageCard: View {
    let product: Product
    let packageInfo: CoinPackageInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // メインコンテンツ
                HStack(spacing: 14) {
                    // アイコン
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f7971e"), Color(hex: "ffd200")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // コイン情報
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(packageInfo.coinAmount) コイン")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                        
                        if let bonus = packageInfo.bonus {
                            HStack(spacing: 4) {
                                Image(systemName: packageInfo.iconName)
                                    .font(.system(size: 11, weight: .bold))
                                Text(bonus)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "f5576c"))
                        }
                    }
                    
                    Spacer()
                    
                    // 価格ボタン
                    Text(packageInfo.price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 90, height: 44)
                        .background(
                            LinearGradient(
                                colors: packageInfo.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(
                            color: packageInfo.gradientColors[0].opacity(0.4),
                            radius: 8,
                            y: 4
                        )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? packageInfo.gradientColors[0] : Color.clear,
                            lineWidth: 2
                        )
                )
                
                // バッジ
                if let badge = packageInfo.badge {
                    BadgeLabel(text: badge)
                        .offset(x: -8, y: -10)
                }
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Badge Label

struct BadgeLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "ff416c"), Color(hex: "ff4b2b")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hex: "ff416c").opacity(0.4), radius: 4, y: 2)
            )
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    CoinModalView(audioManager: AudioManager(), isPresented: .constant(true))
}
