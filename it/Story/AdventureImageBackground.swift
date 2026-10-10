import SwiftUI

enum AdventureMapBackgroundVariant: String, CaseIterable, Identifiable {
    case current
    case expanded
    case previous
    case watercolor
    case vivid
    case diorama

    var id: String { rawValue }

    var title: String {
        switch self {
        case .current: "B · 採用した背景"
        case .expanded: "試作 · 広域マップ"
        case .previous: "以前の背景"
        case .watercolor: "A · 水彩ポップ"
        case .vivid: "C · ビビッドポップ"
        case .diorama: "D · ジオラマ風"
        }
    }

    var assetName: String {
        switch self {
        case .current: "StoryForestWorldTall"
        case .expanded: "StoryForestExpandedPreview"
        case .previous: "StoryForestWorldSharpBackground"
        case .watercolor: "StoryForestWorldPreviewWatercolor"
        case .vivid: "StoryForestWorldPreviewVivid"
        case .diorama: "StoryForestWorldPreviewDiorama"
        }
    }

    var pixelSize: CGSize {
        AdventureMapRasterCache.full(for: self).pixelSize
    }
}

/// Loading and cropping a large map during every drag frame stalls the main thread.
/// Keep each raster and its edge strips for the lifetime of the process.
private struct AdventureMapRaster {
    let image: Image
    let top: Image?
    let bottom: Image?
    let pixelSize: CGSize

    init(assetName: String) {
        guard let source = UIImage(named: assetName)?.cgImage else {
            image = Image(assetName).interpolation(.high)
            top = nil
            bottom = nil
            pixelSize = .zero
            return
        }
        image = Image(decorative: source, scale: 1).interpolation(.high)
        pixelSize = CGSize(width: source.width, height: source.height)
        let stripHeight = min(64, source.height)
        top = source.cropping(to: CGRect(x: 0, y: 0, width: source.width, height: stripHeight))
            .map { Image(decorative: $0, scale: 1).interpolation(.high) }
        bottom = source.cropping(to: CGRect(x: 0, y: source.height - stripHeight,
                                           width: source.width, height: stripHeight))
            .map { Image(decorative: $0, scale: 1).interpolation(.high) }
    }
}

private enum AdventureMapRasterCache {
    static let current = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.current.assetName)
    static let overview = AdventureMapRaster(assetName: "StoryForestWorldTallOverview")
    static let storybookBackdrop = AdventureMapRaster(assetName: "StoryForestWorldTallBackdrop")
    static let expanded = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.expanded.assetName)
    static let expandedOverview = AdventureMapRaster(assetName: "StoryForestExpandedPreviewOverview")
    static let expandedMedium = AdventureMapRaster(assetName: "StoryForestExpandedPreviewMedium")
    static let previous = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.previous.assetName)
    static let watercolor = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.watercolor.assetName)
    static let vivid = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.vivid.assetName)
    static let diorama = AdventureMapRaster(assetName: AdventureMapBackgroundVariant.diorama.assetName)

    static func full(for variant: AdventureMapBackgroundVariant) -> AdventureMapRaster {
        switch variant {
        case .current: current
        case .expanded: expanded
        case .previous: previous
        case .watercolor: watercolor
        case .vivid: vivid
        case .diorama: diorama
        }
    }

    static func displayed(for variant: AdventureMapBackgroundVariant, scale: CGFloat,
                          displayScale: CGFloat, worldWidth: CGFloat) -> AdventureMapRaster {
        let displayedWidth = worldWidth * scale * displayScale
        if variant == .current, overview.pixelSize.width > 0,
           displayedWidth <= overview.pixelSize.width * 1.5 {
            return overview
        }
        if variant == .expanded {
            if expandedOverview.pixelSize.width > 0,
               displayedWidth <= expandedOverview.pixelSize.width * 1.5 {
                return expandedOverview
            }
            if expandedMedium.pixelSize.width > 0,
               displayedWidth <= expandedMedium.pixelSize.width * 1.5 {
                return expandedMedium
            }
        }
        return full(for: variant)
    }
}

struct AdventureMapBackdropProjection {
    let bounds: Anchor<CGRect>
    let camera: CGPoint
    let scale: CGFloat
}

struct AdventureMapBackdropPreferenceKey: PreferenceKey {
    static var defaultValue: AdventureMapBackdropProjection?
    static func reduce(value: inout AdventureMapBackdropProjection?, nextValue: () -> AdventureMapBackdropProjection?) {
        if let next = nextValue() { value = next }
    }
}

/// Extends the live map behind the transparent HUD using its exact screen anchor.
struct AdventureScreenBackdrop: View {
    let projection: AdventureMapBackdropProjection?
    let enabled: Bool
    let backgroundVariant: AdventureMapBackgroundVariant

