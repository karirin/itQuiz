import SwiftUI

struct GraphManagerView: View {
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    @EnvironmentObject var appState: AppState
    @State private var preFlag = false

    var body: some View {
        VStack(spacing: 0) {
            LearningAnalysisHeader()

            ZStack {
                if !appState.hasResolvedSubscriptionState {
                    SlimeCardLoadingView(message: "プランを確認中")
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let userID = authManager.currentUserId, !userID.isEmpty {
                    LearningAnalysisView(authManager: authManager, isPremium: appState.isSubscribed,
                                         onUpgrade: { preFlag = true })
                    .id(userID)
                } else {
                    SlimeCardLoadingView(message: "学習記録を準備中")
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background { LearningModeGlassBackground() }
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager, source: .analysis)
        }
        .onAppear { logPremiumUseIfNeeded() }
        .onChange(of: appState.isSubscribed) { _ in logPremiumUseIfNeeded() }
    }

    private func logPremiumUseIfNeeded() {
        if appState.isSubscribed {
            PremiumAnalytics.logPremiumFirstUseIfNeeded(feature: "analysis")
        }
    }
}

#Preview {
    GraphManagerView()
        .environmentObject(AppState())
}
