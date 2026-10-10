import Foundation
import FirebaseDatabaseInternal
import SwiftUI
import AVKit
import UIKit

enum GachaRarity: String, Codable {
    case normal
    case rare
    case Rrare
    case mekaRare
    case superRare
    case RsuperRare
    case mekaSuperRare
    case ultraRare
    case RultraRare
    case mekaUltraRare
    case legendRare
    case mekaLegendRare
    case godRare          // 神レア
    case godSuperRare     // 神スーパーレア
    case godUltraRare     // 神ウルトラレア
    case godLegendRare    // 神レジェンドレア
    case godMythicRare    // 神話レア（レジェンドの上、最高レアリティ）

    case guardianRare          // 四聖獣：レア
    case guardianSuperRare     // 四聖獣：スーパーレア
    case guardianUltraRare     // 四聖獣：ウルトラレア
    case guardianLegendRare    // 四聖獣：レジェンドレア
    case guardianUltimateRare  // 四聖獣：アルティメットレア（最高レアリティ）

    case deepSeaRare
    case deepSeaSuperRare
    case deepSeaUltraRare
    case deepSeaLegendRare
    case deepSeaUltimateRare


    var displayString: String {
        switch self {
        case .normal:
            return "ノーマル"
        case .rare, .Rrare, .mekaRare,.godRare, .guardianRare, .deepSeaRare:
            return "レア"
        case .superRare, .RsuperRare, .mekaSuperRare,.godSuperRare, .guardianSuperRare, .deepSeaSuperRare:
            return "スーパーレア"
        case .ultraRare, .RultraRare, .mekaUltraRare,.godUltraRare, .guardianUltraRare, .deepSeaUltraRare:
            return "ウルトラレア"
        case .legendRare, .mekaLegendRare,.godLegendRare, .guardianLegendRare, .deepSeaLegendRare:
            return "レジェンドレア"
        case .godMythicRare:
            return "神レア"
        case .guardianUltimateRare, .deepSeaUltimateRare:
            return "アルティメットレア"
        }
    }
    
    var movieName: String {
        return self.rawValue
    }
    
    var gradientColors: [Color] {
        switch self {
        case .normal:
            return [Color.gray.opacity(0.6), Color.gray.opacity(0.3)]
        case .rare, .Rrare, .mekaRare:
            return [Color.blue.opacity(0.6), Color.cyan.opacity(0.3)]
        case .superRare, .RsuperRare, .mekaSuperRare:
            return [Color.purple.opacity(0.6), Color.pink.opacity(0.3)]
        case .ultraRare, .RultraRare, .mekaUltraRare:
            return [Color.orange.opacity(0.6), Color.yellow.opacity(0.3)]
        case .legendRare, .mekaLegendRare:
            return [Color.red.opacity(0.6), Color.orange.opacity(0.4)]
        case .godRare:
            return [Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.7), Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.4)]
        case .godSuperRare:
            return [Color(red: 0.9, green: 0.3, blue: 0.5).opacity(0.7), Color(red: 1.0, green: 0.5, blue: 0.3).opacity(0.4)]
        case .godUltraRare:
            return [Color(red: 0.9, green: 0.1, blue: 0.1).opacity(0.8), Color(red: 1.0, green: 0.4, blue: 0.0).opacity(0.5)]
        case .godLegendRare:
            return [Color(red: 0.9, green: 0.8, blue: 0.0).opacity(0.8), Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.5)]
        case .godMythicRare:
            return [Color(red: 1.0, green: 0.9, blue: 0.3).opacity(0.9), Color(red: 1.0, green: 1.0, blue: 0.8).opacity(0.6)]

        case .guardianRare:
            return [Color(red: 0.2, green: 0.55, blue: 0.45).opacity(0.7), Color(red: 0.3, green: 0.7, blue: 0.55).opacity(0.4)]
        case .guardianSuperRare:
            return [Color(red: 0.15, green: 0.45, blue: 0.55).opacity(0.7), Color(red: 0.25, green: 0.6, blue: 0.6).opacity(0.4)]
        case .guardianUltraRare:
            return [Color(red: 0.55, green: 0.15, blue: 0.5).opacity(0.75), Color(red: 0.7, green: 0.3, blue: 0.6).opacity(0.45)]
        case .guardianLegendRare:
            return [Color(red: 0.1, green: 0.35, blue: 0.75).opacity(0.8), Color(red: 0.25, green: 0.55, blue: 0.9).opacity(0.5)]
        case .guardianUltimateRare:
            return [Color(red: 0.85, green: 0.7, blue: 0.15).opacity(0.9), Color(red: 0.95, green: 0.85, blue: 0.4).opacity(0.6)]
        case .deepSeaRare:
            return [Color(hex: "137FA0").opacity(0.7), Color(hex: "55D9EF").opacity(0.4)]
        case .deepSeaSuperRare:
            return [Color(hex: "3159B8").opacity(0.7), Color(hex: "58CDE4").opacity(0.4)]
        case .deepSeaUltraRare:
            return [Color(hex: "7251CA").opacity(0.8), Color(hex: "A5D9F5").opacity(0.5)]
        case .deepSeaLegendRare:
            return [Color(hex: "264F9B").opacity(0.8), Color(hex: "D8BC70").opacity(0.5)]
        case .deepSeaUltimateRare:
            return [Color(hex: "67E9FF").opacity(0.9), Color(hex: "FFF0AF").opacity(0.6)]
        }
    }
}

enum GachaMode {
    case normal
    case rare
    case meka
    case god
    case guardian   // 四聖獣ガチャ
    case deepSea
}

class GachaManager {
    struct Item: Codable {
        let name: String
        let attack: Int
        let health: Int
        let probability: Int
        let rarity: GachaRarity
    }
    
    private let mode: GachaMode
    private var items: [Item] = []
    
    init(mode: GachaMode) {
        self.mode = mode
        setupItems()
    }
    
    var catalogItems: [Item] {
        items
    }
    
    var gachaCost: Int {
        switch mode {
        case .normal:
            return 300
        case .rare, .meka:
            return 600
        case .god:        // ← 追加
            return 1000
        case .guardian:
            return 1000
        case .deepSea:
            return 1500
        }
    }
    
