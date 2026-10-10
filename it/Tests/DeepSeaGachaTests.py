"""Verify the production gacha catalog, every weighted roll, and bundled character art."""
from pathlib import Path
import hashlib
import json
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def declaration(source, marker):
    start = source.index(marker)
    opening = source.index('{', start)
    end, depth = opening + 1, 1
    while depth:
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return source[start:end]


source = (ROOT / 'Gacha/GachaView.swift').read_text()
support = '''
import Foundation
struct Color {
    init(hex: String) {}
    init(red: Double, green: Double, blue: Double) {}
    static let gray = Color(hex: ""), blue = gray, cyan = gray, purple = gray, pink = gray, white = gray
    static let orange = gray, yellow = gray, red = gray
    func opacity(_ value: Double) -> Self { self }
}
var testRoll = 0
func nextTestRoll(in range: Range<Int>) -> Int {
    precondition(range.contains(testRoll))
    return testRoll
}
'''
support += declaration(source, 'enum GachaRarity:') + '\n'
support += declaration(source, 'enum GachaMode {') + '\n'
manager = declaration(source, 'class GachaManager {')
# Substitute only the entropy source so every legal roll exercises the real selector.
random_call = 'Int.random(in: 0..<totalProbability)'
assert manager.count(random_call) == 1
support += manager.replace(random_call, 'nextTestRoll(in: 0..<totalProbability)') + '\n'
support += '''
enum GachaCatalogTier: Int { case normal, rare, superRare, ultraRare, legendRare, mythicRare, ultimateRare }
'''
support += declaration(source, 'extension GachaRarity {') + '\n'
theme = (ROOT / 'Gacha/GachaTheme.swift').read_text()
support += declaration(theme, 'enum GachaSummonHint:') + '\n'
support += declaration(theme, 'extension GachaRarity {') + '\n'
illustrated = (ROOT / 'App/IllustratedView.swift').read_text()
support += '''
enum UnitPoint { case topLeading, bottomTrailing }
struct LinearGradient {
    init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {}
}
'''
support += 'struct IllustratedView {\n' + declaration(illustrated, 'enum Rarity:') + '\n}\n'
support += declaration(illustrated, 'private extension IllustratedView.Rarity {') + '\n'

expected = [
    ('灯クラゲ ルミ', 35, 340, 2000, 'deepSeaRare'),
    ('メンダコ メロ', 40, 350, 2000, 'deepSeaRare'),
    ('チョウチン魚 ピカリ', 55, 300, 2000, 'deepSeaRare'),
    ('ヨロイエビ ガンゾ', 45, 380, 1500, 'deepSeaRare'),
    ('宝石ガニ クリスタ', 70, 480, 800, 'deepSeaSuperRare'),
    ('影鮫 シャドウ', 105, 330, 600, 'deepSeaSuperRare'),
    ('古代海亀 グランシェル', 65, 600, 600, 'deepSeaSuperRare'),
    ('幽灯鯨 ファントム', 120, 600, 220, 'deepSeaUltraRare'),
    ('大王烏賊 クラーケン', 170, 420, 180, 'deepSeaUltraRare'),
    ('深淵海蛇 アビス', 480, 500, 50, 'deepSeaLegendRare'),
    ('海皇鎧魚 ダンクル', 350, 800, 30, 'deepSeaLegendRare'),
    ('深海王 リヴァイアス', 550, 1000, 20, 'deepSeaUltimateRare'),
]
support += '''
var checks = 0
func check(_ value: @autoclosure () -> Bool, _ message: String) {
    checks += 1
    if !value() { fatalError(message) }
}
let manager = GachaManager(mode: .deepSea)
let items = manager.catalogItems
check(manager.gachaCost == 1500, "Deep-sea draw must cost 1,500 coins")
check(items.count == 12, "Deep-sea catalog must have 12 characters")
check(Set(items.map(\\.name)).count == 12, "Character names must be unique")
check(items.reduce(0) { $0 + $1.probability } == 10000, "Weights must total 10000")
'''
for index, (name, attack, hp, weight, rarity) in enumerate(expected):
    support += f'''check(items[{index}].name == "{name}" && items[{index}].attack == {attack} && items[{index}].health == {hp} && items[{index}].probability == {weight} && items[{index}].rarity == .{rarity}, "Approved stats or rate changed for {name}")\n'''
