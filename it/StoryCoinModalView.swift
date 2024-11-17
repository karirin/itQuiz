//
//  StoryCoinModalView.swift
//  it
//
//  Created by Apple on 2024/11/17.
//

import SwiftUI

struct StoryCoinModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
                ZStack{
                    Image("コイン1")
                        .resizable()
//                        .frame(height: isSmallDevice() ? 160 : 170)
                        .frame(height: 150)
                        .padding(-15)
                    VStack {
                    Text("100コインゲット！！")
//                        .font(.system(size: isSmallDevice() ? 17 : 18))
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        Spacer()
                }
            }.frame(height: 150)
//            .frame(width: isSmallDevice() ? 330: 350,height: isSmallDevice() ? 310: 350)
            
            .foregroundColor(Color("fontGray"))
//            .padding()
        .background(Color("Color2"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
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

#Preview {
    StoryCoinModalView(isPresented: .constant(true))
}
