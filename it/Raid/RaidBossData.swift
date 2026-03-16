//
//  RaidBossData.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI

struct RaidBoss {
    let name: String
    let imageName: String
    let bossHP: Int
    let bossAttack: Int
    let rewardExperience: Int
    let rewardMoney: Int
    let difficulty: RaidDifficulty
}

enum RaidDifficulty: String, CaseIterable {
    case beginner = "初級"
    case intermediate = "中級"
    case advanced = "上級"

    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

let raidBosses: [RaidBoss] = [
    RaidBoss(
        name: "ドラゴンキング",
        imageName: "ボス15",
        bossHP: 5000,
        bossAttack: 30,
        rewardExperience: 100,
        rewardMoney: 100,
        difficulty: .beginner
    ),
    RaidBoss(
        name: "暗黒大魔神",
        imageName: "ボス16",
        bossHP: 10000,
        bossAttack: 50,
        rewardExperience: 200,
        rewardMoney: 200,
        difficulty: .intermediate
    ),
    RaidBoss(
        name: "神竜ヴァルハラ",
        imageName: "ボス35",
        bossHP: 20000,
        bossAttack: 80,
        rewardExperience: 400,
        rewardMoney: 400,
        difficulty: .advanced
    )
]
