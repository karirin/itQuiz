import SwiftUI
import StoreKit
import Combine
import FirebaseAnalytics

enum PremiumPaywallSource: Equatable {
    case analysis
    case review(incorrectCount: Int)
    case course(topicID: String, title: String, remainingCount: Int)
    case ad
    case result
    case settings
    case quiz
    case general

    var analyticsValue: String {
        switch self {
        case .analysis: return "analysis"
        case .review: return "review"
        case .course: return "weakness_course"
        case .ad: return "ad"
        case .result: return "result"
        case .settings: return "settings"
        case .quiz: return "quiz"
        case .general: return "general"
        }
    }

    var headline: String {
        switch self {
        case .analysis:
            return "苦手分野をグラフで発見"
        case .course(_, let title, _):
            return "「\(title)」を、別の問題でも解ける力に"
        case .review(let incorrectCount):
            return incorrectCount > 0
                ? "間違えた\(incorrectCount)問をまとめて復習"
                : "間違えた問題をまとめて復習"
        case .ad:
            return "広告に中断されず学習を続ける"
        case .result:
            return "今日の学習結果を記録・分析"
        case .settings:
            return "広告なしで学習に集中"
        case .quiz:
            return "学習を止めずにプレミアム機能を利用"
        case .general:
            return "学習効率をもっとアップ"
        }
    }

    /// 見出しの上に出す小さなラベル。流入元ごとに「今まさに欲しい価値」を言い切る。
    var eyebrow: String {
        switch self {
        case .analysis:
            return "詳しい学習分析がすぐ使えます"
        case .review:
            return "復習機能がすぐ使えます"
        case .course:
            return "あなたのための苦手克服コース"
        case .ad, .result:
            return "この広告、今日からゼロに"
        case .settings, .quiz, .general:
            return "プレミアムプラン"
        }
    }

    var detail: String {
        switch self {
        case .analysis:
            return "分野別の得意・苦手や期間ごとの成長を確認し、おすすめの演習に取り組めます"
        case .review:
            return "苦手な問題だけを解き直して、知識を効率よく定着できます"
        case .course(_, let title, let remainingCount):
            return remainingCount > 1
                ? "「\(title)」など、あなたの苦手\(remainingCount)テーマを練習。説明・類題・後日のおさらいまで、対応する全10テーマを利用できます。"
                : "「\(title)」の説明・類題・後日のおさらいを用意。ITパスポートの対応する全10テーマを練習できます。"
        case .ad, .settings:
            return "ホーム画面やクイズ後の広告を非表示にして、集中を途切れさせません"
        case .result:
            return "学習の積み重ねをグラフで確認し、間違えた問題をすぐ復習できます"
        case .quiz:
            return "広告非表示・学習分析・復習機能をすべて利用できます"
        case .general:
            return "広告非表示・学習分析・復習機能で、資格学習を効率化できます"
        }
    }
}

enum PremiumAnalytics {
    private enum Key {
        static let pendingSource = "premium.analytics.pendingSource"
        static let pendingDisplayID = "premium.analytics.pendingDisplayID"
        static let pendingProductID = "premium.analytics.pendingProductID"
        static let firstUsePrefix = "premium.analytics.firstUse."
    }

    static func logPaywallView(source: PremiumPaywallSource, displayID: String) {
        Analytics.logEvent("paywall_view", parameters: paywallParameters(
            source: source,
            displayID: displayID
        ))
    }

    static func logPaywallReady(
        source: PremiumPaywallSource,
        displayID: String,
        products: [Product],
        missingProductCount: Int,
        loadAttemptCount: Int,
        hasEligibleMonthlyTrial: Bool
    ) {
        Analytics.logEvent("paywall_ready", parameters: paywallParameters(
            source: source,
            displayID: displayID,
            additional: [
                "product_count": products.count,
                "missing_product_count": missingProductCount,
                "load_attempt_count": loadAttemptCount,
                "monthly_trial_eligible": hasEligibleMonthlyTrial ? 1 : 0
            ]
        ))
    }

    static func logPaywallDismiss(
        source: PremiumPaywallSource,
        displayID: String,
        reason: String,
        selectedProductID: String?
    ) {
        Analytics.logEvent("paywall_dismiss", parameters: paywallParameters(
            source: source,
            displayID: displayID,
            additional: [
                "dismiss_reason": reason,
                "selected_product_id": selectedProductID ?? "none"
            ]
        ))
    }

