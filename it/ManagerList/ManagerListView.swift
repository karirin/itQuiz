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

struct ManagerListView: View {
    // MARK: - Properties
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    
    // Navigation States
    @State private var isPresentingITView: Bool = false
    @State private var isPresentingInfoView: Bool = false
    @State private var isPresentingAppliedView: Bool = false
    @State private var isPresentingESView: Bool = false
    @State private var isPresentingStrategyView: Bool = false
    
    // UI States
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var showAlert: Bool = false
    
    // Reward
    @StateObject var reward = Reward()
    
    // Animation
    @State private var animateCards: Bool = false
    @State private var rewardAnimating: Bool = false
    
    // MARK: - Init
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            backgroundView

            VStack {
                navigationBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        categoryCardsSection
                    }
                }
            }

            floatingRewardButton

            if tutorialNum == 2 {
                tutorialOverlay
            }

            // 👇 ここに追加（レイアウトに影響させない）
            navigationLinks
        }
        .onAppear(perform: setupView)

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
        ZStack {
            LinearGradient(
                colors: [Color(hex: "667eea").opacity(0.1), Color(hex: "764ba2").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color(hex: "667eea").opacity(0.08))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -50)
                
                Circle()
                    .fill(Color(hex: "764ba2").opacity(0.06))
                    .frame(width: 250, height: 250)
                    .offset(x: geo.size.width - 100, y: geo.size.height - 200)
            }
        }
        .ignoresSafeArea()
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
            // IT Passport
            certificationCard(
                title: "ITパスポート",
                subtitle: "IT基礎知識の入門資格",
                gradient: LinearGradient(
                    colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                delay: 0.1
            ) {
                isPresentingITView = true
            }
            .background(GeometryReader { geometry in
                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
            })
            
            // Basic Information Technology Engineer
            certificationCard(
                title: "基本情報技術者",
                subtitle: "ITエンジニアの登竜門",
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
        gradient: LinearGradient,
        delay: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playSound()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon Container
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14)
//                        .fill(.white.opacity(0.2))
//                        .frame(width: 56, height: 56)
//                    
//                    Image(systemName: icon)
//                        .font(.system(size: 26, weight: .semibold))
//                        .foregroundColor(.white)
//                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Difficulty Badge & Arrow
                VStack(alignment: .trailing, spacing: 8) {
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
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
                    .frame(width: 100, height: 100)
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
                        .frame(width: 70, height: 70)
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
                            .position(x: buttonRect.midX, y: isSmallDevice() ? buttonRect.midY - 80 : buttonRect.midY - 115)
                            .blendMode(.destinationOut)
                    )
                    .ignoresSafeArea()
                    .compositingGroup()
            }
            
            // Tutorial Message
            VStack {
                Spacer()
                    .frame(height: isSmallDevice() ? buttonRect.minY + bubbleHeight - 20 : buttonRect.minY + bubbleHeight - 50)
                
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "667eea"))
                    
                    Text("「ITパスポート」をタップしてください")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 10)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            bubbleHeight = geometry.size.height - 40
                        }
                })
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Skip Button
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        tutorialNum = 0
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { _ in }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 12))
                            Text("スキップ")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
        }
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
        }
        .hidden()
        .frame(width: 0, height: 0)
    }

    
    // MARK: - Setup
    private func setupView() {
        reward.LoadReward()
        
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
    func isIPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isSmallDevice() -> Bool {
        UIScreen.main.bounds.width < 390
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ManagerListView(isPresenting: .constant(false))
    }
}
