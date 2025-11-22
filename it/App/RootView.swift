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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isShowingOtherAppsSheet = true
                    }
                }
            }
        }
    }
    func isiPhone12Or13() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let width = min(screenSize.width, screenSize.height)
        let height = max(screenSize.width, screenSize.height)
        // iPhone 12,13 の画面サイズは約幅390ポイント、高さ844ポイント
        return abs(width - 390) < 1 && abs(height - 844) < 1
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authManager: AuthManager())
    }
}
