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
        let probability: Int
        let rarity: Rarity
    }

    enum Rarity: Int {
        case normal = 40
        case rare = 30
        case superRare = 20
        case ultraRare = 10
    }

    var items: [Item] = [
        Item(name: "もりこう", probability: 25, rarity: .normal),
        Item(name: "ルイーカ", probability: 25, rarity: .normal),
        Item(name: "うっさん", probability: 25, rarity: .normal),
        Item(name: "キリキリン", probability: 25, rarity: .normal),
        Item(name: "カゲロウ", probability: 10, rarity: .rare),
        Item(name: "ライム", probability: 10, rarity: .rare),
        Item(name: "ラオン", probability: 10, rarity: .rare),
        Item(name: "レッドドラゴン", probability: 5, rarity: .superRare),
        Item(name: "ブルードラゴン", probability: 5, rarity: .superRare),
        Item(name: "レインボードラゴン", probability: 3, rarity: .ultraRare)
    ]

    // itemsリストをシャッフルする関数
      func shuffleItems() {
          items.shuffle()
      }

      func drawGacha() -> Item {
          let totalProbability = items.map { $0.probability }.reduce(0, +)
          let randomNumber = Int.random(in: 0..<totalProbability)
          var accumulatedProbability = 0
          
          for item in items {
              accumulatedProbability += item.probability
              if randomNumber < accumulatedProbability {
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
    @State private var showResult: Bool = true  // 新しい状態変数

    var body: some View {
        VStack{
            Spacer()
            // ガチャの結果を表示
//            if showResult, let item = obtainedItem {  // showResultを使用して制御
            VStack{
                    ZStack{
                    Image("ガチャ結果名")
                        .resizable()
                        .frame(width: 300,height:100)
                    Text("もりこう")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .padding(.top,40)
                }
                    ZStack{
                        Image("ガチャ背景")
                            .resizable()
                            .frame(maxWidth: .infinity,maxHeight:200)
                            .padding(.bottom)
                        //                    Image("\(item.name)")
                        Image("もりこう")
                            .resizable()
                            .frame(width: 150,height:150)
                    }
                HStack{
                    Image("ハート")
                        .resizable()
                        .frame(width: 30,height:30)
                    Text("体力：20")
                        .font(.system(size: 24))
                    
                    Image("ソード")
                        .resizable()
                        .frame(width: 40,height:30)
                    Text("攻撃力：20")
                        .font(.system(size: 24))
                }
            }
//                Text("ゲットしたアイテム: \(item.name)")
//                    .foregroundColor(colorForRarity(item.rarity))
            Spacer()
                Button(action: {
                    self.gachaManager.shuffleItems()  // itemsリストをシャッフル
                    self.obtainedItem = self.gachaManager.drawGacha()  // 先にobtainedItemを更新
                    self.showAnimation = true
                    self.showResult = false
                    
                    // 1秒の遅延を追加
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showResult = true  // 結果を表示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            animationFinished = true
                        }
                    }
                }) {
                    Image("もう一度ガチャる")
                        .resizable()
                        .frame(width:230,height:100)
                }
            Spacer()
            Spacer()
//            }else{
//
//                Image("ガチャ")
//                    .resizable()
//                    .frame(maxWidth:330,maxHeight:250)
//
//                // ガチャを引くボタン
//                Button(action: {
//                    self.gachaManager.shuffleItems()  // itemsリストをシャッフル
//                    self.obtainedItem = self.gachaManager.drawGacha()  // 先にobtainedItemを更新
//                    self.showAnimation = true
//                    self.showResult = false
//
//                    // 1秒の遅延を追加
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.showResult = true  // 結果を表示
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                            animationFinished = true
//                        }
//                    }
//                }) {
//                    Image("ガチャる")
//                        .resizable()
//                        .frame(width:260,height:130)
//                    //                    .padding()
//                    //                    .background(Color.blue)
//                    //                    .foregroundColor(.white)
//                    //                    .cornerRadius(8)
//                }
//                Image("卵レア度")
//                    .resizable()
//                    .frame(maxWidth:250,maxHeight:180)
//            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
           .onChange(of: animationFinished) { finished in  // この行を追加
               if finished {
                   self.showAnimation = false
               }
           }
           .fullScreenCover(isPresented: $showAnimation) {
               GachaAnimationView(showAnimation: $showAnimation, rarity: obtainedItem?.rarity)  // この行を変更
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
