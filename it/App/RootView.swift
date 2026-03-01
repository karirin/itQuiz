//
//  RootView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/17.
//

import SwiftUI
import StoreKit

struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @State static private var showExperienceModalPreview = false
    @State var isActive = false
    @State private var isUserExists: Bool? = nil
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) var scenePhase
    let viewModel = PositionViewModel.shared
    @State private var isShowingOtherAppsSheet = false

    var body: some View {
        Group {
            if !isActive {
                SplashScreenView()
            } else if isUserExists == false || isUserExists == nil {
                TopView()
            } else {
                TopView()
                .sheet(isPresented: $isShowingOtherAppsSheet) {
                    OtherAppsPromotionView()
                        .presentationDetents([.large,
                                              .fraction(isSmallDevice() ? 0.95 : isiPhone12Or13() ? 0.7 : 0.7)
                        ])
                }
            }
        }
        .onAppear {
            if let userId = authManager.currentUserId {
                authManager.checkIfUserIdExists(userId: userId) { exists in
                    self.isUserExists = exists
                }
            } else {
                self.isUserExists = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                    // ログインボーナス表示チェック後にOtherAppsを出す
                    checkLoginBonusThenShowOtherApps()
                }
            }
        }
    }
    
    /// ログインボーナスが必要か確認し、不要ならOtherAppsを表示
    /// 必要ならログインボーナス終了後に表示されるよう遅延させる
    private func checkLoginBonusThenShowOtherApps() {
        authManager.shouldShowLoginBonus { shouldShow in
            if shouldShow {
                // ログインボーナスが表示される → 3秒後に表示（ボーナス画面が閉じる頃）
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    isShowingOtherAppsSheet = true
                }
            } else {
                // ログインボーナスなし → すぐ表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isShowingOtherAppsSheet = true
                }
            }
        }
    }
    
    func isiPhone12Or13() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let width = min(screenSize.width, screenSize.height)
        let height = max(screenSize.width, screenSize.height)
        return abs(width - 390) < 1 && abs(height - 844) < 1
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authManager: AuthManager())
    }
}
