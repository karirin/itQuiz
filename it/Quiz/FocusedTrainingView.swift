import SwiftUI

/// Field-by-field accuracy, moved here from the recovery home. Viewing is free; starting needs premium.
struct FocusedTrainingView: View {
    let weakAreas: [ReviewWeakArea]
    let subscribed: Bool
    let onStart: (ReviewWeakArea) -> Void
    let onPremium: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    RecoveryTagRow(tags: [.premium])
                    Text("今日の解き直しから、選んだ分野の問題だけを出題します。正解率の低い分野から選ぶのがおすすめです。")
                        .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if weakAreas.isEmpty {
                    RecoveryCard {
                        Text("正解率のデータがまだありません").font(.headline).foregroundStyle(RecoveryStyle.text)
                        Text("問題を解くと、分野ごとの正解率がここに表示されます。通信できないときは表示されません。")
                            .font(.subheadline).foregroundStyle(RecoveryStyle.secondaryText)
                    }
                }
                ForEach(weakAreas) { area in
                    RecoveryCard {
                        accuracyRow(area)
                        if subscribed {
                            Button { onStart(area) } label: {
                                Label("\(area.displayName)を集中特訓", systemImage: "scope")
                            }
                            .buttonStyle(RecoveryOutlineButtonStyle(tint: .review))
                        } else {
                            Button(action: onPremium) {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill")
                                    Text("プレミアムで集中特訓")
                                }
                            }
                            .buttonStyle(RecoveryOutlineButtonStyle(tint: .premium))
                        }
                    }
                }
                if !subscribed && !weakAreas.isEmpty {
                    Text("正解率はいつでも無料で見られます。")
                        .font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                }
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(RecoveryStyle.background)
        .navigationTitle("分野を選んで集中特訓")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func accuracyRow(_ area: ReviewWeakArea) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(area.displayName).font(.headline).foregroundStyle(RecoveryStyle.text)
                Spacer()
                Text("正解率 \(Int(area.accuracy.rounded()))%")
                    .font(.subheadline.bold()).foregroundStyle(accuracyColor(area.accuracy))
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.12))
                    Capsule().fill(accuracyColor(area.accuracy))
                        .frame(width: geometry.size.width * min(max(area.accuracy / 100, 0), 1))
                    Rectangle().fill(RecoveryStyle.text.opacity(0.4))
                        .frame(width: 1, height: 12)
                        .offset(x: geometry.size.width * 0.6)
                }
            }
            .frame(height: 8)
            HStack {
                Spacer()
                Text("合格目安 60%").font(.caption2).foregroundStyle(RecoveryStyle.secondaryText)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(area.displayName)の正解率\(Int(area.accuracy.rounded()))パーセント、合格目安60パーセント")
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy < 50 { return Color(hex: "C53030") }
        if accuracy < 60 { return Color(hex: "B05E00") }
        return RecoveryStyle.done
    }
}
