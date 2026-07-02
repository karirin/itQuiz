//
//  SettingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/10.
//

import SwiftUI
import WebKit

struct OtherApp: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let description2: String
    let appStoreLink: String
}

extension OtherApp {
    static let allApps = [
        OtherApp(name: "簿記クエスト", description: "ゲーム感覚で簿記の資格が学べるアプリ。４級〜１級の階級ごとに、「基礎知識と仕訳」「帳簿と帳簿組織」「決算と財務諸表」「原価計算と管理会計」「税務と法務」の分野別に問題を解くことができます。", description2: "ゲーム感覚で簿記の資格が学べるアプリ。４級〜１級の階級ごとに分野別で問題を解くことができます。", appStoreLink: "https://apps.apple.com/us/app/%E7%B0%BF%E8%A8%98%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E7%B0%BF%E8%A8%98%E3%81%AE%E8%B3%87%E6%A0%BC%E3%81%AB%E5%90%88%E6%A0%BC%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6740277636"),
        OtherApp(name: "FPクエスト", description: "ゲーム感覚でFPの資格が学べるアプリ。３〜１級の階級別に「資産計画」「リスク管理」「金融資産運用」「タックスプランニング」「不動産」「相続・事業継承」で分野別に問題を解くことができます。", description2: "ゲーム感覚でFPの資格が学べるアプリ。３〜１級の階級ごとに分野別で問題を解くことができます。", appStoreLink: "https://apps.apple.com/us/app/%E3%81%8A%E9%87%91%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88/id6476828253"),
        OtherApp(name: "ドリルクエスト", description: "ゲーム感覚で小学生の勉強ができるアプリ。「算数」「国語」「社会」「理科」に分かれており、それぞれ学年別レベルで出題されます。", description2: "ゲーム感覚で小学生の勉強ができるアプリ。「算数」「国語」「社会」「理科」の分野別で学習できます", appStoreLink: "https://apps.apple.com/us/app/%E3%83%89%E3%83%AA%E3%83%AB%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E5%B0%8F%E5%AD%A6%E7%94%9F%E3%81%AE%E5%AD%A6%E7%BF%92%E3%82%A2%E3%83%97%E3%83%AA/id6711333088"),
        OtherApp(name: "英語クエスト", description: "ゲーム感覚で英語の知識が学べるアプリ。「英単語」「英熟語」「英文法」に分かれており、それぞれ『英検』『TOIEC』の難易度別に勉強をゲーム感覚で学べます。", description2: "ゲーム感覚で英語の知識が学べるアプリ。「英単語」「英熟語」「英文法」の分野別で学習できます。", appStoreLink: "https://apps.apple.com/us/app/%E8%8B%B1%E8%AA%9E%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E8%8B%B1%E8%AA%9E%E3%81%AE%E5%95%8F%E9%A1%8C%E3%81%AE%E5%8B%89%E5%BC%B7%E3%81%A8%E5%AD%A6%E7%BF%92%E3%81%8C%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6477769441"),
    ]
}

