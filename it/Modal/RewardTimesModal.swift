//
//  RewardModalView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/02.
//

import SwiftUI

struct RewardTimesModal: View {
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Image("獲得ボーナス")
                    .resizable()
                    .frame(width: 330, height: 170)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .overlay(
                // 閉じるボタン
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white, Color.black.opacity(0.35))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 8, y: -8),
                alignment: .topTrailing
            )
        }
        .onAppear {
        }
    }
}

struct RewardTimesModal_Previews: PreviewProvider {
    static var previews: some View {
        RewardTimesModal(audioManager: AudioManager(), isPresented: .constant(true))
    }
}
