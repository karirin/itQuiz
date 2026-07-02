//
//  GodGachaView.swift
//  it
//
//  Created by Apple on 2026/03/01.
//

import SwiftUI
import Firebase

struct GodGachaView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var gachaManager = GachaManager(mode: .god)
    
    @State private var userMoney: Int = 0
    @State private var isGachaButtonDisabled: Bool = false
    @State private var obtainedRareItem: GachaManager.Item?
    @State private var obtainedItem: GachaManager.Item?
    
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
                gachaMainView
            } else {
                GachaResultView(
                    item: obtainedItem,
                    gachaCost: gachaManager.gachaCost,
                    onClose: {
                        showResult = false
                        obtainedItem = nil
                    },
                    onPlayAgain: {
                        obtainedItem = nil
                        startGacha(resetResult: false)
                    }
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
                GachaAnimationView(rarity: rarity) {
                    showAnimation = false
                    obtainedItem = obtainedRareItem
                    showResult = true
                    refreshPlayerResources()
                    checkAvatarCount()
                }
            }
        }
        .alert("コインが足りません", isPresented: $showUnCoinModal) {
            if authManager.godGachaTicketCount > 0 {
                Button("チケットで引く") {
                    startGachaWithTicket()
                }
            }
            Button(action: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                } else {
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
        .alert("チケットを使えません", isPresented: $showTicketErrorAlert) {
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
            gachaTitle: "神ガチャ",
            heroImageName: "神ガチャトップ",
            ticketType: .godGachaTicket,
            ticketCount: authManager.godGachaTicketCount,
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
            onDraw: {
                startGacha()
            },
            onTicketDraw: startGachaWithTicket,
            onRewardAd: {
                if reward.rewardLoaded {
                    reward.ShowReward()
                }
            }
        )
    }
    
    private func startGacha(resetResult: Bool = true) {
        let cost = gachaManager.gachaCost
        
        authManager.getUserMoney { latestMoney in
            DispatchQueue.main.async {
                userMoney = latestMoney
                isGachaButtonDisabled = latestMoney >= cost
                
                guard latestMoney >= cost else {
                    showUnCoinModal = true
                    return
                }
                
                gachaManager.shuffleItems()
                guard let item = gachaManager.drawGacha() else { return }
                
                obtainedRareItem = item
                authManager.recordGachaUsed()
                userMoney -= cost
                
                if resetResult {
                    showResult = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showAnimation = true
                }
                
                authManager.decreaseGodUserMoney { success in
                    DispatchQueue.main.async {
                        if success {
                            refreshPlayerResources()
                        } else {
                            userMoney += cost
                            showAnimation = false
                            obtainedRareItem = nil
                            refreshPlayerResources()
                            showUnCoinModal = true
                        }
                    }
                }
            }
        }
    }

    private func startGachaWithTicket() {
        guard authManager.godGachaTicketCount > 0 else {
            ticketErrorMessage = "神ガチャチケットがありません。"
            showTicketErrorAlert = true
            refreshPlayerResources()
            return
        }

        authManager.consumeItem(.godGachaTicket) { success in
            guard success else {
                ticketErrorMessage = "チケットの消費に失敗しました。通信状況を確認してもう一度お試しください。"
                showTicketErrorAlert = true
                refreshPlayerResources()
                return
            }

            DispatchQueue.main.async {
                audioManager.playSound()
                gachaManager.shuffleItems()
                guard let item = gachaManager.drawGacha() else {
                    refreshPlayerResources()
                    return
                }

                obtainedRareItem = item
                authManager.recordGachaUsed()
                showResult = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showAnimation = true
                }

                checkAvatarCount()
                refreshPlayerResources()
            }
        }
    }
    
    private func fetchUserMoney() {
        authManager.getUserMoney { money in
            self.userMoney = money
            isGachaButtonDisabled = money >= gachaManager.gachaCost
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
    GodGachaView()
}
