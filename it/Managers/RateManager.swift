//
//  RateManager.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/30.
//

import Firebase

struct QuizData {
    var answer: Int
    var correct: Int
    var correctRate: CGFloat {
        return answer > 0 ? CGFloat(correct) / CGFloat(answer) : 0
    }
    var correctPerRate: CGFloat {
        return answer > 0 ? CGFloat(correct) / CGFloat(answer) * 100 : 0
    }
}

struct ReviewWeakArea: Identifiable {
    let quizLevel: QuizLevel
    let accuracy: Double
    let answerCount: Int

    var id: String { quizLevel.description }
    var displayName: String { quizLevel.reviewDisplayName }
}

extension QuizLevel {
    /// 保存用のdescriptionとは分け、復習画面には日本語の表示名を使う。
    var reviewDisplayName: String {
        switch self {
        case .network: return "ネットワーク"
        case .security: return "セキュリティ"
        case .database: return "データベース"
        case .beginner: return "基礎問題"
        case .intermediate: return "標準問題"
        case .advanced: return "応用問題"
        case .god: return "総合問題"
        case .beginnerStory1: return "ストーリー基礎問題1"
        case .beginnerStory2: return "ストーリー基礎問題2"
        case .beginnerStory3: return "ストーリー基礎問題3"
        case .daily: return "今日の問題"
        case .incorrectAnswer: return "間違えた問題の復習"
        case .incorrectITAnswer: return "ITパスポートの復習"
        case .incorrectInfoAnswer: return "基本情報の復習"
        case .incorrectAppliedAnswer: return "応用情報の復習"
        case .incorrectESAnswer: return "エンベデッドシステムの復習"
        case .incorrectITStrategyAnswer: return "ITストラテジストの復習"
        case .timeBeginner: return "基礎問題（タイムアタック）"
        case .timeIntermediate: return "標準問題（タイムアタック）"
        case .timeAdvanced: return "応用問題（タイムアタック）"
        case .itBasic: return "ITパスポート・基礎理解"
        case .itStrategy: return "ITパスポート・ストラテジ"
        case .itTechnology: return "ITパスポート・テクノロジ"
        case .itManagement: return "ITパスポート・マネジメント"
        case .infoBasic: return "基本情報・基礎理解"
        case .infoStrategy: return "基本情報・ストラテジ"
        case .infoTechnology: return "基本情報・テクノロジ"
        case .infoManagement: return "基本情報・マネジメント"
        case .appliedBasic: return "応用情報・基礎理解"
        case .appliedStrategy: return "応用情報・ストラテジ"
        case .appliedTechnology: return "応用情報・テクノロジ"
        case .appliedManagement: return "応用情報・マネジメント"
        case .mugen: return "無限問題"
        case .computerSystem: return "コンピュータシステム"
        case .softHard: return "ソフトウェア・ハードウェア"
        case .netwarkTusin: return "ネットワーク・通信"
        case .ESsecurity: return "セキュリティ"
        case .kikaku: return "システム企画"
        case .sekkei: return "システム設計"
        case .kaihatu: return "システム開発"
        case .unyouhoshu: return "システム運用・保守"
        }
    }
}

class RateManager {
    static let shared = RateManager()

    private let db = Database.database().reference()

    /// One snapshot supplies every exam, so the chart and list always agree.
    func fetchAccuracyData(userId: String) async throws -> [String: QuizData] {
        try await withCheckedThrowingContinuation { continuation in
            db.child("rates").child(userId).observeSingleEvent(of: .value, with: { snapshot in
                var data: [String: QuizData] = [:]
                for child in snapshot.children {
                    guard let record = child as? DataSnapshot,
                          let values = record.value as? [String: Any],
                          let answer = values["answer"] as? Int,
                          let correct = values["correct"] as? Int else { continue }
                    data[record.key] = QuizData(answer: answer, correct: correct)
                }
                continuation.resume(returning: data)
            }, withCancel: { error in
                continuation.resume(throwing: error)
            })
        }
    }

    func updateQuizData(userId: String, quizType: QuizLevel, newCorrectAnswers: Int, newTotalAnswers: Int) {
        guard !userId.isEmpty, newTotalAnswers > 0 else { return }
        PushNotificationService.shared.recordLearningActivity(userId: userId)
        let correct = min(max(0, newCorrectAnswers), newTotalAnswers)
        let values: [String: Any] = [
            "answer": ServerValue.increment(NSNumber(value: newTotalAnswers)),
            "correct": ServerValue.increment(NSNumber(value: correct))
        ]
        let rates = db.child("rates").child(userId)
        // Keep legacy totals independent of the newly introduced history path.
        rates.child(quizType.description).updateChildValues(values) { error, _ in
            if let error { print("Failed to update quiz totals: \(error.localizedDescription)") }
        }
        rates.child(LearningAnalyticsService.dailyPath)
            .child(LearningDates.key(Date()))
            .child(quizType.description)
            .updateChildValues(values) { error, _ in
                if let error { print("Failed to update dated quiz history: \(error.localizedDescription)") }
            }
    }
    
