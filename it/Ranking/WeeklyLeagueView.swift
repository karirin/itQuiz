import SwiftUI
import UIKit
import FirebaseDatabase

final class WeeklyLeagueViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var isJoined = false
    @Published var tier: WeeklyLeagueTier = .bronze
    @Published var season: WeeklyLeagueSeason?
    @Published var members: [WeeklyLeagueMember] = []
    @Published var pendingResult: WeeklyLeagueResult?
    @Published var errorMessage: String?
    @Published var isClaimingReward = false

    private let service: WeeklyLeagueService
    private let authManager: AuthManager
    private var groupReference: DatabaseReference?
    private var groupHandle: DatabaseHandle?

    init(
        service: WeeklyLeagueService = .shared,
        authManager: AuthManager = .shared
    ) {
        self.service = service
        self.authManager = authManager
    }

    deinit {
        stopObserving()
    }

    var currentUserId: String? {
        authManager.currentUserId
    }

    var isParticipating: Bool { isJoined }

    var snapshot: WeeklyLeagueSnapshot {
        let displayed = members
        return WeeklyLeagueSnapshot(
            tier: tier,
            season: season,
            members: displayed,
            currentUserId: currentUserId,
            // 昇格枠はマスターで 0、降格枠はブロンズで 0（Service の確定条件に合わせる）
            promotionSlots: tier == .master ? 0 : service.promotionCount(memberCount: displayed.count),
            relegationSlots: tier == .bronze ? 0 : service.relegationCount(memberCount: displayed.count)
        )
    }

    func load() {
        stopObserving()
        isLoading = true
        errorMessage = nil

        guard let userId = authManager.currentUserId else {
            isLoading = false
            errorMessage = "ランキングを見るにはログインが必要です。"
            return
        }

        service.resolveCurrentLeague(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                case .success(let resolution):
                    self.tier = resolution.tier
                    self.season = resolution.season
                    self.pendingResult = resolution.pendingResult
                    self.isJoined = resolution.membership != nil

                    guard let membership = resolution.membership else {
                        self.joinCurrentSeason(
                            userId: userId,
                            tier: resolution.tier,
                            season: resolution.season
                        )
                        return
                    }
                    self.beginObserving(membership)
                }
            }
        }
    }

    private func joinCurrentSeason(
        userId: String,
        tier: WeeklyLeagueTier,
        season: WeeklyLeagueSeason
    ) {
        service.joinCurrentSeasonIfNeeded(
            userId: userId,
            tier: tier,
            season: season
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let membership):
                    self.tier = membership.tier
                    self.isJoined = true
                    self.beginObserving(membership)
                case .failure(let error):
                    self.members = []
                    self.isJoined = false
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stopObserving() {
        if let groupReference, let groupHandle {
            groupReference.removeObserver(withHandle: groupHandle)
        }
        groupReference = nil
        groupHandle = nil
    }

    func claim(_ result: WeeklyLeagueResult, completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            errorMessage = "ログイン情報を確認できませんでした。"
            completion(false)
            return
        }
        isClaimingReward = true
        service.claimReward(result, userId: userId) { [weak self] claimResult in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isClaimingReward = false
                switch claimResult {
                case .success(let grantedCoins):
                    // 既に受け取り済みだった場合は 0。残高を二重に増やさない。
                    self.authManager.money += grantedCoins
                    self.pendingResult = nil
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    private func beginObserving(_ membership: WeeklyLeagueMembership) {
        let observation = service.observeGroup(membership: membership) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let members):
                    self.members = members
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        groupReference = observation.reference
        groupHandle = observation.handle
    }
}

// MARK: - 前回訪問時の順位を覚えておく
//
// 「前回から ↑3」を出すためだけの記録。サーバには保存しない。
enum WeeklyLeagueVisitTracker {
    private static func key(_ seasonId: String) -> String {
        "weeklyLeagueLastSeenRank.\(seasonId)"
    }

    static func lastSeenRank(seasonId: String) -> Int? {
        let stored = UserDefaults.standard.integer(forKey: key(seasonId))
        return stored > 0 ? stored : nil
    }

    static func record(rank: Int, seasonId: String) {
        guard rank > 0 else { return }
        UserDefaults.standard.set(rank, forKey: key(seasonId))
    }
}

// MARK: - 画面が必要とする情報だけを束ねた値型
//
// 表示に必要な計算をここへ集約し、View は結果を描画するだけにする。
// Firebase を触らずにあらゆる画面状態を Preview できるようにする狙いもある。
struct WeeklyLeagueSnapshot: Equatable {
    var tier: WeeklyLeagueTier = .bronze
    var season: WeeklyLeagueSeason?
    var members: [WeeklyLeagueMember] = []
    var currentUserId: String?
    var promotionSlots: Int = 0
    var relegationSlots: Int = 0

    var memberCount: Int { members.count }

    var currentIndex: Int? {
        guard let currentUserId else { return nil }
        return members.firstIndex(where: { $0.id == currentUserId })
    }

    var currentRank: Int? {
        currentIndex.map { $0 + 1 }
    }

    var currentMember: WeeklyLeagueMember? {
        currentIndex.map { members[$0] }
    }

    var currentScore: Int {
        currentMember?.score ?? 0
    }

    /// 昇格する最下位の順位。枠が成立しないときは nil。
    var promotionLine: Int? {
        guard promotionSlots > 0, promotionSlots < memberCount else { return nil }
        return promotionSlots
    }

    /// 降格が始まる順位。
    var relegationLine: Int? {
        guard relegationSlots > 0, relegationSlots < memberCount else { return nil }
        let line = memberCount - relegationSlots + 1
        guard let promotionLine else { return line }
        return line > promotionLine ? line : nil
    }

    /// 昇格・降格のどちらも成立していないリーグか（参加者が少ない場合など）。
    var hasNoStakes: Bool {
        promotionLine == nil && relegationLine == nil
    }

    func zone(for rank: Int) -> WeeklyLeagueZone {
        if let promotionLine, rank <= promotionLine { return .promotion }
        if let relegationLine, rank >= relegationLine { return .relegation }
        return .safe
    }

    /// バッジに出す立ち位置。昇降格枠が無いリーグで「昇格圏」と偽らないための区別。
    var standing: WeeklyLeagueStanding {
        guard let rank = currentRank else { return .waiting }
        guard memberCount >= 2 else { return .waiting }
        guard !hasNoStakes else { return rank == 1 ? .leading : .neutral }
        switch zone(for: rank) {
        case .promotion: return .promotion
        case .relegation: return .relegation
        case .safe: return .safe
        }
    }

    /// リーグ構成の説明（例: 上位5人が昇格・下位5人が降格）
    var structureSummary: String {
        var parts: [String] = []
        if let promotionLine { parts.append("上位\(promotionLine)人が昇格") }
        if let relegationLine { parts.append("下位\(memberCount - relegationLine + 1)人が降格") }
        if parts.isEmpty {
            parts.append(tier == .master ? "頂点のリーグ" : "あと\(max(2 - memberCount, 1))人でリーグ戦が成立")
        }
        return parts.joined(separator: "・")
    }

    // MARK: 毎日の動機づけに使う値

    private static func isToday(_ milliseconds: TimeInterval) -> Bool {
        guard milliseconds.isFinite, milliseconds > 0 else { return false }
        return Calendar.current.isDateInToday(Date(timeIntervalSince1970: milliseconds / 1_000))
    }

    /// 自分が今日ポイントを獲得しているか。
    var hasEarnedToday: Bool {
        guard let member = currentMember, member.score > 0 else { return false }
        return Self.isToday(member.scoreReachedAt)
    }

    /// 今日スコアを更新した参加者の数。リーグが動いていることを示す。
    var activeTodayCount: Int {
        members.filter { $0.score > 0 && Self.isToday($0.scoreReachedAt) }.count
    }

    /// 「次に何をすればいいか」をひとつだけ示す。
    var goal: WeeklyLeagueGoal {
        guard let rank = currentRank else {
            return WeeklyLeagueGoal(
                zone: .safe,
                headline: "クイズを解いてポイントを獲得",
                caption: nil,
                progress: 0,
                neededPoints: nil
            )
        }

        // 降格圏にいるときは、まず残留が最優先の目標。
        if let relegationLine, rank >= relegationLine, relegationLine >= 2 {
            let safeRank = relegationLine - 1
            let target = members[safeRank - 1].score + 1
            let need = max(target - currentScore, 0)
            return WeeklyLeagueGoal(
                zone: .relegation,
                headline: "残留まであと \(need)pt",
                caption: "\(safeRank)位・\(members[safeRank - 1].score)ptが残留ライン",
                progress: target > 0 ? Double(currentScore) / Double(target) : 0,
                neededPoints: need
            )
        }

        if let promotionLine {
            if rank <= promotionLine {
                // 昇格圏内。追われている差を見せて「守りたい」動機にする。
                let chaserIndex = promotionLine // 0-based で昇格圏のひとつ下
                let lead = chaserIndex < memberCount ? currentScore - members[chaserIndex].score : currentScore
                return WeeklyLeagueGoal(
                    zone: .promotion,
                    headline: "昇格圏をキープ中",
                    caption: chaserIndex < memberCount
                        ? "\(promotionLine + 1)位に \(max(lead, 0))pt リード"
                        : nil,
                    progress: 1,
                    neededPoints: nil
                )
            }
            let target = members[promotionLine - 1].score + 1
            let need = max(target - currentScore, 0)
            return WeeklyLeagueGoal(
                // 目指している先の色。今がキープ圏でも「昇格」の色で見せる。
                zone: .promotion,
                headline: "昇格まであと \(need)pt",
                caption: "\(promotionLine)位・\(members[promotionLine - 1].score)ptが昇格ライン",
                progress: target > 0 ? Double(currentScore) / Double(target) : 0,
                neededPoints: need
            )
        }

        // ここから先は昇格枠も降格枠も成立していないリーグ。
        // 「昇格圏」と偽らず、参加者が集まるのを待っている状態として扱う。
        guard memberCount >= 2 else {
            return WeeklyLeagueGoal(
                zone: .safe,
                headline: "参加者が集まるのを待っています",
                caption: "ポイントを稼いでおくと、集まったときに有利です",
                progress: 0,
                neededPoints: nil
            )
        }

        if rank == 1 {
            return WeeklyLeagueGoal(
                zone: .safe,
                headline: "首位をキープ中",
                caption: "2位に \(max(currentScore - members[1].score, 0))pt リード",
                progress: 1,
                neededPoints: nil
            )
        }

        let target = members[rank - 2].score + 1
        let need = max(target - currentScore, 0)
        return WeeklyLeagueGoal(
            zone: .promotion,
            headline: "\(rank - 1)位まであと \(need)pt",
            caption: "上位を目指してポイントを積み上げよう",
            progress: target > 0 ? Double(currentScore) / Double(target) : 0,
            neededPoints: need
        )
    }
}

struct WeeklyLeagueGoal: Equatable {
    let zone: WeeklyLeagueZone
    let headline: String
    let caption: String?
    let progress: Double
    /// 目標まで不足しているポイント。達成済み・目標なしのときは nil。
    let neededPoints: Int?

    /// 正解1問分のポイントに読み替えて、次の行動を具体的にする。
    var neededCorrectAnswers: Int? {
        guard let neededPoints, neededPoints > 0 else { return nil }
        return Int(ceil(Double(neededPoints) / Double(WeeklyLeaguePointRules.correctAnswer)))
    }
}

// MARK: - 立ち位置バッジ

enum WeeklyLeagueStanding: Equatable {
    case promotion
    case safe
    case relegation
    case leading
    case neutral
    case waiting

    var title: String {
        switch self {
        case .promotion: return "昇格圏"
        case .safe: return "キープ圏"
        case .relegation: return "降格圏"
        case .leading: return "首位"
        case .neutral: return "参加中"
        case .waiting: return "参加者募集中"
        }
    }

    var symbol: String {
        switch self {
        case .promotion: return "arrow.up.right"
        case .safe: return "minus"
        case .relegation: return "arrow.down.right"
        case .leading: return "crown.fill"
        case .neutral: return "person.fill"
        case .waiting: return "hourglass"
        }
    }

    var tint: Color {
        switch self {
        case .promotion: return WeeklyLeaguePalette.promotion
        case .relegation: return WeeklyLeaguePalette.relegation
        case .leading: return WeeklyLeaguePalette.coin
        case .safe, .neutral, .waiting: return WeeklyLeaguePalette.neutral
        }
    }

    /// 順位の数字に使う色。画面最大の要素なので、無彩色にせず必ず読ませる。
    var rankColor: Color {
        switch self {
        case .promotion: return WeeklyLeaguePalette.promotion
        case .relegation: return WeeklyLeaguePalette.relegation
        case .leading: return WeeklyLeaguePalette.coin
        case .safe, .neutral, .waiting: return WeeklyLeaguePalette.primaryText
        }
    }
}

// MARK: - ゾーン（昇格圏 / キープ圏 / 降格圏）

enum WeeklyLeagueZone: Equatable {
    case promotion
    case safe
    case relegation

    var tint: Color {
        switch self {
        case .promotion: return WeeklyLeaguePalette.promotion
        case .safe: return WeeklyLeaguePalette.neutral
        case .relegation: return WeeklyLeaguePalette.relegation
        }
    }

    /// 昇格は青〜緑、降格は赤〜オレンジ。
    var gradient: LinearGradient {
        switch self {
        case .promotion:
            return LinearGradient(
                colors: [WeeklyLeaguePalette.promotionAlt, WeeklyLeaguePalette.promotion],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .safe:
            return LinearGradient(
                colors: [WeeklyLeaguePalette.neutral, WeeklyLeaguePalette.neutral],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .relegation:
            return LinearGradient(
                colors: [WeeklyLeaguePalette.relegationAlt, WeeklyLeaguePalette.relegation],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - 配色（ライト / ダーク両対応）

enum WeeklyLeaguePalette {
    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { trait in
            UIColor(Color(hex: trait.userInterfaceStyle == .dark ? dark : light))
        })
    }

    static let canvas = adaptive(light: "F4F5FA", dark: "0E1116")
    static let surface = adaptive(light: "FFFFFF", dark: "191F29").opacity(0.64)
    static let surfaceSunken = adaptive(light: "FFFFFF", dark: "141A23").opacity(0.48)
    static let hairline = adaptive(light: "FFFFFF", dark: "AAB4C2").opacity(0.72)
    static let primaryText = adaptive(light: "2C3038", dark: "ECEFF4")
    static let secondaryText = adaptive(light: "79808F", dark: "99A2B2")
    static let track = adaptive(light: "EBEEF4", dark: "252D3A")
    static let skeleton = adaptive(light: "E1E5F0", dark: "222A36")

    /// 固定バーなど、内容の上に重ねて確実に目立たせたい面。
    static let inverseSurface = adaptive(light: "232935", dark: "F1F4F9")
    static let inverseText = adaptive(light: "FFFFFF", dark: "1A1F29")

    static let promotion = adaptive(light: "0E9F6E", dark: "34D399")
    static let promotionAlt = adaptive(light: "2B7FFF", dark: "60A5FA")
    static let relegation = adaptive(light: "DC4E36", dark: "FB7C5C")
    static let relegationAlt = adaptive(light: "EA8A1E", dark: "FBBF24")
    static let neutral = adaptive(light: "8E96A6", dark: "78818F")
    static let coin = adaptive(light: "D9930C", dark: "F5C24B")
    static let flame = adaptive(light: "E4622C", dark: "FB923C")
}

// MARK: - リーグごとの色

struct WeeklyLeagueTheme {
    /// 帯やリングに使うアクセント。面をベタ塗りしないので、彩度は高めでよい。
    let accent: Color
    let stripStart: Color
    let stripEnd: Color
    let fallbackSymbol: String

    var strip: LinearGradient {
        LinearGradient(colors: [stripStart, stripEnd], startPoint: .leading, endPoint: .trailing)
    }

    static func theme(for tier: WeeklyLeagueTier) -> WeeklyLeagueTheme {
        switch tier {
        case .bronze:
            return WeeklyLeagueTheme(
                accent: WeeklyLeaguePalette.adaptive(light: "B06A34", dark: "D89A5E"),
                stripStart: Color(hex: "8A4A22"), stripEnd: Color(hex: "D89A5E"),
                fallbackSymbol: "shield.fill"
            )
        case .silver:
            return WeeklyLeagueTheme(
                accent: WeeklyLeaguePalette.adaptive(light: "6C7A8E", dark: "AEBBCB"),
                stripStart: Color(hex: "5A6779"), stripEnd: Color(hex: "AEBBCB"),
                fallbackSymbol: "shield.fill"
            )
        case .gold:
            return WeeklyLeagueTheme(
                accent: WeeklyLeaguePalette.adaptive(light: "B8820A", dark: "F2C94C"),
                stripStart: Color(hex: "A8760A"), stripEnd: Color(hex: "F2C94C"),
                fallbackSymbol: "shield.lefthalf.filled"
            )
        case .master:
            return WeeklyLeagueTheme(
                accent: WeeklyLeaguePalette.adaptive(light: "6D4AE0", dark: "A78BFA"),
                stripStart: Color(hex: "4C2FBF"), stripEnd: Color(hex: "A78BFA"),
                fallbackSymbol: "crown.fill"
            )
        }
    }
}

// MARK: - 共通の小さな部品

/// リーグのクレスト画像。アセットが無い環境では SF Symbol にフォールバックする。
struct WeeklyLeagueCrest: View {
    let tier: WeeklyLeagueTier
    var size: CGFloat = 56

    private var theme: WeeklyLeagueTheme { .theme(for: tier) }

    var body: some View {
        Group {
            if UIImage(named: tier.assetName) != nil {
                Image(tier.assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: theme.fallbackSymbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(theme.accent)
                    .padding(size * 0.1)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct WeeklyLeagueProgressBar: View {
    let progress: Double
    let fill: AnyShapeStyle
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(WeeklyLeaguePalette.track)
                Capsule()
                    .fill(fill)
                    .frame(width: max(geo.size.width * min(max(progress, 0), 1), progress > 0.001 ? height : 0))
            }
        }
        .frame(height: height)
        .animation(.easeOut(duration: 0.45), value: progress)
        .accessibilityHidden(true)
    }
}

struct WeeklyLeagueStandingBadge: View {
    let standing: WeeklyLeagueStanding

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: standing.symbol)
                .font(.system(size: 10, weight: .heavy))
            Text(standing.title)
                .font(.caption2.weight(.heavy))
        }
        .foregroundColor(standing.tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(standing.tint.opacity(0.13)))
        .fixedSize()
    }
}

/// 「今日はまだ未挑戦」など、再訪の動機になる短い情報。
struct WeeklyLeagueChip: View {
    let symbol: String
    let text: String
    let tint: Color
    var emphasized = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: emphasized ? .heavy : .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(emphasized ? .white : tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule().fill(emphasized ? AnyShapeStyle(tint) : AnyShapeStyle(tint.opacity(0.12)))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - シーズン残り時間

struct WeeklyLeagueCountdown: View {
    let endsAt: Date?

    var body: some View {
        if let endsAt {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                let remaining = max(endsAt.timeIntervalSince(context.date), 0)
                let urgent = remaining < 24 * 60 * 60
                HStack(spacing: 5) {
                    Image(systemName: urgent ? "exclamationmark.triangle.fill" : "hourglass")
                        .font(.system(size: 11, weight: .bold))
                    Text("残り \(Self.remainingText(remaining))")
                        .font(.system(size: 12, weight: .heavy))
                        .monospacedDigit()
                }
                .foregroundColor(urgent ? WeeklyLeaguePalette.relegation : WeeklyLeaguePalette.secondaryText)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(urgent
                                   ? WeeklyLeaguePalette.relegation.opacity(0.13)
                                   : WeeklyLeaguePalette.track)
                )
                .accessibilityElement()
                .accessibilityLabel("シーズン終了まで残り\(Self.remainingText(remaining))。月曜日の4時に終了します。")
            }
        }
    }

    static func remainingText(_ remaining: TimeInterval) -> String {
        let total = Int(remaining)
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        if days > 0 { return "\(days)日 \(hours)時間" }
        if hours > 0 { return "\(hours)時間 \(minutes)分" }
        return "\(minutes)分"
    }
}

// MARK: - ヒーローカード（この画面で最も目立たせる領域）

struct WeeklyLeagueHeroCard: View {
    let snapshot: WeeklyLeagueSnapshot
    let rankDelta: Int?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: WeeklyLeagueTheme { .theme(for: snapshot.tier) }
    private var goal: WeeklyLeagueGoal { snapshot.goal }
    private var isStacked: Bool { dynamicTypeSize >= .accessibility1 }
    private var targetTier: WeeklyLeagueTier {
        snapshot.tier == .master ? .master : snapshot.tier.promoted
    }
    private var targetTheme: WeeklyLeagueTheme { .theme(for: targetTier) }

    var body: some View {
        VStack(spacing: 0) {
            // リーグの識別はベタ塗りではなく、上端の帯とリングで表す
            theme.strip.frame(height: 6)

            if snapshot.currentRank != nil {
                leagueOverview
                    .padding(18)
            }
        }
        .background(WeeklyLeaguePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(WeeklyLeaguePalette.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    /// 盾・現在順位・昇格目標を、ひと続きの情報として見せる。
    private var leagueOverview: some View {
        Group {
            if isStacked {
                VStack(alignment: .leading, spacing: 14) {
                    promotionCrest
                        .frame(maxWidth: .infinity)
                    leagueOverviewDetails
                }
            } else {
                HStack(alignment: .top, spacing: 16) {
                    promotionCrest
                    leagueOverviewDetails
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(leagueOverviewAccessibilityLabel)
    }

    private var promotionCrest: some View {
        ZStack {
            Circle()
                .fill(targetTheme.accent.opacity(0.13))
                .frame(width: 116, height: 116)
            Circle()
                .stroke(targetTheme.accent.opacity(0.36), lineWidth: 2)
                .frame(width: 116, height: 116)
            WeeklyLeagueCrest(tier: targetTier, size: 100)
                .shadow(color: targetTheme.accent.opacity(0.32), radius: 9, y: 4)
        }
        .frame(width: 116, height: 116)
    }

    private var leagueOverviewDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("現在")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
                Text("\(snapshot.currentRank ?? 0)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(snapshot.standing.rankColor)
                    .monospacedDigit()
                Text("位")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)

                Spacer(minLength: 4)
                WeeklyLeagueStandingBadge(standing: snapshot.standing)
            }

            HStack(spacing: 6) {
                Text("\(snapshot.currentScore)pt")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                    .monospacedDigit()
                if let rankDelta, rankDelta != 0 {
                    rankDeltaBadge(rankDelta)
                }
            }

            Spacer(minLength: 2)

            Text(primaryGoalHeadline)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            WeeklyLeagueProgressBar(
                progress: goal.progress,
                fill: AnyShapeStyle(goal.zone.gradient),
                height: 9
            )

            if let caption = goal.caption {
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                if let answers = goal.neededCorrectAnswers {
                    Label("正解\(answers)問目安", systemImage: "checkmark.circle.fill")
                        .foregroundColor(goal.zone.tint)
                }

                Spacer(minLength: 0)

                Label(
                    snapshot.tier == .master ? "500コイン" : "300コイン",
                    systemImage: "gift.fill"
                )
                .foregroundColor(WeeklyLeaguePalette.coin)
            }
            .font(.system(size: 11, weight: .heavy))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
        }
    }

    private var primaryGoalHeadline: String {
        guard snapshot.tier != .master,
              goal.zone == .promotion else { return goal.headline }
        if let neededPoints = goal.neededPoints {
            return "\(targetTier.displayName)昇格まであと\(neededPoints)pt"
        }
        return "\(targetTier.displayName)昇格圏をキープ中"
    }

    private var leagueOverviewAccessibilityLabel: String {
        var parts = [
            "現在\(snapshot.currentRank ?? 0)位",
            snapshot.standing.title,
            "\(snapshot.currentScore)ポイント",
            primaryGoalHeadline
        ]
        if let caption = goal.caption { parts.append(caption) }
        if let answers = goal.neededCorrectAnswers { parts.append("正解\(answers)問が目安") }
        return parts.joined(separator: "、")
    }

    private func rankDeltaBadge(_ delta: Int) -> some View {
        let improved = delta > 0
        return HStack(spacing: 2) {
            Image(systemName: improved ? "arrow.up" : "arrow.down")
                .font(.system(size: 9, weight: .black))
            Text("\(abs(delta))")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
        .foregroundColor(improved ? WeeklyLeaguePalette.promotion : WeeklyLeaguePalette.relegation)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule().fill((improved ? WeeklyLeaguePalette.promotion : WeeklyLeaguePalette.relegation).opacity(0.13))
        )
        .fixedSize()
        .accessibilityLabel(improved ? "前回から\(delta)つ上がりました" : "前回から\(abs(delta))つ下がりました")
    }
}

struct WeeklyLeagueZoneHeader: View {
    let zone: WeeklyLeagueZone
    let detail: String

    var body: some View {
        HStack(spacing: 8) {
            WeeklyLeagueChip(
                symbol: zone == .promotion ? "chevron.up" : (zone == .relegation ? "chevron.down" : "minus"),
                text: zone == .promotion ? "昇格圏" : (zone == .relegation ? "降格圏" : "キープ圏"),
                tint: zone.tint
            )
            Text(detail)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
            Rectangle()
                .fill(WeeklyLeaguePalette.hairline)
                .frame(height: 1)
        }
        .padding(.top, 2)
    }
}

// MARK: - 昇格ライン / 降格ライン

struct WeeklyLeagueBoundaryDivider: View {
    let zone: WeeklyLeagueZone
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(zone.tint.opacity(0.28))
                .frame(height: 1.5)

            HStack(spacing: 4) {
                Image(systemName: zone == .promotion ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .black))
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
            }
            .foregroundColor(zone.tint)
            .fixedSize()

            Rectangle()
                .fill(zone.tint.opacity(0.28))
                .frame(height: 1.5)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

// MARK: - メンバー行

struct WeeklyLeagueMemberRow: View {
    let member: WeeklyLeagueMember
    let rank: Int
    let zone: WeeklyLeagueZone
    let isCurrentUser: Bool
    let tier: WeeklyLeagueTier
    var onChallenge: (() -> Void)? = nil

    private var theme: WeeklyLeagueTheme { .theme(for: tier) }
    private var isPodium: Bool { rank <= 3 }

    @ViewBuilder
    var body: some View {
        if let onChallenge {
            Button {
                generateHapticFeedback()
                onChallenge()
            } label: {
                rowContent
            }
            .buttonStyle(WeeklyLeagueMemberRowButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("ダブルタップして対戦を申し込みます")
        } else {
            rowContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            rankBadge
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text(member.userName)
                    .font(.system(size: 15, weight: isCurrentUser ? .heavy : .semibold))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if isCurrentUser {
                    Text("あなた")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(theme.accent)
                } else if onChallenge != nil {
                    Label("このユーザーと対戦", systemImage: "flame.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(theme.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 6)

            Text("\(member.score)pt")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(isCurrentUser ? WeeklyLeaguePalette.primaryText : WeeklyLeaguePalette.secondaryText)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize()

            if onChallenge != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.accent)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isCurrentUser ? theme.accent.opacity(0.10) : WeeklyLeaguePalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isCurrentUser ? theme.accent.opacity(0.55) : WeeklyLeaguePalette.hairline,
                        lineWidth: isCurrentUser ? 1.5 : 1)
        )
        // ゾーンは行の先頭に細い線でだけ示し、色数を抑える
        .overlay(alignment: .leading) {
            if zone != .safe {
                Capsule()
                    .fill(zone.tint)
                    .frame(width: 3)
                    .padding(.vertical, 12)
                .padding(.leading, 1)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var accessibilityLabel: String {
        var parts = ["\(rank)位", member.userName, "\(member.score)ポイント"]
        if zone == .promotion { parts.append("昇格圏") }
        if zone == .relegation { parts.append("降格圏") }
        if isCurrentUser { parts.append("あなた") }
        if onChallenge != nil { parts.append("(member.userName)と対戦") }
        return parts.joined(separator: "、")
    }

    /// 上位3人のみメダル色。フラットな単色にして装飾を抑える。
    private var rankBadge: some View {
        ZStack(alignment: .top) {
            ZStack {
                Circle()
                    .fill(isPodium ? podiumColor.opacity(0.16) : WeeklyLeaguePalette.track)
                Circle()
                    .stroke(isPodium ? podiumColor.opacity(0.55) : .clear, lineWidth: 1.5)
                Text("\(rank)")
                    .font(.system(size: rank >= 100 ? 13 : 16, weight: .heavy, design: .rounded))
                    .foregroundColor(isPodium ? podiumColor : WeeklyLeaguePalette.secondaryText)
                    .monospacedDigit()
            }
            .frame(width: 36, height: 36)

            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(WeeklyLeaguePalette.coin)
                    .offset(y: -8)
            }
        }
        .frame(width: 36, height: 36)
        .padding(.top, rank == 1 ? 6 : 0)
    }

    private var podiumColor: Color {
        switch rank {
        case 1: return WeeklyLeaguePalette.coin
        case 2: return WeeklyLeaguePalette.adaptive(light: "7C8899", dark: "B5C1D0")
        default: return WeeklyLeaguePalette.adaptive(light: "AF6B33", dark: "D08A52")
        }
    }

    private var avatar: some View {
        Group {
            if UIImage(named: member.avatarName) != nil {
                Image(member.avatarName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(WeeklyLeaguePalette.neutral)
            }
        }
        .frame(width: 38, height: 38)
        .clipShape(Circle())
        .overlay(
            Circle().strokeBorder(
                isPodium ? podiumColor.opacity(0.6) : WeeklyLeaguePalette.hairline,
                lineWidth: isPodium ? 2 : 1
            )
        )
        .accessibilityHidden(true)
    }
}

private struct WeeklyLeagueMemberRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - 自分が画面外にいるときの固定ステータスバー

struct WeeklyLeagueStickyStatusBar: View {
    let snapshot: WeeklyLeagueSnapshot
    let tapped: () -> Void

    var body: some View {
        Button(action: tapped) {
            HStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(snapshot.currentRank ?? 0)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                    Text("位")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(WeeklyLeaguePalette.inverseText)
                .fixedSize()

                Rectangle()
                    .fill(WeeklyLeaguePalette.inverseText.opacity(0.2))
                    .frame(width: 1, height: 22)

                Text(compactGoalTitle)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(WeeklyLeaguePalette.inverseText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(WeeklyLeaguePalette.inverseText.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(WeeklyLeaguePalette.inverseSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityLabel("あなたは\(snapshot.currentRank ?? 0)位、\(snapshot.currentScore)ポイント。\(snapshot.goal.headline)")
        .accessibilityHint("タップすると自分の順位まで移動します")
    }

    private var compactGoalTitle: String {
        let goal = snapshot.goal
        guard snapshot.tier != .master,
              goal.zone == .promotion else {
            return goal.headline.replacingOccurrences(of: " ", with: "")
        }
        if let neededPoints = goal.neededPoints {
            return "\(snapshot.tier.promoted.displayName)昇格まで\(neededPoints)pt"
        }
        return "\(snapshot.tier.promoted.displayName)昇格圏をキープ中"
    }
}

// MARK: - 未参加 / エラー / 読み込み中

/// 未参加のときは1枚のカードにまとめる。紋章を2回出さない。
struct WeeklyLeagueJoinCard: View {
    let tier: WeeklyLeagueTier
    let season: WeeklyLeagueSeason?
    let showRules: () -> Void

    private var theme: WeeklyLeagueTheme { .theme(for: tier) }

    var body: some View {
        VStack(spacing: 0) {
            theme.strip.frame(height: 6)

            VStack(spacing: 14) {
                WeeklyLeagueCrest(tier: tier, size: 84)
                    .padding(10)
                    .background(Circle().fill(theme.accent.opacity(0.12)))
                    .padding(.top, 8)

                Text("\(tier.displayName)リーグに参加しよう")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                    .multilineTextAlignment(.center)

                Text("問題を1問解くと、同じリーグの\n最大25人と自動でマッチングします。")
                    .font(.system(size: 14))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                WeeklyLeagueCountdown(endsAt: season?.endsAt)

                HStack(spacing: 8) {
                    pointChip("正解", value: "+\(WeeklyLeaguePointRules.correctAnswer)pt")
                    pointChip("不正解", value: "+\(WeeklyLeaguePointRules.incorrectAnswer)pt")
                    pointChip("完了", value: "+\(WeeklyLeaguePointRules.quizCompletion)pt")
                }
                .padding(.top, 2)

                Button(action: showRules) {
                    Text("リーグのルールを見る")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.top, 2)
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(maxWidth: .infinity)
        .background(WeeklyLeaguePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(WeeklyLeaguePalette.hairline, lineWidth: 1)
        )
    }

    private func pointChip(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
            Text(value)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.promotion)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(WeeklyLeaguePalette.surfaceSunken))
    }
}

struct WeeklyLeagueErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 42))
                .foregroundColor(WeeklyLeaguePalette.relegationAlt)
            Text("リーグを読み込めませんでした")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
            Text(message)
                .font(.footnote)
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: retry) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("もう一度読み込む")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(Capsule().fill(WeeklyLeagueZone.promotion.gradient))
            }
            .padding(.top, 4)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 読み込み中は最終レイアウトと同じ骨格を見せて、表示位置のブレをなくす。
struct WeeklyLeagueSkeletonView: View {
    var body: some View {
        VStack(spacing: 14) {
            WeeklyLeagueSkeletonBlock(cornerRadius: 22, height: 210)

            ForEach(0..<6, id: \.self) { _ in
                WeeklyLeagueSkeletonBlock(cornerRadius: 14, height: 62)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .accessibilityElement()
        .accessibilityLabel("リーグを読み込んでいます")
    }
}

/// 骨格の濃さは固定し、細い光だけを左から右へ流す。
/// 「視差効果を減らす」が有効な場合はアニメーションせず静止表示にする。
private struct WeeklyLeagueSkeletonBlock: View {
    let cornerRadius: CGFloat
    let height: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmerPosition: CGFloat = -1

    var body: some View {
        GeometryReader { geometry in
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            let bandWidth = max(72, geometry.size.width * 0.24)

            shape
                .fill(WeeklyLeaguePalette.skeleton)
                .overlay {
                    if !reduceMotion {
                        LinearGradient(
                            colors: [
                                .white.opacity(0),
                                .white.opacity(0.42),
                                .white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: bandWidth)
                        .rotationEffect(.degrees(8))
                        .offset(x: shimmerPosition * (geometry.size.width + bandWidth))
                        .mask(shape)
                    }
                }
        }
        .frame(height: height)
        .onAppear {
            guard !reduceMotion else { return }
            shimmerPosition = -1
            withAnimation(.linear(duration: 1.35).repeatForever(autoreverses: false)) {
                shimmerPosition = 1
            }
        }
    }
}

// MARK: - シート

private enum WeeklyLeagueSheet: Identifiable {
    case rules(WeeklyLeagueTier)
    case result(WeeklyLeagueResult)

    var id: String {
        switch self {
        case .rules: return "rules"
        case .result(let result): return "result-\(result.seasonId)"
        }
    }
}

struct WeeklyLeagueRulesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let currentTier: WeeklyLeagueTier
    var season: WeeklyLeagueSeason?


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    tierLadderCard
                    zoneDiagramCard
                    pointsCard
                    bonusPointsCard
                    rewardCard
                    scheduleCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(WeeklyLeaguePalette.canvas.ignoresSafeArea())
            .navigationTitle("週間リーグのルール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }

    // MARK: - カードの共通の器

    private func card<Content: View>(
        icon: String,
        title: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(accent)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(accent.opacity(0.13)))
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                Spacer(minLength: 0)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WeeklyLeaguePalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WeeklyLeaguePalette.hairline, lineWidth: 1)
        )
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(WeeklyLeaguePalette.secondaryText)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - リーグの階段

    private var tierLadderCard: some View {
        card(icon: "arrow.up.right", title: "リーグの階段", accent: WeeklyLeagueTheme.theme(for: currentTier).accent) {
            VStack(spacing: 10) {
                HStack(spacing: 2) {
                    ForEach(Array(WeeklyLeagueTier.allCases.enumerated()), id: \.element) { index, tier in
                        if index > 0 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(WeeklyLeaguePalette.secondaryText.opacity(0.6))
                        }
                        tierStep(tier)
                    }
                }
                note("上位に入ると1つ上のリーグへ進みます。ブロンズからの降格はありません。")
            }
        }
    }

    private func tierStep(_ tier: WeeklyLeagueTier) -> some View {
        let isCurrent = tier == currentTier
        let theme = WeeklyLeagueTheme.theme(for: tier)
        return VStack(spacing: 5) {
            WeeklyLeagueCrest(tier: tier, size: 40)
                .padding(4)
                .background(Circle().fill(isCurrent ? theme.accent.opacity(0.14) : Color.clear))
                .overlay(
                    Circle().stroke(isCurrent ? theme.accent : Color.clear, lineWidth: 2)
                )
                .opacity(isCurrent ? 1 : 0.42)

            Text(tier.displayName)
                .font(.system(size: 10, weight: isCurrent ? .heavy : .medium))
                .foregroundColor(isCurrent ? WeeklyLeaguePalette.primaryText : WeeklyLeaguePalette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(isCurrent ? "現在" : " ")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(theme.accent)
                .opacity(isCurrent ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isCurrent ? "\(tier.displayName)リーグ、現在のリーグ" : "\(tier.displayName)リーグ")
    }

    // MARK: - 昇格・降格の図解

    /// 文章だけでは伝わりにくい仕組みを、25人リーグの帯で示す。
    private var zoneDiagramCard: some View {
        card(icon: "chart.bar.fill", title: "昇格と降格", accent: WeeklyLeaguePalette.promotion) {
            VStack(spacing: 8) {
                zoneRow(
                    range: "1〜5位",
                    label: "昇格",
                    detail: "1つ上のリーグへ",
                    tint: WeeklyLeaguePalette.promotion,
                    symbol: "arrow.up.right"
                )
                zoneRow(
                    range: "6〜20位",
                    label: "残留",
                    detail: "同じリーグを継続",
                    tint: WeeklyLeaguePalette.neutral,
                    symbol: "minus"
                )
                zoneRow(
                    range: "21〜25位",
                    label: "降格",
                    detail: "1つ下のリーグへ",
                    tint: WeeklyLeaguePalette.relegation,
                    symbol: "arrow.down.right"
                )
                note("25人リーグの場合です。参加人数が少ないときは枠が調整され、2人に満たないうちは昇格・降格が起きません。")
            }
        }
    }

    private func zoneRow(range: String, label: String, detail: String, tint: Color, symbol: String) -> some View {
        HStack(spacing: 11) {
            Capsule()
                .fill(tint)
                .frame(width: 4)

            Text(range)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 74, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .black))
                Text(label)
                    .font(.system(size: 11, weight: .heavy))
            }
            .foregroundColor(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(tint.opacity(0.13)))
            .fixedSize()

            Text(detail)
                .font(.system(size: 11))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.06))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(range)は\(label)。\(detail)")
    }

    // MARK: - ポイント

    private var pointsCard: some View {
        card(icon: "plus.circle.fill", title: "ポイントの稼ぎ方", accent: WeeklyLeaguePalette.promotionAlt) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    pointTile("正解", value: "+\(WeeklyLeaguePointRules.correctAnswer)", symbol: "checkmark", tint: WeeklyLeaguePalette.promotion)
                    pointTile("不正解", value: "+\(WeeklyLeaguePointRules.incorrectAnswer)", symbol: "xmark", tint: WeeklyLeaguePalette.secondaryText)
                    pointTile("クイズ完了", value: "+\(WeeklyLeaguePointRules.quizCompletion)", symbol: "flag.fill", tint: WeeklyLeaguePalette.promotionAlt)
                }
                note("ポイントはクイズを1回終えるごとにまとめて加算されます。途中でやめた分は入りません。")
            }
        }
    }

    private func pointTile(_ title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(tint)
            Text(value + "pt")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .monospacedDigit()
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WeeklyLeaguePalette.surfaceSunken)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)で\(value)ポイント")
    }

    // MARK: - 追加ボーナス

    private var bonusPointsCard: some View {
        card(icon: "sparkles", title: "追加ボーナス", accent: WeeklyLeaguePalette.coin) {
            VStack(spacing: 0) {
                bonusRow(
                    title: "正答率ボーナス",
                    detail: "80% / 90% / 全問正解",
                    value: "+10 / +20 / +40pt",
                    symbol: "scope",
                    tint: WeeklyLeaguePalette.promotion
                )
                Divider().overlay(WeeklyLeaguePalette.hairline)
                bonusRow(
                    title: "コンボボーナス",
                    detail: "3 / 5 / 10問連続正解",
                    value: "+5 / +10 / +20pt",
                    symbol: "flame.fill",
                    tint: WeeklyLeaguePalette.relegation
                )
                Divider().overlay(WeeklyLeaguePalette.hairline)
                bonusRow(
                    title: "今日の初回クイズ",
                    detail: "その日最初のクイズ完了",
                    value: "+\(WeeklyLeaguePointRules.firstQuizOfDay)pt",
                    symbol: "sun.max.fill",
                    tint: WeeklyLeaguePalette.coin
                )
                Divider().overlay(WeeklyLeaguePalette.hairline)
                bonusRow(
                    title: "継続学習ボーナス",
                    detail: "2日目から5ptずつ増加",
                    value: "+5〜+30pt",
                    symbol: "calendar.badge.checkmark",
                    tint: WeeklyLeaguePalette.promotionAlt
                )
                Divider().overlay(WeeklyLeaguePalette.hairline)
                bonusRow(
                    title: "復習克服ボーナス",
                    detail: "苦手問題を復習で正解",
                    value: "1問 +\(WeeklyLeaguePointRules.reviewAnswer)pt",
                    symbol: "arrow.counterclockwise.circle.fill",
                    tint: WeeklyLeaguePalette.promotion
                )
                Divider().overlay(WeeklyLeaguePalette.hairline)
                bonusRow(
                    title: "チャレンジクリア",
                    detail: "時間制・上級・ゴッドをクリア",
                    value: "+\(WeeklyLeaguePointRules.challengeClear)pt",
                    symbol: "bolt.fill",
                    tint: WeeklyLeaguePalette.relegation
                )
            }
            note("正答率とコンボは達成した一番高い段階だけ加算され、両方を同時に獲得できます。正答率ボーナスは5問以上のクイズが対象です。")
            note("初回クイズ・継続学習・チャレンジは日本時間で1日1回。復習克服は1日最大\(WeeklyLeaguePointRules.maximumDailyReviewBonus)ptです。")
        }
    }

    private func bonusRow(
        title: String,
        detail: String,
        value: String,
        symbol: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 6)

            Text(value)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(tint)
                .multilineTextAlignment(.trailing)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)。\(detail)。\(value)")
    }

    // MARK: - 報酬

    private var rewardCard: some View {
        card(icon: "bitcoinsign.circle.fill", title: "シーズン報酬", accent: WeeklyLeaguePalette.coin) {
            VStack(spacing: 0) {
                rewardRow("マスターリーグ 3位以内", coins: 500, highlighted: true)
                Divider().overlay(WeeklyLeaguePalette.hairline)
                rewardRow("昇格", coins: 300)
                Divider().overlay(WeeklyLeaguePalette.hairline)
                rewardRow("残留", coins: 100)
                Divider().overlay(WeeklyLeaguePalette.hairline)
                rewardRow("降格", coins: 50)
            }
            note("シーズン終了後、次にリーグ画面を開いたときに受け取れます。1ポイントも獲得していない場合、残留の報酬はありません。")
        }
    }

    private func rewardRow(_ title: String, coins: Int, highlighted: Bool = false) -> some View {
        HStack {
            if highlighted {
                Image(systemName: "crown.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(WeeklyLeaguePalette.coin)
            }
            Text(title)
                .font(.system(size: 13, weight: highlighted ? .heavy : .medium))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 8)
            Text("\(coins)")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.coin)
                .monospacedDigit()
            Text("コイン")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)で\(coins)コイン")
    }

    // MARK: - 開催期間

    private var scheduleCard: some View {
        card(icon: "calendar", title: "開催期間", accent: WeeklyLeaguePalette.promotionAlt) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("毎週 月曜 4:00")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(WeeklyLeaguePalette.primaryText)
                    Text("にリセット")
                        .font(.system(size: 12))
                        .foregroundColor(WeeklyLeaguePalette.secondaryText)
                    Spacer(minLength: 0)
                }
                if season != nil {
                    WeeklyLeagueCountdown(endsAt: season?.endsAt)
                }
                note("リセット時にその週の順位が確定し、昇格・降格と報酬が決まります。")
            }
        }
    }

}

