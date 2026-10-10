//
//  ManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//  Redesigned with modern UI/UX
//

import SwiftUI
import AVFoundation
import Firebase

// ManagerListView専用のPreferenceKey
struct ManagerListPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ManagerListView: View {
    // MARK: - Properties
    private var showsReviewMode: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }

    @ObservedObject private var learningTour = InitialLearningTour.shared
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    let showsBackButton: Bool
    
    // Navigation States
    @State private var isPresentingITView: Bool = false
    @State private var isPresentingInfoView: Bool = false
    @State private var isPresentingAppliedView: Bool = false
    @State private var isPresentingESView: Bool = false
    @State private var isPresentingStrategyView: Bool = false
    @State private var isPresentingReview: Bool = false
    
    // UI States
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var showAlert: Bool = false
    @State private var reviewSummary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)
    @State private var accuracyData: [String: QuizData] = [:]
    @State private var accuracyUserID: String?
    @State private var isLoadingAccuracy = true
    @State private var accuracyLoadFailed = false
    
    // Reward
    @StateObject var reward = Reward()

    // Guerrilla
    @StateObject private var guerrillaManager = GuerrillaManager()
    @State private var isPresentingGuerrilla = false
    @State private var showGuerrillaButton: Bool = false
    private let guerrillaClickedKey = "guerrillaButtonClickedExpiresAt"
    
    // Animation
    @State private var animateCards: Bool = false
    @State private var rewardAnimating: Bool = false
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    
    // MARK: - Init
    init(isPresenting: Binding<Bool>, showsBackButton: Bool = true) {
        _isPresenting = isPresenting
        self.showsBackButton = showsBackButton
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            backgroundView

            VStack {
                navigationBar
                if !connectivity.isConnected {
                    OfflineStatusBanner()
                }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        categoryCardsSection
                    }
                    .padding(.bottom, 130)
                }
            }

            if connectivity.isConnected {
                floatingRewardButton
            }

            if connectivity.isConnected && showGuerrillaButton {
                guerrillaBossButton
            }

            if tutorialNum == 2 && !learningTour.isActive {
                tutorialOverlay
            }

            // 👇 ここに追加（レイアウトに影響させない）
            navigationLinks
        }
        .onAppear(perform: setupView)
        .task(id: accuracyRefreshID) {
            await refreshAccuracy()
        }
        .onChange(of: guerrillaManager.status) { _ in
            updateGuerrillaButtonVisibility()
        }
        .onChange(of: isPresentingITView) { presenting in
            if !presenting && learningTour.isActive { learningTour.revisit(.qualification) }
        }
        .onChange(of: isPresentingReview) { isPresenting in
            if !isPresenting {
                refreshReviewSummary()
            }
        }
        .fullScreenCover(isPresented: $isPresentingReview) {
            QuizIncorrectAnswerListView(isPresenting: $isPresentingReview)
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
        .learningTourOverlay(step: .qualification, target: .qualification)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LearningModeGlassBackground()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            
            Text("学習する資格試験を選択してください")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateCards)
    }
    
    private var navigationBar: some View {
        HStack {
            if showsBackButton {
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
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
                .opacity(0)
            }
            
            Spacer()
            
            Text("学習モード")
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
    
    // MARK: - Category Cards Section
    private var categoryCardsSection: some View {
        VStack(spacing: 16) {
            if showsReviewMode {
                certificationCard(
                    title: "苦手克服",
                    subtitle: reviewCardSubtitle,
                    quizLevels: [.incorrectAnswer, .incorrectITAnswer, .incorrectInfoAnswer, .incorrectAppliedAnswer, .incorrectITStrategyAnswer, .incorrectESAnswer],
                    gradient: LinearGradient(
                        colors: [Color(hex: "ff6b6b"), Color(hex: "feca57")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.05
                ) {
                    isPresentingReview = true
                }
            }

            // IT Passport
            certificationCard(
                title: "ITパスポート",
                subtitle: "IT基礎知識の入門資格",
                quizLevels: [.itBasic, .itStrategy, .itTechnology, .itManagement],
                gradient: LinearGradient(
                    colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.1
            ) {
                learningTour.advance(from: .qualification)
                isPresentingITView = true
            }
            .learningTourTarget(.qualification)
            .accessibilityIdentifier("learningTour.selectITPassport")
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
            
            // Basic Information Technology Engineer
            certificationCard(
                title: "基本情報技術者",
                subtitle: "ITエンジニアの登竜門",
                quizLevels: [.infoBasic, .infoStrategy, .infoTechnology, .infoManagement],
                gradient: LinearGradient(
                    colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.15
            ) {
                isPresentingInfoView = true
            }
            
            // Applied Information Technology Engineer
            certificationCard(
                title: "応用情報技術者",
                subtitle: "高度IT人材への第一歩",
                quizLevels: [.appliedBasic, .appliedStrategy, .appliedTechnology, .appliedManagement],
                gradient: LinearGradient(
                    colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.2
            ) {
                isPresentingAppliedView = true
            }
            
            // IT Strategy
            certificationCard(
                title: "ITストラテジスト",
                subtitle: "経営戦略とIT戦略の融合",
                quizLevels: [.kikaku, .sekkei, .kaihatu, .unyouhoshu],
                gradient: LinearGradient(
                    colors: [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.25
            ) {
                isPresentingStrategyView = true
            }
            
            // Embedded Systems
            certificationCard(
                title: "エンベデッドシステム",
                subtitle: "組込みシステムの専門資格",
                quizLevels: [.computerSystem, .softHard, .netwarkTusin, .ESsecurity],
                gradient: LinearGradient(
                    colors: [Color(hex: "ff9a9e"), Color(hex: "fecfef")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.3
            ) {
                isPresentingESView = true
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func certificationCard(
        title: String,
        subtitle: String,
        quizLevels: [QuizLevel],
        gradient: LinearGradient,
        delay: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playSound()
            action()
        }) {
            LearningModeGlassCard(
                title: title,
                subtitle: subtitle,
                count: accuracyCount(for: quizLevels),
                status: accuracyStatus,
                showsPreviousAccuracy: accuracyUserID == authManager.currentUserId
                    && (!connectivity.isConnected || accuracyLoadFailed),
                gradient: gradient
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityIdentifier("learning.mode.\(quizLevels.first?.description ?? "review")")
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
    }
    
    // MARK: - Floating Reward Button
    private var floatingRewardButton: some View {
        VStack {
            Spacer()
            HStack {
                rewardButton
                    .padding(.leading, 20)
                    .padding(.bottom, 30)
                Spacer()
            }
        }
    }
    
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
        .frame(height: 90)
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
    
    // MARK: - Guerrilla Boss Button
    private var guerrillaBossButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playSound()
                    UserDefaults.standard.set(guerrillaManager.expiresAt, forKey: guerrillaClickedKey)
                    isPresentingGuerrilla = true
                }) {
                    Image("ゲリラボスボタン")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.6), radius: 10, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Tutorial Overlay
    @State private var tutorialPulse: Bool = false

    private var tutorialOverlay: some View {
        TutorialSpotlight(
            spotlight: buttonRect,
            cornerRadius: 20,
            step: 2,
            icon: "hand.tap.fill",
            title: "「ITパスポート」をタップ",
            message: "学習したい資格を選択しましょう",
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
            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { _ in }
        }
    }
    
    private var navigationLinks: some View {
        Group {
            NavigationLink(
                destination: ITManagerListView(isPresenting: $isPresentingITView).navigationBarBackButtonHidden(true),
                isActive: $isPresentingITView
            ) { EmptyView() }

            NavigationLink(
                destination: InfoManagerListView(isPresenting: $isPresentingInfoView).navigationBarBackButtonHidden(true),
                isActive: $isPresentingInfoView
            ) { EmptyView() }

            NavigationLink(
                destination: AppliedManagerListView(isPresenting: $isPresentingAppliedView).navigationBarBackButtonHidden(true),
                isActive: $isPresentingAppliedView
            ) { EmptyView() }

            NavigationLink(
                destination: ESManagerListView(isPresenting: $isPresentingESView).navigationBarBackButtonHidden(true),
                isActive: $isPresentingESView
            ) { EmptyView() }

            NavigationLink(
                destination: ITStoratagyManagerListView(isPresenting: $isPresentingStrategyView).navigationBarBackButtonHidden(true),
                isActive: $isPresentingStrategyView
            ) { EmptyView() }

            NavigationLink(
                destination: GuerrillaLobbyView(authManager: authManager, audioManager: audioManager, isPresenting: $isPresentingGuerrilla).navigationBarBackButtonHidden(true),
                isActive: $isPresentingGuerrilla
            ) { EmptyView() }
        }
        .hidden()
        .frame(width: 0, height: 0)
    }

    
    // MARK: - Guerrilla Button Visibility
    private func updateGuerrillaButtonVisibility() {
        guard guerrillaManager.status == "active" else {
            showGuerrillaButton = false
            UserDefaults.standard.removeObject(forKey: guerrillaClickedKey)
            return
        }

        let clickedExpiresAt = UserDefaults.standard.double(forKey: guerrillaClickedKey)
        if clickedExpiresAt > 0 && clickedExpiresAt == guerrillaManager.expiresAt {
            showGuerrillaButton = true
            return
        }

        // 30% random chance
        showGuerrillaButton = Int.random(in: 1...10) <= 3
    }

    // MARK: - Setup
    private func setupView() {
        guard connectivity.isConnected else {
            showGuerrillaButton = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateCards = true
            }
            return
        }

        reward.LoadReward()
        guerrillaManager.observeActiveGuerrilla()
        refreshReviewSummary()

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
    
    // MARK: - Helper
    private var isShowingLearningDetail: Bool {
        isPresentingITView || isPresentingInfoView || isPresentingAppliedView
            || isPresentingStrategyView || isPresentingESView || isPresentingReview
    }

    private var accuracyRefreshID: String {
        "\(authManager.currentUserId ?? "")-\(connectivity.isConnected)-\(isShowingLearningDetail)"
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

    private func accuracyCount(for levels: [QuizLevel]) -> LearningCount {
        guard accuracyUserID == authManager.currentUserId else { return LearningCount() }
        return levels.reduce(LearningCount()) { total, level in
            guard let data = accuracyData[level.description] else { return total }
            return total + LearningCount(answers: data.answer, correct: data.correct)
        }
    }

    @MainActor
    private func refreshAccuracy() async {
        let userID = authManager.currentUserId
        if accuracyUserID != userID {
            accuracyData = [:]
            accuracyUserID = nil
            accuracyLoadFailed = false
        }
        guard !isShowingLearningDetail, connectivity.isConnected,
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

    private var reviewCardSubtitle: String {
        if reviewSummary.dueCount > 0 {
            return "今日の解き直し \(reviewSummary.dueCount)問・説明と類題でも練習"
        }
        if let nextReviewDate = reviewSummary.nextReviewDate {
            return "次の解き直しは\(nextReviewDate.formatted(date: .abbreviated, time: .omitted))・テーマも練習できます"
        }
        return "問題の解き直し・テーマの説明・類題をひとつに"
    }

    private func refreshReviewSummary() {
        guard let userId = authManager.currentUserId else {
            reviewSummary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)
            return
        }
        ReviewScheduleService.fetchSummary(userId: userId) { summary in
            reviewSummary = summary
        }
    }

    func isIPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isSmallDevice() -> Bool {
        UIScreen.main.bounds.width < 390
    }
}

final class LearningModeAccuracyStore: ObservableObject {
    @Published private var data: [String: QuizData] = [:]
    @Published private var loadedUserID: String?
    @Published private var isLoading = true
    @Published private var loadFailed = false

    func count(for level: QuizLevel, userID: String?) -> LearningCount {
        guard loadedUserID == userID, let record = data[level.description] else {
            return LearningCount()
        }
        return LearningCount(answers: record.answer, correct: record.correct)
    }

    func status(userID: String?, isConnected: Bool) -> String? {
        guard loadedUserID != nil, loadedUserID == userID else {
            if !isConnected { return "オフライン" }
            if userID == nil { return "記録を準備中" }
            if loadFailed { return "取得できませんでした" }
            return isLoading ? "読み込み中" : nil
        }
        return nil
    }

    func showsPreviousAccuracy(userID: String?, isConnected: Bool) -> Bool {
        loadedUserID != nil && loadedUserID == userID && (!isConnected || loadFailed)
    }

    @MainActor
    func refresh(userID: String?, isConnected: Bool, isShowingQuiz: Bool) async {
        if loadedUserID != userID {
            data = [:]
            loadedUserID = nil
            loadFailed = false
        }
        guard !isShowingQuiz, isConnected, let userID, !userID.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        loadFailed = false
        defer { if !Task.isCancelled { isLoading = false } }
        do {
            let records = try await RateManager.shared.fetchAccuracyData(userId: userID)
            guard !Task.isCancelled else { return }
            data = records
            loadedUserID = userID
        } catch {
            guard !Task.isCancelled else { return }
            loadFailed = true
        }
    }
}

struct LearningModeGlassBackground: View {
    var body: some View {
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
}

/// Shared card material used by the learning list and analysis dashboard.
private struct LearningModeGlassSurface: ViewModifier {
    let gradient: LinearGradient
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(reduceTransparency
                          ? AnyShapeStyle(Color(uiColor: .secondarySystemGroupedBackground))
                          : AnyShapeStyle(Material.ultraThin))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(gradient.opacity(colorScheme == .dark ? 0.1 : 0.12))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(colorScheme == .dark ? 0.4 : 0.9), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func learningModeGlassSurface(gradient: LinearGradient) -> some View {
        modifier(LearningModeGlassSurface(gradient: gradient))
    }
}

struct LearningModeGlassCard: View {
    let title: String
    let subtitle: String
    let count: LearningCount
    var status: String? = nil
    var showsPreviousAccuracy = false
    var icon: String? = nil
    var badge: String? = nil
    var isCompact = false
    let gradient: LinearGradient

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    private var accuracyText: String {
        if let status { return status }
        guard let rate = count.rate else { return "未回答" }
        return String(format: "%.0f%%", rate * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 16) {
            HStack(spacing: isCompact ? 10 : 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 17 : 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: isCompact ? 34 : 44, height: isCompact ? 34 : 44)
                        .background(gradient.opacity(0.14), in: Circle())
                }
                VStack(alignment: .leading, spacing: isCompact ? 3 : 5) {
                    Text(title)
                        .font(.system(size: isCompact ? 17 : 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.system(size: isCompact ? 11 : 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if isCompact {
                    HStack(spacing: 6) {
                        cardBadge
                        cardChevron
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 6) {
                        cardBadge
                        cardChevron
                    }
                }
            }

            if isCompact {
                HStack(spacing: 8) {
                    accuracyLabel.fixedSize()
                    accuracyGauge
                    accuracyValue.fixedSize()
                }
            } else {
                VStack(spacing: 7) {
                    HStack(alignment: .firstTextBaseline) {
                        accuracyLabel
                        Spacer(minLength: 8)
                        accuracyValue
                    }
                    accuracyGauge
                }
            }
        }
        .padding(.horizontal, isCompact ? 16 : 20)
        .padding(.vertical, isCompact ? 12 : 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .learningModeGlassSurface(gradient: gradient)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title)、\(subtitle)" + (badge.map { "、\($0)" } ?? ""))
        .accessibilityValue("\(showsPreviousAccuracy ? "前回の正答率" : "正答率")、\(accuracyText)" + (status == nil && count.answers > 0 ? "、\(count.answers)問回答、\(count.correct)問正解" : ""))
    }

    @ViewBuilder
    private var cardBadge: some View {
        if let badge {
            Text(badge)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(gradient.opacity(0.14), in: Capsule())
        }
    }

    private var cardChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.secondary)
            .frame(width: isCompact ? 26 : 30, height: isCompact ? 26 : 30)
            .background(.white.opacity(colorScheme == .dark ? 0.08 : 0.5), in: Circle())
    }

    private var accuracyLabel: some View {
        Text(showsPreviousAccuracy ? "正答率（前回）" : "正答率")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private var accuracyValue: some View {
        Text(accuracyText)
            .font(.system(size: isCompact ? 13 : 14, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
    }

    private var accuracyGauge: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.primary.opacity(0.08))
                Capsule()
                    .fill(gradient)
                    .frame(width: geometry.size.width * CGFloat(status == nil ? count.rate ?? 0 : 0))
            }
            .clipShape(Capsule())
        }
        .frame(height: isCompact ? 5 : 7)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: count.rate)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ManagerListView(isPresenting: .constant(false))
    }
    .environmentObject(ConnectivityMonitor.shared)
}

#Preview("学習モード・正答率ゲージ") {
    ScrollView {
        VStack(spacing: 16) {
            LearningModeGlassCard(title: "ITパスポート", subtitle: "IT基礎知識の入門資格", count: LearningCount(answers: 100, correct: 72), gradient: QuizColors.itPassport)
            LearningModeGlassCard(title: "基本情報技術者", subtitle: "ITエンジニアの登竜門", count: LearningCount(answers: 10, correct: 0), gradient: QuizColors.basicInfo)
            LearningModeGlassCard(title: "応用情報技術者", subtitle: "高度IT人材への第一歩", count: LearningCount(), gradient: QuizColors.appliedInfo)
        }
        .padding(20)
    }
    .background(QuizColors.background)
}
