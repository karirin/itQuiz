//
//  DemoDataSeeder.swift
//  it
//
//  フレンド/対戦/ギルド画面をすぐ確認できるように、デモ用データをFirebaseへ投入します。DEBUGビルド専用です。
//

#if DEBUG
import Foundation
import FirebaseDatabase

enum DemoDataSeeder {
    private static var db: DatabaseReference { Database.database().reference() }

    static func seedAll(completion: @escaping (Bool) -> Void) {
        guard let userId = AuthManager.shared.currentUserId else {
            completion(false)
            return
        }

        fetchMyName(userId: userId) { myName in
            let fake1 = "demoFriend1_\(userId.prefix(6))"
            let fake2 = "demoFriend2_\(userId.prefix(6))"
            let fake3 = "demoFriend3_\(userId.prefix(6))"

            seedFakeUsers(fake1: fake1, fake2: fake2, fake3: fake3)
            seedFriends(myUid: userId, myName: myName, fake1: fake1, fake2: fake2, fake3: fake3)
            seedBattles(myUid: userId, myName: myName, fake1: fake1, fake2: fake2)
            seedGuild(myUid: userId, myName: myName, fake1: fake1, fake2: fake2, fake3: fake3) {
                completion(true)
            }
        }
    }

    // MARK: - フレンド

    private static func seedFakeUsers(fake1: String, fake2: String, fake3: String) {
        let updates: [String: Any] = [
            "users/\(fake1)/userName": "はやぶさ",
            "users/\(fake1)/level": 18,
            "users/\(fake1)/featuredAvatar": ["name": "ドラゴンキング", "attack": 45, "health": 120],
            "users/\(fake2)/userName": "みずき",
            "users/\(fake2)/level": 12,
            "users/\(fake2)/featuredAvatar": ["name": "ボス16", "attack": 30, "health": 90],
            "users/\(fake3)/userName": "けんた",
            "users/\(fake3)/level": 25
        ]
        db.updateChildValues(updates)
    }

    private static func seedFriends(myUid: String, myName: String, fake1: String, fake2: String, fake3: String) {
        let now = ServerValue.timestamp()
        let dayKey = todayKey()

        var updates: [String: Any] = [
            "friends/\(myUid)/\(fake1)/since": now,
            "friends/\(fake1)/\(myUid)/since": now,
            "friends/\(myUid)/\(fake2)/since": now,
            "friends/\(fake2)/\(myUid)/since": now,
            "friendRequests/\(myUid)/\(fake3)": [
                "name": "けんた",
                "level": 25,
                "sentAt": now
            ],
            "helperThanks/\(myUid)": [
                "pendingCoins": 40,
                "pendingCount": 2
            ],
            "helperUsage/\(myUid)/\(dayKey)/\(fake1)": true
        ]
        // fake2 の助っ人はまだ借りていない状態にして「助っ人」ボタンが押せる見た目にする
        updates["helperUsage/\(myUid)/\(dayKey)/\(fake2)"] = NSNull()

        db.updateChildValues(updates)
    }

    // MARK: - 対戦

    private static func seedBattles(myUid: String, myName: String, fake1: String, fake2: String) {
        let questions = Array(BattleCategory.itPassport.questionPool.shuffled().prefix(5))
        guard !questions.isEmpty else { return }
        let questionsData: [[String: Any]] = questions.map { quiz in
            [
                "question": quiz.question,
                "choices": quiz.choices,
                "correctAnswerIndex": quiz.correctAnswerIndex,
                "explanation": quiz.explanation
            ]
        }
        let now = ServerValue.timestamp()

        let incomingBattleId = "demoBattleIncoming_\(myUid.prefix(6))"
        let outgoingBattleId = "demoBattleOutgoing_\(myUid.prefix(6))"
        let finishedBattleId = "demoBattleFinished_\(myUid.prefix(6))"

        let sampleAnswers: [[String: Any]] = [
            ["correct": true, "seconds": 4.2],
            ["correct": true, "seconds": 6.1],
            ["correct": false, "seconds": 9.8],
            ["correct": true, "seconds": 5.0],
            ["correct": true, "seconds": 3.7]
        ]
        let winningAnswers: [[String: Any]] = [
            ["correct": true, "seconds": 3.0],
            ["correct": true, "seconds": 4.5],
            ["correct": true, "seconds": 5.2],
            ["correct": false, "seconds": 10.0],
            ["correct": true, "seconds": 4.8]
        ]

        let updates: [String: Any] = [
            // 招待(相手からの挑戦、まだ自分は未プレイ)
            "battles/\(incomingBattleId)": [
                "category": BattleCategory.itPassport.rawValue,
                "questions": questionsData,
                "challengerUid": fake1,
                "challengerName": "はやぶさ",
                "challengerAvatar": "ドラゴンキング",
                "challengerAnswers": sampleAnswers,
                "opponentUid": myUid,
                "opponentName": myName,
                "status": "waiting_opponent",
                "createdAt": now
            ],
            "userBattles/\(myUid)/\(incomingBattleId)": [
                "role": "opponent",
                "status": "waiting_opponent",
                "opponentName": "はやぶさ",
                "category": BattleCategory.itPassport.rawValue,
                "createdAt": now
            ],

            // 対戦中(自分が送った挑戦、相手の応答待ち)
            "battles/\(outgoingBattleId)": [
                "category": BattleCategory.security.rawValue,
                "questions": questionsData,
                "challengerUid": myUid,
                "challengerName": myName,
                "challengerAvatar": NSNull(),
                "challengerAnswers": winningAnswers,
                "opponentUid": fake2,
                "opponentName": "みずき",
                "status": "waiting_opponent",
                "createdAt": now
            ],
            "userBattles/\(myUid)/\(outgoingBattleId)": [
                "role": "challenger",
                "status": "waiting_opponent",
                "opponentName": "みずき",
                "category": BattleCategory.security.rawValue,
                "createdAt": now
            ],

            // 結果(自分の勝利、報酬未受け取り)
            "battles/\(finishedBattleId)": [
                "category": BattleCategory.fundamentalInfo.rawValue,
                "questions": questionsData,
                "challengerUid": myUid,
                "challengerName": myName,
                "challengerAvatar": NSNull(),
                "challengerAnswers": winningAnswers,
                "opponentUid": fake1,
                "opponentName": "はやぶさ",
                "opponentAnswers": sampleAnswers,
                "status": "finished",
                "winnerUid": myUid,
                "challengerLeaguePoints": 15,
                "opponentLeaguePoints": 0,
                "createdAt": now
            ],
            "userBattles/\(myUid)/\(finishedBattleId)": [
                "role": "challenger",
                "status": "finished",
                "opponentName": "はやぶさ",
                "category": BattleCategory.fundamentalInfo.rawValue,
                "createdAt": now
            ]
        ]

        db.updateChildValues(updates)
    }

