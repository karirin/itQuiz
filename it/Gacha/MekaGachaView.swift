//
//  MekaGachaView.swift
//  it
//
//  Created by Apple on 2025/12/14.
//

import SwiftUI
import Firebase

struct MekaGachaView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var gachaManager = GachaManager(mode: .meka)
    
    @State private var userMoney: Int = 0
    @State private var isGachaButtonDisabled: Bool = false
    @State private var obtainedRareItem: GachaManager.Item?
    @State private var obtainedItem: GachaManager.Item?
    /// 結果画面の NEW 表示用（抽選前の所持状態で判定）
    @State private var obtainedIsNew: Bool = false
    
    @State private var showAnimation: Bool = false
    @State private var showResult: Bool = false
    @State private var showCoinModal: Bool = false
    @State private var showUnCoinModal: Bool = false
    
    @State private var otomo10flag: Bool = false
    @State private var otomo20flag: Bool = false
    @State private var showTitleModal: Bool = false
    @State private var obtainedTitle: String = ""
    
    @State private var showRewardAlert: Bool = false
    @State private var showTicketErrorAlert: Bool = false
    @State private var ticketErrorMessage: String = ""
    
    @ObservedObject var audioManager = AudioManager.shared
    @StateObject var reward = Reward()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCoinOptionsAlert: Bool = false
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Color2")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !showResult {
                // ガチャ初期画面
                gachaMainView
            } else {
                // 結果画面
                GachaResultView(
                    item: obtainedItem,
                    gachaCost: gachaManager.gachaCost,
                    onClose: {
                        showResult = false
                        obtainedItem = nil
                    },
                    onPlayAgain: {
                        // 結果画面を閉じずにガチャを再実行
                        obtainedItem = nil  // アイテムだけクリア
                        
                        guard userMoney >= gachaManager.gachaCost else {
                            showUnCoinModal = true
                            return
                        }
                        performGachaDraw(coinCost: gachaManager.gachaCost, resetResult: false)
                    },
                    isNew: obtainedIsNew
                )
            }
            VStack{
                if showCoinModal {
                    if showUnCoinModal {
                        VStack{
                            HStack{
                                Image("コインが無い")
                                    .resizable()
                                    .frame(width:70,height: 70)
                                VStack(alignment: .leading, spacing:15){
                                    HStack{
                                        Text("コインが足りません")
                                        Spacer()
                                    }
                                    Text("ご購入することもできます")
                                        .font(.system(size: isSmallDevice() ? 17 : 18))
                                }
                                
                            }.padding()
                        }.frame(width: isSmallDevice() ? 330: 340, height:120)
                            .background(Color("Color2"))
                            .font(.system(size: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                    CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
                }
            }
        }
        .onAppear {
            refreshPlayerResources()
            reward.LoadReward()
        }
        .fullScreenCover(isPresented: $showAnimation) {
            if let rarity = obtainedRareItem?.rarity {
                GachaAnimationView(rarity: rarity, item: obtainedRareItem) {
                    showAnimation = false
                    obtainedItem = obtainedRareItem
                    showResult = true
                    refreshPlayerResources()
                }
            }
        }
        .alert("コインが足りません", isPresented: $showUnCoinModal) {
            if authManager.mekaGachaTicketCount > 0 {
                Button("チケットで引く") {
                    startGachaWithTicket()
                }
            }
            Button(action: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                } else {
                    // リワード広告が読み込まれていない場合
                    showCoinModal = true
                }
            }) {
                Text(reward.rewardLoaded ? "広告を見る (300コイン)" : "広告を読み込み中...")
            }
            Button("コインを購入") {
                showCoinModal = true
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ガチャを引くには\(gachaManager.gachaCost)コインが必要です")
        }
        .alert("300コイン獲得しました。", isPresented: $showRewardAlert) {
            Button("OK") {
                refreshPlayerResources()
            }
        }
        .alert("ガチャを引けませんでした", isPresented: $showTicketErrorAlert) {
            Button("OK") {}
        } message: {
            Text(ticketErrorMessage)
        }
        .alert("称号獲得!", isPresented: $showTitleModal) {
            Button("OK") {}
        } message: {
            Text(obtainedTitle)
        }
        .onChange(of: reward.rewardEarned) { rewardEarned in
            showRewardAlert = rewardEarned
            if rewardEarned {
                refreshPlayerResources()
                reward.rewardEarned = false
            }
        }
        .onChange(of: showCoinModal) { _ in
            refreshPlayerResources()
        }
    }
    
    private var gachaMainView: some View {
        GachaLobbyScreen(
            gachaTitle: "メカガチャ",
            heroImageName: "メカガチャトップ",
            backgroundImageName: "MekaGachaSceneBackground",
            ticketType: .mekaGachaTicket,
            ticketCount: authManager.mekaGachaTicketCount,
            userMoney: userMoney,
            cost: gachaManager.gachaCost,
            isDrawEnabled: isGachaButtonDisabled,
            rewardLoaded: reward.rewardLoaded,
            catalogItems: gachaManager.catalogItems,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
                audioManager.playCancelSound()
            },
            onCoinTap: {
                showCoinModal = true
            },
            onDraw: startGacha,
            onTicketDraw: startGachaWithTicket,
            onRewardAd: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                }
            }
        )
    }
    
    private func startGacha() {
        guard userMoney >= gachaManager.gachaCost else {
            showUnCoinModal = true
            return
        }
        performGachaDraw(coinCost: gachaManager.gachaCost)
    }

    private func startGachaWithTicket() {
        guard authManager.mekaGachaTicketCount > 0 else {
            ticketErrorMessage = "メカガチャチケットがありません。"
            showTicketErrorAlert = true
            refreshPlayerResources()
            return
        }

        performGachaDraw(ticketType: .mekaGachaTicket)
    }

    private func performGachaDraw(
        coinCost: Int = 0,
        ticketType: InventoryItemType? = nil,
        resetResult: Bool = true
    ) {
        gachaManager.shuffleItems()
        guard let item = gachaManager.drawGacha() else {
            ticketErrorMessage = "ガチャ結果を取得できませんでした。"
            showTicketErrorAlert = true
            return
        }

        let avatar = Avatar(
            name: item.name,
            attack: item.attack,
            health: item.health,
            usedFlag: 0,
            count: 1
        )
        let isNewAvatar = !authManager.avatars.contains { $0.name == item.name }
        authManager.commitGachaResult(
            avatar: avatar,
            coinCost: coinCost,
            ticketType: ticketType
        ) { success in
            guard success else {
                if ticketType == nil {
                    if userMoney < coinCost {
                        showUnCoinModal = true
                    } else {
                        ticketErrorMessage = "ガチャの確定に失敗しました。時間をおいて再度お試しください。"
                        showTicketErrorAlert = true
                    }
                } else {
                    ticketErrorMessage = "チケットの消費またはおともの保存に失敗しました。"
                    showTicketErrorAlert = true
                }
                refreshPlayerResources()
                return
            }

            audioManager.playSound()
            obtainedRareItem = item
            obtainedIsNew = isNewAvatar
            // 次回の NEW 判定のため所持おともを読み直す（読み取りのみ）
            authManager.fetchAvatars {}
            authManager.recordGachaUsed()
            if resetResult {
                showResult = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (resetResult ? 0.5 : 0.1)) {
                showAnimation = true
            }
            checkAvatarCount()
            refreshPlayerResources()
        }
    }

    private func fetchUserMoney() {
        authManager.getUserMoney { money in
            self.userMoney = money
            // ボタンの有効/無効を更新
            if money < 600 {
                isGachaButtonDisabled = false
            } else {
                isGachaButtonDisabled = true
            }
        }
    }

    private func refreshPlayerResources() {
        fetchUserMoney()
        authManager.fetchInventory()
    }
    
    private func checkAvatarCount() {
        guard let userId = authManager.currentUserId else { return }
        
        countAvatarsForUser(userId: userId) { avatarCount in
            print("ユーザーのアバターの数: \(avatarCount)")
            
            if avatarCount > 9 {
                authManager.checkTitles(userId: userId, title: "おとも１０種類制覇") { exists in
                    if !exists {
                        otomo10flag = true
                        obtainedTitle = "おとも１０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも１０種類制覇")
                    }
                }
            }
            
            if avatarCount > 19 {
                authManager.checkTitles(userId: userId, title: "おとも２０種類制覇") { exists in
                    if !exists {
                        otomo20flag = true
                        obtainedTitle = "おとも２０種類制覇"
                        showTitleModal = true
                        authManager.saveTitleForUser(userId: userId, title: "おとも２０種類制覇")
                    }
                }
            }
        }
    }
    
    private func countAvatarsForUser(userId: String, completion: @escaping (Int) -> Void) {
        let avatarsRef = Database.database().reference().child("users").child(userId).child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value, with: { snapshot in
            let avatarCount = snapshot.childrenCount
            completion(Int(avatarCount))
        })
    }
}

#Preview {
    MekaGachaView()
}
