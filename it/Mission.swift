//
//  Mission.swift
//  it
//
//  Created by hashimo ryoya on 2025/12/16.
//

import Foundation

enum MissionCategory: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case normal = "normal"

    var displayName: String {
        switch self {
        case .daily: return "デイリー"
        case .weekly: return "ウィークリー"
        case .normal: return "通常"
        }
    }
}

enum MissionType: String, Codable {
    case answer = "answer"                   // 問題を○回解こう
    case correctAnswer = "correctAnswer"     // 正解を○回しよう
    case avatar = "avatar"                   // おともを○体仲間にしよう
    case gacha = "gacha"                     // ガチャを○回引こう
    case level = "level"                     // レベルを○にしよう
    case experience = "experience"           // 経験値を○獲得しよう
    case money = "money"                     // コインを○枚集めよう
    case story = "story"                     // ストーリーを○回クリアしよう
    case guerrilla = "guerrilla"             // ゲリラに○回参加しよう
    case guerrillaWin = "guerrillaWin"       // ゲリラで○回勝利しよう
    case login = "login"                     // ○日ログインしよう
    case dailyComplete = "dailyComplete"     // デイリーミッションを全クリアしよう
    case dungeonStep = "dungeonStep"         // ダンジョンを○コマ進もう
}

struct Mission: Identifiable, Codable {
    let id: String
    let type: MissionType
    let category: MissionCategory
    let title: String
    let description: String
    let targetCount: Int
    var currentCount: Int
    let rewardCoin: Int
    let rewardIcon: String
    let rewardItemType: InventoryItemType?
    let rewardItemAmount: Int
    var isCompleted: Bool
    var isClaimed: Bool

    var progressPercentage: Float {
        return min(Float(currentCount) / Float(targetCount), 1.0)
    }

    init(id: String = UUID().uuidString,
         type: MissionType,
         category: MissionCategory = .normal,
         title: String,
         description: String,
         targetCount: Int,
         currentCount: Int = 0,
         rewardCoin: Int,
         rewardIcon: String,
         rewardItemType: InventoryItemType? = nil,
         rewardItemAmount: Int = 0,
         isCompleted: Bool = false,
         isClaimed: Bool = false) {
        self.id = id
        self.type = type
        self.category = category
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.rewardCoin = rewardCoin
        self.rewardIcon = rewardIcon
        self.rewardItemType = rewardItemType
        self.rewardItemAmount = rewardItemAmount
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
    }
}
