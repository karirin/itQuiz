//
//  ModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/04.
//

import SwiftUI

struct RankModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
    @Binding var tutorialNum: Int
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    @Binding var userFlag: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Button(action: {
                    isSoundOn.toggle()
                    audioManager.playSound()
                    if userFlag == 0 {
                        userFlag = 1
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1)
                    }else{
                        userFlag = 0
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 0)
                    }
                }) {
                    HStack {
                        if isSoundOn {
                            Image(systemName: "eye.slash")
                            Text("解説画面非表示")
                        } else {
                            Image(systemName: "eye")
                            Text("解説画面表示　")
                        }
                    }
                        .padding(20)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
                
                Button(action: {
                    showHomeModal = false
                    tutorialNum = 3
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                    }
                    audioManager.playSound()
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("ヘルプ 　　　　")
                    }
                        .padding(20)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .padding(.top,20)
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
            if userFlag == 0 {
                isSoundOn = true
            } else {
                isSoundOn = false
            }
        }
    }
}

//struct ModalView1_Previews: PreviewProvider {
//    @State static private var isPresenting = true
//    static var previews: some View {
//        ModalView(isSoundOn: .constant(true), isPresented: .constant(true), isPresenting: $isPresenting, audioManager: AudioManager.shared)
////ModalView()
//    }
//}
