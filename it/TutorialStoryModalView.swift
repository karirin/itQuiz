//
//  TutorialStoryModalView.swift
//  it
//
//  Created by Apple on 2024/12/07.
//

import SwiftUI

struct TutorialStoryModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
//    @Binding var isFlag: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var isTutorialStart: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
//                    isFlag = true
                    isPresented = false
                    isTutorialStart = true
                }
            VStack(spacing: -25) {
                VStack(alignment: .center){
                    Image("ダンジョンモード")
                        .resizable()
                        .frame(height: isSmallDevice() ? 150 : 150)
                    Text("ダンジョンモードが追加されました\n\nモンスターと戦いながらコマを進めて\nお宝を手に入れたりボスを倒したり\n楽しく学習することができます")
                        .font(.system(size: isSmallDevice() ? 17 : 17))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(10)
                }
            }
            .frame(width: isSmallDevice() ? 330: 350,height: isSmallDevice() ? 280: 280)
            .foregroundColor(Color("fontGray"))
//            .padding()
        .background(Color("Color2"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
//                isFlag = true
                isPresented = false
                isTutorialStart = true
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

#Preview {
    TutorialStoryModalView(isPresented: .constant(true),isTutorialStart: .constant(false))
}
