//
//  GuerrillaBossData.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI

struct GuerrillaBoss {
    let name: String
    let imageName: String
    let bossHP: Int
    let bossAttack: Int
    let rewardExperience: Int
    let rewardMoney: Int
    let difficulty: GuerrillaDifficulty
}

/// ギルドボス戦だけに登場するボス。
struct GuildRaidBoss {
    let name: String
    let imageName: String
    let species: String
    let element: String
    let motif: String
    let difficulty: GuerrillaDifficulty
    /// ギルド全体で共有する最大HP。
    let bossHP: Int
    /// ギルドボス戦で不正解だったときに受けるダメージ。
    let bossAttack: Int
}

enum GuerrillaDifficulty: String, CaseIterable {
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

let guerrillaBosses: [GuerrillaBoss] = [
    GuerrillaBoss(
        name: "ドラゴンキング",
        imageName: "ボス15",
        bossHP: 5000,
        bossAttack: 30,
        rewardExperience: 100,
        rewardMoney: 100,
        difficulty: .beginner
    ),
    GuerrillaBoss(
        name: "暗黒大魔神",
        imageName: "ボス16",
        bossHP: 10000,
        bossAttack: 50,
        rewardExperience: 200,
        rewardMoney: 200,
        difficulty: .intermediate
    ),
    GuerrillaBoss(
        name: "神竜ヴァルハラ",
        imageName: "ボス35",
        bossHP: 20000,
        bossAttack: 80,
        rewardExperience: 400,
        rewardMoney: 400,
        difficulty: .advanced
    )
]

let guildRaidBosses: [GuildRaidBoss] = [
    GuildRaidBoss(
        name: "獄炎城塞イグニス",
        imageName: "GuildBossIgnis",
        species: "炎の巨人・城塞型",
        element: "炎",
        motif: "ファイアウォール",
        difficulty: .advanced,
        bossHP: 55_000,
        bossAttack: 38
    ),
    GuildRaidBoss(
        name: "バイトモグラ",
        imageName: "GuildBossByteMole",
        species: "魔獣・丸型",
        element: "闇",
        motif: "データ容量",
        difficulty: .beginner,
        bossHP: 12_000,
        bossAttack: 15
    ),
    GuildRaidBoss(
        name: "クラウディアス",
        imageName: "GuildBossCloudias",
        species: "天空鳥・翼型",
        element: "風",
        motif: "クラウド",
        difficulty: .intermediate,
        bossHP: 20_000,
        bossAttack: 22
    ),
    GuildRaidBoss(
        name: "アーカイヴァ",
        imageName: "GuildBossArchiva",
        species: "古代亀・低重心型",
        element: "大地",
        motif: "データベース",
        difficulty: .intermediate,
        bossHP: 28_000,
        bossAttack: 18
    ),
    GuildRaidBoss(
        name: "ライゼクスパ",
        imageName: "GuildBossRaizexpa",
        species: "雷虫・多脚型",
        element: "雷",
        motif: "ネットワーク",
        difficulty: .advanced,
        bossHP: 32_000,
        bossAttack: 32
    ),
    GuildRaidBoss(
        name: "クリプティア",
        imageName: "GuildBossCryptia",
        species: "晶霊・浮遊型",
        element: "光晶",
        motif: "暗号化",
        difficulty: .advanced,
        bossHP: 42_000,
        bossAttack: 28
    )
]
