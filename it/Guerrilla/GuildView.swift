//
//  GuildView.swift
//  it
//
//  ギルド(勉強部屋)のホーム・検索・作成画面です。
//
//  情報設計:
//   1) 未所属は「さがして参加する」「自分で作る」の二択を最初に示す
//   2) 所属後はギルドボスの進捗と「次にやること」を最優先に出す
//   3) ギルド全体の進捗と自分の貢献を分けて見せる
//

import SwiftUI

// MARK: - 入口(所属判定)

struct GuildEntryView: View {
    @ObservedObject var guildManager = GuildManager.shared
    @State private var hasLoaded = false
    @State private var isChecking = true

    var body: some View {
        Group {
            if isChecking && !hasLoaded {
                // 判定中に画面が入れ替わってちらつかないよう、同じ土台の上でプレースホルダーを見せる。
                ScrollView {
                    VStack(spacing: SocialMetrics.stackSpacing) {
                        SocialCompactHeader(
                            theme: .guild,
                            title: "ギルド",
                            subtitle: "定員10人の勉強部屋 · ギルドボスに挑戦",
                            icon: SocialTheme.guild.symbol
                        )
                        SocialSkeletonList(count: 3)
                    }
                    .padding(.horizontal, SocialMetrics.screenPadding)
                    .padding(.top, 12)
                }
                .socialScreen(.guild)
                .navigationBarHidden(true)
            } else if guildManager.myGuildId != nil {
                GuildHomeView()
            } else {
                GuildSearchView()
            }
        }
        .interactiveSwipeBackEnabled()
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            guildManager.fetchMyGuild { isChecking = false }
        }
    }
}

// MARK: - 未所属: 参加する / 自分で作る

struct GuildSearchView: View {
    private enum Mode: String, CaseIterable, Hashable {
        case join = "さがして参加"
        case create = "自分で作る"
    }

    private let theme: SocialTheme = .guild

    @ObservedObject var guildManager = GuildManager.shared
    @State private var mode: Mode = .join
    @State private var isPresentingCreate = false
    @State private var isPresentingHelp = false
    @State private var joiningGuildId: String?
    @State private var hasSearchedOnce = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var inviteCode = ""
    @State private var isJoiningInvite = false

    private var isSignedIn: Bool { AuthManager.shared.currentUserId != nil }

    var body: some View {
        VStack(spacing: 0) {
            SocialCompactHeader(
                theme: theme,
                title: "ギルド",
                subtitle: "定員\(guildManager.maxMembers)人の勉強部屋 · ギルドボスに挑戦",
                icon: theme.symbol
            ) {
                guildHelpButton
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    modeChooser

                    switch mode {
                    case .join: joinSection
                    case .create: createSection
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .refreshable { await reload() }
        }
        .socialScreen(theme)
        .navigationBarHidden(true)
        .onAppear {
            guildManager.searchGuilds { hasSearchedOnce = true }
        }
        .sheet(isPresented: $isPresentingCreate) {
            GuildCreateView()
        }
        .sheet(isPresented: $isPresentingHelp) {
            GuildHelpView()
        }
        .alert(
            "お知らせ",
            isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })
        ) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .socialToast(message: $toastMessage)
    }

    private var guildHelpButton: some View {
        Button {
            isPresentingHelp = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.textAccent)
                .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("ギルドの遊び方")
    }

    private var modeChooser: some View {
        HStack(spacing: 10) {
            modeCard(
                .join,
                icon: "magnifyingglass",
                title: "さがして参加",
                message: "すべてのギルドから選べます"
            )
            modeCard(
                .create,
                icon: "flag.2.crossed.fill",
                title: "自分で作る",
                message: "あなたがリーダーに"
            )
        }
    }

    private func modeCard(_ target: Mode, icon: String, title: String, message: String) -> some View {
        let isSelected = mode == target
        return Button {
            generateHapticFeedback()
            mode = target
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(isSelected ? AnyShapeStyle(theme.gradient) : AnyShapeStyle(theme.softFill))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .white : theme.textAccent)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                Text(message)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .padding(13)
            .background(SocialPalette.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                    .stroke(isSelected ? theme.textAccent : Color.clear, lineWidth: 2)
            )
            .shadow(color: SocialPalette.cardShadow, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func reload() async {
        await withCheckedContinuation { continuation in
            guildManager.searchGuilds {
                hasSearchedOnce = true
                continuation.resume()
            }
        }
    }

    // MARK: - さがして参加

    @ViewBuilder
    private var joinSection: some View {
        inviteJoinCard

        if !isSignedIn {
            SocialErrorState(
                theme: theme,
                title: "ギルドを読み込めませんでした",
                message: "通信状況を確認して、もう一度お試しください。"
            ) {
                guildManager.searchGuilds { hasSearchedOnce = true }
            }
            .socialCard(padding: 0)
        } else if guildManager.isLoading && !hasSearchedOnce {
            SocialSkeletonList(count: 3)
        } else if guildManager.searchResults.isEmpty {
            SocialEmptyState(
                theme: theme,
                icon: "person.3",
                title: "ギルドがありません",
                message: "最初のギルドを作って仲間を集めてみましょう。",
                actionTitle: "ギルドを作る"
            ) {
                mode = .create
            }
            .socialCard(padding: 0)
        } else {
            HStack {
                Text("参加できる \(guildManager.searchResults.filter { $0.memberCount < guildManager.maxMembers }.count)件")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("空きが多い順")
                    .font(.system(size: 11.5))
                    .foregroundColor(.secondary)
            }
            ForEach(guildManager.searchResults) { guild in
                GuildSearchRow(
                    guild: guild,
                    theme: theme,
                    maxMembers: guildManager.maxMembers,
                    isJoining: joiningGuildId == guild.id,
                    onJoin: { join(guild) }
                )
            }
        }
    }

    private var inviteJoinCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "ticket.fill", title: "招待コードで参加")
            HStack(spacing: 8) {
                TextField("6桁のコード", text: $inviteCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .padding(.horizontal, 12)
                    .frame(minHeight: SocialMetrics.tapTarget)
                    .background(SocialPalette.insetSurface)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                    .onChange(of: inviteCode) { value in
                        let normalized = value.uppercased().filter { $0.isLetter || $0.isNumber }
                        inviteCode = String(normalized.prefix(6))
                    }

                SocialGradientButton(
                    theme: theme,
                    title: "参加",
                    icon: "person.badge.plus",
                    isLoading: isJoiningInvite,
                    isDisabled: inviteCode.count != 6
                ) {
                    joinByInviteCode()
                }
                .frame(maxWidth: 118)
            }
        }
        .socialCard()
    }

