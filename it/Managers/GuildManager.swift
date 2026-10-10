//
//  GuildManager.swift
//  it
//
//  ギルド(勉強部屋)・ギルドボス・週間ミッション・活動フィードを管理します。
//

import Foundation
import FirebaseDatabase

enum GuildRank: String, CaseIterable, Identifiable {
    case beginner
    case bronze
    case silver
    case gold
    case platinum
    case diamond
    case master
    case legend

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner: return "ビギナー"
        case .bronze: return "ブロンズ"
        case .silver: return "シルバー"
        case .gold: return "ゴールド"
        case .platinum: return "プラチナ"
        case .diamond: return "ダイヤモンド"
        case .master: return "マスター"
        case .legend: return "レジェンド"
        }
    }

    var minimumLevel: Int {
        switch self {
        case .beginner: return 1
        case .bronze: return 10
        case .silver: return 20
        case .gold: return 35
        case .platinum: return 50
        case .diamond: return 70
        case .master: return 85
        case .legend: return 100
        }
    }

    var symbolName: String {
        switch self {
        case .beginner: return "shield.fill"
        case .bronze: return "shield.lefthalf.filled"
        case .silver: return "shield.checkered"
        case .gold: return "crown.fill"
        case .platinum: return "sparkles"
        case .diamond: return "diamond.fill"
        case .master: return "star.circle.fill"
        case .legend: return "trophy.fill"
        }
    }

    var assetName: String {
        switch self {
        case .beginner: return "GuildRankBeginner"
        case .bronze: return "GuildRankBronze"
        case .silver: return "GuildRankSilver"
        case .gold: return "GuildRankGold"
        case .platinum: return "GuildRankPlatinum"
        case .diamond: return "GuildRankDiamond"
        case .master: return "GuildRankMaster"
        case .legend: return "GuildRankLegend"
        }
    }

    var next: GuildRank? {
        guard let index = Self.allCases.firstIndex(of: self), index + 1 < Self.allCases.count else { return nil }
        return Self.allCases[index + 1]
    }

    static func rank(for level: Int) -> GuildRank {
        allCases.last(where: { level >= $0.minimumLevel }) ?? .beginner
    }
}

enum GuildLevelSystem {
    static let maximumLevel = 100

    static func experienceRequiredToAdvance(from level: Int) -> Int {
        500 + max(0, level - 1) * 100
    }

    static func progress(for totalExperience: Int) -> (level: Int, experienceInLevel: Int, experienceForNextLevel: Int) {
        var remaining = max(0, totalExperience)
        var level = 1
        while level < maximumLevel {
            let required = experienceRequiredToAdvance(from: level)
            guard remaining >= required else { return (level, remaining, required) }
            remaining -= required
            level += 1
        }
        return (maximumLevel, 0, 0)
    }
}

struct GuildRankReward {
    let rank: GuildRank
    let coin: Int
    let itemType: InventoryItemType
    let itemAmount: Int

    var items: [InventoryReward] { [InventoryReward(type: itemType, amount: itemAmount)] }
    var rewardText: String { "\(coin)コイン＋\(itemType.displayName)×\(itemAmount)" }
}

extension GuildRank {
    var reward: GuildRankReward? {
        switch self {
        case .beginner: return nil
        case .bronze: return GuildRankReward(rank: self, coin: 300, itemType: .staminaPotion, itemAmount: 2)
        case .silver: return GuildRankReward(rank: self, coin: 500, itemType: .normalGachaTicket, itemAmount: 2)
        case .gold: return GuildRankReward(rank: self, coin: 700, itemType: .rareGachaTicket, itemAmount: 1)
        case .platinum: return GuildRankReward(rank: self, coin: 1_000, itemType: .mekaGachaTicket, itemAmount: 1)
        case .diamond: return GuildRankReward(rank: self, coin: 1_500, itemType: .mekaGachaTicket, itemAmount: 2)
        case .master: return GuildRankReward(rank: self, coin: 2_000, itemType: .godGachaTicket, itemAmount: 1)
        case .legend: return GuildRankReward(rank: self, coin: 5_000, itemType: .godGachaTicket, itemAmount: 3)
        }
    }
}

struct GuildLevelState {
    let totalExperience: Int
    let weeklyExperience: Int
    let level: Int
    let experienceInLevel: Int
    let experienceForNextLevel: Int
    let rankAchievements: [GuildRank: Int64]
    let claimedRankRewards: Set<GuildRank>

    static let empty = GuildLevelState(
        totalExperience: 0,
        weeklyExperience: 0,
        level: 1,
        experienceInLevel: 0,
        experienceForNextLevel: GuildLevelSystem.experienceRequiredToAdvance(from: 1),
        rankAchievements: [:],
        claimedRankRewards: []
    )

    var rank: GuildRank { GuildRank.rank(for: level) }
    var isMaximumLevel: Bool { level >= GuildLevelSystem.maximumLevel }
    var progressValue: Double {
        guard experienceForNextLevel > 0 else { return 1 }
        return Double(experienceInLevel) / Double(experienceForNextLevel)
    }
}

struct GuildSummary: Identifiable {
    let id: String
    let name: String
    let description: String
    /// 保存済みデータの検索インデックス位置。新規ギルドはすべて `all` を使用する。
    let indexScope: String
    let memberCount: Int
    let leaderUid: String
    let inviteCode: String
    let guildExperience: Int

    var guildLevel: Int { GuildLevelSystem.progress(for: guildExperience).level }
    var guildRank: GuildRank { GuildRank.rank(for: guildLevel) }
}

struct GuildMember: Identifiable {
    let id: String // uid
    let name: String
    let level: Int
    let joinedAt: Int64
    /// 現在装備中のおとも。未設定時は空文字。
    let avatarName: String
}

struct GuildRaidPlayer: Identifiable {
    let id: String // uid
    let name: String
    let totalDamage: Int
    let correctCount: Int
    /// 現在装備中のおとも。未設定時は空文字。
    let avatarName: String
}

struct GuildRaidState {
    let raidId: String
    let bossName: String
    let bossImageName: String
    let bossHP: Int
    let bossMaxHP: Int
    let status: String // active, completed
    let players: [GuildRaidPlayer]
    let completedAt: Int64
}

struct GuildMissionState {
    let weekId: String
    let correctTotal: Int
    let target: Int
    let claimedBy: [String]
}

enum GuildMissionSection: String, CaseIterable, Identifiable {
    case learning
    case adventure
    case battle
    case participation
    case hardLearning
    case hardAdventure
    case hardCooperation
    case hardRaid
    case weeklyLogin
    case memberLogin
    case lifetimeLogin

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learning: return "学習系"
        case .adventure: return "ダンジョン・ストーリー系"
        case .battle: return "ゲリラ・バトル系"
        case .participation: return "継続・参加系"
        case .hardLearning: return "高難度・学習系"
        case .hardAdventure: return "高難度・冒険系"
        case .hardCooperation: return "高難度・協力系"
        case .hardRaid: return "高難度・ギルドボス系"
        case .weeklyLogin: return "週間ログイン系"
        case .memberLogin: return "個人連続ログイン合算"
        case .lifetimeLogin: return "長期ギルドミッション"
        }
    }

    var isLifetime: Bool { self == .lifetimeLogin }
}

enum GuildMissionRule {
    case counter(String)
    case answeredMembers(minimumAnswers: Int)
    case activeMembers(minimumDays: Int)
    case playerCount(field: String, minimumValue: Int)
    case accuracy(minimumAnswers: Int, minimumPercent: Int)
    case correctStreak
    case activityStreak(minimumMembers: Int)
    case loginMemberDays(lifetime: Bool)
    case loginGuildStreak(minimumMembers: Int, lifetime: Bool)
    case loginMemberStreak(requiredDays: Int, lifetime: Bool)
    case raidDefeated
    case raidCorrectPlayers(minimumCorrect: Int)
    case raidDamagePlayers(maxHPPercent: Int)
    case raidDamage
    case raidParticipantsAfterDefeat
}

struct GuildMissionDefinition: Identifiable {
    let id: String
    let section: GuildMissionSection
    let title: String
    let description: String
    let target: Int
    let unit: String
    let rewardCoin: Int
    let rewardItemType: InventoryItemType?
    let rewardItemAmount: Int
    let rule: GuildMissionRule

    var rewardItems: [InventoryReward] {
        guard let rewardItemType, rewardItemAmount > 0 else { return [] }
        return [InventoryReward(type: rewardItemType, amount: rewardItemAmount)]
    }

    var rewardText: String {
        var parts = ["\(rewardCoin)コイン"]
        if let rewardItemType, rewardItemAmount > 0 {
            parts.append("\(rewardItemType.displayName)×\(rewardItemAmount)")
        }
        return parts.joined(separator: "＋")
    }
}

struct GuildMissionProgress: Identifiable {
    let definition: GuildMissionDefinition
    let current: Int
    let target: Int
    let isCompleted: Bool
    let isClaimed: Bool
    let detail: String?

    var id: String { definition.id }
    var progressValue: Double { Double(min(current, target)) / Double(max(1, target)) }
}

private enum GuildMissionCatalog {
    private static func mission(
        _ id: String,
        _ section: GuildMissionSection,
        _ title: String,
        _ description: String,
        _ target: Int,
        _ unit: String,
        _ coins: Int,
        _ item: InventoryItemType?,
        _ amount: Int,
        _ rule: GuildMissionRule
    ) -> GuildMissionDefinition {
        GuildMissionDefinition(
            id: id,
            section: section,
            title: title,
            description: description,
            target: target,
            unit: unit,
            rewardCoin: coins,
            rewardItemType: item,
            rewardItemAmount: amount,
            rule: rule
        )
    }

