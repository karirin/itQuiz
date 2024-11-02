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
                    Text(feature.title)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    Spacer()
            }
            .padding(.horizontal)
            Text(feature.description)
                .font(.caption)
                .font(.footnote)
                .padding(.bottom)
                .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PreView: View {
    @State private var selectedPlan = 0
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
        VStack {
            // ヘッダー
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                }
                .padding(.leading)
                Spacer()
                Text("プレミアムプラン")
                    .font(.headline)
                Spacer()
                // レイアウトの対称性を保つために非表示のボタン
                Button(action: {
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
            .padding(.top)
            
            // ScrollView のコンテンツ
            ScrollView {
                // プレミアム画像
                Image("プレミアム")
                    .resizable()
                    .frame(height: isSmallDevice() ? 140 : 150)
                
                // キャッチフレーズ
                VStack(spacing: 5) {
                    Text("飲み物1本で")
                    HStack {
                        Text("アプリでの学習効率アップ")
                        Image(systemName: "arrow.up.forward")
                            .padding(.leading, -10)
                    }
                }
                .padding(5)
                .font(.system(size: 16))
                .bold()
                
                // 料金比較
                HStack {
                    Spacer()
                    Text("　　　　　       ")
                    Spacer()
                    Text("通常")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                    Spacer()
                    Spacer()
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.red)
                        .padding(.trailing, -5)
                        .padding(.bottom, 2)
                    Text("プレミアム")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                // 特徴の比較
                VStack {
                    HStack {
                        Text("広告非表示")
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .bold()
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
                    Divider()
                    
                    HStack {
                        Text("グラフ機能")
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .bold()
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
                    Divider()
                    
                    HStack {
                        Text("復習機能　")
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .bold()
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
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
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
            
            // 購入セクション
            VStack(spacing: 1) {
                HStack {
                    Spacer()
                    Text("月額 ¥")
                        .bold()
                        .padding(.top, 8)
                    Text("200")
                        .font(.system(size: 30))
                        .bold()
                        .padding(.leading, -5)
                }
                .padding(.top, 10)
                .padding(.trailing)
                
                ForEach(viewModel.products, id: \.id) { product in
                    Button(action: {
                        Task {
                            do {
                                try await AppStore.sync()
                                try await viewModel.purchaseProduct(product, showAlert: $showAlert)
                                appState.isBannerVisible = false
                                alertMessage = "広告非表示の反映に少しお時間がかかる場合がございます。\nご了承ください"
                            } catch StoreKitError.userCancelled {
                                print("StoreKitError.userCancelled")
                                // 必要に応じてメッセージを表示
                            } catch {
                                print("購入処理中にエラーが発生しました: \(error)")
                            }
                        }
                    }) {
                        VStack {
                            Text("プレミアムプランに登録する")
                                .padding(.bottom, 1)
                            Text("※いつでも解約することができます")
                                .font(.system(size: 12))
                        }
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color("preAdd"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 1)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .frame(height: 1),
                alignment: .top
            )
            .padding(.bottom)
        }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("プレミアムプラン登録ありがとうございます！"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .background(Color("Color2"))
        .foregroundColor(Color("fontGray"))
        .onAppear {
            Task {
                await viewModel.loadProducts()
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
