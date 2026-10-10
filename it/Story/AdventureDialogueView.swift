import SwiftUI

/// A self-contained dialogue stage. It reads existing art and receives actions
/// from the adventure store, so previews never need authentication or Firebase.
struct AdventureDialogueView: View {
    let playback: AdventureStoryPlayback
    let avatarName: String
    let onAdvance: () -> Void
    let onPrevious: () -> Void
    let onSkip: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let cream = Color(red: 0.98, green: 0.96, blue: 0.88)
    private let gold = Color(red: 0.89, green: 0.76, blue: 0.47)
    private var scene: AdventureStoryScene { playback.bookmark.scene }
    private var page: Int { playback.bookmark.page }
    private var line: AdventureStoryLine { scene.lines[page] }
    private var isLastPage: Bool { page == scene.lines.count - 1 }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 600 || dynamicTypeSize.isAccessibilitySize
            VStack(spacing: 0) {
                header
                if !dynamicTypeSize.isAccessibilitySize {
                    stage(height: max(100, min(geometry.size.height * 0.43, 380)))
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 12)
                }
                dialogueCard
                    .frame(height: compact ? geometry.size.height * 0.64 : min(330, geometry.size.height * 0.43))
                    .padding(.horizontal, 20)
                Text(playback.isReplay ? "旅の記録を読み返しています" : "物語は自動で保存されます")
                    .font(.caption2).foregroundColor(cream.opacity(0.72))
                    .padding(.top, 13).padding(.bottom, 12)
            }
            .frame(maxWidth: 680).frame(maxWidth: .infinity)
        }
        .background {
            GeometryReader { geometry in
                Image("StoryForestWorldTallBackdrop")
                    .resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.4, anchor: scene == .port ? .topTrailing : .bottomLeading)
                    .blur(radius: 1.5)
                    .overlay(Color(red: 0.04, green: 0.13, blue: 0.1).opacity(0.35))
                    .overlay {
                        LinearGradient(colors: [.black.opacity(0.55), .clear, AdventurePalette.deep.opacity(0.96)],
                                       startPoint: .top, endPoint: .bottom)
                    }
                    .clipped()
            }
            .ignoresSafeArea().accessibilityHidden(true)
        }
        .background(AdventurePalette.deep.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("第1章 · はじまりの森", systemImage: "book.closed")
                    .font(.system(size: 11, weight: .semibold)).tracking(1)
                    .foregroundColor(cream.opacity(0.85))
                Spacer(minLength: 8)
                Button(action: onSkip) {
                    Text(playback.isReplay ? "閉じる" : "スキップ")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 14).frame(minHeight: 44)
                        .background(.black.opacity(0.25), in: Capsule())
                        .overlay(Capsule().strokeBorder(cream.opacity(0.25)))
                }
                .buttonStyle(.plain).foregroundColor(cream)
                .accessibilityIdentifier("adventure.story.skip")
            }
            Text(scene.title)
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundColor(cream).shadow(color: .black.opacity(0.45), radius: 5, y: 2)
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 8) {
                Capsule().fill(gold).frame(width: 20, height: 2)
                Text(scene.location).font(.caption).foregroundColor(cream.opacity(0.8))
            }
        }
        .padding(.horizontal, 24).padding(.top, 8)
    }

    private func stage(height: CGFloat) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .bottom) {
                Ellipse().fill(gold.opacity(0.15))
                    .frame(width: width * 0.9, height: 70).blur(radius: 22)
                    .offset(y: -10)
                Image(scene.artwork)
                    .resizable().scaledToFit()
                    .frame(width: min(width * 0.64, 285), height: height * 0.88)
                    .shadow(color: .black.opacity(0.35), radius: 16, y: 10)
                    .brightness(line.speaker.isCompanion ? -0.12 : 0)
                    .scaleEffect(line.speaker.isCharacter ? 1.04 : 1)
                    .offset(x: width * 0.16, y: -height * 0.12)
                Image(avatarName)
                    .resizable().scaledToFit()
                    .frame(width: min(width * 0.47, 225), height: height * 0.65)
                    .shadow(color: .black.opacity(0.45), radius: 12, y: 8)
                    .brightness(line.speaker.isCharacter ? -0.15 : 0)
                    .scaleEffect(line.speaker.isCompanion ? 1.04 : 1)
                    .offset(x: -width * 0.21, y: 0)
            }
            .frame(width: width, height: geometry.size.height, alignment: .bottom)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
            .accessibilityHidden(true)
        }
        .frame(height: height).padding(.horizontal, 20).padding(.bottom, 10)
    }

    private var dialogueCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 9) {
                Image(systemName: line.speaker.isCompanion ? "pawprint.fill" : "sparkle")
                    .foregroundColor(AdventurePalette.leaf)
                Text(line.speaker.name(companion: avatarName))
                    .font(.headline).foregroundColor(AdventurePalette.deep)
                Spacer(minLength: 8)
                Text("\(page + 1) / \(scene.lines.count)")
                    .font(.caption.monospacedDigit()).foregroundColor(AdventurePalette.muted)
                    .accessibilityLabel("\(scene.lines.count)ページ中、\(page + 1)ページ目")
            }
            Rectangle().fill(AdventurePalette.deep.opacity(0.12)).frame(height: 1)
            ScrollViewReader { proxy in
                ScrollView {
                    Text(line.text)
                        .font(.system(.body, design: .serif, weight: .medium))
                        .lineSpacing(8).foregroundColor(AdventurePalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(page)
                        .accessibilityIdentifier("adventure.story.dialogue")
                        .accessibilityLabel("\(line.speaker.name(companion: avatarName))。\(line.text)")
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onAdvance)
                .onChange(of: page) { value in proxy.scrollTo(value, anchor: .top) }
            }
            HStack(spacing: 12) {
                Button(action: onPrevious) {
                    Image(systemName: "arrow.left").font(.system(size: 15, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(AdventurePalette.deep.opacity(0.07), in: Circle())
                }
                .buttonStyle(.plain).foregroundColor(AdventurePalette.deep)
                .disabled(page == 0).opacity(page == 0 ? 0.3 : 1)
                .accessibilityLabel("前のセリフ").accessibilityIdentifier("adventure.story.previous")
                Spacer(minLength: 0)
                Button(action: onAdvance) {
                    HStack(spacing: 8) {
                        Text(isLastPage ? (playback.isReplay ? "物語一覧へ" : scene.destinationTitle) : "つづきを読む")
                        Image(systemName: isLastPage ? "arrow.right" : "chevron.right")
                    }
                    .font(.system(.subheadline, weight: .semibold))
                    .padding(.horizontal, 16).frame(minHeight: 46)
                    .foregroundColor(cream)
                    .background(AdventurePalette.deep, in: Capsule())
                }
                .buttonStyle(.plain).accessibilityIdentifier("adventure.story.next")
            }
        }
        .padding(22)
        .background(cream, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(gold.opacity(0.65)))
        .shadow(color: .black.opacity(0.25), radius: 22, y: 12)
        .environment(\.colorScheme, .light)
    }
}

#if DEBUG
struct AdventureDialogueView_Previews: PreviewProvider {
    static var previews: some View {
        AdventureDialogueView(playback: .init(bookmark: .init(scene: .departure, page: 1), isReplay: false),
                              avatarName: "ネッキー", onAdvance: {}, onPrevious: {}, onSkip: {})
            .previewDisplayName("旅立ちの会話")
        AdventureDialogueView(playback: .init(bookmark: .init(scene: .guardian, page: 1), isReplay: true),
                              avatarName: "ネッキー", onAdvance: {}, onPrevious: {}, onSkip: {})
            .environment(\.dynamicTypeSize, .accessibility3)
            .previewDisplayName("大きな文字で読み返す")
    }
}
#endif
