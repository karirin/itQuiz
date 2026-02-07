//
//  GachaManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/10.
//

import SwiftUI
import AVFoundation

struct GachaManagerView: View {
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
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    // アニメーション用
    @State private var appearAnimation: Bool = false
    @State private var selectedGacha: Int? = nil
    @State private var shimmerOffset: CGFloat = -200
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }
    
    // ガチャデータ
    let gachaItems: [(image: String, cost: Int, rarity: String, gradient: [Color])] = [
        ("レギュラーガチャ", 300, "基本のガチャ！毎日挑戦しよう", [Color(hex: "4ECDC4"), Color(hex: "44A08D")]),
        ("幸福ガチャ", 600, "幸運のキャラが手に入るかも？", [Color(hex: "FF6B6B"), Color(hex: "C94B4B")]),
        ("メカガチャ", 600, "最新メカキャラが登場！", [Color(hex: "667eea"), Color(hex: "764ba2")])
    ]

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(hex: "1a1a2e"),
                    Color(hex: "16213e"),
                    Color(hex: "0f3460")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 背景パーティクル
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 1)
                }
            }
            
            VStack(spacing: 0) {
                // ヘッダー
                headerView
                
                // ガチャリスト
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(Array(gachaItems.enumerated()), id: \.offset) { index, item in
                            GachaCardView(
                                imageName: item.image,
                                cost: item.cost,
                                rarity: item.rarity,
                                gradientColors: item.gradient,
                                isSelected: selectedGacha == index,
                                shimmerOffset: shimmerOffset
                            ) {
                                generateHapticFeedback()
                                audioManager.playSound()
                                withAnimation(.spring(response: 0.3)) {
                                    selectedGacha = index
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    switch index {
                                    case 0: isPresentingQuizBeginner = true
                                    case 1: isPresentingQuizIntermediate = true
                                    case 2: isPresentingQuizAdvanced = true
                                    default: break
                                    }
                                }
                            }
                            .offset(y: appearAnimation ? 0 : 50)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: appearAnimation
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            
            // ナビゲーションリンク
            NavigationLink("", destination: GachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner)
            NavigationLink("", destination: RareGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate)
            NavigationLink("", destination: MekaGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)
        }
        .onAppear {
            setupOnAppear()
            withAnimation {
                appearAnimation = true
            }
            // シマーアニメーション
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
        .onChange(of: isPresentingQuizBeginner) { newValue in
            if !newValue { selectedGacha = nil }
        }
        .onChange(of: isPresentingQuizIntermediate) { newValue in
            if !newValue { selectedGacha = nil }
        }
        .onChange(of: isPresentingQuizAdvanced) { newValue in
            if !newValue { selectedGacha = nil }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                generateHapticFeedback()
                audioManager.playCancelSound()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("戻る")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
            }
            
            Spacer()
            
            Text("ガチャ")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // バランス用の透明ボタン
            Color.clear
                .frame(width: 70, height: 36)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Coin Display
    private var coinDisplayView: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "FFD700"))
            
            Text("\(authManager.money)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("コイン")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Setup
    private func setupOnAppear() {
        if let userId = authManager.currentUserId {
            authManager.fetchLastClickedDate(userId: userId) { date in
                if let unwrappedDate = date {
                    lastClickedDate = unwrappedDate
                    let calendar = Calendar.current
                    if calendar.isDateInToday(unwrappedDate) {
                        isButtonEnabled = false
                    }
                } else {
                    print("lastClickedDate is nil")
                }
            }
        }
        isIntermediateQuizActive = authManager.level >= 10
        if let soundURL = Bundle.main.url(forResource: "soundKettei", withExtension: "mp3") {
            do {
                audioPlayerKettei = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
        if audioManager.isMuted {
            audioPlayerKettei?.volume = 0
        } else {
            audioPlayerKettei?.volume = 1.0
        }
    }
}

// MARK: - Gacha Card View
struct GachaCardView: View {
    let imageName: String
    let cost: Int
    let rarity: String
    let gradientColors: [Color]
    let isSelected: Bool
    let shimmerOffset: CGFloat
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // メイン画像エリア
                ZStack {
                    // 背景グラデーション
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // シマーエフェクト
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    
                    // ガチャ画像
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .frame(height: 120)
                
                // 情報エリア
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // レアリティバッジ
                        Text(rarity)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(rarityColor)
                            )
                    }
                    
                    Spacer()
                    
                    // コスト表示
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "FFD700"))
                        
                        Text("\(cost)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.2))
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: gradientColors[0].opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(GachaButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var rarityColor: Color {
        switch rarity {
        case "ノーマル": return Color(hex: "4ECDC4")
        case "レア": return Color(hex: "FF6B6B")
        case "スーパーレア": return Color(hex: "667eea")
        default: return Color.gray
        }
    }
}

// MARK: - Button Style
struct GachaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GachaManagerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GachaManagerView(isPresenting: .constant(false))
        }
    }
}
