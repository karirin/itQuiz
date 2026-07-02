//
//  StoryCoinModalView.swift
//  it
//
//  Created by Apple on 2024/11/17.
//  Updated with modern design system
//

import SwiftUI

struct Treasure: Codable {
    let coinImage: String
    let coinTitle: String
    let reward: Int
}

struct StoryCoinModalView: View {
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    let coin: Int
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var coinImage: String = ""
    @State private var coinTitle: String = ""
    @State private var rewardAmount: Int = 0
    @State private var itemRewards: [InventoryReward] = []
    @State private var dungeonBoostRewards: [DungeonBoost] = []
    
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var coinScale: CGFloat = 0.5
    @State private var showSparkles = false
    @State private var glowOpacity: Double = 0.3
    
    let treasures: [Int: Treasure] = [
        1: Treasure(coinImage: "コイン1", coinTitle: "100コインゲット！！", reward: 100),
        2: Treasure(coinImage: "コイン1", coinTitle: "100コインゲット！！", reward: 100),
        3: Treasure(coinImage: "コイン1", coinTitle: "100コインゲット！！", reward: 100),
        4: Treasure(coinImage: "コイン3", coinTitle: "300コインゲット！！", reward: 300),
        5: Treasure(coinImage: "コイン2", coinTitle: "200コインゲット！！", reward: 200),
        6: Treasure(coinImage: "コイン3", coinTitle: "300コインゲット！！", reward: 300),
        7: Treasure(coinImage: "コイン2", coinTitle: "200コインゲット！！", reward: 200),
        8: Treasure(coinImage: "コイン5", coinTitle: "500コインゲット！！", reward: 500),
        9: Treasure(coinImage: "コイン4", coinTitle: "400コインゲット！！", reward: 400),
        10: Treasure(coinImage: "コイン4", coinTitle: "400コインゲット！！", reward: 400),
        11: Treasure(coinImage: "コイン4", coinTitle: "400コインゲット！！", reward: 400),
        12: Treasure(coinImage: "コイン4", coinTitle: "400コインゲット！！", reward: 400),
        13: Treasure(coinImage: "コイン7", coinTitle: "800コインゲット！！", reward: 800),
        14: Treasure(coinImage: "コイン6", coinTitle: "600コインゲット！！", reward: 600),
        15: Treasure(coinImage: "コイン6", coinTitle: "600コインゲット！！", reward: 600),
        16: Treasure(coinImage: "宝箱16", coinTitle: "1000コインゲット！！", reward: 1000),
        17: Treasure(coinImage: "宝箱17", coinTitle: "1000コインゲット！！", reward: 1000),
        18: Treasure(coinImage: "宝箱18", coinTitle: "1000コインゲット！！", reward: 1000),
        19: Treasure(coinImage: "宝箱19", coinTitle: "1000コインゲット！！", reward: 1000),
        20: Treasure(coinImage: "宝箱20", coinTitle: "1000コインゲット！！", reward: 1000),
        21: Treasure(coinImage: "宝箱21", coinTitle: "1000コインゲット！！", reward: 1000),
        22: Treasure(coinImage: "宝箱22", coinTitle: "1000コインゲット！！", reward: 1000),
        23: Treasure(coinImage: "宝箱23", coinTitle: "1200コインゲット！！", reward: 1200),
        24: Treasure(coinImage: "宝箱24", coinTitle: "1200コインゲット！！", reward: 1200),
        25: Treasure(coinImage: "宝箱25", coinTitle: "1200コインゲット！！", reward: 1200),
        26: Treasure(coinImage: "宝箱26", coinTitle: "1200コインゲット！！", reward: 1200),
        27: Treasure(coinImage: "宝箱27", coinTitle: "1200コインゲット！！", reward: 1200),
        28: Treasure(coinImage: "宝箱28", coinTitle: "1200コインゲット！！", reward: 1200),
        29: Treasure(coinImage: "宝箱29", coinTitle: "1500コインゲット！！", reward: 1500),
        30: Treasure(coinImage: "宝箱30", coinTitle: "2000コインゲット！！", reward: 2000),
    ]

    private var primaryItemReward: InventoryReward? {
        itemRewards.first
    }

    private var isItemTreasure: Bool {
        !itemRewards.isEmpty
    }
    
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // スパークルエフェクト
            if showSparkles {
                SparkleEffectView()
                    .ignoresSafeArea()
            }
            
            // メインコンテンツ
            VStack(spacing: 20) {
                
                // 宝箱/コインイメージ
                ZStack {
                    // グローエフェクト
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "ffd200").opacity(glowOpacity),
                                    Color(hex: "f7971e").opacity(glowOpacity * 0.5),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)

                    if let primaryItemReward {
                        InventoryItemArtworkView(
                            type: primaryItemReward.type,
                            width: 180,
                            height: 180,
                            cornerRadius: 28
                        )
                        .scaleEffect(coinScale)
                        .modifier(FloatingAnimation(amplitude: 8, duration: 2.0))
                    } else {
                        Image(coinImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .scaleEffect(coinScale)
                            .modifier(FloatingAnimation(amplitude: 8, duration: 2.0))
                    }
                }
                
