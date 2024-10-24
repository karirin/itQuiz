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
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
//    @Binding var tutorialNum: Int
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    @Binding var userFlag: Int
    @StateObject private var viewModel = SubscriptionViewModel()
    @StateObject var appState = AppState()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            ScrollView { // Listの代わりにScrollViewを使用
                VStack { // VStackで各要素を縦に並べる
                    HStack{
//                        Button(action: {
//                            self.presentationMode.wrappedValue.dismiss()
//                            audioManager.playCancelSound()
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(Color("fontGray"))
//                            Text("戻る")
//                                .foregroundColor(Color("fontGray"))
//                        }
//                        .padding(.leading)
                        Spacer()
                        Text("プレミアムプラン")
                            .font(.system(size:24))
                        Spacer()
//                        Button(action: {
//                            self.presentationMode.wrappedValue.dismiss()
//                            audioManager.playCancelSound()
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(Color("fontGray"))
//                            Text("戻る")
//                                .foregroundColor(Color("fontGray"))
//                        }
//                        .padding(.leading)
//                        .opacity(0)
                    }
                    .padding(.top)
                    HStack{
                        Text("プレミアムプランに加入すると\n下記特典が受けられます")
                            .font(.system(size:22))
                        Spacer()
                    }.padding()
                    VStack{
                        HStack{
                            Image(systemName: "rectangle.badge.xmark")
                                .resizable()
                                .frame(width:40,height:30)
                                .fontWeight(.bold)
                        Text("広告が非表示になります")
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }.padding(.leading)
                        .font(.system(size:16))
                        .padding(.bottom)
                    Text("※プレミアムプランはいつでも解約できます")
                            .font(.system(size: 18))
                            .padding(.bottom)
    //                ForEach(viewModel.products.sorted(by: { $0.displayName == "お試しプラン" && $1.displayName != "お試しプラン" }), id: \.id) { product in
                    ForEach(viewModel.products, id: \.id) { product in
                        VStack{ // 各商品情報をVStackで囲む
    //                        if product.displayName == "広告非表示" {
                                    Button(action: {
                                        Task {
                                            do {
                                                try await AppStore.sync()
                                                try await viewModel.purchaseProduct(product, showAlert: $showAlert)
                                                appState.isBannerVisible = false
                                            } catch {
                                                print("購入処理中にエラーが発生しました: \(error)")
                                            }
                                        }
                                    }) {
    //                                    Text("サブスクリプション登録")
                                        Image("広告非表示ボタン")
                                            .resizable()
                                            .frame(width:250,height:80)
                                    }.shadow(radius: 3)
                                    .padding(.bottom)
                        }
                    }
                    
                Button(action: {
                    Task {
                        do {
                            try await AppStore.sync()
                        } catch {
                            print("購入処理中にエラーが発生しました: \(error)")
                        }
                    }
                }) {
                    Text("購入を復元する")
                        .fontWeight(.semibold)
                        .frame(height:40)
                        .padding(3)
                        .padding(.horizontal)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(24)
                        .shadow(radius: 3)
                        .padding(.top)
                }
                    HStack{
                        Text("解約時は")
                        NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                            Text("こちら")
                                .foregroundStyle(Color.blue)
                        }
                        Text("をご参考ください")
                    }.font(.system(size: 18))
                        .padding(.top)
                }
               
                .onAppear {
                    Task {
                        await viewModel.loadProducts()
                    }
                }
            } .foregroundColor(Color("fontGray"))
                .background(Color("Color2"))
                .cornerRadius(20)
                .frame(height:500)
                    .padding()
        //            .background(Color.white)
                    .shadow(radius: 10)
            .overlay(
                // 「×」ボタンを右上に配置
                Button(action: {
                    isPresented = false
                        resumeTimer()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .background(.white)
                        .cornerRadius(30)
                        .padding()
                }
                .offset(x: 10, y: -15), // この値を調整してボタンを正しい位置に移動させます
                alignment: .topTrailing // 枠の右上を基準に位置を調整します
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
//
//struct ModalView1_Previews: PreviewProvider {
//    @State static private var isPresenting = true
//    static var previews: some View {
//        SubModalView(isSoundOn: .constant(true), isPresented: .constant(true), isPresenting: $isPresenting, audioManager: AudioManager(), showHomeModal: .constant(true), userFlag: .constant(1))
////ModalView()
//    }
//}

