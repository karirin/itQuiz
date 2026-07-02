//
//  SubModalView.swift
//  it
//
//  Created by Apple on 2024/02/26.
//

import SwiftUI
import StoreKit

struct SubModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    @Binding var userFlag: Int
    @StateObject private var viewModel = SubscriptionViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ヘッダー
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 56, height: 56)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(hex: "ffd700"))
                    }

                    Text("プレミアムプラン")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("加入すると下記の特典が受けられます")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 特典
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(hex: "667eea").opacity(0.12))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "rectangle.badge.xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("広告が非表示になります")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("fontGray"))
                                Text("バナー広告・動画広告なしで快適に学習")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color(hex: "667eea").opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Text("※プレミアムプランはいつでも解約できます")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        // 購入ボタン
                        ForEach(viewModel.products, id: \.id) { product in
                            Button(action: {
                                Task {
                                    do {
                                        try await AppStore.sync()
                                        try await viewModel.purchaseProduct(product, showAlert: $showAlert)
                                    } catch {
                                        print("購入処理中にエラーが発生しました: \(error)")
                                    }
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.displayName)
                                            .font(.system(size: 16, weight: .bold))
                                        Text(product.displayPrice)
                                            .font(.system(size: 13, weight: .medium))
                                            .opacity(0.9)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.system(size: 22))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "ff9d00"), Color(hex: "ff6a00")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color(hex: "ff6a00").opacity(0.35), radius: 8, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // 復元
                        Button(action: {
                            Task {
                                do {
                                    try await AppStore.sync()
                                    await appState.refreshSubscriptionState()
                                } catch {
                                    print("購入処理中にエラーが発生しました: \(error)")
                                }
                            }
                        }) {
                            Text("購入を復元する")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "667eea"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    Capsule()
                                        .stroke(Color(hex: "667eea").opacity(0.5), lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 解約案内
                        HStack(spacing: 0) {
                            Text("解約時は")
                            NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                                Text("こちら")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            Text("をご参考ください")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    }
                    .padding(20)
                }
                .onAppear {
                    Task {
                        await viewModel.loadProducts()
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .frame(height: 520)
            .padding(20)
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            .overlay(
                // 閉じるボタン
                Button(action: {
                    generateHapticFeedback()
                    isPresented = false
                    resumeTimer()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white, Color.black.opacity(0.35))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(28),
                alignment: .topTrailing
            )
        }
        .onAppear {
            pauseTimer() // モーダルが表示されたときにタイマーを一時停止
            if userFlag == 0 {
                isSoundOn = true
            } else {
                isSoundOn = false
            }
        }
    }
}