                // 報酬テキスト
                VStack(spacing: 12) {
                    // バッジ
                    Text("🎉 おめでとう！ 🎉")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))

                    Text(coinTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                    
                    // メインタイトル
                    if let primaryItemReward {
                        HStack(spacing: 12) {
                            Text(primaryItemReward.type.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("x\(primaryItemReward.amount)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(primaryItemReward.type.accentColor)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(primaryItemReward.type.accentColor.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(primaryItemReward.type.accentColor.opacity(0.6), lineWidth: 2)
                                )
                        )
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "ffd200"), Color(hex: "f7971e")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            Text("\(rewardAmount)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)

                            Text("コイン")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "f7971e").opacity(0.3), Color(hex: "ffd200").opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "ffd200"), Color(hex: "f7971e")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                        )
                    }

                    if itemRewards.count > 1 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("獲得アイテム")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))

                            ForEach(Array(itemRewards.enumerated()), id: \.offset) { entry in
                                let reward = entry.element
                                HStack(spacing: 10) {
                                    InventoryItemArtworkView(type: reward.type, width: 38, height: 38, cornerRadius: 10)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reward.type.displayName)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("x\(reward.amount)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }

                                    Spacer()
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                    }

                    if !dungeonBoostRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("追加効果")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))

                            ForEach(dungeonBoostRewards) { boost in
                                HStack(spacing: 10) {
                                    Image(systemName: boost.type.symbolName)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(boost.type.accentColors.first?.opacity(0.32) ?? .clear)
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(boost.type.title)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("\(boost.type.description) / x\(boost.charges)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.72))
                                    }

                                    Spacer()
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                    }
                }
                
                Spacer()
                    .frame(height: 20)
                
                // 受け取るボタン
                Button(action: dismissModal) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 18))
                        
                        Text("タップして閉じる")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            setTreasureParameters(coin: coin)
            
            // 入場アニメーション
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // コインのバウンスアニメーション
            withAnimation(.spring(response: 0.7, dampingFraction: 0.5).delay(0.2)) {
                coinScale = 1.0
            }
            
            // グローアニメーション
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
                glowOpacity = 0.6
            }
            
            // スパークル表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showSparkles = true
            }
        }
    }
    
    private func setTreasureParameters(coin: Int) {
        if let treasure = treasures[coin] {
            let plannedItemRewards = DungeonRewardPlanner.treasureRewards(for: coin)
            let plannedBoostRewards = treasureBoostRewards(for: coin)
            coinImage = treasure.coinImage
            itemRewards = plannedItemRewards
            dungeonBoostRewards = plannedBoostRewards
            let finalCoinReward = plannedItemRewards.isEmpty
                ? PositionViewModel.shared.applyCoinTreasureBonus(to: treasure.reward)
                : 0
            rewardAmount = finalCoinReward
            coinTitle = plannedItemRewards.isEmpty
                ? treasure.coinTitle
                : itemTreasureTitle(for: plannedItemRewards)

            if plannedItemRewards.isEmpty {
                AuthManager.shared.addMoney(amount: finalCoinReward)
            } else {
                AuthManager.shared.addItems(plannedItemRewards)
            }

            for boost in plannedBoostRewards {
                PositionViewModel.shared.addDungeonBoost(type: boost.type, charges: boost.charges, magnitude: boost.magnitude)
            }
        } else {
            print("未知の宝物")
        }
    }

    private func itemTreasureTitle(for rewards: [InventoryReward]) -> String {
        guard let firstReward = rewards.first, rewards.count == 1 else {
            return "アイテムゲット！！"
        }
        return "\(firstReward.type.displayName)ゲット！！"
    }

    private func treasureBoostRewards(for treasureID: Int) -> [DungeonBoost] {
        switch treasureID {
        case 5:
            return [DungeonBoost(type: .safeShield, charges: 1)]
        case 14:
            return [DungeonBoost(type: .attackSurge, charges: 2)]
        case 24:
            return [DungeonBoost(type: .coinBonus, charges: 1)]
        case 30:
            return [
                DungeonBoost(type: .attackSurge, charges: 2),
                DungeonBoost(type: .safeShield, charges: 1)
            ]
        default:
            return []
        }
    }
    
    private func dismissModal() {
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
}

// MARK: - Sparkle Effect View

struct SparkleEffectView: View {
    @State private var sparkles: [Sparkle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: "sparkle")
                        .font(.system(size: sparkle.size))
                        .foregroundColor(sparkle.color)
                        .position(sparkle.position)
                        .opacity(sparkle.opacity)
                        .rotationEffect(.degrees(sparkle.rotation))
                }
            }
            .onAppear {
                createSparkles(in: geometry.size)
                animateSparkles()
            }
        }
    }
    
    private func createSparkles(in size: CGSize) {
        let colors: [Color] = [
            Color(hex: "ffd200"),
            Color(hex: "f7971e"),
            .white
        ]
        
        sparkles = (0..<20).map { _ in
            Sparkle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...20),
                opacity: 0,
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func animateSparkles() {
        for i in sparkles.indices {
            let delay = Double.random(in: 0...1)
            
            withAnimation(.easeInOut(duration: 0.5).delay(delay)) {
                sparkles[i].opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(delay)) {
                sparkles[i].rotation += 180
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(delay + 0.5)) {
                sparkles[i].opacity = 0.3
            }
        }
    }
}

struct Sparkle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var rotation: Double
}

#Preview {
    StoryCoinModalView(coin: 23, isPresented: .constant(true))
}
