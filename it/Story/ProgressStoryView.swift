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
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 18)

                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.yellow, Color.orange]),
                            startPoint: animateGradient ? .leading : .trailing,
                            endPoint: animateGradient ? .trailing : .leading
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 18)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            animateGradient = true
                        }
                    }
            }
        }
        .frame(height: 18)
    }
}


struct ProgressStoryView_Previews: PreviewProvider {
    @State static var progress: Float = 0.7
    
    static var previews: some View {
        ProgressStoryView(progress: $progress)
            .previewLayout(.sizeThatFits)
    }
}
