import SwiftUI

/// 次の学習を決めてから、システムの許諾へ進む。
struct ReviewReminderOptInView: View {
    let plan: InitialLearningPlan
    let onFinished: () -> Void
    @ObservedObject private var service = PushNotificationService.shared
    @State private var hour = 20
    @State private var isRequesting = false
    @State private var errorMessage: String?

    var body: some View {
        FirstLearningReminderCard(
            plan: plan, hour: $hour, isRequesting: isRequesting,
            canEnableNotifications: service.authorizationStatus != .denied,
            errorMessage: errorMessage,
            onEnable: enableReminder,
            onSkip: {
                GrowthAnalytics.logNotificationSoftPrompt(action: "later")
                onFinished()
            }
        )
        .onAppear {
            hour = service.preferences.reminderHour
            service.refreshAuthorizationStatus()
            GrowthAnalytics.logNotificationSoftPrompt(action: "view")
        }
    }

    private func enableReminder() {
        guard !isRequesting else { return }
        isRequesting = true
        errorMessage = nil
        GrowthAnalytics.logNotificationSoftPrompt(action: "allow", hour: hour)
        service.requestAuthorization(source: "initial_diagnostic") { granted in
            guard granted else { isRequesting = false; return }
            service.scheduleInitialLearningReminder(plan: plan, hour: hour) { error in
                isRequesting = false
                if let error { errorMessage = error.localizedDescription }
                else {
                    GrowthAnalytics.logNotificationSoftPrompt(action: "scheduled", hour: hour)
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    ReviewReminderOptInView(plan: InitialLearningPlan(completedAt: Date(), incorrectCount: 1), onFinished: {})
}
