import SwiftUI

/// Colors for the recovery screens. Problem review is blue, theme learning is teal, premium is amber.
enum RecoveryStyle {
    static let backgroundTop = Color(hex: "E6F0FF")
    static let backgroundBottom = Color(hex: "F5F8FE")
    static let text = Color(hex: "1A2433")
    static let secondaryText = Color(hex: "4A5568")
    static let cardBorder = Color(hex: "E3EAF5")
    static let done = Color(hex: "1E7A45")
    static let gold = Color(hex: "A36A00")
    static let goldBackground = Color(hex: "FFF8E6")

    static var background: some View {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

enum RecoveryTint {
    case review, theme, premium, done, gold, neutral

    var main: Color {
        switch self {
        case .review: return Color(hex: "1D64C2")
        case .theme: return Color(hex: "0B7366")
        case .premium: return Color(hex: "7F4300")
        case .done: return RecoveryStyle.done
        case .gold: return RecoveryStyle.gold
        case .neutral: return RecoveryStyle.secondaryText
        }
    }

    var shadow: Color {
        switch self {
        case .review: return Color(hex: "124A94")
        case .theme: return Color(hex: "06524A")
        case .gold: return Color(hex: "7A5000")
        default: return main.opacity(0.6)
        }
    }

    var tagBackground: Color {
        switch self {
        case .review: return Color(hex: "E1EDFC")
        case .theme: return Color(hex: "D9F2EE")
        case .premium: return Color(hex: "FFEED3")
        case .done: return Color(hex: "E3F4EA")
        case .gold: return RecoveryStyle.goldBackground
        case .neutral: return Color(hex: "EDF1F7")
        }
    }

    var tagText: Color {
        switch self {
        case .review: return Color(hex: "164C93")
        case .theme: return Color(hex: "0A5C52")
        case .premium: return Color(hex: "7F4300")
        case .done: return RecoveryStyle.done
        case .gold: return Color(hex: "7A5000")
        case .neutral: return RecoveryStyle.secondaryText
        }
    }
}

struct RecoveryTag: View {
    let text: String
    var icon: String?
    let tint: RecoveryTint

    static var premium: RecoveryTag { RecoveryTag(text: "プレミアム", icon: "crown.fill", tint: .premium) }
    static var review: RecoveryTag { RecoveryTag(text: "解き直し", icon: "arrow.counterclockwise", tint: .review) }
    static var theme: RecoveryTag { RecoveryTag(text: "テーマ", icon: "book", tint: .theme) }

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).imageScale(.small) }
            Text(text)
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(tint.tagText)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.tagBackground, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

/// Tags sit in a row, and stack vertically at accessibility text sizes.
struct RecoveryTagRow: View {
    let tags: [RecoveryTag]
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .accessibility1 {
            VStack(alignment: .leading, spacing: 6) { ForEach(tags.indices, id: \.self) { tags[$0] } }
        } else {
            FlowLayout(spacing: 6) { ForEach(tags.indices, id: \.self) { tags[$0] } }
        }
    }
}

struct RecoveryPrimaryButtonStyle: ButtonStyle {
    let tint: RecoveryTint

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(tint.main)
                    .background(RoundedRectangle(cornerRadius: 16).fill(tint.shadow).offset(y: configuration.isPressed ? 1 : 4))
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .padding(.bottom, 4)
    }
}

struct RecoveryOutlineButtonStyle: ButtonStyle {
    let tint: RecoveryTint

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(tint.tagText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.main.opacity(configuration.isPressed ? 0.4 : 1), lineWidth: 1.5))
    }
}

struct RecoveryCard<Content: View>: View {
    var highlight: RecoveryTint?
    var background: Color = .white
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20)
                .strokeBorder(highlight?.main ?? RecoveryStyle.cardBorder, lineWidth: highlight == nil ? 1 : 2.5))
    }
}

struct RecoverySectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.title3.bold()).foregroundStyle(RecoveryStyle.text)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            trailing
        }
    }
}

extension RecoverySectionHeader where Trailing == EmptyView {
    init(title: String) { self.init(title: title) { EmptyView() } }
}

/// The same high-contrast companion appears on the home and result screens.
struct RecoveryMonsterAvatar: View {
    let size: CGFloat

