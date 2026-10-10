import SwiftUI

/// L1〜L4 を並べて見比べるための Preview 専用ギャラリー。
private struct SlimeLoadingGallery: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 20) {
                panel("L1 全画面") {
                    SlimeFullScreenLoadingView()
                }
                panel("L2 進捗ステップ") {
                    SlimeStepsLoadingPreview()
                }
                panel("L3 画面内パーツ") {
                    inlineParts
                }
                panel("L4 読み込み失敗") {
                    SlimeErrorView(retry: {})
                }
            }
            .padding(20)
        }
        .background(Color(white: 0.92))
    }

    private var inlineParts: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                caption("カード（データ取得中）")
                SlimeCardLoadingView(message: "学習記録を読み込み中…")

                caption("リスト（ランキングなど）")
                SlimeSkeletonList(rows: 3)

                caption("ボタン（送信・保存）")
                HStack(spacing: 10) {
                    galleryButton("保存する", isLoading: false)
                    galleryButton("保存する", isLoading: true)
                }

                caption("インライン（行の中）")
                SlimeInlineLoadingView(message: "今日の3問を準備中…")
            }
            .padding(16)
        }
        .background(Color.white)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(SlimeLoadingTheme.body(11))
            .foregroundStyle(SlimeLoadingTheme.subInk)
    }

    private func galleryButton(_ title: String, isLoading: Bool) -> some View {
        Text(title)
            .font(SlimeLoadingTheme.body(15))
            .foregroundStyle(.white)
            .slimeLoading(isLoading: isLoading)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(SlimeLoadingTheme.button, in: Capsule())
    }

    private func panel<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            content()
                .frame(width: 320, height: 640)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview("SlimeLoadingGallery") {
    SlimeLoadingGallery()
}

#if DEBUG
/// 起動引数 `-SlimeLoadingPreview` で表示する実機確認用の画面。左右にスワイプで L1〜L4 を切り替える。
struct SlimeLoadingDebugPreview: View {
    var body: some View {
        TabView {
            SlimeFullScreenLoadingView()
            SlimeStepsLoadingPreview()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SlimeCardLoadingView(message: "学習記録を読み込み中…")
                    SlimeSkeletonList(rows: 3)
                    Text("保存する")
                        .font(SlimeLoadingTheme.body(15))
                        .foregroundStyle(.white)
                        .slimeLoading(isLoading: true)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(SlimeLoadingTheme.button, in: Capsule())
                    SlimeInlineLoadingView(message: "今日の3問を準備中…")
                }
                .padding(20)
            }
            SlimeErrorView(retry: {})
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(SlimeLoadingTheme.background.ignoresSafeArea())
    }
}
#endif
