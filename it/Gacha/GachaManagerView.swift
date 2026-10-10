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
    @State private var isPresentingQuizGuardian: Bool = false
    @State private var isPresentingDeepSeaGacha: Bool = false
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
    @State private var userMoney: Int? = nil

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }

    // ガチャデータ
    let gachaItems: [(image: String, cost: Int, rarity: String, gradient: [Color])] = GachaTheme.lineup.map {
        ($0.title, $0.cost, $0.description, $0.themeColors)
    }

    /// 一覧用のテーマ別マスコット画像。
    private var mascotImageNames: [String] { GachaTheme.mascotImageNames }

    private var pickupIndex: Int {
        min(max(GachaTheme.pickupIndex, 0), gachaItems.count - 1)
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                // ヘッダー
                headerView

                // ガチャリスト
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        let pickup = gachaItems[pickupIndex]
                        GachaPickupHeroCard(
                            title: pickup.image,
                            description: pickup.rarity,
                            cost: pickup.cost,
                            imageName: mascotImageNames[pickupIndex],
                            isSelected: selectedGacha == pickupIndex
                        ) {
                            openGacha(pickupIndex)
                        }
                        .modifier(GachaAppearModifier(isVisible: appearAnimation, order: 0))

                        sectionHeading
                            .padding(.top, 14)
                            .modifier(GachaAppearModifier(isVisible: appearAnimation, order: 1))

                        ForEach(Array(regularIndices.enumerated()), id: \.element) { order, index in
                            let item = gachaItems[index]
                            GachaCardView(
                                imageName: item.image,
                                cost: item.cost,
                                rarity: item.rarity,
                                gradientColors: item.gradient,
                                isSelected: selectedGacha == index,
                                shimmerOffset: shimmerOffset,
                                thumbnailImageName: mascotImageNames[index]
                            ) {
                                openGacha(index)
                            }
                            .modifier(GachaAppearModifier(isVisible: appearAnimation, order: order + 2))
                        }
                    }
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                    .frame(maxWidth: .infinity)
                }
            }

            // ナビゲーションリンク
            NavigationLink("", destination: GachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner)
            NavigationLink("", destination: RareGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate)
            NavigationLink("", destination: MekaGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)
            NavigationLink("", destination: GodGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizGod)
            NavigationLink("", destination: GuardianGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizGuardian)
            NavigationLink("", destination: DeepSeaGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingDeepSeaGacha)
        }
        .onAppear {
            setupOnAppear()
            withAnimation {
                appearAnimation = true
            }
            #if DEBUG
            GachaFont.logRegisteredFonts()
            #endif
        }
        .onChange(of: isPresentingQuizBeginner) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
        }
        .onChange(of: isPresentingQuizIntermediate) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
        }
        .onChange(of: isPresentingQuizAdvanced) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
        }
        .onChange(of: isPresentingQuizGod) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
        }
        .onChange(of: isPresentingQuizGuardian) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
        }
        .onChange(of: isPresentingDeepSeaGacha) { newValue in
            if !newValue {
                selectedGacha = nil
                refreshCoinBalance()
            }
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

    private var regularIndices: [Int] {
        gachaItems.indices.filter { $0 != pickupIndex }
    }

    private func openGacha(_ index: Int) {
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
            case 3: isPresentingQuizGod = true
            case 4: isPresentingQuizGuardian = true
            case 5: isPresentingDeepSeaGacha = true
            default: break
            }
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack(alignment: .top) {
            GachaTheme.background

            GachaDiagonalPattern()

            GachaRadialGlow(opacity: 0.16, radius: 320)
                .frame(height: 400)
                .offset(y: -120)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            HStack(spacing: 10) {
                GachaGoldRule(width: 18)
                Text("ガチャ")
                    .font(GachaFont.display(22, relativeTo: .title2))
                    .tracking(GachaFont.tracking(22))
                    .foregroundColor(GachaTheme.goldLight)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                GachaGoldRule(width: 18)
            }

            HStack {
                GachaBackPill {
                    generateHapticFeedback()
                    audioManager.playCancelSound()
                    presentationMode.wrappedValue.dismiss()
                }

                Spacer()

                GachaCoinPill(amount: userMoney)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private var sectionHeading: some View {
        HStack(spacing: 10) {
            Text("ガチャ")
                .font(GachaFont.display(15, relativeTo: .headline))
                .tracking(GachaFont.tracking(15))
                .foregroundColor(GachaTheme.goldLight)
                .accessibilityAddTraits(.isHeader)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [GachaTheme.gold.opacity(0.6), GachaTheme.gold.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Setup
    private func setupOnAppear() {
        refreshCoinBalance()

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

    private func refreshCoinBalance() {
        authManager.getUserMoney { money in
            DispatchQueue.main.async {
                userMoney = money
            }
        }
    }
}

/// 表示時に時間差で下からフェードイン（Reduce Motion のときはフェードのみ）。
private struct GachaAppearModifier: ViewModifier {
    let isVisible: Bool
    let order: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible || reduceMotion ? 0 : 50)
            .opacity(isVisible ? 1 : 0)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.2)
                    : .spring(response: 0.6, dampingFraction: 0.8).delay(Double(order) * 0.1),
                value: isVisible
            )
    }
}

// MARK: - Pickup Hero Card
struct GachaPickupHeroCard: View {
    let title: String
    let description: String
    let cost: Int
    let imageName: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                // 背景
                GachaTheme.heroGradient

                GachaRadialGlow(opacity: 0.3, radius: 150)
                    .offset(x: 90)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // キャラ画像
                HStack {
                    Spacer(minLength: 0)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 210)
                        .shadow(color: GachaTheme.gold.opacity(0.35), radius: 16, x: 0, y: 6)
                        .gachaFloating(amplitude: 5, period: 4)
                        .offset(x: 18)
                        .accessibilityHidden(true)
                }

                // テキスト
                VStack(alignment: .leading, spacing: 8) {
                    GachaTag(text: "PICK UP")

                    Text(title)
                        .font(GachaFont.display(36, relativeTo: .largeTitle))
                        .tracking(GachaFont.tracking(36))
                        .foregroundColor(GachaTheme.goldHighlight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .gachaGoldTextGlow()

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(GachaTheme.text.opacity(0.85))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        GachaCoinIcon(size: 20)
                            .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 6 }
                        Text(cost.formatted())
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(GachaTheme.goldLight)
                        Text("/ 1回")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GachaTheme.textMuted)
                    }
                }
                .padding(.leading, 20)
                .padding(.vertical, 20)
                .frame(maxWidth: 210, maxHeight: .infinity, alignment: .topLeading)

                GachaShineSweep(period: 3.6, intensity: 0.12)
            }
            .frame(height: 236)
            .clipShape(RoundedRectangle(cornerRadius: GachaTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .stroke(GachaTheme.gold, lineWidth: 1)
            )
            .overlay(
                GachaCornerBrackets(length: 14)
                    .stroke(GachaTheme.goldLight, style: StrokeStyle(lineWidth: 2, lineCap: .square))
                    .padding(6)
            )
            // 外側に 4pt 空けた細枠
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius + 4)
                    .stroke(GachaTheme.line, lineWidth: 1)
            )
            .shadow(color: GachaTheme.glow, radius: 20, x: 0, y: 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(GachaButtonStyle())
        .scaleEffect(isSelected ? 0.97 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("ピックアップ \(title)、\(description)、1回\(cost)コイン")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Gacha Card View
/// ガチャ一覧の行カード。
struct GachaCardView: View {
    let imageName: String
    let cost: Int
    /// ガチャの説明文（呼び出し側の互換のため名前は rarity のまま）
    let rarity: String
    let gradientColors: [Color]
    let isSelected: Bool
    let shimmerOffset: CGFloat
    /// サムネに使う画像。nil ならガチャ画像（imageName）を使う。
    var thumbnailImageName: String? = nil
    let action: () -> Void

    private var themeColor: Color { gradientColors.first ?? GachaTheme.gold }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                thumbnail

                VStack(alignment: .leading, spacing: 5) {
                    Text(imageName)
                        .font(GachaFont.display(17, relativeTo: .headline))
                        .tracking(GachaFont.tracking(17))
                        .foregroundColor(GachaTheme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(rarity)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(GachaTheme.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 4)

                HStack(spacing: 4) {
                    GachaCoinIcon(size: 16)
                    Text(cost.formatted())
                        .font(.system(size: 15, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(GachaTheme.goldLight)
                }
                .fixedSize()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(GachaTheme.gold.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.trailing, 4)
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .background(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .fill(GachaTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                    .stroke(GachaTheme.gold.opacity(isSelected ? 0.8 : 0.28), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(GachaButtonStyle())
        .scaleEffect(isSelected ? 0.97 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(imageName)、\(rarity)、1回\(cost)コイン")
        .accessibilityAddTraits(.isButton)
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                .fill(GachaTheme.background)

            RadialGradient(
                colors: [themeColor.opacity(0.55), themeColor.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: 36
            )

            Image(thumbnailImageName ?? imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: GachaTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)
                .stroke(themeColor.opacity(0.6), lineWidth: 1)
        )
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
        .previewDisplayName("ガチャ一覧")

        NavigationView {
            GachaManagerView(isPresenting: .constant(false))
        }
        .previewDevice("iPhone SE (3rd generation)")
        .previewDisplayName("ガチャ一覧（375pt）")
    }
}
