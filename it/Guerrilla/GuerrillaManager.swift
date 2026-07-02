//
//  GuerrillaManager.swift
//  it
//
//  Created on 2026/03/12.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct GuerrillaPlayer: Identifiable {
    let id: String
    var userName: String
    var level: Int
    var avatarName: String
    var totalDamage: Int
    var correctCount: Int
    var totalCount: Int
}

class GuerrillaManager: ObservableObject {
    @Published var bossHP: Int = 0
    @Published var bossMaxHP: Int = 0
    @Published var bossAttack: Int = 0
    @Published var bossName: String = ""
    @Published var bossImageName: String = ""
    @Published var difficulty: String = ""
    @Published var rewardExperience: Int = 0
    @Published var rewardMoney: Int = 0
    @Published var status: String = "none"  // none, active, completed
    @Published var players: [GuerrillaPlayer] = []
    @Published var quizzes: [QuizQuestion] = []
    @Published var expiresAt: Double = 0
    @Published var isParticipating: Bool = false
    @Published var errorMessage: String = ""

    private var guerrillaRef: DatabaseReference {
        Database.database().reference().child("activeRaid")
    }
    private var observerHandle: DatabaseHandle?

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var playerCount: Int {
        players.count
    }

    /// 残り時間（秒）
    var remainingTime: Int {
        let now = Date().timeIntervalSince1970
        return max(0, Int(expiresAt - now))
    }

    /// 自分のプレイヤーデータ
    var myPlayer: GuerrillaPlayer? {
        players.first { $0.id == currentUserId }
    }

    /// 自分のダメージランキング順位（1位〜）
    var myRank: Int {
        guard let me = myPlayer else { return 0 }
        let sorted = players.sorted { $0.totalDamage > $1.totalDamage }
        return (sorted.firstIndex { $0.id == me.id } ?? -1) + 1
    }

    // MARK: - アクティブゲリラを監視

    func observeActiveGuerrilla() {
        stopObserving()

        observerHandle = guerrillaRef.observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async {
                    self.status = "none"
                    self.players = []
                    self.quizzes = []
                    self.isParticipating = false
                }
                return
            }

