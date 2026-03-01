//
//  LoginBonusListView.swift
//  it
//
//  Created by Apple on 2026/02/07.
//

import SwiftUI

struct LoginBonusListView: View {
    let currentDay: Int
    @Environment(\.dismiss) private var dismiss
    @State private var scrollTarget: Int? = nil
    
    // 全500日の累計
    private var totalAllCoins: Int {
        LoginBonusConfig.totalCoins(upTo: LoginBonusConfig.maxDay)
    }
    
    // 現在までの累計
    private var totalEarnedCoins: Int {
        LoginBonusConfig.totalCoins(upTo: currentDay)
    }
    
    // 50日区切りのセクション（0...9 → Day1-50, Day51-100, ...）
    private var sections: [RewardSection] {
        (0..<10).map { sectionIndex in
            let start = sectionIndex * 50 + 1
            let end = min(start + 49, LoginBonusConfig.maxDay)
            let days = (start...end).map { day in
                RewardDay(
                    day: day,
                    coins: LoginBonusConfig.coinAmount(for: day),
                    milestone: LoginBonusConfig.milestoneRank(day: day),
                    isCollected: day < currentDay,
                    isToday: day == currentDay
                )
            }
            let sectionTotal = days.reduce(0) { $0 + $1.coins }
            return RewardSection(
                id: sectionIndex,
                title: "Day \(start) - \(end)",
                days: days,
                sectionTotal: sectionTotal
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color(red: 0.07, green: 0.07, blue: 0.12)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // サマリーヘッダー
                    summaryHeader
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // リスト
                    ScrollViewReader { proxy in
                        List {
                            ForEach(sections) { section in
                                Section {
                                    ForEach(section.days) { day in
                                        RewardRowView(day: day)
                                            .id(day.day)
                                            .listRowBackground(
                                                day.isToday
                                                ? Color.yellow.opacity(0.1)
                                                : Color.clear
                                            )
                                    }
                                } header: {
                                    sectionHeader(section)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo(currentDay, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("報酬一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(.yellow)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.12), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Summary Header
    private var summaryHeader: some View {
        VStack(spacing: 16) {
            // 現在の進捗
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("現在")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(currentDay)日目")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("獲得済み")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(formatNumber(totalEarnedCoins))コイン")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("全報酬合計")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(formatNumber(totalAllCoins))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // プログレスバー
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * CGFloat(currentDay) / CGFloat(LoginBonusConfig.maxDay),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
            
            Text("\(LoginBonusConfig.maxDay)日中 \(currentDay)日達成（\(Int(Double(currentDay) / Double(LoginBonusConfig.maxDay) * 100))%）")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.03))
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ section: RewardSection) -> some View {
        HStack {
            Text(section.title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text("合計 \(formatNumber(section.sectionTotal))コイン")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.orange.opacity(0.7))
        }
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
    }
    
    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - Data Models
struct RewardSection: Identifiable {
    let id: Int
    let title: String
    let days: [RewardDay]
    let sectionTotal: Int
}

struct RewardDay: Identifiable {
    var id: Int { day }
    let day: Int
    let coins: Int
    let milestone: LoginBonusConfig.MilestoneRank
    let isCollected: Bool
    let isToday: Bool
}

// MARK: - Row View
struct RewardRowView: View {
    let day: RewardDay
    
    private var accentColor: Color {
        LoginBonusConfig.color(for: day.day)
    }
    
    private var icon: String {
        LoginBonusConfig.icon(for: day.day)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 左: アイコン
            ZStack {
                Circle()
                    .fill(
                        day.isCollected || day.isToday
                        ? LinearGradient(colors: [accentColor, accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 38, height: 38)
                
                if day.isCollected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(day.isToday ? .white : .white.opacity(0.3))
                }
            }
            
            // 中央: Day番号 + ラベル
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Day \(day.day)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(day.isToday ? .yellow : .white)
                    
                    if day.isToday {
                        Text("← 今日")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    // マイルストーンバッジ
                    milestoneLabel
                }
                
                if day.milestone != .none {
                    Text(milestoneDescription)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(accentColor.opacity(0.8))
                }
            }
            
            Spacer()
            
            // 右: コイン数
            HStack(spacing: 3) {
                Text("¢")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                Text(formatCoinDisplay(day.coins))
                    .font(.system(size: day.milestone != .none ? 17 : 15, weight: .bold, design: .rounded))
                    .foregroundColor(
                        day.milestone == .ultra ? Color(red: 1, green: 0.84, blue: 0) :
                        day.milestone == .super_ ? Color(red: 0.7, green: 0.5, blue: 1) :
                        day.milestone == .normal ? Color(red: 1, green: 0.6, blue: 0.2) :
                        day.isCollected ? .white.opacity(0.7) :
                        .white.opacity(0.4)
                    )
            }
        }
        .padding(.vertical, 4)
        .opacity(day.isCollected ? 0.7 : 1.0)
        .listRowBackground(
            day.isToday ? Color.yellow.opacity(0.08) :
            day.milestone == .ultra ? Color(red: 1, green: 0.84, blue: 0).opacity(0.05) :
            day.milestone == .super_ ? Color(red: 0.6, green: 0.3, blue: 1).opacity(0.05) :
            Color.clear
        )
        .listRowSeparatorTint(Color.white.opacity(0.06))
    }
    
    @ViewBuilder
    private var milestoneLabel: some View {
        switch day.milestone {
        case .ultra:
            Text("👑 超特別")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Color(red: 1, green: 0.84, blue: 0).opacity(0.15))
                .clipShape(Capsule())
        case .super_:
            Text("💎 特大")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Color(red: 0.6, green: 0.3, blue: 1).opacity(0.15))
                .clipShape(Capsule())
        case .normal:
            Text("⭐ ボーナス")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1, green: 0.6, blue: 0.2))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Color(red: 1, green: 0.5, blue: 0.2).opacity(0.15))
                .clipShape(Capsule())
        case .none:
            EmptyView()
        }
    }
    
    private var milestoneDescription: String {
        switch day.milestone {
        case .ultra: return "\(day.day)日達成記念！報酬5倍！"
        case .super_: return "\(day.day)日達成記念！報酬3倍！"
        case .normal: return "5日区切りボーナス！報酬2倍！"
        case .none: return ""
        }
    }
    
    private func formatCoinDisplay(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

// MARK: - Preview
struct LoginBonusListView_Previews: PreviewProvider {
    static var previews: some View {
        LoginBonusListView(currentDay: 23)
            .preferredColorScheme(.dark)
    }
}
