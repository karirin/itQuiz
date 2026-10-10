//
//  GuildBossBattleView.swift
//  it
//
//  ギルド画面から直接挑戦する、ギルドボス専用のバトル画面です。
//  問題演習画面(QuizView)やゲリラボス画面(GuerrillaBattleView)と同じ
//  「モンスターHP + 問題カード + 選択肢」のデザイン言語をそのまま踏襲し、
//  正解のたびにGuildManager経由でギルド共有のボスHPへダメージを反映します。
//
//  ボスHP自体はギルドに所属した時点からGuildManagerが常時観測しているため、
//  この画面はGuildManager.shared.raidを読むだけで他メンバーの攻撃も
//  リアルタイムに反映されます。プレイヤー自身のHPやコンボはこの画面だけの
//  ローカル状態で、通常のクイズ画面と同様にFirebaseへは保存しません。
//

import SwiftUI

struct GuildBossBattleView: View {
    @ObservedObject private var guildManager = GuildManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @StateObject private var interstitial = Interstitial()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var isPresenting: Bool

    private enum Phase: Equatable {
        case fighting
        case victory
        case defeat
        case alreadyResolved
    }

    @State private var phase: Phase = .fighting
    @State private var quizzes: [QuizQuestion] = []
    @State private var currentQuizIndex = 0
    @State private var selectedAnswerIndex: Int?
    @State private var hasAnswered = false
    @State private var quizResults: [QuizResult] = []
    @State private var navigateToQuizResultView = false

    // プレイヤーHP・攻撃力(ローカル管理。問題演習画面と同じ考え方)
    @State private var playerHP: Int = 100
    @State private var playerMaxHP: Int = 100
    @State private var userAttack: Int = 30
    @State private var bossAttackValue: Int = 20
    @State private var avatarLoaded = false
    @State private var avatarName: String?
    @State private var activeHelper: ActiveHelper?

    // コンボ
    @State private var comboCount = 0
    @State private var comboPulse = false

    // エフェクト
    @State private var showAttackImage = false
    @State private var showMonsterDownImage = false
    @State private var showIncorrectBackground = false

    // このセッションでの成果(結果表示用。ギルドの合計はGuildManager側で管理)
    @State private var sessionDamage = 0
    @State private var sessionCorrectCount = 0

    @State private var showSettingsModal = false
    @State private var showExplanationModal = false
    @State private var isExplanationEnabled = true

    private var currentQuiz: QuizQuestion? {
        quizzes.indices.contains(currentQuizIndex) ? quizzes[currentQuizIndex] : nil
    }

    private var bossName: String { guildManager.raid?.bossName.isEmpty == false ? guildManager.raid!.bossName : "ギルドボス" }
    private var bossImageName: String { guildManager.raid?.bossImageName ?? "" }
    private var bossHP: Int { max(0, guildManager.raid?.bossHP ?? 0) }
    private var bossMaxHP: Int { max(1, guildManager.raid?.bossMaxHP ?? 1) }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("ゲリラボス背景")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    header
                    Spacer()

                    if phase == .fighting, let quiz = currentQuiz {
                        battleContent(quiz: quiz)
                    }

                    Spacer()

