//
//  GachaView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI

class GachaManager {
    struct Item {
        let name: String
        let attack: Int
        let probability: Int
        let health: Int
        let rarity: Rarity
    }

    enum Rarity: Int {
        case normal = 40
        case rare = 30
        case superRare = 20
        case ultraRare = 10
    }

    var items: [Item] = [
        Item(name: "もりこう", attack: 20,probability: 25, health: 100, rarity: .normal),
        Item(name: "うっさん", attack: 25,probability: 25, health: 150, rarity: .normal),
        Item(name: "キリキリン", attack: 30,probability: 25, health: 200, rarity: .normal),
        Item(name: "カゲロウ", attack: 35,probability: 10, health: 220, rarity: .rare),
        Item(name: "ライム", attack: 40,probability: 10, health: 240, rarity: .rare),
        Item(name: "ラオン", attack: 45,probability: 10, health: 260, rarity: .rare),
        Item(name: "レッドドラゴン", attack: 47,probability: 5, health: 280, rarity: .superRare),
        Item(name: "ブルードラゴン", attack: 48,probability: 5, health: 285, rarity: .superRare),
        Item(name: "レインボードラゴン", attack: 50, probability: 3,health: 300, rarity: .ultraRare)
    ]

    // itemsリストをシャッフルする関数
      func shuffleItems() {
          items.shuffle()
      }

      func drawGacha() -> Item {
          let totalProbability = items.map { $0.probability }.reduce(0, +)
          let randomNumber = Int.random(in: 0..<totalProbability)
          var accumulatedProbability = 0
          @ObservedObject var authManager = AuthManager.shared
          
          for item in items {
              accumulatedProbability += item.probability
              if randomNumber < accumulatedProbability {
                  let selectedAvatar = Avatar(name: item.name, attack: item.attack, health: item.health , usedFlag: 0 ,count: 1)
                  authManager.addAvatarToUser(avatar: selectedAvatar) { success in
                     if success {
                         print("Avatar successfully added!")
                     } else {
                         print("Failed to add avatar.")
                     }
                 }
                  return item
              }
          }
          return items[0] // 念のためのデフォルトのアイテムを返す
      }
  }


