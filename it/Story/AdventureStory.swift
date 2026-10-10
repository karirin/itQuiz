import Foundation

/// Chapter-one conversations use durable identifiers. Existing raw values are
/// preserved so saves made before the rewritten scenario continue to decode.
enum AdventureStoryScene: String, Codable, CaseIterable, Identifiable {
    case departure
    case entrance
    case firstEncounter
    case shrine
    case keyAcquired
    case bridge
    case guardian
    case guardianVictory
    case port
    case villageReturn

    var id: String { rawValue }
    /// Scenes shown in the journal. `keyAcquired` was folded into the shrine
    /// scene and is kept only so older saves still decode.
    static var journalScenes: [Self] { allCases.filter { $0 != .keyAcquired } }
    var number: Int { (Self.journalScenes.firstIndex(of: self) ?? 0) + 1 }

    var title: String {
        switch self {
        case .departure: return "三日つづきの朝"
        case .entrance: return "元に戻る石"
        case .firstEncounter: return "はじめまして、117回目"
        case .shrine: return "同じページの栞"
        case .keyAcquired: return "あしたの鍵"
        case .bridge: return "毎朝かけ直される橋"
        case .guardian: return "今日はまだ、誰も"
        case .guardianVictory: return "破れたページ"
        case .port: return "三年前の旅人"
        case .villageReturn: return "今日の便り"
        }
    }

    var nodeID: Int {
        switch self {
        case .departure, .villageReturn: return 0
        case .entrance: return 1
        case .firstEncounter: return 3
        case .shrine, .keyAcquired: return 5
        case .bridge: return 8
        case .guardian, .guardianVictory: return 9
        case .port: return 10
        }
    }

    var location: String {
        switch self {
        case .departure: return "出発の村・便り番の机"
        case .villageReturn: return "出発の村"
        case .keyAcquired: return "古い祠"
        case .guardianVictory: return "森の大樹"
        default: return AdventureWorld.node(nodeID)?.name ?? "はじまりの森"
        }
    }

    var artwork: String {
        switch self {
        case .departure, .villageReturn: return "StorySpriteVillage"
        case .entrance: return "StorySpriteForestEntrance"
        case .firstEncounter: return "StorySpriteMossSlime"
        case .shrine, .keyAcquired: return "StorySpriteShrine"
        case .bridge: return "StorySpriteBridge"
        case .guardian, .guardianVictory: return "StorySpriteForestGuardian"
        case .port: return "StorySpritePort"
        }
    }

    var destinationTitle: String {
        switch self {
        case .departure: return "森へ出発する"
        case .entrance: return "森を探索する"
        case .firstEncounter: return "今日をわたす"
        case .shrine: return "祠の鍵を調べる"
        case .keyAcquired: return "鍵を持って進む"
        case .bridge: return "橋の向こうへ"
        case .guardian: return "森の主に届ける"
        case .guardianVictory: return "夕方を見届ける"
        case .port: return "第1章を終える"
        case .villageReturn: return "冒険へ戻る"
        }
    }

    /// True once the player has physically reached this point. This also lets
    /// existing saves read scenes that happened before dialogue was installed.
    func wasReached(in progress: AdventureProgress) -> Bool {
        switch self {
        case .departure:
            return progress.currentNodeID != 0 || progress.clearedNodeIDs.count > 1 || progress.hasKey || progress.hasForestLight
        case .entrance:
            return progress.currentNodeID == 1 || progress.clearedNodeIDs.contains(1)
        case .firstEncounter:
            return progress.currentNodeID == 3 || progress.clearedNodeIDs.contains(3)
        case .shrine:
            return progress.currentNodeID == 5 || progress.clearedNodeIDs.contains(5)
        case .keyAcquired:
            return progress.hasKey
        case .bridge:
            return progress.currentNodeID == 8 || progress.clearedNodeIDs.contains(8)
        case .guardian:
            return progress.currentNodeID == 9 || progress.clearedNodeIDs.contains(9)
        case .guardianVictory:
            return progress.clearedNodeIDs.contains(9)
        case .port:
            return progress.currentNodeID == 10 || progress.clearedNodeIDs.contains(10)
        case .villageReturn:
            return progress.hasForestLight && progress.currentNodeID == 0
        }
    }

    func isUnlocked(in progress: AdventureProgress) -> Bool {
        self == .departure || progress.story?.completed.contains(self) == true || wasReached(in: progress)
    }

