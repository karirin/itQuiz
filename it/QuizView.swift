//
//  QuizView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import AVFoundation

enum QuizLevel {
    case beginner
    case intermediate
    case advanced
    case network
}

struct TimerArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

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
        }
        .cornerRadius(8.0)
    }
}


struct QuizView: View {
    let quizzes: [QuizQuestion]
    let quizLevel: QuizLevel
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
    @State private var playerHP: Int = 1000
    @State private var monsterHP: Int = 3000
    @State private var monsterUnderHP: Int = 30
    @State private var monsterAttack: Int = 20
    @State private var userName: String = ""
    @State private var userIcon: String = ""
    @State private var monsterBackground: String = ""
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var monsterType: Int = 0
    @State private var shakeEffect = false
    @State private var audioPlayerCorrect: AVAudioPlayer?
    @State private var audioPlayerUnCorrect: AVAudioPlayer?
    @State private var audioPlayerAttack: AVAudioPlayer?
    @State private var audioPlayerMonsterAttack: AVAudioPlayer?
    @State private var audioPlayerCountDown: AVAudioPlayer?
    @State private var showAttackImage = false
    @State private var showIncorrectBackground = false
    @EnvironmentObject var soundSettings: SoundSettings
    
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
                playerHP -= monsterAttack
                moveToNextQuiz()
            }
        }
    }
    
    // 次の問題へ移る処理
    func moveToNextQuiz() {
        if currentQuizIndex + 1 < 100 { // 最大3問まで
            currentQuizIndex += 1
            print("currentQuizIndex:\(currentQuizIndex)")
            selectedAnswerIndex = nil
            startTimer()
        } else {
            showCompletionMessage = true
            timer?.invalidate() // タイマーを止める
        }
    }
    
    func playCorrectSound() {
        audioPlayerCorrect?.play()
    }
    
    func playerUnCorrectSound() {
        audioPlayerUnCorrect?.play()
    }
    
    func playAttackSound() {
        audioPlayerAttack?.play()
    }
    
    func playMonsterAttackSound() {
        audioPlayerMonsterAttack?.play()
    }
    
    func playerCountDownSound() {
        audioPlayerCountDown?.play()
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack {
                    HStack{
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .frame(width: 50, height: 50)
                            .padding(.leading)
                            .opacity(0)
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
                    VStack{
                        ZStack {
                            Text(currentQuiz.question)
                                .font(.headline)
                                .frame(height:70)
                                .padding(.horizontal)
                            
                            // 正解の場合の赤い円
                            if let selected = selectedAnswerIndex, selected == currentQuiz.correctAnswerIndex {
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                    .opacity(0.7)
                                    .foregroundColor(.red)
                                    .frame(width: 70)
                            }
                            // 不正解の場合の青いバツマーク
                            else if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .opacity(0.7)
                                    .foregroundColor(.blue)
                                    .frame(width: 70,height:70)
                            }
                        }
                        ZStack{
                            Image("\(monsterBackground)")
                                .resizable()
                                .frame(height:140)
                                .opacity(1)
                            VStack() {
                                //                            Spacer()
                                ZStack{
                                    if monsterHP == 0 {
                                        Image("attack1")
                                            .resizable()
                                            .frame(width:150,height:150)
                                    }else{
                                        VStack{
                                            Image("\(quizLevel)Monster\(monsterType)")
                                                .resizable()
                                                .frame(width:100,height:100)
                                        }
                                    }
                                    
                                    if let selected = selectedAnswerIndex {
                                        if selected == currentQuiz.correctAnswerIndex {
                                            if showAttackImage && monsterHP != 0 {
                                                Image("attack1")
                                                    .resizable()
                                                    .frame(width:80,height:80)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        HStack{
                            ProgressBar3(value: Double(monsterHP), maxValue: Double(monsterUnderHP), color: Color("hpMonsterColor"))
                                .frame(height: 20)
                            Text("\(monsterHP)/\(monsterUnderHP)")
                        }
                        .padding(.horizontal)
                        ZStack{
                            HStack{
                                Image(userIcon.isEmpty ? "defaultIcon" : userIcon)
                                    .resizable()
                                    .frame(width: 30,height:30)
                                ProgressBar3(value: Double(playerHP), maxValue: 1000.0, color: Color("hpUserColor"))
                                    .frame(height: 20)
                                Text("\(playerHP)/1000")
                            }
                            .padding(.horizontal)
                            if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                                if showAttackImage{
                                    Image("\(quizLevel)MonsterAttack\(monsterType)")
                                        .resizable()
                                        .frame(width:30,height:30)
                                }
                            }
                        }
                    }
                    Spacer()
                    VStack{
                        ForEach(0..<currentQuiz.choices.count, id: \.self) { index in
                            HStack{
                                Button(action: {
                                    self.selectedAnswerIndex = index
                                    self.timer?.invalidate() // 回答を選択したらタイマーを止める
                                    
                                    let isAnswerCorrect = (selectedAnswerIndex == currentQuiz.correctAnswerIndex)
                                    if isAnswerCorrect {
                                        playCorrectSound()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            playAttackSound()
                                            self.showAttackImage = true
                                            //                                        }
                                            correctAnswerCount += 1 // 正解の場合、正解数をインクリメント
                                            //                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            monsterHP -= userAttack
                                            if monsterHP <= 0 {
                                                // モンスターのHPが0以下になった場合の処理
                                                monsterType += 1  // 次のモンスターに移行
                                                monsterHP = 100  // 新しいモンスターのHPをリセット
                                                if monsterType == 4 {
                                                    showCompletionMessage = true
                                                    timer?.invalidate()
                                                }
                                            } else if playerHP <= 0 {
                                                // プレイヤーのHPが0以下になった場合の処理
                                                showCompletionMessage = true
                                                timer?.invalidate()
                                            }
                                        }
                                    } else {
                                        playerUnCorrectSound()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            playMonsterAttackSound()
                                            playerHP -= monsterAttack
                                            self.showAttackImage = true
                                        }
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
                                        self.showAttackImage = false
                                        moveToNextQuiz()
                                    }
                                }) {
                                    Text(currentQuiz.choices[index])
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                .padding(.vertical,2)
                            }
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 1)
                        }
                        //                Spacer()
                        
                        if showCompletionMessage {
                            NavigationLink("", destination: QuizResultView(results: quizResults).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity,maxHeight:.infinity)
                .padding(.bottom)
                .background(showIncorrectBackground ? Color("superLightRed") : Color("backgroudGray"))
                .sheet(isPresented: $showModal) {
                    ExperienceModalView(showModal: $showModal, addedExperience: 10)
                }
                if showCountdown {
                    ZStack {
                        // 背景
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        // カウントダウンの数字
                        Text("\(countdownValue)")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            startTimer() // Viewが表示されたときにタイマーを開始
            startCountdown()
            self.monsterType = 1 // すぐに1に戻す
            authManager.fetchUserInfo { (name, icon, money, hp, attack) in
                self.userName = name ?? ""
                self.userIcon = icon ?? ""
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
            }
            if let soundURL = Bundle.main.url(forResource: "正解", withExtension: "mp3") {
                do {
                    audioPlayerCorrect = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if let soundURL = Bundle.main.url(forResource: "不正解", withExtension: "mp3") {
                do {
                    audioPlayerUnCorrect = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if let soundURL = Bundle.main.url(forResource: "味方攻撃", withExtension: "mp3") {
                do {
                    audioPlayerAttack = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if let soundURL = Bundle.main.url(forResource: "敵攻撃", withExtension: "mp3") {
                do {
                    audioPlayerMonsterAttack = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if let soundURL = Bundle.main.url(forResource: "カウントダウン", withExtension: "mp3") {
                do {
                    audioPlayerCountDown = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
             playerCountDownSound()
        }
        .onChange(of: selectedAnswerIndex) { newValue in
            if let selected = newValue, selected != currentQuiz.correctAnswerIndex {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showIncorrectBackground = true
                }
            } else {
                self.showIncorrectBackground = false
            }
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
        .onChange(of: monsterType) { newMonsterType in
            switch quizLevel {
            case .beginner:
                monsterBackground = "beginnerBackground"
                switch newMonsterType {
                case 1:
                    monsterHP = 30
                    monsterUnderHP = 30
                    monsterAttack = 20
                case 2:
                    monsterHP = 40
                    monsterUnderHP = 40
                    monsterAttack = 25
                case 3:
                    monsterHP = 50
                    monsterUnderHP = 50
                    monsterAttack = 30
                default:
                    monsterHP = 30
                }
            case .intermediate:
                monsterBackground = "intermediateBackground"
                switch newMonsterType {
                case 1:
                    monsterHP = 50
                    monsterUnderHP = 50
                    monsterAttack = 30
                case 2:
                    monsterHP = 60
                    monsterUnderHP = 60
                    monsterAttack = 35
                case 3:
                    monsterHP = 70
                    monsterUnderHP = 70
                    monsterAttack = 40
                default:
                    monsterHP = 50
                }
            case .advanced:
                monsterBackground = "advancedBackground"
                switch newMonsterType {
                case 1:
                    monsterHP = 80
                    monsterUnderHP = 80
                    monsterAttack = 45
                case 2:
                    monsterHP = 90
                    monsterUnderHP = 90
                    monsterAttack = 50
                case 3:
                    monsterHP = 100
                    monsterUnderHP = 100
                    monsterAttack = 55
                default:
                    monsterHP = 80
                }
            case .network:
                monsterBackground = "networkBackground"
                switch newMonsterType {
                case 1:
                    print("\(monsterBackground)")
                    monsterHP = 50
                    monsterUnderHP = 50
                    monsterAttack = 30
                case 2:
                    monsterHP = 60
                    monsterUnderHP = 60
                    monsterAttack = 35
                case 3:
                    monsterHP = 70
                    monsterUnderHP = 70
                    monsterAttack = 40
                default:
                    monsterHP = 50
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
