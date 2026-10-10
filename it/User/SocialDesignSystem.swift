//
//  SocialDesignSystem.swift
//  it
//
//  フレンド・対戦・ギルドの3画面で共有するデザイントークンと共通部品です。
//  「毎日遊びたくなる学習RPG」の印象になるよう、明るいアクセント+読みやすい面で構成し、
//  ライト/ダークどちらでも成立するセマンティックカラーを基準にしています。
//
//  ここに置くのは「小さく再利用できる単位」だけです。画面固有のレイアウトは各画面側に残します。
//

import SwiftUI

// MARK: - カラーユーティリティ

extension Color {
    /// ライト/ダークで値を切り替える動的カラー。Color(hex:)は固定色のため、面や文字色はこちらを使う。
    static func socialDynamic(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - テーマ

/// 3つのソーシャル機能。色と記号で「どの機能にいるか」を判別できるようにする。
enum SocialTheme: String, CaseIterable, Identifiable {
    case friend
    case battle
    case guild

    var id: String { rawValue }

    /// ブランドのグラデーション。ヘッダーや主要ボタンなど「面」にだけ使う。
    var colors: [Color] {
        switch self {
        case .friend: return [Color(hex: "f093fb"), Color(hex: "f5576c")]
        case .battle: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case .guild: return [Color(hex: "11998e"), Color(hex: "38ef7d")]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var accent: Color { colors[0] }
    var deepAccent: Color { colors[1] }

    /// カード上の文字やアイコンに使う、コントラストを確保したアクセント。
    var textAccent: Color {
        switch self {
        case .friend: return .socialDynamic(light: Color(hex: "c2185b"), dark: Color(hex: "ff9ec4"))
        case .battle: return .socialDynamic(light: Color(hex: "4a4fbf"), dark: Color(hex: "aab4ff"))
        case .guild: return .socialDynamic(light: Color(hex: "0f766e"), dark: Color(hex: "5eead4"))
        }
    }

    /// チップやアイコン背景に使う淡い面。ダークでは少し濃くして沈まないようにする。
    var softFill: Color {
        .socialDynamic(light: accent.opacity(0.14), dark: accent.opacity(0.26))
    }

    var hairline: Color {
        .socialDynamic(light: accent.opacity(0.22), dark: accent.opacity(0.38))
    }

    var displayName: String {
        switch self {
        case .friend: return "フレンド"
        case .battle: return "対戦"
        case .guild: return "ギルド"
        }
    }

    var symbol: String {
        switch self {
        case .friend: return "person.2.fill"
        case .battle: return "flag.checkered"
        case .guild: return "person.3.fill"
        }
    }

    var backgroundImageName: String {
        switch self {
        case .friend: return "SocialFriendBackground"
        case .battle: return "SocialBattleBackground"
        case .guild: return "SocialGuildBackground"
        }
    }

    /// 画面全体の背景。上部だけテーマ色をうっすら乗せ、下地はセマンティックカラーに任せる。
    var softBackground: LinearGradient {
        LinearGradient(
            colors: [
                .socialDynamic(light: accent.opacity(0.16), dark: accent.opacity(0.20)),
                Color(.systemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - 共通トークン

enum SocialPalette {
    static let gold = Color(hex: "ffb300")
    static let goldSoft = Color.socialDynamic(light: Color(hex: "fff3d6"), dark: Color(hex: "4a3a12"))
    static let goldText = Color.socialDynamic(light: Color(hex: "9a6100"), dark: Color(hex: "ffd479"))

    static let success = Color.socialDynamic(light: Color(hex: "0f8f6f"), dark: Color(hex: "4ade80"))
    static let warning = Color.socialDynamic(light: Color(hex: "b45309"), dark: Color(hex: "fbbf24"))
    static let danger = Color.socialDynamic(light: Color(hex: "d13c5a"), dark: Color(hex: "ff8fa3"))
    static let info = Color.socialDynamic(light: Color(hex: "1d6fd0"), dark: Color(hex: "8ec3ff"))

    static let cardSurface = Color.socialDynamic(
        light: Color.white.opacity(0.64),
        dark: Color(hex: "191F29").opacity(0.72)
    )
    static let insetSurface = Color.socialDynamic(
        light: Color.white.opacity(0.46),
        dark: Color(hex: "141A23").opacity(0.62)
    )
    static let separator = Color(.separator)

    static let cardShadow = Color.socialDynamic(light: Color.black.opacity(0.07), dark: Color.black.opacity(0.35))
}

enum SocialMetrics {
    /// 最低タップ領域。すべての操作要素はこの高さ以上にする。
    static let tapTarget: CGFloat = 44
    static let screenPadding: CGFloat = 16
    static let stackSpacing: CGFloat = 14
}

// MARK: - 面(カード)

struct SocialCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
            }
            .shadow(color: SocialPalette.cardShadow, radius: 10, x: 0, y: 4)
    }
}

extension View {
    func socialCard(padding: CGFloat = 16) -> some View {
        modifier(SocialCardModifier(padding: padding))
    }

    /// 3画面共通のスクロール土台。背景・余白・巨大文字時の上限をここで揃える。
    func socialScreen(_ theme: SocialTheme) -> some View {
        self
            .background(
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .overlay(Color(.systemBackground).opacity(0.38))
                    .ignoresSafeArea()
            )
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

// MARK: - ヒーローヘッダー

struct SocialHeroHeader<Trailing: View>: View {
    let theme: SocialTheme
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.sizeCategory) private var sizeCategory

    private var isCompactLayout: Bool { sizeCategory >= .accessibilityMedium }

    var body: some View {
        Group {
            if isCompactLayout {
                VStack(alignment: .leading, spacing: 12) {
                    identity
                    trailing()
                }
            } else {
                HStack(spacing: 14) {
                    identity
                    Spacer(minLength: 8)
                    trailing()
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                theme.gradient
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 130, height: 130)
                    .offset(x: 40, y: -60)
            }
        )
        .cornerRadius(DesignTokens.Radius.xl)
        .shadow(color: theme.accent.opacity(0.28), radius: 14, x: 0, y: 6)
        .accessibilityElement(children: .contain)
    }

    private var identity: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

extension SocialHeroHeader where Trailing == EmptyView {
    init(theme: SocialTheme, icon: String, title: String, subtitle: String) {
        self.init(theme: theme, icon: icon, title: title, subtitle: subtitle) { EmptyView() }
    }
}

/// ヘッダー内の数値バッジ。
struct SocialHeroStat: View {
    let value: String
    let label: String
    var caption: String?

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
            if let caption {
                Text(caption)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(DesignTokens.Radius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)\(value)")
    }
}

// MARK: - コンパクトナビゲーションヘッダー

/// ソーシャル画面の改善案で共通する、情報密度の高い52ptヘッダー。
/// 大きなヒーローを置かず、画面名・現在状態・主要な補助操作を1行にまとめる。
struct SocialCompactHeader<Trailing: View>: View {
    let theme: SocialTheme
    let title: String
    let subtitle: String
    let icon: String
    var showsBackButton: Bool = true
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        HStack(spacing: 10) {
            if showsBackButton {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.textAccent)
                        .frame(width: 24, height: SocialMetrics.tapTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("戻る")
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.gradient)
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 4)
            trailing()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator).opacity(0.32))
                .frame(height: 0.5)
        }
        .accessibilityElement(children: .contain)
    }
}

extension SocialCompactHeader where Trailing == EmptyView {
    init(
        theme: SocialTheme,
        title: String,
        subtitle: String,
        icon: String,
        showsBackButton: Bool = true
    ) {
        self.init(
            theme: theme,
            title: title,
            subtitle: subtitle,
            icon: icon,
            showsBackButton: showsBackButton
        ) { EmptyView() }
    }
}

/// コンパクトヘッダー右端用の数値表示。
struct SocialCompactStat: View {
    let value: String
    let label: String
    let theme: SocialTheme

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(theme.textAccent)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9.5))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
        .background(theme.softFill)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// カード内に数値を並べて見せる小さなタイル。「与ダメージ」「正解数」のような統計3〜4個を横に並べる用途。
struct SocialStatTile: View {
    let value: String
    let label: String
    var tone: SocialTone = .neutral

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(tone.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(tone.background)
        .cornerRadius(DesignTokens.Radius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)\(value)")
    }
}

// MARK: - セグメント

struct SocialSegmentedControl<Tag: Hashable>: View {
    struct Item: Identifiable {
        let tag: Tag
        let title: String
        let icon: String?
        let badge: Int

        var id: Tag { tag }

        init(tag: Tag, title: String, icon: String? = nil, badge: Int = 0) {
            self.tag = tag
            self.title = title
            self.icon = icon
            self.badge = badge
        }
    }

    let theme: SocialTheme
    let items: [Item]
    @Binding var selection: Tag

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items) { item in
                let isSelected = item.tag == selection

                Button {
                    guard !isSelected else { return }
                    generateHapticFeedback()
                    if reduceMotion {
                        selection = item.tag
                    } else {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            selection = item.tag
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        if let icon = item.icon {
                            Image(systemName: icon)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text(item.title)
                            .font(.footnote.weight(isSelected ? .bold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        if item.badge > 0 {
                            SocialCountBadge(count: item.badge, isOnAccent: isSelected)
                        }
                    }
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                            .fill(isSelected ? AnyShapeStyle(theme.gradient) : AnyShapeStyle(Color.clear))
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.badge > 0 ? "\(item.title) \(item.badge)件" : item.title)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(SocialPalette.cardSurface)
        .cornerRadius(DesignTokens.Radius.lg)
        .shadow(color: SocialPalette.cardShadow, radius: 6, x: 0, y: 2)
    }
}

// MARK: - 見出し

struct SocialSectionTitle: View {
    let theme: SocialTheme
    let icon: String
    let title: String
    var trailingText: String?

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.textAccent)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
            Spacer(minLength: 4)
            if let trailingText {
                Text(trailingText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - バッジ / チップ

/// 未読・未確認の件数バッジ。
struct SocialCountBadge: View {
    let count: Int
    var isOnAccent: Bool = false

    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(isOnAccent ? SocialTheme.friend.deepAccent : .white)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(isOnAccent ? Color.white : Color(hex: "f5576c"))
            .clipShape(Capsule())
            .accessibilityHidden(true)
    }
}

/// 情報の色合い。色だけに頼らず必ずアイコン+文言をセットで持つ。
enum SocialTone {
    case neutral
    case theme(SocialTheme)
    case success
    case warning
    case danger
    case gold
    case info

    var foreground: Color {
        switch self {
        case .neutral: return .secondary
        case .theme(let theme): return theme.textAccent
        case .success: return SocialPalette.success
        case .warning: return SocialPalette.warning
        case .danger: return SocialPalette.danger
        case .gold: return SocialPalette.goldText
        case .info: return SocialPalette.info
        }
    }

    var background: Color {
        switch self {
        case .neutral: return Color.socialDynamic(light: Color(hex: "eef0f4"), dark: Color(hex: "3a3d44"))
        case .theme(let theme): return theme.softFill
        case .success: return .socialDynamic(light: Color(hex: "e2f7ef"), dark: Color(hex: "10352a"))
        case .warning: return .socialDynamic(light: Color(hex: "fdf0dc"), dark: Color(hex: "3d2c10"))
        case .danger: return .socialDynamic(light: Color(hex: "fde8ec"), dark: Color(hex: "45161f"))
        case .gold: return SocialPalette.goldSoft
        case .info: return .socialDynamic(light: Color(hex: "e6f0fd"), dark: Color(hex: "12293f"))
        }
    }
}

/// 小さなラベル。状態はアイコン+文言で伝え、色は補助にとどめる。
struct SocialTagChip: View {
    let text: String
    var icon: String?
    var tone: SocialTone = .neutral

    var body: some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9.5, weight: .bold))
            }
            Text(text)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundColor(tone.foreground)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(tone.background)
        .clipShape(Capsule())
    }
}

/// カード左端などに置く、状態を大きく示すラベル。
struct SocialStatusPill: View {
    let text: String
    let icon: String
    var tone: SocialTone = .neutral

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(tone.foreground)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tone.background)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - ボタン

/// 主要アクションの見た目。ButtonにもNavigationLinkにも同じ形を使えるよう、ラベルだけ切り出す。
struct SocialPrimaryLabel: View {
    let theme: SocialTheme
    let title: String
    var icon: String?
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        HStack(spacing: 7) {
            if isLoading {
                ProgressView()
                    .tint(.white)
                Text("処理中…")
                    .font(.subheadline.weight(.semibold))
            } else {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundColor(isDisabled ? Color.secondary : .white)
        .frame(maxWidth: .infinity)
        .frame(minHeight: SocialMetrics.tapTarget)
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(
            Group {
                if isDisabled {
                    Color.socialDynamic(light: Color(hex: "e3e5ea"), dark: Color(hex: "3a3d44"))
                } else {
                    theme.gradient
                }
            }
        )
        .cornerRadius(DesignTokens.Radius.md)
        .shadow(color: isDisabled ? .clear : theme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
    }
}

/// 主要アクション。1画面につき原則1つ。
struct SocialGradientButton: View {
    let theme: SocialTheme
    let title: String
    var icon: String?
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var accessibilityHintText: String?
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled, !isLoading else { return }
            generateHapticFeedback()
            action()
        } label: {
            SocialPrimaryLabel(
                theme: theme,
                title: title,
                icon: icon,
                isLoading: isLoading,
                isDisabled: isDisabled
            )
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(isLoading ? "\(title)。処理中" : title)
        .accessibilityHint(accessibilityHintText ?? "")
    }
}

/// 副次アクション。主要ボタンと並べても迷わないよう、面を持たせず枠線で表す。
struct SocialSecondaryButton: View {
    let theme: SocialTheme
    let title: String
    var icon: String?
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled else { return }
            generateHapticFeedback()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isDisabled ? .secondary : theme.textAccent)
            .frame(maxWidth: .infinity)
            .frame(minHeight: SocialMetrics.tapTarget)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(theme.softFill.opacity(isDisabled ? 0.4 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(theme.hairline, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .disabled(isDisabled)
    }
}

/// 行の中に置く小さなアクション。最低タップ領域を確保する。
struct SocialPillButton: View {
    let title: String
    let colors: [Color]
    var icon: String?
    var isEnabled: Bool = true
    var isLoading: Bool = false
    /// 行内で2つ並べるときなど、幅いっぱいに広げたい場合に使う。
    var fillWidth: Bool = false
    var accessibilityHintText: String?
    let action: () -> Void

    var body: some View {
        Button {
            guard isEnabled, !isLoading else { return }
            generateHapticFeedback()
            action()
        } label: {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 4) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 11, weight: .bold))
                        }
                        Text(title)
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
            }
            .foregroundColor(isEnabled ? .white : .secondary)
            .frame(minWidth: 84)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .frame(minHeight: 34)
            .padding(.horizontal, 10)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    } else {
                        Color.socialDynamic(light: Color(hex: "eaecf0"), dark: Color(hex: "3a3d44"))
                    }
                }
            )
            .clipShape(Capsule())
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(isLoading ? "\(title)。処理中" : title)
        .accessibilityHint(accessibilityHintText ?? "")
    }
}

