//
//  MissionView.swift
//  it
//
//  Created by hashimo ryoya on 2025/12/16.
//

import SwiftUI

struct MissionView: View {
    @StateObject private var missionManager = MissionManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showHint = false
    @State private var selectedMission: Mission?
    @State private var showRewardAlert = false
    @State private var rewardAmount = 0
    @State private var showAllRewardAlert = false
    @State private var totalRewardAmount = 0
    @State private var isLoading = true
    
    var completedMissionsCount: Int {
        missionManager.missions.filter { $0.isCompleted && !$0.isClaimed }.count
    }
    
    var body: some View {
        ZStack {
            Color("Color2")
                .ignoresSafeArea()
            
            if isLoading {
                VStack {
                    CustomSpinner5()
                }
            } else {
                VStack(spacing: 0) {
                    // ヘッダー
                    headerView
                    
                    // ミッションリスト
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(missionManager.missions) { mission in
                                MissionCardView(mission: mission) {
                                    selectedMission = mission
                                    showHint = true
                                } claimAction: {
                                    claimMissionReward(mission)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // 下部ボタン
                    bottomButtonsView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            generateHapticFeedback()
            presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                Text("戻る")
                    .foregroundColor(Color("fontGray"))
            }
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ミッション")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("fontGray"))
            }
        }
        .sheet(isPresented: $showHint) {
            if let mission = selectedMission {
                HintModalView(mission: mission, isPresented: $showHint)
            }
        }
        .alert("報酬獲得!", isPresented: $showRewardAlert) {
            Button("OK", role: .cancel) {
                audioManager.playSound()
            }
        } message: {
            Text("\(rewardAmount)コイン獲得しました!")
        }
        .alert("報酬獲得!", isPresented: $showAllRewardAlert) {
            Button("OK", role: .cancel) {
                audioManager.playSound()
            }
        } message: {
            Text("合計\(totalRewardAmount)コイン獲得しました!")
        }
        .onAppear {
            loadMissions()
        }
    }
    
    private var headerView: some View {
        HStack {
            Image("beginnerMonster1")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Text("ミッション")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("fontGray"))
            
            Spacer()
            
            // 完了済みミッション数
            if completedMissionsCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(completedMissionsCount)件完了")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private var bottomButtonsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                generateHapticFeedback()
                audioManager.playSound()
                claimAllRewards()
            }) {
                HStack {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 20))
                    Text("まとめて受け取る")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(completedMissionsCount > 0 ? Color.green : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .disabled(completedMissionsCount == 0)
            .shadow(color: completedMissionsCount > 0 ? Color.green.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
            
            Button(action: {
                generateHapticFeedback()
                audioManager.playCancelSound()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("もどる")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .foregroundColor(Color("fontGray"))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
    }
    
    private func loadMissions() {
        missionManager.fetchMissions { success in
            if success {
                // ミッションの最新状態を同期
                missionManager.refreshAllMissions()
            }
            isLoading = false
        }
    }
    
    private func claimMissionReward(_ mission: Mission) {
        generateHapticFeedback()
        audioManager.playSound()
        
        missionManager.claimReward(missionId: mission.id) { success, reward in
            if success {
                rewardAmount = reward
                showRewardAlert = true
            }
        }
    }
    
    private func claimAllRewards() {
        missionManager.claimAllRewards { success, totalReward in
            if success {
                totalRewardAmount = totalReward
                showAllRewardAlert = true
            }
        }
    }
}

struct MissionCardView: View {
    let mission: Mission
    let hintAction: () -> Void
    let claimAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // アイコン
                Text(mission.rewardIcon)
                    .font(.system(size: 30))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(mission.isClaimed ? Color.gray.opacity(0.2) : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                
                // タイトルと報酬
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("fontGray"))
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image("コインバー")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        Text("×\(mission.rewardCoin)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // ヒントボタンまたはCLEARバッジ
                if mission.isClaimed {
                    Text("CLEAR")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.orange, lineWidth: 2)
                        )
                } else {
                    Button(action: hintAction) {
                        Text("ヒント")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("fontGray"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                }
            }
            
            // プログレスバー
            VStack(alignment: .trailing, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 24)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: mission.isClaimed ?
                                        [Color.gray, Color.gray] :
                                        [Color.green, Color.green.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(mission.progressPercentage), height: 24)
                        
                        // 進捗テキスト
                        Text("\(mission.currentCount)/\(mission.targetCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 24)
            }
            
            // 受取可能ボタン
            if mission.isCompleted && !mission.isClaimed {
                Button(action: claimAction) {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("受取可能")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}

struct HintModalView: View {
    let mission: Mission
    @Binding var isPresented: Bool
    @ObservedObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    audioManager.playCancelSound()
                    isPresented = false
                }
            
            VStack(spacing: 24) {
                // タイトル
                HStack {
                    Text(mission.rewardIcon)
                        .font(.system(size: 40))
                    Text("ヒント")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("fontGray"))
                }
                
                Divider()
                
                // 説明
                VStack(spacing: 16) {
                    Text(mission.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("fontGray"))
                        .multilineTextAlignment(.center)
                    
                    Text(mission.description)
                        .font(.system(size: 16))
                        .foregroundColor(Color("fontGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 進捗表示
                    HStack {
                        Text("進捗:")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("\(mission.currentCount) / \(mission.targetCount)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // 閉じるボタン
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
                }) {
                    Text("閉じる")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    NavigationView {
        MissionView()
    }
}
