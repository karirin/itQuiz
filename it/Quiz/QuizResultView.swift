//
//  QuizResultView.swift main
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI

struct QuizResult {
    var question: String
    var userAnswer: String
    var correctAnswer: String
    var explanation: String
    var isCorrect: Bool
    var showExplanation: Bool = false
}

struct QuizTotal {
    var totalAnswers: Int
}

struct QuizResultView: View {
    let quizLevel: QuizLevel
    @State private var showModal = false
    @State private var adFlag = false
    @State private var showLevelUpModal = false
    @State private var showTittleModal = false
    @State private var showMemoView = false
    @State private var currentMemo = ""
    @State private var selectedQuestion = ""
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @State private var playerExperience: Int
    @State private var playerMoney: Int
    @State private var isContentView: Bool = false
    var elapsedTime: TimeInterval
    @State var results: [QuizResult]
    let quizBossLevel: QuizBossLevel
    @State private var isShow: Bool = true
    @State private var flag: Bool = false
    @State private var preFlag: Bool = false
    @State private var showSubFlag: Bool = false
    @State private var level3flag: Bool = false
    @State private var level5flag: Bool = false
    @State private var level10flag: Bool = false
    @State private var answer30flag: Bool = false
    @State private var answer50flag: Bool = false
    @State private var answer100flag: Bool = false
    @State private var goburinflag: Bool = false
    @State private var kaijyuflag: Bool = false
    @State private var shinjyuflag: Bool = false
    @EnvironmentObject var appState: AppState
    @Binding var isPresenting: Bool
    @Binding var navigateToQuizResultView: Bool
    @State private var isHidden = false
    @State private var selectedTab = 0 // 0: 結果, 1: 統計
    @State private var hasRequestedInterstitial = false
    @State private var hasPresentedInterstitial = false
    private let interstitial = Interstitial()
    @Environment(\.presentationMode) var presentationMode
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @State private var restart = false
    @State private var showingAllResults = false

    init(results: [QuizResult], authManager: AuthManager, isPresenting: Binding<Bool>, navigateToQuizResultView: Binding<Bool>, playerExperience: Int, playerMoney: Int, elapsedTime: TimeInterval, quizBossLevel: QuizBossLevel, quizLevel: QuizLevel) {
        _results = State(initialValue: results)
        self.authManager = authManager
        _isPresenting = isPresenting
        _navigateToQuizResultView = navigateToQuizResultView
        _playerExperience = State(initialValue: playerExperience)
        _playerMoney = State(initialValue: playerMoney)
        self.elapsedTime = elapsedTime
        self.quizBossLevel = quizBossLevel
        self.quizLevel = quizLevel
    }
    
    // 正解率を計算
    var correctAnswersCount: Int {
        results.filter { $0.isCorrect }.count
    }
    
