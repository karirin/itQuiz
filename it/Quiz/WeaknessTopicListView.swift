import SwiftUI

/// Every theme in one place: learning, related to missed questions, and the rest.
struct WeaknessTopicListView: View {
    @ObservedObject var store: WeaknessCourseStore
    @EnvironmentObject private var appState: AppState
    let now: Date
    let onSelect: (WeaknessCourseTopic) -> Void
    let onPremium: () -> Void

    private var cloud: CourseCloudState { store.state.cloud }

    private var learning: [WeaknessCourseTopic] {
        let due = Set(WeaknessRecoveryOverview(state: cloud, now: now).dueTopicIDs)
        return WeaknessCourseCatalog.topics.filter { store.state.isLearning($0.id) }
            .sorted { due.contains($0.id) && !due.contains($1.id) }
    }

    private var related: [WeaknessCourseTopic] {
        let learningIDs = Set(learning.map(\.id))
        return store.recommendedTopics.filter { !learningIDs.contains($0.id) }
    }

    private var others: [WeaknessCourseTopic] {
        let shown = Set((learning + related).map(\.id))
        return WeaknessCourseCatalog.topics.filter { !shown.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RecoveryStepFlow(steps: ["説明を読む", "3問練習", "翌日おさらい", "3日後にもう一度"], tint: .theme)
                if !appState.isSubscribed { freeBanner }
                if let message = store.syncMessage {
                    Text(message).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                }
                if store.userID == nil {
                    Text("テーマの学習データを準備しています。")
                        .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                } else {
                    section("学習中", topics: learning, detailed: true)
                    section("まちがえた問題に関係するテーマ", topics: related, detailed: true)
                    section("ほかのテーマ", topics: others, detailed: false)
                }
                if !appState.isSubscribed {
                    Button(action: onPremium) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown")
                            Text("プレミアムで全10テーマを学ぶ")
                        }
                    }
                    .buttonStyle(RecoveryOutlineButtonStyle(tint: .premium))
                }
            }
            .padding(16)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(RecoveryStyle.background)
        .navigationTitle("テーマを選んで学ぶ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var freeBanner: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "ticket").foregroundStyle(RecoveryTint.theme.main).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(cloud.freeClaim.flatMap { WeaknessCourseCatalog.topic($0.topicID) }
                        .map { "無料テーマ：\($0.title)" } ?? "1テーマを無料で学べます")
                    .font(.subheadline.bold())
                Text(cloud.freeClaim == nil
                     ? "最初に始めた1テーマは、おさらい・再練習まで無料です。解き直しの無料枠は使いません。"
                     : "最初に始めた1テーマは、おさらい・再練習まで無料です。ほかのテーマはプレミアムで学べます。")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(RecoveryTint.theme.tagText)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RecoveryTint.theme.tagBackground.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(RecoveryTint.theme.main.opacity(0.3)))
    }

    @ViewBuilder
    private func section(_ title: String, topics: [WeaknessCourseTopic], detailed: Bool) -> some View {
        if !topics.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.headline).foregroundStyle(RecoveryStyle.text).accessibilityAddTraits(.isHeader)
                VStack(spacing: 0) {
                    ForEach(topics.indices, id: \.self) { index in
                        if index > 0 { Divider().padding(.leading, detailed ? 64 : 16) }
                        let topic = topics[index]
                        WeaknessTopicRow(topic: topic, progress: cloud.progress[topic.id],
                                         locked: !cloud.canAccess(topic.id, subscribed: appState.isSubscribed),
                                         hasActiveSession: store.state.activeSession?.topicID == topic.id,
                                         detailed: detailed, now: now) { onSelect(topic) }
                    }
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(RecoveryStyle.cardBorder))
            }
        }
    }
}

private struct WeaknessTopicRow: View {
    let topic: WeaknessCourseTopic
    let progress: CourseProgress?
    let locked: Bool
    let hasActiveSession: Bool
    /// "ほかのテーマ" rows show only the title unless the theme has a status worth reading.
    let detailed: Bool
    let now: Date
    let action: () -> Void

    private var isDue: Bool { progress?.isDue(at: now) == true && !locked }
    private var checkupNumber: Int { (progress?.confirmedCount ?? 0) + 1 }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if detailed {
                    RecoveryIconTile(symbol: topic.symbol, tint: locked ? .neutral : .theme)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(topic.title).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                    if detailed || !locked {
                        Text(status).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 4)
                trailing
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("courses.topic.\(topic.id)")
    }

    @ViewBuilder
    private var trailing: some View {
        if locked {
            RecoveryTag.premium
        } else {
            HStack(spacing: 8) {
                if isDue {
                    Text("今日").font(.caption2.bold()).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(RecoveryTint.theme.main, in: Capsule())
                } else if progress?.stage == .mastered {
                    RecoveryTag(text: "マスター", icon: "checkmark.seal.fill", tint: .done)
                }
                Image(systemName: "chevron.right").font(.footnote.bold())
                    .foregroundStyle(RecoveryStyle.secondaryText).accessibilityHidden(true)
            }
        }
    }

    private var status: String {
        guard let progress else { return "説明と3問で練習" }
        if progress.stage == .mastered { return "日を空けた2回のおさらいに正解" }
        if hasActiveSession { return "途中から再開できます" }
        if isDue { return "今日：おさらい \(topic.checks.count)問" }
        if progress.stage == .waiting, let next = progress.nextReviewAt {
            return "次のおさらい（\(checkupNumber)回目）：\(next.formatted(.dateTime.month(.defaultDigits).day().weekday(.short)))"
        }
        return "説明と3問で練習"
    }
}