    private func joinByInviteCode() {
        isJoiningInvite = true
        guildManager.joinGuild(inviteCode: inviteCode) { result in
            isJoiningInvite = false
            switch result {
            case .success:
                toastMessage = "招待されたギルドに参加しました"
                inviteCode = ""
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    private func join(_ guild: GuildSummary) {
        joiningGuildId = guild.id
        guildManager.joinGuild(guildId: guild.id) { result in
            joiningGuildId = nil
            switch result {
            case .success:
                toastMessage = "\(guild.name)に参加しました"
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    // MARK: - 自分で作る

    private var createSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(theme.gradient)
                        .frame(width: 42, height: 42)
                    Image(systemName: "flag.2.crossed.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("自分のギルドを作る")
                        .font(.subheadline.weight(.bold))
                    Text("あなたがリーダーになります")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                bullet(icon: "person.3.fill", text: "定員は\(guildManager.maxMembers)人。すべてのユーザーから仲間を募集できます")
                bullet(icon: "burst.fill", text: "ボス討伐後、ギルド全体で100問正解すると次のボスが出現します")
                bullet(icon: "gift.fill", text: "週間ミッション達成でメンバー全員がコインを受け取れます")
            }

            SocialGradientButton(theme: theme, title: "ギルドを作成する", icon: "plus") {
                isPresentingCreate = true
            }
        }
        .socialCard()
    }

    private func bullet(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.textAccent)
                .frame(width: 18)
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 検索結果1件

private extension GuildRank {
    var colors: [Color] {
        switch self {
        case .beginner: return [Color(hex: "8d99ae"), Color(hex: "5c677d")]
        case .bronze: return [Color(hex: "d1913c"), Color(hex: "8b4513")]
        case .silver: return [Color(hex: "f1f3f5"), Color(hex: "adb5bd")]
        case .gold: return [Color(hex: "ffd166"), Color(hex: "f59f00")]
        case .platinum: return [Color(hex: "d8f3f7"), Color(hex: "72d6e6")]
        case .diamond: return [Color(hex: "56ccf2"), Color(hex: "6c63ff")]
        case .master: return [Color(hex: "ff6b9d"), Color(hex: "8e44ad")]
        case .legend: return [Color(hex: "ff5f6d"), Color(hex: "ffc371"), Color(hex: "6a82fb")]
        }
    }

}

private struct GuildRankBadge: View {
    let rank: GuildRank
    let size: CGFloat

    var body: some View {
        Image(rank.assetName)
            .resizable()
            .scaledToFit()
            .shadow(
                color: rank.colors.last?.opacity(0.28) ?? .clear,
                radius: size * 0.1,
                x: 0,
                y: size * 0.05
            )
        .frame(width: size, height: size)
        .accessibilityLabel("ギルドランク、\(rank.title)")
    }
}

private struct GuildSearchRow: View {
    let guild: GuildSummary
    let theme: SocialTheme
    let maxMembers: Int
    let isJoining: Bool
    let onJoin: () -> Void

    private var isFull: Bool { guild.memberCount >= maxMembers }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                GuildRankBadge(rank: guild.guildRank, size: 44)

                VStack(alignment: .leading, spacing: 5) {
                    Text(guild.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !guild.description.isEmpty {
                        Text(guild.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 5) {
                        SocialTagChip(
                            text: "\(guild.guildRank.title) Lv.\(guild.guildLevel)",
                            icon: guild.guildRank.symbolName,
                            tone: .neutral
                        )
                        if isFull {
                            SocialTagChip(text: "満員", icon: "person.fill.xmark", tone: .danger)
                        } else {
                            SocialTagChip(
                                text: "あと\(maxMembers - guild.memberCount)人",
                                icon: "person.fill.badge.plus",
                                tone: .success
                            )
                        }
                    }
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("メンバー")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(guild.memberCount)／\(maxMembers)人")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(isFull ? SocialPalette.danger : theme.textAccent)
                }
                SocialProgressBar(
                    value: Double(guild.memberCount),
                    maxValue: Double(maxMembers),
                    colors: isFull ? [Color(hex: "f5576c"), Color(hex: "f093fb")] : theme.colors,
                    height: 8
                )
            }

            if isFull {
                SocialSecondaryButton(theme: theme, title: "満員のため参加できません", icon: "lock.fill", isDisabled: true) {}
            } else {
                SocialGradientButton(
                    theme: theme,
                    title: "このギルドに参加する",
                    icon: "person.badge.plus",
                    isLoading: isJoining,
                    accessibilityHintText: "\(guild.name)のメンバーになります",
                    action: onJoin
                )
            }
        }
        .socialCard(padding: 14)
    }
}

// MARK: - ギルド作成

struct GuildCreateView: View {
    private let theme: SocialTheme = .guild

    private static let nameLimit = 20
    private static let descriptionLimit = 40

    @ObservedObject var guildManager = GuildManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var descriptionText = ""
    @State private var isCreating = false
    @State private var errorMessage: String?

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canCreate: Bool {
        !trimmedName.isEmpty && trimmedName.count <= Self.nameLimit
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: SocialMetrics.stackSpacing) {
                    SocialHeroHeader(
                        theme: theme,
                        icon: "flag.2.crossed.fill",
                        title: "ギルドを作成",
                        subtitle: "定員\(guildManager.maxMembers)人の勉強部屋を立ち上げます"
                    )

                    VStack(alignment: .leading, spacing: 16) {
                        field(
                            title: "ギルド名",
                            icon: "textformat",
                            count: trimmedName.count,
                            limit: Self.nameLimit,
                            isRequired: true
                        ) {
                            TextField("例: 毎日コツコツ勉強部屋", text: $name)
                                .font(.subheadline)
                                .padding(12)
                                .frame(minHeight: SocialMetrics.tapTarget)
                                .background(SocialPalette.insetSurface)
                                .cornerRadius(DesignTokens.Radius.md)
                                .accessibilityLabel("ギルド名。必須、\(Self.nameLimit)文字まで")
                                .onChange(of: name) { newValue in
                                    if newValue.count > Self.nameLimit {
                                        name = String(newValue.prefix(Self.nameLimit))
                                    }
                                    errorMessage = nil
                                }
                        }

                        field(
                            title: "紹介文",
                            icon: "text.alignleft",
                            count: descriptionText.count,
                            limit: Self.descriptionLimit,
                            isRequired: false
                        ) {
                            TextField("メンバーへの一言(任意)", text: $descriptionText)
                                .font(.subheadline)
                                .padding(12)
                                .frame(minHeight: SocialMetrics.tapTarget)
                                .background(SocialPalette.insetSurface)
                                .cornerRadius(DesignTokens.Radius.md)
                                .accessibilityLabel("紹介文。任意、\(Self.descriptionLimit)文字まで")
                                .onChange(of: descriptionText) { newValue in
                                    if newValue.count > Self.descriptionLimit {
                                        descriptionText = String(newValue.prefix(Self.descriptionLimit))
                                    }
                                }
                        }

                    }
                    .socialCard()

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(SocialPalette.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 4)
                    }

                    SocialGradientButton(
                        theme: theme,
                        title: "この内容で作成する",
                        icon: "checkmark",
                        isLoading: isCreating,
                        isDisabled: !canCreate,
                        accessibilityHintText: canCreate ? nil : "ギルド名を入力すると押せます"
                    ) {
                        create()
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .socialScreen(theme)
            .navigationTitle("ギルドを作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func field<Content: View>(
        title: String,
        icon: String,
        count: Int,
        limit: Int,
        isRequired: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(theme.textAccent)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                if isRequired {
                    SocialTagChip(text: "必須", icon: "asterisk", tone: .danger)
                } else {
                    SocialTagChip(text: "任意", tone: .neutral)
                }
                Spacer(minLength: 4)
                Text("\(count)/\(limit)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(count >= limit ? SocialPalette.warning : .secondary)
            }
            content()
        }
    }

    private func create() {
        isCreating = true
        errorMessage = nil
        guildManager.createGuild(name: name, description: descriptionText) { result in
            isCreating = false
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                errorMessage = error.errorDescription
            }
        }
    }
}

// MARK: - 所属中: ホーム画面

/// 詳細シートで見るメンバーの選択。sheet(item:) の識別のためだけに使う軽量な値。
private struct GuildMemberSelection: Identifiable, Equatable {
    let id: String
}

struct GuildHomeView: View {
    private let theme: SocialTheme = .guild

    @ObservedObject var guildManager = GuildManager.shared
    @ObservedObject private var friendManager = FriendManager.shared
    @State private var isPresentingLeaveConfirm = false
    @State private var isClaimingMission = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var isPresentingManagement = false
    @State private var isPresentingHelp = false
    @State private var isClaimingRankReward = false
    @State private var selectedMember: GuildMemberSelection?

    private var myUid: String { AuthManager.shared.currentUserId ?? "" }

    private var myRaidPlayer: GuildRaidPlayer? {
        guildManager.raid?.players.first { $0.id == myUid }
    }

    private var isMissionClaimable: Bool {
        guildManager.missionProgresses.contains { $0.isCompleted && !$0.isClaimed }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                LazyVStack(spacing: 12) {
                    guildLevelCard
                    raidCard
                    missionCard
                    membersCard
                    feedCard
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .refreshable { await reload() }
        }
        .socialScreen(theme)
        .navigationBarHidden(true)
        .alert(
            "お知らせ",
            isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })
        ) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .socialToast(message: $toastMessage)
        .sheet(isPresented: $isPresentingManagement) {
            GuildManagementView()
        }
        .sheet(isPresented: $isPresentingHelp) {
            GuildHelpView()
        }
        .sheet(item: $selectedMember) { selection in
            GuildMemberDetailSheet(uid: selection.id)
        }
        .confirmationDialog(
            "ギルドを脱退しますか?",
            isPresented: $isPresentingLeaveConfirm,
            titleVisibility: .visible
        ) {
            Button("脱退する", role: .destructive) {
                guildManager.leaveGuild { result in
                    if case .failure(let error) = result {
                        alertMessage = error.errorDescription
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ギルドボスと週間ミッションの報酬が受け取れなくなります。")
        }
    }

    private func reload() async {
        await withCheckedContinuation { continuation in
            guildManager.fetchMyGuild { continuation.resume() }
        }
    }

    // MARK: - ヘッダー

    private var header: some View {
        let leaderName = guildManager.members.first { $0.id == guildManager.guild?.leaderUid }?.name ?? "—"
        return SocialCompactHeader(
            theme: theme,
            title: guildManager.guild?.name ?? "ギルド",
            subtitle: "\(guildManager.guildLevelState.rank.title) Lv.\(guildManager.guildLevelState.level) · \(guildManager.members.count)／\(guildManager.maxMembers)人 · リーダー: \(leaderName)",
            icon: theme.symbol
        ) {
            HStack(spacing: 0) {
                Button {
                    isPresentingHelp = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.textAccent)
                        .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("ギルドの遊び方")

                Button {
                    isPresentingManagement = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.textAccent)
                        .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("ギルドの管理")
            }
        }
    }

    private var guildLevelCard: some View {
        GuildLevelCard(
            state: guildManager.guildLevelState,
            claimableRewards: guildManager.claimableRankRewards,
            theme: theme,
            isClaiming: isClaimingRankReward,
            onClaim: claimNextRankReward
        )
    }

    private func claimNextRankReward() {
        guard !isClaimingRankReward,
              let reward = guildManager.claimableRankRewards.first else { return }
        isClaimingRankReward = true
        guildManager.claimRankReward(reward.rank) { success in
            isClaimingRankReward = false
            if success {
                toastMessage = "\(reward.rank.title)到達報酬を受け取りました"
            } else {
                alertMessage = "ランク報酬の受け取りに失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    /// 「次に何をすればよいか」を1つだけ提示する。
    @ViewBuilder
    private var nextActionBanner: some View {
        if isMissionClaimable {
            SocialInlineBanner(
                icon: "gift.fill",
                title: "週間ミッションの報酬を受け取れます",
                message: "ギルド全員で目標を達成しました。",
                tone: .gold,
                actionTitle: isClaimingMission ? "受け取り中…" : "受け取る"
            ) {
                claimMission()
            }
        } else if let raid = guildManager.raid, raid.status == "active" {
            SocialInlineBanner(
                icon: "burst.fill",
                title: myRaidPlayer == nil ? "まだ攻撃していません" : "ギルドボス進行中",
                message: "クイズに正解すると\(raid.bossName)にダメージが入ります。討伐まで期限はありません。",
                tone: .theme(theme)
            )
        } else if guildManager.raid?.status == "completed" {
            SocialInlineBanner(
                icon: "checkmark.seal.fill",
                title: "ギルドボスを討伐しました",
                message: "次のボスまであと\(summonRemainingAnswers)問正解です。",
                tone: .success
            )
        }
    }

    // MARK: - ギルドボス

    private var raidCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(
                theme: theme,
                icon: "burst.fill",
                title: "ギルドボス",
                trailingText: guildManager.raid?.status == "completed"
                    ? "次まであと\(summonRemainingAnswers)問"
                    : "出現中"
            )

            if let raid = guildManager.raid {
                if raid.status == "active", raid.bossHP > 0 {
                    NavigationLink {
                        GuildBossDetailView()
                            .appNavigationBackButton()
                    } label: {
                        GuildBossActiveBanner(raid: raid)
                    }
                    .buttonStyle(.plain)
                } else {
                    GuildRaidBossRow(raid: raid)
                    SocialStatusPill(text: "討伐完了! 次のボスを召喚しよう", icon: "checkmark.seal.fill", tone: .success)
                    GuildBossSummonProgressView(
                        progress: guildManager.raidSummonCorrectAnswers,
                        target: guildManager.raidSummonTarget,
                        theme: theme
                    )
                    if !raid.players.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 9) {
                            Text("メンバーの貢献度")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            ForEach(Array(raid.players.prefix(3).enumerated()), id: \.element.id) { index, player in
                                GuildContributionRow(
                                    rank: index + 1,
                                    player: player,
                                    theme: theme,
                                    isMe: player.id == myUid
                                )
                            }
                        }
                    }
                }
            } else {
                SocialSkeletonRow(showsTrailing: false, insideCard: true)
            }
        }
        .socialCard()
    }

    private var summonRemainingAnswers: Int {
        max(guildManager.raidSummonTarget - guildManager.raidSummonCorrectAnswers, 0)
    }

    @ViewBuilder
    private var helperPreparationRow: some View {
        if let helper = friendManager.activeHelper {
            HStack(spacing: 10) {
                SocialAvatarThumb(imageName: helper.avatarName, theme: .friend, size: 40, ringTone: .success)
                VStack(alignment: .leading, spacing: 2) {
                    Text("フレンドの助っ人を編成中")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("\(helper.ownerName)のおとも · 攻撃+\(helper.attackBonus)")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(SocialPalette.success)
            }
            .padding(11)
            .background(SocialTheme.friend.softFill)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .accessibilityElement(children: .combine)
        } else {
            NavigationLink {
                FriendListView().appNavigationBackButton()
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(SocialTheme.friend.textAccent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("フレンドの助っ人を連れていく")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.primary)
                        Text("フレンド画面でおともを1体選べます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                }
                .padding(11)
                .background(SocialTheme.friend.softFill)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("フレンド画面でギルドボス戦の助っ人を選ぶ")
        }
    }

    // MARK: - 週間ミッション

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            let progresses = guildManager.missionProgresses
            let completed = progresses.filter(\.isCompleted).count
            let claimable = progresses.filter { $0.isCompleted && !$0.isClaimed }.count

            SocialSectionTitle(
                theme: theme,
                icon: "checklist",
                title: "ギルドミッション",
                trailingText: "\(completed)/\(progresses.count)達成"
            )

            if progresses.isEmpty {
                SocialSkeletonRow(showsTrailing: false, lines: 2, insideCard: true)
            } else {
                ForEach(Array(progresses.sorted(by: missionPriority).prefix(3))) { progress in
                    compactMissionRow(progress)
                }

                NavigationLink {
                    GuildMissionListView()
                        .appNavigationBackButton()
                } label: {
                    HStack {
                        Label("すべてのミッションを見る", systemImage: "list.bullet.rectangle")
                        Spacer()
                        if claimable > 0 {
                            SocialStatusPill(text: "受取\(claimable)件", icon: "gift.fill", tone: .gold)
                        }
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(theme.textAccent)
                    .frame(minHeight: SocialMetrics.tapTarget)
                }
                .buttonStyle(.plain)
            }
        }
        .socialCard()
    }

    private func missionPriority(_ lhs: GuildMissionProgress, _ rhs: GuildMissionProgress) -> Bool {
        let leftRank = lhs.isCompleted && !lhs.isClaimed ? 0 : lhs.isCompleted ? 2 : 1
        let rightRank = rhs.isCompleted && !rhs.isClaimed ? 0 : rhs.isCompleted ? 2 : 1
        if leftRank != rightRank { return leftRank < rightRank }
        return lhs.progressValue > rhs.progressValue
    }

    private func compactMissionRow(_ progress: GuildMissionProgress) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(progress.definition.title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                if progress.isCompleted {
                    Image(systemName: progress.isClaimed ? "checkmark.seal.fill" : "gift.fill")
                        .foregroundColor(progress.isClaimed ? SocialPalette.success : SocialPalette.warning)
                }
            }
            SocialProgressBar(
                value: Double(progress.current),
                maxValue: Double(progress.target),
                colors: theme.colors,
                height: 8
            )
            Text("\(progress.current) / \(progress.target)\(progress.definition.unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func claimMission() {
        guard !isClaimingMission,
              let mission = guildManager.missionProgresses.first(where: { $0.isCompleted && !$0.isClaimed }) else { return }
        isClaimingMission = true
        guildManager.claimMissionReward(missionId: mission.id) { success in
            isClaimingMission = false
            if success {
                toastMessage = "報酬を受け取りました"
            } else {
                alertMessage = "受け取りに失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    // MARK: - メンバー

    private var membersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(
                theme: theme,
                icon: "person.2.fill",
                title: "メンバー",
                trailingText: "\(guildManager.members.count)／\(guildManager.maxMembers)人"
            )

            if guildManager.members.isEmpty {
                SocialSkeletonRow(showsTrailing: false, lines: 1, insideCard: true)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(guildManager.members) { member in
                            memberMiniCard(member)
                        }
                        if guildManager.members.count < guildManager.maxMembers {
                            VStack(spacing: 5) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .foregroundColor(.secondary.opacity(0.4))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "plus")
                                        .foregroundColor(.secondary)
                                }
                                Text("空き\(guildManager.maxMembers - guildManager.members.count)")
                                    .font(.system(size: 10.5))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 52)
                        }
                    }
                    // 円形アバターの枠線が横スクロール領域の上端で欠けないよう余白を確保する。
                    .padding(.vertical, 2)
                }
            }
        }
        .socialCard()
    }

    private func memberMiniCard(_ member: GuildMember) -> some View {
        let isLeader = member.id == guildManager.guild?.leaderUid
        let isMe = member.id == myUid
        return Button {
            generateHapticFeedback()
            selectedMember = GuildMemberSelection(id: member.id)
        } label: {
            VStack(spacing: 4) {
                SocialAvatarThumb(
                    imageName: member.avatarName.isEmpty ? nil : member.avatarName,
                    theme: theme,
                    size: 40,
                    ringTone: isLeader ? .gold : (isMe ? .theme(theme) : nil)
                )
                Text(member.name)
                    .font(.system(size: 10.5, weight: isMe ? .bold : .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                SocialTagChip(
                    text: isLeader ? "リーダー" : "Lv.\(member.level)",
                    icon: isLeader ? "crown.fill" : nil,
                    tone: isLeader ? .gold : (isMe ? .theme(theme) : .neutral)
                )
            }
            .frame(width: 62)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(member.name)。レベル\(member.level)\(isLeader ? "、リーダー" : "")\(isMe ? "、あなた" : "")")
        .accessibilityHint("タップして詳細を見ます")
    }

    // MARK: - 活動フィード

    private var feedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "waveform.path.ecg", title: "活動フィード")

            if guildManager.feed.isEmpty {
                Text("まだ活動がありません。クイズを解くとここに記録されます。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                let items = Array(guildManager.feed.prefix(15))
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(alignment: .top, spacing: 10) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(theme.accent.opacity(0.6))
                                    .frame(width: 7, height: 7)
                                if index < items.count - 1 {
                                    Rectangle()
                                        .fill(theme.accent.opacity(0.2))
                                        .frame(width: 1.5)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 7)
                            .padding(.top, 5)
                            .accessibilityHidden(true)

                            Text("\(item.name)\(item.text)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 11)

                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
        .socialCard()
    }

    // MARK: - 管理(破壊的操作は主要導線から分離)

    private var manageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "gearshape.fill", title: "ギルドの管理")

            Text("脱退すると現在のボス戦への貢献度はギルドに残りますが、あなたはギルドボスと報酬の対象外になります。")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            SocialDestructiveButton(title: "ギルドを脱退する") {
                isPresentingLeaveConfirm = true
            }
        }
        .socialCard()
        .padding(.top, 6)
        .confirmationDialog(
            "ギルドを脱退しますか?",
            isPresented: $isPresentingLeaveConfirm,
            titleVisibility: .visible
        ) {
            Button("脱退する", role: .destructive) {
                guildManager.leaveGuild { result in
                    if case .failure(let error) = result {
                        alertMessage = error.errorDescription
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ギルドボスと週間ミッションの報酬が受け取れなくなります。")
        }
    }
}

// MARK: - ギルドレベル

private struct GuildLevelCard: View {
    let state: GuildLevelState
    let claimableRewards: [GuildRankReward]
    let theme: SocialTheme
    let isClaiming: Bool
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(
                theme: theme,
                icon: "crown.fill",
                title: "ギルドレベル",
                trailingText: state.rank.title
            )

            HStack(spacing: 13) {
                GuildRankBadge(rank: state.rank, size: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text(state.rank.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("ギルド Lv.\(state.level)")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundColor(theme.textAccent)
                    Text("累計 \(state.totalExperience.formatted()) ギルドEXP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }

            SocialProgressBar(
                value: state.isMaximumLevel ? 1 : Double(state.experienceInLevel),
                maxValue: state.isMaximumLevel ? 1 : Double(max(1, state.experienceForNextLevel)),
                colors: state.rank.colors,
                height: 11
            )

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.isMaximumLevel
                         ? "最大レベルに到達"
                         : "次のレベルまで \((state.experienceForNextLevel - state.experienceInLevel).formatted()) EXP")
                        .font(.caption.weight(.semibold))
                    if let nextRank = state.rank.next {
                        Text("次のランク: \(nextRank.title)（Lv.\(nextRank.minimumLevel)）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Label("今週 +\(state.weeklyExperience.formatted())", systemImage: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(theme.textAccent)
            }

            if let reward = claimableRewards.first {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("\(reward.rank.title)到達報酬", systemImage: "gift.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(SocialPalette.warning)
                        Spacer()
                        if claimableRewards.count > 1 {
                            Text("ほか\(claimableRewards.count - 1)件")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text(reward.rewardText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SocialGradientButton(
                        theme: theme,
                        title: "ランク報酬を受け取る",
                        icon: "gift.fill",
                        isLoading: isClaiming,
                        isDisabled: isClaiming,
                        action: onClaim
                    )
                }
            }
        }
        .socialCard()
        .accessibilityElement(children: .contain)
    }
}

// MARK: - ギルドミッション一覧

private struct GuildMissionListView: View {
    private enum Scope: String, CaseIterable, Identifiable {
        case weekly = "週間"
        case lifetime = "長期"
        var id: String { rawValue }
    }

    private let theme: SocialTheme = .guild
    @ObservedObject private var guildManager = GuildManager.shared
    @State private var scope: Scope = .weekly
    @State private var claimingId: String?
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var selectedMissionId: String?

    private var visibleSections: [GuildMissionSection] {
        GuildMissionSection.allCases.filter { section in
            scope == .lifetime ? section.isLifetime : !section.isLifetime
        }
    }

    private var selectedMission: GuildMissionProgress? {
        guard let selectedMissionId else { return nil }
        return guildManager.missionProgresses.first { $0.id == selectedMissionId }
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    Picker("期間", selection: $scope) {
                        ForEach(Scope.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    if scope == .weekly {
                        Label("毎週月曜日5時に進捗と受取状態が更新されます", systemImage: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    } else {
                        Label("長期ミッションは週をまたいで進捗が残ります", systemImage: "calendar.badge.clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    ForEach(visibleSections) { section in
                        let progresses = guildManager.missionProgresses.filter { $0.definition.section == section }
                        if !progresses.isEmpty {
                            missionSection(section, progresses: progresses)
                        }
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.34),
                                            Color.white.opacity(0.14)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.68), lineWidth: 0.8)
                }
                .shadow(color: Color.black.opacity(0.09), radius: 10, x: 0, y: 4)
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.vertical, 12)
            }

            if let mission = selectedMission {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedMissionId = nil }
                    .transition(.opacity)

                GuildMissionDetailModalView(
                    progress: mission,
                    theme: theme,
                    isClaiming: claimingId == mission.id,
                    onClaim: { claim(mission) },
                    onClose: { selectedMissionId = nil }
                )
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: selectedMissionId)
        .socialScreen(theme)
        .navigationTitle("ギルドミッション")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "お知らせ",
            isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })
        ) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .socialToast(message: $toastMessage)
    }

    private func missionSection(_ section: GuildMissionSection, progresses: [GuildMissionProgress]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(
                theme: theme,
                icon: sectionIcon(section),
                title: section.title,
                trailingText: "\(progresses.filter(\.isCompleted).count)/\(progresses.count)"
            )
            ForEach(progresses) { progress in
                GuildMissionCardView(
                    progress: progress,
                    theme: theme,
                    icon: sectionArtwork(progress.definition.section),
                    isClaiming: claimingId == progress.id,
                    claimAction: { claim(progress) },
                    detailAction: { selectedMissionId = progress.id }
                )
            }
        }
    }

    private func claim(_ progress: GuildMissionProgress) {
        claimingId = progress.id
        guildManager.claimMissionReward(missionId: progress.id) { success in
            claimingId = nil
            if success {
                toastMessage = "\(progress.definition.rewardText)を受け取りました"
            } else {
                alertMessage = "報酬の受け取りに失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    private func sectionIcon(_ section: GuildMissionSection) -> String {
        switch section {
        case .learning, .hardLearning: return "book.closed.fill"
        case .adventure, .hardAdventure: return "map.fill"
        case .battle: return "bolt.fill"
        case .participation, .hardCooperation: return "person.3.fill"
        case .hardRaid: return "burst.fill"
        case .weeklyLogin, .memberLogin, .lifetimeLogin: return "calendar.badge.checkmark"
        }
    }

    /// 個別の「ミッション」画面と同じ画像アセットを、系統ごとに割り当てる。
    private func sectionArtwork(_ section: GuildMissionSection) -> String {
        switch section {
        case .learning, .hardLearning: return "ミッション問題"
        case .adventure, .hardAdventure: return "足場1"
        case .battle: return "ミッションゲリラ"
        case .participation, .hardCooperation: return "ライム"
        case .hardRaid: return "ミッションゲリラ勝利"
        case .weeklyLogin, .memberLogin, .lifetimeLogin: return "ミッションログイン"
        }
    }
}

/// ギルドミッション画面専用の面の色。共通の `SocialPalette.cardSurface` より
/// 不透明度を上げ、背景の絵柄が透けすぎないようにしている。
private let guildMissionCardSurface = Color.socialDynamic(
    light: Color.white.opacity(0.88),
    dark: Color(hex: "191F29").opacity(0.90)
)

// MARK: - ギルドミッションカード（個別ミッション画面と同じ見せ方）

private struct GuildMissionCardView: View {
    let progress: GuildMissionProgress
    let theme: SocialTheme
    let icon: String
    let isClaiming: Bool
    let claimAction: () -> Void
    let detailAction: () -> Void

    private var accentColor: Color {
        if progress.isClaimed { return .secondary }
        if progress.isCompleted { return SocialPalette.success }
        return theme.textAccent
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            progress.isClaimed
                                ? AnyShapeStyle(Color.secondary.opacity(0.12))
                                : AnyShapeStyle(accentColor.opacity(0.16))
                        )
                        .frame(width: 40, height: 40)
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .opacity(progress.isClaimed ? 0.4 : 1.0)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(progress.definition.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(progress.isClaimed ? .secondary : .primary)
                        .lineLimit(2)

                    Text(progress.definition.rewardText)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(progress.isClaimed ? .secondary : SocialPalette.warning)
                        .lineLimit(1)
                }

                Spacer()

                if progress.isClaimed {
                    SocialStatusPill(text: "CLEAR", icon: "checkmark.circle.fill", tone: .neutral)
                } else if progress.isCompleted {
                    Button(action: claimAction) {
                        HStack(spacing: 4) {
                            if isClaiming {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 12))
                                Text("受取")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(theme.gradient))
                    }
                    .disabled(isClaiming)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            SocialProgressBar(
                value: Double(progress.current),
                maxValue: Double(progress.target),
                colors: progress.isClaimed ? [Color.secondary.opacity(0.4), Color.secondary.opacity(0.4)] : theme.colors,
                height: 6
            )
            .padding(.horizontal, 14)

            HStack {
                Spacer()
                Text("\(progress.current)/\(progress.target)\(progress.definition.unit)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .background(guildMissionCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                .stroke(progress.isCompleted && !progress.isClaimed ? SocialPalette.success.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { detailAction() }
    }
}

// MARK: - ギルドミッション詳細モーダル

private struct GuildMissionDetailModalView: View {
    let progress: GuildMissionProgress
    let theme: SocialTheme
    let isClaiming: Bool
    let onClaim: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.softFill)
                    .frame(width: 64, height: 64)
                Image(systemName: progress.isCompleted ? "checkmark.seal.fill" : "flag.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(theme.textAccent)
            }
            .padding(.top, 20)

            Text(progress.definition.title)
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)

            Text(progress.definition.description)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                HStack {
                    Text("進捗")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(progress.current) / \(progress.target)\(progress.definition.unit)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                SocialProgressBar(
                    value: Double(progress.current),
                    maxValue: Double(progress.target),
                    colors: theme.colors,
                    height: 8
                )
                if let detail = progress.detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(SocialPalette.insetSurface))

            VStack(alignment: .leading, spacing: 8) {
                Text("獲得できる報酬")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(progress.definition.rewardText)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(SocialPalette.warning)
                Text("＋\(progress.definition.rewardCoin) ギルドEXP")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.textAccent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(SocialPalette.insetSurface))

            if progress.isCompleted && !progress.isClaimed {
                SocialGradientButton(
                    theme: theme,
                    title: "報酬を受け取る",
                    icon: "gift.fill",
                    isLoading: isClaiming,
                    isDisabled: isClaiming
                ) {
                    onClaim()
                }
                .padding(.bottom, 20)
            } else {
                Button(action: onClose) {
                    Text("閉じる")
                        .font(.system(size: 15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(SocialPalette.insetSurface))
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
        .background(
            guildMissionCardSurface
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
        .shadow(color: SocialPalette.cardShadow, radius: 24, x: 0, y: 10)
    }
}

// MARK: - ギルドヘルプ

private struct GuildHelpView: View {
    private struct HelpItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
        let tone: SocialTone
    }

    private let theme: SocialTheme = .guild
    @Environment(\.presentationMode) private var presentationMode

    private let items: [HelpItem] = [
        HelpItem(
            icon: "person.3.fill",
            title: "ギルドとは？",
            body: "最大10人で参加する勉強部屋です。ギルドを検索して参加するほか、自分で作成したり、6桁の招待コードから参加したりできます。",
            tone: .theme(.guild)
        ),
        HelpItem(
            icon: "list.bullet.clipboard.fill",
            title: "ギルドミッション",
            body: "学習やログイン、ダンジョンなどメンバー全員の活動が進捗になります。達成したミッションは報酬を受け取り、ギルドEXPも獲得できます。",
            tone: .success
        ),
        HelpItem(
            icon: "burst.fill",
            title: "ギルドボス",
            body: "出現中のボスに、クイズで正解してダメージを与えます。討伐に期限はありません。討伐後はギルド全体で100問正解すると、次のボスが自動で出現します。",
            tone: .danger
        ),
        HelpItem(
            icon: "chart.line.uptrend.xyaxis",
            title: "ギルドランク",
            body: "活動で得たギルドEXPが貯まると、ギルドレベルとランクが上がります。到達したランクに報酬がある場合は、ギルド画面から受け取れます。",
            tone: .gold
        ),
        HelpItem(
            icon: "person.2.fill",
            title: "メンバーと活動フィード",
            body: "メンバーをタップすると、現在のボス戦への貢献を確認できます。活動フィードには、参加や学習など仲間の最近の活動が表示されます。",
            tone: .info
        ),
        HelpItem(
            icon: "crown.fill",
            title: "リーダーの管理機能",
            body: "リーダーは歯車ボタンからギルド情報の編集、招待コードの共有、メンバー管理、リーダー変更を行えます。脱退や解散は取り消せないため注意してください。",
            tone: .warning
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    introCard

                    ForEach(items) { item in
                        helpCard(item)
                    }

                    Text("週間ミッションの進捗と受取状態は月曜日5時に更新されます。ギルドボスと召喚ノルマに期限はありません。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.vertical, 12)
            }
            .socialScreen(theme)
            .navigationTitle("ギルドの遊び方")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var introCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(theme.gradient)
                    .frame(width: 50, height: 50)
                Image(systemName: theme.symbol)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("仲間と学んで、みんなで成長")
                    .font(.headline)
                Text("活動するほどミッションやボス戦が進みます。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .socialCard()
    }

    private func helpCard(_ item: HelpItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(item.tone.background)
                    .frame(width: 38, height: 38)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(item.tone.foreground)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14.5, weight: .bold))
                Text(item.body)
                    .font(.system(size: 12.5))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .socialCard()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - ギルド管理

private struct GuildManagementView: View {
    private enum Confirmation: Identifiable {
        case transfer(GuildMember)
        case remove(GuildMember)
        case leave
        case disband

        var id: String {
            switch self {
            case .transfer(let member): return "transfer-\(member.id)"
            case .remove(let member): return "remove-\(member.id)"
            case .leave: return "leave"
            case .disband: return "disband"
            }
        }
    }

    private let theme: SocialTheme = .guild
    private let nameLimit = 20
    private let descriptionLimit = 40

    @ObservedObject private var guildManager = GuildManager.shared
    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""
    @State private var descriptionText = ""
    @State private var isSaving = false
    @State private var isLoadingInviteCode = false
    @State private var confirmation: Confirmation?
    @State private var alertMessage: String?
    @State private var toastMessage: String?

    private var myUid: String { AuthManager.shared.currentUserId ?? "" }
    private var isLeader: Bool { guildManager.guild?.leaderUid == myUid }
    private var inviteCode: String { guildManager.guild?.inviteCode ?? "" }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    if isLeader {
                        editCard
                    }
                    inviteCard
                    membersManagementCard
                    destructiveCard
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .socialScreen(theme)
            .navigationTitle("ギルドの管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: load)
            .confirmationDialog(
                confirmationTitle,
                isPresented: Binding(get: { confirmation != nil }, set: { if !$0 { confirmation = nil } }),
                titleVisibility: .visible
            ) {
                if let confirmation {
                    Button(confirmationButtonTitle, role: confirmationRole) {
                        perform(confirmation)
                    }
                }
                Button("キャンセル", role: .cancel) { confirmation = nil }
            } message: {
                Text(confirmationMessage)
            }
            .alert(
                "お知らせ",
                isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })
            ) {
                Button("OK", role: .cancel) { alertMessage = nil }
            } message: {
                Text(alertMessage ?? "")
            }
            .socialToast(message: $toastMessage)
        }
        .navigationViewStyle(.stack)
    }

    private var editCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "pencil", title: "基本情報を編集")

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("ギルド名").font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(name.count)/\(nameLimit)").font(.caption2).foregroundColor(.secondary)
                }
                TextField("ギルド名", text: $name)
                    .padding(.horizontal, 12)
                    .frame(minHeight: SocialMetrics.tapTarget)
                    .background(SocialPalette.insetSurface)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                    .onChange(of: name) { name = String($0.prefix(nameLimit)) }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("紹介文").font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(descriptionText.count)/\(descriptionLimit)").font(.caption2).foregroundColor(.secondary)
                }
                TextEditor(text: $descriptionText)
                    .frame(minHeight: 78)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(SocialPalette.insetSurface)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                    .onChange(of: descriptionText) { descriptionText = String($0.prefix(descriptionLimit)) }
            }

            SocialGradientButton(
                theme: theme,
                title: "変更を保存",
                icon: "checkmark",
                isLoading: isSaving,
                isDisabled: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) { save() }
        }
        .socialCard()
    }

    private var inviteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "person.badge.plus", title: "メンバーを招待")
            Text("このコードを共有すると、ギルド検索画面から直接参加できます。")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Text(inviteCode.isEmpty ? "発行中…" : inviteCode)
                    .font(.system(.title2, design: .monospaced).weight(.bold))
                    .foregroundColor(theme.textAccent)
                    .tracking(1.2)
                Spacer()
                if isLoadingInviteCode {
                    ProgressView()
                } else if !inviteCode.isEmpty {
                    Button {
                        UIPasteboard.general.string = inviteCode
                        toastMessage = "招待コードをコピーしました"
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                            .background(theme.softFill)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: "ITクエストのギルド「\(guildManager.guild?.name ?? "")」に参加しよう！\n招待コード: \(inviteCode)") {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                            .background(theme.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(12)
            .background(SocialPalette.insetSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
        .socialCard()
    }

    private var membersManagementCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(
                theme: theme,
                icon: "person.2.fill",
                title: "メンバー管理",
                trailingText: "\(guildManager.members.count)/\(guildManager.maxMembers)人"
            )

            ForEach(guildManager.members) { member in
                HStack(spacing: 10) {
                    SocialAvatarThumb(
                        imageName: member.avatarName.isEmpty ? nil : member.avatarName,
                        theme: theme,
                        size: 38
                    )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(member.name).font(.subheadline.weight(.semibold))
                        Text(member.id == guildManager.guild?.leaderUid ? "リーダー" : "Lv.\(member.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if isLeader && member.id != myUid {
                        Menu {
                            Button {
                                confirmation = .transfer(member)
                            } label: {
                                Label("リーダーを任せる", systemImage: "crown.fill")
                            }
                            Button(role: .destructive) {
                                confirmation = .remove(member)
                            } label: {
                                Label("ギルドから外す", systemImage: "person.badge.minus")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                                .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                        }
                    }
                }
                if member.id != guildManager.members.last?.id { Divider() }
            }
        }
        .socialCard()
    }

    private var destructiveCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "exclamationmark.triangle.fill", title: "所属の変更")
            if !isLeader || guildManager.members.count == 1 {
                SocialDestructiveButton(title: "ギルドを脱退する") {
                    confirmation = .leave
                }
            } else {
                Text("リーダーが脱退するには、先にほかのメンバーへリーダーを任せてください。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if isLeader {
                SocialDestructiveButton(title: "ギルドを解散する") {
                    confirmation = .disband
                }
            }
        }
        .socialCard()
    }

    private func load() {
        name = guildManager.guild?.name ?? ""
        descriptionText = guildManager.guild?.description ?? ""
        guard inviteCode.isEmpty else { return }
        isLoadingInviteCode = true
        guildManager.ensureInviteCode { result in
            isLoadingInviteCode = false
            if case .failure(let error) = result {
                alertMessage = error.errorDescription
            }
        }
    }

    private func save() {
        isSaving = true
        guildManager.updateGuild(name: name, description: descriptionText) { result in
            isSaving = false
            handle(result, successMessage: "ギルド情報を更新しました")
        }
    }

    private var confirmationTitle: String {
        switch confirmation {
        case .transfer(let member): return "\(member.name)にリーダーを任せますか?"
        case .remove(let member): return "\(member.name)をギルドから外しますか?"
        case .leave: return "ギルドを脱退しますか?"
        case .disband: return "ギルドを解散しますか?"
        case nil: return "確認"
        }
    }

    private var confirmationButtonTitle: String {
        switch confirmation {
        case .transfer: return "リーダーを変更する"
        case .remove: return "ギルドから外す"
        case .leave: return "脱退する"
        case .disband: return "解散する"
        case nil: return "実行する"
        }
    }

    private var confirmationRole: ButtonRole? {
        if case .transfer = confirmation { return nil }
        return .destructive
    }

    private var confirmationMessage: String {
        switch confirmation {
        case .transfer: return "変更後は、新しいリーダーだけがギルド情報とメンバーを管理できます。"
        case .remove: return "対象メンバーはギルドボスと週間ミッションに参加できなくなります。"
        case .leave: return "今週の報酬を受け取れなくなります。"
        case .disband: return "全メンバーの所属が解除されます。この操作は取り消せません。"
        case nil: return ""
        }
    }

    private func perform(_ action: Confirmation) {
        confirmation = nil
        switch action {
        case .transfer(let member):
            guildManager.transferLeadership(to: member) { result in
                handle(result, successMessage: "\(member.name)にリーダーを変更しました")
            }
        case .remove(let member):
            guildManager.removeMember(member) { result in
                handle(result, successMessage: "\(member.name)をギルドから外しました")
            }
        case .leave:
            guildManager.leaveGuild { result in
                handle(result, successMessage: "ギルドを脱退しました", dismissOnSuccess: true)
            }
        case .disband:
            guildManager.disbandGuild { result in
                handle(result, successMessage: "ギルドを解散しました", dismissOnSuccess: true)
            }
        }
    }

    private func handle(
        _ result: Result<Void, GuildError>,
        successMessage: String,
        dismissOnSuccess: Bool = false
    ) {
        switch result {
        case .success:
            toastMessage = successMessage
            if dismissOnSuccess {
                presentationMode.wrappedValue.dismiss()
            }
        case .failure(let error):
            alertMessage = error.errorDescription
        }
    }
}

