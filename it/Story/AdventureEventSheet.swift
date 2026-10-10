import SwiftUI

struct AdventureEventSheet: View {
    @ObservedObject var store: AdventureStore
    @State private var route: AdventurePresentation
    var coinBalance = 0
    var defaults: UserDefaults = .standard
    var avatarName = "ネッキー"
    var mapStyle: AdventureMapStyle = .illustrated
    var onBattleStart: () -> Void = {}
    var onChapterTwoStart: () -> Void = {}
    var onMapAction: (AdventureMapCommand.Action) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss
#if DEBUG
    @State private var showsDebugStoryRestartConfirmation = false
#endif

    init(store: AdventureStore, initialPresentation: AdventurePresentation,
         coinBalance: Int = 0, defaults: UserDefaults = .standard, avatarName: String = "ネッキー",
         mapStyle: AdventureMapStyle = .illustrated,
         onBattleStart: @escaping () -> Void = {},
         onChapterTwoStart: @escaping () -> Void = {},
         onMapAction: @escaping (AdventureMapCommand.Action) -> Void = { _ in }) {
        self.store = store
        _route = State(initialValue: initialPresentation)
        self.coinBalance = coinBalance
        self.defaults = defaults
        self.avatarName = avatarName
        self.mapStyle = mapStyle
        self.onBattleStart = onBattleStart
        self.onChapterTwoStart = onChapterTwoStart
        self.onMapAction = onMapAction
    }

    private var isBattleRoute: Bool { route.id == "battle" }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: isBattleRoute ? 14 : 17) { content }
                        .padding(.horizontal, isBattleRoute ? 8 : 24).padding(.top, 10).padding(.bottom, 28)
                        .frame(maxWidth: 520).frame(maxWidth: .infinity)
                }
                .onChange(of: store.progress.battle?.selectedAnswer) { answer in
                    if answer != nil { withAnimation { proxy.scrollTo("adventure.feedback", anchor: .bottom) } }
                }
            }
            .foregroundColor(AdventurePalette.ink)
            .background {
                // 戦闘中は学習モードの問題演習画面と同じ「明るい背景＋白いカード」にする
                if isBattleRoute {
                    Image("StoryForestBackground").resizable().ignoresSafeArea()
                } else {
                    AdventurePalette.paper.ignoresSafeArea()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isBattleRoute {
                        Button("中断") { close() }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("fontGray"))
                            .accessibilityIdentifier("adventure.event.close")
                    } else {
                        Button("閉じる") { close() }
                            .foregroundColor(AdventurePalette.muted).accessibilityIdentifier("adventure.event.close")
                    }
                }
            }
        }
        .onChange(of: store.presentation?.id) { _ in
            guard let presentation = store.presentation else { return }
            // Keep the encounter visible while this sheet closes. Battle UI
            // belongs only to the full-screen cover presented after dismissal.
            if case .battle = presentation { return }
            route = presentation
        }
    }

    @ViewBuilder private var content: some View {
        switch route {
        case .battle: battleContent
        case .world: worldContent
        case .inventory: inventoryContent
        case .menu: menuContent
        case .journal: journalContent
        case .defeat:
            eventHero("THE MARK REMAINS", title: "1コマ戻った。", kind: store.progress.currentNode.kind, nodeID: store.progress.currentNodeID)
            message("モンスターに敗れ、直前のコマへ戻った。\n手に入れた宝物や、進んできた道の記録は残っている。")
            AdventurePrimaryButton("冒険をつづける") { close() }
        case .treasure(let id):
            eventHero("TREASURE FOUND", title: "\(AdventureWorld.node(id)?.name ?? "宝箱")を見つけた！", kind: .treasure, nodeID: id)
            message(AdventureWorld.node(id)?.detail ?? "宝箱を見つけた。")
            AdventurePrimaryButton("宝箱を開ける", symbol: "sparkles") { store.openTreasure() }
                .accessibilityIdentifier("adventure.treasure.open")
        case .reward(let id):
            let grantsPotion = AdventureWorld.treasureGrantsPotion(id)
            eventHero("A LITTLE DISCOVERY", title: "お宝を手に入れた！", kind: .treasure, completed: true, nodeID: id)
            rewardBox("\(AdventureWorld.node(id)?.coins ?? 0) コイン\(grantsPotion ? "\n冒険用の回復薬 × 1" : "")")
            message(grantsPotion ? "コインはホームでも使えます。\n回復薬は、この冒険のもちものです。" : "コインはホームでも使えます。")
            AdventurePrimaryButton("冒険をつづける", symbol: "checkmark") { close() }
        case .victory(let id):
            eventHero(id == 9 ? "THE DAY MOVES ON" : "VICTORY", title: id == 9 ? "森に、夕方が来た。" : "道を切りひらいた！", kind: id == 9 ? .shrine : .treasure, completed: true)
            message(id == 9 ? "繰り返していた朝が終わり、森の日が傾いた。\n港町へ続く道が、見えるようになった。" : "学んだことが、冒険の力になった。\nこの先には、何が待っているだろう。")
            rewardBox("\(AdventureWorld.node(id)?.coins ?? 0) コイン獲得\(id == 9 ? "\n森に明日を取り戻した！" : "")")
            AdventurePrimaryButton(id == 9 ? "港町を目指そう" : "冒険をつづける") { close() }
        case .encounter(let id): encounterContent(AdventureWorld.node(id) ?? AdventureWorld.nodes[0])
        }
    }

    private var menuContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("冒険メニュー").font(.system(size: 25, weight: .bold, design: .serif))
            VStack(alignment: .leading, spacing: 9) {
                Text("第1章 · クエスト").font(.system(size: 11, weight: .semibold)).foregroundColor(AdventurePalette.muted)
                Text(store.progress.hasForestLight ? "森に夕方が来た！" : "繰り返す朝を終わらせよう")
                    .font(.system(size: 18, weight: .bold))
                Text(store.progress.hasForestLight ? "開かれた道を進んで、潮風の港町へ" : "森の主に今日を届けて、港町への道をひらく")
                    .font(.system(size: 13)).foregroundColor(AdventurePalette.muted)
                Text("探索済み \(store.progress.clearedNodeIDs.count) / \(AdventureWorld.nodes.count)")
                    .font(.system(size: 12, weight: .semibold)).monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(18)
            .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 12) {
                Image(avatarName).resizable().scaledToFit().frame(width: 38, height: 42)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lv.\(store.progress.playerStats?.level ?? 1) · \(avatarName)").font(.system(size: 12, weight: .semibold))
                    HStack {
                        Text("HP \(store.progress.hp) / \(store.progress.maximumHP)")
                        Spacer()
                        Label(coinBalance.formatted(), systemImage: "circle.fill")
                            .accessibilityLabel("所持コイン \(coinBalance)")
                    }
                    .font(.system(size: 12)).monospacedDigit().foregroundColor(AdventurePalette.muted)
                    AdventureHPBar(value: store.progress.hp, maximum: store.progress.maximumHP)
                }
            }

            playerStatsSummary

            VStack(spacing: 8) {
                menuRow("旅の物語", symbol: "book.closed", id: "adventure.journal") { store.presentation = .journal }
                menuRow("もちもの", symbol: "backpack", id: "adventure.inventory") { store.presentation = .inventory }
                menuRow("世界地図", symbol: "globe.asia.australia", id: "adventure.world") { store.presentation = .world }
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("地図の操作").font(.system(size: 13, weight: .semibold))
                HStack(spacing: 8) {
                    mapMenuButton("縮小", symbol: "minus", action: .zoomOut, id: "adventure.map.zoomOut")
                    mapMenuButton("拡大", symbol: "plus", action: .zoomIn, id: "adventure.map.zoomIn")
                    mapMenuButton(mapStyle == .storybook ? "画面に広げる" : "全体", symbol: "arrow.up.left.and.arrow.down.right", action: .overview, id: "adventure.map.overview")
                    mapMenuButton("現在地", symbol: "location.fill", action: .locate, id: "adventure.map.locate")
                }
                Text("地図を指で広げて拡大、ドラッグで移動できます。")
                    .font(.system(size: 11)).foregroundColor(AdventurePalette.muted)
            }
            if !store.isPreview && !store.progress.pendingRewardIDs.isEmpty {
                Button { store.syncRewards() } label: {
                    Label(store.isDeliveringRewards ? "コイン報酬を受取中…" : "保管中のコイン報酬を受け取る", systemImage: "tray.and.arrow.down")
                        .font(.system(size: 13)).frame(minHeight: 44)
                }
                .disabled(store.isDeliveringRewards).accessibilityIdentifier("adventure.claimRewards")
            }
