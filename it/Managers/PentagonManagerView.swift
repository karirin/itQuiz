//
//  PentagonManagerView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct PentagonManagerView: View {
        @StateObject var viewModel = RankingViewModel()
//        @ObservedObject var audioManager : AudioManager
        @ObservedObject var authManager = AuthManager.shared
        @Environment(\.presentationMode) var presentationMode
        @State private var selectedTab: Int = 0
        @State private var canSwipe: Bool = false
    @ObservedObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
        let list: [String] = ["ITパスポート", "基本情報\n技術者試験", "応用情報\n技術者試験"]
        
        var body: some View {
                VStack{
                    TopTabView(list: list, selectedTab: $selectedTab)
                    TabView(selection: $selectedTab,
                                        content: {
                        PentagonITView(authManager: authManager, flag: .constant(false))
                            .padding(.top)
                                        .tag(0)
                        PentagonInfoView(authManager: authManager, flag: .constant(false))
                            .padding(.top)
                                        .tag(1)
                        PentagonAppliedView(authManager: authManager, flag: .constant(false))
                            .padding(.top)
                                        .tag(2)
                                })
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 80 {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                )
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
//                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("fontGray"))
                    Text("戻る")
                        .foregroundColor(Color("fontGray"))
                }).buttonStyle(.plain)
                .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("ダンジョン一覧")
                                .font(.system(size: 20)) // ここでフォントサイズを指定
                                .foregroundStyle(Color("fontGray"))
                        }
                    }
                .background(Color("Color2"))
            
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action: { 
//                        generateHapticFeedback()
//                self.presentationMode.wrappedValue.dismiss()
//                audioManager.playCancelSound()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.gray)
//                Text("戻る")
//                    .foregroundColor(Color("fontGray"))
//            })
//            .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("ランキング")
//                            .font(.system(size: 20)) // ここでフォントサイズを指定
//                            .foregroundColor(Color("fontGray"))
//                    }
//                }
        }
}


#Preview {
    PentagonManagerView()
}


