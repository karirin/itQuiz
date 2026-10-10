import Foundation

/// Chapter 2 has its own identifiers so the forest's saved scene values stay stable.
enum ChapterTwoScene: String, Codable, CaseIterable, Identifiable {
    case lighthouse, oldSignal, redSail, shellBeach, pier, cave
    case fog, guardian, rescue, calmNight, reunion, blankPage

    var id: String { rawValue }
    var number: Int { (Self.allCases.firstIndex(of: self) ?? 0) + 1 }

    var title: String {
        switch self {
        case .lighthouse: return "岬の灯台"
        case .oldSignal: return "三年前の声"
        case .redSail: return "赤い帆の船"
        case .shellBeach: return "貝殻の浜"
        case .pier: return "沈みかけた桟橋"
        case .cave: return "潮の洞窟"
        case .fog: return "返事をして"
        case .guardian: return "潮の番人"
        case .rescue: return "いま聞こえる声"
        case .calmNight: return "静かになった夜"
        case .reunion: return "三年越しのただいま"
        case .blankPage: return "消えた一ページ"
        }
    }

    var location: String {
        switch self {
        case .lighthouse, .oldSignal: return "岬の灯台"
        case .redSail, .calmNight, .blankPage: return "潮風の港町"
        case .shellBeach: return "貝殻の浜"
        case .pier: return "古い桟橋"
        case .cave: return "潮の洞窟"
        case .fog: return "霧の浜辺"
        case .guardian: return "中央灯台"
        case .rescue: return "北の岩礁"
        case .reunion: return "森の大樹"
        }
    }

    var symbol: String {
        switch self {
        case .lighthouse, .oldSignal, .guardian: return "light.beacon.max.fill"
        case .redSail, .rescue: return "sailboat.fill"
        case .shellBeach: return "shell.fill"
        case .pier: return "water.waves"
        case .cave: return "mountain.2.fill"
        case .fog: return "cloud.fog.fill"
        case .calmNight: return "moon.stars.fill"
        case .reunion: return "leaf.fill"
        case .blankPage: return "book.closed.fill"
        }
    }