/// シーズン結果。昇格 / 残留 / 降格で色と言葉を変え、報酬の受け取り前後も出し分ける。
struct WeeklyLeagueResultSheet: View {
    @Environment(\.dismiss) private var dismiss

    let result: WeeklyLeagueResult
    let isClaiming: Bool
    let onClaim: (WeeklyLeagueResult, @escaping (Bool) -> Void) -> Void

    @State private var hasClaimed = false
    @State private var appeared = false
    @State private var claimErrorMessage: String?

    private var theme: WeeklyLeagueTheme { .theme(for: result.nextTier) }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 168, height: 168)
                    .scaleEffect(appeared ? 1 : 0.8)

                WeeklyLeagueCrest(tier: result.nextTier, size: 118)
                    .scaleEffect(appeared ? 1 : 0.7)

                Image(systemName: movementSymbol)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(accentColor))
                    .shadow(color: accentColor.opacity(0.35), radius: 6, x: 0, y: 3)
                    .offset(x: 58, y: 50)
                    .opacity(appeared ? 1 : 0)
            }
            .padding(.bottom, 18)

            Text(resultTitle)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(result.tier.displayName)リーグ 最終\(result.rank)位")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .padding(.top, 6)

            Text("\(result.score)pt")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(accentColor)
                .monospacedDigit()
                .padding(.top, 8)

            if result.rewardCoins > 0 {
                rewardChip
                    .padding(.top, 16)
            }

            if let claimErrorMessage {
                Text(claimErrorMessage)
                    .font(.footnote)
                    .foregroundColor(WeeklyLeaguePalette.relegation)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
            }

            Spacer(minLength: 16)

            actionButton
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(WeeklyLeaguePalette.canvas.ignoresSafeArea())
        .presentationDetents([.large])
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { appeared = true }
        }
    }

    private var rewardChip: some View {
        HStack(spacing: 9) {
            Image(systemName: hasClaimed ? "checkmark.circle.fill" : "bitcoinsign.circle.fill")
                .font(.system(size: 19))
                .foregroundColor(hasClaimed ? WeeklyLeaguePalette.promotion : WeeklyLeaguePalette.coin)
            Text(hasClaimed ? "\(result.rewardCoins)コインを受け取りました" : "\(result.rewardCoins)コイン")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule().fill((hasClaimed ? WeeklyLeaguePalette.promotion : WeeklyLeaguePalette.coin).opacity(0.12))
        )
        .animation(.easeInOut(duration: 0.25), value: hasClaimed)
    }

    private var actionButton: some View {
        Button {
            guard !hasClaimed else {
                dismiss()
                return
            }
            claimErrorMessage = nil
            onClaim(result) { success in
                guard success else {
                    claimErrorMessage = "報酬を受け取れませんでした。通信環境を確認して、もう一度お試しください。"
                    return
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { hasClaimed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { dismiss() }
            }
        } label: {
            Group {
                if isClaiming {
                    ProgressView().tint(.white)
                } else {
                    Text(buttonTitle)
                        .font(.system(size: 17, weight: .heavy))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(hasClaimed ? WeeklyLeaguePalette.promotion : accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(isClaiming)
        .shadow(color: accentColor.opacity(0.25), radius: 10, x: 0, y: 5)
    }

    private var buttonTitle: String {
        if hasClaimed { return "閉じる" }
        return result.rewardCoins > 0 ? "報酬を受け取る" : "次のリーグへ"
    }

    private var resultTitle: String {
        switch result.movement {
        case .promoted:
            return "\(result.nextTier.displayName)リーグへ昇格！"
        case .stayed:
            if result.tier == .master, result.rank <= 3 { return "マスターリーグ トップ3！" }
            return "\(result.nextTier.displayName)リーグに残留！"
        case .relegated:
            return "\(result.nextTier.displayName)リーグから再挑戦"
        }
    }

    private var movementSymbol: String {
        switch result.movement {
        case .promoted: return "arrow.up"
        case .stayed: return "checkmark"
        case .relegated: return "arrow.down"
        }
    }

    private var accentColor: Color {
        switch result.movement {
        case .promoted: return WeeklyLeaguePalette.promotion
        case .stayed: return theme.accent
        case .relegated: return WeeklyLeaguePalette.relegation
        }
    }
}

// MARK: - ランキング本体（データに依存しない表示部）

private struct WeeklyLeagueRowFrameKey: PreferenceKey {
    static let defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

private struct WeeklyLeagueHeroFrameKey: PreferenceKey {
    static let defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

struct WeeklyLeagueBoard: View {
    let snapshot: WeeklyLeagueSnapshot
    let isJoined: Bool
    let rankDelta: Int?
    let inlineErrorMessage: String?
    let showRules: () -> Void
    let reload: () -> Void
    var onChallenge: ((WeeklyLeagueMember) -> Void)? = nil
    var pendingInvitationCount: Int = 0
    var onOpenInvitations: (() -> Void)? = nil

    // LazyVStack は画面外の行を破棄するため、frame が届かない = 自分の行は見えていない。
    @State private var isCurrentUserVisible = false
    @State private var isHeroVisible = true

    private static let scrollSpace = "weeklyLeagueScroll"

    var body: some View {
        GeometryReader { outer in
            let viewportHeight = outer.size.height

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        // 未参加のときはヒーローを出さない。参加カードが同じ情報
                        // （リーグ名・紋章・残り時間）を持っており、二重になるため。
                        if isJoined {
                            WeeklyLeagueHeroCard(
                                snapshot: snapshot,
                                rankDelta: rankDelta
                            )
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: WeeklyLeagueHeroFrameKey.self,
                                        value: geo.frame(in: .named(Self.scrollSpace))
                                    )
                                }
                            )
                            if pendingInvitationCount > 0, let onOpenInvitations {
                                invitationBanner(count: pendingInvitationCount, action: onOpenInvitations)
                            }
                            memberList
                            rulesLink
                        } else {
                            WeeklyLeagueJoinCard(
                                tier: snapshot.tier,
                                season: snapshot.season,
                                showRules: showRules
                            )
                        }

                        if let inlineErrorMessage {
                            Text(inlineErrorMessage)
                                .font(.footnote)
                                .foregroundColor(WeeklyLeaguePalette.relegation)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    // 固定バーの表示状態では下余白を変えない。変えると再レイアウト→
                    // 可視判定の反転→再レイアウト、と往復してしまう。
                    .padding(.bottom, reservesStickyBarSpace ? 96 : 24)
                }
                .coordinateSpace(name: Self.scrollSpace)
                .refreshable { reload() }
                .onPreferenceChange(WeeklyLeagueRowFrameKey.self) { rect in
                    updateVisibility(rect, viewportHeight: viewportHeight)
                }
                .onPreferenceChange(WeeklyLeagueHeroFrameKey.self) { rect in
                    updateHeroVisibility(rect, viewportHeight: viewportHeight)
                }
                .overlay(alignment: .bottom) {
                    if showsStickyBar, let currentUserId = snapshot.currentUserId {
                        WeeklyLeagueStickyStatusBar(snapshot: snapshot) {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                proxy.scrollTo(currentUserId, anchor: .center)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
    }

    private var reservesStickyBarSpace: Bool {
        isJoined && snapshot.currentRank != nil
    }

    private var showsStickyBar: Bool {
        reservesStickyBarSpace && !isHeroVisible && !isCurrentUserVisible
    }

    private func updateVisibility(_ rect: CGRect?, viewportHeight: CGFloat) {
        // 固定バーが載る下端 88pt は「見えている」扱いにしない。
        let visible: Bool
        if let rect {
            visible = rect.maxY > 0 && rect.minY < viewportHeight - 88
        } else {
            visible = false
        }
        guard visible != isCurrentUserVisible else { return }
        withAnimation(.easeInOut(duration: 0.22)) { isCurrentUserVisible = visible }
    }

    private func updateHeroVisibility(_ rect: CGRect?, viewportHeight: CGFloat) {
        let visible = rect.map { $0.maxY > 0 && $0.minY < viewportHeight } ?? false
        guard visible != isHeroVisible else { return }
        withAnimation(.easeInOut(duration: 0.22)) { isHeroVisible = visible }
    }

    private func invitationBanner(count: Int, action: @escaping () -> Void) -> some View {
        SocialInlineBanner(
            icon: "bolt.fill",
            title: "\(count)件の対戦がきみの番です",
            message: "先に回答すると相手を待たせません。",
            tone: .theme(.battle),
            actionTitle: "今すぐ回答する",
            action: action
        )
    }

    private var memberList: some View {
        LazyVStack(spacing: 8) {
            ForEach(Array(snapshot.members.enumerated()), id: \.element.id) { index, member in
                let rank = index + 1

                if rank == 1, let promotionLine = snapshot.promotionLine {
                    WeeklyLeagueZoneHeader(
                        zone: .promotion,
                        detail: "上位\(promotionLine)人が\(nextTierName)へ"
                    )
                }
                if let line = snapshot.promotionLine, rank == line + 1 {
                    WeeklyLeagueZoneHeader(
                        zone: .safe,
                        detail: "\(rank)〜\((snapshot.relegationLine ?? snapshot.memberCount + 1) - 1)位は\(snapshot.tier.displayName)残留"
                    )
                }
                if let line = snapshot.relegationLine, rank == line {
                    WeeklyLeagueZoneHeader(
                        zone: .relegation,
                        detail: "下位\(snapshot.memberCount - line + 1)人が\(previousTierName)へ"
                    )
                }

                let isCurrentUser = member.id == snapshot.currentUserId
                WeeklyLeagueMemberRow(
                    member: member,
                    rank: rank,
                    zone: snapshot.zone(for: rank),
                    isCurrentUser: isCurrentUser,
                    tier: snapshot.tier,
                    onChallenge: (isCurrentUser || onChallenge == nil) ? nil : { onChallenge?(member) }
                )
                .id(member.id)
                .background(
                    Group {
                        if isCurrentUser {
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: WeeklyLeagueRowFrameKey.self,
                                    value: geo.frame(in: .named(Self.scrollSpace))
                                )
                            }
                        }
                    }
                )
            }
        }
    }

    private var nextTierName: String {
        switch snapshot.tier {
        case .bronze: return "シルバー"
        case .silver: return "ゴールド"
        case .gold: return "マスター"
        case .master: return "マスター"
        }
    }

    private var previousTierName: String {
        switch snapshot.tier {
        case .bronze: return "ブロンズ"
        case .silver: return "ブロンズ"
        case .gold: return "シルバー"
        case .master: return "ゴールド"
        }
    }

    private var rulesLink: some View {
        Button(action: showRules) {
            HStack(spacing: 6) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 12))
                Text("リーグのルールを見る")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(WeeklyLeaguePalette.promotionAlt)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(WeeklyLeaguePalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(WeeklyLeaguePalette.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
}

// MARK: - 対戦前の確認

private struct WeeklyLeagueChallengePreparationSheet: View {
    let opponent: WeeklyLeagueMember
    let opponentRank: Int
    let currentMember: WeeklyLeagueMember?
    let currentRank: Int?
    let tier: WeeklyLeagueTier
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var theme: WeeklyLeagueTheme { .theme(for: tier) }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    introduction
                    matchupCard
                    rulesCard
                    pointsCard
                    actionArea
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(WeeklyLeaguePalette.canvas.ignoresSafeArea())
            .navigationTitle("リーグ対戦")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var introduction: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [WeeklyLeaguePalette.relegationAlt, WeeklyLeaguePalette.flame],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("この相手に挑戦しますか？")
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
            Text("3試験からランダムに5問出題します")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var matchupCard: some View {
        HStack(alignment: .center, spacing: 8) {
            playerSummary(
                title: "あなた",
                member: currentMember,
                rank: currentRank,
                isOpponent: false
            )

            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(theme.strip)
                        .frame(width: 46, height: 46)
                    Text("VS")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("5問勝負")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
            }
            .accessibilityHidden(true)

            playerSummary(
                title: "対戦相手",
                member: opponent,
                rank: opponentRank,
                isOpponent: true
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(WeeklyLeaguePalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.accent.opacity(0.32), lineWidth: 1)
        )
    }

    private func playerSummary(
        title: String,
        member: WeeklyLeagueMember?,
        rank: Int?,
        isOpponent: Bool
    ) -> some View {
        VStack(spacing: 7) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isOpponent ? WeeklyLeaguePalette.flame : theme.accent)

            avatar(member?.avatarName)

            Text(member?.userName ?? "あなた")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 4) {
                if let rank {
                    Text("\(rank)位")
                }
                Text("\(member?.score ?? 0)pt")
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(WeeklyLeaguePalette.secondaryText)
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func avatar(_ imageName: String?) -> some View {
        Group {
            if let imageName, UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(WeeklyLeaguePalette.neutral)
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(Circle())
        .overlay(Circle().stroke(theme.accent.opacity(0.4), lineWidth: 2))
        .accessibilityHidden(true)
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("対戦ルール", systemImage: "list.bullet.clipboard.fill")
                .font(.system(size: 15, weight: .heavy))
                .foregroundColor(WeeklyLeaguePalette.primaryText)

            ruleRow(icon: "5.circle.fill", text: "ITパス・基本情報・応用情報から5問出題")
            ruleRow(icon: "person.fill", text: "あなたが先に問題へ挑戦")
            ruleRow(icon: "person.2.fill", text: "相手の回答後に勝敗が決定")
            ruleRow(icon: "timer", text: "正解数が同じ場合は回答タイムで判定")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WeeklyLeaguePalette.surface)
        )
    }

    private func ruleRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.accent)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(WeeklyLeaguePalette.primaryText)
            Spacer(minLength: 0)
        }
    }

    private var pointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("獲得リーグポイント", systemImage: "star.circle.fill")
                .font(.system(size: 15, weight: .heavy))
                .foregroundColor(WeeklyLeaguePalette.primaryText)

            HStack(spacing: 8) {
                pointResult("勝利", points: 15, tint: WeeklyLeaguePalette.promotion)
                pointResult("引き分け", points: 5, tint: WeeklyLeaguePalette.coin)
                pointResult("敗北", points: 0, tint: WeeklyLeaguePalette.neutral)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WeeklyLeaguePalette.surface)
        )
    }

    private func pointResult(_ title: String, points: Int, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
            Text("+\(points)pt")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(tint)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(tint.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var actionArea: some View {
        VStack(spacing: 10) {
            Button {
                generateHapticFeedback()
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onContinue()
                }
            } label: {
                Label("この相手に対戦を申し込む", systemImage: "flame.fill")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [WeeklyLeaguePalette.relegationAlt, WeeklyLeaguePalette.flame],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)

            Button("キャンセル") { dismiss() }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(WeeklyLeaguePalette.secondaryText)
                .padding(.vertical, 6)
        }
    }
}

// MARK: - 画面本体

private struct WeeklyLeagueNavigationHeader: View {
    let snapshot: WeeklyLeagueSnapshot

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        let theme = WeeklyLeagueTheme.theme(for: snapshot.tier)
        return HStack(spacing: 10) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.accent)
                    .frame(width: 24, height: 44)
            }
            .buttonStyle(.plain)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.strip)
                    .frame(width: 34, height: 34)
                Image(systemName: theme.fallbackSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("週間リーグ")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(WeeklyLeaguePalette.primaryText)
                Text("\(snapshot.tier.displayName)リーグ")
                    .font(.system(size: 11))
                    .foregroundColor(WeeklyLeaguePalette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            Spacer(minLength: 4)
            WeeklyLeagueCountdown(endsAt: snapshot.season?.endsAt)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator).opacity(0.32))
                .frame(height: 0.5)
        }
    }
}

