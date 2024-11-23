//
//  StoryCoinModalView.swift
//  it
//
//  Created by Apple on 2024/11/17.
//

import SwiftUI

struct StoryCoinModalView: View {
    @ObservedObject var authManager = AuthManager()
    let coin: Int
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var isMovingUp = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
                ZStack{
                    VStack {
                    Image("コイン\(coin)")
//                        Image("コイン1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .offset(y: isMovingUp ? -5 : 5)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isMovingUp.toggle()
                            }
                        }
                    Text("\(coin)00コインゲット！！")
//                        Text("100コインゲット！！")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
            }.frame(height: 150)
//            .frame(width: isSmallDevice() ? 330: 350,height: isSmallDevice() ? 310: 350)
            
            .foregroundColor(Color("fontGray"))
//            .padding()
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(.white)
                    .cornerRadius(50)
                    .padding()
            }
                .offset(x: 35, y: -70), // この値を調整してボタンを正しい位置に移動させます
            alignment: .topTrailing // 枠の右上を基準に位置を調整します
        )
        .padding(25)
                }
            }
        }

#Preview {
    StoryCoinModalView(coin: 1, isPresented: .constant(true))
}
