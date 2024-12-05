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
        HStack{
            ZStack(alignment: .leading) {
                // 背景バー
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width:350, height: 20)
                
                // 進捗バー
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.yellow, Color.orange]),
                            startPoint: animateGradient ? .leading : .trailing,
                            endPoint: animateGradient ? .trailing : .leading
                        )
                    )
                    .frame(width: 350 * CGFloat(progress), height: 20)
                    .onAppear {
                        animateGradient = true
                    }
            }
        }
    }
}


struct ProgressStoryView_Previews: PreviewProvider {
    @State static var progress: Float = 0.7
    
    static var previews: some View {
        ProgressStoryView(progress: $progress)
            .previewLayout(.sizeThatFits)
    }
}
