import Foundation

/// 初回案内と練習をひとつの状態で管理し、ホームの案内との重複を防ぐ。
struct InitialLearningFlow {
    enum Phase: Equatable {
        case welcome
        case practice
        case nameRegistration
        case spotlight
        case reminder
        case home
    }

    private(set) var phase: Phase
    private var phaseAfterNameRegistration: Phase = .home

    init(hasSeenWelcome: Bool, hasPendingNameRegistration: Bool = false) {
        phase = hasSeenWelcome ? (hasPendingNameRegistration ? .nameRegistration : .home) : .welcome
    }

    var allowsHomePrompts: Bool { phase == .home }

    mutating func skipWelcome(canOfferNameRegistration: Bool = false) {
        guard phase == .welcome else { return }
        phase = canOfferNameRegistration ? .nameRegistration : .home
    }

    mutating func startPractice() {
        guard phase == .welcome || phase == .home else { return }
        phase = .practice
    }

    mutating func finishPractice(completed: Bool, canOfferReminder: Bool, canOfferSpotlight: Bool = false, canOfferNameRegistration: Bool = false) {
        guard phase == .practice else { return }
        let nextPhase: Phase = completed && canOfferSpotlight ? .spotlight : (completed && canOfferReminder ? .reminder : .home)
        if canOfferNameRegistration {
            phaseAfterNameRegistration = nextPhase
            phase = .nameRegistration
        } else {
            phase = nextPhase
        }
    }

    mutating func finishNameRegistration() {
        guard phase == .nameRegistration else { return }
        phase = phaseAfterNameRegistration
    }

    mutating func resumeSpotlight() {
        guard phase == .home else { return }
        phase = .spotlight
    }

    mutating func finishSpotlight(canOfferReminder: Bool) {
        guard phase == .spotlight else { return }
        phase = canOfferReminder ? .reminder : .home
    }

    mutating func finishReminder() {
        guard phase == .reminder else { return }
        phase = .home
    }
}

/// 操作が実行されたときだけ進める。別画面からの遅いコールバックでは案内を飛ばさない。
struct InitialLearningTourProgress {
    enum Step: Int, CaseIterable {
        case home, qualification, category, questionIntroduction, question, explanation, completion
    }

    private(set) var step: Step?

    mutating func start() {
        guard step == nil else { return }
        step = .home
    }

    mutating func advance(from expected: Step) {
        guard step == expected else { return }
        step = Step(rawValue: expected.rawValue + 1) ?? expected
    }

    mutating func revisit(_ selection: Step) {
        guard let step, selection.rawValue <= Step.category.rawValue,
              selection.rawValue <= step.rawValue else { return }
        self.step = selection
    }

    mutating func finish() { step = nil }
}

/// 初回完了時の実際の誤答から、翌日の学習内容を案内する。
struct InitialLearningPlan: Codable, Equatable {
    let completedAt: Date
    let incorrectCount: Int

    var nextLearningTitle: String {
        incorrectCount > 0 ? "今日の問題を、もう一度" : "ITパスポートの新しい3問"
    }

    var nextLearningMessage: String {
        incorrectCount > 0
            ? "間違えた\(incorrectCount)問を保存しました。明日は復習から始めましょう。"
            : "今日は3問をやりきりました。明日は新しい問題で、知識を少しずつ増やしましょう。"
    }

    func reminderDate(hour: Int, now: Date = Date(), calendar: Calendar = .current) -> Date? {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: completedAt),
              let date = calendar.date(bySettingHour: min(max(hour, 6), 23), minute: 0, second: 0, of: nextDay),
              date > now else { return nil }
        return date
    }
}

enum InitialLearningPlanStore {
    static let localGuestID = "__local_guest__"
    private static func key(_ userID: String) -> String { "initialLearning.plan.v1.\(userID)" }

    static func load(userID: String, defaults: UserDefaults = .standard) -> InitialLearningPlan? {
        guard !userID.isEmpty, let data = defaults.data(forKey: key(userID)) else { return nil }
        return try? JSONDecoder().decode(InitialLearningPlan.self, from: data)
    }

    @discardableResult
    static func recordCompletion(userID: String, incorrectCount: Int, now: Date = Date(), defaults: UserDefaults = .standard) -> InitialLearningPlan? {
        guard !userID.isEmpty else { return nil }
        if let existing = load(userID: userID, defaults: defaults) { return existing }
        let plan = InitialLearningPlan(completedAt: now, incorrectCount: min(max(incorrectCount, 0), 3))
        guard let data = try? JSONEncoder().encode(plan) else { return nil }
        defaults.set(data, forKey: key(userID))
        return plan
    }
}
