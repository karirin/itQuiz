//
//  GuerrillaLobbyView.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI

struct GuerrillaLobbyView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager: AudioManager
    @StateObject private var guerrillaManager = GuerrillaManager()
    @Binding var isPresenting: Bool

    @State private var navigateToBattle = false
    @State private var showError = false
    @State private var remainingTimeText = ""
    @State private var refreshTimer: Timer? = nil
    @State private var showGuerrillaHelp = false

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.22),
                    Color(red: 0.06, green: 0.04, blue: 0.14)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    if guerrillaManager.status == "active" {
                        // ゲリラ開催中
                        activeGuerrillaView
                    } else if guerrillaManager.status == "completed" {
                        // ゲリラ終了
                        completedGuerrillaView
                    } else {
                        // ゲリラなし
                        noGuerrillaView
                    }
                }
                .padding(.bottom, 40)
            }

            // バトル画面への遷移
            NavigationLink("",
                destination: GuerrillaBattleView(
                    guerrillaManager: guerrillaManager,
                    authManager: authManager,
                    audioManager: audioManager,
                    isPresenting: $isPresenting
                ).navigationBarBackButtonHidden(true),
                isActive: $navigateToBattle
            )

            // チュートリアル / ヘルプモーダル
            if showGuerrillaHelp {
                GuerrillaHelpModalView(isPresented: $showGuerrillaHelp)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationTitle("ゲリラボス")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ゲリラボス")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showGuerrillaHelp = true }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            guerrillaManager.observeActiveGuerrilla()
            guerrillaManager.spawnGuerrillaIfNeeded()
            authManager.fetchUsedAvatars { _ in }
            if !UserDefaults.standard.bool(forKey: "hasSeenGuerrillaTutorial") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showGuerrillaHelp = true
                }
                UserDefaults.standard.set(true, forKey: "hasSeenGuerrillaTutorial")
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(guerrillaManager.errorMessage)
        }
    }

    // MARK: - ゲリラ開催中

    private var activeGuerrillaView: some View {
        VStack(spacing: 20) {
            // ゲリラ出現バナー
            EmptyView()
                .padding(.top, 8)

            // ボスカード
            VStack(spacing: 12) {
                // 難易度
                HStack {
                    Spacer()
                    Text(guerrillaManager.difficulty)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(difficultyColor)
                        )
                }
                .padding(.horizontal)

                // ボス画像
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.red.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)

                    Image(guerrillaManager.bossImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .shadow(color: .red.opacity(0.5), radius: 20)
                }

                // ボス名
                Text(guerrillaManager.bossName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // HPバー
                VStack(spacing: 4) {
                    ProgressView(value: max(0, Double(guerrillaManager.bossHP)), total: Double(guerrillaManager.bossMaxHP))
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
                        .scaleEffect(x: 1, y: 2.5, anchor: .center)
                        .padding(.horizontal, 30)

                    Text("HP  \(guerrillaManager.bossHP) / \(guerrillaManager.bossMaxHP)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }

                // 参加者数
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(guerrillaManager.playerCount) 人が参戦中")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)

            // 参加 or バトルボタン
            if guerrillaManager.isParticipating {
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playSound()
                    navigateToBattle = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                        Text("バトルに戻る")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
            } else {
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playSound()
                    joinGuerrilla()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.title3)
                        Text("参戦する！")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
            }

            // ダメージランキング
            if !guerrillaManager.players.isEmpty {
                damageRankingSection
            }

            // 報酬情報
            rewardInfoSection
        }
    }

    // MARK: - ダメージランキング

    private var damageRankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("ダメージランキング")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("TOP \(min(guerrillaManager.playerCount, 10))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            ForEach(Array(guerrillaManager.players.prefix(10).enumerated()), id: \.element.id) { index, player in
                let isMe = player.id == guerrillaManager.currentUserId
                let displayAvatarName = player.avatarName.isEmpty && isMe
                    ? (authManager.usedAvatars.first?.name ?? "")
                    : player.avatarName
                HStack(spacing: 10) {
                    // アバター + 順位バッジ
                    ZStack(alignment: .bottomTrailing) {
                        if displayAvatarName.isEmpty {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.4))
                                )
                        } else {
                            Image(displayAvatarName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        }
                        Circle()
                            .fill(rankColor(index: index))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }

                    // 名前
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(player.userName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            if player.id == guerrillaManager.currentUserId {
                                Text("自分")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill(Color.yellow.opacity(0.2)))
                            }
                        }
                        Text("Lv.\(player.level)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // ダメージ
                    Text("\(player.totalDamage)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                    Text("ダメージ")
                        .font(.system(size: 11))
                        .foregroundColor(.orange.opacity(0.7))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(player.id == guerrillaManager.currentUserId
                              ? Color.yellow.opacity(0.08)
                              : Color.white.opacity(0.03))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .padding(.horizontal)
    }

    // MARK: - 報酬情報

    private var rewardInfoSection: some View {
        let baseItemRewards = GuerrillaRewardPlanner.baseRewards(forDifficulty: guerrillaManager.difficulty)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.purple)
                Text("報酬")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                rewardRow(rank: "1位 (MVP)", expMultiplier: "1.5x", color: .yellow)
                rewardRow(rank: "2位〜3位", expMultiplier: "1.0x", color: .white)
                rewardRow(rank: "4位以降", expMultiplier: "貢献度に応じて", color: .white.opacity(0.6))
            }

            if !baseItemRewards.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("アイテム報酬")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    HStack(spacing: 8) {
                        ForEach(Array(baseItemRewards.enumerated()), id: \.offset) { entry in
                            let reward = entry.element
                            HStack(spacing: 6) {
                                InventoryItemArtworkView(type: reward.type, width: 26, height: 26, cornerRadius: 8)
                                Text("\(reward.type.shortName)x\(reward.amount)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }

                    Text("※ 上位3名はスタミナ回復薬 x1、MVPはさらにブースト薬 x1")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.45))
                }
            }

            Text("※ 報酬はダメージ貢献度に応じて分配されます")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .padding(.horizontal)
    }

    private func rewardRow(rank: String, expMultiplier: String, color: Color) -> some View {
        HStack {
            Text(rank)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
            Spacer()
            Text("経験値 \(guerrillaManager.rewardExperience) × \(expMultiplier)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - ゲリラ終了

    private var completedGuerrillaView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("ゲリラ終了！")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("次のゲリラボスの出現をお待ちください")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))

            // 結果を表示（参加していた場合）
            if !guerrillaManager.players.isEmpty {
                damageRankingSection
            }

            Spacer()
        }
    }

    // MARK: - ゲリラなし

    private var noGuerrillaView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 120, height: 120)

                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
            }

            Text("現在ゲリラボスは出現していません")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))

            Text("ゲリラボスはゲリラ的に出現します\nしばらくお待ちください")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - ヘルパー

    private var backButton: some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playCancelSound()
            guerrillaManager.stopObserving()
            isPresenting = false
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("戻る")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    private func joinGuerrilla() {
        authManager.fetchUserInfo { (name, avatar, _, _, _, _) in
            let userName = name ?? "プレイヤー"
            let avatarName = (avatar?.first?["name"] as? String) ?? ""
            guerrillaManager.joinGuerrilla(userName: userName, level: authManager.level, avatarName: avatarName) { success in
                if success {
                    navigateToBattle = true
                } else {
                    showError = true
                }
            }
        }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let seconds = guerrillaManager.remainingTime
            let min = seconds / 60
            let sec = seconds % 60
            remainingTimeText = String(format: "%02d:%02d", min, sec)
        }
    }

    private var difficultyColor: Color {
        switch guerrillaManager.difficulty {
        case "初級": return .green
        case "中級": return .orange
        case "上級": return .red
        default: return .gray
        }
    }

    private func rankColor(index: Int) -> Color {
        switch index {
        case 0: return .orange
        case 1: return .gray
        case 2: return .brown
        default: return Color.white.opacity(0.15)
        }
    }
}