struct GachaView: View {
    @State private var obtainedItem: GachaManager.Item? = nil
    private let gachaManager = GachaManager()
    @State private var animationFinished: Bool = false
    @State private var showAnimation: Bool = false
    @State private var showResult: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager.shared
    @State private var isGachaButtonDisabled: Bool = false
    @State private var userMoney: Int = 0
    @ObservedObject var audioManager = AudioManager.shared
    @State private var isShowingActivityIndicator: Bool = false

    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    Image("コイン")
                        .resizable()
                        .frame(width:20,height:20)
                    Text("+")
                    Text(" \(userMoney)")
                }
                .foregroundColor(Color("fontGray"))
                .padding(.trailing)
                // ガチャの結果を表示
                if showResult, let item = obtainedItem {  // showResultを使用して制御
                    //            if(showResult){
                    VStack{
                        ZStack{
                            Image("ガチャ背景5")
                                .resizable()
                            
                                .frame(maxWidth: .infinity,maxHeight:280)
                            Text("\(item.name)")
                                .foregroundColor(Color("fontGray"))
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .padding(.bottom,190)
                            Image("\(item.name)")
                                .resizable()
                                .frame(width: 150,height:150)
                                .padding(.top,70)
                        }
                        
                        HStack{
                            Image("ハート")
                                .resizable()
                                .frame(width: 30,height:30)
                            Text("体力：\(item.health)")
                                .font(.system(size: 24))
                            Image("ソード")
                                .resizable()
                                .frame(width: 40,height:30)
                            Text("攻撃力：\(item.attack)")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(Color("fontGray"))
                    }
                    Spacer()
                    Button(action: {
//                        self.isShowingActivityIndicator = true  // ローディング画面を表示
                        self.showResult = false
                        authManager.decreaseUserMoney { success in
                            if success {
                                print("User money decreased successfully.")
                            } else {
                                print("Failed to decrease user money.")
                            }
                        }
                        self.showAnimation = true
                            self.gachaManager.shuffleItems()
                            self.obtainedItem = self.gachaManager.drawGacha()
                        // ガチャを引く処理を非同期で実行
                        DispatchQueue.global().async {
                            // UIの更新はメインスレッドで実行
                            DispatchQueue.main.async {
//                                self.isShowingActivityIndicator = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    animationFinished = true
//                                    self.showResult = true
                                }
                            }
                        }
                    }){
                        if(isGachaButtonDisabled){
                            Image("もう一度ガチャる")
                                .resizable()
                                .frame(width:210,height:100)
                        }else{
                            Image("もう一度ガチャる白黒")
                                .resizable()
                                .frame(width:210,height:100)
                        }
                    }
                    .disabled(!isGachaButtonDisabled)
                    HStack{
                        Spacer()
                        Image("コイン300")
                            .resizable()
                            .frame(maxWidth:150,maxHeight:50)
                        Spacer()
                    }
                    Spacer()
                }else{
                    Image("ガチャ")
                        .resizable()
                        .frame(maxWidth:350,maxHeight:280)
                    Spacer()
                    HStack{
                        Button(action: {
                            self.showResult = false
                            authManager.decreaseUserMoney { success in
                                if success {
                                    print("User money decreased successfully.")
                                } else {
                                    print("Failed to decrease user money.")
                                }
                            }
                            self.showAnimation = true
                            self.gachaManager.shuffleItems()
                            self.obtainedItem = self.gachaManager.drawGacha()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                self.showResult = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    animationFinished = true
                                }
                            }
                        }) {
                            if(isGachaButtonDisabled){
                                Image("ガチャる")
                                    .resizable()
                                    .frame(width:210,height:100)
                            }else{
                                Image("ガチャる白黒")
                                    .resizable()
                                    .frame(width:210,height:100)
                            }
                        }
                        .shadow(radius: 10)
                        .disabled(!isGachaButtonDisabled)
                    }
                    HStack{
                        Spacer()
                        Image("コイン300")
                            .resizable()
                            .frame(maxWidth:150,maxHeight:50)
                        Spacer()
                    }
                    Spacer()
                    Image("卵レア度")
                        .resizable()
                        .frame(maxWidth:350 , maxHeight:120)
                }
                Spacer()
            }
            if isShowingActivityIndicator {
                              ActivityIndicator()
                          .frame(maxWidth: .infinity, maxHeight: .infinity)
                          .background(Color.white)
                          .cornerRadius(10)
                          .shadow(radius: 10)
                      }
        }
        .onAppear {
            authManager.getUserMoney { userMoney in
                print(userMoney)
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 300){
                    isGachaButtonDisabled = false
                }else{
                    isGachaButtonDisabled = true
                }
            }
        }
        .onChange(of: showAnimation) { userMoney in
            authManager.getUserMoney { userMoney in
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 300){
                    isGachaButtonDisabled = false
                }else{
                    isGachaButtonDisabled = true
                }
            }
        }
        .onChange(of: isShowingActivityIndicator) { isShowing in
            if isShowing {
                self.isShowingActivityIndicator = isShowingActivityIndicator
            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                })
        .background(Color("Color2"))
           .onChange(of: animationFinished) { finished in
               if finished {
                   self.showAnimation = false
               }
           }
           .fullScreenCover(isPresented: $showAnimation) {
               GachaAnimationView(showAnimation: $showAnimation, rarity: obtainedItem?.rarity, showResult: $showResult) // この行を変更
           }
        
       }

    func colorForRarity(_ rarity: GachaManager.Rarity) -> Color {
        switch rarity {
        case .normal:
            return .gray
        case .rare:
            return .green
        case .superRare:
            return .purple
        case .ultraRare:
            return .purple
        }
    }
}

struct GachaView_Previews: PreviewProvider {
    static var previews: some View {
        GachaView()
    }
}
