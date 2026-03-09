//
//  StoryQuizResultView.swift
//  it
//
//  Created by Apple on 2024/11/17.
//

import SwiftUI

struct StoryQuizResultView: View {
    let quizLevel: QuizLevel
    @State private var showModal = false
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
    @State private var rankUpFlag: Bool = false
    @State private var rankDownFlag: Bool = false
    @EnvironmentObject var appState: AppState
    @Binding var isPresenting: Bool
    @Binding var navigateToQuizResultView: Bool
    @State private var isHidden = false
    @State private var selectedTab = 0 // 0: 結果, 1: 統計
    private let interstitial = Interstitial()
    @Environment(\.presentationMode) var presentationMode
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @Binding var victoryFlag: Bool
    @Binding var isUserStoryFlag: Bool
    @ObservedObject var viewModel: PositionViewModel
    @State private var hasRequestedInterstitial = false
    @State private var hasPresentedInterstitial = false

    init(results: [QuizResult], authManager: AuthManager, isPresenting: Binding<Bool>, navigateToQuizResultView: Binding<Bool>, playerExperience: Int, playerMoney: Int, elapsedTime: TimeInterval, quizLevel: QuizLevel, victoryFlag: Binding<Bool>, isUserStoryFlag: Binding<Bool>, viewModel: PositionViewModel) {
        _results = State(initialValue: results)
        self.authManager = authManager
        _isPresenting = isPresenting
        _navigateToQuizResultView = navigateToQuizResultView
        _playerExperience = State(initialValue: playerExperience)
        _playerMoney = State(initialValue: playerMoney)
        self.elapsedTime = elapsedTime
        self.quizLevel = quizLevel
        _victoryFlag = victoryFlag
        _isUserStoryFlag = isUserStoryFlag
        self.viewModel = viewModel
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
                    if appState.isBannerVisible {
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
                .navigationTitle("ストーリー結果")
                .navigationBarTitleDisplayMode(.inline)
            }
            .background {
                if appState.isBannerVisible {
                    adViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                }
            }
            
            // モーダル類
            modalOverlays
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        isPresenting = false
                    }
                }
        )
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
        .onChange(of: authManager.rankUp) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    rankUpFlag = true
                    audioManager.playLevelUpSound()
                }
            }
        }
        .onChange(of: authManager.rankDown) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    rankDownFlag = true
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
        .onDisappear {
            if victoryFlag {
                if isUserStoryFlag {
                    viewModel.incrementUserPosition()
                } else {
                    viewModel.incrementPosition()
                }
            } else {
                viewModel.decreaseStamina(by: 10)
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
                    preFlag = true
                    audioManager.playSound()
                }) {
                    Image("プレミアムプランボタン")
                        .resizable()
                        .frame(width: 240, height: 70)
                }
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .fullScreenCover(isPresented: $showSubFlag) {
                    SubscriptionView(audioManager: audioManager)
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
                if victoryFlag {
                    statisticRow(title: "ステータス", value: "勝利 🏆")
                } else {
                    statisticRow(title: "ステータス", value: "敗北 😔")
                }
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
        if rankUpFlag {
            // ランクアップモーダルの実装
        }
        if rankDownFlag {
            // ランクダウンモーダルの実装
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
            if appState.isBannerVisible {
                executeProcessEveryFortyTimes()
            }
        }
        
        // 広告処理
        DispatchQueue.main.async {
            if !interstitial.interstitialAdLoaded && interstitial.wasAdDismissed == false {
                interstitial.loadInterstitial(completion: { isLoaded in
                    if isLoaded {
                        self.interstitial.presentInterstitial(from: adViewControllerRepresentable.viewController)
                    }
                })
            } else if !interstitial.wasAdDismissed {
                interstitial.presentInterstitial(from: adViewControllerRepresentable.viewController)
            }
        }
        
        // 広告処理
        if appState.isBannerVisible && !hasRequestedInterstitial {
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

// MARK: - Preview
struct StoryQuizResultView_Previews: PreviewProvider {
    @State static var isPresenting = false
    @State static var navigateToQuizResultView = false

    static var previews: some View {
        let dummyResults = [
            QuizResult(question: "SwiftUIでレイアウトを作成する際に使用する基本的なコンテナビューは？", userAnswer: "VStack", correctAnswer: "VStack", explanation: "VStackは垂直方向にビューを配置するためのコンテナビューです。", isCorrect: true),
            QuizResult(question: "iOSアプリ開発で使用される主要なプログラミング言語は？", userAnswer: "Java", correctAnswer: "Swift", explanation: "Swiftは、Appleが開発したiOSアプリ開発用のプログラミング言語です。", isCorrect: false),
            QuizResult(question: "Xcodeとは何ですか？", userAnswer: "IDE", correctAnswer: "IDE", explanation: "Xcode（統合開発環境）は、Appleのプラットフォームでのソフトウェアアプリケーション開発用の統合開発環境です。", isCorrect: true)
        ]
        let authManager = AuthManager()

        StoryQuizResultView(
            results: dummyResults,
            authManager: authManager,
            isPresenting: $isPresenting,
            navigateToQuizResultView: $navigateToQuizResultView,
            playerExperience: 25,
            playerMoney: 15,
            elapsedTime: 0,
            quizLevel: .beginner,
            victoryFlag: .constant(true),
            isUserStoryFlag: .constant(false),
            viewModel: PositionViewModel.shared
        )
    }
}
