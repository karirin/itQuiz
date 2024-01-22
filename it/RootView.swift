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
    @State private var isUserExists: Bool? = nil
    @StateObject var appState = AppState()
    @Environment(\.requestReview) var requestReview

    var body: some View {
        Group {
            if isUserExists == nil {
                // ユーザー存在チェック中の表示 (例: ローディングインジケータ)
                ActivityIndicator()
            } else if isUserExists == false || isUserExists == nil {
                SignUp()
            } else {
//                ContentView(isPresentingQuizBeginnerList: .constant(false), isPresentingAvatarList: .constant(false))
//                ContentView()
                TopView()
                    .environmentObject(appState)
                    .onAppear{
                            requestReview()
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
        }
    }
}
