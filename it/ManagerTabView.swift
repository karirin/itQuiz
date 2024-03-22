//
//  ManagerTabView.swift
//  it
//
//  Created by Apple on 2024/03/22.
//

import SwiftUI

struct ManagerTabView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var canSwipe: Bool = false
//    @ObservedObject var viewModel: RankingViewModel
    @ObservedObject var authManager = AuthManager.shared
//    @ObservedObject var viewModel: QuizBeginnerStoryViewModel
    let list: [String] = ["ダンジョン","ランクマッチ"]
    
    var body: some View {
        NavigationView {
            VStack{
                TopTabView(list: list, selectedTab: $selectedTab)
               
                TabView(selection: $selectedTab,
                                    content: {
//                    QuizManagerTabView(isPresenting: .constant(false))
//                                    .tag(0)
                    ManagerListView(isPresenting: .constant(false))
                                    .tag(0)
//                    Test(isPresenting: .constant(false), viewModel: QuizBeginnerStoryViewModel())
                    RankMatchListView(authManager: authManager)
//                    TopView()
                        .padding(.top)
                                    .tag(1)
                            })
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                LevelRankingView(viewModel: viewModel)
            }
            .background(Color("Color2"))
        }
        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//            audioManager.playCancelSound()
//        }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.gray)
//            Text("戻る")
//                .foregroundColor(Color("fontGray"))
//        })
//        .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("ランキング")
//                        .font(.system(size: 20)) // ここでフォントサイズを指定
//                        .foregroundColor(Color("fontGray"))
//                }
//            }
    }
}

#Preview {
    ManagerTabView()
}
