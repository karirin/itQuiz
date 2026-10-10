import Foundation

enum AdventureNodeKind: String, Codable {
    case village, road, treasure, monster, camp, shrine, bridge, boss, port

    var title: String {
        switch self {
        case .village: return "拠点"
        case .road: return "探索"
        case .treasure: return "お宝"
        case .monster: return "バトル"
        case .camp: return "休憩"
        case .shrine: return "古代の鍵"
        case .bridge: return "封印の橋"
        case .boss: return "BOSS"
        case .port: return "次の地方"
        }
    }

    var symbol: String {
        switch self {
        case .village: return "house.fill"
        case .road: return "leaf.fill"
        case .treasure: return "shippingbox.fill"
        case .monster: return "leaf.circle.fill"
        case .camp: return "tent.fill"
        case .shrine: return "building.columns.fill"
        case .bridge: return "key.fill"
        case .boss: return "crown.fill"
        case .port: return "sailboat.fill"
        }
    }
}

struct AdventureNode: Identifiable, Hashable {
    let id: Int
    let x: Double
    let y: Double
    let kind: AdventureNodeKind
    let name: String
    let detail: String
    var coins: Int = 0

    var isBattle: Bool { kind == .monster || kind == .boss }
    var enemyHP: Int {
        switch id {
        case 3, 22: return 180
        case 14: return 240
        case 6: return 270
        case 27: return 300
        case 17: return 360
        case 18: return 390
        case 36: return 420
        case 32: return 450
        case 9: return 1000
        default: return kind == .boss ? 1000 : 180
        }
    }
    var enemyAttack: Int {
        switch id {
        case 3, 22: return 35
        case 14, 6: return 40
        case 27: return 45
        case 17, 18: return 50
        case 36, 32: return 55
        case 9: return 80
        default: return kind == .boss ? 80 : 35
        }
    }
}