                    if phase == .fighting, let quiz = currentQuiz {
                        ScrollView {
                            VStack {
                                AnswerSelectionView(
                                    choices: quiz.choices,
                                    correctAnswerIndex: hasAnswered ? quiz.correctAnswerIndex : nil
                                ) { index in
                                    answerSelectionAction(index: index)
                                }
                                .frame(maxWidth: .infinity)
                                .shadow(radius: 1)

                                Spacer()
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                    }
                }
                .background(showIncorrectBackground ? Color.red.opacity(0.1) : Color.white.opacity(0))

                if showSettingsModal {
                    GuildBossSettingsModalView(
                        isPresented: $showSettingsModal,
                        isExplanationEnabled: $isExplanationEnabled,
                        audioManager: audioManager,
                        onToggleExplanation: updateExplanationPreference
                    )
                }

                if showExplanationModal,
                   let quiz = currentQuiz,
                   let selectedIndex = selectedAnswerIndex,
                   quiz.choices.indices.contains(selectedIndex),
                   quiz.choices.indices.contains(quiz.correctAnswerIndex) {
                    GuildBossExplanationModalView(
                        isPresented: $showExplanationModal,
                        question: quiz.question,
                        userAnswer: quiz.choices[selectedIndex],
                        correctAnswer: quiz.choices[quiz.correctAnswerIndex],
                        explanation: quiz.explanation,
                        isCorrect: selectedIndex == quiz.correctAnswerIndex,
                        onContinue: moveToNextQuiz,
                        onDisableExplanation: disableExplanationAndContinue
                    )
                }

                // 開始前に他メンバーが討伐した場合だけ、専用の案内を表示する。
                // 実際に戦った後は通常の問題結果画面へ遷移する。
                if phase == .alreadyResolved {
                    resultOverlay
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToQuizResultView) {
                QuizResultView(
                    results: quizResults,
                    authManager: authManager,
                    isPresenting: $isPresenting,
                    navigateToQuizResultView: $navigateToQuizResultView,
                    playerExperience: 0,
                    playerMoney: 0,
                    elapsedTime: 0,
                    quizBossLevel: .none,
                    quizLevel: .daily,
                    interstitial: interstitial,
                    isCleared: phase == .victory
                )
                .navigationBarBackButtonHidden(true)
            }
            .onAppear(perform: setupBattle)
            .onChange(of: guildManager.raid?.bossHP) { newValue in
                guard phase == .fighting, let hp = newValue, hp <= 0 else { return }
                handleVictory()
            }
            .onChange(of: authManager.userFlag) { userFlag in
                isExplanationEnabled = userFlag == 0
            }
            .onChange(of: phase) { newPhase in
                guard newPhase == .victory || newPhase == .defeat else { return }
                navigateToQuizResultView = true
            }
        }
    }

    // MARK: - ヘッダー

    private var header: some View {
        HStack {
            Button {
                generateHapticFeedback()
                audioManager.playSound()
                showSettingsModal = true
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
            .padding(.leading)
            .accessibilityLabel("設定")
            .accessibilityHint("解説画面の表示設定を変更できます")

            Spacer()

            if phase == .fighting, !quizzes.isEmpty {
                Text("第\(currentQuizIndex + 1)問")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .padding(.trailing)
                    .accessibilityLabel("\(currentQuizIndex + 1)問目")
            }
        }
    }

    // MARK: - バトル本体(問題演習画面と同じ構成)

    private func battleContent(quiz: QuizQuestion) -> some View {
        VStack {
            QuestionCardView(
                question: quiz.question,
                selectedAnswerIndex: selectedAnswerIndex,
                correctAnswerIndex: quiz.correctAnswerIndex
            )
            .padding(.horizontal, 16)

            // ボス画像 + コンボバッジ
            ZStack {
                if !bossImageName.isEmpty, UIImage(named: bossImageName) != nil {
                    Image(bossImageName)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 10)
                        .frame(width: isSmallDevice() ? 100 : 160)
                } else {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(width: isSmallDevice() ? 70 : 110)
                }

                if let selected = selectedAnswerIndex, selected == quiz.correctAnswerIndex, showAttackImage {
                    Image("attack1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: isSmallDevice() ? 80 : 130)
                }

                if showMonsterDownImage {
                    Image("倒す")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                }

                if comboCount >= 2 {
                    MonsterComboBadgeView(
                        comboCount: comboCount,
                        multiplier: MonsterComboSystem.multiplier(for: comboCount),
                        isPulsing: reduceMotion ? false : comboPulse
                    )
                    .offset(x: isSmallDevice() ? 65 : 90, y: 32)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: comboCount)
                }
            }
            .frame(height: isSmallDevice() ? 100 : 160)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(bossName)。残りHP\(bossHP)、最大\(bossMaxHP)")

            // HPバー
            ZStack {
                VStack {
                    HStack {
                        ProgressBar3(value: Double(bossHP), maxValue: Double(bossMaxHP), color: Color("hpMonsterColor"))
                            .frame(height: 20)
                        Text("\(bossHP)/\(bossMaxHP)")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    .accessibilityHidden(true)

                    HStack {
                        if !avatarLoaded {
                            ProgressView()
                                .frame(width: 30, height: 30)
                        } else if let avatarName {
                            Image(avatarName)
                                .resizable()
                                .frame(width: 30, height: 30)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        }
                        ProgressBar3(value: Double(max(0, playerHP)), maxValue: Double(playerMaxHP), color: Color("hpUserColor"))
                            .frame(height: 20)
                        Text("\(max(0, playerHP))/\(playerMaxHP)")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("あなたの残りHP\(max(0, playerHP))、最大\(playerMaxHP)")

                    if let activeHelper {
                        HStack(spacing: 7) {
                            Image(activeHelper.avatarName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                            Text("\(activeHelper.ownerName)の助っ人と共闘中（攻撃+\(activeHelper.attackBonus)）")
                                .font(.system(size: 11, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(SocialTheme.friend.gradient)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(activeHelper.ownerName)さんの助っ人と共闘中。攻撃力プラス\(activeHelper.attackBonus)")
                    }
                }

                if let selected = selectedAnswerIndex, selected != quiz.correctAnswerIndex, showAttackImage {
                    Image("beginnerMonsterAttack1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        .padding(.bottom, -30)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    // MARK: - 初期設定

    private func setupBattle() {
        guard let raid = guildManager.raid, raid.status == "active", raid.bossHP > 0 else {
            phase = .alreadyResolved
            return
        }
        isExplanationEnabled = authManager.userFlag == 0
        authManager.fetchUserFlag()
        if let boss = guildRaidBosses.first(where: { $0.name == raid.bossName }) {
            bossAttackValue = boss.bossAttack
        }
        loadQuizBatch()
        let helper = FriendManager.shared.consumeActiveHelperIfNeeded()
        activeHelper = helper

        authManager.fetchUsedAvatars { usedAvatars in
            let avatarAttack = usedAvatars.first?.attack ?? 0
            let avatarHealth = usedAvatars.first?.health ?? 0
            avatarName = usedAvatars.first?.name
            avatarLoaded = true
            authManager.fetchUserInfo { (_, _, _, hp, attack, _) in
                let baseAttack = attack ?? 20
                let baseHp = hp ?? 100
                userAttack = baseAttack + avatarAttack + (helper?.attackBonus ?? 0)
                playerMaxHP = baseHp + avatarHealth
                playerHP = playerMaxHP
            }
        }
    }

    private func loadQuizBatch() {
        quizzes = Self.combinedQuizPool().shuffled()
        currentQuizIndex = 0
        selectedAnswerIndex = nil
        hasAnswered = false
    }

    private static func combinedQuizPool() -> [QuizQuestion] {
        let categories: [BattleCategory] = [.itPassport, .security, .fundamentalInfo, .appliedInfo]
        var seenQuestions = Set<String>()
        return categories
            .flatMap { $0.questionPool }
            .filter { seenQuestions.insert($0.question).inserted }
    }

    // MARK: - 撃破処理

    private func handleVictory() {
        showMonsterDownImage = true
        audioManager.playGameClearSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            phase = .victory
        }
    }

    // MARK: - 回答処理

    private func answerSelectionAction(index: Int) {
        guard phase == .fighting, let quiz = currentQuiz, !hasAnswered else { return }
        hasAnswered = true
        selectedAnswerIndex = index

        let isCorrect = index == quiz.correctAnswerIndex
        if quiz.choices.indices.contains(index), quiz.choices.indices.contains(quiz.correctAnswerIndex) {
            quizResults.append(
                QuizResult(
                    question: quiz.question,
                    userAnswer: quiz.choices[index],
                    correctAnswer: quiz.choices[quiz.correctAnswerIndex],
                    explanation: quiz.explanation,
                    isCorrect: isCorrect
                )
            )
        }
        authManager.recordAnswer(isCorrect: isCorrect)

        if isCorrect {
            audioManager.playCorrectSound()
            let damage = comboAdjustedDamage()
            comboCount += 1
            sessionDamage += damage
            sessionCorrectCount += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                audioManager.playAttackSound()
                showAttackImage = true
                registerSuccessfulCombo()
                guildManager.attackRaidBossIfPossible(damage: damage)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard phase == .fighting, bossHP > 0 else { return }
                finishAnsweredQuestion()
            }
        } else {
            audioManager.playUnCorrectSound()
            comboCount = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                audioManager.playMonsterAttackSound()
                playerHP -= bossAttackValue
                showAttackImage = true
                showIncorrectBackground = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showIncorrectBackground = false
                guard phase == .fighting else { return }
                if playerHP <= 0 {
                    phase = .defeat
                    return
                }
                finishAnsweredQuestion()
            }
        }
    }

    private func finishAnsweredQuestion() {
        guard phase == .fighting else { return }
        if isExplanationEnabled {
            showExplanationModal = true
        } else {
            moveToNextQuiz()
        }
    }

    private func updateExplanationPreference() {
        isExplanationEnabled.toggle()
        let userFlag = isExplanationEnabled ? 0 : 1
        authManager.userFlag = userFlag
        if let userId = authManager.currentUserId {
            authManager.updateUserFlag(userId: userId, userFlag: userFlag)
        }
    }

    private func disableExplanationAndContinue() {
        guard phase == .fighting else { return }
        isExplanationEnabled = false
        authManager.userFlag = 1
        if let userId = authManager.currentUserId {
            authManager.updateUserFlag(userId: userId, userFlag: 1)
        }
        moveToNextQuiz()
    }

    private func moveToNextQuiz() {
        guard phase == .fighting else { return }

        if currentQuizIndex + 1 >= quizzes.count {
            let nextRound = Self.combinedQuizPool().shuffled()
            guard !nextRound.isEmpty else { return }
            quizzes.append(contentsOf: nextRound)
        }

        currentQuizIndex += 1
        selectedAnswerIndex = nil
        hasAnswered = false
        showAttackImage = false
        showIncorrectBackground = false
    }

    // MARK: - コンボ

    private func comboAdjustedDamage() -> Int {
        let multiplier = MonsterComboSystem.multiplier(for: comboCount + 1)
        return max(Int((Double(userAttack) * multiplier).rounded()), userAttack)
    }

    private func registerSuccessfulCombo() {
        comboPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            comboPulse = false
        }
    }

    // MARK: - 結果オーバーレイ

    @ViewBuilder
    private var resultOverlay: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()
            resultCard
                .padding(.horizontal, 28)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96)))
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: phase)
    }

    private var resultCard: some View {
        VStack(spacing: 16) {
            Image(systemName: resultIcon)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(resultTint)

            Text(resultTitle)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Text(resultMessage)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if phase != .alreadyResolved {
                HStack(spacing: 10) {
                    statPill(value: "\(sessionDamage)", label: "与えたダメージ")
                    statPill(value: "\(sessionCorrectCount)", label: "正解数")
                }
            }

            VStack(spacing: 10) {
                Button {
                    generateHapticFeedback()
                    dismiss()
                } label: {
                    Text("閉じる")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                        .background(SocialTheme.guild.gradient)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 12)
        .accessibilityElement(children: .contain)
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)\(value)")
    }

    private var resultIcon: String {
        switch phase {
        case .victory: return "crown.fill"
        case .defeat: return "flag.fill"
        case .alreadyResolved: return "checkmark.seal.fill"
        case .fighting: return "flame.fill"
        }
    }

    private var resultTint: Color {
        switch phase {
        case .victory: return Color(hex: "11998e")
        case .defeat: return Color(hex: "f5576c")
        case .alreadyResolved: return Color(hex: "38ef7d")
        case .fighting: return .orange
        }
    }

    private var resultTitle: String {
        switch phase {
        case .victory: return "ギルドボスを討伐した!"
        case .defeat: return "力尽きた…"
        case .alreadyResolved: return "すでに決着しています"
        case .fighting: return ""
        }
    }

    private var resultMessage: String {
        switch phase {
        case .victory:
            return "ギルドの仲間と一緒に\(bossName)を倒しました。ギルドミッションの進捗にも反映されます。"
        case .defeat:
            return "HPが0になりました。ここまでに与えたダメージはギルドにそのまま反映されています。"
        case .alreadyResolved:
            return guildManager.raid?.status == "completed"
                ? "ギルドボスはすでに討伐されています。100問正解して次のボスを召喚しましょう。"
                : "ギルドボスの情報を確認できませんでした。時間をおいて開き直してください。"
        case .fighting:
            return ""
        }
    }
}

// MARK: - 設定モーダル(学習モードと同じデザイン)

private struct GuildBossSettingsModalView: View {
    @Binding var isPresented: Bool
    @Binding var isExplanationEnabled: Bool
    @ObservedObject var audioManager: AudioManager
    var onToggleExplanation: () -> Void

    @State private var showContent = false
    @State private var showMenuButton = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: dismissModal)

            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 8) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                        Text("一時停止")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 24)
                }
                .frame(height: 120)

                VStack(spacing: 12) {
                    MenuButton(
                        icon: isExplanationEnabled ? "eye.slash.fill" : "eye.fill",
                        title: isExplanationEnabled ? "解説画面を非表示" : "解説画面を表示",
                        iconColor: Color(hex: "4ECDC4"),
                        action: {
                            generateHapticFeedback()
                            onToggleExplanation()
                            audioManager.playSound()
                        }
                    )
                    .scaleEffect(showMenuButton ? 1 : 0.8)
                    .opacity(showMenuButton ? 1 : 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)

                Button(action: dismissModal) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("クイズに戻る")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(showContent ? 1 : 0.9)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showMenuButton = true
                }
            }
        }
    }

    private func dismissModal() {
        generateHapticFeedback()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            audioManager.playCancelSound()
        }
    }
}

