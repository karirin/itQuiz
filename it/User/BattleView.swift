//
//  BattleView.swift
//  it
//
//  週間リーグの同じグループに所属するメンバーとの非同期1vs1クイズバトル画面です。
//  週間リーグ画面(WeeklyLeagueView)に組み込んで使うパーツ群で、単独の一覧画面は持ちません。
//

import SwiftUI

// MARK: - 対戦カードの共通パーツ

/// 相手・カテゴリ・問題数を1行で示す。
private struct BattleMetaRow: View {
    let category: String
    let questionCount: Int
    let theme: SocialTheme

    var body: some View {
        Text("\(BattleCategory(rawValue: category)?.displayName ?? category) · \(questionCount)問")
            .font(.system(size: 11.5))
            .foregroundColor(.secondary)
            .lineLimit(1)
    }
}

func battleRelativeTime(_ milliseconds: Int64) -> String {
    guard milliseconds > 0 else { return "" }
    let elapsed = max(0, Date().timeIntervalSince1970 - Double(milliseconds) / 1_000)
    if elapsed < 3_600 { return "\(max(1, Int(elapsed / 60)))分前" }
    if elapsed < 86_400 { return "\(Int(elapsed / 3_600))時間前" }
    if elapsed < 172_800 { return "きのう" }
    if elapsed < 604_800 { return "\(Int(elapsed / 86_400))日前" }
    return "先週"
}

// MARK: - 招待カード

struct BattleInvitationCard: View {
    let battle: BattleSummary
    let theme: SocialTheme
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("きみ\nの番")
                    .font(.system(size: 10, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .frame(width: 46)
            .frame(maxHeight: .infinity)
            .background(theme.gradient)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    SocialAvatarThumb(
                        imageName: battle.challenger.avatarName,
                        theme: theme,
                        size: 40
                    )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(battle.challenger.name)
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            BattleMetaRow(
                                category: battle.category,
                                questionCount: battle.questions.count,
                                theme: theme
                            )
                            let relative = battleRelativeTime(battle.createdAt)
                            if !relative.isEmpty {
                                Text("· \(relative)に届きました")
                                    .font(.system(size: 11.5))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    Button("辞退") { onDecline() }
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(minWidth: 68, minHeight: SocialMetrics.tapTarget)
                        .background(SocialTone.neutral.background)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                        .buttonStyle(.plain)

                    SocialGradientButton(
                        theme: theme,
                        title: "\(battle.questions.count)問に回答する",
                        icon: "play.fill",
                        accessibilityHintText: "\(battle.questions.count)問のクイズがすぐに始まります",
                        action: onAccept
                    )
                }
            }
            .padding(12)
        }
        .frame(minHeight: 112)
        .socialCard(padding: 0)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .stroke(theme.hairline, lineWidth: 1.5)
        )
    }
}

// MARK: - 対戦招待一覧

/// リーグ画面上部の招待バナーから開く、届いている対戦招待の一覧。
struct BattleInvitationsSheet: View {
    let battles: [BattleSummary]
    var onAccept: (BattleSummary) -> Void
    var onDecline: (BattleSummary) -> Void

    private let theme: SocialTheme = .battle

    @Environment(\.presentationMode) var presentationMode
    @State private var pendingDecline: BattleSummary?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    if battles.isEmpty {
                        SocialEmptyState(
                            theme: theme,
                            icon: "envelope.open",
                            title: "回答待ちの招待はありません",
                            message: "ランキングのメンバーから対戦を申し込めます。"
                        )
                        .socialCard(padding: 0)
                    } else {
                        ForEach(battles) { battle in
                            BattleInvitationCard(
                                battle: battle,
                                theme: theme,
                                onAccept: { onAccept(battle) },
                                onDecline: { pendingDecline = battle }
                            )
                        }
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .socialScreen(theme)
            .navigationTitle("届いている対戦")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .confirmationDialog(
            "この対戦を辞退しますか?",
            isPresented: Binding(get: { pendingDecline != nil }, set: { if !$0 { pendingDecline = nil } }),
            titleVisibility: .visible
        ) {
            if let battle = pendingDecline {
                Button("辞退する", role: .destructive) {
                    pendingDecline = nil
                    onDecline(battle)
                }
            }
            Button("キャンセル", role: .cancel) { pendingDecline = nil }
        } message: {
            Text("この対戦は一覧から削除され、あとから回答できなくなります。")
        }
    }
}

// MARK: - 勝敗

struct BattleOutcome {
    enum Kind { case win, lose, draw, pending }

    let kind: Kind

    init(winnerUid: String?, myUid: String?) {
        guard let winnerUid else { kind = .pending; return }
        if winnerUid == "draw" {
            kind = .draw
        } else if winnerUid == myUid {
            kind = .win
        } else {
            kind = .lose
        }
    }

