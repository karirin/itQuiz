import SwiftUI

extension AccuracyExam {
    var accent: Color {
        switch self {
        case .it: return .socialDynamic(light: Color(hex: "087F82"), dark: Color(hex: "5DD8CD"))
        case .info: return .socialDynamic(light: Color(hex: "3568C4"), dark: Color(hex: "90B8FF"))
        case .applied: return .socialDynamic(light: Color(hex: "AA3B69"), dark: Color(hex: "FFAFCD"))
        }
    }

    var learningGradient: LinearGradient {
        switch self {
        case .it: return QuizColors.itPassport
        case .info: return QuizColors.basicInfo
        case .applied: return QuizColors.appliedInfo
        }
    }

}

struct AccuracyRecord: Identifiable {
    let area: AccuracyArea
    let data: QuizData

    var id: String { area.id }
    var answerCount: Int { max(0, data.answer) }
    var correctCount: Int { min(answerCount, max(0, data.correct)) }
    var hasAnswers: Bool { answerCount > 0 }
    var rate: Double { hasAnswers ? Double(correctCount) / Double(answerCount) : 0 }
    var percentage: String { hasAnswers ? String(format: "%.0f%%", rate * 100) : "未回答" }
}

struct PentagonManagerView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var selectedExam: AccuracyExam = .it
    @State private var quizData: [String: QuizData] = [:]
    @State private var loadState: LoadState = .loading
    @State private var requestID = UUID()
    @State private var loadedUserID: String?
    @State private var refreshFailed = false

    private enum LoadState {
        case loading, loaded, failed, signedOut
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("試験を選択", selection: $selectedExam) {
                ForEach(AccuracyExam.allCases) { exam in
                    Text(exam.title).tag(exam)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .accessibilityIdentifier("accuracy.examPicker")

            ScrollView {
                VStack(spacing: 12) {
                    switch loadState {
                    case .loading:
                        SlimeCardLoadingView(message: "学習記録を読み込み中")
                            .padding(.top, 40)
                    case .loaded:
                        if refreshFailed {
                            Label("更新できませんでした。下に引いて再試行できます。", systemImage: "wifi.exclamationmark")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        AccuracyDashboard(exam: selectedExam, quizData: quizData)
                            .id(selectedExam)
                    case .failed:
                        SlimeErrorView(
                            title: "学習記録を読み込めませんでした",
                            message: "通信状況を確認して、もう一度お試しください。"
                        ) {
                            Task { await loadData() }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.top, 16)
                    case .signedOut:
                        stateMessage(
                            symbol: "person.crop.circle",
                            title: "学習記録を準備しています",
                            message: "ユーザー情報の取得後に、正答率を表示します。"
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .refreshable { await loadData() }
        }
        .background(Color(.systemGroupedBackground))
        .tint(selectedExam.accent)
        .task(id: authManager.currentUserId) { await loadData() }
    }

    private func stateMessage(symbol: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(selectedExam.accent)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    @MainActor
    private func loadData() async {
        let currentRequest = UUID()
        requestID = currentRequest
        refreshFailed = false
        guard let userID = authManager.currentUserId, !userID.isEmpty else {
            quizData = [:]
            loadedUserID = nil
            loadState = .signedOut
            return
        }

        let hasCurrentData = loadedUserID == userID && loadState == .loaded
        if !hasCurrentData {
            quizData = [:]
            loadState = .loading
        }
        do {
            let data = try await RateManager.shared.fetchAccuracyData(userId: userID)
            guard !Task.isCancelled, requestID == currentRequest,
                  authManager.currentUserId == userID else { return }
            quizData = data
            loadedUserID = userID
            loadState = .loaded
        } catch {
            guard !Task.isCancelled, requestID == currentRequest,
                  authManager.currentUserId == userID else { return }
            if hasCurrentData {
                refreshFailed = true
            } else {
                loadState = .failed
            }
        }
    }
}

// Both the chart and the list use these same records, including unanswered areas.
struct AccuracyDashboard: View {
    let exam: AccuracyExam
    let quizData: [String: QuizData]
    var periodTitle: String = "累計"
    var showsLearningHint: Bool = true
    var onPractice: ((AccuracyArea) -> Void)? = nil
    @State private var selectedArea: AccuracyArea = .basic
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var records: [AccuracyRecord] {
        AccuracyArea.allCases.map { area in
            AccuracyRecord(area: area, data: quizData[exam.key(for: area)] ?? QuizData(answer: 0, correct: 0))
        }
    }

    private var totalAnswers: Int { records.reduce(0) { $0 + $1.answerCount } }
    private var totalCorrect: Int { records.reduce(0) { $0 + $1.correctCount } }
    private var overallRate: Double { totalAnswers > 0 ? Double(totalCorrect) / Double(totalAnswers) : 0 }
    private var selectedRecord: AccuracyRecord { records.first { $0.area == selectedArea } ?? records[0] }
    private var weakestRecord: AccuracyRecord? { records.filter(\.hasAnswers).min { $0.rate < $1.rate } }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            summaryCard
            chartCard
            categoryCard
            if showsLearningHint { learningHint }
            Text("正答率は表示期間の正解数 ÷ 回答数で計算しています。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { selectedArea = weakestRecord?.area ?? .basic }
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(exam.title).font(.subheadline.weight(.semibold))
                    Text(periodTitle)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(exam.accent.opacity(0.1), in: Capsule())
                }
                .foregroundStyle(exam.accent)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(totalAnswers > 0 ? String(format: "%.1f", overallRate * 100) : "—")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    if totalAnswers > 0 {
                        Text("%").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                    }
                    Text("正答率").font(.caption).foregroundStyle(.secondary)
                }
                .minimumScaleFactor(0.7)
                .lineLimit(1)

                Text(totalAnswers > 0 ? "\(totalAnswers.formatted())問回答 · \(totalCorrect.formatted())問正解" : "問題を解くと、学習記録が表示されます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if !dynamicTypeSize.isAccessibilitySize {
                ZStack {
                    Circle().stroke(exam.accent.opacity(0.1), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: overallRate)
                        .stroke(exam.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(exam.accent)
                }
                .frame(width: 68, height: 68)
                .accessibilityHidden(true)
            }
        }
        .padding(20)
        .learningModeGlassSurface(gradient: exam.learningGradient)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("accuracy.summary")
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("得意・苦手のバランス").font(.headline)
                    Text(dynamicTypeSize.isAccessibilitySize ? "分野別の記録で詳しく確認" : "分野をタップして記録を確認")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("0–100%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            AccuracyRadarChart(records: records, accent: exam.accent, selectedArea: $selectedArea)
                .frame(height: dynamicTypeSize.isAccessibilitySize ? nil : 268)

            HStack(spacing: 10) {
                Image(systemName: selectedArea.symbol)
                    .foregroundStyle(exam.accent)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedArea.title).font(.subheadline.weight(.semibold))
                    Text(selectedRecord.hasAnswers
                         ? "\(selectedRecord.answerCount.formatted())問回答 · \(selectedRecord.correctCount.formatted())問正解"
                         : "この分野の学習記録はまだありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Text(selectedRecord.hasAnswers ? selectedRecord.percentage : "—")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(exam.accent)
            }
            .padding(14)
            .background(exam.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("accuracy.selectedRecord")

            if let onPractice {
                Button { onPractice(selectedArea) } label: {
                    Label("\(selectedArea.title)を5問解く", systemImage: "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("analysis.areaPractice")
            }

            if records.contains(where: { !$0.hasAnswers }) {
                Text("未回答の分野は、グラフ上では中心に表示されます。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .learningModeGlassSurface(gradient: exam.learningGradient)
    }

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("分野別の記録").font(.headline)
                Spacer()
                Text("\(records.filter(\.hasAnswers).count) / \(records.count) 分野を学習")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(records) { record in
                Button {
                    selectedArea = record.area
                } label: {
                    AccuracyCategoryRow(record: record, accent: exam.accent, isSelected: selectedArea == record.area)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(record.area.title)、\(record.hasAnswers ? "正答率" + record.percentage : "未回答")、\(record.answerCount)問回答")
                .accessibilityAddTraits(selectedArea == record.area ? [.isSelected] : [])
                .accessibilityIdentifier("accuracy.area.\(record.area.id)")
            }
        }
        .padding(20)
        .learningModeGlassSurface(gradient: exam.learningGradient)
    }

    private var learningHint: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(exam.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text("次の学習のヒント").font(.subheadline.weight(.semibold))
                Text(hintText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(exam.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
    }

    private var hintText: String {
        let answered = records.filter(\.hasAnswers)
        if totalAnswers == 0 {
            return "まずは気になる分野から問題を解いてみましょう。学習するほど、得意・苦手が見えてきます。"
        }
        if totalCorrect == 0 {
            return "間違えた問題の解説を読み返して、少しずつ理解を深めましょう。"
        }
        if let unanswered = records.first(where: { !$0.hasAnswers }) {
            return "\(unanswered.area.title)にも挑戦して、得意な分野を見つけましょう。"
        }
        if let weakest = weakestRecord, let best = answered.max(by: { $0.rate < $1.rate }), weakest.rate < best.rate {
            return "\(weakest.area.title)を復習すると、全体のバランスを伸ばせそうです。回答数も目安に、少しずつ取り組みましょう。"
        }
        return "各分野にバランスよく取り組めています。問題演習を続けて、理解を深めましょう。"
    }
}

private struct AccuracyCategoryRow: View {
    let record: AccuracyRecord
    let accent: Color
    let isSelected: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.area.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 8) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 6) { title; percentage }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        title
                        Spacer(minLength: 4)
                        percentage
                    }
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(accent.opacity(0.1))
                        Capsule().fill(accent)
                            .frame(width: geometry.size.width * record.rate)
                    }
                }
                .frame(height: 5)
                .accessibilityHidden(true)
                Text(record.hasAnswers ? "\(record.answerCount.formatted())問回答 · \(record.correctCount.formatted())問正解" : "学習すると正答率を表示")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? accent : Color.secondary.opacity(0.3))
                .font(.system(size: 15))
                .accessibilityHidden(true)
        }
        .padding(12)
        .background(isSelected ? accent.opacity(0.05) : Color.clear, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? accent.opacity(0.3) : Color(.separator).opacity(0.25), lineWidth: 1))
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }

    private var title: some View {
        Text(record.area.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var percentage: some View {
        Text(record.percentage)
            .font(record.hasAnswers ? .subheadline.weight(.bold) : .caption)
            .foregroundStyle(record.hasAnswers ? accent : Color.secondary)
            .monospacedDigit()
    }
}

private struct AccuracyRadarChart: View {
    let records: [AccuracyRecord]
    let accent: Color
    @Binding var selectedArea: AccuracyArea
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // The list offers the same interaction without tightly positioned labels.
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 12) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.largeTitle)
                    .foregroundStyle(accent)
                Text("各分野の正答率は、下の分野別の記録で確認できます。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        } else {
            GeometryReader { geometry in
                let size = geometry.size
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = max(1, min(size.width / 2 - 76, size.height / 2 - 56))

                ZStack {
                    ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                        radarPath(center: center, radius: radius, values: Array(repeating: scale, count: 4))
                            .stroke(Color(.separator).opacity(0.45), lineWidth: 1)
                        Text("\(Int(scale * 100))")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .position(x: center.x + 12, y: center.y - radius * scale + 5)
                            .accessibilityHidden(true)
                    }

                    Path { path in
                        for index in records.indices {
                            path.move(to: center)
                            path.addLine(to: point(index: index, rate: 1, center: center, radius: radius))
                        }
                    }
                    .stroke(Color(.separator).opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))

                    if records.contains(where: \.hasAnswers) {
                        radarPath(center: center, radius: radius, values: records.map(\.rate))
                            .fill(LinearGradient(colors: [accent.opacity(0.3), accent.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                        radarPath(center: center, radius: radius, values: records.map(\.rate))
                            .stroke(accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            if record.hasAnswers {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: selectedArea == record.area ? 11 : 7,
                                           height: selectedArea == record.area ? 11 : 7)
                                    .overlay(Circle().stroke(accent, lineWidth: 2.5))
                                    .position(point(index: index, rate: record.rate, center: center, radius: radius))
                                    .accessibilityHidden(true)
                            }
                        }
                    } else {
                        Text("記録なし")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                            .position(center)
                    }

                    ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                        Button { selectedArea = record.area } label: {
                            VStack(spacing: 4) {
                                Text(record.area.title)
                                    .font(.system(size: 11, weight: .semibold))
                                    .lineLimit(1)
                                Text(record.percentage)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                            }
                            .foregroundStyle(selectedArea == record.area ? accent : Color.secondary)
                            .frame(width: 86, height: 48)
                            .background(selectedArea == record.area ? accent.opacity(0.08) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 11))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .position(labelPosition(index: index, size: size))
                        .accessibilityLabel("\(record.area.title)、\(record.hasAnswers ? "正答率" + record.percentage : "未回答")、詳細を表示")
                        .accessibilityAddTraits(selectedArea == record.area ? [.isSelected] : [])
                        .accessibilityIdentifier("accuracy.chart.\(record.area.id)")
                    }
                }
            }
        }
    }

    private func point(index: Int, rate: Double, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = Double(index) * .pi / 2 - .pi / 2
        return CGPoint(x: center.x + radius * rate * cos(angle), y: center.y + radius * rate * sin(angle))
    }

    private func radarPath(center: CGPoint, radius: CGFloat, values: [Double]) -> Path {
        Path { path in
            for (index, value) in values.enumerated() {
                let vertex = point(index: index, rate: value, center: center, radius: radius)
                if index == 0 { path.move(to: vertex) } else { path.addLine(to: vertex) }
            }
            path.closeSubpath()
        }
    }

    private func labelPosition(index: Int, size: CGSize) -> CGPoint {
        switch index {
        case 0: return CGPoint(x: size.width / 2, y: 25)
        case 1: return CGPoint(x: size.width - 43, y: size.height / 2)
        case 2: return CGPoint(x: size.width / 2, y: size.height - 25)
        default: return CGPoint(x: 43, y: size.height / 2)
        }
    }
}

#if DEBUG
private let accuracyPreviewData: [String: QuizData] = [
    "itBasic": QuizData(answer: 120, correct: 102),
    "itStrategy": QuizData(answer: 80, correct: 52),
    "itTechnology": QuizData(answer: 150, correct: 111),
    "itManagement": QuizData(answer: 50, correct: 44)
]

#Preview("正答率・学習済み") {
    ScrollView { AccuracyDashboard(exam: .it, quizData: accuracyPreviewData).padding(20) }
        .background(Color(.systemGroupedBackground))
}

#Preview("正答率・未回答") {
    ScrollView { AccuracyDashboard(exam: .info, quizData: [:]).padding(20) }
        .background(Color(.systemGroupedBackground))
}

#Preview("正答率・一部分野のみ・ダーク") {
    ScrollView {
        AccuracyDashboard(exam: .applied, quizData: ["appliedBasic": QuizData(answer: 10, correct: 7)]).padding(20)
    }
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
#endif
