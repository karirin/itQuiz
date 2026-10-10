import Foundation

struct QuizQuestion: Codable, Equatable, Sendable {
    var id: String?
    var question: String
    var choices: [String]
    var correctAnswerIndex: Int
    var explanation: String
    var sourceQuizLevel: String? = nil
    
    var isFourChoices: Bool { choices.count == 4 }

    var recommendedTimeLimit: Int {
        let longestChoiceCount = choices.map(\.count).max() ?? 0
        let totalChoiceCount = choices.reduce(0) { $0 + $1.count }

        if question.count >= 80 || longestChoiceCount >= 55 || totalChoiceCount >= 140 {
            return 60
        } else if question.count >= 60 || longestChoiceCount >= 35 || totalChoiceCount >= 100 {
            return 45
        } else {
            return 30
        }
    }
}