    private func setupItems() {
        switch mode {
        case .normal:
            items = [
                Item(name: "ネッキー",     attack: 10, health: 20, probability: 25,  rarity: .normal),
                Item(name: "ピョン吉",     attack: 15, health: 15, probability: 25,  rarity: .normal),
                Item(name: "ルイーカ",     attack: 20, health: 10, probability: 25,  rarity: .normal),
                Item(name: "もりこう",     attack: 20, health: 100, probability: 25, rarity: .normal),
                Item(name: "うっさん",     attack: 25, health: 150, probability: 25, rarity: .normal),
                Item(name: "キリキリン",   attack: 30, health: 200, probability: 25, rarity: .normal),
                Item(name: "カゲロウ",     attack: 35, health: 220, probability: 10, rarity: .rare),
                Item(name: "ライム",       attack: 40, health: 240, probability: 10, rarity: .rare),
                Item(name: "ラオン",       attack: 45, health: 260, probability: 10, rarity: .rare),
                Item(name: "レッドドラゴン", attack: 47, health: 280, probability: 5, rarity: .superRare),
                Item(name: "ブルードラゴン", attack: 48, health: 285, probability: 5, rarity: .superRare),
                Item(name: "レインボードラゴン", attack: 50, health: 300, probability: 3, rarity: .ultraRare)
            ]

        case .rare:
            items = [
                Item(name: "忍太",         attack: 20, health: 210, probability: 25, rarity: .Rrare),
                Item(name: "ぴょこん",     attack: 20, health: 215, probability: 25, rarity: .Rrare),
                Item(name: "かみ蔵",       attack: 20, health: 220, probability: 25, rarity: .Rrare),
                Item(name: "キャット夫人", attack: 25, health: 225, probability: 25, rarity: .Rrare),
                Item(name: "ミッチー",     attack: 30, health: 240, probability: 25, rarity: .Rrare),
                Item(name: "ライム兄",     attack: 40, health: 250, probability: 10, rarity: .Rrare),
                Item(name: "幸福のパンダ", attack: 47, health: 260, probability: 5, rarity: .Rrare),
                Item(name: "英雄デル",     attack: 50, health: 300, probability: 10, rarity: .RsuperRare),
                Item(name: "覚醒 ライム",   attack: 56, health: 300, probability: 10, rarity: .RsuperRare),
                Item(name: "七福神 玉",    attack: 72, health: 350, probability: 5, rarity: .RultraRare),
                Item(name: "七福神 福天丸", attack: 75, health: 380, probability: 3, rarity: .RultraRare),
                Item(name: "七福神 金満徳", attack: 100, health: 500, probability: 3, rarity: .legendRare)
            ]

        case .meka:
            items = [
                Item(name: "メカマウス",       attack: 20, health: 210, probability: 25, rarity: .mekaRare),
                Item(name: "メカドック",       attack: 20, health: 215, probability: 25, rarity: .mekaRare),
                Item(name: "メカベアー",       attack: 20, health: 220, probability: 25, rarity: .mekaRare),
                Item(name: "ロボン",           attack: 25, health: 225, probability: 25, rarity: .mekaRare),
                Item(name: "ロボノコ",         attack: 30, health: 240, probability: 25, rarity: .mekaRare),
                Item(name: "ロボカー",         attack: 40, health: 250, probability: 10, rarity: .mekaRare),
                Item(name: "バースト",         attack: 47, health: 260, probability: 5, rarity: .mekaRare),
                Item(name: "古代ロボ マーク",   attack: 30, health: 600, probability: 10, rarity: .mekaSuperRare),
                Item(name: "メカライオネル",   attack: 70, health: 200, probability: 10, rarity: .mekaSuperRare),
                Item(name: "ロボ長 バーグ",     attack: 60, health: 400, probability: 5, rarity: .mekaUltraRare),
                Item(name: "悪意ロボ ルーク",   attack: 70, health: 450, probability: 3, rarity: .mekaUltraRare),
                Item(name: "究極完全体バーグ",   attack: 200, health: 400, probability: 3, rarity: .mekaLegendRare)
            ]
        case .god:
             items = [
                 // 神レア (確率高め、基本キャラ)
                 Item(name: "天狗丸",         attack: 40, health: 300, probability: 20, rarity: .godRare),
                 Item(name: "神龍子",         attack: 45, health: 310, probability: 20, rarity: .godRare),
                 Item(name: "雷神太郎",       attack: 50, health: 320, probability: 20, rarity: .godRare),
                 Item(name: "風神次郎",       attack: 55, health: 330, probability: 15, rarity: .godRare),
                 
                 // 神スーパーレア (中確率)
                 Item(name: "阿修羅王",       attack: 80, health: 400, probability: 10, rarity: .godSuperRare),
                 Item(name: "不動明王",       attack: 85, health: 420, probability: 8,  rarity: .godSuperRare),
                 Item(name: "毘沙門天",       attack: 90, health: 400, probability: 8,  rarity: .godSuperRare),
                 
                 // 神ウルトラレア (低確率)
                 Item(name: "天照大神",       attack: 120, health: 350, probability: 5, rarity: .godUltraRare),
                 Item(name: "月読命",         attack: 130, health: 300, probability: 4, rarity: .godUltraRare),
                 
                 // 神レジェンドレア (かなり低確率)
                 Item(name: "須佐之男命",     attack: 300, health: 400, probability: 3, rarity: .godLegendRare),
                 Item(name: "大国主命",       attack: 400, health: 350, probability: 2, rarity: .godLegendRare),
                 
                 // 神話レア (最高レアリティ、1%!!!)
                 Item(name: "創世神イザナギ",  attack: 500, health: 800, probability: 1, rarity: .godMythicRare)
             ]
        case .guardian:
            // 確率は合計10000のウェイト（= 0.01%単位）で管理
            items = [
                // レア (幼体、四方守護獣の子)
                Item(name: "蒼龍の子 ソウ",     attack: 40,  health: 300, probability: 1800, rarity: .guardianRare),
                Item(name: "白虎の子 ライ",     attack: 45,  health: 310, probability: 1800, rarity: .guardianRare),
                Item(name: "朱雀の雛 スザク丸", attack: 50,  health: 320, probability: 1800, rarity: .guardianRare),
                Item(name: "玄武の童 ゲンブ",   attack: 55,  health: 330, probability: 1300, rarity: .guardianRare),

                // スーパーレア (関連する瑞獣)
                Item(name: "麒麟",             attack: 80,  health: 400, probability: 900, rarity: .guardianSuperRare),
                Item(name: "鳳凰",             attack: 85,  health: 380, probability: 700, rarity: .guardianSuperRare),
                Item(name: "応龍",             attack: 90,  health: 420, probability: 700, rarity: .guardianSuperRare),

                // ウルトラレア (成体、四聖獣の一部)
                Item(name: "朱雀",             attack: 130, health: 350, probability: 400, rarity: .guardianUltraRare),
                Item(name: "玄武",             attack: 110, health: 480, probability: 350, rarity: .guardianUltraRare),

                // レジェンドレア (成体、四聖獣の一部)
                Item(name: "青龍",             attack: 320, health: 420, probability: 120, rarity: .guardianLegendRare),
                Item(name: "白虎",             attack: 380, health: 400, probability: 80,  rarity: .guardianLegendRare),

                // アルティメットレア (最高峰、五行の中央に座す黄龍。0.5%)
                Item(name: "黄龍",             attack: 500, health: 800, probability: 50,  rarity: .guardianUltimateRare)
            ]
        case .deepSea:
            // 合計10000のウェイト。1 = 0.01%、最高レアは0.20%。
            items = [
                Item(name: "灯クラゲ ルミ", attack: 35, health: 340, probability: 2000, rarity: .deepSeaRare),
                Item(name: "メンダコ メロ", attack: 40, health: 350, probability: 2000, rarity: .deepSeaRare),
                Item(name: "チョウチン魚 ピカリ", attack: 55, health: 300, probability: 2000, rarity: .deepSeaRare),
                Item(name: "ヨロイエビ ガンゾ", attack: 45, health: 380, probability: 1500, rarity: .deepSeaRare),
                Item(name: "宝石ガニ クリスタ", attack: 70, health: 480, probability: 800, rarity: .deepSeaSuperRare),
                Item(name: "影鮫 シャドウ", attack: 105, health: 330, probability: 600, rarity: .deepSeaSuperRare),
                Item(name: "古代海亀 グランシェル", attack: 65, health: 600, probability: 600, rarity: .deepSeaSuperRare),
                Item(name: "幽灯鯨 ファントム", attack: 120, health: 600, probability: 220, rarity: .deepSeaUltraRare),
                Item(name: "大王烏賊 クラーケン", attack: 170, health: 420, probability: 180, rarity: .deepSeaUltraRare),
                Item(name: "深淵海蛇 アビス", attack: 480, health: 500, probability: 50, rarity: .deepSeaLegendRare),
                Item(name: "海皇鎧魚 ダンクル", attack: 350, health: 800, probability: 30, rarity: .deepSeaLegendRare),
                Item(name: "深海王 リヴァイアス", attack: 550, health: 1000, probability: 20, rarity: .deepSeaUltimateRare)
            ]
        }
    }
    
    func shuffleItems() {
        items.shuffle()
    }
    
    func drawGacha() -> Item? {
        let totalProbability = items.map { $0.probability }.reduce(0, +)
        let randomNumber = Int.random(in: 0..<totalProbability)
        
        var accumulatedProbability = 0
        for item in items {
            accumulatedProbability += item.probability
            if randomNumber < accumulatedProbability {
                return item
            }
        }
        
        return items.first
    }
}