    var shortLabel: String {
        switch kind {
        case .win: return "WIN"
        case .lose: return "LOSE"
        case .draw: return "DRAW"
        case .pending: return "…"
        }
    }

    var label: String {
        switch kind {
        case .win: return "勝ち"
        case .lose: return "負け"
        case .draw: return "引き分け"
        case .pending: return "結果待ち"
        }
    }

    var icon: String {
        switch kind {
        case .win: return "crown.fill"
        case .lose: return "flag.fill"
        case .draw: return "equal.circle.fill"
        case .pending: return "hourglass"
        }
    }

    var colors: [Color] {
        switch kind {
        case .win: return [Color(hex: "11998e"), Color(hex: "38ef7d")]
        case .lose: return [Color(hex: "8e9aaf"), Color(hex: "6b7688")]
        case .draw: return [Color(hex: "ffa726"), Color(hex: "fb8c00")]
        case .pending: return [Color(hex: "9aa5b4"), Color(hex: "c0c8d4")]
        }
    }
}

// MARK: - 対戦を申し込む

struct BattleChallengeSheet: View {
    let friend: FriendSummary
    let myName: String
    let myAvatarName: String?
    let myRank: Int?
    let opponentRank: Int?
    var onStart: (BattlePlaySession) -> Void

    private let theme: SocialTheme = .battle

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    @State private var isStarting = false
    @State private var errorMessage: String?
    @State private var opponentLevel: Int?
    @State private var usedChallengeCount: Int?
    @State private var myCombatant: BattleCombatantProfile?
    @State private var opponentCombatant: BattleCombatantProfile?
    @State private var isLoadingPreparation = true

