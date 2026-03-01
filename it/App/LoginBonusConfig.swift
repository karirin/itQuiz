//
//  LoginBonusConfig.swift
//  it
//
//  連続ログインボーナスの報酬計算エンジン（500日対応）
//  - 基本: 50コインずつ増加
//  - 5日ごと: 特別ボーナス（通常の2〜3倍）
//  - 50日ごと: 超特別ボーナス
//  - 100日ごと: 超超特別ボーナス
//

import SwiftUI

// MARK: - LoginBonusConfig
struct LoginBonusConfig {
    
    static let maxDay = 500
    
    /// 指定日のボーナスコイン数を計算
    static func coinAmount(for day: Int) -> Int {
        let clampedDay = min(max(day, 1), maxDay)
        
        // 基本報酬: 50コインずつ増加（Day1=50, Day2=100, ...）
        let base = clampedDay * 50
        
        // 100日ごとの超超特別ボーナス（5倍）
        if clampedDay % 100 == 0 {
            return base * 5
        }
        
        // 50日ごとの超特別ボーナス（3倍）
        if clampedDay % 50 == 0 {
            return base * 3
        }
        
        // 5日ごとの特別ボーナス（2倍）
        if clampedDay % 5 == 0 {
            return base * 2
        }
        
        return base
    }
    
    /// 5日ごとかどうか
    static func isMilestone(day: Int) -> Bool {
        day % 5 == 0
    }
    
    /// 50日ごとかどうか
    static func isSuperMilestone(day: Int) -> Bool {
        day % 50 == 0
    }
    
    /// 100日ごとかどうか
    static func isUltraMilestone(day: Int) -> Bool {
        day % 100 == 0
    }
    
    /// マイルストーンのランク
    static func milestoneRank(day: Int) -> MilestoneRank {
        if day % 100 == 0 { return .ultra }
        if day % 50 == 0 { return .super_ }
        if day % 5 == 0 { return .normal }
        return .none
    }
    
    /// 指定日までの累計コイン数
    static func totalCoins(upTo day: Int) -> Int {
        (1...min(max(day, 1), maxDay)).reduce(0) { $0 + coinAmount(for: $1) }
    }
    
    /// 現在の5日間ページ（0-indexed）
    static func currentPage(for day: Int) -> Int {
        (day - 1) / 5
    }
    
    /// 指定ページの5日間の範囲（1-indexed）
    static func dayRange(for page: Int) -> ClosedRange<Int> {
        let start = page * 5 + 1
        let end = min(start + 4, maxDay)
        return start...end
    }
    
    /// 指定日のアイコン
    static func icon(for day: Int) -> String {
        let rank = milestoneRank(day: day)
        switch rank {
        case .ultra: return "crown.fill"
        case .super_: return "diamond.fill"
        case .normal: return "star.circle.fill"
        case .none:
            let pos = ((day - 1) % 5)
            switch pos {
            case 0: return "star.fill"
            case 1: return "flame.fill"
            case 2: return "bolt.fill"
            case 3: return "sparkles"
            case 4: return "star.circle.fill"
            default: return "star.fill"
            }
        }
    }
    
    /// 指定日のカラー
    static func color(for day: Int) -> Color {
        let rank = milestoneRank(day: day)
        switch rank {
        case .ultra: return Color(red: 1.0, green: 0.84, blue: 0.0)      // ゴールド
        case .super_: return Color(red: 0.6, green: 0.3, blue: 1.0)      // パープル
        case .normal: return Color(red: 1.0, green: 0.5, blue: 0.2)      // オレンジ
        case .none:
            let pos = ((day - 1) % 5)
            switch pos {
            case 0: return Color(red: 0.4, green: 0.7, blue: 1.0)
            case 1: return Color(red: 0.5, green: 0.8, blue: 0.4)
            case 2: return Color(red: 1.0, green: 0.6, blue: 0.3)
            case 3: return Color(red: 0.9, green: 0.4, blue: 0.6)
            default: return .blue
            }
        }
    }
    
    enum MilestoneRank {
        case none, normal, super_, ultra
    }
}
