import SwiftUI

/// The theme's explanation, the original missed question, and the single next action.
struct ThemeIntroductionContent: View {
    let topic: WeaknessCourseTopic
    let progress: CourseProgress?
    let canAccess: Bool
    let hasActiveSession: Bool
    let subscribed: Bool
    let freeClaimTopicID: String?
    let subscriptionResolved: Bool
    let startTitle: String
    let onStart: () -> Void
    let onUnlock: () -> Void
    let onClose: () -> Void
    var now = Date()

    private var isMastered: Bool { progress?.stage == .mastered }
    private var isDue: Bool { progress?.isDue(at: now) == true }
    private var checkupNumber: Int { (progress?.confirmedCount ?? 0) + 1 }
    private var waitingDate: Date? {
        guard progress?.stage == .waiting, let date = progress?.nextReviewAt, date > now else { return nil }
        return date
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statusCard
                lessonCard
                if let original = progress?.sourceQuestion, original.isValid { originalCard(original) }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(RecoveryStyle.background)
        .safeAreaInset(edge: .bottom) { footer }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RecoveryIconTile(symbol: topic.symbol, tint: canAccess ? .theme : .neutral, size: 52)
                RecoveryTagRow(tags: tags)
            }
            Text(topic.title).font(.largeTitle.bold()).foregroundStyle(RecoveryStyle.text)
                .accessibilityAddTraits(.isHeader)
            RecoveryStepFlow(steps: ["説明を読む", "3問練習", "翌日おさらい", "3日後にもう一度", "マスター"], tint: .theme)
        }
    }

    private var tags: [RecoveryTag] {
        var tags: [RecoveryTag] = [.theme]
        if !canAccess { tags.append(.premium) }
        else if isMastered { tags.append(RecoveryTag(text: "マスター", icon: "checkmark.seal.fill", tint: .done)) }
        else if hasActiveSession { tags.append(RecoveryTag(text: "途中で中断中", icon: "pause.circle", tint: .neutral)) }
        else if isDue { tags.append(RecoveryTag(text: "今日：おさらい\(checkupNumber)", icon: "calendar", tint: .theme)) }
        if canAccess && !subscribed && freeClaimTopicID == topic.id {
            tags.append(RecoveryTag(text: "無料で学習中", tint: .done))
        }
        return tags
    }

    // MARK: Status

    @ViewBuilder
    private var statusCard: some View {
        if !canAccess {
            RecoveryCard(background: RecoveryTint.premium.tagBackground.opacity(0.5)) {
                Label("このテーマはプレミアムで学べます", systemImage: "crown.fill")
                    .font(.headline).foregroundStyle(RecoveryTint.premium.tagText)
                Text("無料で学べるのは、最初に始めた1テーマです。プレミアムなら「\(topic.title)」の3問の練習と、日を空けたおさらいまで利用できます。")
                    .font(.subheadline).foregroundStyle(RecoveryStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else if isMastered {
            statusRow(icon: "rosette", tint: .gold, title: "マスターしました",
                      detail: "日を空けた2回のおさらいに正解しました。説明はいつでも読み返せます。")
        } else if let date = waitingDate {
            RecoveryCard {
                HStack(spacing: 12) {
                    RecoveryIconTile(symbol: "calendar", tint: .theme)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("次のおさらい（\(checkupNumber)回目）").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text("\(date.formatted(.dateTime.month(.defaultDigits).day().weekday(.short)))（\(relativeDay(date))）に、苦手克服のホームから2問に挑戦できます")
                            .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                ThemeStepProgress(checkupNumber: checkupNumber, currentPrefix: "次")
            }
        } else if isDue {
            RecoveryCard(highlight: .theme) {
                HStack(spacing: 12) {
                    RecoveryIconTile(symbol: "calendar", tint: .theme)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今日は\(checkupNumber)回目のおさらいの日").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text("説明を読み返してから、別の\(topic.checks.count)問で覚えているか確かめます。")
                            .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                ThemeStepProgress(checkupNumber: checkupNumber)
            }
        }
    }

    private func statusRow(icon: String, tint: RecoveryTint, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            RecoveryIconTile(symbol: icon, tint: tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(RecoveryStyle.text)
                Text(detail).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "E8B85A"), lineWidth: 2))
        .accessibilityElement(children: .combine)
    }

    // MARK: Lesson

    private var lessonCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            RecoverySectionHeader(title: "説明")
            Text(topic.lesson)
                .font(.body).lineSpacing(7).foregroundStyle(RecoveryStyle.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(RecoveryStyle.cardBorder))
        }
    }

    private func originalCard(_ original: CourseQuestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RecoverySectionHeader(title: "まちがえた問題をふりかえる")
            RecoveryCard {
                RecoveryTagRow(tags: [.review])
                Text(original.prompt).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
                if let selected = progress?.lastSelectedIndex, original.choices.indices.contains(selected),
                   selected != original.correctIndex {
                    answerRow(icon: "xmark.circle.fill", color: Color(hex: "C53030"),
                              label: "あなたの回答", text: original.choices[selected])
                }
                answerRow(icon: "checkmark.circle.fill", color: RecoveryStyle.done,
                          label: "正解", text: original.choices[original.correctIndex])
                Divider()
                Text(original.explanation).font(.subheadline).lineSpacing(5).foregroundStyle(RecoveryStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("courses.originalExplanation")
    }

    private func answerRow(icon: String, color: Color, label: String, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon).foregroundStyle(color).accessibilityHidden(true)
            (Text("\(label)：").bold() + Text(text))
                .font(.subheadline).foregroundStyle(RecoveryStyle.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Footer

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 8) {
            if !canAccess {
                Button(action: onUnlock) { Label("プレミアムでこのテーマを学ぶ", systemImage: "crown.fill") }
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .premium))
                    .accessibilityIdentifier("courses.unlock")
            } else if isMastered || waitingDate != nil {
                Button("苦手克服に戻る", action: onClose)
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
            } else if !subscriptionResolved {
                SlimeInlineLoadingView(message: "プランを確認中…").frame(minHeight: 54)
            } else {
                Button(action: onStart) { Label(startTitle, systemImage: "play.fill") }
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                    .accessibilityIdentifier("courses.start")
                VStack(alignment: .leading, spacing: 4) {
                    RecoveryNote(icon: "list.number", text: sessionNote)
                    if let note = freeNote { RecoveryNote(icon: "info.circle", text: note) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    /// Mirrors `CourseQuestionIndex.select`: practice starts with the missed question, checkups use other questions.
    private var sessionNote: String {
        if isDue { return "練習とは別の\(topic.checks.count)問で、覚えているか確かめます。" }
        if progress?.sourceQuestion?.isValid == true { return "まちがえた問題と、同じテーマの別の問題を合わせて3問練習します。" }
        return "このテーマの問題を3問練習します。"
    }

    private var freeNote: String? {
        if subscribed { return nil }
        if freeClaimTopicID == nil { return "このテーマを無料で学ぶテーマに選びます。後日のおさらいと再練習まで無料です。" }
        return "無料で学習中のテーマです。解き直しの無料枠は使いません。"
    }

    private func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        return days <= 1 ? "明日" : "\(days)日後"
    }
}

#if DEBUG
/// `-WeaknessCoursePreview -ReviewHomeOpen themeIntro -ThemeIntroKind new|due|waiting|mastered|locked`
struct ThemeIntroductionPreview: View {
    var kind = UserDefaults.standard.string(forKey: "ThemeIntroKind") ?? "new"

    var body: some View {
        let now = Date()
        let topic = WeaknessCourseCatalog.topic("dns") ?? WeaknessCourseCatalog.topics[0]
        let original = ITPassportQuestionBank.all.first { WeaknessRecoveryOverview.topic(for: $0)?.id == "dns" }
            .flatMap { WeaknessCourseCatalog.source(prompt: $0.question, choices: $0.choices,
                                                     correctIndex: $0.correctAnswerIndex, explanation: $0.explanation)?.question }
        let wrong = original.map { ($0.correctIndex + 1) % $0.choices.count }
        let progress: CourseProgress? = {
            switch kind {
            case "due": return CourseProgress(stage: .waiting, sourceQuestion: original, lastSelectedIndex: wrong,
                                              nextReviewAt: now - 60, updatedAt: now)
            case "waiting": return CourseProgress(stage: .waiting, sourceQuestion: original, lastSelectedIndex: wrong,
                                                  confirmedCount: 1, nextReviewAt: now + 3 * 86400, updatedAt: now)
            case "mastered": return CourseProgress(stage: .mastered, sourceQuestion: original, confirmedCount: 2,
                                                   masteredAt: now, updatedAt: now)
            default: return CourseProgress(sourceQuestion: original, lastSelectedIndex: wrong, mistakeCount: 1, updatedAt: now)
            }
        }()
        return NavigationStack {
            ThemeIntroductionContent(topic: topic, progress: progress, canAccess: kind != "locked",
                                     hasActiveSession: false, subscribed: false,
                                     freeClaimTopicID: kind == "new" ? nil : (kind == "locked" ? "memory" : topic.id),
                                     subscriptionResolved: true,
                                     startTitle: kind == "due" ? "おさらいを始める" : "このテーマを無料で始める",
                                     onStart: {}, onUnlock: {}, onClose: {})
                .navigationTitle(topic.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ThemeIntroductionPreview_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["new", "due", "waiting", "mastered", "locked"], id: \.self) { kind in
            ThemeIntroductionPreview(kind: kind).previewDisplayName(kind)
        }
    }
}
#endif
