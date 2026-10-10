//
//  FriendManager.swift
//  it
//
//  フレンド機能(申請/承認/助っ人おとも)を管理します。
//

import Foundation
import FirebaseDatabase

struct FriendSummary: Identifiable, Equatable {
    let id: String // uid
    let name: String
    let level: Int
    let featuredAvatarName: String?
    let featuredAvatarAttack: Int
    var canBorrowToday: Bool
    let lastLoginDate: TimeInterval?
    var canGreetToday: Bool
    var canCheerToday: Bool

    init(
        id: String,
        name: String,
        level: Int,
        featuredAvatarName: String?,
        featuredAvatarAttack: Int,
        canBorrowToday: Bool,
        lastLoginDate: TimeInterval? = nil,
        canGreetToday: Bool = true,
        canCheerToday: Bool = true
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.featuredAvatarName = featuredAvatarName
        self.featuredAvatarAttack = featuredAvatarAttack
        self.canBorrowToday = canBorrowToday
        self.lastLoginDate = lastLoginDate
        self.canGreetToday = canGreetToday
        self.canCheerToday = canCheerToday
    }
}

struct FriendRequestSummary: Identifiable, Equatable {
    let id: String // fromUid
    let name: String
    let level: Int
}

struct ActiveHelper {
    let ownerUid: String
    let ownerName: String
    let avatarName: String
    let attackBonus: Int
}

struct HelperUsageHistoryEntry: Identifiable, Equatable {
    let id: String
    let borrowerUid: String
    let borrowerName: String
    let avatarName: String
    let usedAt: TimeInterval
}

enum FriendCheerType: String, CaseIterable, Identifiable {
    case stamina
    case experience

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stamina: return "スタミナ+10"
        case .experience: return "経験値+10"
        }
    }

    var icon: String {
        switch self {
        case .stamina: return "bolt.fill"
        case .experience: return "star.fill"
        }
    }
}

enum FriendLimitPolicy {
    static let standard = 10
    static let premium = 30

    static func normalized(_ value: Int) -> Int {
        value >= premium ? premium : standard
    }
}

enum FriendReferralPolicy {
    static let rewardCoins = 5_000
    static let appStoreURL = "https://apps.apple.com/jp/app/id6469339499"
}

enum FriendError: LocalizedError, Equatable {
    case notLoggedIn
    case invalidCode
    case codeNotFound
    case cannotAddSelf
    case alreadyFriends
    case alreadyRequested
    case friendLimitReached(Int)
    case helperNotAvailable
    case alreadyBorrowedToday
    case helperAlreadySelected
    case alreadyGreetedToday
    case alreadyCheeredToday
    case noLongerFriends
    case cheerTargetFull
    case cheerTargetUnavailable
    case networkError

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "ログイン情報を確認できませんでした。"
        case .invalidCode: return "フレンドコードは6桁の数字で入力してください。"
        case .codeNotFound: return "そのフレンドコードのユーザーが見つかりませんでした。"
        case .cannotAddSelf: return "自分自身をフレンドに追加することはできません。"
        case .alreadyFriends: return "すでにフレンドです。"
        case .alreadyRequested: return "すでに申請中です。"
        case .friendLimitReached(let limit): return "フレンドは\(limit)人まで登録できます。"
        case .helperNotAvailable: return "このフレンドはおともを選択していません。"
        case .alreadyBorrowedToday: return "このフレンドの助っ人は今日はもう借りています。明日また挑戦してください。"
        case .helperAlreadySelected: return "すでに助っ人を編成しています。次のダンジョンまたはギルドボス戦で一緒に戦えます。"
        case .alreadyGreetedToday: return "このフレンドには今日すでにあいさつしています。"
        case .alreadyCheeredToday: return "このフレンドには今日すでに応援を送っています。"
        case .noLongerFriends: return "フレンド状態を確認できませんでした。一覧を更新してください。"
        case .cheerTargetFull: return "相手のスタミナは満タンです。経験値の応援を選んでください。"
        case .cheerTargetUnavailable: return "相手に応援を届けられませんでした。別の応援をお試しください。"
        case .networkError: return "通信エラーが発生しました。時間をおいて再度お試しください。"
        }
    }
}

final class FriendManager: ObservableObject {
    static let shared = FriendManager()
    private init() {}