    static func logPlanSelect(product: Product, source: PremiumPaywallSource, displayID: String, method: String) {
        Analytics.logEvent("plan_select", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID,
            additional: ["selection_method": method]
        ))
    }

    static func logPurchaseStart(product: Product, source: PremiumPaywallSource, displayID: String) {
        Analytics.logEvent("purchase_start", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID
        ))
    }

    static func logPurchaseSuccess(
        product: Product,
        transaction: StoreKit.Transaction,
        isFreeTrial: Bool,
        source: PremiumPaywallSource,
        displayID: String
    ) {
        InterstitialOpportunityCoordinator.shared.recordPremiumPurchase()
        Analytics.logEvent("purchase_success", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID,
            additional: [
                "purchase_kind": isFreeTrial ? "trial_start" : "paid_start",
                "is_trial_start": isFreeTrial ? 1 : 0,
                "transaction_id": String(transaction.id),
                "original_transaction_id": String(transaction.originalID)
            ]
        ))

        SubscriptionLifecycleAnalytics.record(
            transaction: transaction,
            source: source.analyticsValue,
            paywallDisplayID: displayID,
            expectedFreeTrial: isFreeTrial
        )

        let defaults = UserDefaults.standard
        defaults.set(source.analyticsValue, forKey: Key.pendingSource)
        defaults.set(displayID, forKey: Key.pendingDisplayID)
        defaults.set(product.id, forKey: Key.pendingProductID)
    }

    static func logRestoreStart(source: PremiumPaywallSource, displayID: String) {
        Analytics.logEvent("restore_start", parameters: paywallParameters(source: source, displayID: displayID))
    }

    static func logRestoreSuccess(source: PremiumPaywallSource, displayID: String, restoredSubscription: Bool) {
        Analytics.logEvent("restore_success", parameters: paywallParameters(
            source: source,
            displayID: displayID,
            additional: ["restored_subscription": restoredSubscription ? 1 : 0]
        ))
    }

    static func logRestoreError(source: PremiumPaywallSource, displayID: String, error: Error) {
        Analytics.logEvent("restore_error", parameters: paywallParameters(
            source: source,
            displayID: displayID,
            additional: ["error_type": String(describing: error)]
        ))
    }

    static func logPurchaseCancel(product: Product, source: PremiumPaywallSource, displayID: String) {
        Analytics.logEvent("purchase_cancel", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID
        ))
    }

    static func logPurchasePending(product: Product, source: PremiumPaywallSource, displayID: String) {
        Analytics.logEvent("purchase_pending", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID
        ))
    }

    static func logPurchaseError(product: Product, source: PremiumPaywallSource, displayID: String, error: Error) {
        Analytics.logEvent("purchase_error", parameters: productParameters(
            product: product,
            source: source,
            displayID: displayID,
            additional: ["error_type": String(describing: error)]
        ))
    }

    /// 購入後に初めてプレミアム機能を実際に使った時だけ、アカウント単位で送る。
    @MainActor
    static func logPremiumFirstUseIfNeeded(feature: String) {
#if DEBUG
        // 開発ビルドの仮のプレミアム状態を実購入の利用開始として記録しない。
        return
#else
        guard AppState.shared.isSubscribed else { return }

        let accountID = AuthManager.shared.currentUserId ?? "anonymous"
        let firstUseKey = Key.firstUsePrefix + accountID
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: firstUseKey) else { return }

        // 二重onAppearでも重複しないよう、イベント送信前に記録する。
        defaults.set(true, forKey: firstUseKey)
        Analytics.logEvent("premium_first_use", parameters: [
            "feature": feature,
            "entry_point": defaults.string(forKey: Key.pendingSource) ?? "existing_subscriber",
            "paywall_display_id": defaults.string(forKey: Key.pendingDisplayID) ?? "none",
            "product_id": defaults.string(forKey: Key.pendingProductID) ?? "unknown"
        ])

        defaults.removeObject(forKey: Key.pendingSource)
        defaults.removeObject(forKey: Key.pendingDisplayID)
        defaults.removeObject(forKey: Key.pendingProductID)
