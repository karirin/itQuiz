import Foundation
import FirebaseDatabase

extension AccuracyExam {
    var reviewLevel: QuizLevel {
        switch self {
        case .it: return .incorrectITAnswer
        case .info: return .incorrectInfoAnswer
        case .applied: return .incorrectAppliedAnswer
        }
    }
    var incorrectPath: String {
        switch self {
        case .it: return "IncorrectITAnswers"
        case .info: return "IncorrectInfoAnswers"
        case .applied: return "IncorrectAppliedAnswers"
        }
    }
    func level(for area: AccuracyArea) -> QuizLevel {
        QuizLevel.allCases.first { $0.description == key(for: area) }!
    }
}

enum LearningAnalyticsService {
    static let dailyPath = "_analysisDays"

    static func fetchHistory(userID: String) async throws -> LearningHistory {
        let root = Database.database().reference()
        async let ratesSnapshot = snapshot(root.child("rates").child(userID))
        async let answersSnapshot = snapshot(root.child("answers").child(userID))
        let (rates, answers) = try await (ratesSnapshot, answersSnapshot)
        let values = rates.value as? [String: Any] ?? [:]
        var history = LearningHistory()
        for (key, value) in values {
            if let count = count(value) { history.totals[key] = count }
        }
        if let days = values[dailyPath] as? [String: [String: Any]] {
            for (date, levels) in days {
                history.daily[date] = levels.compactMapValues(count)
            }
        }
        if let levels = answers.value as? [String: [String: Int]] {
            history.answers = levels
        }
        return history
    }

    static func fetchReviews(userID: String, exam: AccuracyExam) async throws -> [QuizQuestion] {
        let result = try await snapshot(Database.database().reference().child(exam.incorrectPath).child(userID))
        let remote = result.children.compactMap { child -> QuizQuestion? in
            guard let child = child as? DataSnapshot,
                  let value = child.value as? [String: Any],
                  let question = value["quizQuestion"] as? String,
                  let choices = value["choices"] as? [String],
                  let correct = value["correctAnswerIndex"] as? Int,
                  choices.indices.contains(correct),
                  let explanation = value["explanation"] as? String else { return nil }
            return QuizQuestion(id: child.key, question: question, choices: choices,
                                correctAnswerIndex: correct, explanation: explanation,
                                sourceQuizLevel: value["sourceQuizLevel"] as? String)
        }
        let local = LocalIncorrectAnswerStore.questions(userId: userID, category: exam.reviewLevel.localReviewCategory)
        return LocalIncorrectAnswerStore.merged(local: local, remote: remote)
    }

    private static func count(_ value: Any) -> LearningCount? {
        guard let values = value as? [String: Any],
              let answer = values["answer"] as? Int,
              let correct = values["correct"] as? Int else { return nil }
        return LearningCount(answers: answer, correct: correct)
    }

    private static func snapshot(_ reference: DatabaseReference) async throws -> DataSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            reference.observeSingleEvent(of: .value, with: { continuation.resume(returning: $0) },
                                         withCancel: { continuation.resume(throwing: $0) })
        }
    }
}
