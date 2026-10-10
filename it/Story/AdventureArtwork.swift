import SwiftUI

enum AdventurePalette {
    static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
    static let paper = adaptive(0xFBF8EF, 0x20372F)
    static let ink = adaptive(0x203C35, 0xF1EDDD)
    static let muted = adaptive(0x697A6D, 0xB2C1B4)
    static let line = adaptive(0xE2E3D4, 0x45604F)
    static let deep = adaptive(0x21483C, 0x163D30)
    static let ground = adaptive(0xC9D5B1, 0x48654C)
    static let patch = adaptive(0xB6C69D, 0x3B5840)
    static let grass = adaptive(0xE0E2BB, 0x586D4B)
    static let tree = adaptive(0x55795A, 0x2E523D)
    static let leaf = adaptive(0x789361, 0x52794C)
    static let lit = adaptive(0x9EB67A, 0x708E59)
    static let water = adaptive(0x8EBDC0, 0x497C84)
    static let wave = adaptive(0xC6DDCE, 0x729D9E)
    static let trail = adaptive(0xF4E6C6, 0xA9A17B)
    static let edge = adaptive(0xACAE85, 0x6F7A54)
    static let stone = adaptive(0x9AAB95, 0x667D6B)
    static let mist = adaptive(0xECEDD7, 0x687D6A)
    static let gold = Color(hex: "EDC879")
}

enum AdventureSpriteAsset: String, CaseIterable {
    case mossSlime = "StorySpriteMossSlime"
    case leafGuard = "StorySpriteLeafGuard"
    case forestGuardian = "StorySpriteForestGuardian"
    case treasureClosed = "StorySpriteTreasureClosed"
    case treasureOpen = "StorySpriteTreasureOpen"
    case village = "StorySpriteVillage"
    case forestEntrance = "StorySpriteForestEntrance"
    case camp = "StorySpriteCamp"
    case shrine = "StorySpriteShrine"
    case bridge = "StorySpriteBridge"
    case port = "StorySpritePort"
    case streamPath = "StorySpriteStreamPath"
    case eastCamp = "StorySpriteEastCamp"
    case leafshadeGuard = "StorySpriteLeafshadeGuard"
    case waterfallTreasureClosed = "StorySpriteWaterfallTreasureClosed"
    case hillLookout = "StorySpriteHillLookout"
    case windGuard = "StorySpriteWindGuard"
    case mistSlime = "StorySpriteMistSlime"
    case flowerPath = "StorySpriteFlowerPath"
    case moonlightTreasure = "StorySpriteMoonlightTreasure"
    case birdsongPath = "StorySpriteBirdsongPath"
    case vineSlime = "StorySpriteVineSlime"
    case eastWindCamp = "StorySpriteEastWindCamp"
    case amberPath = "StorySpriteAmberPath"
    case dewTreasure = "StorySpriteDewTreasure"
    case ancientRootPath = "StorySpriteAncientRootPath"
    case sunlitGuardian = "StorySpriteSunlitGuardian"
    case windyPass = "StorySpriteWindyPass"
    case starviewTreasure = "StorySpriteStarviewTreasure"

    private static let images: [AdventureSpriteAsset: UIImage] = Dictionary(uniqueKeysWithValues: allCases.compactMap { asset in
        UIImage(named: asset.rawValue).map { (asset, $0) }
    })

    var image: UIImage? { Self.images[self] }