#endif
    }

    private static func productParameters(
        product: Product,
        source: PremiumPaywallSource,
        displayID: String,
        additional: [String: Any] = [:]
    ) -> [String: Any] {
        var parameters = paywallParameters(
            source: source,
            displayID: displayID,
            additional: [
                "product_id": product.id,
                "price": NSDecimalNumber(decimal: product.price)
            ]
        )
        additional.forEach { parameters[$0.key] = $0.value }
        return parameters
    }

    private static func paywallParameters(
        source: PremiumPaywallSource,
        displayID: String,
        additional: [String: Any] = [:]
    ) -> [String: Any] {
        var parameters: [String: Any] = [
            "source": source.analyticsValue,
            "entry_point": source.analyticsValue,
            "paywall_display_id": displayID
        ]
        if case let .course(topicID, _, count) = source {
            parameters["course_topic_id"] = topicID
            parameters["course_remaining_count"] = count
        }
        additional.forEach { parameters[$0.key] = $0.value }
        return parameters
    }
}

// MARK: - Premium Hero Image
// この画像をAssets.xcassetsに「PremiumHeroBanner」という名前で追加してください

// MARK: - Premium Design System

enum PremiumPalette {
    static let backdropTop = Color(hex: "0B1026")
    static let backdropMid = Color(hex: "16214B")
    static let backdropBottom = Color(hex: "2A1B4A")

    static let cardFill = Color.white.opacity(0.07)
    static let cardStroke = Color.white.opacity(0.14)

    static let ink = Color(hex: "2D1F14")
    static let gold = Color(hex: "FFCF5C")

    static let goldGradient = LinearGradient(
        colors: [Color(hex: "FFE9A8"), Color(hex: "FFC83D"), Color(hex: "F59A1E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldTextGradient = LinearGradient(
        colors: [Color(hex: "FFE9A8"), Color(hex: "FFC83D")],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct PremiumBackdrop: View {
    var animate: Bool

    var body: some View {
        LinearGradient(
            colors: [
                PremiumPalette.backdropTop,
                PremiumPalette.backdropMid,
                PremiumPalette.backdropBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .top) {
            glow(color: Color(hex: "FFC83D").opacity(0.30))
                .offset(x: -110, y: animate ? -160 : -130)
        }
        .overlay(alignment: .bottom) {
            glow(color: Color(hex: "6C5CE7").opacity(0.34))
                .offset(x: 120, y: animate ? 140 : 110)
        }
        .clipped()
        .ignoresSafeArea()
    }

    private func glow(color: Color) -> some View {
        Circle()
            .fill(
                RadialGradient(colors: [color, .clear], center: .center, startRadius: 0, endRadius: 210)
            )
            .frame(width: 420, height: 420)
            .allowsHitTesting(false)
    }
}

struct PremiumSectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(PremiumPalette.goldTextGradient)

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Spacer(minLength: 0)
        }
    }
}

struct PremiumTrustChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(.white.opacity(0.82))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.white.opacity(0.09)))
        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
    }
}

struct PremiumFAQRow: View {
    let question: String
    let answer: String
    @State private var isOpen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                generateHapticFeedback()
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOpen.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Text(question)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.92))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if isOpen {
                Text(answer)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 13)
                    .padding(.bottom, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PremiumPalette.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PremiumPalette.cardStroke, lineWidth: 1)
        )
    }
}

enum PremiumLegalSheet: String, Identifiable {
    case terms
    case privacy
    case cancelGuide

    var id: String { rawValue }
}

// MARK: - Period / Price Helpers

/// 購読期間を「週/月/年」に正規化する。
/// App Store Connect で「7日間」のように日数で登録されていても週額として扱う。
func premiumNormalizedPeriod(for product: Product) -> (unit: Product.SubscriptionPeriod.Unit, value: Int)? {
    if let period = product.subscription?.subscriptionPeriod {
        switch (period.unit, period.value) {
        case (.day, 7):
            return (.week, 1)
        case (.day, 30), (.day, 31):
            return (.month, 1)
        case (.day, 365), (.day, 366):
            return (.year, 1)
        default:
            return (period.unit, max(period.value, 1))
        }
    }

    let id = product.id.lowercased()
    if id.contains("week") { return (.week, 1) }
    if id.contains("month") { return (.month, 1) }
    if id.contains("year") || id.contains("annual") { return (.year, 1) }
    return nil
}

func premiumPeriodUnit(for product: Product) -> Product.SubscriptionPeriod.Unit? {
    premiumNormalizedPeriod(for: product)?.unit
}

/// 1か月あたりの実質金額。プラン同士を同じものさしで比べるために使う。
func premiumMonthlyEquivalent(for product: Product) -> Double? {
    guard let period = premiumNormalizedPeriod(for: product) else { return nil }
    let price = NSDecimalNumber(decimal: product.price).doubleValue
    let count = Double(period.value)

    switch period.unit {
    case .day: return price * 30.0 / count
    case .week: return price * 52.0 / 12.0 / count
    case .month: return price / count
    case .year: return price / (12.0 * count)
    default: return nil
    }
}

