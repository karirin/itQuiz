import SwiftUI

/// ホームの今日の学習。完了した入口はHomeLearningActivity.availableで除外する。
struct DailyReviewPillButton: View {
    let activity: HomeLearningActivity
    let isSubscribed: Bool
    let action: () -> Void

    private let accent = Color(hex: "5B3FE0")

    @ViewBuilder
    var body: some View {
        if activity.isCompleted {
            cardContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(activity.title)、\(activity.message(isSubscribed: isSubscribed))")
                .accessibilityIdentifier("home.learning.\(activity.id).completed")
        } else {
            Button(action: action) { cardContent }
                .buttonStyle(.plain)
                .accessibilityLabel("\(activity.title)、\(activity.message(isSubscribed: isSubscribed))、\(activity.questionCount)問中\(activity.answeredCount)問回答済み")
                .accessibilityIdentifier("home.learning.\(activity.id)")
        }
    }

    private var cardContent: some View {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accent)
                        .frame(width: 46, height: 46)
                    Image(systemName: activity.isCompleted ? "checkmark" : (activity.analyticsActivity == .quickQuiz ? "bolt.fill" : "arrow.counterclockwise"))
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(activity.title)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "1F1D40"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if activity.questionCount <= 5 {
                            progressBars
                        } else {
                            Spacer(minLength: 0)
                            Text("\(activity.answeredCount)/\(activity.questionCount)問")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "4F4D6E"))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    Text(activity.message(isSubscribed: isSubscribed))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "4F4D6E"))
                        .lineLimit(2)
                    if activity.questionCount > 5 {
                        continuousProgressBar
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: activity.isCompleted ? "checkmark.seal.fill" : "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "4A32C4"))
            }
            .padding(.leading, 12)
            .padding(.trailing, 14)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .frame(minHeight: 72)
            .background(Capsule().fill(Color.white.opacity(0.85)))
            .overlay(Capsule().strokeBorder(Color.white, lineWidth: 1.5))
            .contentShape(Capsule())
            .shadow(color: Color(hex: "3C508C").opacity(0.15), radius: 18, y: 6)
    }

    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(0..<activity.questionCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(index < activity.answeredCount ? accent : Color(hex: "D9D6F5"))
                    .frame(width: 14, height: 6)
            }
        }
        .accessibilityHidden(true)
    }

    private var continuousProgressBar: some View {
        GeometryReader { geometry in
            let progress = CGFloat(min(max(0, activity.answeredCount), activity.questionCount))
                / CGFloat(activity.questionCount)
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: "D9D6F5"))
                Capsule()
                    .fill(accent)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}

#Preview("今日の学習の各状態") {
    ScrollView {
        VStack(spacing: 20) {
            DailyReviewPillButton(activity: .quickQuiz(.notStarted), isSubscribed: false, action: {})
            DailyReviewPillButton(activity: .quickQuiz(DailyQuickQuizProgress(questionCount: 3, answeredCount: 1)), isSubscribed: false, action: {})
            DailyReviewPillButton(activity: .savedITReview(DailyReviewProgress(incorrectCount: 12, questionCount: 5, answeredCount: 2)), isSubscribed: false, action: {})
            DailyReviewPillButton(activity: .savedITReview(DailyReviewProgress(incorrectCount: 100, questionCount: 100, answeredCount: 0)), isSubscribed: true, action: {})
            DailyReviewPillButton(activity: .savedITReview(DailyReviewProgress(incorrectCount: 1000, questionCount: 1000, answeredCount: 123)), isSubscribed: true, action: {})
            Text("完了後：学習ボタンは非表示")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
    }
    .background(LinearGradient(colors: [Color(hex: "E8EEFF"), Color(hex: "F6F2FF")], startPoint: .top, endPoint: .bottom))
}

#Preview("大量の復習・320pt幅") {
    DailyReviewPillButton(
        activity: .savedITReview(DailyReviewProgress(incorrectCount: 1000, questionCount: 1000, answeredCount: 123)),
        isSubscribed: true,
        action: {}
    )
    .padding(8)
    .frame(width: 320)
    .background(Color(hex: "E8EEFF"))
}