    var accuracyPercentage: Double {
        guard !results.isEmpty else { return 0 }
        return Double(correctAnswersCount) / Double(results.count) * 100
    }
    
    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 0) {
                    if appState.shouldShowAds {
                        // ヘッダー部分
                        headerView
                    }
                    ScrollView{
                        // 結果サマリーカード
                        resultSummaryCard
                            .padding(.horizontal).padding(.top,5)
                        // タブ選択
                        tabSelector
                        
                        // コンテンツ
                        if selectedTab == 0 {
                            resultsContent
                        } else {
                            statisticsContent
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: backButton)
                .navigationTitle("結果")
                .navigationBarTitleDisplayMode(.inline)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 80 {
                            isPresenting = false
                        }
                    }
            )
            .background {
                if appState.shouldShowAds {
                    adViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                }
            }
            
            // モーダル類
            modalOverlays
        }
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager)
        }
        .onChange(of: authManager.didLevelUp) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showLevelUpModal = true
                    audioManager.playLevelUpSound()
                }
            }
        }
        .onAppear {
            setupOnAppear()
            // モーダルを少し遅れて表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showModal = true
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // プレミアムボタン
            HStack {
                Spacer()
                Button(action: {
                    generateHapticFeedback()
                    showSubFlag = true
                    audioManager.playSound()
                }) {
                    Image("プレミアムプランボタン")
                        .resizable()
                        .frame(width: 240, height: 70)
                }
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .fullScreenCover(isPresented: $showSubFlag) {
                    PreView(audioManager: audioManager)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Result Summary Card
    private var resultSummaryCard: some View {
        VStack(spacing: 16) {
            // タイムアタック結果 or 通常結果
            if elapsedTime != 0 {
                timeAttackSummary
            } else {
                regularSummary
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var timeAttackSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "stopwatch.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("タイムアタック結果")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(formatDuration(elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                resultActionButton(title: "解説を見る", systemImage: "book.fill") {
                    generateHapticFeedback()
                    withAnimation(.spring()) {
                        isHidden.toggle()
                    }
                }
                
                resultActionButton(title: "ランキング", systemImage: "chart.bar.fill") {
                    generateHapticFeedback()
                    // ランキング機能の実装
                }
            }
        }
    }
    
    private var regularSummary: some View {
        VStack(spacing: 16) {
            // 正解率表示
            HStack(spacing: 30) {
                
                // 円形プログレス
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: accuracyPercentage / 100)
                        .stroke(
                            accuracyPercentage >= 80 ? Color.green :
                            accuracyPercentage >= 60 ? Color.orange : Color.red,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: accuracyPercentage)
                    
                    Text("\(correctAnswersCount)/\(results.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.top,8)
                VStack(alignment: .leading, spacing: 4) {
                    Text("正解率")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", accuracyPercentage))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "結果詳細", index: 0, systemImage: "list.bullet")
            tabButton(title: "統計", index: 1, systemImage: "chart.pie")
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    private func tabButton(title: String, index: Int, systemImage: String) -> some View {
        Button(action: {
            generateHapticFeedback()
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .white : .primary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTab == index ? Color.accentColor : Color.clear)
            )
        }
    }
    
    // MARK: - Results Content
    private var resultsContent: some View {
        VStack {
            LazyVStack(spacing: 12) {
                ForEach(results.indices, id: \.self) { index in
                    resultCard(for: results[index], index: index)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .opacity(elapsedTime != 0 ? (isHidden ? 1 : 0) : 1)
    }
    
    private func resultCard(for result: QuizResult, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                // 正解/不正解アイコン
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(result.isCorrect ? .green : .red)
                
                Text("問題 \(index + 1)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 正解/不正解ラベル
                Text(result.isCorrect ? "正解" : "不正解")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(result.isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    )
                    .foregroundColor(result.isCorrect ? .green : .red)
            }
            
            // 問題文
            Text(result.question)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // 回答部分
            VStack(alignment: .leading, spacing: 8) {
                answerRow(title: "あなたの回答", answer: result.userAnswer,
                         isCorrect: result.isCorrect, isUserAnswer: true)
                answerRow(title: "正解", answer: result.correctAnswer,
                         isCorrect: true, isUserAnswer: false)
            }
            
            // 解説
            if !result.explanation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("解説")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Text(result.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func answerRow(title: String, answer: String, isCorrect: Bool, isUserAnswer: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(answer)
                .font(.body)
                .foregroundColor(isUserAnswer ? (isCorrect ? .green : .red) : .primary)
                .fontWeight(isUserAnswer ? .medium : .regular)
                .lineLimit(nil)
            
            Spacer()
        }
    }
    
    // MARK: - Statistics Content
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 統計カード
                statisticsCards
                
                // 詳細統計
                detailedStatistics
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }
    
    private var statisticsCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statisticCard(title: "正解数", value: "\(correctAnswersCount)",
                            icon: "checkmark.circle.fill", color: .green)
                statisticCard(title: "不正解数", value: "\(results.count - correctAnswersCount)",
                            icon: "xmark.circle.fill", color: .red)
            }
            
            HStack(spacing: 12) {
                statisticCard(title: "正解率", value: "\(String(format: "%.1f", accuracyPercentage))%",
                            icon: "percent", color: .blue)
                statisticCard(title: "総問題数", value: "\(results.count)",
                            icon: "questionmark.circle.fill", color: .orange)
            }
        }
    }
    
    private func statisticCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var detailedStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("詳細統計")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                statisticRow(title: "平均回答時間", value: elapsedTime > 0 ?
                           "\(String(format: "%.1f", elapsedTime / Double(results.count)))秒" : "未計測")
                statisticRow(title: "最高連続正解", value: "\(maxConsecutiveCorrect())問")
                statisticRow(title: "レベル", value: "Level \(authManager.level)")
                statisticRow(title: "経験値", value: "\(authManager.experience) XP")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func statisticRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Helper Views
    private func resultActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.accentColor)
            )
        }
    }
    
    private var backButton: some View {
        Button(action: {
            generateHapticFeedback()
            isPresenting = false
            audioManager.playCancelSound()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("戻る")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Modal Overlays
    @ViewBuilder
    private var modalOverlays: some View {
        if showModal {
            ExperienceModalView(showModal: $showModal, addedExperience: playerExperience, addedMoney: playerMoney, authManager: authManager)
        }
        if showLevelUpModal {
            LevelUpModalView(showLevelUpModal: $showLevelUpModal, authManager: authManager)
        }
        if answer30flag {
            ModalTittleView(showLevelUpModal: $answer30flag, authManager: authManager, tittleNumber: .constant(30))
        }
        if answer50flag {
            ModalTittleView(showLevelUpModal: $answer50flag, authManager: authManager, tittleNumber: .constant(50))
        }
        if answer100flag {
            ModalTittleView(showLevelUpModal: $answer100flag, authManager: authManager, tittleNumber: .constant(100))
        }
        if level3flag {
            ModalTittleView(showLevelUpModal: $level3flag, authManager: authManager, tittleNumber: .constant(3))
        }
        if level5flag {
            ModalTittleView(showLevelUpModal: $level5flag, authManager: authManager, tittleNumber: .constant(5))
        }
        if level10flag {
            ModalTittleView(showLevelUpModal: $level10flag, authManager: authManager, tittleNumber: .constant(10))
        }
        if goburinflag {
            ModalTittleView(showLevelUpModal: $goburinflag, authManager: authManager, tittleNumber: .constant(44))
        }
        if kaijyuflag {
            ModalTittleView(showLevelUpModal: $kaijyuflag, authManager: authManager, tittleNumber: .constant(55))
        }
        if shinjyuflag {
            ModalTittleView(showLevelUpModal: $shinjyuflag, authManager: authManager, tittleNumber: .constant(66))
        }
        
        NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $isContentView)
    }
    
    // MARK: - Helper Functions
    private func maxConsecutiveCorrect() -> Int {
        var maxStreak = 0
        var currentStreak = 0
        
        for result in results {
            if result.isCorrect {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }
    
    private func setupOnAppear() {
        authManager.fetchUserStory()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if appState.shouldShowAds {
                executeProcessEveryFortyTimes()
            }
        }
        
        // タイトル獲得処理
        if playerExperience != 5 {
            checkBossTitles()
        }
        
        // 広告処理
        if appState.shouldShowAds && !hasRequestedInterstitial {
//            && authManager.currentUserId != "dzarHuAdiXXLtDjtwIRvIfVhA1A2" {  // ★ここを追加
            hasRequestedInterstitial = true

            interstitial.loadInterstitial { isLoaded in
                DispatchQueue.main.async {
                    guard isLoaded,
                          !self.hasPresentedInterstitial,
                          !self.interstitial.wasAdDismissed
                    else { return }

                    self.hasPresentedInterstitial = true
                    self.interstitial.presentInterstitial(from: adViewControllerRepresentable.viewController)
                }
            }
        }
        
        // レベルとタイトル処理
        authManager.fetchUserExperienceAndLevel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkLevelTitles()
            checkAnswerTitles()
        }
    }
    
    private func checkBossTitles() {
        if quizBossLevel == .goburin {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ゴブリン") { exists in
                if !exists {
                    goburinflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ゴブリン")
                }
            }
        }
        if quizBossLevel == .kaijyu {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ガルーラ") { exists in
                if !exists {
                    kaijyuflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ガルーラ")
                }
            }
        }
        if quizBossLevel == .shinjyu {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ルーン") { exists in
                if !exists {
                    shinjyuflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ルーン")
                }
            }
        }
    }
    
    private func checkLevelTitles() {
        if authManager.level > 2 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル３") { exists in
                if !exists {
                    level3flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル３")
                }
            }
        }
        if authManager.level > 4 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル５") { exists in
                if !exists {
                    level5flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル５")
                }
            }
        }
        if authManager.level > 9 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル１０") { exists in
                if !exists {
                    level10flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル１０")
                }
            }
        }
    }
    
    private func checkAnswerTitles() {
        authManager.fetchTotalAnswersData(userId: authManager.currentUserId!) { (totalData, totalAnswers) in
            if totalAnswers > 30 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数３０") { exists in
                    if !exists {
                        answer30flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数３０")
                    }
                }
            }
            if totalAnswers > 50 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数５０") { exists in
                    if !exists {
                        answer50flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数５０")
                    }
                }
            }
            if totalAnswers > 100 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数１００") { exists in
                    if !exists {
                        answer100flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数１００")
                    }
                }
            }
        }
    }
    
    func executeProcessEveryFortyTimes() {
        let count = UserDefaults.standard.integer(forKey: "launchPreCount") + 1
        UserDefaults.standard.set(count, forKey: "launchPreCount")
        if count % 3 == 0 {
            preFlag = true
        }
    }
}

