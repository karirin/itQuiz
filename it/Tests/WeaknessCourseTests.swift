import Foundation

@main
struct WeaknessCourseTests {
    static func main() throws {
        if CommandLine.arguments.contains("--benchmark") { try CourseQuestionBenchmark.run(); return }
        if CommandLine.arguments.contains("--dump-bank") {
            let banks = ["basic": ITPassportQuestionBank.basic, "technology": ITPassportQuestionBank.technology,
                         "strategy": ITPassportQuestionBank.strategy, "management": ITPassportQuestionBank.management]
            print(String(data: try JSONEncoder().encode(banks), encoding: .utf8)!)
            return
        }
        var checks = 0
        func expect(_ value: @autoclosure () -> Bool, _ message: String) {
            checks += 1
            guard value() else { fatalError("FAILED: \(message)") }
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let now = Date(timeIntervalSince1970: 1_791_000_000)
        let day1 = calendar.date(byAdding: .day, value: 1, to: now)!
        let day4 = calendar.date(byAdding: .day, value: 4, to: now)!
        let topics = WeaknessCourseCatalog.topics
        let topic = topics[0]
        let other = topics[1]

        expect(topics.count == 10, "初期版は10テーマ")
        expect(Set(topics.map(\.id)).count == 10, "テーマIDは一意")
        let questions = topics.flatMap { $0.practice + $0.checks }
        expect(questions.count == 50, "練習30問・確認20問")
        expect(Set(questions.map(\.id)).count == questions.count, "問題IDは全テーマで一意")
        expect(Set(questions.map(\.correctIndex)).count == 4, "正解位置は固定しない")
        expect(questions.allSatisfy(\.isValid), "全問に有効な選択肢・正解・解説がある")
        for item in topics {
            expect(item.practice.count == 3 && item.checks.count == 2, "各テーマの問題数")
            expect(Set((item.practice + item.checks).map(\.prompt)).count == 5, "確認問題は練習の別問題")
            expect(!item.sourcePrompts.isEmpty && !item.lesson.isEmpty, "通常問題との接続と説明がある")
        }
        let prompts = topics.flatMap(\.sourcePrompts)
        expect(Set(prompts).count == prompts.count, "元問題は複数テーマへ曖昧に分類しない")
        expect(WeaknessCourseCatalog.source(prompt: "公開鍵という単語だけを含む別問題", choices: ["a", "b"], correctIndex: 0, explanation: "test") == nil,
               "単語の偶然の一致では分類しない")

        var account = CourseAccountState()
        let original = CourseQuestion(id: "memory.source1", prompt: topic.sourcePrompts[0], choices: ["ROM", "RAM", "SSD", "HDD"], correctIndex: 1, explanation: "RAMは揮発性です。")
        account.recordMistake(topicID: topic.id, question: original, selectedIndex: 0, now: now)
        expect(account.cloud.progress[topic.id]?.lastSelectedIndex == 0, "選択した誤答を保存")
        let session = account.begin(topic: topic, subscribed: false, now: now)!
        expect(session.questions.first == original, "最初に実際の誤答を練習")
        expect(session.questions.count == 3, "元問題と別の2問で構成")
        expect(account.cloud.freeClaim?.topicID == topic.id, "最初の無料テーマを確定")
        expect(account.begin(topic: other, subscribed: false, now: now) == nil, "2テーマ目は加入が必要")
        expect(account.activeSession?.id == session.id, "ロックされたテーマで途中の練習を失わない")
        expect(account.finish(sessionID: session.id, now: now) == nil, "未回答ではクリアできない")
        account.activeSession?.answer(session.questions[0].correctIndex)
        account.activeSession?.answer(-1)
        expect(account.activeSession?.correctCount == 1, "連打で回答を上書きしない")
        expect(account.activeSession?.questionIndex == 0, "回答後は解説画面を維持")

        let suiteName = "course-tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        CourseLocalPersistence.save(account, userID: "alice", defaults: defaults)
        expect(CourseLocalPersistence.load(userID: "alice", defaults: defaults) == account, "再起動後も選択済み回答・解説を復元")
        expect(CourseLocalPersistence.load(userID: "bob", defaults: defaults).cloud.freeClaim == nil, "別アカウントに無料枠や進捗が漏れない")
        account = CourseLocalPersistence.load(userID: "alice", defaults: defaults)
        expect(account.begin(topic: topic, subscribed: false, now: day1)?.id == session.id, "同じ途中セッションを再開")

        func complete(_ account: inout CourseAccountState, at date: Date, fail: Bool = false) -> CourseCompletion? {
            let id = account.activeSession!.id
            while let question = account.activeSession?.currentQuestion {
                if account.activeSession?.answers[question.id] == nil {
                    account.activeSession?.answer(fail ? -1 : question.correctIndex)
                }
                account.activeSession?.advance()
            }
            return account.finish(sessionID: id, now: date, calendar: calendar)
        }
        let practiceResult = complete(&account, at: now)!
        expect(practiceResult.passed && practiceResult.progress.stage == .waiting, "練習の全問正解で確認待ち")
        expect(practiceResult.progress.nextReviewAt == day1, "初回確認は翌日の同時刻")
        expect(account.finish(sessionID: session.id, now: now) == nil, "二重完了を防止")
        expect(account.begin(topic: topic, subscribed: false, now: now.addingTimeInterval(10)) == nil, "同日の反復で確認回数を増やせない")

        account.importMistake(topicID: topic.id, question: original, now: day1)
        expect(account.cloud.progress[topic.id]?.stage == .waiting, "古い誤答の再読み込みは進捗を戻さない")
        var differentOriginal = original
        differentOriginal = CourseQuestion(id: "memory.source2", prompt: "別の古い問題", choices: original.choices, correctIndex: 1, explanation: original.explanation)
        account.importMistake(topicID: topic.id, question: differentOriginal, now: day1)
        expect(account.cloud.progress[topic.id]?.stage == .waiting, "別の古い誤答でも進行中コースを戻さない")

        let firstCheck = account.begin(topic: topic, subscribed: false, now: day1)!
        expect(firstCheck.kind == .confirmation && firstCheck.questions.count == 2, "無料テーマも後日の確認へ進める")
        let firstResult = complete(&account, at: day1)!
        expect(firstResult.progress.confirmedCount == 1 && firstResult.progress.nextReviewAt == day4, "2回目確認は初回確認の3日後")
        expect(account.begin(topic: topic, subscribed: false, now: day4) != nil, "2回目も無料のまま")
        let finalResult = complete(&account, at: day4)!
        expect(finalResult.progress.stage == .mastered && finalResult.progress.masteredAt == day4, "日を空けた2回確認でクリア")
        expect(account.begin(topic: topic, subscribed: false, now: day4) == nil, "クリア後の連打で成果を増やせない")

        account.recordMistake(topicID: topic.id, question: original, selectedIndex: 2, now: day4.addingTimeInterval(100))
        expect(account.cloud.progress[topic.id]?.stage == .needsPractice && account.cloud.progress[topic.id]?.masteredAt == nil, "新たな誤答で練習に戻る")
        expect(account.begin(topic: topic, subscribed: false, now: day4.addingTimeInterval(101)) != nil, "同じ無料テーマは再練習可能")
        let failed = complete(&account, at: day4.addingTimeInterval(102), fail: true)!
        expect(!failed.passed && failed.progress.stage == .needsPractice, "わからないを含むとクリアしない")
        expect(failed.progress.nextReviewAt == nil, "不正解のコースは説明から練習")

        expect(account.begin(topic: other, subscribed: true, now: day4) != nil, "加入後に選んだ別テーマを開始")
        expect(account.cloud.freeClaim?.topicID == topic.id, "加入後も元の無料テーマを維持")
        expect(account.begin(topic: other, subscribed: false, now: day4) == nil, "期限終了後は別テーマの新規開始・再開をロック")
        expect(account.begin(topic: topic, subscribed: false, now: day4) != nil, "期限終了後も無料テーマは使える")

        var formerSubscriber = CourseAccountState()
        let paidSession = formerSubscriber.begin(topic: topic, subscribed: true, now: now)!
        expect(formerSubscriber.cloud.freeClaim == nil, "有料利用中に無料枠を消費しない")
        expect(formerSubscriber.begin(topic: topic, subscribed: false, now: day1)?.id == paidSession.id, "期限終了後に同じセッションを無料枠で再開")
        expect(formerSubscriber.cloud.freeClaim?.topicID == topic.id, "再開でも無料テーマを確定する")
        expect(formerSubscriber.begin(topic: other, subscribed: false, now: day1) == nil, "再開を使って無料枠を増やせない")

        var remote = CourseCloudState()
        remote.progress[other.id] = CourseProgress(updatedAt: day4)
        remote.freeClaim = CourseFreeClaim(topicID: other.id, claimedAt: now.addingTimeInterval(60))
        let merged = account.cloud.merging(remote)
        expect(merged.progress[topic.id] != nil && merged.progress[other.id] != nil, "端末ごとの別テーマの進捗をマージ")
        expect(merged.freeClaim?.topicID == topic.id, "オフライン競合では先に選んだ無料テーマを維持")
        remote.progress[topic.id] = CourseProgress(stage: .mastered, masteredAt: day4, updatedAt: now.addingTimeInterval(-1))
        expect(merged.merging(remote).progress[topic.id]?.stage == .needsPractice, "古いクラウドのクリア記録で新たな誤答を消さない")
        let emptyCloud = try JSONDecoder().decode(CourseCloudState.self, from: Data("{}".utf8))
        expect(emptyCloud == CourseCloudState(), "Firebaseが空の配列・辞書を消しても読める")
        let cloudEncoded = try JSONEncoder().encode(merged)
        let cloudDecoded = try JSONDecoder().decode(CourseCloudState.self, from: cloudEncoded)
        expect(cloudDecoded == merged, "クラウドデータを往復しても進捗は同じ")

        var stale = account
        let oldSession = stale.activeSession!
        stale.cloud.progress[topic.id]?.updatedAt = day4.addingTimeInterval(1_000)
        while let question = stale.activeSession?.currentQuestion {
            stale.activeSession?.answer(question.correctIndex)
            stale.activeSession?.advance()
        }
        expect(stale.finish(sessionID: oldSession.id, now: day4) == nil, "別端末で更新された進捗を古いセッションで上書きしない")
        let bank = ITPassportQuestionBank.all
        expect(bank.count == 844 && Set(bank.compactMap(\.id)).count == 841, "元の844問を共通データに保持、同一内容の3重複は同じID")
        expect(CourseQuestionIndex.tags.count == 28, "28問の関連付けを確認済み")
        expect(CourseQuestionIndex.tags.keys.allSatisfy { CourseQuestionIndex.question($0)?.isValid == true }, "関連付けの全IDが実問題を参照")
        expect(CourseQuestionIndex.tags.values.allSatisfy { WeaknessCourseCatalog.topic($0) != nil }, "全タグが実テーマに接続")
        for item in topics {
            expect(item.sourcePrompts.allSatisfy { prompt in
                CourseQuestionIndex.candidates(topicID: item.id).contains { $0.prompt == prompt }
            }, "旧23件の対応を維持：\(item.id)")
        }
        let dns = WeaknessCourseCatalog.topic("dns")!
        let dhcp = CourseQuestionIndex.question("it.fc2f75a99a7d579af042876a")!
        let mappedDHCP = WeaknessCourseCatalog.source(prompt: dhcp.prompt, choices: dhcp.choices,
                                                     correctIndex: dhcp.correctIndex, explanation: dhcp.explanation)
        expect(mappedDHCP?.topicID == dns.id && mappedDHCP?.question.id == dhcp.id, "追加したDHCP問題もDNSとの区別に接続")
        var rotating = CourseAccountState()
        rotating.recordMistake(topicID: dns.id, question: dhcp, selectedIndex: -1, now: now)
        let round1 = rotating.begin(topic: dns, subscribed: true, now: now)!
        let extras1 = Set(round1.questions.dropFirst().map(\.id))
        expect(round1.questions.first == dhcp, "変更した元問題の問題文と解説を使う")
        expect(round1.questions.dropFirst().allSatisfy { CourseQuestionIndex.tags[$0.id] == dns.id }, "未出題の既存関連問題を優先")
        _ = complete(&rotating, at: now, fail: true)
        expect(rotating.cloud.progress[dns.id]?.questionHistory[dhcp.id]?.incorrectCount == 2, "通常誤答とコース誤答を履歴に記録")
        let round2 = rotating.begin(topic: dns, subscribed: true, now: day1)!
        expect(Set(round2.questions.dropFirst().map(\.id)).isDisjoint(with: extras1), "再練習は未出題を優先して同じ2問を繰り返さない")
        expect(rotating.begin(topic: dns, subscribed: true, now: day4)?.questions == round2.questions, "再開では問題を再選択しない")

        let candidates = CourseQuestionIndex.candidates(topicID: dns.id) + dns.practice + dns.checks
        var seen = Dictionary(uniqueKeysWithValues: candidates.map { ($0.id, CourseQuestionHistory(lastSeenAt: day1)) })
        seen[dns.practice[2].id]?.lastSeenAt = now.addingTimeInterval(-100)
        seen[dns.checks[1].id]?.lastSeenAt = now.addingTimeInterval(-200)
        let oldest = CourseQuestionIndex.select(topic: dns, kind: .confirmation, original: dhcp, history: seen)
        expect(oldest.map(\.id) == [dns.checks[1].id, dns.practice[2].id], "全問既出なら古い問題から出す")
        var smallPool = CourseAccountState()
        smallPool.recordMistake(topicID: topic.id, question: original, selectedIndex: -1, now: now)
        _ = smallPool.begin(topic: topic, subscribed: true, now: now)
        _ = complete(&smallPool, at: now)
        let check1 = smallPool.begin(topic: topic, subscribed: true, now: day1)!
        _ = complete(&smallPool, at: day1)
        let check2 = smallPool.begin(topic: topic, subscribed: true, now: day4)!
        expect(Set(check1.questions.map(\.id)).isDisjoint(with: check2.questions.map(\.id)), "元問題が少ないテーマも2回の確認は別問題")

        var compact = CourseCloudState()
        compact.progress[dns.id] = CourseProgress(sourceQuestion: dhcp, updatedAt: now)
        let compactValue = CourseCloudCodec.encode(compact)!
        let compactText = String(data: try JSONSerialization.data(withJSONObject: compactValue), encoding: .utf8)!
        expect(compactText.contains("sourceQuestionID") && !compactText.contains(dhcp.prompt), "クラウドは本文の代わりにIDを保存")
        expect(CourseCloudCodec.decode(CourseCloudState.self, from: compactValue) == compact, "IDから元問題・解説を復元")
        func hasValidFirebaseKeys(_ value: Any) -> Bool {
            if let object = value as? [String: Any] {
                return object.allSatisfy { key, child in
                    !key.isEmpty && !key.unicodeScalars.contains { scalar in
                        ".#$[]/".unicodeScalars.contains(scalar) || scalar.value < 32 || scalar.value == 127
                    } && hasValidFirebaseKeys(child)
                }
            }
            if let array = value as? [Any] { return array.allSatisfy(hasValidFirebaseKeys) }
            return true
        }
        let historyCloud = CourseCloudCodec.encode(rotating.cloud)!
        expect(hasValidFirebaseKeys(historyCloud), "起動時の誤答同期にFirebase禁止キーを含まない")
        expect(CourseCloudCodec.decode(CourseCloudState.self, from: historyCloud) == rotating.cloud,
               "問題IDと正誤履歴をクラウド同期で保持")
        let historyProgress = rotating.cloud.progress[dns.id]!
        let historyNode = CourseCloudCodec.encode(historyProgress) as! [String: Any]
        expect(hasValidFirebaseKeys(historyNode) && historyNode["questionHistory"] == nil,
               "テーマ単位のトランザクションも安全な履歴形式を使う")
        expect(CourseCloudCodec.decode(CourseProgress.self, from: historyNode) == historyProgress,
               "テーマ単位のトランザクション応答から履歴を復元")
        let legacyHistoryNode = try JSONSerialization.jsonObject(with: JSONEncoder().encode(historyProgress))
        expect(CourseCloudCodec.decode(CourseProgress.self, from: legacyHistoryNode) == historyProgress,
               "既存の辞書形式の履歴も読み込める")
        var emptyHistoryNode = compactValue as! [String: Any]
        var emptyHistoryProgress = emptyHistoryNode["progress"] as! [String: [String: Any]]
        emptyHistoryProgress[dns.id]?.removeValue(forKey: "questionHistoryEntries")
        emptyHistoryNode["progress"] = emptyHistoryProgress
        expect(CourseCloudCodec.decode(CourseCloudState.self, from: emptyHistoryNode) == compact,
               "Firebaseが空の履歴配列を消しても読める")
        var edited = dhcp
        edited = CourseQuestion(id: edited.id, prompt: edited.prompt, choices: edited.choices,
                                correctIndex: edited.correctIndex, explanation: "保存済みの旧版解説")
        compact.progress[dns.id]?.sourceQuestion = edited
        expect(CourseCloudCodec.decode(CourseCloudState.self, from: CourseCloudCodec.encode(compact)) == compact, "旧版解説が異なるときは失わずに保存")
        let legacyJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(account))
        var legacyObject = legacyJSON as! [String: Any]
        var legacyCloud = legacyObject["cloud"] as! [String: Any]
        var legacyProgress = legacyCloud["progress"] as! [String: [String: Any]]
        for id in legacyProgress.keys { legacyProgress[id]?.removeValue(forKey: "questionHistory") }
        legacyCloud["progress"] = legacyProgress; legacyObject["cloud"] = legacyCloud
        let migrated = try JSONDecoder().decode(CourseAccountState.self, from: JSONSerialization.data(withJSONObject: legacyObject))
        expect(migrated.cloud.freeClaim == account.cloud.freeClaim && migrated.activeSession == account.activeSession,
               "旧保存データから無料枠・途中セッションを引き継ぐ")
        expect(migrated.cloud.progress.values.allSatisfy { $0.questionHistory.isEmpty }, "旧データの履歴なしを許容")

        var baseline = rotating.cloud
        expect(CourseSyncDelta(local: rotating.cloud, acknowledged: baseline).isEmpty, "変更なしならネットワーク書き込み不要")
        var dirty = baseline
        dirty.progress[dns.id]?.updatedAt = day4
        let delta = CourseSyncDelta(local: dirty, acknowledged: baseline)
        expect(delta.progress.count == 1 && delta.progress[dns.id] != nil && delta.freeClaim == nil && delta.importedSourceIDs.isEmpty,
               "更新した1テーマだけを同期対象にする")
        baseline = baseline.merging(dirty)
        dirty.progress[dns.id]?.updatedAt = day4.addingTimeInterval(1)
        expect(!CourseSyncDelta(local: dirty, acknowledged: baseline).isEmpty, "通信中の新しい変更は成功した旧更新で消えない")
        let unknownIDValue: [String: Any] = ["stage": "needsPractice", "sourceQuestionID": "future.unknown",
                                            "mistakeCount": 1, "confirmedCount": 0, "updatedAt": 0]
        expect(CourseCloudCodec.decode(CourseProgress.self, from: unknownIDValue) == nil, "未知のクラウド問題IDを空データで上書きしない")
        var recovery = CourseCloudState()
        recovery.progress[topic.id] = CourseProgress(stage: .waiting, confirmedCount: 1,
            nextReviewAt: day1, updatedAt: now)
        recovery.progress[dns.id] = CourseProgress(stage: .waiting, nextReviewAt: day4, updatedAt: now)
        recovery.progress[other.id] = CourseProgress(stage: .mastered, masteredAt: now, updatedAt: now)
        recovery.progress["future-topic"] = CourseProgress(stage: .waiting, nextReviewAt: now, updatedAt: now)
        recovery.freeClaim = CourseFreeClaim(topicID: topic.id, claimedAt: now)
        let recoveryBefore = recovery
        let today = WeaknessRecoveryOverview(state: recovery, now: day1)
        expect(today.dueTopicIDs == [topic.id], "確認予定の時刻になったテーマだけを今日の予定に表示")
        expect(today.nextConfirmationAt == day4, "次の確認は未来の予定から選ぶ")
        expect(today.masteredTopicIDs == [other.id], "克服したテーマは今日の確認に混ぜない")
        expect(recovery == recoveryBefore && recovery.freeClaim?.topicID == topic.id,
               "共通画面の集計では既存の進捗・無料テーマを書き換えない")
        let overdue = WeaknessRecoveryOverview(state: recovery, now: day4)
        expect(overdue.dueTopicIDs == [topic.id, dns.id], "期限が過ぎた確認も古い予定から表示")
        expect(overdue.nextConfirmationAt == nil, "未来の確認予定がなければ次回を捏造しない")
        recovery.progress[dns.id]?.stage = .needsPractice
        expect(WeaknessRecoveryOverview(state: recovery, now: day4).practiceTopicIDs == [dns.id],
               "間違えて練習に戻ったテーマは確認待ちと区別する")
        let mappedOriginal = ITPassportQuestionBank.all.first { $0.question == topic.sourcePrompts[0] }!
        expect(WeaknessRecoveryOverview.topic(for: mappedOriginal)?.id == topic.id,
               "復習する元問題から対応するテーマへ進める")
        let unrelated = QuizQuestion(question: "DNSという単語だけを含む未分類の問題", choices: ["a", "b"],
                                     correctAnswerIndex: 0, explanation: "説明")
        expect(WeaknessRecoveryOverview.topic(for: unrelated) == nil, "未対応の問題には誤ったテーマ導線を出さない")
        print("Weakness course regression checks passed (\(checks) checks)")
    }
}
