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
            Circle()
                            .fill(Color.black.opacity(0.7))
        Text("\(remainingSeconds)秒")
            .foregroundColor(remainingSeconds <= 5 ? .red : .white)
            .fontWeight(.bold)
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .opacity(0.3)
                    .foregroundColor(.gray)
            TimerArc(startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(remainingSeconds) / 30.0 * 360.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(remainingSeconds <= 5 ? Color.red : Color(hue: 0.642, saturation: 0.517, brightness: 0.605))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 50, height: 50)
        .padding(.leading)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedUser = User(id: "1", userName: "SampleUser", level: 1, experience: 100, avatars: [], userMoney: 1000, userHp: 100, userAttack: 20, userFlag: 0, adminFlag: 0, rankMatchPoint: 100, rank: 1)

        TimerView(remainingSeconds: .constant(30))
    }
}
