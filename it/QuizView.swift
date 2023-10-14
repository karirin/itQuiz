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
        case security
        case database
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
        @ObservedObject var audioManager : AudioManager
        @State private var showModal: Bool = false
        @State private var showTutorial: Bool = false
        @State private var quizResults: [QuizResult] = []
        @State private var correctAnswerCount: Int = 0
        @State private var countdownValue: Int = 3
        @State private var showCountdown: Bool = true
        @State private var playerHP: Int = 1000
        @State private var playerMaxHP: Int = 1000
        @State private var monsterHP: Int = 3000
        @State private var monsterUnderHP: Int = 30
        @State private var monsterAttack: Int = 30
        @State private var userName: String = ""
        @State private var avator: [[String: Any]] = []
        @State private var monsterBackground: String = ""
        @State private var userMoney: Int = 0
        @State private var userHp: Int = 100
        @State private var userMaxHp: Int = 100
        @State private var avatarHp: Int = 100
        @State private var userAttack: Int = 30
        @State private var tutorialNum: Int = 0
        @State private var monsterType: Int = 0
        @State private var playerExperience: Int = 0
        @State private var playerMoney: Int = 0
        @State private var shakeEffect: Bool = false
        @State private var showAttackImage: Bool = false
        @State private var showMonsterDownImage: Bool = false
        @State private var showIncorrectBackground: Bool = false
        @State private var hasAnswered: Bool = false
        @Binding var isPresenting: Bool
        @State var showHomeModal: Bool = false
        @State private var isSoundOn: Bool = true
        @State private var showTutorial1 = true
        @State private var showTutorial2 = false
        @State private var showTutorial3 = false
        @State private var showTutorial4 = false
        
        var currentQuiz: QuizQuestion {
            quizzes[currentQuizIndex]
        }
        
        func pauseTimer() {
            timer?.invalidate()
        }
        
        func resumeTimer() {
            // 現在のタイマーを止める
            self.timer?.invalidate()
            
            // ここではremainingSecondsをリセットしない
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    timer.invalidate()
                    playerHP -= monsterAttack
                    self.moveToNextQuiz()
                }
            }
        }
        
        func startCountdown() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if countdownValue > 1 {
                        countdownValue -= 1
                    } else {
                        timer.invalidate()
                        showCountdown = false
                        showTutorial = true
                    }
                }
            }
        }

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
                    playerHP -= monsterAttack
                    self.moveToNextQuiz()
                }
            }
        }
        
        // 次の問題へ移る処理
        func moveToNextQuiz() {
            if monsterType == 3 && monsterHP <= 0 {
                // 最後のモンスターが倒された場合、結果画面へ遷移
                showCompletionMessage = true
                timer?.invalidate()
                navigateToQuizResultView = true  //ここで結果画面への遷移フラグをtrueに
            } else if playerHP <= 0 {
                showCompletionMessage = true
                timer?.invalidate()
                playerExperience = 5
                playerMoney = 5
                navigateToQuizResultView = true  //ここで結果画面への遷移フラグをtrueに
            } else if currentQuizIndex + 1 < quizzes.count { // 最大問題数を超えていないかチェック
                currentQuizIndex += 1
                selectedAnswerIndex = nil
                startTimer()
                hasAnswered = false
            } else {
                // すべての問題が終了した場合、結果画面へ遷移
                showCompletionMessage = true
                timer?.invalidate()
                navigateToQuizResultView = true  // ここで結果画面への遷移フラグをtrueに
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                audioManager.playDownSound()
                                self.showMonsterDownImage = true
                            }
                            // モンスターのHPが0以下になった場合の処理
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.showMonsterDownImage = false
                                monsterType += 1
                            }
                        } else if playerHP <= 0 {
                            // プレイヤーのHPが0以下になった場合の処理
                            showCompletionMessage = true
                            timer?.invalidate()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        moveToNextQuiz()
                    }
                } else {
                    audioManager.playUnCorrectSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        audioManager.playMonsterAttackSound()
                        playerHP -= monsterAttack
                        self.showAttackImage = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        moveToNextQuiz()
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
                self.showAttackImage = false
                hasAnswered = true
            }
        }
        
        var body: some View {
            NavigationView{
            ZStack{
                VStack {
                    HStack{
                        Button(action: {
                            showHomeModal.toggle()
                            audioManager.playSound()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .padding(.leading)
                        .foregroundColor(.gray)
                        Spacer()
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
                        .padding(.leading)
                    }
                    .padding(.trailing)
                    .padding(.top,40)
                    Spacer()
                    VStack{
                        ZStack {
                            Text(currentQuiz.question)
                                .font(.headline)
//                                .font(.system(size: 24.0))
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
                                        if showMonsterDownImage && monsterHP <= 0 {
                                            Image("倒す")
                                                .resizable()
                                                .frame(width:130,height:130)
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
                                ProgressBar3(value: Double(playerHP), maxValue: Double(self.userMaxHp), color: Color("hpUserColor"))
                                    .frame(height: 20)
                                Text("\(playerHP)/\(self.userMaxHp)")
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
                            // QuizView.swift
                            NavigationLink("", destination: QuizResultView(results: quizResults, authManager: authManager, isPresenting: $isPresenting, playerExperience: playerExperience, playerMoney: playerMoney).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)

                        }
                        //                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity,maxHeight:.infinity)
                    .padding(.bottom)
                    
                    .sheet(isPresented: $showModal) {
                        ExperienceModalView(showModal: $showModal, addedExperience: 10, addedMoney: 10, authManager: authManager)
                    }
                    
                   
                }.background(showIncorrectBackground ? Color("superLightRed") : Color("Color2"))
                if showHomeModal {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        ModalView(isSoundOn: $isSoundOn, isPresented: $showHomeModal, isPresenting: $isPresenting, audioManager: audioManager, showHomeModal: $showHomeModal,tutorialNum: $tutorialNum,pauseTimer:pauseTimer,resumeTimer: resumeTimer)
                    }
                }
                if tutorialNum == 3 && showTutorial == true {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: 360, height: 90)
                                    .position(x: geometry.size.width / 2.0, y: geometry.size.height / 5.435)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack(alignment: .trailing, spacing: .zero) {
                    Image("上矢印")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 206.0)
                        Text("問題が出題されます。")
                            .font(.system(size: 24.0))
                            .padding(.all, 16.0)
                            .background(Color.white)
                            .cornerRadius(4.0)
                            .padding(.horizontal, 16)
                    }.offset(x: -40, y: -130)
                }
                if tutorialNum == 4 && showTutorial == true{
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: 360, height: 260)
                                    .position(x: geometry.size.width / 2.0, y: geometry.size.height / 1.32)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack(alignment: .trailing, spacing: .zero) {
                        Text("選択肢の中から正解と思うものをクリックしてください。")
                            .font(.system(size: 23.0))
                            .padding(.all, 16.0)
                            .background(Color.white)
                            .cornerRadius(4.0)
                            .padding(.horizontal, 18)
                        Image("下矢印")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 236.0)
                    }.offset(x: -10, y: -10)
                }
                if tutorialNum == 5 && showTutorial == true{
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: 360, height: 80)
                                    .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.05)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack(alignment: .trailing, spacing: .zero) {
                        Text("正解すると相手モンスターにダメージ、不正解だと自分がダメージを受けます。\n相手のHPが０になれば次の相手に、自分のHPが０になればゲームオーバーです。")
                            .font(.system(size: 18.0))
                            .padding(.all, 16.0)
                            .background(Color.white)
                            .cornerRadius(4.0)
                            .padding(.horizontal, 18)
                        Image("下矢印")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 236.0)
                    }.offset(x: -10, y: -150)
                }
                if tutorialNum == 6 && showTutorial == true{
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: 70, height: 70)
                                    .position(x: geometry.size.width / 1.125, y: geometry.size.height / 10.9)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                            .background(.clear)
                    }
                    VStack(alignment: .trailing, spacing: .zero) {
                        Image("上矢印")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 46.0)
                        Text("30秒経つと自分がダメージを受けることになります。")
                            .font(.system(size: 24.0))
                            .padding(.all, 16.0)
                            .background(Color.white)
                            .cornerRadius(4.0)
                            .padding(.horizontal, 18)
                    }.offset(x: 10, y: -190)
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
            
            .onTapGesture {
                audioManager.playSound()
                if showCountdown == false {
                    if tutorialNum == 3 {
                        tutorialNum = 4
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                        }
                    } else if tutorialNum == 4 {
                        tutorialNum = 5
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                        }
                    } else if tutorialNum == 5 {
                        tutorialNum = 6
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                        }
                    } else if tutorialNum == 6 {
                                            resumeTimer()
                        tutorialNum = 0
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                        }
                    }
                }
            }
            .onAppear {
                startCountdown()
                self.monsterType = 1 // すぐに1に戻す
                authManager.fetchUserInfo { (name, avator, money, hp, attack, tutorialNum) in
                    self.userName = name ?? ""
                    self.avator = avator ?? [[String: Any]]()
                    self.userMoney = money ?? 0
                    self.userHp = hp ?? 100
                    self.userAttack = attack ?? 20
                    self.tutorialNum = tutorialNum ?? 0
                    if let additionalAttack = self.avator.first?["attack"] as? Int {
                        self.userAttack = self.userAttack + additionalAttack
                    }
                    if let additionalHealth = self.avator.first?["health"] as? Int {
                        self.userMaxHp = self.userHp + additionalHealth
                    }
                    if let additionalHealth = self.avator.first?["health"] as? Int {
                        self.playerHP = self.userHp + additionalHealth
                    } else {
                        self.playerHP = self.userHp
                    }
                    if self.tutorialNum == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            startTimer() // Viewが表示されたときにタイマーを開始
                        }
                    }
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
                if newValue && playerHP <= 0 {
                    DispatchQueue.global(qos: .background).async {
                        authManager.addExperience(points: 5, onSuccess: {
                            // 成功した時の処理をここに書きます
                        }, onFailure: { error in
                            // 失敗した時の処理をここに書きます。`error`は失敗の原因を示す情報が含まれている可能性があります。
                        })
                        authManager.addMoney(amount: 5)
                        
                        DispatchQueue.main.async {
                        }
                    }
                } else {
                    DispatchQueue.global(qos: .background).async {
                        authManager.addExperience(points: playerExperience, onSuccess: {
                            // 成功した時の処理をここに書きます
                        }, onFailure: { error in
                            // 失敗した時の処理をここに書きます。`error`は失敗の原因を示す情報が含まれている可能性があります。
                        })
                        authManager.addMoney(amount: playerMoney)
                        DispatchQueue.main.async {
                            // ここでUIの更新を行います。
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showModal = false
                    navigateToQuizResultView = true
                }
            }
            .onChange(of: monsterType) { newMonsterType in
                switch quizLevel {
                case .beginner:
                    monsterBackground = "beginnerBackground"
                    playerExperience = 20
                    playerMoney = 10
                    print(playerExperience)
                    if playerHP <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 80
                        monsterUnderHP = 80
                        monsterAttack = 20
                    case 2:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 30
                    case 3:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 40
                    default:
                        monsterHP = 30
                    }
                case .intermediate:
                    monsterBackground = "intermediateBackground"
                    playerExperience = 30
                    playerMoney = 20
                    if userHp <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 80
                        monsterUnderHP = 80
                        monsterAttack = 30
                    case 2:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 40
                    case 3:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 50
                    default:
                        monsterHP = 50
                    }
                case .advanced:
                    monsterBackground = "advancedBackground"
                    playerExperience = 40
                    playerMoney = 30
                    if userHp <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 40
                    case 2:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 50
                    case 3:
                        monsterHP = 200
                        monsterUnderHP = 200
                        monsterAttack = 60
                    default:
                        monsterHP = 80
                    }
                case .network:
                    monsterBackground = "networkBackground"
                    playerExperience = 40
                    playerMoney = 30
                    if userHp <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 80
                        monsterUnderHP = 80
                        monsterAttack = 40
                    case 2:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 50
                    case 3:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 60
                    default:
                        monsterHP = 50
                    }
                case .security:
                    monsterBackground = "securityBackground"
                    playerExperience = 40
                    playerMoney = 30
                    if userHp <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 80
                        monsterUnderHP = 80
                        monsterAttack = 40
                    case 2:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 50
                    case 3:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 60
                    default:
                        monsterHP = 50
                    }
                case .database:
                    monsterBackground = "databaseBackground"
                    playerExperience = 40
                    playerMoney = 30
                    if userHp <= 0 {
                        playerExperience = 5
                        playerMoney = 5
                    }
                    switch newMonsterType {
                    case 1:
                        monsterHP = 80
                        monsterUnderHP = 80
                        monsterAttack = 40
                    case 2:
                        monsterHP = 120
                        monsterUnderHP = 120
                        monsterAttack = 50
                    case 3:
                        monsterHP = 160
                        monsterUnderHP = 160
                        monsterAttack = 60
                    default:
                        monsterHP = 50
                    }
                }
            }
        }
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList(isPresenting: .constant(false))
    }
}
