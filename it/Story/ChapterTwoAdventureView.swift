import SwiftUI
import Combine

@MainActor
final class ChapterTwoStore: ObservableObject {
    @Published private(set) var progress = ChapterTwoProgress()
    @Published private(set) var loadError: String?
    private let repository: ChapterTwoSaveRepository
    private let accountID: String
    let isPreview: Bool

    init(accountID: String, defaults: UserDefaults = .standard, isPreview: Bool = false) {
        repository = ChapterTwoSaveRepository(defaults: defaults, accountID: accountID)
        self.accountID = accountID
        self.isPreview = isPreview
        reload()
    }

    func reload() {
        do {
            progress = try repository.load()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func save() {
        do { try repository.save(progress) }
        catch { loadError = "第2章の記録を保存できませんでした。画面を閉じずに、もう一度お試しください。" }
    }

    func advanceScene() { if progress.advanceScene() { save() } }
    func previousPage() { if progress.previousPage() { save() } }
    func skipScene() { if progress.skipScene() { save() } }
    func rest() { if progress.rest() { save() } }

    func startBattle() {
        let questions = isPreview ? AdventureQuizBank.preview : AdventureQuizBank.questions(for: .itPassport).shuffled()
        if progress.startBattle(questions: Array(questions.prefix(20))) { save() }
    }

    func answer(_ index: Int) {
        let question = progress.battle?.currentQuestion
        guard let correct = progress.answer(index) else { return }
        save()
        if correct { AudioManager.shared.playCorrectSound() }
        else { AudioManager.shared.playUnCorrectSound() }
        guard !isPreview, AuthManager.shared.currentUserId == accountID else { return }
        AuthManager.shared.recordAnswer(isCorrect: correct)
        if !correct, let question {
            let level = AdventureQuizBank.level(for: .itPassport)
            let answer = IncorrectAnswer(userId: accountID, quizQuestion: question.question, choices: question.choices,
                                         correctAnswerIndex: question.correctAnswerIndex, explanation: question.explanation,
                                         sourceQuizLevel: level.description)
            _ = LocalIncorrectAnswerStore.save(answer, quizLevel: level)
        }
    }

    func advanceBattle() {
        switch progress.advanceBattle() {
        case .victory: AudioManager.shared.playGameClearSound()
        case .question, .defeat, .unavailable: break
        }
        save()
    }
}

struct ChapterTwoAdventureView: View {
    @StateObject private var store: ChapterTwoStore
    @StateObject private var interstitial = Interstitial()
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var connectivity = ConnectivityMonitor.shared
    private let adPresenter = AdViewControllerRepresentable()
    let avatarName: String
    @Environment(\.dismiss) private var dismiss
    @State private var isJournalPresented = false
    @State private var replayScene: ChapterTwoScene?
    @State private var replayPage = 0
    @State private var isFinishingBattle = false

    private let deepSea = Color(red: 0.04, green: 0.17, blue: 0.28)
    private let sea = Color(red: 0.11, green: 0.39, blue: 0.48)
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.88)

    init(accountID: String, avatarName: String, isPreview: Bool = false, defaults: UserDefaults = .standard) {
        _store = StateObject(wrappedValue: ChapterTwoStore(accountID: accountID, defaults: defaults, isPreview: isPreview))
        self.avatarName = avatarName
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if let error = store.loadError {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed").font(.system(size: 42))
                    Text(error).multilineTextAlignment(.center)
                    Button("読み込みをやり直す") { store.reload() }
                        .buttonStyle(ChapterTwoActionStyle())
                }
                .foregroundColor(cream).padding(30).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let scene = replayScene ?? store.progress.scene {
                dialogue(scene: scene, page: replayScene == nil ? store.progress.page : replayPage)
            } else if let encounter = store.progress.encounter {
                battle(encounter: encounter)
            } else {
                ending
            }
        }
        .background {
            LinearGradient(colors: [deepSea, sea, deepSea], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isJournalPresented) { journal }
        .disabled(isFinishingBattle)
        .background { adPresenter.frame(width: .zero, height: .zero) }
        .onAppear { preloadBattleAd() }
        .onChange(of: store.progress.battle != nil) { _ in preloadBattleAd() }
        .onChange(of: appState.shouldShowAds) { _ in preloadBattleAd() }
        .onChange(of: connectivity.isConnected) { _ in preloadBattleAd() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").frame(width: 44, height: 44)
            }
            .accessibilityLabel("森の地図に戻る")
            VStack(alignment: .leading, spacing: 2) {
                Text("STORY QUEST · CHAPTER 02")
                    .font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundColor(cream.opacity(0.7))
                Text("潮風の群島").font(.system(size: 21, weight: .bold, design: .serif))
            }
            Spacer()
            Button { isJournalPresented = true } label: {
                Image(systemName: "map.fill").frame(width: 44, height: 44)
            }
            .accessibilityLabel("航路と旅の記録")
            .accessibilityIdentifier("chapter02.journal")
        }
        .buttonStyle(.plain).foregroundColor(cream)
        .padding(.horizontal, 10).padding(.vertical, 8)
    }

