//
//  SpotlightView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/03.
//

import SwiftUI

struct SpotlightView: View {
    var body: some View {
        // 画面全体をカバーする黒いビュー
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            // スポットライトの領域をカットアウト
            .overlay(
                Circle()
                    .frame(width: 100, height: 100)
                    .offset(x: 50, y: 50) // このオフセットを変更してスポットライトの位置を調整
                    .blendMode(.destinationOut)
            )
    }
}

struct SpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightView()
    }
}

