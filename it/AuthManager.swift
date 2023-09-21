//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase

class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var experience: Int = 0
    @Published var level: Int = 1
    @Published var money: Int = 0
    @State private var earnedTitles: [Title] = []
    
    init() {
        user = Auth.auth().currentUser
        if user == nil {
            anonymousSignIn()
        }
    }

    static let shared: AuthManager = {
        let instance = AuthManager()
        return instance
    }()

    var onLoginCompleted: (() -> Void)?
    var currentUserId: String? {
        print("user?.uid:\(user?.uid)")
        return user?.uid
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
        let userData: [String: Any] = ["userName": userName, "userIcon": userIcon, "avatar": userIcon,"userMoney": 0]
        
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
            print("test1")
            completion(nil, nil, 0)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let userIcon = data["userIcon"] as? String,
               let userMoney = data["userMoney"] as? Int {
                print("test3")
                completion(userName, userIcon, userMoney)
            } else {
                completion(nil, nil, nil)
            }
        }
    }
    
    func addExperience(points: Int) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
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
                userRef.updateChildValues(userData) { (error, ref) in
                    if error == nil {
                        // 称号の確認と保存
                        self.saveEarnedTitles()
                    }
                }
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
    
    func saveLastClickedDate(userId: String, completion: @escaping (Bool) -> Void) {
            let ref = Database.database().reference().child("users").child(userId)
            ref.updateChildValues(["lastClickedDate": "\(Date())"]) { (error, _) in
                if let error = error {
                    print("Error saving last clicked date: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }

    func fetchLastClickedDate(userId: String, completion: @escaping (Date?) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.child("lastClickedDate").observeSingleEvent(of: .value) { (snapshot) in
            
            // DateFormatterのインスタンスを作成
            let dateFormatter = DateFormatter()
            
            // フォーマットを設定
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            // このフォーマッターを使用して、文字列から日付に変換
            if let dateString = snapshot.value as? String, let date = dateFormatter.date(from: dateString) {
                print("date:\(date)")
                completion(date)
            } else {
                print("nil")
                completion(nil)
            }
        }
    }

    func checkForTitles(completion: @escaping ([Title]) -> Void) {
        guard let userId = user?.uid else {
            completion([])
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any], let userLevel = data["level"] as? Int {
                var earnedTitles: [Title] = []

                print("userLevel:\(userLevel)")
                if userLevel >= 3 {
                    earnedTitles.append(Title(name: "レベル３達成", condition: "レベル3に到達", description: "レベル3に到達した証"))
                }
                if userLevel >= 10 {
                    earnedTitles.append(Title(name: "初級レベルクリア", condition: "初級レベルのクイズを全てクリア", description: "初級レベルのクイズを全てクリアした証"))
                }

                completion(earnedTitles)
            } else {
                completion([])
            }
        }
    }
    
    func fetchEarnedTitles(completion: @escaping ([Title]) -> Void) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("titles")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            var fetchedTitles: [Title] = []
            if let titlesData = snapshot.value as? [String] {
                print("titlesData:\(titlesData)")
                self.checkForTitles { availableTitles in
                    for titleName in titlesData {
                        if let title = availableTitles.first(where: { $0.name == titleName }) {
                            fetchedTitles.append(title)
                        }
                    }
                    completion(fetchedTitles)
                }
            } else {
                completion([])
            }
        }
    }

    
    private func saveEarnedTitles() {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("titles")
        
        checkForTitles { titles in
            var titlesData: [String] = []
            for title in titles {
                titlesData.append(title.name)
            }
            userRef.setValue(titlesData)
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

