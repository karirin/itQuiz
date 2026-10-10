import SwiftUI

/// Floors 151–300. Encounter IDs are independent of their dedicated artwork.
enum DungeonExpansion {
    static let firstFloor = 151
    static let finalFloor = 300

    struct Area: Identifiable {
        let id: Int
        let title: String
        let mission: String
        let subjects: [Subject]
        let guardian: String

        var range: ClosedRange<Int> { (151 + id * 10)...(160 + id * 10) }
        var monsterFloors: [Int] { [1, 2, 4, 6, 8].map { range.lowerBound + $0 } }
        var monsterID: Int { 1_000 + monsterFloors[0] }
        var bossID: Int { 101 + id }
        var isChapterFinale: Bool { id % 5 == 4 }
        var quizTitle: String { subjects.map(\.title).joined(separator: "・") }
    }

    enum Subject: String, CaseIterable {
        case network, security, computer, design, development, operation, planning
        case technology, management, strategy

        var title: String {
            switch self {
            case .network: return "ネットワーク"
            case .security: return "セキュリティ"
            case .computer: return "コンピュータシステム"
            case .design: return "システム設計"
            case .development: return "システム開発"
            case .operation: return "運用・保守"
            case .planning: return "システム企画"
            case .technology: return "応用テクノロジ"
            case .management: return "応用マネジメント"
            case .strategy: return "応用ストラテジ"
            }
        }

        var quizLevel: QuizLevel {
            switch self {
            case .network: return .netwarkTusin
            case .security: return .ESsecurity
            case .computer: return .computerSystem
            case .design: return .sekkei
            case .development: return .kaihatu
            case .operation: return .unyouhoshu
            case .planning: return .kikaku
            case .technology: return .appliedTechnology
            case .management: return .appliedManagement
            case .strategy: return .appliedStrategy
            }
        }
    }

    static let areas: [Area] = [
        Area(id: 0, title: "通信の吊り橋", mission: "途切れた通信路をつなぎ、空中要塞への道を開こう。", subjects: [.network], guardian: "経路の番人 ルートガー"),
        Area(id: 1, title: "暗号の城門", mission: "暗号と認証を使い分け、偽りの鍵を見破ろう。", subjects: [.security], guardian: "暗号騎士 シファー"),
        Area(id: 2, title: "仮想機関室", mission: "サーバと資源の仕組みを読み解き、停止した機関を動かそう。", subjects: [.computer, .network], guardian: "仮想巨兵 ハイパリオン"),
        Area(id: 3, title: "監視の回廊", mission: "障害と攻撃の兆候を探し、要塞の防御を立て直そう。", subjects: [.operation, .security], guardian: "監視獣 センチネル"),
        Area(id: 4, title: "防衛中枢", mission: "通信・認証・運用の知識を結集し、要塞を奪還しよう。", subjects: [.network, .security, .computer, .operation], guardian: "要塞竜 ファイアウォール"),
        Area(id: 5, title: "記録の書庫", mission: "データと処理の関係を整理し、眠る記録を読み解こう。", subjects: [.technology], guardian: "記録獣 アーカイブ"),
        Area(id: 6, title: "設計の水路", mission: "要求を設計へ落とし込み、迷宮を流れる情報を整えよう。", subjects: [.design], guardian: "設計騎士 スキーマ"),
        Area(id: 7, title: "実装の工房", mission: "開発とテストの知識で、壊れた仕掛けを修復しよう。", subjects: [.development], guardian: "試験巨兵 テストロン"),
        Area(id: 8, title: "復旧の神殿", mission: "障害への備えと復旧手順を学び、失われた機能を取り戻そう。", subjects: [.operation, .design], guardian: "復旧鳥 リカバリア"),
        Area(id: 9, title: "創造の炉心", mission: "設計・開発・運用をつなぎ、遺跡の炉心を再起動しよう。", subjects: [.technology, .design, .development, .operation], guardian: "機神 アーキテクト"),
        Area(id: 10, title: "戦略の議場", mission: "課題と投資を見極め、天空へ続く計画を描こう。", subjects: [.strategy, .planning], guardian: "戦略王 ストラテガ"),
        Area(id: 11, title: "計画の時計塔", mission: "品質・コスト・納期の均衡を保ち、止まった時計を進めよう。", subjects: [.management], guardian: "時の監督 クロノス"),
        Area(id: 12, title: "技術の星廊", mission: "分野を越えて技術を選び、星の回路をつなごう。", subjects: [.technology, .network, .development], guardian: "星詠み オラクル"),
        Area(id: 13, title: "信頼の天秤", mission: "安全性と継続性を確かめ、最後の門を開こう。", subjects: [.security, .operation, .management], guardian: "秩序の守護者 ガバナス"),
        Area(id: 14, title: "知恵の頂", mission: "技術・管理・戦略の総合力で、300階の最終試練に挑もう。", subjects: [.technology, .management, .strategy], guardian: "知恵の覇竜 ソフィア")
    ]

