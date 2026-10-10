import SwiftUI

/// Result of a theme practice or checkup, in the same style as the problem-review result.
struct ThemeSessionResultScreen: View {
    let completion: CourseCompletion
    let topic: WeaknessCourseTopic
    /// Other themes related to missed questions, and whether each is locked.
    let relatedTopics: [(topic: WeaknessCourseTopic, locked: Bool)]
    let isFreeTheme: Bool
    let onRetry: () -> Void
    let onClose: () -> Void
    let onSelectTopic: (WeaknessCourseTopic) -> Void
    var now = Date()

    private var isMastered: Bool { completion.progress.stage == .mastered }
    /// After a passed checkup the stored count is the checkup just passed; a failed one resets it.
    private var passedCheckup: Int? {
        completion.kind == .confirmation && completion.passed ? completion.progress.confirmedCount : nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statusCard
                if !relatedTopics.isEmpty { relatedSection }
                actions
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(
            VStack(spacing: 0) {
                LinearGradient(colors: [completion.passed ? Color(hex: "FFF3D6") : RecoveryTint.theme.tagBackground,
                                        RecoveryStyle.backgroundBottom], startPoint: .top, endPoint: .bottom)
                    .frame(height: 360)
                RecoveryStyle.backgroundBottom
            }
            .ignoresSafeArea()
        )
        .accessibilityIdentifier("courses.result")
    }