            DispatchQueue.main.async {
                self.bossName = data["bossName"] as? String ?? ""
                self.bossImageName = data["bossImageName"] as? String ?? ""
                self.difficulty = data["difficulty"] as? String ?? ""
                self.bossHP = data["bossHP"] as? Int ?? 0
                self.bossMaxHP = data["bossMaxHP"] as? Int ?? 0
                self.bossAttack = data["bossAttack"] as? Int ?? 0
                self.rewardExperience = data["rewardExperience"] as? Int ?? 0
                self.rewardMoney = data["rewardMoney"] as? Int ?? 0
                self.status = data["status"] as? String ?? "none"
                self.expiresAt = data["expiresAt"] as? Double ?? 0

                // プレイヤー一覧
                if let playersData = data["players"] as? [String: [String: Any]] {
                    self.players = playersData.map { (key, value) in
                        GuerrillaPlayer(
                            id: key,
                            userName: value["userName"] as? String ?? "",
                            level: value["level"] as? Int ?? 1,
                            avatarName: value["avatarName"] as? String ?? "",
                            totalDamage: value["totalDamage"] as? Int ?? 0,
                            correctCount: value["correctCount"] as? Int ?? 0,
                            totalCount: value["totalCount"] as? Int ?? 0
                        )
                    }.sorted { $0.totalDamage > $1.totalDamage }

                    // 自分が参加しているか
                    self.isParticipating = playersData[self.currentUserId ?? ""] != nil
                }

                // クイズ読み込み（初回のみ）
                if self.quizzes.isEmpty, let quizzesData = data["quizzes"] as? [[String: Any]] {
                    self.quizzes = quizzesData.compactMap { quizData in
                        guard let question = quizData["question"] as? String,
                              let choices = quizData["choices"] as? [String],
                              let correctAnswerIndex = quizData["correctAnswerIndex"] as? Int,
                              let explanation = quizData["explanation"] as? String else {
                            return nil
                        }
                        return QuizQuestion(
                            question: question,
                            choices: choices,
                            correctAnswerIndex: correctAnswerIndex,
                            explanation: explanation
                        )
                    }
                }

                // ボス撃破判定
                if self.bossHP <= 0 && self.status == "active" {
                    self.guerrillaRef.child("status").setValue("completed")
                }
            }
        }
    }

    // MARK: - ゲリラに参加

    func joinGuerrilla(userName: String, level: Int, avatarName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            errorMessage = "ログインが必要です"
            completion(false)
            return
        }

        guard status == "active" else {
            errorMessage = "現在ゲリラは開催されていません"
            completion(false)
            return
        }

        let playerData: [String: Any] = [
            "userName": userName,
            "level": level,
            "avatarName": avatarName,
            "totalDamage": 0,
            "correctCount": 0,
            "totalCount": 0
        ]

        guerrillaRef.child("players").child(userId).setValue(playerData) { error, _ in
            if let error = error {
                self.errorMessage = "参加に失敗しました: \(error.localizedDescription)"
                completion(false)
            } else {
                self.isParticipating = true
                completion(true)
            }
        }
    }

    // MARK: - ボスにダメージ（トランザクション）

    func attackBoss(damage: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }

        // ボスHPを原子的に減算
        guerrillaRef.child("bossHP").runTransactionBlock { currentData in
            var hp = currentData.value as? Int ?? 0
            hp = max(0, hp - damage)
            currentData.value = hp
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, _ in
            if committed {
                let playerRef = self.guerrillaRef.child("players").child(userId)
                playerRef.child("totalDamage").runTransactionBlock { currentData in
                    let current = currentData.value as? Int ?? 0
                    currentData.value = current + damage
                    return TransactionResult.success(withValue: currentData)
                }
                playerRef.child("correctCount").runTransactionBlock { currentData in
                    let current = currentData.value as? Int ?? 0
                    currentData.value = current + 1
                    return TransactionResult.success(withValue: currentData)
                }
            }
            completion(committed)
        }
    }

    // MARK: - 回答数を更新

    func incrementTotalCount() {
        guard let userId = currentUserId else { return }
        guerrillaRef.child("players").child(userId).child("totalCount").runTransactionBlock { currentData in
            let current = currentData.value as? Int ?? 0
            currentData.value = current + 1
            return TransactionResult.success(withValue: currentData)
        }
    }

    // MARK: - ゲリラを作成（ゲリラ出現）
    /// アプリ起動時やタイミングで呼び出してアクティブゲリラを生成
    func spawnGuerrillaIfNeeded() {
        guerrillaRef.observeSingleEvent(of: .value) { snapshot in
            // 既にアクティブなゲリラがある場合はスキップ
            if let data = snapshot.value as? [String: Any],
               let status = data["status"] as? String,
               status == "active" {
                return
            }

            // 新しいゲリラを生成
            self.spawnNewGuerrilla()
        }
    }

    private func spawnNewGuerrilla() {
        // ランダムにボスを選択
        let boss = guerrillaBosses.randomElement()!

        // クイズを用意
        let shuffled = guerrillaQuizPool().shuffled()
        let selectedQuizzes = Array(shuffled.prefix(30))

        let quizzesData: [[String: Any]] = selectedQuizzes.map { quiz in
            [
                "question": quiz.question,
                "choices": quiz.choices,
                "correctAnswerIndex": quiz.correctAnswerIndex,
                "explanation": quiz.explanation
            ]
        }

        // 制限時間なし
        let expiresAt = Date().timeIntervalSince1970 + (365 * 24 * 60 * 60)

        let guerrillaData: [String: Any] = [
            "bossName": boss.name,
            "bossImageName": boss.imageName,
            "bossHP": boss.bossHP,
            "bossMaxHP": boss.bossHP,
            "bossAttack": boss.bossAttack,
            "difficulty": boss.difficulty.rawValue,
            "rewardExperience": boss.rewardExperience,
            "rewardMoney": boss.rewardMoney,
            "status": "active",
            "createdAt": ServerValue.timestamp(),
            "expiresAt": expiresAt,
            "quizzes": quizzesData,
            "players": [String: Any]()
        ]

        guerrillaRef.setValue(guerrillaData)
    }

    private func guerrillaQuizPool() -> [QuizQuestion] {
        let standardPools =
            QuizITBasicList(isPresenting: .constant(false)).quizBeginnerList +
            QuizITStrategyListView(isPresenting: .constant(false)).quizBeginnerList +
            QuizITTechnologyListView(isPresenting: .constant(false)).quizBeginnerList +
            QuizITManagementListView(isPresenting: .constant(false)).quizBeginnerList
        var seenQuestions = Set<String>()
        return standardPools.filter { seenQuestions.insert($0.question).inserted }
    }

    // MARK: - 報酬計算

    func rewardForPlayer(_ player: GuerrillaPlayer) -> (experience: Int, money: Int) {
        let totalDamage = players.reduce(0) { $0 + $1.totalDamage }
        guard totalDamage > 0 else { return (5, 5) }

        let ratio = Double(player.totalDamage) / Double(totalDamage)
        let sorted = players.sorted { $0.totalDamage > $1.totalDamage }
        let rank = (sorted.firstIndex { $0.id == player.id } ?? players.count) + 1

        // MVP（1位）ボーナス: 1.5倍
        let mvpBonus: Double = rank == 1 ? 1.5 : 1.0

        let exp = max(5, Int(Double(rewardExperience) * ratio * mvpBonus))
        let money = max(5, Int(Double(rewardMoney) * ratio * mvpBonus))
        return (exp, money)
    }

    // MARK: - 監視停止

    func stopObserving() {
        if let handle = observerHandle {
            guerrillaRef.removeObserver(withHandle: handle)
        }
        observerHandle = nil
    }

    deinit {
        stopObserving()
    }
}