    static let all: [GuildMissionDefinition] = [
        mission("answer_500", .learning, "ギルド全体で問題を解こう", "ギルド全体で問題を500問解答しよう", 500, "問", 100, .staminaPotion, 1, .counter("answers")),
        mission("correct_300", .learning, "ギルド全体で正解しよう", "ギルド全体で300問正解しよう", 300, "問", 150, .normalGachaTicket, 1, .counter("correctAnswers")),
        mission("experience_10000", .learning, "ギルド全体で経験値を獲得しよう", "ギルド全体で経験値を10,000獲得しよう", 10_000, "XP", 150, .boostTicket, 1, .counter("experience")),
        mission("review_30", .learning, "ギルド全体で苦手問題を克服しよう", "苦手問題を合計30問克服しよう", 30, "問", 200, .rareGachaTicket, 1, .counter("reviews")),

        mission("dungeon_500", .adventure, "ギルド全体でダンジョンを進もう", "ダンジョンを合計500コマ進もう", 500, "コマ", 150, .staminaPotion, 2, .counter("dungeonSteps")),
        mission("story_50", .adventure, "ギルド全体でストーリーをクリアしよう", "ストーリーを合計50回クリアしよう", 50, "回", 150, .boostTicket, 1, .counter("storyClears")),
        mission("boss_30", .adventure, "ギルド全体でボスを倒そう", "ストーリーボスを合計30体倒そう", 30, "体", 200, .rareGachaTicket, 1, .counter("bossKills")),

        mission("guerrilla_join_30", .battle, "ギルド全体でゲリラに参加しよう", "ゲリラに合計30回参加しよう", 30, "回", 150, .staminaPotion, 1, .counter("guerrillaParticipations")),
        mission("guerrilla_win_20", .battle, "ギルド全体でゲリラに勝利しよう", "ゲリラに合計20回勝利しよう", 20, "回", 200, .rareGachaTicket, 1, .counter("guerrillaWins")),
        mission("guerrilla_first_10", .battle, "ギルド全体でゲリラ1位を取ろう", "ゲリラで合計10回1位を取ろう", 10, "回", 300, .godGachaTicket, 1, .counter("guerrillaFirsts")),
        mission("raid_defeat", .battle, "ギルドボスを討伐しよう", "出現中のギルドボスを討伐しよう", 1, "体", 200, .mekaGachaTicket, 1, .raidDefeated),

        mission("login_days_50", .participation, "ギルドメンバーでログインしよう", "メンバーのログインを合計50日分記録しよう", 50, "日分", 150, .normalGachaTicket, 1, .loginMemberDays(lifetime: false)),
        mission("daily_complete_30", .participation, "デイリーミッションを全クリアしよう", "デイリーミッションを合計30回全クリアしよう", 30, "回", 200, .mekaGachaTicket, 1, .counter("dailyCompletes")),
        mission("active_3days_5members", .participation, "3日以上活動するメンバーを増やそう", "3日以上問題を解いたメンバーを5人にしよう", 5, "人", 200, .rareGachaTicket, 1, .activeMembers(minimumDays: 3)),
        mission("answer_members_8", .participation, "1問以上解答したメンバーを増やそう", "1問以上解答したメンバーを8人にしよう", 8, "人", 150, .staminaPotion, 2, .answeredMembers(minimumAnswers: 1)),

        mission("answer_1500", .hardLearning, "ギルド全体で大量演習しよう", "ギルド全体で1,500問解答しよう", 1_500, "問", 300, .staminaPotion, 3, .counter("answers")),
        mission("correct_1000", .hardLearning, "ギルド全体で知識を極めよう", "ギルド全体で1,000問正解しよう", 1_000, "問", 300, .rareGachaTicket, 1, .counter("correctAnswers")),
        mission("experience_50000", .hardLearning, "ギルド全体で経験値を稼ごう", "ギルド全体で経験値を50,000獲得しよう", 50_000, "XP", 300, .boostTicket, 2, .counter("experience")),
        mission("review_100", .hardLearning, "苦手問題を徹底攻略しよう", "苦手問題を合計100問克服しよう", 100, "問", 400, .mekaGachaTicket, 1, .counter("reviews")),
        mission("accuracy_500_80", .hardLearning, "高い正解率を維持しよう", "500問以上解答し、ギルド正解率80%以上を達成しよう", 500, "問", 500, .mekaGachaTicket, 1, .accuracy(minimumAnswers: 500, minimumPercent: 80)),
        mission("correct_streak_100", .hardLearning, "正解をつなげよう", "ギルド全体で100問連続正解しよう", 100, "問", 500, .godGachaTicket, 1, .correctStreak),

        mission("dungeon_2000", .hardAdventure, "ダンジョン大遠征", "ダンジョンを合計2,000コマ進もう", 2_000, "コマ", 300, .staminaPotion, 3, .counter("dungeonSteps")),
        mission("story_150", .hardAdventure, "ストーリー大攻略", "ストーリーを合計150回クリアしよう", 150, "回", 300, .rareGachaTicket, 1, .counter("storyClears")),
        mission("boss_100", .hardAdventure, "ボスハンター", "ストーリーボスを合計100体倒そう", 100, "体", 400, .mekaGachaTicket, 1, .counter("bossKills")),
        mission("guerrilla_join_100", .hardAdventure, "ゲリラ大作戦", "ゲリラに合計100回参加しよう", 100, "回", 300, .staminaPotion, 3, .counter("guerrillaParticipations")),
        mission("guerrilla_win_50", .hardAdventure, "ゲリラ制圧", "ゲリラで合計50回勝利しよう", 50, "回", 400, .mekaGachaTicket, 1, .counter("guerrillaWins")),
        mission("guerrilla_first_25", .hardAdventure, "最強ギルドへの挑戦", "ゲリラで合計25回1位を取ろう", 25, "回", 500, .godGachaTicket, 1, .counter("guerrillaFirsts")),

        mission("players_answer_10x50", .hardCooperation, "総力戦", "10人がそれぞれ50問解答しよう", 10, "人", 500, .godGachaTicket, 1, .playerCount(field: "answers", minimumValue: 50)),
        mission("players_correct_7x50", .hardCooperation, "精鋭ギルド", "7人がそれぞれ50問正解しよう", 7, "人", 400, .mekaGachaTicket, 1, .playerCount(field: "correctAnswers", minimumValue: 50)),
        mission("players_guerrilla_10x3", .hardCooperation, "全員参加", "10人がそれぞれゲリラに3回参加しよう", 10, "人", 500, .godGachaTicket, 1, .playerCount(field: "guerrillaParticipations", minimumValue: 3)),
        mission("activity_7days_5", .hardCooperation, "毎日活動しよう", "7日間、毎日5人以上が問題を解こう", 7, "日", 500, .godGachaTicket, 1, .activityStreak(minimumMembers: 5)),
        mission("daily_complete_50", .hardCooperation, "デイリー完全攻略", "デイリーミッションを合計50回全クリアしよう", 50, "回", 400, .mekaGachaTicket, 1, .counter("dailyCompletes")),
        mission("login_days_60", .hardCooperation, "活発なギルドを作ろう", "メンバーのログインを合計60日分記録しよう", 60, "日分", 400, .mekaGachaTicket, 1, .loginMemberDays(lifetime: false)),

        mission("raid_all_10", .hardRaid, "連携攻撃", "3人以上がそれぞれ5問以上正解して討伐しよう", 3, "人", 500, .godGachaTicket, 1, .raidCorrectPlayers(minimumCorrect: 5)),
        mission("raid_elite_5", .hardRaid, "精鋭討伐", "3人以上が現在のボス最大HPの10%以上のダメージを与えよう", 3, "人", 400, .mekaGachaTicket, 1, .raidDamagePlayers(maxHPPercent: 10)),
        mission("raid_damage_100000", .hardRaid, "大ダメージ作戦", "ギルド全体で現在のボス最大HPと同じダメージを与えよう", 1, "ダメージ", 400, .rareGachaTicket, 2, .raidDamage),
        mission("raid_participants_7", .hardRaid, "最後まで戦おう", "5人以上が攻撃に参加してギルドボスを討伐しよう", 5, "人", 400, .mekaGachaTicket, 1, .raidParticipantsAfterDefeat),

        mission("login_guild_3x3", .weeklyLogin, "ギルド活動開始", "3日連続で毎日3人以上がログインしよう", 3, "日", 100, .staminaPotion, 1, .loginGuildStreak(minimumMembers: 3, lifetime: false)),
        mission("login_guild_7x3", .weeklyLogin, "毎日集まろう", "7日連続で毎日3人以上がログインしよう", 7, "日", 200, .rareGachaTicket, 1, .loginGuildStreak(minimumMembers: 3, lifetime: false)),
        mission("login_guild_5x5", .weeklyLogin, "活発なギルド", "5日連続で毎日5人以上がログインしよう", 5, "日", 250, .mekaGachaTicket, 1, .loginGuildStreak(minimumMembers: 5, lifetime: false)),
        mission("login_guild_7x5", .weeklyLogin, "みんなで皆勤", "7日連続で毎日5人以上がログインしよう", 7, "日", 400, .mekaGachaTicket, 1, .loginGuildStreak(minimumMembers: 5, lifetime: false)),
        mission("login_guild_3x10", .weeklyLogin, "全員集合", "3日連続で毎日10人がログインしよう", 3, "日", 500, .godGachaTicket, 1, .loginGuildStreak(minimumMembers: 10, lifetime: false)),

        mission("login_members_5x3", .memberLogin, "ログイン仲間を増やそう", "5人がそれぞれ3日連続ログインしよう", 5, "人", 150, .staminaPotion, 2, .loginMemberStreak(requiredDays: 3, lifetime: false)),
        mission("login_members_5x7", .memberLogin, "継続するギルド", "5人がそれぞれ7日連続ログインしよう", 5, "人", 300, .rareGachaTicket, 1, .loginMemberStreak(requiredDays: 7, lifetime: false)),
        mission("login_members_7x7", .memberLogin, "精鋭メンバー", "7人がそれぞれ7日連続ログインしよう", 7, "人", 400, .mekaGachaTicket, 1, .loginMemberStreak(requiredDays: 7, lifetime: false)),
        mission("login_members_10x7", .memberLogin, "全員皆勤", "10人がそれぞれ7日連続ログインしよう", 10, "人", 700, .godGachaTicket, 1, .loginMemberStreak(requiredDays: 7, lifetime: false)),

        mission("lifetime_guild_14x3", .lifetimeLogin, "いつもにぎやか", "14日連続で毎日3人以上がログインしよう", 14, "日", 500, .mekaGachaTicket, 1, .loginGuildStreak(minimumMembers: 3, lifetime: true)),
        mission("lifetime_guild_30x3", .lifetimeLogin, "活動拠点", "30日連続で毎日3人以上がログインしよう", 30, "日", 1_000, .godGachaTicket, 1, .loginGuildStreak(minimumMembers: 3, lifetime: true)),
        mission("lifetime_members_5x14", .lifetimeLogin, "結束の証", "5人がそれぞれ14日連続ログインしよう", 5, "人", 700, .mekaGachaTicket, 2, .loginMemberStreak(requiredDays: 14, lifetime: true)),
        mission("lifetime_members_5x30", .lifetimeLogin, "強い絆", "5人がそれぞれ30日連続ログインしよう", 5, "人", 1_500, .godGachaTicket, 1, .loginMemberStreak(requiredDays: 30, lifetime: true)),
        mission("lifetime_members_10x30", .lifetimeLogin, "最高のギルド", "10人がそれぞれ30日連続ログインしよう", 10, "人", 3_000, .godGachaTicket, 3, .loginMemberStreak(requiredDays: 30, lifetime: true))
    ]
}

