//
//  QuizResultComponents.swift
//  it
//
//  通常クイズの結果画面（学習レポート型）とレベルアップカードの部品。
//

import SwiftUI

// MARK: - Palette

/// 結果画面の色。Color(hex:)は固定色なので、面や文字はダークモードで切り替える。
enum ResultPalette {
    static func dynamic(_ light: String, _ dark: String) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }

    static let screen = dynamic("F2F4F8", "000000")
    static let card = Color(.secondarySystemGroupedBackground)
    static let track = dynamic("E8ECF3", "2C2F36")
    static let progress = Color(hex: "2F7CF6")
    static let segmentBackground = dynamic("E3E7EF", "1F2229")
    static let segmentSelected = dynamic("FFFFFF", "3A3D45")
    static let barBorder = dynamic("E3E7EF", "2C2F36")
    static let outline = dynamic("C9D0DD", "4A4F5A")
    static let primaryButton = Color(hex: "2F6FDB")
    static let primaryText = dynamic("1B2333", "F2F4F8")

    static let expBackground = dynamic("EFEAFE", "2E2650")
    static let expText = dynamic("5B3FD0", "C9B8FF")
    static let coinBackground = dynamic("FFF4D6", "3D3115")
    static let coinText = dynamic("8A5A00", "F5C451")

    static let incorrectBadge = dynamic("FDE8E8", "4A1E1E")
    static let incorrectText = dynamic("C62828", "FF8A80")
    static let correctBadge = dynamic("E3F4E5", "1C3A22")
    static let correctText = dynamic("1E7B34", "7DDB8E")
    static let userAnswerBackground = dynamic("FDF2F2", "3A1F1F")
    static let correctAnswerBackground = dynamic("EEF6EE", "1D3322")
}

private extension Font {
    static func resultRounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Score card

struct ResultScoreCard: View {
    let correctCount: Int
    let totalCount: Int
    /// 0 のときは時間を表示しない
    let duration: TimeInterval
    let experience: Int
    let coins: Int

    @State private var animatedProgress: Double = 0

    private var ratio: Double {
        totalCount > 0 ? Double(correctCount) / Double(totalCount) : 0
    }

    private var percent: Int { Int((ratio * 100).rounded()) }

