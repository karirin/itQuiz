//
//  QuizView.swift main
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import AVFoundation
import Firebase

struct Monster: Codable {
    let name: String
    let playerExperience: Int
    let playerMoney: Int
    let monsterHP: Int
    let monsterUnderHP: Int
    let monsterAttack: Int
}

// 2. monsters辞書の定義
let monsters: [String: Monster] = [
    "モンスター1": Monster(name: "モンスター1", playerExperience: 30, playerMoney: 30, monsterHP: 160, monsterUnderHP: 160, monsterAttack: 30),
    "モンスター2": Monster(name: "モンスター2", playerExperience: 20, playerMoney: 20, monsterHP: 100, monsterUnderHP: 100, monsterAttack: 10),
    "モンスター3": Monster(name: "モンスター3", playerExperience: 15, playerMoney: 15, monsterHP: 120, monsterUnderHP: 120, monsterAttack: 15),
    "モンスター4": Monster(name: "モンスター4", playerExperience: 25, playerMoney: 25, monsterHP: 110, monsterUnderHP: 110, monsterAttack: 12),
    "モンスター5": Monster(name: "モンスター5", playerExperience: 22, playerMoney: 22, monsterHP: 115, monsterUnderHP: 115, monsterAttack: 14),
    "モンスター6": Monster(name: "モンスター6", playerExperience: 28, playerMoney: 28, monsterHP: 125, monsterUnderHP: 125, monsterAttack: 18),
    "モンスター7": Monster(name: "モンスター7", playerExperience: 35, playerMoney: 35, monsterHP: 150, monsterUnderHP: 150, monsterAttack: 25),
    "モンスター8": Monster(name: "モンスター8", playerExperience: 18, playerMoney: 18, monsterHP: 95, monsterUnderHP: 95, monsterAttack: 9),
    "モンスター9": Monster(name: "モンスター9", playerExperience: 40, playerMoney: 40, monsterHP: 160, monsterUnderHP: 160, monsterAttack: 28),
    "モンスター10": Monster(name: "モンスター10", playerExperience: 45, playerMoney: 45, monsterHP: 170, monsterUnderHP: 170, monsterAttack: 30),
    "モンスター11": Monster(name: "モンスター11", playerExperience: 50, playerMoney: 50, monsterHP: 180, monsterUnderHP: 180, monsterAttack: 32),
    "モンスター12": Monster(name: "モンスター12", playerExperience: 55, playerMoney: 55, monsterHP: 190, monsterUnderHP: 190, monsterAttack: 35),
    "モンスター13": Monster(name: "モンスター13", playerExperience: 60, playerMoney: 60, monsterHP: 200, monsterUnderHP: 200, monsterAttack: 38),
    "モンスター14": Monster(name: "モンスター14", playerExperience: 65, playerMoney: 65, monsterHP: 210, monsterUnderHP: 210, monsterAttack: 40),
//    "ボス15": Monster(name: "ボス15", playerExperience: 120, playerMoney: 150, monsterHP: 300, monsterUnderHP: 300, monsterAttack: 65),
//    "ボス16": Monster(name: "ボス16", playerExperience: 200, playerMoney: 300, monsterHP: 500, monsterUnderHP: 500, monsterAttack: 200),
    "ボス15": Monster(name: "ボス15", playerExperience: 150, playerMoney: 150, monsterHP: 1000, monsterUnderHP: 1000, monsterAttack: 100),
    "ボス16": Monster(name: "ボス16", playerExperience: 300, playerMoney: 300, monsterHP: 3000, monsterUnderHP: 3000, monsterAttack: 300),
    "モンスター17": Monster(name: "モンスター17", playerExperience: 80, playerMoney: 80, monsterHP: 240, monsterUnderHP: 240, monsterAttack: 48),
    "モンスター18": Monster(name: "モンスター18", playerExperience: 85, playerMoney: 85, monsterHP: 250, monsterUnderHP: 250, monsterAttack: 50),
    "モンスター19": Monster(name: "モンスター19", playerExperience: 90, playerMoney: 90, monsterHP: 260, monsterUnderHP: 260, monsterAttack: 52),
    "モンスター20": Monster(name: "モンスター20", playerExperience: 95, playerMoney: 95, monsterHP: 270, monsterUnderHP: 270, monsterAttack: 55),
    "モンスター21": Monster(name: "モンスター21", playerExperience: 100, playerMoney: 100, monsterHP: 280, monsterUnderHP: 280, monsterAttack: 58),
    "モンスター22": Monster(name: "モンスター22", playerExperience: 105, playerMoney: 105, monsterHP: 290, monsterUnderHP: 290, monsterAttack: 60),
    "モンスター23": Monster(name: "モンスター23", playerExperience: 110, playerMoney: 110, monsterHP: 300, monsterUnderHP: 300, monsterAttack: 62),
    "モンスター24": Monster(name: "モンスター24", playerExperience: 115, playerMoney: 115, monsterHP: 310, monsterUnderHP: 310, monsterAttack: 65),
    "モンスター25": Monster(name: "モンスター25", playerExperience: 120, playerMoney: 120, monsterHP: 320, monsterUnderHP: 320, monsterAttack: 68),
    "モンスター26": Monster(name: "モンスター26", playerExperience: 125, playerMoney: 125, monsterHP: 330, monsterUnderHP: 330, monsterAttack: 70),
    "モンスター27": Monster(name: "モンスター27", playerExperience: 130, playerMoney: 130, monsterHP: 340, monsterUnderHP: 340, monsterAttack: 72),
    "モンスター28": Monster(name: "モンスター28", playerExperience: 135, playerMoney: 135, monsterHP: 350, monsterUnderHP: 350, monsterAttack: 75),
    "モンスター29": Monster(name: "モンスター29", playerExperience: 140, playerMoney: 140, monsterHP: 360, monsterUnderHP: 360, monsterAttack: 78),
    "モンスター30": Monster(name: "モンスター30", playerExperience: 145, playerMoney: 145, monsterHP: 370, monsterUnderHP: 370, monsterAttack: 80),
    "モンスター31": Monster(name: "モンスター31", playerExperience: 150, playerMoney: 150, monsterHP: 380, monsterUnderHP: 380, monsterAttack: 82),
    "モンスター32": Monster(name: "モンスター32", playerExperience: 155, playerMoney: 155, monsterHP: 390, monsterUnderHP: 390, monsterAttack: 85),
    "モンスター33": Monster(name: "モンスター33", playerExperience: 160, playerMoney: 160, monsterHP: 400, monsterUnderHP: 400, monsterAttack: 88),
    "モンスター34": Monster(name: "モンスター34", playerExperience: 170, playerMoney: 165, monsterHP: 420, monsterUnderHP: 420, monsterAttack: 92),
    "ボス35": Monster(name: "ボス35", playerExperience: 1000, playerMoney: 1000, monsterHP: 5000, monsterUnderHP: 5000, monsterAttack: 500),
    "モンスター36": Monster(name: "モンスター36", playerExperience: 190, playerMoney: 185, monsterHP: 460, monsterUnderHP: 460, monsterAttack: 100),
    "モンスター37": Monster(name: "モンスター37", playerExperience: 200, playerMoney: 190, monsterHP: 480, monsterUnderHP: 480, monsterAttack: 105),
    "モンスター38": Monster(name: "モンスター38", playerExperience: 200, playerMoney: 200, monsterHP: 500, monsterUnderHP: 500, monsterAttack: 110),
    "モンスター39": Monster(name: "モンスター39", playerExperience: 210, playerMoney: 210, monsterHP: 510, monsterUnderHP: 510, monsterAttack: 120),
    "モンスター40": Monster(name: "モンスター40", playerExperience: 220, playerMoney: 220, monsterHP: 520, monsterUnderHP: 520, monsterAttack: 130),
    "モンスター41": Monster(name: "モンスター41", playerExperience: 230, playerMoney: 230, monsterHP: 530, monsterUnderHP: 530, monsterAttack: 150),
    "モンスター42": Monster(name: "モンスター42", playerExperience: 240, playerMoney: 240, monsterHP: 550, monsterUnderHP: 550, monsterAttack: 170),
    "モンスター43": Monster(name: "モンスター43", playerExperience: 250, playerMoney: 250, monsterHP: 570, monsterUnderHP: 570, monsterAttack: 190),
    "モンスター44": Monster(name: "モンスター44", playerExperience: 260, playerMoney: 270, monsterHP: 600, monsterUnderHP: 600, monsterAttack: 210),
    
    "モンスター45": Monster(name: "モンスター45", playerExperience: 280, playerMoney: 280, monsterHP: 630, monsterUnderHP: 630, monsterAttack: 230),
    "モンスター46": Monster(name: "モンスター46", playerExperience: 310, playerMoney: 310, monsterHP: 660, monsterUnderHP: 660, monsterAttack: 250),
    "モンスター47": Monster(name: "モンスター47", playerExperience: 340, playerMoney: 340, monsterHP: 690, monsterUnderHP: 690, monsterAttack: 270),
    "モンスター48": Monster(name: "モンスター48", playerExperience: 370, playerMoney: 370, monsterHP: 720, monsterUnderHP: 720, monsterAttack: 290),
    "モンスター49": Monster(name: "モンスター49", playerExperience: 400, playerMoney: 400, monsterHP: 750, monsterUnderHP: 550, monsterAttack: 310),
    "モンスター50": Monster(name: "モンスター50", playerExperience: 430, playerMoney: 430, monsterHP: 800, monsterUnderHP: 800, monsterAttack: 350),
    "モンスター51": Monster(name: "モンスター51", playerExperience: 460, playerMoney: 460, monsterHP: 850, monsterUnderHP: 850, monsterAttack: 400),
    
    "モンスター52": Monster(name: "モンスター52", playerExperience: 500, playerMoney: 500, monsterHP: 900, monsterUnderHP: 900, monsterAttack: 500),
]