struct GuildFeedItem: Identifiable {
    let id: String
    let uid: String
    let name: String
    let text: String
    let timestamp: Int64
}

enum GuildError: LocalizedError {
    case notLoggedIn
    case alreadyInGuild
    case notInGuild
    case guildFull
    case guildNotFound
    case nameTooShort
    case invalidInviteCode
    case notLeader
    case memberNotFound
    case cannotRemoveSelf
    case networkError

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "ログイン情報を確認できませんでした。"
        case .alreadyInGuild: return "すでにギルドに所属しています。先に脱退してください。"
        case .notInGuild: return "ギルドに所属していません。"
        case .guildFull: return "このギルドは定員に達しています。"
        case .guildNotFound: return "ギルドが見つかりませんでした。"
        case .nameTooShort: return "ギルド名を入力してください。"
        case .invalidInviteCode: return "招待コードに一致するギルドが見つかりませんでした。"
        case .notLeader: return "この操作はギルドリーダーだけが行えます。"
        case .memberNotFound: return "対象のメンバーが見つかりませんでした。"
        case .cannotRemoveSelf: return "自分自身はメンバーから除外できません。脱退を使用してください。"
        case .networkError: return "通信エラーが発生しました。時間をおいて再度お試しください。"
        }
    }
}

final class GuildManager: ObservableObject {
    static let shared = GuildManager()
    private init() {}

    @Published var myGuildId: String?
    @Published var guild: GuildSummary?
    @Published var members: [GuildMember] = []
    @Published var raid: GuildRaidState?
    @Published var raidSummonCorrectAnswers = 0
    @Published var mission: GuildMissionState?
    @Published var missionProgresses: [GuildMissionProgress] = []
    @Published var guildLevelState: GuildLevelState = .empty
    @Published var feed: [GuildFeedItem] = []
    @Published var searchResults: [GuildSummary] = []
    @Published var isLoading = false

    let maxMembers = 10
    let raidSummonTarget = 100
    private let legacyMissionTarget = 300
    private let commonIndexScope = "all"
    /// 旧バージョンで試験別に作成されたギルドも、共通一覧へ表示するために読み込む。
    private let searchableIndexScopes = ["all", "itPassport", "fundamentalInfo", "appliedInfo"]

    private var db: DatabaseReference { Database.database().reference() }
    private var currentUserId: String? { AuthManager.shared.currentUserId }
    private var raidRef: DatabaseReference?
    private var raidHandle: DatabaseHandle?
    private var feedRef: DatabaseQuery?
    private var feedHandle: DatabaseHandle?
    private var membersRef: DatabaseReference?
    private var membersHandle: DatabaseHandle?
    private var missionsRef: DatabaseReference?
    private var missionsHandle: DatabaseHandle?
    private var guildProgressRef: DatabaseReference?
    private var guildProgressHandle: DatabaseHandle?
    private var weeklyMissionData: [String: Any] = [:]
    private var lifetimeMissionData: [String: Any] = [:]
    private var awardedMissionExperienceKeys: Set<String> = []
    private var pendingMissionExperienceKeys: Set<String> = []

    // MARK: - 所属確認

