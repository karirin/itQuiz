import SwiftUI
import UIKit

enum QuizAttackStyle: CaseIterable {
    case slash
    case crossSlash
    case shockwave
}

// One event per hit keeps repeated attacks with the same damage animated.
struct QuizAttackImpact: Identifiable {
    static let delay: TimeInterval = 0.15

    let id = UUID()
    let damage: Int?
    let isBoosted: Bool
    let style: QuizAttackStyle
    let comboStrength: Int

    init(damage: Int?, isBoosted: Bool, sequence: Int, comboCount: Int = 0) {
        self.damage = damage
        self.isBoosted = isBoosted
        self.style = QuizAttackStyle.allCases[(max(sequence, 1) - 1) % QuizAttackStyle.allCases.count]
        self.comboStrength = comboCount >= 8 ? 3 : (comboCount >= 5 ? 2 : 1)
    }

    func playHaptic() {
        UIImpactFeedbackGenerator(style: .rigid)
            .impactOccurred(intensity: isBoosted ? 1.0 : 0.8)
    }
}

private struct QuizAttackEffectView: View {
    let impact: QuizAttackImpact
    let width: CGFloat
    let isVisible: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            if impact.comboStrength > 1 {
                Circle()
                    .stroke(impact.comboStrength == 3 ? Color.orange : Color.cyan, lineWidth: impact.comboStrength == 3 ? 5 : 3)
                    .frame(width: width * 0.95, height: width * 0.95)
                    .scaleEffect(reduceMotion ? 1 : (isVisible ? 1.2 : 0.45))
                    .opacity(isVisible ? 0.75 : 0)
            }

            switch impact.style {
            case .slash:
                Image("attack1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 1.25)
                    .rotationEffect(.degrees(-12))
            case .crossSlash:
                ZStack {
                    Image("attack1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 1.1)
                        .rotationEffect(.degrees(-20))
                        .offset(x: -width * 0.06, y: -width * 0.04)
                    Image("attack1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 1.1)
                        .rotationEffect(.degrees(78))
                        .offset(x: width * 0.06, y: width * 0.04)
                }
            case .shockwave:
                ZStack {
                    QuizImpactBurstShape()
                        .fill(
                            RadialGradient(
                                colors: [.white, impact.comboStrength == 3 ? .orange : .cyan, .clear],
                                center: .center,
                                startRadius: 2,
                                endRadius: width * 0.6
                            )
                        )
                        .frame(width: width * 1.1, height: width * 1.1)
                    Circle()
                        .stroke(.white.opacity(0.9), lineWidth: 3)
                        .frame(width: width * 0.64, height: width * 0.64)
                }
            }
        }
        .frame(width: width * 1.35, height: width * 1.2)
        .scaleEffect(reduceMotion ? 1 : (isVisible ? 1.08 : 0.65))
        .opacity(isVisible ? 1 : 0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct QuizImpactBurstShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) * 0.5
        let innerRadius = outerRadius * 0.37
        let pointCount = 24
        var path = Path()

        for point in 0..<pointCount {
            let angle = Double(point) * .pi * 2 / Double(pointCount) - .pi / 2
            let radius = point.isMultiple(of: 2) ? outerRadius : innerRadius
            let position = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if point == 0 { path.move(to: position) }
            else { path.addLine(to: position) }
        }
        path.closeSubpath()
        return path
    }
}

struct QuizMonsterImpactView: View {
    let imageName: String
    let width: CGFloat
    let impact: QuizAttackImpact?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRecoiling = false
    @State private var isFlashing = false
    @State private var showsStrike = false
    @State private var showsDamage = false
    @State private var damageHasRisen = false

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .shadow(radius: 10)
            .brightness(isFlashing ? 0.5 : 0)
            .scaleEffect(reduceMotion || !isRecoiling ? 1 : 0.94)
            .rotationEffect(.degrees(reduceMotion || !isRecoiling ? 0 : -7))
            .offset(x: reduceMotion || !isRecoiling ? 0 : 12,
                    y: reduceMotion || !isRecoiling ? 0 : -6)
            // Overlays keep the question and answer layout still during impact.
            .overlay {
                if let impact {
                    QuizAttackEffectView(
                        impact: impact,
                        width: width,
                        isVisible: showsStrike,
                        reduceMotion: reduceMotion
                    )
                }
            }
            .overlay {
                if let impact, let damage = impact.damage, damage > 0 {
                    Text("−\(damage)")
                        .font(.system(size: width < 120 ? 32 : 42, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(impact.isBoosted ? .yellow : .white)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 2)
                        .shadow(color: impact.isBoosted ? .orange : .black.opacity(0.5), radius: 7)
                        .fixedSize()
                        .scaleEffect(reduceMotion ? 1 : (showsDamage ? 1 : 0.65))
                        .offset(y: -width * 0.22 - (reduceMotion || !damageHasRisen ? 0 : 28))
                        .opacity(showsDamage ? 1 : 0)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .task(id: impact?.id) {
                resetImpact()
                guard impact != nil else { return }

                isFlashing = !reduceMotion
                withAnimation(reduceMotion ? nil : .spring(response: 0.18, dampingFraction: 0.55)) {
                    isRecoiling = true
                    showsStrike = true
                    showsDamage = true
                }

                do {
                    try await Task.sleep(nanoseconds: 80_000_000)
                    withAnimation(.easeOut(duration: 0.1)) { isFlashing = false }
                    withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.55)) {
                        isRecoiling = false
                    }
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.55)) {
                        damageHasRisen = true
                    }
                    try await Task.sleep(nanoseconds: 120_000_000)
                    withAnimation(.easeOut(duration: 0.16)) { showsStrike = false }
                    try await Task.sleep(nanoseconds: 450_000_000)
                    withAnimation(.easeOut(duration: 0.18)) { showsDamage = false }
                } catch {
                    // SwiftUI cancels the sequence when the hit changes or the view disappears.
                }
            }
    }

    private func resetImpact() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isRecoiling = false
            isFlashing = false
            showsStrike = false
            showsDamage = false
            damageHasRisen = false
        }
    }
}

