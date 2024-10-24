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

    var body: some View {
        Group {
            if !isActive && isUserExists == nil {
                // ユーザー存在チェック中の表示 (例: ローディングインジケータ)
//                ActivityIndicator()
                SplashScreenView()
            } else if isUserExists == false || isUserExists == nil {
                SignUp()
            } else {
//                ContentView(isPresentingQuizBeginnerList: .constant(false), isPresentingAvatarList: .constant(false))
//                ContentView()
                TopView()
//                    .onAppear{
//                            requestReview()
//                    }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authManager: AuthManager())
    }
}