    static func resolve(kind: AdventureNodeKind, nodeID: Int?, completed: Bool) -> AdventureSpriteAsset {
        switch kind {
        case .monster:
            if nodeID == 32 { return .windGuard }
            if nodeID == 36 { return .leafshadeGuard }
            if nodeID == 22 { return .vineSlime }
            if nodeID == 27 { return .sunlitGuardian }
            if nodeID == 14 { return .leafshadeGuard }
            if nodeID == 17 { return .windGuard }
            if nodeID == 18 { return .mistSlime }
            return nodeID == 6 ? .leafGuard : .mossSlime
        case .boss: return .forestGuardian
        case .treasure:
            if completed { return .treasureOpen }
            if nodeID == 31 { return .moonlightTreasure }
            if nodeID == 35 { return .waterfallTreasureClosed }
            if nodeID == 15 { return .waterfallTreasureClosed }
            if nodeID == 20 { return .moonlightTreasure }
            if nodeID == 25 { return .dewTreasure }
            if nodeID == 29 { return .starviewTreasure }
            return .treasureClosed
        case .village: return .village
        case .road:
            if nodeID == 30 { return .windyPass }
            if nodeID == 34 { return .streamPath }
            if nodeID == 37 { return .ancientRootPath }
            if nodeID == 19 { return .flowerPath }
            if nodeID == 21 { return .birdsongPath }
            if nodeID == 24 { return .amberPath }
            if nodeID == 26 { return .ancientRootPath }
            if nodeID == 28 { return .windyPass }
            if nodeID == 11 { return .streamPath }
            return nodeID == 16 ? .hillLookout : .forestEntrance
        case .camp:
            if nodeID == 23 { return .eastWindCamp }
            return nodeID == 13 ? .eastCamp : .camp
        case .shrine: return .shrine
        case .bridge: return .bridge
        case .port: return .port
        }
    }
}

struct AdventureIllustration: View {
    let kind: AdventureNodeKind
    var completed = false
    var nodeID: Int?
    var outlineWidth: CGFloat = 0

    var body: some View {
        Group {
            if let image = AdventureSpriteAsset.resolve(kind: kind, nodeID: nodeID, completed: completed).image {
                AdventureSpriteImage(image: image, outlineWidth: outlineWidth)
                    .overlay(alignment: .bottom) {
                        if kind == .bridge && !completed {
                            Image(systemName: "lock.fill").font(.system(size: 12, weight: .bold))
                                .foregroundColor(AdventurePalette.gold).padding(4)
                                .background(AdventurePalette.deep, in: Circle())
                        }
                    }
            } else {
                Canvas { context, size in
                    var painter = AdventurePainter(context: context)
                    painter.context.translateBy(x: size.width / 2, y: size.height * 0.60)
                    let scale = min(size.width / 75, size.height / 80)
                    painter.context.scaleBy(x: scale, y: scale)
                    painter.marker(kind, completed: completed)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private struct AdventureSpriteImage: View {
    let image: UIImage
    let outlineWidth: CGFloat

    private static let outlineDirections: [CGSize] = [
        CGSize(width: -1, height: 0), CGSize(width: 1, height: 0),
        CGSize(width: 0, height: -1), CGSize(width: 0, height: 1),
        CGSize(width: -0.707, height: -0.707), CGSize(width: 0.707, height: -0.707),
        CGSize(width: -0.707, height: 0.707), CGSize(width: 0.707, height: 0.707)
    ]

    var body: some View {
        ZStack {
            if outlineWidth > 0 {
                // Offset the alpha silhouette so the border follows the artwork.
                // Width is in screen points and stays readable at every map zoom.
                ForEach(Self.outlineDirections.indices, id: \.self) { index in
                    let direction = Self.outlineDirections[index]
                    Image(uiImage: image).renderingMode(.template)
                        .resizable().interpolation(.high).scaledToFit()
                        .foregroundColor(Color(hex: "FFF0CA").opacity(0.94))
                        .offset(x: direction.width * outlineWidth, y: direction.height * outlineWidth)
                }
            }
            Image(uiImage: image).resizable().interpolation(.high).scaledToFit()
        }
        .compositingGroup()
        .shadow(color: .black.opacity(outlineWidth > 0 ? 0.42 : 0.25),
                radius: outlineWidth > 0 ? 3 : 1.5, y: outlineWidth > 0 ? 3 : 2)
    }
}

struct AdventurePainter {
    var context: GraphicsContext

    mutating func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double, _ color: Color) {
        context.fill(Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2)), with: .color(color))
    }
    mutating func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ radius: Double, _ color: Color) {
        context.fill(Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: radius), with: .color(color))
    }
    mutating func polygon(_ points: [(Double, Double)], _ color: Color) {
        var path = Path()
        for (index, point) in points.enumerated() {
            if index == 0 { path.move(to: CGPoint(x: point.0, y: point.1)) }
            else { path.addLine(to: CGPoint(x: point.0, y: point.1)) }
        }
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }
    mutating func tree(at point: CGPoint, scale: Double) {
        var painter = self
        painter.context.translateBy(x: point.x, y: point.y)
        painter.context.scaleBy(x: scale, y: scale)
        painter.ellipse(3, 5, 17, 6, .black.opacity(0.12))
        painter.rect(-3, -13, 6, 18, 2, Color(hex: "7A7551"))
        painter.polygon([(-19, -8), (0, -44), (19, -8)], AdventurePalette.tree)
        painter.polygon([(-16, -21), (0, -53), (16, -21)], AdventurePalette.leaf)
        painter.polygon([(-10, -33), (0, -57), (10, -33)], AdventurePalette.lit)
    }

