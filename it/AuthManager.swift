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
    @Published var experience: Int = 0
    @Published var level: Int = 1

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
    
    func saveUserToDatabase(userName: String, userIcon: String) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let userData: [String: Any] = ["userName": userName, "userIcon": userIcon]
        
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                return
            }
            print("Successfully saved user to database.")
        }
    }
    
    func fetchUserInfo(completion: @escaping (String?, String?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let userIcon = data["userIcon"] as? String {
                completion(userName, userIcon)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func addExperience(points: Int) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        experience += points
        level = calculateLevel(experience: experience)
        
        let userData: [String: Any] = ["experience": experience, "level": level]
        userRef.updateChildValues(userData)
    }
    
    func calculateLevel(experience: Int) -> Int {
        return experience / 100 + 1
    }

    func fetchUserExperienceAndLevel() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.experience = data["experience"] as? Int ?? 0
                self.level = data["level"] as? Int ?? 1
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

