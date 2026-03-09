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
            fetchUserMoney()
            reward.LoadReward()
        }
        .fullScreenCover(isPresented: $showAnimation) {
            if let rarity = obtainedRareItem?.rarity {
                GachaAnimationView(rarity: rarity) {
                    showAnimation = false
                    obtainedItem = obtainedRareItem
                    showResult = true
                    fetchUserMoney()
                    checkAvatarCount()
                }
            }
        }
        .alert("コインが足りません", isPresented: $showUnCoinModal) {
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
                fetchUserMoney()
            }
        }
        .alert("称号獲得!", isPresented: $showTitleModal) {
            Button("OK") {}
        } message: {
            Text(obtainedTitle)
        }
        .onChange(of: reward.rewardEarned) { rewardEarned in
            showRewardAlert = rewardEarned
            if rewardEarned {
                fetchUserMoney()
                reward.rewardEarned = false
            }
        }
        .onChange(of: showCoinModal) { _ in
            fetchUserMoney()
        }
    }
    
    private var gachaMainView: some View {
        VStack(spacing: 50) {
            
            // コイン表示（購入ボタン付き）
            HStack {
                Button(action: {
                    generateHapticFeedback()
                    self.presentationMode.wrappedValue.dismiss()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                }.buttonStyle(.plain)
                .padding(.leading)
                Spacer()
                
                Button(action: {
                    showCoinModal = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("\(userMoney)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("コイン")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                            )
                    )
                }
            }
            .padding(.trailing)
            .padding(.bottom)
            
            Image("神ガチャトップ")
                .resizable()
                .scaledToFit()
                .padding(-60)
            
            // ガチャボタン
            Button(action: { startGacha() }) {
                HStack(spacing: 15) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(spacing: 2) {
                        Text("ガチャを引く")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("1000コイン")
                            .font(.system(size: 14, weight: .medium))
                            .opacity(0.9)
                    }
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    Group {
                        if isGachaButtonDisabled {
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(20)
                .shadow(color: isGachaButtonDisabled ? .purple.opacity(0.6) : .clear, radius: 15, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            }
            .disabled(!isGachaButtonDisabled)
            .padding(.horizontal, 30)
            .padding(.top,20)
            .padding(.bottom,-20)
            
            // ボタングループ（リワード広告・コイン購入）
            VStack(spacing: 12) {
                // リワード広告ボタン
                Button(action: {
                    if reward.rewardLoaded {
                        reward.ShowReward()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 22, weight: .bold))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("広告を見て")
                                .font(.system(size: 14, weight: .medium))
                            Text("300コイン獲得")
                                .font(.system(size: 18, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: reward.rewardLoaded ? [
                                Color(red: 0.95, green: 0.6, blue: 0.2),
                                Color(red: 0.98, green: 0.75, blue: 0.3)
                            ] : [
                                Color.gray.opacity(0.6),
                                Color.gray.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: reward.rewardLoaded ? Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .overlay(
                        Group {
                            if !reward.rewardLoaded {
                                ZStack {
                                    Color.black.opacity(0.3)
                                        .cornerRadius(16)
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                }
                            }
                        }
                    )
                }
                .disabled(!reward.rewardLoaded)
                
                // コイン購入ボタン
                Button(action: {
                    showCoinModal = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("コイン購入")
                            .font(.system(size: 18, weight: .bold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.5),
                                Color(red: 0.3, green: 0.8, blue: 0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.2, green: 0.7, blue: 0.5).opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 30)

            Image("神卵レア度")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        }
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
                            fetchUserMoney()
                        } else {
                            userMoney += cost
                            showAnimation = false
                            obtainedRareItem = nil
                            fetchUserMoney()
                            showUnCoinModal = true
                        }
                    }
                }
            }
        }
    }
    
    private func fetchUserMoney() {
        authManager.getUserMoney { money in
            self.userMoney = money
            isGachaButtonDisabled = money >= gachaManager.gachaCost
        }
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