/// 破壊的操作。主要ボタンと視覚的にはっきり分ける。
struct SocialDestructiveButton: View {
    let title: String
    var icon: String = "rectangle.portrait.and.arrow.right"
    let action: () -> Void

    var body: some View {
        Button(role: .destructive) {
            generateHapticFeedback()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                Text(title)
                    .font(.footnote.weight(.semibold))
            }
            .foregroundColor(SocialPalette.danger)
            .frame(maxWidth: .infinity)
            .frame(minHeight: SocialMetrics.tapTarget)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(SocialPalette.danger.opacity(0.45), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
    }
}

// MARK: - アバター

struct SocialAvatarThumb: View {
    let imageName: String?
    let theme: SocialTheme
    var size: CGFloat = 46
    /// 代表おともが設定済みかなど、状態を縁で示したいときに使う。
    var ringTone: SocialTone?

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.softFill)
                .frame(width: size, height: size)
            if let imageName, !imageName.isEmpty, UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.78, height: size * 0.78)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42))
                    .foregroundColor(theme.textAccent.opacity(0.7))
            }
        }
        .overlay(
            Circle().stroke(ringTone?.foreground ?? theme.hairline, lineWidth: ringTone == nil ? 1 : 2)
        )
        .accessibilityHidden(true)
    }
}

