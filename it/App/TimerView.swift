//
//  TimerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/15.
//

import SwiftUI

struct TimerView: View {
    @Binding var remainingSeconds: Int
    private let totalSeconds: Int = 30
    
    private var progress: Double {
        Double(remainingSeconds) / Double(totalSeconds)
    }
    
    private var timerColor: Color {
        if remainingSeconds <= 5 {
            return .red
        } else if remainingSeconds <= 10 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        ZStack {
            // 背景サークル
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: 40, height: 40)
            
            // プログレスサークル
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remainingSeconds)
            
            // 時間テキスト
            Text("\(remainingSeconds)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(timerColor)
        }
        .padding(8)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: timerColor.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedUser = User(id: "1", userName: "SampleUser", level: 1, experience: 100, avatars: [], userMoney: 1000, userHp: 100, userAttack: 20, userFlag: 0, adminFlag: 0, rankMatchPoint: 100, rank: 1)

//        TimerView(remainingSeconds: .constant(30))
        QuizITBasicList(isPresenting: .constant(false))
    }
}
