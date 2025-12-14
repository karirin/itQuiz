//
//  CoinModalView.swift
//  it
//
//  Created by Apple on 2024/02/05.
//

import SwiftUI
import StoreKit

struct CoinModalView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @StateObject var store: Store = Store()
    
    var body: some View {
        ZStack {
            // 背景のぼかし
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                // ヘッダー
                ZStack {
                    Text("コインを購入")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    HStack {
                        Spacer()
                        Button(action: {
                            generateHapticFeedback()
                            audioManager.playCancelSound()
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                    VStack(spacing: 12) {
                        ForEach(store.productList, id: \.self) { product in
                            coinPackageView(for: product)
                        }
                    }
                    .padding()
                .background(Color("Color2"))
            }
            .frame(width: isSmallDevice() ? 340 : 360)
            .background(Color("Color2"))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print(store.productList)
                }
            }
        }
    }
    
    @ViewBuilder
    private func coinPackageView(for product: Product) -> some View {
        let packageInfo = getPackageInfo(for: product)
        
        Button(action: {
            generateHapticFeedback()
            audioManager.playSound()
            Task {
                do {
                    try await purchase(product)
                } catch {
                    print("Purchase failed: \(error)")
                }
            }
        }) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 16) {
                    // コイン情報
                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                            Text(packageInfo.coinText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("fontGray"))
                        }
                        
                        if let bonus = packageInfo.bonus {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                Text(bonus)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 価格ボタン
                    VStack(spacing: 2) {
                        Text(packageInfo.price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: packageInfo.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: packageInfo.gradientColors[0].opacity(0.4), radius: 8, y: 4)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                )
                
                // お得バッジ
                if let badge = packageInfo.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .offset(x: -8, y: -8)
                }
            }.padding(.vertical,10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func getPackageInfo(for product: Product) -> PackageInfo {
        switch product.displayName {
        case "15000コイン":
            return PackageInfo(
                coinText: "15,000コイン",
                price: "¥500",
                bonus: "3倍お得!",
                badge: "人気No.1",
                gradientColors: [Color.purple, Color.blue]
            )
        case "4000コイン":
            return PackageInfo(
                coinText: "4,000コイン",
                price: "¥200",
                bonus: "2倍お得!",
                badge: "おすすめ",
                gradientColors: [Color.blue, Color.cyan]
            )
        default:
            return PackageInfo(
                coinText: "1,000コイン",
                price: "¥100",
                bonus: nil,
                badge: nil,
                gradientColors: [Color.green, Color.mint]
            )
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct PackageInfo {
    let coinText: String
    let price: String
    let bonus: String?
    let badge: String?
    let gradientColors: [Color]
}

#Preview {
    CoinModalView(audioManager: AudioManager(), isPresented: .constant(true))
}
