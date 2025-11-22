//
//  ProgressExpBar.swift
//  it
//
//  Created by Apple on 2024/12/13.
//

import SwiftUI

struct ProgressExpBar: View {
    var level: Int
    var experience: Int

    var body: some View {
        HStack(spacing: -10){
            Text("経験値")
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width , height: geometry.size.height)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.mint, Color.green, Color.mint]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: CGFloat(experience) / CGFloat(level * 100) * geometry.size.width, height: geometry.size.height)
                }
            }.frame(height:20).cornerRadius(45.0).padding(.horizontal)
            Text("\(experience) / \(level * 100)")
        }.padding(.leading,5).fontWeight(.bold)
    }
}

#Preview {
    ProgressExpBar(level: 3, experience: 200)
}
