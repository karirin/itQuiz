//
//  RewardModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/02.
//

import SwiftUI

struct RewardModalView: View {
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Image("動画視聴ボーナス")
                    .resizable()
                    .frame(width:330,height:170)
            }
//            .padding(50)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .overlay(
                // 「×」ボタンを右上に配置
                Button(action: { 
                        generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
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
        }
    }
}

struct RewardModalView_Previews: PreviewProvider {
    static var previews: some View {
        RewardModalView(audioManager: AudioManager(), isPresented: .constant(true))
    }
}