struct BattleComboTier {
    let requiredStreak: Int
    let multiplier: Double
    let title: String
    let colors: [Color]
}

enum MonsterComboSystem {
    static let tiers: [BattleComboTier] = [
        BattleComboTier(requiredStreak: 8, multiplier: 2.0, title: "必殺コンボ", colors: [Color.red, Color.orange]),
        BattleComboTier(requiredStreak: 5, multiplier: 1.5, title: "連撃", colors: [Color.orange, Color.yellow]),
        BattleComboTier(requiredStreak: 2, multiplier: 1.2, title: "コンボ開始", colors: [Color.blue, Color.cyan])
    ]

    static func tier(for comboCount: Int) -> BattleComboTier? {
        tiers.first { comboCount >= $0.requiredStreak }
    }

    static func multiplier(for comboCount: Int) -> Double {
        tier(for: comboCount)?.multiplier ?? 1.0
    }

    static func reducedComboCountAfterTimeout(from comboCount: Int) -> Int {
        comboCount / 2
    }
}

// MARK: - Combo Badge View

struct MonsterComboBadgeView: View {
    let comboCount: Int
    let multiplier: Double
    let isPulsing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tier: BattleComboTier? {
        MonsterComboSystem.tier(for: comboCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(tier?.title ?? "COMBO")
                .font(.system(size: 10, weight: .heavy, design: .rounded))

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(comboCount)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .monospacedDigit()
                Text("COMBO")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(0.5)
            }

            Text(String(format: "ATK x%.1f", multiplier))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
        }
        .foregroundColor(.white)
        .fixedSize()
        .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 2)
        .shadow(color: .black.opacity(0.55), radius: 7, x: 0, y: 2)
        .scaleEffect(reduceMotion || !isPulsing ? 1 : 1.14)
        .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.58), value: isPulsing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(comboCount)コンボ、攻撃倍率\(String(format: "%.1f", multiplier))倍")
    }
}

// MARK: - Combo Burst View

struct MonsterComboBurstView: View {
    let title: String
    let subtitle: String
    let colors: [Color]
    let isVisible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: title == "COMBO BREAK" ? 32 : 42, weight: .black, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
        .shadow(color: .black.opacity(0.6), radius: 9, x: 0, y: 3)
        .scaleEffect(reduceMotion || isVisible ? 1 : 1.13)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: reduceMotion || isVisible ? 0 : 12)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.65), value: isVisible)
    }
}
