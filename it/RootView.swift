//
//  RootView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/17.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @State static private var showExperienceModalPreview = false

    var body: some View {
        if authManager.user == nil {
            SignUp()
        } else {
            ContentView()
        }
    }
}