struct SettingView: View {
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var isSoundOn: Bool = true
    @ObservedObject var authManager = AuthManager.shared
    @State private var showingDeleteAlert = false
    @Environment(\.colorScheme) private var colorScheme
    var backgroundColor: Color { colorScheme == .dark ? Color(.systemBackground) : Color(.white) }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // フィードバックセクション
                    VStack(spacing: 0) {
                        HStack {
                            Text("各種設定")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            soundToggleRow
                            Divider().padding(.leading, 56)

                            NavigationLink(destination: InventoryView()) {
                                settingRow(icon: "shippingbox.fill", iconColor: .teal, title: "持ち物")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                            
                            NavigationLink(destination: TermsOfServiceView()) {
                                settingRow(icon: "doc.text", iconColor: .blue, title: "利用規約")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                            
                            NavigationLink(destination: PrivacyView()) {
                                settingRow(icon: "lock.shield", iconColor: .orange, title: "プライバシーポリシー")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                            
                            NavigationLink(destination: WebView(urlString: "https://docs.google.com/forms/d/e/1FAIpQLSfHxhubkEjUw_gexZtQGU8ujZROUgBkBcIhB3R6b8KZpKtOEQ/viewform?embedded=true")) {
                                settingRow(icon: "envelope", iconColor: .green, title: "お問い合せ")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                            
                            NavigationLink(destination: PreView(audioManager: audioManager).navigationBarBackButtonHidden(true)) {
                                settingRow(icon: "eye.slash", iconColor: .purple, title: "広告を非表示にする")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                            
                            deleteAccountRow
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    
                    // おすすめのアプリセクション
                    VStack(spacing: 0) {
                        HStack {
                            Text("おすすめのアプリ")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(OtherApp.allApps.enumerated()), id: \.element.id) { index, app in
                                appRow(app: app)
                                if index < OtherApp.allApps.count - 1 {
                                    Divider().padding(.leading, 72)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationBarTitle("", displayMode: .inline)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onAppear {
            AuthManager.shared.fetchCurrentUserAdminFlag()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Components
    
    private var backButton: some View {
        Button(action: {
            generateHapticFeedback()
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                Text("戻る")
                    .font(.system(size: 17))
            }
            .foregroundColor(.blue)
        }
    }
    
    private var soundToggleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: isSoundOn ? "speaker.wave.2" : "speaker.slash")
                .font(.system(size: 20))
                .foregroundColor(isSoundOn ? .blue : .gray)
                .frame(width: 24, height: 24)
            
            Text(isSoundOn ? "音声オン" : "音声オフ")
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: $isSoundOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onChange(of: isSoundOn) { newValue in
            audioManager.toggleSound()
        }
    }
    
    private func settingRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.tertiaryLabel)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    private var deleteAccountRow: some View {
        Button(action: {
            showingDeleteAlert = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .frame(width: 24, height: 24)
                
                Text("アカウントを削除")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.tertiaryLabel)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .alert("アカウントを削除してもよろしいですか？この操作は元に戻せません。", isPresented: $showingDeleteAlert) {
            Button("削除", role: .destructive) {
                authManager.deleteUserAccount { success, error in
                    if success {
                        // アカウント削除成功時の処理
                    } else {
                        // エラー処理
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
    
    private func appRow(app: OtherApp) -> some View {
        Link(destination: URL(string: app.appStoreLink)!) {
            HStack(spacing: 12) {
                Image(app.name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 16, weight: .medium))
                    
                    .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(app.description2)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.tertiaryLabel)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

struct InventoryView: View {
    private enum GachaDestination: String, Identifiable {
        case normal
        case rare
        case meka
        case god

        var id: String { rawValue }
    }

    var showsNavigationTitle: Bool = true
    var showsOwnBackground: Bool = true
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var storyViewModel = PositionViewModel.shared
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var appearAnimation = false
    @State private var selectedCategory = 0
    @State private var presentedGachaDestination: GachaDestination?

    private let ticketTypes: [InventoryItemType] = [
        .normalGachaTicket,
        .rareGachaTicket,
        .mekaGachaTicket,
        .godGachaTicket
    ]

    private let supportItemTypes: [InventoryItemType] = [
        .staminaPotion,
        .boostTicket
    ]

    private var totalItemCount: Int {
        (ticketTypes + supportItemTypes).reduce(0) { $0 + authManager.inventoryCount(for: $1) }
    }

    private var currentItems: [InventoryItemType] {
        selectedCategory == 0 ? ticketTypes : supportItemTypes
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader
                    .padding(.bottom, 20)

                categoryPicker
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                LazyVStack(spacing: 14) {
                    ForEach(Array(currentItems.enumerated()), id: \.element.rawValue) { index, type in
                        inventoryItemRow(for: type)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.08),
                                value: appearAnimation
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(
            Group {
                if showsOwnBackground {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                } else {
                    Color.clear
                }
            }
        )
        .navigationTitle(showsNavigationTitle ? "持ち物" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authManager.fetchInventory()
            authManager.fetchUserRewardFlag()
            authManager.syncRewardBoostState()
            withAnimation { appearAnimation = true }
        }
        .onChange(of: selectedCategory) { _ in
            appearAnimation = false
            withAnimation { appearAnimation = true }
        }
        .alert("持ち物", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(item: $presentedGachaDestination) { destination in
            inventoryGachaDestinationView(for: destination)
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.22, green: 0.24, blue: 0.42),
                        Color(red: 0.35, green: 0.28, blue: 0.58)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Decorative circles
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .offset(x: 120, y: -40)
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 140, height: 140)
                    .offset(x: -100, y: 30)

                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        ForEach(ticketTypes.prefix(3), id: \.rawValue) { type in
                            miniItemBubble(type: type)
                        }
                    }

                    VStack(spacing: 6) {
                        Text("合計 \(totalItemCount) アイテム")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                        Text("チケットとサポートアイテムを管理")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    quickSummaryRow
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .clipShape(
                RoundedShape(corners: [.bottomLeft, .bottomRight], radius: 28)
            )
        }
    }

    private func miniItemBubble(type: InventoryItemType) -> some View {
        ZStack {
            Circle()
                .fill(type.accentColor.opacity(0.25))
                .frame(width: 52, height: 52)
            InventoryItemArtworkView(type: type, width: 36, height: 36, cornerRadius: 8)
        }
    }

    private var quickSummaryRow: some View {
        HStack(spacing: 0) {
            ForEach(Array((ticketTypes + supportItemTypes).enumerated()), id: \.element.rawValue) { index, type in
                if index > 0 {
                    Divider()
                        .frame(height: 28)
                        .background(Color.white.opacity(0.15))
                }
                VStack(spacing: 3) {
                    Text("\(authManager.inventoryCount(for: type))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(type.shortName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Category Picker
    private var categoryPicker: some View {
        HStack(spacing: 0) {
            categoryTab(title: "ガチャチケット", icon: "ticket.fill", index: 0)
            categoryTab(title: "サポート", icon: "cross.case.fill", index: 1)
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func categoryTab(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedCategory = index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(selectedCategory == index ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                Group {
                    if selectedCategory == index {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color(red: 0.30, green: 0.30, blue: 0.52))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Item Row
    private func inventoryItemRow(for type: InventoryItemType) -> some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 14) {
                // Item artwork with count badge
                ZStack(alignment: .topTrailing) {
                    InventoryItemArtworkView(type: type, width: 60, height: 60, cornerRadius: 16)

                    Text("\(authManager.inventoryCount(for: type))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(minWidth: 22, minHeight: 22)
                        .background(
                            Circle()
                                .fill(type.accentColor)
                                .shadow(color: type.accentColor.opacity(0.4), radius: 4, y: 2)
                        )
                        .offset(x: 6, y: -6)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(type.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(type.usageDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Status indicators
            if type == .staminaPotion {
                staminaStatusBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }

            if type == .boostTicket {
                boostStatusBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }

            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, 16)

            // Action area
            actionRow(for: type)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Status Bars
    private var staminaStatusBar: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.24, green: 0.74, blue: 0.48))
                Text("スタミナ")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(storyViewModel.stamina)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("/ 100")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.24, green: 0.74, blue: 0.48),
                                    Color(red: 0.30, green: 0.85, blue: 0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(min(storyViewModel.stamina, 100)) / 100.0)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(Color(red: 0.24, green: 0.74, blue: 0.48).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var boostStatusBar: some View {
        HStack(spacing: 10) {
            Image(systemName: authManager.rewardFlag >= 2 ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(authManager.rewardFlag >= 2 ? Color(red: 1.0, green: 0.45, blue: 0.24) : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("ブースト状態")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(authManager.rewardFlag >= 2 ? "経験値・コイン 2倍 発動中" : "未使用")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(authManager.rewardFlag >= 2 ? Color(red: 1.0, green: 0.45, blue: 0.24) : .secondary)
            }

            Spacer()

            if authManager.rewardFlag >= 2 {
                Text("ACTIVE")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.45, blue: 0.24))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(authManager.rewardFlag >= 2
                      ? Color(red: 1.0, green: 0.45, blue: 0.24).opacity(0.08)
                      : Color(.systemGray6))
        )
    }

    // MARK: - Action Row
    @ViewBuilder
    private func actionRow(for type: InventoryItemType) -> some View {
        switch type {
        case .normalGachaTicket:
            gachaNavigationButton(title: "レギュラーガチャへ", color: type.accentColor) {
                presentedGachaDestination = .normal
            }
        case .rareGachaTicket:
            gachaNavigationButton(title: "幸福ガチャへ", color: type.accentColor) {
                presentedGachaDestination = .rare
            }
        case .mekaGachaTicket:
            gachaNavigationButton(title: "メカガチャへ", color: type.accentColor) {
                presentedGachaDestination = .meka
            }
        case .godGachaTicket:
            gachaNavigationButton(title: "神ガチャへ", color: type.accentColor) {
                presentedGachaDestination = .god
            }
        case .staminaPotion:
            useItemButton(
                title: "回復薬を使う",
                icon: "heart.fill",
                color: type.accentColor,
                isDisabled: authManager.inventoryCount(for: type) == 0,
                action: useStaminaPotion
            )
        case .boostTicket:
            useItemButton(
                title: authManager.rewardFlag >= 2 ? "ブースト発動中" : "ブースト薬を使う",
                icon: "bolt.fill",
                color: type.accentColor,
                isDisabled: authManager.inventoryCount(for: type) == 0 || authManager.rewardFlag >= 2,
                action: useBoostTicket
            )
        }
    }

    private func gachaNavigationButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func inventoryGachaDestinationView(for destination: GachaDestination) -> some View {
        switch destination {
        case .normal:
            GachaView().navigationBarBackButtonHidden(true)
        case .rare:
            RareGachaView().navigationBarBackButtonHidden(true)
        case .meka:
            MekaGachaView().navigationBarBackButtonHidden(true)
        case .god:
            GodGachaView().navigationBarBackButtonHidden(true)
        }
    }

    private func useItemButton(title: String, icon: String, color: Color, isDisabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(isDisabled ? .white.opacity(0.7) : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray.opacity(0.35) : color)
            )
        }
        .disabled(isDisabled)
    }

    private func useStaminaPotion() {
        authManager.useStaminaPotion { success in
            alertMessage = success ? "スタミナを30回復しました。" : "回復薬を使えませんでした。"
            showAlert = true
        }
    }

    private func useBoostTicket() {
        authManager.useBoostTicket { success in
            alertMessage = success ? "1時間ブーストを発動しました。" : "ブースト薬を使えませんでした。"
            showAlert = true
        }
    }
}

// MARK: - RoundedShape helper
private struct RoundedShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