enum WeeklyLeagueNotificationLaunch: Equatable {
    case invitations
    case battleResult(String)
    case leagueResult
}

/// ランキングで選んだユーザーと、その時点の順位を対戦開始まで同じ値として保持する。
private struct WeeklyLeagueChallengeTarget: Identifiable {
    let member: WeeklyLeagueMember
    let rank: Int

    var id: String { member.id }
}

struct WeeklyLeagueView: View {
    let notificationLaunch: WeeklyLeagueNotificationLaunch?
    @StateObject private var viewModel = WeeklyLeagueViewModel()
    @ObservedObject private var battleManager = BattleManager.shared
    @State private var presentedSheet: WeeklyLeagueSheet?
    @State private var rankDelta: Int?
    @State private var didCaptureBaseline = false
    @State private var challengeTarget: WeeklyLeagueChallengeTarget?
    @State private var battlePlaySession: BattlePlaySession?
    @State private var battleResult: BattleSummary?
    @State private var isPresentingInvitations = false
    @State private var didHandleNotificationLaunch = false

    init(notificationLaunch: WeeklyLeagueNotificationLaunch? = nil) {
        self.notificationLaunch = notificationLaunch
    }


    private var isParticipating: Bool { viewModel.isJoined }

    var body: some View {
        ZStack {
            Image("WeeklyLeagueBackground")
                .resizable()
                .scaledToFill()
                .overlay(Color(.systemBackground).opacity(0.36))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                WeeklyLeagueNavigationHeader(
                    snapshot: viewModel.snapshot
                )
                content
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
            }
        }
        .navigationBarHidden(true)
        .interactiveSwipeBackEnabled()
        .onAppear {
            viewModel.load()
            captureBaselineIfNeeded()
            restoreBattleIfNeeded()
            battleManager.fetchMyBattles {
                handleNotificationLaunchIfNeeded()
            }
        }
        .onDisappear {
            viewModel.stopObserving()
            recordCurrentRank()
        }
        .onChange(of: viewModel.snapshot.currentRank) { _ in
            captureBaselineIfNeeded()
        }
        .onChange(of: viewModel.pendingResult?.id) { _ in
            guard let result = viewModel.pendingResult else { return }
            presentedSheet = .result(result)
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .rules(let tier):
                WeeklyLeagueRulesSheet(currentTier: tier, season: viewModel.season)
            case .result(let result):
                WeeklyLeagueResultSheet(
                    result: result,
                    isClaiming: viewModel.isClaimingReward
                ) { target, completion in
                    viewModel.claim(target, completion: completion)
                }
            }
        }
        .sheet(item: $challengeTarget) { target in
            let snapshot = viewModel.snapshot
            BattleChallengeSheet(
                friend: FriendSummary(leagueMember: target.member),
                myName: snapshot.currentMember?.userName ?? "あなた",
                myAvatarName: snapshot.currentMember?.avatarName,
                myRank: snapshot.currentRank,
                opponentRank: target.rank
            ) { session in
                challengeTarget = nil
                battlePlaySession = session
            }
        }
        .fullScreenCover(item: $battlePlaySession) { session in
            BattlePlayView(session: session) { summary in
                battlePlaySession = nil
                if let summary {
                    battleResult = summary
                }
            }
        }
        .sheet(item: $battleResult) { summary in
            BattleResultView(summary: summary) {
                battleResult = nil
                viewModel.load()
            }
        }
        .sheet(isPresented: $isPresentingInvitations) {
            BattleInvitationsSheet(
                battles: battleManager.incomingBattles,
                onAccept: { battle in
                    isPresentingInvitations = false
                    battlePlaySession = BattlePlaySession(
                        battleId: battle.id,
                        questions: battle.questions,
                        role: .opponent,
                        player: battle.opponent ?? BattlePlayerInfo(
                            uid: AuthManager.shared.currentUserId ?? "",
                            name: "あなた",
                            avatarName: nil,
                            answers: []
                        ),
                        opponent: battle.challenger,
                        category: BattleCategory(rawValue: battle.category)?.displayName ?? battle.category
                    )
                },
                onDecline: { battle in
                    battleManager.declineIncomingBattle(battleId: battle.id) { _ in
                        battleManager.fetchMyBattles()
                    }
                }
            )
        }
    }

    private func handleNotificationLaunchIfNeeded() {
        guard !didHandleNotificationLaunch, let notificationLaunch else { return }
        didHandleNotificationLaunch = true

        switch notificationLaunch {
        case .invitations:
            isPresentingInvitations = true
        case .battleResult(let battleId):
            battleManager.fetchBattle(battleId: battleId) { summary in
                if let summary, summary.status == "finished" {
                    battleResult = summary
                }
            }
        case .leagueResult:
            if let result = viewModel.pendingResult {
                presentedSheet = .result(result)
            }
        }
    }

    /// アプリやリーグ画面を閉じた場合も、未完了の対戦を同じ問題から再開する。
    private func restoreBattleIfNeeded() {
        guard battlePlaySession == nil,
              battleResult == nil,
              let progress = BattlePlayProgressStore.load(for: AuthManager.shared.currentUserId) else {
            return
        }

        battleManager.fetchBattle(battleId: progress.session.battleId) { summary in
            // 一時的な通信失敗ではローカルの途中経過を消さず、次回表示時に再試行する。
            guard let summary else { return }
            if summary.status == "finished" {
                BattlePlayProgressStore.clear(battleId: progress.session.battleId)
                battleResult = summary
                return
            }

            let canResume = summary.myRole == progress.session.role
                && ((progress.session.role == .challenger && summary.status == "challenger_playing")
                    || (progress.session.role == .opponent && summary.status == "waiting_opponent"))
            guard canResume else {
                BattlePlayProgressStore.clear(battleId: progress.session.battleId)
                return
            }
            battlePlaySession = progress.session
        }
    }

    /// 前回この画面を離れたときの順位と比べて、変動を一度だけ確定させる。
    /// 表示中に順位が動いても差分がぶれないよう、最初の1回で固定する。
    private func captureBaselineIfNeeded() {
        guard !didCaptureBaseline,
              let seasonId = viewModel.season?.id,
              let rank = viewModel.snapshot.currentRank else { return }
        didCaptureBaseline = true
        if let last = WeeklyLeagueVisitTracker.lastSeenRank(seasonId: seasonId), last != rank {
            rankDelta = last - rank
        }
    }

    private func recordCurrentRank() {
        guard let seasonId = viewModel.season?.id,
              let rank = viewModel.snapshot.currentRank else { return }
        WeeklyLeagueVisitTracker.record(rank: rank, seasonId: seasonId)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            WeeklyLeagueSkeletonView()
                .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage, !isParticipating {
            WeeklyLeagueErrorView(message: errorMessage) {
                viewModel.load()
            }
            .transition(.opacity)
        } else {
            WeeklyLeagueBoard(
                snapshot: viewModel.snapshot,
                isJoined: isParticipating,
                rankDelta: rankDelta,
                inlineErrorMessage: viewModel.isJoined ? viewModel.errorMessage : nil,
                showRules: { presentedSheet = .rules(viewModel.tier) },
                reload: { viewModel.load() },
                onChallenge: { member in
                    guard let rank = rank(of: member) else { return }
                    challengeTarget = WeeklyLeagueChallengeTarget(member: member, rank: rank)
                },
                pendingInvitationCount: battleManager.incomingBattles.count,
                onOpenInvitations: { isPresentingInvitations = true }
            )
            .transition(.opacity)
        }
    }

    private func rank(of member: WeeklyLeagueMember) -> Int? {
        viewModel.snapshot.members.firstIndex(where: { $0.id == member.id }).map { $0 + 1 }
    }
}

