//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase

struct Avatar: Equatable {
    var name: String
    var attack: Int
    var health: Int
    var usedFlag: Int
    var count: Int 
}

struct User {
    var userName: String
    var avatars: [Avatar]
}

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var experience: Int = 0
    @Published var level: Int = 1
    @Published var money: Int = 0
    @Published var avatars: [Avatar] = []
    @Published var didLevelUp: Bool = false
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
    
    func addAvatarToUser(avatar: Avatar) {
        guard let userId = user?.uid else { return }

        // ユーザーのアバターデータの参照を作成
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")

        // すべてのアバターを取得
        avatarsRef.observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error fetching avatars: \(error)")
                return
            }
            
            var avatarExists = false
            var existingRef: DatabaseReference?

            // 各アバターをループして、新しいアバターが既存のものと一致するか確認
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   name == avatar.name {
                    avatarExists = true
                    existingRef = childSnapshot.ref
                    break
                }
            }

            if avatarExists, let existingRef = existingRef {
                existingRef.child("count").runTransactionBlock { currentData in
                    var count = currentData.value as? Int ?? 0
                    count += 1
                    currentData.value = count
                    return TransactionResult.success(withValue: currentData)
                }
            } else {
                // 新しいアバターをデータベースに追加
                let avatarRef = avatarsRef.childByAutoId()
                let avatarData: [String: Any] = [
                    "name": avatar.name,
                    "attack": avatar.attack,
                    "health": avatar.health,
                    "usedFlag": avatar.usedFlag,
                    "count": 1  // 初期カウント値を設定
                ]
                avatarRef.setValue(avatarData)
            }
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
    
    func saveUserToDatabase(userName: String) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let userData: [String: Any] = ["userName": userName, "userMoney": 0, "userHp": 100, "userAttack": 20]
        
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                return
            }
            print("Successfully saved user to database.")
        }
    }
    
    func fetchUserInfo(completion: @escaping (String?, [[String: Any]]?, Int?, Int?, Int?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil, nil, nil, nil)
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let avatarsData = data["avatars"] as? [String:[String: Any]], // Adjust this line
               let userMoney = data["userMoney"] as? Int,
               let userHp = data["userHp"] as? Int,
               let userAttack = data["userAttack"] as? Int {
                print("test1")
                // usedFlagが1のアバターのみをフィルタリング
                var filteredAvatars: [[String: Any]] = []
                for (_, avatarData) in avatarsData {
                    if avatarData["usedFlag"] as? Int == 1 {
                        filteredAvatars.append(avatarData)
                    }
                }
                
                completion(userName, filteredAvatars, userMoney, userHp, userAttack)
            } else {
                completion(nil, nil, nil, nil, nil)
            }
        }
    }
    
    func fetchAvatars(completion: @escaping () -> Void) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
        userRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var newAvatars: [Avatar] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   let attack = avatarData["attack"] as? Int,
                   let health = avatarData["health"] as? Int,
                   let usedFlag = avatarData["usedFlag"] as? Int,
                   let count = avatarData["count"] as? Int {
                    let avatar = Avatar(name: name, attack: attack, health: health, usedFlag: usedFlag, count: count)
                    newAvatars.append(avatar)
                }
            }
            DispatchQueue.main.async {
                self.avatars = newAvatars
            }

            completion() // データがフェッチされた後にクロージャを呼び出す
        }
    }
    
    func updateUsedFlag(for avatar: Avatar, to newValue: Int) -> Avatar {
        return Avatar(name: avatar.name, attack: avatar.attack, health: avatar.health, usedFlag: newValue, count: avatar.count)
    }
    
    func switchAvatar(to newAvatar: Avatar) {
        guard let userId = user?.uid else { return }
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")

        // すべてのアバターのusedFlagを0に設定
        avatarsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                let avatarKey = childSnapshot.key
                let avatarRef = avatarsRef.child(avatarKey)
                avatarRef.updateChildValues(["usedFlag": 0])
            }

            // 新しいアバターのusedFlagを1に設定
            if let avatarKey = snapshot.children.allObjects.first(where: { (child) -> Bool in
                guard let childSnapshot = child as? DataSnapshot,
                      let avatarData = childSnapshot.value as? [String: Any],
                      let name = avatarData["name"] as? String else { return false }
                return name == newAvatar.name
            }) as? DataSnapshot {
                let avatarRef = avatarsRef.child(avatarKey.key)
                avatarRef.updateChildValues(["usedFlag": 1])
            }

            // avatars配列を手動で更新
            self.fetchAvatars {}
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
                    
                    // ここで攻撃力とHPを更新
                    self.updateStatsUponLevelUp()
                }
                
                self.experience = newExperience
                
                // 更新された経験値とレベルをデータベースに保存
                let userData: [String: Any] = ["experience": self.experience, "level": self.level]
                userRef.updateChildValues(userData) { (error, ref) in
                    if error == nil {
                        // 称号の確認と保存
                        self.saveEarnedTitles()
                        self.didLevelUp = true
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
                    let currentMoney = data["userMoney"] as? Int ?? 0
                    
                    // 新しく獲得するお金を加える
                    let newMoney = currentMoney + amount
                    
                    self.money = newMoney
                    
                    // 更新された所持金をデータベースに保存
                    let userData: [String: Any] = ["userMoney": self.money]
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
                completion(date)
            } else {
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
    
    func updateStatsUponLevelUp() {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        
        // レベルに応じて攻撃力とHPを計算
        let newAttack = 20 + (level - 1) * 2
        let newHp = 100 + (level - 1) * 10
        
        // データベースに新しい攻撃力とHPを保存
        let updatedStats: [String: Any] = ["userAttack": newAttack, "userHp": newHp]
        userRef.updateChildValues(updatedStats) { (error, ref) in
            if let error = error {
                print("Failed to update stats:", error.localizedDescription)
                return
            }
            print("Successfully updated stats.")
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
    
    func checkIfUserIdExists(userId: String, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func decreaseUserMoney(by amount: Int = 300, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在のuserMoneyを取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                var currentMoney = data["userMoney"] as? Int ?? 0
                
                // userMoneyからamountを引く
                currentMoney -= amount
                
                // 新しいuserMoneyの値をデータベースに保存
                let userData: [String: Any] = ["userMoney": currentMoney]
                userRef.updateChildValues(userData) { (error, ref) in
                    if let error = error {
                        print("Failed to update userMoney:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully updated userMoney.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func getUserMoney(completion: @escaping (Int) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let currentMoney = data["userMoney"] as? Int ?? 0
                completion(currentMoney)
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