    private var header: some View {
        VStack(spacing: 8) {
            RecoveryMonsterAvatar(size: 120)
            Text(resultLabel).font(.subheadline.bold())
                .foregroundStyle(completion.passed ? RecoveryTint.gold.tagText : RecoveryTint.theme.tagText)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(completion.correctCount) / \(completion.questionCount)").font(.largeTitle.bold().monospacedDigit())
                Text("問 正解").font(.title3.bold())
            }
            .foregroundStyle(RecoveryStyle.text)
            .accessibilityElement(children: .combine)
            Text(companionMessage)
                .font(.subheadline.weight(.bold)).foregroundStyle(RecoveryStyle.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(completion.passed ? RecoveryStyle.gold.opacity(0.5) : RecoveryTint.theme.main.opacity(0.4)))
                .accessibilityLabel("おとも：\(companionMessage)")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var resultLabel: String {
        switch completion.kind {
        case .practice: return "「\(topic.title)」練習の結果"
        case .confirmation:
            return passedCheckup.map { "「\(topic.title)」\($0)回目のおさらいの結果" } ?? "「\(topic.title)」おさらいの結果"
        }
    }

    private var companionMessage: String {
        if isMastered { return "「\(topic.title)」をマスターしたのう。繰り返し学んだ成果じゃ。" }
        if !completion.passed { return "説明を読み直し、もう一度練習するとよい。焦らず進めるのじゃ。" }
        if completion.kind == .practice { return "全問正解じゃ。日を空けて、覚えておるか確かめるとよい。" }
        return "おさらいに合格じゃ。もう一度確かめれば、マスターじゃ。"
    }

    @ViewBuilder
    private var statusCard: some View {
        if isMastered {
            HStack(spacing: 14) {
                RecoveryIconTile(symbol: "rosette", tint: .gold, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("マスターしました").font(.headline).foregroundStyle(RecoveryStyle.text)
                    Text("克服図鑑の「マスターしたテーマ」に記録しました")
                        .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "E8B85A"), lineWidth: 2))
            .accessibilityElement(children: .combine)
        } else if completion.passed, let next = completion.progress.nextReviewAt {
            let number = (passedCheckup ?? 0) + 1
            RecoveryCard {
                HStack(spacing: 12) {
                    RecoveryIconTile(symbol: "calendar", tint: .theme)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("次のおさらい（\(number)回目）").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text("\(next.formatted(.dateTime.month(.defaultDigits).day().weekday(.short)))（\(relativeDay(next))）に、別の\(topic.checks.count)問で確かめます")
                            .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                ThemeStepProgress(checkupNumber: number, currentPrefix: "次")
                if isFreeTheme {
                    RecoveryNote(icon: "info.circle", text: "無料で学習中のテーマです。おさらいも無料です。")
                }
            }
        } else {
            RecoveryCard {
                HStack(spacing: 12) {
                    RecoveryIconTile(symbol: "book", tint: .theme)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("説明を読んで、もう一度練習").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text(completion.kind == .confirmation
                             ? "おさらいで全問正解できなかったので、練習からやり直します。"
                             : "全問正解すると、日を空けたおさらいに進めます。")
                            .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if isFreeTheme {
                    RecoveryNote(icon: "info.circle", text: "無料で学習中のテーマです。再練習も無料です。")
                }
            }
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "まちがえた問題に関係するテーマ")
            VStack(spacing: 0) {
                ForEach(relatedTopics.indices, id: \.self) { index in
                    if index > 0 { Divider().padding(.leading, 64) }
                    let item = relatedTopics[index]
                    Button { onSelectTopic(item.topic) } label: {
                        HStack(spacing: 12) {
                            RecoveryIconTile(symbol: item.topic.symbol, tint: item.locked ? .neutral : .theme)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.topic.title).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                                Text("説明と3問で練習").font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            }
                            Spacer(minLength: 4)
                            if item.locked {
                                RecoveryTag.premium
                            } else {
                                Image(systemName: "chevron.right").font(.footnote.bold())
                                    .foregroundStyle(RecoveryStyle.secondaryText).accessibilityHidden(true)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .frame(minHeight: 52)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(RecoveryStyle.cardBorder))
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            if completion.passed {
                Button("苦手克服に戻る", action: onClose)
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                    .accessibilityIdentifier("courses.close")
            } else {
                Button(action: onRetry) { Label("説明を読んでもう一度練習", systemImage: "play.fill") }
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                    .accessibilityIdentifier("courses.retry")
                Button(action: onClose) {
                    Text("苦手克服に戻る").font(.subheadline.bold()).foregroundStyle(RecoveryTint.review.tagText)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }

    private func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        return days <= 1 ? "明日" : "\(days)日後"
    }
}

#if DEBUG
/// `-WeaknessCoursePreview -ReviewHomeOpen themeResult -ThemeResultKind failed|practice|checkup|mastered`
struct ThemeSessionResultPreview: View {
    var kind = UserDefaults.standard.string(forKey: "ThemeResultKind") ?? "failed"

    var body: some View {
        let now = Date()
        let topic = WeaknessCourseCatalog.topic("ipv4") ?? WeaknessCourseCatalog.topics[0]
        let completion: CourseCompletion
        switch kind {
        case "practice":
            completion = CourseCompletion(topicID: topic.id, correctCount: 3, questionCount: 3, kind: .practice,
                progress: CourseProgress(stage: .waiting, nextReviewAt: now + 86400, updatedAt: now))
        case "checkup":
            completion = CourseCompletion(topicID: topic.id, correctCount: 2, questionCount: 2, kind: .confirmation,
                progress: CourseProgress(stage: .waiting, confirmedCount: 1, nextReviewAt: now + 3 * 86400, updatedAt: now))
        case "mastered":
            completion = CourseCompletion(topicID: topic.id, correctCount: 2, questionCount: 2, kind: .confirmation,
                progress: CourseProgress(stage: .mastered, confirmedCount: 2, masteredAt: now, updatedAt: now))
        default:
            completion = CourseCompletion(topicID: topic.id, correctCount: 0, questionCount: 3, kind: .practice,
                progress: CourseProgress(updatedAt: now))
        }
        let related = ["phishing", "backup", "mfa"].compactMap(WeaknessCourseCatalog.topic).map { ($0, true) }
        return NavigationStack {
            ThemeSessionResultScreen(completion: completion, topic: topic, relatedTopics: related, isFreeTheme: true,
                                     onRetry: {}, onClose: {}, onSelectTopic: { _ in })
                .navigationTitle(topic.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ThemeSessionResultPreview_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["failed", "practice", "checkup", "mastered"], id: \.self) { kind in
            ThemeSessionResultPreview(kind: kind).previewDisplayName(kind)
        }
    }
}
#endif
