//
//  itApp.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import Firebase
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    var appState: AppState!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        self.appState = AppState()
        return true
    }
}

@main
struct itApp: App {
    @ObservedObject var authManager: AuthManager
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
        authManager = AuthManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager)
//            RewardView()
//            GachaView()
        }
    }
}
