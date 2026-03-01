//
//  LoginBonusModernView.swift
//  it
//
//  モダンなログインボーナス画面
//  - 5日間のスタンプカード式UI（連続ログインで日付が進む）
//  - リッチなアニメーション
//  - コイン獲得エフェクト
//

import SwiftUI

// MARK: - Login Bonus Day Model
struct LoginBonusDay: Identifiable {
    let id: Int
    let day: Int
    let coinAmount: Int
    let isToday: Bool
    let isCollected: Bool
    
    var icon: String {
        switch day {
        case 1: return "star.fill"
        case 2: return "flame.fill"
        case 3: return "bolt.fill"
        case 4: return "sparkles"
        case 5: return "crown.fill"
        default: return "star.fill"
        }
    }
    
    var dayColor: Color {
        switch day {
        case 1: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case 2: return Color(red: 0.5, green: 0.8, blue: 0.4)
        case 3: return Color(red: 1.0, green: 0.6, blue: 0.3)
        case 4: return Color(red: 0.9, green: 0.4, blue: 0.6)
        case 5: return Color(red: 1.0, green: 0.8, blue: 0.2)
        default: return .blue
        }
    }
}

// MARK: - Main Login Bonus View
//
//  LoginBonusModernView.swift
//  it
//
//  モダンなログインボーナス画面（500日対応）
//  - 5日間ずつのスタンプカード（ページング）
//  - 5日ごと特別ボーナス演出
//  - 全報酬一覧モーダル
//

import SwiftUI

// MARK: - Main Login Bonus View
struct LoginBonusModernView: View {
    @Binding var isPresented: Bool
    /// 連続ログイン日数（1〜500）
    let loginCount: Int
    /// 今回のボーナスコイン数
    let currentBonus: Int
    @ObservedObject var authManager: AuthManager
    var onCollected: (() -> Void)? = nil
    
    @State private var appearAnimation = false
    @State private var stampAnimation = false
    @State private var coinBurstAnimation = false
    @State private var shimmerOffset: CGFloat = -300
    @State private var particlePhase: CGFloat = 0
    @State private var todayStampScale: CGFloat = 0.0
    @State private var bonusTextScale: CGFloat = 0.0
    @State private var backgroundPulse = false
    @State private var confettiActive = false
    @State private var hasCollected = false
    @State private var showRewardList = false
    
    /// 現在のページ（5日単位）
    private var currentPage: Int {
        LoginBonusConfig.currentPage(for: loginCount)
    }
    
    /// 現在ページの5日間
    private var currentDays: [Int] {
        let range = LoginBonusConfig.dayRange(for: currentPage)
        return Array(range)
    }
    
