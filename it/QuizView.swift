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
    @State private var navigateToQuizResultView = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var showModal = false
    @State private var quizResults: [QuizResult] = []
    @State private var correctAnswerCount = 0
    @State private var countdownValue = 3
    @State private var showCountdown = true
    
    var currentQuiz: QuizQuestion {
        quizzes[currentQuizIndex]
    }
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                timer.invalidate()
                showCountdown = false
                startTimer() // カウントダウンが終了したら、クイズのタイマーを開始
            }
        }
    }

    // タイマーの処理
    func startTimer() {
        self.timer?.invalidate() // 現在のタイマーを止める
        self.remainingSeconds = 3000
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
                if showCountdown {
                                    Text("\(countdownValue)")
                                        .font(.system(size: 200))
                                        .foregroundColor(.gray)
                                        .transition(.scale)
                }else{
                    HStack{
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .frame(width: 50, height: 50)
                            .padding(.leading)
                            .opacity(0)
                        Spacer()
                        if let selected = selectedAnswerIndex {
                            if selected == currentQuiz.correctAnswerIndex {
                                Text("正解")
                                    .font(.system(size:40))
                                    .foregroundColor(.green)
                            } else {
                                Text("不正解")
                                    .font(.system(size:40))
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                        ZStack {
                            // 背景の円
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                .opacity(0.3)
                                .foregroundColor(.gray)
                            
                            // アニメーションする円
                            TimerArc(startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(remainingSeconds) / 30.0 * 360.0))
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                .foregroundColor(remainingSeconds <= 5 ? Color.red : Color("purple1"))
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(remainingSeconds)秒")
                                .foregroundColor(remainingSeconds <= 5 ? .red : .black) // 5秒以下で赤色に
                        }
                        .frame(width: 50, height: 50)
                        
                    }
                    .padding(.trailing)
                    Spacer()
                    ZStack {
                        Text(currentQuiz.question)
                            .font(.headline)
                            .padding()
                        
                        // 正解の場合の赤い円
                        if let selected = selectedAnswerIndex, selected == currentQuiz.correctAnswerIndex {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                .opacity(0.7)
                                .foregroundColor(.red)
                                .frame(width: 200, height: 200)
                        }
                        // 不正解の場合の青いバツマーク
                        else if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                            Image(systemName: "xmark")
                                .resizable()
                                .opacity(0.7)
                                .foregroundColor(.blue)
                                .frame(width: 200, height: 200)
                        }
                    }
                    Spacer()
                    
                    ForEach(0..<currentQuiz.choices.count, id: \.self) { index in
                        HStack{
                            Button(action: {
                                self.selectedAnswerIndex = index
                                self.timer?.invalidate() // 回答を選択したらタイマーを止める
                                
                                let isAnswerCorrect = (selectedAnswerIndex == currentQuiz.correctAnswerIndex)
                                if isAnswerCorrect {
                                    correctAnswerCount += 1 // 正解の場合、正解数をインクリメント
                                }
                                
                                let result = QuizResult(
                                    question: currentQuiz.question,
                                    userAnswer: currentQuiz.choices[index],
                                    correctAnswer: currentQuiz.choices[currentQuiz.correctAnswerIndex],
                                    explanation: currentQuiz.explanation,
                                    isCorrect: isAnswerCorrect
                                )
                                quizResults.append(result)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    moveToNextQuiz()
                                }
                            }) {
                                Text(currentQuiz.choices[index])
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("purple"))
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 1)
                    }
                    //                Spacer()
                    
                    if showCompletionMessage {
                        NavigationLink("", destination: QuizResultView(results: quizResults).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                    }
                }
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity)
            .padding(.bottom)
            .sheet(isPresented: $showModal) {
                ExperienceModalView(showModal: $showModal, addedExperience: 10)
            }
            .onAppear {
                startTimer() // Viewが表示されたときにタイマーを開始
                startCountdown()
            }
            .onChange(of: showCompletionMessage) { newValue in
                if newValue && correctAnswerCount >= 0 {
                    authManager.addExperience(points: 80)
                    authManager.addMoney(amount: 50)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showModal = false
                    navigateToQuizResultView = true
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
