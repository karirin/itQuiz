import SwiftUI

/// Passed from the recovery home through `QuizView` so the result screen can show the review outcome.
struct ReviewResultContext {
    /// Computes the outcome once the quiz is finished. Safe to call more than once.
    let load: () -> ReviewSessionResult?
    /// Called just before the result screen closes. A non-nil action runs on the recovery home afterwards.
    let finish: (ReviewHomeAction?) -> Void
}

struct ReviewSessionResult {
    let outcome: ReviewSessionOutcome
    let next: ReviewRecommendation?
    /// All mastered questions after this session.
    let masteredTotal: Int
    /// Today's remaining free reviews; nil for premium.
    let freeRemaining: Int?
}

/// Replaces the regular quiz result for problem reviews started from the recovery home.
struct ReviewSessionResultScreen: View {
    let result: ReviewSessionResult
    let onFinish: (ReviewHomeAction?) -> Void
    var now = Date()

    private var outcome: ReviewSessionOutcome { result.outcome }

    private var relatedTopics: [(topic: WeaknessCourseTopic, missed: Int)] {
        var order: [String] = []
        var counts: [String: Int] = [:]
        for topic in outcome.missedQuestions.compactMap(WeaknessRecoveryOverview.topic(for:)) {
            if counts[topic.id] == nil { order.append(topic.id) }
            counts[topic.id, default: 0] += 1
        }
        return order.compactMap { id in WeaknessCourseCatalog.topic(id).map { ($0, counts[id] ?? 0) } }
    }

    private var nextDates: [(date: Date, count: Int)] {
        Dictionary(grouping: outcome.nextReviewDates) { Calendar.current.startOfDay(for: $0) }
            .map { ($0.key, $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if outcome.masteredCount > 0 { masteredCard }
                if !nextDates.isEmpty || outcome.retryCount > 0 { nextReviewSection }
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
                LinearGradient(colors: [Color(hex: "FFF3D6"), RecoveryStyle.backgroundBottom], startPoint: .top, endPoint: .bottom)
                    .frame(height: 360)
                RecoveryStyle.backgroundBottom
            }
            .ignoresSafeArea()
        )
        .accessibilityIdentifier("review.result")
    }

    private var header: some View {
        VStack(spacing: 8) {
            RecoveryMonsterAvatar(size: 120)
            Text("解き直しの結果").font(.subheadline.bold()).foregroundStyle(RecoveryTint.gold.tagText)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(outcome.correctCount) / \(outcome.answeredCount)").font(.largeTitle.bold().monospacedDigit())
                Text("問 正解").font(.title3.bold())
            }
            .foregroundStyle(RecoveryStyle.text)
            .accessibilityElement(children: .combine)
            Text(companionMessage)
                .font(.subheadline.weight(.bold)).foregroundStyle(RecoveryStyle.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(RecoveryStyle.gold.opacity(0.5)))
                .accessibilityLabel("おとも：\(companionMessage)")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var masteredCard: some View {
        HStack(spacing: 14) {
            RecoveryIconTile(symbol: "trophy.fill", tint: .gold, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(outcome.masteredCount)問を克服しました").font(.headline).foregroundStyle(RecoveryStyle.text)
                Text("克服図鑑に記録しました（克服した問題 \(result.masteredTotal)問）")
                    .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "E8B85A"), lineWidth: 2))
        .accessibilityElement(children: .combine)
    }