// MARK: - 解説モーダル

private struct GuildBossExplanationModalView: View {
    @Binding var isPresented: Bool
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let explanation: String
    let isCorrect: Bool
    let onContinue: () -> Void
    let onDisableExplanation: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(isCorrect ? Color.green : Color.red)
                    Text(isCorrect ? "正解" : "不正解")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3436"))
                    Spacer()

                    Button {
                        generateHapticFeedback()
                        isPresented = false
                        onDisableExplanation()
                    } label: {
                        Label("今後は非表示", systemImage: "eye.slash.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "636E72"))
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        explanationSection(title: "問題内容", text: question)
                        explanationSection(title: "あなたの回答", text: userAnswer)
                        explanationSection(title: "正解", text: correctAnswer)
                        explanationSection(title: "解説", text: explanation)
                    }
                }

                Button {
                    generateHapticFeedback()
                    isPresented = false
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("次の問題へ")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(20)
            .frame(maxHeight: 620)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .padding(.horizontal, 20)
        }
    }

    private func explanationSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "667eea"))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "2D3436"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(12)
    }
}

// MARK: - プレビュー

#if DEBUG
struct GuildBossBattleView_Previews: PreviewProvider {
    static var previews: some View {
        GuildBossBattleView(isPresenting: .constant(true))
            .previewDisplayName("ギルドボス戦")
    }
}
#endif