    var body: some View {
        Image("ReviewWhiteBeardMonster")
            .resizable().scaledToFit()
            .frame(width: size, height: size)
            .padding(4)
            .background(
                Circle().fill(
                    LinearGradient(
                        colors: [Color(hex: "83ADD1"), Color(hex: "5B88B5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
            .overlay(Circle().strokeBorder(Color(hex: "4B78A3"), lineWidth: 1))
            .shadow(color: Color(hex: "315E86").opacity(0.25), radius: 4, y: 2)
            .accessibilityHidden(true)
    }
}

private struct RecoverySpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        let left: CGFloat = 10
        let radius = min(16, rect.height / 2)
        let middle = rect.midY
        var path = Path()
        path.move(to: CGPoint(x: left + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: left + radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: left, y: rect.maxY - radius),
                          control: CGPoint(x: left, y: rect.maxY))
        path.addLine(to: CGPoint(x: left, y: middle + 8))
        path.addLine(to: CGPoint(x: rect.minX, y: middle))
        path.addLine(to: CGPoint(x: left, y: middle - 8))
        path.addLine(to: CGPoint(x: left, y: rect.minY + radius))
        path.addQuadCurve(to: CGPoint(x: left + radius, y: rect.minY),
                          control: CGPoint(x: left, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

/// At accessibility sizes the bubble is placed by the parent below the cards.
struct RecoveryCompanion: View {
    let message: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedMessage = ""

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            RecoveryMonsterAvatar(size: 62)
            ZStack(alignment: .topLeading) {
                // Keep the bubble at its final size while the text is being typed.
                Text(message).hidden()
                Text(displayedMessage)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(RecoveryStyle.text)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 24).padding(.trailing, 14).padding(.vertical, 10)
            .background(RecoverySpeechBubble().fill(.white))
            .overlay(RecoverySpeechBubble().stroke(RecoveryStyle.cardBorder, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("おとも：\(message)")
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { displayedMessage = message }
        .accessibilityAction(named: Text("全文を表示")) { displayedMessage = message }
        .task(id: message) {
            displayedMessage = ""
            if reduceMotion {
                displayedMessage = message
                return
            }
            for character in message {
                try? await Task.sleep(nanoseconds: 30_000_000)
                guard !Task.isCancelled, displayedMessage != message else { return }
                displayedMessage.append(character)
            }
        }
    }
}

/// Horizontal step indicator, e.g. "説明 → 3問 → 翌日おさらい".
struct RecoveryStepFlow: View {
    let steps: [String]
    let tint: RecoveryTint

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(steps.indices, id: \.self) { index in
                HStack(spacing: 4) {
                    Text(steps[index])
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint.tagText)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(tint.tagBackground, in: RoundedRectangle(cornerRadius: 8))
                    if index < steps.count - 1 {
                        Image(systemName: "arrow.right").font(.caption2.bold()).foregroundStyle(RecoveryStyle.secondaryText)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(steps.joined(separator: "、そのあと"))
    }
}

/// Vertical steps for the explanation sheet. The goal step gets a check instead of a number.
struct RecoveryVerticalSteps: View {
    struct Step {
        let title: String
        var detail: String? = nil
        var isGoal = false
    }

    let steps: [Step]
    let tint: RecoveryTint

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Group {
                            if step.isGoal {
                                Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                            } else {
                                Text("\(index + 1)").font(.caption.bold()).foregroundStyle(tint.tagText)
                            }
                        }
                        .frame(width: 24, height: 24)
                        .background(step.isGoal ? tint.main : tint.tagBackground, in: Circle())
                        if index < steps.count - 1 {
                            Rectangle().fill(tint.tagBackground).frame(width: 2).frame(minHeight: 12)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                        if let detail = step.detail {
                            Text(detail).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2).padding(.bottom, 10)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// "次の予定": date and how far away, then the kind and what happens.
struct RecoveryUpcomingList: View {
    let items: [ReviewUpcomingItem]
    var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                if index > 0 { Divider() }
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.date.formatted(.dateTime.month(.defaultDigits).day().weekday(.short)))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(RecoveryStyle.text)
                        Text(relativeDay(item.date)).font(.caption2.weight(.semibold))
                            .foregroundStyle(RecoveryStyle.secondaryText)
                    }
                    .frame(minWidth: 72, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        tag(for: item.kind)
                        Text(content(for: item.kind)).font(.subheadline.weight(.bold))
                            .foregroundStyle(RecoveryStyle.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 10)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now),
                                           to: calendar.startOfDay(for: date)).day ?? 0
        return days <= 1 ? "明日" : "\(days)日後"
    }

    private func tag(for kind: ReviewUpcomingItem.Kind) -> RecoveryTag {
        switch kind {
        case .review: return .review
        case .themeCheckup: return .theme
        }
    }

    private func content(for kind: ReviewUpcomingItem.Kind) -> String {
        switch kind {
        case .review: return "日付が来た問題を解き直す"
        case let .themeCheckup(topicID, number):
            return "\(WeaknessCourseCatalog.topic(topicID)?.title ?? "テーマ") \(number)回目のおさらい"
        }
    }
}

/// Rounded square behind an SF Symbol, used for list rows and section titles.
struct RecoveryIconTile: View {
    let symbol: String
    let tint: RecoveryTint
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .font(.body.weight(.semibold))
            .foregroundStyle(tint.main)
            .frame(width: size, height: size)
            .background(tint.tagBackground, in: RoundedRectangle(cornerRadius: size * 0.28))
            .accessibilityHidden(true)
    }
}

/// Small print under a button: an icon followed by the note.
struct RecoveryNote: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: icon).accessibilityHidden(true)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption)
        .foregroundStyle(RecoveryStyle.secondaryText)
    }
}

struct RecoveryNumberBadge: View {
    let number: Int
    let tint: RecoveryTint
    let filled: Bool

    var body: some View {
        Text("\(number)")
            .font(.caption.bold().monospacedDigit())
            .foregroundStyle(filled ? .white : tint.tagText)
            .frame(width: 24, height: 24)
            .background(filled ? tint.main : tint.tagBackground, in: Circle())
            .accessibilityLabel("\(number)番目")
    }
}

/// 練習 › おさらい1 › おさらい2 › マスター, with today's step filled.
struct ThemeStepProgress: View {
    /// 1 or 2: the checkup that is due today (or next, with `currentPrefix` "次").
    let checkupNumber: Int
    var currentPrefix = "今日"

    private var steps: [(title: String, done: Bool, current: Bool)] {
        [("練習", true, false),
         (checkupNumber == 1 ? "\(currentPrefix)：おさらい1" : "おさらい1", checkupNumber > 1, checkupNumber == 1),
         (checkupNumber == 2 ? "\(currentPrefix)：おさらい2" : "おさらい2", false, checkupNumber == 2),
         ("マスター", false, false)]
    }

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                HStack(spacing: 4) {
                    HStack(spacing: 3) {
                        if step.done { Image(systemName: "checkmark").font(.caption2.bold()) }
                        Text(step.title)
                    }
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(step.current ? .white : step.done ? RecoveryTint.theme.tagText : RecoveryStyle.secondaryText)
                    .padding(.horizontal, 7).padding(.vertical, 4)
                    .background(step.current ? RecoveryTint.theme.main : step.done ? RecoveryTint.theme.tagBackground : .white,
                                in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(step.current || step.done ? .clear : RecoveryStyle.cardBorder))
                    if index < steps.count - 1 {
                        Image(systemName: "chevron.right").font(.caption2.bold()).imageScale(.small)
                            .foregroundStyle(RecoveryStyle.secondaryText)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("練習済み、\(currentPrefix)は\(checkupNumber)回目のおさらい。2回目のあとマスター")
    }
}

/// Wraps children onto new lines when the row is full.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indexes {
                let size = subviews[index].sizeThatFits(.unspecified)
                let fitted = CGSize(width: min(size.width, bounds.width), height: size.height)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - fitted.height) / 2),
                                      proposal: ProposedViewSize(fitted))
                x += fitted.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row { var indexes: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let itemWidth = min(size.width, width)
            if !current.indexes.isEmpty && current.width + spacing + itemWidth > width {
                rows.append(current)
                current = Row()
            }
            current.width += (current.indexes.isEmpty ? 0 : spacing) + itemWidth
            current.height = max(current.height, size.height)
            current.indexes.append(index)
        }
        if !current.indexes.isEmpty { rows.append(current) }
        return rows
    }
}

extension CourseAccountState {
    /// A theme counts as "learning" once practice has started, not merely because a related question was missed.
    func isLearning(_ topicID: String) -> Bool {
        if activeSession?.topicID == topicID { return true }
        guard let progress = cloud.progress[topicID], progress.stage != .mastered else { return false }
        if progress.stage == .waiting || cloud.freeClaim?.topicID == topicID { return true }
        return !Set(progress.questionHistory.keys).subtracting(cloud.importedSourceIDs).isEmpty
    }
}
