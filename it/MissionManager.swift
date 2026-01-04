//
//  MissionManager.swift
//  it
//
//  Created by hashimo ryoya on 2025/12/16.
//

import Foundation
import Firebase

class MissionManager: ObservableObject {
    @Published var missions: [Mission] = []
    @Published var isLoading = false
    
    static let shared = MissionManager()
    private let authManager = AuthManager.shared
    
    private init() {
        setupDefaultMissions()
    }
    
    // デフォルトミッションの設定
    private func setupDefaultMissions() {
        missions = [
            Mission(type: .answer,
                   title: "問題を14回解こう",
                   description: "ダンジョンで問題を14回解答しましょう",
                   targetCount: 14,
                   rewardCoin: 100,
                   rewardIcon: "🥐"),
            
            Mission(type: .correctAnswer,
                   title: "正解を4回しよう",
                   description: "問題に4回正解しましょう",
                   targetCount: 4,
                   rewardCoin: 50,
                   rewardIcon: "💎"),
            
            Mission(type: .avatar,
                   title: "おともを9体仲間にしよう",
                   description: "ガチャでおともを9体獲得しましょう",
                   targetCount: 9,
                   rewardCoin: 200,
                   rewardIcon: "🐾"),
            
            Mission(type: .gacha,
                   title: "ガチャを10回引こう",
                   description: "ガチャを10回引いてみましょう",
                   targetCount: 10,
                   rewardCoin: 150,
                   rewardIcon: "🎰"),
            
            Mission(type: .level,
                   title: "レベル4に到達しよう",
                   description: "経験値を貯めてレベル4に到達しましょう",
                   targetCount: 4,
                   rewardCoin: 300,
                   rewardIcon: "⭐"),
            
            Mission(type: .experience,
                   title: "経験値を500獲得しよう",
                   description: "問題に答えて経験値を500獲得しましょう",
                   targetCount: 500,
                   rewardCoin: 250,
                   rewardIcon: "📈"),
            
            Mission(type: .money,
                   title: "コインを1000枚集めよう",
                   description: "様々な方法でコインを1000枚集めましょう",
                   targetCount: 1000,
                   rewardCoin: 500,
                   rewardIcon: "💰")
        ]
    }
    
    // Firebaseからミッションデータを取得
    func fetchMissions(completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            completion(false)
            return
        }
        
        isLoading = true
        let missionsRef = Database.database().reference().child("missions").child(userId)
        
        missionsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if snapshot.exists(), let missionsData = snapshot.value as? [[String: Any]] {
                self.missions = missionsData.compactMap { dict in
                    guard let id = dict["id"] as? String,
                          let typeString = dict["type"] as? String,
                          let type = MissionType(rawValue: typeString),
                          let title = dict["title"] as? String,
                          let description = dict["description"] as? String,
                          let targetCount = dict["targetCount"] as? Int,
                          let currentCount = dict["currentCount"] as? Int,
                          let rewardCoin = dict["rewardCoin"] as? Int,
                          let rewardIcon = dict["rewardIcon"] as? String,
                          let isCompleted = dict["isCompleted"] as? Bool,
                          let isClaimed = dict["isClaimed"] as? Bool else {
                        return nil
                    }
                    
                    return Mission(id: id, type: type, title: title, description: description,
                                 targetCount: targetCount, currentCount: currentCount,
                                 rewardCoin: rewardCoin, rewardIcon: rewardIcon,
                                 isCompleted: isCompleted, isClaimed: isClaimed)
                }
            } else {
                // 初回の場合はデフォルトミッションを保存
                self.syncMissionsWithCurrentProgress()
                return
            }
            