    private var battleManager: BattleManager { .shared }
    private var remainingChallengeCount: Int? {
        usedChallengeCount.map { max(0, battleManager.leagueBattleDailyLimit - $0) }
    }
    private var cannotStart: Bool {
        isLoadingPreparation || remainingChallengeCount == 0 || myCombatant == nil || opponentCombatant == nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        versusCard
                        battleRulesCard
                        rewardAndLimitCard

                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(SocialPalette.danger)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, SocialMetrics.screenPadding)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }

                SocialGradientButton(
                    theme: theme,
                    title: remainingChallengeCount == 0
                        ? "本日の挑戦回数を使い切りました"
                        : "\(friend.name)さんに挑戦する",
                    icon: remainingChallengeCount == 0 ? "clock.fill" : "flame.fill",
                    isLoading: isStarting,
                    isDisabled: cannotStart,
                    accessibilityHintText: "\(friend.name)さんを対戦相手に指定して、どちらかのHPがなくなるまで対戦します"
                ) { start() }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 12)
                .background(SocialPalette.cardSurface.opacity(0.96))
                .overlay(alignment: .top) { Divider() }
            }
            .socialScreen(theme)
            .navigationTitle("対戦準備")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .onAppear(perform: loadPreparation)
    }

    private var versusCard: some View {
        HStack(alignment: .center, spacing: 10) {
            competitor(
                name: myName,
                avatarName: myCombatant?.avatarName ?? myAvatarName,
                levelText: "Lv.\(max(1, authManager.level))",
                rank: myRank,
                hp: myCombatant?.maxHP,
                attack: myCombatant?.attack,
                isCurrentUser: true
            )

            VStack(spacing: 4) {
                Text("VS")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "ffe082"))
            }

            competitor(
                name: friend.name,
                avatarName: opponentCombatant?.avatarName ?? friend.featuredAvatarName,
                levelText: opponentLevel.map { "Lv.\($0)" } ?? "Lv.--",
                rank: opponentRank,
                hp: opponentCombatant?.maxHP,
                attack: opponentCombatant?.attack,
                isCurrentUser: false
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
        .background(theme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .shadow(color: theme.accent.opacity(0.28), radius: 14, x: 0, y: 6)
    }

    private func competitor(
        name: String,
        avatarName: String?,
        levelText: String,
        rank: Int?,
        hp: Int?,
        attack: Int?,
        isCurrentUser: Bool
    ) -> some View {
        VStack(spacing: 7) {
            SocialAvatarThumb(imageName: avatarName, theme: theme, size: 68)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                }

            Text(isCurrentUser ? "あなた" : name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(levelText)
                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.92))

            Text(rank.map { "週間リーグ \($0)位" } ?? "週間リーグ 順位未確定")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 5) {
                Text("HP \(hp.map { String($0) } ?? "--")")
                Text("ATK \(attack.map { String($0) } ?? "--")")
            }
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.black.opacity(0.18)))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(isCurrentUser ? "あなた" : name)、\(levelText)、" +
            (rank.map { "週間リーグ\($0)位" } ?? "週間リーグ順位未確定") +
            "、HP\(hp.map { String($0) } ?? "未取得")、攻撃力\(attack.map { String($0) } ?? "未取得")"
        )
    }

    private var battleRulesCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("HPバトル", systemImage: "heart.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(theme.textAccent)
                Spacer()
                Text("即時決着")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(theme.textAccent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(theme.softFill))
            }

            Divider()

            ruleRow(
                icon: "books.vertical.fill",
                text: "ITパスポート・基本情報・応用情報からランダム出題"
            )
            ruleRow(
                icon: "checkmark.circle.fill",
                text: "正解すると自分の攻撃力ぶん、相手のHPにダメージ"
            )
            ruleRow(
                icon: "xmark.circle.fill",
                text: "不正解・時間切れでは相手の攻撃力ぶん、自分のHPにダメージ"
            )
            ruleRow(
                icon: "flag.checkered",
                text: "どちらかのHPが0になるまで問題が続き、その場で勝敗が決まります"
            )
        }
        .padding(16)
        .background(SocialPalette.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                .stroke(theme.hairline, lineWidth: 1)
        }
        .shadow(color: SocialPalette.cardShadow, radius: 10, x: 0, y: 4)
    }

    private func ruleRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.textAccent)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private var rewardAndLimitCard: some View {
        VStack(spacing: 0) {
            preparationInfoRow(
                icon: "trophy.fill",
                title: "勝敗ポイント",
                value: "勝利 +\(battleManager.leagueBattleWinPoints) / 敗北 \(battleManager.leagueBattleLosePoints)",
                tint: Color(hex: "f9a825")
            )

            Divider().padding(.leading, 34)

            preparationInfoRow(
                icon: "arrow.triangle.2.circlepath",
                title: "本日の残り挑戦回数",
                value: isLoadingPreparation
                    ? "確認中…"
                    : "\(remainingChallengeCount ?? battleManager.leagueBattleDailyLimit)/\(battleManager.leagueBattleDailyLimit)回",
                tint: remainingChallengeCount == 0 ? SocialPalette.danger : theme.accent
            )
        }
        .background(SocialPalette.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                .stroke(theme.hairline, lineWidth: 1)
        }
        .shadow(color: SocialPalette.cardShadow, radius: 10, x: 0, y: 4)
    }

    private func preparationInfoRow(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                .foregroundColor(tint)
                .monospacedDigit()
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 52)
        .accessibilityElement(children: .combine)
    }

    private func loadPreparation() {
        guard isLoadingPreparation else { return }
        battleManager.fetchLeagueBattlePreparation(against: friend) { preparation in
            opponentLevel = preparation.opponentLevel
            usedChallengeCount = preparation.usedCount
            myCombatant = preparation.challenger
            opponentCombatant = preparation.opponent
            if preparation.challenger == nil {
                errorMessage = "自分の対戦情報を取得できませんでした。代表おともを選択してから再度お試しください。"
            } else if preparation.opponent == nil {
                errorMessage = "相手の対戦情報を取得できませんでした。時間をおいて再度お試しください。"
            }
            isLoadingPreparation = false
        }
    }

    private func start() {
        isStarting = true
        errorMessage = nil
        BattleManager.shared.startLeagueBattle(against: friend) { result in
            isStarting = false
            switch result {
            case .success(let started):
                dismiss()
                onStart(BattlePlaySession(
                    battleId: started.battleId,
                    questions: started.questions,
                    role: .challenger,
                    player: started.challenger.playerInfo,
                    opponent: started.opponent.playerInfo,
                    category: BattleCategory.leagueMixed.displayName
                ))
            case .failure(let error):
                errorMessage = error.errorDescription
                if case .dailyLimitReached = error {
                    usedChallengeCount = battleManager.leagueBattleDailyLimit
                }
            }
        }
    }
}

// MARK: - プレイセッション

struct BattlePlaySession: Codable, Identifiable {
    let battleId: String
    let questions: [QuizQuestion]
    let role: BattleSummary.Role
    let player: BattlePlayerInfo
    let opponent: BattlePlayerInfo
    let category: String
    var opponentName: String { opponent.name }
    var id: String { battleId + "-" + (role == .challenger ? "c" : "o") }
}

/// 画面が破棄されても、同じ対戦を回答途中から再開するためのチェックポイント。
struct BattlePlayProgressSnapshot: Codable {
    let userId: String
    let session: BattlePlaySession
    let currentIndex: Int
    let answers: [BattleAnswerRecord]
    let selectedIndex: Int?
    let remainingSeconds: Double
    let questionDeadline: Date?
    let showExplanation: Bool
    let playerHP: Int
    let opponentHP: Int
}

enum BattlePlayProgressStore {
    private static let key = "weeklyLeague.activeBattleProgress.v1"

