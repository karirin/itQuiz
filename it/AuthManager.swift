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
    @Published var money: Int = 0 // 追加: ユーザーの所持金

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
    
    func fetchUserInfo(completion: @escaping (String?, String?, Int?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil, 0)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot, errorString) in
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let userIcon = data["userIcon"] as? String,
               let userMoney = data["money"] as? Int {
                completion(userName, userIcon, userMoney)
            } else {
                completion(nil, nil, nil)
            }
        }
    }
    
    func addExperience(points: Int) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在の経験値を取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let currentExperience = data["experience"] as? Int ?? 0
                
                // 現在の経験値に新しく加算する経験値を加える
                var newExperience = currentExperience + points
                
                // レベルアップの条件を確認
                while newExperience >= self.level * 100 {
                    newExperience -= self.level * 100  // 現在のレベル×100を引いて余りを計算
                    self.level += 1    // レベルを1つ上げる
                }
                
                self.experience = newExperience
                print("experience:\(self.experience)")
                print("level:\(self.level)")
                
                // 更新された経験値とレベルをデータベースに保存
                let userData: [String: Any] = ["experience": self.experience, "level": self.level]
                userRef.updateChildValues(userData)
            }
        }
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
    
    func addMoney(amount: Int) {
            guard let userId = user?.uid else { return }
            
            let userRef = Database.database().reference().child("users").child(userId)
            
            // 現在の所持金を取得
            userRef.observeSingleEvent(of: .value) { (snapshot) in
                if let data = snapshot.value as? [String: Any] {
                    let currentMoney = data["money"] as? Int ?? 0
                    
                    // 新しく獲得するお金を加える
                    let newMoney = currentMoney + amount
                    
                    self.money = newMoney
                    print("money:\(self.money)")
                    
                    // 更新された所持金をデータベースに保存
                    let userData: [String: Any] = ["money": self.money]
                    userRef.updateChildValues(userData)
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

