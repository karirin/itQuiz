//
//  ITManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//  Redesigned with modern UI/UX
//

import SwiftUI
import AVFoundation
import Firebase

// ITManagerListView専用のPreferenceKey
struct ITManagerListPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ITManagerListView: View {
    // MARK: - Properties
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    
    // Quiz Presentation States
    @State private var isPresentingQuizBasic: Bool = false
    @State private var isPresentingQuizStrategy: Bool = false
    @State private var isPresentingQuizTechnology: Bool = false
    @State private var isPresentingQuizManagement: Bool = false
    @State private var isPresentingQuizIncorrect: Bool = false
    @State private var isPresentingStarterQuiz: Bool = false
    @State private var isPresentingLearningTourQuiz = false
    @ObservedObject private var learningTour = InitialLearningTour.shared
    
    // UI States
    @State private var isLoading: Bool = true
    @State private var incorrectCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var preFlag: Bool = false
    @State private var accuracyData: [String: QuizData] = [:]
    @State private var accuracyUserID: String?
    @State private var isLoadingAccuracy = true
    @State private var accuracyLoadFailed = false
    
    // Tutorial
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    // Reward
    @StateObject var reward = Reward()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    
    // Animation
    @State private var animateCards: Bool = false
    
    // MARK: - Init
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Main Content
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Review Section
                        reviewSection

                        
                        // Category Section
                        categorySection
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            
            // Floating Reward Button
            floatingRewardButton
            
