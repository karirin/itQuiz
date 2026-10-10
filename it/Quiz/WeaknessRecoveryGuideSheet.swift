import SwiftUI

/// "しくみ": how problem review, theme learning and focused training work, and what is free.
struct WeaknessRecoveryGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("学び方は2つ。進み具合はそれぞれ別に記録され、毎日のおすすめはアプリが選びます。")
                        .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    block(icon: "arrow.counterclockwise", tint: .review, title: "まちがえた問題の解き直し",
                          lead: "クイズでまちがえた問題を、日を空けてもう一度解きます。",
                          example: "「DNSの役割」の問題をまちがえた → 翌日、同じ問題がここに届く",
                          steps: [.init(title: "翌日に解き直す"),
                                  .init(title: "正解から3日後にもう一度"),
                                  .init(title: "正解から7日後にもう一度", detail: "ホームでは「あと1回で克服」と表示"),
                                  .init(title: "克服！", detail: "克服図鑑の「克服した問題」に記録", isGoal: true)],
                          free: "1日\(ReviewAccessPolicy.dailyFreeLimit)問まで。ホームの「今日の復習」と共通です",
                          premium: "問題数の制限なし")
                    block(icon: "book", tint: .theme, title: "テーマを学ぶ",
                          lead: "ITパスポートの10テーマから選び、説明を読んで理解してから練習します。",
                          example: "RAMとROM、DNSの役割、暗号の使い分け、損益分岐点 など",
                          steps: [.init(title: "説明を読む"),
                                  .init(title: "3問を練習"),
                                  .init(title: "翌日：おさらい 2問", detail: "別の問題で、覚えているか確かめます"),
                                  .init(title: "全問正解から3日後：もう一度おさらい"),
                                  .init(title: "マスター！", detail: "克服図鑑の「マスターしたテーマ」に記録", isGoal: true)],
                          free: "最初に始めた1テーマを、おさらい・再練習まで。解き直しの\(ReviewAccessPolicy.dailyFreeLimit)問とは別です",
                          premium: "全10テーマ")
                    RecoveryCard {
                        blockTitle(icon: "scope", tint: .premium, title: "分野を選んで集中特訓")
                        Text("正解率の低い分野を選ぶと、今日解き直せる問題のうち、その分野の問題だけをまとめて出題します。")
                            .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        Label("プレミアムで利用できます", systemImage: "crown.fill")
                            .font(.subheadline.bold()).foregroundStyle(RecoveryTint.premium.tagText)
                    }
                }
                .padding(16)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(RecoveryStyle.background)
            .navigationTitle("苦手克服のしくみ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("閉じる") { dismiss() } }
            }
        }
        .presentationDetents([.large])
    }

    private func blockTitle(icon: String, tint: RecoveryTint, title: String) -> some View {
        HStack(spacing: 10) {
            RecoveryIconTile(symbol: icon, tint: tint, size: 36)
            Text(title).font(.headline).foregroundStyle(RecoveryStyle.text)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private func block(icon: String, tint: RecoveryTint, title: String, lead: String, example: String,
                       steps: [RecoveryVerticalSteps.Step], free: String, premium: String) -> some View {
        RecoveryCard {
            blockTitle(icon: icon, tint: tint, title: title)
            Text(lead).font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            (Text("例　").bold() + Text(example))
                .font(.caption).foregroundStyle(RecoveryStyle.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "F1F5FB"), in: RoundedRectangle(cornerRadius: 12))
            RecoveryVerticalSteps(steps: steps, tint: tint)
            Divider()
            planRow(icon: "ticket", label: "無料", text: free, tint: RecoveryTint.review.tagText)
            planRow(icon: "crown", label: "プレミアム", text: premium, tint: RecoveryTint.premium.tagText)
        }
    }

    private func planRow(icon: String, label: String, text: String, tint: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: icon).foregroundStyle(tint).accessibilityHidden(true)
            (Text(label).bold() + Text("　") + Text(text))
                .foregroundStyle(RecoveryStyle.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption)
    }
}
