"""Compile the production catalog and real question banks without Firebase or SwiftUI."""
from pathlib import Path
import re
import subprocess
import tempfile
import unicodedata

ROOT = Path(__file__).resolve().parents[1]


def declaration(source, marker):
    start = source.index(marker)
    opening = source.index("{", start)
    end, depth = opening + 1, 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start:end]


story = (ROOT / "Story/StoryView.swift").read_text()
catalog = (ROOT / "Quiz/DungeonExpansion.swift").read_text()
support = r'''
import Foundation
struct Color: Equatable { init(hex: String) {} }
struct EdgeInsets {
    let top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat
}
enum QuizLevel: String, CaseIterable {
    case netwarkTusin, ESsecurity, computerSystem, sekkei, kaihatu, unyouhoshu, kikaku
    case appliedTechnology, appliedManagement, appliedStrategy
    var description: String { rawValue }
}
struct InventoryReward {
    enum Item { case rareGachaTicket, mekaGachaTicket, godGachaTicket, boostTicket, staminaPotion }
    let type: Item
    let amount: Int
}
struct DungeonBoost {
    enum Kind { case attackSurge }
    let type: Kind
    let charges: Int
}
struct Binding<T> { static func constant(_ value: T) -> Self { Self() } }
'''
for file, marker in [
    ("Quiz/StoryQuizView.swift", "struct Monster:"),
    ("Modal/StoryCoinModalView.swift", "struct Treasure:"),
    ("Quiz/QuizQuestion.swift", "struct QuizQuestion:"),
]:
    support += declaration((ROOT / file).read_text(), marker) + "\n"
support += declaration(story, "struct PlatformData:") + "\n"
support += declaration(story, "struct DungeonChapterInfo:") + "\n"
support += declaration(catalog, "enum DungeonExpansion {") + "\n"

# Extract actual array literals, excluding commented-out legacy examples.
for name in re.findall(r"private static let \w+ = (\w+)\(isPresenting:", catalog):
    bank = (ROOT / "Quiz/QuizList" / f"{name}.swift").read_text()
    match = re.search(r"^    let quizBeginnerList: \[QuizQuestion\] = \[", bank, re.M)
    assert match, name
    end = re.search(r"^    \]", bank[match.end():], re.M)
    assert end, name
    array = bank[match.start():match.end() + end.end()]
    support += f"struct {name} {{ init(isPresenting: Binding<Bool>) {{}}\n{array}\n}}\n"
support += declaration(catalog, "enum DungeonExpansionQuestions {") + "\n"

support += r'''
final class TileModel {
    var canEnterDungeon = true
    var coin = 0
    var monster = 0
    var monsterName = ""
    var showCoinAlert = false
    var showMonsterAlert = false
    var showUserStoryAlert = false
    var showStaminaAlert = false
    var selectedUser: String?
}
struct Rival { let user = "rival" }
struct Audio { func playTittleSound() {}; func playSound() {} }
final class TileProbe {
    let viewModel = TileModel()
    let audioManager = Audio()
    var treasure: Int? = 0
    var monster: Int? = 0
    var boss: Int? = 0
    var otherUser: Rival?
    var onArrowTap: (() -> Void)?
    func triggerHaptic() {}
'''
support += declaration(story, "func handleDownArrowTap()") + "\n}\n"

# Compile every original floor as well as the new rows, checking the real map connection.
container = story[story.index("struct PlatformsContainer:"):]
legacy = container.split("self.platformDatas = DungeonExpansion.platformRows + [", 1)[1].split("\n        ]\n    }", 1)[0]
support += 'let legacy: [[PlatformData]] = [' + legacy.replace('self.platformImageName', '"DungeonStorybookMossPlatform"') + '\n]\n'