    func updateAnswerData(userId: String, quizType: QuizLevel, newTotalAnswers: Int) {
        guard !userId.isEmpty, newTotalAnswers > 0 else { return }
        db.child("answers").child(userId).child(quizType.description)
            .child(LearningDates.key(Date()))
            .setValue(ServerValue.increment(NSNumber(value: newTotalAnswers))) { error, _ in
                if let error { print("Failed to update daily answers: \(error.localizedDescription)") }
            }
    }

    func updateAnswerBossData(userId: String, quizType: QuizBossLevel, newTotalAnswers: Int) {
        guard !userId.isEmpty, newTotalAnswers > 0 else { return }
        PushNotificationService.shared.recordLearningActivity(userId: userId)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
//        let currentDate = "2023-12-08"

        // 各日付ごとに別々のレコードを作成するための参照
        let dateRef = db.child("answers").child(userId).child(quizType.description).child(currentDate)

        dateRef.observeSingleEvent(of: .value, with: { snapshot in
            var totalAnswers = newTotalAnswers

            // その日付で既にデータがある場合は、新しい値を加算する
            if let currentTotal = snapshot.value as? Int {
                totalAnswers += currentTotal
            }

            // データベースを更新
            dateRef.setValue(totalAnswers) { error, _ in
                if let error = error {
                    print("Error updating quiz data: \(error.localizedDescription)")
                } else {
                    print("Quiz data updated successfully.")
                }
            }
        })
    }
    
    func fetchQuizData(userId: String, completion: @escaping ([QuizLevel: QuizData]) -> Void) {
            let ratesRef = db.child("rates").child(userId)

            ratesRef.observeSingleEvent(of: .value, with: { snapshot in
                var quizData = [QuizLevel: QuizData]()

                for level in QuizLevel.allCases {
                    if let levelData = snapshot.childSnapshot(forPath: level.description).value as? [String: Int],
                       let correct = levelData["correct"],
                       let answer = levelData["answer"] {
                        quizData[level] = QuizData(answer: answer, correct: correct)
                    }
                }

                completion(quizData)
            })
        }

    func fetchReviewWeakAreas(userId: String, completion: @escaping ([ReviewWeakArea]) -> Void) {
        fetchQuizData(userId: userId) { quizData in
            let areas = quizData.compactMap { level, data -> ReviewWeakArea? in
                guard data.answer > 0 else { return nil }
                return ReviewWeakArea(
                    quizLevel: level,
                    accuracy: Double(data.correctPerRate),
                    answerCount: data.answer
                )
            }
            .sorted {
                if $0.accuracy == $1.accuracy {
                    return $0.answerCount > $1.answerCount
                }
                return $0.accuracy < $1.accuracy
            }
            completion(Array(areas.prefix(3)))
        }
    }
    
    func fetchITQuizData(userId: String, completion: @escaping ([QuizITLevel: QuizData]) -> Void) {
            let ratesRef = db.child("rates").child(userId)

            ratesRef.observeSingleEvent(of: .value, with: { snapshot in
                var quizData = [QuizITLevel: QuizData]()
print("snapshot:\(snapshot)")
                print("QuizITLevel.allCases:\(QuizITLevel.allCases)")
                for level in QuizITLevel.allCases {
                    if let levelData = snapshot.childSnapshot(forPath: level.description).value as? [String: Int],
                       let correct = levelData["correct"],
                       let answer = levelData["answer"] {
//                        print("test:\(levelData)")
                        quizData[level] = QuizData(answer: answer, correct: correct)
                        print("quizData1:\(quizData)")
                    }
                }

                completion(quizData)
            })
        }
    
    func fetchInfoQuizData(userId: String, completion: @escaping ([QuizInfoLevel: QuizData]) -> Void) {
            let ratesRef = db.child("rates").child(userId)

            ratesRef.observeSingleEvent(of: .value, with: { snapshot in
                var quizData = [QuizInfoLevel: QuizData]()

                for level in QuizInfoLevel.allCases {
                    if let levelData = snapshot.childSnapshot(forPath: level.description).value as? [String: Int],
                       let correct = levelData["correct"],
                       let answer = levelData["answer"] {
                        quizData[level] = QuizData(answer: answer, correct: correct)
                    }
                }

                completion(quizData)
            })
        }
    
    func fetchAppliedQuizData(userId: String, completion: @escaping ([QuizAppliedLevel: QuizData]) -> Void) {
            let ratesRef = db.child("rates").child(userId)

            ratesRef.observeSingleEvent(of: .value, with: { snapshot in
                var quizData = [QuizAppliedLevel: QuizData]()

                for level in QuizAppliedLevel.allCases {
                    if let levelData = snapshot.childSnapshot(forPath: level.description).value as? [String: Int],
                       let correct = levelData["correct"],
                       let answer = levelData["answer"] {
                        quizData[level] = QuizData(answer: answer, correct: correct)
                    }
                }

                completion(quizData)
            })
        }
}
