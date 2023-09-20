//
//  itApp.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import Firebase

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}

@main
struct itApp: App {
    @ObservedObject var authManager: AuthManager

    init() {
        FirebaseApp.configure()
        authManager = AuthManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager)
//            GachaView()
        }
    }
}
