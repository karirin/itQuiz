import SwiftUI
import StoreKit
import Combine

struct Feature: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct FeatureView: View {
    let feature: Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(feature.title)
                .resizable()
                .frame(height:120)
            HStack {
                    Spacer()
                    Image(systemName: feature.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(feature.title)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
            }
            .padding(.horizontal)
            Text(feature.description)
//                .font(.system(size: isSmallDevice() ? 12 : 18))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom)
                .padding(.horizontal)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        )
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PreView: View {
    @State private var selectedProduct: Product? = nil
    @State private var hasSetDefaultProduct = false
    @StateObject private var viewModel = SubscriptionViewModel()
    @StateObject var appState = AppState()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager: AudioManager
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentIndex = 0
    @State private var timer: Timer? = nil
    
    let features: [Feature] = [
        Feature(imageName: "rectangle.badge.xmark",
                title: "広告非表示",
                description: "ホーム画面やダンジョンが終わった後の広告が非表示になります。"),
        Feature(imageName: "chart.bar",
                title: "グラフ機能追加",
                description: "毎日の回答数や問題分野ごとの正答率をグラフで確認することができます。"),
        Feature(imageName: "questionmark.circle",
                title: "復習機能",
                description: "１度間違えた問題をもう１度解くことができます。\n"),
        Feature(imageName: "rectangle.badge.xmark",
                title: "広告非表示",
                description: "ホーム画面やダンジョンが終わった後の広告が非表示になります。")
        
    ]
    
    var body: some View {
        NavigationView {
            ZStack{
                if isSmallDevice() {
                    Image("プレミアムプラン背景SE")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Image("プレミアムプラン背景")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
                VStack {
                    // ヘッダー
                    HStack {
                        Button(action: { 
                        generateHapticFeedback()
                            self.presentationMode.wrappedValue.dismiss()
                            audioManager.playCancelSound()
                        }) {
                            Image(systemName: "chevron.left")
//                                .foregroundColor(Color("fontGray"))
                            Text("戻る")
//                                .foregroundColor(Color("fontGray"))
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(30)
                        .padding(.leading).buttonStyle(.plain)
                        Spacer()
//                        Text("プレミアムプラン")
//                            .font(.headline)
                        Spacer()
                        // レイアウトの対称性を保つために非表示のボタン
                        Button(action: { 
                        generateHapticFeedback()
                            self.presentationMode.wrappedValue.dismiss()
                            audioManager.playCancelSound()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("fontGray"))
                            Text("戻る")
                                .foregroundColor(Color("fontGray"))
                        }
                        .padding(.leading)
                        .opacity(0)
                    }
//                    .padding(.top,10)
//                    .padding(.bottom, -10)
                    // ScrollView のコンテンツ
                    ScrollView {
                        VStack{
                            Image("プレミアムプランタイトル")
                                .resizable()
                                .scaledToFit()
                                .padding(.bottom, -70)
                                .zIndex(1)
                            ZStack{
                                //                            HStack{
                                Image("プレミアムプランロック")
                                    .resizable()
                                //                                    .scaledToFit()
                                    .frame(height: 350)
                                    .padding(.leading, -150)
                                Image("プレミアムプランライム")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 170)
                                    .padding(.trailing, -200)
                                    .padding(.leading, 60)
                                    .padding(.bottom, -30)
                                Image("プレミアムプランエフェクト")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top, -200)
                                    .padding(.leading, -30)
                                //                            }
                            }.padding(.bottom,isSmallDevice() ? -100 : -70 )
                        }
                        // キャッチフレーズ
//                        HStack{
//                            Spacer()
//                            VStack(spacing: 5) {
//                                Text("飲み物1本で")
//                                HStack {
//                                    Text("アプリでの学習効率アップ")
//                                    Image(systemName: "arrow.up.forward")
//                                        .padding(.leading, -10)
//                                }
//                            }
//                            Spacer()
//                        }
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .background(Color.black.opacity(0.7))
                        
                        // 料金比較
                        HStack {
                            Spacer()
                            Text("　　　　　       ")
                            Spacer()
                            Text("通常")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                            Spacer()
                            Spacer()
                            Spacer()
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.red)
                                .padding(.trailing, -5)
                                .padding(.bottom, 2)
                            Text("プレミアム")
                                .font(.system(size: isSmallDevice() ? 16 : 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                        // 特徴の比較
                        VStack {
                            HStack {
                                Text("広告非表示")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                HStack{
                                    Spacer()
                                    Image(systemName: "xmark")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                HStack{
                                    Spacer()
                                    Image(systemName: "circle")
                                        .foregroundStyle(.red)
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            Rectangle()
                              .frame(height: 1)
                              .foregroundColor(Color.white)
                            HStack {
                                Text("グラフ機能")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                HStack{
                                    Spacer()
                                    Image(systemName: "xmark")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                HStack{
                                    Spacer()
                                    Image(systemName: "circle")
                                        .foregroundStyle(.red)
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                            Rectangle()
                              .frame(height: 1)
                              .foregroundColor(Color.white)
                            
                            HStack {
                                Text("復習機能　")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                HStack{
                                    Spacer()
                                    Image(systemName: "xmark")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                HStack{
                                    Spacer()
                                    Image(systemName: "circle")
                                        .foregroundStyle(.red)
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        // 自動スクロール付きカルーセルセクション
                        TabView(selection: $currentIndex) {
                            ForEach(Array(features.enumerated()), id: \.1.id) { index, feature in
                                FeatureView(feature: feature)
                                    .frame(width: UIScreen.main.bounds.width * 0.9,height: 220)
                                    .padding(.horizontal, 10)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 230)
                        .onAppear {
                            startTimer()
                        }
                        .onDisappear {
                            stopTimer()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { _ in
                                    stopTimer()
                                }
                                .onEnded { _ in
                                    startTimer()
                                }
                        )
                        
                        // ページインジケーターの追加
                        HStack(spacing: 8) {
                            ForEach(0..<features.count-1, id: \.self) { index in
                                Circle()
                                    .fill(index == (currentIndex == features.count - 1 ? 0 : currentIndex) ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
                            }
                        }.padding(.bottom)
                        
                        // 週 / 月 / 年 のプラン選択ボタン
                        if !viewModel.products.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(sortedProducts(), id: \.id) { product in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedProduct = product
                                        }
                                        generateHapticFeedback()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 8) {
                                                // プラン名とラベル
                                                HStack(spacing: 8) {
                                                    Text(planLabel(for: product) + "プラン")
                                                        .font(.system(size: 20))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                    
                                                    // ラベル表示
                                                    if let period = product.subscription?.subscriptionPeriod {
                                                        Group {
                                                            switch period.unit {
                                                            case .week:
                                                                Text("お試しに最適")
                                                                    .font(.system(size: 11))
                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(.white)
                                                                    .padding(.horizontal, 10)
                                                                    .padding(.vertical, 4)
                                                                    .background(
                                                                        Capsule()
                                                                            .fill(
                                                                                LinearGradient(
                                                                                    gradient: Gradient(colors: [Color.green, Color.teal]),
                                                                                    startPoint: .leading,
                                                                                    endPoint: .trailing
                                                                                )
                                                                            )
                                                                    )
                                                            case .month:
                                                                HStack(spacing: 4) {
                                                                    Image(systemName: "heart.fill")
                                                                        .font(.system(size: 10))
                                                                    Text("人気")
                                                                        .font(.system(size: 11))
                                                                        .fontWeight(.bold)
                                                                }
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 10)
                                                                .padding(.vertical, 4)
                                                                .background(
                                                                    Capsule()
                                                                        .fill(
                                                                            LinearGradient(
                                                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                                                startPoint: .leading,
                                                                                endPoint: .trailing
                                                                            )
                                                                        )
                                                                )
                                                            case .year:
                                                                HStack(spacing: 4) {
                                                                    Image(systemName: "star.fill")
                                                                        .font(.system(size: 10))
                                                                    Text("最もお得")
                                                                        .font(.system(size: 11))
                                                                        .fontWeight(.bold)
                                                                }
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 10)
                                                                .padding(.vertical, 4)
                                                                .background(
                                                                    Capsule()
                                                                        .fill(
                                                                            LinearGradient(
                                                                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                                                                startPoint: .leading,
                                                                                endPoint: .trailing
                                                                            )
                                                                        )
                                                                )
                                                            default:
                                                                Text("お試しに最適")
                                                                    .font(.system(size: 11))
                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(.white)
                                                                    .padding(.horizontal, 10)
                                                                    .padding(.vertical, 4)
                                                                    .background(
                                                                        Capsule()
                                                                            .fill(
                                                                                LinearGradient(
                                                                                    gradient: Gradient(colors: [Color.green, Color.teal]),
                                                                                    startPoint: .leading,
                                                                                    endPoint: .trailing
                                                                                )
                                                                            )
                                                                    )
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // 価格表示
                                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                                    Text(formatPrice(product.displayPrice).replacingOccurrences(of: "¥", with: ""))
                                                        .font(.system(size: 36, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Text("円")
                                                        .font(.system(size: 18, weight: .bold))
                                                        .foregroundColor(.white)
                                                    
                                                    if let period = product.subscription?.subscriptionPeriod {
                                                        Text(periodText(for: period.unit))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.white.opacity(0.7))
                                                    }
                                                }
                                                
                                                // お得情報
                                                if let period = product.subscription?.subscriptionPeriod {
                                                    Group {
                                                        switch period.unit {
                                                        case .week:
                                                            Text("まずは1週間から")
                                                                .font(.system(size: 13))
                                                                .foregroundColor(.white.opacity(0.7))
                                                        case .month:
                                                            Text("週間プランの50%オフ")
                                                                .font(.system(size: 13))
                                                                .foregroundColor(.white.opacity(0.7))
                                                        case .year:
                                                            Text("月払いの2ヶ月分が無料")
                                                                .font(.system(size: 13))
                                                                .foregroundColor(.white.opacity(0.7))
                                                        default:
                                                            Text("まずは1週間から")
                                                                .font(.system(size: 13))
                                                                .foregroundColor(.white.opacity(0.7))
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // 選択チェックマーク
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        selectedProduct?.id == product.id ?
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ) :
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.3)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 32, height: 32)
                                                
                                                if selectedProduct?.id == product.id {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .padding(16)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedProduct?.id == product.id ?
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.pink, Color.purple, Color.blue]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ) :
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.5)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: selectedProduct?.id == product.id ? 3 : 1
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 16)
                            .onChange(of: viewModel.products) { products in
                                // 週額プランをデフォルト選択
                                if !hasSetDefaultProduct && !products.isEmpty {
                                    if let weeklyProduct = products.first(where: {
                                        $0.subscription?.subscriptionPeriod.unit == .week
                                    }) {
                                        selectedProduct = weeklyProduct
                                        hasSetDefaultProduct = true
                                    }
                                }
                            }
                        }
                        
                        VStack{
                            // 購入復元と解約リンク
                            HStack {
                                Text("購入復元時は")
                                Button(action: { 
                                    Task {
                                        do {
                                            try await AppStore.sync()
                                        } catch {
                                            print("購入処理中にエラーが発生しました: \(error)")
                                        }
                                    }
                                }) {
                                    Text("こちら　")
                                        .foregroundStyle(Color.blue)
                                }
                                Text("から")
                            }
                            HStack {
                                Text("解約時は")
                                NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                                    Text("こちら")
                                        .foregroundStyle(Color.blue)
                                }
                                Text("をご参考ください")
                            }
                            .padding(.top, 5)
                            
                            // 利用規約とプライバシーポリシーリンク
                            HStack {
                                Spacer()
                                NavigationLink(destination: TermsOfServiceView()) {
                                    Text("利用規約")
                                }
                                Spacer()
                                NavigationLink(destination: PrivacyView()) {
                                    Text("プライバシーポリシー")
                                }
                                Spacer()
                            }
                            .padding(.top, 5)
                            .foregroundStyle(Color.blue)
                        }
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.7))
                        .padding(.top, -20)
                    }
                    
                    // 購入セクション
                    VStack(spacing: 1) {
                        HStack {
                            Spacer()
                            if let product = selectedProduct {
                                HStack {
                                    Text(planLabel(for: product) + "プラン")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.top, 8)
                                    Text(formatPrice(product.displayPrice).replacingOccurrences(of: "¥", with: ""))
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                Text("円")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                }
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(5)
                                .padding(.horizontal, 10)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(10)
                            } else {
                                Text("プランを選択")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.trailing)
                        .padding(.bottom,10)
                        // 選択中のプランで購入するボタン
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
                            VStack {
                                Text("プレミアムプランに登録する")
                                    .padding(.bottom, 1)
                                Text("※いつでも解約することができます")
                                    .font(.system(size: 16))
                            }
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.black)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .padding(.horizontal,20)
                            .shadow(radius: 30)
                            .padding(.bottom, 10)
                        }
                        .disabled(selectedProduct == nil)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("プレミアムプラン登録ありがとうございます！"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .foregroundColor(Color("fontGray"))
        .onAppear {
            Task {
                await viewModel.loadProducts()
                await MainActor.run {
                    // 週額プランを優先的に選択
                    if let weeklyProduct = viewModel.products.first(where: {
                        $0.subscription?.subscriptionPeriod.unit == .week
                    }) {
                        selectedProduct = weeklyProduct
                    } else {
                        // 週額がなければ、最初のプロダクトを選択
                        selectedProduct = viewModel.products.first
                    }
                }
            }
        }
    }
}
    
    // カルーセルのタイマーと無限ループの実装
    extension PreView {
        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation {
                    currentIndex += 1
                }
                
                // 無限ループの実装
                if currentIndex >= features.count {
                    currentIndex = 0
                }
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // ヘルパー関数
    extension PreView {
        func isSmallDevice() -> Bool {
            return UIScreen.main.bounds.width < 390
        }
        
        func periodText(for unit: Product.SubscriptionPeriod.Unit) -> String {
            switch unit {
            case .week:
                return "/週"
            case .month:
                return "/月"
            case .year:
                return "/年"
            default:
                return "/週"
            }
        }
        
        func sortedProducts() -> [Product] {
            return viewModel.products.sorted { product1, product2 in
                let period1 = product1.subscription?.subscriptionPeriod.unit
                let period2 = product2.subscription?.subscriptionPeriod.unit
                
                let order: [Product.SubscriptionPeriod.Unit: Int] = [
                    .week: 0,
                    .month: 1,
                    .year: 2
                ]
                
                let priority1 = order[period1 ?? .day] ?? 999
                let priority2 = order[period2 ?? .day] ?? 999
                
                return priority1 < priority2
            }
        }
        
        func formatPrice(_ price: String) -> String {
            // ¥10 → 480円、¥98 → 9800円、¥5 → 480円 のように変換
            let numericPrice = price.filter { "0123456789".contains($0) }
            
            if let value = Int(numericPrice) {
                let actualPrice: Int
                if value == 10 {
                    actualPrice = 980
                } else if value == 98 {
                    actualPrice = 9800
                } else if value == 5 {
                    actualPrice = 480
                } else {
                    actualPrice = value
                }
                return "¥\(actualPrice)"
            }
            
            return price
        }
        
        func planLabel(for product: Product) -> String {
            if let period = product.subscription?.subscriptionPeriod {
                switch period.unit {
                case .week:
                    return "週間"
                case .month:
                    return "月額"
                case .year:
                    return "年額"
                default:
                    return "週額"
                }
            }
            return "週額"
        }
        
        func fontSizeSE(for text: String, isIPad: Bool) -> CGFloat {
            let baseFontSize: CGFloat = isIPad ? 34 : 30
            
            let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let textCharacterSet = CharacterSet(charactersIn: text)
            
            if englishAlphabet.isSuperset(of: textCharacterSet) {
                return baseFontSize
            } else {
                if text.count >= 14 {
                    return baseFontSize - 12
                } else if text.count >= 12 {
                    return baseFontSize - 10
                } else if text.count >= 10 {
                    return baseFontSize - 8
                } else if text.count >= 8 {
                    return baseFontSize - 6
                } else {
                    return baseFontSize
                }
            }
        }
    }
    
    struct PreView_Previews: PreviewProvider {
        static var previews: some View {
            PreView(audioManager: AudioManager())
        }
    }