// MARK: - Enhanced Modal Views
struct ExperienceModalView: View {
    @Binding var showModal: Bool
    var addedExperience: Int
    var addedMoney: Int
    var itemRewards: [InventoryReward] = []
    @State private var currentExperience: Double = 0
    @State private var currentMoney: Double = 0
    @State private var showContent = false
    let maxExperience: Double = 100
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            VStack(spacing: 24) {
                // アニメーション付きアイコン
                ZStack {
                    Circle()
                        .fill(currentExperience != 5 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                    
                    Image(systemName: currentExperience != 5 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(currentExperience != 5 ? .green : .red)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                }
                
                VStack(spacing: 8) {
                    Text(currentExperience != 5 ? "クリア！" : "ゲームオーバー")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: showContent)
                }
                
                // 獲得リワード
                VStack(spacing: 16) {
                    rewardRow(icon: "経験値", title: "経験値", value: "+\(Int(currentExperience))")
                    rewardRow(icon: "コイン", title: "コイン", value: "+\(Int(currentMoney))")
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.6), value: showContent)

                if !itemRewards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("追加アイテム")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)

                        ForEach(Array(itemRewards.enumerated()), id: \.offset) { entry in
                            let reward = entry.element
                            HStack(spacing: 12) {
                                InventoryItemArtworkView(type: reward.type, width: 34, height: 34, cornerRadius: 10)

                                Text(reward.type.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("x\(reward.amount)")
                                    .font(.headline)
                                    .foregroundColor(reward.type.accentColor)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.7), value: showContent)
                }
                