    static func load(for userId: String?) -> BattlePlayProgressSnapshot? {
        guard let userId,
              let data = UserDefaults.standard.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(BattlePlayProgressSnapshot.self, from: data),
              snapshot.userId == userId else {
            return nil
        }
        return snapshot
    }

    static func save(_ snapshot: BattlePlayProgressSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear(battleId: String) {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(BattlePlayProgressSnapshot.self, from: data),
              snapshot.session.battleId == battleId else {
            return
        }
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - バトルプレイ画面

struct BattlePlayView: View {
    let session: BattlePlaySession
    var onFinish: (BattleSummary?) -> Void

    private let theme: SocialTheme = .battle

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var authManager = AuthManager.shared

    @State private var currentIndex = 0
    @State private var answers: [BattleAnswerRecord] = []
    @State private var selectedIndex: Int?
    @State private var remainingSeconds: Double = timeLimit
    @State private var timer: Timer?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var questionAppeared = false
    @State private var showExplanation = false
    @State private var showSettings = false
    @State private var isExplanationEnabled = true
    @State private var playerHP = 0
    @State private var opponentHP = 0
    @State private var questionDeadline: Date?
    @State private var didFinishBattle = false

    private static let timeLimit: Double = 15

    private var currentQuestion: QuizQuestion? {
        session.questions.indices.contains(currentIndex) ? session.questions[currentIndex] : nil
    }

    private var battleEnded: Bool { playerHP <= 0 || opponentHP <= 0 }

    var body: some View {
        ZStack {
            Image("SocialBattleBackground")
                .resizable()
                .scaledToFill()
                .overlay(Color.white.opacity(0.18))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if let question = currentQuestion {
                    Spacer(minLength: 0)

                    VStack(spacing: 0) {
                        QuestionCardView(
                            question: question.question,
                            selectedAnswerIndex: selectedIndex,
                            correctAnswerIndex: question.correctAnswerIndex
                        )
                            .id(currentIndex)
                            .opacity(questionAppeared ? 1 : 0)
                            .offset(y: questionAppeared || reduceMotion ? 0 : 16)
                            .animation(
                                reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.4, dampingFraction: 0.85),
                                value: questionAppeared
                            )
                            .padding(.horizontal, 24)

                        battleArena
                    }

                    Spacer(minLength: 0)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            AnswerSelectionView(
                                choices: question.choices,
                                correctAnswerIndex: selectedIndex == nil ? nil : question.correctAnswerIndex
                            ) { index in
                                select(index: index, question: question)
                            }
                            .id("answers-\(currentIndex)")
                            .allowsHitTesting(selectedIndex == nil)
                            // AnswerSelectionView内の16ptと合わせて、左右24ptの余白にする。
                            .padding(.horizontal, 8)

                            footer
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom)
                }
            }

            if showExplanation, let question = currentQuestion {
                battleExplanation(question)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .zIndex(2)
            }

            if showSettings {
                battleSettings
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .zIndex(3)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .onAppear {
            isExplanationEnabled = authManager.userFlag == 0
            authManager.fetchUserFlag()
            if !restoreProgress() {
                playerHP = session.player.maxHP
                opponentHP = session.opponent.maxHP
                startTimer()
            } else if selectedIndex == nil && !showExplanation && !showSettings && !isSubmitting {
                resumeTimer()
            } else if selectedIndex != nil && !showExplanation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    finishAnsweredQuestion()
                }
            }
            questionAppeared = true
        }
        .onChange(of: authManager.userFlag) { userFlag in
            isExplanationEnabled = userFlag == 0
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                if selectedIndex == nil && !showExplanation && !showSettings && !isSubmitting {
                    resumeTimer()
                }
            case .inactive, .background:
                pauseTimer()
            @unknown default:
                pauseTimer()
            }
        }
        .onDisappear { pauseTimer() }
    }

    private var battleArena: some View {
        VStack(spacing: 0) {
            battleAvatar(
                imageName: session.opponent.avatarName,
                size: isSmallDevice() ? 100 : 160
            )
            .shadow(radius: 10)
            .accessibilityLabel("対戦相手のおとも")

            VStack(spacing: 0) {
                battleHPRow(
                    accessibilityTitle: session.opponent.name,
                    info: session.opponent,
                    hp: opponentHP,
                    tint: Color("hpMonsterColor"),
                    avatarName: nil
                )

                battleHPRow(
                    accessibilityTitle: "あなた",
                    info: session.player,
                    hp: playerHP,
                    tint: Color("hpUserColor"),
                    avatarName: session.player.avatarName
                )
            }
        }
    }

    @ViewBuilder
    private func battleAvatar(imageName: String?, size: CGFloat) -> some View {
        if let imageName, !imageName.isEmpty, UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.48, weight: .semibold))
                .foregroundColor(theme.textAccent.opacity(0.75))
                .frame(width: size, height: size)
        }
    }

    private func battleHPRow(
        accessibilityTitle: String,
        info: BattlePlayerInfo,
        hp: Int,
        tint: Color,
        avatarName: String?
    ) -> some View {
        HStack(spacing: 8) {
            if let avatarName {
                battleAvatar(imageName: avatarName, size: 26)
                    .frame(width: 30, height: 30)
            }

            ProgressBar3(
                value: Double(max(0, hp)),
                maxValue: Double(max(1, info.maxHP)),
                color: tint
            )
            .frame(height: 20)

            Text("\(max(0, hp))/\(info.maxHP)")
                .foregroundColor(.white)
                .monospacedDigit()
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.black.opacity(0.5)))
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(accessibilityTitle)、HP\(max(0, hp))/\(info.maxHP)、攻撃力\(info.attack)")
    }

    // MARK: - ヘッダー(相手・残り時間・進み具合)

    private var header: some View {
        HStack {
            Button {
                generateHapticFeedback()
                pauseTimer()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSettings = true
                }
                persistProgress()
                audioManager.playSound()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 52, height: 52)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color("fontGray"))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("対戦設定")

            Spacer()

            timerRing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .contain)
    }

    private var battleSettings: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: closeSettings)

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 110)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 38))
                        Text("一時停止")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }

                VStack(spacing: 16) {
                    Button {
                        generateHapticFeedback()
                        audioManager.toggleSound()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(theme.accent)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(theme.softFill))
                            Text(audioManager.isMuted ? "効果音をオンにする" : "効果音をオフにする")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(hex: "F8F9FA"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        updateExplanationPreference()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: isExplanationEnabled ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(Color(hex: "4ECDC4"))
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color(hex: "4ECDC4").opacity(0.15)))
                            Text(isExplanationEnabled ? "解説画面を非表示" : "解説画面を表示")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "B2BEC3"))
                        }
                        .padding(14)
                        .background(Color(hex: "F8F9FA"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isExplanationEnabled ? "解説画面を非表示にする" : "解説画面を表示する")

                    Button(action: closeSettings) {
                        Label("対戦に戻る", systemImage: "play.fill")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                            .background(theme.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
    }

    private func closeSettings() {
        generateHapticFeedback()
        withAnimation(.easeInOut(duration: 0.2)) {
            showSettings = false
        }
        resumeTimer()
        audioManager.playCancelSound()
    }

    private func updateExplanationPreference() {
        generateHapticFeedback()
        isExplanationEnabled.toggle()
        let userFlag = isExplanationEnabled ? 0 : 1
        authManager.userFlag = userFlag
        if let userId = authManager.currentUserId {
            authManager.updateUserFlag(userId: userId, userFlag: userFlag)
        }
        audioManager.playSound()
    }

    private var timerRing: some View {
        TimerView(
            remainingSeconds: Binding(
                get: { Int(ceil(remainingSeconds)) },
                set: { _ in }
            ),
            totalSeconds: Int(Self.timeLimit)
        )
        .accessibilityLabel("残り\(Int(ceil(remainingSeconds)))秒")
    }

    // MARK: - 学習モードと共通の解説フロー

    private func battleExplanation(_ question: QuizQuestion) -> some View {
        ZStack {
            Color.black.opacity(0.70)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: selectedIndex == question.correctAnswerIndex ? "circle" : "xmark")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(selectedIndex == question.correctAnswerIndex ? .red : .blue)
                        Text(selectedIndex == question.correctAnswerIndex ? "正解" : selectedIndex == -1 ? "時間切れ" : "不正解")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                    }

                    explanationSection(title: "問題内容", text: question.question)
                    explanationSection(title: "あなたの回答", text: selectedAnswerText(for: question))
                    explanationSection(title: "正解", text: question.choices[safe: question.correctAnswerIndex] ?? "")
                    explanationSection(title: "解説", text: question.explanation)

                    Button {
                        generateHapticFeedback()
                        AudioManager.shared.playCancelSound()
                        advance()
                    } label: {
                        HStack {
                            Spacer()
                            Text(battleEnded || currentIndex + 1 >= session.questions.count ? "勝敗を確定" : "次の問題へ")
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "chevron.right")
                            Spacer()
                        }
                        .foregroundColor(Color("fontGray"))
                        .frame(minHeight: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 10)
                .padding(20)
            }
        }
    }

    private func explanationSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray)
                    .frame(width: 6, height: 20)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("fontGray"))
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("fontGray"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func selectedAnswerText(for question: QuizQuestion) -> String {
        guard let selectedIndex, selectedIndex >= 0 else { return "時間切れ（未回答）" }
        return question.choices[safe: selectedIndex] ?? "未回答"
    }

    // MARK: - フッター(送信状態とエラー復帰)

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 10) {
            if isSubmitting {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text("結果を送信しています…")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            if let errorMessage {
                VStack(spacing: 8) {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "ff8a80"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        Button {
                            generateHapticFeedback()
                            self.errorMessage = nil
                            submit()
                        } label: {
                            Text("もう一度送信")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(Color(hex: "2b2d5c"))
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: SocialMetrics.tapTarget)
                                .background(Capsule().fill(Color.white))
                        }
                        .buttonStyle(.plain)

                        Button {
                            generateHapticFeedback()
                            onFinish(nil)
                        } label: {
                            Text("閉じる")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: SocialMetrics.tapTarget)
                                .background(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - 進行

    private func select(index: Int, question: QuizQuestion) {
        guard selectedIndex == nil else { return }
        generateHapticFeedback()
        selectedIndex = index
        timer?.invalidate()
        questionDeadline = nil
        let correct = index == question.correctAnswerIndex
        applyDamage(correct: correct)
        if correct {
            AudioManager.shared.playCorrectSound()
        } else {
            AudioManager.shared.playUnCorrectSound()
        }
        let elapsed = Self.timeLimit - remainingSeconds
        answers.append(BattleAnswerRecord(correct: correct, seconds: elapsed))
        persistProgress()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            finishAnsweredQuestion()
        }
    }

    private func startTimer() {
        remainingSeconds = Self.timeLimit
        resumeTimer()
    }

    private func resumeTimer() {
        guard selectedIndex == nil, !showExplanation, !showSettings, !isSubmitting else { return }
        timer?.invalidate()
        let deadline = Date().addingTimeInterval(max(0, remainingSeconds))
        questionDeadline = deadline
        persistProgress()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            remainingSeconds = max(0, deadline.timeIntervalSinceNow)
            if remainingSeconds <= 0 {
                t.invalidate()
                questionDeadline = nil
                if selectedIndex == nil {
                    selectedIndex = -1
                    applyDamage(correct: false)
                    answers.append(BattleAnswerRecord(correct: false, seconds: Self.timeLimit))
                    persistProgress()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        finishAnsweredQuestion()
                    }
                }
            }
        }
    }

    private func pauseTimer() {
        if let questionDeadline {
            remainingSeconds = max(0, questionDeadline.timeIntervalSinceNow)
        }
        timer?.invalidate()
        timer = nil
        questionDeadline = nil
        persistProgress()
    }

    private func finishAnsweredQuestion() {
        if isExplanationEnabled {
            withAnimation(.easeInOut(duration: 0.2)) {
                showExplanation = true
            }
            persistProgress()
        } else {
            advance()
        }
    }

    private func advance() {
        showExplanation = false
        selectedIndex = nil
        if battleEnded {
            persistProgress()
            submit()
        } else if currentIndex + 1 < session.questions.count {
            questionAppeared = false
            currentIndex += 1
            startTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                questionAppeared = true
            }
        } else {
            persistProgress()
            submit()
        }
    }

    private func submit() {
        isSubmitting = true
        switch session.role {
        case .challenger:
            BattleManager.shared.finishLeagueHPBattle(battleId: session.battleId, answers: answers) { result in
                isSubmitting = false
                switch result {
                case .success(let summary):
                    didFinishBattle = true
                    BattlePlayProgressStore.clear(battleId: session.battleId)
                    onFinish(summary)
                case .failure(let error):
                    errorMessage = error.errorDescription
                }
            }
        case .opponent:
            BattleManager.shared.submitOpponentResult(battleId: session.battleId, answers: answers) { result in
                isSubmitting = false
                switch result {
                case .success(let summary):
                    didFinishBattle = true
                    BattlePlayProgressStore.clear(battleId: session.battleId)
                    onFinish(summary)
                case .failure(let error):
                    errorMessage = error.errorDescription
                }
            }
        }
    }

    private func applyDamage(correct: Bool) {
        if correct {
            opponentHP = max(0, opponentHP - session.player.attack)
        } else {
            playerHP = max(0, playerHP - session.opponent.attack)
        }
    }

    private func persistProgress() {
        guard !didFinishBattle, let userId = authManager.currentUserId else { return }
        BattlePlayProgressStore.save(BattlePlayProgressSnapshot(
            userId: userId,
            session: session,
            currentIndex: currentIndex,
            answers: answers,
            selectedIndex: selectedIndex,
            remainingSeconds: remainingSeconds,
            questionDeadline: questionDeadline,
            showExplanation: showExplanation,
            playerHP: playerHP,
            opponentHP: opponentHP
        ))
    }

    @discardableResult
    private func restoreProgress() -> Bool {
        guard let snapshot = BattlePlayProgressStore.load(for: authManager.currentUserId),
              snapshot.session.id == session.id,
              session.questions.indices.contains(snapshot.currentIndex),
              snapshot.answers.count <= session.questions.count else {
            return false
        }
        currentIndex = snapshot.currentIndex
        answers = snapshot.answers
        selectedIndex = snapshot.selectedIndex
        remainingSeconds = min(Self.timeLimit, max(0, snapshot.remainingSeconds))
        showExplanation = snapshot.showExplanation
        playerHP = min(session.player.maxHP, max(0, snapshot.playerHP))
        opponentHP = min(session.opponent.maxHP, max(0, snapshot.opponentHP))
        questionDeadline = snapshot.questionDeadline

        if let deadline = snapshot.questionDeadline, selectedIndex == nil {
            remainingSeconds = min(remainingSeconds, max(0, deadline.timeIntervalSinceNow))
        }
        return true
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 結果画面

struct BattleResultView: View {
    let summary: BattleSummary
    var onClose: () -> Void

    private let theme: SocialTheme = .battle

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var myUid: String? { AuthManager.shared.currentUserId }
    private var isChallenger: Bool { myUid == summary.challenger.uid }
    private var me: BattlePlayerInfo? { isChallenger ? summary.challenger : summary.opponent }
    private var rival: BattlePlayerInfo? { isChallenger ? summary.opponent : summary.challenger }
    private var outcome: BattleOutcome { BattleOutcome(winnerUid: summary.winnerUid, myUid: myUid) }
    private var myLeaguePoints: Int { isChallenger ? summary.challengerLeaguePoints : summary.opponentLeaguePoints }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: SocialMetrics.stackSpacing) {
                    outcomeBanner
                    scoreCard
                    breakdownCard

                    SocialGradientButton(theme: theme, title: "閉じる", icon: "xmark") {
                        onClose()
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .socialScreen(theme)
            .navigationTitle("対戦結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { onClose() }
                        .accessibilityHint("結果を閉じて一覧に戻ります")
                }
            }
            .onAppear {
                appeared = true
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - 勝敗バナー

    private var outcomeBanner: some View {
        VStack(spacing: 6) {
            Image(systemName: outcome.icon)
                .font(.system(size: 34))
                .foregroundColor(.white)
            Text(outcome.shortLabel)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(outcomeMessage)
                .font(.footnote.weight(.medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            if myLeaguePoints != 0 {
                rewardChip(
                    icon: myLeaguePoints > 0 ? "trophy.fill" : "arrow.down.circle.fill",
                    text: "リーグP \(myLeaguePoints > 0 ? "+" : "")\(myLeaguePoints)"
                )
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 16)
        .background(
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: outcome.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 150, height: 150)
                    .offset(x: 50, y: -70)
            }
        )
        .cornerRadius(DesignTokens.Radius.xl)
        .shadow(color: outcome.colors[0].opacity(0.35), radius: 14, x: 0, y: 6)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.94)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7), value: appeared)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(outcome.label)。\(outcomeMessage)")
    }

    private func rewardChip(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.24))
            .clipShape(Capsule())
    }

    private var outcomeMessage: String {
        let rivalName = rival?.name ?? "相手"
        switch outcome.kind {
        case .win: return "\(rivalName)に勝ちました!"
        case .lose: return "\(rivalName)に惜敗。次はリベンジしよう"
        case .draw: return "\(rivalName)と互角の勝負でした"
        case .pending: return "\(rivalName)の回答を待っています"
        }
    }

    // MARK: - スコア

    private var scoreCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                scoreColumn(title: "あなた", info: me, highlight: outcome.kind == .win)
                Text("VS")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundColor(.secondary)
                    .frame(width: 34)
                scoreColumn(title: rival?.name ?? "相手", info: rival, highlight: outcome.kind == .lose)
            }

            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                Text("相手より先にHPを0にした方が勝利です")
                    .font(.caption2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .socialCard(padding: 14)
    }

    private func scoreColumn(title: String, info: BattlePlayerInfo?, highlight: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            SocialAvatarThumb(imageName: info?.avatarName, theme: theme, size: 54)
            Text("\(max(0, info?.remainingHP ?? info?.maxHP ?? 0)) / \(info?.maxHP ?? 0)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(highlight ? SocialPalette.success : .primary)
                .monospacedDigit()
            Text("残りHP")
                .font(.caption2)
                .foregroundColor(.secondary)
            SocialTagChip(
                text: "攻撃力 \(info?.attack ?? 0)",
                icon: "bolt.fill",
                tone: .neutral
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(highlight ? SocialTone.success.background : Color.clear)
        .cornerRadius(DesignTokens.Radius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(title)。残りHP\(max(0, info?.remainingHP ?? info?.maxHP ?? 0))/\(info?.maxHP ?? 0)、攻撃力\(info?.attack ?? 0)"
        )
    }

    // MARK: - 問題ごとの結果

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "chart.bar.fill", title: "問題ごとの結果")

            HStack {
                Text("あなた")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("ダメージ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            VStack(spacing: 8) {
                ForEach(0..<(me?.answers.count ?? 0), id: \.self) { index in
                    breakdownRow(index: index)
                }
            }
        }
        .socialCard()
    }

    private func breakdownRow(index: Int) -> some View {
        let mine = me?.answers[safe: index]
        return HStack(spacing: 10) {
            Text("Q\(index + 1)")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.secondary)
                .frame(width: 26, alignment: .leading)

            resultMark(record: mine)
            Text(secondsText(mine))
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)

            Spacer(minLength: 4)
            Text(mine?.correct == true ? "相手へ \(me?.attack ?? 0)ダメージ" : "自分へ \(rival?.attack ?? 0)ダメージ")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(mine?.correct == true ? SocialPalette.success : SocialPalette.danger)
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "第\(index + 1)問。あなたは\(mine?.correct == true ? "正解" : "不正解")\(secondsText(mine))"
        )
    }

    private func secondsText(_ record: BattleAnswerRecord?) -> String {
        guard let record else { return "—" }
        return String(format: "%.1f秒", record.seconds)
    }

    private func resultMark(record: BattleAnswerRecord?) -> some View {
        Image(systemName: record?.correct == true ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.subheadline)
            .foregroundColor(record?.correct == true ? SocialPalette.success : SocialPalette.danger)
            .accessibilityHidden(true)
    }
}