// MARK: - 状態表示(空 / エラー / 読み込み中)

/// 空状態。「次に何をすればよいか」を必ず1つ提示する。
struct SocialEmptyState: View {
    let theme: SocialTheme
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.softFill)
                    .frame(width: 66, height: 66)
                Image(systemName: icon)
                    .font(.system(size: 27, weight: .light))
                    .foregroundColor(theme.textAccent)
            }
            .accessibilityHidden(true)

            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let actionTitle, let action {
                SocialGradientButton(theme: theme, title: actionTitle, icon: "arrow.right") {
                    action()
                }
                .padding(.top, 2)
                .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 22)
        .accessibilityElement(children: .contain)
    }
}

/// 通信エラー。原因の説明と再試行をセットで出す。
struct SocialErrorState: View {
    let theme: SocialTheme
    var title: String = "読み込めませんでした"
    var message: String = "通信状況を確認して、もう一度お試しください。"
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(SocialPalette.warning)
                .accessibilityHidden(true)
            Text(title)
                .font(.subheadline.weight(.bold))
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            SocialSecondaryButton(theme: theme, title: "再読み込み", icon: "arrow.clockwise") {
                retry()
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
    }
}

private struct SocialOptionalCard: ViewModifier {
    let isEnabled: Bool
    let padding: CGFloat