    /// 5日ごとマイルストーンか
    private var isMilestone: Bool {
        LoginBonusConfig.isMilestone(day: loginCount)
    }
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            if confettiActive {
                ConfettiEffectView().allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                headerSection
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                
                Spacer().frame(height: 20)
                
                stampCardSection
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 40)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appearAnimation)
                
                Spacer().frame(height: 24)
                
                todayBonusSection
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(bonusTextScale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.8), value: bonusTextScale)
                
                // マイルストーンメッセージ
                milestoneMessage
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(1.0), value: appearAnimation)
                
                Spacer().frame(height: 24)
                
                // ボタン群
                VStack(spacing: 12) {
                    collectButton
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: appearAnimation)
                    
                    // 報酬一覧ボタン
                    Button(action: { showRewardList = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 14, weight: .semibold))
                            Text("報酬一覧を見る")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.vertical, 10)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(1.2), value: appearAnimation)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            if coinBurstAnimation {
                CoinBurstEffectView().allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showRewardList) {
            LoginBonusListView(currentDay: loginCount)
        }
        .onAppear { startAnimationSequence() }
    }
    
    // MARK: - Milestone Message
    @ViewBuilder
    private var milestoneMessage: some View {
        if LoginBonusConfig.isUltraMilestone(day: loginCount) {
            Text("👑 \(loginCount)日達成！超特別ボーナス！（5倍）")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
                .padding(.top, 8)
        } else if LoginBonusConfig.isSuperMilestone(day: loginCount) {
            Text("💎 \(loginCount)日達成！特大ボーナス！（3倍）")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1))
                .padding(.top, 8)
        } else if LoginBonusConfig.isMilestone(day: loginCount) {
            Text("⭐ 5日区切りボーナス！（2倍）")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1, green: 0.6, blue: 0.2))
                .padding(.top, 8)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Background
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.14),
                    Color(red: 0.1, green: 0.08, blue: 0.18),
                    Color(red: 0.06, green: 0.06, blue: 0.12)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            Circle()
                .fill(RadialGradient(colors: [Color.yellow.opacity(0.08), .clear], center: .center, startRadius: 0, endRadius: 200))
                .frame(width: 400, height: 400).offset(x: -50, y: -200)
                .scaleEffect(backgroundPulse ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: backgroundPulse)
            
            Circle()
                .fill(RadialGradient(colors: [Color.orange.opacity(0.06), .clear], center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 360, height: 360).offset(x: 100, y: 300)
                .scaleEffect(backgroundPulse ? 0.9 : 1.1)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: backgroundPulse)
            
            LoginBonusParticleView().opacity(0.6)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AngularGradient(colors: [.yellow, .orange, .yellow, .white, .yellow], center: .center), lineWidth: 3)
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(particlePhase))
                    .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: particlePhase)
                
                Circle()
                    .fill(LinearGradient(colors: [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 0.95, green: 0.6, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                    .shadow(color: .orange.opacity(0.5), radius: 15, x: 0, y: 5)
                
                Image(systemName: isMilestone ? "trophy.fill" : "gift.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(0.8), radius: 5)
            }
            
            Text("ログインボーナス")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                Text("連続")
                    .foregroundColor(.white.opacity(0.6))
                Text("\(loginCount)")
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
                Text("日目")
                    .foregroundColor(.white.opacity(0.6))
            }
            .font(.system(size: 15, weight: .medium, design: .rounded))
        }
    }
    
    // MARK: - Stamp Card (5日単位)
    private var stampCardSection: some View {
        VStack(spacing: 16) {
            // ページヘッダー
            HStack {
                Text("Day \(currentDays.first ?? 1) - \(currentDays.last ?? 5)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(currentPage + 1) / \(LoginBonusConfig.maxDay / 5)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            HStack(spacing: 8) {
                ForEach(currentDays, id: \.self) { day in
                    DayStampView(
                        day: day,
                        coinAmount: LoginBonusConfig.coinAmount(for: day),
                        isToday: day == loginCount,
                        isCollected: day < loginCount,
                        todayStampScale: day == loginCount ? todayStampScale : 1.0
                    )
                }
            }
            
            // Progress bar (5日間内)
            GeometryReader { geo in
                let posInPage = loginCount - (currentPage * 5)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 6)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [Color(red: 1, green: 0.8, blue: 0.2), Color(red: 1, green: 0.5, blue: 0.2)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: stampAnimation ? geo.size.width * CGFloat(posInPage) / 5.0 : 0, height: 6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5), value: stampAnimation)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(LinearGradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [.clear, Color.white.opacity(0.08), .clear], startPoint: .leading, endPoint: .trailing))
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 24))
                )
        )
    }
    
    // MARK: - Today's Bonus
    private var todayBonusSection: some View {
        VStack(spacing: 12) {
            Text("本日のボーナス")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        .frame(width: 44, height: 44)
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 3)
                    Text("¢").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                }
                
                Text("+\(currentBonus)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [Color(red: 1, green: 0.9, blue: 0.4), Color(red: 1, green: 0.7, blue: 0.2)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 3)
                
                Text("コイン")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Collect Button
    private var collectButton: some View {
        Button(action: {
            guard !hasCollected else { return }
            hasCollected = true
            collectBonus()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "hand.tap.fill").font(.system(size: 20, weight: .bold))
                Text("受け取る").font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.05))
            .frame(maxWidth: .infinity).frame(height: 58)
            .background(
                ZStack {
                    LinearGradient(colors: [Color(red: 1, green: 0.88, blue: 0.4), Color(red: 1, green: 0.7, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    LinearGradient(colors: [.clear, Color.white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing).offset(x: shimmerOffset * 0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.orange.opacity(0.5), radius: 16, x: 0, y: 8)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(BonusButtonStyle())
        .opacity(hasCollected ? 0.5 : 1.0)
    }
    
    // MARK: - Animations
    private func startAnimationSequence() {
        backgroundPulse = true
        particlePhase = 360
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) { shimmerOffset = 400 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation { appearAnimation = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { stampAnimation = true; todayStampScale = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { bonusTextScale = 1.0 }
        }
    }
    
    private func collectBonus() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.3)) { coinBurstAnimation = true; confettiActive = true }
        onCollected?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) { appearAnimation = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isPresented = false }
        }
    }
}

// MARK: - Day Stamp View (Updated for 500-day system)
struct DayStampView: View {
    let day: Int
    let coinAmount: Int
    let isToday: Bool
    let isCollected: Bool
    let todayStampScale: CGFloat
    @State private var glowPulse = false
    
    private var dayColor: Color { LoginBonusConfig.color(for: day) }
    private var dayIcon: String { LoginBonusConfig.icon(for: day) }
    private var milestone: LoginBonusConfig.MilestoneRank { LoginBonusConfig.milestoneRank(day: day) }
    
    var body: some View {
        VStack(spacing: 5) {
            // Day番号
            Text("\(day)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(isToday ? dayColor : isCollected ? .white.opacity(0.8) : .white.opacity(0.35))
            
            ZStack {
                // 今日のグローエフェクト
                if isToday {
                    Circle().fill(dayColor.opacity(0.3)).frame(width: 58, height: 58).blur(radius: 10)
                        .scaleEffect(glowPulse ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                }
                
                // マイルストーン外枠
                if milestone != .none && (isToday || isCollected) {
                    Circle()
                        .stroke(dayColor.opacity(0.6), lineWidth: 2)
                        .frame(width: 54, height: 54)
                }
                
                Circle()
                    .fill(
                        isCollected || isToday
                        ? LinearGradient(colors: [dayColor, dayColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle().stroke(
                            isToday ? dayColor : isCollected ? dayColor.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: isToday ? 2.5 : 1
                        )
                    )
                    .shadow(color: isToday ? dayColor.opacity(0.5) : isCollected ? dayColor.opacity(0.2) : .clear, radius: isToday ? 10 : 5)
                
                if isCollected {
                    Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                } else if isToday {
                    Image(systemName: dayIcon).font(.system(size: 20, weight: .bold)).foregroundColor(.white).shadow(color: .white.opacity(0.5), radius: 3)
                } else {
                    Image(systemName: "lock.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.2))
                }
            }
            .scaleEffect(isToday ? todayStampScale : 1.0)
            
            // コイン額
            Text(formatCoin(coinAmount))
                .font(.system(size: milestone != .none ? 10 : 9, weight: .bold, design: .rounded))
                .foregroundColor(isToday ? dayColor : isCollected ? .white.opacity(0.6) : .white.opacity(0.3))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .onAppear { if isToday { glowPulse = true } }
    }
    
    private func formatCoin(_ amount: Int) -> String {
        if amount >= 10000 {
            let k = Double(amount) / 1000.0
            return String(format: "%.0fk", k)
        } else if amount >= 1000 {
            let k = Double(amount) / 1000.0
            return String(format: "%.1fk", k)
        }
        return "\(amount)"
    }
}

// MARK: - Bonus Button Style
struct BonusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Coin Burst Effect
struct CoinBurstEffectView: View {
    @State private var coins: [CoinParticle] = []
    struct CoinParticle: Identifiable {
        let id = UUID(); var x, y, targetX, targetY, scale: CGFloat; var rotation, delay: Double
    }
    var body: some View {
        GeometryReader { _ in ForEach(coins) { coin in CoinParticleView(coin: coin) } }
        .onAppear {
            let cx = UIScreen.main.bounds.midX, cy = UIScreen.main.bounds.midY
            coins = (0..<12).map { i in
                let angle = Double(i) * (360.0 / 12.0) * .pi / 180.0
                let dist = CGFloat.random(in: 80...180)
                return CoinParticle(x: cx, y: cy, targetX: cx + dist * CGFloat(cos(angle)), targetY: cy + dist * CGFloat(sin(angle)), scale: .random(in: 0.5...1.0), rotation: .random(in: 0...360), delay: Double(i) * 0.03)
            }
        }
    }
}
struct CoinParticleView: View {
    let coin: CoinBurstEffectView.CoinParticle; @State private var isAnimating = false
    var body: some View {
        Circle().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)).frame(width: 20, height: 20)
            .overlay(Text("¢").font(.system(size: 10, weight: .bold)).foregroundColor(.white))
            .shadow(color: .orange.opacity(0.6), radius: 5)
            .scaleEffect(isAnimating ? 0 : coin.scale)
            .position(x: isAnimating ? coin.targetX : coin.x, y: isAnimating ? coin.targetY - 50 : coin.y)
            .opacity(isAnimating ? 0 : 1).rotationEffect(.degrees(isAnimating ? coin.rotation : 0))
            .onAppear { withAnimation(.easeOut(duration: 0.8).delay(coin.delay)) { isAnimating = true } }
    }
}

// MARK: - Confetti Effect
struct ConfettiEffectView: View {
    @State private var pieces: [ConfettiPiece] = []
    struct ConfettiPiece: Identifiable { let id = UUID(); let x: CGFloat; let color: Color; let size: CGFloat; let speed, delay, rotation: Double }
    var body: some View {
        GeometryReader { geo in ForEach(pieces) { p in ConfettiPieceView(piece: p, screenHeight: geo.size.height) } }
        .onAppear {
            pieces = (0..<40).map { _ in
                ConfettiPiece(x: .random(in: 0...UIScreen.main.bounds.width), color: [.yellow, .orange, .red, .pink, .purple, .blue, .cyan].randomElement()!, size: .random(in: 4...10), speed: .random(in: 1.5...3.0), delay: .random(in: 0...0.5), rotation: .random(in: 0...720))
            }
        }
    }
}
struct ConfettiPieceView: View {
    let piece: ConfettiEffectView.ConfettiPiece; let screenHeight: CGFloat; @State private var isAnimating = false
    var body: some View {
        RoundedRectangle(cornerRadius: 2).fill(piece.color).frame(width: piece.size, height: piece.size * 1.5)
            .rotationEffect(.degrees(isAnimating ? piece.rotation : 0))
            .position(x: piece.x + (isAnimating ? .random(in: -30...30) : 0), y: isAnimating ? screenHeight + 50 : -20)
            .opacity(isAnimating ? 0 : 1)
            .onAppear { withAnimation(.easeIn(duration: piece.speed).delay(piece.delay)) { isAnimating = true } }
    }
}

// MARK: - Particle Background
struct LoginBonusParticleView: View {
    @State private var particles: [StarParticle] = []
    struct StarParticle: Identifiable { let id = UUID(); var x, y, size: CGFloat; var opacity, blinkSpeed: Double }
    var body: some View {
        GeometryReader { geo in ForEach(particles) { p in BlinkingStar(particle: p, geoSize: geo.size) } }
        .onAppear { particles = (0..<25).map { _ in StarParticle(x: .random(in: 0...1), y: .random(in: 0...1), size: .random(in: 2...5), opacity: .random(in: 0.2...0.6), blinkSpeed: .random(in: 1.5...4.0)) } }
    }
}
struct BlinkingStar: View {
    let particle: LoginBonusParticleView.StarParticle; let geoSize: CGSize; @State private var isBlinking = false
    var body: some View {
        Circle().fill(Color.white).frame(width: particle.size, height: particle.size)
            .opacity(isBlinking ? particle.opacity : particle.opacity * 0.3)
            .position(x: particle.x * geoSize.width, y: particle.y * geoSize.height)
            .blur(radius: particle.size > 3 ? 1 : 0)
            .onAppear { withAnimation(.easeInOut(duration: particle.blinkSpeed).repeatForever(autoreverses: true)) { isBlinking = true } }
    }
}

// MARK: - Preview
struct LoginBonusModernView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginBonusModernView(isPresented: .constant(true), loginCount: 1, currentBonus: 100, authManager: AuthManager.shared).previewDisplayName("Day 1")
            LoginBonusModernView(isPresented: .constant(true), loginCount: 3, currentBonus: 500, authManager: AuthManager.shared).previewDisplayName("Day 3")
            LoginBonusModernView(isPresented: .constant(true), loginCount: 5, currentBonus: 1000, authManager: AuthManager.shared).previewDisplayName("Day 5")
        }
    }
}
