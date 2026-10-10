//
//  BattleManager.swift
//  it
//
//  週間リーグの同じグループに所属するメンバーとの非同期1vs1クイズバトルを管理します。
//  勝敗結果はそのまま週間リーグのスコアに反映されます。
//

import Foundation
import FirebaseDatabase

enum BattleCategory: String, CaseIterable, Identifiable {
    case itPassport
    case security
    case fundamentalInfo
    case appliedInfo
    case leagueMixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .itPassport: return "ITパスポート"
        case .security: return "情報セキュリティ"
        case .fundamentalInfo: return "基本情報技術者"
        case .appliedInfo: return "応用情報技術者"
        case .leagueMixed: return "3試験ミックス"
        }
    }

    var questionPool: [QuizQuestion] {
        let pools: [QuizQuestion]
        switch self {
        case .itPassport:
            pools = QuizITBasicList(isPresenting: .constant(false)).quizBeginnerList +
                QuizITStrategyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizITTechnologyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizITManagementListView(isPresenting: .constant(false)).quizBeginnerList
        case .security:
            pools = QuizESsecurityListView(isPresenting: .constant(false)).quizBeginnerList
        case .fundamentalInfo:
            pools = QuizInfoBasicListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizInfoStrategyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizInfoTechnologyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizInfoManagementListView(isPresenting: .constant(false)).quizBeginnerList
        case .appliedInfo:
            pools = QuizAppliedBasicListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizAppliedStrategyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizAppliedTechnologyListView(isPresenting: .constant(false)).quizBeginnerList +
                QuizAppliedManagementListView(isPresenting: .constant(false)).quizBeginnerList
        case .leagueMixed:
            pools = BattleCategory.itPassport.questionPool +
                BattleCategory.fundamentalInfo.questionPool +
                BattleCategory.appliedInfo.questionPool
        }
        var seen = Set<String>()
        return pools.filter { seen.insert($0.question).inserted }
    }
}

struct BattleAnswerRecord: Codable, Equatable {
    let correct: Bool
    let seconds: Double

    var dictionary: [String: Any] {
        ["correct": correct, "seconds": seconds]
    }

    static func from(_ dict: [String: Any]) -> BattleAnswerRecord? {
        guard let correct = dict["correct"] as? Bool else { return nil }
        let seconds = (dict["seconds"] as? Double) ?? Double(dict["seconds"] as? Int ?? 0)
        return BattleAnswerRecord(correct: correct, seconds: seconds)
    }
}

struct BattlePlayerInfo: Codable, Equatable {
    let uid: String
    let name: String
    let avatarName: String?
    let answers: [BattleAnswerRecord]
    let maxHP: Int
    let attack: Int
    let remainingHP: Int?

    init(
        uid: String,
        name: String,
        avatarName: String?,
        answers: [BattleAnswerRecord],
        maxHP: Int = 100,
        attack: Int = 20,
        remainingHP: Int? = nil
    ) {
        self.uid = uid
        self.name = name
        self.avatarName = avatarName
        self.answers = answers
        self.maxHP = max(1, maxHP)
        self.attack = max(1, attack)
        self.remainingHP = remainingHP
    }

    var correctCount: Int { answers.filter(\.correct).count }
    var totalSeconds: Double { answers.reduce(0) { $0 + $1.seconds } }
}

struct BattleCombatantProfile: Equatable {
    let uid: String
    let name: String
    let avatarName: String
    let maxHP: Int
    let attack: Int

    var dictionary: [String: Any] {
        [
            "uid": uid,
            "name": name,
            "avatarName": avatarName,
            "maxHP": maxHP,
            "attack": attack
        ]
    }

    var playerInfo: BattlePlayerInfo {
        BattlePlayerInfo(
            uid: uid,
            name: name,
            avatarName: avatarName,
            answers: [],
            maxHP: maxHP,
            attack: attack
        )
    }
}

struct BattleStartPayload {
    let battleId: String
    let questions: [QuizQuestion]
    let challenger: BattleCombatantProfile
    let opponent: BattleCombatantProfile
}

struct BattlePreparation {
    let opponentLevel: Int
    let usedCount: Int
    let challenger: BattleCombatantProfile?
    let opponent: BattleCombatantProfile?
}

struct BattleSummary: Identifiable {
    let id: String
    let category: String
    let questions: [QuizQuestion]
    let challenger: BattlePlayerInfo
    let opponent: BattlePlayerInfo?
    let status: String // "waiting_opponent" | "finished" | "expired" | "cancelled" | "declined"
    let createdAt: Int64
    let winnerUid: String?
    let challengerLeaguePoints: Int
    let opponentLeaguePoints: Int