    func fetchMyGuild(completion: (() -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?()
            return
        }
        db.child("userGuild").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            guard let guildId = snapshot.value as? String else {
                DispatchQueue.main.async {
                    self.myGuildId = nil
                    self.guild = nil
                    self.members = []
                    self.missionProgresses = []
                    self.guildLevelState = .empty
                }
                self.stopObservingMembers()
                self.stopObservingMissions()
                self.stopObservingGuildProgress()
                completion?()
                return
            }
            DispatchQueue.main.async { self.myGuildId = guildId }
            self.fetchGuildInfo(guildId: guildId) {
                self.fetchMembers(guildId: guildId)
                self.observeRaid(guildId: guildId)
                self.observeMissions(guildId: guildId)
                self.observeGuildProgress(guildId: guildId)
                self.observeFeed(guildId: guildId)
                self.recordLoginIfNeeded(guildId: guildId, userId: userId)
                completion?()
            }
        }
    }

    private func fetchGuildInfo(guildId: String, completion: (() -> Void)? = nil) {
        db.child("guilds").child(guildId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            guard let value = snapshot.value as? [String: Any] else {
                completion?()
                return
            }
            let membersDict = value["members"] as? [String: Any] ?? [:]
            let summary = GuildSummary(
                id: guildId,
                name: value["name"] as? String ?? "名称未設定",
                description: value["description"] as? String ?? "",
                indexScope: self.indexScope(from: value),
                memberCount: membersDict.count,
                leaderUid: value["leaderUid"] as? String ?? "",
                inviteCode: value["inviteCode"] as? String ?? "",
                guildExperience: self.intValue((value["guildProgress"] as? [String: Any])?["totalExperience"])
            )
            DispatchQueue.main.async { self.guild = summary }
            completion?()
        }
    }

    // MARK: - 検索

    func searchGuilds(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { self.isLoading = true }
        let group = DispatchGroup()
        let resultQueue = DispatchQueue(label: "GuildManager.searchResults")
        var resultsById: [String: GuildSummary] = [:]

        searchableIndexScopes.forEach { scope in
            group.enter()
            db.child("guildIndex").child(scope).observeSingleEvent(of: .value) { snapshot in
                let results = snapshot.children
                    .compactMap { $0 as? DataSnapshot }
                    .compactMap { child -> GuildSummary? in
                        guard let value = child.value as? [String: Any],
                              let name = value["name"] as? String else { return nil }
                        return GuildSummary(
                            id: child.key,
                            name: name,
                            description: value["description"] as? String ?? "",
                            indexScope: scope,
                            memberCount: value["memberCount"] as? Int ?? 0,
                            leaderUid: value["leaderUid"] as? String ?? "",
                            inviteCode: "",
                            guildExperience: self.intValue(value["guildExperience"])
                        )
                    }
                resultQueue.async {
                    results.forEach { result in
                        if resultsById[result.id] == nil || scope == self.commonIndexScope {
                            resultsById[result.id] = result
                        }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: resultQueue) {
            let results = resultsById.values.sorted { lhs, rhs in
                if lhs.memberCount == rhs.memberCount { return lhs.name < rhs.name }
                return lhs.memberCount < rhs.memberCount
            }
            DispatchQueue.main.async {
                self.searchResults = results
                self.isLoading = false
                completion?()
            }
        }
    }

    // MARK: - 作成

    func createGuild(name: String, description: String, completion: @escaping (Result<String, GuildError>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            completion(.failure(.nameTooShort))
            return
        }

        db.child("userGuild").child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.failure(.alreadyInGuild))
                return
            }

            self.generateUniqueInviteCode { inviteCode in
                guard let inviteCode else {
                    completion(.failure(.networkError))
                    return
                }
                self.fetchUserBasicInfo(uid: userId) { myName, myLevel, myAvatarName in
                    let guildRef = self.db.child("guilds").childByAutoId()
                    guard let guildId = guildRef.key else {
                        completion(.failure(.networkError))
                        return
                    }
                    let now = ServerValue.timestamp()
                    let guildData: [String: Any] = [
                        "name": trimmedName,
                        "description": description,
                        "indexScope": self.commonIndexScope,
                        "leaderUid": userId,
                        "inviteCode": inviteCode,
                        "createdAt": now,
                        "guildProgress": ["totalExperience": 0],
                        "members": [
                            userId: [
                                "name": myName ?? "名無し",
                                "level": myLevel ?? 1,
                                "joinedAt": now,
                                "avatarName": myAvatarName ?? ""
                            ]
                        ]
                    ]
                    let indexData: [String: Any] = [
                        "name": trimmedName,
                        "description": description,
                        "memberCount": 1,
                        "leaderUid": userId,
                        "guildExperience": 0,
                        "guildLevel": 1
                    ]
                    let updates: [String: Any] = [
                        "guilds/\(guildId)": guildData,
                        "guildIndex/\(self.commonIndexScope)/\(guildId)": indexData,
                        "guildInviteCodes/\(inviteCode)": guildId,
                        "userGuild/\(userId)": guildId
                    ]
                    self.db.updateChildValues(updates) { error, _ in
                        guard error == nil else {
                            completion(.failure(.networkError))
                            return
                        }
                        self.fetchMyGuild()
                        completion(.success(guildId))
                    }
                }
            }
        }
    }

    // MARK: - 参加/脱退

    func joinGuild(guildId: String, completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        db.child("userGuild").child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.failure(.alreadyInGuild))
                return
            }

            let guildRef = self.db.child("guilds").child(guildId)
            guildRef.observeSingleEvent(of: .value) { guildSnapshot in
                guard let guildValue = guildSnapshot.value as? [String: Any] else {
                    completion(.failure(.guildNotFound))
                    return
                }
                let indexScope = self.indexScope(from: guildValue)
                self.fetchUserBasicInfo(uid: userId) { myName, myLevel, myAvatarName in
                    let memberData: [String: Any] = [
                        "name": myName ?? "名無し",
                        "level": myLevel ?? 1,
                        "joinedAt": ServerValue.timestamp(),
                        "avatarName": myAvatarName ?? ""
                    ]
                    let membersRef = guildRef.child("members")
                    membersRef.runTransactionBlock { mutableData in
                        var members = mutableData.value as? [String: Any] ?? [:]
                        guard members[userId] == nil, members.count < self.maxMembers else {
                            return TransactionResult.abort()
                        }
                        members[userId] = memberData
                        mutableData.value = members
                        return TransactionResult.success(withValue: mutableData)
                    } andCompletionBlock: { error, committed, snapshot in
                        guard error == nil else {
                            completion(.failure(.networkError))
                            return
                        }
                        guard committed else {
                            completion(.failure(.guildFull))
                            return
                        }
                        let count = Int(snapshot?.childrenCount ?? 0)
                        let updates: [String: Any] = [
                            "guildIndex/\(indexScope)/\(guildId)/memberCount": count,
                            "userGuild/\(userId)": guildId
                        ]
                        self.db.updateChildValues(updates) { error, _ in
                            guard error == nil else {
                                membersRef.child(userId).removeValue()
                                completion(.failure(.networkError))
                                return
                            }
                            self.postFeedEvent(guildId: guildId, uid: userId, name: myName ?? "名無し", text: "が仲間になりました")
                            self.fetchMyGuild()
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }

    func joinGuild(inviteCode rawCode: String, completion: @escaping (Result<Void, GuildError>) -> Void) {
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard code.count == 6 else {
            completion(.failure(.invalidInviteCode))
            return
        }
        db.child("guildInviteCodes").child(code).observeSingleEvent(of: .value) { snapshot in
            guard let guildId = snapshot.value as? String, !guildId.isEmpty else {
                completion(.failure(.invalidInviteCode))
                return
            }
            self.joinGuild(guildId: guildId, completion: completion)
        }
    }

    func leaveGuild(completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId, let guildId = myGuildId else {
            completion(.failure(.notInGuild))
            return
        }
        let guildRef = db.child("guilds").child(guildId)
        guildRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  var membersDict = value["members"] as? [String: Any] else {
                completion(.failure(.guildNotFound))
                return
            }
            let indexScope = self.indexScope(from: value)
            let leaderUid = value["leaderUid"] as? String ?? userId
            membersDict.removeValue(forKey: userId)
            let remainingCount = membersDict.count

            if remainingCount == 0 {
                // 最後の1人が抜けたらギルドを解散
                var updates: [String: Any] = [
                    "guilds/\(guildId)": NSNull(),
                    "guildIndex/\(indexScope)/\(guildId)": NSNull(),
                    "userGuild/\(userId)": NSNull()
                ]
                if let inviteCode = value["inviteCode"] as? String, !inviteCode.isEmpty {
                    updates["guildInviteCodes/\(inviteCode)"] = NSNull()
                }
                self.db.updateChildValues(updates) { error, _ in
                    self.finishLeave(error: error, completion: completion)
                }
                return
            }

            var updates: [String: Any] = [
                "guilds/\(guildId)/members/\(userId)": NSNull(),
                "guildIndex/\(indexScope)/\(guildId)/memberCount": remainingCount,
                "userGuild/\(userId)": NSNull()
            ]

            if leaderUid == userId {
                // リーダーが抜ける場合は最も古参のメンバーに委譲
                let nextLeaderUid = membersDict
                    .compactMap { key, value -> (String, Int64)? in
                        guard let dict = value as? [String: Any], let joinedAt = dict["joinedAt"] as? Int64 else { return nil }
                        return (key, joinedAt)
                    }
                    .min { $0.1 < $1.1 }?.0
                if let nextLeaderUid {
                    updates["guilds/\(guildId)/leaderUid"] = nextLeaderUid
                    updates["guildIndex/\(indexScope)/\(guildId)/leaderUid"] = nextLeaderUid
                }
            }

            self.db.updateChildValues(updates) { error, _ in
                self.finishLeave(error: error, completion: completion)
            }
        }
    }

    private func finishLeave(error: Error?, completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard error == nil else {
            completion(.failure(.networkError))
            return
        }
        stopObservingRaid()
        stopObservingFeed()
        stopObservingMembers()
        stopObservingMissions()
        stopObservingGuildProgress()
        DispatchQueue.main.async {
            self.myGuildId = nil
            self.guild = nil
            self.members = []
            self.raid = nil
            self.raidSummonCorrectAnswers = 0
            self.mission = nil
            self.missionProgresses = []
            self.guildLevelState = .empty
            self.feed = []
        }
        completion(.success(()))
    }

    // MARK: - ギルド管理

    func ensureInviteCode(completion: ((Result<String, GuildError>) -> Void)? = nil) {
        guard let userId = currentUserId, let guildId = myGuildId else {
            completion?(.failure(.notInGuild))
            return
        }
        let guildRef = db.child("guilds").child(guildId)
        guildRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  (value["members"] as? [String: Any])?[userId] != nil else {
                completion?(.failure(.notInGuild))
                return
            }
            if let code = value["inviteCode"] as? String, !code.isEmpty {
                completion?(.success(code))
                return
            }
            self.generateUniqueInviteCode { code in
                guard let code else {
                    completion?(.failure(.networkError))
                    return
                }
                let updates: [String: Any] = [
                    "guilds/\(guildId)/inviteCode": code,
                    "guildInviteCodes/\(code)": guildId
                ]
                self.db.updateChildValues(updates) { error, _ in
                    guard error == nil else {
                        completion?(.failure(.networkError))
                        return
                    }
                    self.fetchGuildInfo(guildId: guildId)
                    completion?(.success(code))
                }
            }
        }
    }

    func updateGuild(name: String, description: String, completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId, let guild = guild else {
            completion(.failure(.notInGuild))
            return
        }
        guard guild.leaderUid == userId else {
            completion(.failure(.notLeader))
            return
        }
        let trimmedName = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(20))
        guard !trimmedName.isEmpty else {
            completion(.failure(.nameTooShort))
            return
        }
        let trimmedDescription = String(description.prefix(40))
        let updates: [String: Any] = [
            "guilds/\(guild.id)/name": trimmedName,
            "guilds/\(guild.id)/description": trimmedDescription,
            "guildIndex/\(guild.indexScope)/\(guild.id)/name": trimmedName,
            "guildIndex/\(guild.indexScope)/\(guild.id)/description": trimmedDescription
        ]
        db.updateChildValues(updates) { error, _ in
            guard error == nil else {
                completion(.failure(.networkError))
                return
            }
            self.fetchGuildInfo(guildId: guild.id)
            completion(.success(()))
        }
    }

    func transferLeadership(to member: GuildMember, completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId, let guild = guild else {
            completion(.failure(.notInGuild))
            return
        }
        guard guild.leaderUid == userId else {
            completion(.failure(.notLeader))
            return
        }
        guard members.contains(where: { $0.id == member.id }) else {
            completion(.failure(.memberNotFound))
            return
        }
        let updates: [String: Any] = [
            "guilds/\(guild.id)/leaderUid": member.id,
            "guildIndex/\(guild.indexScope)/\(guild.id)/leaderUid": member.id
        ]
        db.updateChildValues(updates) { error, _ in
            guard error == nil else {
                completion(.failure(.networkError))
                return
            }
            self.postFeedEvent(guildId: guild.id, uid: member.id, name: member.name, text: "が新しいリーダーになりました")
            self.fetchGuildInfo(guildId: guild.id)
            completion(.success(()))
        }
    }

    func removeMember(_ member: GuildMember, completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId, let guild = guild else {
            completion(.failure(.notInGuild))
            return
        }
        guard guild.leaderUid == userId else {
            completion(.failure(.notLeader))
            return
        }
        guard member.id != userId else {
            completion(.failure(.cannotRemoveSelf))
            return
        }
        guard members.contains(where: { $0.id == member.id }) else {
            completion(.failure(.memberNotFound))
            return
        }
        let nextCount = max(1, members.count - 1)
        let updates: [String: Any] = [
            "guilds/\(guild.id)/members/\(member.id)": NSNull(),
            "guildIndex/\(guild.indexScope)/\(guild.id)/memberCount": nextCount,
            "userGuild/\(member.id)": NSNull()
        ]
        db.updateChildValues(updates) { error, _ in
            guard error == nil else {
                completion(.failure(.networkError))
                return
            }
            self.postFeedEvent(guildId: guild.id, uid: member.id, name: member.name, text: "がギルドから外れました")
            completion(.success(()))
        }
    }

    func disbandGuild(completion: @escaping (Result<Void, GuildError>) -> Void) {
        guard let userId = currentUserId, let guildId = myGuildId else {
            completion(.failure(.notInGuild))
            return
        }
        db.child("guilds").child(guildId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  value["leaderUid"] as? String == userId else {
                completion(.failure(.notLeader))
                return
            }
            let indexScope = self.indexScope(from: value)
            let memberIds = Array((value["members"] as? [String: Any] ?? [:]).keys)
            var updates: [String: Any] = [
                "guilds/\(guildId)": NSNull(),
                "guildIndex/\(indexScope)/\(guildId)": NSNull()
            ]
            memberIds.forEach { updates["userGuild/\($0)"] = NSNull() }
            if let inviteCode = value["inviteCode"] as? String, !inviteCode.isEmpty {
                updates["guildInviteCodes/\(inviteCode)"] = NSNull()
            }
            self.db.updateChildValues(updates) { error, _ in
                guard error == nil else {
                    completion(.failure(.networkError))
                    return
                }
                self.finishLeave(error: nil, completion: completion)
            }
        }
    }

    // MARK: - メンバー一覧

    private func fetchMembers(guildId: String) {
        stopObservingMembers()
        let ref = db.child("guilds").child(guildId).child("members")
        membersRef = ref
        membersHandle = ref.observe(.value) { [weak self] snapshot in
            let members: [GuildMember] = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .compactMap { child -> GuildMember? in
                    guard let value = child.value as? [String: Any],
                          let name = value["name"] as? String else { return nil }
                    return GuildMember(
                        id: child.key,
                        name: name.isEmpty ? "名無し" : name,
                        level: value["level"] as? Int ?? 1,
                        joinedAt: self?.int64Value(value["joinedAt"]) ?? 0,
                        avatarName: value["avatarName"] as? String ?? ""
                    )
                }
                .sorted { $0.level > $1.level }
            DispatchQueue.main.async { self?.members = members }
        }
    }

    private func stopObservingMembers() {
        if let membersRef, let membersHandle {
            membersRef.removeObserver(withHandle: membersHandle)
        }
        membersRef = nil
        membersHandle = nil
    }

    /// 装備しているおともを切り替えたときに呼びます。ギルドに所属していなければ何もしません。
    func updateMyAvatarName(_ avatarName: String) {
        guard let guildId = myGuildId, let userId = currentUserId else { return }
        db.child("guilds").child(guildId).child("members").child(userId).child("avatarName").setValue(avatarName)
    }

    // MARK: - ギルドボス

    private func observeRaid(guildId: String) {
        stopObservingRaid()
        let ref = db.child("guilds").child(guildId).child("guildBoss")
        raidRef = ref
        raidHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            guard let root = snapshot.value as? [String: Any],
                  let value = root["current"] as? [String: Any] else {
                self.spawnInitialRaidIfNeeded(guildId: guildId)
                return
            }
            let players: [GuildRaidPlayer] = (value["players"] as? [String: Any] ?? [:])
                .compactMap { key, raw -> GuildRaidPlayer? in
                    guard let dict = raw as? [String: Any] else { return nil }
                    let rawName = dict["name"] as? String ?? ""
                    return GuildRaidPlayer(
                        id: key,
                        name: rawName.isEmpty ? "名無し" : rawName,
                        totalDamage: dict["totalDamage"] as? Int ?? 0,
                        correctCount: dict["correctCount"] as? Int ?? 0,
                        avatarName: dict["avatarName"] as? String ?? ""
                    )
                }
                .sorted { $0.totalDamage > $1.totalDamage }
            let state = GuildRaidState(
                raidId: value["raidId"] as? String ?? "",
                bossName: value["bossName"] as? String ?? "",
                bossImageName: value["bossImageName"] as? String ?? "",
                bossHP: value["bossHP"] as? Int ?? 0,
                bossMaxHP: value["bossMaxHP"] as? Int ?? 1,
                status: value["status"] as? String ?? "active",
                players: players,
                completedAt: Int64(self.intValue(value["completedAt"]))
            )
            DispatchQueue.main.async {
                self.raid = state
                self.raidSummonCorrectAnswers = min(
                    self.intValue(root["summonCorrectAnswers"]),
                    self.raidSummonTarget
                )
                self.rebuildMissionProgresses()
            }
            self.migrateRaidBalanceIfNeeded(guildId: guildId, raidValue: value)
        }
    }

    /// 固定HP 100,000だった旧レイドを、ボス固有HPへ一度だけ換算する。
    /// 残りHP率とメンバーごとの与ダメージ率を維持するため、途中の攻略状況を失わない。
    private func migrateRaidBalanceIfNeeded(guildId: String, raidValue: [String: Any]) {
        let status = raidValue["status"] as? String ?? "active"
        let bossName = raidValue["bossName"] as? String ?? ""
        let oldMaxHP = intValue(raidValue["bossMaxHP"])
        guard oldMaxHP > 0,
              let boss = guildRaidBosses.first(where: { $0.name == bossName }),
              oldMaxHP != boss.bossHP else { return }

        let currentRef = db.child("guilds").child(guildId).child("guildBoss").child("current")
        currentRef.runTransactionBlock { mutableData in
            guard var current = mutableData.value as? [String: Any],
                  (current["status"] as? String ?? "active") == status,
                  (current["bossName"] as? String ?? "") == bossName else {
                return TransactionResult.abort()
            }

            let transactionOldMaxHP = self.intValue(current["bossMaxHP"])
            guard transactionOldMaxHP == oldMaxHP else { return TransactionResult.abort() }

            let oldHP = min(max(self.intValue(current["bossHP"]), 0), transactionOldMaxHP)
            let remainingRatio = Double(oldHP) / Double(transactionOldMaxHP)
            current["bossMaxHP"] = boss.bossHP
            current["bossHP"] = status == "completed"
                ? 0
                : min(boss.bossHP, max(1, Int((Double(boss.bossHP) * remainingRatio).rounded())))

            let damageScale = Double(boss.bossHP) / Double(transactionOldMaxHP)
            if var players = current["players"] as? [String: Any] {
                for (uid, rawPlayer) in players {
                    guard var player = rawPlayer as? [String: Any] else { continue }
                    let oldDamage = self.intValue(player["totalDamage"])
                    player["totalDamage"] = max(0, Int((Double(oldDamage) * damageScale).rounded()))
                    players[uid] = player
                }
                current["players"] = players
            }

            mutableData.value = current
            return TransactionResult.success(withValue: mutableData)
        }
    }

    func stopObservingRaid() {
        if let raidRef, let raidHandle {
            raidRef.removeObserver(withHandle: raidHandle)
        }
        raidRef = nil
        raidHandle = nil
    }

    // MARK: - ギルドレベル・ランク

    private func observeGuildProgress(guildId: String) {
        stopObservingGuildProgress()
        let ref = db.child("guilds").child(guildId).child("guildProgress")
        guildProgressRef = ref
        guildProgressHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            let value = snapshot.value as? [String: Any] ?? [:]
            let totalExperience = self.intValue(value["totalExperience"])
            let weeklyExperience = self.intValue(self.dictionary(value["weeklyExperience"])[self.currentWeekId()])
            let levelProgress = GuildLevelSystem.progress(for: totalExperience)

            let achievementData = self.dictionary(value["rankAchievements"])
            let achievements = GuildRank.allCases.reduce(into: [GuildRank: Int64]()) { result, rank in
                let timestamp = self.int64Value(achievementData[rank.rawValue])
                if timestamp > 0 { result[rank] = timestamp }
            }

            let claimData = self.dictionary(value["rankRewardClaims"])
            let userId = self.currentUserId
            let claimed = Set(GuildRank.allCases.filter { rank in
                guard let userId else { return false }
                return self.dictionary(claimData[rank.rawValue])[userId] != nil
            })

            let missionAwards = self.dictionary(value["missionAwards"])
            let lifetimeAwardIds = Set(self.dictionary(missionAwards["lifetime"]).keys.map { "lifetime/\($0)" })
            let weeklyAwards = self.dictionary(self.dictionary(missionAwards["weekly"])[self.currentWeekId()])
            let weeklyAwardIds = Set(weeklyAwards.keys.map { "weekly/\(self.currentWeekId())/\($0)" })

            let state = GuildLevelState(
                totalExperience: totalExperience,
                weeklyExperience: weeklyExperience,
                level: levelProgress.level,
                experienceInLevel: levelProgress.experienceInLevel,
                experienceForNextLevel: levelProgress.experienceForNextLevel,
                rankAchievements: achievements,
                claimedRankRewards: claimed
            )
            DispatchQueue.main.async {
                self.guildLevelState = state
                self.awardedMissionExperienceKeys = lifetimeAwardIds.union(weeklyAwardIds)
            }
        }
    }

    private func stopObservingGuildProgress() {
        if let guildProgressRef, let guildProgressHandle {
            guildProgressRef.removeObserver(withHandle: guildProgressHandle)
        }
        guildProgressRef = nil
        guildProgressHandle = nil
        awardedMissionExperienceKeys = []
        pendingMissionExperienceKeys = []
    }

    var claimableRankRewards: [GuildRankReward] {
        guard let userId = currentUserId,
              let member = members.first(where: { $0.id == userId }) else { return [] }
        return GuildRank.allCases.compactMap { rank in
            guard let reward = rank.reward,
                  let achievedAt = guildLevelState.rankAchievements[rank],
                  member.joinedAt <= achievedAt,
                  !guildLevelState.claimedRankRewards.contains(rank) else { return nil }
            return reward
        }
    }

    func claimRankReward(_ rank: GuildRank, completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId,
              let guildId = myGuildId,
              let reward = claimableRankRewards.first(where: { $0.rank == rank }) else {
            completion?(false)
            return
        }

        let ref = db.child("guilds").child(guildId)
            .child("guildProgress/rankRewardClaims").child(rank.rawValue).child(userId)
        ref.runTransactionBlock { data in
            guard data.value == nil || data.value is NSNull else { return TransactionResult.abort() }
            data.value = true
            return TransactionResult.success(withValue: data)
        } andCompletionBlock: { error, committed, _ in
            guard error == nil, committed else {
                DispatchQueue.main.async { completion?(false) }
                return
            }
            AuthManager.shared.grantRewardBundle(
                idempotencyKey: "guildRankReward:\(guildId):\(rank.rawValue)",
                coinAmount: reward.coin,
                itemRewards: reward.items
            ) { rewardSuccess in
                guard rewardSuccess else {
                    ref.removeValue { _, _ in
                        DispatchQueue.main.async { completion?(false) }
                    }
                    return
                }
                DispatchQueue.main.async { completion?(true) }
            }
        }
    }

    private func spawnInitialRaidIfNeeded(guildId: String) {
        let guildBossRef = db.child("guilds").child(guildId).child("guildBoss")
        let legacyWeekId = currentWeekId()
        let legacyRaidRef = db.child("guilds").child(guildId).child("raid").child(legacyWeekId)

        // 旧週次方式のボスがいる場合は、HPと貢献を失わず現在のボスへ移行する。
        legacyRaidRef.observeSingleEvent(of: .value) { snapshot in
            var raidData: [String: Any]
            if var legacyRaid = snapshot.value as? [String: Any] {
                legacyRaid["raidId"] = legacyRaid["raidId"] as? String ?? "legacy-\(legacyWeekId)"
                raidData = legacyRaid
            } else {
                let boss = guildRaidBosses.randomElement() ?? guildRaidBosses[0]
                raidData = self.makeRaidData(boss: boss)
            }

            guildBossRef.runTransactionBlock { mutableData in
                var root = mutableData.value as? [String: Any] ?? [:]
                guard root["current"] == nil || root["current"] is NSNull else {
                    return TransactionResult.abort()
                }
                root["current"] = raidData
                root["summonCorrectAnswers"] = 0
                root["summonTarget"] = self.raidSummonTarget
                mutableData.value = root
                return TransactionResult.success(withValue: mutableData)
            }
        }
    }

    private func makeRaidData(boss: GuildRaidBoss) -> [String: Any] {
        return [
            "raidId": UUID().uuidString,
            "bossName": boss.name,
            "bossImageName": boss.imageName,
            "bossHP": boss.bossHP,
            "bossMaxHP": boss.bossHP,
            "status": "active",
            "createdAt": ServerValue.timestamp()
        ]
    }

    /// 正解時、ボス出現中ならダメージ、討伐後なら次のボスの召喚ノルマに1問を加算する。
    func attackRaidBossIfPossible(damage: Int) {
        guard damage > 0, let guildId = myGuildId, let userId = currentUserId else { return }
        guard let raid else {
            spawnInitialRaidIfNeeded(guildId: guildId)
            return
        }
        guard raid.status == "active", raid.bossHP > 0 else {
            recordSummonCorrectAnswer(guildId: guildId, previousBossName: raid.bossName)
            return
        }

        let raidRef = db.child("guilds").child(guildId).child("guildBoss").child("current")
        raidRef.child("bossHP").runTransactionBlock { mutableData in
            let hp = mutableData.value as? Int ?? 0
            mutableData.value = max(0, hp - damage)
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { error, committed, snapshot in
            guard committed else { return }
            let playerRef = raidRef.child("players").child(userId)
            self.fetchUserBasicInfo(uid: userId) { myName, _, myAvatarName in
                playerRef.child("name").setValue(myName ?? "名無し")
                playerRef.child("avatarName").setValue(myAvatarName ?? "")
            }
            playerRef.child("totalDamage").runTransactionBlock { mutableData in
                let current = mutableData.value as? Int ?? 0
                mutableData.value = current + damage
                return TransactionResult.success(withValue: mutableData)
            }
            playerRef.child("correctCount").runTransactionBlock { mutableData in
                let current = mutableData.value as? Int ?? 0
                mutableData.value = current + 1
                return TransactionResult.success(withValue: mutableData)
            }
            if let hp = snapshot?.value as? Int, hp <= 0 {
                raidRef.child("status").runTransactionBlock { data in
                    guard (data.value as? String ?? "active") != "completed" else {
                        return TransactionResult.abort()
                    }
                    data.value = "completed"
                    return TransactionResult.success(withValue: data)
                } andCompletionBlock: { _, committed, _ in
                    guard committed else { return }
                    raidRef.child("completedAt").setValue(ServerValue.timestamp())
                    self.incrementMissionCounter("raidBossKills", by: 1, guildId: guildId, userId: userId)
                    self.postFeedEvent(guildId: guildId, uid: userId, name: "ギルドボス", text: "を討伐した!")
                }
            }
        }
    }

    private func recordSummonCorrectAnswer(guildId: String, previousBossName: String) {
        let nextBossCandidates = guildRaidBosses.filter { $0.name != previousBossName }
        let nextBoss = nextBossCandidates.randomElement() ?? guildRaidBosses[0]
        let nextRaidData = makeRaidData(boss: nextBoss)
        let guildBossRef = db.child("guilds").child(guildId).child("guildBoss")

        guildBossRef.runTransactionBlock { mutableData in
            guard var root = mutableData.value as? [String: Any],
                  let current = root["current"] as? [String: Any],
                  (current["status"] as? String ?? "active") == "completed" else {
                return TransactionResult.abort()
            }

            let progress = min(self.intValue(root["summonCorrectAnswers"]) + 1, self.raidSummonTarget)
            if progress >= self.raidSummonTarget {
                root["current"] = nextRaidData
                root["summonCorrectAnswers"] = 0
            } else {
                root["summonCorrectAnswers"] = progress
            }
            root["summonTarget"] = self.raidSummonTarget
            mutableData.value = root
            return TransactionResult.success(withValue: mutableData)
        }
    }

    // MARK: - ギルドミッション

    private func observeMissions(guildId: String) {
        stopObservingMissions()
        let ref = db.child("guilds").child(guildId).child("guildMissions")
        missionsRef = ref
        missionsHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            let root = snapshot.value as? [String: Any] ?? [:]
            let weeklyRoot = root["weekly"] as? [String: Any] ?? [:]
            self.weeklyMissionData = weeklyRoot[self.currentWeekId()] as? [String: Any] ?? [:]
            self.lifetimeMissionData = root["lifetime"] as? [String: Any] ?? [:]
            DispatchQueue.main.async { self.rebuildMissionProgresses() }
        }
    }

    private func stopObservingMissions() {
        if let missionsRef, let missionsHandle {
            missionsRef.removeObserver(withHandle: missionsHandle)
        }
        missionsRef = nil
        missionsHandle = nil
        weeklyMissionData = [:]
        lifetimeMissionData = [:]
    }

    private func rebuildMissionProgresses() {
        let progresses = GuildMissionCatalog.all.map(makeMissionProgress)
        missionProgresses = progresses
        awardGuildExperienceForCompletedMissions(progresses)

        if let legacy = progresses.first(where: { $0.id == "correct_300" }) {
            mission = GuildMissionState(
                weekId: currentWeekId(),
                correctTotal: legacy.current,
                target: legacy.target,
                claimedBy: legacy.isClaimed ? [currentUserId].compactMap { $0 } : []
            )
        }
    }

    private func awardGuildExperienceForCompletedMissions(_ progresses: [GuildMissionProgress]) {
        guard let guildId = myGuildId else { return }
        progresses.filter(\.isCompleted).forEach { progress in
            let isLifetime = progress.definition.section.isLifetime
            let awardKey = isLifetime
                ? "lifetime/\(progress.id)"
                : "weekly/\(currentWeekId())/\(progress.id)"
            guard !awardedMissionExperienceKeys.contains(awardKey),
                  !pendingMissionExperienceKeys.contains(awardKey) else { return }
            pendingMissionExperienceKeys.insert(awardKey)
            awardGuildExperience(for: progress.definition, guildId: guildId, awardKey: awardKey)
        }
    }

    private func awardGuildExperience(
        for definition: GuildMissionDefinition,
        guildId: String,
        awardKey: String
    ) {
        let weekId = currentWeekId()
        let experience = definition.rewardCoin
        let ref = db.child("guilds").child(guildId).child("guildProgress")
        var newlyReachedRanks: [GuildRank] = []

        ref.runTransactionBlock { data in
            newlyReachedRanks = []
            var root = self.dictionary(data.value)
            var missionAwards = self.dictionary(root["missionAwards"])

            if definition.section.isLifetime {
                var lifetimeAwards = self.dictionary(missionAwards["lifetime"])
                guard lifetimeAwards[definition.id] == nil else { return TransactionResult.abort() }
                lifetimeAwards[definition.id] = experience
                missionAwards["lifetime"] = lifetimeAwards
            } else {
                var weeklyAwards = self.dictionary(missionAwards["weekly"])
                var currentWeekAwards = self.dictionary(weeklyAwards[weekId])
                guard currentWeekAwards[definition.id] == nil else { return TransactionResult.abort() }
                currentWeekAwards[definition.id] = experience
                weeklyAwards[weekId] = currentWeekAwards
                missionAwards["weekly"] = weeklyAwards
            }

            let oldExperience = self.intValue(root["totalExperience"])
            let newExperience = oldExperience + experience
            let newLevel = GuildLevelSystem.progress(for: newExperience).level
            root["totalExperience"] = newExperience
            root["missionAwards"] = missionAwards

            var weeklyExperience = self.dictionary(root["weeklyExperience"])
            weeklyExperience[weekId] = self.intValue(weeklyExperience[weekId]) + experience
            root["weeklyExperience"] = weeklyExperience

            var achievements = self.dictionary(root["rankAchievements"])
            let achievedAt = Int64(Date().timeIntervalSince1970 * 1_000)
            for rank in GuildRank.allCases where rank != .beginner && newLevel >= rank.minimumLevel {
                if achievements[rank.rawValue] == nil {
                    achievements[rank.rawValue] = achievedAt
                    newlyReachedRanks.append(rank)
                }
            }
            root["rankAchievements"] = achievements

            data.value = root
            return TransactionResult.success(withValue: data)
        } andCompletionBlock: { error, committed, snapshot in
            DispatchQueue.main.async { self.pendingMissionExperienceKeys.remove(awardKey) }
            guard error == nil, committed,
                  let value = snapshot?.value as? [String: Any] else { return }

            let totalExperience = self.intValue(value["totalExperience"])
            self.updateGuildIndexProgress(guildId: guildId, totalExperience: totalExperience)

            if let highestRank = newlyReachedRanks.max(by: { $0.minimumLevel < $1.minimumLevel }) {
                self.postFeedEvent(
                    guildId: guildId,
                    uid: "guild",
                    name: "ギルド",
                    text: "ランクが\(highestRank.title)になりました!"
                )
            }
        }
    }

    private func updateGuildIndexProgress(guildId: String, totalExperience: Int) {
        let scope = guild?.indexScope ?? commonIndexScope
        let indexRef = db.child("guildIndex").child(scope).child(guildId)
        indexRef.child("guildExperience").runTransactionBlock { data in
            data.value = max(self.intValue(data.value), totalExperience)
            return TransactionResult.success(withValue: data)
        }
        let level = GuildLevelSystem.progress(for: totalExperience).level
        indexRef.child("guildLevel").runTransactionBlock { data in
            data.value = max(self.intValue(data.value), level)
            return TransactionResult.success(withValue: data)
        }
    }

    private func makeMissionProgress(_ definition: GuildMissionDefinition) -> GuildMissionProgress {
        let result = evaluate(definition)
        let target = missionTarget(for: definition)
        let claimData = definition.section.isLifetime ? lifetimeMissionData : weeklyMissionData
        let claims = claimData["claims"] as? [String: Any] ?? [:]
        let missionClaims = claims[definition.id] as? [String: Any] ?? [:]
        let isClaimed = currentUserId.map { missionClaims[$0] != nil } ?? false
        return GuildMissionProgress(
            definition: definition,
            current: min(max(0, result.current), target),
            target: target,
            isCompleted: result.completed,
            isClaimed: isClaimed,
            detail: result.detail
        )
    }

    private func evaluate(_ definition: GuildMissionDefinition) -> (current: Int, completed: Bool, detail: String?) {
        let weeklyCounters = dictionary(weeklyMissionData["counters"])
        let weeklyPlayers = nestedDictionary(weeklyMissionData["players"])
        let weeklyLoginDays = memberDays(weeklyMissionData["loginDays"])
        let weeklyActivityDays = memberDays(weeklyMissionData["activityDays"])
        let lifetimeLoginDays = memberDays(lifetimeMissionData["loginDays"])
        let target = missionTarget(for: definition)

        switch definition.rule {
        case .counter(let key):
            let value = intValue(weeklyCounters[key])
            return (value, value >= target, nil)
        case .answeredMembers(let minimumAnswers):
            let value = weeklyPlayers.values.filter { intValue($0["answers"]) >= minimumAnswers }.count
            return (value, value >= target, nil)
        case .activeMembers(let minimumDays):
            let activeDaysByMember = invert(dayMembers: weeklyActivityDays)
            let value = activeDaysByMember.values.filter { $0.count >= minimumDays }.count
            return (value, value >= target, "各メンバーが活動した日数で判定")
        case .playerCount(let field, let minimumValue):
            let value = weeklyPlayers.values.filter { intValue($0[field]) >= minimumValue }.count
            return (value, value >= target, "1人あたり\(minimumValue)以上")
        case .accuracy(let minimumAnswers, let minimumPercent):
            let answers = intValue(weeklyCounters["answers"])
            let correct = intValue(weeklyCounters["correctAnswers"])
            let percent = answers > 0 ? Int((Double(correct) / Double(answers) * 100).rounded(.down)) : 0
            return (min(answers, minimumAnswers), answers >= minimumAnswers && percent >= minimumPercent, "現在の正解率 \(percent)%")
        case .correctStreak:
            let value = intValue(weeklyCounters["maxCorrectStreak"])
            return (value, value >= target, nil)
        case .activityStreak(let minimumMembers):
            let value = longestGuildStreak(in: weeklyActivityDays, minimumMembers: minimumMembers)
            return (value, value >= target, "毎日\(minimumMembers)人以上")
        case .loginMemberDays(let lifetime):
            let days = lifetime ? lifetimeLoginDays : weeklyLoginDays
            let value = days.values.reduce(0) { $0 + $1.count }
            return (value, value >= target, nil)
        case .loginGuildStreak(let minimumMembers, let lifetime):
            let days = lifetime ? lifetimeLoginDays : weeklyLoginDays
            let value = longestGuildStreak(in: days, minimumMembers: minimumMembers)
            return (value, value >= target, "毎日\(minimumMembers)人以上")
        case .loginMemberStreak(let requiredDays, let lifetime):
            let days = lifetime ? lifetimeLoginDays : weeklyLoginDays
            let memberDates = invert(dayMembers: days)
            let value = memberDates.values.filter { longestDateStreak($0) >= requiredDays }.count
            return (value, value >= target, "1人あたり\(requiredDays)日連続")
        case .raidDefeated:
            let completed = raid?.status == "completed"
            return (completed ? 1 : 0, completed, nil)
        case .raidCorrectPlayers(let minimumCorrect):
            let count = raid?.players.filter { $0.correctCount >= minimumCorrect }.count ?? 0
            let completed = raid?.status == "completed" && count >= target
            return (count, completed, "1人あたり\(minimumCorrect)問以上＋討伐")
        case .raidDamagePlayers(let maxHPPercent):
            let minimumDamage = max(1, (max(1, raid?.bossMaxHP ?? 1) * maxHPPercent) / 100)
            let count = raid?.players.filter { $0.totalDamage >= minimumDamage }.count ?? 0
            return (count, count >= target, "1人あたり\(minimumDamage)ダメージ以上")
        case .raidDamage:
            let damage = raid?.players.reduce(0) { $0 + $1.totalDamage } ?? 0
            return (damage, damage >= target, "目標は現在のボス最大HP")
        case .raidParticipantsAfterDefeat:
            let count = raid?.players.filter { $0.correctCount > 0 }.count ?? 0
            let completed = raid?.status == "completed" && count >= target
            return (count, completed, "攻撃参加＋討伐")
        }
    }

    private func missionTarget(for definition: GuildMissionDefinition) -> Int {
        if case .raidDamage = definition.rule {
            return max(1, raid?.bossMaxHP ?? definition.target)
        }
        return max(1, definition.target)
    }

    func claimMissionReward(missionId: String, completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId,
              let guildId = myGuildId,
              let progress = missionProgresses.first(where: { $0.id == missionId }),
              progress.isCompleted,
              !progress.isClaimed else {
            completion?(false)
            return
        }

        let scopePath = progress.definition.section.isLifetime
            ? "guildMissions/lifetime/claims"
            : "guildMissions/weekly/\(currentWeekId())/claims"
        let ref = db.child("guilds").child(guildId).child(scopePath).child(missionId).child(userId)
        ref.runTransactionBlock { data in
            guard data.value == nil || data.value is NSNull else { return TransactionResult.abort() }
            data.value = true
            return TransactionResult.success(withValue: data)
        } andCompletionBlock: { error, committed, _ in
            guard error == nil, committed else {
                DispatchQueue.main.async { completion?(false) }
                return
            }
            AuthManager.shared.grantRewardBundle(
                idempotencyKey: "guildMissionReward:\(guildId):\(progress.definition.section.rawValue):\(progress.definition.id):\(userId)",
                coinAmount: progress.definition.rewardCoin,
                itemRewards: progress.definition.rewardItems
            ) { rewardSuccess in
                guard rewardSuccess else {
                    ref.removeValue { _, _ in
                        DispatchQueue.main.async { completion?(false) }
                    }
                    return
                }
                DispatchQueue.main.async { completion?(true) }
            }
        }
    }

    /// 旧画面からの呼び出しを維持する互換API。
    func claimMissionReward(completion: ((Bool) -> Void)? = nil) {
        claimMissionReward(missionId: "correct_300", completion: completion)
    }

    func recordAnswer(isCorrect: Bool) {
        withGuildContext { guildId, userId in
            let countersRef = self.weeklyMissionRef(guildId: guildId).child("counters")
            countersRef.runTransactionBlock { data in
                var counters = data.value as? [String: Any] ?? [:]
                let answers = self.intValue(counters["answers"]) + 1
                let correctAnswers = self.intValue(counters["correctAnswers"]) + (isCorrect ? 1 : 0)
                let currentStreak = isCorrect ? self.intValue(counters["currentCorrectStreak"]) + 1 : 0
                counters["answers"] = answers
                counters["correctAnswers"] = correctAnswers
                counters["currentCorrectStreak"] = currentStreak
                counters["maxCorrectStreak"] = max(self.intValue(counters["maxCorrectStreak"]), currentStreak)
                data.value = counters
                return TransactionResult.success(withValue: data)
            }
            self.incrementPlayerMissionCounter("answers", by: 1, guildId: guildId, userId: userId)
            if isCorrect {
                self.incrementPlayerMissionCounter("correctAnswers", by: 1, guildId: guildId, userId: userId)
            }
            self.weeklyMissionRef(guildId: guildId)
                .child("activityDays").child(self.currentGuildDayId()).child(userId).setValue(true)
        }
    }

    func recordExperience(_ amount: Int) { recordCounter("experience", amount: amount) }
    func recordReviewCompleted() { recordCounter("reviews", amount: 1) }
    func recordDungeonStep() { recordCounter("dungeonSteps", amount: 1) }

    func recordStoryCompleted(isBoss: Bool) {
        recordCounter("storyClears", amount: 1)
        if isBoss { recordCounter("bossKills", amount: 1) }
    }

    func recordGuerrillaParticipation() {
        recordCounter("guerrillaParticipations", amount: 1, playerField: "guerrillaParticipations")
    }

    func recordGuerrillaResult(isVictory: Bool, isFirstPlace: Bool) {
        if isVictory { recordCounter("guerrillaWins", amount: 1) }
        if isFirstPlace { recordCounter("guerrillaFirsts", amount: 1) }
    }

    func recordDailyMissionCompleted() { recordCounter("dailyCompletes", amount: 1) }

    private func recordCounter(_ key: String, amount: Int, playerField: String? = nil) {
        guard amount > 0 else { return }
        withGuildContext { guildId, userId in
            self.incrementMissionCounter(key, by: amount, guildId: guildId, userId: userId)
            if let playerField {
                self.incrementPlayerMissionCounter(playerField, by: amount, guildId: guildId, userId: userId)
            }
        }
    }

    private func incrementMissionCounter(_ key: String, by amount: Int, guildId: String, userId: String) {
        let ref = weeklyMissionRef(guildId: guildId).child("counters").child(key)
        ref.runTransactionBlock { data in
            data.value = self.intValue(data.value) + amount
            return TransactionResult.success(withValue: data)
        }
    }

    private func incrementPlayerMissionCounter(_ key: String, by amount: Int, guildId: String, userId: String) {
        let ref = weeklyMissionRef(guildId: guildId).child("players").child(userId).child(key)
        ref.runTransactionBlock { data in
            data.value = self.intValue(data.value) + amount
            return TransactionResult.success(withValue: data)
        }
    }

    private func recordLoginIfNeeded(guildId: String, userId: String) {
        let dayId = currentGuildDayId()
        weeklyMissionRef(guildId: guildId).child("loginDays").child(dayId).child(userId).setValue(true)
        db.child("guilds").child(guildId).child("guildMissions/lifetime/loginDays").child(dayId).child(userId).setValue(true)
    }

    private func withGuildContext(_ action: @escaping (String, String) -> Void) {
        guard let userId = currentUserId else { return }
        if let guildId = myGuildId {
            action(guildId, userId)
            return
        }
        db.child("userGuild").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let guildId = snapshot.value as? String, !guildId.isEmpty else { return }
            action(guildId, userId)
        }
    }

    private func weeklyMissionRef(guildId: String) -> DatabaseReference {
        db.child("guilds").child(guildId).child("guildMissions/weekly").child(currentWeekId())
    }

    private func dictionary(_ value: Any?) -> [String: Any] {
        value as? [String: Any] ?? [:]
    }

    private func nestedDictionary(_ value: Any?) -> [String: [String: Any]] {
        dictionary(value).reduce(into: [:]) { result, entry in
            result[entry.key] = dictionary(entry.value)
        }
    }

    private func intValue(_ value: Any?) -> Int {
        if let value = value as? Int { return value }
        if let value = value as? NSNumber { return value.intValue }
        if let value = value as? String { return Int(value) ?? 0 }
        return 0
    }

    private func int64Value(_ value: Any?) -> Int64 {
        if let value = value as? Int64 { return value }
        if let value = value as? NSNumber { return value.int64Value }
        if let value = value as? String { return Int64(value) ?? 0 }
        return 0
    }

    private func memberDays(_ value: Any?) -> [String: Set<String>] {
        dictionary(value).reduce(into: [:]) { result, dayEntry in
            result[dayEntry.key] = Set(dictionary(dayEntry.value).keys)
        }
    }

    private func invert(dayMembers: [String: Set<String>]) -> [String: Set<String>] {
        dayMembers.reduce(into: [:]) { result, dayEntry in
            dayEntry.value.forEach { result[$0, default: []].insert(dayEntry.key) }
        }
    }

    private func longestGuildStreak(in dayMembers: [String: Set<String>], minimumMembers: Int) -> Int {
        longestDateStreak(Set(dayMembers.compactMap { $0.value.count >= minimumMembers ? $0.key : nil }))
    }

    private func longestDateStreak(_ dayIds: Set<String>) -> Int {
        let dates = dayIds.compactMap { guildDayFormatter.date(from: $0) }.sorted()
        guard !dates.isEmpty else { return 0 }
        var longest = 1
        var current = 1
        for index in 1..<dates.count {
            let days = Calendar(identifier: .gregorian).dateComponents([.day], from: dates[index - 1], to: dates[index]).day ?? 0
            if days == 1 {
                current += 1
                longest = max(longest, current)
            } else if days > 1 {
                current = 1
            }
        }
        return longest
    }

    private var guildDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private func currentGuildDayId(_ date: Date = Date()) -> String {
        guildDayFormatter.string(from: date.addingTimeInterval(-5 * 60 * 60))
    }

    // MARK: - 活動フィード

    private func observeFeed(guildId: String) {
        stopObservingFeed()
        let ref = db.child("guilds").child(guildId).child("feed").queryLimited(toLast: 30)
        feedRef = ref
        feedHandle = ref.observe(.value) { [weak self] snapshot in
            let items: [GuildFeedItem] = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .compactMap { child -> GuildFeedItem? in
                    guard let value = child.value as? [String: Any],
                          let uid = value["uid"] as? String,
                          let name = value["name"] as? String,
                          let text = value["text"] as? String else { return nil }
                    return GuildFeedItem(
                        id: child.key,
                        uid: uid,
                        name: name,
                        text: text,
                        timestamp: (value["timestamp"] as? Int64) ?? 0
                    )
                }
                .sorted { $0.timestamp > $1.timestamp }
            DispatchQueue.main.async { self?.feed = items }
        }
    }

    func stopObservingFeed() {
        if let feedRef, let feedHandle {
            feedRef.removeObserver(withHandle: feedHandle)
        }
        feedRef = nil
        feedHandle = nil
    }

    private func postFeedEvent(guildId: String, uid: String, name: String, text: String) {
        let feedRef = db.child("guilds").child(guildId).child("feed").childByAutoId()
        feedRef.setValue([
            "uid": uid,
            "name": name,
            "text": text,
            "timestamp": ServerValue.timestamp()
        ])
    }

    // MARK: - Helpers

    private func indexScope(from guildValue: [String: Any]) -> String {
        if let scope = guildValue["indexScope"] as? String, !scope.isEmpty {
            return scope
        }
        // 旧データは試験区分の下にあるため、更新・削除時だけ保存先として引き継ぐ。
        if let legacyScope = guildValue["targetExam"] as? String, !legacyScope.isEmpty {
            return legacyScope
        }
        return commonIndexScope
    }

    private func fetchUserBasicInfo(uid: String, completion: @escaping (String?, Int?, String?) -> Void) {
        db.child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, nil, nil)
                return
            }
            let name = value["userName"] as? String
            let avatarName = value["usedAvatarName"] as? String
            completion(name?.isEmpty == false ? name : nil, value["level"] as? Int, avatarName?.isEmpty == false ? avatarName : nil)
        }
    }

    private func generateUniqueInviteCode(attempt: Int = 0, completion: @escaping (String?) -> Void) {
        guard attempt < 10 else {
            completion(nil)
            return
        }
        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let code = String((0..<6).compactMap { _ in characters.randomElement() })
        db.child("guildInviteCodes").child(code).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.generateUniqueInviteCode(attempt: attempt + 1, completion: completion)
            } else {
                completion(code)
            }
        }
    }

    private func currentWeekId(_ date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        let shiftedDate = date.addingTimeInterval(-5 * 60 * 60)
        let year = calendar.component(.yearForWeekOfYear, from: shiftedDate)
        let week = calendar.component(.weekOfYear, from: shiftedDate)
        return String(format: "%04d-W%02d", year, week)
    }
}