    mutating func marker(_ kind: AdventureNodeKind, completed: Bool) {
        ellipse(0, 12, 24, 8, .black.opacity(0.13))
        switch kind {
        case .treasure:
            rect(-18, -12, 36, 28, 4, Color(hex: "916137"))
            rect(-19, completed ? -27 : -19, 38, 17, 5, Color(hex: "D7A84F"))
            rect(-19, -5, 38, 5, 1, Color(hex: "F3D280"))
            rect(-12, -17, 5, 29, 1, AdventurePalette.gold)
            rect(7, -17, 5, 29, 1, AdventurePalette.gold)
            rect(-4, -4, 8, 9, 2, Color(hex: "FFE4A0"))
            if completed { rect(-14, -13, 28, 6, 1, Color(hex: "543D2B")) }
        case .monster, .boss:
            let isBoss = kind == .boss
            var body = Path()
            body.move(to: CGPoint(x: -23, y: 8))
            body.addCurve(to: CGPoint(x: 0, y: -28), control1: CGPoint(x: -29, y: -12), control2: CGPoint(x: -14, y: -32))
            body.addCurve(to: CGPoint(x: 23, y: 8), control1: CGPoint(x: 21, y: -30), control2: CGPoint(x: 29, y: -6))
            body.addQuadCurve(to: CGPoint(x: -23, y: 8), control: CGPoint(x: 0, y: 20))
            context.fill(body, with: .color(Color(hex: isBoss ? "546756" : "83A866")))
            ellipse(-8, -13, 8, 6, Color(hex: isBoss ? "718779" : "B5CA83"))
            ellipse(-8, 0, 2.3, 3, Color(hex: "283C2E"))
            ellipse(9, 0, 2.3, 3, Color(hex: "283C2E"))
            ellipse(1, 5, 3, 2, Color(hex: "405537"))
            polygon([(-3, -27), (-9, -43), (4, -34), (14, -45), (11, -25)], Color(hex: isBoss ? "D6B364" : "547543"))
            if isBoss {
                polygon([(-23, -15), (-30, -34), (-15, -26)], Color(hex: "ADA578"))
                polygon([(23, -15), (30, -34), (15, -26)], Color(hex: "ADA578"))
            }
        case .village, .port:
            rect(-19, -13, 38, 30, 3, Color(hex: "EEE0BC"))
            polygon([(-25, -12), (0, -37), (25, -12)], Color(hex: "A97556"))
            polygon([(-25, -12), (0, -37), (0, -12)], Color(hex: "C58C61"))
            rect(-4, 0, 10, 17, 2, Color(hex: "526B56"))
            rect(-14, -5, 6, 7, 1, AdventurePalette.gold)
            rect(10, -5, 6, 7, 1, AdventurePalette.gold)
            if kind == .port {
                rect(26, -33, 2, 45, 1, Color(hex: "7D7355"))
                polygon([(29, -30), (45, -5), (29, -5)], Color(hex: "F1E0B1"))
            }
        case .camp:
            polygon([(-29, 16), (0, -26), (29, 16)], Color(hex: "C2955C"))
            polygon([(-29, 16), (0, -26), (0, 16)], Color(hex: "E0BC79"))
            polygon([(-11, 16), (0, -11), (10, 16)], Color(hex: "695B42"))
        case .shrine:
            rect(-22, 10, 44, 8, 2, AdventurePalette.stone)
            rect(-15, -19, 30, 31, 4, Color(hex: "889684"))
            polygon([(-21, -18), (0, -37), (21, -18)], Color(hex: "A9B296"))
            rect(-5, -10, 10, 18, 3, Color(hex: "D5D5A7"))
            ellipse(0, -3, 3, 5, Color(hex: "F4E7AD"))
        case .bridge:
            for index in -3...3 { rect(-24, Double(index * 7 - 15), 48, 5, 1, Color(hex: "A1845B")) }
            rect(-25, -37, 4, 54, 1, Color(hex: "736D4B"))
            rect(21, -37, 4, 54, 1, Color(hex: "736D4B"))
            if !completed { rect(-8, -8, 16, 16, 3, AdventurePalette.gold) }
        case .road:
            ellipse(0, 1, 11, 7, AdventurePalette.trail)
            ellipse(0, -1, 7, 4, AdventurePalette.grass)
        }
    }

