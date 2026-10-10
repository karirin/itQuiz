import Foundation
import FirebaseAuth
import FirebaseDatabase

enum WeeklyLeagueTier: String, CaseIterable, Codable {
    case bronze
    case silver
    case gold
    case master

    var displayName: String {
        switch self {
        case .bronze: return "ブロンズ"
        case .silver: return "シルバー"
        case .gold: return "ゴールド"
        case .master: return "マスター"
        }
    }

    var assetName: String {
        switch self {
        case .bronze: return "GuildRankBronze"
        case .silver: return "GuildRankSilver"
        case .gold: return "GuildRankGold"
        case .master: return "GuildRankMaster"
        }
    }

    var promoted: WeeklyLeagueTier {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold, .master: return .master
        }
    }

    var relegated: WeeklyLeagueTier {
        switch self {
        case .bronze, .silver: return .bronze
        case .gold: return .silver
        case .master: return .gold
        }
    }
}

enum WeeklyLeagueMovement: String, Codable {
    case promoted
    case stayed
    case relegated
}

struct WeeklyLeagueSeason: Equatable {
    let id: String
    let startsAt: Date
    let endsAt: Date
}

struct WeeklyLeagueMember: Identifiable, Equatable {
    let id: String
    let userName: String
    let avatarName: String
    let score: Int
    let scoreReachedAt: TimeInterval
    let joinedAt: TimeInterval
}

struct WeeklyLeagueMembership: Equatable {
    let seasonId: String
    let groupId: String
    let tier: WeeklyLeagueTier
}

struct WeeklyLeagueResult: Identifiable, Equatable {
    var id: String { seasonId }

    let seasonId: String
    let tier: WeeklyLeagueTier
    let rank: Int
    let score: Int
    let movement: WeeklyLeagueMovement
    let nextTier: WeeklyLeagueTier
    let rewardCoins: Int
    var rewardClaimed: Bool
}

struct WeeklyLeagueResolution {
    let season: WeeklyLeagueSeason
    let tier: WeeklyLeagueTier
    let membership: WeeklyLeagueMembership?
    let pendingResult: WeeklyLeagueResult?
}

enum WeeklyLeaguePointRules {
    static let correctAnswer = 10
    static let incorrectAnswer = 2
    static let quizCompletion = 10

    static let minimumAnswersForAccuracyBonus = 5
    static let firstQuizOfDay = 20
    static let reviewAnswer = 5
    static let maximumDailyReviewBonus = 30
    static let challengeClear = 20

    static func accuracyBonus(correctAnswers: Int, totalAnswers: Int) -> Int {
        guard totalAnswers >= minimumAnswersForAccuracyBonus else { return 0 }
        let accuracy = Double(correctAnswers) / Double(totalAnswers)
        if accuracy == 1 { return 40 }
        if accuracy >= 0.9 { return 20 }
        if accuracy >= 0.8 { return 10 }
        return 0
    }

    static func comboBonus(maximumCorrectStreak: Int) -> Int {
        if maximumCorrectStreak >= 10 { return 20 }
        if maximumCorrectStreak >= 5 { return 10 }
        if maximumCorrectStreak >= 3 { return 5 }
        return 0
    }

    static func continuationBonus(streakDays: Int) -> Int {
        guard streakDays >= 2 else { return 0 }
        return min((streakDays - 1) * 5, 30)
    }
}

struct WeeklyLeagueQuizContext {
    let correctAnswers: Int
    let totalAnswers: Int
    let maximumCorrectStreak: Int
    let isReview: Bool
    let didClearChallenge: Bool

