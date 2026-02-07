import SwiftUI
import StoreKit
import Combine

// MARK: - Premium Hero Image
// この画像をAssets.xcassetsに「PremiumHeroBanner」という名前で追加してください
// 添付の「学習効率アップ プレミアムプラン」の画像を使用

struct Feature: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Compact Feature Card (横スクロール用)
struct CompactFeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [feature.color, feature.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: feature.imageName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(feature.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            Text(feature.description)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Plan Selection Card
struct PlanSelectionCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var periodUnit: Product.SubscriptionPeriod.Unit? {
        product.subscription?.subscriptionPeriod.unit
    }
    
    private var labelInfo: (text: String, colors: [Color], icon: String)? {
        guard let unit = periodUnit else { return nil }
        switch unit {
        case .week:
            return ("お試し", [Color.teal, Color.green], "leaf.fill")
        case .month:
            return ("人気", [Color.blue, Color.purple], "heart.fill")
        case .year:
            return ("最もお得", [Color.orange, Color.red], "star.fill")
        default:
            return ("お試し", [Color.teal, Color.green], "leaf.fill")
        }
    }
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            onSelect()
        }) {
            HStack(spacing: 14) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ?
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                            lineWidth: isSelected ? 3 : 2
                        )
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 16, height: 16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(planLabel)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let label = labelInfo {
                            HStack(spacing: 3) {
                                Image(systemName: label.icon)
                                    .font(.system(size: 9))
                                Text(label.text)
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(LinearGradient(colors: label.colors, startPoint: .leading, endPoint: .trailing))
                            )
                        }
                    }
                    
                    Text(savingsText)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(formattedPrice)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("円")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Text(periodText)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Color(hex: "4A3728").opacity(0.9), Color(hex: "2D1F14").opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.black.opacity(0.5), Color.black.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        LinearGradient(colors: [.yellow, .orange, .yellow.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(color: isSelected ? .orange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var planLabel: String {
        guard let unit = periodUnit else { return "プラン" }
        switch unit {
        case .week: return "週間プラン"
        case .month: return "月額プラン"
        case .year: return "年額プラン"
        default: return "週間プラン"
        }
    }
    
    private var periodText: String {
        guard let unit = periodUnit else { return "" }
        switch unit {
        case .week: return "/週"
        case .month: return "/月"
        case .year: return "/年"
        default: return "/週"
        }
    }
    
    private var savingsText: String {
        guard let unit = periodUnit else { return "" }
        switch unit {
        case .week: return "まずは1週間から"
        case .month: return "週間プランの50%オフ"
        case .year: return "月払いの2ヶ月分が無料"
        default: return "まずは1週間から"
        }
    }
    
    private var formattedPrice: String {
        let price = product.displayPrice
        let numericPrice = price.filter { "0123456789".contains($0) }
        
        if let value = Int(numericPrice) {
            let actualPrice: Int
            switch value {
            case 10: actualPrice = 980
            case 98: actualPrice = 9800
            case 5: actualPrice = 480
            default: actualPrice = value
            }
            return "\(actualPrice)"
        }
        return price.replacingOccurrences(of: "¥", with: "")
    }
}

// MARK: - Main PreView
struct PreView: View {
    @State private var selectedProduct: Product? = nil
    @State private var hasSetDefaultProduct = false
    @StateObject private var viewModel = SubscriptionViewModel()
    @StateObject var appState = AppState()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager: AudioManager
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var animateGlow = false
    
    let features: [Feature] = [
        Feature(
            imageName: "rectangle.badge.xmark",
            title: "広告非表示",
            description: "ホーム画面やダンジョン後の広告が非表示に",
            color: .red
        ),
        Feature(
            imageName: "chart.bar.fill",
            title: "グラフ機能",
            description: "毎日の回答数や正答率をグラフで確認",
            color: .blue
        ),
        Feature(
            imageName: "arrow.counterclockwise.circle.fill",
            title: "復習機能",
            description: "間違えた問題をもう一度解き直し",
            color: .purple
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient matching the hero image
                LinearGradient(
                    colors: [
                        Color(hex: "87CEEB"), // Sky blue
                        Color(hex: "98D982"), // Light green
                        Color(hex: "7CB342")  // Green field
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack(spacing: 0){
                    HStack{
                        
                        // Back button overlay
                        Button(action: {
                            generateHapticFeedback()
                            presentationMode.wrappedValue.dismiss()
                            audioManager.playCancelSound()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                Text("戻る")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.5))
                                    .background(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.leading, 16)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Hero Image - 添付画像を使用
                            // Assets.xcassetsに「PremiumHeroBanner」として追加してください
                            Image("PremiumHeroBanner")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                            
                            // MARK: - Main Content Card
                            VStack(spacing: 16) {
                                // Premium Features Section - 横スクロール
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .foregroundStyle(
                                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                                            )
                                            .font(.system(size: 16))
                                        
                                        Text("プレミアム特典")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(features) { feature in
                                                CompactFeatureCard(feature: feature)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                                .padding(.top, 16)
                                
                                // Divider
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.3), .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                                
                                // MARK: - Plan Selection
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("プランを選択")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                    
                                    if viewModel.products.isEmpty {
                                        // Loading state
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("読み込み中...")
                                                .foregroundColor(.white.opacity(0.7))
                                            Spacer()
                                        }
                                        .padding(.vertical, 30)
                                    } else {
                                        ForEach(sortedProducts(), id: \.id) { product in
                                            PlanSelectionCard(
                                                product: product,
                                                isSelected: selectedProduct?.id == product.id
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedProduct = product
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // MARK: - Subscribe Button
                                Button(action: {
                                    guard let product = selectedProduct else { return }
                                    Task {
                                        do {
                                            try await AppStore.sync()
                                            try await viewModel.purchaseProduct(product, showAlert: $showAlert)
                                            appState.isBannerVisible = false
                                            alertMessage = "広告非表示の反映に少しお時間がかかる場合がございます。\nご了承ください"
                                        } catch StoreKitError.userCancelled {
                                            print("StoreKitError.userCancelled")
                                        } catch {
                                            print("購入処理中にエラーが発生しました: \(error)")
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 18))
                                        
                                        VStack(spacing: 2) {
                                            Text("プレミアムプランに登録")
                                                .font(.system(size: 17, weight: .bold))
                                            Text("いつでも解約できます")
                                                .font(.system(size: 11))
                                                .opacity(0.8)
                                        }
                                    }
                                    .foregroundColor(Color(hex: "2D1F14"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .orange.opacity(0.5), radius: animateGlow ? 12 : 6, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(selectedProduct == nil)
                                .opacity(selectedProduct == nil ? 0.6 : 1)
                                .padding(.top, 8)
                                
                                // MARK: - Footer Links
                                VStack(spacing: 10) {
                                    HStack(spacing: 4) {
                                        Text("購入復元は")
                                            .foregroundColor(.white.opacity(0.7))
                                        Button("こちら") {
                                            Task {
                                                do {
                                                    try await AppStore.sync()
                                                } catch {
                                                    print("購入処理中にエラーが発生しました: \(error)")
                                                }
                                            }
                                        }
                                        .foregroundColor(.cyan)
                                        Text("・解約は")
                                            .foregroundColor(.white.opacity(0.7))
                                        NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                                            Text("こちら")
                                                .foregroundColor(.cyan)
                                        }
                                    }
                                    .font(.system(size: 13))
                                    
                                    HStack(spacing: 16) {
                                        NavigationLink(destination: TermsOfServiceView()) {
                                            Text("利用規約")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Text("・")
                                            .foregroundColor(.white.opacity(0.4))
                                        
                                        NavigationLink(destination: PrivacyView()) {
                                            Text("プライバシーポリシー")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    .font(.system(size: 12))
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 30)
                            }
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "1A1A2E").opacity(0.95),
                                                Color(hex: "16213E").opacity(0.98)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                            )
                            .offset(y: -20)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("プレミアムプラン登録ありがとうございます！"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Glow animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
            
            // Load products
            Task {
                await viewModel.loadProducts()
                await MainActor.run {
                    if let weeklyProduct = viewModel.products.first(where: {
                        $0.subscription?.subscriptionPeriod.unit == .week
                    }) {
                        selectedProduct = weeklyProduct
                    } else {
                        selectedProduct = viewModel.products.first
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    private func sortedProducts() -> [Product] {
        return viewModel.products.sorted { product1, product2 in
            let order: [Product.SubscriptionPeriod.Unit: Int] = [
                .week: 0,
                .month: 1,
                .year: 2
            ]
            
            let unit1 = product1.subscription?.subscriptionPeriod.unit
            let unit2 = product2.subscription?.subscriptionPeriod.unit
            
            let priority1 = order[unit1 ?? .day] ?? 0
            let priority2 = order[unit2 ?? .day] ?? 0
            
            return priority1 < priority2
        }
    }
}

// MARK: - Preview
struct PreView_Previews: PreviewProvider {
    static var previews: some View {
        PreView(audioManager: AudioManager())
    }
}
