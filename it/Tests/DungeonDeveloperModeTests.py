"""Exercise production dungeon movement in Debug and Release with a local database."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / "Story/StoryView.swift").read_text()


def declaration(marker):
    start = source.index(marker)
    opening = source.index("{", start)
    end, depth = opening + 1, 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start:end]


support = r'''
import Foundation
struct DispatchQueue {
    static let main = DispatchQueue()
    func async(execute: () -> Void) { execute() }
}
struct Animation { static func easeInOut(duration: Double) -> Animation { Animation() } }
func withAnimation(_ animation: Animation? = nil, _ body: () -> Void) { body() }
final class AuthManager {
    static let shared = AuthManager()
    var currentUserId: String? = "player"
    var steps = 0
    func recordDungeonStep(position: Int) { steps += 1 }
}
final class GuildManager {
    static let shared = GuildManager()
    func recordDungeonStep() {}
}
final class DatabaseReference {
    var writes = 0
    var lastUpdate: [String: Any] = [:]
    var fails = false
    func child(_ key: String) -> DatabaseReference { self }
    func updateChildValues(_ values: [String: Any], completion: (Error?, DatabaseReference) -> Void) {
        writes += 1; lastUpdate = values
        completion(fails ? NSError(domain: "test", code: 1) : nil, self)
    }
    func setValue(_ value: Int, completion: (Error?, DatabaseReference) -> Void) {
        writes += 1
        completion(fails ? NSError(domain: "test", code: 1) : nil, self)
    }
}
final class PositionViewModel {
    struct Constants { static let finalFloor = __FINAL_FLOOR__ }
    let authManager = AuthManager.shared
    let dbRef = DatabaseReference()
    var userPosition = 1
    var stamina = 100
    var showStaminaAlert = false
    var isPositionFetched = false
    func refreshRecoveryCountdown() {}
'''

expansion = (ROOT / "Quiz/DungeonExpansion.swift").read_text()
import re
final_floor = int(re.search(r"static let finalFloor = (\d+)", expansion)[1])
support = support.replace("__FINAL_FLOOR__", str(final_floor))

methods = "\n".join(declaration(marker) for marker in [
    "var dungeonStaminaCost:", "var canEnterDungeon:",
    "func incrementPosition()", "func incrementUserPosition()", "func decreaseStamina(",
])
debug_method = declaration("func setPositionForDebug(")
checks = r'''
}
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    precondition(condition(), message)
}
#if DEBUG
let expectedCost = 0
#else
let expectedCost = 10
#endif
for startingStamina in [0, 9, 10, 100] {
    let model = PositionViewModel()
    model.stamina = startingStamina
    check(model.dungeonStaminaCost == expectedCost, "Build configuration must control stamina cost")
    model.incrementPosition()
    let canEnter = startingStamina >= expectedCost
    check(model.userPosition == (canEnter ? 2 : 1), "Movement eligibility")
    check(model.stamina == (canEnter ? startingStamina - expectedCost : startingStamina), "Movement cost")
    check(model.showStaminaAlert == !canEnter, "Insufficient stamina alert")
    check(model.dbRef.writes == (canEnter ? 1 : 0), "Blocked movement must not persist")
    if canEnter {
        check(model.dbRef.lastUpdate["stamina"] as? Int == model.stamina, "Persisted stamina matches local state")
    }

    let rival = PositionViewModel()
    rival.stamina = startingStamina
    rival.incrementUserPosition()
    check(rival.userPosition == (canEnter ? 2 : 1), "Rival victory eligibility")
    check(rival.stamina == startingStamina, "Rival victory remains free")

    let defeat = PositionViewModel()
    defeat.stamina = startingStamina
    defeat.decreaseStamina(by: 10)
    let charged = expectedCost > 0 && startingStamina >= 10
    check(defeat.stamina == startingStamina - (charged ? 10 : 0), "Defeat cost")
    check(defeat.dbRef.writes == (charged ? 1 : 0), "Developer defeat must not persist a stamina deduction")
}
for position in [1, 150, 200, 250, 299, 300] {
    let model = PositionViewModel()
    model.userPosition = position
    model.stamina = 47
    model.dbRef.fails = true
    model.incrementPosition()
    check(model.userPosition == position && model.stamina == 47, "Failed movement restores the actual previous state")
}
for position in [149, 150, 199, 200, 249, 250, 299] {
    let model = PositionViewModel()
    model.userPosition = position
    model.incrementPosition()
    check(model.userPosition == position + 1, "Chapter boundaries remain traversable")
}
for rival in [false, true] {
    let model = PositionViewModel()
    model.userPosition = 300
    model.stamina = 100
    let steps = AuthManager.shared.steps
    if rival { model.incrementUserPosition() } else { model.incrementPosition() }
    check(model.userPosition == 300 && model.stamina == 100, "Final floor never charges stamina")
    check(model.dbRef.writes == 0 && AuthManager.shared.steps == steps, "Final floor cannot grant repeat progress")
}
#if DEBUG
let model = PositionViewModel()
model.stamina = 0
let startingSteps = AuthManager.shared.steps
for position in [300, 299, 251, 250, 201, 200, 151, 150, 52, 101, 1] {
    var success = false
    model.setPositionForDebug(position) { if case .success = $0 { success = true } }
    check(success && model.userPosition == position, "Developer travel can jump forward and backward")
    check(model.stamina == 0, "Developer travel must preserve stamina")
}
check(AuthManager.shared.steps == startingSteps, "Teleporting must not grant dungeon step credit")
for invalidPosition in [0, 301] {
    let writes = model.dbRef.writes
    var failed = false
    model.setPositionForDebug(invalidPosition) { if case .failure = $0 { failed = true } }
    check(failed && model.userPosition == 1 && model.dbRef.writes == writes, "Invalid destinations cannot be saved")
}
model.dbRef.fails = true
model.setPositionForDebug(150) { _ in }
check(model.userPosition == 1, "Failed teleport must preserve the current position")
AuthManager.shared.currentUserId = nil
let writes = model.dbRef.writes
model.setPositionForDebug(52) { _ in }
check(model.dbRef.writes == writes, "Teleport requires a signed-in user")
#endif
print("Dungeon developer mode checks passed")
'''

with tempfile.TemporaryDirectory() as directory:
    path = Path(directory)
    swift = path / "Tests.swift"
    swift.write_text(support + methods + "\n#if DEBUG\n" + debug_method + "\n#endif\n" + checks)
    for configuration in ["Debug", "Release"]:
        binary = path / configuration
        flags = ["-D", "DEBUG"] if configuration == "Debug" else []
        subprocess.run(["xcrun", "swiftc", "-swift-version", "5", *flags, str(swift), "-o", str(binary)], check=True)
        subprocess.run([str(binary)], check=True)
        print(f"{configuration}: passed")
