//
//  ModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/04.
//

import SwiftUI

struct ModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
    @Binding var tutorialNum: Int
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button(action: {
                    isPresenting = false
                    audioManager.playReturnSound()
                }) {
                    HStack{
                        Image(systemName: "house.fill")
                        Text("ホームに戻る")
                            
                    }.padding(20)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
                
//                Button(action: {
//                    audioManager.toggleSound()
//                    isSoundOn.toggle()
//                    audioManager.playSound()
//                }) {
//                    HStack {
//                        if isSoundOn {
//                            Image(systemName: "speaker.slash")
//                            Text("　音声オフ　")
//                        } else {
//                            Image(systemName: "speaker.wave.2")
//                            Text("　音声オン　")
//                        }
//                    }
//                        .padding(20)
//                        .foregroundColor(.black)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .shadow(radius: 1)
//                }
                
                Button(action: {
                    showHomeModal = false
                    tutorialNum = 3
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                    }
                    audioManager.playSound()
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("　ヘルプ　　")
                    }
                        .padding(20)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
            }
            .padding(50)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .overlay(
                // 「×」ボタンを右上に配置
                Button(action: {
                    isPresented = false
                    resumeTimer()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .background(.white)
                        .cornerRadius(30)
                        .padding()
                }
                .offset(x: 35, y: -35), // この値を調整してボタンを正しい位置に移動させます
                alignment: .topTrailing // 枠の右上を基準に位置を調整します
            )
        }
        .onAppear {
            pauseTimer() // モーダルが表示されたときにタイマーを一時停止
        }
    }
}

//struct ModalView_Previews: PreviewProvider {
//    @State static private var isPresenting = true
//    static var previews: some View {
////        ModalView(isSoundOn: .constant(true), isPresented: .constant(true), isPresenting: $isPresenting, audioManager: AudioManager.shared)
//    }
//}
