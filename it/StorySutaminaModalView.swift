//
//  StorySutaminaModalView.swift
//  it
//
//  Created by Apple on 2024/12/01.
//

import SwiftUI

struct StorySutaminaModalView: View {
    @StateObject var reward = Reward()
    @State private var showAlert: Bool = false
    @Binding var isPresented: Bool
    @ObservedObject var audioManager = AudioManager()
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            VStack{
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
                .padding(.top, -50)
                VStack{
                    Text("スタミナがありません")
                    Text("1分に1スタミナ回復します")
                }
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .fontWeight(.bold)
                Button(action: {
                    reward.ShowSutaminaReward()
                }) {
                    if reward.rewardLoaded {
                        Image("スタミナボタン")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                    } else {
                        ZStack {
                            Image("スタミナボタン白黒")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                            ProgressView()
                                .scaleEffect(3)
                        }
                    }
                }
                .disabled(!reward.rewardLoaded)
                .onChange(of: reward.rewardEarned) { rewardEarned in
                    showAlert = rewardEarned
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("報酬獲得！"),
                        message: Text("30スタミナが回復しました"),
                        dismissButton: .default(Text("OK"), action: {
                            showAlert = false
                            isPresented = false
                            reward.rewardEarned = false
                        })
                    )
                }
                
//                Button(action: {
//                    reward.ShowReward()
//                }) {
//                    if reward.rewardLoaded {
//                        Image("獲得")
//                            .resizable()
//                            .frame(maxWidth:110,maxHeight:110)
//                    } else {
//                        Image("獲得白黒")
//                            .resizable()
//                            .frame(maxWidth:110,maxHeight:110)
//                    }
//                }
//                .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
//                .onChange(of: reward.rewardEarned) { rewardEarned in
//                    showAlert = rewardEarned
//                    print("onChange reward.rewardEarned:\(reward.rewardEarned)")
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(
//                        title: Text("報酬獲得！"),
//                        message: Text("300コイン獲得しました。"),
//                        dismissButton: .default(Text("OK"), action: {
//                            // アラートを閉じるアクション
//                            showAlert = false // アラートの表示状態を更新
//                            reward.rewardEarned = false // 必要に応じてrewardEarnedも更新
//                        })
//                    )
//                }
            }
        }
        .onAppear() {
            reward.LoadStoryReward()
        }
    }
}

#Preview {
    StorySutaminaModalView(isPresented: .constant(true))
}