private extension FriendSummary {
    /// 週間リーグのグループメンバーを、対戦画面が扱う `FriendSummary` に変換します。
    /// `level`/`featuredAvatarAttack` は対戦画面の表示にのみ使われるためダミー値で問題ありません。
    init(leagueMember member: WeeklyLeagueMember) {
        self.init(
            id: member.id,
            name: member.userName,
            level: 1,
            featuredAvatarName: member.avatarName,
            featuredAvatarAttack: 0,
            canBorrowToday: false
        )
    }
}

// MARK: - Preview

#if DEBUG
enum WeeklyLeagueMockData {
    static let names = [
        "コード・レイ", "ハッシュ", "ぱけっと", "サーバ番長", "Kotori",
        "アルゴ", "ビットまる", "ゆうき", "ネストくん", "キャッシュ",
        "スタックさん", "しおり", "リレー", "クエリ", "そると",
        "ぽーと", "ドメイン", "ふぁいあ", "レンダ", "こんぱいら",
        "ゲートウェイ", "ぱすわーど", "ゆに", "ぶーる", "ゼロデイ"
    ]

    static func members(count: Int = 25, currentUserRank: Int = 9) -> [WeeklyLeagueMember] {
        let now: TimeInterval = Date().timeIntervalSince1970 * 1_000
        return (0..<count).map { index in
            let rank: Int = index + 1
            let score: Int = max(880 - index * 34 - (index % 3) * 7, 12)
            let updatedAt: TimeInterval = now - Double(index) * 5_400_000
            return WeeklyLeagueMember(
                id: rank == currentUserRank ? "me" : "user-\(rank)",
                userName: rank == currentUserRank ? "みなと" : names[index % names.count],
                avatarName: "defaultIcon",
                score: score,
                scoreReachedAt: updatedAt,
                joinedAt: updatedAt
            )
        }
    }

