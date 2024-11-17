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
    var adminFlag: Int
    var rankMatchPoint: Int
    var rank: Int

    init(id: String, userName: String, level: Int, experience: Int, avatars: [[String: Any]], userMoney: Int, userHp: Int, userAttack: Int, userFlag: Int, adminFlag: Int,rankMatchPoint: Int,rank: Int) {
        self.id = id
        self.userName = userName
        self.level = level
        self.experience = experience
        self.avatars = avatars
        self.userMoney = userMoney
        self.userHp = userHp
        self.userAttack = userAttack
        self.userFlag = userFlag
        self.adminFlag = adminFlag
        self.rankMatchPoint = rankMatchPoint
        self.rank = rank
    }
}

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var experience: Int = 0
    @Published var rankMatchPoint: Int = 0
    @Published var rank: Int = 0
    @Published var level: Int = 1
    @Published var money: Int = 0
    @Published var userFlag: Int = 0
    @Published var userCsFlag: Int = 0
    @Published var adminFlag: Int = 0
    @Published var avatars: [Avatar] = []
    @Published var rankUp: Bool = false
    @Published var rankDown: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var userAvatars: [Avatar] = []
    @Published var rewardFlag: Int = 1
    @Published var story: Int = 0
    @Published var userPreFlag: Int = 0
    @State private var selectedAvatar: Avatar?
    @Published var loginCount: Int = 0 // 追加: ログイン回数を保持
    @Published var loginBonus: Int = 0  // 追加: 現在のボーナス額を保持
    @Published var usedAvatars: [Avatar] = []
    
    init() {
        user = Auth.auth().currentUser
//        if user == nil {
//            anonymousSignIn()
//        }
    }
    
    static let shared: AuthManager = {
        let instance = AuthManager()
        return instance
    }()
    
    var onLoginCompleted: (() -> Void)?
    var currentUserId: String? {
//        print("user?.uid:\(user?.uid)")
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
    
    func anonymousSignIn(completion: @escaping () -> Void) {
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
    
    func deleteUserAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func fetchUserStory() {
        guard let userId = user?.uid else { return }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.child("story").observeSingleEvent(of: .value) { snapshot in
            if let story = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.story = story
                }
            }
        }
    }
    
    func updateStory(story: Int, completion: @escaping (Bool) -> Void) {
            guard let userId = user?.uid else {
                completion(false) // ユーザーIDがnilの場合は失敗
                return
            }

            let userRef = Database.database().reference().child("users").child(userId)
            userRef.child("story").setValue(story) { error, _ in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to update story:", error.localizedDescription)
                        completion(false) // 更新に失敗した場合
                    } else {
                        print("Successfully updated story.")
                        self.story = story // AuthManagerのstoryプロパティを更新
                        completion(true) // 更新に成功した場合
                    }
                }
            }
        }
    
    func saveUserToDatabase(userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        // ユーザーのリファレンスを作成
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 選択されたアバターの作成
        let selectedAvatar = Avatar(name: self.selectedAvatar?.name ?? "ネッキー", attack: 20, health: 20, usedFlag: 1, count: 1)
        
        // ユーザーデータを設定（アバターデータは後で設定）
        let userData: [String: Any] = [
            "userName": userName,
            "userMoney": 300,
            "userHp": 100,
            "userAttack": 20,
            "tutorialNum": 0,
            "userFlag": 0
        ]

        // ユーザーデータを保存
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                completion(false)
                return
            }
            print("Successfully saved user to database.")
            
            // アバターデータを保存
            let avatarRef = userRef.child("avatars").childByAutoId()
            let avatarData: [String: Any] = [
                "name": selectedAvatar.name,
                "attack": selectedAvatar.attack,
                "health": selectedAvatar.health,
                "usedFlag": selectedAvatar.usedFlag,
                "count": selectedAvatar.count
            ]
            
            avatarRef.setValue(avatarData) { (error, ref) in
                if let error = error {
                    print("Failed to save avatar to database:", error.localizedDescription)
                    completion(false)
                    return
                }
                print("Successfully saved avatar to database.")
                completion(true)
            }
        }
    }
    
    func fetchUsedAvatars(completion: @escaping ([Avatar]) -> Void) {
            guard let userId = user?.uid else {
                completion([])
                return
            }
            
            let avatarsRef = Database.database().reference()
                .child("users")
                .child(userId)
                .child("avatars")
            
            // usedFlag が 1 のアバターのみを取得するクエリ
            let query = avatarsRef.queryOrdered(byChild: "usedFlag").queryEqual(toValue: 1)
            
            query.observeSingleEvent(of: .value) { snapshot in
                var usedAvatars: [Avatar] = []
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let avatarData = childSnapshot.value as? [String: Any],
                       let name = avatarData["name"] as? String,
                       let attack = avatarData["attack"] as? Int,
                       let health = avatarData["health"] as? Int,
                       let usedFlag = avatarData["usedFlag"] as? Int,
                       let count = avatarData["count"] as? Int {
                        let avatar = Avatar(name: name, attack: attack, health: health, usedFlag: usedFlag, count: count)
                        usedAvatars.append(avatar)
                    }
                }
                DispatchQueue.main.async {
                    self.usedAvatars = usedAvatars
                    completion(usedAvatars)
                }
            }
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
//                            print("filteredAvatars:\(filteredAvatars)")
                        }
                    }
                    
                    completion(userName, filteredAvatars, userMoney, userHp, userAttack, tutorialNum)  // 追加
                } else {
                    completion(nil, nil, nil, nil, nil, nil)  // 追加
                }
            }
        }
    
    func fetchCurrentUserAdminFlag() {
        guard let userId = user?.uid else {
            print("User is not logged in")
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self, let data = snapshot.value as? [String: Any], let adminFlag = data["adminFlag"] as? Int else {
                print("Failed to fetch user data or adminFlag is missing")
                return
            }
            DispatchQueue.main.async {
                self.adminFlag = adminFlag
                print("Updated adminFlag to \(adminFlag)")
            }
        })
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
    
    func updateUserFlag(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateUserName(userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userName": userName]
        
        userRef.updateChildValues(updates) { error, _ in
            if let error = error {
                print("Failed to update userName: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully updated userName.")
                completion(true)
            }
        }
    }
    
    func updateUserCsFlag(userId: String, userCsFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userCsFlag": userCsFlag]
        print(updates)
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updatePreFlag(userId: String, userPreFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userPreFlag": userPreFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchPreFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.userPreFlag = data["userPreFlag"] as? Int ?? 0
                print("self.userPreFlag:\(self.userPreFlag)")
            }
        }
    }
    
    func updateContact(userId: String, newContact: String, completion: @escaping (Bool) -> Void) {
        // contactテーブルの下の指定されたuserIdの参照を取得
        let contactRef = Database.database().reference().child("contacts").child(userId)
        
        // まず現在のcontactの値を読み取る
        contactRef.observeSingleEvent(of: .value, with: { snapshot in
            // 既存の問い合わせ内容を保持する変数を準備
            var contacts: [String] = []
            
            // 現在の問い合わせ内容がある場合、それを読み込む
            if let currentContacts = snapshot.value as? [String] {
                contacts = currentContacts
            }
            
            // 新しい問い合わせ内容をリストに追加
            contacts.append(newContact)
            
            // データベースを更新する
            contactRef.setValue(contacts, withCompletionBlock: { error, _ in
                if let error = error {
                    print("Error updating contact: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }) { error in
            print(error.localizedDescription)
            completion(false)
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
    
    func addRankMatchPoints(for userId: String, points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                // 現在のrankMatchPointとrankを取得、またはデフォルト値として100と1を設定
                var currentRankMatchPoints = data["rankMatchPoint"] as? Int ?? 100
                var currentRank = data["rank"] as? Int ?? 1
                
                // 100の位が変わるかどうかをチェック
                let previousHundred = currentRankMatchPoints / 100
                currentRankMatchPoints += points
                let newHundred = currentRankMatchPoints / 100

                if newHundred > previousHundred {
                    // 100の位が増加した場合、rankをインクリメント
                    currentRank += 1
                    self.rankUp = true
                }

                // 更新されたデータでデータベースを更新
                let updatedData: [String: Any] = ["rankMatchPoint": currentRankMatchPoints, "rank": currentRank]
                userRef.updateChildValues(updatedData) { (error, ref) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }

    
    func subtractRankMatchPoints(for userId: String, points: Int, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                // 現在のrankMatchPointとrankを取得、またはデフォルト値として100と1を設定
                var currentRankMatchPoints = data["rankMatchPoint"] as? Int ?? 100
                var currentRank = data["rank"] as? Int ?? 1

                // 100の位が変わるかどうかをチェック
                let previousHundred = currentRankMatchPoints / 100
                currentRankMatchPoints -= points // ポイントを減算
                let newHundred = currentRankMatchPoints / 100

                if newHundred < previousHundred {
                    // 100の位が減少した場合、rankをデクリメント（ただし、rankが1より小さくならないようにする）
                    currentRank = max(currentRank - 1, 1)
                    self.rankDown = true
                }

                // 更新されたデータでデータベースを更新
                let updatedData: [String: Any] = ["rankMatchPoint": currentRankMatchPoints, "rank": currentRank]
                userRef.updateChildValues(updatedData) { (error, _) in
                    if let error = error {
                        onFailure(error)
                    } else {
                        onSuccess()
                    }
                }
            } else {
                onFailure(nil)
            }
        }
    }

    
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
    
    func fetchUserRankMatchPoint() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            var rankMatchPoint = 100 // デフォルト値を100に設定
            var rank = 1
            
            if let data = snapshot.value as? [String: Any] {
                // rankMatchPointが存在する場合は取得した値を使用
                if let existingRankMatchPoint = data["rankMatchPoint"] as? Int,
                   let existingRank = data["rank"] as? Int{
                    rankMatchPoint = existingRankMatchPoint
                    rank = existingRank
                    self.rankMatchPoint = existingRankMatchPoint
                    self.rank = existingRank
                } else {
                    // rankMatchPointが存在しない場合は、デフォルト値でデータベースを更新
                    userRef.updateChildValues(["rankMatchPoint": rankMatchPoint,"rank": rank])
                    self.rankMatchPoint = 100
                    self.rank = 1
                }
            }
            
            // rankMatchPointを使用する処理（必要に応じて）
            print("rankMatchPoint: \(self.rank)")
        }
    }

    
    func fetchUserRewardFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.rewardFlag = data["rewardFlag"] as? Int ?? 1
            }
        }
    }
    
    func fetchUserFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
//                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userFlag = data["userFlag"] as? Int ?? 0
                print("self.userFlag:\(self.userFlag)")
            }
        }
    }
    
    func fetchUserCsFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
