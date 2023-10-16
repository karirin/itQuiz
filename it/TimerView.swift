//
//  TimerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/15.
//

import SwiftUI

struct TimerView: View {
    @Binding var remainingSeconds: Int
    
    var body: some View {
        ZStack {
            // 背景の円
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(.gray)
            
            // アニメーションする円
            // TimerArc(...) の部分は、あなたのコードに合わせてください。
            TimerArc(startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(remainingSeconds) / 30.0 * 360.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(remainingSeconds <= 5 ? Color.red : Color("purple1"))
                .rotationEffect(.degrees(-90))
            
            Text("\(remainingSeconds)秒")
                .foregroundColor(remainingSeconds <= 5 ? .red : .black)
        }
        .frame(width: 50, height: 50)
        .padding(.leading)
    }
}