    func body(content: Content) -> some View {
        if isEnabled {
            content.socialCard(padding: padding)
        } else {
            content.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// 読み込み中のプレースホルダー。画面が消えたり高さが飛んだりしないよう、行の形を保つ。
struct SocialSkeletonRow: View {
    var showsTrailing: Bool = true
    var lines: Int = 2
    /// すでにカードの中にいる場合は、二重のカードにならないよう面を持たせない。
    var insideCard: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmer = false

    private var base: Color {
        Color.socialDynamic(light: Color(hex: "e8eaef"), dark: Color(hex: "3a3d44"))
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(base)
                .frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 7) {
                ForEach(0..<max(1, lines), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(base)
                        .frame(height: index == 0 ? 13 : 10)
                        .frame(maxWidth: index == 0 ? .infinity : 120, alignment: .leading)
                }
            }
            if showsTrailing {
                Capsule()
                    .fill(base)
                    .frame(width: 74, height: 30)
            }
        }
        .opacity(shimmer ? 0.55 : 1)
        .modifier(SocialOptionalCard(isEnabled: !insideCard, padding: 12))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
        .accessibilityHidden(true)
    }
}

struct SocialSkeletonList: View {
    var count: Int = 3
    var showsTrailing: Bool = true

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<max(1, count), id: \.self) { _ in
                SocialSkeletonRow(showsTrailing: showsTrailing)
            }
        }
        .accessibilityLabel("読み込み中")
    }
}

