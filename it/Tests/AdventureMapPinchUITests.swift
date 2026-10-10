import XCTest

final class AdventureMapPinchUITests: XCTestCase {
    func testPinchZoomAndNodeSelection() throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "Swift-Beginners-app.it")
        app.launchArguments = ["-StoryImageAdventurePreview"]
        app.launch()
        let close = app.buttons["adventure.event.close"]
        if close.waitForExistence(timeout: 2) { close.tap() }

        let map = app.otherElements["adventure.map"].firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 10))
        func zoom() throws -> Int {
            let value = try XCTUnwrap(map.value as? String)
            return try XCTUnwrap(Int(value.filter(\.isNumber)))
        }

        let initial = try zoom()
        map.pinch(withScale: 1.25, velocity: 1)
        let enlarged = try zoom()
        XCTAssertGreaterThan(enlarged, initial, "Two fingers spreading apart must enlarge the map")

        map.pinch(withScale: 0.72, velocity: -1)
        let reduced = try zoom()
        XCTAssertLessThan(reduced, enlarged, "Two fingers moving together must reduce the map")
        XCTAssertEqual(Double(reduced), Double(enlarged) * 0.72, accuracy: 2,
                       "Ending a pinch must commit its scale once")

        map.pinch(withScale: 1.2, velocity: 1)
        XCTAssertGreaterThan(try zoom(), reduced, "A second pinch must start from the committed zoom")
        print("Verified pinch zoom: \(initial)% -> \(enlarged)% -> \(reduced)% -> \(try zoom())%")

        let nodes = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'adventure.node.'"))
        let node = try XCTUnwrap(nodes.allElementsBoundByIndex.first(where: { $0.isHittable }))
        let name = try XCTUnwrap(node.label.split(separator: "、").first.map(String.init))
        node.tap()
        XCTAssertTrue(app.buttons["adventure.move"].label.contains(name), "Node taps must still work after pinching")

        let proof = XCTAttachment(screenshot: app.screenshot())
        proof.name = "Map after real pinch gestures"
        proof.lifetime = .keepAlways
        add(proof)
    }
}