// MARK: - プレビュー

#if DEBUG
enum BattlePreviewFixtures {
    static func question(_ index: Int) -> QuizQuestion {
        QuizQuestion(
            question: "サンプル問題\(index):IT用語として正しいものはどれでしょうか。",
            choices: ["選択肢A", "選択肢B", "選択肢C", "選択肢D"],
            correctAnswerIndex: 1,
            explanation: "解説文のサンプルです。"
        )
    }

    static var questions: [QuizQuestion] { (1...5).map(question) }

    static func summary(winnerUid: String?) -> BattleSummary {
        let challengerPoints: Int
        let opponentPoints: Int
        switch winnerUid {
        case "me": challengerPoints = 15; opponentPoints = 0
        case "rival": challengerPoints = 0; opponentPoints = 15
        case "draw": challengerPoints = 5; opponentPoints = 5
        default: challengerPoints = 0; opponentPoints = 0
        }
        return BattleSummary(
            id: "preview-battle",
            category: BattleCategory.itPassport.rawValue,
            questions: questions,
            challenger: BattlePlayerInfo(
                uid: "me",
                name: "あなた",
                avatarName: nil,
                answers: [
                    BattleAnswerRecord(correct: true, seconds: 3.2),
                    BattleAnswerRecord(correct: true, seconds: 4.8),
                    BattleAnswerRecord(correct: false, seconds: 9.1),
                    BattleAnswerRecord(correct: true, seconds: 2.7),
                    BattleAnswerRecord(correct: true, seconds: 5.5)
                ]
            ),
            opponent: BattlePlayerInfo(
                uid: "rival",
                name: "ライバル",
                avatarName: nil,
                answers: [
                    BattleAnswerRecord(correct: true, seconds: 4.0),
                    BattleAnswerRecord(correct: false, seconds: 8.2),
                    BattleAnswerRecord(correct: true, seconds: 6.4),
                    BattleAnswerRecord(correct: true, seconds: 3.9),
                    BattleAnswerRecord(correct: false, seconds: 15.0)
                ]
            ),
            status: "finished",
            createdAt: 0,
            winnerUid: winnerUid,
            challengerLeaguePoints: challengerPoints,
            opponentLeaguePoints: opponentPoints
        )
    }
}

struct BattleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 10) {
                    BattleInvitationCard(
                        battle: BattlePreviewFixtures.summary(winnerUid: nil),
                        theme: .battle,
                        onAccept: {},
                        onDecline: {}
                    )
                }
                .padding()
            }
            .socialScreen(.battle)
            .previewDisplayName("対戦カード / ライト")

            BattleResultView(summary: BattlePreviewFixtures.summary(winnerUid: "me")) {}
                .preferredColorScheme(.dark)
                .previewDisplayName("結果(勝ち) / ダーク")

            BattleChallengeSheet(
                friend: FriendSummary(
                    id: "rival",
                    name: "コード・レイ",
                    level: 31,
                    featuredAvatarName: "ネッキー",
                    featuredAvatarAttack: 0,
                    canBorrowToday: false
                ),
                myName: "あなた",
                myAvatarName: "ぴょこん",
                myRank: 5,
                opponentRank: 2
            ) { _ in }
            .previewDisplayName("対戦準備")
        }
    }
}
#endif