    static func arriving(at nodeID: Int) -> Self? {
        switch nodeID {
        case 1: return .entrance
        case 3: return .firstEncounter
        case 5: return .shrine
        case 8: return .bridge
        case 9: return .guardian
        case 10: return .port
        default: return nil
        }
    }

    var lines: [AdventureStoryLine] {
        switch self {
        case .departure:
            return [
                .init(.narrator, "出発の村の朝。便り番のミナが、森から届いた手紙を机に並べていた。"),
                .init(.character("ミナ"), "おはよう。ちょっとこれ、見てくれる？"),
                .init(.character("ミナ"), "森の見張り台から毎朝届く便り。今日の分、きのうの分、おとといの分。"),
                .init(.companion, "……三枚とも、まったく同じ文だ。"),
                .init(.character("ミナ"), "そう。字のにじみ方まで同じなの。三日間、森の時間が止まってるみたい。"),
                .init(.narrator, "森の方を見ると、朝もやが三日前と同じ高さで止まっていた。"),
                .init(.character("ミナ"), "森の奥に古い祠がある。何が起きてるのか、見てきてくれないかな。"),
                .init(.companion, "うん、行ってみる！"),
                .init(.character("ミナ"), "それと、これを持っていって。"),
                .init(.narrator, "ミナが手渡したのは、便りの受け取りに使う日付印。押すと、その日の日付が残る。"),
                .init(.character("ミナ"), "森の中で日にちが分からなくなったら、これを押して。押した日が「今日」だから。"),
                .init(.companion, "なるほど。目印にもなるね。"),
                .init(.companion, "もしはぐれたら、いちばん新しい日付の場所で待ち合わせしよう。"),
                .init(.character("ミナ"), "気をつけてね。"),
                .init(.companion, "じゃあ、行ってくるね。")
            ]

        case .entrance:
            return [
                .init(.narrator, "森に入ると、道ばたに苔むした大きな石が三つ並んでいた。"),
                .init(.companion, "ねえ、見て。さっき足をかけて、ずらしちゃった石。"),
                .init(.narrator, "振り返ると、ずれたはずの石が、苔の跡にぴったり戻っていた。"),
                .init(.companion, "勝手に元の場所に戻ってる……。この森、ずっと「同じ朝」をくり返してるんだ。"),
                .init(.narrator, "いちばん大きな石に、日付印を押した。今日の日付が、くっきり残る。"),
                .init(.companion, "石は戻っても、印は消えてない！"),
                .init(.companion, "この日付印だけは、森に巻き戻されないみたいだね。"),
                .init(.companion, "……べ、別にこわくないからね。先に進もう。")
            ]

        case .firstEncounter:
            return [
                .init(.character("モススライム"), "わあ、旅の人だ！　はじめまして！"),
                .init(.companion, "うん、はじめまして。"),
                .init(.character("モススライム"), "わあ、旅の人だ！　はじめまして！"),
                .init(.companion, "……あれ？　いま、二回言わなかった？"),
                .init(.character("モススライム"), "え？　ぼく、きみたちに会うのは今日がはじめてだよ。"),
                .init(.narrator, "そばの岩に、線が何本も刻まれていた。"),
                .init(.companion, "数えてみるね……百十七本。"),
                .init(.character("モススライム"), "これ、ぼくがつけたのかな。なんの数だろう。"),
                .init(.companion, "きっと、きみが同じ朝をくり返した回数だよ。"),
                .init(.character("モススライム"), "そんなに？　ぼく、今朝のことしか覚えてないのに……。"),
                .init(.companion, "同じ朝をくり返すと、覚えたことも毎朝消えちゃうんだ。"),
                .init(.companion, "でも、森の外から来たぼくらの知識なら、消えないはず。"),
                .init(.companion, "クイズに正解するたびに、この森に「新しいこと」が増えていく。"),
                .init(.companion, "それが、止まった時間を動かすカギになるんだと思う。")
            ]

        case .shrine:
            return [
                .init(.narrator, "祠の中に、森の日誌が開いたまま置かれていた。"),
                .init(.voice("森の日誌"), "『今日、森は無事。旅人はみんな、日暮れまでに橋を渡り終えた。』"),
                .init(.companion, "次のページも同じ文。その次も、その次も……全部同じだ。"),
                .init(.companion, "毎日同じことを書いてる。やっぱりこの森は、同じ一日をくり返してるんだ。"),
                .init(.narrator, "ページをめくっていくと、一枚だけ破り取られた跡があった。"),
                .init(.companion, "ここだけ破られてる。そしてこの次から、同じ文がずっと続いてる。"),
                .init(.companion, "誰かが、この日のことを「なかったこと」にしたんだ。"),
                .init(.companion, "それで、その前の朝をずっとくり返してる……。"),
                .init(.narrator, "破れた跡には栞が挟まっていた。何度も挟み直したのか、端がすり切れている。"),
                .init(.companion, "毎朝この栞を挟み直して、一日を巻き戻してるのは誰なんだろう。"),
                .init(.narrator, "そのとき台座が低く鳴り、石のくぼみから一本の鍵がせり上がってきた。"),
                .init(.voice("鍵の刻印"), "『あしたへ渡る』"),
                .init(.companion, "「あしたへ」……この鍵があれば、橋の先へ進めるかもしれない。")
            ]

        case .keyAcquired:
            // 祠の場面に統合したため再生しない。古い保存データの読み込み用に case だけ残す。
            return []

        case .bridge:
            return [
                .init(.narrator, "谷にかかる橋は、作ったばかりのように真新しかった。"),
                .init(.companion, "新しい橋だ。木のにおいがまだする。"),
                .init(.narrator, "ところが、向こう岸の柵は古びて、ツタに覆われている。"),
                .init(.companion, "こっち側だけ新しいなんて、おかしいよ。"),
                .init(.companion, "もしかして……誰かが毎朝、この橋を作り直してるの？"),
                .init(.voice("森の主の声"), "引き返しなさい。"),
                .init(.companion, "だ、だれ！？"),
                .init(.voice("森の主の声"), "この先へ行けば、今日が終わってしまう。今日はまだ、誰も失っていないのに。"),
                .init(.companion, "「誰も失っていない」……？　この橋で、何かあったんだ。"),
                .init(.narrator, "祠の鍵を差し込むと、橋の板が一斉にきしみ、みるみる古びていった。"),
                .init(.companion, "橋が古くなった……！　止まってた時間が動き出したんだ。"),
                .init(.voice("森の主の声"), "やめて……朝が終わってしまう。")
            ]

        case .guardian:
            return [
                .init(.narrator, "森の奥の大樹の下に、森の主がひざをついていた。胸に栞を抱えている。"),
                .init(.character("森の主"), "来ないで。もう一度、朝からやり直させて。"),
                .init(.companion, "あなたが、毎朝この森を巻き戻してたんだね。"),
                .init(.character("森の主"), "今日のままなら、まだ誰も失わずにすむの。"),
                .init(.companion, "失うって、誰を……？"),
                .init(.narrator, "答えるかわりに、白い霧が足もとから噴き出した。おともの姿が見えなくなる。"),
                .init(.companion, "どこ！？　何も見えないよ！"),
                .init(.narrator, "足もとの岩に、日付印を押した。霧の中で、その印だけが消えずに残る。"),
                .init(.companion, "あった、今日の日付！　いちばん新しい日付の場所で待ち合わせ、だったよね。"),
                .init(.companion, "……ほんとに、ちょっとだけこわかった。"),
                .init(.character("森の主"), "どうして見つけられたの。この森では、何もかも朝に戻るはずなのに。"),
                .init(.companion, "この印は、森の外から持ってきた「今日」だから消えないんだ。"),
                .init(.character("森の主"), "……そんなもの、残ってほしくない。"),
                .init(.companion, "クイズで、この森にもっと新しいことを増やそう。"),
                .init(.companion, "正解するたびに、止まった朝が少しずつ進むはずだよ。")
            ]

        case .guardianVictory:
            return [
                .init(.narrator, "霧が晴れると、森の主の手から栞がすべり落ちた。"),
                .init(.character("森の主"), "……日が、傾いてる。本当に、夕方が来るのね。"),
                .init(.narrator, "森の主は、胸元からしわだらけの紙を取り出した。日誌の、破られたページだ。"),
                .init(.voice("破れたページ"), "『雨。川があふれ、橋が落ちた。旅人ナギ、帰らず。』"),
                .init(.character("森の主"), "あの日、ナギは帰ってこなかった。"),
                .init(.character("森の主"), "だから私は、その日が来る前の朝に巻き戻した。毎朝、橋を作り直して。"),
                .init(.character("森の主"), "同じ朝をくり返せば、ナギを失った日は来ない。そう思っていたの。"),
                .init(.companion, "でも、そのせいで森のみんなは、毎日のことを忘れちゃってたよ。"),
                .init(.character("森の主"), "……わかってた。それでも、明日へ進むのがこわかった。"),
                .init(.narrator, "破れたページを受け取り、余白に日付印を押した。今日の日付が残る。"),
                .init(.companion, "これで、この日のことはちゃんと日誌に残るよ。"),
                .init(.companion, "そうすれば、次のページに新しいことが書けるんだ。"),
                .init(.character("森の主"), "……次のページに、何を書けばいいの？"),
                .init(.companion, "なんでもいいよ。きのうと違うことなら。"),
                .init(.companion, "そういえば、まだ名前を聞いてなかったね。"),
                .init(.character("森の主"), "シオリ。"),
                .init(.narrator, "森に、何百日ぶりかの夕方が来た。")
            ]

        case .port:
            return [
                .init(.narrator, "森を抜けると、潮のにおいと港の灯りが待っていた。"),
                .init(.companion, "海だ……！　地図で見るより、ずっと広い！"),
                .init(.character("港の案内人"), "森から来たのかい？　あの道を通ってきた人は、ずいぶん久しぶりだよ。"),
                .init(.companion, "森の時間が止まってたんだ。でも、もう大丈夫。"),
                .init(.character("港の案内人"), "そうかい。……そういえば三年前、森の川から流されてきた人がいたな。"),
                .init(.character("港の案内人"), "橋ごと川に落ちたらしい。助かって、今は岬の灯台で働いてるよ。"),
                .init(.companion, "その人の名前は？"),
                .init(.character("港の案内人"), "ナギだ。"),
                .init(.companion, "ナギさん、生きてたんだ！　シオリさんに知らせなきゃ！"),
                .init(.narrator, "岬の灯台が光った。ピカ、ピカ、ピカ。そしてまた、ピカ、ピカ、ピカ。"),
                .init(.companion, "あの光……さっきから、ずっと同じリズムでくり返してる。"),
                .init(.companion, "まさか、海でも森と同じことが起きてるのかな……？"),
                .init(.narrator, "第1章『はじまりの森』――完。")
            ]

        case .villageReturn:
            return [
                .init(.narrator, "村に戻ると、ミナが今日の便りを開いていた。"),
                .init(.character("ミナ"), "見て！　今日の便り、きのうと違う文になってる！"),
                .init(.companion, "森の時間が、ちゃんと動き出したんだ。"),
                .init(.character("ミナ"), "おかえり。四日ぶりだね。森で何があったのか、あとで全部聞かせて。"),
                .init(.companion, "長くなるよ。石が勝手に戻るところから話さなきゃ。"),
                .init(.narrator, "旅帳を開き、最後の余白に日付印を押した。"),
                .init(.companion, "明日の便りには、きっとまた新しいことが書いてあるね。"),
                .init(.companion, "次はどこに行こうか。ぼく、海がいいな。")
            ]
        }
    }
}

enum AdventureStorySpeaker {
    case narrator, companion, voice(String), character(String)

    func name(companion: String) -> String {
        switch self {
        case .narrator: return "ものがたり"
        case .companion: return companion
        case .voice(let name), .character(let name): return name
        }
    }

    var isCompanion: Bool { if case .companion = self { return true }; return false }
    var isCharacter: Bool { if case .character = self { return true }; return false }
}

struct AdventureStoryLine {
    let speaker: AdventureStorySpeaker
    let text: String
    init(_ speaker: AdventureStorySpeaker, _ text: String) { self.speaker = speaker; self.text = text }
}

struct AdventureStoryBookmark: Codable, Equatable {
    let scene: AdventureStoryScene
    var page: Int = 0
    var isValid: Bool { scene.lines.indices.contains(page) }
}

struct AdventureStoryProgress: Codable, Equatable {
    var completed: Set<AdventureStoryScene> = []
    var bookmark: AdventureStoryBookmark?
}

struct AdventureStoryPlayback: Identifiable {
    var bookmark: AdventureStoryBookmark
    let isReplay: Bool
    var id: String { bookmark.scene.id }
}
