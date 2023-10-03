//
//  QuizView.swift main
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

struct QuizView: View {
    let quizzes: [QuizQuestion]
    let quizLevel: QuizLevel
    @State private var selectedAnswerIndex: Int? = nil
    @State private var currentQuizIndex: Int = 0
    @State private var showCompletionMessage: Bool = false
    @State private var remainingSeconds: Int = 30
    @State private var timer: Timer? = nil
    @State private var navigateToQuizResultView: Bool = false
    @ObservedObject var authManager : AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showModal: Bool = false
    @State private var quizResults: [QuizResult] = []
    @State private var correctAnswerCount: Int = 0
    @State private var countdownValue: Int = 3
    @State private var showCountdown: Bool = true
    @State private var playerHP: Int = 1000
    @State private var monsterHP: Int = 3000
    @State private var monsterUnderHP: Int = 30
    @State private var monsterAttack: Int = 30
    @State private var userName: String = ""
    @State private var avator: [[String: Any]] = []
    @State private var monsterBackground: String = ""
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 30
    @State private var monsterType: Int = 0
    @State private var playerExperience: Int = 0
    @State private var playerMoney: Int = 0
    @State private var shakeEffect: Bool = false
    @State private var showAttackImage: Bool = false
    @State private var showMonsterDownImage: Bool = false
    @State private var showIncorrectBackground: Bool = false
    @State private var hasAnswered: Bool = false
    @Binding var isPresenting: Bool
    
    
    var currentQuiz: QuizQuestion {
        quizzes[currentQuizIndex]
    }
    
    func startCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
    }
    
    // タイマーの処理
    func startTimer() {
        // 現在のタイマーを止める
        self.timer?.invalidate()
        
        // 3秒後に以下のコードブロックを実行
        self.remainingSeconds = 30
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                timer.invalidate()
                // ここでplayerHPとmonsterAttackは既に定義されている必要があります
                playerHP -= monsterAttack
                self.moveToNextQuiz()
            }
        }
    }
    
    // 次の問題へ移る処理
    func moveToNextQuiz() {
        if currentQuizIndex + 1 < 100 { // 最大3問まで
            currentQuizIndex += 1
            selectedAnswerIndex = nil
            startTimer()
            hasAnswered = false
        } else {
            showCompletionMessage = true
            timer?.invalidate() // タイマーを止める
        }
    }
    
    func answerSelectionAction(index: Int) {
        if !hasAnswered {
            self.selectedAnswerIndex = index
            self.timer?.invalidate() // 回答を選択したらタイマーを止める
            
            let isAnswerCorrect = (selectedAnswerIndex == currentQuiz.correctAnswerIndex)
            if isAnswerCorrect {
                audioManager.playCorrectSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    audioManager.playAttackSound()
                    
                    self.showAttackImage = true
                    //                                        }
                    correctAnswerCount += 1 // 正解の場合、正解数をインクリメント
                    //                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    monsterHP -= userAttack
                    if monsterHP <= 0 {
                        // モンスターのHPが0以下になった場合の処理
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            monsterType += 1  // 次のモンスターに移行
                            monsterHP = 100  // 新しいモンスターのHPをリセット
                            self.showMonsterDownImage = true
                        }
                        if monsterType == 3 {
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
                audioManager.playUnCorrectSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    audioManager.playMonsterAttackSound()
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
            hasAnswered = true
        }
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
                        if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                            Text("正解")
                            Text("\(currentQuiz.choices[currentQuiz.correctAnswerIndex])")
                        }
                        Spacer()
                        // 正解の場合の赤い円
                        if let selected = selectedAnswerIndex, selected == currentQuiz.correctAnswerIndex {
                        }
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
                                    ZStack{
                                        Image("\(quizLevel)Monster\(monsterType)")
                                            .resizable()
                                            .frame(width:100,height:100)
                                        // 敵キャラを倒した
                                        if showMonsterDownImage && monsterHP == 0 {
                                            Image("倒す")
                                                .resizable()
                                                .frame(width:150,height:150)
                                        }
                                    }
                                    
                                    // 問題に正解して敵キャラにダメージ
                                    if let selected = selectedAnswerIndex {
                                        if selected == currentQuiz.correctAnswerIndex {
                                            if showAttackImage {
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
                            // 味方キャラのHP
                            HStack{
                                Image(avator.isEmpty ? "defaultIcon" : (avator.first?["name"] as? String) ?? "")
                                    .resizable()
                                    .frame(width: 30,height:30)
                                ProgressBar3(value: Double(playerHP), maxValue: 1000.0, color: Color("hpUserColor"))
                                    .frame(height: 20)
                                Text("\(playerHP)/1000")
                            }
                            .padding(.horizontal)
                            
                            // 味方がダメージをくらう
                            if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                                if showAttackImage{
//                                    Image("\(quizLevel)MonsterAttack\(monsterType)")
                                    Image("beginnerMonsterAttack\(monsterType)")
                                        .resizable()
                                        .frame(width:30,height:30)
                                }
                            }
                        }
                    }
                    Spacer()
                    VStack{
                        //                        VStack {
                        AnswerSelectionView(choices: currentQuiz.choices) { index in
                            answerSelectionAction(index: index)
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 1)
                        Spacer()
                        
                        if showCompletionMessage {
                            NavigationLink("", destination: QuizResultView(results: quizResults, authManager: authManager,isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                        }
                        //                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity,maxHeight:.infinity)
                    .padding(.bottom)
                    .background(showIncorrectBackground ? Color("superLightRed") : Color("Color2"))
                    .sheet(isPresented: $showModal) {
                        ExperienceModalView(showModal: $showModal, addedExperience: 10, authManager: authManager)
                    }
                    
                   
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
            .onAppear {
                startCountdown()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    startTimer() // Viewが表示されたときにタイマーを開始
                }
                self.monsterType = 1 // すぐに1に戻す
                authManager.fetchUserInfo { (name, avator, money, hp, attack) in
                    self.userName = name ?? ""
                    self.avator = avator ?? [[String: Any]]()
                    self.userMoney = money ?? 0
                    self.userHp = hp ?? 100
                    self.userAttack = attack ?? 20
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    audioManager.playCountdownSound()
                }
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
                // 味方のHPが０以下のとき
                print(playerHP)
                if newValue && playerHP <= 0 {
                    DispatchQueue.global(qos: .background).async {
                        authManager.addExperience(points: 5)
                        authManager.addMoney(amount: 5)
                        DispatchQueue.main.async {
                            // ここでUIの更新を行います。
                        }
                    }
                } else {
                    DispatchQueue.global(qos: .background).async {
                        authManager.addExperience(points: playerExperience)
                        authManager.addMoney(amount: playerMoney)
                        DispatchQueue.main.async {
                            // ここでUIの更新を行います。
                        }
                    }
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showModal = false
                    navigateToQuizResultView = true
                    print("navigateToQuizResultView:\(navigateToQuizResultView)")
                }
            }
            .onChange(of: monsterType) { newMonsterType in
                switch quizLevel {
                case .beginner:
                    monsterBackground = "beginnerBackground"
                    playerExperience = 20
                    playerMoney = 10
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
                    playerExperience = 30
                    playerMoney = 20
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
                    playerExperience = 40
                    playerMoney = 30
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
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList(isPresenting: .constant(false))
    }
}
