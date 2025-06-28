//
//  CoinModalView.swift
//  it
//
//  Created by Apple on 2024/02/05.
//

import SwiftUI

struct CoinModalView: View {
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @StateObject var store: Store = Store()
    
    var body: some View {
        ZStack {
            VStack(spacing: -25) {
                ForEach(store.productList, id: \.self) { product in
                    if product.displayName == "15000コイン" {
                        
                    HStack{
                        Image("3倍お得")
                            .resizable()
                            .frame(width:90,height:80)
                        Spacer()
                    }
                    HStack{
                        Image("コイン")
                            .resizable()
                            .frame(width:25,height:25)
                            .padding(.trailing,-5)
                        Text("15000コイン")
                            .font(.system(size: isSmallDevice() ? 20 : 24))
                            
                        Spacer()
                        Button(action: { 
                        generateHapticFeedback()
                            audioManager.playSound()
                            Task {
                                do {
                                    try await purchase(product)
                                } catch {
                                    // エラーハンドリングをここで行う
                                    print("Purchase failed: \(error)")
                                }
                            }
                        }) {
                            Image("500円で購入")
                                .resizable()
                                .frame(width:130,height:40)
                                .shadow(radius: 3)
                        }
                        
                    }//.padding(.top,-20)
                    } else if product.displayName == "4000コイン" {
                        HStack{
                            Image("2倍お得")
                                .resizable()
                                .frame(width:90,height:80)
                            Spacer()
                        }.padding(.top)
                        HStack{
                            Image("コイン")
                                .resizable()
                                .frame(width:25,height:25)
                                .padding(.trailing,-5)
                            Text("4000コイン")
                                .font(.system(size: isSmallDevice() ? 22 : 26))
                            Spacer()
                            Button(action: { 
                        generateHapticFeedback()
                                audioManager.playSound()
                                Task {
                                    do {
                                        try await purchase(product)
                                    } catch {
                                        // エラーハンドリングをここで行う
                                        print("Purchase failed: \(error)")
                                    }
                                }
                            }) {
                                Image("200円で購入")
                                    .resizable()
                                    .frame(width:130,height:40)
                                    .shadow(radius: 3)
                            }
                        }
                    } else {
                            HStack{
                                Image("コイン")
                                    .resizable()
                                    .frame(width:24,height:24)
                                    .padding(.trailing,-5)
                                Text("1000コイン")
                                    .font(.system(size: isSmallDevice() ? 22 : 26))
                                Spacer()
                                Button(action: { 
                        generateHapticFeedback()
                                    audioManager.playSound()
                                    Task {
                                        do {
                                            try await purchase(product)
                                        } catch {
                                            // エラーハンドリングをここで行う
                                            print("Purchase failed: \(error)")
                                        }
                                    }
                                }) {
                                    Image("100円で購入")
                                        .resizable()
                                        .frame(width:130,height:40)
                                        .shadow(radius: 3)
                                }
                            }.padding(.top,60)
                    }
                }
            }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print(store.productList)
                    }
                }
            //            .padding(50)
                .frame(width: isSmallDevice() ? 290: 310, height:270)
                .padding()
            .background(Color("Color2"))
            .foregroundColor(Color("fontGray"))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 15)
            )
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
            .padding(25)
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    CoinModalView(audioManager: AudioManager(), isPresented: .constant(true))
}