    private func dialogue(scene: ChapterTwoScene, page: Int) -> some View {
        let line = scene.lines[page]
        let replaying = replayScene != nil
        return GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scene.location).font(.caption).foregroundColor(cream.opacity(0.72))
                            Text(scene.title).font(.system(.title, design: .serif, weight: .bold))
                                .foregroundColor(cream)
                        }
                        Spacer()
                        Text("\(scene.number) / \(ChapterTwoScene.allCases.count)")
                            .font(.caption.monospacedDigit()).foregroundColor(cream.opacity(0.75))
                    }
                    .padding(.horizontal, 20)

                    ZStack {
                        Ellipse().fill(Color.cyan.opacity(0.15))
                            .frame(width: 280, height: 70).blur(radius: 20).offset(y: 65)
                        Image(systemName: scene.symbol)
                            .resizable().scaledToFit().foregroundStyle(cream)
                            .frame(width: 100, height: 100).offset(x: 80, y: -15)
                            .shadow(color: .black.opacity(0.35), radius: 14)
                        Image(avatarName).resizable().scaledToFit()
                            .frame(width: 140, height: 150).offset(x: -76, y: 28)
                            .shadow(color: .black.opacity(0.4), radius: 12)
                    }
                    .frame(maxWidth: .infinity, minHeight: min(220, geometry.size.height * 0.31))
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(line.speaker.name(companion: avatarName))
                                .font(.headline).foregroundColor(deepSea)
                            Spacer()
                            Text("\(page + 1) / \(scene.lines.count)")
                                .font(.caption.monospacedDigit()).foregroundColor(.gray)
                        }
                        Rectangle().fill(deepSea.opacity(0.14)).frame(height: 1)
                        Text(line.text)
                            .font(.system(.body, design: .serif, weight: .medium))
                            .lineSpacing(7).foregroundColor(deepSea)
                            .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("chapter02.dialogue")
                        HStack(spacing: 10) {
                            Button {
                                if replaying { replayPage = max(0, replayPage - 1) }
                                else { store.previousPage() }
                            } label: {
                                Image(systemName: "arrow.left").frame(width: 48, height: 48)
                            }
                            .disabled(page == 0).opacity(page == 0 ? 0.35 : 1)
                            .accessibilityLabel("前のセリフ")
                            Spacer()
                            Button {
                                if replaying {
                                    if replayPage + 1 < scene.lines.count { replayPage += 1 }
                                    else { replayScene = nil }
                                } else {
                                    store.advanceScene()
                                }
                            } label: {
                                Label(page + 1 == scene.lines.count ? (replaying ? "旅の記録に戻る" : "次の場面へ") : "つづきを読む",
                                      systemImage: "arrow.right")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(minHeight: 48).padding(.horizontal, 17)
                                    .foregroundColor(cream).background(deepSea, in: Capsule())
                            }
                            .accessibilityIdentifier("chapter02.next")
                        }
                        .buttonStyle(.plain).foregroundColor(deepSea)
                    }
                    .padding(22)
                    .background(cream, in: RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 16)

                    Button(replaying ? "読み返しを閉じる" : "この場面をスキップ") {
                        if replaying { replayScene = nil }
                        else { store.skipScene() }
                    }
                    .font(.caption).foregroundColor(cream.opacity(0.82))
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("chapter02.skip")
                }
                .frame(maxWidth: 620).frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
    }

    private func battle(encounter: ChapterTwoEncounter) -> some View {
        ScrollView {
            VStack(spacing: 19) {
                Text(encounter == .guardian ? "中央灯台" : encounter == .kelp ? "貝殻の浜" : "潮の洞窟")
                    .font(.caption).foregroundColor(cream.opacity(0.75))
                Image(systemName: encounter.symbol)
                    .resizable().scaledToFit().foregroundStyle(cream)
                    .frame(width: 90, height: 90).padding(26)
                    .background(.white.opacity(0.12), in: Circle())
                    .accessibilityHidden(true)
                Text(encounter.title).font(.system(.title, design: .serif, weight: .bold)).foregroundColor(cream)
                if let battle = store.progress.battle, let question = battle.currentQuestion {
                    HStack(spacing: 12) {
                        Label("HP \(store.progress.hp)/100", systemImage: "heart.fill")
                        Spacer()
                        Label("敵 \(battle.enemyHP)/\(encounter.hp)", systemImage: "bolt.fill")
                    }
                    .font(.subheadline.weight(.semibold)).foregroundColor(cream)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.question).font(.headline).foregroundColor(deepSea)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(question.choices.indices, id: \.self) { index in
                            Button { store.answer(index) } label: {
                                HStack(alignment: .top, spacing: 10) {
                                    Text(String(UnicodeScalar(65 + index) ?? "A"))
                                        .font(.caption.bold()).frame(width: 20)
                                    Text(question.choices[index])
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if battle.selectedAnswer != nil && index == question.correctAnswerIndex {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    }
                                }
                                .font(.subheadline).foregroundColor(deepSea)
                                .padding(13).frame(maxWidth: .infinity, alignment: .leading)
                                .background(deepSea.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain).disabled(battle.selectedAnswer != nil)
                            .accessibilityIdentifier("chapter02.answer.\(index)")
                        }
                        if let correct = battle.wasCorrect {
                            Text(correct ? "正解！　30ダメージ" : "惜しい！　\(encounter.attack)ダメージを受けた")
                                .font(.subheadline.bold()).foregroundColor(correct ? .green : .red)
                            Text(question.explanation).font(.subheadline).foregroundColor(deepSea)
                            Button(store.progress.hp == 0 ? "もう一度挑戦" : battle.enemyHP == 0 ? "先へ進む" : "次の問題へ") {
                                advanceBattleAfterExplanation()
                            }
                            .buttonStyle(ChapterTwoActionStyle())
                            .accessibilityIdentifier("chapter02.battle.next")
                        }
                    }
                    .padding(20).background(cream, in: RoundedRectangle(cornerRadius: 20))
                } else {
                    Text(encounter == .guardian ? "絡まった光をほどき、返事を届けよう。" : "クイズで魔物を退け、中継灯を取り戻そう。")
                        .multilineTextAlignment(.center).foregroundColor(cream)
                    Text("HP \(store.progress.hp) / 100")
                        .font(.subheadline.monospacedDigit()).foregroundColor(cream)
                    if store.progress.hp < 100 {
                        Button("船で休んでHPを全回復") { store.rest() }
                            .buttonStyle(ChapterTwoActionStyle())
                    }
                    Button("クイズで戦う") { store.startBattle() }
                        .buttonStyle(ChapterTwoActionStyle())
                        .accessibilityIdentifier("chapter02.battle.start")
                }
            }
            .frame(maxWidth: 520).frame(maxWidth: .infinity)
            .padding(24)
        }
    }

    private func preloadBattleAd() {
        guard !isFinishingBattle, store.progress.battle != nil else { return }
        interstitial.preloadStoryBattleAd(isPreview: store.isPreview)
    }

    private func advanceBattleAfterExplanation() {
        guard !isFinishingBattle, let battle = store.progress.battle,
              battle.selectedAnswer != nil else { return }
        guard store.progress.hp == 0 || battle.enemyHP == 0 else {
            store.advanceBattle()
            return
        }
        isFinishingBattle = true
        interstitial.presentAfterStoryBattle(
            isPreview: store.isPreview,
            surface: "story_adventure_chapter02",
            from: adPresenter.viewController
        ) {
            DispatchQueue.main.async {
                self.store.advanceBattle()
                self.isFinishingBattle = false
            }
        }
    }

    private var ending: some View {
        VStack(spacing: 22) {
            Image(systemName: "light.beacon.max.fill")
                .font(.system(size: 76)).foregroundColor(cream)
            Text("第2章 完了")
                .font(.system(.largeTitle, design: .serif, weight: .bold)).foregroundColor(cream)
            Text("潮風の群島に、返事の光が戻った。")
                .foregroundColor(cream).multilineTextAlignment(.center)
            Button("旅の記録を読む") { isJournalPresented = true }
                .buttonStyle(ChapterTwoActionStyle())
            Button("森の地図に戻る") { dismiss() }
                .foregroundColor(cream).frame(minHeight: 48)
        }
        .padding(28).frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var journal: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("潮風の群島をめぐる航路")
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .padding(.bottom, 8)
                    ForEach(ChapterTwoStage.all.indices, id: \.self) { index in
                        let stage = ChapterTwoStage.all[index]
                        if case .scene(let scene) = stage {
                            let unlocked = index < store.progress.stageIndex || store.progress.isComplete
                            Button {
                                guard unlocked else { return }
                                replayScene = scene
                                replayPage = 0
                                isJournalPresented = false
                            } label: {
                                HStack(spacing: 13) {
                                    Image(systemName: scene.symbol).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(scene.title).fontWeight(.semibold)
                                        Text(scene.location).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: unlocked ? "book.closed" : "lock.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(14).background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 13))
                            }
                            .buttonStyle(.plain).disabled(!unlocked)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("旅の記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                Button("閉じる") { isJournalPresented = false }
            } }
        }
        .preferredColorScheme(.light)
    }
}

private struct ChapterTwoActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(Color(red: 0.04, green: 0.17, blue: 0.28))
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, 16)
            .background(Color(red: 0.98, green: 0.96, blue: 0.88), in: RoundedRectangle(cornerRadius: 13))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