enum GachaCatalogTier: Int, CaseIterable, Identifiable {
    case normal
    case rare
    case superRare
    case ultraRare
    case legendRare
    case mythicRare
    case ultimateRare

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .normal:
            return "ノーマル"
        case .rare:
            return "レア"
        case .superRare:
            return "スーパーレア"
        case .ultraRare:
            return "ウルトラレア"
        case .legendRare:
            return "レジェンド"
        case .mythicRare:
            return "神レア"
        case .ultimateRare:
            return "アルティメットレア"
        }
    }

    var color: Color {
        switch self {
        case .normal:
            return Color(red: 0.62, green: 0.64, blue: 0.7)
        case .rare:
            return Color(red: 0.34, green: 0.58, blue: 0.96)
        case .superRare:
            return Color(red: 0.74, green: 0.38, blue: 0.96)
        case .ultraRare:
            return Color(red: 1.0, green: 0.66, blue: 0.22)
        case .legendRare:
            return Color(red: 1.0, green: 0.85, blue: 0.28)
        case .mythicRare:
            return Color(red: 1.0, green: 0.96, blue: 0.7)
        case .ultimateRare:
            return Color(red: 0.85, green: 0.7, blue: 0.15)
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .normal:
            return LinearGradient(
                colors: [Color(red: 0.22, green: 0.23, blue: 0.28), Color(red: 0.16, green: 0.17, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rare:
            return LinearGradient(
                colors: [Color(red: 0.12, green: 0.18, blue: 0.34), Color(red: 0.08, green: 0.12, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .superRare:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.12, blue: 0.34), Color(red: 0.14, green: 0.08, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ultraRare:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.18, blue: 0.1), Color(red: 0.2, green: 0.11, blue: 0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .legendRare:
            return LinearGradient(
                colors: [Color(red: 0.28, green: 0.24, blue: 0.1), Color(red: 0.2, green: 0.16, blue: 0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mythicRare:
            return LinearGradient(
                colors: [Color(red: 0.32, green: 0.28, blue: 0.16), Color(red: 0.22, green: 0.18, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ultimateRare:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.24, blue: 0.06), Color(red: 0.2, green: 0.15, blue: 0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension GachaRarity {
    var catalogTier: GachaCatalogTier {
        switch self {
        case .normal:
            return .normal
        case .rare, .Rrare, .mekaRare, .godRare, .guardianRare, .deepSeaRare:
            return .rare
        case .superRare, .RsuperRare, .mekaSuperRare, .godSuperRare, .guardianSuperRare, .deepSeaSuperRare:
            return .superRare
        case .ultraRare, .RultraRare, .mekaUltraRare, .godUltraRare, .guardianUltraRare, .deepSeaUltraRare:
            return .ultraRare
        case .legendRare, .mekaLegendRare, .godLegendRare, .guardianLegendRare, .deepSeaLegendRare:
            return .legendRare
        case .godMythicRare:
            return .mythicRare
        case .guardianUltimateRare, .deepSeaUltimateRare:
            return .ultimateRare
        }
    }
}

extension InventoryItemType {
    var gachaButtonTrailingColor: Color {
        switch self {
        case .normalGachaTicket:
            return Color(red: 0.16, green: 0.75, blue: 0.72)
        case .rareGachaTicket:
            return Color(red: 0.93, green: 0.38, blue: 0.35)
        case .mekaGachaTicket:
            return Color(red: 0.32, green: 0.41, blue: 0.92)
        case .godGachaTicket:
            return Color(red: 1.0, green: 0.67, blue: 0.24)
        case .guardianGachaTicket:
            return Color(red: 0.2, green: 0.6, blue: 0.45)
        case .staminaPotion:
            return Color(red: 0.24, green: 0.74, blue: 0.48)
        case .boostTicket:
            return Color(red: 1.0, green: 0.45, blue: 0.24)
        }
    }
}

struct GachaCatalogEntry: Identifiable {
    let item: GachaManager.Item

    var id: String { item.name }
    var tier: GachaCatalogTier { item.rarity.catalogTier }
}

struct GachaLobbyScreen: View {
    let gachaTitle: String
    let heroImageName: String
    let backgroundImageName: String
    let ticketType: InventoryItemType?
    let ticketCount: Int
    let userMoney: Int
    let cost: Int
    let isDrawEnabled: Bool
    let rewardLoaded: Bool
    let catalogItems: [GachaManager.Item]
    let onBack: () -> Void
    let onCoinTap: () -> Void
    let onDraw: () -> Void
    let onTicketDraw: () -> Void
    let onRewardAd: () -> Void

    @ObservedObject private var authManager = AuthManager.shared
    @State private var showCatalogSheet = false
    @State private var featuredEntry: GachaCatalogEntry?
    /// おともの姿と名前を十分に確認できるよう、切り替え間隔を長めにする。
    @State private var featuredAutoSlideTimer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// インジケーター表示用。おともが切り替わるたびに進む。
    @State private var featuredTick = 0

    private var lineupEntry: GachaLineupEntry? {
        GachaTheme.lineupEntry(title: gachaTitle)
    }

    /// 既存の各ガチャのテーマ色（召喚陣の奥にごく薄く敷く）。
    private var themeColor: Color {
        lineupEntry?.themeColors.first ?? ticketType?.accentColor ?? GachaTheme.gold
    }

    private var catalogEntries: [GachaCatalogEntry] {
        return catalogItems
            .map { GachaCatalogEntry(item: $0) }
            .sorted { lhs, rhs in
                if lhs.tier.rawValue != rhs.tier.rawValue {
                    return lhs.tier.rawValue > rhs.tier.rawValue
                }
                if lhs.item.probability != rhs.item.probability {
                    return lhs.item.probability < rhs.item.probability
                }
                return lhs.item.name < rhs.item.name
            }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                headerView
                titleView
                    .padding(.top, 4)
                stageView
                catalogButton
                drawButton
                    .padding(.top, 4)
                if let ticketType {
                    ticketButton(for: ticketType)
                }
                utilityButtons
            }
            .frame(maxWidth: 560)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 110)
            .frame(maxWidth: .infinity)
        }
        .background {
            // 背景だけをセーフエリア外へ広げ、ヘッダーは安全領域内に保つ。
            backgroundView
        }
        .sheet(isPresented: $showCatalogSheet) {
            GachaCatalogSheet(
                gachaTitle: gachaTitle,
                items: catalogItems,
                accentColor: themeColor
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            authManager.fetchAvatars {}
        }
    }

    /// backgroundImageName の画像は使わず、漆黒＋金の放射グローで統一する。
    private var backgroundView: some View {
        ZStack {
            GachaTheme.background

            GachaRadialGlow(opacity: 0.22, radius: 300)
                .offset(y: -40)
        }
        .ignoresSafeArea()
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            GachaBackPill {
                generateHapticFeedback()
                onBack()
            }

            Spacer()

            GachaCoinPill(amount: userMoney) {
                generateHapticFeedback()
                onCoinTap()
            }
        }
    }

    private var titleView: some View {
        VStack(spacing: 6) {
            Text(gachaTitle)
                .font(GachaFont.display(32, relativeTo: .largeTitle))
                .tracking(GachaFont.tracking(32))
                .foregroundColor(GachaTheme.goldHighlight)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .gachaGoldTextGlow()
                .accessibilityAddTraits(.isHeader)

            if let description = lineupEntry?.description {
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(GachaTheme.textMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Stage
    private var stageView: some View {
        let entries = catalogEntries

        return ZStack {
            GachaRadialGlow(color: themeColor, opacity: 0.16, radius: 170)

            GachaSummoningCircle(size: 300)

            // 足元の楕円グロー
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [GachaTheme.gold.opacity(0.45), GachaTheme.gold.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 110
                    )
                )
                .frame(width: 230, height: 44)
                .offset(y: 92)
                .accessibilityHidden(true)

            // フィーチャー中のおとも
            ZStack {
                if let entry = featuredEntry {
                    GachaLobbyFeaturedOtomoSpotlight(
                        entry: entry,
                        isOwned: isOwned(entry.item.name)
                    )
                    .id(entry.id)
                    .transition(.opacity)
                }
            }
            .gachaFloating(amplitude: 6, period: 4)
            .offset(y: -18)

            VStack(spacing: 0) {
                HStack {
                    GachaTag(text: "PICK UP")
                    Spacer()
                }
                Spacer()
                namePlate(entries: entries)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .onReceive(featuredAutoSlideTimer) { _ in
            advanceFeaturedCarousel(entries: entries)
        }
        .onAppear {
            if featuredEntry == nil {
                featuredEntry = pickFeaturedEntry(from: entries, excluding: nil)
            }
        }
    }

    @ViewBuilder
    private func namePlate(entries: [GachaCatalogEntry]) -> some View {
        if let entry = featuredEntry {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    GachaTag(text: entry.tier.title, useLabelFont: false)

                    Text(isOwned(entry.item.name) ? entry.item.name : "シークレット")
                        .font(GachaFont.display(16, relativeTo: .headline))
                        .tracking(GachaFont.tracking(16))
                        .foregroundColor(GachaTheme.goldHighlight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.85))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(GachaTheme.gold, lineWidth: 1))
                )
                .id(entry.id)
                .transition(.opacity)
                .accessibilityHidden(true)

                indicator(count: min(entries.count, 5))
            }
        }
    }

    private func indicator(count: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                let isActive = count > 0 && featuredTick % count == index
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? GachaTheme.gold : GachaTheme.gold.opacity(0.35))
                    .frame(width: isActive ? 18 : 6, height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: featuredTick)
        .accessibilityHidden(true)
    }

    private func isOwned(_ name: String) -> Bool {
        authManager.avatars.contains(where: { $0.name == name })
    }

    /// シークレット（未所持）を所持済みの3倍出やすくした重み付き抽選
    private func pickFeaturedEntry(from entries: [GachaCatalogEntry], excluding previous: GachaCatalogEntry.ID?) -> GachaCatalogEntry? {
        guard !entries.isEmpty else { return nil }

        let weighted = entries.flatMap { entry in
            Array(repeating: entry, count: isOwned(entry.item.name) ? 1 : 3)
        }

        guard entries.count > 1 else { return entries.first }

        for _ in 0..<6 {
            if let picked = weighted.randomElement(), picked.id != previous {
                return picked
            }
        }
        return weighted.randomElement()
    }

    private func advanceFeaturedCarousel(entries: [GachaCatalogEntry]) {
        guard entries.count > 1 else { return }
        withAnimation(.easeInOut(duration: reduceMotion ? 0.3 : 0.8)) {
            featuredEntry = pickFeaturedEntry(from: entries, excluding: featuredEntry?.id)
            featuredTick += 1
        }
    }

    // MARK: Buttons
    private var catalogButton: some View {
        Button(action: {
            generateHapticFeedback()
            showCatalogSheet = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(GachaTheme.gold)

                Text("おとも一覧")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(GachaTheme.text)

                Spacer()

                Text("全\(catalogEntries.count)体")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(GachaTheme.textMuted)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(GachaTheme.textMuted)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(GachaTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                            .stroke(GachaTheme.line, lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("おとも一覧、全\(catalogEntries.count)体")
    }

    private var drawButton: some View {
        Button(action: {
            generateHapticFeedback()
            onDraw()
        }) {
            VStack(spacing: 3) {
                Text("召喚する")
                    .font(GachaFont.display(24, relativeTo: .title))
                    .tracking(24 * 0.3)
                    // tracking は末尾にも付くので、左にも同じ幅を足して中央に揃える
                    .padding(.leading, 24 * 0.3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(cost.formatted())コイン ／ 1回")
                    .font(.system(size: 12, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .foregroundColor(isDrawEnabled ? GachaTheme.goldButtonText : Color.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(GachaGoldButtonBackground(isEnabled: isDrawEnabled, shinePeriod: 2.8))
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isDrawEnabled)
        .accessibilityLabel("召喚する、1回\(cost)コイン")
        .accessibilityHint(isDrawEnabled ? "" : "コインが足りません")
    }

    private func ticketButton(for ticketType: InventoryItemType) -> some View {
        let hasTicket = ticketCount > 0

        return Button(action: {
            generateHapticFeedback()
            onTicketDraw()
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("チケットで引く")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(hasTicket ? GachaTheme.text : GachaTheme.textMuted)
                        .lineLimit(1)

                    Text("\(ticketType.shortName)チケットを1枚消費")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(GachaTheme.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Text("×\(ticketCount)")
                    .font(.system(size: 20, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(hasTicket ? GachaTheme.goldLight : GachaTheme.textMuted)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(GachaTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                            .stroke(hasTicket ? GachaTheme.gold : Color.gray.opacity(0.35), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("チケットで引く、\(ticketType.shortName)チケット残り\(ticketCount)枚")
    }

    private var utilityButtons: some View {
        HStack(spacing: 10) {
            GachaSubActionButton(
                title: rewardLoaded ? "広告を見て" : "広告を準備中",
                subtitle: rewardLoaded ? "300コイン獲得" : "読み込み中…",
                isEnabled: rewardLoaded,
                isLoading: !rewardLoaded,
                action: {
                    generateHapticFeedback()
                    onRewardAd()
                }
            )
            .disabled(!rewardLoaded)
            .accessibilityLabel(rewardLoaded ? "広告を見て300コイン獲得" : "広告を準備中")

            GachaSubActionButton(
                title: "コイン購入",
                subtitle: "必要な分だけ追加",
                action: {
                    generateHapticFeedback()
                    onCoinTap()
                }
            )
            .accessibilityLabel("コイン購入")
        }
    }
}

/// ガチャ画面下段の小さな行動ボタン（広告／コイン購入）。
struct GachaSubActionButton: View {
    let title: String
    let subtitle: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isEnabled ? GachaTheme.text : GachaTheme.textMuted)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(GachaTheme.textMuted)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: 0)

                if isLoading {
                    ProgressView()
                        .tint(GachaTheme.textMuted)
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(GachaTheme.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                            .stroke(isEnabled ? GachaTheme.gold.opacity(0.22) : Color.gray.opacity(0.25), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct GachaLobbyFeaturedOtomoSpotlight: View {
    let entry: GachaCatalogEntry
    let isOwned: Bool

    var body: some View {
        artwork
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                isOwned
                    ? "ピックアップ中のおとも、\(entry.item.name)、\(entry.tier.title)"
                    : "ピックアップ中の未獲得のおとも、\(entry.tier.title)"
            )
    }

    @ViewBuilder
    private var artwork: some View {
        let imageName = GachaCatalogAvatarResolver.imageName(for: entry.item.name)

        if imageName == "questionmark.circle.fill" {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .foregroundColor(GachaTheme.textMuted.opacity(0.5))
        } else {
            Image(imageName)
                // 未所持は単色のシルエット。暗い背景でも形がわかるよう金の縁光を付ける。
                .renderingMode(isOwned ? .original : .template)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .foregroundColor(Color(hex: "2A2438"))
                .shadow(color: isOwned ? Color.black.opacity(0.45) : GachaTheme.gold.opacity(0.55), radius: isOwned ? 12 : 6, x: 0, y: isOwned ? 10 : 0)
        }
    }
}

private struct GachaLobbyParticleField: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<24, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.34 : 0.18))
                        .frame(
                            width: CGFloat(2 + index % 4),
                            height: CGFloat(2 + index % 4)
                        )
                        .position(
                            x: starX(index: index, width: proxy.size.width),
                            y: starY(index: index, height: proxy.size.height)
                        )
                        .opacity(animate ? 1 : 0.25)
                        .scaleEffect(animate ? 1.15 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.6 + Double(index % 5) * 0.28)
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
        }
        .allowsHitTesting(false)
    }

    private func starX(index: Int, width: CGFloat) -> CGFloat {
        let raw = abs(sin(Double(index * 37) * 0.73))
        return CGFloat(raw) * width
    }

    private func starY(index: Int, height: CGFloat) -> CGFloat {
        let raw = abs(cos(Double(index * 29) * 0.61))
        return CGFloat(raw) * height
    }
}

struct GachaUtilityButton: View {
    let iconName: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 18, weight: .black))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(22)
            .shadow(color: gradientColors.first?.opacity(0.28) ?? .clear, radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1.2)
            )
            .overlay {
                if isLoading {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.black.opacity(0.26))

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct GachaCatalogSheet: View {
    let gachaTitle: String
    let items: [GachaManager.Item]
    let accentColor: Color

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedTier: GachaCatalogTier? = nil
    @State private var selectedEntry: GachaCatalogEntry? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var entries: [GachaCatalogEntry] {
        return items
            .map { GachaCatalogEntry(item: $0) }
            .sorted { lhs, rhs in
                if lhs.tier.rawValue != rhs.tier.rawValue {
                    return lhs.tier.rawValue < rhs.tier.rawValue
                }
                if lhs.item.probability != rhs.item.probability {
                    return lhs.item.probability > rhs.item.probability
                }
                return lhs.item.name < rhs.item.name
            }
    }

    private var availableTiers: [GachaCatalogTier] {
        GachaCatalogTier.allCases.filter { tier in
            entries.contains(where: { $0.tier == tier })
        }
    }

    private var filteredEntries: [GachaCatalogEntry] {
        if let selectedTier {
            return entries.filter { $0.tier == selectedTier }
        }
        return entries
    }

    private var highestTier: GachaCatalogTier {
        availableTiers.last ?? .normal
    }

    var body: some View {
        ZStack {
            GachaTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(
                            title: "すべて",
                            isSelected: selectedTier == nil,
                            color: .white
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTier = nil
                            }
                        }

                        ForEach(availableTiers) { tier in
                            FilterChip(
                                title: tier.title,
                                isSelected: selectedTier == tier,
                                color: tier.color
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedTier = tier
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }

                summaryView
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredEntries) { entry in
                            GachaCatalogCardView(
                                entry: entry,
                                isOwned: isOwned(entry.item.name),
                                isSelected: selectedEntry?.id == entry.id
                            )
                            .onTapGesture {
                                generateHapticFeedback()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedEntry = entry
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 100)
                }
            }

            if let selectedEntry {
                GachaCatalogDetailOverlay(
                    entry: selectedEntry,
                    isOwned: isOwned(selectedEntry.item.name)
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        self.selectedEntry = nil
                    }
                }
            }
        }
        .onAppear {
            authManager.fetchAvatars {}
        }
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(gachaTitle)のおとも一覧")
                    .font(GachaFont.display(22, relativeTo: .title2))
                    .tracking(GachaFont.tracking(22))
                    .foregroundColor(GachaTheme.goldHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityAddTraits(.isHeader)

                Text("\(entries.count)体のおともを確認できます")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(GachaTheme.textMuted)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(GachaTheme.goldLight)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(GachaTheme.surface)
                            .overlay(Circle().stroke(GachaTheme.line, lineWidth: 1))
                    )
            }
            .accessibilityLabel("閉じる")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var summaryView: some View {
        HStack(spacing: 12) {
            GachaCatalogSummaryCard(
                title: "おとも数",
                value: "\(entries.count)体",
                accentColor: accentColor
            )

            GachaCatalogSummaryCard(
                title: "最高レア",
                value: highestTier.title,
                accentColor: highestTier.color
            )
        }
    }

    private func isOwned(_ name: String) -> Bool {
        authManager.avatars.contains(where: { $0.name == name })
    }
}

struct GachaCatalogSummaryCard: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(GachaTheme.textMuted)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(GachaTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                .fill(GachaTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                        .stroke(GachaTheme.line, lineWidth: 1)
                )
        )
    }
}

struct GachaCatalogCardView: View {
    let entry: GachaCatalogEntry
    let isOwned: Bool
    let isSelected: Bool

    @State private var shimmer = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if entry.tier == .legendRare || entry.tier == .mythicRare {
                    RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                        .fill(entry.tier.color.opacity(0.22))
                        .blur(radius: 10)
                }

                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(entry.tier.backgroundGradient)

                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .stroke(
                        isSelected ? GachaTheme.gold : GachaTheme.gold.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )

                VStack(spacing: 8) {
                    ZStack {
                        if entry.tier == .legendRare || entry.tier == .mythicRare {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.yellow, .orange, .yellow, .white, .yellow],
                                        center: .center
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .blur(radius: 14)
                                .rotationEffect(.degrees(shimmer ? 360 : 0))
                        }

                        catalogImage(width: 66, height: 66)
                    }

                    Text(entry.tier.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(entry.tier.color.opacity(0.8))
                        )
                }
                .padding(12)
            }
            .frame(height: 128)

            Text(isOwned ? entry.item.name : "???")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GachaTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .onAppear {
            if !reduceMotion && (entry.tier == .legendRare || entry.tier == .mythicRare) {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
        }
    }

    @ViewBuilder
    private func catalogImage(width: CGFloat, height: CGFloat) -> some View {
        let imageName = GachaCatalogAvatarResolver.imageName(for: entry.item.name)

        if imageName == "questionmark.circle.fill" {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(.white.opacity(isOwned ? 0.9 : 0.35))
        } else {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .colorMultiply(isOwned ? .white : .black)
        }
    }
}

struct GachaCatalogDetailOverlay: View {
    let entry: GachaCatalogEntry
    let isOwned: Bool
    let onClose: () -> Void

    @State private var appear = false
    @State private var floatAnimation = false
    @State private var glowAnimation = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            VStack(spacing: 22) {
                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(GachaTheme.goldLight)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(GachaTheme.background)
                                    .overlay(Circle().stroke(GachaTheme.line, lineWidth: 1))
                            )
                    }
                    .accessibilityLabel("閉じる")
                }

                GachaTag(text: entry.tier.title, useLabelFont: false, size: 13)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [entry.tier.color.opacity(0.45), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(glowAnimation ? 1.08 : 0.92)

                    catalogImage(width: 170, height: 170)
                        .shadow(color: entry.tier.color.opacity(0.45), radius: 18, x: 0, y: 10)
                        .offset(y: floatAnimation ? -8 : 8)
                }

                Text(isOwned ? entry.item.name : "???")
                    .font(GachaFont.display(26, relativeTo: .title))
                    .tracking(GachaFont.tracking(26))
                    .foregroundColor(GachaTheme.goldHighlight)
                    .multilineTextAlignment(.center)
                    .gachaGoldTextGlow()

                if isOwned {
                    HStack(spacing: 36) {
                        StatDisplay(
                            icon: "heart.fill",
                            value: entry.item.health,
                            label: "HP",
                            color: .red
                        )

                        StatDisplay(
                            icon: "bolt.fill",
                            value: entry.item.attack,
                            label: "ATK",
                            color: .blue
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(GachaTheme.heroGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                            .stroke(GachaTheme.gold, lineWidth: 1)
                    )
                    .overlay(
                        GachaCornerBrackets(length: 14)
                            .stroke(GachaTheme.goldLight, lineWidth: 2)
                            .padding(6)
                    )
            )
            .padding(.horizontal, 28)
            .scaleEffect(appear ? 1 : 0.82)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.8)) {
                appear = true
            }
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floatAnimation = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }

    @ViewBuilder
    private func catalogImage(width: CGFloat, height: CGFloat) -> some View {
        let imageName = GachaCatalogAvatarResolver.imageName(for: entry.item.name)

        if imageName == "questionmark.circle.fill" {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(.white.opacity(isOwned ? 0.9 : 0.4))
        } else {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .colorMultiply(isOwned ? .white : .black)
        }
    }
}

private enum GachaCatalogAvatarResolver {
    /// 未所持でも本物のおとも画像を使い、表示側で黒く塗って隠す。
    /// 専用のシークレット画像は用意しない(本体の形と食い違うため)。
    static func imageName(for name: String) -> String {
        UIImage(named: name) != nil ? name : "questionmark.circle.fill"
    }
}

struct GachaView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var gachaManager = GachaManager(mode: .normal)
    
    @State private var userMoney: Int = 0
    @State private var isGachaButtonDisabled: Bool = false
    @State private var obtainedRareItem: GachaManager.Item?
    @State private var obtainedItem: GachaManager.Item?
    /// 結果画面の NEW 表示用（抽選前の所持状態で判定）
    @State private var obtainedIsNew: Bool = false
    
    @State private var showAnimation: Bool = false
    @State private var showResult: Bool = false
    @State private var showCoinModal: Bool = false
    @State private var showUnCoinModal: Bool = false
    
    @State private var otomo10flag: Bool = false
    @State private var otomo20flag: Bool = false
    @State private var showTitleModal: Bool = false
    @State private var obtainedTitle: String = ""
    
    @State private var showRewardAlert: Bool = false
    @State private var showTicketErrorAlert: Bool = false
    @State private var ticketErrorMessage: String = ""
    
    @ObservedObject var audioManager = AudioManager.shared
    @StateObject var reward = Reward()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCoinOptionsAlert: Bool = false
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Color2")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !showResult {
                // ガチャ初期画面
                gachaMainView
            } else {
                // 結果画面
                GachaResultView(
                    item: obtainedItem,
                    gachaCost: gachaManager.gachaCost,
                    onClose: {
                        showResult = false
                        obtainedItem = nil
                    },
                    onPlayAgain: {
                        let cost = gachaManager.gachaCost
                        guard userMoney >= cost else {
                            showUnCoinModal = true
                            return
                        }
                        performGachaDraw(coinCost: cost, resetResult: false)
                    },
                    isNew: obtainedIsNew
                )
            }
            VStack{
                if showCoinModal {
                    if showUnCoinModal {
                        VStack{
                            HStack{
                                Image("コインが無い")
                                    .resizable()
                                    .frame(width:70,height: 70)
                                VStack(alignment: .leading, spacing:15){
                                    HStack{
                                        Text("コインが足りません")
                                        Spacer()
                                    }
                                    Text("ご購入することもできます")
                                        .font(.system(size: isSmallDevice() ? 17 : 18))
                                }
                                
                            }.padding()
                        }.frame(width: isSmallDevice() ? 330: 340, height:120)
                            .background(Color("Color2"))
                            .font(.system(size: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                    CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
                }
            }
        }
        .onAppear {
            refreshPlayerResources()
            reward.LoadReward()
        }
        .fullScreenCover(isPresented: $showAnimation) {
            if let rarity = obtainedRareItem?.rarity {
                GachaAnimationView(rarity: rarity, item: obtainedRareItem) {
                    showAnimation = false
                    obtainedItem = obtainedRareItem
                    showResult = true
                    fetchUserMoney()
                }
            }
        }
        .alert("コインが足りません", isPresented: $showUnCoinModal) {
            if authManager.normalGachaTicketCount > 0 {
                Button("チケットで引く") {
                    startGachaWithTicket(resetResult: false)
                }
            }
            Button(action: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                } else {
                    // リワード広告が読み込まれていない場合
                    showCoinModal = true
                }
            }) {
                Text(reward.rewardLoaded ? "広告を見る (300コイン)" : "広告を読み込み中...")
            }
            Button("コインを購入") {
                showCoinModal = true
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ガチャを引くには\(gachaManager.gachaCost)コインが必要です")
        }
        .alert("300コイン獲得しました。", isPresented: $showRewardAlert) {
            Button("OK") {
                refreshPlayerResources()
            }
        }
        .alert("ガチャを引けませんでした", isPresented: $showTicketErrorAlert) {
            Button("OK") {}
        } message: {
            Text(ticketErrorMessage)
        }
        .alert("称号獲得!", isPresented: $showTitleModal) {
            Button("OK") {}
        } message: {
            Text(obtainedTitle)
        }
        .onChange(of: reward.rewardEarned) { rewardEarned in
            showRewardAlert = rewardEarned
            if rewardEarned {
                refreshPlayerResources()
                reward.rewardEarned = false
            }
        }
        .onChange(of: showCoinModal) { _ in
            refreshPlayerResources()
        }
    }
    
    private var gachaMainView: some View {
        GachaLobbyScreen(
            gachaTitle: "レギュラーガチャ",
            heroImageName: "ガチャ",
            backgroundImageName: "StandardGachaSceneBackground",
            ticketType: .normalGachaTicket,
            ticketCount: authManager.normalGachaTicketCount,
            userMoney: userMoney,
            cost: gachaManager.gachaCost,
            isDrawEnabled: isGachaButtonDisabled,
            rewardLoaded: reward.rewardLoaded,
            catalogItems: gachaManager.catalogItems,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
                audioManager.playCancelSound()
            },
            onCoinTap: {
                showCoinModal = true
            },
            onDraw: startGacha,
            onTicketDraw: {
                startGachaWithTicket()
            },
            onRewardAd: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                }
            }
        )
    }
    
    private func startGacha() {
        let cost = gachaManager.gachaCost
        guard userMoney >= cost else {
            showUnCoinModal = true
            return
        }
        performGachaDraw(coinCost: cost)
    }

    private func startGachaWithTicket(resetResult: Bool = true) {
        guard authManager.normalGachaTicketCount > 0 else {
            ticketErrorMessage = "レギュラーガチャチケットがありません。"
            showTicketErrorAlert = true
            refreshPlayerResources()
            return
        }

        performGachaDraw(ticketType: .normalGachaTicket, resetResult: resetResult)
    }

    private func performGachaDraw(
        coinCost: Int = 0,
        ticketType: InventoryItemType? = nil,
        resetResult: Bool = true
    ) {
        gachaManager.shuffleItems()
        guard let item = gachaManager.drawGacha() else {
            ticketErrorMessage = "ガチャ結果を取得できませんでした。"
            showTicketErrorAlert = true
            return
        }

        let avatar = Avatar(
            name: item.name,
            attack: item.attack,
            health: item.health,
            usedFlag: 0,
            count: 1
        )
        let isNewAvatar = !authManager.avatars.contains { $0.name == item.name }
        authManager.commitGachaResult(
            avatar: avatar,
            coinCost: coinCost,
            ticketType: ticketType
        ) { success in
            guard success else {
                if ticketType == nil {
                    if userMoney < coinCost {
                        showUnCoinModal = true
                    } else {
                        ticketErrorMessage = "ガチャの確定に失敗しました。時間をおいて再度お試しください。"
                        showTicketErrorAlert = true
                    }
                } else {
                    ticketErrorMessage = "チケットの消費またはおともの保存に失敗しました。"
                    showTicketErrorAlert = true
                }
                refreshPlayerResources()
                return
            }

            audioManager.playSound()
            obtainedRareItem = item
            obtainedIsNew = isNewAvatar
            // 次回の NEW 判定のため所持おともを読み直す（読み取りのみ）
            authManager.fetchAvatars {}
            authManager.recordGachaUsed()
            if resetResult {
                showResult = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (resetResult ? 0.5 : 0.1)) {
                showAnimation = true
            }
            checkAvatarCount()
            refreshPlayerResources()
        }
    }

    private func fetchUserMoney() {
        authManager.getUserMoney { money in
            self.userMoney = money
            // ボタンの有効/無効を更新（コストに応じて）
            let cost = gachaManager.gachaCost
            isGachaButtonDisabled = money >= cost
        }
    }

    private func refreshPlayerResources() {
        fetchUserMoney()
        authManager.fetchInventory()
    }
    
    private func checkAvatarCount() {
        guard let userId = authManager.currentUserId else { return }
        
        countAvatarsForUser(userId: userId) { avatarCount in
            print("ユーザーのアバターの数: \(avatarCount)")
            
            if avatarCount > 9 {
                authManager.checkTitles(userId: userId, title: "おとも１０種類制覇") { exists in
                    if !exists {
                        otomo10flag = true
                        obtainedTitle = "おとも１０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも１０種類制覇")
                    }
                }
            }
            
            if avatarCount > 19 {
                authManager.checkTitles(userId: userId, title: "おとも２０種類制覇") { exists in
                    if !exists {
                        otomo20flag = true
                        obtainedTitle = "おとも２０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも２０種類制覇")
                    }
                }
            }
        }
    }
    
    private func countAvatarsForUser(userId: String, completion: @escaping (Int) -> Void) {
        let avatarsRef = Database.database().reference().child("users").child(userId).child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value, with: { snapshot in
            let avatarCount = snapshot.childrenCount
            completion(Int(avatarCount))
        })
    }
}

// MARK: - Animation View
/// 召喚演出（約4.8秒）。暗転・召喚陣 → 宝珠落下 → ひび割れ・予告 → 光の柱 → 登場。
struct GachaAnimationView: View {
    let rarity: GachaRarity?
    /// 登場させるおとも。省略時はレア度だけを表示する。
    var item: GachaManager.Item? = nil
    let onFinished: () -> Void

    /// 演出の段階。
    enum SummonPhase: Int {
        case idle
        case circle      // 0.0s 暗転・召喚陣
        case orbDrop     // 0.8s 宝珠落下
        case crack       // 1.8s ひび割れ・レア度の予告
        case pillar      // 2.8s 光の柱・ホワイトアウト
        case reveal      // 3.6s 登場
        case done
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase: SummonPhase = .idle
    @State private var sequence: Task<Void, Never>?
    @State private var didFinish = false

    // 召喚陣
    @State private var circleScale: CGFloat = 0.2
    @State private var circleOpacity: Double = 0
    // 宝珠
    @State private var orbOffset: CGFloat = -560
    @State private var orbOpacity: Double = 0
    @State private var orbScale: CGFloat = 1
    @State private var trailOpacity: Double = 0
    @State private var isShaking = false
    @State private var crackProgress: CGFloat = 0
    @State private var hintColor: Color = GachaTheme.goldLight
    @State private var hintGlow: Double = 0
    @State private var isRainbow = false
    @State private var rainbowSpin = false
    // 光の柱・白飛び
    @State private var pillarScale: CGFloat = 0
    @State private var pillarOpacity: Double = 0
    @State private var flashOpacity: Double = 0
    // 登場
    @State private var revealOpacity: Double = 0
    @State private var raysRotation: Double = 0
    @State private var avatarScale: CGFloat = 0.6
    @State private var bannerOffset: CGFloat = -600
    @State private var bannerOpacity: Double = 0

    private static let rainbowColors: [Color] = [
        Color(hex: "FF5A5A"), Color(hex: "FFB347"), Color(hex: "FFF07A"),
        Color(hex: "6BFF8E"), Color(hex: "5AD8FF"), Color(hex: "7A7BFF"),
        Color(hex: "E07BFF"), Color(hex: "FF5A5A")
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let floorY = size.height * 0.64
            let orbRestY = floorY - 46
            let revealY = size.height * 0.42

            ZStack {
                Color.black

                // 5. 登場
                revealLayer(size: size, centerY: revealY)
                    .opacity(revealOpacity)

                // 1. 召喚陣（床に寝かせた楕円）
                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [hintColor.opacity(0.35 + hintGlow * 0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 170
                            )
                        )
                        .frame(width: 340, height: 130)

                    GachaSummoningCircle(size: 300, color: GachaTheme.gold)
                        .scaleEffect(x: 1, y: 0.36)
                }
                .scaleEffect(circleScale)
                .opacity(circleOpacity)
                .position(x: size.width / 2, y: floorY)

                // 2〜3. 宝珠
                orbLayer
                    .offset(y: orbOffset)
                    .opacity(orbOpacity)
                    .position(x: size.width / 2, y: orbRestY)

                // 4. 光の柱
                LinearGradient(
                    colors: [.clear, pillarColor.opacity(0.9), .white, pillarColor.opacity(0.9), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 150)
                .scaleEffect(x: pillarScale, y: 1)
                .opacity(pillarOpacity)
                .blur(radius: 6)
                .frame(maxHeight: .infinity)
                .position(x: size.width / 2, y: size.height / 2)
                .allowsHitTesting(false)

                Color.white
                    .opacity(flashOpacity)
                    .allowsHitTesting(false)
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            skipButton
        }
        .onAppear {
            guard sequence == nil else { return }
            sequence = Task { @MainActor in
                if reduceMotion {
                    await runReducedSequence()
                } else {
                    await runSequence()
                }
            }
        }
        .onDisappear {
            sequence?.cancel()
        }
    }

    // MARK: Layers
    private var pillarColor: Color {
        isRainbow ? GachaTheme.goldHighlight : hintColor
    }

    private var orbLayer: some View {
        ZStack {
            // 落下時の光の尾
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [GachaTheme.goldLight.opacity(0), GachaTheme.goldLight.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 26, height: 240)
                .offset(y: -130)
                .blur(radius: 4)
                .opacity(trailOpacity)

            // 漏れる光
            Group {
                if isRainbow {
                    Circle()
                        .fill(AngularGradient(colors: Self.rainbowColors, center: .center))
                        .hueRotation(.degrees(rainbowSpin ? 360 : 0))
                } else {
                    Circle().fill(hintColor)
                }
            }
            .frame(width: 150, height: 150)
            .blur(radius: 28)
            .opacity(hintGlow)

            // 宝珠本体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, GachaTheme.goldLight, GachaTheme.gold, Color(hex: "8C5F10")],
                        center: UnitPoint(x: 0.38, y: 0.32),
                        startRadius: 0,
                        endRadius: 44
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    GachaOrbCrackShape()
                        .trim(from: 0, to: crackProgress)
                        .stroke(isRainbow ? Color.white : hintColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .shadow(color: isRainbow ? .white : hintColor, radius: 4)
                )
                .shadow(color: GachaTheme.gold.opacity(0.8), radius: 16)
        }
        .scaleEffect(orbScale)
        .rotationEffect(.degrees(phase == .crack ? (isShaking ? 3 : -3) : 0))
    }

    private func revealLayer(size: CGSize, centerY: CGFloat) -> some View {
        let diameter = max(size.width, size.height) * 1.6

        return ZStack {
            GachaSunburst(opacity: 0.16)
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(raysRotation))
                .position(x: size.width / 2, y: centerY)

            GachaRadialGlow(opacity: 0.35, radius: 220)
                .position(x: size.width / 2, y: centerY)

            avatarImage
                .frame(width: 250, height: 250)
                .shadow(color: GachaTheme.gold.opacity(0.5), radius: 24)
                .scaleEffect(avatarScale)
                .position(x: size.width / 2, y: centerY)

            nameBanner
                .offset(x: bannerOffset)
                .opacity(bannerOpacity)
                .position(x: size.width / 2, y: centerY + 170)
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let item, UIImage(named: item.name) != nil {
            Image(item.name)
                .resizable()
                .scaledToFit()
                .accessibilityLabel(item.name)
        } else {
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .padding(60)
                .foregroundColor(GachaTheme.goldLight)
                .accessibilityHidden(true)
        }
    }

    private var nameBanner: some View {
        HStack(spacing: 10) {
            if let rarity {
                GachaTag(text: rarity.displayString, useLabelFont: false, size: 12)
            }
            Text(item?.name ?? rarity?.displayString ?? "")
                .font(GachaFont.display(22, relativeTo: .title2))
                .tracking(GachaFont.tracking(22))
                .foregroundColor(GachaTheme.goldHighlight)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .gachaGoldTextGlow()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black.opacity(0.85))
        .overlay(alignment: .top) {
            Rectangle().fill(GachaTheme.gold).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(GachaTheme.gold).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var skipButton: some View {
        Button(action: finish) {
            HStack(spacing: 4) {
                Text("スキップ")
                    .font(.system(size: 13, weight: .bold))
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(GachaTheme.goldLight)
            .padding(.horizontal, 14)
            .frame(minWidth: 44, minHeight: 44)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
                    .overlay(Capsule().stroke(GachaTheme.line, lineWidth: 1))
            )
            .contentShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.trailing, 16)
        .padding(.top, 8)
        .accessibilityLabel("演出をスキップ")
    }

    // MARK: Sequence
    private func runSequence() async {
        // 1. 0.0s 暗転・召喚陣
        phase = .circle
        withAnimation(.easeOut(duration: 0.8)) {
            circleScale = 1
            circleOpacity = 1
        }
        guard await pause(0.8) else { return }

        // 2. 0.8s 宝珠が降ってくる
        phase = .orbDrop
        orbOpacity = 1
        trailOpacity = 1
        withAnimation(.easeIn(duration: 0.55)) {
            orbOffset = 0
        }
        guard await pause(0.55) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        orbScale = 0.86
        withAnimation(.easeOut(duration: 0.35)) {
            trailOpacity = 0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
            orbScale = 1
        }
        guard await pause(0.45) else { return }

        // 3. 1.8s ひび割れ・レア度の予告
        phase = .crack
        withAnimation(.easeInOut(duration: 0.05).repeatForever(autoreverses: true)) {
            isShaking = true
        }
        withAnimation(.easeIn(duration: 1.0)) {
            orbScale = 1.4
            crackProgress = 1
        }
        let stages = rarity?.summonHint.stages ?? []
        if stages.isEmpty {
            // ノーマルは色が上がらない
            withAnimation(.easeIn(duration: 0.6)) { hintGlow = 0.35 }
            guard await pause(1.0) else { return }
        } else {
            let step = 1.0 / Double(stages.count)
            for (index, stage) in stages.enumerated() {
                withAnimation(.easeInOut(duration: min(0.25, step))) {
                    hintColor = stage.color ?? GachaTheme.goldLight
                    hintGlow = 0.45 + 0.45 * Double(index + 1) / Double(stages.count)
                    isRainbow = stage == .rainbow
                }
                if stage == .rainbow {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        rainbowSpin = true
                    }
                }
                guard await pause(step) else { return }
            }
        }

        // 4. 2.8s 光の柱・ホワイトアウト
        phase = .pillar
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.linear(duration: 0.01)) { isShaking = false }
        withAnimation(.easeOut(duration: 0.2)) {
            orbOpacity = 0
            orbScale = 1.8
            pillarScale = 1
            pillarOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.1)) { flashOpacity = 1 }
        guard await pause(0.2) else { return }
        withAnimation(.easeOut(duration: 0.5)) { flashOpacity = 0 }
        guard await pause(0.6) else { return }

        // 5. 3.6s 登場
        phase = .reveal
        withAnimation(.easeOut(duration: 0.4)) {
            pillarOpacity = 0
            circleOpacity = 0
            revealOpacity = 1
        }
        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            raysRotation = 360
        }
        withAnimation(.easeOut(duration: 0.22)) { avatarScale = 1.08 }
        guard await pause(0.22) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { avatarScale = 1 }
        guard await pause(0.13) else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            bannerOffset = 0
            bannerOpacity = 1
        }
        guard await pause(0.85) else { return }
        finish()
    }

    /// Reduce Motion 用：回転・発光のループは使わず、短いフェードだけでつなぐ。
    private func runReducedSequence() async {
        phase = .circle
        circleScale = 1
        orbOffset = 0
        hintColor = rarity?.summonHintColor ?? GachaTheme.goldLight
        hintGlow = rarity?.summonHint == GachaSummonHint.none ? 0.3 : 0.7
        crackProgress = 1
        withAnimation(.easeOut(duration: 0.25)) {
            circleOpacity = 1
            orbOpacity = 1
        }
        guard await pause(0.7) else { return }

        phase = .reveal
        avatarScale = 1
        bannerOffset = 0
        withAnimation(.easeInOut(duration: 0.3)) {
            circleOpacity = 0
            orbOpacity = 0
            revealOpacity = 1
            bannerOpacity = 1
        }
        guard await pause(1.0) else { return }
        finish()
    }

    /// 指定秒待つ。キャンセル・スキップされたら false。
    private func pause(_ seconds: Double) async -> Bool {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        return !Task.isCancelled && !didFinish
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        phase = .done
        sequence?.cancel()
        onFinished()
    }
}

/// 宝珠のひび（中心から外へ伸びる折れ線）。
struct GachaOrbCrackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        // (角度, 半径に対する割合)
        let branches: [[(Double, CGFloat)]] = [
            [(-80, 0.05), (-68, 0.35), (-95, 0.62), (-82, 0.98)],
            [(15, 0.05), (32, 0.4), (8, 0.7), (24, 0.98)],
            [(150, 0.05), (138, 0.45), (166, 0.75), (152, 0.98)],
            [(235, 0.05), (250, 0.5), (226, 0.95)],
            [(-30, 0.4), (-42, 0.75)]
        ]
        var path = Path()
        for branch in branches {
            for (index, point) in branch.enumerated() {
                let angle = point.0 * .pi / 180
                let p = CGPoint(
                    x: center.x + radius * point.1 * CGFloat(cos(angle)),
                    y: center.y + radius * point.1 * CGFloat(sin(angle))
                )
                if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
        }
        return path
    }
}

// MARK: - Custom Shapes
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Result View
struct GachaResultView: View {
    let item: GachaManager.Item?
    let gachaCost: Int  // 追加
    let onClose: () -> Void
    let onPlayAgain: () -> Void
    /// 初めて手に入れたおともなら true（抽選前の所持状態で呼び出し側が判定する）。
    var isNew: Bool = false
    
    @State private var showContent: Bool = false
    @State private var raysRotation: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        GeometryReader { proxy in
            // 縦が足りない端末（iPhone SE など）ではカードを縮める
            let cardScale = min(1, max(0.72, (proxy.size.height - 330) / 380))
            let cardSize = CGSize(width: 296 * cardScale, height: 380 * cardScale)

            ZStack {
                backgroundView(size: proxy.size)

                VStack(spacing: 0) {
                    Spacer(minLength: 8)

                    if let item = item {
                        rarityTitle(item)
                            .modifier(ResultAppear(isVisible: showContent, delay: 0.1, reduceMotion: reduceMotion))

                        Spacer(minLength: 12).frame(maxHeight: 22)

                        resultCard(item, size: cardSize, scale: cardScale)
                            .modifier(ResultAppear(isVisible: showContent, delay: 0.25, reduceMotion: reduceMotion, fromScale: 0.6))

                        Spacer(minLength: 12).frame(maxHeight: 20)

                        statusTiles(item)
                            .frame(maxWidth: cardSize.width + 24)
                            .modifier(ResultAppear(isVisible: showContent, delay: 0.45, reduceMotion: reduceMotion))
                    }

                    Spacer(minLength: 12)

                    buttons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .modifier(ResultAppear(isVisible: showContent, delay: 0.6, reduceMotion: reduceMotion))
                }
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            startEntrance()
            if !reduceMotion {
                withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                    raysRotation = 360
                }
            }
        }
        // 「もう一度召喚」で中身が変わったら登場アニメをやり直す
        .onChange(of: item?.name) { _ in
            showContent = false
            startEntrance()
        }
    }

    private func startEntrance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showContent = true
        }
    }

    // MARK: Background
    private func backgroundView(size: CGSize) -> some View {
        let diameter = max(size.width, size.height) * 1.6

        return ZStack {
            GachaTheme.background

            GachaSunburst()
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(raysRotation))
                .position(x: size.width / 2, y: size.height * 0.42)

            GachaRadialGlow(opacity: 0.3, radius: 240)
                .position(x: size.width / 2, y: size.height * 0.42)

            // 下の方は背景色に溶かす
            LinearGradient(
                stops: [
                    .init(color: GachaTheme.background.opacity(0), location: 0.55),
                    .init(color: GachaTheme.background, location: 0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    // MARK: Parts
    private func rarityTitle(_ item: GachaManager.Item) -> some View {
        HStack(spacing: 12) {
            GachaGoldRule(width: 40, fadeToTrailing: false)
            Text(item.rarity.displayString)
                .font(GachaFont.display(34, relativeTo: .largeTitle))
                .tracking(GachaFont.tracking(34))
                .foregroundColor(GachaTheme.goldHighlight)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .gachaGoldTextGlow()
            GachaGoldRule(width: 40, fadeToTrailing: true)
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("レア度 \(item.rarity.displayString)")
    }

    private func resultCard(_ item: GachaManager.Item, size: CGSize, scale: CGFloat) -> some View {
        let frameWidth: CGFloat = 6

        return ZStack {
            // 枠（金グラデ）
            RoundedRectangle(cornerRadius: 8)
                .fill(GachaTheme.cardFrameGradient)

            // 内側
            ZStack(alignment: .bottom) {
                GachaTheme.cardInnerGradient(radius: size.height * 0.6)

                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 18 * scale)
                    .padding(.top, 26 * scale)
                    .padding(.bottom, 64 * scale)
                    .shadow(color: GachaTheme.gold.opacity(0.35), radius: 18, x: 0, y: 8)
                    .gachaFloating(amplitude: 5, period: 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)

                // 下部の暗いグラデ＋キャラ名
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 96 * scale)

                Text(item.name)
                    .font(GachaFont.display(24, relativeTo: .title))
                    .tracking(GachaFont.tracking(24))
                    .foregroundColor(GachaTheme.goldHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .gachaGoldTextGlow()
                    .padding(.horizontal, 14)
                    .padding(.bottom, 18 * scale)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(frameWidth)

            if isNew {
                GachaTag(text: "NEW", size: 12)
                    .padding(.top, frameWidth + 12)
                    .padding(.trailing, frameWidth + 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .accessibilityLabel("初めて獲得")
            }
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: GachaTheme.glow, radius: 30, x: 0, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name)\(isNew ? "、初めて獲得" : "")")
    }

    private func statusTiles(_ item: GachaManager.Item) -> some View {
        HStack(spacing: 12) {
            statusTile(label: "攻撃力", value: item.attack)
            statusTile(label: "HP", value: item.health)
        }
        .padding(.horizontal, 12)
    }

    private func statusTile(label: String, value: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(GachaTheme.textMuted)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .monospacedDigit()
                .foregroundColor(GachaTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                .fill(GachaTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                        .stroke(GachaTheme.line, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            // もう一度召喚
            Button(action: onPlayAgain) {
                VStack(spacing: 2) {
                    Text("もう一度召喚")
                        .font(GachaFont.display(19, relativeTo: .title3))
                        .tracking(GachaFont.tracking(19))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(gachaCost.formatted())コイン")
                        .font(.system(size: 11, weight: .bold))
                        .monospacedDigit()
                }
                .foregroundColor(GachaTheme.goldButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(GachaGoldButtonBackground(shinePeriod: 2.8))
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("もう一度召喚、\(gachaCost)コイン")

            // 確認
            Button(action: onClose) {
                Text("確認")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)
                    .foregroundColor(GachaTheme.goldLight)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                            .fill(Color.black.opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                                    .stroke(GachaTheme.gold, lineWidth: 1)
                            )
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("確認して閉じる")
        }
    }
}

/// 結果画面の時間差登場（バネ）。Reduce Motion のときはフェードのみ。
private struct ResultAppear: ViewModifier {
    let isVisible: Bool
    let delay: Double
    let reduceMotion: Bool
    var fromScale: CGFloat = 0.85

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible || reduceMotion ? 1 : fromScale)
            .offset(y: isVisible || reduceMotion ? 0 : 16)
            .opacity(isVisible ? 1 : 0)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.25).delay(delay * 0.5)
                    : .spring(response: 0.6, dampingFraction: 0.7).delay(delay),
                value: isVisible
            )
    }
}

// MARK: - Particle Effect
struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<30 {
            let particle = Particle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.3...0.8)
            )
            particles.append(particle)
        }
        
        animateParticles()
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            for i in 0..<particles.count {
                particles[i].y -= CGFloat.random(in: 1...3)
                particles[i].opacity -= 0.01
                
                if particles[i].opacity <= 0 || particles[i].y < 0 {
                    particles[i].y = UIScreen.main.bounds.height
                    particles[i].x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                    particles[i].opacity = Double.random(in: 0.3...0.8)
                }
            }
        }
    }
}