    static var season: WeeklyLeagueSeason {
        WeeklyLeagueSeason(
            id: "2026-W32",
            startsAt: Date().addingTimeInterval(-3 * 86_400),
            endsAt: Date().addingTimeInterval(2 * 86_400 + 14 * 3_600)
        )
    }

    static func snapshot(
        tier: WeeklyLeagueTier = .gold,
        currentUserRank: Int = 9,
        count: Int = 25
    ) -> WeeklyLeagueSnapshot {
        WeeklyLeagueSnapshot(
            tier: tier,
            season: season,
            members: members(count: count, currentUserRank: currentUserRank),
            currentUserId: "me",
            promotionSlots: tier == .master ? 0 : 5,
            relegationSlots: tier == .bronze ? 0 : 5
        )
    }

    /// 参加者が自分ひとりだけの、実際に起こりうる状態。
    static var soloSnapshot: WeeklyLeagueSnapshot {
        WeeklyLeagueSnapshot(
            tier: .bronze,
            season: season,
            members: [
                WeeklyLeagueMember(
                    id: "me", userName: "アイティ", avatarName: "defaultIcon",
                    score: 0, scoreReachedAt: 0, joinedAt: 0
                )
            ],
            currentUserId: "me",
            promotionSlots: 0,
            relegationSlots: 0
        )
    }

