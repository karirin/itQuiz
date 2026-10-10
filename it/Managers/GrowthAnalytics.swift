import Foundation
import FirebaseAnalytics

/// 獲得から初回学習、再訪までを同じキーで追跡するための共通Analytics入口。
enum GrowthAnalytics {
    private enum Key {
        static let firstOpenLogged = "growth.analytics.firstOpenLogged"
        static let initialDiagnosticCompleted = "growth.analytics.initialDiagnosticCompleted"
    }

    private static let sessionID = UUID().uuidString

    static var hasCompletedInitialDiagnostic: Bool {
        UserDefaults.standard.bool(forKey: Key.initialDiagnosticCompleted)
    }

    static func logFirstOpenIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: Key.firstOpenLogged) else { return }
        defaults.set(true, forKey: Key.firstOpenLogged)
        log("growth_first_open")
    }

    static func logOnboardingStart() {
        log("onboarding_start")
    }

    static func logOnboardingAction(_ action: String) {
        log("onboarding_action", parameters: ["action": action])
    }

    static func logInitialDiagnosticStart() {
        log("diagnostic_start", parameters: [
            "qualification": "it_passport",
            "question_count": 3,
            "practice_version": InitialPracticeContent.practiceVersion
        ])
    }

    static func logLearningSetComplete(
        quizLevel: QuizLevel,
        answeredCount: Int,
        correctCount: Int,
        isInitialDiagnostic: Bool,
        learningContext: LearningEntryContext? = nil
    ) {
        if isInitialDiagnostic {
            UserDefaults.standard.set(true, forKey: Key.initialDiagnosticCompleted)
        }

        var parameters: [String: Any] = [
            "quiz_level": quizLevel.description,
            "qualification": quizLevel.localReviewCategory.rawValue,
            "answered_count": answeredCount,
            "correct_count": correctCount,
            "incorrect_count": max(0, answeredCount - correctCount),
            "is_initial_diagnostic": isInitialDiagnostic ? 1 : 0
        ]
        if isInitialDiagnostic { parameters["practice_version"] = InitialPracticeContent.practiceVersion }
        parameters.merge(learningContext?.parameters ?? [:]) { _, new in new }
        log("learning_set_complete", parameters: parameters)

        if isInitialDiagnostic {
            log("activation_complete", parameters: [
                "qualification": "it_passport",
                "answered_count": answeredCount,
                "incorrect_count": max(0, answeredCount - correctCount)
            ])
        }
    }

    static func logDailyLearningCardView(_ activity: HomeLearningActivity) {
        log("daily_learning_card_view", parameters: [
            "entry_source": "home",
            "learning_activity": activity.analyticsActivity.rawValue,
            "card_state": activity.stateName,
            "question_count": activity.questionCount,
            "remaining_count": activity.remainingCount
        ])
    }

    static func logDailyLearningAction(activity: HomeLearningActivity, context: LearningEntryContext) {
        var parameters = context.parameters
        // 既存レポートで使用しているaction/due_countも残す。
        parameters["action"] = activity.analyticsActivity == .quickQuiz ? "quick_quiz" : "review_due"
        parameters["due_count"] = activity.reviewCount
        parameters["remaining_count"] = activity.remainingCount
        parameters["card_state"] = activity.stateName
        log("daily_learning_action", parameters: parameters)
    }

    static func logDailyLearningComplete(context: LearningEntryContext, questionCount: Int) {
        var parameters = context.parameters
        parameters["question_count"] = questionCount
        log("daily_learning_complete", parameters: parameters)
    }

    static func logNotificationSoftPrompt(action: String, hour: Int? = nil) {
        var parameters: [String: Any] = ["action": action]
        if let hour { parameters["reminder_hour"] = hour }
        log("notification_soft_prompt", parameters: parameters)
    }

    static func logNotificationPermission(status: String, source: String) {
        log("notification_permission_result", parameters: [
            "status": status,
            "source": source
        ])
    }

    static func logNotificationOpen(type: String) {
        log("notification_open", parameters: ["notification_type": type])
    }

    private static func log(_ name: String, parameters: [String: Any] = [:]) {
        var enriched = parameters
        enriched["session_id"] = sessionID
        Analytics.logEvent(name, parameters: enriched)
    }
}
