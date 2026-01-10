//
//  StoryMonsterModalView.swift
//  it
//
//  Created by Apple on 2024/11/30.
//  Updated with modern design system
//

import SwiftUI

struct StoryMonsterModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var monster: Int
    @Binding var isPresented: Bool
    @Binding var showQuizList: Bool
    @State var toggle = false
    @State private var monsterName: String = ""
    @State private var monsterHP: Int = 100
    @State private var monsterAttack: Int = 10
    @State private var quizTitle: String = ""
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var viewModel: PositionViewModel
    
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0
    @State private var monsterScale: CGFloat = 0.8

    let monsters: [Int: Monster] = [
        1: Monster(name: "モンスター1", playerExperience: 30, playerMoney: 30, monsterHP: 160, monsterUnderHP: 160, monsterAttack: 30),
        2: Monster(name: "モンスター2", playerExperience: 20, playerMoney: 20, monsterHP: 100, monsterUnderHP: 100, monsterAttack: 10),
        3: Monster(name: "モンスター3", playerExperience: 15, playerMoney: 15, monsterHP: 120, monsterUnderHP: 120, monsterAttack: 15),
        4: Monster(name: "モンスター4", playerExperience: 25, playerMoney: 25, monsterHP: 110, monsterUnderHP: 110, monsterAttack: 12),
        5: Monster(name: "モンスター5", playerExperience: 22, playerMoney: 22, monsterHP: 115, monsterUnderHP: 115, monsterAttack: 14),
        6: Monster(name: "モンスター6", playerExperience: 28, playerMoney: 28, monsterHP: 125, monsterUnderHP: 125, monsterAttack: 18),
        7: Monster(name: "モンスター7", playerExperience: 35, playerMoney: 35, monsterHP: 150, monsterUnderHP: 150, monsterAttack: 25),
        8: Monster(name: "モンスター8", playerExperience: 18, playerMoney: 18, monsterHP: 95, monsterUnderHP: 95, monsterAttack: 9),
        9: Monster(name: "モンスター9", playerExperience: 40, playerMoney: 40, monsterHP: 160, monsterUnderHP: 160, monsterAttack: 28),
        10: Monster(name: "モンスター10", playerExperience: 45, playerMoney: 45, monsterHP: 170, monsterUnderHP: 170, monsterAttack: 30),
        11: Monster(name: "モンスター11", playerExperience: 50, playerMoney: 50, monsterHP: 180, monsterUnderHP: 180, monsterAttack: 32),
        12: Monster(name: "モンスター12", playerExperience: 55, playerMoney: 55, monsterHP: 190, monsterUnderHP: 190, monsterAttack: 35),
        13: Monster(name: "モンスター13", playerExperience: 60, playerMoney: 60, monsterHP: 200, monsterUnderHP: 200, monsterAttack: 38),
        14: Monster(name: "モンスター14", playerExperience: 65, playerMoney: 65, monsterHP: 210, monsterUnderHP: 210, monsterAttack: 40),
        15: Monster(name: "ボス15", playerExperience: 150, playerMoney: 150, monsterHP: 1000, monsterUnderHP: 1000, monsterAttack: 100),
        16: Monster(name: "ボス16", playerExperience: 300, playerMoney: 300, monsterHP: 3000, monsterUnderHP: 3000, monsterAttack: 300),
        17: Monster(name: "モンスター17", playerExperience: 80, playerMoney: 80, monsterHP: 240, monsterUnderHP: 240, monsterAttack: 48),
        18: Monster(name: "モンスター18", playerExperience: 85, playerMoney: 85, monsterHP: 250, monsterUnderHP: 250, monsterAttack: 50),
        19: Monster(name: "モンスター19", playerExperience: 90, playerMoney: 90, monsterHP: 260, monsterUnderHP: 260, monsterAttack: 52),
        20: Monster(name: "モンスター20", playerExperience: 95, playerMoney: 95, monsterHP: 270, monsterUnderHP: 270, monsterAttack: 55),
        21: Monster(name: "モンスター21", playerExperience: 100, playerMoney: 100, monsterHP: 280, monsterUnderHP: 280, monsterAttack: 58),
        22: Monster(name: "モンスター22", playerExperience: 105, playerMoney: 105, monsterHP: 290, monsterUnderHP: 290, monsterAttack: 60),
        23: Monster(name: "モンスター23", playerExperience: 110, playerMoney: 110, monsterHP: 300, monsterUnderHP: 300, monsterAttack: 62),
        24: Monster(name: "モンスター24", playerExperience: 115, playerMoney: 115, monsterHP: 310, monsterUnderHP: 310, monsterAttack: 65),
        25: Monster(name: "モンスター25", playerExperience: 120, playerMoney: 120, monsterHP: 320, monsterUnderHP: 320, monsterAttack: 68),
        26: Monster(name: "モンスター26", playerExperience: 125, playerMoney: 125, monsterHP: 330, monsterUnderHP: 330, monsterAttack: 70),
        27: Monster(name: "モンスター27", playerExperience: 130, playerMoney: 130, monsterHP: 340, monsterUnderHP: 340, monsterAttack: 72),
        28: Monster(name: "モンスター28", playerExperience: 135, playerMoney: 135, monsterHP: 350, monsterUnderHP: 350, monsterAttack: 75),
        29: Monster(name: "モンスター29", playerExperience: 140, playerMoney: 140, monsterHP: 360, monsterUnderHP: 360, monsterAttack: 78),
        30: Monster(name: "モンスター30", playerExperience: 145, playerMoney: 145, monsterHP: 370, monsterUnderHP: 370, monsterAttack: 80),
        31: Monster(name: "モンスター31", playerExperience: 150, playerMoney: 150, monsterHP: 380, monsterUnderHP: 380, monsterAttack: 82),
        32: Monster(name: "モンスター32", playerExperience: 155, playerMoney: 155, monsterHP: 390, monsterUnderHP: 390, monsterAttack: 85),
        33: Monster(name: "モンスター33", playerExperience: 160, playerMoney: 160, monsterHP: 400, monsterUnderHP: 400, monsterAttack: 88),
        34: Monster(name: "モンスター34", playerExperience: 170, playerMoney: 165, monsterHP: 420, monsterUnderHP: 420, monsterAttack: 92),
        35: Monster(name: "ボス35", playerExperience: 1000, playerMoney: 1000, monsterHP: 5000, monsterUnderHP: 5000, monsterAttack: 500),
        36: Monster(name: "モンスター36", playerExperience: 190, playerMoney: 185, monsterHP: 460, monsterUnderHP: 460, monsterAttack: 100),
        37: Monster(name: "モンスター37", playerExperience: 200, playerMoney: 190, monsterHP: 480, monsterUnderHP: 480, monsterAttack: 105),
        38: Monster(name: "モンスター38", playerExperience: 200, playerMoney: 200, monsterHP: 500, monsterUnderHP: 500, monsterAttack: 110),
        39: Monster(name: "モンスター39", playerExperience: 210, playerMoney: 210, monsterHP: 510, monsterUnderHP: 510, monsterAttack: 120),
        40: Monster(name: "モンスター40", playerExperience: 220, playerMoney: 220, monsterHP: 520, monsterUnderHP: 520, monsterAttack: 130),
        41: Monster(name: "モンスター41", playerExperience: 230, playerMoney: 230, monsterHP: 530, monsterUnderHP: 530, monsterAttack: 150),
        42: Monster(name: "モンスター42", playerExperience: 240, playerMoney: 240, monsterHP: 550, monsterUnderHP: 550, monsterAttack: 170),
        43: Monster(name: "モンスター43", playerExperience: 250, playerMoney: 250, monsterHP: 570, monsterUnderHP: 570, monsterAttack: 190),
        44: Monster(name: "モンスター44", playerExperience: 260, playerMoney: 270, monsterHP: 600, monsterUnderHP: 600, monsterAttack: 210),
        45: Monster(name: "モンスター45", playerExperience: 280, playerMoney: 280, monsterHP: 630, monsterUnderHP: 630, monsterAttack: 230),
        46: Monster(name: "モンスター46", playerExperience: 310, playerMoney: 310, monsterHP: 660, monsterUnderHP: 660, monsterAttack: 250),
        47: Monster(name: "モンスター47", playerExperience: 340, playerMoney: 340, monsterHP: 690, monsterUnderHP: 690, monsterAttack: 270),
        48: Monster(name: "モンスター48", playerExperience: 370, playerMoney: 370, monsterHP: 720, monsterUnderHP: 720, monsterAttack: 290),
        49: Monster(name: "モンスター49", playerExperience: 400, playerMoney: 400, monsterHP: 750, monsterUnderHP: 550, monsterAttack: 310),
        50: Monster(name: "モンスター50", playerExperience: 430, playerMoney: 430, monsterHP: 800, monsterUnderHP: 800, monsterAttack: 350),
        51: Monster(name: "モンスター51", playerExperience: 460, playerMoney: 460, monsterHP: 850, monsterUnderHP: 850, monsterAttack: 400),
        52: Monster(name: "モンスター52", playerExperience: 500, playerMoney: 500, monsterHP: 900, monsterUnderHP: 900, monsterAttack: 500),
    ]

    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // メインコンテンツ
            VStack(spacing: 16) {
                // モンスター情報
                VStack(spacing: 16) {
                    // モンスター画像
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "ff416c").opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                        
                        Image(monsterName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .scaleEffect(monsterScale)
                            .modifier(FloatingAnimation(amplitude: 6, duration: 1.5))
                    }
                    
                    // ステータス
                    HStack(spacing: 16) {
                        StatBadge(icon: "HPマーク", value: "\(monsterHP)", color: Color(hex: "38ef7d"))
                        StatBadge(icon: "攻撃マーク", value: "\(monsterAttack)", color: Color(hex: "ff416c"))
                    }
                }
                
                // クイズ情報
                VStack(spacing: 8) {
                    Text("出題カテゴリ")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16))
                        Text(quizTitle)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    )
                }
                
                Spacer().frame(height: 10)
                
                // バトルボタン
                Button(action: startBattle) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text("たたかう")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "ff416c"), Color(hex: "ff4b2b")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "ff416c").opacity(0.5), radius: 12, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
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
            }
            .padding(.vertical, 20)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            setMonsterParameters(monster: monster)
            setQuizTitle()
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                monsterScale = 1.0
            }
        }
    }
    
    private func setMonsterParameters(monster: Int) {
        if let m = monsters[monster] {
            monsterName = m.name
            monsterHP = m.monsterHP
            monsterAttack = m.monsterAttack
        }
    }
    
    private func setQuizTitle() {
        switch viewModel.userPosition {
        case 1...52: quizTitle = "ITパスポート"
        case 53...101: quizTitle = "基本情報技術者試験"
        case 102...150: quizTitle = "応用情報技術者試験"
        default: quizTitle = "ITパスポート"
        }
    }
    
    private func startBattle() {
        generateHapticFeedback()
        audioManager.playKetteiSound()
        isPresented = false
        showQuizList = true
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        audioManager.playCancelSound()
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(height: 26)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(color.opacity(0.25))
                .overlay(Capsule().stroke(color.opacity(0.5), lineWidth: 1.5))
        )
    }
}

#Preview {
    StoryMonsterModalView(monster: .constant(1), isPresented: .constant(true), showQuizList: .constant(false), audioManager: AudioManager(), viewModel: PositionViewModel.shared)
}
