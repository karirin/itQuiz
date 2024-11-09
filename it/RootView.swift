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
            if !isActive {
                SplashScreenView()
            } else if isUserExists == false || isUserExists == nil {
                TopView()
            } else {
                TopView()
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
