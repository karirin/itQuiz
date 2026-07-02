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
        TabView {
            ContentView()
                .background(Color("sky"))
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }

            MissionView()
                .tabItem {
                    Label("ミッション", systemImage: "checklist")
                }
                .badge(MissionManager.shared.totalClaimableCount)

            AvatarListView(isPresenting: $isPresentingAvatarList)
                .tabItem {
                    Label("おとも一覧", systemImage: "square.grid.2x2.fill")
                }

            GraphManagerView()
                .tabItem {
                    Label("分析", systemImage: "chart.pie.fill")
                }

            SettingView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.primary)
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