    // MARK: - ギルド

    private static func seedGuild(
        myUid: String,
        myName: String,
        fake1: String,
        fake2: String,
        fake3: String,
        completion: @escaping () -> Void
    ) {
        let guildId = "demoGuild_\(myUid.prefix(6))"
        let indexScope = "all"
        let weekId = currentWeekId()
        let now = ServerValue.timestamp()

        db.child("userGuild").child(myUid).observeSingleEvent(of: .value) { snapshot in
            var cleanupUpdates: [String: Any] = [:]
            if let oldGuildId = snapshot.value as? String, oldGuildId != guildId {
                cleanupUpdates["guilds/\(oldGuildId)/members/\(myUid)"] = NSNull()
            }

            let boss = guildRaidBosses.first ?? guildRaidBosses[0]
            let bossMaxHP = boss.bossHP

            var updates: [String: Any] = cleanupUpdates
            updates["userGuild/\(myUid)"] = guildId
            updates["guilds/\(guildId)/name"] = "毎日コツコツ勉強部屋"
            updates["guilds/\(guildId)/description"] = "毎日コツコツ、合格を目指す部屋です。"
            updates["guilds/\(guildId)/indexScope"] = indexScope
            updates["guilds/\(guildId)/leaderUid"] = myUid
            updates["guilds/\(guildId)/createdAt"] = now
            updates["guilds/\(guildId)/members/\(myUid)"] = ["name": myName, "level": 10, "joinedAt": now, "avatarName": ""]
            updates["guilds/\(guildId)/members/\(fake1)"] = ["name": "はやぶさ", "level": 18, "joinedAt": now, "avatarName": "ネッキー"]
            updates["guilds/\(guildId)/members/\(fake2)"] = ["name": "みずき", "level": 12, "joinedAt": now, "avatarName": "かみ蔵"]
            updates["guilds/\(guildId)/members/\(fake3)"] = ["name": "けんた", "level": 25, "joinedAt": now, "avatarName": "ぴょこん"]

            updates["guildIndex/\(indexScope)/\(guildId)"] = [
                "name": "毎日コツコツ勉強部屋",
                "description": "毎日コツコツ、合格を目指す部屋です。",
                "memberCount": 4,
                "leaderUid": myUid
            ]

            updates["guilds/\(guildId)/guildBoss"] = [
                "summonCorrectAnswers": 0,
                "summonTarget": 100,
                "current": [
                    "raidId": "demo-\(UUID().uuidString)",
                    "bossName": boss.name,
                    "bossImageName": boss.imageName,
                    "bossHP": bossMaxHP - 6800,
                    "bossMaxHP": bossMaxHP,
                    "status": "active",
                    "createdAt": now,
                    "players": [
                        fake1: ["name": "はやぶさ", "totalDamage": 3200, "correctCount": 28, "avatarName": "ネッキー"],
                        fake2: ["name": "みずき", "totalDamage": 2100, "correctCount": 19, "avatarName": "かみ蔵"],
                        myUid: ["name": myName, "totalDamage": 1500, "correctCount": 13, "avatarName": ""]
                    ]
                ]
            ]

            updates["guilds/\(guildId)/missions/\(weekId)"] = [
                "correctTotal": 340,
                "claimedBy": [String: Bool]()
            ]

            updates["guilds/\(guildId)/feed/demoFeed1"] = ["uid": fake1, "name": "はやぶさ", "text": "が仲間になりました", "timestamp": now]
            updates["guilds/\(guildId)/feed/demoFeed2"] = ["uid": fake2, "name": "みずき", "text": "がギルドボスに2100ダメージ", "timestamp": now]
            updates["guilds/\(guildId)/feed/demoFeed3"] = ["uid": fake3, "name": "けんた", "text": "が応用情報を15問クリア", "timestamp": now]

            self.db.updateChildValues(updates) { _, _ in
                completion()
            }
        }
    }

    // MARK: - Helpers

    private static func fetchMyName(userId: String, completion: @escaping (String) -> Void) {
        db.child("users").child(userId).child("userName").observeSingleEvent(of: .value) { snapshot in
            let name = (snapshot.value as? String) ?? ""
            completion(name.isEmpty ? "自分" : name)
        }
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = Calendar.current.timeZone
        return formatter.string(from: Date())
    }

    private static func currentWeekId(_ date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let week = calendar.component(.weekOfYear, from: date)
        return String(format: "%04d-W%02d", year, week)
    }
}
#endif
