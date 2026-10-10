import Foundation

/// Shared immutable question data. Views and review courses reuse the same literals.
enum ITPassportQuestionBank {
    static let all = basic + technology + strategy + management
}

private struct CourseQuestionKey: Hashable {
    let prompt: String
    let choices: [String]
    let correctIndex: Int
}

struct CourseQuestionHistory: Codable, Equatable {
    var lastSeenAt: Date
    var correctCount = 0
    var incorrectCount = 0
}

/// A reviewed tag manifest, not runtime keyword matching. Untagged bank questions
/// remain available in ordinary quizzes and can be added after editorial review.
enum CourseQuestionIndex {
    static let tags: [String: String] = [
        "it.05bd0bea3b194c62a0efef28": "memory",
        "it.d9e63bceff07c7ca2ebc9802": "encryption",
        "it.66667df0d3f2ebd55722cea5": "encryption",
        "it.2a26fec54992f8ce645f9013": "signature",
        "it.605b54b35d3450af833ab53a": "signature",
        "it.3c86ade0256943e485137c29": "dns",
        "it.65ca88d49ade526fca0bf094": "dns",
        "it.fc2f75a99a7d579af042876a": "dns",
        "it.8703068d61e9a7499cd8d6ac": "ipv4",
        "it.79f3699b31642806bceaa150": "ipv4",
        "it.af76e9b02205a265cacade01": "ipv4",
        "it.5c4629aa5f151c0b3d244fbd": "ipv4",
        "it.a11815ca2de01cbe94a26800": "ipv4",
        "it.d82e979ddb1f554dcbf2d769": "backup",
        "it.4f35ce678ea50d5a2317d4c7": "backup",
        "it.ffd3e34758f426be6c972e05": "backup",
        "it.a05a23d47c3d2862f436d1fc": "backup",
        "it.0551bec25523d9b493c90df4": "backup",
        "it.6a3020b4a0c18e6d3b48bbd8": "phishing",
        "it.a189bedcaa5ae302a6f862da": "phishing",
        "it.ea7bb2590cc7a08d0dc913e1": "phishing",
        "it.85fb350a32dc4d13337dbd16": "mfa",
        "it.df8dd441725194f3ca6af46a": "mfa",
        "it.9b42391afab25f602b715554": "breakeven",
        "it.a2da1c22b5ec30cebc5a0302": "breakeven",
        "it.76667e2c62b72e64874880f1": "pdca",
        "it.ead51c47922f1d1cec751ae0": "pdca",
        "it.7fd949ebe96dfbc4ffa86015": "pdca"
    ]

    private struct Storage {
        var byID: [String: CourseQuestion] = [:]
        var byContent: [CourseQuestionKey: String] = [:]
        var byTopic: [String: [CourseQuestion]] = [:]

        init() {
            for quiz in ITPassportQuestionBank.all {
                guard let id = quiz.id else { continue }
                let question = CourseQuestion(id: id, prompt: quiz.question, choices: quiz.choices,
                                              correctIndex: quiz.correctAnswerIndex, explanation: quiz.explanation)
                byID[id] = question
                byContent[CourseQuestionKey(prompt: quiz.question, choices: quiz.choices,
                                           correctIndex: quiz.correctAnswerIndex)] = id
            }
            for (id, topicID) in CourseQuestionIndex.tags {
                guard let question = byID[id], question.isValid else { continue }
                byTopic[topicID, default: []].append(question)
            }
            for topic in WeaknessCourseCatalog.topics {
                byTopic[topic.id]?.sort { $0.id < $1.id }
                for question in topic.practice + topic.checks { byID[question.id] = question }
                // Preserve append-only legacy IDs already stored on devices.
                for (offset, prompt) in topic.sourcePrompts.enumerated() {
                    if let question = byTopic[topic.id]?.first(where: { $0.prompt == prompt }) {
                        byID["\(topic.id).source\(offset + 1)"] = question
                    }
                }
            }
        }
    }

    private static let storage = Storage()

    static func question(_ id: String) -> CourseQuestion? { storage.byID[id] }
    static func candidates(topicID: String) -> [CourseQuestion] { storage.byTopic[topicID] ?? [] }

    static func source(prompt: String, choices: [String], correctIndex: Int, explanation: String)
        -> (topicID: String, question: CourseQuestion)? {
        let key = CourseQuestionKey(prompt: prompt, choices: choices, correctIndex: correctIndex)
        guard let id = storage.byContent[key], let topic = tags[id],
              let question = storage.byID[id], question.isValid else { return nil }
        // Use the explanation attached to the actual mistake, including older saved editions.
        return (topic, CourseQuestion(id: id, prompt: prompt, choices: choices,
                                      correctIndex: correctIndex, explanation: explanation))
    }

    static func select(topic: WeaknessCourseTopic, kind: CourseSessionKind,
                       original: CourseQuestion?, history: [String: CourseQuestionHistory]) -> [CourseQuestion] {
        let original = original.flatMap { $0.isValid ? $0 : nil }
        let preferredIDs = Set((kind == .practice ? topic.practice : topic.checks).map(\.id))
        let bank = candidates(topicID: topic.id)
        let bankIDs = Set(bank.map(\.id))
        let pool = (bank + topic.practice + topic.checks).filter { $0.isValid && $0.prompt != original?.prompt }
        let sorted = pool.sorted { left, right in
            let lSeen = history[left.id]?.lastSeenAt ?? .distantPast
            let rSeen = history[right.id]?.lastSeenAt ?? .distantPast
            if lSeen != rSeen { return lSeen < rSeen }
            if bankIDs.contains(left.id) != bankIDs.contains(right.id) { return bankIDs.contains(left.id) }
            if preferredIDs.contains(left.id) != preferredIDs.contains(right.id) { return preferredIDs.contains(left.id) }
            return left.id < right.id
        }
        var questions: [CourseQuestion] = kind == .practice ? original.map { [$0] } ?? [] : []
        let count = kind == .practice ? 3 : 2
        var prompts = Set(questions.map(\.prompt))
        for question in sorted where questions.count < count {
            if prompts.insert(question.prompt).inserted { questions.append(question) }
        }
        return questions
    }
}
