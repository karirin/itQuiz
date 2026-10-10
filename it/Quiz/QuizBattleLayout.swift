import SwiftUI

/// Answer space depends on the viewport, never on the current question's length.
/// The answer area stays put while the question and monster share the space above it.
struct QuizBattleLayoutMetrics {
    let availableHeight: CGFloat
    let isPad: Bool
    var reservedFooterHeight: CGFloat = 0

    var answerHeight: CGFloat {
        let fourAnswerHeight: CGFloat = isPad ? 352 : 276
        return min(fourAnswerHeight, availableHeight * 0.46)
    }

    var monsterSize: CGFloat {
        let maximumSize: CGFloat = isPad ? 190 : 160
        let minimumSize: CGFloat = reservedFooterHeight > 0 ? 88 : 116
        let readingHeight = availableHeight - reservedFooterHeight
        return min(maximumSize, max(minimumSize, (readingHeight - 440) * 0.5))
    }

    var questionMaximumHeight: CGFloat {
        min(isPad ? 260 : 210, max(88, availableHeight * 0.28))
    }
}

/// Keeps short questions compact while allowing long questions to use the available space.
struct QuizQuestionHeightLayout: Layout {
    let maximumHeight: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let naturalHeight = subviews.first?.sizeThatFits(.init(width: width, height: nil)).height ?? 88
        let availableHeight = proposal.height ?? maximumHeight
        return CGSize(width: width, height: min(max(88, naturalHeight), maximumHeight, availableHeight))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.last?.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: .init(width: bounds.width, height: bounds.height)
        )
    }
}

/// Reset only the scroll position between questions, preserving answer feedback state.
struct QuizAnswerScrollView<Content: View>: View {
    let questionIndex: Int
    @ViewBuilder var content: Content

    private let topID = "quiz.answers.top"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 0).id(topID)
                    content
                }
            }
            .onChange(of: questionIndex) { _ in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
        }
    }
}