func premiumCurrencyText(_ amount: Double, like product: Product) -> String {
    Decimal(amount).formatted(product.priceFormatStyle)
}

/// 1日あたりの金額表記。「月980円」より心理的な負担が小さく見える。
func premiumDailyEquivalentText(for product: Product) -> String? {
    guard let monthly = premiumMonthlyEquivalent(for: product) else { return nil }
    return premiumCurrencyText(monthly * 12.0 / 365.0, like: product)
}

/// 他プランと比べた割引率。実価格から計算するので価格改定しても表示が狂わない。
func premiumDiscountPercent(for product: Product, comparedTo base: Product?) -> Int? {
    guard let base,
          let target = premiumMonthlyEquivalent(for: product),
          let baseline = premiumMonthlyEquivalent(for: base),
          baseline > 0,
          target < baseline else { return nil }

    let percent = Int(((baseline - target) / baseline * 100).rounded())
    return percent > 0 ? percent : nil
}

func premiumPlanTitle(for product: Product) -> String {
    switch premiumPeriodUnit(for: product) {
    case .week: return "週額プラン"
    case .month: return "月額プラン"
    case .year: return "年額プラン"
    default: return "プラン"
    }
}

func premiumPeriodSuffix(for product: Product) -> String {
    switch premiumPeriodUnit(for: product) {
    case .week: return "/週"
    case .month: return "/月"
    case .year: return "/年"
    default: return ""
    }
}

// MARK: - Free vs Premium Comparison
struct PremiumComparisonRow: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let free: String
    let premium: String
    let premiumIsCheck: Bool
}

let premiumComparisonRows: [PremiumComparisonRow] = [
    PremiumComparisonRow(icon: "checkmark.seal.fill", title: "苦手克服のテーマ練習（IT）", free: "1テーマ", premium: "全10テーマ", premiumIsCheck: false),
    PremiumComparisonRow(icon: "scope", title: "苦手分野の集中特訓", free: "－", premium: "", premiumIsCheck: true),
    PremiumComparisonRow(icon: "rectangle.badge.xmark", title: "広告", free: "表示あり", premium: "非表示", premiumIsCheck: false),
    PremiumComparisonRow(icon: "chart.bar.fill", title: "学習分析", free: "基本のみ", premium: "すべて", premiumIsCheck: false),
    PremiumComparisonRow(icon: "arrow.counterclockwise.circle.fill", title: "間違えた問題の復習", free: "1日5問", premium: "全問題", premiumIsCheck: false),
    PremiumComparisonRow(icon: "person.2.fill", title: "フレンド登録", free: "10人まで", premium: "30人まで", premiumIsCheck: false)
]

struct PremiumComparisonTable: View {
    private let freeColumnWidth: CGFloat = 68
    private let premiumColumnWidth: CGFloat = 92

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Spacer(minLength: 4)

