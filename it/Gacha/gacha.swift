////
////  gacha.swift
////  it
////
////  Created by Apple on 2025/12/08.
////
//
//import SwiftUI
//
//// MARK: - 1. データモデル
//enum gachaRarity: String, CaseIterable {
//    case common = "N"
//    case rare = "R"
//    case superRare = "SR"
//    case ultraRare = "SSR"
//    
//    var color: Color {
//        switch self {
//        case .common: return .blue
//        case .rare: return .green
//        case .superRare: return .orange
//        case .ultraRare: return .pink
//        }
//    }
//    
//    var title: String {
//        switch self {
//        case .common: return "ノーマル"
//        case .rare: return "レア"
//        case .superRare: return "スーパーレア"
//        case .ultraRare: return "ウルトラレア"
//        }
//    }
//}
//
//struct testGachaItem: Identifiable {
//    let id = UUID()
//    let name: String
//    let rarity: gachaRarity
//    let imageName: String // SF Symbolsの名前を使用
//}
//
//// MARK: - 2. メインビュー
//struct testGachaView: View {
//    // 状態管理
//    @State private var isAnimating = false
//    @State private var showResult = false
//    @State private var currentItem: testGachaItem?
//    @State private var capsuleOffset: CGFloat = -300
//    @State private var machineShakeAmount: CGFloat = 0
//    
//    // ガチャの中身リスト
//    let items: [testGachaItem] = [
//        testGachaItem(name: "木の剣", rarity: .common, imageName: "pencil"),
//        testGachaItem(name: "鉄の盾", rarity: .common, imageName: "shield"),
//        testGachaItem(name: "魔法の薬", rarity: .rare, imageName: "flask"),
//        testGachaItem(name: "黄金の王冠", rarity: .superRare, imageName: "crown"),
//        testGachaItem(name: "伝説のドラゴン", rarity: .ultraRare, imageName: "flame.fill")
//    ]
//    
//    var body: some View {
//        ZStack {
//            // 背景
//            Color(hex: "1a1a2e").ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                // タイトル
//                Text("MYSTIC GACHA")
//                    .font(.system(size: 28, weight: .heavy, design: .rounded))
//                    .foregroundStyle(
//                        LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing)
//                    )
//                    .padding(.top, 40)
//                
//                Spacer()
//                
//                // ガチャマシンの本体
//                ZStack {
//                    // マシンのドーム（透明部分）
//                    Circle()
//                        .fill(.ultraThinMaterial)
//                        .frame(width: 260, height: 260)
//                        .overlay(
//                            Circle().stroke(.white.opacity(0.3), lineWidth: 2)
//                        )
//                    
//                    // 中のカプセルたち（装飾用）
//                    ForEach(0..<6) { i in
//                        CapsuleIconView(color: gachaRarity.allCases.randomElement()!.color, size: 40)
//                            .offset(x: CGFloat.random(in: -60...60), y: CGFloat.random(in: -60...60))
//                            .opacity(0.8)
//                    }
//                    
//                    // 落ちてくるカプセル（アニメーション用）
//                    if isAnimating {
//                        CapsuleIconView(color: currentItem?.rarity.color ?? .gray, size: 80)
//                            .offset(y: capsuleOffset)
//                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
//                    }
//                }
//                .offset(x: machineShakeAmount) // 揺れるアニメーション
//                
//                Spacer()
//                
//                // ガチャボタン
//                Button(action: pullGacha) {
//                    Text("PULL GACHA")
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(
//                            LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
//                        )
//                        .cornerRadius(16)
//                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
//                }
//                .padding(.horizontal, 40)
//                .padding(.bottom, 40)
//                .disabled(isAnimating) // アニメーション中は無効化
//            }
//            
//            // 結果表示オーバーレイ
//            if showResult, let item = currentItem {
//                ResultOverlayView(item: item) {
//                    withAnimation(.spring()) {
//                        showResult = false
//                        capsuleOffset = -300 // カプセル位置リセット
//                    }
//                }
//                .transition(.scale.combined(with: .opacity))
//                .zIndex(100)
//            }
//        }
//    }
//    
//    // ガチャを引くロジック
//    func pullGacha() {
//        // 1. 抽選
//        let randomItem = items.randomElement()!
//        currentItem = randomItem
//        
//        // 2. アニメーション開始
//        isAnimating = true
//        HapticManager.impact(style: .medium)
//        
//        // マシンを揺らす
//        withAnimation(.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
//            machineShakeAmount = 5
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            machineShakeAmount = 0
//            
//            // カプセルが落ちてくる
//            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
//                capsuleOffset = 150
//            }
//            
//            // 結果表示
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                HapticManager.notification(type: .success)
//                withAnimation(.spring()) {
//                    showResult = true
//                    isAnimating = false
//                }
//            }
//        }
//    }
//}
//
//// MARK: - 3. サブビュー（デザインパーツ）
//
//// カプセルの見た目
//struct CapsuleIconView: View {
//    let color: Color
//    let size: CGFloat
//    
//    var body: some View {
//        ZStack {
//            // 球体
//            Circle()
//                .fill(
//                    RadialGradient(colors: [.white, color], center: .topLeading, startRadius: size/4, endRadius: size)
//                )
//                .frame(width: size, height: size)
//            
//            // カプセルの継ぎ目
//            Rectangle()
//                .fill(.black.opacity(0.1))
//                .frame(width: size, height: 2)
//            
//            // ハイライト
//            Circle()
//                .fill(.white.opacity(0.6))
//                .frame(width: size * 0.3, height: size * 0.2)
//                .offset(x: -size * 0.25, y: -size * 0.25)
//                .rotationEffect(.degrees(-45))
//        }
//    }
//}
//
//// 結果表示画面
//struct ResultOverlayView: View {
//    let item: testGachaItem
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        ZStack {
//            // 背景のボカシ
//            Color.black.opacity(0.7).ignoresSafeArea()
//                .onTapGesture(perform: onDismiss)
//            
//            VStack(spacing: 20) {
//                // 光のエフェクト（レア度が高いと派手になる）
//                ZStack {
//                    if item.rarity == .ultraRare || item.rarity == .superRare {
//                        ForEach(0..<2) { _ in
//                            Circle()
//                                .fill(item.rarity.color.opacity(0.3))
//                                .frame(width: 200, height: 200)
//                                .blur(radius: 20)
//                        }
//                        
//                        // キラキラ回転
//                        Image(systemName: "sparkles")
//                            .font(.system(size: 60))
//                            .foregroundStyle(.yellow)
//                            .offset(x: 80, y: -80)
//                    }
//                    
//                    // アイコン表示
//                    Circle()
//                        .fill(LinearGradient(colors: [.white, item.rarity.color.opacity(0.2)], startPoint: .top, endPoint: .bottom))
//                        .frame(width: 140, height: 140)
//                        .overlay(
//                            Image(systemName: item.imageName)
//                                .font(.system(size: 60))
//                                .foregroundStyle(item.rarity.color)
//                        )
//                        .overlay(
//                            Circle().stroke(item.rarity.color, lineWidth: 4)
//                        )
//                }
//                
//                VStack(spacing: 8) {
//                    Text(item.rarity.rawValue)
//                        .font(.title3.bold())
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 4)
//                        .background(item.rarity.color)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    
//                    Text(item.name)
//                        .font(.largeTitle.bold())
//                        .foregroundColor(.white)
//                }
//                
//                Button(action: onDismiss) {
//                    Text("閉じる")
//                        .font(.headline)
//                        .padding(.horizontal, 40)
//                        .padding(.vertical, 12)
//                        .background(Color.white)
//                        .foregroundColor(.black)
//                        .cornerRadius(25)
//                }
//                .padding(.top, 20)
//            }
//            .padding(40)
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(Color(hex: "252540"))
//                    .shadow(color: item.rarity.color.opacity(0.6), radius: 30, x: 0, y: 0)
//            )
//        }
//    }
//}
//
//// MARK: - 4. ユーティリティ
//struct HapticManager {
//    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
//        let generator = UIImpactFeedbackGenerator(style: style)
//        generator.impactOccurred()
//    }
//    
//    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(type)
//    }
//}
//
//// Color Hex拡張
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//// プレビュー
//#Preview {
//    testGachaView()
//}
