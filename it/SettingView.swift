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
        OtherApp(name: "お金クエスト", description: "ゲーム感覚でお金の知識が学べるアプリ。税金、投資、節約、予算管理などお金周りの勉強をゲーム感覚で学べます。", appStoreLink: "https://apps.apple.com/us/app/%E3%81%8A%E9%87%91%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88/id6476828253")
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
                    NavigationLink(destination: SubscriptionView(audioManager: audioManager).navigationBarBackButtonHidden(true)) {
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
                                Image("お金クエスト")
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