// MARK: - バナー

/// 注目してほしい1件を伝える帯。バッジ的な役割も兼ねる。
struct SocialInlineBanner: View {
    let icon: String
    let title: String
    var message: String?
    var tone: SocialTone = .gold
    var actionTitle: String?
    var action: (() -> Void)?

    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        let content = HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tone.foreground.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tone.foreground)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 4)
        }

        return VStack(alignment: .leading, spacing: 10) {
            content
            if let actionTitle, let action {
                Button {
                    generateHapticFeedback()
                    action()
                } label: {
                    HStack(spacing: 5) {
                        Text(actionTitle)
                            .font(.footnote.weight(.bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: sizeCategory >= .accessibilityMedium ? .infinity : nil)
                    .frame(minHeight: 36)
                    .padding(.horizontal, 14)
                    .background(Capsule().fill(tone.foreground))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tone.background)
        .cornerRadius(DesignTokens.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .stroke(tone.foreground.opacity(0.28), lineWidth: 1)
        )
    }
}

// MARK: - 進捗

struct SocialProgressBar: View {
    let value: Double
    let maxValue: Double
    let colors: [Color]
    var height: CGFloat = 12

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ratio: Double {
        guard maxValue > 0 else { return 0 }
        return min(1, max(0, value / maxValue))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.socialDynamic(light: Color(hex: "e6e8ee"), dark: Color(hex: "3a3d44")))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, geometry.size.width * ratio))
                    .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.85), value: ratio)
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}

