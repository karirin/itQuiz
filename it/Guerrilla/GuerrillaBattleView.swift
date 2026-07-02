//
//  GuerrillaBattleView.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI
import AVFoundation

struct GuerrillaBattleView: View {
    @ObservedObject var guerrillaManager: GuerrillaManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager: AudioManager
    @Binding var isPresenting: Bool

    @State private var selectedAnswerIndex: Int? = nil
    @State private var currentQuizIndex: Int = 0
    @State private var hasAnswered: Bool = false
    @State private var quizResults: [QuizResult] = []

    // プレイヤーHP（ローカル管理）
    @State private var playerHP: Int = 100
    @State private var playerMaxHP: Int = 100
    @State private var userAttack: Int = 30
    @State private var avatarLoaded: Bool = false

    // コンボ
    @State private var comboCount: Int = 0
    @State private var comboPulse: Bool = false

    // エフェクト
    @State private var showAttackImage: Bool = false
    @State private var showMonsterDownImage: Bool = false
    @State private var showIncorrectBackground: Bool = false

    // 終了
    @State private var navigateToResult: Bool = false

    // モーダル
    @State private var showHomeModal: Bool = false
    @State private var isSoundOn: Bool = true

    var currentQuiz: QuizQuestion? {
        guard currentQuizIndex < guerrillaManager.quizzes.count else { return nil }
        return guerrillaManager.quizzes[currentQuizIndex]
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 背景画像
                Image("ゲリラボス背景")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // ヘッダー: 設定ボタン
                    HStack {
                        Button(action: {
                            generateHapticFeedback()
                            showHomeModal.toggle()
                            audioManager.playSound()
                        }) {
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
                        .foregroundColor(.gray)
                        Spacer()
                    }

                    Spacer()

                    VStack {
                        // 問題カード
                        if let quiz = currentQuiz {
                            QuestionCardView(
                                question: quiz.question,
                                selectedAnswerIndex: selectedAnswerIndex,
                                correctAnswerIndex: quiz.correctAnswerIndex
                            )
                            .padding(.horizontal, 16)

                            // モンスター画像 + コンボバッジ
                            ZStack {
                                Image(guerrillaManager.bossImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(radius: 10)
                                    .frame(width: isSmallDevice() ? 100 : 160)

                                if let selected = selectedAnswerIndex {
                                    if selected == quiz.correctAnswerIndex {
                                        if showAttackImage {
                                            Image("attack1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: isSmallDevice() ? 80 : 130)
                                        }
                                    }
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
                                        isPulsing: comboPulse
                                    )
                                    .offset(x: isSmallDevice() ? 90 : 120, y: 40)
                                    .transition(.scale.combined(with: .opacity))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: comboCount)
                                }
                            }
                            .frame(height: isSmallDevice() ? 100 : 160)

                            // HPバー
                            ZStack {
                                VStack {
                                    // ボスHP
                                    HStack {
                                        ProgressBar3(value: Double(max(0, guerrillaManager.bossHP)), maxValue: Double(guerrillaManager.bossMaxHP), color: Color("hpMonsterColor"))
                                            .frame(height: 20)
                                        Text("\(max(0, guerrillaManager.bossHP))/\(guerrillaManager.bossMaxHP)")
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 3)
                                            .foregroundColor(Color(.white))
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(30)
                                    }
                                    .padding(.horizontal)

                                    // プレイヤーHP
                                    HStack {
                                        if !avatarLoaded {
                                            ProgressView()
                                                .frame(width: 30, height: 30)
                                        } else if let avatarName = authManager.usedAvatars.first?.name {
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
                                            .foregroundColor(Color(.white))
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(30)
                                    }
                                    .padding(.horizontal)
                                }

                                // 不正解時のモンスター攻撃エフェクト
                                if let selected = selectedAnswerIndex, selected != quiz.correctAnswerIndex {
                                    if showAttackImage {
                                        Image("beginnerMonsterAttack1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 90)
                                            .padding(.bottom, -30)
                                    }
                                }
                            }

                            // 参加者ダメージバー（ゲリラ専用）
                            playersBar
                        }
                    }

                    Spacer()

                    // 回答ボタン
                    if let quiz = currentQuiz {
                        ScrollView {
                            VStack {
                                AnswerSelectionView(choices: quiz.choices, correctAnswerIndex: hasAnswered ? quiz.correctAnswerIndex : nil) { index in
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
                .background(showIncorrectBackground ? Color(.red).opacity(0.1) : Color(.white).opacity(0))

                // ホームモーダル（RankModalViewと同じデザイン）
                if showHomeModal {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        GuerrillaHomeModalView(
                            isSoundOn: $isSoundOn,
                            isPresented: $showHomeModal,
                            isPresenting: $isPresenting,
                            audioManager: audioManager
                        )
                    }
                }

                // 結果画面への遷移
                NavigationLink("",
                    destination: GuerrillaResultView(
                        guerrillaManager: guerrillaManager,
                        authManager: authManager,
                        audioManager: audioManager,
                        results: quizResults,
                        isPresenting: $isPresenting
                    ).navigationBarBackButtonHidden(true),
                    isActive: $navigateToResult
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupBattle()
        }
        .onChange(of: guerrillaManager.status) { newStatus in
            if newStatus == "completed" {
                handleBossDefeated()
            }
        }
        .onChange(of: guerrillaManager.bossHP) { newHP in
            if newHP <= 0 && !navigateToResult {
                handleBossDefeated()
            }
        }
    }

    // MARK: - 参加者バー（ゲリラ専用）

    private var playersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(guerrillaManager.players) { player in
                    let isMe = player.id == guerrillaManager.currentUserId
                    let displayAvatarName = player.avatarName.isEmpty && isMe
                        ? (authManager.usedAvatars.first?.name ?? "")
                        : player.avatarName
                    HStack(spacing: 6) {
                        Group {
                            if displayAvatarName.isEmpty {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            } else {
                                Image(displayAvatarName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .clipShape(Circle())
                            }
                        }
                        .overlay(Circle().stroke(isMe ? Color.orange : Color.clear, lineWidth: 1.5))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(player.userName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text("\(player.totalDamage) ダメージ")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(isMe ? .yellow : .white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isMe ? Color.orange.opacity(0.85) : Color.black.opacity(0.65))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isMe ? Color.orange : Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .background(Color.black.opacity(0.4))
    }

    // MARK: - 初期設定

    private func setupBattle() {
        authManager.fetchUsedAvatars { usedAvatars in
            let avatarAttack = usedAvatars.first?.attack ?? 0
            let avatarHealth = usedAvatars.first?.health ?? 0
            self.avatarLoaded = true
            authManager.fetchUserInfo { (_, _, _, hp, attack, _) in
                let baseAttack = attack ?? 20
                let baseHp = hp ?? 100
                self.userAttack = baseAttack + avatarAttack
                self.playerMaxHP = baseHp + avatarHealth
                self.playerHP = self.playerMaxHP
            }
        }
    }

    // MARK: - ボス撃破処理

    private func handleBossDefeated() {
        showMonsterDownImage = true
        audioManager.playGameClearSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            navigateToResult = true
        }
    }

    // MARK: - 回答処理

    private func answerSelectionAction(index: Int) {
        guard let quiz = currentQuiz, !hasAnswered else { return }
        hasAnswered = true
        selectedAnswerIndex = index

        let isCorrect = index == quiz.correctAnswerIndex
        authManager.recordAnswer(isCorrect: isCorrect)

        if isCorrect {
            audioManager.playCorrectSound()
            let damage = comboAdjustedDamage()

            comboCount += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                audioManager.playAttackSound()
                showAttackImage = true
                registerSuccessfulCombo()
                guerrillaManager.attackBoss(damage: damage) { _ in }
            }

            quizResults.append(QuizResult(
                question: quiz.question,
                userAnswer: quiz.choices[index],
                correctAnswer: quiz.choices[quiz.correctAnswerIndex],
                explanation: quiz.explanation,
                isCorrect: true
            ))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guerrillaManager.incrementTotalCount()
                if playerHP <= 0 {
                    navigateToResult = true
                    return
                }
                moveToNextQuiz()
            }
        } else {
            audioManager.playUnCorrectSound()

            comboCount = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                audioManager.playMonsterAttackSound()
                playerHP -= guerrillaManager.bossAttack
                showAttackImage = true
                showIncorrectBackground = true
            }

            quizResults.append(QuizResult(
                question: quiz.question,
                userAnswer: quiz.choices[index],
                correctAnswer: quiz.choices[quiz.correctAnswerIndex],
                explanation: quiz.explanation,
                isCorrect: false
            ))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showIncorrectBackground = false
                guerrillaManager.incrementTotalCount()
                if playerHP <= 0 {
                    navigateToResult = true
                    return
                }
                moveToNextQuiz()
            }
        }
    }

    private func moveToNextQuiz() {
        if guerrillaManager.bossHP <= 0 { return }

        if currentQuizIndex + 1 < guerrillaManager.quizzes.count {
            currentQuizIndex += 1
            selectedAnswerIndex = nil
            hasAnswered = false
            showAttackImage = false
            showIncorrectBackground = false
        } else {
            navigateToResult = true
        }
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
}

// MARK: - ゲリラ用ホームモーダル（RankModalViewと同じデザイン）

struct GuerrillaHomeModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("メニュー")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("fontGray"))
                    .padding(.top, 4)

                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
                    isPresenting = false
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: "667eea").opacity(0.12))
                                .frame(width: 40, height: 40)

                            Image(systemName: "house.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "667eea"))
                        }

                        Text("ホームに戻る")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("fontGray"))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding(12)
                    .background(Color(hex: "f5f7fa"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .overlay(
                Button(action: {
                    generateHapticFeedback()
                    isPresented = false
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white, Color.black.opacity(0.35))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 8, y: -8),
                alignment: .topTrailing
            )
        }
    }
}
