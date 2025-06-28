//
//  TutorialModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/31.
//

import SwiftUI

struct TutorialModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @Binding var isFlag: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var showAlert: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isFlag = true
                    isPresented = false
                }
            VStack(spacing: -25) {
                VStack(alignment: .center){
                    Image("チュートリアル")
                        .resizable()
                        .frame(height: isSmallDevice() ? 160 : 170)
                        .padding(-15)
                    Text("インストールありがとうございます！\n\nゲーム感覚でIT系の勉強ができます\n問題に答えてモンスターと戦おう！\nガチャで仲間を増やすこともできます\n\nまずは名前を設定してみましょう")
                        .font(.system(size: isSmallDevice() ? 17 : 18))
                        .multilineTextAlignment(.center)
                        .padding(10)
                }
            }
            .frame(width: isSmallDevice() ? 330: 350,height: isSmallDevice() ? 310: 350)
            .foregroundColor(Color("fontGray"))
//            .padding()
        .background(Color("Color2"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                isFlag = true
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
        .padding(25)
                }
            }
        }

func isSmallDevice() -> Bool {
    return UIScreen.main.bounds.width < 390
}

#Preview {
    TutorialModalView(isPresented: .constant(true), isFlag: .constant(false), showAlert: .constant(false))
}
