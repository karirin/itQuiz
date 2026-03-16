import SwiftUI

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

    private var tier: BattleComboTier? {
        MonsterComboSystem.tier(for: comboCount)
    }

    private var colors: [Color] {
        tier?.colors ?? [Color.gray.opacity(0.9), Color.gray.opacity(0.7)]
    }

    private var isMaxTier: Bool {
        comboCount >= 8
    }

    var body: some View {
        HStack(spacing: 6) {
            // Fire icon with layered glow
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .yellow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: colors.first?.opacity(0.8) ?? .clear, radius: 6)

                if isMaxTier {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .blur(radius: 4)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                // Combo count with bold number
                HStack(spacing: 3) {
                    Text("\(comboCount)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                    Text("COMBO")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .offset(y: 2)
                }

                // Multiplier
                Text(String(format: "ATK x%.1f", multiplier))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .foregroundColor(.white)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Main gradient background
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: colors + [colors.first?.opacity(0.8) ?? .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Inner highlight
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: isPulsing ? 16 : 10, x: 0, y: 4)
        .scaleEffect(isPulsing ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPulsing)
    }
}

// MARK: - Combo Burst View

struct MonsterComboBurstView: View {
    let title: String
    let subtitle: String
    let colors: [Color]
    let isVisible: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Title with shadow layers
            ZStack {
                // Shadow text
                Text(title)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
                    .offset(y: 2)

                // Main text with gradient
                Text(title)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            // Subtitle
            HStack(spacing: 6) {
                // Left dash
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 16, height: 2)

                Text(subtitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.9))

                // Right dash
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 16, height: 2)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Main gradient
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Inner glow at top
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear, .black.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: 24, x: 0, y: 8)
        .scaleEffect(isVisible ? 1.0 : 0.5)
        .opacity(isVisible ? 1.0 : 0.0)
        .rotation3DEffect(
            .degrees(isVisible ? 0 : -15),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isVisible)
    }
}