            // Tutorial Overlay
            if tutorialNum == 3 && !learningTour.isActive {
                tutorialOverlay
            }
        }
        .onAppear(perform: setupView)
        .task(id: accuracyRefreshID) {
            await refreshAccuracy()
        }
        .onChange(of: connectivity.isConnected) { isConnected in
            refreshIncorrectCount()
        }
        .onChange(of: appState.isSubscribed) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizBasic) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizStrategy) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizTechnology) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizManagement) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizIncorrect) { _ in refreshIncorrectCount() }
        .gesture(swipeBackGesture)
        .fullScreenCover(isPresented: $preFlag) {
            PreView(
                audioManager: audioManager,
                source: .review(incorrectCount: incorrectCount)
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizBasic, onDismiss: finishGuidedQuizDismissal) {
            QuizITBasicList(
                isPresenting: $isPresentingQuizBasic,
                isInfiniteMode: false,
                questionLimit: isPresentingStarterQuiz ? 3 : nil,
                isLearningTour: isPresentingLearningTourQuiz
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizStrategy) {
            QuizITStrategyListView(
                isPresenting: $isPresentingQuizStrategy,
                isInfiniteMode: false
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizTechnology) {
            QuizITTechnologyListView(
                isPresenting: $isPresentingQuizTechnology,
                isInfiniteMode: false
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizManagement) {
            QuizITManagementListView(
                isPresenting: $isPresentingQuizManagement,
                isInfiniteMode: false
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizIncorrect) {
            QuizITIncorrectAnswerListView(isPresenting: $isPresentingQuizIncorrect)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("報酬獲得！"),
                message: Text("1時間だけ獲得した経験値とコインが2倍になります"),
                dismissButton: .default(Text("OK")) {
                    showAlert = false
                    reward.rewardEarned = false
                }
            )
        }
        .navigationBarHidden(true)
        .learningTourOverlay(step: .category, target: .category)
    }

    
    // MARK: - Background View
    private var backgroundView: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
            LinearGradient(
                colors: [Color(hex: "b9e9e1").opacity(0.4), Color(hex: "d4d9fa").opacity(0.3), Color(hex: "f5d8e7").opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            GeometryReader { geometry in
                Circle()
                    .fill(Color(hex: "38c9ae").opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: -100, y: -50)
                Circle()
                    .fill(Color(hex: "667eea").opacity(0.22))
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button(action: {
                generateHapticFeedback()
                audioManager.playCancelSound()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("戻る")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color(hex: "11998e"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text("ITパスポート")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // バランス用
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                Text("戻る")
            }
            .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Review Section
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(
                        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 4, height: 20)
                
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "f093fb"))
                
                Text("不正解した問題を復習")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Review Button
            reviewButton
                .padding(.horizontal, 16)
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateCards)
        }
    }
    
    private var reviewButton: some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playKetteiSound()
            if incorrectCount > 0 {
                isPresentingQuizIncorrect = true
            } else {
                isPresentingStarterQuiz = !appState.isSubscribed
                isPresentingQuizBasic = true
            }
        }) {
            LearningModeGlassCard(
                title: "復習問題",
                subtitle: reviewCardSubtitle,
                count: accuracyCount(for: .incorrectITAnswer),
                status: accuracyStatus,
                showsPreviousAccuracy: showsPreviousAccuracy,
                icon: "arrow.counterclockwise",
                badge: !appState.isSubscribed ? "1日5問無料" : (incorrectCount > 0 ? "\(incorrectCount)問" : nil),
                isCompact: true,
                gradient: QuizColors.review
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .accessibilityIdentifier("learning.it.review")
    }

    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 4, height: 20)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "11998e"))
                
                Text("問題カテゴリを選択")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Category Buttons
            VStack(spacing: 12) {
                categoryButton(
                    title: "基礎理解",
                    subtitle: "IT基礎知識・コンピュータ基礎",
                    icon: "book.fill",
                    quizLevel: .itBasic,
                    gradient: LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.15
                ) {
                    isPresentingStarterQuiz = false
                    isPresentingLearningTourQuiz = learningTour.step == .category
                    learningTour.advance(from: .category)
                    isPresentingQuizBasic = true
                }
                .learningTourTarget(.category)
                .accessibilityIdentifier("learningTour.selectBasic")
                .overlay(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.buttonRect = geometry.frame(in: .global)
                                }
                            }
                    }
                    .allowsHitTesting(false)
                )
                
                categoryButton(
                    title: "ストラテジ",
                    subtitle: "経営戦略・システム戦略",
                    icon: "chart.line.uptrend.xyaxis",
                    quizLevel: .itStrategy,
                    gradient: LinearGradient(
                        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.2
                ) {
                    isPresentingQuizStrategy = true
                }
                
                categoryButton(
                    title: "テクノロジ",
                    subtitle: "ハードウェア・ソフトウェア・ネットワーク",
                    icon: "cpu.fill",
                    quizLevel: .itTechnology,
                    gradient: LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.25
                ) {
                    isPresentingQuizTechnology = true
                }
                
                categoryButton(
                    title: "マネジメント",
                    subtitle: "プロジェクト管理・サービスマネジメント",
                    icon: "person.3.fill",
                    quizLevel: .itManagement,
                    gradient: LinearGradient(
                        colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.3
                ) {
                    isPresentingQuizManagement = true
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func categoryButton(
        title: String,
        subtitle: String,
        icon: String,
        quizLevel: QuizLevel,
        gradient: LinearGradient,
        delay: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playKetteiSound()
            action()
        }) {
            LearningModeGlassCard(
                title: title,
                subtitle: subtitle,
                count: accuracyCount(for: quizLevel),
                status: accuracyStatus,
                showsPreviousAccuracy: showsPreviousAccuracy,
                icon: icon,
                isCompact: true,
                gradient: gradient
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("learning.it.\(quizLevel.description)")
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: animateCards)
    }
    
    // MARK: - Floating Reward Button
    private var floatingRewardButton: some View {
        VStack {
            Spacer()
            HStack {
                rewardButton
                    .padding(.leading, 16)
                    .padding(.bottom, 30)
                Spacer()
            }
        }
    }
    
    @State private var rewardAnimating = false
    
    private var rewardButton: some View {
        Button(action: {
            generateHapticFeedback()
            reward.ExAndMoReward()
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "ffd700").opacity(0.4),
                                Color(hex: "ffd700").opacity(0)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(rewardAnimating ? 1.2 : 1.0)
                    .opacity(reward.rewardLoaded ? 1 : 0)
                
                // Main button
                ZStack {
                    Circle()
                        .fill(
                            reward.rewardLoaded ?
                            LinearGradient(
                                colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: reward.rewardLoaded ? Color(hex: "ffd700").opacity(0.5) : .clear, radius: 10)
                    
                    VStack(spacing: 2) {
                        Text("動画視聴で")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("経験値とコインが")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text("2倍に")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!reward.rewardLoaded)
        .onChange(of: reward.rewardEarned) { earned in
            showAlert = earned
        }
        .onAppear {
            if reward.rewardLoaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rewardAnimating = true
                }
            }
        }
        .onChange(of: reward.rewardLoaded) { loaded in
            if loaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rewardAnimating = true
                }
            }
        }
    }
    
    // MARK: - Tutorial Overlay
    @State private var tutorialPulse: Bool = false

    private var tutorialOverlay: some View {
        TutorialSpotlight(
            spotlight: buttonRect,
            cornerRadius: 20,
            step: 3,
            icon: "hand.tap.fill",
            title: "「基礎理解」をタップ",
            message: "まずは基礎から始めてみましょう",
            accent: [Color(hex: "11998e"), Color(hex: "38ef7d")],
            placement: .below,
            onSkip: {
                generateHapticFeedback()
                tutorialNum = 0
                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { _ in }
            }
        )
        .onTapGesture {
            audioManager.playSound()
            tutorialNum = 0
            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { _ in }
        }
    }
    
    // MARK: - Gestures
    private var swipeBackGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width > 80 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    // MARK: - Setup
    private func finishGuidedQuizDismissal() {
        guard isPresentingLearningTourQuiz else { return }
        isPresentingLearningTourQuiz = false
        if learningTour.pendingExit != nil { learningTour.finish() }
        if learningTour.isActive {
            learningTour.revisit(.category)
        } else if learningTour.exit == .continueLearning {
            isPresentingQuizBasic = true
        }
    }

    private func setupView() {
        if connectivity.isConnected {
            reward.LoadReward()
        }
        fetchIncorrectCount()
        
        authManager.fetchUserInfo { _, _, _, _, _, tutorial in
            if let tutorial = tutorial {
                tutorialNum = tutorial
            }
        }
        
        // Start animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateCards = true
        }
    }
    
    private func fetchIncorrectCount() {
        guard let userId = authManager.currentUserId else {
            incorrectCount = 0
            isLoading = false
            return
        }

        let localCount = LocalIncorrectAnswerStore.count(userId: userId, category: .itPassport)
        guard appState.isSubscribed, connectivity.isConnected else {
            incorrectCount = localCount
            isLoading = false
            return
        }

        let ref = Database.database().reference().child("IncorrectITAnswers").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            let count = Int(snapshot.childrenCount)
            DispatchQueue.main.async {
                self.incorrectCount = max(count, localCount)
                self.isLoading = false
            }
        }
    }
    
    private func refreshIncorrectCount() {
        fetchIncorrectCount()
    }
    
    private var reviewCardSubtitle: String {
        guard !isLoading else { return "復習問題を読み込み中" }
        if incorrectCount > 0 {
            return appState.isSubscribed
                ? "\(incorrectCount)問の復習問題"
                : "\(incorrectCount)問から1日5問を無料復習"
        }
        return appState.isSubscribed
            ? "まずは通常問題に挑戦"
            : "まずは3問に挑戦して復習を準備"
    }

    private var isShowingQuiz: Bool {
        isPresentingQuizBasic || isPresentingQuizStrategy || isPresentingQuizTechnology
            || isPresentingQuizManagement || isPresentingQuizIncorrect || preFlag
    }

    private var accuracyRefreshID: String {
        "\(authManager.currentUserId ?? "")-\(connectivity.isConnected)-\(isShowingQuiz)"
    }

    private var showsPreviousAccuracy: Bool {
        accuracyUserID != nil && accuracyUserID == authManager.currentUserId
            && (!connectivity.isConnected || accuracyLoadFailed)
    }

    private var accuracyStatus: String? {
        guard accuracyUserID != nil, accuracyUserID == authManager.currentUserId else {
            if !connectivity.isConnected { return "オフライン" }
            if authManager.currentUserId == nil { return "記録を準備中" }
            if accuracyLoadFailed { return "取得できませんでした" }
            return isLoadingAccuracy ? "読み込み中" : nil
        }
        return nil
    }

    private func accuracyCount(for level: QuizLevel) -> LearningCount {
        guard accuracyUserID == authManager.currentUserId,
              let data = accuracyData[level.description] else { return LearningCount() }
        return LearningCount(answers: data.answer, correct: data.correct)
    }

    @MainActor
    private func refreshAccuracy() async {
        let userID = authManager.currentUserId
        if accuracyUserID != userID {
            accuracyData = [:]
            accuracyUserID = nil
            accuracyLoadFailed = false
        }
        guard !isShowingQuiz, connectivity.isConnected,
              let userID, !userID.isEmpty else {
            isLoadingAccuracy = false
            return
        }
        isLoadingAccuracy = true
        accuracyLoadFailed = false
        defer { if !Task.isCancelled { isLoadingAccuracy = false } }
        do {
            let data = try await RateManager.shared.fetchAccuracyData(userId: userID)
            guard !Task.isCancelled, userID == authManager.currentUserId else { return }
            accuracyData = data
            accuracyUserID = userID
        } catch {
            guard !Task.isCancelled, userID == authManager.currentUserId else { return }
            accuracyLoadFailed = true
        }
    }

    // MARK: - Helper
    func isIPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isSmallDevice() -> Bool {
        UIScreen.main.bounds.width < 390
    }
}

// MARK: - Preview
#Preview {
    ITManagerListView(isPresenting: .constant(false))
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
}