    static func area(at floor: Int) -> Area? {
        guard (firstFloor...finalFloor).contains(floor) else { return nil }
        return areas[(floor - firstFloor) / 10]
    }

    static func encounterID(at floor: Int) -> Int? {
        guard let area = area(at: floor) else { return nil }
        switch (floor - firstFloor) % 10 + 1 {
        case 2, 3, 5, 7, 9: return 1_000 + floor
        case 10 where area.isChapterFinale: return area.bossID
        default: return nil
        }
    }

    static func treasureID(at floor: Int) -> Int? {
        guard let area = area(at: floor) else { return nil }
        switch (floor - firstFloor) % 10 + 1 {
        case 4: return 31 + area.id * 2
        case 8: return 32 + area.id * 2
        default: return nil
        }
    }

    static func isBossFloor(_ floor: Int) -> Bool {
        [200, 250, 300].contains(floor)
    }

    static func encounterName(for id: Int) -> String {
        (101...115).contains(id) ? "ボス\(id)" : "モンスター\(id)"
    }

    static func monster(for id: Int) -> Monster? {
        let isBoss = (101...115).contains(id)
        guard let index = isBoss ? Optional(id - 101) : regularMonsterIndex(for: id).map({ $0 / 5 }) else { return nil }
        guard areas.indices.contains(index) else { return nil }
        guard !isBoss || areas[index].isChapterFinale else { return nil }
        let finale = isBoss && areas[index].isChapterFinale
        let hp = finale ? 6_000 + (index / 5) * 1_500 : (isBoss ? 3_200 + index * 300 : 1_000 + index * 100)
        let attack = finale ? 550 + (index / 5) * 75 : (isBoss ? 400 + index * 15 : 360 + index * 15)
        let reward = finale ? 3_000 + (index / 5) * 1_000 : (isBoss ? 1_200 + index * 100 : 550 + index * 35)
        return Monster(name: encounterName(for: id), playerExperience: reward, playerMoney: reward,
                       monsterHP: hp, monsterUnderHP: hp, monsterAttack: attack)
    }

    static let monstersByName: [String: Monster] = {
        let monsters = areas.flatMap { area -> [Monster] in
            area.monsterFloors.map { monster(for: 1_000 + $0)! } + (monster(for: area.bossID).map { [$0] } ?? [])
        }
        return Dictionary(uniqueKeysWithValues: monsters.map { ($0.name, $0) })
    }()

    /// Stable floor-based IDs give every regular battle its own enemy and artwork.
    private static func regularMonsterIndex(for id: Int) -> Int? {
        let floor = id - 1_000
        guard let area = area(at: floor), let slot = area.monsterFloors.firstIndex(of: floor) else { return nil }
        return area.id * 5 + slot
    }

    private static let regularMonsterNames: [String] = [
        "雷翼コウモリ",
        "プリズム甲虫",
        "雲海エイ",
        "電波キツネザル",
        "伝導ムカデ",
        "仮面ジャッカル",
        "鍵殻カニ",
        "暗号カマキリ",
        "鍵の精霊",
        "鏡紋ナメクジ",
        "仮想クラゲ",
        "演算ウニ",
        "機関カモノハシ",
        "幻灯ガ",
        "硝子ミミズ",
        "遠望キリン",
        "灯眼アンコウ",
        "見張りミーアキャット",
        "透視カメレオン",
        "監察クジャク",
        "鉄殻アルマジロ",
        "城壁サイ",
        "六角ガメ",
        "防壁ハリネズミ",
        "結界ケンタウロス",
        "書架ヘラジカ",
        "古書カタツムリ",
        "索引アナグマ",
        "筆針ヤマアラシ",
        "巻物タツノオトシゴ",
        "水門ワニ",
        "栓術カワウソ",
        "結びヘビ",
        "羅針コウノトリ",
        "架橋グモ",
        "金槌キノコ",
        "工具ザル",
        "継ぎ目人形",
        "歯車バッタ",
        "試験ウサギ",
        "救命イルカ",
        "再生サンショウウオ",
        "芽角シカ",
        "蓮のマンドラゴラ",
        "薬師ペリカン",
        "炉心イノシシ",
        "金床オーロックス",
        "黒曜サソリ",
        "鐘楼キマイラ",
        "機巧オウムガイ",
        "王冠ライオン",
        "棋駒の馬",
        "金貨カササギ",
        "旗印バイソン",
        "地図バク",
        "砂時計カンガルー",
        "振り子ペンギン",
        "暦のカピバラ",
        "針路トンボ",
        "時刻ハムスター",
        "彗星ギツネ",
        "隕石コオロギ",
        "星座タコ",
        "天測ユニコーン",
        "星盤フェニックス",
        "天秤トキ",
        "誓約センザンコウ",
        "真実のハクチョウ",
        "契約シロクマ",
        "封印コウイカ",
        "智慧スフィンクス",
        "瑞雲キリン",
        "結晶チョウ",
        "賢者ゾウ",
        "三眼トラ",
    ]