                // プログレスバー
                VStack(spacing: 12) {
                    Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    ProgressBar1(value: Double(authManager.experience), maxValue: Double(authManager.level * 100))
                        .frame(height: 12)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.8), value: showContent)
                
                // 閉じるボタン
                Button(action: dismissModal) {
                    Text("続ける")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.0), value: showContent)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
        }
        .onAppear {
            authManager.fetchUserFlag()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                    currentExperience = Double(addedExperience) * Double(authManager.rewardFlag)
                    currentMoney = Double(addedMoney) * Double(authManager.rewardFlag)
                }
            }
            
            if currentExperience != 5 {
                audioManager.playGameClearSound()
            } else {
                audioManager.playGameOverSound()
            }
            
            DispatchQueue.global(qos: .background).async {
                authManager.fetchUserExperienceAndLevel()
            }
        }
    }
    
    private func rewardRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        withAnimation(.spring()) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showModal = false
        }
        audioManager.playCancelSound()
    }
}

struct LevelUpModalView: View {
    @Binding var showLevelUpModal: Bool
    @State private var showBackground = false
    @State private var showCard = false
    @State private var showIcon = false
    @State private var showLevel = false
    @State private var showText = false
    @State private var showButton = false
    @State private var ringRotation: Double = 0
    @State private var outerRingScale: CGFloat = 0.3
    @State private var confettiParticles: [LevelUpConfetti] = []
    @State private var glowPulse = false
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(showBackground ? 0.75 : 0)
                .ignoresSafeArea()
                .onTapGesture { }

