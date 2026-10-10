import XCTest

/// Run in a UI-test target against the installed Debug app. All resets and
/// rewards use the isolated story-adventure-debug preview save.
final class AdventureEventTransitionUITests: XCTestCase {
    func testTreasureMenuAndBattleTransitions() throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "Swift-Beginners-app.it")
        app.launchArguments = ["-StoryImageAdventurePreview"]
        app.launch()

        let skip = app.buttons["adventure.story.skip"]
        if skip.waitForExistence(timeout: 3) { skip.tap() }
        let suspend = app.buttons["adventure.battle.suspend"]
        if suspend.exists { suspend.tap() }
        let close = app.buttons["adventure.event.close"]
        if close.exists { close.tap() }

        app.buttons["adventure.menu"].tap()
        app.buttons["adventure.debug.restartStory"].tap()
        app.buttons["最初から開始"].tap()
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        skip.tap()

        func move(to id: Int) {
            let node = app.buttons["adventure.node.\(id)"]
            XCTAssertTrue(node.waitForExistence(timeout: 5))
            node.tap()
            app.buttons["adventure.move"].tap()
        }

        move(to: 1)
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        skip.tap()
        move(to: 2)
        let open = app.buttons["adventure.treasure.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        XCTAssertTrue(app.staticTexts["お宝を手に入れた！"].waitForExistence(timeout: 5))
        XCTAssertFalse(open.exists, "The treasure sheet must update to its reward content")
        XCTAssertTrue(close.isHittable)
        app.buttons["冒険をつづける"].tap()

        app.buttons["adventure.menu"].tap()
        app.buttons["adventure.inventory"].tap()
        XCTAssertTrue(app.staticTexts["旅のもちもの"].waitForExistence(timeout: 5))
        XCTAssertTrue(close.isHittable, "Menu navigation must retain a usable event sheet")
        close.tap()
        app.buttons["adventure.menu"].tap()
        app.buttons["adventure.world"].tap()
        XCTAssertTrue(app.staticTexts["忘却の大陸"].waitForExistence(timeout: 5))
        close.tap()

        move(to: 21)
        XCTAssertTrue(app.buttons["adventure.move"].waitForExistence(timeout: 5))
        move(to: 22)
        let start = app.buttons["adventure.battle.start"]
        XCTAssertTrue(start.waitForExistence(timeout: 8))
        start.tap()
        XCTAssertTrue(suspend.waitForExistence(timeout: 5))
        XCTAssertFalse(start.exists)
        XCTAssertFalse(close.exists, "Battle must only appear in the full-screen cover")
        XCTAssertTrue(app.descendants(matching: .any)["adventure.battle.answers"].firstMatch.exists)

        let proof = XCTAttachment(screenshot: app.screenshot())
        proof.name = "Battle after one encounter transition"
        proof.lifetime = .keepAlways
        add(proof)

        suspend.tap()
        let resume = app.buttons["adventure.move"]
        XCTAssertTrue(resume.waitForExistence(timeout: 5))
        XCTAssertTrue(resume.label.contains("戦闘を再開する"))
        resume.tap()
        XCTAssertTrue(suspend.waitForExistence(timeout: 5))
        XCTAssertFalse(close.exists)
        suspend.tap()
    }
}
