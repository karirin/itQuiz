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

class User: Identifiable {
    var id: String
    var userName: String
    var level: Int
    var experience: Int
    var avatars: [[String: Any]]
    var userMoney: Int
    var userHp: Int
    var userAttack: Int
    var userFlag: Int

    init(id: String, userName: String, level: Int, experience: Int, avatars: [[String: Any]], userMoney: Int, userHp: Int, userAttack: Int, userFlag: Int) {
        self.id = id
        self.userName = userName
        self.level = level
        self.experience = experience
        self.avatars = avatars
        self.userMoney = userMoney
        self.userHp = userHp
        self.userAttack = userAttack
        self.userFlag = userFlag
    }
}

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var experience: Int = 0
    @Published var level: Int = 1
    @Published var money: Int = 0
    @Published var userFlag: Int = 0
    @Published var avatars: [Avatar] = []
    @Published var didLevelUp: Bool = false
    @Published var userAvatars: [Avatar] = []
    
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
    
    func addAvatarToUser(avatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilの場合、失敗としてfalseを返す
            return
        }

        // ユーザーのアバターデータの参照を作成
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")

        // すべてのアバターを取得
        avatarsRef.observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error fetching avatars: \(error)")
                completion(false) // エラーが発生した場合、falseを返す
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
                completion(true) // トランザクションが完了した場合、trueを返す
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
                avatarRef.setValue(avatarData) { (error, ref) in
                    if let error = error {
                        print("Failed to add avatar to database:", error.localizedDescription)
                        completion(false) // 保存に失敗した場合、falseを返す
                        return
                    }
                    print("Successfully added avatar to database.")
                    completion(true) // 保存に成功した場合、trueを返す
                }
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
    
    func saveUserToDatabase(userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let userData: [String: Any] = ["userName": userName, "userMoney": 0, "userHp": 100, "userAttack": 20, "tutorialNum": 1, "userFlag": 0]
        
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                return
            }
            print("Successfully saved user to database.")
        }
        completion(true)
    }
    
    func fetchUserInfo(completion: @escaping (String?, [[String: Any]]?, Int?, Int?, Int?, Int?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil, nil, nil, nil, nil)
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let avatarsData = data["avatars"] as? [String:[String: Any]],
               let userMoney = data["userMoney"] as? Int,
               let userHp = data["userHp"] as? Int,
               let userAttack = data["userAttack"] as? Int,
               let tutorialNum = data["tutorialNum"] as? Int {  // 追加

                var filteredAvatars: [[String: Any]] = []
                for (_, avatarData) in avatarsData {
                    if avatarData["usedFlag"] as? Int == 1 {
                        filteredAvatars.append(avatarData)
                    }
                }
                
                completion(userName, filteredAvatars, userMoney, userHp, userAttack, tutorialNum)  // 追加
            } else {
                completion(nil, nil, nil, nil, nil, nil)  // 追加
            }
        }
    }

    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
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
    
    func switchAvatar(to newAvatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilなので、失敗としてfalseを返します。
            return
        }
        
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                let avatarKey = childSnapshot.key
                let avatarRef = avatarsRef.child(avatarKey)
                avatarRef.updateChildValues(["usedFlag": 0])
            }
            
            if let avatarKey = snapshot.children.allObjects.first(where: { (child) -> Bool in
                guard let childSnapshot = child as? DataSnapshot,
                      let avatarData = childSnapshot.value as? [String: Any],
                      let name = avatarData["name"] as? String else { return false }
                return name == newAvatar.name
            }) as? DataSnapshot {
                let avatarRef = avatarsRef.child(avatarKey.key)
                avatarRef.updateChildValues(["usedFlag": 1]) { (error, ref) in
                    if let error = error {
                        print("Failed to update avatar: \(error.localizedDescription)")
                        completion(false) // 更新に失敗したので、falseを返します。
                    } else {
                        print("Successfully updated avatar.")
                        self.fetchAvatars {
                            completion(true) // 更新に成功したので、trueを返します。
                        }
                    }
                }
            } else {
                completion(false) // 新しいアバターが見つからなかったので、falseを返します。
            }
        }
    }

    
