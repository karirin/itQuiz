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
    var user: User

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                    viewModel.incrementPosition()
                    audioManager.playCancelSound()
                }
                ZStack{
                    VStack {
                    HStack{
                        Spacer()
                            .frame(width:270)
                        Button(action: { 
                        generateHapticFeedback()
                            isPresented = false
                            viewModel.incrementPosition()
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
                        ForEach(user.avatars.indices, id: \.self) { index in
                            let avatarData = user.avatars[index]
                            if let name = avatarData["name"] as? String,
                               let avatarAttack = avatarData["attack"] as? Int,
                               let avatarHealth = avatarData["health"] as? Int,
                               let usedFlag = avatarData["usedFlag"] as? Int,
                               usedFlag == 1 {
                                VStack {
                                    HStack() {
                                        Text("\(user.userName)")
                                            .font(.system(size: 28))
                                            .padding(10)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(10)
                                    }
                                    .zIndex(1)
                                    HStack(spacing: 10) {
                                        Image(name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .offset(y: isMovingUp ? -5 : 5)
                                        .onAppear {
                                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                                isMovingUp.toggle()
                                            }
                                        }
                                    }
                                    
                                HStack{
                                    HStack{
                                        Image("攻撃マーク")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:30)
                                        Text("\(user.userAttack + avatarAttack)")
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
                                        Text("\(user.userHp + avatarHealth)")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                }
                                .padding(.top, -60)
                            }
                        }
                        Text("問題：\(quizTitle)")
                            .font(.system(size: isSmallDevice() ? 26 : 28))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Button(action: { 
                        generateHapticFeedback()
                            isPresented = false
                            showQuizList = true
                            audioManager.playKetteiSound()
                        }) {
                            Image("対戦するボタン")
                                .resizable()
                                .scaledToFit()
                                .frame(height:80)
                                .foregroundColor(.gray)
                        }
                        Text("勝てばステミナ消費無しで１コマ進めます\n※負けたらスタミナ消費＋コマも進みません")
                            .font(.system(size: 18))
                            .padding(5)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding(.horizontal, -30)
                }
            }
            
            .foregroundColor(Color("fontGray"))
        .shadow(radius: 10)
        .padding(25)
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
