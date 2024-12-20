//
//  StoryMonsterModalView.swift
//  it
//
//  Created by Apple on 2024/11/30.
//

import SwiftUI

struct StoryMonsterModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var monster: Int
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
        15: Monster(name: "ボス15", playerExperience: 120, playerMoney: 150, monsterHP: 300, monsterUnderHP: 300, monsterAttack: 65),
        16: Monster(name: "ボス16", playerExperience: 200, playerMoney: 300, monsterHP: 500, monsterUnderHP: 500, monsterAttack: 200),
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
        32: Monster(name: "モンスター32", playerExperience: 155, playerMoney: 155, monsterHP: 390, monsterUnderHP: 390, monsterAttack: 85)
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                    audioManager.playCancelSound()
                }
                ZStack{
                    VStack {
                    HStack{
                        Spacer()
                            .frame(width:270)
                        Button(action: {
                            isPresented = false
                            audioManager.playCancelSound()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .background(.white)
                                .cornerRadius(50)
                        }
                    }
                    .padding(.bottom, -50)
                    Image("\(monsterName)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .offset(y: isMovingUp ? -5 : 5)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isMovingUp.toggle()
                            }
                        }
                    HStack{
                        HStack{
                            Image("攻撃マーク")
                                .resizable()
                                .scaledToFit()
                                .frame(height:30)
                            Text("\(monsterHP)")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                            .frame(width:30)
                        HStack{
                            Image("HPマーク")
                                .resizable()
                                .scaledToFit()
                                .frame(height:30)
                            Text("\(monsterAttack)")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                    }
                        Text("問題：\(quizTitle)")
                            .font(.system(size: isSmallDevice() ? 26 : 28))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            isPresented = false
                            showQuizList = true
                            audioManager.playKetteiSound()
                        }) {
                            Image("たたかう")
                                .resizable()
                                .scaledToFit()
                                .frame(height:80)
                                .foregroundColor(.gray)
                        }
                }
            }
            
            .foregroundColor(Color("fontGray"))
        .shadow(radius: 10)
//        .overlay(
//            ZStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    VStack{
//                        Spacer()
//                        HStack {
//                            Button(action: {
//                                reward.ExAndMoReward()
//                            }, label: {
//                                if reward.rewardLoaded{
//                                    Image("倍ボタン")
//                                        .resizable()
//                                        .frame(width: 110, height: 110)
//                                }else{
//                                    Image("倍ボタン白黒")
//                                        .resizable()
//                                        .frame(width: 110, height: 110)
//                                }
//                            })
//                                .shadow(radius: 5)
//                                .disabled(!reward.rewardLoaded)
//                                .onChange(of: reward.rewardEarned) { rewardEarned in
//                                    showAlert = rewardEarned
//                                    print("onchange reward.rewardEarned:\(showAlert)")
//                                }
//                                .alert(isPresented: $showAlert) {
//                                    Alert(
//                                        title: Text("報酬獲得！"),
//                                        message: Text("1時間だけ獲得した経験値とコインが2倍"),
//                                        dismissButton: .default(Text("OK"), action: {
//                                            showAlert = false
//                                            reward.rewardEarned = false
//                                        })
//                                    )
//                                }
//                                .background(GeometryReader { geometry in
//                                    Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
//                                })
//                                .padding(.bottom)
//                            
//                                Spacer()
//                        }
//                    }
//                }
//            }
//        )
//        .overlay(
//            ZStack {
//                HStack {
//                    Spacer()
//                    VStack{
//                        HStack {
//                            // 「×」ボタンを右上に配置
//                            Button(action: {
//                                isPresented = false
//                                audioManager.playCancelSound()
//                            }) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .resizable()
//                                    .frame(width: 60, height: 60)
//                                    .foregroundColor(.gray)
//                                    .background(.white)
//                                    .cornerRadius(50)
//                                    .padding()
//                            }
//                        }
//                        Spacer()
//                    }
//                }
//            }
//        )
        .padding(25)
        }
        .onAppear {
            // ビューが表示された際にパラメータを設定
            print("monster  :\(monster)")
            setMonsterParameters(monster: monster)
            if monster < 8 {
                quizTitle = "ITパスポート"
            } else if monster == 15 {
                quizTitle = "ITパスポート"
            } else {
                quizTitle = "基本情報技術者試験"
            }
        }
            }
    private func setMonsterParameters(monster: Int) {
        if let monster = monsters[monster] {
            monsterName = monster.name
            monsterHP = monster.monsterHP
            monsterAttack = monster.monsterAttack
        } else {
            // 未定義のモンスターの場合のデフォルト値
                print("未知の宝物")
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    StoryMonsterModalView(monster: .constant(1), isPresented: .constant(true), showQuizList: .constant(false), audioManager: AudioManager())
}