//                print("data:\(data)")
//                self.experience = data["experience"] as? Int ?? 0
                self.userCsFlag = data["userCsFlag"] as? Int ?? 0
            }
        }
    }
    
    func addMoney(amount: Int) {
            guard let userId = user?.uid else { return }
            print("addMoney")
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
    
    /// 現在の日時をユーザーの最後のログイン日時として保存する
    func saveLastLoginDate(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let ref = Database.database().reference().child("users").child(userId)
        let currentTimestamp = Date().timeIntervalSince1970
        ref.updateChildValues(["lastLoginDate": currentTimestamp]) { (error, _) in
            if let error = error {
                print("最後のログイン日時の保存に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                print("最後のログイン日時を正常に保存しました。")
                completion(true)
            }
        }
    }

    /// ユーザーの最後のログイン日時を取得する
    func fetchLastLoginDate(completion: @escaping (Date?) -> Void) {
        guard let userId = currentUserId else {
            completion(nil)
            return
        }

        let ref = Database.database().reference().child("users").child(userId).child("lastLoginDate")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let timestamp = snapshot.value as? TimeInterval {
                let date = Date(timeIntervalSince1970: timestamp)
                completion(date)
            } else {
                completion(nil)
            }
        }
    }
    
    func daysBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: from)
        let toDate = calendar.startOfDay(for: to)
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return components.day ?? 0
    }
    
    /// ログインボーナスを表示すべきかどうかを判断する
    func shouldShowLoginBonus(completion: @escaping (Bool) -> Void) {
        fetchLastLoginDate { lastLoginDate in
            let calendar = Calendar.current
            let now = Date()
            if let lastLogin = lastLoginDate {
                if !calendar.isDate(lastLogin, inSameDayAs: now) {
                    // 前回のログインが異なる日に行われている
                    completion(true)
                } else {
                    // 前回のログインが同じ日
                    completion(false)
                }
            } else {
                // 最後のログイン日時が記録されていない場合（初回ログイン）
                completion(true)
            }
        }
    }

    /// ログインボーナスをユーザーに付与する
    func grantLoginBonus(amount: Int, completion: @escaping (Bool) -> Void) {
        addLoginMoney(amount: amount) { success in
            if success {
                print("ログインボーナスを付与: +\(amount) コイン")
                self.saveLastLoginDate { saveSuccess in
                    if saveSuccess {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func addLoginMoney(amount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在の所持金を取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any],
               var currentMoney = data["userMoney"] as? Int {
                // 新しい金額を計算
                currentMoney += amount
                
                // データベースを更新
                userRef.updateChildValues(["userMoney": currentMoney]) { error, _ in
                    if let error = error {
                        print("所持金の更新に失敗: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("所持金を正常に更新しました。新しい金額: \(currentMoney)")
                        completion(true)
                    }
                }
            } else {
                // userMoney が存在しない場合、新しく設定
                userRef.updateChildValues(["userMoney": amount]) { error, _ in
                    if let error = error {
                        print("所持金の初期設定に失敗: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("所持金を初期設定しました。金額: \(amount)")
                        completion(true)
                    }
                }
            }
        }
    }
    
    /// loginCount を取得する
    func fetchLoginCount(completion: @escaping (Int) -> Void) {
        guard let userId = currentUserId else {
            completion(0)
            return
        }

        let loginCountRef = Database.database().reference().child("users").child(userId).child("loginCount")
        loginCountRef.observeSingleEvent(of: .value) { snapshot in
            let count = snapshot.value as? Int ?? 0
            completion(count)
        }
    }

    /// loginCount をインクリメントする
    func incrementLoginCount(completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        let loginCountRef = Database.database().reference().child("users").child(userId).child("loginCount")
        loginCountRef.runTransactionBlock { currentData in
            var value = currentData.value as? Int ?? 0
            value += 1
            currentData.value = value > 5 ? 1 : value
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print("loginCount のインクリメントに失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                let updatedCount = snapshot?.value as? Int ?? 1
                DispatchQueue.main.async {
                    self.loginCount = updatedCount
                }
                print("loginCount を更新しました。新しい値: \(updatedCount)")
                completion(true)
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
    
    /// ログインボーナスをチェックし、付与する
    func checkAndGrantLoginBonus(completion: @escaping (Bool) -> Void) {
        fetchLastLoginDate { lastLoginDate in
            let now = Date()
            if let lastLogin = lastLoginDate {
                let days = self.daysBetween(lastLogin, now)
                var newLoginCount = 1
                if days == 1 {
                    // 連続ログイン
                    self.fetchLoginCount { currentCount in
                        newLoginCount = currentCount + 1
                        // 必要に応じて最大値を設定（例: 5日目まで）
                        if newLoginCount > 5 {
                            newLoginCount = 1
                        }
                        self.loginCount = newLoginCount
                        let bonus = self.getBonusAmount(for: newLoginCount)
                        self.loginBonus = bonus
                        // ボーナスを付与
                        self.grantLoginBonus(amount: bonus) { success in
                            if success {
                                // 最終ログイン日時を保存
                                self.saveLastLoginDate { saveSuccess in
                                    if saveSuccess {
                                        // loginCount をデータベースに更新
                                        self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                            if updateSuccess {
                                                completion(true)
                                            } else {
                                                completion(false)
                                            }
                                        }
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                completion(false)
                            }
                        }
                    }
                } else if days > 1 {
                    // 連続していないログイン（リセット）
                    newLoginCount = 1
                    self.loginCount = newLoginCount
                    let bonus = self.getBonusAmount(for: newLoginCount)
                    self.loginBonus = bonus
                    // ボーナスを付与
                    self.grantLoginBonus(amount: bonus) { success in
                        if success {
                            // 最終ログイン日時を保存
                            self.saveLastLoginDate { saveSuccess in
                                if saveSuccess {
                                    // loginCount をデータベースに更新
                                    self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                        if updateSuccess {
                                            completion(true)
                                        } else {
                                            completion(false)
                                        }
                                    }
                                } else {
                                    completion(false)
                                }
                            }
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    // 同日に複数回ログインした場合はボーナスを付与しない
                    completion(false)
                }
            } else {
                // 初回ログイン
                let newLoginCount = 1
                self.loginCount = newLoginCount
                let bonus = self.getBonusAmount(for: newLoginCount)
                self.loginBonus = bonus
                self.grantLoginBonus(amount: bonus) { success in
                    if success {
                        // 最終ログイン日時を保存
                        self.saveLastLoginDate { saveSuccess in
                            if saveSuccess {
                                // loginCount をデータベースに更新
                                self.updateLoginCount(to: newLoginCount) { updateSuccess in
                                    if updateSuccess {
                                        completion(true)
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                completion(false)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    /// loginCount に基づいてボーナス額を決定
    func getBonusAmount(for count: Int) -> Int {
        // 例として、1日目から10日目まで異なるボーナス額を設定
        let bonuses = [100, 300, 500, 800, 1000]
        return count <= 5 ? bonuses[count - 1] : 100
    }
    
    func updateLoginCount(to newCount: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["loginCount": newCount]) { error, _ in
            if let error = error {
                print("loginCount の更新に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                print("loginCount を \(newCount) に更新しました。")
                completion(true)
            }
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
    
    func updateRewardFlag(userId: String, userFlag: Int) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["rewardFlag": userFlag]) { error, _ in
            if let error = error {
                print("Error updating rewardFlag: \(error)")
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

//            print("totalData:\(totalData)")
//            print("Total Answers for all levels: \(totalAnswers)") // 全レベルの合計回答数を出力
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
                    self.authManager.anonymousSignIn(){}
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