    init(results: [QuizResult], quizLevel: QuizLevel, didClear: Bool) {
        totalAnswers = results.count
        correctAnswers = results.filter(\.isCorrect).count

        var currentStreak = 0
        var bestStreak = 0
        for result in results {
            if result.isCorrect {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        maximumCorrectStreak = bestStreak
        isReview = quizLevel.isWeeklyLeagueReview
        didClearChallenge = didClear && quizLevel.isWeeklyLeagueChallenge
    }
}

private extension QuizLevel {
    var isWeeklyLeagueReview: Bool {
        switch self {
        case .incorrectAnswer, .incorrectITAnswer, .incorrectInfoAnswer,
             .incorrectAppliedAnswer, .incorrectESAnswer, .incorrectITStrategyAnswer:
            return true
        default:
            return false
        }
    }

    var isWeeklyLeagueChallenge: Bool {
        switch self {
        case .advanced, .god, .timeBeginner, .timeIntermediate, .timeAdvanced:
            return true
        default:
            return false
        }
    }
}

private struct WeeklyLeagueActivityBonuses {
    let firstQuiz: Int
    let continuation: Int
    let review: Int
    let challenge: Int

    static let zero = WeeklyLeagueActivityBonuses(
        firstQuiz: 0,
        continuation: 0,
        review: 0,
        challenge: 0
    )
}

private struct WeeklyLeaguePointBreakdown {
    let correctAnswers: Int
    let incorrectAnswers: Int
    let completion: Int
    let accuracy: Int
    let combo: Int
    let firstQuiz: Int
    let continuation: Int
    let review: Int
    let challenge: Int

    var total: Int {
        correctAnswers + incorrectAnswers + completion + accuracy + combo
            + firstQuiz + continuation + review + challenge
    }

    var firebaseValue: [String: Any] {
        [
            "correctAnswers": correctAnswers,
            "incorrectAnswers": incorrectAnswers,
            "completion": completion,
            "accuracy": accuracy,
            "combo": combo,
            "firstQuiz": firstQuiz,
            "continuation": continuation,
            "review": review,
            "challenge": challenge,
            "total": total
        ]
    }
}

enum WeeklyLeagueServiceError: LocalizedError {
    case notAuthenticated
    case invalidProfile
    case membershipFailed
    case bonusFailed
    case rewardNotGranted
    case database(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "ログイン情報を確認できませんでした。"
        case .invalidProfile:
            return "リーグ情報を読み込めませんでした。"
        case .membershipFailed:
            return "リーグへの参加に失敗しました。"
        case .bonusFailed:
            return "リーグボーナスを計算できませんでした。"
        case .rewardNotGranted:
            return "報酬を受け取れませんでした。通信環境を確認して、もう一度お試しください。"
        case .database(let error):
            return error.localizedDescription
        }
    }
}

/// Realtime Database backed weekly league.
///
/// This implementation intentionally keeps each season immutable after it ends. A new
/// season is selected from server-adjusted time, and a user's previous result is lazily
/// finalized before they enter the new season.
final class WeeklyLeagueService {
    static let shared = WeeklyLeagueService()

    static let groupSize = 25

    private let root = Database.database().reference()
    private let calendarTimeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
    private var serverTimeOffset: TimeInterval = 0
    private var serverTimeHandle: DatabaseHandle?

    private init() {
        let offsetRef = root.child(".info/serverTimeOffset")
        serverTimeHandle = offsetRef.observe(.value) { [weak self] snapshot in
            guard let milliseconds = WeeklyLeagueService.doubleValue(snapshot.value) else { return }
            self?.serverTimeOffset = milliseconds / 1_000
        }
    }

    deinit {
        if let serverTimeHandle {
            root.child(".info/serverTimeOffset").removeObserver(withHandle: serverTimeHandle)
        }
    }

    var serverAdjustedNow: Date {
        Date().addingTimeInterval(serverTimeOffset)
    }

    func season(containing date: Date? = nil) -> WeeklyLeagueSeason {
        let now = date ?? serverAdjustedNow
        let shiftedDate = now.addingTimeInterval(-4 * 60 * 60)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = calendarTimeZone

        let interval = calendar.dateInterval(of: .weekOfYear, for: shiftedDate)
        let shiftedStart = interval?.start ?? shiftedDate
        let startsAt = shiftedStart.addingTimeInterval(4 * 60 * 60)
        let endsAt = calendar.date(byAdding: .day, value: 7, to: startsAt)
            ?? startsAt.addingTimeInterval(7 * 24 * 60 * 60)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: shiftedDate)
        let year = components.yearForWeekOfYear ?? calendar.component(.year, from: shiftedDate)
        let week = components.weekOfYear ?? 1

        return WeeklyLeagueSeason(
            id: String(format: "%04d-W%02d", year, week),
            startsAt: startsAt,
            endsAt: endsAt
        )
    }

