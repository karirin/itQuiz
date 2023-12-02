//
//  TopView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI

struct TopView: View {
    static let samplePaymentDates: [Date] = [Date()]
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        VStack {
            TabView {
                ZStack {
                    ContentView()
                        .background(Color("sky"))
                }
                .tabItem {
                    Image(systemName: "house")
                        .padding()
                    Text("ホーム")
                        .padding()
                }
                
                ZStack {
                    QuizManagerView(isPresenting: $isPresentingQuizList)
                }
                .tabItem {
                    Image(systemName: "map")
//                        .resizable()
                        .frame(width:1,height:1)
                    Text("ダンジョン")
                }
                
                AvatarListView(isPresenting: $isPresentingAvatarList)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("おとも一覧")
                    }
                PentagonView(authManager: authManager)
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("分析")
                    }
                SettingView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
            }
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