// MARK: - Coin Purchase View
struct CoinPurchaseView: View {
    @Environment(\.dismiss) var dismiss
    
    // コインパッケージ定義
    struct CoinPackage {
        let coins: Int
        let price: String
        let bonus: String?
        let isPopular: Bool
        let gradientColors: [Color]
    }
    
    let packages = [
        CoinPackage(coins: 500, price: "¥120", bonus: nil, isPopular: false,
                    gradientColors: [Color(red: 0.4, green: 0.6, blue: 0.9), Color(red: 0.3, green: 0.5, blue: 0.8)]),
        CoinPackage(coins: 1200, price: "¥250", bonus: "+200ボーナス", isPopular: true,
                    gradientColors: [Color(red: 0.9, green: 0.6, blue: 0.2), Color(red: 0.8, green: 0.5, blue: 0.1)]),
        CoinPackage(coins: 2500, price: "¥490", bonus: "+500ボーナス", isPopular: false,
                    gradientColors: [Color(red: 0.7, green: 0.3, blue: 0.9), Color(red: 0.6, green: 0.2, blue: 0.8)]),
        CoinPackage(coins: 6000, price: "¥980", bonus: "+1500ボーナス", isPopular: false,
                    gradientColors: [Color(red: 0.9, green: 0.2, blue: 0.4), Color(red: 0.8, green: 0.1, blue: 0.3)])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Color2"),
                        Color("Color2").opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        VStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                            
                            Text("コイン購入")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("お得なパッケージをお選びください")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // コインパッケージ一覧
                        VStack(spacing: 16) {
                            ForEach(packages.indices, id: \.self) { index in
                                CoinPurchasePackageCard(package: packages[index])
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 注意事項
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                                Text("ご注意")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text("• 購入したコインは返金できません")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("• コインの有効期限はありません")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
}

#Preview {
    GachaView()
}

// MARK: - Previews (redesign)
private enum GachaPreviewData {
    static let mythic = GachaManager.Item(name: "創世神イザナギ", attack: 500, health: 800, probability: 1, rarity: .godMythicRare)
    static let rare = GachaManager.Item(name: "カゲロウ", attack: 35, health: 220, probability: 10, rarity: .rare)
    static let superRare = GachaManager.Item(name: "レッドドラゴン", attack: 47, health: 280, probability: 5, rarity: .superRare)
    static let ultra = GachaManager.Item(name: "レインボードラゴン", attack: 50, health: 300, probability: 3, rarity: .ultraRare)
    static let normal = GachaManager.Item(name: "ネッキー", attack: 10, health: 20, probability: 25, rarity: .normal)
    static let ultimate = GachaManager.Item(name: "黄龍", attack: 500, health: 800, probability: 50, rarity: .guardianUltimateRare)
}

#Preview("ガチャ画面（神）") {
    GachaLobbyScreen(
        gachaTitle: "神ガチャ",
        heroImageName: "神ガチャトップ",
        backgroundImageName: "GodGachaSceneBackground",
        ticketType: .godGachaTicket,
        ticketCount: 2,
        userMoney: 3200,
        cost: 1000,
        isDrawEnabled: true,
        rewardLoaded: true,
        catalogItems: GachaManager(mode: .god).catalogItems,
        onBack: {}, onCoinTap: {}, onDraw: {}, onTicketDraw: {}, onRewardAd: {}
    )
}

#Preview("ガチャ画面（押せない状態）") {
    GachaLobbyScreen(
        gachaTitle: "四聖獣ガチャ",
        heroImageName: "四聖獣ガチャトップ",
        backgroundImageName: "GuardianGachaSceneBackground",
        ticketType: .guardianGachaTicket,
        ticketCount: 0,
        userMoney: 200,
        cost: 1000,
        isDrawEnabled: false,
        rewardLoaded: false,
        catalogItems: GachaManager(mode: .guardian).catalogItems,
        onBack: {}, onCoinTap: {}, onDraw: {}, onTicketDraw: {}, onRewardAd: {}
    )
}