struct SocialRankBadge: View {
    let rank: Int

    private var colors: [Color] {
        switch rank {
        case 1: return [Color(hex: "ffd700"), Color(hex: "ffb300")]
        case 2: return [Color(hex: "c0c8d4"), Color(hex: "9aa5b4")]
        case 3: return [Color(hex: "d9a06a"), Color(hex: "b97a42")]
        default: return [Color.gray.opacity(0.28), Color.gray.opacity(0.28)]
        }
    }

    var body: some View {
        Text("\(rank)")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(rank <= 3 ? .white : .secondary)
            .frame(width: 22, height: 22)
            .background(
                Circle().fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            )
            .accessibilityLabel("\(rank)位")
    }
}

// MARK: - 成功フィードバック(トースト)

private struct SocialToastModifier: ViewModifier {
    @Binding var message: String?
    var tone: SocialTone

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text(message)
                            .font(.footnote.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(tone.foreground))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel(message)
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.85), value: message)
            .onChange(of: message) { newValue in
                guard newValue != nil else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    if self.message == newValue { self.message = nil }
                }
            }
    }
}

extension View {
    /// 承認・受け取りなどの成功を、画面を止めずに知らせる。
    func socialToast(message: Binding<String?>, tone: SocialTone = .success) -> some View {
        modifier(SocialToastModifier(message: message, tone: tone))
    }
}

// MARK: - 3画面を行き来するショートカット

/// フレンド/ギルド/対戦を1つのソーシャル体験として繋ぐ。今いる画面は出さない。
struct SocialShortcutBar: View {
    let current: SocialTheme

    @ObservedObject private var friendManager = FriendManager.shared
    @ObservedObject private var battleManager = BattleManager.shared

    private var others: [SocialTheme] {
        SocialTheme.allCases.filter { $0 != current }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SocialSectionTitle(theme: current, icon: "square.grid.2x2.fill", title: "ほかのソーシャル機能")

            HStack(spacing: 10) {
                ForEach(others) { theme in
                    NavigationLink {
                        destination(for: theme)
                    } label: {
                        shortcutLabel(theme)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(theme.displayName)を開く")
                }
            }
        }
        .socialCard()
    }

    @ViewBuilder
    private func destination(for theme: SocialTheme) -> some View {
        switch theme {
        case .friend: FriendListView().appNavigationBackButton()
        case .battle: WeeklyLeagueView().appNavigationBackButton()
        case .guild: GuildEntryView().appNavigationBackButton()
        }
    }

    private func badge(for theme: SocialTheme) -> Int {
        switch theme {
        case .friend: return friendManager.incomingRequests.count
        case .battle: return battleManager.incomingBattles.count
        case .guild: return 0
        }
    }

    private func shortcutLabel(_ theme: SocialTheme) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.gradient)
                    .frame(width: 30, height: 30)
                Image(systemName: theme.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text(theme.displayName)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if badge(for: theme) > 0 {
                SocialCountBadge(count: badge(for: theme))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: SocialMetrics.tapTarget)
        .background(theme.softFill)
        .cornerRadius(DesignTokens.Radius.md)
        .contentShape(Rectangle())
    }
}