#if DEBUG
            debugStoryRestartButton
#endif
        }
        .padding(.top, 4)
    }

#if DEBUG
    private var debugStoryRestartButton: some View {
        Button {
            showsDebugStoryRestartConfirmation = true
        } label: {
            Label("ストーリーを最初から開始", systemImage: "arrow.counterclockwise")
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(Color.red)
                .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 13))
                .overlay {
                    RoundedRectangle(cornerRadius: 13)
                        .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("adventure.debug.restartStory")
        .confirmationDialog("ストーリーを最初から開始しますか？", isPresented: $showsDebugStoryRestartConfirmation,
                            titleVisibility: .visible) {
            Button("最初から開始", role: .destructive) {
                store.restartStoryFromBeginningForDebug()
                close()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("このユーザーのストーリーモードの進行だけを初期化します。クイズ成績、コイン、所持品は変わりません。")
        }
    }
#endif

    private var playerStatsSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let error = store.playerStatsLoadError {
                Text(error).font(.caption).foregroundColor(AdventurePalette.muted)
                Button("読み込みをやり直す") { store.loadPlayerStats() }
            } else if !store.hasLoadedPlayerStats {
                Text("レベルとオトモを読み込み中…").font(.caption)
            }
            Text("Lv.\(store.progress.playerStats?.level ?? 1) · \(store.progress.playerStats?.companionName ?? "オトモ未選択")").font(.headline)
            Text("HP \(store.progress.hp) / \(store.progress.maximumHP)　攻撃 \(store.progress.playerAttack)")
                .font(.subheadline).monospacedDigit()
            if let stats = store.progress.playerStats {
                Text("最大HP：レベル分 \(stats.baseHP) ＋ オトモ \(stats.companionHP)\n攻撃：レベル分 \(stats.baseAttack) ＋ オトモ \(stats.companionAttack)")
                    .font(.caption).foregroundColor(AdventurePalette.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
        .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 13))
    }

    private func menuRow(_ title: String, symbol: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol).frame(width: 24)
                Text(title).fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundColor(AdventurePalette.muted)
            }
            .font(.system(size: 15)).padding(16)
            .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain).disabled(store.isMoving).accessibilityIdentifier(id)
    }

    private var journalContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("旅の物語").font(.system(size: 28, weight: .bold, design: .serif))
            Text("第1章 · はじまりの森").font(.subheadline).foregroundColor(AdventurePalette.muted)
            Text("おともとたどった物語を、もう一度。\n新しい場面は、冒険を進めると開きます。")
                .font(.subheadline).lineSpacing(4).foregroundColor(AdventurePalette.muted)
            ForEach(AdventureStoryScene.journalScenes) { scene in
                let unlocked = scene.isUnlocked(in: store.progress)
                Button { store.replayStory(scene) } label: {
                    HStack(spacing: 14) {
                        Text(String(format: "%02d", scene.number))
                            .font(.system(size: 23, weight: .medium, design: .serif))
                            .foregroundColor(AdventurePalette.muted).frame(width: 34)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(unlocked ? scene.title : "まだ見ぬ物語").font(.headline)
                            Text(unlocked ? scene.location : "冒険を進めると開放")
                                .font(.caption).foregroundColor(AdventurePalette.muted)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: unlocked ? "play.circle" : "lock.fill")
                            .font(.system(size: 21)).foregroundColor(AdventurePalette.leaf)
                    }
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                    .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain).disabled(!unlocked || store.progress.battle != nil)
                .accessibilityIdentifier("adventure.story.replay.\(scene.id)")
            }
            if store.progress.battle != nil {
                Text("会話は戦闘が終わってから読み返せます。")
                    .font(.footnote).foregroundColor(AdventurePalette.muted)
            }
        }
    }

    private func mapMenuButton(_ title: String, symbol: String, action: AdventureMapCommand.Action, id: String) -> some View {
        Button {
            onMapAction(action)
            close()
        } label: {
            VStack(spacing: 7) {
                Image(systemName: symbol).font(.system(size: 17, weight: .semibold))
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain).disabled(store.isMoving).accessibilityIdentifier(id)
    }

    @ViewBuilder private func encounterContent(_ node: AdventureNode) -> some View {
        switch node.kind {
        case .monster, .boss:
            eventHero(node.kind == .boss ? "GUARDIAN OF THE FOREST" : "MONSTER ENCOUNTER", title: "\(node.name)が現れた！", kind: node.kind, nodeID: node.id)
            message(node.kind == .boss ? "森の主は、同じ朝をやり直し続けている。\n外から持ってきた言葉で、今日を届けよう。" : "正解すると攻撃、間違えると反撃。\nオトモと力を合わせて、道を切りひらこう。")
            rewardBox("敵のHP \(node.enemyHP) · 攻撃 \(node.enemyAttack)\n勝利報酬　\(node.coins) コイン")
            playerStatsSummary
            courseSummary
            AdventurePrimaryButton("クイズで戦う", symbol: "bolt.shield.fill") {
                store.startBattle()
                guard store.progress.battle != nil else { return }
                onBattleStart()
            }
                .disabled(!store.hasLoadedPlayerStats || store.progress.hp == 0)
                .accessibilityIdentifier("adventure.battle.start")
            Button("いったん引き返す") { store.retreat(); dismiss() }.foregroundColor(AdventurePalette.muted)
        case .camp:
            eventHero("A MOMENT OF REST", title: node.name, kind: .camp, nodeID: node.id)
            message(node.id == 4 ? "「北の橋を渡るには、古い祠の鍵がいる」\n旅人が、道の先を教えてくれた。" : node.detail)
            AdventurePrimaryButton("ありがとう、行ってくる") { close() }
        case .shrine:
            eventHero("AN ANCIENT SECRET", title: "祠に眠る、森の鍵。", kind: .shrine)
            message("石碑を読むと、封印が静かにほどけた。\nこの鍵があれば、北の橋を渡れそうだ。")
            rewardBox("古代の鍵 × 1")
            AdventurePrimaryButton("鍵を受け取る", symbol: "key.fill") { store.takeKey(); dismiss() }
                .accessibilityIdentifier("adventure.key.claim")
        case .bridge:
            eventHero("A NEW PATH OPENS", title: "森の奥へ、道が開いた。", kind: .bridge, completed: true)
            message("古代の鍵が光り、橋の封印が消えた。\nこの先で、森の主が待っている。")
            AdventurePrimaryButton("橋の向こうへ") { close() }
        case .port:
            eventHero("CHAPTER 01 COMPLETE", title: "冒険は、まだつづく。", kind: .port)
            message("森を抜けると、潮風が頬をなでた。\n船の向こうには、まだ知らない世界。")
            rewardBox("第1章「はじまりの森」クリア")
            AdventurePrimaryButton("第2章 · 潮風の群島へ", symbol: "sailboat.fill") { onChapterTwoStart() }
                .accessibilityIdentifier("chapter02.open")
            AdventurePrimaryButton("世界地図を見る", symbol: "globe.asia.australia") { store.presentation = .world }
            Button("森をもう少し探索する") { close() }.foregroundColor(AdventurePalette.muted)
        case .road:
            eventHero(node.id == 1 ? "THE ADVENTURE BEGINS" : "FOREST PATH",
                      title: node.id == 1 ? "道は、ひとつじゃない。" : node.name,
                      kind: .road, nodeID: node.id)
            message(node.id == 1 ? "木陰には、きらりと光る宝箱。\n東の道には、見慣れないモンスター。\nどちらから進もう？" : node.detail)
            AdventurePrimaryButton("冒険をつづける") { close() }
        default:
            eventHero("HOME SWEET HOME", title: "出発の村", kind: .village)
            message("「おかえり。旅は順調かな？」\n村のみんなが、あなたを待っている。")
            playerStatsSummary
            AdventurePrimaryButton("休んでHPを全回復", symbol: "heart.fill") { store.rest(); close() }
                .disabled(!store.hasLoadedPlayerStats)
                .accessibilityIdentifier("adventure.rest")
            AdventurePrimaryButton("冒険に戻る") { close() }
        }
    }

    // 学習モードの問題演習画面(QuizView)と同じ構成:
    // 問題カード → モンスター → HPバー → 選択肢 → 解説
    @ViewBuilder private var battleContent: some View {
        if let battle = store.progress.battle, let question = battle.currentQuestion,
           let node = AdventureWorld.node(battle.nodeID) {
            QuestionCardView(
                question: question.question,
                selectedAnswerIndex: battle.selectedAnswer,
                correctAnswerIndex: question.correctAnswerIndex
            )
            .padding(.horizontal, 8)

            AdventureIllustration(kind: node.kind, nodeID: node.id)
                .frame(width: isSmallDevice() ? 110 : 160, height: isSmallDevice() ? 100 : 145)
                .shadow(radius: 10)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    hpPill(node.name)
                    ProgressBar3(value: Double(battle.enemyHP), maxValue: Double(max(1, battle.maximumEnemyHP)),
                                 color: Color("hpMonsterColor"))
                        .frame(height: 20)
                    hpPill("\(battle.enemyHP)/\(battle.maximumEnemyHP)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(node.name)のHP \(battle.enemyHP) / \(battle.maximumEnemyHP)")

                HStack(spacing: 10) {
                    Image(avatarName).resizable().scaledToFit().frame(width: 30, height: 30)
                        .accessibilityHidden(true)
                    ProgressBar3(value: Double(store.progress.hp), maxValue: Double(store.progress.maximumHP), color: Color("hpUserColor"))
                        .frame(height: 20)
                    hpPill("\(store.progress.hp)/\(store.progress.maximumHP)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("あなたのHP \(store.progress.hp) / \(store.progress.maximumHP)")
            }
            .padding(.horizontal, 8)

            AnswerSelectionView(
                choices: question.choices,
                correctAnswerIndex: battle.selectedAnswer != nil ? question.correctAnswerIndex : nil
            ) { index in
                store.answer(index)
            }
            .shadow(radius: 1)

            if let correct = battle.wasCorrect {
                quizCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text(correct ? "正解！ \(store.progress.playerAttack)ダメージ！" : "惜しい！ \(battle.attack)ダメージを受けた")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(correct ? Color(hex: "11998e") : Color(hex: "f5576c"))
                        Text(question.explanation)
                            .font(.system(size: 14))
                            .foregroundColor(Color("fontGray"))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)

                if let interjection = guardianInterjection(for: battle) {
                    quizCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(interjection.speaker)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AdventurePalette.leaf)
                            Text(interjection.text)
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(Color("fontGray"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }

                quizPrimaryButton(
                    store.progress.hp == 0 ? "1コマ戻る" : battle.enemyHP == 0 ? "勝利！ 報酬を見る" : "次の問題へ",
                    symbol: store.progress.hp == 0 ? "arrow.uturn.backward" : battle.enemyHP == 0 ? "sparkles" : "arrow.right"
                ) { store.nextQuestion() }
                    .padding(.horizontal, 8)
                    .accessibilityIdentifier("adventure.battle.next").id("adventure.feedback")
            }
        }
    }

    /// HPバーの両脇に置く、学習モードと同じ黒半透明のピル
    private func hpPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .monospacedDigit()
            .lineLimit(1)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.5))
            .cornerRadius(30)
    }

    /// 学習モードの問題カードと同じ、白い角丸カード
    private func quizCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
            )
            .padding(.horizontal, 8)
    }

    /// 学習モードの一時停止モーダルと同じグラデーションのボタン
    private func quizPrimaryButton(_ title: String, symbol: String,
                                   action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 14, weight: .bold))
                Text(title).font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func guardianInterjection(for battle: AdventureBattle) -> (speaker: String, text: String)? {
        guard battle.nodeID == 9, battle.selectedAnswer != nil else { return nil }
        guard battle.wasCorrect == true else {
            return ("森の主", "知らない言葉。……知らないものは、この朝に要らない。")
        }
        switch battle.guardianReaction {
        case 2:
            return ("森の主", "待って。今の一行、私の日誌のどこにも無い……。")
        case 1:
            return (avatarName, "そうだよ、きのうには無かった言葉だ。今日にしか無いんだ！")
        case 0:
            return ("森の主", "栞が……外れる。次のページが、めくれてしまう……。")
        default:
            return nil
        }
    }

    private func answerButton(_ question: AdventureQuestion, index: Int, battle: AdventureBattle) -> some View {
        let answered = battle.selectedAnswer != nil
        let correct = answered && index == question.correctAnswerIndex
        let wrong = answered && index == battle.selectedAnswer && !correct
        return Button { store.answer(index) } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(String(UnicodeScalar(65 + index) ?? "A")).font(.system(size: 11, weight: .bold))
                    .frame(width: 24, height: 25).background(AdventurePalette.line, in: RoundedRectangle(cornerRadius: 6))
                Text(question.choices[index]).font(.system(size: 14)).frame(maxWidth: .infinity, alignment: .leading).fixedSize(horizontal: false, vertical: true)
                if correct { Image(systemName: "checkmark.circle.fill").foregroundColor(AdventurePalette.leaf) }
                else if wrong { Image(systemName: "xmark.circle.fill").foregroundColor(.red.opacity(0.75)) }
            }
            .padding(13).frame(minHeight: 50).foregroundColor(AdventurePalette.ink)
            .background(correct ? AdventurePalette.leaf.opacity(0.17) : wrong ? Color.red.opacity(0.09) : AdventurePalette.paper, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(correct ? AdventurePalette.leaf : wrong ? Color.red.opacity(0.5) : AdventurePalette.line))
        }
        .buttonStyle(.plain).disabled(answered).accessibilityIdentifier("adventure.answer.\(index)")
    }

    private var worldContent: some View {
        VStack(spacing: 19) {
            eyebrow("WORLD MAP")
            Text("忘却の大陸").font(.system(size: 29, weight: .bold, design: .serif))
            message("六つの土地をめぐる、長い旅。")
            worldRow("はじまりの森", symbol: "leaf.fill", status: store.progress.isChapterComplete ? "踏破" : "探索中")
            worldRow("潮風の群島", symbol: "sailboat.fill", status: chapterTwoStatus)
            worldRow("砂に埋もれた遺跡", symbol: "building.columns.fill", status: "未開放")
            worldRow("歯車の山脈", symbol: "mountain.2.fill", status: "未開放")
            worldRow("商人たちの王都", symbol: "building.2.fill", status: "未開放")
            worldRow("封印の雪原", symbol: "snowflake", status: "未開放")
            if store.progress.isChapterComplete {
                AdventurePrimaryButton("第2章 · 潮風の群島へ", symbol: "sailboat.fill") { onChapterTwoStart() }
                    .accessibilityIdentifier("chapter02.open")
            }
            AdventurePrimaryButton("はじまりの森へ戻る") { close() }
        }
    }

    private var chapterTwoStatus: String {
        guard store.progress.isChapterComplete else { return "未開放" }
        guard let chapter = try? ChapterTwoSaveRepository(defaults: defaults, accountID: store.accountID).load() else {
            return "記録を確認"
        }
        if chapter.isComplete { return "踏破" }
        return chapter.stageIndex == 0 ? "冒険へ" : "冒険中"
    }

    private var inventoryContent: some View {
        VStack(spacing: 18) {
            eyebrow("YOUR INVENTORY")
            Text("旅のもちもの").font(.system(size: 27, weight: .bold, design: .serif))
            worldRow("冒険用の回復薬", symbol: "cross.case.fill", status: "\(store.progress.potions) 個")
            AdventurePrimaryButton("回復薬を使う · HP＋\(store.progress.potionHealing)", symbol: "heart.fill") { store.usePotion() }
                .disabled(store.progress.potions == 0 || store.progress.hp == store.progress.maximumHP || store.progress.battle != nil)
            worldRow("古代の鍵", symbol: "key.fill", status: store.progress.hasKey ? "入手済み" : "未入手")
            Divider()
            courseSummary
            Text("この旅で獲得したコイン　\(store.progress.earnedCoins)").font(.system(size: 13))
            if let message = store.rewardMessage { Text(message).font(.system(size: 12)).foregroundColor(AdventurePalette.muted).multilineTextAlignment(.center) }
            Text("冒険の記録は、この端末に自動保存されます。").font(.system(size: 11)).foregroundColor(AdventurePalette.muted)
        }
    }

    private var courseSummary: some View {
        Label("第1エリアの出題：ITパスポート", systemImage: "book.closed.fill")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(AdventurePalette.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier("adventure.course.fixed")
    }
    private func worldRow(_ title: String, symbol: String, status: String) -> some View {
        HStack(spacing: 12) { Image(systemName: symbol).frame(width: 23); Text(title).fontWeight(.semibold); Spacer(); Text(status).font(.system(size: 11)).foregroundColor(AdventurePalette.muted) }
            .font(.system(size: 13)).padding(15).background(AdventurePalette.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
    private func eventHero(_ kicker: String, title: String, kind: AdventureNodeKind, completed: Bool = false, nodeID: Int? = nil) -> some View {
        VStack(spacing: 13) {
            eyebrow(kicker)
            AdventureIllustration(kind: kind, completed: completed, nodeID: nodeID).frame(width: 145, height: 135)
                .background(AdventurePalette.grass.opacity(0.6), in: Circle())
            Text(title).font(.system(size: 25, weight: .bold, design: .serif)).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
    }
    private func eyebrow(_ text: String) -> some View { Text(text).font(.system(size: 10, weight: .bold)).tracking(1.8).foregroundColor(AdventurePalette.muted) }
    private func message(_ text: String) -> some View { Text(text).font(.system(size: 13)).lineSpacing(6).multilineTextAlignment(.center).foregroundColor(AdventurePalette.muted).fixedSize(horizontal: false, vertical: true) }
    private func rewardBox(_ text: String) -> some View { Text(text).font(.system(size: 15, weight: .semibold)).multilineTextAlignment(.center).lineSpacing(7).frame(maxWidth: .infinity).padding(17).background(AdventurePalette.line.opacity(0.5), in: RoundedRectangle(cornerRadius: 13)) }
    private func close() { store.presentation = nil; dismiss() }
}

/// The story encounter uses the same quiz components as learning mode, but it
/// owns the entire screen so the map never competes with the question or the
/// answer feedback.
struct AdventureBattleView: View {
    @ObservedObject var store: AdventureStore
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var connectivity = ConnectivityMonitor.shared
    @StateObject private var interstitial = Interstitial()
    private let adPresenter = AdViewControllerRepresentable()
    let avatarName: String
    let onSuspend: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isExplanationPresented = false
    @State private var explanationSelection: Int?
    @State private var isResolvingAnswer = false
    @State private var isAttackEffectVisible = false
    @State private var attackEffectIsCorrect = false
    // 学習モードと同じ: 不正解の攻撃を受けたら画面をうっすら赤くし、次の問題まで残す
    @State private var showsIncorrectTint = false
    @State private var showsDefeatMark = false
    @State private var isFinishingBattle = false

    var body: some View {
        Group {
            if let battle = store.progress.battle,
               let question = battle.currentQuestion,
               let node = AdventureWorld.node(battle.nodeID) {
                battleScreen(battle: battle, question: question, node: node)
            } else {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onAppear { dismiss() }
            }
        }
        .preferredColorScheme(.light)
        .disabled(isFinishingBattle)
        .background { adPresenter.frame(width: .zero, height: .zero) }
        .onAppear { preloadBattleAd() }
        .onChange(of: appState.shouldShowAds) { _ in preloadBattleAd() }
        .onChange(of: connectivity.isConnected) { _ in preloadBattleAd() }
    }

    private func battleScreen(battle: AdventureBattle, question: AdventureQuestion,
                              node: AdventureNode) -> some View {
        ZStack {
            Color.clear
                .onAppear { syncExplanationStateIfNeeded(battle: battle) }
            // GeometryReader owns the background's dimensions. The image is
            // cropped inside that fixed viewport, so its aspect ratio can
            // never enlarge the ZStack or the quiz content.
            GeometryReader { backgroundGeometry in
                Image("StoryBattleBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: backgroundGeometry.size.width,
                           height: backgroundGeometry.size.height)
                    .clipped()
            }
                .ignoresSafeArea()
            Color.black.opacity(0.28)
                .ignoresSafeArea()
            Color.red.opacity(showsIncorrectTint ? 0.1 : 0)
                .ignoresSafeArea()

            GeometryReader { geometry in
                let contentWidth = min(max(geometry.size.width - 32, 0), 620)
                ScrollView {
                    VStack(spacing: 16) {
                            battleHeader(node: node, battle: battle)
                                .frame(width: contentWidth)

                            // These are the same shared components used by the
                            // learning-mode exercise screen.
                            QuestionCardView(
                                question: question.question,
                                selectedAnswerIndex: battle.selectedAnswer,
                                correctAnswerIndex: question.correctAnswerIndex
                            )
                            .frame(width: contentWidth)

                            enemySection(node: node, battle: battle)
                                .frame(width: contentWidth)
                            playerHealth
                                .frame(width: contentWidth)

                            AnswerSelectionView(
                                choices: question.choices,
                                correctAnswerIndex: battle.selectedAnswer == nil && !isResolvingAnswer
                                    ? nil
                                    : question.correctAnswerIndex
                            ) { index in
                                presentExplanation(afterSelecting: index)
                            }
                            .frame(width: contentWidth)
                            .accessibilityIdentifier("adventure.battle.answers")
                    }
                    // A flexible max width can adopt its 620pt ideal size
                    // inside a ScrollView and be clipped on phones. Use the
                    // viewport's exact width so no content can escape either edge.
                    .frame(width: contentWidth)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }

            if isExplanationPresented,
               let selectedIndex = explanationSelection,
               question.choices.indices.contains(selectedIndex) {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()

                AdventureBattleExplanationModal(
                    isCorrect: battle.wasCorrect == true,
                    question: question.question,
                    userAnswer: question.choices[selectedIndex],
                    correctAnswer: question.choices[question.correctAnswerIndex],
                    explanation: question.explanation,
                    guardianInterjection: guardianInterjection(for: battle),
                    nextTitle: nextTitle(battle),
                    nextSymbol: nextSymbol(battle),
                    onNext: advanceBattleAfterExplanation
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .accessibilityIdentifier("adventure.battle.explanation")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExplanationPresented)
    }

    /// 中断した瞬間、回答済みだが解説モーダルを開く前だった場合、再開後の
    /// 新しい画面インスタンスにはその演出状態が残っていない。保存されている
    /// battle.selectedAnswer だけが残り、解説モーダルが二度と開かず画面が
    /// 固まって見えるので、再開時にすぐ解説を出して先へ進めるようにする。
    private func syncExplanationStateIfNeeded(battle: AdventureBattle) {
        guard !isFinishingBattle, battle.selectedAnswer != nil,
              !isExplanationPresented, !isResolvingAnswer else { return }
        isAttackEffectVisible = false
        showsIncorrectTint = false
        showsDefeatMark = false
        explanationSelection = battle.selectedAnswer
        isExplanationPresented = true
    }

    private func presentExplanation(afterSelecting index: Int) {
        guard !isResolvingAnswer,
              let battle = store.progress.battle,
              battle.selectedAnswer == nil,
              let question = battle.currentQuestion,
              question.choices.indices.contains(index) else { return }

        // Keep the same cadence as learning mode: show the selected answer,
        // begin the attack after 0.5 seconds, then open the explanation only
        // after that attack has had time to play.
        isResolvingAnswer = true
        let isCorrect = index == question.correctAnswerIndex
        attackEffectIsCorrect = isCorrect
        if isCorrect {
            AudioManager.shared.playCorrectSound()
        } else {
            AudioManager.shared.playUnCorrectSound()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard isResolvingAnswer else { return }
            if isCorrect {
                AudioManager.shared.playAttackSound()
            } else {
                AudioManager.shared.playMonsterAttackSound()
            }
            store.answer(index, playsFeedbackSound: false)
            guard store.progress.battle?.selectedAnswer == index else {
                isResolvingAnswer = false
                return
            }

            withAnimation(.easeOut(duration: 0.16)) {
                isAttackEffectVisible = true
                if !isCorrect { showsIncorrectTint = true }
            }

            // 学習モードと同じく、敵を倒したら0.5秒後に「倒す」を出す
            if isCorrect, store.progress.battle?.enemyHP == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AudioManager.shared.playDownSound()
                    withAnimation(.easeOut(duration: 0.16)) { showsDefeatMark = true }
                }
            }

            let effectDuration = isCorrect ? 1.0 : 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + effectDuration) {
                explanationSelection = index
                isExplanationPresented = true
                isResolvingAnswer = false
            }
        }
    }

    private func advanceBattleAfterExplanation() {
        guard !isFinishingBattle, let battle = store.progress.battle,
              battle.selectedAnswer != nil else { return }
        let battleEnded = store.progress.hp == 0 || battle.enemyHP == 0
        if battleEnded { isFinishingBattle = true }
        isExplanationPresented = false
        explanationSelection = nil
        isAttackEffectVisible = false
        showsIncorrectTint = false
        showsDefeatMark = false
        isResolvingAnswer = false
        // Dismiss the overlay before the battle state advances, so the modal
        // always describes the answer the player just selected.
        DispatchQueue.main.async {
            if battleEnded {
                self.interstitial.presentAfterStoryBattle(
                    isPreview: self.store.isPreview,
                    surface: "story_adventure_chapter01",
                    from: self.adPresenter.viewController
                ) {
                    DispatchQueue.main.async { self.store.nextQuestion() }
                }
            } else {
                self.store.nextQuestion()
            }
        }
    }

    private func preloadBattleAd() {
        guard !isFinishingBattle, store.progress.battle != nil else { return }
        interstitial.preloadStoryBattleAd(isPreview: store.isPreview)
    }

    private func battleHeader(node: AdventureNode, battle: AdventureBattle) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("STORY BATTLE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundColor(.white.opacity(0.84))
                Text("\(node.name) · 攻撃\(battle.attack)")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Text("QUESTION \(battle.questionIndex + 1) / \(battle.questions.count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.82))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
            Spacer(minLength: 0)
            Button {
                onSuspend()
                dismiss()
            } label: {
                Label("中断", systemImage: "pause.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("fontGray"))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.96), in: Capsule())
            }
            .fixedSize(horizontal: true, vertical: false)
            .buttonStyle(ScaleButtonStyle())
            .accessibilityIdentifier("adventure.battle.suspend")
        }
        .padding(.top, 4)
    }

    private func enemySection(node: AdventureNode, battle: AdventureBattle) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.28))
                    .frame(width: isSmallDevice() ? 118 : 150, height: isSmallDevice() ? 118 : 150)
                    .blur(radius: 1)
                AdventureIllustration(kind: node.kind, nodeID: node.id)
                    .frame(width: isSmallDevice() ? 124 : 165, height: isSmallDevice() ? 116 : 150)
                    .shadow(color: .black.opacity(0.32), radius: 10, y: 6)
            }
            // エフェクトは overlay で重ねる。ZStack の子にすると画像の大きさで
            // レイアウトが広がり、HPバーや選択肢が動いてしまう。
            .overlay {
                ZStack {
                    if isAttackEffectVisible && attackEffectIsCorrect {
                        // 学習モードと同じ、味方の攻撃エフェクト
                        Image("attack1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: isSmallDevice() ? 80 : 130)
                            .transition(.scale.combined(with: .opacity))
                    }
                    if showsDefeatMark {
                        Image("倒す")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            VStack(spacing: 5) {
                HStack(spacing: 8) {
                    healthPill(node.name)
                    Spacer(minLength: 8)
                    healthPill("\(battle.enemyHP)/\(battle.maximumEnemyHP)", reserving: "\(battle.maximumEnemyHP)/\(battle.maximumEnemyHP)")
                }
                ProgressBar3(value: Double(battle.enemyHP), maxValue: Double(max(1, battle.maximumEnemyHP)),
                             color: Color("hpMonsterColor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(node.name)のHP \(battle.enemyHP) / \(battle.maximumEnemyHP)")
    }

    private var playerHealth: some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Image(avatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)
                Text("Lv.\(store.progress.playerStats?.level ?? 1) · 攻撃\(store.progress.playerAttack)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer(minLength: 8)
                healthPill("\(store.progress.hp)/\(store.progress.maximumHP)", reserving: "\(store.progress.maximumHP)/\(store.progress.maximumHP)")
            }
            ProgressBar3(value: Double(store.progress.hp), maxValue: Double(store.progress.maximumHP), color: Color("hpUserColor"))
                .frame(maxWidth: .infinity)
                .frame(height: 20)
        }
        // 学習モードと同じ、HPバーの上に重なる敵の攻撃エフェクト。
        // overlay なので表示されてもレイアウトは変わらない。
        .overlay {
            if isAttackEffectVisible && !attackEffectIsCorrect {
                Image("beginnerMonsterAttack1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .offset(y: 15)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("あなたのHP \(store.progress.hp) / \(store.progress.maximumHP)")
    }

    /// `reserving` に最大値の文字列を渡すと、その幅を確保して HP が減っても幅が変わらない
    private func healthPill(_ text: String, reserving template: String? = nil) -> some View {
        ZStack(alignment: .trailing) {
            if let template { Text(template).hidden() }
            Text(text)
        }
            .font(.system(size: 13, weight: .bold))
            .monospacedDigit()
            .lineLimit(1)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(.black.opacity(0.5), in: Capsule())
    }

    private func nextTitle(_ battle: AdventureBattle) -> String {
        if store.progress.hp == 0 { return "1コマ戻る" }
        if battle.enemyHP == 0 { return "勝利！ 報酬を見る" }
        return "次の問題へ"
    }

    private func nextSymbol(_ battle: AdventureBattle) -> String {
        if store.progress.hp == 0 { return "arrow.uturn.backward" }
        return battle.enemyHP == 0 ? "sparkles" : "arrow.right"
    }

    private func guardianInterjection(for battle: AdventureBattle) -> (speaker: String, text: String)? {
        guard battle.nodeID == 9, battle.selectedAnswer != nil else { return nil }
        guard battle.wasCorrect == true else {
            return ("森の主", "知らない言葉。……知らないものは、この朝に要らない。")
        }
        switch battle.guardianReaction {
        case 2:
            return ("森の主", "待って。今の一行、私の日誌のどこにも無い……。")
        case 1:
            return (avatarName, "そうだよ、きのうには無かった言葉だ。今日にしか無いんだ！")
        case 0:
            return ("森の主", "栞が……外れる。次のページが、めくれてしまう……。")
        default:
            return nil
        }
    }
}

/// Story battles use this dedicated modal so their explanation flow matches
/// learning mode while continuing the current AdventureBattle after dismissal.
private struct AdventureBattleExplanationModal: View {
    let isCorrect: Bool
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let explanation: String
    let guardianInterjection: (speaker: String, text: String)?
    let nextTitle: String
    let nextSymbol: String
    let onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 27, weight: .bold))
                                .foregroundColor(isCorrect ? .red : .blue)
                            Text(isCorrect ? "正解" : "不正解")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color("fontGray"))
                            Spacer(minLength: 0)
                        }

                        explanationSection("問題内容", text: question)
                        explanationSection("あなたの回答", text: userAnswer)
                        explanationSection("正解", text: correctAnswer)
                        explanationSection("解説", text: explanation)

                        if let guardianInterjection {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(guardianInterjection.speaker)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AdventurePalette.leaf)
                                Text(guardianInterjection.text)
                                    .font(.system(size: 15, weight: .medium, design: .serif))
                                    .foregroundColor(Color("fontGray"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .background(AdventurePalette.line.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                        }

                        Button(action: proceed) {
                            Label(nextTitle, systemImage: nextSymbol)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                                   startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityIdentifier("adventure.battle.next")
                    }
                    .padding(20)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                .frame(minHeight: geometry.size.height)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func explanationSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(.gray)
                    .frame(width: 8, height: 20)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("fontGray"))
            }
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color("fontGray"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func proceed() {
        generateHapticFeedback()
        onNext()
    }
}