                Text("無料")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: freeColumnWidth)

                HStack(spacing: 3) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("プレミアム")
                        .font(.system(size: 11, weight: .black))
                }
                .foregroundStyle(PremiumPalette.goldTextGradient)
                .frame(width: premiumColumnWidth)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            ForEach(Array(premiumComparisonRows.enumerated()), id: \.element.id) { index, row in
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: row.icon)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 20)

                        Text(row.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer(minLength: 4)

                    Text(row.free)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.42))
                        .frame(width: freeColumnWidth)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))

                        if !row.premiumIsCheck {
                            Text(row.premium)
                                .font(.system(size: 12, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .foregroundColor(PremiumPalette.gold)
                    .frame(width: premiumColumnWidth)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(index % 2 == 0 ? Color.white.opacity(0.05) : Color.clear)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PremiumPalette.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PremiumPalette.cardStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Plan Selection Card
struct PlanSelectionCard: View {
    let product: Product
    let isSelected: Bool
    /// 無料トライアル情報。nil の場合は従来どおりの表示になる
    var introOffer: IntroOfferInfo? = nil
    /// 割引率の計算に使う。渡さない場合は割引表示なし。
    var allProducts: [Product] = []
    let onSelect: () -> Void

    private var unit: Product.SubscriptionPeriod.Unit? {
        premiumPeriodUnit(for: product)
    }

    /// 月額プランを基準に「おすすめ」を出す（迷ったときの初期選択と揃える）
    private var isRecommended: Bool {
        unit == .month
    }

    private var badge: (text: String, colors: [Color], icon: String)? {
        if let intro = introOffer {
            return (intro.badgeText, [Color(hex: "1FBF75"), Color(hex: "2FD08A")], "gift.fill")
        }

        switch unit {
        case .month:
            return ("人気", [Color(hex: "5B7CFA"), Color(hex: "8E5BFA")], "heart.fill")
        case .year:
            if let percent = premiumDiscountPercent(for: product, comparedTo: monthlyProduct) {
                return ("\(percent)%お得", [Color(hex: "FF8A3D"), Color(hex: "FF4D6D")], "star.fill")
            }
            return ("最もお得", [Color(hex: "FF8A3D"), Color(hex: "FF4D6D")], "star.fill")
        case .week:
            return ("お試し", [Color(hex: "16BFA5"), Color(hex: "2FD08A")], "leaf.fill")
        default:
            return nil
        }
    }

    private var monthlyProduct: Product? {
        allProducts.first { premiumPeriodUnit(for: $0) == .month }
    }

    /// トライアルがある場合はその内容を、無い場合は金額の目安を出す
    private var subtitleText: String {
        if let intro = introOffer { return intro.cardSubtitle }

        switch unit {
        case .year:
            if let monthlyEquivalent = premiumMonthlyEquivalent(for: product) {
                return "月あたり約\(premiumCurrencyText(monthlyEquivalent, like: product))"
            }
            return "1年分をまとめてお得に"
        case .month:
            if let daily = premiumDailyEquivalentText(for: product) {
                return "1日あたり約\(daily)で続けられます"
            }
            return "学習習慣を続けたい方におすすめ"
        case .week:
            return "まずは1週間おためし"
        default:
            return "プレミアム機能をすべて利用できます"
        }
    }

    var body: some View {
        Button(action: {
            generateHapticFeedback()
            onSelect()
        }) {
            HStack(spacing: 13) {
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? PremiumPalette.gold : Color.white.opacity(0.32),
                            lineWidth: isSelected ? 2.5 : 1.5
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(PremiumPalette.goldGradient)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(premiumPlanTitle(for: product))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        if let badge {
                            HStack(spacing: 3) {
                                Image(systemName: badge.icon)
                                    .font(.system(size: 9))
                                Text(badge.text)
                                    .font(.system(size: 10, weight: .black))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(
                                    LinearGradient(colors: badge.colors, startPoint: .leading, endPoint: .trailing)
                                )
                            )
                        }
                    }

                    Text(subtitleText)
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.66))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                VStack(alignment: .trailing, spacing: 0) {
                    Text(product.displayPrice)
                        .font(.system(size: 23, weight: .black))
                        .foregroundColor(.white)

                    Text(premiumPeriodSuffix(for: product))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.13) : Color.black.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSelected
                            ? LinearGradient(
                                colors: [Color(hex: "FFE9A8"), Color(hex: "FFC83D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.16), Color.white.opacity(0.10)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color(hex: "FFC83D").opacity(0.28) : .clear, radius: 10, x: 0, y: 4)
            .overlay(alignment: .topTrailing) {
                if isRecommended {
                    Text("おすすめ")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(PremiumPalette.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(PremiumPalette.goldGradient))
                        .offset(x: -12, y: -9)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductLoadStatusView: View {
    let state: StoreProductLoadState
    let message: String?
    let retry: () -> Void

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                HStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("App Storeから価格を確認しています")
                        .foregroundColor(.white.opacity(0.75))
                }
            case .empty, .failed:
                VStack(spacing: 12) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    Text(message ?? "購入プランを取得できませんでした。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Button(action: retry) {
                        Label("もう一度読み込む", systemImage: "arrow.clockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "2D1F14"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            case .loaded:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - Main PreView
struct PreView: View {
    let source: PremiumPaywallSource
    private let onPurchaseSuccess: (() -> Void)?
    @State private var selectedProduct: Product? = nil
    @StateObject private var viewModel = SubscriptionViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager: AudioManager
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var animateGlow = false
    @State private var isPurchasing = false
    @State private var didLogPaywallView = false
    @State private var didLogPaywallReady = false
    @State private var didLogPaywallDismiss = false
    @State private var purchaseSucceeded = false
    @State private var paywallDisplayID = UUID().uuidString
    @State private var activeLegalSheet: PremiumLegalSheet?
    @State private var shineOffset: CGFloat = -180

    init(
        audioManager: AudioManager,
        source: PremiumPaywallSource = .general,
        onPurchaseSuccess: (() -> Void)? = nil
    ) {
        self.audioManager = audioManager
        self.source = source
        self.onPurchaseSuccess = onPurchaseSuccess
    }
    
    var body: some View {
        ZStack {
            PremiumBackdrop(animate: animateGlow)

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroSection
                        headlineSection
                        trustChips
                        comparisonSection
                        planSection
                        faqSection
                        legalFooter
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            purchaseBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $activeLegalSheet) { sheet in
            legalSheetView(sheet)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    guard purchaseSucceeded else { return }
                    purchaseSucceeded = false
                    onPurchaseSuccess?()
                    logPaywallDismissIfNeeded(reason: "purchase_success")
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            if !didLogPaywallView {
                PremiumAnalytics.logPaywallView(source: source, displayID: paywallDisplayID)
                didLogPaywallView = true
            }

            // Glow animation
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
            withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                shineOffset = 220
            }

            // Load products
            Task {
                await loadProductsAndConfigurePaywall(selectionMethod: "default")
            }
        }
    }

    // MARK: - Sections

    private var topBar: some View {
        HStack {
            Button(action: {
                generateHapticFeedback()
                logPaywallDismissIfNeeded(reason: "back_button")
                presentationMode.wrappedValue.dismiss()
                audioManager.playCancelSound()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("戻る")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.92))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.12)))
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: restorePurchases) {
                Text("購入を復元")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [
                    PremiumPalette.backdropTop,
                    PremiumPalette.backdropTop.opacity(0.92),
                    PremiumPalette.backdropTop.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
        .zIndex(1)
    }

    private var heroSection: some View {
        Image("PremiumHeroBanner")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(PremiumPalette.gold.opacity(0.45), lineWidth: 1.5)
            )
            .shadow(color: Color(hex: "FFC83D").opacity(0.25), radius: 16, x: 0, y: 6)
    }

    private var headlineSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                Text(source.eyebrow)
                    .font(.system(size: 11, weight: .black))
            }
            .foregroundColor(PremiumPalette.ink)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(Capsule().fill(PremiumPalette.goldGradient))

            Text(source.headline)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(source.detail)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.76))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 6)
    }

    private var trustChips: some View {
        HStack(spacing: 8) {
            PremiumTrustChip(icon: "checkmark.shield.fill", text: "いつでも解約OK")
            PremiumTrustChip(icon: "applelogo", text: "App Store決済")
            PremiumTrustChip(icon: "bolt.fill", text: "登録後すぐ反映")
        }
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            PremiumSectionHeader(icon: "crown.fill", title: "無料プランとのちがい")
            PremiumComparisonTable()
        }
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            PremiumSectionHeader(icon: "tag.fill", title: "プランを選択")

            if viewModel.productLoadState != .loaded {
                ProductLoadStatusView(
                    state: viewModel.productLoadState,
                    message: viewModel.productLoadErrorMessage,
                    retry: retryProductLoad
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedProducts(), id: \.id) { product in
                        PlanSelectionCard(
                            product: product,
                            isSelected: selectedProduct?.id == product.id,
                            introOffer: viewModel.introOffer(for: product),
                            allProducts: viewModel.products
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedProduct = product
                            }
                            PremiumAnalytics.logPlanSelect(
                                product: product,
                                source: source,
                                displayID: paywallDisplayID,
                                method: "manual"
                            )
                        }
                    }
                }
            }
        }
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            PremiumSectionHeader(icon: "questionmark.circle.fill", title: "よくある質問")

            PremiumFAQRow(
                question: "解約はいつでもできますか？",
                answer: "はい。App Storeの「サブスクリプション」からいつでも解約できます。解約しても、支払い済みの期間が終わるまではプレミアム機能をそのまま使えます。"
            )

            PremiumFAQRow(
                question: "料金はどのように請求されますか？",
                answer: "Apple IDに登録されたお支払い方法から請求されます。期間終了の24時間前までに解約しない場合は、同じ期間で自動更新されます。"
            )

            PremiumFAQRow(
                question: "機種変更しても引き継げますか？",
                answer: "同じApple IDでサインインし、画面右上の「購入を復元」を押すと引き継げます。"
            )
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                Text("購入復元は")
                    .foregroundColor(.white.opacity(0.6))
                Button("こちら") {
                    restorePurchases()
                }
                .foregroundColor(.cyan)
                Text("・解約は")
                    .foregroundColor(.white.opacity(0.6))
                Button("こちら") {
                    activeLegalSheet = .cancelGuide
                }
                .foregroundColor(.cyan)
            }
            .font(.system(size: 12))

            HStack(spacing: 14) {
                Button("利用規約") {
                    activeLegalSheet = .terms
                }
                .foregroundColor(.white.opacity(0.55))

                Text("・")
                    .foregroundColor(.white.opacity(0.35))

                Button("プライバシーポリシー") {
                    activeLegalSheet = .privacy
                }
                .foregroundColor(.white.opacity(0.55))
            }
            .font(.system(size: 11))

            Text("登録期間終了の24時間前までに解約しない場合、同じ料金で自動更新されます。")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func legalSheetView(_ sheet: PremiumLegalSheet) -> some View {
        NavigationView {
            Group {
                switch sheet {
                case .terms:
                    TermsOfServiceView()
                case .privacy:
                    PrivacyView()
                case .cancelGuide:
                    WebView(urlString: "https://support.apple.com/ja-jp/HT202039")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        activeLegalSheet = nil
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func restorePurchases() {
        generateHapticFeedback()
        Task {
            PremiumAnalytics.logRestoreStart(source: source, displayID: paywallDisplayID)
            do {
                try await AppStore.sync()
                await appState.refreshSubscriptionState()
                PremiumAnalytics.logRestoreSuccess(
                    source: source,
                    displayID: paywallDisplayID,
                    restoredSubscription: appState.isSubscribed
                )
            } catch {
                PremiumAnalytics.logRestoreError(
                    source: source,
                    displayID: paywallDisplayID,
                    error: error
                )
                print("購入処理中にエラーが発生しました: \(error)")
            }
        }
    }

    private var purchaseBar: some View {
        VStack(spacing: 8) {
            if let summary = selectedPlanSummary {
                Text(summary)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Button(action: purchaseSelectedProduct) {
                HStack(spacing: 10) {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PremiumPalette.ink))
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 17))
                    }

                    VStack(spacing: 2) {
                        Text(purchaseButtonTitle)
                            .font(.system(size: 17, weight: .black))
                        Text(purchaseButtonCaption)
                            .font(.system(size: 10.5))
                            .multilineTextAlignment(.center)
                            .opacity(0.85)
                    }
                }
                .foregroundColor(PremiumPalette.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PremiumPalette.goldGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color.white.opacity(0.5), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 46)
                        .blur(radius: 6)
                        .rotationEffect(.degrees(18))
                        .offset(x: shineOffset)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
                .shadow(
                    color: Color(hex: "FFB020").opacity(animateGlow ? 0.55 : 0.28),
                    radius: animateGlow ? 16 : 8,
                    x: 0,
                    y: 5
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(selectedProduct == nil || isPurchasing)
            .opacity(selectedProduct == nil ? 0.55 : 1)
            .accessibilityLabel(purchaseButtonTitle)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [PremiumPalette.backdropTop.opacity(0), PremiumPalette.backdropTop],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)

                PremiumPalette.backdropTop
            }
            .padding(.top, -28)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    /// 選択中プランの要約。1日あたりの金額に言い換えて心理的な負担を下げる。
    private var selectedPlanSummary: String? {
        guard let product = selectedProduct else { return nil }
        let title = premiumPlanTitle(for: product)

        if let intro = viewModel.introOffer(for: product) {
            return "\(title)・\(intro.badgeText)からスタート"
        }

        if let daily = premiumDailyEquivalentText(for: product) {
            return "\(title) \(product.displayPrice)\(premiumPeriodSuffix(for: product))・1日あたり約\(daily)"
        }

        return "\(title) \(product.displayPrice)\(premiumPeriodSuffix(for: product))"
    }

    private var purchaseButtonTitle: String {
        guard let product = selectedProduct else {
            return "プランを選択してください"
        }
        if let intro = viewModel.introOffer(for: product) {
            return intro.ctaTitle
        }
        return "\(periodLabel(for: product))\(product.displayPrice)で始める"
    }

    /// トライアル時は期間と終了後の価格を明示する（App Store 審査ガイドライン 3.1.2 の要件）
    private var purchaseButtonCaption: String {
        if let product = selectedProduct,
           let intro = viewModel.introOffer(for: product) {
            return intro.disclosureText
        }
        return "自動更新・いつでも解約できます"
    }

    private func periodLabel(for product: Product) -> String {
        switch product.subscription?.subscriptionPeriod.unit {
        case .week: return "週額"
        case .month: return "月額"
        case .year: return "年額"
        default: return ""
        }
    }

    private func purchaseSelectedProduct() {
        guard let product = selectedProduct, !isPurchasing else { return }
        generateHapticFeedback()
        isPurchasing = true
        PremiumAnalytics.logPlanSelect(
            product: product,
            source: source,
            displayID: paywallDisplayID,
            method: "purchase_button"
        )
        PremiumAnalytics.logPurchaseStart(product: product, source: source, displayID: paywallDisplayID)
        let startsFreeTrial = viewModel.introOffer(for: product)?.isFreeTrial == true

        Task {
            do {
                let transaction = try await viewModel.purchaseProduct(product)
                PremiumAnalytics.logPurchaseSuccess(
                    product: product,
                    transaction: transaction,
                    isFreeTrial: startsFreeTrial,
                    source: source,
                    displayID: paywallDisplayID
                )
                purchaseSucceeded = true
                alertTitle = "プレミアムプラン登録ありがとうございます！"
                alertMessage = "プレミアム機能が利用できるようになりました"
                showAlert = true
            } catch SubscribeError.userCancelled {
                PremiumAnalytics.logPurchaseCancel(product: product, source: source, displayID: paywallDisplayID)
            } catch SubscribeError.pending {
                PremiumAnalytics.logPurchasePending(product: product, source: source, displayID: paywallDisplayID)
                alertTitle = "購入は保留中です"
                alertMessage = SubscribeError.pending.errorDescription ?? "承認後に自動的に反映されます"
                showAlert = true
            } catch {
                PremiumAnalytics.logPurchaseError(product: product, source: source, displayID: paywallDisplayID, error: error)
                alertTitle = "購入できませんでした"
                alertMessage = (error as? LocalizedError)?.errorDescription
                    ?? "購入処理中にエラーが発生しました。もう一度お試しください"
                showAlert = true
            }
            isPurchasing = false
        }
    }
    
    // MARK: - Helper Functions
    private func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    private func sortedProducts() -> [Product] {
        sortProductsByPeriod(viewModel.products)
    }

    private func retryProductLoad() {
        Task {
            await loadProductsAndConfigurePaywall(selectionMethod: "retry_default")
        }
    }

    @MainActor
    private func loadProductsAndConfigurePaywall(selectionMethod: String) async {
        await viewModel.loadProducts()
        guard viewModel.productLoadState == .loaded else { return }

        if !didLogPaywallReady {
            let monthlyTrialEligible = viewModel.products.contains { product in
                product.subscription?.subscriptionPeriod.unit == .month
                    && viewModel.introOffer(for: product)?.isFreeTrial == true
            }
            PremiumAnalytics.logPaywallReady(
                source: source,
                displayID: paywallDisplayID,
                products: viewModel.products,
                missingProductCount: viewModel.missingProductCount,
                loadAttemptCount: viewModel.productLoadAttemptCount,
                hasEligibleMonthlyTrial: monthlyTrialEligible
            )
            didLogPaywallReady = true
        }

        let defaultProduct = viewModel.products.first(where: {
            $0.subscription?.subscriptionPeriod.unit == .month
        }) ?? sortedProducts().first

        guard selectedProduct == nil else { return }
        guard let product = defaultProduct else { return }
        selectedProduct = product
        PremiumAnalytics.logPlanSelect(
            product: product,
            source: source,
            displayID: paywallDisplayID,
            method: selectionMethod
        )
    }

    private func logPaywallDismissIfNeeded(reason: String) {
        guard !didLogPaywallDismiss else { return }
        didLogPaywallDismiss = true
        PremiumAnalytics.logPaywallDismiss(
            source: source,
            displayID: paywallDisplayID,
            reason: reason,
            selectedProductID: selectedProduct?.id
        )
    }
}

func sortProductsByPeriod(_ products: [Product]) -> [Product] {
    let order: [Product.SubscriptionPeriod.Unit: Int] = [
        .month: 0,
        .year: 1,
        .week: 2
    ]
    return products.sorted { product1, product2 in
        let priority1 = order[product1.subscription?.subscriptionPeriod.unit ?? .day] ?? 0
        let priority2 = order[product2.subscription?.subscriptionPeriod.unit ?? .day] ?? 0
        return priority1 < priority2
    }
}

// MARK: - Preview
struct PreView_Previews: PreviewProvider {
    static var previews: some View {
        PreView(audioManager: AudioManager())
    }
}