// MARK: - 週の残り時間

enum SocialWeek {
    /// 月曜5時を境界にした週の終わりまでの残り日数。週次リセットの説明に使う。
    static func remainingDays(from date: Date = Date()) -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let shiftedDate = date.addingTimeInterval(-5 * 60 * 60)
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: shiftedDate) else { return 0 }
        let resetDate = interval.end.addingTimeInterval(5 * 60 * 60)
        let seconds = resetDate.timeIntervalSince(date)
        return max(0, Int(ceil(seconds / 86_400)))
    }

    static func resetDescription(from date: Date = Date()) -> String {
        let days = remainingDays(from: date)
        return days <= 1 ? "まもなく週次リセット" : "リセットまであと\(days)日"
    }
}

// MARK: - プレビュー

#if DEBUG
struct SocialDesignSystem_Previews: PreviewProvider {
    private struct Gallery: View {
        let theme: SocialTheme
        @State private var segment = 0
        @State private var toast: String?

        var body: some View {
            ScrollView {
                VStack(spacing: SocialMetrics.stackSpacing) {
                    SocialHeroHeader(
                        theme: theme,
                        icon: theme.symbol,
                        title: theme.displayName,
                        subtitle: "共通部品のプレビュー"
                    ) {
                        SocialHeroStat(value: "12", label: "人")
                    }

                    SocialSegmentedControl(
                        theme: theme,
                        items: [
                            .init(tag: 0, title: "一覧"),
                            .init(tag: 1, title: "申請", badge: 3),
                            .init(tag: 2, title: "追加")
                        ],
                        selection: $segment
                    )

                    SocialInlineBanner(
                        icon: "gift.fill",
                        title: "お礼コインが届いています",
                        message: "3人があなたのおともを借りました",
                        tone: .gold,
                        actionTitle: "受け取る"
                    ) { toast = "120コインを受け取りました" }

                    VStack(alignment: .leading, spacing: 10) {
                        SocialSectionTitle(theme: theme, icon: "sparkles", title: "チップとボタン")
                        HStack(spacing: 6) {
                            SocialTagChip(text: "Lv.24", icon: "star.fill", tone: .theme(theme))
                            SocialTagChip(text: "本日利用済み", icon: "checkmark", tone: .success)
                            SocialTagChip(text: "満員", icon: "person.fill.xmark", tone: .danger)
                        }
                        SocialStatusPill(text: "回答待ち", icon: "hourglass", tone: .warning)
                        SocialGradientButton(theme: theme, title: "主要アクション", icon: "bolt.fill") {}
                        SocialGradientButton(theme: theme, title: "処理中", isLoading: true) {}
                        SocialGradientButton(theme: theme, title: "無効", isDisabled: true) {}
                        SocialSecondaryButton(theme: theme, title: "副次アクション", icon: "arrow.clockwise") {}
                        SocialDestructiveButton(title: "破壊的な操作") {}
                    }
                    .socialCard()

                    SocialSkeletonList(count: 2)

                    SocialEmptyState(
                        theme: theme,
                        icon: "person.2",
                        title: "まだ何もありません",
                        message: "次の一歩をここで案内します。",
                        actionTitle: "はじめる"
                    ) {}
                    .socialCard(padding: 0)

                    SocialErrorState(theme: theme) {}
                        .socialCard(padding: 0)
                }
                .padding(SocialMetrics.screenPadding)
            }
            .socialScreen(theme)
            .socialToast(message: $toast)
        }
    }

    static var previews: some View {
        Group {
            Gallery(theme: .friend)
                .previewDisplayName("フレンド / ライト")
            Gallery(theme: .battle)
                .preferredColorScheme(.dark)
                .previewDisplayName("対戦 / ダーク")
            Gallery(theme: .guild)
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDisplayName("ギルド / 特大文字")
        }
    }
}
#endif
