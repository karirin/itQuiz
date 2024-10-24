//
//  PreView.swift
//  it
//
//  Created by Apple on 2024/09/07.
//

import SwiftUI
import StoreKit

struct PreView: View {
    @State private var selectedPlan = 0
    @StateObject private var viewModel = SubscriptionViewModel()
    @StateObject var appState = AppState()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager:AudioManager
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack{
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
//                    .font(.system(size:20))
                Spacer()
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
            ScrollView {
                Image("プレミアム")
                    .resizable()
//                    .frame(height: 150)
                    .frame(height: isSmallDevice() ? 140 : 150)
                
                VStack(spacing: 5) {
                    Text("飲み物1本で")
                    HStack {
                        Text("アプリでの学習効率アップ")
                        Image(systemName: "arrow.up.forward")
                            .padding(.leading,-10)
                    }
                }
                .padding(5)
                .font(.system(size: 16))
                .bold()
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
                        .padding(.trailing,-5)
                        .padding(.bottom,2)
                    Text("プレミアム")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 5)
                VStack{
                    HStack{
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
                    HStack{
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
                    HStack{
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
                                .bold()
                                .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom)
            VStack{
                VStack{
                    HStack{
                        Image(systemName: "rectangle.badge.xmark")
                            .resizable()
                            .frame(width:40,height:30)
                            .fontWeight(.bold)
                        Text("広告非表示")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Text("ホーム画面やダンジョンが終わった後の広告が非表示になります。")
                }
                VStack{
                    HStack{
                        Image(systemName: "chart.bar")
                            .resizable()
                            .frame(width:40,height:30)
                            .fontWeight(.bold)
                        Text("グラフ機能追加")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Text("毎日の回答数や問題分野ごとの正答率をグラフで確認することができます。")
                }
                VStack{
                    HStack{
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width:40,height:40)
                            .fontWeight(.bold)
                        Text("復習機能")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Text("１度間違えた問題をもう１度解くことができます。")
                }
            }.padding(.horizontal)
                .font(.system(size:16))
                .padding(.bottom)
                HStack{
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
                HStack{
                    Text("解約時は")
                    NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                        Text("こちら")
                            .foregroundStyle(Color.blue)
                    }
                    Text("をご参考ください")
                }
                .padding(.top,5)
                HStack{
                    Spacer()
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Text("利用規約")
                        }
                    }
                    Spacer()
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Text("プライバシーポリシー")
                        }
                    }
                    Spacer()
                }
                .padding(.top,5)
                .foregroundStyle(Color.blue)
            }
            VStack(spacing: 1){
                HStack{
                    Spacer()
                    Text("月額 ¥")
                        .bold()
                        .padding(.top,8)
                    Text("200")
                        .font(.system(size: 30))
                        .bold()
                        .padding(.leading,-5)
                }
                .padding(.top,10)
                .padding(.trailing)
//                .frame(maxWidth: .infinity,maxHeight: 50)
//                .background(.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
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
                                // サブスク登録がキャンセルされた場合のメッセージ
//                                alertMessage = "サブスク登録がキャンセルされました。"
                            } catch {
                                print("購入処理中にエラーが発生しました: \(error)")
                            }
                        }
                    }) {
                        VStack{
                            Text("プレミアムプランに登録する")
                                .padding(.bottom,1)
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
            .padding(.top,1)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .frame(height: 1),
                alignment: .top
            )
            .padding(.bottom)
        }
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
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func fontSizeSE(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

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

#Preview {
    PreView(audioManager: AudioManager())
}
