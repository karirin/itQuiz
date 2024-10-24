//
//  MockView.swift
//  it
//
//  Created by Apple on 2024/10/12.
//

import SwiftUI
import StoreKit

struct MockView: View {
    @State private var showFeedbackAlert = false
    @State private var navigateToContact = false
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        NavigationView {
            VStack {
                // メインコンテンツ
                Text("メイン画面")
                    .padding()
                
                Button(action: {
                    showFeedbackAlert = true
                }) {
                    Text("フィードバックを送る")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(
                    destination: MockContactView(),
                    isActive: $navigateToContact,
                    label: {
                        EmptyView()
                    })
            }
            .navigationTitle("ホーム")
            .alert(isPresented: $showFeedbackAlert) {
                Alert(
                    title: Text("アプリの使い心地はどうですか"),
                    message: nil,
                    primaryButton: .default(Text("はい"), action: {
                        requestReview()
                    }),
                    secondaryButton: .cancel(Text("いいえ"), action: {
                        navigateToContact = true
                    })
                )
            }
        }
    }
    
    func redirectToAppStoreReview() {
        // App Storeのレビュー画面に遷移
        // 自分のアプリのApple IDを以下のURLに置き換えてください
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6711333088?action=write-review") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct MockContactView: View {
    var body: some View {
        VStack {
            Text("問い合わせ画面")
                .font(.title)
                .padding()
            // ここに問い合わせフォームなどを追加
        }
        .navigationTitle("お問い合わせ")
    }
}

struct MockView_Previews: PreviewProvider {
    static var previews: some View {
        MockView()
    }
}

