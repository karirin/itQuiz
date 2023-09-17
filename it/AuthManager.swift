//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase

extension AuthManager {
    var currentUserId: String? {
        return user?.uid
    }
}

class AuthManager: ObservableObject {
    @Published var user: User?

    static let shared: AuthManager = {
        let instance = AuthManager()
        return instance
    }()

    var onLoginCompleted: (() -> Void)?

       init() {
           user = Auth.auth().currentUser
           if user == nil {
               anonymousSignIn()
           }
       }

       func anonymousSignIn() {
           Auth.auth().signInAnonymously { result, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
               } else if let result = result {
                   print("Signed in anonymously with user ID: \(result.user.uid)")
                   self.user = result.user
                   self.onLoginCompleted?()
               }
           }
       }
    
    func createUser(name: String, icon: UIImage?) { // bioを追加
            guard let firebaseUser = Auth.auth().currentUser else { print("user")
                return }
            guard let image = icon, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let storageRef = Storage.storage().reference().child("\(firebaseUser.uid).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    print("Errorあ: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { result in
                        switch result {
                        case .success(let url):
                            // URLの取得に成功した場合の処理
                            print("Download URL: \(url)")
                        case .failure(let error):
                            // エラーが発生した場合の処理
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
   }

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn()
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}

