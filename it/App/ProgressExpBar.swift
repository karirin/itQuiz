//
//  ProgressExpBar.swift
//  it
//
//  Created by Apple on 2024/12/13.
//

import SwiftUI

struct ProgressExpBar: View {
    let level: Int
    let experience: Int
    
    private var maxExperience: Int { max(level, 1) * 100 }
    
    private var progress: CGFloat {
        let maxExp = maxExperience
        guard maxExp > 0 else { return 0 }
        return min(max(CGFloat(experience) / CGFloat(maxExp), 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("経験値")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(experience) / \(maxExperience)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("fontGray"))
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    
                    // シャイン効果
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
                .frame(height: 12)
            }
        }
    }
}

#Preview {
    ProgressExpBar(level: 3, experience: 200)
}
