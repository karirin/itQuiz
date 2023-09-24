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
        let rarity: Rarity
    }

    enum Rarity: Int {
        case normal = 60
        case rare = 30
        case superRare = 10
        case ultraRare = 20
    }

    let items: [Item] = [
        Item(name: "もりこう", rarity: .normal),
        Item(name: "ルイーカ", rarity: .normal),
        Item(name: "うっさん", rarity: .normal),
        Item(name: "キリキリン", rarity: .normal),
        Item(name: "カゲロウ", rarity: .rare),
        Item(name: "ライム", rarity: .rare),
        Item(name: "ラオン", rarity: .rare),
        Item(name: "レッドドラゴン", rarity: .superRare),
        Item(name: "ブルードラゴン", rarity: .superRare),
        Item(name: "レインボードラゴン", rarity: .ultraRare)
    ]

    func drawGacha() -> Item {
        let randomNumber = Int.random(in: 0..<100)
        var accumulatedProbability = 0

        for item in items {
            accumulatedProbability += item.rarity.rawValue
            if randomNumber < accumulatedProbability {
                return item
            }
        }

        return items[0] // デフォルトのアイテムを返す
    }
}


struct GachaView: View {
    @State private var obtainedItem: GachaManager.Item? = nil
    private let gachaManager = GachaManager()
    @State private var animationFinished: Bool = false
    @State private var showAnimation: Bool = false

    var body: some View {
           VStack(spacing: 20) {
               // ガチャの結果を表示
               if animationFinished, let item = obtainedItem {
                   Image("\(item.name)")
                       .resizable()
                       .frame(width: 150,height:150)
                   Text("ゲットしたアイテム: \(item.name)")
                       .foregroundColor(colorForRarity(item.rarity))
               }

               // ガチャを引くボタン
               Button(action: {
                   self.showAnimation = true
                   self.obtainedItem = self.gachaManager.drawGacha()
                   DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                       animationFinished = true
                   }
               }) {
                   Text("ガチャを引く")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
               }
           }
           .padding()
           .onChange(of: animationFinished) { finished in  // この行を追加
               if finished {
                   self.showAnimation = false
               }
           }
           .fullScreenCover(isPresented: $showAnimation) {
               GachaAnimationView(showAnimation: $showAnimation)  // この行を変更
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