    var myRole: Role {
        AuthManager.shared.currentUserId == challenger.uid ? .challenger : .opponent
    }

    /// 自分視点で獲得したリーグポイント。
    var myLeaguePoints: Int {
        myRole == .challenger ? challengerLeaguePoints : opponentLeaguePoints
    }

    enum Role: String, Codable { case challenger, opponent }
}

enum BattleError: LocalizedError {
    case notLoggedIn
    case opponentHasNoAvatar
    case dailyLimitReached
    case battleNotFound
    case alreadyPlayed
    case actionNotAllowed
    case networkError

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "ログイン情報を確認できませんでした。"
        case .opponentHasNoAvatar: return "この相手はまだ代表おともを設定していません。"
        case .dailyLimitReached: return "この相手への挑戦は1日3回までです。明日また挑戦してください。"
        case .battleNotFound: return "対戦データが見つかりませんでした。"
        case .alreadyPlayed: return "この対戦はすでにプレイ済みです。"
        case .actionNotAllowed: return "この対戦は現在その操作を行えません。"
        case .networkError: return "通信エラーが発生しました。時間をおいて再度お試しください。"
        }
    }
}

final class BattleManager: ObservableObject {
    static let shared = BattleManager()
    private init() {}

    @Published var incomingBattles: [BattleSummary] = []
    @Published var isLoadingBattles = false

    private let dailyLimitPerOpponent = 3
    private let winLeaguePoints = 10
    private let drawLeaguePoints = 0
    private let loseLeaguePoints = -10
    private let expirationMilliseconds: Int64 = 3 * 24 * 60 * 60 * 1_000

    var leagueBattleDailyLimit: Int { dailyLimitPerOpponent }
    var leagueBattleWinPoints: Int { winLeaguePoints }
    var leagueBattleLosePoints: Int { loseLeaguePoints }

    private var db: DatabaseReference { Database.database().reference() }
    private var currentUserId: String? { AuthManager.shared.currentUserId }

    // MARK: - 対戦開始

    /// 週間リーグ用。カテゴリ選択を行わず、3試験の問題を混ぜて出題します。
    func startLeagueBattle(
        against opponent: FriendSummary,
        completion: @escaping (Result<BattleStartPayload, BattleError>) -> Void
    ) {
        startBattle(against: opponent, category: .leagueMixed, completion: completion)
    }

    /// 対戦準備画面に表示する相手のレベルと、本日の対戦済み回数を取得します。
    func fetchLeagueBattlePreparation(
        against opponent: FriendSummary,
        completion: @escaping (BattlePreparation) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(BattlePreparation(opponentLevel: 1, usedCount: 0, challenger: nil, opponent: nil))
            return
        }

