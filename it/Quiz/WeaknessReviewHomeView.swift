import SwiftUI

enum ReviewHomeRoute: Hashable {
    case topics, focusedTraining
}

enum ReviewHomeAction {
    case startReview, openTopic(String), openPremium, openMastered, openGuide, close
}

/// Values the cards display besides the plan itself.
struct ReviewHomeContext {
    let subscribed: Bool
    let freeRemaining: Int
    let freeClaimTopicID: String?
    let masteredQuestionCount: Int
    let masteredTopicCount: Int
    let learningTopicID: String?
    /// The learning theme has passed its first checkup; one more makes it mastered.
    let learningTopicNearMastery: Bool
    let reviewStreak: Int
    let todayMasteredCount: Int
}

struct WeaknessReviewHomeContent: View {
    let plan: ReviewHomePlan
    let context: ReviewHomeContext
    let onAction: (ReviewHomeAction) -> Void
    var now = Date()
    @Environment(\.dynamicTypeSize) private var typeSize

    private var isAccessibilitySize: Bool { typeSize >= .accessibility1 }
    private var showsNumbers: Bool { plan.totalCount >= 2 && !isAccessibilitySize }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch plan.state {
            case .firstRun:
                RecoveryCompanion(message: companionMessage)
                firstRunSection
                achievementPlaceholder
            case .allClear:
                RecoveryCompanion(message: companionMessage)
                allClearCard
                upcomingSection
                selfSelectSection
                achievementSection
            default:
                if !isAccessibilitySize { RecoveryCompanion(message: companionMessage) }
                todaySection
                if isAccessibilitySize { RecoveryCompanion(message: companionMessage) }
                selfSelectSection
                achievementSection
            }
        }
    }

    // MARK: Today

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            todayHeader
            ForEach(plan.completedResults.indices, id: \.self) { completedRow(plan.completedResults[$0]) }
            if plan.state == .nothingToday {
                nothingTodayCard
            } else {
                ForEach(plan.cards.indices, id: \.self) { index in
                    card(plan.cards[index], position: index)
                }
            }
        }
    }

    @ViewBuilder
    private var todayHeader: some View {
        let title = Text("今日のおすすめ").font(.title3.bold()).foregroundStyle(RecoveryStyle.text)
            .accessibilityAddTraits(.isHeader)
        let counter = Text("\(plan.completedCount) / \(plan.totalCount) 完了")
            .font(.subheadline.weight(.bold).monospacedDigit())
            .foregroundStyle(RecoveryStyle.secondaryText)
            .accessibilityLabel("\(plan.totalCount)件中\(plan.completedCount)件完了")
        if isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                title
                if plan.totalCount > 0 { counter }
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                title
                Spacer(minLength: 8)
                if plan.totalCount > 0 { counter }
            }
        }
    }

    private func completedRow(_ result: ReviewTodayResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark").font(.subheadline.bold()).foregroundStyle(.white)
                .frame(width: 28, height: 28).background(RecoveryStyle.done, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(resultTitle(result, short: true)) 完了").font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                Text(resultDetail(result)).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(RecoveryTint.done.tagBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(RecoveryStyle.done.opacity(0.25)))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func card(_ card: ReviewRecommendation, position: Int) -> some View {
        let featured = card == plan.cards.first(where: \.isActionable)
        let number = showsNumbers && card.isActionable && !isFreeAlternative(card)
            ? plan.completedCount + plan.cards[..<position].filter(\.isActionable).count + 1 : nil
        switch card {
        case let .continueTheme(session):
            continueCard(session, number: number, featured: featured)
        case let .review(count, finalStageCount):
            reviewCard(count: count, finalStageCount: finalStageCount, number: number, featured: featured, position: position)
        case let .themeCheckup(theme):
            checkupCard(theme, number: number, featured: featured)
        case let .freeLimitReached(remainingCount):
            freeLimitCard(remainingCount: remainingCount, featured: featured)
        }
    }

    private func isFreeAlternative(_ card: ReviewRecommendation) -> Bool {
        guard case let .themeCheckup(theme) = card else { return false }
        return plan.state == .themeCheckup(theme, isFreeAlternative: true)
    }

    private func cardHeader(number: Int?, tint: RecoveryTint, featured: Bool, tags: [RecoveryTag]) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if let number { RecoveryNumberBadge(number: number, tint: tint, filled: featured) }
            RecoveryTagRow(tags: tags)
        }
    }

    @ViewBuilder
    private func actionButton(_ title: String, tint: RecoveryTint, featured: Bool, action: ReviewHomeAction) -> some View {
        if featured {
            Button { onAction(action) } label: { Label(title, systemImage: "play.fill") }
                .buttonStyle(RecoveryPrimaryButtonStyle(tint: tint))
        } else {
            Button(title) { onAction(action) }
                .buttonStyle(RecoveryOutlineButtonStyle(tint: tint))
        }
    }

    private func reviewCard(count: Int, finalStageCount: Int, number: Int?, featured: Bool, position: Int) -> some View {
        RecoveryCard(highlight: featured ? .review : nil) {
            cardHeader(number: number, tint: .review, featured: featured, tags: [.review])
            VStack(alignment: .leading, spacing: 6) {
                Text("まちがえた問題 \(count)問").font(featured ? .title2.bold() : .title3.bold())
                    .foregroundStyle(RecoveryStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text(reviewDetail(finalStageCount: finalStageCount, position: position))
                    .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            actionButton("\(count)問を解き直す", tint: .review, featured: featured, action: .startReview)
            if !context.subscribed {
                RecoveryNote(icon: "ticket",
                             text: "無料枠：今日あと\(context.freeRemaining)問（ホームの「今日の復習」と共通）")
            }
        }
    }

    private func reviewDetail(finalStageCount: Int, position: Int) -> String {
        if position > 0, let first = plan.cards.first {
            switch first {
            case .continueTheme: return "練習のあとに、こちらも解いておこう。"
            case .themeCheckup: return "おさらいのあとに、こちらも解いておこう。"
            default: break
            }
        }
        return finalStageCount > 0 ? "うち\(finalStageCount)問は、あと1回正解で克服できます。"
            : "日を空けて、同じ問題をもう一度解きます。"
    }

    private func continueCard(_ session: ReviewThemeResume, number: Int?, featured: Bool) -> some View {
        let title = topicTitle(session.topicID)
        let step = stepName(session.step)
        return RecoveryCard(highlight: featured ? .theme : nil) {
            cardHeader(number: number, tint: .theme, featured: featured,
                       tags: [.theme, RecoveryTag(text: "途中で中断中", icon: "pause.circle", tint: .neutral)])
            VStack(alignment: .leading, spacing: 4) {
                Text("\(title)の\(step)").font(featured ? .title2.bold() : .title3.bold())
                    .foregroundStyle(RecoveryStyle.text)
                Text("\(session.questionIndex + 1)問目から再開").font(.subheadline.weight(.semibold))
                    .foregroundStyle(RecoveryTint.theme.tagText)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(step) \(session.questionCount)問")
                    Spacer()
                    Text("\(session.questionIndex)問 回答済み")
                }
                .font(.caption.weight(.semibold)).foregroundStyle(RecoveryStyle.secondaryText)
                ProgressView(value: Double(session.questionIndex), total: Double(max(session.questionCount, 1)))
                    .tint(RecoveryTint.theme.main)
            }
            .accessibilityElement(children: .combine)
            actionButton("続きから練習する", tint: .theme, featured: featured, action: .openTopic(session.topicID))
            RecoveryNote(icon: "info.circle", text: continueNote(session))
        }
    }

    private func continueNote(_ session: ReviewThemeResume) -> String {
        let saved = session.questionIndex == 1 ? "解いた1問目の答えは保存されています。"
            : session.questionIndex > 1 ? "解いた\(session.questionIndex)問の答えは保存されています。" : "途中から続けられます。"
        return !context.subscribed && context.freeClaimTopicID == session.topicID ? "無料で学習中のテーマです。\(saved)" : saved
    }

    private func checkupCard(_ theme: ReviewDueTheme, number: Int?, featured: Bool) -> some View {
        let title = topicTitle(theme.topicID)
        let freeAlternative = isFreeAlternative(.themeCheckup(theme))
        let count = WeaknessCourseCatalog.topic(theme.topicID)?.checks.count ?? 2
        return RecoveryCard(highlight: featured ? .theme : nil) {
            cardHeader(number: number, tint: .theme, featured: featured,
                       tags: [.theme] + (freeAlternative ? [RecoveryTag(text: "今すぐ無料でできます", tint: .done)] : []))
            Text("\(title)のおさらい \(count)問").font(featured ? .title2.bold() : .title3.bold())
                .foregroundStyle(RecoveryStyle.text)
                .fixedSize(horizontal: false, vertical: true)
            Text(theme.checkupNumber >= 2
                 ? "全問正解から3日たちました。別の\(count)問に正解すると、マスターです。"
                 : "前回の練習を覚えているか、別の\(count)問で確かめます。")
                .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            ThemeStepProgress(checkupNumber: theme.checkupNumber)
            actionButton("\(title)のおさらいを始める", tint: .theme, featured: featured, action: .openTopic(theme.topicID))
            if freeAlternative {
                RecoveryNote(icon: "info.circle", text: "テーマのおさらいは、解き直しの無料枠（1日\(ReviewAccessPolicy.dailyFreeLimit)問）とは別です。")
            } else if !context.subscribed && context.freeClaimTopicID == theme.topicID {
                RecoveryNote(icon: "info.circle", text: "無料で学習中のテーマです。解き直しの無料枠は使いません。")
            }
        }
    }

    private func freeLimitCard(remainingCount: Int, featured: Bool) -> some View {
        let limit = ReviewAccessPolicy.dailyFreeLimit
        let used = max(0, limit - context.freeRemaining)
        return RecoveryCard(highlight: featured ? .review : nil, background: featured ? .white : Color(hex: "F3F8FF")) {
            RecoveryTagRow(tags: [.review, RecoveryTag(text: "今日の無料分 完了", icon: "checkmark", tint: .done)])
            Text("今日は\(used)問を解き直しました").font(.title3.bold()).foregroundStyle(RecoveryStyle.text)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("無料枠（1日\(limit)問）")
                    Spacer()
                    Text("\(used) / \(limit) 使用").monospacedDigit()
                }
                .font(.caption.weight(.bold)).foregroundStyle(RecoveryStyle.secondaryText)
                HStack(spacing: 4) {
                    ForEach(0..<limit, id: \.self) { index in
                        Capsule().fill(index < used ? RecoveryTint.review.main : Color(hex: "DDE4EE")).frame(height: 8)
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("今日の無料枠 \(limit)問中\(used)問 使用済み")
            Text("残りの\(remainingCount)問は、明日の無料枠で解けます。")
                .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
            Button { onAction(.openPremium) } label: {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                    Text("プレミアムなら、残り\(remainingCount)問も今日解けます")
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.caption.bold())
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(RecoveryTint.premium.tagText)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var nothingTodayCard: some View {
        RecoveryCard {
            RecoveryTagRow(tags: [RecoveryTag(text: "今日の予定なし", icon: "calendar", tint: .neutral)])
            Text("次の日付を待っています").font(.title2.bold()).foregroundStyle(RecoveryStyle.text)
            Text("解き直しもテーマのおさらいも、日を空けるほど記憶に残ります。")
                .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            if !plan.upcoming.isEmpty {
                RecoveryUpcomingList(items: plan.upcoming, now: now)
                    .padding(.horizontal, 14).padding(.vertical, 4)
                    .background(Color(hex: "F1F5FB"), in: RoundedRectangle(cornerRadius: 14))
            }
            Button("冒険にもどって問題を解く") { onAction(.close) }
                .buttonStyle(RecoveryPrimaryButtonStyle(tint: .review))
            RecoveryNote(icon: "info.circle", text: "新しくまちがえた問題も、翌日からここで解き直せます。")
        }
    }

    // MARK: First run

    private var firstRunSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "まずはここから")
            RecoveryCard(highlight: .theme) {
                RecoveryTagRow(tags: [.theme])
                Text("テーマを1つ選んで学ぶ").font(.title2.bold()).foregroundStyle(RecoveryStyle.text)
                Text("説明を読んで3問を練習。翌日に、覚えているかおさらいします。")
                    .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                FlowLayout(spacing: 6) {
                    ForEach(["RAMとROM", "DNSの役割", "暗号の使い分け", "損益分岐点", "ほか6テーマ"], id: \.self) {
                        Text($0).font(.caption.weight(.semibold)).foregroundStyle(RecoveryStyle.text)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(hex: "F1F5FB"), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .accessibilityElement(children: .combine)
                NavigationLink(value: ReviewHomeRoute.topics) {
                    Text(context.subscribed ? "学ぶテーマを選ぶ" : "無料で学ぶテーマを選ぶ")
                }
                .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                if !context.subscribed {
                    RecoveryNote(icon: "info.circle", text: "最初に始めた1テーマは、後日のおさらいまで無料です。")
                }
            }
            RecoveryCard {
                RecoveryTagRow(tags: [.review])
                Text("まちがえた問題は、ここに届きます").font(.title3.bold()).foregroundStyle(RecoveryStyle.text)
                Text("クイズでまちがえた問題を、日を空けてもう一度出題します。")
                    .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                RecoveryStepFlow(steps: ["まちがえる", "翌日", "正解から3日後", "正解から7日後", "克服"], tint: .review)
                Label("今はまだ、解き直す問題はありません", systemImage: "calendar")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(RecoveryStyle.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(hex: "F1F5FB"), in: RoundedRectangle(cornerRadius: 12))
            }
            Button { onAction(.openGuide) } label: {
                HStack(spacing: 4) {
                    Text("しくみをくわしく見る")
                    Image(systemName: "chevron.right").font(.caption.bold())
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(RecoveryTint.review.tagText)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: All clear

    private var allClearCard: some View {
        RecoveryCard(background: RecoveryStyle.goldBackground) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日のおすすめを\nすべて完了").font(.title2.bold()).foregroundStyle(RecoveryStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(plan.completedCount) / \(plan.totalCount) 完了")
                    .font(.caption.weight(.bold)).foregroundStyle(RecoveryTint.gold.tagText)
            }
            VStack(spacing: 0) {
                ForEach(plan.todayResults.indices, id: \.self) { index in
                    if index > 0 { Divider().padding(.leading, 48) }
                    let result = plan.todayResults[index]
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark").font(.subheadline.bold()).foregroundStyle(.white)
                            .frame(width: 28, height: 28).background(RecoveryStyle.done, in: Circle())
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(resultTitle(result, short: false)).font(.subheadline.bold()).foregroundStyle(RecoveryStyle.text)
                            Text(resultDetail(result)).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .accessibilityElement(children: .combine)
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            Button("冒険にもどる") { onAction(.close) }
                .buttonStyle(RecoveryPrimaryButtonStyle(tint: .review))
        }
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "E8B85A"), lineWidth: 2))
    }

    @ViewBuilder
    private var upcomingSection: some View {
        if !plan.upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                RecoverySectionHeader(title: "次の予定")
                RecoveryUpcomingList(items: plan.upcoming, now: now)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(RecoveryStyle.cardBorder))
            }
        }
    }

    // MARK: Self select

    private var selfSelectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "自分で選んで練習")
            VStack(spacing: 0) {
                NavigationLink(value: ReviewHomeRoute.topics) {
                    selfSelectRow(icon: "book", tint: .theme, title: "テーマを選んで学ぶ",
                                  detail: "説明を読んで3問練習。全10テーマ", premium: false)
                }
                Divider().padding(.leading, 68)
                NavigationLink(value: ReviewHomeRoute.focusedTraining) {
                    selfSelectRow(icon: "scope", tint: .premium, title: "分野を選んで集中特訓",
                                  detail: "正解率の低い分野の問題だけを解き直し", premium: true)
                }
            }
            .buttonStyle(.plain)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(RecoveryStyle.cardBorder))
        }
    }

    private func selfSelectRow(icon: String, tint: RecoveryTint, title: String, detail: String, premium: Bool) -> some View {
        HStack(spacing: 12) {
            if !isAccessibilitySize { RecoveryIconTile(symbol: icon, tint: tint) }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(RecoveryStyle.text)
                Text(detail).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                if premium { RecoveryTag.premium }
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").font(.footnote.bold()).foregroundStyle(RecoveryStyle.secondaryText)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }

    // MARK: Achievements

    private var achievementHeader: some View {
        RecoverySectionHeader(title: "これまでの成果") {
            Button { onAction(.openMastered) } label: {
                HStack(spacing: 2) {
                    Text("克服図鑑")
                    Image(systemName: "chevron.right").font(.caption.bold())
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(RecoveryTint.review.tagText)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            achievementHeader
            let tiles = Group {
                achievementTile(icon: "trophy", tint: .gold, title: "克服した問題",
                                value: "\(context.masteredQuestionCount)", unit: "問",
                                todayGain: context.todayMasteredCount, detail: "日を空けた3回の解き直しに正解")
                achievementTile(icon: "rosette", tint: .theme, title: "マスターしたテーマ",
                                value: "\(context.masteredTopicCount)", unit: "テーマ", todayGain: 0,
                                detail: masteredTopicDetail)
            }
            if isAccessibilitySize {
                VStack(spacing: 12) { tiles }
            } else {
                HStack(alignment: .top, spacing: 12) { tiles }
            }
            if context.reviewStreak > 0 {
                RecoveryTag(text: "解き直し \(context.reviewStreak)日連続", icon: "flame.fill", tint: .gold)
            }
        }
    }

    private var masteredTopicDetail: String {
        guard let id = context.learningTopicID else { return "日を空けた2回のおさらいに正解" }
        return context.learningTopicNearMastery ? "\(topicTitle(id))は、あと1回のおさらいでマスター" : "\(topicTitle(id))を学習中"
    }

    private func achievementTile(icon: String, tint: RecoveryTint, title: String, value: String, unit: String,
                                 todayGain: Int, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon).font(.caption.weight(.bold)).foregroundStyle(RecoveryStyle.text)
                .labelStyle(TintedIconLabelStyle(tint: tint.main))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.title.bold().monospacedDigit())
                Text(unit).font(.subheadline.bold())
                if todayGain > 0 {
                    Text("今日 +\(todayGain)").font(.caption2.bold()).foregroundStyle(RecoveryStyle.done)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(RecoveryTint.done.tagBackground, in: Capsule())
                        .padding(.leading, 4)
                }
            }
            .foregroundStyle(RecoveryStyle.text)
            Text(detail).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(RecoveryStyle.cardBorder))
        .accessibilityElement(children: .combine)
    }

    private var achievementPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecoverySectionHeader(title: "これまでの成果")
            Button { onAction(.openMastered) } label: {
                HStack(spacing: 12) {
                    RecoveryIconTile(symbol: "trophy", tint: .gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("克服図鑑").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text("克服した問題と、マスターしたテーマがここに記録されます")
                            .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right").font(.footnote.bold()).foregroundStyle(RecoveryStyle.secondaryText)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(RecoveryStyle.cardBorder))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Copy

    private var companionMessage: String {
        let remaining = plan.cards.filter(\.isActionable).count
        if let done = plan.completedResults.last, let next = plan.cards.first(where: \.isActionable) {
            let doneName = resultTitle(done, short: true)
            return remaining == 1 ? "\(doneName)を終えたのう。次の\(recommendationName(next))を済ませれば、今日の学習は完了じゃ。"
                : "\(doneName)を終えたのう。次は\(recommendationName(next))に取り組むとよい。"
        }
        switch plan.state {
        case let .continueTheme(session):
            return "\(topicTitle(session.topicID))の\(stepName(session.step))が途中じゃ。続きから取り組むとよい。"
        case let .reviewDue(_, finalStageCount):
            if remaining > 1 { return "今日のおすすめは\(remaining)つじゃ。まずは、まちがえた問題を解き直すとよい。" }
            return finalStageCount > 0 ? "あと1回で克服できる問題があるのう。まずは解き直すとよい。" : "まずは、まちがえた問題を解き直すとよい。"
        case let .themeCheckup(theme, isFreeAlternative):
            if isFreeAlternative {
                return "今日の無料の解き直しは完了じゃ。\(topicTitle(theme.topicID))のおさらいは、まだ無料で取り組めるのじゃ。"
            }
            return remaining > 1 ? "今日のおすすめは\(remaining)つじゃ。まずは、\(topicTitle(theme.topicID))をおさらいするとよい。"
                : "\(topicTitle(theme.topicID))を覚えておるか、おさらいで確かめるとよい。"
        case .freeLimitReached:
            return "今日の無料の解き直しは完了じゃ。残りは明日取り組むとよい。"
        case .firstRun:
            return "ここは、苦手を少しずつ克服する場所じゃ。まずは学ぶテーマを1つ選ぶとよい。"
        case .allClear:
            return "今日の学習をすべて終えたのう。よく取り組んだ。"
        case .nothingToday:
            guard let next = plan.upcoming.first else { return "今日は復習の予定はないのじゃ。新しい問題に取り組んでもよい。" }
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now),
                                                       to: Calendar.current.startOfDay(for: next.date)).day ?? 1
            return "次の復習は\(days <= 1 ? "明日" : "\(days)日後")じゃ。それまでは新しい問題で学ぶとよい。"
        }
    }

    private func recommendationName(_ card: ReviewRecommendation) -> String {
        switch card {
        case let .continueTheme(session): return "\(topicTitle(session.topicID))の\(stepName(session.step))"
        case .review: return "解き直し"
        case let .themeCheckup(theme): return "\(topicTitle(theme.topicID))のおさらい"
        case .freeLimitReached: return "解き直し"
        }
    }

    private func stepName(_ step: ReviewThemeStep) -> String {
        switch step {
        case .practice: return "練習"
        case let .checkup(number): return "おさらい（\(number)回目）"
        }
    }

    private func resultTitle(_ result: ReviewTodayResult, short: Bool) -> String {
        switch result.kind {
        case .review: return short ? "解き直し" : "まちがえた問題の解き直し"
        case let .themePractice(topicID): return "\(topicTitle(topicID))の練習"
        case let .themeCheckup(topicID, _): return "\(topicTitle(topicID))のおさらい"
        }
    }

    private func resultDetail(_ result: ReviewTodayResult) -> String {
        let score = "\(result.answeredCount)問中\(result.correctCount)問 正解"
        switch result.kind {
        case .review:
            return score + (result.masteredCount > 0 ? "・\(result.masteredCount)問を克服" : "")
        case .themePractice:
            return score + (result.passed ? "・練習クリア" : "・説明からもう一度")
        case let .themeCheckup(_, number):
            if result.masteredCount > 0 { return score + "・マスター" }
            return score + (result.passed ? "・\(number)回目のおさらいに合格" : "・練習からもう一度")
        }
    }

    private func topicTitle(_ id: String) -> String {
        WeaknessCourseCatalog.topic(id)?.title ?? "テーマ"
    }
}

private struct TintedIconLabelStyle: LabelStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.foregroundStyle(tint)
            configuration.title
        }
    }
}