    @Published var friendCode: String = ""
    @Published var friends: [FriendSummary] = []
    @Published var incomingRequests: [FriendRequestSummary] = []
    @Published var outgoingRequests: [FriendRequestSummary] = []
    @Published var pendingThanksCoins: Int = 0
    @Published var pendingThanksCount: Int = 0
    @Published var activeHelper: ActiveHelper?
    @Published var isLoadingFriends: Bool = false
    @Published var friendPoints: Int = 0
    @Published var helperHistory: [HelperUsageHistoryEntry] = []
    @Published var isLoadingHelperHistory: Bool = false

    private let helperThanksReward = 20
    private let greetingPointsReward = 5
    private let cheerAmount = 10
    private let maximumStamina = 100
    private var requestsHandle: DatabaseHandle?
    private var requestsRef: DatabaseReference?
    private var sentRequestsHandle: DatabaseHandle?
    private var sentRequestsRef: DatabaseReference?

    private var db: DatabaseReference { Database.database().reference() }
    private var currentUserId: String? { AuthManager.shared.currentUserId }

    // MARK: - フレンドコード

    func ensureFriendCode(completion: ((String) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?("")
            return
        }
        db.child("users").child(userId).child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            if let code = snapshot.value as? String, !code.isEmpty {
                DispatchQueue.main.async { self.friendCode = code }
                completion?(code)
            } else {
                self.generateUniqueCode(userId: userId, completion: completion)
            }
        }
    }

    private func generateUniqueCode(userId: String, attempt: Int = 0, completion: ((String) -> Void)? = nil) {
        guard attempt < 8 else {
            completion?("")
            return
        }
        let code = String(format: "%06d", Int.random(in: 0...999_999))
        db.child("friendCodes").child(code).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            if snapshot.exists() {
                self.generateUniqueCode(userId: userId, attempt: attempt + 1, completion: completion)
                return
            }
            let updates: [String: Any] = [
                "friendCodes/\(code)": userId,
                "users/\(userId)/friendCode": code
            ]
            self.db.updateChildValues(updates) { error, _ in
                if error == nil {
                    DispatchQueue.main.async { self.friendCode = code }
                    completion?(code)
                } else {
                    completion?("")
                }
            }
        }
    }

    func syncCurrentUserFriendLimit(_ limit: Int) {
        guard let userId = currentUserId else { return }
        db.child("users")
            .child(userId)
            .child("friendLimit")
            .setValue(FriendLimitPolicy.normalized(limit))
    }

    // MARK: - 申請

    func sendFriendRequest(
        code rawCode: String,
        maxFriendCount requestedLimit: Int,
        completion: @escaping (Result<String, FriendError>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        let maxFriendCount = FriendLimitPolicy.normalized(requestedLimit)
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count == 6, code.allSatisfy({ $0.isNumber }) else {
            completion(.failure(.invalidCode))
            return
        }

        fetchFriendCount(uid: userId) { [weak self] myFriendCount in
            guard let self else { return }
            guard myFriendCount < maxFriendCount else {
                completion(.failure(.friendLimitReached(maxFriendCount)))
                return
            }
            self.db.child("friendCodes").child(code).observeSingleEvent(of: .value) { snapshot in
                guard let targetUid = snapshot.value as? String, !targetUid.isEmpty else {
                    completion(.failure(.codeNotFound))
                    return
                }
                if targetUid == userId {
                    completion(.failure(.cannotAddSelf))
                    return
                }

                self.fetchFriendLimit(uid: targetUid) { targetLimit in
                    self.fetchFriendCount(uid: targetUid) { targetFriendCount in
                        guard targetFriendCount < targetLimit else {
                            completion(.failure(.friendLimitReached(targetLimit)))
                            return
                        }
                        self.db.child("friends").child(userId).child(targetUid).observeSingleEvent(of: .value) { existingFriend in
                            if existingFriend.exists() {
                                completion(.failure(.alreadyFriends))
                                return
                            }

                            self.db.child("friendRequests").child(targetUid).child(userId).observeSingleEvent(of: .value) { existingRequest in
                                if existingRequest.exists() {
                                    completion(.failure(.alreadyRequested))
                                    return
                                }

                                // 相手からすでに申請が届いていた場合は、そのまま相互フレンドにする。
                                self.db.child("friendRequests").child(userId).child(targetUid).observeSingleEvent(of: .value) { reverseRequest in
                                    if reverseRequest.exists() {
                                        self.registerReferralCandidateIfEligible(
                                            inviteeUid: userId,
                                            inviterUid: targetUid,
                                            currentFriendCount: myFriendCount
                                        ) { registeredReferral in
                                            self.acceptRequest(fromUid: targetUid, maxFriendCount: maxFriendCount) { result in
                                                if case .failure = result, registeredReferral {
                                                    self.clearPendingReferral(inviteeUid: userId, inviterUid: targetUid)
                                                }
                                                completion(result.map { targetUid })
                                            }
                                        }
                                        return
                                    }

                                    self.fetchUserBasicInfo(uid: userId) { myName, myLevel in
                                        self.fetchUserBasicInfo(uid: targetUid) { targetName, targetLevel in
                                            self.registerReferralCandidateIfEligible(
                                                inviteeUid: userId,
                                                inviterUid: targetUid,
                                                currentFriendCount: myFriendCount
                                            ) { registeredReferral in
                                                let sentAt = ServerValue.timestamp()
                                                let updates: [String: Any] = [
                                                    "friendRequests/\(targetUid)/\(userId)": [
                                                        "name": myName ?? "名無し",
                                                        "level": myLevel ?? 1,
                                                        "sentAt": sentAt
                                                    ],
                                                    "sentFriendRequests/\(userId)/\(targetUid)": [
                                                        "name": targetName ?? "名無し",
                                                        "level": targetLevel ?? 1,
                                                        "sentAt": sentAt
                                                    ]
                                                ]
                                                self.db.updateChildValues(updates) { error, _ in
                                                    if error != nil, registeredReferral {
                                                        self.clearPendingReferral(inviteeUid: userId, inviterUid: targetUid)
                                                    }
                                                    completion(error == nil ? .success(targetUid) : .failure(.networkError))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func registerReferralCandidateIfEligible(
        inviteeUid: String,
        inviterUid: String,
        currentFriendCount: Int,
        completion: @escaping (Bool) -> Void
    ) {
        guard currentFriendCount == 0 else {
            completion(false)
            return
        }

        let referralRef = db.child("referralInvites").child(inviteeUid)
        referralRef.runTransactionBlock { mutableData in
            if let existing = mutableData.value as? [String: Any] {
                let existingInviter = existing["inviterUid"] as? String
                let status = existing["status"] as? String ?? "pending"
                guard existingInviter == inviterUid, status == "pending" else {
                    return TransactionResult.abort()
                }
                return TransactionResult.success(withValue: mutableData)
            }

            mutableData.value = [
                "inviterUid": inviterUid,
                "status": "pending",
                "rewardCoins": FriendReferralPolicy.rewardCoins,
                "createdAt": Int(Date().timeIntervalSince1970 * 1_000)
            ]
            return TransactionResult.success(withValue: mutableData)
        } andCompletionBlock: { error, committed, snapshot in
            let value = snapshot?.value as? [String: Any]
            let matchesInviter = value?["inviterUid"] as? String == inviterUid
            let isPending = value?["status"] as? String == "pending"
            completion(error == nil && committed && matchesInviter && isPending)
        }
    }

    private func clearPendingReferral(inviteeUid: String, inviterUid: String) {
        let referralRef = db.child("referralInvites").child(inviteeUid)
        referralRef.runTransactionBlock { mutableData in
            guard let value = mutableData.value as? [String: Any],
                  value["inviterUid"] as? String == inviterUid,
                  (value["status"] as? String ?? "pending") == "pending" else {
                return TransactionResult.abort()
            }
            mutableData.value = nil
            return TransactionResult.success(withValue: mutableData)
        }
    }

    func observeIncomingRequests() {
        guard let userId = currentUserId else { return }
        if let requestsRef, let requestsHandle {
            requestsRef.removeObserver(withHandle: requestsHandle)
        }
        let ref = db.child("friendRequests").child(userId)
        requestsRef = ref
        requestsHandle = ref.observe(.value) { [weak self] snapshot in
            let requests: [FriendRequestSummary] = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .compactMap { child -> FriendRequestSummary? in
                    guard let value = child.value as? [String: Any],
                          let name = value["name"] as? String else { return nil }
                    let level = (value["level"] as? Int) ?? 1
                    return FriendRequestSummary(id: child.key, name: name, level: level)
                }
                .sorted { $0.name < $1.name }
            DispatchQueue.main.async {
                self?.incomingRequests = requests
            }
        }
    }

    func observeOutgoingRequests() {
        guard let userId = currentUserId else { return }
        if let sentRequestsRef, let sentRequestsHandle {
            sentRequestsRef.removeObserver(withHandle: sentRequestsHandle)
        }
        let ref = db.child("sentFriendRequests").child(userId)
        sentRequestsRef = ref
        sentRequestsHandle = ref.observe(.value) { [weak self] snapshot in
            let requests: [FriendRequestSummary] = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .compactMap { child -> FriendRequestSummary? in
                    guard let value = child.value as? [String: Any] else { return nil }
                    return FriendRequestSummary(
                        id: child.key,
                        name: value["name"] as? String ?? "名無し",
                        level: value["level"] as? Int ?? 1
                    )
                }
                .sorted { $0.name < $1.name }
            DispatchQueue.main.async {
                self?.outgoingRequests = requests
            }
        }
    }

    func stopObservingRequests() {
        if let requestsRef, let requestsHandle {
            requestsRef.removeObserver(withHandle: requestsHandle)
        }
        requestsRef = nil
        requestsHandle = nil
        if let sentRequestsRef, let sentRequestsHandle {
            sentRequestsRef.removeObserver(withHandle: sentRequestsHandle)
        }
        sentRequestsRef = nil
        sentRequestsHandle = nil
    }

    func acceptRequest(
        fromUid: String,
        maxFriendCount requestedLimit: Int,
        completion: ((Result<Void, FriendError>) -> Void)? = nil
    ) {
        guard let userId = currentUserId else {
            completion?(.failure(.notLoggedIn))
            return
        }
        let maxFriendCount = FriendLimitPolicy.normalized(requestedLimit)
        fetchFriendCount(uid: userId) { [weak self] myFriendCount in
            guard let self else { return }
            guard myFriendCount < maxFriendCount else {
                completion?(.failure(.friendLimitReached(maxFriendCount)))
                return
            }
            self.fetchFriendLimit(uid: fromUid) { senderLimit in
                self.fetchFriendCount(uid: fromUid) { senderFriendCount in
                    guard senderFriendCount < senderLimit else {
                        completion?(.failure(.friendLimitReached(senderLimit)))
                        return
                    }
                    let now = ServerValue.timestamp()
                    let updates: [String: Any] = [
                        "friends/\(userId)/\(fromUid)/since": now,
                        "friends/\(fromUid)/\(userId)/since": now,
                        "friendRequests/\(userId)/\(fromUid)": NSNull(),
                        "sentFriendRequests/\(fromUid)/\(userId)": NSNull()
                    ]
                    self.db.updateChildValues(updates) { error, _ in
                        if error == nil {
                            self.fetchFriends()
                        }
                        completion?(error == nil ? .success(()) : .failure(.networkError))
                    }
                }
            }
        }
    }

    func rejectRequest(fromUid: String, completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(false)
            return
        }
        let updates: [String: Any] = [
            "friendRequests/\(userId)/\(fromUid)": NSNull(),
            "sentFriendRequests/\(fromUid)/\(userId)": NSNull()
        ]
        db.updateChildValues(updates) { error, _ in
            if error == nil {
                self.clearPendingReferral(inviteeUid: fromUid, inviterUid: userId)
            }
            completion?(error == nil)
        }
    }

    func cancelOutgoingRequest(toUid: String, completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(false)
            return
        }
        let updates: [String: Any] = [
            "friendRequests/\(toUid)/\(userId)": NSNull(),
            "sentFriendRequests/\(userId)/\(toUid)": NSNull()
        ]
        db.updateChildValues(updates) { error, _ in
            if error == nil {
                self.clearPendingReferral(inviteeUid: userId, inviterUid: toUid)
            }
            completion?(error == nil)
        }
    }

    // MARK: - フレンド一覧

    func fetchFriends(completion: (() -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?()
            return
        }
        DispatchQueue.main.async { self.isLoadingFriends = true }
        db.child("friends").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let friendUids = snapshot.children
                .compactMap { $0 as? DataSnapshot }
                .map { $0.key }

            guard !friendUids.isEmpty else {
                DispatchQueue.main.async {
                    self.friends = []
                    self.isLoadingFriends = false
                }
                completion?()
                return
            }

            self.dayKey { todayKey in
                self.fetchDailyActionStates(userId: userId, dayKey: todayKey) { borrowed, greeted, cheered in
                    let group = DispatchGroup()
                    var results: [FriendSummary] = []
                    let lock = NSLock()

                    for friendUid in friendUids {
                        group.enter()
                        self.db.child("users").child(friendUid).observeSingleEvent(of: .value) { userSnapshot in
                            defer { group.leave() }
                            guard let value = userSnapshot.value as? [String: Any] else { return }
                            let rawName = value["userName"] as? String ?? ""
                            let name = rawName.isEmpty ? "名無し" : rawName
                            let selectedAvatar = self.selectedAvatarProfile(from: value)
                            let summary = FriendSummary(
                                id: friendUid,
                                name: name,
                                level: self.intValue(from: value["level"], default: 1),
                                featuredAvatarName: selectedAvatar?.name,
                                featuredAvatarAttack: selectedAvatar?.attack ?? 0,
                                canBorrowToday: !borrowed.contains(friendUid),
                                lastLoginDate: self.timeIntervalValue(from: value["lastLoginDate"]),
                                canGreetToday: !greeted.contains(friendUid),
                                canCheerToday: !cheered.contains(friendUid)
                            )
                            lock.lock()
                            results.append(summary)
                            lock.unlock()
                        }
                    }

                    group.notify(queue: .main) {
                        self.friends = results.sorted { $0.level > $1.level }
                        self.isLoadingFriends = false
                        completion?()
                    }
                }
            }
        }
    }

    func removeFriend(uid: String, completion: ((Bool) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(false)
            return
        }
        let updates: [String: Any] = [
            "friends/\(userId)/\(uid)": NSNull(),
            "friends/\(uid)/\(userId)": NSNull()
        ]
        db.updateChildValues(updates) { [weak self] error, _ in
            if error == nil {
                self?.friends.removeAll { $0.id == uid }
            }
            completion?(error == nil)
        }
    }

    // MARK: - あいさつ・フレンドポイント

    func fetchFriendPoints() {
        guard let userId = currentUserId else { return }
        db.child("users").child(userId).child("friendPoints").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            DispatchQueue.main.async {
                self.friendPoints = self.intValue(from: snapshot.value)
            }
        }
    }

    func greet(_ friend: FriendSummary, completion: @escaping (Result<Int, FriendError>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        guard friend.canGreetToday else {
            completion(.failure(.alreadyGreetedToday))
            return
        }

        verifyFriendship(with: friend.id, userId: userId) { [weak self] isFriend in
            guard let self else { return }
            guard isFriend else {
                DispatchQueue.main.async { completion(.failure(.noLongerFriends)) }
                return
            }
            self.dayKey { todayKey in
                let reservationRef = self.db.child("friendGreetings").child(userId).child(todayKey).child(friend.id)
                reservationRef.runTransactionBlock { mutableData in
                    guard mutableData.value == nil else { return TransactionResult.abort() }
                    mutableData.value = ["sentAt": ServerValue.timestamp()]
                    return TransactionResult.success(withValue: mutableData)
                } andCompletionBlock: { error, committed, _ in
                    guard error == nil else {
                        DispatchQueue.main.async { completion(.failure(.networkError)) }
                        return
                    }
                    guard committed else {
                        DispatchQueue.main.async { completion(.failure(.alreadyGreetedToday)) }
                        return
                    }

                    let increment = ServerValue.increment(NSNumber(value: self.greetingPointsReward))
                    let updates: [String: Any] = [
                        "users/\(userId)/friendPoints": increment,
                        "users/\(friend.id)/friendPoints": increment
                    ]
                    self.db.updateChildValues(updates) { updateError, _ in
                        guard updateError == nil else {
                            reservationRef.removeValue()
                            DispatchQueue.main.async { completion(.failure(.networkError)) }
                            return
                        }
                        DispatchQueue.main.async {
                            self.friendPoints += self.greetingPointsReward
                            if let index = self.friends.firstIndex(where: { $0.id == friend.id }) {
                                self.friends[index].canGreetToday = false
                            }
                            completion(.success(self.greetingPointsReward))
                        }
                    }
                }
            }
        }
    }

    // MARK: - 応援

    func cheer(
        _ friend: FriendSummary,
        type: FriendCheerType,
        completion: @escaping (Result<FriendCheerType, FriendError>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        guard friend.canCheerToday else {
            completion(.failure(.alreadyCheeredToday))
            return
        }

        verifyFriendship(with: friend.id, userId: userId) { [weak self] isFriend in
            guard let self else { return }
            guard isFriend else {
                DispatchQueue.main.async { completion(.failure(.noLongerFriends)) }
                return
            }
            self.dayKey { todayKey in
                let reservationRef = self.db.child("friendCheers").child(userId).child(todayKey).child(friend.id)
                reservationRef.runTransactionBlock { mutableData in
                    guard mutableData.value == nil else { return TransactionResult.abort() }
                    mutableData.value = [
                        "type": type.rawValue,
                        "amount": self.cheerAmount,
                        "sentAt": ServerValue.timestamp()
                    ]
                    return TransactionResult.success(withValue: mutableData)
                } andCompletionBlock: { error, committed, _ in
                    guard error == nil else {
                        DispatchQueue.main.async { completion(.failure(.networkError)) }
                        return
                    }
                    guard committed else {
                        DispatchQueue.main.async { completion(.failure(.alreadyCheeredToday)) }
                        return
                    }

                    self.grantCheer(type, to: friend.id) { result in
                        switch result {
                        case .success:
                            self.recordCheer(from: userId, to: friend.id, type: type)
                            DispatchQueue.main.async {
                                if let index = self.friends.firstIndex(where: { $0.id == friend.id }) {
                                    self.friends[index].canCheerToday = false
                                }
                                completion(.success(type))
                            }
                        case .failure(let error):
                            reservationRef.removeValue()
                            DispatchQueue.main.async { completion(.failure(error)) }
                        }
                    }
                }
            }
        }
    }

    private func grantCheer(
        _ type: FriendCheerType,
        to friendUid: String,
        completion: @escaping (Result<Void, FriendError>) -> Void
    ) {
        switch type {
        case .stamina:
            let staminaRef = db.child("storys").child(friendUid).child("stamina")
            staminaRef.runTransactionBlock { mutableData in
                let current = mutableData.value == nil
                    ? self.maximumStamina
                    : self.intValue(from: mutableData.value)
                guard current < self.maximumStamina else { return TransactionResult.abort() }
                mutableData.value = min(current + self.cheerAmount, self.maximumStamina)
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                if error != nil {
                    completion(.failure(.networkError))
                } else if !committed {
                    completion(.failure(.cheerTargetFull))
                } else {
                    completion(.success(()))
                }
            }

        case .experience:
            let userRef = db.child("users").child(friendUid)
            userRef.runTransactionBlock { mutableData in
                guard var value = mutableData.value as? [String: Any] else {
                    return TransactionResult.abort()
                }
                var experience = self.intValue(from: value["experience"])
                var level = self.intValue(from: value["level"], default: 1)
                let previousLevel = level
                experience += self.cheerAmount
                while experience >= level * 100 {
                    experience -= level * 100
                    level += 1
                }
                value["experience"] = experience
                value["level"] = level
                if level != previousLevel {
                    value["userAttack"] = 20 + (level - 1) * 2
                    value["userHp"] = 100 + (level - 1) * 10
                }
                mutableData.value = value
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                if error != nil {
                    completion(.failure(.networkError))
                } else if !committed {
                    completion(.failure(.cheerTargetUnavailable))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    private func recordCheer(from senderUid: String, to receiverUid: String, type: FriendCheerType) {
        fetchUserBasicInfo(uid: senderUid) { [weak self] senderName, _ in
            guard let self else { return }
            let historyRef = self.db.child("friendCheerHistory").child(receiverUid).childByAutoId()
            historyRef.setValue([
                "senderUid": senderUid,
                "senderName": senderName ?? "名無し",
                "type": type.rawValue,
                "amount": self.cheerAmount,
                "sentAt": ServerValue.timestamp()
            ])
        }
    }

    // MARK: - 選択中のおとも

    func fetchSelectedAvatarName(completion: @escaping (String?) -> Void) {
        guard let userId = currentUserId else {
            completion(nil)
            return
        }
        db.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self, let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            completion(self.selectedAvatarProfile(from: value)?.name)
        }
    }

    private func selectedAvatarProfile(from userValue: [String: Any]) -> (name: String, attack: Int)? {
        let avatars = userValue["avatars"] as? [String: Any] ?? [:]
        let avatarValues = avatars.values.compactMap { $0 as? [String: Any] }

        if let usedName = userValue["usedAvatarName"] as? String, !usedName.isEmpty {
            if let selected = avatarValues.first(where: { $0["name"] as? String == usedName }) {
                return (usedName, intValue(from: selected["attack"]))
            }
            // 旧データでアバター一覧がまだ同期されていない場合だけ、同名の公開データを補助的に使う。
            if let featured = userValue["featuredAvatar"] as? [String: Any],
               featured["name"] as? String == usedName {
                return (usedName, intValue(from: featured["attack"]))
            }
            return (usedName, 0)
        }

        if let selected = avatarValues.first(where: { intValue(from: $0["usedFlag"]) == 1 }),
           let name = selected["name"] as? String, !name.isEmpty {
            return (name, intValue(from: selected["attack"]))
        }
        return nil
    }

    // MARK: - 助っ人

    func borrowHelper(from friend: FriendSummary, completion: @escaping (Result<Void, FriendError>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(.notLoggedIn))
            return
        }
        guard activeHelper == nil else {
            completion(.failure(.helperAlreadySelected))
            return
        }
        guard let avatarName = friend.featuredAvatarName else {
            completion(.failure(.helperNotAvailable))
            return
        }
        guard friend.canBorrowToday else {
            completion(.failure(.alreadyBorrowedToday))
            return
        }

        dayKey { todayKey in
            let usageRef = self.db.child("helperUsage").child(userId).child(todayKey).child(friend.id)
            usageRef.runTransactionBlock { mutableData in
                guard mutableData.value == nil else { return TransactionResult.abort() }
                mutableData.value = ["usedAt": ServerValue.timestamp()]
                return TransactionResult.success(withValue: mutableData)
            } andCompletionBlock: { error, committed, _ in
                    guard error == nil else {
                        DispatchQueue.main.async { completion(.failure(.networkError)) }
                        return
                    }
                    guard committed else {
                        DispatchQueue.main.async { completion(.failure(.alreadyBorrowedToday)) }
                        return
                    }
                    self.grantThanksCoins(to: friend.id)
                    self.recordHelperUsage(
                        ownerUid: friend.id,
                        borrowerUid: userId,
                        avatarName: avatarName
                    )
                    let bonus = max(1, friend.featuredAvatarAttack)
                    DispatchQueue.main.async {
                        self.activeHelper = ActiveHelper(
                            ownerUid: friend.id,
                            ownerName: friend.name,
                            avatarName: avatarName,
                            attackBonus: bonus
                        )
                        if let index = self.friends.firstIndex(where: { $0.id == friend.id }) {
                            self.friends[index].canBorrowToday = false
                        }
                        completion(.success(()))
                    }
            }
        }
    }

    /// ダンジョンまたはギルドボス戦から呼び出し、有効な助っ人を1回分だけ消費して返します。
    @discardableResult
    func consumeActiveHelperIfNeeded() -> ActiveHelper? {
        guard let helper = activeHelper else { return nil }
        activeHelper = nil
        return helper
    }

    private func grantThanksCoins(to ownerUid: String) {
        let ref = db.child("helperThanks").child(ownerUid)
        ref.runTransactionBlock { mutableData in
            var value = mutableData.value as? [String: Any] ?? [:]
            let currentCoins = (value["pendingCoins"] as? Int) ?? 0
            let currentCount = (value["pendingCount"] as? Int) ?? 0
            value["pendingCoins"] = currentCoins + self.helperThanksReward
            value["pendingCount"] = currentCount + 1
            mutableData.value = value
            return TransactionResult.success(withValue: mutableData)
        }
    }

    private func recordHelperUsage(ownerUid: String, borrowerUid: String, avatarName: String) {
        fetchUserBasicInfo(uid: borrowerUid) { [weak self] borrowerName, _ in
            guard let self else { return }
            let historyRef = self.db.child("helperHistory").child(ownerUid).childByAutoId()
            historyRef.setValue([
                "borrowerUid": borrowerUid,
                "borrowerName": borrowerName ?? "名無し",
                "avatarName": avatarName,
                "usedAt": ServerValue.timestamp()
            ])
        }
    }

    func fetchHelperHistory() {
        guard let userId = currentUserId else { return }
        DispatchQueue.main.async { self.isLoadingHelperHistory = true }
        db.child("helperHistory")
            .child(userId)
            .queryOrdered(byChild: "usedAt")
            .queryLimited(toLast: 20)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self else { return }
                let entries: [HelperUsageHistoryEntry] = snapshot.children
                    .compactMap { $0 as? DataSnapshot }
                    .compactMap { child in
                        guard let value = child.value as? [String: Any] else { return nil }
                        return HelperUsageHistoryEntry(
                            id: child.key,
                            borrowerUid: value["borrowerUid"] as? String ?? "",
                            borrowerName: value["borrowerName"] as? String ?? "名無し",
                            avatarName: value["avatarName"] as? String ?? "おとも",
                            usedAt: self.serverTimestampValue(from: value["usedAt"])
                        )
                    }
                    .sorted { $0.usedAt > $1.usedAt }
                DispatchQueue.main.async {
                    self.helperHistory = entries
                    self.isLoadingHelperHistory = false
                }
            } withCancel: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.helperHistory = []
                    self?.isLoadingHelperHistory = false
                }
            }
    }

    // MARK: - お礼コイン受け取り

    func fetchPendingThanks() {
        guard let userId = currentUserId else { return }
        db.child("helperThanks").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            let value = snapshot.value as? [String: Any]
            DispatchQueue.main.async {
                self?.pendingThanksCoins = (value?["pendingCoins"] as? Int) ?? 0
                self?.pendingThanksCount = (value?["pendingCount"] as? Int) ?? 0
            }
        }
    }

    func claimThanksCoins(completion: ((Int) -> Void)? = nil) {
        guard let userId = currentUserId else {
            completion?(0)
            return
        }
        let coins = pendingThanksCoins
        guard coins > 0 else {
            completion?(0)
            return
        }
        db.child("helperThanks").child(userId).setValue([
            "pendingCoins": 0,
            "pendingCount": 0
        ]) { [weak self] error, _ in
            guard error == nil else {
                completion?(0)
                return
            }
            AuthManager.shared.addMoney(amount: coins)
            DispatchQueue.main.async {
                self?.pendingThanksCoins = 0
                self?.pendingThanksCount = 0
            }
            completion?(coins)
        }
    }

    // MARK: - Helpers

    private func fetchDailyActionStates(
        userId: String,
        dayKey: String,
        completion: @escaping (_ borrowed: Set<String>, _ greeted: Set<String>, _ cheered: Set<String>) -> Void
    ) {
        let group = DispatchGroup()
        let lock = NSLock()
        var borrowed = Set<String>()
        var greeted = Set<String>()
        var cheered = Set<String>()

        let requests: [(DatabaseReference, (Set<String>) -> Void)] = [
            (db.child("helperUsage").child(userId).child(dayKey), { borrowed = $0 }),
            (db.child("friendGreetings").child(userId).child(dayKey), { greeted = $0 }),
            (db.child("friendCheers").child(userId).child(dayKey), { cheered = $0 })
        ]

        for (ref, assign) in requests {
            group.enter()
            ref.observeSingleEvent(of: .value) { snapshot in
                let keys = Set(snapshot.children.compactMap { ($0 as? DataSnapshot)?.key })
                lock.lock()
                assign(keys)
                lock.unlock()
                group.leave()
            } withCancel: { _ in
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(borrowed, greeted, cheered)
        }
    }

    private func verifyFriendship(with friendUid: String, userId: String, completion: @escaping (Bool) -> Void) {
        db.child("friends").child(userId).child(friendUid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        } withCancel: { _ in
            completion(false)
        }
    }

    private func intValue(from value: Any?, default defaultValue: Int = 0) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let int = value as? Int { return int }
        if let string = value as? String, let int = Int(string) { return int }
        return defaultValue
    }

    private func timeIntervalValue(from value: Any?) -> TimeInterval? {
        if let number = value as? NSNumber { return number.doubleValue }
        if let interval = value as? TimeInterval { return interval }
        if let string = value as? String, let interval = TimeInterval(string) { return interval }
        return nil
    }

    private func serverTimestampValue(from value: Any?) -> TimeInterval {
        guard let rawValue = timeIntervalValue(from: value) else { return 0 }
        return rawValue > 10_000_000_000 ? rawValue / 1_000 : rawValue
    }

    private func fetchUserBasicInfo(uid: String, completion: @escaping (String?, Int?) -> Void) {
        db.child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }
            let name = value["userName"] as? String
            completion(name?.isEmpty == false ? name : nil, self.intValue(from: value["level"], default: 1))
        }
    }

    private func fetchFriendCount(uid: String, completion: @escaping (Int) -> Void) {
        db.child("friends").child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(Int(snapshot.childrenCount))
        }
    }

    private func fetchFriendLimit(uid: String, completion: @escaping (Int) -> Void) {
        db.child("users").child(uid).child("friendLimit").observeSingleEvent(of: .value) { snapshot in
            let storedLimit = self.intValue(
                from: snapshot.value,
                default: FriendLimitPolicy.standard
            )
            completion(FriendLimitPolicy.normalized(storedLimit))
        }
    }

    private func dayKey(completion: @escaping (String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = Calendar.current.timeZone
        completion(formatter.string(from: Date()))
    }
}