            self.isLoading = false
            completion(true)
        }
    }
    
    // 現在の進捗状況と同期してミッションを初期化
    func syncMissionsWithCurrentProgress() {
        guard let userId = authManager.currentUserId else { return }
        
        let group = DispatchGroup()
        
        // 回答数の取得
        group.enter()
        authManager.fetchTotalAnswersData(userId: userId) { [weak self] (_, totalAnswers) in
            if let index = self?.missions.firstIndex(where: { $0.type == .answer }) {
                self?.missions[index].currentCount = totalAnswers
                if totalAnswers >= self?.missions[index].targetCount ?? 0 {
                    self?.missions[index].isCompleted = true
                }
            }
            group.leave()
        }
        
        // レベルの取得
        group.enter()
        authManager.fetchUserExperienceAndLevel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let index = self?.missions.firstIndex(where: { $0.type == .level }) {
                self?.missions[index].currentCount = self?.authManager.level ?? 1
                if (self?.authManager.level ?? 1) >= self?.missions[index].targetCount ?? 0 {
                    self?.missions[index].isCompleted = true
                }
            }
            
            // 経験値の設定
            if let index = self?.missions.firstIndex(where: { $0.type == .experience }) {
                self?.missions[index].currentCount = self?.authManager.experience ?? 0
                if (self?.authManager.experience ?? 0) >= self?.missions[index].targetCount ?? 0 {
                    self?.missions[index].isCompleted = true
                }
            }
            group.leave()
        }
        
        // コインの取得
        group.enter()
        authManager.getUserMoney { [weak self] money in
            if let index = self?.missions.firstIndex(where: { $0.type == .money }) {
                self?.missions[index].currentCount = money
                if money >= self?.missions[index].targetCount ?? 0 {
                    self?.missions[index].isCompleted = true
                }
            }
            group.leave()
        }
        
        // アバター数の取得
        group.enter()
        authManager.fetchAvatars { [weak self] in
            let avatarCount = self?.authManager.avatars.reduce(0) { $0 + $1.count } ?? 0
            if let index = self?.missions.firstIndex(where: { $0.type == .avatar }) {
                self?.missions[index].currentCount = avatarCount
                if avatarCount >= self?.missions[index].targetCount ?? 0 {
                    self?.missions[index].isCompleted = true
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.saveMissions { success in
                self?.isLoading = false
                print("Initial missions synced: \(success)")
            }
        }
    }
    
    // ミッションデータをFirebaseに保存
    func saveMissions(completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            completion(false)
            return
        }
        
        let missionsRef = Database.database().reference().child("missions").child(userId)
        let missionsData = missions.map { mission -> [String: Any] in
            return [
                "id": mission.id,
                "type": mission.type.rawValue,
                "title": mission.title,
                "description": mission.description,
                "targetCount": mission.targetCount,
                "currentCount": mission.currentCount,
                "rewardCoin": mission.rewardCoin,
                "rewardIcon": mission.rewardIcon,
                "isCompleted": mission.isCompleted,
                "isClaimed": mission.isClaimed
            ]
        }
        
        missionsRef.setValue(missionsData) { error, _ in
            completion(error == nil)
        }
    }
    
    // ミッションの進捗を更新（type指定）
    func updateMissionProgress(type: MissionType, increment: Int = 1, completion: @escaping (Bool) -> Void) {
        guard let index = missions.firstIndex(where: { $0.type == type && !$0.isCompleted }) else {
            completion(false)
            return
        }
        
        missions[index].currentCount += increment
        
        if missions[index].currentCount >= missions[index].targetCount {
            missions[index].isCompleted = true
        }
        
        saveMissions(completion: completion)
    }
    
    // ミッションの進捗を現在値で更新（レベルやお金など）
    func updateMissionProgressWithValue(type: MissionType, currentValue: Int, completion: @escaping (Bool) -> Void) {
        guard let index = missions.firstIndex(where: { $0.type == type && !$0.isCompleted }) else {
            completion(false)
            return
        }
        
        missions[index].currentCount = currentValue
        
        if missions[index].currentCount >= missions[index].targetCount {
            missions[index].isCompleted = true
        }
        
        saveMissions(completion: completion)
    }
    
    // 報酬を受け取る
    func claimReward(missionId: String, completion: @escaping (Bool, Int) -> Void) {
        guard let index = missions.firstIndex(where: { $0.id == missionId }),
              missions[index].isCompleted && !missions[index].isClaimed else {
            completion(false, 0)
            return
        }
        
        let reward = missions[index].rewardCoin
        missions[index].isClaimed = true
        
        // コインを追加
        authManager.addMoney(amount: reward)
        
        saveMissions { success in
            completion(success, reward)
        }
    }
    
    // すべての報酬を一括で受け取る
    func claimAllRewards(completion: @escaping (Bool, Int) -> Void) {
        let completedMissions = missions.filter { $0.isCompleted && !$0.isClaimed }
        let totalReward = completedMissions.reduce(0) { $0 + $1.rewardCoin }
        
        guard totalReward > 0 else {
            completion(false, 0)
            return
        }
        
        for index in missions.indices where missions[index].isCompleted && !missions[index].isClaimed {
            missions[index].isClaimed = true
        }
        
        authManager.addMoney(amount: totalReward)
        
        saveMissions { success in
            completion(success, totalReward)
        }
    }
    
    // すべてのミッションの進捗を更新（定期的に呼び出す）
    func refreshAllMissions() {
        guard let userId = authManager.currentUserId else { return }
        
        // 回答数の更新
        authManager.fetchTotalAnswersData(userId: userId) { [weak self] (_, totalAnswers) in
            self?.updateMissionProgressWithValue(type: .answer, currentValue: totalAnswers) { _ in }
        }
        
        // レベルの更新
        updateMissionProgressWithValue(type: .level, currentValue: authManager.level) { _ in }
        
        // 経験値の更新
        updateMissionProgressWithValue(type: .experience, currentValue: authManager.experience) { _ in }
        
        // コインの更新
        authManager.getUserMoney { [weak self] money in
            self?.updateMissionProgressWithValue(type: .money, currentValue: money) { _ in }
        }
        
        // アバター数の更新
        let avatarCount = authManager.avatars.reduce(0) { $0 + $1.count }
        updateMissionProgressWithValue(type: .avatar, currentValue: avatarCount) { _ in }
    }
}

// AuthManagerの拡張でミッションマネージャーとの連携を追加
extension AuthManager {
    // 回答時にミッション進捗を更新
    func recordAnswer(isCorrect: Bool) {
        MissionManager.shared.updateMissionProgress(type: .answer, increment: 1) { _ in }
        if isCorrect {
            MissionManager.shared.updateMissionProgress(type: .correctAnswer, increment: 1) { _ in }
        }
    }
    
    // ガチャ使用時
    func recordGachaUsed() {
        MissionManager.shared.updateMissionProgress(type: .gacha, increment: 1) { _ in }
    }
    
    // アバター獲得時
    func recordAvatarObtained() {
        let avatarCount = self.avatars.reduce(0) { $0 + $1.count }
        MissionManager.shared.updateMissionProgressWithValue(type: .avatar, currentValue: avatarCount) { _ in }
    }
}
