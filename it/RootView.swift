//
//  RootView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/17.
//

import SwiftUI

class SoundSettings: ObservableObject {
    @Published var isSoundOn: Bool = true
}

struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @State static private var showExperienceModalPreview = false
    var soundSettings = SoundSettings()

    var body: some View {
            if authManager.user == nil {
                SignUp()
            } else {
                ContentView()
                    .environmentObject(soundSettings)
            }
    }
}
