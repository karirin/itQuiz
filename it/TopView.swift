//
//  TopView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI

struct ViewPositionKey5: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}


struct TopView: View {
    static let samplePaymentDates: [Date] = [Date()]
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var flag: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    var body: some View {
        ZStack{
            VStack {
                TabView {
                    HStack{
                            ContentView()
                                .background(Color("sky"))
                        }
                        .tabItem {
                            Image(systemName: "house")
                                .padding()
                            Text("ホーム")
                                .padding()
                        }
//                        ZStack {
//                            QuizManagerView(isPresenting: .constant(false))
//                        }
//                        .tabItem {
//                            Image(systemName: "map")
//                            //                        .resizable()
//                                .frame(width:1,height:1)
//                            Text("ダンジョン")
//                        }
                        
                        AvatarListView(isPresenting: $isPresentingAvatarList)
                            .tabItem {
                                Image(systemName: "square.grid.2x2")
                                Text("おとも一覧")
                            }
                    PentagonView(authManager: authManager, flag: .constant(false))
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
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
