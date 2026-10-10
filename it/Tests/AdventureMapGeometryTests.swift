import Foundation
import CoreGraphics

@main
enum AdventureMapGeometryTests {
    static var checks = 0
    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        checks += 1
        precondition(condition(), message)
    }
    static func near(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) < 0.0001 }

    static func main() {
        // A route passing through an unrelated marker looks like a second
        // course or an intersection the player cannot actually take.
        for (a, b) in AdventureWorld.edges {
            let start = AdventureWorld.node(a)!, end = AdventureWorld.node(b)!
            let dx = end.x - start.x, dy = end.y - start.y
            for node in AdventureWorld.nodes where node.id != a && node.id != b {
                let t = max(0, min(1, ((node.x - start.x) * dx + (node.y - start.y) * dy) / (dx * dx + dy * dy)))
                check(hypot(node.x - start.x - t * dx, node.y - start.y - t * dy) >= 30,
                      "A trail must stay clear of unrelated markers: \(a)–\(b), stop \(node.id)")
            }
        }
        func side(_ a: AdventureNode, _ b: AdventureNode, _ c: AdventureNode) -> Double {
            (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        }
        for (index, edge) in AdventureWorld.edges.enumerated() {
            for other in AdventureWorld.edges.dropFirst(index + 1) {
                guard edge.0 != other.0, edge.0 != other.1,
                      edge.1 != other.0, edge.1 != other.1 else { continue }
                let a = AdventureWorld.node(edge.0)!, b = AdventureWorld.node(edge.1)!
                let c = AdventureWorld.node(other.0)!, d = AdventureWorld.node(other.1)!
                check(!(side(a, b, c) * side(a, b, d) < 0 && side(c, d, a) * side(c, d, b) < 0),
                      "Trails must meet at a real stop rather than an unplayable crossing")
            }
        }

        let layout = AdventureMapLayout(style: .storybook)
        let expanded = AdventureMapLayout(style: .storybook, expanded: true)
        let tallArtwork = AdventureMapLayout(style: .storybook, usesTallArtwork: true)
        let original = AdventureMapLayout(style: .illustrated)
        check(near(expanded.worldSize.width, layout.worldSize.width * 1.5) &&
              near(expanded.worldSize.height, layout.worldSize.height * 1.5),
              "Expanded preview must provide new terrain on every side")
        for node in AdventureWorld.nodes {
            let oldPoint = layout.point(x: node.x, y: node.y)
            let newPoint = expanded.point(x: node.x, y: node.y)
            check(near(newPoint.x - oldPoint.x, expanded.worldOffset.x) &&
                  near(newPoint.y - oldPoint.y, expanded.worldOffset.y),
                  "Saved landmarks must stay in the same central-map positions")
        }
        check(near(tallArtwork.worldSize.width / tallArtwork.worldSize.height, 850 / 1850),
              "Tall storybook artwork must retain its native portrait aspect ratio")
        for node in AdventureWorld.nodes {
            let originalPoint = layout.point(x: node.x, y: node.y)
            let tallPoint = tallArtwork.point(x: node.x, y: node.y)
            check(near(tallPoint.x, originalPoint.x) &&
                  near(tallPoint.y - originalPoint.y, (tallArtwork.worldSize.height - layout.worldSize.height) / 2),
                  "Tall artwork must preserve all saved landmark positions in the centered original terrain")
        }
        let tallBaseGeometry = AdventureMapGeometry(worldSize: tallArtwork.worldSize,
                                                    viewportSize: CGSize(width: 390, height: 700))
        let tallScreenGeometry = AdventureMapGeometry(
            worldSize: tallArtwork.worldSize, viewportSize: CGSize(width: 390, height: 700),
            minimumAllowedScale: tallBaseGeometry.screenFillScale(screenHeight: 844))
        check(tallScreenGeometry.minimumScale * tallArtwork.worldSize.width >= 389.5 &&
              tallScreenGeometry.minimumScale * tallArtwork.worldSize.height >= 843.5,
              "The tall artwork should fill an iPhone screen without letterboxing the overview")
        let source = CGSize(width: 1042, height: 1509)
        let retinaLimit = AdventureMapImageQuality.maximumScale(pixelSize: source, worldSize: layout.worldSize, displayScale: 3)
        check(retinaLimit > 0.30 && retinaLimit < 0.31, "Small sources must not be enlarged to 160%")
        let largerLimit = AdventureMapImageQuality.maximumScale(pixelSize: CGSize(width: 4168, height: 6036),
                                                               worldSize: layout.worldSize, displayScale: 3)
        check(near(largerLimit, retinaLimit * 4), "Replacing the source with a larger image should unlock more zoom")
        let highResolutionGeometry = AdventureMapGeometry(
            worldSize: layout.worldSize, viewportSize: CGSize(width: 402, height: 650),
            maximumAllowedScale: largerLimit)
        check(highResolutionGeometry.maximumScale > 1.2 && highResolutionGeometry.minimumScale < 0.3,
              "The new image should allow useful pinch zoom while retaining the wide opening view")
        var highResolutionPinch = AdventureMapInteraction(camera: highResolutionGeometry.worldCenter,
                                                           scale: highResolutionGeometry.minimumScale)
        highResolutionPinch.update(translation: nil, magnification: 2, anchor: CGPoint(x: 201, y: 325),
                                   geometry: highResolutionGeometry)
        check(near(highResolutionPinch.scale, highResolutionGeometry.minimumScale * 2),
              "Pinching outward should enlarge the high-resolution map")
        highResolutionPinch.update(translation: nil, magnification: 0.1, anchor: CGPoint(x: 201, y: 325),
                                   geometry: highResolutionGeometry)
        check(near(highResolutionPinch.scale, highResolutionGeometry.minimumScale),
              "Pinching inward should return to the full-map overview")
        let scaleTwoLimit = AdventureMapImageQuality.maximumScale(pixelSize: source, worldSize: layout.worldSize, displayScale: 2)
        check(near(scaleTwoLimit, retinaLimit * 1.5), "Raster limits must account for the display's pixel density")
        let limited = AdventureMapGeometry(worldSize: layout.worldSize, viewportSize: CGSize(width: 402, height: 450),
                                           maximumAllowedScale: retinaLimit)
        check(near(limited.clampedScale(1.6), retinaLimit), "Buttons, pinch and recenter must share the raster zoom limit")
        check(limited.fitScale < limited.maximumScale, "The whole map and useful zoom should remain available")
        let filled = limited.screenFillScale(screenHeight: 844 + 48)
        check(filled > limited.fitScale && near(filled * layout.worldSize.height, 892),
              "Screen-fill mode should cover the device height without stretching the map")
        check(limited.clampedCamera(.zero, scale: filled).x < limited.worldCenter.x,
              "The cropped horizontal edge must remain reachable by dragging")
        let fullMapGeometry = AdventureMapGeometry(
            worldSize: layout.worldSize, viewportSize: CGSize(width: 390, height: 620),
            maximumAllowedScale: retinaLimit)
        check(near(fullMapGeometry.minimumScale, fullMapGeometry.fitScale),
              "The storybook map must allow a full-map overview")
        check(fullMapGeometry.maximumScale >= fullMapGeometry.minimumScale,
              "The image quality limit must leave the overview available")
        check(near(fullMapGeometry.clampedScale(0.01), fullMapGeometry.minimumScale),
              "Zooming out must stop at the full-map overview")
        let overviewCamera = fullMapGeometry.clampedCamera(CGPoint.zero, scale: fullMapGeometry.minimumScale)
        for corner in [CGPoint.zero, CGPoint(x: layout.worldSize.width, y: layout.worldSize.height)] {
            let screen = fullMapGeometry.screenPoint(corner, camera: overviewCamera, scale: fullMapGeometry.minimumScale)
            check(screen.x >= 19.9 && screen.x <= fullMapGeometry.viewportSize.width - 19.9 &&
                  screen.y >= 23.9 && screen.y <= fullMapGeometry.viewportSize.height - 23.9,
                  "The overview must include every edge of the map")
        }
        let tallBottomGeometry = AdventureMapGeometry(worldSize: tallArtwork.worldSize,
                                                       viewportSize: CGSize(width: 390, height: 620),
                                                       maximumAllowedScale: 0.35)
        let bottomCamera = tallBottomGeometry.clampedCamera(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude),
                                                            scale: tallBottomGeometry.maximumScale)
        let bottomNode = tallArtwork.point(x: 250, y: 1300)
        let bottomScreen = tallBottomGeometry.screenPoint(bottomNode, camera: bottomCamera,
                                                          scale: tallBottomGeometry.maximumScale)
        check(bottomScreen.y < tallBottomGeometry.viewportSize.height - 30,
              "The village at the map bottom must remain visible above the footer")
        let topCamera = fullMapGeometry.clampedCamera(CGPoint.zero, scale: fullMapGeometry.maximumScale)
        let topNode = layout.point(x: 455, y: 55)
        let topScreen = fullMapGeometry.screenPoint(topNode, camera: topCamera,
                                                     scale: fullMapGeometry.maximumScale)
        check(topScreen.y > 30, "The first nodes must remain tappable below the header")
        var fullMapPinch = AdventureMapInteraction(camera: fullMapGeometry.worldCenter,
                                                    scale: fullMapGeometry.maximumScale)
        fullMapPinch.update(translation: nil, magnification: 0.01, anchor: CGPoint(x: 195, y: 310),
                            geometry: fullMapGeometry)
        check(near(fullMapPinch.scale, fullMapGeometry.minimumScale),
              "Pinching inward must share the full-map zoom floor")
        check(AdventureMapImageQuality.maximumScale(pixelSize: .zero, worldSize: layout.worldSize, displayScale: 3).isFinite,
              "A missing asset must not produce invalid camera coordinates")
        check(near(layout.worldSize.width * layout.worldSize.height,
                   original.worldSize.width * original.worldSize.height * 9), "Expanded world should cover nine times the area")
        for node in AdventureWorld.nodes {
            let point = layout.point(x: node.x, y: node.y)
            check(near(point.x / layout.worldSize.width, node.x / AdventureWorld.width), "Horizontal landmark alignment must survive expansion")
            check(near(point.y / layout.worldSize.height, node.y / AdventureWorld.height), "Vertical landmark alignment must survive expansion")
        }

        for viewport in [CGSize(width: 320, height: 300), CGSize(width: 402, height: 450),
                         CGSize(width: 844, height: 180), CGSize(width: 1024, height: 800)] {
            let geometry = AdventureMapGeometry(worldSize: layout.worldSize, viewportSize: viewport)
            let scale = geometry.fitScale
            let camera = geometry.clampedCamera(CGPoint(x: -99999, y: 99999), scale: scale)
            check(camera == geometry.worldCenter, "Overview must remain centered in every aspect ratio")
            for point in [CGPoint.zero, CGPoint(x: layout.worldSize.width, y: layout.worldSize.height)] {
                let screen = geometry.screenPoint(point, camera: camera, scale: scale)
                check(screen.x >= 19.9 && screen.x <= viewport.width - 19.9, "Overview must include both horizontal map edges")
                check(screen.y >= 23.9 && screen.y <= viewport.height - 23.9, "Overview must include both vertical map edges")
            }
            check(near(geometry.clampedScale(0), scale), "Zoom must not collapse below overview")
            check(near(geometry.clampedScale(100), 1.6), "Zoom must respect the maximum")

            for zoom in [CGFloat(0.4), CGFloat(0.82), CGFloat(1.6)] {
                let start = geometry.worldCenter
                let pan = CGSize(width: 8, height: -8)
                let end = geometry.pannedCamera(start, translation: pan, scale: zoom)
                let oldScreen = geometry.screenPoint(start, camera: start, scale: zoom)
                let newScreen = geometry.screenPoint(start, camera: end, scale: zoom)
                let expectedX = layout.worldSize.width * zoom <= viewport.width ? 0 : pan.width
                let expectedY = layout.worldSize.height * zoom <= viewport.height ? 0 : pan.height
                check(near(newScreen.x - oldScreen.x, expectedX), "Drag distance must remain consistent at every zoom")
                check(near(newScreen.y - oldScreen.y, expectedY), "Vertical drag direction must match the finger")
                for target in [CGPoint(x: -99999, y: -99999), CGPoint(x: 99999, y: 99999)] {
                    let bounded = geometry.clampedCamera(target, scale: zoom)
                    let left = bounded.x - viewport.width / zoom / 2
                    let top = bounded.y - viewport.height / zoom / 2
                    let horizontalFits = layout.worldSize.width * zoom <= viewport.width
                    let verticalFits = layout.worldSize.height * zoom <= viewport.height
                    check(horizontalFits ? near(bounded.x, geometry.worldCenter.x)
                          : left >= -0.001 && left + viewport.width / zoom <= layout.worldSize.width + 0.001,
                          "Panning at detail zoom must not reveal empty horizontal space")
                    check(verticalFits ? near(bounded.y, geometry.worldCenter.y)
                          : top >= -0.001 && top + viewport.height / zoom <= layout.worldSize.height + 0.001,
                          "Panning at detail zoom must not reveal empty vertical space")
                }
            }
        }
        let pinchGeometry = AdventureMapGeometry(worldSize: layout.worldSize, viewportSize: CGSize(width: 402, height: 650),
                                                maximumAllowedScale: retinaLimit)
        let startScale: CGFloat = 0.23
        let startCamera = pinchGeometry.worldCenter
        let anchor = CGPoint(x: 140, y: 270)
        let worldAtAnchor = CGPoint(x: startCamera.x + (anchor.x - 201) / startScale,
                                   y: startCamera.y + (anchor.y - 325) / startScale)
        var pinch = AdventureMapInteraction(camera: startCamera, scale: startScale)
        pinch.update(translation: CGSize(width: 80, height: -70), magnification: 1.2, anchor: anchor, geometry: pinchGeometry)
        let after = pinchGeometry.screenPoint(worldAtAnchor, camera: pinch.camera, scale: pinch.scale)
        check(near(after.x, anchor.x) && near(after.y, anchor.y), "The world point between the fingers must stay anchored while zooming")
        let pinchedCamera = pinch.camera
        pinch.update(translation: CGSize(width: 150, height: 160), magnification: nil, anchor: nil, geometry: pinchGeometry)
        check(pinch.camera == pinchedCamera, "Lifting one finger must not apply a competing drag offset")
        pinch.update(translation: nil, magnification: 1.2, anchor: anchor, geometry: pinchGeometry)
        check(pinch.camera == pinchedCamera, "Ending a pinch must not apply the magnification a second time")
        pinch.update(translation: nil, magnification: 100, anchor: anchor, geometry: pinchGeometry)
        check(near(pinch.scale, retinaLimit), "Pinch zoom must retain the image quality limit")
        pinch.update(translation: nil, magnification: 0.001, anchor: anchor, geometry: pinchGeometry)
        check(near(pinch.scale, pinchGeometry.fitScale) && pinch.camera == pinchGeometry.worldCenter,
              "Pinching inward must stop at the full map without drifting outside it")

        var panThenPinch = AdventureMapInteraction(camera: startCamera, scale: startScale)
        panThenPinch.update(translation: CGSize(width: 12, height: -10), magnification: nil, anchor: nil, geometry: pinchGeometry)
        let beforePinch = panThenPinch.camera
        panThenPinch.update(translation: CGSize(width: 50, height: 20), magnification: 1, anchor: anchor, geometry: pinchGeometry)
        check(panThenPinch.camera == beforePinch, "Adding a second finger must preserve an existing drag position")
        panThenPinch.update(translation: nil, magnification: 1.1, anchor: anchor, geometry: pinchGeometry)
        var nextPinch = AdventureMapInteraction(camera: panThenPinch.camera, scale: panThenPinch.scale)
        nextPinch.update(translation: nil, magnification: 1 / 1.1, anchor: anchor, geometry: pinchGeometry)
        check(near(nextPinch.scale, startScale) && near(nextPinch.camera.x, beforePinch.x) && near(nextPinch.camera.y, beforePinch.y),
              "Separate outward and inward pinch sessions must compose without a zoom or position jump")

        print("Adventure map geometry: \(checks) checks passed")
    }
}