// MARK: - ギルドボス表示

private struct GuildBossSummonProgressView: View {
    let progress: Int
    let target: Int
    let theme: SocialTheme

    private var safeTarget: Int { max(target, 1) }
    private var safeProgress: Int { min(max(progress, 0), safeTarget) }
    private var remaining: Int { max(safeTarget - safeProgress, 0) }
    private var ratio: Double { Double(safeProgress) / Double(safeTarget) }

    private var encouragement: String {
        switch ratio {
        case 0:
            return "まだ召喚ノルマは進んでいません"
        case ..<0.5:
            return "メンバーと正解を積み重ねよう"
        case ..<0.8:
            return "召喚ノルマの半分を超えました"
        default:
            return "あと少しで次のボスが出現します"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("次のボスまであと\(remaining)問")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text(encouragement)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 8)
                Text("\(safeProgress) / \(safeTarget)問")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.textAccent)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.softFill)
                    Capsule()
                        .fill(theme.gradient)
                        .frame(width: proxy.size.width * ratio)
                }
            }
            .frame(height: 9)

            Label("ボス討伐後の正解1問につき＋1", systemImage: "checkmark.circle.fill")
                .font(.caption2.weight(.semibold))
                .foregroundColor(theme.textAccent)
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.softFill.opacity(0.72))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(theme.textAccent.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("次のギルドボスまであと\(remaining)問正解。現在\(safeProgress)問、ノルマ\(safeTarget)問")
    }
}