//    func addExperience(points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
//        guard let userId = user?.uid else {
//            onFailure(nil)
//            return
//        }
//        let userRef = Database.database().reference().child("users").child(userId)
//        userRef.observeSingleEvent(of: .value) { (snapshot) in
//
//            if let data = snapshot.value as? [String: Any] {
//                let currentExperience = data["experience"] as? Int ?? 0
//                var newExperience = currentExperience + points
//
//                while newExperience >= self.level * 100 {
//                    newExperience -= self.level * 100
//                    print("self.level1:\(self.level)")
//                    self.level += 1
//                    print("self.level2:\(self.level)")
//                    self.didLevelUp = true
//                    self.updateStatsUponLevelUp()
//                }
//
//                self.experience = newExperience
//
//                let userData: [String: Any] = ["experience": self.experience, "level": self.level]
//                print("userData")
//                print(userData)
//                userRef.updateChildValues(userData) { (error, ref) in
//                    if error == nil {
//                        self.saveEarnedTitles()
//                        onSuccess()  // 成功時のコールバックを呼ぶ
//                    } else {
//                        onFailure(error)  // エラー時のコールバックを呼ぶ
//                    }
//                }
//            }
//        }
//    }
    
//    func addExperience(points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
//        guard let userId = user?.uid else {
//            onFailure(nil)
//            return
//        }
//        
//        let userRef = Database.database().reference().child("users").child(userId)
//        userRef.observeSingleEvent(of: .value) { (snapshot, errorString) in
//            if let errorString = errorString {
//                // Handle the error here
//                onFailure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
//                return
//            }
//            if let data = snapshot.value as? [String: Any] {
//                var currentExperience = data["experience"] as? Int ?? 0
//                var currentLevel = data["level"] as? Int ?? 1
//                
//                currentExperience += points
//                
//                while currentExperience >= currentLevel * 100 {
//                    currentExperience -= currentLevel * 100
//                    currentLevel += 1
//                    self.didLevelUp = true
//                    self.updateStatsUponLevelUp()
//                }
//                
//                let updatedData: [String: Any] = ["experience": currentExperience, "level": currentLevel]
//                userRef.updateChildValues(updatedData) { (error, ref) in
//                    if let error = error {
//                        onFailure(error)
//                    } else {
//                        self.experience = currentExperience
//                        self.level = currentLevel
////                        self.saveEarnedTitles()
//                        onSuccess()
//                    }
//                }
//            } else {
//                onFailure(nil)
//            }
//        }
//    }
    
    func addExperience(points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        guard let userId = user?.uid else {
            onFailure(nil)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot, errorString) in
            if let errorString = errorString {
                onFailure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            if let data = snapshot.value as? [String: Any] {
                var currentExperience = data["experience"] as? Int ?? 0
                var currentLevel = data["level"] as? Int ?? 1

                currentExperience += points

                while currentExperience >= currentLevel * 100 {
                    currentExperience -= currentLevel * 100
                    currentLevel += 1
                    self.didLevelUp = true
                    self.updateStatsUponLevelUp()

                    if currentLevel == 3 {
                        // レベル3に達した場合、称号を保存
                        self.saveTitleForUser(userId: userId, title: "レベル３")
                    } else if currentLevel == 5 {
                        self.saveTitleForUser(userId: userId, title: "レベル５")
                    } else if currentLevel == 10 {
                        self.saveTitleForUser(userId: userId, title: "レベル10")
                    }
                }

                let updatedData: [String: Any] = ["experience": currentExperience, "level": currentLevel]
                userRef.updateChildValues(updatedData) { (error, ref) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        self.experience = currentExperience
                        self.level = currentLevel
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }
    
    func checkTitles(userId: String, title: String, completion: @escaping (Bool) -> Void) {
        let titlesRef = Database.database().reference().child("titles").child(userId)

        titlesRef.observeSingleEvent(of: .value, with: { snapshot in
            if let titlesData = snapshot.value as? [String: Bool] {
                // 指定された称号が存在するかチェックし、その結果を返す
                completion(titlesData[title] ?? false)
            } else {
                // `titles` データが存在しない場合は false を返す
                completion(false)
            }
        })
    }

    
    func saveTitleForUser(userId: String, title: String) {
        let titleRef = Database.database().reference().child("titles").child(userId)
        // 辞書形式でデータを追加する
        let titleData = [title: true] // または任意の値
        titleRef.updateChildValues(titleData) { error, ref in
            if let error = error {
                print("Error saving title: \(error)")
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
    
    func fetchUserFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userFlag = data["userFlag"] as? Int ?? 0
                print("self.userFlag:\(self.userFlag)")
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
    
    func saveLastLoginDate(userId: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.updateChildValues(["lastLoginDate": "\(Date())"]) { (error, _) in
            if let error = error {
                print("Error saving last login date: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func fetchLastLoginDate(userId: String, completion: @escaping (Date?) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.child("lastLoginDate").observeSingleEvent(of: .value) { (snapshot) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            if let dateString = snapshot.value as? String, let date = dateFormatter.date(from: dateString) {
                completion(date)
            } else {
                completion(nil)
            }
        }
    }


//    func checkForTitles(completion: @escaping ([Title]) -> Void) {
//        guard let userId = user?.uid else {
//            completion([])
//            return
//        }
//        
//        let userRef = Database.database().reference().child("users").child(userId)
//        userRef.observeSingleEvent(of: .value) { (snapshot) in
//            if let data = snapshot.value as? [String: Any], let userLevel = data["level"] as? Int {
//                var earnedTitles: [Title] = []
//
////                print("userLevel:\(userLevel)")
//                if userLevel >= 3 {
//                    earnedTitles.append(Title(name: "レベル３達成", condition: "レベル3に到達", description: "レベル3に到達した証"))
//                }
//                if userLevel >= 10 {
//                    earnedTitles.append(Title(name: "初級レベルクリア", condition: "初級レベルのクイズを全てクリア", description: "初級レベルのクイズを全てクリアした証"))
//                }
//
//                completion(earnedTitles)
//            } else {
//                completion([])
//            }
//        }
//    }
    
//    func fetchEarnedTitles(completion: @escaping ([Title]) -> Void) {
//        guard let userId = user?.uid else { return }
//        let userRef = Database.database().reference().child("users").child(userId).child("titles")
//        userRef.observeSingleEvent(of: .value) { (snapshot) in
//            var fetchedTitles: [Title] = []
//            if let titlesData = snapshot.value as? [String] {
//                self.checkForTitles { availableTitles in
//                    for titleName in titlesData {
//                        if let title = availableTitles.first(where: { $0.name == titleName }) {
//                            fetchedTitles.append(title)
//                        }
//                    }
//                    completion(fetchedTitles)
//                }
//            } else {
//                completion([])
//            }
//        }
//    }
    
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
    
//    private func saveEarnedTitles() {
//        guard let userId = user?.uid else { return }
//        let userRef = Database.database().reference().child("users").child(userId).child("titles")
//        
//        checkForTitles { titles in
//            var titlesData: [String] = []
//            for title in titles {
//                titlesData.append(title.name)
//            }
//            userRef.setValue(titlesData)
//        }
//    }
    
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
    
    func decreaseRareUserMoney(by amount: Int = 600, completion: @escaping (Bool) -> Void) {
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
    
    func updateUserFlag(userId: String, userFlag: Int) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["userFlag": userFlag]) { error, _ in
            if let error = error {
                print("Error updating userFlag: \(error)")
            } else {
                print("userFlag successfully updated")
            }
        }
    }
    
    func saveElapsedTime(category: String, elapsedTime: TimeInterval, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // ユーザーIDがnilの場合、失敗としてfalseを返す
            return
        }

        // ユーザーの経過時間データの参照を作成
        let userRef = Database.database().reference().child("users").child(userId)

        // 経過時間を保存する辞書を作成
        let elapsedTimeData: [String: Any] = ["タイム": elapsedTime]

        // カテゴリに応じて保存する場所を指定
        userRef.child(category).setValue(elapsedTimeData) { (error, ref) in
            if let error = error {
                print("Failed to save elapsed time:", error.localizedDescription)
                completion(false) // 保存に失敗した場合、falseを返す
                return
            }
            print("Successfully saved elapsed time.")
            completion(true) // 保存に成功した場合、trueを返す
        }
    }
    
    struct QuizTotal {
        var totalAnswers: Int
    }
    
    func fetchTotalAnswersData(userId: String, completion: @escaping ([QuizLevel: QuizTotal], Int) -> Void) {
        let answersRef = Database.database().reference().child("answers").child(userId)

        answersRef.observeSingleEvent(of: .value, with: { snapshot in
            var totalData = [QuizLevel: QuizTotal]()
            var totalAnswers = 0 // 全体の回答数の合計を格納する変数

            // 各クイズレベルでループ
            for level in QuizLevel.allCases {
                var totalAnswersForLevel = 0

                // 指定されたレベルの日付別データにアクセス
                let levelSnapshot = snapshot.childSnapshot(forPath: level.description)
                if levelSnapshot.exists() {
                    for dateChild in levelSnapshot.children {
                        if let dateSnapshot = dateChild as? DataSnapshot,
                           let answersCount = dateSnapshot.value as? Int {
                            totalAnswersForLevel += answersCount
                        }
                    }
                }

                totalData[level] = QuizTotal(totalAnswers: totalAnswersForLevel)
                totalAnswers += totalAnswersForLevel // 合計回答数に加算
            }

            print("totalData:\(totalData)")
            print("Total Answers for all levels: \(totalAnswers)") // 全レベルの合計回答数を出力
            completion(totalData, totalAnswers) // コンプリーションハンドラーに合計回答数も渡す
        })
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

