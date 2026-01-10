//
//  StoryMonsterModalView.swift
//  it
//
//  Created by Apple on 2024/11/30.
//

import SwiftUI

struct StoryUserModalView: View {
    @ObservedObject var authManager = AuthManager()
    @ObservedObject var viewModel: PositionViewModel
//    @Binding var monster: Int
    @Binding var isPresented: Bool
    @Binding var showQuizList: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var coinImage: String = ""
    @State private var coinTitle: String = ""
    @State private var isMovingUp = false
    @State private var monsterName: String = ""
    @State private var monsterHP: Int = 100
    @State private var monsterAttack: Int = 10
    @State private var quizTitle: String = ""
    @State private var slideOut = false
    @ObservedObject var audioManager: AudioManager
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var avatarScale: CGFloat = 0.8
    var user: User

    var body: some View {
        ZStack {
            // 背景オーバーレイ（Monster版に寄せる）
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { dismissModal() }

            // メインコンテンツ
            VStack(spacing: 16) {

                // ユーザー情報（Monsterの丸背景 + 浮遊っぽさ）
                VStack(spacing: 16) {
                    Text("\(user.userName)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        )

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.15), Color.clear],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)

                        // ここは既存の usedFlag 判定ロジックをそのまま使う
                        ForEach(user.avatars.indices, id: \.self) { index in
                            let avatarData = user.avatars[index]
                            if let name = avatarData["name"] as? String,
                               let avatarAttack = avatarData["attack"] as? Int,
                               let avatarHealth = avatarData["health"] as? Int,
                               let usedFlag = avatarData["usedFlag"] as? Int,
                               usedFlag == 1 {
                                VStack{
                                    Image(name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .scaleEffect(avatarScale)
                                        .offset(y: isMovingUp ? -6 : 6)   // 既存の浮遊処理を流用
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                                isMovingUp.toggle()
                                            }
                                        }
                                    
                                    // ステータス（MonsterのStatBadgeに寄せる）
                                    HStack(spacing: 16) {
                                        StatBadge(icon: "攻撃マーク", value: "\(user.userAttack + avatarAttack)", color: .white)
                                        StatBadge(icon: "HPマーク", value: "\(user.userHp + avatarHealth)", color: .white)
                                    }
                                    .padding(.top, 10)
                                }
                            }
                        }
                    }
                }

                // バトルボタン（既存処理維持）
                Button(action: startBattle) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text("対戦する")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)

                // 注意書き（既存文言そのまま）
                Text("勝てばステミナ消費無しで１コマ進めます\n※負けたらスタミナ消費＋コマも進みません")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.35))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    )
                    .padding(.horizontal, 24)

                Button(action: dismissModal) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 18))
                        Text("タップして閉じる")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 6)
            }
            .padding(.vertical, 20)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                avatarScale = 1.0
            }
        }
    }

    private func startBattle() {
        generateHapticFeedback()
        isPresented = false
        showQuizList = true
        audioManager.playKetteiSound()
    }

    // 追加（閉じる処理は「元の処理」を維持している）
    private func dismissModal() {
        generateHapticFeedback()
        audioManager.playCancelSound()

        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            viewModel.incrementPosition()
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        let selectedUser = User(
            id: "1",
            userName: "SampleUser",
            level: 1,
            experience: 100,
            avatars: [
                [
                    "name": "ネッキー",
                    "attack": 10,
                    "health": 20,
                    "usedFlag": 1,
                    "count": 1
                ]
            ], // [[String: Any]] 型
            userMoney: 1000,
            userHp: 100,
            userAttack: 20,
            userFlag: 0,
            adminFlag: 0,
            rankMatchPoint: 100,
            rank: 1
        )
        
        StoryUserModalView(
            viewModel: PositionViewModel.shared, isPresented: .constant(true),
            showQuizList: .constant(false),
            audioManager: AudioManager(),
            user: selectedUser
        )
    }
}