            // コンフェティ
            ForEach(confettiParticles) { p in
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: p.width, height: p.height)
                    .rotationEffect(.degrees(p.rotation))
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }

            if showCard {
                VStack(spacing: 28) {
                    // レベルアイコン
                    ZStack {
                        // 外側リング（回転）
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [.yellow, .orange, .red, .orange, .yellow],
                                    center: .center
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(outerRingScale)
                            .rotationEffect(.degrees(ringRotation))

                        // グロー
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.yellow.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(glowPulse ? 1.1 : 0.9)

                        // 中央円
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 1.0, green: 0.55, blue: 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .shadow(color: .orange.opacity(0.6), radius: 20)
                            .scaleEffect(showIcon ? 1.0 : 0.3)

                        // 矢印アイコン（画像の代わり）
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(showIcon ? 1.0 : 0.1)
                            .opacity(showIcon ? 1 : 0)

                        // レベル数字
                        if showLevel {
                            Text("Lv.\(authManager.level)")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                                .offset(y: 44)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 170)

                    // テキスト
                    if showText {
                        VStack(spacing: 10) {
                            Text("LEVEL UP!")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text("レベル \(authManager.level) に到達しました！")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // ボタン
                    if showButton {
                        Button(action: dismissModal) {
                            Text("素晴らしい！")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 1.0, green: 0.7, blue: 0.1), Color(red: 1.0, green: 0.45, blue: 0.1)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: .orange.opacity(0.5), radius: 10, y: 4)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.10, blue: 0.22),
                                    Color(red: 0.08, green: 0.06, blue: 0.16)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 30, y: 10)
                )
                .padding(.horizontal, 36)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .onAppear {
            authManager.fetchUserExperienceAndLevel()
            playSequence()
        }
    }

    private func playSequence() {
        // 背景
        withAnimation(.easeOut(duration: 0.3)) {
            showBackground = true
        }

        // カード
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCard = true
            }
        }

        // アイコン
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                showIcon = true
                outerRingScale = 1.0
            }
            // リング回転開始
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            // グローパルス
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }

        // レベル数字
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showLevel = true
            }
        }

        // コンフェティ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spawnConfetti()
        }

        // テキスト
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showText = true
            }
        }

        // ボタン
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showButton = true
            }
        }
    }

    private func spawnConfetti() {
        let colors: [Color] = [.yellow, .orange, .red, .pink, .purple, .cyan]
        for i in 0..<25 {
            var piece = LevelUpConfetti(
                x: CGFloat.random(in: -180...180),
                y: -400,
                width: CGFloat.random(in: 4...8),
                height: CGFloat.random(in: 10...18),
                color: colors.randomElement()!,
                rotation: 0,
                opacity: 1.0
            )
            let delay = Double(i) * 0.025
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: Double.random(in: 1.5...3.0))) {
                    piece.y = 500
                    piece.x += CGFloat.random(in: -30...30)
                    piece.rotation = Double.random(in: 360...720)
                    piece.opacity = 0
                }
                confettiParticles.append(piece)
            }
        }
    }

    private func dismissModal() {
        generateHapticFeedback()
        audioManager.playCancelSound()
        withAnimation(.easeOut(duration: 0.2)) {
            showCard = false
            showBackground = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            showLevelUpModal = false
        }
    }
}

struct LevelUpConfetti: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
}

struct ProgressBar1: View {
    var value: Double
    var maxValue: Double
    @State private var animatedValue: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(animatedValue / maxValue) * geometry.size.width)
                    .animation(.easeInOut(duration: 1.5), value: animatedValue)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animatedValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Preview
struct QuizResultView_Previews: PreviewProvider {
    @State static var isPresenting = false
    @State static var navigateToQuizResultView = false

    static var previews: some View {
        let dummyResults = [
            QuizResult(question: "SwiftUIでレイアウトを作成する際に使用する基本的なコンテナビューは？", userAnswer: "VStack", correctAnswer: "VStack", explanation: "VStackは垂直方向にビューを配置するためのコンテナビューです。", isCorrect: true),
            QuizResult(question: "iOSアプリ開発で使用される主要なプログラミング言語は？", userAnswer: "Java", correctAnswer: "Swift", explanation: "Swiftは、Appleが開発したiOSアプリ開発用のプログラミング言語です。", isCorrect: false),
            QuizResult(question: "Xcodeとは何ですか？", userAnswer: "IDE", correctAnswer: "IDE", explanation: "Xcode（統合開発環境）は、Appleのプラットフォームでのソフトウェアアプリケーション開発用の統合開発環境です。", isCorrect: true)
        ]
        let authManager = AuthManager()

        QuizResultView(
            results: dummyResults,
            authManager: authManager,
            isPresenting: $isPresenting,
            navigateToQuizResultView: $navigateToQuizResultView,
            playerExperience: 25,
            playerMoney: 15,
            elapsedTime: 0,
            quizBossLevel: .none,
            quizLevel: .beginner
        )
    }
}