#Preview("結果（神レア・NEW）") {
    GachaResultView(item: GachaPreviewData.mythic, gachaCost: 1000, onClose: {}, onPlayAgain: {}, isNew: true)
}

#Preview("結果（ノーマル）") {
    GachaResultView(item: GachaPreviewData.normal, gachaCost: 300, onClose: {}, onPlayAgain: {})
}

#Preview("演出：ノーマル") {
    GachaAnimationView(rarity: .normal, item: GachaPreviewData.normal) {}
}

#Preview("演出：レア") {
    GachaAnimationView(rarity: .rare, item: GachaPreviewData.rare) {}
}

#Preview("演出：スーパーレア") {
    GachaAnimationView(rarity: .superRare, item: GachaPreviewData.superRare) {}
}

#Preview("演出：ウルトラレア") {
    GachaAnimationView(rarity: .ultraRare, item: GachaPreviewData.ultra) {}
}

#Preview("演出：神レア（虹）") {
    GachaAnimationView(rarity: .godMythicRare, item: GachaPreviewData.mythic) {}
}

#Preview("演出：アルティメット（虹）") {
    GachaAnimationView(rarity: .guardianUltimateRare, item: GachaPreviewData.ultimate) {}
}

#if DEBUG
/// 起動引数 `-GachaDesignPreview <screen>` でガチャ画面のデザインを単体表示する（Firebase に書き込まない）。
/// screen: list / lobby-normal / lobby-rare / lobby-meka / lobby-god / lobby-guardian / lobby-deepsea / lobby-disabled /
///         catalog-deepsea / result-new / result-normal / result-deepsea / anim-normal / anim-rare / anim-super /
///         anim-ultra / anim-mythic / anim-ultimate / anim-deepsea
struct GachaDesignPreview: View {
    @State private var showResult = false