checks = r'''
var checks = 0
func check(_ valid: @autoclosure () -> Bool, _ message: String) {
    precondition(valid(), message)
    checks += 1
}
let rows = DungeonExpansion.platformRows
let floors = rows.flatMap { $0 }
let allFloors = (rows + legacy).flatMap { $0 }
check(allFloors.count == 300, "Exactly 300 map tiles")
check(Set(allFloors.map(\.position)) == Set(1...300), "No missing or duplicate floors")
check(floors.count == 150 && rows.count == 54, "150 expansion floors in 54 rows")
check(Set(floors.filter { ($0.boss ?? 0) > 0 }.map(\.position)) == Set([200, 250, 300]), "Only chapter finales have bosses")
check(Set((151...300).filter(DungeonExpansion.isBossFloor)) == Set([200, 250, 300]), "Only chapter finales use wide boss platforms")
check(floors.filter { ($0.monster ?? 0) > 0 }.count == 75, "75 regular battles")
check(floors.filter { ($0.treasure ?? 0) > 0 }.count == 30, "30 treasures")
check(Set(rows.filter { $0.count == 1 }.flatMap { $0.map(\.position) }) == Set([200, 250, 300]), "Only boss floors stand alone")
for (rowIndex, row) in rows.enumerated() {
    check((1...3).contains(row.count), "Rows fit at most three platforms")
    check(row.filter { ($0.boss ?? 0) > 0 }.isEmpty || row.count == 1, "Boss platform cannot overlap another tile")
    if row.count > 1 {
        let elevations = row.map { $0.padding!.bottom }
        let direction: CGFloat = (rowIndex % 18 - 1).isMultiple(of: 2) ? 1 : -1
        check(zip(elevations, elevations.dropFirst()).allSatisfy { $0.1 - $0.0 == direction * 60 },
              "Expansion rows alternate rising and falling staircases")
    }
    check(row.allSatisfy { $0.paddingTreasure == nil }, "Expansion treasures use the platform surface")
}
for floor in allFloors {
    check([floor.boss, floor.monster, floor.treasure].compactMap { $0 }.filter { $0 > 0 }.count <= 1, "At most one encounter per floor")
    check(DungeonChapterInfo.chapters.filter { $0.range.contains(floor.position) }.count == 1, "Each floor has exactly one chapter")
}
for area in DungeonExpansion.areas {
    for floor in area.range { check(DungeonExpansion.area(at: floor)?.id == area.id, "Area lookup") }
    let regular = DungeonExpansion.monster(for: area.monsterID)!
    let boss = DungeonExpansion.monster(for: area.bossID)
    if area.isChapterFinale {
        check(boss != nil, "Chapter finale has a boss")
        check(boss!.monsterHP > regular.monsterHP && boss!.monsterAttack > regular.monsterAttack, "Boss is stronger than regular enemies")
        check(!DungeonExpansion.battleRewards(for: boss!.name).isEmpty, "Chapter boss grants a reward")
    } else {
        check(boss == nil, "Intermediate area has no boss")
        check(DungeonExpansion.encounterID(at: area.range.upperBound) == nil, "Intermediate tenth floor is an ordinary tile")
        check(DungeonExpansion.battleRewards(for: DungeonExpansion.encounterName(for: area.bossID)).isEmpty, "Intermediate areas have no boss reward")
    }
    let questions = DungeonExpansionQuestions.questions(for: area)
    check(questions.count >= 30, "Each area needs at least 30 usable questions")
    check(Set(questions.map(\.question)).count == questions.count, "No repeated prompts in a battle pool")
    for question in questions {
        check(question.isFourChoices && question.choices.indices.contains(question.correctAnswerIndex), "Valid answer choices")
        check(!question.explanation.isEmpty, "Every question has an explanation")
        check(area.subjects.map { $0.quizLevel.description }.contains(question.sourceQuizLevel ?? ""), "Question provenance stays within the area")
    }
    if area.subjects.count > 1 {
        check(Set(questions.prefix(12).compactMap(\.sourceQuizLevel)).count == area.subjects.count, "Mixed trials start with all subjects represented")
    }
    print("\(area.range): \(area.title), \(questions.count) questions")
}
for id in 31...60 {
    let treasure = DungeonExpansion.treasure(for: id)!
    check(treasure.reward > 0, "Treasures have a valid coin fallback")
    if id.isMultiple(of: 2) {
        check(!DungeonExpansion.treasureRewards(for: id).isEmpty, "Supply chest contains items")
        check(DungeonExpansion.treasureBoosts(for: id).first?.charges == 3, "Supply chest prepares upcoming battles")
    } else {
        check(DungeonExpansion.treasureRewards(for: id).isEmpty, "Coin chest is not replaced by items")
    }
}
for floor in [0, 150, 301] {
    check(DungeonExpansion.area(at: floor) == nil, "Legacy and invalid floors are excluded")
    check(DungeonExpansion.encounterID(at: floor) == nil, "No out-of-range encounters")
}
check(DungeonExpansion.monster(for: 52) == nil && DungeonExpansion.monster(for: 116) == nil, "Unknown monsters are excluded")
check(DungeonExpansion.monstersByName.count == 78, "Regular enemies and three bosses resolve to battle stats")
let regularTiles = allFloors.filter { $0.position >= 151 && ($0.monster ?? 0) > 0 }
check(regularTiles.count == 75, "Every regular battle has a monster")
check(Set(regularTiles.compactMap(\.monster)).count == 75, "No repeated regular encounter IDs")
let regularNames = regularTiles.map { DungeonExpansion.encounterName(for: $0.monster!) }
check(Set(regularNames.map { DungeonExpansion.artworkName(for: $0) }).count == 75, "All 75 battles use different artwork")
check(Set(regularNames.map { DungeonExpansion.displayName(for: $0) }).count == 75, "All 75 monster species have different names")
for tile in regularTiles {
    let id = tile.monster!
    let area = DungeonExpansion.area(at: tile.position)!
    let monster = DungeonExpansion.monster(for: id)!
    check(id == 1_000 + tile.position && DungeonExpansion.encounterID(at: tile.position) == id, "Floor-specific monster reaches its tile")
    check(monster.monsterHP == 1_000 + area.id * 100 && monster.monsterAttack == 360 + area.id * 15, "Distinct species preserve area difficulty")
    check(DungeonExpansion.monstersByName[monster.name] != nil, "Every unique monster resolves in battle")
}
for floor in [151, 154, 200, 250, 300, 301] {
    check(DungeonExpansion.monster(for: 1_000 + floor) == nil, "Non-battle floors cannot resolve as regular monsters")
}
check(DungeonExpansionQuestions.level(for: "ESsecurity", fallback: .appliedTechnology) == .ESsecurity, "Mixed trials preserve the mistake's original subject")
check(DungeonExpansionQuestions.level(for: nil, fallback: .appliedTechnology) == .appliedTechnology, "Legacy questions keep their original routing")
for id in [1, 30, 31, 60] {
    let tile = TileProbe()
    tile.treasure = id
    var moves = 0
    tile.onArrowTap = { moves += 1 }
    tile.handleDownArrowTap()
    check(moves == 1 && tile.viewModel.coin == id && tile.viewModel.showCoinAlert, "Chest arrows advance exactly once")
}
for id in [1152, 1299, 105, 115] {
    let tile = TileProbe()
    if (101...115).contains(id) { tile.boss = id } else { tile.monster = id }
    var moves = 0
    tile.onArrowTap = { moves += 1 }
    tile.handleDownArrowTap()
    check(moves == 0 && tile.viewModel.showMonsterAlert, "Battle tiles wait for victory before moving")
    check(tile.viewModel.monsterName == DungeonExpansion.encounterName(for: id), "Encounter IDs reach the battle")
}
let blockedTile = TileProbe()
blockedTile.viewModel.canEnterDungeon = false
blockedTile.treasure = 60
blockedTile.handleDownArrowTap()
check(blockedTile.viewModel.showStaminaAlert && !blockedTile.viewModel.showCoinAlert, "Insufficient stamina cannot open a chest")
for monster in DungeonExpansion.monstersByName.values {
    print("ASSET:\(DungeonExpansion.artworkName(for: monster.name))")
}
for id in 31...60 { print("ASSET:\(DungeonExpansion.treasureArtwork(for: id))") }
for floor in [151, 200, 201, 250, 251, 300] {
    print("ASSET:\(DungeonExpansion.background(at: floor))")
    print("ASSET:\(DungeonExpansion.platformArtwork(at: floor))")
}
print("Dungeon expansion: \(checks) checks passed")
'''

with tempfile.TemporaryDirectory(prefix="dungeon-expansion-tests-") as directory:
    path = Path(directory)
    swift = path / "main.swift"
    swift.write_text(support + checks)
    binary = path / "checks"
    subprocess.run(["xcrun", "swiftc", "-swift-version", "5", str(swift), "-o", str(binary)], check=True)
    output = subprocess.check_output([str(binary)], text=True)
    assets = {unicodedata.normalize("NFC", p.stem) for p in (ROOT / "Assets.xcassets").rglob("*.imageset")}
    for line in output.splitlines():
        if line.startswith("ASSET:"):
            assert line[6:] in assets, f"Missing artwork: {line[6:]}"
        else:
            print(line)
    print("All expansion artwork references exist")