        dayKey { todayKey in
            let opponentId = opponent.id
            let usageRef = self.db.child("battleUsage").child(userId).child(todayKey).child(opponentId)
            let group = DispatchGroup()
            var level = 1
            var usedCount = 0
            var challenger: BattleCombatantProfile?
            var opponentProfile: BattleCombatantProfile?

            group.enter()
            self.fetchCombatantProfile(uid: userId, fallbackName: "あなた") {
                challenger = $0
                group.leave()
            }
            group.enter()
            self.fetchCombatantProfile(
                uid: opponentId,
                fallbackName: opponent.name,
                fallbackAvatarName: opponent.featuredAvatarName,
                fallbackAvatarAttack: opponent.featuredAvatarAttack
            ) {
                opponentProfile = $0
                group.leave()
            }
            group.enter()
            self.db.child("users").child(opponentId).child("level").observeSingleEvent(of: .value) { snapshot in
                level = max(1, self.intValue(snapshot.value, fallback: 1))
                group.leave()
            } withCancel: { _ in group.leave() }
            group.enter()
            usageRef.observeSingleEvent(of: .value) { snapshot in
                usedCount = max(0, min(self.intValue(snapshot.value), self.dailyLimitPerOpponent))
                group.leave()
            } withCancel: { _ in group.leave() }

            group.notify(queue: .main) {
                completion(BattlePreparation(
                    opponentLevel: level,
                    usedCount: usedCount,
                    challenger: challenger,
                    opponent: opponentProfile
                ))
            }
        }
    }

    /// 週間リーグの同じグループに所属するメンバーを指名して対戦を始めます。
    /// 勝敗結果は週間リーグのスコアにそのまま加算されます。
    func startBattle(
        against opponent: FriendSummary,
        category: BattleCategory,
        completion: @escaping (Result<BattleStartPayload, BattleError>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        dayKey { todayKey in
            let usageRef = self.db.child("battleUsage").child(userId).child(todayKey).child(opponent.id)
            usageRef.runTransactionBlock { mutableData in
                let currentCount = self.intValue(mutableData.value)
                guard currentCount < self.dailyLimitPerOpponent else {
                    return TransactionResult.abort()
                }
                mutableData.value = currentCount + 1
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                guard error == nil else {
                    completion(.failure(.networkError))
                    return
                }
                guard committed else {
                    completion(.failure(.dailyLimitReached))
                    return
                }

                self.fetchCombatantProfile(uid: userId, fallbackName: "あなた") { challengerProfile in
                    self.fetchCombatantProfile(
                        uid: opponent.id,
                        fallbackName: opponent.name,
                        fallbackAvatarName: opponent.featuredAvatarName,
                        fallbackAvatarAttack: opponent.featuredAvatarAttack
                    ) { opponentProfile in
                        guard let challengerProfile, let opponentProfile else {
                            self.releaseUsageReservation(usageRef)
                            completion(.failure(.opponentHasNoAvatar))
                            return
                        }
                        let questions = self.questions(
                            for: category,
                            challenger: challengerProfile,
                            opponent: opponentProfile
                        )
                        guard !questions.isEmpty else {
                            self.releaseUsageReservation(usageRef)
                            completion(.failure(.battleNotFound))
                            return
                        }
                        let battleRef = self.db.child("battles").childByAutoId()
                        guard let battleId = battleRef.key else {
                            self.releaseUsageReservation(usageRef)
                            completion(.failure(.networkError))
                            return
                        }

                        let questionsData: [[String: Any]] = questions.map { quiz in
                            [
                                "question": quiz.question,
                                "choices": quiz.choices,
                                "correctAnswerIndex": quiz.correctAnswerIndex,
                                "explanation": quiz.explanation
                            ]
                        }

                        let battleData: [String: Any] = [
                            "battleMode": "hp",
                            "category": category.rawValue,
                            "questions": questionsData,
                            "challengerUid": userId,
                            "challengerName": challengerProfile.name,
                            "challengerAvatar": challengerProfile.avatarName,
                            "challengerMaxHP": challengerProfile.maxHP,
                            "challengerAttack": challengerProfile.attack,
                            "opponentUid": opponent.id,
                            "opponentName": opponentProfile.name,
                            "opponentAvatar": opponentProfile.avatarName,
                            "opponentMaxHP": opponentProfile.maxHP,
                            "opponentAttack": opponentProfile.attack,
                            "status": "challenger_playing",
                            "createdAt": ServerValue.timestamp()
                        ]

                        battleRef.setValue(battleData) { error, _ in
                            guard error == nil else {
                                self.releaseUsageReservation(usageRef)
                                completion(.failure(.networkError))
                                return
                            }
                            completion(.success(BattleStartPayload(
                                battleId: battleId,
                                questions: questions,
                                challenger: challengerProfile,
                                opponent: opponentProfile
                            )))
                        }
                    }
                }
            }
        }
    }

    /// HP制バトルを確定します。正解なら相手へ、不正解・時間切れなら自分へダメージが入ります。
    func finishLeagueHPBattle(
        battleId: String,
        answers: [BattleAnswerRecord],
        completion: @escaping (Result<BattleSummary, BattleError>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        let battleRef = db.child("battles").child(battleId)
        battleRef.observeSingleEvent(of: .value) { snapshot in
            guard var value = snapshot.value as? [String: Any],
                  value["battleMode"] as? String == "hp",
                  value["challengerUid"] as? String == userId,
                  let challenger = self.playerInfo(prefix: "challenger", value: value, answers: answers),
                  let opponent = self.playerInfo(prefix: "opponent", value: value, answers: []) else {
                completion(.failure(.actionNotAllowed))
                return
            }

            if value["status"] as? String == "finished" {
                self.applyHPBattlePointsIfNeeded(battleId: battleId, value: value)
                guard let summary = self.parseBattle(id: battleId, value: value) else {
                    completion(.failure(.battleNotFound))
                    return
                }
                completion(.success(summary))
                return
            }
            guard value["status"] as? String == "challenger_playing" else {
                completion(.failure(.actionNotAllowed))
                return
            }

            let result = self.resolveHPBattle(answers: answers, challenger: challenger, opponent: opponent)
            guard result.challengerRemainingHP == 0 || result.opponentRemainingHP == 0 else {
                completion(.failure(.actionNotAllowed))
                return
            }
            let challengerPoints = result.winnerUid == challenger.uid ? self.winLeaguePoints : self.loseLeaguePoints
            let opponentPoints = -challengerPoints
            let updates: [String: Any] = [
                "challengerAnswers": result.answers.map(\.dictionary),
                "status": "finished",
                "winnerUid": result.winnerUid,
                "challengerRemainingHP": result.challengerRemainingHP,
                "opponentRemainingHP": result.opponentRemainingHP,
                "challengerLeaguePoints": challengerPoints,
                "opponentLeaguePoints": opponentPoints,
                "finishedAt": ServerValue.timestamp()
            ]
            battleRef.updateChildValues(updates) { error, _ in
                guard error == nil else {
                    completion(.failure(.networkError))
                    return
                }
                value["challengerAnswers"] = result.answers.map(\.dictionary)
                value["status"] = "finished"
                value["winnerUid"] = result.winnerUid
                value["challengerRemainingHP"] = result.challengerRemainingHP
                value["opponentRemainingHP"] = result.opponentRemainingHP
                value["challengerLeaguePoints"] = challengerPoints
                value["opponentLeaguePoints"] = opponentPoints
                self.applyHPBattlePointsIfNeeded(battleId: battleId, value: value)
                guard let summary = self.parseBattle(id: battleId, value: value) else {
                    completion(.failure(.battleNotFound))
                    return
                }
                completion(.success(summary))
            }
        }
    }

    /// 挑戦者が5問解き終えたときに呼びます。対戦相手への招待が届きます。
    func submitChallengerResult(battleId: String, answers: [BattleAnswerRecord], completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(false)
            return
        }
        let battleRef = db.child("battles").child(battleId)
        let answersData = answers.map { $0.dictionary }
        let updates: [String: Any] = [
            "challengerAnswers": answersData,
            "status": "waiting_opponent"
        ]
        battleRef.updateChildValues(updates) { error, _ in
            guard error == nil else {
                completion?(false)
                return
            }
            battleRef.observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let opponentUid = value["opponentUid"] as? String,
                      let category = value["category"] as? String,
                      let challengerName = value["challengerName"] as? String else {
                    completion?(true)
                    return
                }
                let indexUpdates: [String: Any] = [
                    "userBattles/\(userId)/\(battleId)": [
                        "role": "challenger",
                        "status": "waiting_opponent",
                        "opponentName": value["opponentName"] as? String ?? "",
                        "category": category,
                        "createdAt": value["createdAt"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)
                    ],
                    "userBattles/\(opponentUid)/\(battleId)": [
                        "role": "opponent",
                        "status": "waiting_opponent",
                        "opponentName": challengerName,
                        "category": category,
                        "createdAt": value["createdAt"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)
                    ]
                ]
                self.db.updateChildValues(indexUpdates) { error, _ in
                    completion?(error == nil)
                }
            }
        }
    }

    /// 対戦相手が5問解き終えたときに呼びます。勝敗を確定し、その場で両者のリーグスコアに反映します。
    func submitOpponentResult(battleId: String, answers: [BattleAnswerRecord], completion: @escaping (Result<BattleSummary, BattleError>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        let battleRef = db.child("battles").child(battleId)
        battleRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let challengerUid = value["challengerUid"] as? String,
                  let opponentUid = value["opponentUid"] as? String,
                  opponentUid == userId,
                  value["status"] as? String == "waiting_opponent",
                  let challengerAnswersData = value["challengerAnswers"] as? [[String: Any]] else {
                completion(.failure(.actionNotAllowed))
                return
            }
            if value["opponentAnswers"] != nil {
                completion(.failure(.alreadyPlayed))
                return
            }

            let challengerAnswers = challengerAnswersData.compactMap(BattleAnswerRecord.from)
            let challengerCorrect = challengerAnswers.filter(\.correct).count
            let challengerSeconds = challengerAnswers.reduce(0) { $0 + $1.seconds }
            let opponentCorrect = answers.filter(\.correct).count
            let opponentSeconds = answers.reduce(0) { $0 + $1.seconds }

            let winnerUid: String
            if opponentCorrect != challengerCorrect {
                winnerUid = opponentCorrect > challengerCorrect ? userId : challengerUid
            } else if opponentSeconds != challengerSeconds {
                winnerUid = opponentSeconds < challengerSeconds ? userId : challengerUid
            } else {
                winnerUid = "draw"
            }

            let challengerPoints = self.leaguePoints(isWinner: winnerUid == challengerUid, isDraw: winnerUid == "draw")
            let opponentPoints = self.leaguePoints(isWinner: winnerUid == userId, isDraw: winnerUid == "draw")

            let updates: [String: Any] = [
                "battles/\(battleId)/opponentAnswers": answers.map { $0.dictionary },
                "battles/\(battleId)/status": "finished",
                "battles/\(battleId)/winnerUid": winnerUid,
                "battles/\(battleId)/challengerLeaguePoints": challengerPoints,
                "battles/\(battleId)/opponentLeaguePoints": opponentPoints,
                "userBattles/\(userId)/\(battleId)/status": "finished",
                "userBattles/\(challengerUid)/\(battleId)/status": "finished"
            ]

            self.db.updateChildValues(updates) { error, _ in
                guard error == nil else {
                    completion(.failure(.networkError))
                    return
                }

                if challengerPoints != 0 {
                    WeeklyLeagueService.shared.awardBattlePoints(userId: challengerUid, points: challengerPoints, battleId: battleId)
                }
                if opponentPoints != 0 {
                    WeeklyLeagueService.shared.awardBattlePoints(userId: userId, points: opponentPoints, battleId: battleId)
                }

                guard let questions = self.parseQuestions(value["questions"]),
                      let category = value["category"] as? String else {
                    completion(.failure(.battleNotFound))
                    return
                }
                let challenger = BattlePlayerInfo(
                    uid: challengerUid,
                    name: value["challengerName"] as? String ?? "名無し",
                    avatarName: value["challengerAvatar"] as? String,
                    answers: challengerAnswers
                )
                let opponent = BattlePlayerInfo(
                    uid: userId,
                    name: value["opponentName"] as? String ?? "名無し",
                    avatarName: value["opponentAvatar"] as? String,
                    answers: answers
                )
                let summary = BattleSummary(
                    id: battleId,
                    category: category,
                    questions: questions,
                    challenger: challenger,
                    opponent: opponent,
                    status: "finished",
                    createdAt: (value["createdAt"] as? Int64) ?? 0,
                    winnerUid: winnerUid,
                    challengerLeaguePoints: challengerPoints,
                    opponentLeaguePoints: opponentPoints
                )
                completion(.success(summary))
            }
        }
    }

    /// 勝敗に応じて獲得するリーグポイント。
    private func leaguePoints(isWinner: Bool, isDraw: Bool) -> Int {
        if isWinner { return winLeaguePoints }
        if isDraw { return drawLeaguePoints }
        return loseLeaguePoints
    }

    // MARK: - 保留中の対戦操作

    func cancelOutgoingBattle(battleId: String, completion: @escaping (Result<Void, BattleError>) -> Void) {
        closePendingBattle(
            battleId: battleId,
            requiredParticipantKey: "challengerUid",
            terminalStatus: "cancelled",
            completion: completion
        )
    }

    func declineIncomingBattle(battleId: String, completion: @escaping (Result<Void, BattleError>) -> Void) {
        closePendingBattle(
            battleId: battleId,
            requiredParticipantKey: "opponentUid",
            terminalStatus: "declined",
            completion: completion
        )
    }

    private func closePendingBattle(
        battleId: String,
        requiredParticipantKey: String,
        terminalStatus: String,
        completion: @escaping (Result<Void, BattleError>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        let battleRef = db.child("battles").child(battleId)
        battleRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  value[requiredParticipantKey] as? String == userId,
                  value["status"] as? String == "waiting_opponent",
                  let challengerUid = value["challengerUid"] as? String,
                  let opponentUid = value["opponentUid"] as? String else {
                completion(.failure(.actionNotAllowed))
                return
            }
            let updates: [String: Any] = [
                "battles/\(battleId)/status": terminalStatus,
                "battles/\(battleId)/closedAt": ServerValue.timestamp(),
                "userBattles/\(challengerUid)/\(battleId)": NSNull(),
                "userBattles/\(opponentUid)/\(battleId)": NSNull()
            ]
            self.db.updateChildValues(updates) { error, _ in
                guard error == nil else {
                    completion(.failure(.networkError))
                    return
                }
                self.fetchMyBattles()
                completion(.success(()))
            }
        }
    }

    // MARK: - 一覧取得

    func fetchBattle(battleId: String, completion: @escaping (BattleSummary?) -> Void) {
        guard !battleId.isEmpty else {
            completion(nil)
            return
        }
        db.child("battles").child(battleId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let summary = self.parseBattle(id: battleId, value: snapshot.value as? [String: Any])
            DispatchQueue.main.async { completion(summary) }
        } withCancel: { _ in
            DispatchQueue.main.async { completion(nil) }
        }
    }

    /// 現在自分が回答すべき対戦招待を取得します。期限切れ・辞退済みなどはあわせて片付けます。
    func fetchMyBattles(completion: (() -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?()
            return
        }
        DispatchQueue.main.async { self.isLoadingBattles = true }
        db.child("userBattles").child(userId).observeSingleEvent(of: .value) { snapshot in
            let entries = snapshot.children.compactMap { $0 as? DataSnapshot }
            guard !entries.isEmpty else {
                DispatchQueue.main.async {
                    self.incomingBattles = []
                    self.isLoadingBattles = false
                }
                completion?()
                return
            }

            let group = DispatchGroup()
            var incoming: [BattleSummary] = []
            let lock = NSLock()

            for entry in entries {
                guard let indexValue = entry.value as? [String: Any],
                      let role = indexValue["role"] as? String,
                      let status = indexValue["status"] as? String else { continue }

                group.enter()
                self.db.child("battles").child(entry.key).observeSingleEvent(of: .value) { battleSnapshot in
                    defer { group.leave() }
                    guard let summary = self.parseBattle(id: entry.key, value: battleSnapshot.value as? [String: Any]) else { return }
                    if self.shouldExpire(summary) {
                        self.expire(summary)
                    } else if ["expired", "cancelled", "declined"].contains(summary.status) {
                        self.removeBattleIndex(summary)
                    } else if summary.status != "finished", status != "finished", role == "opponent" {
                        lock.lock()
                        incoming.append(summary)
                        lock.unlock()
                    }
                }
            }

            group.notify(queue: .main) {
                self.incomingBattles = incoming.sorted { $0.createdAt > $1.createdAt }
                self.isLoadingBattles = false
                completion?()
            }
        }
    }

    // MARK: - Helpers

    private func parseBattle(id: String, value: [String: Any]?) -> BattleSummary? {
        guard let value,
              let category = value["category"] as? String,
              let challengerUid = value["challengerUid"] as? String,
              let challengerName = value["challengerName"] as? String,
              let opponentUid = value["opponentUid"] as? String,
              let opponentName = value["opponentName"] as? String,
              let status = value["status"] as? String,
              let questions = parseQuestions(value["questions"]) else {
            return nil
        }
        let challengerAnswers = (value["challengerAnswers"] as? [[String: Any]] ?? []).compactMap(BattleAnswerRecord.from)
        let challenger = BattlePlayerInfo(
            uid: challengerUid,
            name: challengerName,
            avatarName: value["challengerAvatar"] as? String,
            answers: challengerAnswers,
            maxHP: intValue(value["challengerMaxHP"], fallback: 100),
            attack: intValue(value["challengerAttack"], fallback: 20),
            remainingHP: optionalIntValue(value["challengerRemainingHP"])
        )
        let opponentAnswersData = value["opponentAnswers"] as? [[String: Any]] ?? []
        let opponent = BattlePlayerInfo(
            uid: opponentUid,
            name: opponentName,
            avatarName: value["opponentAvatar"] as? String,
            answers: opponentAnswersData.compactMap(BattleAnswerRecord.from),
            maxHP: intValue(value["opponentMaxHP"], fallback: 100),
            attack: intValue(value["opponentAttack"], fallback: 20),
            remainingHP: optionalIntValue(value["opponentRemainingHP"])
        )
        return BattleSummary(
            id: id,
            category: category,
            questions: questions,
            challenger: challenger,
            opponent: opponent,
            status: status,
            createdAt: (value["createdAt"] as? Int64) ?? 0,
            winnerUid: value["winnerUid"] as? String,
            challengerLeaguePoints: intValue(value["challengerLeaguePoints"]),
            opponentLeaguePoints: intValue(value["opponentLeaguePoints"])
        )
    }

    private func parseQuestions(_ raw: Any?) -> [QuizQuestion]? {
        guard let list = raw as? [[String: Any]] else { return nil }
        return list.compactMap { dict in
            guard let question = dict["question"] as? String,
                  let choices = dict["choices"] as? [String],
                  let correctAnswerIndex = dict["correctAnswerIndex"] as? Int,
                  let explanation = dict["explanation"] as? String else { return nil }
            return QuizQuestion(question: question, choices: choices, correctAnswerIndex: correctAnswerIndex, explanation: explanation)
        }
    }

    private struct HPBattleResolution {
        let answers: [BattleAnswerRecord]
        let challengerRemainingHP: Int
        let opponentRemainingHP: Int
        let winnerUid: String
    }

    private func resolveHPBattle(
        answers: [BattleAnswerRecord],
        challenger: BattlePlayerInfo,
        opponent: BattlePlayerInfo
    ) -> HPBattleResolution {
        var challengerHP = challenger.maxHP
        var opponentHP = opponent.maxHP
        var appliedAnswers: [BattleAnswerRecord] = []

        for answer in answers where challengerHP > 0 && opponentHP > 0 {
            appliedAnswers.append(answer)
            if answer.correct {
                opponentHP = max(0, opponentHP - challenger.attack)
            } else {
                challengerHP = max(0, challengerHP - opponent.attack)
            }
        }

        // 保存済みの問題数が尽きた旧データでも必ず勝敗を確定できるよう、残HPで判定します。
        let winnerUid: String
        if opponentHP == 0 {
            winnerUid = challenger.uid
        } else if challengerHP == 0 {
            winnerUid = opponent.uid
        } else {
            let challengerRatio = Double(challengerHP) / Double(challenger.maxHP)
            let opponentRatio = Double(opponentHP) / Double(opponent.maxHP)
            winnerUid = challengerRatio >= opponentRatio ? challenger.uid : opponent.uid
        }
        return HPBattleResolution(
            answers: appliedAnswers,
            challengerRemainingHP: challengerHP,
            opponentRemainingHP: opponentHP,
            winnerUid: winnerUid
        )
    }

    private func applyHPBattlePointsIfNeeded(battleId: String, value: [String: Any]) {
        guard let challengerUid = value["challengerUid"] as? String,
              let opponentUid = value["opponentUid"] as? String else { return }
        let challengerPoints = intValue(value["challengerLeaguePoints"])
        let opponentPoints = intValue(value["opponentLeaguePoints"])
        WeeklyLeagueService.shared.awardBattlePoints(
            userId: challengerUid,
            points: challengerPoints,
            battleId: battleId
        )
        // 開発用リーグ参加者は Firebase 上のユーザーではないため、相手側の加減算は行わない。
        if !opponentUid.hasPrefix("demo-") {
            WeeklyLeagueService.shared.awardBattlePoints(
                userId: opponentUid,
                points: opponentPoints,
                battleId: battleId
            )
        }
    }

    private func playerInfo(
        prefix: String,
        value: [String: Any],
        answers: [BattleAnswerRecord]
    ) -> BattlePlayerInfo? {
        guard let uid = value["\(prefix)Uid"] as? String,
              let name = value["\(prefix)Name"] as? String else { return nil }
        return BattlePlayerInfo(
            uid: uid,
            name: name,
            avatarName: value["\(prefix)Avatar"] as? String,
            answers: answers,
            maxHP: intValue(value["\(prefix)MaxHP"], fallback: 100),
            attack: intValue(value["\(prefix)Attack"], fallback: 20),
            remainingHP: optionalIntValue(value["\(prefix)RemainingHP"])
        )
    }

    private func questions(
        for category: BattleCategory,
        challenger: BattleCombatantProfile,
        opponent: BattleCombatantProfile
    ) -> [QuizQuestion] {
        let pool = category.questionPool.shuffled()
        guard !pool.isEmpty else { return [] }
        let hitsToDefeatOpponent = Int(ceil(Double(opponent.maxHP) / Double(challenger.attack)))
        let hitsToDefeatChallenger = Int(ceil(Double(challenger.maxHP) / Double(opponent.attack)))
        let requiredCount = max(1, hitsToDefeatOpponent + hitsToDefeatChallenger - 1)
        return (0..<requiredCount).map { pool[$0 % pool.count] }
    }

    private func fetchCombatantProfile(
        uid: String,
        fallbackName: String,
        fallbackAvatarName: String? = nil,
        fallbackAvatarAttack: Int = 0,
        completion: @escaping (BattleCombatantProfile?) -> Void
    ) {
        db.child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(self.fallbackCombatantProfile(
                    uid: uid,
                    name: fallbackName,
                    avatarName: fallbackAvatarName,
                    avatarAttack: fallbackAvatarAttack
                ))
                return
            }
            let usedName = value["usedAvatarName"] as? String
            let featured = value["featuredAvatar"] as? [String: Any]
            let avatarValues: [[String: Any]] = {
                if let avatars = value["avatars"] as? [String: Any] {
                    return avatars.values.compactMap { $0 as? [String: Any] }
                }
                return value["avatars"] as? [[String: Any]] ?? []
            }()
            let selected = usedName.flatMap { name in
                avatarValues.first { $0["name"] as? String == name }
            } ?? avatarValues.first { self.intValue($0["usedFlag"]) == 1 }
            let avatar = selected ?? featured
            let avatarName = (selected?["name"] as? String)
                ?? usedName
                ?? (featured?["name"] as? String)
                ?? fallbackAvatarName
            guard let avatarName, !avatarName.isEmpty else {
                completion(nil)
                return
            }
            let baseHP = self.intValue(value["userHp"], fallback: 100)
            let baseAttack = self.intValue(value["userAttack"], fallback: 20)
            let avatarHP = self.optionalIntValue(avatar?["health"]) ?? 20
            let avatarAttack = self.optionalIntValue(avatar?["attack"])
                ?? (fallbackAvatarAttack > 0 ? fallbackAvatarAttack : 20)
            completion(BattleCombatantProfile(
                uid: uid,
                name: (value["userName"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? fallbackName,
                avatarName: avatarName,
                maxHP: max(1, baseHP + avatarHP),
                attack: max(1, baseAttack + avatarAttack)
            ))
        } withCancel: { _ in
            completion(self.fallbackCombatantProfile(
                uid: uid,
                name: fallbackName,
                avatarName: fallbackAvatarName,
                avatarAttack: fallbackAvatarAttack
            ))
        }
    }

    /// 旧形式のリーグ参加者や開発用参加者には公開プロフィールしかないため、
    /// 初期ユーザー値（HP 100 / ATK 20）と初期おとも相当の値で戦闘可能にします。
    private func fallbackCombatantProfile(
        uid: String,
        name: String,
        avatarName: String?,
        avatarAttack: Int
    ) -> BattleCombatantProfile? {
        guard let avatarName, !avatarName.isEmpty else { return nil }
        return BattleCombatantProfile(
            uid: uid,
            name: name,
            avatarName: avatarName,
            maxHP: 120,
            attack: 20 + (avatarAttack > 0 ? avatarAttack : 20)
        )
    }

    private func intValue(_ raw: Any?, fallback: Int = 0) -> Int {
        if let value = raw as? Int { return value }
        if let value = raw as? NSNumber { return value.intValue }
        if let value = raw as? String, let parsed = Int(value) { return parsed }
        return fallback
    }

    private func optionalIntValue(_ raw: Any?) -> Int? {
        guard raw != nil, !(raw is NSNull) else { return nil }
        return intValue(raw)
    }

    private func releaseUsageReservation(_ usageRef: DatabaseReference) {
        usageRef.runTransactionBlock { mutableData in
            let current = self.intValue(mutableData.value)
            mutableData.value = max(0, current - 1)
            return TransactionResult.success(withValue: mutableData)
        }
    }

    private func shouldExpire(_ battle: BattleSummary) -> Bool {
        guard battle.status == "waiting_opponent", battle.createdAt > 0 else { return false }
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        return now - battle.createdAt >= expirationMilliseconds
    }

    private func expire(_ battle: BattleSummary) {
        var updates: [String: Any] = [
            "battles/\(battle.id)/status": "expired",
            "battles/\(battle.id)/closedAt": ServerValue.timestamp(),
            "userBattles/\(battle.challenger.uid)/\(battle.id)": NSNull()
        ]
        if let opponentUid = battle.opponent?.uid, !opponentUid.isEmpty {
            updates["userBattles/\(opponentUid)/\(battle.id)"] = NSNull()
        }
        db.updateChildValues(updates)
    }

    private func removeBattleIndex(_ battle: BattleSummary) {
        var updates: [String: Any] = [
            "userBattles/\(battle.challenger.uid)/\(battle.id)": NSNull()
        ]
        if let opponentUid = battle.opponent?.uid, !opponentUid.isEmpty {
            updates["userBattles/\(opponentUid)/\(battle.id)"] = NSNull()
        }
        db.updateChildValues(updates)
    }

    private func dayKey(completion: @escaping (String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = Calendar.current.timeZone
        completion(formatter.string(from: Date()))
    }
}