    static func artworkName(for name: String) -> String {
        if name.hasPrefix("モンスター"), let id = Int(name.dropFirst("モンスター".count)),
           regularMonsterIndex(for: id) != nil {
            return "DungeonFloorMonster\(id - 1_000)"
        }
        switch name {
        case "ボス105": return "DungeonBossFirewall"
        case "ボス110": return "DungeonBossArchitect"
        case "ボス115": return "DungeonBossSophia"
        default: return name
        }
    }

    static func displayName(for name: String) -> String {
        if name.hasPrefix("モンスター"), let id = Int(name.dropFirst("モンスター".count)),
           let index = regularMonsterIndex(for: id) {
            return regularMonsterNames[index]
        }
        if let area = areas.first(where: { $0.isChapterFinale && name == encounterName(for: $0.bossID) }) {
            return area.guardian
        }
        return name
    }

    static func treasureArtwork(for id: Int) -> String {
        (31...60).contains(id) ? "DungeonExpansionTreasure\(id)" : "宝箱\(id)"
    }

    static func treasure(for id: Int) -> Treasure? {
        guard (31...60).contains(id) else { return nil }
        let coins = 1_500 + ((id - 31) / 2) * 100
        return Treasure(coinImage: treasureArtwork(for: id), coinTitle: "\(coins)コインゲット！！", reward: coins)
    }

    static func treasureRewards(for id: Int) -> [InventoryReward] {
        guard (31...60).contains(id), id.isMultiple(of: 2) else { return [] }
        switch id {
        case 40: return [InventoryReward(type: .rareGachaTicket, amount: 1)]
        case 50: return [InventoryReward(type: .mekaGachaTicket, amount: 1)]
        case 60: return [InventoryReward(type: .boostTicket, amount: 1)]
        default: return [InventoryReward(type: .staminaPotion, amount: 1)]
        }
    }

    static func battleRewards(for name: String) -> [InventoryReward] {
        guard let area = areas.first(where: { $0.isChapterFinale && encounterName(for: $0.bossID) == name }) else { return [] }
        switch area.id {
        case 4: return [InventoryReward(type: .mekaGachaTicket, amount: 1), InventoryReward(type: .staminaPotion, amount: 2)]
        case 9: return [InventoryReward(type: .godGachaTicket, amount: 1), InventoryReward(type: .boostTicket, amount: 1)]
        case 14: return [InventoryReward(type: .godGachaTicket, amount: 2), InventoryReward(type: .boostTicket, amount: 2)]
        default: return [InventoryReward(type: .staminaPotion, amount: 1)]
        }
    }

    static func treasureBoosts(for id: Int) -> [DungeonBoost] {
        guard (31...60).contains(id), id.isMultiple(of: 2) else { return [] }
        return [DungeonBoost(type: .attackSurge, charges: 3)]
    }

    /// Three 50-floor chapters, each ending in one standalone boss platform.
    static let platformRows: [[PlatformData]] = {
        [251, 201, 151].flatMap { start -> [[PlatformData]] in
            let bossFloor = start + 49
            let regularFloors = Array((start..<bossFloor).reversed())
            let rowSizes = [2] + Array(repeating: 3, count: 15) + [2]
            var offset = 0
            var rows = [[platform(at: bossFloor)]]
            for (index, rowSize) in rowSizes.enumerated() {
                let floors = Array(regularFloors[offset..<(offset + rowSize)])
                let ordered = index.isMultiple(of: 2) ? Array(floors.reversed()) : floors
                rows.append(ordered.enumerated().map { column, floor in
                    // Follow the earlier floors' alternating staircase, without
                    // deriving height from the floor number (which made V shapes).
                    let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
                    let elevation = direction * CGFloat(2 * column - (rowSize - 1)) * 30
                    return platform(at: floor, elevation: elevation)
                })
                offset += rowSize
            }
            return rows
        }
    }()

    private static func platform(at floor: Int, elevation: CGFloat = 0) -> PlatformData {
        let encounter = encounterID(at: floor) ?? 0
        return PlatformData(imageName: platformArtwork(at: floor), position: floor,
                            padding: EdgeInsets(top: 0, leading: 0, bottom: elevation, trailing: 0),
                            padding1: EdgeInsets(top: 0, leading: 0, bottom: elevation + 60, trailing: 0),
                            boss: isBossFloor(floor) ? encounter : 0,
                            treasure: treasureID(at: floor) ?? 0,
                            monster: isBossFloor(floor) ? 0 : encounter)
    }

