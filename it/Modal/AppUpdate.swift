import Foundation

struct AppUpdate: Identifiable {
    struct Feature: Identifiable {
        let id: String
        let symbol: String
        let title: String
        let message: String
        var notice: String? = nil
    }

    let id: String
    let version: String
    let title: String
    let introduction: String
    let features: [Feature]

    // 公開済みのお知らせは残し、新しい更新を先頭に追加する。
    // 公開日が決まるまでは、案内に日付を表示しない。
    static let history: [AppUpdate] = [
        AppUpdate(
            id: "10.12-adventure-dungeon-gacha-recovery",
            version: "10.12",
            title: "新しい冒険・ガチャが登場！",
            introduction: "いつも遊んでいただきありがとうございます。今回のアップデートで追加したコンテンツと、準備中の機能をご紹介します。",
            features: [
                Feature(
                    id: "story", symbol: "map.fill", title: "ストーリーモードが登場！",
                    message: "おともと一緒に、第1章「はじまりの森」を冒険しよう！宝箱やモンスターが待つ世界を、クイズを解きながら探索できます。",
                    notice: "第2章は現在準備中です。続きの物語をお楽しみに！"
                ),
                Feature(
                    id: "dungeon", symbol: "flag.checkered", title: "ダンジョンを300階まで拡張！",
                    message: "151〜300階に新たなエリアを追加。新しいモンスターや3体の大ボスに、学んだ知識で挑みましょう！"
                ),
                Feature(
                    id: "gacha", symbol: "sparkles", title: "新しいガチャを追加！",
                    message: "「四聖獣ガチャ」と「深海ガチャ」が登場！新しいおともを仲間にして、冒険をさらに楽しもう！"
                ),
                Feature(
                    id: "recovery", symbol: "checkmark.seal.fill", title: "苦手克服モードを準備中",
                    message: "ITパスポートの苦手なテーマを、説明・練習問題・日を空けたおさらいで学べるモードを準備しています。",
                    notice: "公開まで、もうしばらくお待ちください。"
                )
            ]
        )
    ]

    static var latest: AppUpdate { history[0] }
}

enum AppUpdateReadState {
    static let storageKey = "appUpdates.readIDs.v1"
    static let automaticPresentationKey = "appUpdates.lastAutomaticallyPresentedID.v1"

    static func contains(_ id: String, in data: Data) -> Bool {
        ids(in: data).contains(id)
    }

    static func markingRead(_ id: String, in data: Data) -> Data {
        let updated = Set(ids(in: data)).union([id]).sorted()
        return (try? JSONEncoder().encode(updated)) ?? data
    }

    private static func ids(in data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
