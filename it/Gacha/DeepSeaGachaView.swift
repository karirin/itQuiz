import SwiftUI

/// 深海ガチャ。支払いとおとも付与が確定してから召喚演出へ進む。
struct DeepSeaGachaView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @StateObject private var reward = Reward()
    @Environment(\.dismiss) private var dismiss

    private let gachaManager = GachaManager(mode: .deepSea)
    @State private var userMoney = 0
    @State private var isDrawing = false
    @State private var summon: DeepSeaGachaDraw?
    @State private var result: DeepSeaGachaDraw?
    @State private var showCoinModal = false
    @State private var activeAlert: DeepSeaGachaAlert?
    @State private var pendingTitle: String?

    var body: some View {
        ZStack {
            if let result {
                GachaResultView(
                    item: result.item,
                    gachaCost: gachaManager.gachaCost,
                    onClose: { self.result = nil },
                    onPlayAgain: drawGacha,
                    isNew: result.isNew
                )
            } else {
                lobby
            }

            if showCoinModal {
                CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
            }

            if isDrawing {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("召喚を準備中…")
                    .tint(GachaTheme.goldLight)
                    .foregroundColor(GachaTheme.text)
                    .padding(24)
                    .background(GachaTheme.surface, in: RoundedRectangle(cornerRadius: GachaTheme.cornerRadius))
                    .accessibilityLabel("召喚を準備中")
            }
        }
        .allowsHitTesting(!isDrawing)
        .onAppear {
            refreshPlayerResources()
            reward.LoadReward()
        }
        .fullScreenCover(item: $summon, onDismiss: presentPendingTitle) { draw in
            GachaAnimationView(rarity: draw.item.rarity, item: draw.item) {
                result = draw
                summon = nil
                refreshPlayerResources()
            }
        }
        .alert(
            activeAlert?.title ?? "",
            isPresented: Binding(
                get: { activeAlert != nil },
                set: { if !$0 { activeAlert = nil } }
            ),
            presenting: activeAlert
        ) { alert in
            switch alert {
            case .insufficientCoins:
                if reward.rewardLoaded {
                    Button("広告を見る（300コイン）") { reward.ShowReward() }
                }
                Button("コインを購入") { showCoinModal = true }
                Button("キャンセル", role: .cancel) {}
            case .saveFailed, .coinReward, .collectionTitle:
                Button("OK") {}
            }
        } message: { alert in
            Text(alert.message(cost: gachaManager.gachaCost))
        }
        .onChange(of: reward.rewardEarned) { earned in
            if earned {
                refreshPlayerResources()
                reward.rewardEarned = false
                activeAlert = .coinReward
            }
        }
        .onChange(of: showCoinModal) { _ in refreshPlayerResources() }
    }

    private var lobby: some View {
        GachaLobbyScreen(
            gachaTitle: "深海ガチャ",
            heroImageName: "深海王 リヴァイアス",
            backgroundImageName: "",
            ticketType: nil,
            ticketCount: 0,
            userMoney: userMoney,
            cost: gachaManager.gachaCost,
            isDrawEnabled: !isDrawing && userMoney >= gachaManager.gachaCost,
            rewardLoaded: reward.rewardLoaded,
            catalogItems: gachaManager.catalogItems,
            onBack: {
                audioManager.playCancelSound()
                dismiss()
            },
            onCoinTap: { showCoinModal = true },
            onDraw: drawGacha,
            onTicketDraw: {},
            onRewardAd: {
                if reward.rewardLoaded { reward.ShowReward() }
            }
        )
    }

    private func drawGacha() {
        // 連打や保存待ち中の再抽選で、複数の支払いが走るのを防ぐ。
        guard !isDrawing, summon == nil else { return }
        guard userMoney >= gachaManager.gachaCost else {
            activeAlert = .insufficientCoins
            refreshPlayerResources()
            return
        }
        guard let item = gachaManager.drawGacha() else {
            activeAlert = .saveFailed
            return
        }

        isDrawing = true
        let draw = DeepSeaGachaDraw(
            item: item,
            isNew: !authManager.avatars.contains { $0.name == item.name }
        )
        let avatar = Avatar(name: item.name, attack: item.attack, health: item.health, usedFlag: 0, count: 1)

        authManager.commitGachaResult(avatar: avatar, coinCost: gachaManager.gachaCost) { success in
            isDrawing = false
            guard success else {
                activeAlert = authManager.money < gachaManager.gachaCost ? .insufficientCoins : .saveFailed
                refreshPlayerResources()
                return
            }

            userMoney = authManager.money
            audioManager.playSound()
            authManager.recordGachaUsed()
            summon = draw
            authManager.fetchAvatars { checkCollectionTitle() }
        }
    }

    private func refreshPlayerResources() {
        authManager.getUserMoney { userMoney = $0 }
    }

    private func checkCollectionTitle() {
        guard let userID = authManager.currentUserId else { return }
        let count = authManager.avatars.count
        for (threshold, title) in [(10, "おとも１０種類制覇"), (20, "おとも２０種類制覇")] where count >= threshold {
            authManager.checkTitles(userId: userID, title: title) { exists in
                guard !exists else { return }
                authManager.saveTitleForUser(userId: userID, title: title)
                pendingTitle = title
                if summon == nil { presentPendingTitle() }
            }
        }
    }

    private func presentPendingTitle() {
        if let title = pendingTitle {
            activeAlert = .collectionTitle(title)
            pendingTitle = nil
        }
    }
}

private struct DeepSeaGachaDraw: Identifiable {
    let id = UUID()
    let item: GachaManager.Item
    let isNew: Bool
}

private enum DeepSeaGachaAlert {
    case insufficientCoins
    case saveFailed
    case coinReward
    case collectionTitle(String)

    var title: String {
        switch self {
        case .insufficientCoins: return "コインが足りません"
        case .saveFailed: return "ガチャを引けませんでした"
        case .coinReward: return "300コイン獲得しました"
        case .collectionTitle: return "称号獲得！"
        }
    }

    func message(cost: Int) -> String {
        switch self {
        case .insufficientCoins: return "深海ガチャを引くには\(cost)コインが必要です。"
        case .saveFailed: return "ガチャの確定に失敗しました。通信状態を確認して再度お試しください。"
        case .coinReward: return "学習や冒険で集めたコインでも召喚できます。"
        case .collectionTitle(let title): return title
        }
    }
}

#Preview {
    DeepSeaGachaView()
}
