//
//  Mission.swift
//  it
//
//  Created by hashimo ryoya on 2025/12/16.
//

import Foundation

enum MissionType: String, Codable {
    case answer = "answer"           // 問題を○回解こう
    case correctAnswer = "correctAnswer"  // 正解を○回しよう
    case avatar = "avatar"           // おともを○体仲間にしよう
    case gacha = "gacha"            // ガチャを○回引こう
    case level = "level"            // レベルを○にしよう
    case experience = "experience"  // 経験値を○獲得しよう
    case money = "money"            // コインを○枚集めよう
}

struct Mission: Identifiable, Codable {
    let id: String
    let type: MissionType
    let title: String
    let description: String
    let targetCount: Int
    var currentCount: Int
    let rewardCoin: Int
    let rewardIcon: String
    var isCompleted: Bool
    var isClaimed: Bool
    
    var progressPercentage: Float {
        return min(Float(currentCount) / Float(targetCount), 1.0)
    }
    
    init(id: String = UUID().uuidString,
         type: MissionType,
         title: String,
         description: String,
         targetCount: Int,
         currentCount: Int = 0,
         rewardCoin: Int,
         rewardIcon: String,
         isCompleted: Bool = false,
         isClaimed: Bool = false) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.rewardCoin = rewardCoin
        self.rewardIcon = rewardIcon
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
    }
}
