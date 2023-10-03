//
//  SpotlightView1.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/03.
//

import SwiftUI

struct SpotlightView1: View {
    @State private var showTutorial = true // チュートリアルを表示するかどうかを制御するフラグ

      var body: some View {
          ZStack {
              // 通常のUI
              VStack {
                  Text("Hello, World!")
                  Button("End Tutorial") {
                      showTutorial = false
                  }
              }

              // チュートリアル
              if showTutorial {
                  SpotlightView()
                      .animation(.default) // アニメーションを追加
                      .onTapGesture {
                          showTutorial = false // タップでチュートリアルを終了
                      }
              }
          }
      }
  }



struct SpotlightView1_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightView1()
    }
}