struct StoryQuizView: View {
    @ObservedObject var viewModel: PositionViewModel
    let quizzes: [QuizQuestion]
    let quizLevel: QuizLevel
    let monsterName: String
    let backgroundName: String
    @State private var selectedAnswerIndex: Int? = nil
    @State private var currentQuizIndex: Int = 0
    @State private var showCompletionMessage: Bool = false
    @State private var showSubFlag: Bool = false
    @State private var remainingSeconds: Int = 30
    @State private var timer: Timer? = nil
    @State private var navigateToQuizResultView: Bool = false
    @ObservedObject var authManager : AuthManager
    @ObservedObject var audioManager : AudioManager
    @State private var showModal: Bool = false
    @State private var showTutorial: Bool = false
    @State private var quizResults: [QuizResult] = []
    @State private var answerCount: Int = 0
    @State private var incorrectCount: Int = 0
    @State private var incorrectAnswerCount: Int = 0
    @State private var correctAnswerCount: Int = 0
    @State private var countdownValue: Int = 3
    @State private var showCountdown: Bool = false
    @State private var playerHP: Int = 100
    @State private var playerMaxHP: Int = 100
    @State private var monsterHP: Int = 100
    @State private var monsterUnderHP: Int = 30
    @State private var monsterAttack: Int = 30
    @State var showAlert: Bool = false
    @State private var userName: String = ""
    @State private var avator: [[String: Any]] = []
    @State private var monsterBackground: String = ""
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userMaxHp: Int = 100
    @State private var userFlag: Int = 0
    @StateObject private var appState = AppState()
    @State private var avatarHp: Int = 100
    @State private var userAttack: Int = 30
    @State private var tutorialNum: Int = 0
    @State private var monsterType: Int = 0
    @State private var playerExperience: Int = 0
    @State private var playerMoney: Int = 0
    @State private var shakeEffect: Bool = false
    @State private var showAttackImage: Bool = false
    @State var showExplanationModal: Bool = false
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
    @State private var buttonRect: CGRect = .zero
    @State private var buttonRect1: CGRect = .zero
    @State private var buttonRect2: CGRect = .zero
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var startTime = Date()
    @State private var endTime: Date?
    @State private var elapsedTime: TimeInterval?
    @State private var navigateToQuizResult = false
    @State private var victoryFlag = false
    @ObservedObject var interstitial: Interstitial
    @State private var rewardFlag: Int = 0
    @Environment(\.presentationMode) var presentationMode
//    var user: User // ここでユーザー情報全体を受け取る
//    var userName2: String
//    var user: User
    
    
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
                    if tutorialNum != 3 {
                        startTimer()
                    }
                }
            }
        }
    }
    
    
    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
    }
    }
    func fetchNumberOfIncorrectITAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectITAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
    }
    }
    func fetchNumberOfIncorrectInfoAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectInfoAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
    }
    }
    func fetchNumberOfIncorrectAppliedAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectAppliedAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
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
        if monsterHP <= 0 {
            showCompletionMessage = true
            timer?.invalidate()
            RateManager.shared.updateQuizData(userId: authManager.currentUserId!, quizType: quizLevel, newCorrectAnswers: correctAnswerCount, newTotalAnswers: answerCount)
            RateManager.shared.updateAnswerData(userId: authManager.currentUserId!, quizType: quizLevel,  newTotalAnswers: answerCount)
            navigateToQuizResultView = true //ここで結果画面への遷移フラグをtrueに
            print("moveToNextQuiz")
        } else if playerHP <= 0 {
            showCompletionMessage = true
            timer?.invalidate()
            playerExperience = 5
            playerMoney = 5
            navigateToQuizResultView = true  //ここで結果画面への遷移フラグをtrueに
            RateManager.shared.updateQuizData(userId: authManager.currentUserId!, quizType: quizLevel, newCorrectAnswers: correctAnswerCount, newTotalAnswers: answerCount)
            RateManager.shared.updateAnswerData(userId: authManager.currentUserId!, quizType: quizLevel, newTotalAnswers: answerCount)
        } else if self.remainingSeconds == 0 {
            currentQuizIndex += 1
           selectedAnswerIndex = nil
           startTimer()
           hasAnswered = false
        } else if currentQuizIndex + 1 < quizzes.count {
            if userFlag == 0 {
                showExplanationModal = true
            } else {
                currentQuizIndex += 1
               selectedAnswerIndex = nil
                startTimer()
            }
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
//                print("index:\(index)")
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
                    incorrectCount -= 1
                    answerCount += 1
                    if quizLevel != .incorrectAnswer && quizLevel != .incorrectITAnswer && quizLevel != .incorrectInfoAnswer && quizLevel != .incorrectAppliedAnswer {
                        monsterHP -= userAttack
                    }
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
                if quizLevel == .incorrectITAnswer{
                    removeCorrectITAnswer(for: authManager.currentUserId!, questionId: currentQuiz.id!)
                }else if quizLevel == .incorrectInfoAnswer {
                    removeCorrectInfoAnswer(for: authManager.currentUserId!, questionId: currentQuiz.id!)
                }else if quizLevel == .incorrectAppliedAnswer {
                removeCorrectAppliedAnswer(for: authManager.currentUserId!, questionId: currentQuiz.id!)
                }else if quizLevel == .incorrectAnswer {
                    removeCorrectAnswer(for: authManager.currentUserId!, questionId: currentQuiz.id!)
                    }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    moveToNextQuiz()
                }
            } else {
                let incorrectAnswer = IncorrectAnswer(
                userId: authManager.currentUserId!,
                quizQuestion: currentQuiz.question,
                choices: currentQuiz.choices,
                correctAnswerIndex: currentQuiz.correctAnswerIndex, explanation: currentQuiz.explanation
                )
                // incorrectAnswer以外のクイズなら不正解の問題をincorrectAnswerテーブルに保存する
                if !appState.isBannerVisible {
                    if quizLevel != .incorrectAnswer && quizLevel != .incorrectITAnswer && quizLevel != .incorrectInfoAnswer && quizLevel != .incorrectAppliedAnswer {
                        switch quizLevel {
                        case .itBasic,.itStrategy,.itTechnology,.itManagement:
                            saveIncorrectITAnswer(incorrectAnswer)
                            break
                        case .itBasic,.itStrategy,.itTechnology,.itManagement:
                            saveIncorrectITAnswer(incorrectAnswer)
                            break
                            
                        case .infoBasic,.infoStrategy,.infoTechnology,.infoManagement:
                            saveIncorrectInfoAnswer(incorrectAnswer)
                            break
                            
                        case .appliedBasic,.appliedStrategy,.appliedTechnology,.appliedManagement:
                            saveIncorrectAppliedAnswer(incorrectAnswer)
                            break
                        default:
                            saveIncorrectAnswer(incorrectAnswer)
                            break
                        }
                    }
                }
                answerCount += 1
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
    func saveIncorrectAnswer(_ answer: IncorrectAnswer) {
    // ユーザーIDを親ノードとして設定
    let ref = Database.database().reference().child("IncorrectAnswers").child(answer.userId).childByAutoId()
    ref.setValue([
    "quizQuestion": answer.quizQuestion,
    "choices": answer.choices,
    "correctAnswerIndex": answer.correctAnswerIndex,
    "explanation": answer.explanation
    ])
    }
        func saveIncorrectITAnswer(_ answer: IncorrectAnswer) {
        // ユーザーIDを親ノードとして設定
        let ref = Database.database().reference().child("IncorrectITAnswers").child(answer.userId).childByAutoId()
        ref.setValue([
        "quizQuestion": answer.quizQuestion,
        "choices": answer.choices,
        "correctAnswerIndex": answer.correctAnswerIndex,
        "explanation": answer.explanation
        ])
        }
        func saveIncorrectInfoAnswer(_ answer: IncorrectAnswer) {
        // ユーザーIDを親ノードとして設定
        let ref = Database.database().reference().child("IncorrectInfoAnswers").child(answer.userId).childByAutoId()
        ref.setValue([
        "quizQuestion": answer.quizQuestion,
        "choices": answer.choices,
        "correctAnswerIndex": answer.correctAnswerIndex,
        "explanation": answer.explanation
        ])
        }
        func saveIncorrectAppliedAnswer(_ answer: IncorrectAnswer) {
        // ユーザーIDを親ノードとして設定
        let ref = Database.database().reference().child("IncorrectAppliedAnswers").child(answer.userId).childByAutoId()
        ref.setValue([
        "quizQuestion": answer.quizQuestion,
        "choices": answer.choices,
        "correctAnswerIndex": answer.correctAnswerIndex,
        "explanation": answer.explanation
        ])
        }
    
    func removeCorrectAnswer(for userId: String, questionId: String) {
        let ref = Database.database().reference().child("IncorrectAnswers").child(userId).child(questionId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer removed successfully.")
            }
        }
    }
    func removeCorrectITAnswer(for userId: String, questionId: String) {
        let ref = Database.database().reference().child("IncorrectITAnswers").child(userId).child(questionId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer removed successfully.")
            }
        }
    }
    func removeCorrectInfoAnswer(for userId: String, questionId: String) {
        let ref = Database.database().reference().child("IncorrectInfoAnswers").child(userId).child(questionId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer removed successfully.")
            }
        }
    }
    func removeCorrectAppliedAnswer(for userId: String, questionId: String) {
        let ref = Database.database().reference().child("IncorrectAppliedAnswers").child(userId).child(questionId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer removed successfully.")
            }
        }
    }
    
    var body: some View {
        NavigationView{
        ZStack{
            
            Image("\(backgroundName)")
                 .resizable()
                 .edgesIgnoringSafeArea(.all)
            VStack {
                HStack{
                    Button(action: { 
                        generateHapticFeedback()
                        showHomeModal.toggle()
                        audioManager.playSound()
                    }) {
                        Image("設定")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                    .padding(.leading)
                    .foregroundColor(.gray)
                    Spacer()
                    Spacer()
                    // 正解の場合の赤い円
                    if let selected = selectedAnswerIndex, selected == currentQuiz.correctAnswerIndex {
                    }
                    TimerView(remainingSeconds: $remainingSeconds)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                        })
                }
                .padding(.trailing)
//                    .padding(.top,40)
                Spacer()
                VStack{
                    ZStack {
                        VStack{
                            Text(currentQuiz.question)
                                .font(.headline)
                                .frame(height: tutorialNum == 0 ? 120 : nil)
                                .padding(.horizontal)
                                .foregroundColor(Color("fontGray"))
                            
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color("Color2"))
                        .padding(.vertical, 5)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                        })//
                        
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
                                Image("\(monsterName)")
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(radius: 10)
                                    .frame(width: isSmallDevice() ? 100 : 160)
                            
                            // 問題に正解して敵キャラにダメージ
                            if let selected = selectedAnswerIndex {
                                if selected == currentQuiz.correctAnswerIndex {
                                    if showAttackImage {
                                        Image("attack1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:isSmallDevice() ? 80 : 130)
                                    }
                                }
                            }
                        
                          if showMonsterDownImage && monsterHP <= 0 {
                            Image("倒す")
                                .resizable()
                                .scaledToFit()
                                .frame(height:80)
                          }
                    }
                    
                    if quizLevel != .incorrectAnswer && quizLevel != .incorrectITAnswer && quizLevel != .incorrectInfoAnswer && quizLevel != .incorrectAppliedAnswer {
                        
                        ZStack{
                            VStack{
                                HStack{
                                    ProgressBar3(value: Double(monsterHP), maxValue: Double(monsterUnderHP), color: Color("hpMonsterColor"))
                                        .frame(height: 20)
                                    Text("\(monsterHP)/\(monsterUnderHP)")
                                        .padding(.horizontal,10)
                                        .padding(.vertical, 3)
                                        .foregroundColor(Color(.white))
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(30)
                                }
                                .padding(.horizontal)
                                // 味方キャラのHP
                                HStack{
                                    Image(avator.isEmpty ? "defaultIcon" : (avator.first?["name"] as? String) ?? "")
                                        .resizable()
                                        .frame(width: 30,height:30)
                                    ProgressBar3(value: Double(playerHP), maxValue: Double(self.userMaxHp), color: Color("hpUserColor"))
                                        .frame(height: 20)
                                    Text("\(playerHP)/\(self.userMaxHp)")
                                        .padding(.horizontal,10)
                                        .padding(.vertical, 3)
                                        .foregroundColor(Color(.white))
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(30)
                                }
                                .padding(.horizontal)
                            }
                            
                            if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                                if showAttackImage{
                                    Image("beginnerMonsterAttack\(monsterType)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:90)
                                        .padding(.bottom, -30)
                                }
                            }
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                        })
                    } else {
                        HStack {
                            VStack{
                                Text("問題数")
                                Text("\(incorrectCount)")
                                    .font(.system(size: 24))
                            }
                            .foregroundColor(Color("fontGray"))
                            ProgressBar3(value: Double(incorrectCount), maxValue: Double(self.incorrectAnswerCount), color: Color("loading"))
                                .frame(height: 20)
                        }
                        .padding()
                    }
                }
                Spacer()
                ScrollView{
                    VStack{
                        
                        AnswerSelectionView(choices: currentQuiz.choices, correctAnswerIndex: hasAnswered ? currentQuiz.correctAnswerIndex : nil) { index in
                            answerSelectionAction(index: index)
                        }
        .onAppear{
            showTutorial = true
        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 1)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey1.self, value: [geometry.frame(in: .global)])
                        })
                        
                        Spacer()
                        Spacer()
                    }
                                        }
                    .frame(maxWidth: .infinity,maxHeight:.infinity)
                    .padding(.bottom)
                    
                    .sheet(isPresented: $showModal) {
                        ExperienceModalView(showModal: $showModal, addedExperience: 10, addedMoney: 10, authManager: authManager)
                    }
            }
            .background(showIncorrectBackground ? Color(.red).opacity(0.1) : Color(.white).opacity(0))
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey1.self) { positions in
                self.buttonRect1 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey2.self) { positions in
                self.buttonRect2 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey3.self) { positions in
                self.buttonRect3 = positions.first ?? .zero
            }
            if showExplanationModal {
                ZStack {
                    Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                    if let selectedIndex = selectedAnswerIndex, selectedIndex < currentQuiz.choices.count {
                        ModalExplanationView(
                            isPresented: $showExplanationModal,
                            selectedAnswerIndex: $selectedAnswerIndex, showAlert: $showAlert, audioManager: audioManager , question: quizzes[currentQuizIndex].question, userAnswer: currentQuiz.choices[selectedIndex],
                            correctAnswer: quizzes[currentQuizIndex].choices[quizzes[currentQuizIndex].correctAnswerIndex],
                            explanation: quizzes[currentQuizIndex].explanation, currentQuizIndex: $currentQuizIndex,
                            userFlag: $userFlag, pauseTimer:pauseTimer, startTimer: startTimer
                        )
                    }else{
                        ModalReturnView(
                        isPresented: $showExplanationModal, pauseTimer:pauseTimer, startTimer: startTimer)
                    }
                }
            }
            if showHomeModal {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    RankModalView(isSoundOn: $isSoundOn, isPresented: $showHomeModal, isPresenting: $isPresenting, audioManager: audioManager, showHomeModal: $showHomeModal,tutorialNum: $tutorialNum,pauseTimer:pauseTimer,resumeTimer: resumeTimer, userFlag: $userFlag)
                }
            }
            if showSubFlag {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    SubModalView(isSoundOn: $isSoundOn, isPresented: $showSubFlag, isPresenting: $isPresenting, audioManager: audioManager, showHomeModal: $showHomeModal,pauseTimer:pauseTimer,resumeTimer: resumeTimer, userFlag: $userFlag)
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
            NavigationLink("", destination: StoryQuizResultView(results: quizResults, authManager: authManager, isPresenting: $isPresenting, navigateToQuizResultView: $navigateToQuizResultView, playerExperience: playerExperience, playerMoney: playerMoney, elapsedTime: 0, quizLevel: quizLevel,victoryFlag:$victoryFlag, isUserStoryFlag: .constant(false), viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                .onAppear{
                    print("isPresenting     :\(isPresenting)")
                }
    }
        .fontWeight(.bold)
        .onTapGesture {
//                audioManager.playSound()
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
        .onChange(of: showCompletionMessage) { newValue in
            navigateToQuizResultView = true
        }
        .onAppear {
            print("backgroundName quiz      :\(backgroundName)")
            if let monster = monsters[monsterName] {
                playerExperience = monster.playerExperience
                playerMoney = monster.playerMoney
                monsterHP = monster.monsterHP
                monsterUnderHP = monster.monsterUnderHP
                monsterAttack = monster.monsterAttack
            } else {
                // 未定義のモンスターの場合のデフォルト値
                print("未知のモンスター: \(monsterName)")
                playerExperience = 0
                playerMoney = 0
                monsterHP = 30
                monsterUnderHP = 30
                monsterAttack = 0
            }
            self.monsterType = 1 // すぐに1に戻す
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                self.userName = name ?? ""
                self.avator = avatar ?? [[String: Any]]()
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
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    startTimer() // Viewが表示されたときにタイマーを開始
                    //                        }
                }
                if self.tutorialNum == 2 {
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                        // データベースのアップデートが成功したかどうかをハンドリング
                    }
                }
            }
            self.startTime = Date()
            authManager.fetchUserRewardFlag()
            
            if quizLevel == .incorrectITAnswer{
                fetchNumberOfIncorrectITAnswers(userId: authManager.currentUserId!) { count in
                    self.incorrectAnswerCount = count
                    incorrectCount = count
                }
                if quizLevel == .incorrectITAnswer {
                    userAttack = 0
                }
            }else if quizLevel == .incorrectInfoAnswer {
                fetchNumberOfIncorrectInfoAnswers(userId: authManager.currentUserId!) { count in
                    self.incorrectAnswerCount = count
                    incorrectCount = count
                }
                if quizLevel == .incorrectInfoAnswer {
                    userAttack = 0
                }
            }else if quizLevel == .incorrectAppliedAnswer {
                fetchNumberOfIncorrectAppliedAnswers(userId: authManager.currentUserId!) { count in
                    self.incorrectAnswerCount = count
                    incorrectCount = count
                }
                if quizLevel == .incorrectAppliedAnswer {
                    userAttack = 0
                }
            }else if quizLevel == .incorrectAnswer {
                fetchNumberOfIncorrectAnswers(userId: authManager.currentUserId!) { count in
                    self.incorrectAnswerCount = count
                    incorrectCount = count
                }
                if quizLevel == .incorrectAnswer {
                    userAttack = 0
                }
            }
            if quizLevel == .incorrectAnswer {
                userAttack = 0
            }
            authManager.fetchUserFlag()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                userFlag = authManager.userFlag
            }
        }
        .onDisappear {
            // 画面を離れるときは必ずタイマーを止める
            timer?.invalidate()
            timer = nil

            // 経過時間の記録だけを行う（遷移はここでは行わない）
            if playerExperience != 5 && playerMoney != 5 {
                self.endTime = Date()
                self.elapsedTime = self.endTime?.timeIntervalSince(self.startTime)
                // self.navigateToQuizResult = true  // ← ここは削除
            }
        }
        .alert(isPresented: $showAlert) {
              Alert(
                  title: Text("通知"),
                  message: Text("設定画面で切り替える事ができます"),
                  dismissButton: .default(Text("OK"), action: {
//                        isPresented = false
                      startTimer()
                      selectedAnswerIndex = nil
                  })
              )
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
                victoryFlag = false
                authManager.addRankMatchPoints(for: authManager.currentUserId!, points: 10, onSuccess: {
                    print("@@@@@@@@@@@@@@@@@@@@@@@1")
                }, onFailure: { error in
                })
                authManager.subtractRankMatchPoints(for: authManager.currentUserId!, points: 10, onSuccess: {
                    print("@@@@@@@@@@@@@@@@@@@@@@@2")
                    }, onFailure: { error in
                    })
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
                victoryFlag = true
                DispatchQueue.global(qos: .background).async {
                    authManager.addRankMatchPoints(for: authManager.currentUserId!, points: 10, onSuccess: {
                    }, onFailure: { error in
                       
                    })
                authManager.subtractRankMatchPoints(for: authManager.currentUserId!, points: 10, onSuccess: {
                    }, onFailure: { error in
                    })
                    authManager.addExperience(points: playerExperience * authManager.rewardFlag, onSuccess: {
//                            print("addExperience \(authManager.rewardFlag)")
                    }, onFailure: { error in
                        // 失敗した時の処理をここに書きます。`error`は失敗の原因を示す情報が含まれている可能性があります。
                    })
                    authManager.addMoney(amount: playerMoney * authManager.rewardFlag)
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
    }
//            .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)

}
}

//struct RankMatchQuizView_Previews: PreviewProvider {
//static var previews: some View {
////    QuizIntermediateList(isPresenting: .constant(false))
////        QuizIncorrectAnswerListView(isPresenting: .constant(false))
//    RankMatchListView(viewModel: RankingViewModel())
//}
//}
struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedUser = User(id: "1", userName: "SampleUser", level: 1, experience: 100, avatars: [
            [
                "name": "ネッキー",
                "attack": 10,
                "health": 20,
                "usedFlag": 1,
                "count": 1
            ]
        ], userMoney: 1000, userHp: 100, userAttack: 20, userFlag: 0, adminFlag: 0, rankMatchPoint: 100, rank: 1)

        StoryITListView(isPresenting: .constant(false), monsterName: "モンスター1", backgroundName: "ダンジョン背景1", viewModel: PositionViewModel.shared)
    }
}
