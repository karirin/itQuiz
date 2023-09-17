//
//  QuizView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct TimerArc: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct QuizView: View {
    let quizzes: [QuizQuestion]
    @State private var selectedAnswerIndex: Int? = nil
    @State private var currentQuizIndex = 0
    @State private var showCompletionMessage = false
    @State private var remainingSeconds = 30
    @State private var timer: Timer? = nil
    @State private var navigateToContentView = false

    var currentQuiz: QuizQuestion {
        quizzes[currentQuizIndex]
    }

    // タイマーの処理
    func startTimer() {
        self.timer?.invalidate() // 現在のタイマーを止める
        self.remainingSeconds = 30
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                timer.invalidate()
                moveToNextQuiz()
            }
        }
    }

    // 次の問題へ移る処理
    func moveToNextQuiz() {
        if currentQuizIndex + 1 < 3 { // 最大3問まで
            currentQuizIndex += 1
            selectedAnswerIndex = nil
            startTimer()
        } else {
            showCompletionMessage = true
            timer?.invalidate() // タイマーを止める
        }
    }

    var body: some View {
        NavigationView{
            VStack {
                Text(currentQuiz.question)
                    .font(.headline)
                    .padding()
                
                ZStack {
                    // 背景の円
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .opacity(0.3)
                    
                    // アニメーションする円
                    TimerArc(startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(remainingSeconds) / 30.0 * 360.0))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(remainingSeconds <= 5 ? Color.red : Color.blue)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(remainingSeconds)秒")
                        .foregroundColor(remainingSeconds <= 5 ? .red : .black) // 5秒以下で赤色に
                }
                .frame(width: 50, height: 50)
                
                ForEach(0..<currentQuiz.choices.count, id: \.self) { index in
                    Button(action: {
                        self.selectedAnswerIndex = index
                        self.timer?.invalidate() // 回答を選択したらタイマーを止める
                    }) {
                        Text(currentQuiz.choices[index])
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if let selected = selectedAnswerIndex {
                    if selected == currentQuiz.correctAnswerIndex {
                        Text("正解!")
                            .foregroundColor(.green)
                        
                        Button("次の問題へ") {
                            moveToNextQuiz()
                        }
                    } else {
                        Text("不正解")
                            .foregroundColor(.red)
                        Button("次の問題へ") {
                            moveToNextQuiz()
                        }
                    }
                }
                
                if showCompletionMessage {
                    Text("クイズ終了！")
                        .font(.headline)
                        .padding()
                    
                    NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToContentView)
                }
            }
            .onAppear {
                startTimer() // Viewが表示されたときにタイマーを開始
            }
            .onChange(of: showCompletionMessage) { newValue in
                if newValue {
                    navigateToContentView = true
                }
            }
        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList()
    }
}