    static func result(movement: WeeklyLeagueMovement, claimed: Bool = false) -> WeeklyLeagueResult {
        switch movement {
        case .promoted:
            return WeeklyLeagueResult(seasonId: "2026-W31", tier: .silver, rank: 3, score: 720,
                                      movement: .promoted, nextTier: .gold, rewardCoins: 300, rewardClaimed: claimed)
        case .stayed:
            return WeeklyLeagueResult(seasonId: "2026-W31", tier: .gold, rank: 12, score: 430,
                                      movement: .stayed, nextTier: .gold, rewardCoins: 100, rewardClaimed: claimed)
        case .relegated:
            return WeeklyLeagueResult(seasonId: "2026-W31", tier: .gold, rank: 23, score: 90,
                                      movement: .relegated, nextTier: .silver, rewardCoins: 50, rewardClaimed: claimed)
        }
    }
}

struct WeeklyLeagueBoardPreview: View {
    var snapshot: WeeklyLeagueSnapshot
    var isJoined = true
    var rankDelta: Int? = nil
    var inlineError: String? = nil

    var body: some View {
        ZStack {
            WeeklyLeaguePalette.canvas.ignoresSafeArea()
            WeeklyLeagueBoard(
                snapshot: snapshot,
                isJoined: isJoined,
                rankDelta: rankDelta,
                inlineErrorMessage: inlineError,
                showRules: {},
                reload: {}
            )
        }
    }
}