    private var screen: String {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-GachaDesignPreview"), index + 1 < args.count else { return "list" }
        return args[index + 1]
    }

    var body: some View {
        switch screen {
        case "list":
            NavigationView { GachaManagerView(isPresenting: .constant(true)) }
                .navigationViewStyle(.stack)
        case let s where s.hasPrefix("lobby-"):
            lobby(String(s.dropFirst("lobby-".count)))
        case "result-new":
            GachaResultView(item: GachaPreviewData.mythic, gachaCost: 1000, onClose: {}, onPlayAgain: {}, isNew: true)
        case "result-normal":
            GachaResultView(item: GachaPreviewData.normal, gachaCost: 300, onClose: {}, onPlayAgain: {})
        case "result-deepsea":
            GachaResultView(item: deepSeaUltimate, gachaCost: GachaManager(mode: .deepSea).gachaCost, onClose: {}, onPlayAgain: {}, isNew: true)
        case "catalog-deepsea":
            GachaCatalogSheet(gachaTitle: "深海ガチャ", items: GachaManager(mode: .deepSea).catalogItems, accentColor: Color(hex: "36CDE6"))
        case let s where s.hasPrefix("anim-"):
            let item = animItem(String(s.dropFirst("anim-".count)))
            if showResult {
                GachaResultView(item: item, gachaCost: s == "anim-deepsea" ? GachaManager(mode: .deepSea).gachaCost : 1000, onClose: { showResult = false }, onPlayAgain: { showResult = false }, isNew: true)
            } else {
                GachaAnimationView(rarity: item.rarity, item: item) { showResult = true }
            }
        default:
            Text("unknown screen: \(screen)")
        }
    }