    private var headline: String {
        switch percent {
        case 80...: return "合格ラインクリア！"
        case 60..<80: return "合格ラインまであと少し"
        default: return "まずは復習から"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ring
            VStack(alignment: .leading, spacing: 6) {
                Text(headline)
                    .font(.resultRounded(17, .heavy))
                    .foregroundColor(ResultPalette.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                if duration > 0 {
                    Text("時間 \(Self.clock(duration))　平均 \(averageSeconds)秒/問")
                        .font(.resultRounded(12, .semibold))
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6) {
                    chip("EXP +\(experience)", background: ResultPalette.expBackground, foreground: ResultPalette.expText)
                    chip("コイン +\(coins)", background: ResultPalette.coinBackground, foreground: ResultPalette.coinText)
                }
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            withAnimation(.easeOut(duration: 0.9).delay(0.15)) {
                animatedProgress = ratio
            }
        }
    }

    private var averageSeconds: Int {
        guard totalCount > 0 else { return 0 }
        return Int((duration / Double(totalCount)).rounded())
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(ResultPalette.track, lineWidth: 10)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(ResultPalette.progress, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(percent)")
                        .font(.resultRounded(26, .heavy))
                    Text("%")
                        .font(.resultRounded(13, .heavy))
                }
                .foregroundColor(ResultPalette.primaryText)
                Text("\(correctCount) / \(totalCount)")
                    .font(.resultRounded(11, .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 96, height: 96)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("正解率\(percent)パーセント、\(totalCount)問中\(correctCount)問正解")
    }

    private func chip(_ text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(.resultRounded(12, .heavy))
            .foregroundColor(foreground)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: Capsule())
    }

    static func clock(_ duration: TimeInterval) -> String {
        let seconds = max(0, Int(duration.rounded()))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Filter

enum ResultFilter: Hashable, CaseIterable {
    case incorrect, correct, all

    var title: String {
        switch self {
        case .incorrect: return "不正解"
        case .correct: return "正解"
        case .all: return "すべて"
        }
    }

    func includes(_ result: QuizResult) -> Bool {
        switch self {
        case .incorrect: return !result.isCorrect
        case .correct: return result.isCorrect
        case .all: return true
        }
    }
}

struct ResultFilterSegment: View {
    @Binding var selection: ResultFilter
    let counts: [ResultFilter: Int]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ResultFilter.allCases, id: \.self) { filter in
                let isSelected = selection == filter
                Button {
                    generateHapticFeedback()
                    withAnimation(.easeInOut(duration: 0.2)) { selection = filter }
                } label: {
                    Text("\(filter.title) \(counts[filter] ?? 0)")
                        .font(.resultRounded(14, isSelected ? .heavy : .bold))
                        .foregroundColor(isSelected ? ResultPalette.primaryText : .secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(ResultPalette.segmentSelected)
                                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(filter.title)、\(counts[filter] ?? 0)問")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(ResultPalette.segmentBackground, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

// MARK: - Question row

struct ResultQuestionRow: View {
    let number: Int
    let result: QuizResult
    @Binding var isExpanded: Bool
    @State private var showsExplanation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                generateHapticFeedback()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    ResultMarkBadge(isCorrect: result.isCorrect)
                    Text("Q\(number). \(result.question)")
                        .font(.resultRounded(14, .bold))
                        .foregroundColor(ResultPalette.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 3)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, 6)
                        .accessibilityHidden(true)
                }
                // 1行の問題でも上下の余白がそろうよう、行の中で縦中央に置く
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("問題\(number)、\(result.isCorrect ? "正解" : "不正解")。\(result.question)")
            .accessibilityHint(isExpanded ? "回答を閉じます" : "あなたの回答と正解を表示します")

            if isExpanded {
                HStack(alignment: .top, spacing: 8) {
                    answerBox(
                        title: "あなたの回答",
                        answer: result.userAnswer,
                        titleColor: result.isCorrect ? ResultPalette.correctText : ResultPalette.incorrectText,
                        background: result.isCorrect ? ResultPalette.correctAnswerBackground : ResultPalette.userAnswerBackground
                    )
                    answerBox(
                        title: "正解",
                        answer: result.correctAnswer,
                        titleColor: ResultPalette.correctText,
                        background: ResultPalette.correctAnswerBackground
                    )
                }

                if !result.explanation.isEmpty {
                    Button {
                        generateHapticFeedback()
                        withAnimation(.easeInOut(duration: 0.2)) { showsExplanation.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showsExplanation ? "解説を閉じる" : "解説を読む")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .heavy))
                                .rotationEffect(.degrees(showsExplanation ? 90 : 0))
                        }
                        .font(.resultRounded(13, .heavy))
                        .foregroundColor(ResultPalette.primaryButton)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if showsExplanation {
                        Text(result.explanation)
                            .font(.resultRounded(13, .medium))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func answerBox(title: String, answer: String, titleColor: Color, background: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.resultRounded(11, .heavy))
                .foregroundColor(titleColor)
            Text(answer)
                .font(.resultRounded(13, .semibold))
                .foregroundColor(ResultPalette.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct ResultMarkBadge: View {
    let isCorrect: Bool

    var body: some View {
        Image(systemName: isCorrect ? "circle" : "xmark")
            .font(.system(size: 11, weight: .black))
            .foregroundColor(isCorrect ? ResultPalette.correctText : ResultPalette.incorrectText)
            .frame(width: 26, height: 26)
            .background(isCorrect ? ResultPalette.correctBadge : ResultPalette.incorrectBadge, in: Circle())
            .accessibilityLabel(isCorrect ? "正解" : "不正解")
    }
}

// MARK: - Action bar

struct ResultBarButton {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
}

struct ResultActionBar: View {
    /// 左のアウトラインボタン。nil のときは primary を全幅で表示する
    let secondary: ResultBarButton?
    let primary: ResultBarButton
    /// 「ホームに戻る」リンク。nil のときは表示しない
    let onHome: (() -> Void)?

    var body: some View {
        VStack(spacing: 6) {
            if let secondary {
                GeometryReader { proxy in
                    let available = proxy.size.width - 10
                    HStack(spacing: 10) {
                        outlineButton(secondary)
                            .frame(width: available / 2.35)
                        filledButton(primary)
                            .frame(width: available * 1.35 / 2.35)
                    }
                }
                .frame(height: 54)
            } else {
                filledButton(primary)
                    .frame(height: 54)
            }

            if let onHome {
                Button {
                    generateHapticFeedback()
                    onHome()
                } label: {
                    Text("ホームに戻る")
                        .font(.resultRounded(14, .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, onHome == nil ? 12 : 0)
        .background(
            ResultPalette.card
                .overlay(alignment: .top) {
                    ResultPalette.barBorder.frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func label(_ button: ResultBarButton, subtitleColor: Color) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                if let systemImage = button.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .heavy))
                }
                Text(button.title)
                    .font(.resultRounded(15, .heavy))
            }
            if let subtitle = button.subtitle {
                Text(subtitle)
                    .font(.resultRounded(11, .bold))
                    .foregroundColor(subtitleColor)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private func outlineButton(_ button: ResultBarButton) -> some View {
        Button {
            generateHapticFeedback()
            button.action()
        } label: {
            label(button, subtitleColor: .secondary)
                .foregroundColor(ResultPalette.primaryText)
                .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(ResultPalette.outline, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private func filledButton(_ button: ResultBarButton) -> some View {
        Button {
            generateHapticFeedback()
            button.action()
        } label: {
            label(button, subtitleColor: .white.opacity(0.85))
                .foregroundColor(.white)
                .background(ResultPalette.primaryButton, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Level up

/// HP・攻撃力は AuthManager.updateStatsUponLevelUp と同じ式で計算する。
enum LevelUpStats {
    static func hp(at level: Int) -> Int { 100 + (level - 1) * 10 }
    static func attack(at level: Int) -> Int { 20 + (level - 1) * 2 }
}

enum LevelUpPalette {
    static let ink = Color(hex: "3A3326")
    static let card = ResultPalette.dynamic("FFFDF7", "2A261E")
    static let title = ResultPalette.dynamic("1F1A12", "FFF7E6")
    static let accent = ResultPalette.dynamic("B45309", "FBBF24")
    static let medal = Color(hex: "7C5CE6")
    static let gold = Color(hex: "FBBF24")
    static let statBackground = ResultPalette.dynamic("FFFFFF", "37322A")
    static let statBorder = ResultPalette.dynamic("E8DFCB", "4A4436")
    static let gain = ResultPalette.dynamic("1E7B34", "7DDB8E")
    static let barTrack = ResultPalette.dynamic("ECE6F9", "3A3350")
    static let hp = Color(hex: "E5484D")
    static let attack = Color(hex: "E07B39")
}

struct LevelUpRewardCard: View {
    let level: Int
    let previousLevel: Int
    let experience: Int
    /// アニメーションの段階（LevelUpModalView が進める）。プレビューでは最終状態を渡す
    var showsMedal = true
    var visibleRows = 2
    var expProgress: Double = 1
    var showsButton = true
    let onClose: () -> Void

    private var gainedLevels: Int { max(1, level - previousLevel) }
    private var baseLevel: Int { level - gainedLevels }
    private var nextLevelExperience: Int { max(1, level * 100) }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("LEVEL UP")
                    .font(.resultRounded(13, .heavy))
                    .tracking(3)
                    .foregroundColor(LevelUpPalette.accent)
                Text("レベル\(level)になった！")
                    .font(.resultRounded(24, .heavy))
                    .foregroundColor(LevelUpPalette.title)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 10) {
                statTile(
                    icon: "heart.fill", iconColor: LevelUpPalette.hp, title: "HP",
                    value: LevelUpStats.hp(at: level),
                    gain: LevelUpStats.hp(at: level) - LevelUpStats.hp(at: baseLevel)
                )
                .opacity(visibleRows >= 1 ? 1 : 0)
                .offset(y: visibleRows >= 1 ? 0 : 8)
                statTile(
                    icon: "bolt.fill", iconColor: LevelUpPalette.attack, title: "攻撃力",
                    value: LevelUpStats.attack(at: level),
                    gain: LevelUpStats.attack(at: level) - LevelUpStats.attack(at: baseLevel)
                )
                .opacity(visibleRows >= 2 ? 1 : 0)
                .offset(y: visibleRows >= 2 ? 0 : 8)
            }

            VStack(spacing: 6) {
                HStack {
                    Text("次のレベルまで")
                    Spacer()
                    Text("\(experience) / \(nextLevelExperience) EXP")
                        .monospacedDigit()
                }
                .font(.resultRounded(12, .bold))
                .foregroundColor(.secondary)

                GeometryReader { proxy in
                    let ratio = min(1, max(0, Double(experience) / Double(nextLevelExperience)))
                    ZStack(alignment: .leading) {
                        Capsule().fill(LevelUpPalette.barTrack)
                        Capsule()
                            .fill(LevelUpPalette.medal)
                            .frame(width: max(8, proxy.size.width * ratio * expProgress))
                    }
                }
                .frame(height: 8)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("次のレベルまで、\(nextLevelExperience)経験値のうち\(experience)")

            Button(action: onClose) {
                Text("戻る")
                    .font(.resultRounded(17, .heavy))
                    .foregroundColor(LevelUpPalette.ink)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LevelUpPalette.gold)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(LevelUpPalette.ink, lineWidth: 3)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LevelUpPalette.ink)
                            .offset(y: 4)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .opacity(showsButton ? 1 : 0)
            .offset(y: showsButton ? 0 : 10)
            .disabled(!showsButton)
        }
        .padding(.horizontal, 20)
        .padding(.top, 70)
        .padding(.bottom, 20)
        .frame(maxWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LevelUpPalette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(LevelUpPalette.ink, lineWidth: 3)
        )
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LevelUpPalette.ink)
                .offset(y: 6)
        )
        .overlay(alignment: .top) {
            medal
                .offset(y: -60)
                .scaleEffect(showsMedal ? 1 : 0.2)
                .opacity(showsMedal ? 1 : 0)
        }
        .padding(.top, 60)
    }

    private var medal: some View {
        ZStack {
            Circle().fill(LevelUpPalette.medal)
            Circle().strokeBorder(LevelUpPalette.gold, lineWidth: 5).padding(4)
            Circle().strokeBorder(LevelUpPalette.ink, lineWidth: 4)
            VStack(spacing: -6) {
                Text("Lv")
                    .font(.resultRounded(16, .heavy))
                Text("\(level)")
                    .font(.resultRounded(56, .black))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
        }
        .frame(width: 120, height: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("レベル\(level)")
    }

    private func statTile(icon: String, iconColor: Color, title: String, value: Int, gain: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.resultRounded(12, .heavy))
                    .foregroundColor(LevelUpPalette.title)
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(value)")
                    .font(.resultRounded(22, .heavy))
                    .foregroundColor(LevelUpPalette.title)
                Text("+\(gain)")
                    .font(.resultRounded(14, .heavy))
                    .foregroundColor(LevelUpPalette.gain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LevelUpPalette.statBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(LevelUpPalette.statBorder, lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value)、\(gain)アップ")
    }
}

// MARK: - Normal result content

/// 通常クイズ結果のスクロール部分。QuizResultView から状態と補助カードを受け取る
struct ResultReportContent<Supplements: View>: View {
    let results: [QuizResult]
    let duration: TimeInterval
    let experience: Int
    let coins: Int
    @ViewBuilder let supplements: () -> Supplements

    @State private var filter: ResultFilter
    @State private var expanded: Set<Int>

    init(
        results: [QuizResult],
        duration: TimeInterval,
        experience: Int,
        coins: Int,
        @ViewBuilder supplements: @escaping () -> Supplements
    ) {
        self.results = results
        self.duration = duration
        self.experience = experience
        self.coins = coins
        self.supplements = supplements
        let firstIncorrect = results.firstIndex { !$0.isCorrect }
        _filter = State(initialValue: firstIncorrect == nil ? .all : .incorrect)
        // 最初の不正解だけ開いておくと、何を間違えたかがすぐ分かる
        _expanded = State(initialValue: firstIncorrect.map { [$0] } ?? [])
    }

    private var correctCount: Int { results.filter(\.isCorrect).count }

    var body: some View {
        VStack(spacing: 12) {
            ResultScoreCard(
                correctCount: correctCount,
                totalCount: results.count,
                duration: duration,
                experience: experience,
                coins: coins
            )

            // TODO: QuizResult に分野（テクノロジ系のネットワーク等）を持たせたら「苦手：◯◯」カードを出す

            supplements()

            ResultFilterSegment(
                selection: $filter,
                counts: [
                    .incorrect: results.count - correctCount,
                    .correct: correctCount,
                    .all: results.count
                ]
            )
            .padding(.top, 4)

            LazyVStack(spacing: 8) {
                let visible = results.indices.filter { filter.includes(results[$0]) }
                if visible.isEmpty {
                    Text(filter == .incorrect ? "不正解の問題はありません" : "正解した問題はありません")
                        .font(.resultRounded(14, .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80)
                }
                ForEach(visible, id: \.self) { index in
                    ResultQuestionRow(
                        number: index + 1,
                        result: results[index],
                        isExpanded: Binding(
                            get: { expanded.contains(index) },
                            set: { isOpen in
                                if isOpen { expanded.insert(index) } else { expanded.remove(index) }
                            }
                        )
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        // 下部の固定バーに最後の行が隠れないようにする
        .padding(.bottom, 24)
    }
}

// MARK: - Previews

private enum ResultPreviewData {
    static let mixed: [QuizResult] = [
        QuizResult(question: "RAID5の特徴として正しいものはどれか", userAnswer: "ミラーリングのみ", correctAnswer: "パリティを分散記録", explanation: "RAID5はデータとパリティを複数のディスクに分散して記録します。", isCorrect: false),
        QuizResult(question: "OSの役割として適切なものはどれか", userAnswer: "資源の管理", correctAnswer: "資源の管理", explanation: "", isCorrect: true),
        QuizResult(question: "公開鍵暗号方式で、送信者が暗号化に使う鍵は", userAnswer: "送信者の秘密鍵", correctAnswer: "受信者の公開鍵", explanation: "受信者の公開鍵で暗号化し、受信者の秘密鍵で復号します。", isCorrect: false),
        QuizResult(question: "SLAとは何か", userAnswer: "サービスレベル合意書", correctAnswer: "サービスレベル合意書", explanation: "", isCorrect: true),
        QuizResult(question: "DNSの役割として適切なものはどれか", userAnswer: "IPアドレスの自動割当て", correctAnswer: "ドメイン名とIPアドレスの対応付け", explanation: "IPアドレスの自動割当てはDHCPの役割です。", isCorrect: false),
        QuizResult(question: "SQLのSELECT文の用途は", userAnswer: "データの検索", correctAnswer: "データの検索", explanation: "", isCorrect: true),
        QuizResult(question: "PDCAサイクルのCは何か", userAnswer: "Check", correctAnswer: "Check", explanation: "", isCorrect: true),
        QuizResult(question: "2進数1010を10進数にすると", userAnswer: "10", correctAnswer: "10", explanation: "", isCorrect: true),
        QuizResult(question: "ファイアウォールの主な役割は", userAnswer: "不正な通信の遮断", correctAnswer: "不正な通信の遮断", explanation: "", isCorrect: true),
        QuizResult(question: "クラウドのSaaSとは", userAnswer: "ソフトウェアの提供", correctAnswer: "ソフトウェアの提供", explanation: "", isCorrect: true)
    ]

    static let perfect: [QuizResult] = mixed.map {
        QuizResult(question: $0.question, userAnswer: $0.correctAnswer, correctAnswer: $0.correctAnswer, explanation: $0.explanation, isCorrect: true)
    }
}

private struct ResultReportPreview: View {
    let results: [QuizResult]

    private var incorrectCount: Int { results.filter { !$0.isCorrect }.count }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("ITパスポート・テクノロジ・結果")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                HStack {
                    Image(systemName: "chevron.left").frame(width: 44, height: 44)
                    Spacer()
                    Image(systemName: "square.and.arrow.up").frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 4)
            ScrollView {
                ResultReportContent(results: results, duration: 168, experience: 70, coins: 35) {
                    EmptyView()
                }
            }
        }
        .background(ResultPalette.screen.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if incorrectCount > 0 {
                ResultActionBar(
                    secondary: ResultBarButton(title: "別の問題で", subtitle: "新しい問題", action: {}),
                    primary: ResultBarButton(title: "不正解の\(incorrectCount)問を解き直す", subtitle: "プレミアム限定", systemImage: "crown.fill", action: {}),
                    onHome: {}
                )
            } else {
                ResultActionBar(
                    secondary: nil,
                    primary: ResultBarButton(title: "別の問題で", subtitle: "新しい問題", action: {}),
                    onHome: {}
                )
            }
        }
    }
}

private struct LevelUpPreview: View {
    let previousLevel: Int
    let level: Int

    var body: some View {
        ZStack {
            ResultPalette.screen.ignoresSafeArea()
            Color(red: 18 / 255, green: 16 / 255, blue: 34 / 255).opacity(0.62).ignoresSafeArea()
            LevelUpRewardCard(level: level, previousLevel: previousLevel, experience: 0, onClose: {})
                .padding(.horizontal, 24)
        }
    }
}

#Preview("7/10 不正解あり") {
    ResultReportPreview(results: ResultPreviewData.mixed)
}

#Preview("10/10 全問正解") {
    ResultReportPreview(results: ResultPreviewData.perfect)
}

#Preview("Lv4→5") {
    LevelUpPreview(previousLevel: 4, level: 5)
}

#Preview("Lv5→6") {
    LevelUpPreview(previousLevel: 5, level: 6)
}

#Preview("Lv3→5 2レベルアップ・ダーク") {
    LevelUpPreview(previousLevel: 3, level: 5)
        .preferredColorScheme(.dark)
}
