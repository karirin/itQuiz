//
//  ProgressBar3.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/29.
//

import SwiftUI

struct ProgressBar3: View {
    var value: Double
    var maxValue: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.3)
                    .foregroundColor(color)
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(value / maxValue))
                    .foregroundColor(color)
            }            
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(Color.black, lineWidth: 1) // 枠線の色と幅を指定
            )
        }
        .cornerRadius(8.0)
    }
}
