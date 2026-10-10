#if DEBUG
import SwiftUI

/// 設定内の確認入口。閉じて開き直すたびに、新しいプレビューの状態を使う。
struct DebugInitialLearningSettings: View {
    @State private var isPresented = false
    @State private var sessionID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("初回ユーザーの体験", systemImage: "play.rectangle.fill")
                .font(.system(size: 16, weight: .semibold))
            Text("案内 → 3問 → 学習結果 → 名前登録 → 翌日の通知設定を、何度でも確認できます。")
                .font(.subheadline).foregroundStyle(.secondary)
            Button {
                sessionID = UUID()
                isPresented = true
            } label: {
                Label("初回体験を確認", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("settings.debug.initialLearning")
            Text("確認中は学習記録・報酬・通知の送信を行いません。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .fullScreenCover(isPresented: $isPresented) {
            InitialLearningPreview(onClose: { isPresented = false })
                .id(sessionID)
        }
    }
}
#endif
