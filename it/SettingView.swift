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
    let appStoreLink: String
}

extension OtherApp {
    static let allApps = [
        OtherApp(name: "FPクエスト", description: "ゲーム感覚でFPの資格が学べるアプリ。３〜１級の階級別に「資産計画」「リスク管理」「金融資産運用」「タックスプランニング」「不動産」「相続・事業継承」で分野別に問題を解くことができます。", appStoreLink: "https://apps.apple.com/us/app/%E3%81%8A%E9%87%91%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88/id6476828253"),
        OtherApp(name: "ドリルクエスト", description: "ゲーム感覚で小学生の勉強ができるアプリ。「数学」「国語」「社会」「理科」に分かれており、それぞれ学年別レベルで出題されます。", appStoreLink: "https://apps.apple.com/us/app/%E3%83%89%E3%83%AA%E3%83%AB%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E5%B0%8F%E5%AD%A6%E7%94%9F%E3%81%AE%E5%AD%A6%E7%BF%92%E3%82%A2%E3%83%97%E3%83%AA/id6711333088"),
        OtherApp(name: "英語クエスト", description: "ゲーム感覚で英語の知識が学べるアプリ。「英単語」「英熟語」「英文法」に分かれており、それぞれ『英検』『TOIEC』の難易度別に勉強をゲーム感覚で学べます。", appStoreLink: "https://apps.apple.com/us/app/%E8%8B%B1%E8%AA%9E%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E8%8B%B1%E8%AA%9E%E3%81%AE%E5%95%8F%E9%A1%8C%E3%81%AE%E5%8B%89%E5%BC%B7%E3%81%A8%E5%AD%A6%E7%BF%92%E3%81%8C%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6477769441"),
    ]
}

struct SettingView: View {
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var isSoundOn: Bool = true
    @ObservedObject var authManager = AuthManager()
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("情報")) {
                    Toggle(isOn: $isSoundOn) {
                        if isSoundOn {
                            Image(systemName: "speaker.wave.2")
                            Text("音声オン")
                        } else {
                            Image(systemName: "speaker.slash")
                            Text("音声オフ")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // Switch color. You can adjust as per your need.
                    .onChange(of: isSoundOn, perform: { newValue in
                        audioManager.toggleSound()
                    })
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Text("利用規約")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: WebView(urlString: "https://docs.google.com/forms/d/e/1FAIpQLSfHxhubkEjUw_gexZtQGU8ujZROUgBkBcIhB3R6b8KZpKtOEQ/viewform?embedded=true")) {
                        HStack {
                            Text("お問い合せ")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
//                    if authManager.adminFlag == 1 {
                    NavigationLink(destination: PreView(audioManager: audioManager).navigationBarBackButtonHidden(true)) {
                        HStack {
                            Text("広告を非表示にする")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    Button("アカウントを削除") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
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
//                    }
//                    NavigationLink(destination: Interstitial1()) {
//                        HStack {
//                            Text("インタースティシャル")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(.systemGray4))
//                        }
//                    }
                }
                Section(header: Text("他のアプリ")) {
                    ForEach(OtherApp.allApps) { app in
                        Link(destination: URL(string: app.appStoreLink)!) {
                            HStack {
                                Image(app.name)
                                    .resizable()
                                    .frame(width:80,height: 80)
                                    .cornerRadius(15)
                                VStack(alignment: .leading) {
                                    Text(app.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(app.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("設定")
        }
        .onAppear{
            AuthManager.shared.fetchCurrentUserAdminFlag()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(leading: Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            audioManager.playCancelSound()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("fontGray"))
                            Text("戻る")
                                .foregroundColor(Color("fontGray"))
                        })
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
