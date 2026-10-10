import SwiftUI

struct DailyLearningCard: View {
    let activity: HomeLearningActivity
    let isSubscribed: Bool
    let action: () -> Void

    private var hasReviews: Bool { activity.reviewCount > 0 }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: hasReviews ? "arrow.counterclockwise.circle.fill" : "bolt.fill")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 18, weight: .bold))
                    Text(activity.message(isSubscribed: isSubscribed))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [Color(hex: "2563eb"), Color(hex: "7c3aed")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.indigo.opacity(0.25), radius: 9, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(activity.title)、\(activity.message(isSubscribed: isSubscribed))")
        .accessibilityIdentifier("home.learning.\(activity.id)")
    }
}

#Preview {
    VStack(spacing: 12) {
        DailyLearningCard(activity: .scheduledReview(count: 2), isSubscribed: true, action: {})
    }
    .padding()
}
