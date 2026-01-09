//  TopView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI
import AppVersionMonitorSwiftUI

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
    @State var isAlert: Bool = false
    @StateObject private var storyViewModel = PositionViewModel.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack{
                Image("背景")
                                .resizable()
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

                    ZStack {
                            StoryView(isReturnActive: .constant(false), isPresented: .constant(false))
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
                    GraphManagerView()
                            .tabItem {
                                Image(systemName: "chart.pie")
                                Text("分析")
                            }
                    ZStack {
                        SettingView()
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
             switch newPhase {
             case .background:
                 storyViewModel.handleAppWentToBackground()
             case .active:
                 storyViewModel.handleAppBecameActive()
             default:
                 break
             }
         }
    }
}

func generateHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(AppState())
    }
}