support += '''
let expectedTiers: [GachaCatalogTier] = [.rare, .superRare, .ultraRare, .legendRare, .ultimateRare]
let rarities: [GachaRarity] = [.deepSeaRare, .deepSeaSuperRare, .deepSeaUltraRare, .deepSeaLegendRare, .deepSeaUltimateRare]
let expectedHints: [GachaSummonHint] = [.blue, .purple, .gold, .gold, .rainbow]
let titles = ["レア", "スーパーレア", "ウルトラレア", "レジェンドレア", "アルティメットレア"]
let illustratedTiers: [IllustratedView.Rarity] = [.rare, .superRare, .ultraRare, .legendRare, .ultimateRare]
for index in rarities.indices {
    let rarity = rarities[index]
    check(rarity.catalogTier == expectedTiers[index], "Incorrect catalog tier")
    check(rarity.summonHint == expectedHints[index], "Incorrect summon effect")
    check(rarity.displayString == titles[index], "Incorrect rarity label")
    check(IllustratedView.Rarity(gachaRarity: rarity) == illustratedTiers[index], "Incorrect main companion catalog tier")
    let data = try JSONEncoder().encode(rarity)
    check(try JSONDecoder().decode(GachaRarity.self, from: data) == rarity, "Rarity must round-trip")
}
check(IllustratedView.Rarity.ultimateRare.displayString == "アルティメットレア", "Main catalog must label the ultimate tier correctly")
for pass in 0..<2 {
    if pass == 1 { manager.shuffleItems() }
    var counts: [String: Int] = [:]
    for roll in 0..<10000 {
        testRoll = roll
        guard let item = manager.drawGacha() else { fatalError("No result for legal roll") }
        check(items.contains { $0.name == item.name }, "Draw returned a foreign character")
        counts[item.name, default: 0] += 1
    }
    for item in items { check(counts[item.name] == item.probability, "Wrong probability for \\(item.name) after shuffle=\\(pass)") }
}
let guardian = GachaManager(mode: .guardian).catalogItems
let deepLegend = items.filter { $0.rarity.catalogTier.rawValue >= GachaCatalogTier.legendRare.rawValue }.reduce(0) { $0 + $1.probability }
let guardianLegend = guardian.filter { $0.rarity.catalogTier.rawValue >= GachaCatalogTier.legendRare.rawValue }.reduce(0) { $0 + $1.probability }
check(deepLegend == 100 && deepLegend < guardianLegend, "Deep-sea top tiers must be harder to get")
check(items.last!.attack > guardian.last!.attack && items.last!.health > guardian.last!.health, "Livaias must exceed Huanglong's base stats")
for mode in [GachaMode.normal, .rare, .meka, .god, .guardian] {
    let oldManager = GachaManager(mode: mode)
    check(oldManager.catalogItems.count == 12, "Existing catalog changed")
}
print("DeepSeaGacha: \\(checks) production catalog/draw checks passed")
'''
# Throwing decoder calls cannot be nested inside a nonthrowing autoclosure.
support = support.replace('check(try JSONDecoder().decode(GachaRarity.self, from: data) == rarity,', 'let decoded = try JSONDecoder().decode(GachaRarity.self, from: data)\n    check(decoded == rarity,')
with tempfile.TemporaryDirectory(prefix='deep-sea-gacha-tests-') as directory:
    swift = Path(directory) / 'main.swift'
    swift.write_text(support)
    binary = Path(directory) / 'tests'
    subprocess.run(['xcrun', 'swiftc', str(swift), '-o', str(binary)], check=True)
    subprocess.run([str(binary)], check=True)

record = {r['name']: r for r in json.loads((ROOT / 'output/imagegen/deep-sea-gacha-2026-10-06/generation-record.json').read_text())}
for name, *_ in expected:
    imageset = ROOT / 'Assets.xcassets/アバター' / f'{name}.imageset'
    contents = json.loads((imageset / 'Contents.json').read_text())
    png = imageset / contents['images'][0]['filename']
    data = png.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', name
    width, height, depth, color = struct.unpack('>IIBB', data[16:26])
    assert width == height == 1254 and color == 6, name
    assert hashlib.sha256(data).hexdigest() == record[name]['sha256'], name
print('DeepSeaGacha: all 12 bundled PNGs match approved transparent originals')