// MARK: - ゲリラボス ヘルプモーダル

struct GuerrillaHelpModalView: View {
    @Binding var isPresented: Bool

    private let items: [(icon: String, color: Color, title: String, desc: String)] = [
        ("bolt.fill",        .yellow,  "ゲリラ出現",     "ゲリラボスはランダムで出現します。学習一覧に出現ボタンが表示されたら参戦チャンス！"),
        ("figure.run",       .green,   "参戦方法",       "「参戦する！」ボタンで参加登録。参加後はバトル画面で問題に答えてボスにダメージを与えよう。"),
        ("flame.fill",       .orange,  "ダメージ",       "正解するとボスにダメージ。連続正解でコンボが発動し、ダメージが倍増します。"),
        ("trophy.fill",      .yellow,  "報酬",           "ボス討伐後、与えたダメージ量に応じて経験値とコインが分配されます。1位（MVP）はボーナスあり！"),
        ("person.3.fill",    .cyan,    "みんなで協力",   "ゲリラボスはすべてのユーザーが共有する強敵。協力してHPをゼロにしよう。"),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("ゲリラボスとは？")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider().background(Color.white.opacity(0.15))

                // コンテンツ
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(items, id: \.title) { item in
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(item.color.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: item.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(item.color)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(item.desc)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(20)
                }

                // 閉じるボタン
                Button(action: { isPresented = false }) {
                    Text("わかった！")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                        )
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.65)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.08, blue: 0.22))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 24)
        }
    }
}