enum AdventureWorld {
    static let chapterID = "forest-v1"
    static let width: Double = 760
    static let height: Double = 1100
    /// Six carefully placed chests provide recovery for the chapter's routes.
    /// The remaining chests still award their listed coins.
    static let potionTreasureIDs: Set<Int> = [2, 7, 12, 15, 25, 29]
    static let nodes: [AdventureNode] = [
        .init(id: 0, x: 250, y: 1300, kind: .village, name: "出発の村", detail: "村のみんなが、あなたの冒険を応援している。"),
        // Bring the first destination closer to the village, then distribute
        // the following stops in even tiers so the opening route stays compact.
        .init(id: 1, x: 300, y: 1080, kind: .road, name: "森の入口", detail: "さあ、最初の一歩を踏み出そう。"),
        .init(id: 2, x: 175, y: 920, kind: .treasure, name: "木陰の宝箱", detail: "木の根元に、金色の宝箱を見つけた。", coins: 80),
        .init(id: 3, x: 450, y: 880, kind: .monster, name: "モススライム", detail: "道をふさぐモンスター。クイズで戦おう。", coins: 40),
        .init(id: 4, x: 325, y: 760, kind: .road, name: "森の分かれ道", detail: "木立の間で道が二手に分かれている。"),
        .init(id: 5, x: 137, y: 620, kind: .shrine, name: "古い祠", detail: "石碑に眠る、森の秘密を解き明かそう。"),
        .init(id: 6, x: 470, y: 600, kind: .monster, name: "リーフガード", detail: "森の奥へ進む道を守っている。", coins: 60),
        .init(id: 7, x: 525, y: 470, kind: .treasure, name: "旅人の宝箱", detail: "寄り道の先に、特別なお宝がありそう。", coins: 150),
        .init(id: 8, x: 340, y: 450, kind: .bridge, name: "封印の橋", detail: "古い祠の鍵で、封印された道をひらく。"),
        .init(id: 9, x: 285, y: 280, kind: .boss, name: "森の主", detail: "同じ朝を繰り返す守り手に、今日を届けよう。", coins: 200),
        .init(id: 10, x: 455, y: 165, kind: .port, name: "潮風の港町", detail: "森を抜けた先に、新しい冒険が待っている。"),
        .init(id: 12, x: 615, y: 900, kind: .treasure, name: "陽だまりの宝箱", detail: "木漏れ日の中に、古びた宝箱が隠れている。", coins: 90),
        .init(id: 13, x: 650, y: 675, kind: .road, name: "東の分かれ道", detail: "東風に導かれ、森の奥へ続く小道。"),
        .init(id: 14, x: 70, y: 735, kind: .monster, name: "葉陰の番人", detail: "西の細道を守るモンスターが現れた。", coins: 50),
        .init(id: 15, x: 85, y: 390, kind: .treasure, name: "滝裏の宝箱", detail: "滝の陰で、きらりと光る宝箱を見つけた。", coins: 110),
        .init(id: 16, x: 565, y: 290, kind: .road, name: "丘の見晴らし", detail: "木々の上から、港へ続く道が見える。"),
        .init(id: 17, x: 685, y: 430, kind: .monster, name: "風見の番人", detail: "北東の丘に、森の番人が立っている。", coins: 70),
        .init(id: 18, x: 95, y: 235, kind: .monster, name: "霧のモススライム", detail: "滝の上から漂う霧に、スライムが潜んでいた。", coins: 60),
        // Keep stop IDs stable for saves. Stops along the same trail connect
        // in sequence rather than creating a parallel shortcut.
        .init(id: 19, x: 465, y: 1050, kind: .road, name: "花風の分かれ道", detail: "花びらが風に舞う、東へ続く静かな小道。"),
        .init(id: 20, x: 560, y: 970, kind: .treasure, name: "月影の宝箱", detail: "月明かりを受けて、宝箱がそっと光っている。", coins: 100),
        // Keep the early detour on the east side of the main route. This
        // prevents its path from crossing the 3 → 4 story route.
        .init(id: 21, x: 358, y: 993, kind: .road, name: "鳥歌の小径", detail: "小鳥の歌声をたどると、森の東側へ抜けられる。"),
        .init(id: 22, x: 307, y: 906, kind: .monster, name: "つる草スライム", detail: "つる草をまとったスライムが、道の真ん中で待ち構えている。", coins: 55),
        .init(id: 23, x: 610, y: 790, kind: .road, name: "東風の小径", detail: "やわらかな風が吹く、森の東側の小径。"),
        .init(id: 24, x: 585, y: 640, kind: .road, name: "琥珀の小道", detail: "夕陽色の木漏れ日が、奥へ続く足元を照らしている。"),
        .init(id: 25, x: 575, y: 535, kind: .treasure, name: "露草の宝箱", detail: "朝露に包まれた草むらで、小さな宝箱を見つけた。", coins: 120),
        .init(id: 26, x: 250, y: 686, kind: .road, name: "古樹の小道", detail: "大きな古樹の根元をくぐる、苔むした抜け道。"),
        .init(id: 27, x: 285, y: 570, kind: .monster, name: "木漏れ日の守り手", detail: "古樹のそばで、森の秘密を守る番人が立ちはだかる。", coins: 65),
        .init(id: 28, x: 565, y: 380, kind: .road, name: "風渡る峠", detail: "高台を抜ける風が、潮の香りを運んでくる。"),
        .init(id: 29, x: 120, y: 490, kind: .treasure, name: "星見の宝箱", detail: "夜空がよく見える崖のそばに、宝箱が隠されている。", coins: 130),
        // The tall artwork adds terrain above the port and below the village.
        // Negative and overflow y-values are presentation coordinates only;
        // they are shifted into the vertically expanded storybook canvas.
        .init(id: 30, x: 190, y: -50, kind: .road, name: "雲上の滝道", detail: "雲をくぐり、滝の源流へ向かう細い山道。"),
        .init(id: 31, x: 365, y: -125, kind: .treasure, name: "空翠の宝箱", detail: "海を見下ろす断崖で、澄んだ光を放つ宝箱を見つけた。", coins: 180),
        .init(id: 32, x: 535, y: -60, kind: .monster, name: "雲海の番人", detail: "白い霧の向こうから、峠を守る番人が現れた。", coins: 90),
        .init(id: 33, x: 665, y: 25, kind: .road, name: "岬の小径", detail: "潮風と滝音が交わる、岬へ続く細道。"),
        // The southern trail stays to the east of the village-to-entrance
        // route so the long connector never cuts across the starting course.
        .init(id: 34, x: 520, y: 1140, kind: .road, name: "深緑の小径", detail: "村の南に続く、木漏れ日の静かな小径。"),
        .init(id: 35, x: 635, y: 1070, kind: .treasure, name: "渓谷の宝箱", detail: "渓流のそばで、苔に隠れた古い宝箱を見つけた。", coins: 140),
        .init(id: 36, x: 640, y: 1170, kind: .monster, name: "谷風の守り手", detail: "風の通り道を守る、森の番人が立ちはだかる。", coins: 75),
        .init(id: 37, x: 580, y: 1250, kind: .road, name: "川霧の渡り道", detail: "川霧の中を進むと、遠くで滝の音が聞こえる。"),
        .init(id: 38, x: 500, y: 1300, kind: .road, name: "谷あいの小径", detail: "深い森に囲まれた、谷を抜ける静かな小径。")
    ]
    static let edges: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 4), (3, 4), (4, 6), (5, 8), (7, 8), (8, 9), (9, 10),
        // The village deliberately has one departure only. Optional routes
        // merge into the forest beyond the entrance, rather than fanning out
        // from the starting marker.
        (3, 12), (2, 14), (14, 5),
        (16, 10), (16, 17), (17, 13), (15, 18),
        (19, 20), (20, 12),
        // Each chain is the sole trail between its endpoints. Direct edges
        // here would draw a second course and bypass the intermediate stops.
        (1, 21), (21, 22), (22, 3),
        (12, 23), (23, 13), (13, 24), (24, 6),
        (6, 25), (25, 7), (4, 26), (26, 27), (27, 5),
        (7, 28), (28, 16), (5, 29), (29, 15),
        (10, 30), (30, 31), (31, 32), (32, 33),
        (19, 34), (34, 35), (35, 36), (36, 37), (37, 38)
    ]

    static func node(_ id: Int) -> AdventureNode? { nodes.first { $0.id == id } }
    static func neighbors(of id: Int) -> [Int] {
        edges.compactMap { a, b in a == id ? b : b == id ? a : nil }
    }

    /// A map-only guide that ignores encounter and lock requirements. It is
    /// used to explain one tapped, unavailable destination without making it
    /// playable.
    static func guidanceRoute(from start: Int, to target: Int) -> [Int]? {
        guard node(start) != nil, node(target) != nil else { return nil }
        if start == target { return [start] }

        // Count physical trail length rather than stops. Otherwise inserting
        // intermediate markers makes guidance prefer a long, unrelated branch.
        var paths = [start: [start]]
        var distances: [Int: Double] = [start: 0]
        var pending: Set<Int> = [start]
        var visited: Set<Int> = []
        while let current = pending.min(by: {
            let lhs = distances[$0] ?? .infinity, rhs = distances[$1] ?? .infinity
            return lhs == rhs ? $0 < $1 : lhs < rhs
        }) {
            if current == target { return paths[current] }
            pending.remove(current)
            visited.insert(current)
            guard let from = node(current), let path = paths[current] else { continue }
            for next in neighbors(of: current) where !visited.contains(next) {
                guard let to = node(next) else { continue }
                let distance = (distances[current] ?? .infinity) + hypot(to.x - from.x, to.y - from.y)
                if distance < (distances[next] ?? .infinity) {
                    distances[next] = distance
                    paths[next] = path + [next]
                    pending.insert(next)
                }
            }
        }
        return nil
    }

    static func rewardKey(for id: Int) -> String { "story-adventure.\(chapterID).node-\(id)" }

    static func treasureGrantsPotion(_ id: Int) -> Bool {
        potionTreasureIDs.contains(id)
    }
}

struct AdventureQuestion: Codable, Equatable, Identifiable {
    let id: String
    let question: String
    let choices: [String]
    let correctAnswerIndex: Int
    let explanation: String

    var isValid: Bool {
        !id.isEmpty && !question.isEmpty && choices.count >= 2 && choices.indices.contains(correctAnswerIndex)
    }
}

enum AdventureCourse: String, Codable, CaseIterable, Identifiable {
    case itPassport, fundamental, applied
    var id: String { rawValue }
    var title: String {
        switch self {
        case .itPassport: return "ITパスポート"
        case .fundamental: return "基本情報"
        case .applied: return "応用情報"
        }
    }
}
