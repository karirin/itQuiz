//
//  ManagerView.swift
//  it
//
//  Created by Apple on 2024/03/22.
//

import SwiftUI

struct ManagerView: View {
    @ObservedObject var audioManager : AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var canSwipe: Bool = false
    @ObservedObject var viewModel: RankingViewModel
    @StateObject var reward = Reward()
    @State private var showAlert: Bool = false
    
    let list: [String] = ["学習","ランクマッチ", "ボス戦"]
    
    var body: some View {
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        audioManager.playCancelSound()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                        
                        Text("戻る")
                            .foregroundColor(Color("fontGray"))
                    }
                    .padding(.top)
                    Spacer()
                }
                .padding(.leading)
                .background(.white)
//                TopTabView(list: list, selectedTab: $selectedTab)
//                    .padding(.top,-13)
//                TabView(selection: $selectedTab,
//                                    content: {
//                    QuizManagerView(isPresenting: .constant(false))
//                                    .tag(0)
                    ManagerListView(isPresenting: .constant(false))
//                                    .tag(0)
//                    RankMatchListView(authManager: authManager)
//                    TopView()
//                    StoryView()
//                        .tag(1)
//                    BossManagerListView(isPresenting: .constant(false))
//                        .padding(.top)
//                                    .tag(2)
//                })
//                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                LevelRankingView(viewModel: viewModel)
            }
            .onAppear{
                reward.LoadReward()
            }
            .background(Color("Color2"))
    }
}

#Preview {
    ManagerView(audioManager: AudioManager(), viewModel: RankingViewModel())
}