    private var nextReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "次の解き直し")
            VStack(spacing: 0) {
                ForEach(nextDates.indices, id: \.self) { index in
                    if index > 0 { Divider() }
                    let item = nextDates[index]
                    scheduleRow(count: item.count,
                                title: "\(item.date.formatted(.dateTime.month(.defaultDigits).day().weekday(.short)))に出題",
                                detail: "今日正解したので、\(daysFromToday(item.date))日後にもう一度")
                }
                if outcome.retryCount > 0 {
                    if !nextDates.isEmpty { Divider() }
                    scheduleRow(count: outcome.retryCount, title: "日を空けて、もう一度出題",
                                detail: "まちがえた問題は、また解き直せます")
                }
            }
            .padding(.horizontal, 16)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(RecoveryStyle.cardBorder))
        }
    }

    private func scheduleRow(count: Int, title: String, detail: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(count)").font(.title3.bold().monospacedDigit())
                Text("問").font(.caption.bold())
            }
            .foregroundStyle(RecoveryStyle.text)
            .frame(minWidth: 44, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                Text(detail).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "まちがえた問題を理解する")
            ForEach(relatedTopics, id: \.topic.id) { item in
                Button { onFinish(.openTopic(item.topic.id)) } label: {
                    HStack(spacing: 12) {
                        RecoveryIconTile(symbol: "book", tint: .theme)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("「\(item.topic.title)」の説明を読む").font(.subheadline.bold())
                                .foregroundStyle(RecoveryStyle.text)
                            Text("まちがえた\(item.missed)問と同じテーマです").font(.caption)
                                .foregroundStyle(RecoveryStyle.secondaryText)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").font(.footnote.bold())
                            .foregroundStyle(RecoveryStyle.secondaryText)
                    }
                    .padding(14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(RecoveryTint.theme.main.opacity(0.4)))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            if let next = result.next, let title = nextTitle(next) {
                Button { onFinish(nextAction(next)) } label: { Label(title, systemImage: "play.fill") }
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: nextTint(next)))
                Button { onFinish(nil) } label: {
                    Text("苦手克服に戻る").font(.subheadline.bold()).foregroundStyle(RecoveryTint.review.tagText)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Button("苦手克服に戻る") { onFinish(nil) }
                    .buttonStyle(RecoveryPrimaryButtonStyle(tint: .review))
            }
            if let remaining = result.freeRemaining {
                RecoveryNote(icon: "ticket", text: remaining == 0
                             ? "解き直しの無料枠は、今日の\(ReviewAccessPolicy.dailyFreeLimit)問を使いました"
                             : "解き直しの無料枠：今日あと\(remaining)問")
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    private var companionMessage: String {
        if outcome.masteredCount > 0 { return "苦手モンスターを\(outcome.masteredCount)体倒したのう。学んだことが身についてきたようじゃ。" }
        if outcome.answeredCount > 0 && outcome.correctCount == outcome.answeredCount { return "全問正解じゃ。しっかり覚えておるのう。" }
        return "まちがえた問題は、日を空けてまた出題するのじゃ。焦らず取り組むとよい。"
    }

    private func daysFromToday(_ date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
    }

    private func nextTitle(_ next: ReviewRecommendation) -> String? {
        switch next {
        case let .continueTheme(session):
            return "続けて\(topicTitle(session.topicID))の練習を再開"
        case let .review(count, _):
            return "続けて\(count)問を解き直す"
        case let .themeCheckup(theme):
            let count = WeaknessCourseCatalog.topic(theme.topicID)?.checks.count ?? 2
            return "続けて\(topicTitle(theme.topicID))のおさらい（\(count)問）"
        case .freeLimitReached:
            return nil
        }
    }

    private func nextAction(_ next: ReviewRecommendation) -> ReviewHomeAction {
        switch next {
        case let .continueTheme(session): return .openTopic(session.topicID)
        case .review: return .startReview
        case let .themeCheckup(theme): return .openTopic(theme.topicID)
        case .freeLimitReached: return .openPremium
        }
    }

    private func nextTint(_ next: ReviewRecommendation) -> RecoveryTint {
        if case .review = next { return .review }
        return .theme
    }

    private func topicTitle(_ id: String) -> String {
        WeaknessCourseCatalog.topic(id)?.title ?? "テーマ"
    }
}

/// Shown under the monster for a review question that is one correct answer from mastery.
struct ReviewFinalStageBadge: View {
    var body: some View {
        Label("この問題は、あと1回正解で克服", systemImage: "trophy")
            .font(.caption.weight(.bold))
            .foregroundStyle(RecoveryTint.gold.tagText)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color(hex: "FFF3D6"), in: Capsule())
            .overlay(Capsule().strokeBorder(Color(hex: "E8B85A")))
    }
}

#if DEBUG
/// The review result with sample data.
struct ReviewSessionResultPreview: View {
    var body: some View {
        let now = Date()
        let missed = ITPassportQuestionBank.all.first { WeaknessRecoveryOverview.topic(for: $0)?.id == "dns" }
        let outcome = ReviewSessionOutcome(answeredCount: 5, correctCount: 4, masteredCount: 2,
                                           nextReviewDates: [now + 3 * 86400, now + 3 * 86400],
                                           missedQuestions: missed.map { [$0] } ?? [])
        ReviewSessionResultScreen(result: ReviewSessionResult(outcome: outcome,
            next: .themeCheckup(ReviewDueTheme(topicID: "dns", checkupNumber: 1)),
            masteredTotal: 14, freeRemaining: 0)) { _ in }
    }
}

struct ReviewSessionResultPreview_Previews: PreviewProvider {
    static var previews: some View {
        ReviewSessionResultPreview()
        ReviewFinalStageBadge().padding().previewLayout(.sizeThatFits)
    }
}
#endif