    static func platformArtwork(at floor: Int) -> String {
        switch floor {
        case 151...200: return "DungeonStorybookBlueCrystalPlatform"
        case 201...250: return "DungeonStorybookRunePlatform"
        case 251...300: return "DungeonStorybookCrystalPlatform"
        case 102...150: return "DungeonStorybookOchrePlatform"
        case 53...101: return "DungeonStorybookLavenderPlatform"
        default: return "DungeonStorybookMossPlatform"
        }
    }

    static func background(at floor: Int) -> String {
        switch floor {
        case 151...200: return "DungeonSkyDefenseBackground"
        case 201...250: return "DungeonClockworkRuinsBackground"
        case 251...300: return "DungeonSkyTrialBackground"
        case 52...100: return "DungeonStorybookLavenderCaveBackground"
        case 101...150: return "DungeonStorybookTerracottaDepthBackground"
        default: return "DungeonStorybookForestBackground"
        }
    }
}

/// Reuse the app's subject banks; build each bank only when first needed.
enum DungeonExpansionQuestions {
    private static let network = QuizTusinNetworkListView(isPresenting: .constant(false)).quizBeginnerList
    private static let security = QuizESsecurityListView(isPresenting: .constant(false)).quizBeginnerList
    private static let computer = QuizComputerSystemListView(isPresenting: .constant(false)).quizBeginnerList
    private static let design = QuizSystemSekkeiListView(isPresenting: .constant(false)).quizBeginnerList
    private static let development = QuizSystemKaihatuListView(isPresenting: .constant(false)).quizBeginnerList
    private static let operation = QuizSystemUnyouHoshuListView(isPresenting: .constant(false)).quizBeginnerList
    private static let planning = QuizSystemKikakuListView(isPresenting: .constant(false)).quizBeginnerList
    private static let technology = QuizAppliedTechnologyListView(isPresenting: .constant(false)).quizBeginnerList
    private static let management = QuizAppliedManagementListView(isPresenting: .constant(false)).quizBeginnerList
    private static let strategy = QuizAppliedStrategyListView(isPresenting: .constant(false)).quizBeginnerList

    static func level(for source: String?, fallback: QuizLevel) -> QuizLevel {
        QuizLevel.allCases.first(where: { $0.description == source }) ?? fallback
    }

    static func pool(for subject: DungeonExpansion.Subject) -> [QuizQuestion] {
        let questions: [QuizQuestion]
        switch subject {
        case .network: questions = network
        case .security: questions = security
        case .computer: questions = computer
        case .design: questions = design
        case .development: questions = development
        case .operation: questions = operation
        case .planning: questions = planning
        case .technology: questions = technology
        case .management: questions = management
        case .strategy: questions = strategy
        }
        return questions.filter { $0.isFourChoices && $0.choices.indices.contains($0.correctAnswerIndex) }.map {
            var question = $0
            question.sourceQuizLevel = subject.quizLevel.description
            return question
        }
    }

    static func questions(for area: DungeonExpansion.Area) -> [QuizQuestion] {
        // Interleave sources so large banks do not drown out smaller subjects in mixed trials.
        let pools = area.subjects.map { pool(for: $0).shuffled() }
        var seen = Set<String>()
        var questions: [QuizQuestion] = []
        for index in 0..<(pools.map(\.count).max() ?? 0) {
            for pool in pools where pool.indices.contains(index) {
                let question = pool[index]
                if seen.insert(question.question).inserted { questions.append(question) }
            }
        }
        return questions
    }
}

struct DungeonExpansionQuizView: View {
    @Binding var isPresenting: Bool
    @ObservedObject var viewModel: PositionViewModel
    let monsterName: String
    let area: DungeonExpansion.Area
    @State private var quizzes: [QuizQuestion]
    @StateObject private var interstitial = Interstitial()

    init(isPresenting: Binding<Bool>, viewModel: PositionViewModel, monsterName: String, area: DungeonExpansion.Area) {
        _isPresenting = isPresenting
        self.viewModel = viewModel
        self.monsterName = monsterName
        self.area = area
        _quizzes = State(initialValue: DungeonExpansionQuestions.questions(for: area))
    }

    var body: some View {
        StoryQuizView(viewModel: viewModel, quizzes: quizzes, quizLevel: area.subjects[0].quizLevel,
                      monsterName: monsterName, backgroundName: DungeonExpansion.background(at: area.range.lowerBound),
                      authManager: AuthManager.shared, audioManager: AudioManager.shared,
                      isPresenting: $isPresenting, interstitial: interstitial)
    }
}
