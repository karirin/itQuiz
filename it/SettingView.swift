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
    @ObservedObject var authManager = AuthManager()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