    var lines: [AdventureStoryLine] {
        switch self {
        case .lighthouse:
            return [
                .init(.narrator, "灯台の階段を上ると、一人の青年が大きなレンズを磨いていた。"),
                .init(.companion, "あの……ナギさん？"),
                .init(.character("ナギ"), "そうだけど。灯台を見に来たの？"),
                .init(.companion, "森から来たんだ。シオリさんのことで、話があって。"),
                .init(.narrator, "ナギの手が止まった。"),
                .init(.character("ナギ"), "……シオリが、どうかした？"),
                .init(.companion, "ずっと、きみのことを待ってた。"),
                .init(.character("ナギ"), "生きているって、伝わってなかったのか。"),
                .init(.narrator, "ナギは机の引き出しを開けた。宛先の同じ手紙が、何通も重なっていた。"),
                .init(.character("ナギ"), "森に入ろうとしても、いつも同じ場所に戻ってしまう。手紙も、全部戻ってきた。"),
                .init(.companion, "シオリさんが、森の朝を巻き戻してたんだ。ナギさんが帰ってこなかった日を、もう一度やり直そうとして。"),
                .init(.character("ナギ"), "……僕がここで三年過ごしている間、ずっと？"),
                .init(.narrator, "うなずくと、ナギは磨き布をゆっくり畳んだ。"),
                .init(.character("ナギ"), "帰らないとな。……その前に、ひとつだけ手伝ってほしい。灯台の様子がおかしいんだ。"),
                .init(.narrator, "窓の外で、海に向かって三度、光が走った。")
            ]
        case .oldSignal:
            return [
                .init(.narrator, "日が暮れると、灯台の壁に埋め込まれた貝殻が震えた。"),
                .init(.voice("貝殻の声"), "橋が落ちた。川口の岩にいる。誰か、聞こえますか。"),
                .init(.companion, "誰かが助けを呼んでる！"),
                .init(.character("ナギ"), "……これは、僕の声だ。三年前、川に流されたあと、岩の上から救助船に送った声だよ。"),
                .init(.narrator, "貝殻がもう一度震えた。同じ言葉が、同じ息づかいで流れる。"),
                .init(.character("ナギ"), "群島の灯台は、助けを求める声を島から島へ渡していく。救助が終わったら返事を送る。そうすると光が止まるんだ。"),
                .init(.companion, "でも、ナギさんは助かったよね？"),
                .init(.character("ナギ"), "何度も返事を送った。それでも止まらない。"),
                .init(.narrator, "ナギが航海図を広げた。三つの島と、沖に浮かぶ中央灯台が線で結ばれている。"),
                .init(.character("ナギ"), "嵐のあとから、返事が中央灯台まで届いていないらしい。最近は、昔の声まで次々に流れ始めた。"),
                .init(.companion, "返事を待ってる声が、たまり続けてるんだ。"),
                .init(.character("ナギ"), "中継灯を直しに行ったんだけど、光に集まった魔物がいてね。僕ひとりでは近づけなかった。"),
                .init(.companion, "それなら、ぼくらも行くよ。")
            ]
        case .redSail:
            return [
                .init(.narrator, "翌朝、港では赤い帆の船が出航の準備をしていた。"),
                .init(.character("船乗り"), "灯台守さん！　今日は島へ？"),
                .init(.character("ナギ"), "中継灯の修理だ。そちらは？"),
                .init(.character("船乗り"), "向こうの島へ粉を届ける。夕方までには戻るよ。"),
                .init(.narrator, "船の縁から、小さな子どもが顔を出した。"),
                .init(.character("子ども"), "この帆、きのう染めたんだよ！"),
                .init(.companion, "すごく赤いね。遠くからでも、すぐ分かりそう。"),
                .init(.character("子ども"), "帰ってきたら見つけてね！"),
                .init(.companion, "うん！"),
                .init(.narrator, "赤い帆の船が、朝の海へ出ていった。"),
                .init(.character("ナギ"), "僕たちは、まず貝殻の浜へ行こう。"),
                .init(.narrator, "旅帳に今日の日付を押した。"),
                .init(.companion, "海に押すのは、ちょっと難しそうだね。")
            ]
        case .shellBeach:
            return [
                .init(.narrator, "浜辺には、大きさも色も違う貝殻が並んでいた。その一つ一つから、かすかな声が聞こえる。"),
                .init(.voice("貝殻の声"), "帆が破れた。東の入り江で待っている。"),
                .init(.voice("別の貝殻の声"), "薬を積んだ船が戻らない。見かけた人はいないか。"),
                .init(.companion, "こんなにたくさん……。"),
                .init(.narrator, "浜の奥に、貝殻を磨いている老人がいた。"),
                .init(.character("老人"), "その声なら、覚えているよ。帆が破れたのは、うちの船だ。隣の島の人が迎えに来てくれた。もう十年も前だ。"),
                .init(.companion, "助かったのに、まだ鳴ってるんだね。"),
                .init(.character("ナギ"), "返事の通り道を直してきます。"),
                .init(.character("老人"), "それなら、これも持っていってくれ。"),
                .init(.voice("老人の便り"), "迎えに来てくれて、ありがとう。船は今も使っています。"),
                .init(.companion, "ちゃんと届けるね。"),
                .init(.narrator, "浜の中継灯には、黒い藻のような魔物が絡みついていた。"),
                .init(.companion, "あれが光をふさいでるんだ。行こう！")
            ]
        case .pier:
            return [
                .init(.narrator, "魔物がほどけると、中継灯から細い光が伸びた。沖の灯台が、一度だけまたたいた。"),
                .init(.character("ナギ"), "つながった。ひとつ目だ。"),
                .init(.narrator, "次の島では、古い桟橋が波のたびにきしんでいた。"),
                .init(.companion, "一歩ずつね。いまの板、ちょっと嫌な音がした。"),
                .init(.narrator, "中継灯を調べていると、受信用の貝殻が激しく鳴った。"),
                .init(.voice("貝殻の声"), "赤い帆の船。北の岩礁に座礁。霧で灯台が見えない。"),
                .init(.companion, "赤い帆……。"),
                .init(.character("ナギ"), "方角は北。でも、この声がいつのものか……。"),
                .init(.voice("貝殻の声"), "子どもが一人いる。船底から水が入っている。"),
                .init(.companion, "今朝の船だよ。帆をきのう染めたって、言ってた。"),
                .init(.narrator, "声は途切れ、いくつもの古い声が重なり合った。"),
                .init(.character("ナギ"), "北の岩礁は広い。位置をもう少し聞ければ……。"),
                .init(.companion, "返事をしたら、聞こえるかな。"),
                .init(.narrator, "ナギと桟橋の中継灯を直した。二つ目の光がともる。"),
                .init(.narrator, "ナギが貝殻へ呼びかけた。しかし、こちらの声は沖へ届く前に消えた。"),
                .init(.character("ナギ"), "最後の中継灯までつながないと、呼び返せない。"),
                .init(.companion, "洞窟の灯だね。急ごう。")
            ]
        case .cave:
            return [
                .init(.narrator, "引いた潮の下から、岩に刻まれた道が現れていた。"),
                .init(.character("ナギ"), "僕は船を近くへ回す。灯がつながったら、そのまま中央灯台へ向かおう。"),
                .init(.companion, "分かった。気をつけて。"),
                .init(.narrator, "洞窟の奥へ進むほど、波の音が大きくなった。"),
                .init(.companion, "これ、帰りには水の下なんだよね。……見なかったことにしたい高さだな。"),
                .init(.narrator, "奥の中継灯には、砕けた石が積もっていた。二人で石をどけると、小さな魔物が光を抱えて飛び出してきた。"),
                .init(.companion, "その光、返して！")
            ]
        case .fog:
            return [
                .init(.narrator, "取り戻した光を台座へ戻すと、洞窟の天井に青い道筋が映った。"),
                .init(.voice("子どもの声"), "……だれか……。"),
                .init(.companion, "聞こえてるよ！　いま行くから！"),
                .init(.narrator, "洞窟を出ると、白い霧が浜を覆っていた。数歩先も見えない。"),
                .init(.narrator, "足もとの岩に日付印を押した。振り返ると、おともの姿がなかった。"),
                .init(.companion, "……どこ？　今日の印、見つからないよ。"),
                .init(.narrator, "大きく名前を呼んだ。"),
                .init(.companion, "聞こえた！　もう一回！　そこにいて。動かないでね。"),
                .init(.narrator, "呼ぶたびに、返事が少しずつ近づく。やがて、おともが霧の中から現れた。"),
                .init(.companion, "……よかった。さっき、何回か呼んだんだ。波の音が大きくて、聞こえなかった？"),
                .init(.narrator, "うなずくと、おともは息を吐いた。"),
                .init(.companion, "呼んでも返事がないの、こわかった。あの子も、いま同じ気持ちなのかな。"),
                .init(.narrator, "霧の向こうで、船の鐘が鳴った。"),
                .init(.companion, "ナギさん！　ここにいるよ！"),
                .init(.voice("ナギの声"), "聞こえた！　迎えに行く！")
            ]
        case .guardian:
            return [
                .init(.narrator, "中央灯台の中では、無数の光が渦を巻いていた。一つ一つが、人の声で助けを求めている。"),
                .init(.narrator, "その中心に、巨大な貝殻を背負った番人がいた。"),
                .init(.character("潮の番人"), "近づくな。灯が消える。"),
                .init(.character("ナギ"), "返事を届けに来た。壊れていた三つの中継灯をつないできたんだ。"),
                .init(.character("潮の番人"), "まだ、これだけの者が助けを待っている。"),
                .init(.voice("ナギの古い声"), "橋が落ちた。川口の岩にいる。"),
                .init(.character("ナギ"), "その声は僕だ。僕は助かった。ここにいる。"),
                .init(.character("潮の番人"), "声を止めれば、誰にも見つけてもらえなくなる。"),
                .init(.companion, "でも、いま助けを呼んでる子の声が、聞こえなくなってる！"),
                .init(.character("潮の番人"), "一つも消せない。私は、一つも忘れない。"),
                .init(.narrator, "光が絡まり、返事を受け取る窓を覆った。"),
                .init(.character("ナギ"), "あの窓まで声を通せれば、返事を受け取れるはずだ。"),
                .init(.companion, "分かった。ぼくらが道を開く！")
            ]
        case .rescue:
            return [
                .init(.narrator, "答えを重ねるたび、絡まった光が一本ずつほどけていく。"),
                .init(.character("潮の番人"), "やめろ。その声には、まだ返事が……。"),
                .init(.companion, "あるよ。ちゃんと、持ってきた！"),
                .init(.voice("老人の便り"), "迎えに来てくれて、ありがとう。船は今も使っています。"),
                .init(.narrator, "返事を受け取る窓が開いた。ナギが、その前に立った。"),
                .init(.character("ナギ"), "川口の岩にいたナギです。船に助けてもらいました。僕は、無事です。"),
                .init(.narrator, "三年前の声が止まった。"),
                .init(.character("潮の番人"), "……救助、完了。そうか。もう、待たなくてよかったのか。"),
                .init(.voice("子どもの声"), "赤い帆の船です。だれか、聞こえますか。"),
                .init(.character("ナギ"), "聞こえる。迎えに行く。近くに何が見える？"),
                .init(.voice("子どもの声"), "二つに割れた岩。白い鳥がいっぱいいる。"),
                .init(.character("ナギ"), "双子岩だ！"),
                .init(.character("潮の番人"), "北の航路を照らす。"),
                .init(.narrator, "番人が灯を持ち上げた。霧の中に、一本の明るい道が伸びる。"),
                .init(.narrator, "船は光の道を進み、岩礁の陰に傾いた赤い帆を見つけた。"),
                .init(.character("子ども"), "こっち！"),
                .init(.companion, "見つけた！　約束したもんね！"),
                .init(.narrator, "ロープを渡し、一人ずつ船へ迎える。最後の船乗りが乗り移ると、ナギが舵を切った。"),
                .init(.character("船乗り"), "こちら、赤い帆の船。全員、救助されました。"),
                .init(.character("子ども"), "迎えに来るって声、ちゃんと聞こえた！")
            ]
        case .calmNight:
            return [
                .init(.narrator, "港に戻るころには、空に星が出ていた。"),
                .init(.companion, "静かだね。"),
                .init(.character("ナギ"), "海って、本当はこんな音だったんだな。"),
                .init(.narrator, "桟橋の下で、波が小さく砕けている。"),
                .init(.character("子ども"), "ねえ。また船に乗ってもいい？"),
                .init(.character("船乗り"), "船を直して、天気を確かめてからな。"),
                .init(.character("子ども"), "じゃあ、帆も直す。赤いの、まだ使いたい。"),
                .init(.companion, "うん。あの赤、見つけやすかったよ。"),
                .init(.voice("潮の番人"), "赤い帆の船。救助完了を記録した。"),
                .init(.character("ナギ"), "ありがとう。明日、ほかの返事も届けに行くよ。"),
                .init(.voice("潮の番人"), "待っている。"),
                .init(.narrator, "ナギは貝殻を置き、森の方角を見た。"),
                .init(.character("ナギ"), "僕の返事も、届けないとな。")
            ]
        case .reunion:
            return [
                .init(.narrator, "翌日、ナギと一緒に森の道を歩いた。木々の隙間から、午後の光が差している。"),
                .init(.character("ナギ"), "こんな道だったな。ここを曲がったところに、大きな根があって。"),
                .init(.narrator, "言い終わる前に、ナギが根につまずいた。"),
                .init(.companion, "覚えてても、つまずくんだね。"),
                .init(.character("ナギ"), "……そこまで昔と同じだ。"),
                .init(.narrator, "大樹のそばで、シオリが日誌を書いていた。"),
                .init(.companion, "シオリさん。"),
                .init(.character("シオリ"), "おかえり。海は、どうだった？"),
                .init(.narrator, "ナギが、一歩前へ出た。"),
                .init(.character("ナギ"), "シオリ。"),
                .init(.narrator, "ペンが紙の上で止まった。"),
                .init(.character("シオリ"), "……ナギ？　本当に？"),
                .init(.character("ナギ"), "うん。手紙、届かなくて。何度も帰ろうとしたんだけど。"),
                .init(.character("シオリ"), "……遅いよ。"),
                .init(.character("ナギ"), "うん。ごめん。ただいま。"),
                .init(.character("シオリ"), "おかえり。"),
                .init(.narrator, "旅帳に今日の日付を押した。二人はまだ、三年分の話をしていた。")
            ]
        case .blankPage:
            return [
                .init(.narrator, "数日後。港へ戻ると、灯台にナギからの荷物が届いていた。"),
                .init(.companion, "手紙と……古い航海日誌？"),
                .init(.voice("ナギの手紙"), "世話になった救助船の記録を見つけました。あの嵐の日、僕のほかにも助けられた人がいたようです。"),
                .init(.narrator, "日誌には、船が訪れた港や、その日の天気が細かく記されていた。"),
                .init(.companion, "三年前の嵐の日……ここだ。"),
                .init(.narrator, "その一ページだけが、真っ白だった。"),
                .init(.companion, "破れてない。濡れた跡もない。"),
                .init(.narrator, "前のページには、出航地が書かれている。"),
                .init(.companion, "『砂に埋もれた遺跡』……この船に、誰が乗ってたんだろう。"),
                .init(.narrator, "白いページに栞を挟み、旅帳の隣へしまった。"),
                .init(.companion, "次は、砂の国だね。"),
                .init(.narrator, "港の灯台が光った。少し間を置いて、海の向こうから返事の光が届いた。")
            ]
        }
    }
}

enum ChapterTwoEncounter: String, Codable {
    case kelp, cave, guardian

    var title: String {
        switch self {
        case .kelp: return "黒藻の魔物"
        case .cave: return "光を抱えた魔物"
        case .guardian: return "潮の番人"
        }
    }
    var symbol: String {
        switch self {
        case .kelp: return "leaf.circle.fill"
        case .cave: return "sparkles"
        case .guardian: return "shell.fill"
        }
    }
    var hp: Int { self == .guardian ? 180 : 60 }
    var attack: Int { self == .guardian ? 25 : 20 }
}

enum ChapterTwoStage {
    case scene(ChapterTwoScene)
    case battle(ChapterTwoEncounter)

    static let all: [Self] = [
        .scene(.lighthouse), .scene(.oldSignal), .scene(.redSail),
        .scene(.shellBeach), .battle(.kelp), .scene(.pier),
        .scene(.cave), .battle(.cave), .scene(.fog),
        .scene(.guardian), .battle(.guardian), .scene(.rescue),
        .scene(.calmNight), .scene(.reunion), .scene(.blankPage)
    ]
}