    /// Keeps the map readable by showing immediate options in blue, or one
    /// isolated guide when the selected stop is not reachable yet.
    mutating func storybookPaths(clearedNodeIDs: Set<Int>, activeRoutes: [[Int]]) {
        var exploredRoutes = Path()
        var selectedRoutes = Path()
        for (a, b) in AdventureWorld.edges {
            guard let start = AdventureWorld.node(a), let end = AdventureWorld.node(b) else { continue }
            var road = Path()
            road.move(to: CGPoint(x: start.x, y: start.y))
            road.addLine(to: CGPoint(x: end.x, y: end.y))
            let isOnActiveRoute = activeRoutes.contains { route in
                zip(route, route.dropFirst()).contains { from, to in
                    (from == a && to == b) || (from == b && to == a)
                }
            }
            if isOnActiveRoute {
                selectedRoutes.addPath(road)
            } else if clearedNodeIDs.contains(a) && clearedNodeIDs.contains(b) {
                exploredRoutes.addPath(road)
            }
        }

        // Explored paths provide just enough context without competing with
        // the routes the player can take next.
        context.stroke(exploredRoutes, with: .color(Color.white.opacity(0.36)),
                       style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [0.1, 30]))

        // Blur only the shown routes' halo; the blue dots and white centers
        // remain crisp. Tighter spacing makes each sequence read as one trail.
        let dots: [CGFloat] = [0.1, 28]
        context.drawLayer { glow in
            glow.addFilter(.blur(radius: 3))
            glow.stroke(selectedRoutes, with: .color(Color(hex: "009DFF").opacity(0.5)),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round, dash: dots))
        }
        context.stroke(selectedRoutes, with: .color(Color(hex: "072D65").opacity(0.8)),
                       style: StrokeStyle(lineWidth: 15, lineCap: .round, dash: dots))
        context.stroke(selectedRoutes, with: .color(Color(hex: "28B7FF")),
                       style: StrokeStyle(lineWidth: 12, lineCap: .round, dash: dots))
        context.stroke(selectedRoutes, with: .color(Color(hex: "EFFBFF")),
                       style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: dots))
    }

    mutating func terrain(hasLight: Bool) {
        rect(-1000, -1000, 3000, 3500, 0, AdventurePalette.ground)
        ellipse(145, 790, 195, 230, AdventurePalette.patch)
        ellipse(465, 590, 205, 220, AdventurePalette.grass)
        ellipse(360, 285, 280, 160, AdventurePalette.patch)
        ellipse(230, 920, 85, 70, AdventurePalette.grass)
        var river = Path()
        river.move(to: CGPoint(x: -120, y: 310))
        river.addCurve(to: CGPoint(x: 230, y: 320), control1: CGPoint(x: 40, y: 370), control2: CGPoint(x: 110, y: 285))
        river.addCurve(to: CGPoint(x: 560, y: 280), control1: CGPoint(x: 370, y: 365), control2: CGPoint(x: 400, y: 300))
        river.addCurve(to: CGPoint(x: 820, y: 80), control1: CGPoint(x: 680, y: 250), control2: CGPoint(x: 630, y: 60))
        context.stroke(river, with: .color(AdventurePalette.water), style: StrokeStyle(lineWidth: 43, lineCap: .round))
        context.stroke(river, with: .color(AdventurePalette.wave.opacity(0.7)), style: StrokeStyle(lineWidth: 2))
        ellipse(35, 1045, 125, 94, AdventurePalette.water)
        ellipse(5, 1045, 100, 66, AdventurePalette.wave)
        for index in 0...2 {
            let j = Double(index)
            polygon([(25 + j * 51, 204 - j * 30), (80 + j * 50, 76 - j * 14), (135 + j * 51, 204 - j * 30)], AdventurePalette.stone)
            polygon([(80 + j * 50, 76 - j * 14), (135 + j * 51, 204 - j * 30), (82 + j * 50, 176 - j * 20)], AdventurePalette.tree)
        }
        for (a, b) in AdventureWorld.edges {
            guard let start = AdventureWorld.node(a), let end = AdventureWorld.node(b) else { continue }
            var road = Path()
            road.move(to: CGPoint(x: start.x, y: start.y))
            road.addLine(to: CGPoint(x: end.x, y: end.y))
            context.stroke(road, with: .color(AdventurePalette.edge), style: StrokeStyle(lineWidth: 20, lineCap: .round))
            context.stroke(road, with: .color(AdventurePalette.trail), style: StrokeStyle(lineWidth: 15, lineCap: .round))
            context.stroke(road, with: .color(AdventurePalette.edge.opacity(0.45)), style: StrokeStyle(lineWidth: 2, dash: [1, 17]))
        }
        for tree in AdventureForestDecoration.trees { self.tree(at: tree.point, scale: tree.scale) }
        context.draw(Text("ささやきの森").font(.system(size: 14, design: .serif)).foregroundColor(AdventurePalette.tree.opacity(0.6)), at: CGPoint(x: 85, y: 605))
        context.draw(Text("木漏れ日の街道").font(.system(size: 14, design: .serif)).foregroundColor(AdventurePalette.tree.opacity(0.6)), at: CGPoint(x: 440, y: 922))
        if !hasLight {
            for index in 0..<7 { ellipse(Double(70 + index * 90), Double(85 + (index % 2) * 45), 100, 54, AdventurePalette.mist.opacity(0.52)) }
        }
    }
}

private enum AdventureForestDecoration {
    struct Tree { let point: CGPoint; let scale: Double }
    static let trees: [Tree] = {
        var seed: Int64 = 741
        func random() -> Double { seed = seed * 16807 % 2147483647; return Double(seed - 1) / 2147483646 }
        var result: [Tree] = []
        for _ in 0..<235 {
            let x = random() * 760, y = random() * 1140, scale = 0.75 + random() * 0.65
            let clearOfRoads = AdventureWorld.edges.allSatisfy { a, b in
                guard let start = AdventureWorld.node(a), let end = AdventureWorld.node(b) else { return true }
                let dx = end.x - start.x, dy = end.y - start.y
                let t = max(0, min(1, ((x - start.x) * dx + (y - start.y) * dy) / (dx * dx + dy * dy)))
                return hypot(x - start.x - t * dx, y - start.y - t * dy) > 48
            }
            if clearOfRoads && !(x < 135 && y > 945) { result.append(Tree(point: CGPoint(x: x, y: y), scale: scale)) }
        }
        return result.sorted { $0.point.y < $1.point.y }
    }()
}