    var body: some View {
        GeometryReader { reader in
            if enabled {
                ZStack {
                    AdventurePalette.deep
                    if let projection {
                        let mapFrame = reader[projection.bounds]
                        let camera = CGPoint(
                            x: projection.camera.x + (reader.size.width / 2 - mapFrame.midX) / projection.scale,
                            y: projection.camera.y + (reader.size.height / 2 - mapFrame.midY) / projection.scale)
                        AdventureMapExtendedBackdrop(camera: camera, scale: projection.scale,
                                                     variant: backgroundVariant)
                    }
                    LinearGradient(stops: [
                        .init(color: .black.opacity(0.64), location: 0),
                        .init(color: .black.opacity(0.35), location: 0.10),
                        .init(color: .clear, location: 0.20),
                        .init(color: .clear, location: 0.82),
                        .init(color: .black.opacity(0.58), location: 0.94),
                        .init(color: .black.opacity(0.78), location: 1)
                    ], startPoint: .top, endPoint: .bottom)
                }
            } else {
                AdventurePalette.paper
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The main map remains phone-aspect so it can be shown in full. This separate,
/// vertically extended artwork only fills the non-interactive header and footer.
private struct AdventureMapExtendedBackdrop: View {
    let camera: CGPoint
    let scale: CGFloat
    let variant: AdventureMapBackgroundVariant

    private static let mapPixels = CGSize(width: 850, height: 1850)
    private static let backdropPixels = CGSize(width: 754, height: 2085)

    var body: some View {
        if variant == .current {
            let world = AdventureMapLayout(style: .storybook, usesTallArtwork: true).worldSize
            let pixelToWorld = world.width / Self.backdropPixels.width
            let centeredMapHeight = Self.mapPixels.height * Self.backdropPixels.width / Self.mapPixels.width
            let topBleed = max(0, (Self.backdropPixels.height - centeredMapHeight) / 2) * pixelToWorld
            let destination = CGRect(x: -camera.x * scale, y: -(camera.y + topBleed) * scale,
                                     width: world.width * scale,
                                     height: Self.backdropPixels.height * pixelToWorld * scale)
            Canvas { context, size in
                context.translateBy(x: size.width / 2, y: size.height / 2)
                context.draw(AdventureMapRasterCache.storybookBackdrop.image, in: destination)
            }
        } else {
            AdventureImageBackground(camera: camera, scale: scale, variant: variant)
        }
    }
}

/// The image and landmarks use the same world transform.
/// Replace this asset to change the scenery without changing progression or rewards.
struct AdventureImageBackground: View {
    static let assetName = AdventureMapBackgroundVariant.current.assetName

    @Environment(\.displayScale) private var displayScale
    let camera: CGPoint
    let scale: CGFloat
    let variant: AdventureMapBackgroundVariant

    private var mapImage: some View {
        let world = AdventureMapLayout(style: .storybook, expanded: variant == .expanded,
                                       usesTallArtwork: variant == .current).worldSize
        let raster = AdventureMapRasterCache.displayed(for: variant, scale: scale,
                                                       displayScale: displayScale, worldWidth: world.width)
        return Canvas { context, size in
            // Draw at the viewport's display resolution; do not magnify an
            // intermediate rasterized SwiftUI layer with scaleEffect.
            let destination = CGRect(
                x: size.width / 2 - camera.x * scale,
                y: size.height / 2 - camera.y * scale,
                width: world.width * scale, height: world.height * scale)
            // Do not stretch edge strips outside the map. When the user pans to
            // either end, the surrounding deep backdrop remains visible instead.
            context.draw(raster.image, in: destination)
        }
    }

    @ViewBuilder var body: some View {
        if variant == .current || variant == .expanded {
            // These adjustments are baked into every resolution of these maps.
            mapImage.accessibilityHidden(true)
        } else {
            mapImage.saturation(0.80).contrast(0.90).brightness(-0.03)
                .accessibilityHidden(true)
        }
    }
}

struct StoryImageAdventureHomeCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("STORY QUEST · ANOTHER VIEW")
                        .font(.system(size: 9, weight: .bold)).tracking(1.2)
                        .foregroundColor(AdventurePalette.gold)
                    Text("絵本の森を冒険する")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                    Text("同じ冒険を、もうひとつの景色で。")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.18), in: Circle())
            }
            .foregroundColor(.white)
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 115, alignment: .leading)
            .background {
                GeometryReader { geometry in
                    Image("StoryForestWorldTallOverview")
                        .resizable().scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                .overlay {
                    LinearGradient(colors: [Color(hex: "173D2E").opacity(0.95), Color(hex: "173D2E").opacity(0.35)],
                                   startPoint: .leading, endPoint: .trailing)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(AdventurePalette.gold.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.storyImageAdventure")
    }
}
