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
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @State private var selectedTab = 0
    @ObservedObject private var learningTour = InitialLearningTour.shared

    var body: some View {
        ZStack{
                Image("背景")
                                .resizable()
            VStack {
                TabView(selection: $selectedTab) {
                    HStack{
                            ContentView()
                                .toolbar(learningTour.isActive ? .hidden : .visible, for: .tabBar)
                                .background(Color("sky"))
                        }
                    
                        .tabItem {
                            Image(systemName: "house")
                                .padding()
                            Text("ホーム")
                                .padding()
                        }
                        .tag(0)

                        // 学習モードはオフラインでも問題演習ができる（画面内にオフライン表示あり）。
                        // ホームの「学習モード」ボタンと挙動をそろえ、タブからも開けるようにする。
                        NavigationView {
                            ManagerListView(
                                isPresenting: $isPresentingQuizList,
                                showsBackButton: false
                            )
                        }
                        .navigationViewStyle(.stack)
                            .tabItem {
                                Image(systemName: "book.fill")
                                Text("学習モード")
                            }
                            .tag(1)

                        Group {
                            if connectivity.isConnected {
                                AvatarListView(isPresenting: $isPresentingAvatarList)
                            } else {
                                OfflineUnavailableView(featureName: "おとも一覧")
                            }
                        }
                            .tabItem {
                                Image(systemName: "square.grid.2x2")
                                Text("おとも一覧")
                            }
                            .tag(2)
                    Group {
                        if connectivity.isConnected {
                            GraphManagerView()
                        } else {
                            OfflineUnavailableView(featureName: "分析")
                        }
                    }
                            .tabItem {
                                Image(systemName: "chart.pie")
                                Text("分析")
                            }
                            .tag(3)
                    ZStack {
                        SettingView()
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                    .tag(4)
                }
            }
        }
        .onAppear {
            GuildManager.shared.fetchMyGuild()
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
        .onChange(of: connectivity.isConnected) { isConnected in
            if !isConnected && selectedTab != 4 && selectedTab != 1 {
                selectedTab = 0
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
            .environmentObject(ConnectivityMonitor.shared)
    }
}
