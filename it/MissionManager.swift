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
    @Published var selectedCategory: MissionCategory = .daily

    static let shared = MissionManager()
    private let authManager = AuthManager.shared
    private var loadedUserId: String?
    private var isLoadingInitialState = false
    private var pendingInitialLoadCompletions: [(Bool) -> Void] = []

    // リセット日時の管理
    @Published var lastDailyReset: Date?
    @Published var lastWeeklyReset: Date?

    private init() {
        setupDefaultMissions()
    }

    // MARK: - Filtered Missions

    var dailyMissions: [Mission] {
        missions.filter { $0.category == .daily }
    }

    var weeklyMissions: [Mission] {
        missions.filter { $0.category == .weekly }
    }

    var normalMissions: [Mission] {
        missions.filter { $0.category == .normal }
    }

    func missionsForCategory(_ category: MissionCategory) -> [Mission] {
        missions.filter { $0.category == category }
    }

    var currentCategoryMissions: [Mission] {
        missionsForCategory(selectedCategory)
    }

    // MARK: - Completion Bonus

    var isDailyAllCompleted: Bool {
        let daily = dailyMissions
        return !daily.isEmpty && daily.allSatisfy { $0.isCompleted }
    }

    var isWeeklyAllCompleted: Bool {
        let weekly = weeklyMissions
        return !weekly.isEmpty && weekly.allSatisfy { $0.isCompleted }
    }

    func completedCount(for category: MissionCategory) -> Int {
        missionsForCategory(category).filter { $0.isCompleted && !$0.isClaimed }.count
    }

    var totalClaimableCount: Int {
        missions.filter { $0.isCompleted && !$0.isClaimed }.count
    }

    // MARK: - Reset Timer

    var nextDailyReset: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let todayMidnight = calendar.date(from: components) else { return now }
        if now >= todayMidnight {
            return calendar.date(byAdding: .day, value: 1, to: todayMidnight) ?? now
        }
        return todayMidnight
    }

    var nextWeeklyReset: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let thisMonday = calendar.date(from: components) else { return now }
        if now >= thisMonday {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: thisMonday) ?? now
        }
        return thisMonday
    }

    func timeUntilReset(for category: MissionCategory) -> TimeInterval {
        switch category {
        case .daily:
            return max(nextDailyReset.timeIntervalSince(Date()), 0)
        case .weekly:
            return max(nextWeeklyReset.timeIntervalSince(Date()), 0)
        case .normal:
            return 0
        }
    }

    // MARK: - Default Missions

    private func setupDefaultMissions() {
        missions = defaultDailyMissions() + defaultWeeklyMissions() + defaultNormalMissions()
    }

    private func defaultDailyMissions() -> [Mission] {
        [
            Mission(type: .answer,
                    category: .daily,
                    title: "問題を5回解こう",
                    description: "今日中に問題を5回解答しましょう",
                    targetCount: 5,
                    rewardCoin: 50,
                    rewardIcon: "ミッション問題"),

            Mission(type: .correctAnswer,
                    category: .daily,
                    title: "正解を3回しよう",
                    description: "今日中に問題に3回正解しましょう",
                    targetCount: 3,
                    rewardCoin: 30,
                    rewardIcon: "ミッション正解"),

            Mission(type: .gacha,
                    category: .daily,
                    title: "ガチャを1回引こう",
                    description: "今日中にガチャを1回引きましょう",
                    targetCount: 1,
                    rewardCoin: 20,
                    rewardIcon: "ミッションガチャ"),

        ]
    }

    private func defaultWeeklyMissions() -> [Mission] {
        [
            Mission(type: .answer,
                    category: .weekly,
                    title: "問題を30回解こう",
                    description: "今週中に問題を30回解答しましょう",
                    targetCount: 30,
                    rewardCoin: 200,
                    rewardIcon: "ミッション問題",
                    rewardItemType: .staminaPotion,
                    rewardItemAmount: 2),

            Mission(type: .correctAnswer,
                    category: .weekly,
                    title: "正解を15回しよう",
                    description: "今週中に問題に15回正解しましょう",
                    targetCount: 15,
                    rewardCoin: 150,
                    rewardIcon: "ミッション正解",
                    rewardItemType: .normalGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .guerrilla,
                    category: .weekly,
                    title: "ゲリラに3回参加しよう",
                    description: "今週中にゲリラバトルに3回参加しましょう",
                    targetCount: 3,
                    rewardCoin: 200,
                    rewardIcon: "ミッションゲリラ",
                    rewardItemType: .rareGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .dailyComplete,
                    category: .weekly,
                    title: "デイリーミッションを3日全クリアしよう",
                    description: "デイリーミッションを3日間すべてクリアしましょう",
                    targetCount: 3,
                    rewardCoin: 300,
                    rewardIcon: "デイリー全クリア",
                    rewardItemType: .mekaGachaTicket,
                    rewardItemAmount: 1),
        ]
    }

    private func defaultNormalMissions() -> [Mission] {
        [
            Mission(type: .answer,
                    category: .normal,
                    title: "問題を14回解こう",
                    description: "ダンジョンで問題を14回解答しましょう",
                    targetCount: 14,
                    rewardCoin: 100,
                    rewardIcon: "ミッション問題",
                    rewardItemType: .staminaPotion,
                    rewardItemAmount: 1),

            Mission(type: .correctAnswer,
                    category: .normal,
                    title: "正解を4回しよう",
                    description: "問題に4回正解しましょう",
                    targetCount: 4,
                    rewardCoin: 50,
                    rewardIcon: "ミッション正解",
                    rewardItemType: .normalGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .avatar,
                    category: .normal,
                    title: "おともを9体仲間にしよう",
                    description: "ガチャでおともを9体獲得しましょう",
                    targetCount: 9,
                    rewardCoin: 200,
                    rewardIcon: "ライム",
                    rewardItemType: .rareGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .gacha,
                    category: .normal,
                    title: "ガチャを10回引こう",
                    description: "ガチャを10回引いてみましょう",
                    targetCount: 10,
                    rewardCoin: 150,
                    rewardIcon: "ミッションガチャ",
                    rewardItemType: .rareGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .level,
                    category: .normal,
                    title: "レベル4に到達しよう",
                    description: "経験値を貯めてレベル4に到達しましょう",
                    targetCount: 4,
                    rewardCoin: 300,
                    rewardIcon: "ミッションレベル",
                    rewardItemType: .boostTicket,
                    rewardItemAmount: 1),

            Mission(type: .experience,
                    category: .normal,
                    title: "経験値を500獲得しよう",
                    description: "問題に答えて経験値を500獲得しましょう",
                    targetCount: 500,
                    rewardCoin: 250,
                    rewardIcon: "ミッション経験値",
                    rewardItemType: .staminaPotion,
                    rewardItemAmount: 2),

            Mission(type: .money,
                    category: .normal,
                    title: "コインを1000枚集めよう",
                    description: "様々な方法でコインを1000枚集めましょう",
                    targetCount: 1000,
                    rewardCoin: 500,
                    rewardIcon: "ミッションコイン",
                    rewardItemType: .mekaGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .guerrilla,
                    category: .normal,
                    title: "ゲリラに5回参加しよう",
                    description: "ゲリラバトルに5回参加しましょう",
                    targetCount: 5,
                    rewardCoin: 300,
                    rewardIcon: "ミッションゲリラ",
                    rewardItemType: .rareGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .guerrillaWin,
                    category: .normal,
                    title: "ゲリラボス1位勝利を3回しよう",
                    description: "ゲリラバトルで1位で勝利を3回達成しましょう",
                    targetCount: 3,
                    rewardCoin: 500,
                    rewardIcon: "ミッションゲリラ勝利",
                    rewardItemType: .godGachaTicket,
                    rewardItemAmount: 1),

            Mission(type: .login,
                    category: .normal,
                    title: "7日連続ログインしよう",
                    description: "7日連続でログインしましょう",
                    targetCount: 7,
                    rewardCoin: 200,
                    rewardIcon: "ミッションログイン",
                    rewardItemType: .normalGachaTicket,
                    rewardItemAmount: 2),

            Mission(type: .dungeonStep,
                    category: .normal,
                    title: "ダンジョンを30コマ進もう",
                    description: "ダンジョンで30コマ以上進みましょう",
                    targetCount: 30,
                    rewardCoin: 200,
                    rewardIcon: "足場1",
                    rewardItemType: .staminaPotion,
                    rewardItemAmount: 2),
        ]
    }

    private func allDefaultMissions() -> [Mission] {
        defaultDailyMissions() + defaultWeeklyMissions() + defaultNormalMissions()
    }

    private func configuredMission(for type: MissionType, category: MissionCategory) -> Mission? {
        allDefaultMissions().first(where: { $0.type == type && $0.category == category })
    }

    private func applyRewardConfig(to mission: Mission) -> Mission {
        guard let configured = configuredMission(for: mission.type, category: mission.category) else {
            return mission
        }
        return Mission(
            id: mission.id,
            type: mission.type,
            category: mission.category,
            title: mission.title,
            description: mission.description,
            targetCount: mission.targetCount,
            currentCount: mission.currentCount,
            rewardCoin: configured.rewardCoin,
            rewardIcon: configured.rewardIcon,
            rewardItemType: configured.rewardItemType,
            rewardItemAmount: configured.rewardItemAmount,
            isCompleted: mission.isCompleted,
            isClaimed: mission.isClaimed
        )
    }

    func itemRewards(for mission: Mission) -> [InventoryReward] {
        guard let rewardItemType = mission.rewardItemType, mission.rewardItemAmount > 0 else {
            return []
        }
        return [InventoryReward(type: rewardItemType, amount: mission.rewardItemAmount)]
    }

    private func mergedRewards(_ rewards: [InventoryReward]) -> [InventoryReward] {
        let totals = rewards.reduce(into: [InventoryItemType: Int]()) { partialResult, reward in
            partialResult[reward.type, default: 0] += reward.amount
        }
        return InventoryItemType.allCases.compactMap { type in
            guard let amount = totals[type], amount > 0 else { return nil }
            return InventoryReward(type: type, amount: amount)
        }
    }

    func rewardSummary(coinAmount: Int, itemRewards: [InventoryReward]) -> String {
        var components: [String] = []
        if coinAmount > 0 {
            components.append("\(coinAmount)コイン")
        }
        components.append(contentsOf: itemRewards.map { "\($0.type.displayName)x\($0.amount)" })
        return components.joined(separator: " / ")
    }

    // MARK: - Firebase Operations

    func fetchMissions(completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            completion(false)
            return
        }

        isLoading = true
        let ref = Database.database().reference().child("missions").child(userId)

        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            // リセット日時の取得
            if let resetData = (snapshot.value as? [String: Any])?["resetDates"] as? [String: Any] {
                if let dailyStr = resetData["lastDailyReset"] as? String {
                    self.lastDailyReset = ISO8601DateFormatter().date(from: dailyStr)
                }
                if let weeklyStr = resetData["lastWeeklyReset"] as? String {
                    self.lastWeeklyReset = ISO8601DateFormatter().date(from: weeklyStr)
                }
            }

            if let missionsData = (snapshot.value as? [String: Any])?["list"] as? [[String: Any]] {
                self.loadedUserId = userId
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

                    let categoryStr = dict["category"] as? String ?? "normal"
                    let category = MissionCategory(rawValue: categoryStr) ?? .normal
                    let rewardItemType = (dict["rewardItemType"] as? String).flatMap(InventoryItemType.init(rawValue:))
                    let rewardItemAmount = dict["rewardItemAmount"] as? Int ?? 0

                    return Mission(id: id, type: type, category: category,
                                   title: title, description: description,
                                   targetCount: targetCount, currentCount: currentCount,
                                   rewardCoin: rewardCoin, rewardIcon: rewardIcon,
                                   rewardItemType: rewardItemType,
                                   rewardItemAmount: rewardItemAmount,
                                   isCompleted: isCompleted, isClaimed: isClaimed)
                }.map { self.applyRewardConfig(to: $0) }

                // リセットチェック
                self.checkAndResetMissions()
            } else {
                // 旧形式チェック: 配列形式
                if snapshot.exists(), let missionsData = snapshot.value as? [[String: Any]] {
                    self.loadedUserId = userId
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

                        let rewardItemType = (dict["rewardItemType"] as? String).flatMap(InventoryItemType.init(rawValue:))
                        let rewardItemAmount = dict["rewardItemAmount"] as? Int ?? 0

                        return Mission(id: id, type: type, category: .normal,
                                       title: title, description: description,
                                       targetCount: targetCount, currentCount: currentCount,
                                       rewardCoin: rewardCoin, rewardIcon: rewardIcon,
                                       rewardItemType: rewardItemType,
                                       rewardItemAmount: rewardItemAmount,
                                       isCompleted: isCompleted, isClaimed: isClaimed)
                    }.map { self.applyRewardConfig(to: $0) }

                    // 旧形式 → 新形式: デイリー/ウィークリーを追加
                    self.addMissingCategoryMissions()
                    self.saveMissions { _ in }
                } else {
                    self.loadedUserId = userId
                    self.syncMissionsWithCurrentProgress { success in
                        if !success {
                            self.loadedUserId = nil
                        }
                        completion(success)
                    }
                    return
                }
            }

            self.isLoading = false
            completion(true)
        }
    }

    // 不足しているカテゴリのミッションを補完
    private func addMissingCategoryMissions() {
        let existingDaily = missions.filter { $0.category == .daily }
        let existingWeekly = missions.filter { $0.category == .weekly }

        if existingDaily.isEmpty {
            missions.append(contentsOf: defaultDailyMissions())
        }
        if existingWeekly.isEmpty {
            missions.append(contentsOf: defaultWeeklyMissions())
        }

        // 通常ミッションで不足タイプを補完
        let existingNormalTypes = Set(normalMissions.map { $0.type })
        for m in defaultNormalMissions() where !existingNormalTypes.contains(m.type) {
            missions.append(m)
        }
    }

    // MARK: - Reset Logic

    func checkAndResetMissions() {
        let calendar = Calendar.current
        let now = Date()

        // デイリーリセット
        if let lastReset = lastDailyReset {
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                resetDailyMissions()
            }
        } else {
            lastDailyReset = now
        }

        // ウィークリーリセット
        if let lastReset = lastWeeklyReset {
            let lastWeek = calendar.component(.weekOfYear, from: lastReset)
            let currentWeek = calendar.component(.weekOfYear, from: now)
            let lastYear = calendar.component(.year, from: lastReset)
            let currentYear = calendar.component(.year, from: now)
            if lastWeek != currentWeek || lastYear != currentYear {
                resetWeeklyMissions()
            }
        } else {
            lastWeeklyReset = now
        }
    }

    private func resetDailyMissions() {
        // デイリー全クリアだった場合、ウィークリーの dailyComplete を進捗
        if isDailyAllCompleted {
            updateMissionProgress(type: .dailyComplete, category: .weekly, increment: 1) { _ in }
        }

        // デイリーミッションをリセット
        let newDailies = defaultDailyMissions()
        missions.removeAll { $0.category == .daily }
        missions.append(contentsOf: newDailies)
        lastDailyReset = Date()

        saveMissions { _ in }
    }

    private func resetWeeklyMissions() {
        let newWeeklies = defaultWeeklyMissions()
        missions.removeAll { $0.category == .weekly }
        missions.append(contentsOf: newWeeklies)
        lastWeeklyReset = Date()

        saveMissions { _ in }
    }

    // MARK: - Save

    func saveMissions(completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            completion(false)
            return
        }

        let missionsRef = Database.database().reference().child("missions").child(userId)
        let formatter = ISO8601DateFormatter()

        let missionsData = missions.map { mission -> [String: Any] in
            return [
                "id": mission.id,
                "type": mission.type.rawValue,
                "category": mission.category.rawValue,
                "title": mission.title,
                "description": mission.description,
                "targetCount": mission.targetCount,
                "currentCount": mission.currentCount,
                "rewardCoin": mission.rewardCoin,
                "rewardIcon": mission.rewardIcon,
                "rewardItemType": mission.rewardItemType?.rawValue ?? "",
                "rewardItemAmount": mission.rewardItemAmount,
                "isCompleted": mission.isCompleted,
                "isClaimed": mission.isClaimed
            ]
        }

        let saveData: [String: Any] = [
            "list": missionsData,
            "resetDates": [
                "lastDailyReset": formatter.string(from: lastDailyReset ?? Date()),
                "lastWeeklyReset": formatter.string(from: lastWeeklyReset ?? Date())
            ]
        ]

        missionsRef.setValue(saveData) { error, _ in
            completion(error == nil)
        }
    }

    // MARK: - Sync with Current Progress

    func syncMissionsWithCurrentProgress(completion: ((Bool) -> Void)? = nil) {
        guard authManager.currentUserId != nil else {
            completion?(false)
            return
        }

        let group = DispatchGroup()

        group.enter()
        authManager.fetchUserExperienceAndLevel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let level = self?.authManager.level {
                self?.updateAllMatchingMissions(type: .level, value: level, useAbsolute: true)
            }
            if let exp = self?.authManager.experience {
                self?.updateAllMatchingMissions(type: .experience, value: exp, useAbsolute: true)
            }
            group.leave()
        }

        group.enter()
        authManager.getUserMoney { [weak self] money in
            self?.updateAllMatchingMissions(type: .money, value: money, useAbsolute: true)
            group.leave()
        }

        group.enter()
        authManager.fetchAvatars { [weak self] in
            let avatarCount = self?.authManager.avatars.reduce(0) { $0 + $1.count } ?? 0
            self?.updateAllMatchingMissions(type: .avatar, value: avatarCount, useAbsolute: true)
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.lastDailyReset = Date()
            self?.lastWeeklyReset = Date()
            self?.saveMissions { success in
                self?.isLoading = false
                completion?(success)
            }
        }
    }

    private func updateAllMatchingMissions(type: MissionType, value: Int, useAbsolute: Bool) {
        for index in missions.indices where missions[index].type == type && !missions[index].isCompleted {
            if useAbsolute {
                missions[index].currentCount = value
            } else {
                missions[index].currentCount = value
            }
            if missions[index].currentCount >= missions[index].targetCount {
                missions[index].isCompleted = true
            }
        }
    }

    // MARK: - Progress Updates

    func updateMissionProgress(type: MissionType, increment: Int = 1, completion: @escaping (Bool) -> Void) {
        ensureMissionsLoaded { [weak self] success in
            guard let self = self, success else {
                completion(false)
                return
            }
            self.updateLoadedMissionProgress(type: type, increment: increment, completion: completion)
        }
    }

    func updateMissionProgress(type: MissionType, category: MissionCategory, increment: Int = 1, completion: @escaping (Bool) -> Void) {
        ensureMissionsLoaded { [weak self] success in
            guard let self = self, success else {
                completion(false)
                return
            }
            self.updateLoadedMissionProgress(type: type, category: category, increment: increment, completion: completion)
        }
    }

    func updateMissionProgressWithValue(type: MissionType, currentValue: Int, completion: @escaping (Bool) -> Void) {
        ensureMissionsLoaded { [weak self] success in
            guard let self = self, success else {
                completion(false)
                return
            }
            self.updateLoadedMissionProgressWithValue(type: type, currentValue: currentValue, completion: completion)
        }
    }

    func recordAnswerProgress(isCorrect: Bool, completion: @escaping (Bool) -> Void = { _ in }) {
        ensureMissionsLoaded { [weak self] success in
            guard let self = self, success else {
                completion(false)
                return
            }
            self.updateLoadedAnswerProgress(isCorrect: isCorrect, completion: completion)
        }
    }

    private func ensureMissionsLoaded(completion: @escaping (Bool) -> Void) {
        guard let userId = authManager.currentUserId else {
            completion(false)
            return
        }

        if loadedUserId == userId {
            completion(true)
            return
        }

        pendingInitialLoadCompletions.append(completion)
        guard !isLoadingInitialState else { return }

        isLoadingInitialState = true
        fetchMissions { [weak self] success in
            guard let self = self else { return }
            self.isLoadingInitialState = false
            if success {
                self.loadedUserId = userId
            }

            let completions = self.pendingInitialLoadCompletions
            self.pendingInitialLoadCompletions.removeAll()
            completions.forEach { $0(success) }
        }
    }

    private func updateLoadedMissionProgress(type: MissionType, increment: Int = 1, completion: @escaping (Bool) -> Void) {
        let updated = incrementLoadedMissions(type: type, increment: increment)
        guard updated else {
            completion(false)
            return
        }
        saveMissions(completion: completion)
    }

    private func updateLoadedMissionProgress(type: MissionType, category: MissionCategory, increment: Int = 1, completion: @escaping (Bool) -> Void) {
        guard let index = missions.firstIndex(where: { $0.type == type && $0.category == category && !$0.isCompleted }) else {
            completion(false)
            return
        }
        missions[index].currentCount += increment
        if missions[index].currentCount >= missions[index].targetCount {
            missions[index].isCompleted = true
        }
        saveMissions(completion: completion)
    }

    private func updateLoadedAnswerProgress(isCorrect: Bool, completion: @escaping (Bool) -> Void) {
        let updatedAnswer = incrementLoadedMissions(type: .answer, increment: 1)
        let updatedCorrectAnswer = isCorrect ? incrementLoadedMissions(type: .correctAnswer, increment: 1) : false

        guard updatedAnswer || updatedCorrectAnswer else {
            completion(false)
            return
        }
        saveMissions(completion: completion)
    }

    private func incrementLoadedMissions(type: MissionType, increment: Int) -> Bool {
        var updated = false
        for index in missions.indices where missions[index].type == type && !missions[index].isCompleted {
            missions[index].currentCount += increment
            if missions[index].currentCount >= missions[index].targetCount {
                missions[index].isCompleted = true
            }
            updated = true
        }
        return updated
    }

    private func updateLoadedMissionProgressWithValue(type: MissionType, currentValue: Int, completion: @escaping (Bool) -> Void) {
        var updated = false
        for index in missions.indices where missions[index].type == type && !missions[index].isCompleted {
            missions[index].currentCount = currentValue
            if missions[index].currentCount >= missions[index].targetCount {
                missions[index].isCompleted = true
            }
            updated = true
        }
        guard updated else {
            completion(false)
            return
        }
        saveMissions(completion: completion)
    }

    // MARK: - Claim Rewards

    func claimReward(missionId: String, completion: @escaping (Bool, Int, [InventoryReward]) -> Void) {
        guard let index = missions.firstIndex(where: { $0.id == missionId }),
              missions[index].isCompleted && !missions[index].isClaimed else {
            completion(false, 0, [])
            return
        }

        let reward = missions[index].rewardCoin
        let items = itemRewards(for: missions[index])
        missions[index].isClaimed = true

        authManager.addMoney(amount: reward)

        authManager.addItems(items) { itemSuccess in
            self.saveMissions { success in
                completion(success && itemSuccess, reward, items)
            }
        }
    }

    func claimAllRewards(for category: MissionCategory? = nil, completion: @escaping (Bool, Int, [InventoryReward]) -> Void) {
        let targetMissions: [Mission]
        if let category = category {
            targetMissions = missions.filter { $0.category == category && $0.isCompleted && !$0.isClaimed }
        } else {
            targetMissions = missions.filter { $0.isCompleted && !$0.isClaimed }
        }

        let totalReward = targetMissions.reduce(0) { $0 + $1.rewardCoin }
        let totalItemRewards = mergedRewards(targetMissions.flatMap { itemRewards(for: $0) })

        guard totalReward > 0 || !totalItemRewards.isEmpty else {
            completion(false, 0, [])
            return
        }

        for index in missions.indices {
            if let cat = category {
                if missions[index].category == cat && missions[index].isCompleted && !missions[index].isClaimed {
                    missions[index].isClaimed = true
                }
            } else {
                if missions[index].isCompleted && !missions[index].isClaimed {
                    missions[index].isClaimed = true
                }
            }
        }

        authManager.addMoney(amount: totalReward)

        authManager.addItems(totalItemRewards) { itemSuccess in
            self.saveMissions { success in
                completion(success && itemSuccess, totalReward, totalItemRewards)
            }
        }
    }

    // MARK: - Refresh

    func refreshAllMissions() {
        guard authManager.currentUserId != nil else { return }

        checkAndResetMissions()

        updateMissionProgressWithValue(type: .level, currentValue: authManager.level) { _ in }
        updateMissionProgressWithValue(type: .experience, currentValue: authManager.experience) { _ in }

        authManager.getUserMoney { [weak self] money in
            self?.updateMissionProgressWithValue(type: .money, currentValue: money) { _ in }
        }

        let avatarCount = authManager.avatars.reduce(0) { $0 + $1.count }
        updateMissionProgressWithValue(type: .avatar, currentValue: avatarCount) { _ in }
    }
}

// MARK: - AuthManager Extension

extension AuthManager {
    func recordAnswer(isCorrect: Bool) {
        MissionManager.shared.recordAnswerProgress(isCorrect: isCorrect)
    }

    func recordGachaUsed() {
        MissionManager.shared.updateMissionProgress(type: .gacha, increment: 1) { _ in }
    }

    func recordAvatarObtained() {
        let avatarCount = self.avatars.reduce(0) { $0 + $1.count }
        MissionManager.shared.updateMissionProgressWithValue(type: .avatar, currentValue: avatarCount) { _ in }
    }

    func recordStoryCompleted() {
        MissionManager.shared.updateMissionProgress(type: .story, increment: 1) { _ in }
    }

    func recordDungeonStep(position: Int) {
        MissionManager.shared.updateMissionProgressWithValue(type: .dungeonStep, currentValue: position) { _ in }
    }

    func recordGuerrillaParticipation() {
        MissionManager.shared.updateMissionProgress(type: .guerrilla, increment: 1) { _ in }
    }

    func recordGuerrillaWin() {
        MissionManager.shared.updateMissionProgress(type: .guerrillaWin, increment: 1) { _ in }
    }
}
