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
    
    // UI States
    @State private var isLoading: Bool = true
    @State private var incorrectCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var preFlag: Bool = false
    
    // Tutorial
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    // Reward
    @StateObject var reward = Reward()
    @StateObject private var appState = AppState()
    
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
            if tutorialNum == 3 {
                tutorialOverlay
            }
        }
        .onAppear(perform: setupView)
        .onChange(of: isPresentingQuizBasic) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizStrategy) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizTechnology) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizManagement) { _ in refreshIncorrectCount() }
        .onChange(of: isPresentingQuizIncorrect) { _ in refreshIncorrectCount() }
        .gesture(swipeBackGesture)
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager)
        }
        .fullScreenCover(isPresented: $isPresentingQuizBasic) {
            QuizITBasicList(isPresenting: $isPresentingQuizBasic)
        }
        .fullScreenCover(isPresented: $isPresentingQuizStrategy) {
            QuizITStrategyListView(isPresenting: $isPresentingQuizStrategy)
        }
        .fullScreenCover(isPresented: $isPresentingQuizTechnology) {
            QuizITTechnologyListView(isPresenting: $isPresentingQuizTechnology)
        }
        .fullScreenCover(isPresented: $isPresentingQuizManagement) {
            QuizITManagementListView(isPresenting: $isPresentingQuizManagement)
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
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(hex: "f8fafc"), Color(hex: "e2e8f0")],
            startPoint: .top,
            endPoint: .bottom
        )
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
            if appState.isBannerVisible {
                preFlag = true
            } else if incorrectCount > 0 {
                isPresentingQuizIncorrect = true
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("復習問題")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !isLoading {
                        Text(incorrectCount > 0 ? "\(incorrectCount)問の復習問題" : "復習問題なし")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Badge or Lock
                if appState.isBannerVisible {
                    VStack(spacing: 2) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                        Text("Premium")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else if incorrectCount > 0 {
                    Text("\(incorrectCount)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    if incorrectCount == 0 && !appState.isBannerVisible && !isLoading {
                        Color.black.opacity(0.4)
                    }
                    
                    if appState.isBannerVisible {
                        Color.black.opacity(0.2)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "f093fb").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(incorrectCount == 0 && !appState.isBannerVisible)
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
                    gradient: LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.15
                ) {
                    isPresentingQuizBasic = true
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                })
                
                categoryButton(
                    title: "ストラテジ",
                    subtitle: "経営戦略・システム戦略",
                    icon: "chart.line.uptrend.xyaxis",
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
        gradient: LinearGradient,
        delay: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playKetteiSound()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon
//                ZStack {
//                    Circle()
//                        .fill(.white.opacity(0.2))
//                        .frame(width: 50, height: 50)
//                    
//                    Image(systemName: icon)
//                        .font(.system(size: 22, weight: .semibold))
//                        .foregroundColor(.white)
//                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
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
    private var tutorialOverlay: some View {
        ZStack {
            // Dark overlay with cutout
            GeometryReader { geometry in
                Color.black.opacity(0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .frame(width: buttonRect.width - 20, height: buttonRect.height)
                            .position(x: buttonRect.midX, y: buttonRect.midY)
                            .blendMode(.destinationOut)
                    )
                    .ignoresSafeArea()
                    .compositingGroup()
            }
            
            // Tutorial Message
            VStack {
                Spacer()
                    .frame(height: buttonRect.minY + bubbleHeight)
                
                VStack(spacing: 12) {
                    Text("「基礎理解」をタップしてください")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 10)
                }
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            bubbleHeight = geometry.size.height
                        }
                })
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Skip Button
            VStack {
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        tutorialNum = 0
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { _ in }
                    }) {
                        Text("スキップ")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
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
    private func setupView() {
        reward.LoadReward()
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
        guard let userId = authManager.currentUserId else { return }
        let ref = Database.database().reference().child("IncorrectITAnswers").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            let count = Int(snapshot.childrenCount)
            DispatchQueue.main.async {
                self.incorrectCount = count
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
        }
    }
    
    private func refreshIncorrectCount() {
        fetchIncorrectCount()
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
}