// 1. 初回読み込み中
struct WeeklyLeague_Loading_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            WeeklyLeaguePalette.canvas.ignoresSafeArea()
            WeeklyLeagueSkeletonView()
        }
        .previewDisplayName("1. 読み込み中")
    }
}

// 2. 未参加
struct WeeklyLeague_NotJoined_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyLeagueBoardPreview(
            snapshot: WeeklyLeagueSnapshot(tier: .bronze, season: WeeklyLeagueMockData.season, members: [], currentUserId: "me"),
            isJoined: false
        )
        .previewDisplayName("2. 未参加")
    }
}

// 3. 通常表示 / 端末サイズ確認
struct WeeklyLeague_Normal_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .gold, currentUserRank: 9), rankDelta: 3)
                .previewDevice("iPhone 12")
                .previewDisplayName("3. 通常 / iPhone 12")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .gold, currentUserRank: 9), rankDelta: 3)
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("3. 通常 / iPhone SE")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .gold, currentUserRank: 9))
                .previewDevice("iPhone 16 Pro Max")
                .previewDisplayName("3. 通常 / 大画面")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .gold, currentUserRank: 9), rankDelta: -2)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 12")
                .previewDisplayName("3. 通常 / ダーク")
        }
    }
}

// 4. 昇格圏 / 5. 降格圏 / 少人数
struct WeeklyLeague_Zones_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .silver, currentUserRank: 3))
                .previewDisplayName("4. 昇格圏")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .gold, currentUserRank: 23))
                .previewDisplayName("5. 降格圏")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .master, currentUserRank: 2))
                .previewDisplayName("5b. マスター")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.snapshot(tier: .bronze, currentUserRank: 18))
                .previewDisplayName("5c. ブロンズ（降格なし）")

            WeeklyLeagueBoardPreview(snapshot: WeeklyLeagueMockData.soloSnapshot)
                .previewDisplayName("5d. 参加者が自分だけ")
        }
        .previewDevice("iPhone 12")
    }
}