private struct GuildBossActiveBanner: View {
    let raid: GuildRaidState

    private var hpProgress: Double {
        guard raid.bossMaxHP > 0 else { return 0 }
        return min(max(Double(raid.bossHP) / Double(raid.bossMaxHP), 0), 1)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("GuildBossActiveBanner")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(2.4, contentMode: .fit)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(spacing: 7) {
                HStack {
                    Text(raid.bossName.isEmpty ? "ギルドボス" : raid.bossName)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    Label("詳細を見る", systemImage: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.92))
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.25))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * hpProgress)
                    }
                }
                .frame(height: 7)

                HStack {
                    Text("HP \(raid.bossHP) / \(raid.bossMaxHP)")
                    Spacer()
                    Text("参加 \(raid.players.count)人")
                }
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.88))
            }
            .padding(.horizontal, 13)
            .padding(.bottom, 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.yellow.opacity(0.75), lineWidth: 1.5)
        }
        .shadow(color: Color.orange.opacity(0.28), radius: 12, y: 5)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ギルドボス出現中。\(raid.bossName)。HP\(raid.bossHP)、最大\(raid.bossMaxHP)。詳細を見る")
    }
}

private struct GuildBossDetailView: View {
    private let theme: SocialTheme = .guild

    @ObservedObject private var guildManager = GuildManager.shared
    @ObservedObject private var friendManager = FriendManager.shared
    @State private var isPresentingBattle = false
    @State private var selectedMember: GuildMemberSelection?