    func resolveCurrentLeague(
        userId: String,
        completion: @escaping (Result<WeeklyLeagueResolution, Error>) -> Void
    ) {
        let currentSeason = season()
        let profileRef = root.child("leagueProfiles").child(userId)

        profileRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let profile = snapshot.value as? [String: Any] ?? [:]
            let tier = WeeklyLeagueTier(rawValue: profile["currentTier"] as? String ?? "") ?? .bronze
            let profileSeasonId = profile["currentSeasonId"] as? String
            let profileGroupId = profile["currentGroupId"] as? String

            if profileSeasonId == currentSeason.id, let profileGroupId, !profileGroupId.isEmpty {
                let membership = WeeklyLeagueMembership(
                    seasonId: currentSeason.id,
                    groupId: profileGroupId,
                    tier: tier
                )
                self.loadPendingResult(userId: userId, profile: profile) { result in
                    completion(.success(WeeklyLeagueResolution(
                        season: currentSeason,
                        tier: tier,
                        membership: membership,
                        pendingResult: result
                    )))
                }
                return
            }

            guard let previousSeasonId = profileSeasonId,
                  let previousGroupId = profileGroupId,
                  !previousSeasonId.isEmpty,
                  !previousGroupId.isEmpty else {
                self.loadPendingResult(userId: userId, profile: profile) { result in
                    completion(.success(WeeklyLeagueResolution(
                        season: currentSeason,
                        tier: tier,
                        membership: nil,
                        pendingResult: result
                    )))
                }
                return
            }

            self.finalizePreviousSeason(
                userId: userId,
                seasonId: previousSeasonId,
                groupId: previousGroupId,
                tier: tier
            ) { result in
                switch result {
                case .success(let leagueResult):
                    completion(.success(WeeklyLeagueResolution(
                        season: currentSeason,
                        tier: leagueResult.nextTier,
                        membership: nil,
                        pendingResult: leagueResult.rewardClaimed ? nil : leagueResult
                    )))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } withCancel: { error in
            completion(.failure(WeeklyLeagueServiceError.database(error)))
        }
    }

    @discardableResult
    func observeGroup(
        membership: WeeklyLeagueMembership,
        onChange: @escaping (Result<[WeeklyLeagueMember], Error>) -> Void
    ) -> (reference: DatabaseReference, handle: DatabaseHandle) {
        let reference = root
            .child("leagueGroups")
            .child(membership.seasonId)
            .child(membership.groupId)
            .child("members")

        let handle = reference.observe(.value) { snapshot in
            let members = self.members(from: snapshot)
            onChange(.success(members))
        } withCancel: { error in
            onChange(.failure(WeeklyLeagueServiceError.database(error)))
        }
        return (reference, handle)
    }

    func recordQuizResult(
        userId: String,
        context: WeeklyLeagueQuizContext,
        sessionId: String,
        completion: ((Result<Int, Error>) -> Void)? = nil
    ) {
        let safeTotal = max(context.totalAnswers, 0)
        let safeCorrect = min(max(context.correctAnswers, 0), safeTotal)
        guard safeTotal > 0 else {
            completion?(.success(0))
            return
        }

        let wrongAnswers = safeTotal - safeCorrect
        let currentSeason = season()
        let receiptRef = root
            .child("leaguePointReceipts")
            .child(currentSeason.id)
            .child(userId)
            .child(sessionId)

        receiptRef.runTransactionBlock { mutableData in
            guard Self.isAbsent(mutableData.value) else { return TransactionResult.abort() }
            mutableData.value = [
                "status": "pending",
                "ruleVersion": 2,
                "createdAt": self.serverAdjustedNow.timeIntervalSince1970 * 1_000
            ]
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { [weak self] error, committed, _ in
            guard let self else { return }
            if let error {
                completion?(.failure(WeeklyLeagueServiceError.database(error)))
                return
            }
            guard committed else {
                completion?(.success(0))
                return
            }

            self.claimActivityBonuses(userId: userId, context: context) { bonusResult in
                switch bonusResult {
                case .failure(let error):
                    receiptRef.removeValue()
                    completion?(.failure(error))
                case .success(let activityBonuses):
                    let breakdown = WeeklyLeaguePointBreakdown(
                        correctAnswers: safeCorrect * WeeklyLeaguePointRules.correctAnswer,
                        incorrectAnswers: wrongAnswers * WeeklyLeaguePointRules.incorrectAnswer,
                        completion: WeeklyLeaguePointRules.quizCompletion,
                        accuracy: WeeklyLeaguePointRules.accuracyBonus(
                            correctAnswers: safeCorrect,
                            totalAnswers: safeTotal
                        ),
                        combo: WeeklyLeaguePointRules.comboBonus(
                            maximumCorrectStreak: context.maximumCorrectStreak
                        ),
                        firstQuiz: activityBonuses.firstQuiz,
                        continuation: activityBonuses.continuation,
                        review: activityBonuses.review,
                        challenge: activityBonuses.challenge
                    )

                    self.resolveCurrentLeague(userId: userId) { resolutionResult in
                        switch resolutionResult {
                        case .failure(let error):
                            receiptRef.removeValue()
                            completion?(.failure(error))
                        case .success(let resolution):
                            if let membership = resolution.membership {
                                self.add(
                                    breakdown: breakdown,
                                    userId: userId,
                                    membership: membership,
                                    receiptRef: receiptRef,
                                    completion: completion
                                )
                            } else {
                                self.joinCurrentSeason(
                                    userId: userId,
                                    tier: resolution.tier,
                                    season: resolution.season
                                ) { joinResult in
                                    switch joinResult {
                                    case .success(let membership):
                                        self.add(
                                            breakdown: breakdown,
                                            userId: userId,
                                            membership: membership,
                                            receiptRef: receiptRef,
                                            completion: completion
                                        )
                                    case .failure(let error):
                                        receiptRef.removeValue()
                                        completion?(.failure(error))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func claimActivityBonuses(
        userId: String,
        context: WeeklyLeagueQuizContext,
        completion: @escaping (Result<WeeklyLeagueActivityBonuses, Error>) -> Void
    ) {
        let today = dayIndex(for: serverAdjustedNow)
        let activityRef = root.child("leagueActivity").child(userId)
        var awardedBonuses = WeeklyLeagueActivityBonuses.zero

        activityRef.runTransactionBlock { mutableData in
            var activity = mutableData.value as? [String: Any] ?? [:]
            let previousActiveDay = Self.intValue(activity["lastActiveDayIndex"])
            var streakDays = Self.intValue(activity["streakDays"]) ?? 0
            var firstQuizPoints = 0
            var continuationPoints = 0

            if previousActiveDay != today {
                streakDays = previousActiveDay == today - 1 ? streakDays + 1 : 1
                firstQuizPoints = WeeklyLeaguePointRules.firstQuizOfDay
                continuationPoints = WeeklyLeaguePointRules.continuationBonus(streakDays: streakDays)
                activity["lastActiveDayIndex"] = today
                activity["streakDays"] = streakDays
            }

            let previousReviewDay = Self.intValue(activity["reviewDayIndex"])
            var reviewPointsToday = previousReviewDay == today
                ? Self.intValue(activity["reviewPointsToday"]) ?? 0
                : 0
            let requestedReviewPoints = context.isReview
                ? context.correctAnswers * WeeklyLeaguePointRules.reviewAnswer
                : 0
            let reviewPoints = min(
                requestedReviewPoints,
                max(WeeklyLeaguePointRules.maximumDailyReviewBonus - reviewPointsToday, 0)
            )
            if reviewPoints > 0 {
                reviewPointsToday += reviewPoints
                activity["reviewDayIndex"] = today
                activity["reviewPointsToday"] = reviewPointsToday
            }

            let previousChallengeDay = Self.intValue(activity["challengeDayIndex"])
            let challengePoints: Int
            if context.didClearChallenge, previousChallengeDay != today {
                challengePoints = WeeklyLeaguePointRules.challengeClear
                activity["challengeDayIndex"] = today
            } else {
                challengePoints = 0
            }

            activity["updatedAt"] = self.serverAdjustedNow.timeIntervalSince1970 * 1_000
            awardedBonuses = WeeklyLeagueActivityBonuses(
                firstQuiz: firstQuizPoints,
                continuation: continuationPoints,
                review: reviewPoints,
                challenge: challengePoints
            )
            mutableData.value = activity
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { error, committed, _ in
            if let error {
                completion(.failure(WeeklyLeagueServiceError.database(error)))
            } else if committed {
                completion(.success(awardedBonuses))
            } else {
                completion(.failure(WeeklyLeagueServiceError.bonusFailed))
            }
        }
    }

    private func dayIndex(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = calendarTimeZone
        let startOfDay = calendar.startOfDay(for: date)
        return Int(floor(startOfDay.timeIntervalSince1970 / (24 * 60 * 60)))
    }

    func claimReward(
        _ result: WeeklyLeagueResult,
        userId: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let userRef = root.child("users").child(userId)

        // トランザクションのブロックはローカルキャッシュ未取得だとデータ無しで呼ばれる。
        // 空データから組み立て直す実装にするため、ユーザーの実在を先に確かめておく。
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(WeeklyLeagueServiceError.invalidProfile))
                return
            }

            var alreadyClaimed = false

            userRef.runTransactionBlock { mutableData in
                var userData = mutableData.value as? [String: Any] ?? [:]
                var claims = userData["leagueRewardClaims"] as? [String: Any] ?? [:]

                if Self.boolValue(claims[result.seasonId]) == true {
                    alreadyClaimed = true
                    return TransactionResult.abort()
                }
                alreadyClaimed = false

                let currentMoney = Self.intValue(userData["userMoney"]) ?? 0
                userData["userMoney"] = currentMoney + result.rewardCoins
                claims[result.seasonId] = true
                userData["leagueRewardClaims"] = claims
                mutableData.value = userData
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                if let error {
                    completion(.failure(WeeklyLeagueServiceError.database(error)))
                    return
                }

                // 中断理由が「受け取り済み」以外なら加算されていない。
                // ここで rewardClaimed を立てると報酬が永久に失われるため、失敗として返す。
                guard committed || alreadyClaimed else {
                    completion(.failure(WeeklyLeagueServiceError.rewardNotGranted))
                    return
                }

                let grantedCoins = committed ? result.rewardCoins : 0

                self.root
                    .child("leagueResults")
                    .child(userId)
                    .child(result.seasonId)
                    .child("rewardClaimed")
                    .setValue(true) { error, _ in
                        if let error {
                            completion(.failure(WeeklyLeagueServiceError.database(error)))
                        } else {
                            completion(.success(grantedCoins))
                        }
                    }
            }
        } withCancel: { error in
            completion(.failure(WeeklyLeagueServiceError.database(error)))
        }
    }

    func promotionCount(memberCount: Int) -> Int {
        if memberCount >= 20 { return 5 }
        if memberCount >= 10 { return 3 }
        if memberCount >= 2 { return min(2, memberCount - 1) }
        return 0
    }

    func relegationCount(memberCount: Int) -> Int {
        if memberCount >= 20 { return 5 }
        if memberCount >= 10 { return 3 }
        return 0
    }

    // MARK: - Membership and scoring

    /// リーグ画面を初めて開いたユーザーも、その場で現在シーズンへ参加させる。
    /// `joinCurrentSeason` 側で既存プロフィールを再確認するため、複数回呼ばれても
    /// 同じシーズンの所属先が重複して作られることはない。
    func joinCurrentSeasonIfNeeded(
        userId: String,
        tier: WeeklyLeagueTier,
        season: WeeklyLeagueSeason,
        completion: @escaping (Result<WeeklyLeagueMembership, Error>) -> Void
    ) {
        joinCurrentSeason(
            userId: userId,
            tier: tier,
            season: season,
            completion: completion
        )
    }

    private func joinCurrentSeason(
        userId: String,
        tier: WeeklyLeagueTier,
        season: WeeklyLeagueSeason,
        completion: @escaping (Result<WeeklyLeagueMembership, Error>) -> Void
    ) {
        let queueRef = root
            .child("leagueQueues")
            .child(season.id)
            .child(tier.rawValue)
            .child("nextSlot")

        queueRef.runTransactionBlock { mutableData in
            let current = Self.intValue(mutableData.value) ?? 0
            mutableData.value = current + 1
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { [weak self] error, committed, snapshot in
            guard let self else { return }
            if let error {
                completion(.failure(WeeklyLeagueServiceError.database(error)))
                return
            }
            guard committed,
                  let nextSlot = Self.intValue(snapshot?.value) else {
                completion(.failure(WeeklyLeagueServiceError.membershipFailed))
                return
            }

            let slot = max(nextSlot - 1, 0)
            let groupIndex = slot / Self.groupSize
            let candidateGroupId = "\(tier.rawValue)-\(String(format: "%04d", groupIndex))"
            let profileRef = self.root.child("leagueProfiles").child(userId)

            profileRef.runTransactionBlock { mutableData in
                var profile = mutableData.value as? [String: Any] ?? [:]
                if profile["currentSeasonId"] as? String == season.id,
                   let existingGroupId = profile["currentGroupId"] as? String,
                   !existingGroupId.isEmpty {
                    return TransactionResult.abort()
                }

                profile["currentTier"] = tier.rawValue
                profile["currentSeasonId"] = season.id
                profile["currentGroupId"] = candidateGroupId
                profile["joinedAt"] = self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                mutableData.value = profile
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, _, snapshot in
                if let error {
                    completion(.failure(WeeklyLeagueServiceError.database(error)))
                    return
                }

                guard let profile = snapshot?.value as? [String: Any],
                      let groupId = profile["currentGroupId"] as? String,
                      profile["currentSeasonId"] as? String == season.id else {
                    completion(.failure(WeeklyLeagueServiceError.invalidProfile))
                    return
                }

                let actualTier = WeeklyLeagueTier(rawValue: profile["currentTier"] as? String ?? "") ?? tier
                let membership = WeeklyLeagueMembership(
                    seasonId: season.id,
                    groupId: groupId,
                    tier: actualTier
                )
                self.ensureMember(userId: userId, membership: membership) { result in
                    switch result {
                    case .success:
                        completion(.success(membership))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func ensureMember(
        userId: String,
        membership: WeeklyLeagueMembership,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        fetchPublicProfile(userId: userId) { profile in
            let groupRef = self.root
                .child("leagueGroups")
                .child(membership.seasonId)
                .child(membership.groupId)
            let memberRef = groupRef.child("members").child(userId)

            groupRef.updateChildValues([
                "tier": membership.tier.rawValue,
                "groupSize": Self.groupSize
            ])

            memberRef.runTransactionBlock { mutableData in
                var member = mutableData.value as? [String: Any] ?? [:]
                member["userName"] = profile.userName
                member["avatarName"] = profile.avatarName
                member["score"] = Self.intValue(member["score"]) ?? 0
                member["scoreReachedAt"] = Self.doubleValue(member["scoreReachedAt"])
                    ?? self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                member["joinedAt"] = Self.doubleValue(member["joinedAt"])
                    ?? self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                mutableData.value = member
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                if let error {
                    completion(.failure(WeeklyLeagueServiceError.database(error)))
                } else if committed {
                    completion(.success(()))
                } else {
                    completion(.failure(WeeklyLeagueServiceError.membershipFailed))
                }
            }
        }
    }

    private func add(
        breakdown: WeeklyLeaguePointBreakdown,
        userId: String,
        membership: WeeklyLeagueMembership,
        receiptRef: DatabaseReference,
        completion: ((Result<Int, Error>) -> Void)?
    ) {
        let points = breakdown.total
        applyMemberScoreDelta(points: points, userId: userId, membership: membership) { result in
            switch result {
            case .failure(let error):
                receiptRef.removeValue()
                completion?(.failure(error))
            case .success:
                receiptRef.updateChildValues([
                    "status": "completed",
                    "points": points,
                    "breakdown": breakdown.firebaseValue,
                    "completedAt": self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                ])
                completion?(.success(points))
            }
        }
    }

    /// 指定メンバーの現在グループのスコアに `points` を加算します。
    /// メンバーノードが未作成なら `ensureMember` で先に作成してから加算します。
    private func applyMemberScoreDelta(
        points: Int,
        userId: String,
        membership: WeeklyLeagueMembership,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        ensureMember(userId: userId, membership: membership) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                let memberRef = self.root
                    .child("leagueGroups")
                    .child(membership.seasonId)
                    .child(membership.groupId)
                    .child("members")
                    .child(userId)

                memberRef.runTransactionBlock { mutableData in
                    // ローカルキャッシュが無い初回はデータが届かないことがある。ここで abort すると
                    // サーバ値での再実行に進めず、加算が一度も成立しない。
                    // 直前の ensureMember でノードは作成済みなので、空なら初期値から積む。
                    var member = mutableData.value as? [String: Any] ?? [:]
                    let score = Self.intValue(member["score"]) ?? 0
                    member["score"] = score + points
                    member["scoreReachedAt"] = self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                    mutableData.value = member
                    return TransactionResult.success(withValue: mutableData)
                } andCompletionBlock: { error, committed, _ in
                    if let error {
                        completion(.failure(WeeklyLeagueServiceError.database(error)))
                    } else if committed {
                        completion(.success(()))
                    } else {
                        completion(.failure(WeeklyLeagueServiceError.membershipFailed))
                    }
                }
            }
        }
    }

    /// 対戦(Battle)勝利時などに、現在のリーグへ固定ポイントを加算します。
    /// `battleId` をレシートキーに使い、同じ対戦結果からの二重加算を防ぎます。
    func awardBattlePoints(
        userId: String,
        points: Int,
        battleId: String,
        completion: ((Result<Int, Error>) -> Void)? = nil
    ) {
        guard points != 0 else {
            completion?(.success(0))
            return
        }
        let currentSeason = season()
        let receiptRef = root
            .child("leaguePointReceipts")
            .child(currentSeason.id)
            .child(userId)
            .child("battle_\(battleId)")

        receiptRef.runTransactionBlock { mutableData in
            guard Self.isAbsent(mutableData.value) else { return TransactionResult.abort() }
            mutableData.value = [
                "status": "pending",
                "source": "battle",
                "createdAt": self.serverAdjustedNow.timeIntervalSince1970 * 1_000
            ]
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { [weak self] error, committed, _ in
            guard let self else { return }
            if let error {
                completion?(.failure(WeeklyLeagueServiceError.database(error)))
                return
            }
            guard committed else {
                completion?(.success(0))
                return
            }

            self.resolveCurrentLeague(userId: userId) { resolutionResult in
                switch resolutionResult {
                case .failure(let error):
                    receiptRef.removeValue()
                    completion?(.failure(error))
                case .success(let resolution):
                    let apply: (WeeklyLeagueMembership) -> Void = { membership in
                        self.applyMemberScoreDelta(points: points, userId: userId, membership: membership) { result in
                            switch result {
                            case .success:
                                receiptRef.updateChildValues([
                                    "status": "completed",
                                    "points": points,
                                    "completedAt": self.serverAdjustedNow.timeIntervalSince1970 * 1_000
                                ])
                                completion?(.success(points))
                            case .failure(let error):
                                receiptRef.removeValue()
                                completion?(.failure(error))
                            }
                        }
                    }
                    if let membership = resolution.membership {
                        apply(membership)
                    } else {
                        self.joinCurrentSeason(userId: userId, tier: resolution.tier, season: resolution.season) { joinResult in
                            switch joinResult {
                            case .success(let membership):
                                apply(membership)
                            case .failure(let error):
                                receiptRef.removeValue()
                                completion?(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Season finalization

    private func finalizePreviousSeason(
        userId: String,
        seasonId: String,
        groupId: String,
        tier: WeeklyLeagueTier,
        completion: @escaping (Result<WeeklyLeagueResult, Error>) -> Void
    ) {
        let resultRef = root.child("leagueResults").child(userId).child(seasonId)
        resultRef.observeSingleEvent(of: .value) { snapshot in
            if let existing = self.result(from: snapshot, seasonId: seasonId) {
                self.applyFinalizedTier(existing, userId: userId) {
                    completion(.success(existing))
                }
                return
            }

            self.root
                .child("leagueGroups")
                .child(seasonId)
                .child(groupId)
                .child("members")
                .observeSingleEvent(of: .value) { membersSnapshot in
                    let members = self.members(from: membersSnapshot)
                    guard let index = members.firstIndex(where: { $0.id == userId }) else {
                        let fallback = WeeklyLeagueResult(
                            seasonId: seasonId,
                            tier: tier,
                            rank: max(members.count, 1),
                            score: 0,
                            movement: .stayed,
                            nextTier: tier,
                            rewardCoins: 0,
                            rewardClaimed: true
                        )
                        self.persist(result: fallback, userId: userId, completion: completion)
                        return
                    }

                    let rank = index + 1
                    let promotionCount = self.promotionCount(memberCount: members.count)
                    let relegationCount = self.relegationCount(memberCount: members.count)
                    let relegationStartsAt = max(members.count - relegationCount + 1, 1)
                    let movement: WeeklyLeagueMovement
                    let nextTier: WeeklyLeagueTier

                    if promotionCount > 0, rank <= promotionCount, tier != .master {
                        movement = .promoted
                        nextTier = tier.promoted
                    } else if relegationCount > 0, rank >= relegationStartsAt, tier != .bronze {
                        movement = .relegated
                        nextTier = tier.relegated
                    } else {
                        movement = .stayed
                        nextTier = tier
                    }

                    let rewardCoins: Int
                    if tier == .master, rank <= 3 {
                        rewardCoins = 500
                    } else {
                        switch movement {
                        case .promoted: rewardCoins = 300
                        case .stayed: rewardCoins = members[index].score > 0 ? 100 : 0
                        case .relegated: rewardCoins = 50
                        }
                    }

                    let leagueResult = WeeklyLeagueResult(
                        seasonId: seasonId,
                        tier: tier,
                        rank: rank,
                        score: members[index].score,
                        movement: movement,
                        nextTier: nextTier,
                        rewardCoins: rewardCoins,
                        rewardClaimed: rewardCoins == 0
                    )
                    self.persist(result: leagueResult, userId: userId, completion: completion)
                } withCancel: { error in
                    completion(.failure(WeeklyLeagueServiceError.database(error)))
                }
        } withCancel: { error in
            completion(.failure(WeeklyLeagueServiceError.database(error)))
        }
    }

    private func persist(
        result: WeeklyLeagueResult,
        userId: String,
        completion: @escaping (Result<WeeklyLeagueResult, Error>) -> Void
    ) {
        let resultRef = root.child("leagueResults").child(userId).child(result.seasonId)
        resultRef.runTransactionBlock { mutableData in
            if !Self.isAbsent(mutableData.value) { return TransactionResult.abort() }
            mutableData.value = self.dictionary(from: result)
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { error, _, snapshot in
            if let error {
                completion(.failure(WeeklyLeagueServiceError.database(error)))
                return
            }
            let storedResult = snapshot.flatMap { self.result(from: $0, seasonId: result.seasonId) } ?? result
            self.applyFinalizedTier(storedResult, userId: userId) {
                completion(.success(storedResult))
            }
        }
    }

    private func applyFinalizedTier(
        _ result: WeeklyLeagueResult,
        userId: String,
        completion: @escaping () -> Void
    ) {
        root.child("leagueProfiles").child(userId).updateChildValues([
            "currentTier": result.nextTier.rawValue,
            "lastResultSeasonId": result.seasonId
        ]) { _, _ in
            completion()
        }
    }

    private func loadPendingResult(
        userId: String,
        profile: [String: Any],
        completion: @escaping (WeeklyLeagueResult?) -> Void
    ) {
        guard let seasonId = profile["lastResultSeasonId"] as? String, !seasonId.isEmpty else {
            completion(nil)
            return
        }
        root.child("leagueResults").child(userId).child(seasonId).observeSingleEvent(of: .value) { snapshot in
            guard let result = self.result(from: snapshot, seasonId: seasonId), !result.rewardClaimed else {
                completion(nil)
                return
            }
            completion(result)
        } withCancel: { _ in
            completion(nil)
        }
    }

    // MARK: - Parsing

    private func members(from snapshot: DataSnapshot) -> [WeeklyLeagueMember] {
        var members: [WeeklyLeagueMember] = []
        for case let child as DataSnapshot in snapshot.children {
            guard let value = child.value as? [String: Any] else { continue }
            members.append(WeeklyLeagueMember(
                id: child.key,
                userName: value["userName"] as? String ?? "冒険者",
                avatarName: value["avatarName"] as? String ?? "defaultIcon",
                score: Self.intValue(value["score"]) ?? 0,
                scoreReachedAt: Self.doubleValue(value["scoreReachedAt"]) ?? .greatestFiniteMagnitude,
                joinedAt: Self.doubleValue(value["joinedAt"]) ?? .greatestFiniteMagnitude
            ))
        }
        return members.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            if $0.scoreReachedAt != $1.scoreReachedAt { return $0.scoreReachedAt < $1.scoreReachedAt }
            return $0.id < $1.id
        }
    }

    private func fetchPublicProfile(
        userId: String,
        completion: @escaping ((userName: String, avatarName: String)) -> Void
    ) {
        root.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            let data = snapshot.value as? [String: Any] ?? [:]
            let rawName = data["userName"] as? String ?? ""
            let userName = rawName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "冒険者" : rawName
            var avatarName = "defaultIcon"
            if let avatars = data["avatars"] as? [String: [String: Any]] {
                for avatar in avatars.values where Self.intValue(avatar["usedFlag"]) == 1 {
                    avatarName = avatar["name"] as? String ?? avatarName
                    break
                }
            }
            completion((userName, avatarName))
        } withCancel: { _ in
            completion(("冒険者", "defaultIcon"))
        }
    }

    private func result(from snapshot: DataSnapshot, seasonId: String) -> WeeklyLeagueResult? {
        guard let value = snapshot.value as? [String: Any],
              let tier = WeeklyLeagueTier(rawValue: value["tier"] as? String ?? ""),
              let movement = WeeklyLeagueMovement(rawValue: value["movement"] as? String ?? ""),
              let nextTier = WeeklyLeagueTier(rawValue: value["nextTier"] as? String ?? "") else {
            return nil
        }
        return WeeklyLeagueResult(
            seasonId: seasonId,
            tier: tier,
            rank: Self.intValue(value["rank"]) ?? 0,
            score: Self.intValue(value["score"]) ?? 0,
            movement: movement,
            nextTier: nextTier,
            rewardCoins: Self.intValue(value["rewardCoins"]) ?? 0,
            rewardClaimed: Self.boolValue(value["rewardClaimed"]) ?? false
        )
    }

    private func dictionary(from result: WeeklyLeagueResult) -> [String: Any] {
        [
            "tier": result.tier.rawValue,
            "rank": result.rank,
            "score": result.score,
            "movement": result.movement.rawValue,
            "nextTier": result.nextTier.rawValue,
            "rewardCoins": result.rewardCoins,
            "rewardClaimed": result.rewardClaimed,
            "finalizedAt": serverAdjustedNow.timeIntervalSince1970 * 1_000
        ]
    }

    /// ノードが未作成かどうか。
    ///
    /// `MutableData.value` は Objective-C 由来のため、空ノードでは Swift の `nil` ではなく
    /// `NSNull()` を返す。`== nil` だけで判定すると «既に存在する» と誤認して
    /// トランザクションが必ず abort され、書き込みが一度も成立しない。
    private static func isAbsent(_ value: Any?) -> Bool {
        value == nil || value is NSNull
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int { return value }
        if let value = value as? NSNumber { return value.intValue }
        if let value = value as? Double { return Int(value) }
        return nil
    }

    private static func doubleValue(_ value: Any?) -> Double? {
        if let value = value as? Double { return value }
        if let value = value as? NSNumber { return value.doubleValue }
        if let value = value as? Int { return Double(value) }
        return nil
    }

    private static func boolValue(_ value: Any?) -> Bool? {
        if let value = value as? Bool { return value }
        if let value = value as? NSNumber { return value.boolValue }
        return nil
    }
}
