//
//  GuerrillaResultView.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI

struct GuerrillaResultView: View {
    @ObservedObject var guerrillaManager: GuerrillaManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager: AudioManager
    let results: [QuizResult]
    @Binding var isPresenting: Bool

    @State private var showContent = false
    @State private var hasAwardedRewards = false
    @State private var selectedTab = 0

    private var isVictory: Bool {
        guerrillaManager.bossHP <= 0
    }

    private var myPlayer: GuerrillaPlayer? {
        guerrillaManager.players.first { $0.id == guerrillaManager.currentUserId }
    }

    private var mvpPlayer: GuerrillaPlayer? {
        guerrillaManager.players.max(by: { $0.totalDamage < $1.totalDamage })
    }

    private var myReward: (experience: Int, money: Int) {
        guard let me = myPlayer else { return (5, 5) }
        return guerrillaManager.rewardForPlayer(me)
    }

    private var guerrillaItemRewards: [InventoryReward] {
        guard myPlayer != nil else { return [] }
        return GuerrillaRewardPlanner.rewards(
            forDifficulty: guerrillaManager.difficulty,
            rank: guerrillaManager.myRank,
            isVictory: isVictory
        )
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: isVictory
                    ? [Color(red: 0.15, green: 0.1, blue: 0.05), Color(red: 0.1, green: 0.08, blue: 0.02)]
                    : [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    resultHeader
                    if isVictory { rewardCard }
                    tabSelector
                    if selectedTab == 0 {
                        contributionList
                    } else {
                        answerDetailList
                    }
                }
                .padding(.bottom, 100)
            }

            // 戻るボタン
            VStack {
                Spacer()
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    guerrillaManager.stopObserving()
                    isPresenting = false
                }) {
                    Text("ホームに戻る")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showContent = true
            }

            if !hasAwardedRewards {
                hasAwardedRewards = true
                // ゲリラ参加のミッション進捗
                authManager.recordGuerrillaParticipation()
                if isVictory {
                    // ゲリラ1位勝利のミッション進捗
                    if guerrillaManager.myRank == 1 {
                        authManager.recordGuerrillaWin()
                    }
                    audioManager.playGameClearSound()
                    authManager.addExperience(points: myReward.experience, onSuccess: {}, onFailure: { _ in })
                    authManager.addMoney(amount: myReward.money)
                    if !guerrillaItemRewards.isEmpty {
                        authManager.addItems(guerrillaItemRewards)
                    }
                } else {
                    audioManager.playGameOverSound()
                    authManager.addExperience(points: 5, onSuccess: {}, onFailure: { _ in })
                    authManager.addMoney(amount: 5)
                }
            }
        }
    }

    // MARK: - 結果ヘッダー

    private var resultHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isVictory ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)

                Image(systemName: isVictory ? "trophy.fill" : "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(isVictory ? .orange : .red)
                    .scaleEffect(showContent ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
            }

            Text(isVictory ? "ゲリラボス撃破！" : "ゲリラボス討伐失敗...")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.4), value: showContent)

            HStack(spacing: 8) {
                Image(guerrillaManager.bossImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(guerrillaManager.bossName)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeInOut(duration: 0.5).delay(0.5), value: showContent)

            // 自分の順位
            if let _ = myPlayer, isVictory {
                HStack(spacing: 4) {
                    Text("あなたの順位:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(guerrillaManager.myRank)位")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(guerrillaManager.myRank == 1 ? .yellow : .orange)
                    if guerrillaManager.myRank == 1 {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.6), value: showContent)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - 報酬カード

    private var rewardCard: some View {
        VStack(spacing: 16) {
            Text("獲得報酬")
                .font(.headline)
                .foregroundColor(.white)

            if guerrillaManager.myRank == 1 {
                Text("MVP ボーナス 1.5x！")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.yellow.opacity(0.2)))
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Image("経験値")
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("+\(myReward.experience)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text("経験値")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 4) {
                    Image("コイン")
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("+\(myReward.money)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("コイン")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            if !guerrillaItemRewards.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("追加アイテム")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))

                    ForEach(Array(guerrillaItemRewards.enumerated()), id: \.offset) { entry in
                        let reward = entry.element
                        HStack(spacing: 10) {
                            InventoryItemArtworkView(type: reward.type, width: 34, height: 34, cornerRadius: 10)

                            Text(reward.type.displayName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text("x\(reward.amount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(reward.type.accentColor)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5).delay(0.7), value: showContent)
    }

    // MARK: - タブ切り替え

    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "貢献度ランキング", index: 0, systemImage: "chart.bar.fill")
            tabButton(title: "回答詳細", index: 1, systemImage: "list.bullet")
        }
        .padding(.horizontal)
    }

    private func tabButton(title: String, index: Int, systemImage: String) -> some View {
        Button(action: {
            generateHapticFeedback()
            withAnimation(.spring()) { selectedTab = index }
        }) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .medium))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedTab == index ? Color.orange : Color.clear)
            )
        }
    }

    // MARK: - 貢献度一覧

    private var contributionList: some View {
        VStack(spacing: 10) {
            ForEach(Array(guerrillaManager.players.enumerated()), id: \.element.id) { index, player in
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(rankColor(index: index))
                            .frame(width: 30, height: 30)
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    if index == 0 && isVictory {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(player.userName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            if player.id == guerrillaManager.currentUserId {
                                Text("自分")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill(Color.yellow.opacity(0.2)))
                            }
                        }
                        if player.totalCount > 0 {
                            Text("\(player.correctCount)/\(player.totalCount) 正解")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(player.totalDamage)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                        Text("ダメージ")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.6))
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(player.id == guerrillaManager.currentUserId
                              ? Color.yellow.opacity(0.08)
                              : Color.white.opacity(0.04))
                )
            }
        }
        .padding(.horizontal)
    }

    private func rankColor(index: Int) -> Color {
        switch index {
        case 0: return .orange
        case 1: return .gray
        case 2: return .brown
        default: return Color.white.opacity(0.15)
        }
    }

    // MARK: - 回答詳細

    private var answerDetailList: some View {
        LazyVStack(spacing: 8) {
            ForEach(results.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    Image(systemName: results[index].isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(results[index].isCorrect ? .green : .red)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Q\(index + 1): \(results[index].question)")
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(2)
                            .foregroundColor(.white)

                        if !results[index].isCorrect {
                            Text("正解: \(results[index].correctAnswer)")
                                .font(.system(size: 11))
                                .foregroundColor(.green.opacity(0.8))
                        }
                    }
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.04))
                )
            }
        }
        .padding(.horizontal)
    }
}
