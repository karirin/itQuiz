//
//  ModalTitleView.swift
//  it
//
//  Created by hashimo ryoya on 2024/01/07.
//

import SwiftUI

struct ModalTittleView: View {
    @Binding var showLevelUpModal: Bool
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var tittleNumber: Int

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showLevelUpModal = false
                }

            VStack(spacing: 20) {
//                    .padding(.bottom,80)
                if tittleNumber == 3 {
                    Text("称号獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("レベル３")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("レベル３を達成\n「スリースター」を獲得しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 5 {
                    Text("称号獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("レベル５")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("レベル５を達成\n「ネオンスター」を獲得しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 10 {
                    Text("称号獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("レベル１０")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("レベル10を達成\n「プラチナスター」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 30 {
                    Text("称号獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("回答数３０")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("回答数30問を達成\n「ブロンズメダル」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 50 {
                    Text("称号獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("回答数５０")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("回答数50問を達成\n「シルバーメダル」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 100 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("回答数１００")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("回答数100問を達成\n「ゴールドメダル」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 01 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("おとも１０種類制覇")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("おとも１０種類を仲間にした\n「ライムメダル」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 02 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("おとも２０種類制覇")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("おとも２０種類を仲間にした\n「覚醒ライムの盾」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 44 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("ゴブリン")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("ゴブリンリーダーを倒した\n「ゴブリンの財産」を獲得しました")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 55 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("ガルーラ")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("海獣ガルーンを倒した\n「神秘の海藻」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                } else if tittleNumber == 66 {
                    Text("称号獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("ルーン")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("神竜ルーンを倒した\n「神玉」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                }
//                else if tittleNumber == 03 {
//                    Text("称号獲得")
//                        .font(.system(size: 28))
//                        .fontWeight(.medium)
//                    Image("おともフルコンプ")
//                        .resizable()
//                        .frame(width:200,height:200)
//                    Text("おとも３０種類を仲間にした\n「ゴールドメダル」を獲得しました")
//                        .font(.system(size: 20))
//                        .multilineTextAlignment(.center)
//                }
            }
            .frame(width:300,height:330)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                showLevelUpModal = false
                audioManager.playCancelSound()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(50)
                    .padding()
            }
            .offset(x: 160, y: -170)
        )
        .onAppear{
            authManager.fetchUserExperienceAndLevel()
            audioManager.playTittleSound()
        }
    }
}

struct ModalTittleView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        ModalTittleView(showLevelUpModal: .constant(true), authManager: authManager, tittleNumber: .constant(66))
    }
}