    private var myUid: String { AuthManager.shared.currentUserId ?? "" }
    private var raid: GuildRaidState? { guildManager.raid }
    private var myContribution: GuildRaidPlayer? { raid?.players.first { $0.id == myUid } }
    private var totalDamage: Int { raid?.players.reduce(0) { $0 + $1.totalDamage } ?? 0 }
    private var totalCorrect: Int { raid?.players.reduce(0) { $0 + $1.correctCount } ?? 0 }
    private var isActive: Bool { raid?.status == "active" && (raid?.bossHP ?? 0) > 0 }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if let raid {
                    bossStatus(raid)
                    activitySummary(raid)
                    myContributionCard
                    helperCard
                    contributionCard(raid)
                    missionRewardCard
                } else {
                    SocialSkeletonList(count: 3)
                }
            }
            .padding(.horizontal, SocialMetrics.screenPadding)
            .padding(.vertical, 12)
            .padding(.bottom, isActive ? 78 : 24)
        }
        .socialScreen(theme)
        .navigationTitle("ギルドボス詳細")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isActive {
                VStack(spacing: 0) {
                    Divider()
                    SocialGradientButton(
                        theme: theme,
                        title: "ギルドボスに挑戦する",
                        icon: "flame.fill",
                        accessibilityHintText: "ギルドボスを倒すまで続く専用クイズバトルを開始します"
                    ) {
                        generateHapticFeedback()
                        isPresentingBattle = true
                    }
                    .padding(.horizontal, SocialMetrics.screenPadding)
                    .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial)
            }
        }
        .fullScreenCover(isPresented: $isPresentingBattle) {
            GuildBossBattleView(isPresenting: $isPresentingBattle)
        }
        .sheet(item: $selectedMember) { selection in
            GuildMemberDetailSheet(uid: selection.id)
        }
    }

    private func bossStatus(_ raid: GuildRaidState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(
                theme: theme,
                icon: "burst.fill",
                title: raid.bossName.isEmpty ? "ギルドボス" : raid.bossName,
                trailingText: isActive ? "出現中" : "討伐完了"
            )
            GuildRaidBossRow(raid: raid)
            if let boss = guildRaidBosses.first(where: { $0.name == raid.bossName }) {
                HStack(spacing: 8) {
                    SocialStatusPill(
                        text: boss.difficulty.rawValue,
                        icon: "star.fill",
                        tone: boss.difficulty == .beginner ? .success : (boss.difficulty == .intermediate ? .warning : .danger)
                    )
                    SocialStatusPill(
                        text: "攻撃力 \(boss.bossAttack)",
                        icon: "bolt.fill",
                        tone: .danger
                    )
                }
            }
            if !isActive {
                SocialStatusPill(text: "討伐完了! 次のボスを召喚しよう", icon: "checkmark.seal.fill", tone: .success)
                GuildBossSummonProgressView(
                    progress: guildManager.raidSummonCorrectAnswers,
                    target: guildManager.raidSummonTarget,
                    theme: theme
                )
            }
            Label(isActive ? "討伐期限なし" : "ギルド全体の正解100問で次のボスが出現", systemImage: "infinity")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .socialCard()
    }

    private func activitySummary(_ raid: GuildRaidState) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 10) {
            metric(title: "参加メンバー", value: "\(raid.players.count)人", icon: "person.3.fill")
            metric(title: "ギルド総ダメージ", value: "\(totalDamage)", icon: "flame.fill")
            metric(title: "合計正解数", value: "\(totalCorrect)問", icon: "checkmark.circle.fill")
            metric(title: "残りHP", value: "\(max(raid.bossHP, 0))", icon: "heart.fill")
        }
    }

    private func metric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .foregroundColor(theme.textAccent)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
        .padding(12)
        .background(SocialPalette.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
    }

    private var myContributionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "person.fill", title: "あなたの貢献")
            if let player = myContribution {
                HStack {
                    metricValue("ダメージ", value: "\(player.totalDamage)")
                    Divider().frame(height: 38)
                    metricValue("正解数", value: "\(player.correctCount)問")
                }
            } else {
                Text("まだ攻撃していません。専用バトルや通常のクイズで正解すると貢献度が記録されます。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .socialCard()
    }

    private func metricValue(_ title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundColor(theme.textAccent)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var helperCard: some View {
        if let helper = friendManager.activeHelper {
            HStack(spacing: 11) {
                SocialAvatarThumb(imageName: helper.avatarName, theme: .friend, size: 44, ringTone: .success)
                VStack(alignment: .leading, spacing: 3) {
                    Text("フレンドの助っ人を編成中")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("\(helper.ownerName)のおとも · 攻撃+\(helper.attackBonus)")
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(SocialPalette.success)
            }
            .socialCard()
        } else {
            NavigationLink {
                FriendListView().appNavigationBackButton()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(SocialTheme.friend.textAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("フレンドの助っ人を連れていく")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.primary)
                        Text("攻撃ボーナスを受けて挑戦できます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .socialCard()
            }
            .buttonStyle(.plain)
        }
    }

    private func contributionCard(_ raid: GuildRaidState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(
                theme: theme,
                icon: "trophy.fill",
                title: "メンバーの貢献度",
                trailingText: "\(raid.players.count)人参加"
            )
            if raid.players.isEmpty {
                Text("まだ参加者はいません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(raid.players.enumerated()), id: \.element.id) { index, player in
                    Button {
                        selectedMember = GuildMemberSelection(id: player.id)
                    } label: {
                        GuildContributionRow(
                            rank: index + 1,
                            player: player,
                            theme: theme,
                            isMe: player.id == myUid
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .socialCard()
    }

    private var missionRewardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SocialSectionTitle(theme: theme, icon: "gift.fill", title: "討伐と報酬")
            Label("ボスへの攻撃・討伐は高難度レイド系のギルドミッションへ反映されます", systemImage: "checkmark.seal.fill")
            Label("達成した報酬はギルドミッション画面から受け取れます", systemImage: "gift.fill")
            Label("通常のクイズに正解した場合も、ギルドボスへ自動でダメージが入ります", systemImage: "book.closed.fill")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .socialCard()
    }
}

private struct GuildRaidBossRow: View {
    let raid: GuildRaidState

    private var hpPercent: Int {
        guard raid.bossMaxHP > 0 else { return 0 }
        return Int((Double(raid.bossHP) / Double(raid.bossMaxHP) * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(SocialTone.danger.background)
                    .frame(width: 62, height: 62)
                if !raid.bossImageName.isEmpty, UIImage(named: raid.bossImageName) != nil {
                    Image(raid.bossImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                } else {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SocialPalette.danger)
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(raid.bossName.isEmpty ? "ギルドボス" : raid.bossName)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                SocialProgressBar(
                    value: Double(raid.bossHP),
                    maxValue: Double(raid.bossMaxHP),
                    colors: [Color(hex: "f5576c"), Color(hex: "f093fb")],
                    height: 13
                )
                HStack {
                    Text("HP \(raid.bossHP) / \(raid.bossMaxHP)")
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(hpPercent)%")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(SocialPalette.danger)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ギルドボス\(raid.bossName)。残りHP\(hpPercent)パーセント")
    }
}

// MARK: - 貢献度1件

private struct GuildContributionRow: View {
    let rank: Int
    let player: GuildRaidPlayer
    let theme: SocialTheme
    let isMe: Bool

    var body: some View {
        HStack(spacing: 9) {
            SocialRankBadge(rank: rank)
            SocialAvatarThumb(
                imageName: player.avatarName.isEmpty ? nil : player.avatarName,
                theme: theme,
                size: 28,
                ringTone: isMe ? .theme(theme) : nil
            )
            Text(player.name)
                .font(.footnote.weight(isMe ? .bold : .regular))
                .foregroundColor(isMe ? theme.textAccent : .primary)
                .lineLimit(1)
            if isMe {
                SocialTagChip(text: "YOU", icon: "person.fill", tone: .theme(theme))
            }
            Spacer(minLength: 4)
            Text("\(player.totalDamage)")
                .font(.system(.footnote, design: .rounded).weight(.bold))
                .foregroundColor(.primary)
            Text("ダメージ")
                .font(.caption2)
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(minHeight: 34)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rank)位 \(player.name)\(isMe ? "、あなた" : "")。\(player.totalDamage)ダメージ")
        .accessibilityHint("タップして詳細を見ます")
    }
}

// MARK: - メンバー1件

private struct GuildMemberRow: View {
    let member: GuildMember
    let theme: SocialTheme
    let isLeader: Bool
    let isMe: Bool

    var body: some View {
        HStack(spacing: 10) {
            SocialAvatarThumb(
                imageName: member.avatarName.isEmpty ? nil : member.avatarName,
                theme: theme,
                size: 34,
                ringTone: isMe ? .theme(theme) : nil
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                    .font(.footnote.weight(isMe ? .bold : .regular))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    if isLeader {
                        SocialTagChip(text: "リーダー", icon: "crown.fill", tone: .gold)
                    }
                    if isMe {
                        SocialTagChip(text: "あなた", icon: "person.fill", tone: .theme(theme))
                    }
                }
            }

            Spacer(minLength: 4)

            SocialTagChip(text: "Lv.\(member.level)", icon: "star.fill", tone: .theme(theme))
        }
        .frame(minHeight: 40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(member.name)。レベル\(member.level)\(isLeader ? "、リーダー" : "")\(isMe ? "、あなた" : "")"
        )
    }
}

// MARK: - メンバー詳細シート

/// メンバー一覧・貢献度一覧のどちらからもタップして開ける詳細画面。
/// Firebase を直接観測するのではなく、GuildManager が既に持っている状態から
/// 都度組み立てることで、他メンバーの操作もリアルタイムに反映される。
struct GuildMemberDetailSheet: View {
    let uid: String

    private let theme: SocialTheme = .guild

    @ObservedObject private var guildManager = GuildManager.shared
    @Environment(\.presentationMode) private var presentationMode

    private var myUid: String { AuthManager.shared.currentUserId ?? "" }
    private var isMe: Bool { uid == myUid }
    private var member: GuildMember? { guildManager.members.first { $0.id == uid } }
    private var isLeader: Bool { uid == guildManager.guild?.leaderUid }
    private var raidPlayer: GuildRaidPlayer? { guildManager.raid?.players.first { $0.id == uid } }

    private var avatarName: String? {
        let name = member?.avatarName ?? raidPlayer?.avatarName ?? ""
        return name.isEmpty ? nil : name
    }

    private var displayName: String {
        member?.name ?? raidPlayer?.name ?? "名無し"
    }

    private var rank: Int? {
        guard let players = guildManager.raid?.players,
              let index = players.firstIndex(where: { $0.id == uid }) else { return nil }
        return index + 1
    }

    private var sharePercent: String {
        guard let raid = guildManager.raid else { return "—" }
        let dealt = max(0, raid.bossMaxHP - raid.bossHP)
        guard dealt > 0 else { return "—" }
        let mine = raidPlayer?.totalDamage ?? 0
        return "\(Int((Double(mine) / Double(dealt) * 100).rounded()))%"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: SocialMetrics.stackSpacing) {
                    header
                    statsCard
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .socialScreen(theme)
            .navigationTitle("メンバー詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var header: some View {
        VStack(spacing: 10) {
            SocialAvatarThumb(
                imageName: avatarName,
                theme: theme,
                size: 76,
                ringTone: isLeader ? .gold : (isMe ? .theme(theme) : nil)
            )
            Text(displayName)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 6) {
                if let member {
                    SocialTagChip(text: "Lv.\(member.level)", icon: "star.fill", tone: .theme(theme))
                }
                if isLeader {
                    SocialTagChip(text: "リーダー", icon: "crown.fill", tone: .gold)
                }
                if isMe {
                    SocialTagChip(text: "あなた", icon: "person.fill", tone: .theme(theme))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "burst.fill", title: "現在のギルドボスへの貢献")

            if guildManager.raid == nil {
                SocialSkeletonRow(showsTrailing: false, lines: 1, insideCard: true)
            } else if raidPlayer == nil {
                Text("まだ攻撃していません。クイズに正解するとここに記録されます。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack(spacing: 10) {
                    SocialStatTile(value: "\(raidPlayer?.totalDamage ?? 0)", label: "与ダメージ", tone: .theme(theme))
                    SocialStatTile(value: "\(raidPlayer?.correctCount ?? 0)", label: "正解数", tone: .success)
                    SocialStatTile(value: sharePercent, label: "全体に占める割合", tone: .gold)
                }
                if let rank {
                    SocialStatusPill(text: "貢献度\(rank)位", icon: "trophy.fill", tone: .gold)
                }
            }
        }
        .socialCard()
    }
}

// MARK: - プレビュー

#if DEBUG
enum GuildPreviewFixtures {
    static let guild = GuildSummary(
        id: "g1",
        name: "毎日コツコツ勉強部屋",
        description: "毎日1問でもOK。ゆるく続ける部屋です。",
        indexScope: "all",
        memberCount: 6,
        leaderUid: "leader",
        inviteCode: "ABC234",
        guildExperience: 82_400
    )

    static let fullGuild = GuildSummary(
        id: "g2",
        name: "週20問チャレンジ",
        description: "週20問以上を目安に活動中。",
        indexScope: "all",
        memberCount: 10,
        leaderUid: "leader",
        inviteCode: "XYZ789",
        guildExperience: 286_000
    )

    static let raid = GuildRaidState(
        raidId: "preview-raid",
        bossName: "バグドラゴン",
        bossImageName: "",
        bossHP: 7200,
        bossMaxHP: 18000,
        status: "active",
        players: [
            GuildRaidPlayer(id: "me", name: "あなた", totalDamage: 5200, correctCount: 26, avatarName: "ネッキー"),
            GuildRaidPlayer(id: "u2", name: "たろう", totalDamage: 3400, correctCount: 17, avatarName: "かみ蔵"),
            GuildRaidPlayer(id: "u3", name: "はなこ", totalDamage: 2200, correctCount: 11, avatarName: "")
        ],
        completedAt: 0
    )

    static let levelState = GuildLevelState(
        totalExperience: 82_400,
        weeklyExperience: 2_350,
        level: 37,
        experienceInLevel: 1_400,
        experienceForNextLevel: 4_100,
        rankAchievements: [.bronze: 1, .silver: 2, .gold: 3],
        claimedRankRewards: [.bronze, .silver]
    )
}

struct GuildView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 10) {
                    GuildSearchRow(
                        guild: GuildPreviewFixtures.guild,
                        theme: .guild,
                        maxMembers: 10,
                        isJoining: false,
                        onJoin: {}
                    )
                    GuildSearchRow(
                        guild: GuildPreviewFixtures.fullGuild,
                        theme: .guild,
                        maxMembers: 10,
                        isJoining: false,
                        onJoin: {}
                    )
                }
                .padding()
            }
            .socialScreen(.guild)
            .previewDisplayName("ギルド検索 / ライト")

            ScrollView {
                GuildLevelCard(
                    state: GuildPreviewFixtures.levelState,
                    claimableRewards: [GuildRank.gold.reward].compactMap { $0 },
                    theme: .guild,
                    isClaiming: false,
                    onClaim: {}
                )
                .padding()
            }
            .socialScreen(.guild)
            .previewDisplayName("ギルドレベル / 報酬あり")

            ScrollView {
                VStack(spacing: 12) {
                    GuildRaidBossRow(raid: GuildPreviewFixtures.raid)
                        .socialCard()
                    VStack(spacing: 9) {
                        ForEach(Array(GuildPreviewFixtures.raid.players.enumerated()), id: \.element.id) { index, player in
                            GuildContributionRow(
                                rank: index + 1,
                                player: player,
                                theme: .guild,
                                isMe: player.id == "me"
                            )
                        }
                    }
                    .socialCard()
                    GuildMemberRow(
                        member: GuildMember(id: "me", name: "あなた", level: 31, joinedAt: 0, avatarName: "ネッキー"),
                        theme: .guild,
                        isLeader: true,
                        isMe: true
                    )
                    .socialCard()
                }
                .padding()
            }
            .socialScreen(.guild)
            .preferredColorScheme(.dark)
            .previewDisplayName("ギルドボス・メンバー / ダーク")

            GuildMemberDetailSheet(uid: "u2")
                .previewDisplayName("メンバー詳細")
        }
    }
}
#endif
