//
//  ProgressStoryView.swift
//  it
//
//  Created by Apple on 2024/11/23.
//

import SwiftUI

struct ProgressStoryView: View {
    @Binding var progress: Float
    @State private var animateGradient = false

    var body: some View {
        ZStack(alignment: .leading) {
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
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 20)
    }
}


struct ProgressStoryView_Previews: PreviewProvider {
    @State static var progress: Float = 0.5
    
    static var previews: some View {
        ProgressStoryView(progress: $progress)
            .previewLayout(.sizeThatFits)
    }
}