    private func animItem(_ key: String) -> GachaManager.Item {
        switch key {
        case "rare": return GachaPreviewData.rare
        case "super": return GachaPreviewData.superRare
        case "ultra": return GachaPreviewData.ultra
        case "mythic": return GachaPreviewData.mythic
        case "ultimate": return GachaPreviewData.ultimate
        case "deepsea": return deepSeaUltimate
        default: return GachaPreviewData.normal
        }
    }

    private var deepSeaUltimate: GachaManager.Item {
        GachaManager(mode: .deepSea).catalogItems.first { $0.rarity == .deepSeaUltimateRare }!
    }

    @ViewBuilder
    private func lobby(_ key: String) -> some View {
        let configs: [String: (GachaMode, InventoryItemType?)] = [
            "normal": (.normal, .normalGachaTicket),
            "rare": (.rare, .rareGachaTicket),
            "meka": (.meka, .mekaGachaTicket),
            "god": (.god, .godGachaTicket),
            "guardian": (.guardian, .guardianGachaTicket),
            "deepsea": (.deepSea, nil),
            "disabled": (.guardian, .guardianGachaTicket)
        ]
        let config = configs[key] ?? (.god, .godGachaTicket)
        let entry = GachaTheme.lineup.first { $0.mode == config.0 } ?? GachaTheme.lineup[GachaTheme.pickupIndex]
        let isDisabled = key == "disabled"

        GachaLobbyScreen(
            gachaTitle: entry.title,
            heroImageName: entry.title,
            backgroundImageName: "",
            ticketType: config.1,
            ticketCount: isDisabled ? 0 : 2,
            userMoney: isDisabled ? 200 : 3200,
            cost: entry.cost,
            isDrawEnabled: !isDisabled,
            rewardLoaded: !isDisabled,
            catalogItems: GachaManager(mode: config.0).catalogItems,
            onBack: {}, onCoinTap: {}, onDraw: {}, onTicketDraw: {}, onRewardAd: {}
        )
    }
}
#endif
