//
//  AppliedManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//

import SwiftUI
import AVFoundation
import Firebase

struct AppliedManagerListView: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date = Date()
    @State private var audioPlayerKettei: AVAudioPlayer?
    @State private var isPresentingQuizBeginner: Bool = false
    @State private var isPresentingQuizIntermediate: Bool = false
    @State private var isPresentingQuizAdvanced: Bool = false
    @State private var isPresentingQuizNetwork: Bool = false
    @State private var isPresentingQuizSecurity: Bool = false
    @State private var isPresentingQuizDatabase: Bool = false
    @State private var isPresentingQuizGod: Bool = false
    @State private var isPresentingQuizIncorrectAnswer: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isIncorrectAnswersEmpty: Bool = true
    @StateObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showAlert: Bool = false
    @State private var preFlag: Bool = false
    @StateObject private var appState = AppState()
    @State private var isLoading: Bool = true
    @State private var animateCards: Bool = false
    @State private var incorrectCount: Int = 0
    @State private var rewardAnimating = false

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                navigationBar(title: "応用情報技術者試験")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        reviewSection
                        categorySection
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }

            floatingRewardButton

            if tutorialNum == 2 {
                tutorialOverlay
            }
        }
        .onAppear(perform: setupView)
        .gesture(swipeBackGesture)
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager)
        }
        .fullScreenCover(isPresented: $isPresentingQuizIncorrectAnswer) {
            QuizAppliedIncorrectAnswerListView(isPresenting: $isPresentingQuizIncorrectAnswer)
        }
        .fullScreenCover(isPresented: $isPresentingQuizDatabase) {
            QuizAppliedBasicListView(isPresenting: $isPresentingQuizDatabase)
        }
        .fullScreenCover(isPresented: $isPresentingQuizIntermediate) {
            QuizAppliedStrategyListView(isPresenting: $isPresentingQuizIntermediate)
        }
        .fullScreenCover(isPresented: $isPresentingQuizAdvanced) {
            QuizAppliedManagementListView(isPresenting: $isPresentingQuizAdvanced)
        }
        .fullScreenCover(isPresented: $isPresentingQuizGod) {
            QuizAppliedTechnologyListView(isPresenting: $isPresentingQuizGod)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("報酬獲得！"),
                message: Text("1時間だけ獲得した経験値とコインが2倍"),
                dismissButton: .default(Text("OK")) {
                    showAlert = false
                    reward.rewardEarned = false
                }
            )
        }
        .navigationBarHidden(true)
    }

    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectAppliedAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
        
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
        print("count:\(count)")
        self.isIncorrectAnswersEmpty = (count == 0)
    }
    }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(hex: "f8fafc"), Color(hex: "e2e8f0")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func navigationBar(title: String) -> some View {
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
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 6) { Image(systemName: "chevron.left"); Text("戻る") }
                .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            } else if !isIncorrectAnswersEmpty {
                isPresentingQuizIncorrectAnswer = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(.white.opacity(0.2)).frame(width: 50, height: 50)
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                        Text(!isIncorrectAnswersEmpty ? "\(incorrectCount)問の復習問題" : "復習問題なし")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                if appState.isBannerVisible {
                    VStack(spacing: 2) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                        Text("Premium")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else if !isIncorrectAnswersEmpty {
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
                    if isIncorrectAnswersEmpty && !appState.isBannerVisible && !isLoading { Color.black.opacity(0.4) }
                    if appState.isBannerVisible { Color.black.opacity(0.2) }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "f093fb").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(isIncorrectAnswersEmpty && !appState.isBannerVisible)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
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

            VStack(spacing: 12) {
                categoryButton(
                    title: "基礎理解",
                    subtitle: "応用・アルゴリズム基礎",
                    icon: "book.fill",
                    gradient: LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.15
                ) { isPresentingQuizDatabase = true }
                .background(GeometryReader { g in
                    Color.clear.preference(key: ViewPositionKey.self, value: [g.frame(in: .global)])
                })

                categoryButton(
                    title: "ストラテジ",
                    subtitle: "経営戦略・業務分析",
                    icon: "chart.line.uptrend.xyaxis",
                    gradient: LinearGradient(
                        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.2
                ) { isPresentingQuizIntermediate = true }

                categoryButton(
                    title: "マネジメント",
                    subtitle: "プロジェクト・サービス管理",
                    icon: "person.3.fill",
                    gradient: LinearGradient(
                        colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.25
                ) { isPresentingQuizAdvanced = true }

                categoryButton(
                    title: "テクノロジ",
                    subtitle: "開発技術・ネットワーク・DB",
                    icon: "cpu.fill",
                    gradient: LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.3
                ) { isPresentingQuizGod = true }
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
        .buttonStyle(.plain)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: animateCards)
    }

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

    private var rewardButton: some View {
        Button(action: {
            generateHapticFeedback()
            reward.ExAndMoReward()
        }) {
            ZStack {
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

                    VStack(spacing: 2) {
                        Text("×2")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("報酬")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .buttonStyle(.plain)
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

    private var tutorialOverlay: some View {
        ZStack {
            GeometryReader { _ in
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

            VStack {
                Spacer().frame(height: buttonRect.minY + bubbleHeight)

                Text("「基礎理解」をタップしてください")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 10)
                    .background(GeometryReader { g in
                        Color.clear.onAppear { bubbleHeight = g.size.height }
                    })

                Spacer()
            }
            .padding(.horizontal, 20)

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
            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { _ in }
        }
    }

    private var swipeBackGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width > 80 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }

    private func setupView() {
        reward.LoadReward()

        if let uid = authManager.currentUserId {
            fetchNumberOfIncorrectAnswers(userId: uid) { count in
                DispatchQueue.main.async {
                    self.incorrectCount = count
                    self.isIncorrectAnswersEmpty = (count == 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isLoading = false
                }
            }
        }

        authManager.fetchUserInfo { (_, _, _, _, _, tutorialNum) in
            if let t = tutorialNum { self.tutorialNum = t }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateCards = true
        }
    }

}

#Preview {
    AppliedManagerListView(isPresenting: .constant(false))
}
