import SwiftUI
import Charts

struct AnalysisCard<Content: View>: View {
    var gradient: LinearGradient = QuizColors.itPassport
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 16, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .learningModeGlassSurface(gradient: gradient)
    }
}

struct AnalysisRecentAccuracyCard: View {
    let exam: AccuracyExam
    let history: LearningHistory
    let now: Date

    private var count: LearningCount {
        history.overallCount(exam: exam, period: .week, now: now)
    }

    var body: some View {
        AnalysisCard(gradient: exam.learningGradient) {
            Label("直近7日の正答率", systemImage: "chart.pie.fill")
                .font(.headline)
            if let rate = count.rate {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(Int((rate * 100).rounded()))")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("%")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Text("\(count.answers)問中\(count.correct)問正解")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(exam.accent)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("analysis.recentAccuracy")
                ProgressView(value: rate)
                    .tint(exam.accent)
                    .accessibilityHidden(true)
                if let change = history.change(exam: exam, period: .week, now: now) {
                    // Match the arrow and zero state to the displayed precision.
                    let roundedChange = (change * 10).rounded() / 10
                    Label(roundedChange == 0 ? "前の7日間と同じ正答率" : String(format: "前の7日間より %+.1fポイント", roundedChange),
                          systemImage: roundedChange > 0 ? "arrow.up.right" : roundedChange < 0 ? "arrow.down.right" : "arrow.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(roundedChange > 0 ? exam.accent : Color.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(exam.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("analysis.weeklyChange")
                } else {
                    Text("前の7日間との比較は、両期間の記録が揃い、それぞれ10問以上になると表示します。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("問題を解くと記録されます")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(exam.accent)
                Text("\(exam.title)の演習に挑戦して、最近の正答率を確認しましょう。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("\(exam.title)の全分野の演習を集計しています。復習は含みません。日付付きで記録された回答が対象です。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct AnalysisInsightPreviewCard: View {
    let exam: AccuracyExam
    let recommendation: LearningRecommendation
    let source: String
    let onUpgrade: () -> Void

    private var headline: String {
        switch recommendation.reason {
        case .unexplored: return "まだ解いていない分野に挑戦しよう"
        case .sampling: return "もう少し解いて、分析を充実させよう"
        case .weakness: return "次に伸ばしたい分野"
        case .balanced: return "バランスよく学べています"
        }
    }

    private var detail: String {
        switch recommendation.reason {
        case .unexplored: return "この分野はまだ未回答。問題を解くと、正答率がここに表示されます。"
        case .sampling: return "この分野はまだ回答が少なめ。得意・苦手を見つけるために、まずは10問を目指しましょう。"
        case .weakness: return "ほかの分野より正答率が低め。この分野から取り組んでみましょう。"
        case .balanced: return "分野ごとの正答率に大きな差はありません。次はこの分野で理解を深めましょう。"
        }
    }

    var body: some View {
        AnalysisCard(gradient: exam.learningGradient) {
            HStack(alignment: .top, spacing: 8) {
                Label("あなたの分析", systemImage: "sparkles")
                    .font(.headline)
                Spacer(minLength: 0)
                Text("一部公開")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(exam.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(exam.accent.opacity(0.1), in: Capsule())
                    .fixedSize()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(source).font(.caption).foregroundStyle(.secondary)
                Text(headline)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Label(recommendation.area.title, systemImage: recommendation.area.symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(exam.accent)
                    .fixedSize(horizontal: false, vertical: true)

                if let rate = recommendation.count.rate {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(Int((rate * 100).rounded()))%")
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundStyle(exam.accent)
                        Text("正答率 · \(recommendation.count.answers)問回答")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("正答率\(Int((rate * 100).rounded()))パーセント、\(recommendation.count.answers)問回答")
                    .accessibilityIdentifier("analysis.previewAccuracy")
                    ProgressView(value: rate)
                        .tint(exam.accent)
                        .accessibilityHidden(true)
                }

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("analysis.insightPreview")

            Divider()

            // Show the shape of the remaining analysis without inventing scores.
            VStack(spacing: 10) {
                ForEach(AccuracyArea.allCases.filter { $0 != recommendation.area }) { area in
                    HStack {
                        Label(area.title, systemImage: area.symbol)
                        Spacer(minLength: 8)
                        Image(systemName: "lock.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .mask(LinearGradient(colors: [.black, .black.opacity(0.2)], startPoint: .top, endPoint: .bottom))
            .accessibilityHidden(true)

            Label("全分野の比較・おすすめ演習", systemImage: "lock.fill")
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onUpgrade) {
                Text("プレミアムで分析の続きを見る")
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(Color(hex: "087F82"), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .accessibilityHint("プレミアムプランの案内を開きます")
            .accessibilityIdentifier("analysis.upgrade")
        }
    }
}

struct AnalysisRecommendationCard: View {
    let recommendation: LearningRecommendation
    let source: String
    let accent: Color
    let gradient: LinearGradient
    let action: () -> Void

    private var headline: String {
        switch recommendation.reason {
        case .unexplored: return "\(recommendation.area.title)をはじめよう"
        case .sampling: return "\(recommendation.area.title)をもう少し"
        case .weakness: return "\(recommendation.area.title)を重点的に"
        case .balanced: return "バランスよく学べています"
        }
    }
    private var detail: String {
        switch recommendation.reason {
        case .unexplored: return "この分野はまだ未回答。まずは5問に挑戦して、理解度を確かめましょう。"
        case .sampling: return "現在\(recommendation.count.answers)問回答。得意・苦手を見つけるために、もう少し解いてみましょう。"
        case .weakness: return "正答率\(Int((recommendation.count.rate ?? 0) * 100))%・\(recommendation.count.answers)問回答。ほかの分野より正答率が低めなので、優先して取り組みましょう。"
        case .balanced: return "各分野に大きな偏りはありません。次の5問で理解を深めましょう。"
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("今日のおすすめ", systemImage: "sparkles")
                    .font(.caption.weight(.bold)).foregroundStyle(accent)
                Spacer(minLength: 4)
                Text(source).font(.caption2).foregroundStyle(.secondary)
            }
            Text(headline).font(.title3.weight(.bold)).fixedSize(horizontal: false, vertical: true)
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: action) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("\(recommendation.area.title)を5問解く")
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 30, height: 30)
                        .background(.background.opacity(0.5), in: Circle())
                }
                .font(.subheadline.weight(.semibold))
                .padding(16).frame(maxWidth: .infinity)
                .foregroundStyle(accent)
                .background(gradient.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityIdentifier("analysis.recommendedPractice")
        }
        .padding(20)
        .learningModeGlassSurface(gradient: gradient)
    }
}

struct AnalysisWeekCard: View {
    let exam: AccuracyExam
    let history: LearningHistory
    let now: Date
    @AppStorage private var weeklyGoal: Int

    init(exam: AccuracyExam, history: LearningHistory, userID: String, now: Date) {
        self.exam = exam
        self.history = history
        self.now = now
        _weeklyGoal = AppStorage(wrappedValue: 50, "analysis.weeklyGoal.\(userID).\(exam.rawValue)")
    }
    private var days: [LearningDay] {
        let calendar = LearningDates.calendar()
        let start = LearningDates.weekStart(now, calendar: calendar)
        let count = calendar.dateComponents([.day], from: start, to: calendar.startOfDay(for: now)).day! + 1
        return history.activity(exam: exam, dates: LearningDates.days(ending: now, count: count, calendar: calendar))
    }
    private var answers: Int { days.reduce(0) { $0 + $1.count } }
    private var goal: Int { max(1, weeklyGoal) }

    var body: some View {
        AnalysisCard(gradient: exam.learningGradient) {
            HStack {
                Text("今週の積み重ね").font(.headline)
                Spacer()
                Text("月曜から今日").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 24) {
                AnalysisMetric(value: "\(answers)", unit: "問", title: "回答数", accent: exam.accent)
                AnalysisMetric(value: "\(days.filter { $0.count > 0 }.count)", unit: "日", title: "学習した日", accent: exam.accent)
            }
            Divider()
            HStack {
                Text(answers >= goal ? "今週の目標を達成しました！" : "目標まであと\(goal - answers)問")
                    .font(.subheadline.weight(.semibold))
                Spacer(minLength: 8)
                Menu {
                    ForEach([25, 50, 100, 200], id: \.self) { target in
                        Button {
                            weeklyGoal = target
                        } label: {
                            if weeklyGoal == target { Label("週\(target)問", systemImage: "checkmark") }
                            else { Text("週\(target)問") }
                        }
                    }
                } label: {
                    Label("週\(goal)問", systemImage: "pencil")
                        .font(.caption.weight(.semibold))
                }
                .accessibilityLabel("週間目標を変更、現在\(goal)問")
                .accessibilityIdentifier("analysis.weeklyGoal")
            }
            ProgressView(value: Double(min(answers, goal)), total: Double(goal)).tint(exam.accent)
                .accessibilityLabel("週間目標").accessibilityValue("\(goal)問中\(answers)問")
            Text("\(exam.title)の演習・復習を集計しています。")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }
}

private struct AnalysisMetric: View {
    let value: String
    let unit: String
    let title: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.system(size: 30, weight: .bold, design: .rounded)).monospacedDigit()
                Text(unit).font(.caption)
            }
            .foregroundStyle(accent)
            .lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct AnalysisReviewCard: View {
    let pendingCount: Int?
    let correctCount: Int
    let failed: Bool
    let accent: Color
    let gradient: LinearGradient
    let onReview: () -> Void
    let onRetry: () -> Void

    var body: some View {
        AnalysisCard(gradient: gradient) {
            Label("復習の成果", systemImage: "arrow.counterclockwise.circle.fill")
                .font(.headline)
            HStack(spacing: 24) {
                AnalysisMetric(value: pendingCount.map(String.init) ?? "—", unit: "問", title: "復習待ち", accent: accent)
                AnalysisMetric(value: "\(correctCount)", unit: "問", title: "復習で正解（累計）", accent: accent)
            }
            if failed {
                Text("復習対象を読み込めませんでした。")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button("再読み込み", action: onRetry).font(.subheadline.weight(.semibold))
            } else if let pendingCount {
                if pendingCount > 0 {
                    Button(action: onReview) {
                        Label("復習を\(min(5, pendingCount))問解く", systemImage: "play.fill")
                            .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("analysis.reviewPractice")
                } else {
                    Label("復習待ちの問題はありません", systemImage: "checkmark.circle")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            } else {
                SlimeInlineLoadingView(message: "復習対象を確認中")
            }
            Text("正解数は復習で正解した回答の累計です。同じ問題の解き直しも含みます。")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }
}

struct AnalysisActivityCard: View {
    let exam: AccuracyExam
    let history: LearningHistory
    let now: Date
    @State private var monthOffset = 0
    @State private var selectedDate: Date?
    private let calendar = LearningDates.calendar()

    private var month: Date { calendar.date(byAdding: .month, value: monthOffset, to: now)! }
    private var monthStart: Date { calendar.date(from: calendar.dateComponents([.year, .month], from: month))! }
    private var monthDays: [LearningDay] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let dates = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: monthStart) }
        return history.activity(exam: exam, dates: dates, calendar: calendar)
    }
    private var offset: Int { (calendar.component(.weekday, from: monthStart) + 5) % 7 }
    private var visibleDays: [LearningDay] { monthDays.filter { $0.date <= now } }
    private var selected: LearningDay? { monthDays.first { $0.date == selectedDate } }

    var body: some View {
        AnalysisCard(gradient: exam.learningGradient) {
            Text("学習カレンダー").font(.headline)
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left").frame(width: 44, height: 44)
                }
                .accessibilityLabel("前の月").accessibilityIdentifier("analysis.previousMonth")
                Spacer()
                Text(month, format: .dateTime.year().month(.wide)).font(.subheadline.weight(.semibold))
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 44, height: 44)
                }
                .disabled(monthOffset >= 0)
                .accessibilityLabel("次の月").accessibilityIdentifier("analysis.nextMonth")
            }
            Text("\(visibleDays.reduce(0) { $0 + $1.count })問回答 · \(visibleDays.filter { $0.count > 0 }.count)日学習")
                .font(.subheadline.weight(.semibold)).foregroundStyle(exam.accent)

            Chart(visibleDays) { day in
                BarMark(x: .value("日付", day.date, unit: .day), y: .value("回答数", day.count))
                    .foregroundStyle(exam.accent.gradient).cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis { AxisMarks(position: .leading) }
            .frame(height: 130)
            .accessibilityLabel("この月の日別回答数。各日の記録は下のカレンダーで確認できます。")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 7) {
                ForEach(["月", "火", "水", "木", "金", "土", "日"], id: \.self) { day in
                    Text(day).font(.caption2).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
                ForEach(0..<offset, id: \.self) { _ in Color.clear.frame(height: 34).accessibilityHidden(true) }
                ForEach(monthDays) { day in
                    Button { selectedDate = day.date } label: {
                        Text("\(calendar.component(.day, from: day.date))")
                            .font(.caption.weight(day.count > 0 ? .bold : .regular))
                            .frame(maxWidth: .infinity).frame(minHeight: 34)
                            .foregroundStyle(day.count > 0 ? exam.accent : Color.secondary)
                            .background(day.count > 0 ? exam.accent.opacity(min(0.35, 0.08 + Double(day.count) / 100)) : Color(.tertiarySystemGroupedBackground),
                                        in: RoundedRectangle(cornerRadius: 7))
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(selectedDate == day.date ? exam.accent : .clear, lineWidth: 2))
                            .opacity(day.date > now ? 0.3 : 1)
                    }
                    .buttonStyle(.plain).disabled(day.date > now)
                    .accessibilityLabel("\(day.date.formatted(.dateTime.month().day()))、\(day.count)問回答")
                }
            }
            if let selected {
                Text("\(selected.date.formatted(.dateTime.month().day()))：\(selected.count)問回答")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(exam.accent)
            } else {
                Text("日付をタップすると、その日の回答数を確認できます。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func changeMonth(_ value: Int) {
        monthOffset = min(0, monthOffset + value)
        selectedDate = nil
    }
}