// 6. 通信エラー
struct WeeklyLeague_Error_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                WeeklyLeaguePalette.canvas.ignoresSafeArea()
                WeeklyLeagueErrorView(message: "ネットワークに接続できませんでした。通信環境を確認してください。") {}
            }
            .previewDisplayName("6. エラー（全画面）")

            WeeklyLeagueBoardPreview(
                snapshot: WeeklyLeagueMockData.snapshot(),
                inlineError: "最新の順位を取得できませんでした。"
            )
            .previewDisplayName("6b. エラー（表示中）")
        }
    }
}

// 7-9. シーズン結果 / 報酬受け取り前後
struct WeeklyLeague_Result_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyLeagueResultSheet(result: WeeklyLeagueMockData.result(movement: .promoted), isClaiming: false) { _, done in done(true) }
                .previewDisplayName("8a. 昇格（受け取り前）")

            WeeklyLeagueResultSheet(result: WeeklyLeagueMockData.result(movement: .stayed), isClaiming: false) { _, done in done(true) }
                .previewDisplayName("8b. 残留")

            WeeklyLeagueResultSheet(result: WeeklyLeagueMockData.result(movement: .relegated), isClaiming: false) { _, done in done(true) }
                .previewDisplayName("8c. 降格")

            WeeklyLeagueResultSheet(result: WeeklyLeagueMockData.result(movement: .promoted), isClaiming: true) { _, done in done(true) }
                .previewDisplayName("9. 報酬受け取り中")

            WeeklyLeagueResultSheet(result: WeeklyLeagueMockData.result(movement: .promoted), isClaiming: false) { _, done in done(false) }
                .previewDisplayName("9b. 受け取り失敗")
        }
    }
}

// ルールシート

struct WeeklyLeague_Rules_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyLeagueRulesSheet(currentTier: .gold)
            .previewDisplayName("ルール")
    }
}
#endif
