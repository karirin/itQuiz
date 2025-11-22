//
//  MockView.swift
//  it
//
//  Created by Apple on 2024/10/12.
//

import SwiftUI
import StoreKit

struct MockView: View {
    @Binding var progress: Float
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // 背景バー
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 20)

            // 進捗バー
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.yellow, Color.orange]),
                        startPoint: animateGradient ? .leading : .trailing,
                        endPoint: animateGradient ? .trailing : .leading
                    )
                )
                .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(progress), height: 20)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: animateGradient)
                .onAppear {
                    animateGradient = true
                }

            // パーセンテージテキスト
            Text(String(format: "%.0f%%", progress * 100))
                .font(.caption)
                .foregroundColor(.black)
                .bold()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 20, alignment: .center)
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 20)
    }
}


struct MockView_Previews: PreviewProvider {
    @State static var progress: Float = 0.5
    
    static var previews: some View {
        MockView(progress: $progress)
            .previewLayout(.sizeThatFits)
    }
}

