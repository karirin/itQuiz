//
//  FriendListView.swift
//  it
//
//  フレンド一覧・申請・フレンドコード追加・助っ人おともの画面です。
//
//  情報設計:
//   1) いちばん使う「フレンド一覧」を初期表示にする
//   2) 申請が届いていれば、タブに入る前にバナーとバッジで気づかせる
//   3) 自分のコードは「追加」タブへ集約し、共有までを一気通貫にする
//

import SwiftUI

// MARK: - 画面

enum FriendListInitialSection {
    case friends
    case requests
    case add
}

struct FriendListView: View {
    private enum Segment: String, CaseIterable, Hashable {
        case friends = "フレンド"
        case requests = "申請"
        case add = "追加"
    }

    private let theme: SocialTheme = .friend

    @ObservedObject var friendManager = FriendManager.shared
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject private var appState: AppState

    @State private var segment: Segment = .friends
    @State private var friendPendingRemoval: FriendSummary?
    @State private var removingFriendId: String?
    @State private var borrowingFriendId: String?
    @State private var greetingFriendId: String?
    @State private var cheeringFriendId: String?
    @State private var handlingRequestId: String?
    @State private var cancelingRequestId: String?
    @State private var codeInput: String = ""
    @State private var isSendingRequest = false
    @State private var didCopyCode = false
    @State private var hasLoadedFriendsOnce = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var addErrorMessage: String?
    @State private var isPresentingHelperHelp = false
    @FocusState private var isCodeInputFocused: Bool

    init(initialSection: FriendListInitialSection = .friends) {
        let segment: Segment
        switch initialSection {
        case .friends: segment = .friends
        case .requests: segment = .requests
        case .add: segment = .add
        }
        _segment = State(initialValue: segment)
    }

    private var friendLimit: Int {
        appState.isSubscribed ? FriendLimitPolicy.premium : FriendLimitPolicy.standard
    }
    private var isSignedIn: Bool { authManager.currentUserId != nil }

    /// 今日まだ借りられる助っ人を上に出す。同条件ならレベル順。
    private var sortedFriends: [FriendSummary] {
        friendManager.friends.sorted { lhs, rhs in
            let lhsReady = lhs.featuredAvatarName != nil && lhs.canBorrowToday
            let rhsReady = rhs.featuredAvatarName != nil && rhs.canBorrowToday
            if lhsReady != rhsReady { return lhsReady }
            if lhs.level != rhs.level { return lhs.level > rhs.level }
            return lhs.name < rhs.name
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            segmentPicker
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 12) {
                    switch segment {
                    case .friends: friendsSection
                    case .requests: requestsSection
                    case .add: addSection
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.bottom, 32)
            }
            .refreshable { await reloadFriends() }
        }
        .socialScreen(theme)
        .navigationBarHidden(true)
        .interactiveSwipeBackEnabled()
        .onAppear(perform: load)
        .onDisappear { friendManager.stopObservingRequests() }
        .onChange(of: appState.isSubscribed) { _ in
            friendManager.syncCurrentUserFriendLimit(friendLimit)
        }
        .onChange(of: segment) { newSegment in
            if newSegment != .add {
                isCodeInputFocused = false
            }
        }
        .confirmationDialog(
            "フレンドを解除しますか?",
            isPresented: Binding(
                get: { friendPendingRemoval != nil },
                set: { if !$0 { friendPendingRemoval = nil } }
            ),
            titleVisibility: .visible,
            presenting: friendPendingRemoval
        ) { friend in
            Button("\(friend.name)を解除する", role: .destructive) { remove(friend) }
            Button("キャンセル", role: .cancel) { friendPendingRemoval = nil }
        } message: { friend in
            Text("\(friend.name)の助っ人を借りられなくなります。相手のフレンド一覧からも消えます。")
        }
        .alert(
            "お知らせ",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .socialToast(message: $toastMessage)
        .sheet(isPresented: $isPresentingHelperHelp) {
            HelperBorrowHelpView()
        }
    }

    // MARK: - ライフサイクル

    private func load() {
        friendManager.syncCurrentUserFriendLimit(friendLimit)
        friendManager.ensureFriendCode()
        friendManager.observeIncomingRequests()
        friendManager.observeOutgoingRequests()
        friendManager.fetchPendingThanks()
        friendManager.fetchFriendPoints()
        friendManager.fetchFriends { hasLoadedFriendsOnce = true }
    }

    private func reloadFriends() async {
        await withCheckedContinuation { continuation in
            friendManager.fetchFriends {
                hasLoadedFriendsOnce = true
                continuation.resume()
            }
        }
        friendManager.fetchPendingThanks()
        friendManager.fetchFriendPoints()
    }

    // MARK: - ヘッダー

    private var header: some View {
        SocialCompactHeader(
            theme: theme,
            title: "フレンド",
            subtitle: "\(friendManager.friends.count)／\(friendLimit)人 · 助っ人は1日1回",
            icon: theme.symbol
        ) {
            HStack(spacing: 4) {
                Button {
                    generateHapticFeedback()
                    isPresentingHelperHelp = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.textAccent)
                        .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("助っ人おともの説明を見る")

                NavigationLink {
                    HelperHistoryView(friendManager: friendManager)
                        .appNavigationBackButton()
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.textAccent)
                        .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("助っ人履歴を見る")
            }
        }
    }

    private var requestsBanner: some View {
        SocialInlineBanner(
            icon: "person.crop.circle.badge.plus",
            title: "\(friendManager.incomingRequests.count)件のフレンド申請が届いています",
            message: "承認するとすぐに助っ人を借りられます。",
            tone: .theme(theme),
            actionTitle: "申請を見る"
        ) {
            segment = .requests
        }
    }

    private var thanksBanner: some View {
        HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(SocialPalette.goldText.opacity(0.14))
                    .frame(width: 32, height: 32)
                Image(systemName: "gift.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SocialPalette.goldText)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("お礼コイン +\(friendManager.pendingThanksCoins)")
                    .font(.system(size: 14, weight: .bold))
                Text("\(friendManager.pendingThanksCount)人があなたのおともを借りました")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 4)
            Button("受け取る") {
                claimThanks()
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 13)
            .frame(minHeight: 34)
            .background(SocialPalette.goldText)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(SocialPalette.goldSoft)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                .stroke(SocialPalette.goldText.opacity(0.28), lineWidth: 1)
        )
    }

    private func claimThanks() {
            friendManager.claimThanksCoins { coins in
                if coins > 0 {
                    toastMessage = "\(coins)コインを受け取りました"
                } else {
                    alertMessage = "受け取りに失敗しました。時間をおいて再度お試しください。"
                }
            }
    }

    private var segmentPicker: some View {
        SocialSegmentedControl(
            theme: theme,
            items: [
                .init(tag: Segment.friends, title: Segment.friends.rawValue, icon: "person.2.fill"),
                .init(
                    tag: Segment.requests,
                    title: Segment.requests.rawValue,
                    icon: "tray.fill",
                    badge: friendManager.incomingRequests.count
                ),
                .init(tag: Segment.add, title: Segment.add.rawValue, icon: "plus")
            ],
            selection: $segment
        )
    }

    // MARK: - フレンド一覧

    @ViewBuilder
    private var friendsSection: some View {
        VStack(spacing: 12) {
            if let helper = friendManager.activeHelper {
                activeHelperBanner(helper)
            }

            if friendManager.pendingThanksCoins > 0 {
                thanksBanner
            }

            if !isSignedIn {
                SocialErrorState(
                    theme: theme,
                    title: "フレンド情報を読み込めませんでした",
                    message: "通信状況を確認して、もう一度お試しください。"
                ) {
                    load()
                }
                .socialCard(padding: 0)
            } else if friendManager.isLoadingFriends && !hasLoadedFriendsOnce {
                SocialSkeletonList(count: 3)
            } else if friendManager.friends.isEmpty {
                SocialEmptyState(
                    theme: theme,
                    icon: "person.2",
                    title: "フレンドがまだいません",
                    message: "フレンドコードを交換すると、お互いの助っ人を借りられます。",
                    actionTitle: "コードを共有して追加する"
                ) {
                    segment = .add
                }
                .socialCard(padding: 0)
            } else {
                friendCountHeader

                ForEach(sortedFriends) { friend in
                    FriendRowCard(
                        friend: friend,
                        theme: theme,
                        isBorrowing: borrowingFriendId == friend.id,
                        isGreeting: greetingFriendId == friend.id,
                        isCheering: cheeringFriendId == friend.id,
                        isRemoving: removingFriendId == friend.id,
                        selectedHelperOwnerUid: friendManager.activeHelper?.ownerUid,
                        onBorrow: { borrow(friend) },
                        onGreet: { greet(friend) },
                        onCheer: { cheerType in cheer(friend, type: cheerType) },
                        onRemove: { friendPendingRemoval = friend }
                    )
                }
            }
        }
    }

    private var friendCountHeader: some View {
        HStack(spacing: 8) {
            Text("フレンド \(friendManager.friends.count)人")
                .font(.system(size: 14, weight: .semibold))
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.14))
                    Capsule()
                        .fill(theme.gradient)
                        .frame(width: proxy.size.width * min(CGFloat(friendManager.friends.count) / CGFloat(friendLimit), 1))
                }
            }
            .frame(height: 4)
            Text("上限\(friendLimit)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    private func activeHelperBanner(_ helper: ActiveHelper) -> some View {
        HStack(spacing: 11) {
            SocialAvatarThumb(imageName: helper.avatarName, theme: theme, size: 42, ringTone: .success)
            VStack(alignment: .leading, spacing: 2) {
                Text("助っ人を編成しました")
                    .font(.subheadline.weight(.bold))
                Text("\(helper.ownerName)のおとも · 攻撃+\(helper.attackBonus)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("次のダンジョンまたはギルドボス戦で参戦します")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.textAccent)
            }
            Spacer(minLength: 4)
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(SocialPalette.success)
        }
        .socialCard(padding: 13)
        .accessibilityElement(children: .combine)
    }

    private func borrow(_ friend: FriendSummary) {
        borrowingFriendId = friend.id
        friendManager.borrowHelper(from: friend) { result in
            borrowingFriendId = nil
            switch result {
            case .success:
                toastMessage = "\(friend.name)のおともを編成しました。ダンジョンまたはギルドボス戦で参戦します"
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    private func greet(_ friend: FriendSummary) {
        greetingFriendId = friend.id
        friendManager.greet(friend) { result in
            greetingFriendId = nil
            switch result {
            case .success(let points):
                toastMessage = "\(friend.name)とあいさつしました（双方 +\(points)FP）"
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    private func cheer(_ friend: FriendSummary, type: FriendCheerType) {
        cheeringFriendId = friend.id
        friendManager.cheer(friend, type: type) { result in
            cheeringFriendId = nil
            switch result {
            case .success(let deliveredType):
                toastMessage = "\(friend.name)に\(deliveredType.title)を送りました"
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    private func remove(_ friend: FriendSummary) {
        removingFriendId = friend.id
        friendPendingRemoval = nil
        friendManager.removeFriend(uid: friend.id) { success in
            removingFriendId = nil
            if success {
                toastMessage = "\(friend.name)とのフレンドを解除しました"
            } else {
                alertMessage = "解除に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    // MARK: - 申請一覧

    @ViewBuilder
    private var requestsSection: some View {
        VStack(spacing: 10) {
            if friendManager.incomingRequests.isEmpty && friendManager.outgoingRequests.isEmpty {
                SocialEmptyState(
                    theme: theme,
                    icon: "tray",
                    title: "フレンド申請はありません",
                    message: "コードを共有するか、相手のコードを入力して申請を送りましょう。",
                    actionTitle: "コードを共有する"
                ) {
                    segment = .add
                }
                .socialCard(padding: 0)
            } else {
                if !friendManager.incomingRequests.isEmpty {
                    HStack {
                        Text("届いている申請 \(friendManager.incomingRequests.count)件")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text("残り\(max(0, friendLimit - friendManager.friends.count))枠")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    ForEach(friendManager.incomingRequests) { request in
                        FriendRequestCard(
                            request: request,
                            theme: theme,
                            isProcessing: handlingRequestId == request.id,
                            onAccept: { accept(request) },
                            onReject: { reject(request) }
                        )
                    }
                }

                if !friendManager.outgoingRequests.isEmpty {
                    Text("送信済み \(friendManager.outgoingRequests.count)件")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, friendManager.incomingRequests.isEmpty ? 0 : 6)

                    ForEach(friendManager.outgoingRequests) { request in
                        OutgoingFriendRequestCard(
                            request: request,
                            theme: theme,
                            isCanceling: cancelingRequestId == request.id,
                            onCancel: { cancel(request) }
                        )
                    }
                }
            }
        }
    }

    private func accept(_ request: FriendRequestSummary) {
        guard friendManager.friends.count < friendLimit else {
            alertMessage = "フレンドは\(friendLimit)人まで登録できます。誰かを解除してから承認してください。"
            return
        }
        handlingRequestId = request.id
        friendManager.acceptRequest(fromUid: request.id, maxFriendCount: friendLimit) { result in
            handlingRequestId = nil
            switch result {
            case .success:
                friendManager.fetchFriends()
                toastMessage = "\(request.name)とフレンドになりました"
                segment = .friends
            case .failure(let error):
                alertMessage = error.errorDescription
            }
        }
    }

    private func reject(_ request: FriendRequestSummary) {
        handlingRequestId = request.id
        friendManager.rejectRequest(fromUid: request.id) { success in
            handlingRequestId = nil
            if success {
                toastMessage = "\(request.name)の申請を削除しました"
            } else {
                alertMessage = "処理に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    private func cancel(_ request: FriendRequestSummary) {
        cancelingRequestId = request.id
        friendManager.cancelOutgoingRequest(toUid: request.id) { success in
            cancelingRequestId = nil
            if success {
                toastMessage = "\(request.name)への申請を取り消しました"
            } else {
                alertMessage = "取り消しに失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    // MARK: - 追加(自分のコード + コード入力)

    private var addSection: some View {
        VStack(spacing: SocialMetrics.stackSpacing) {
            referralInviteCard
            myCodeCard
            sendRequestCard
        }
    }

    private var referralInviteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SocialPalette.goldSoft)
                        .frame(width: 48, height: 48)
                    Image(systemName: "gift.fill")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(SocialPalette.goldText)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("友達を招待して5,000コイン")
                        .font(.system(size: 16, weight: .bold))
                    Text("招待した人・された人の両方が獲得")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text("友達がアプリをダウンロードし、あなたのコードで最初のフレンドになると、2人にそれぞれ5,000コインをプレゼントします。")
                .font(.system(size: 12.5))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if friendManager.friendCode.isEmpty {
                SocialGradientButton(
                    theme: theme,
                    title: "招待コードを発行中…",
                    icon: "hourglass",
                    isDisabled: true
                ) {}
            } else {
                ShareLink(item: shareText, subject: Text("ITクエストに招待")) {
                    HStack(spacing: 7) {
                        Image(systemName: "paperplane.fill")
                        Text("LINEなどで友達を招待")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: SocialMetrics.tapTarget)
                    .background(theme.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("LINEなどで友達を招待する。双方が5,000コインを獲得できます")
            }

            Label("紹介特典は、招待されたユーザー1人につき1回だけ受け取れます。", systemImage: "checkmark.shield.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.textAccent)
        }
        .socialCard()
    }

    private var myCodeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "qrcode", title: "あなたの招待・フレンドコード")

            HStack(spacing: 10) {
                Text(friendManager.friendCode.isEmpty ? "発行中…" : formattedCode(friendManager.friendCode))
                    .font(.system(.title, design: .monospaced).weight(.bold))
                    .foregroundColor(theme.textAccent)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(theme.softFill)
            .cornerRadius(DesignTokens.Radius.md)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                friendManager.friendCode.isEmpty
                    ? "フレンドコードを発行中"
                    : "あなたのフレンドコードは\(friendManager.friendCode.map(String.init).joined(separator: " "))"
            )

            HStack(spacing: 10) {
                SocialSecondaryButton(
                    theme: theme,
                    title: didCopyCode ? "コピーしました" : "コピー",
                    icon: didCopyCode ? "checkmark" : "doc.on.doc",
                    isDisabled: friendManager.friendCode.isEmpty
                ) {
                    copyCode()
                }

                if !friendManager.friendCode.isEmpty {
                    ShareLink(item: shareText) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                            Text("共有")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: SocialMetrics.tapTarget)
                        .background(theme.gradient)
                        .cornerRadius(DesignTokens.Radius.md)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("フレンドコードを共有する")
                }
            }

            Text("コードを渡すと相手から申請が届きます。相手の最初のフレンドとして成立すると、双方に5,000コインが贈られます。")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .socialCard()
    }

    private var shareText: String {
        """
        ITクエストで一緒に勉強しよう！📚✨
        問題を解いておともを育てたり、ダンジョンやギルドボスに挑戦できるよ！

        招待コード：\(friendManager.friendCode)
        このコードで最初のフレンドになると、2人とも5,000コイン獲得！

        アプリをダウンロード👇
        \(FriendReferralPolicy.appStoreURL)
        """
    }

    private func copyCode() {
        UIPasteboard.general.string = friendManager.friendCode
        didCopyCode = true
        toastMessage = "フレンドコードをコピーしました"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            didCopyCode = false
        }
    }

    private var isFriendLimitReached: Bool {
        friendManager.friends.count >= friendLimit
    }

    private var sendRequestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SocialSectionTitle(theme: theme, icon: "number", title: "フレンドコードで追加")

            ZStack {
                HStack(spacing: 7) {
                    ForEach(0..<6, id: \.self) { index in
                        let character = codeCharacter(at: index)
                        Text(character.map(String.init) ?? "")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(index == codeInput.count ? theme.textAccent : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(SocialPalette.insetSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        index == codeInput.count ? theme.textAccent : SocialPalette.separator,
                                        lineWidth: index == codeInput.count ? 2 : 1
                                    )
                            )
                    }
                }

                TextField("123456", text: $codeInput)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isCodeInputFocused)
                    .foregroundColor(.clear)
                    .tint(.clear)
                    .opacity(0.02)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
                    .accessibilityLabel("フレンドコード入力欄。6桁の数字")
                    .onChange(of: codeInput) { newValue in
                        let digitsOnly = newValue.filter(\.isNumber)
                        let trimmed = String(digitsOnly.prefix(6))
                        if trimmed != newValue { codeInput = trimmed }
                        addErrorMessage = nil
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isCodeInputFocused = true
            }

            if isFriendLimitReached {
                SocialTagChip(
                    text: "フレンドは\(friendLimit)人が上限です",
                    icon: "exclamationmark.triangle.fill",
                    tone: .warning
                )
            }

            if let addErrorMessage {
                Label(addErrorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundColor(SocialPalette.danger)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !codeInput.isEmpty, codeInput.count < 6 {
                Label("あと\(6 - codeInput.count)桁入力してください", systemImage: "exclamationmark.circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundColor(SocialPalette.danger)
            }

            SocialGradientButton(
                theme: theme,
                title: "フレンド申請を送る",
                icon: "paperplane.fill",
                isLoading: isSendingRequest,
                isDisabled: codeInput.count != 6 || isFriendLimitReached,
                accessibilityHintText: codeInput.count != 6 ? "6桁のコードを入力すると押せます" : nil
            ) {
                sendRequest()
            }
        }
        .socialCard()
    }

    private func sendRequest() {
        isSendingRequest = true
        addErrorMessage = nil
        friendManager.sendFriendRequest(code: codeInput, maxFriendCount: friendLimit) { result in
            isSendingRequest = false
            switch result {
            case .success:
                codeInput = ""
                friendManager.fetchFriends()
                toastMessage = "フレンド申請を送りました"
            case .failure(let error):
                addErrorMessage = error.errorDescription
            }
        }
    }

    private func codeCharacter(at index: Int) -> Character? {
        guard codeInput.indices.contains(codeInput.index(codeInput.startIndex, offsetBy: index, limitedBy: codeInput.endIndex) ?? codeInput.endIndex) else {
            return nil
        }
        let target = codeInput.index(codeInput.startIndex, offsetBy: index)
        return codeInput[target]
    }

    private func formattedCode(_ code: String) -> String {
        guard code.count == 6 else { return code }
        let mid = code.index(code.startIndex, offsetBy: 3)
        return "\(code[..<mid]) \(code[mid...])"
    }
}

// MARK: - 助っ人履歴

private struct HelperHistoryView: View {
    private let theme: SocialTheme = .friend

    @ObservedObject var friendManager: FriendManager

    var body: some View {
        VStack(spacing: 0) {
            SocialCompactHeader(
                theme: theme,
                title: "助っ人履歴",
                subtitle: "フレンドがあなたの助っ人を使った記録",
                icon: "clock.arrow.circlepath"
            ) {
                EmptyView()
            }

            ScrollView {
                VStack(spacing: 12) {
                    if friendManager.isLoadingHelperHistory {
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("履歴を読み込み中…")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 36)
                        .socialCard()
                    } else if friendManager.helperHistory.isEmpty {
                        SocialEmptyState(
                            theme: theme,
                            icon: "clock.arrow.circlepath",
                            title: "助っ人履歴はありません",
                            message: "フレンドがあなたのおともを使うと、ここに履歴が表示されます。"
                        )
                        .socialCard(padding: 0)
                    } else {
                        ForEach(friendManager.helperHistory) { entry in
                            HStack(spacing: 12) {
                                SocialAvatarThumb(imageName: entry.avatarName, theme: theme, size: 42)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(entry.borrowerName)さんが助っ人を使用")
                                        .font(.system(size: 14, weight: .semibold))
                                        .lineLimit(1)
                                    Text(entry.avatarName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer(minLength: 4)

                                Text(historyDateText(entry.usedAt))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .socialCard(padding: 13)
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.vertical, 12)
            }
            .refreshable {
                friendManager.fetchHelperHistory()
            }
        }
        .socialScreen(theme)
        .navigationBarHidden(true)
        .onAppear { friendManager.fetchHelperHistory() }
    }

    private func historyDateText(_ timestamp: TimeInterval) -> String {
        guard timestamp > 0 else { return "日時不明" }
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = Calendar.current.isDateInToday(date) ? "今日 H:mm" : "M/d H:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 助っ人おともの説明

private struct HelperBorrowHelpView: View {
    private let theme: SocialTheme = .friend

    @Environment(\.presentationMode) private var presentationMode

    private struct HelpItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
    }

    private let items: [HelpItem] = [
        HelpItem(
            icon: "bolt.fill",
            title: "何を借りられる？",
            body: "フレンドが今装備しているおともの攻撃力を、そのまま丸ごと自分の攻撃力に上乗せできます。HPなど他のステータスは対象外です。"
        ),
        HelpItem(
            icon: "flag.checkered",
            title: "どこで使える？",
            body: "借りた助っ人は、次に挑む1回の戦闘だけで消費されます。ダンジョンのクイズ戦闘、またはギルドボス戦で一緒に戦えます。"
        ),
        HelpItem(
            icon: "calendar",
            title: "借りられる回数",
            body: "同じフレンドからは1日1回まで(端末の日付が変わるとリセット)。編成できる助っ人は同時に1人だけなので、借りたら使い切ってから次を借ります。"
        ),
        HelpItem(
            icon: "person.crop.circle.badge.exclamationmark",
            title: "借りるための条件",
            body: "フレンドがおともを装備していない場合は借りられません。"
        ),
        HelpItem(
            icon: "gift.fill",
            title: "貸したフレンドへの特典",
            body: "あなたのおともを誰かが借りるたびに「お礼コイン」が20枚貯まり、フレンド画面から受け取れます。誰が借りたかの履歴も確認できます。"
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .fill(theme.softFill)
                                    .frame(width: 34, height: 34)
                                Image(systemName: item.icon)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(theme.textAccent)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.system(size: 14.5, weight: .bold))
                                Text(item.body)
                                    .font(.system(size: 12.5))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .socialCard()
                    }
                }
                .padding(.horizontal, SocialMetrics.screenPadding)
                .padding(.vertical, 12)
            }
            .socialScreen(theme)
            .navigationTitle("助っ人おともについて")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - フレンド1件

private struct FriendRowCard: View {
    let friend: FriendSummary
    let theme: SocialTheme
    let isBorrowing: Bool
    let isGreeting: Bool
    let isCheering: Bool
    let isRemoving: Bool
    let selectedHelperOwnerUid: String?
    let onBorrow: () -> Void
    let onGreet: () -> Void
    let onCheer: (FriendCheerType) -> Void
    let onRemove: () -> Void

    private var hasHelper: Bool { friend.featuredAvatarName != nil }
    private var isSelectedHelper: Bool { selectedHelperOwnerUid == friend.id }
    private var canBorrow: Bool { hasHelper && friend.canBorrowToday && selectedHelperOwnerUid == nil }

    private var helperChip: SocialTagChip {
        if !hasHelper {
            return SocialTagChip(text: "おとも未設定", icon: "questionmark.circle", tone: .neutral)
        }
        if isSelectedHelper {
            return SocialTagChip(text: "出撃待ち", icon: "checkmark.seal.fill", tone: .success)
        }
        if selectedHelperOwnerUid != nil {
            return SocialTagChip(text: "助っ人編成済み", icon: "person.2.fill", tone: .neutral)
        }
        if friend.canBorrowToday {
            return SocialTagChip(text: "助っ人OK", icon: "bolt.fill", tone: .success)
        }
        return SocialTagChip(text: "本日利用済み", icon: "checkmark.circle.fill", tone: .neutral)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                SocialAvatarThumb(
                    imageName: friend.featuredAvatarName,
                    theme: theme,
                    ringTone: canBorrow ? .success : nil
                )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(friend.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        SocialTagChip(text: "Lv.\(friend.level)", tone: .theme(theme))
                    }

                    Label("最終ログイン \(lastLoginText)", systemImage: "clock.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Calendar.current.isDateInToday(lastLoginDate ?? .distantPast) ? SocialPalette.success : .secondary)

                    HStack(spacing: 5) {
                        helperChip
                        if hasHelper {
                            Text("攻撃+\(max(1, friend.featuredAvatarAttack)) のおとも")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        } else {
                            Text("おともが選択されていません")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer(minLength: 4)

                Menu {
                    Button(role: .destructive, action: onRemove) {
                        Label("フレンドを解除", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.secondary)
                        .frame(width: SocialMetrics.tapTarget, height: SocialMetrics.tapTarget)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("\(friend.name)のその他の操作")
                .accessibilityHint("フレンド解除ができます")
            }
            .accessibilityElement(children: .contain)

            HStack(spacing: 8) {
                SocialPillButton(
                    title: friend.canGreetToday ? "あいさつ +5FP" : "あいさつ済み",
                    colors: [theme.accent, SocialPalette.goldText],
                    icon: friend.canGreetToday ? "hand.wave.fill" : "checkmark",
                    isEnabled: friend.canGreetToday,
                    isLoading: isGreeting,
                    fillWidth: true,
                    accessibilityHintText: friend.canGreetToday ? "双方が5フレンドポイントを受け取ります" : nil,
                    action: onGreet
                )
                .frame(maxWidth: .infinity)

                cheerMenu
                    .frame(maxWidth: .infinity)
            }

            SocialPillButton(
                title: borrowTitle,
                colors: theme.colors,
                icon: "sparkles",
                isEnabled: canBorrow,
                isLoading: isBorrowing,
                fillWidth: true,
                accessibilityHintText: canBorrow ? "次のダンジョンまたはギルドボス戦に\(friend.name)のおともが参戦します" : nil,
                action: onBorrow
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(isRemoving ? 0.5 : 1)
        .socialCard(padding: 12)
    }

    private var borrowTitle: String {
        if !hasHelper { return "おとも未設定" }
        if isSelectedHelper { return "次の共闘に編成済み" }
        if selectedHelperOwnerUid != nil { return "助っ人を編成済み" }
        return friend.canBorrowToday ? "助っ人を借りる" : "明日また借りられます"
    }

    private var cheerMenu: some View {
        Menu {
            ForEach(FriendCheerType.allCases) { type in
                Button {
                    onCheer(type)
                } label: {
                    Label(type.title, systemImage: type.icon)
                }
            }
        } label: {
            Group {
                if isCheering {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: friend.canCheerToday ? "megaphone.fill" : "checkmark")
                            .font(.system(size: 11, weight: .bold))
                        Text(friend.canCheerToday ? "応援を送る" : "応援済み")
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
            }
            .foregroundColor(friend.canCheerToday ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 34)
            .padding(.horizontal, 10)
            .background(
                Group {
                    if friend.canCheerToday {
                        LinearGradient(
                            colors: [SocialPalette.goldText, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.socialDynamic(light: Color(hex: "eaecf0"), dark: Color(hex: "3a3d44"))
                    }
                }
            )
            .clipShape(Capsule())
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
        .disabled(!friend.canCheerToday || isCheering)
        .accessibilityLabel(friend.canCheerToday ? "応援を選んで送る" : "今日は応援済み")
    }

    private var lastLoginDate: Date? {
        guard let timestamp = friend.lastLoginDate else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    private var lastLoginText: String {
        guard let date = lastLoginDate else { return "不明" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "今日" }
        if calendar.isDateInYesterday(date) { return "昨日" }
        let days = max(0, calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0)
        if days <= 30 { return "\(days)日前" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - 申請1件

private struct FriendRequestCard: View {
    let request: FriendRequestSummary
    let theme: SocialTheme
    let isProcessing: Bool
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                SocialAvatarThumb(imageName: nil, theme: theme, size: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(request.name)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                    HStack(spacing: 5) {
                        SocialTagChip(text: "Lv.\(request.level)", icon: "star.fill", tone: .theme(theme))
                        SocialTagChip(text: "申請が届いています", icon: "envelope.fill", tone: .warning)
                    }
                }

                Spacer(minLength: 4)
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 8) {
                Button(action: onReject) {
                    Text("削除")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: SocialMetrics.tapTarget)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                                .fill(SocialTone.neutral.background)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isProcessing)
                .accessibilityLabel("\(request.name)の申請を削除")

                SocialGradientButton(
                    theme: theme,
                    title: "承認する",
                    icon: "checkmark",
                    isLoading: isProcessing,
                    accessibilityHintText: "承認すると\(request.name)とフレンドになります",
                    action: onAccept
                )
            }
        }
        .socialCard(padding: 12)
    }
}

private struct OutgoingFriendRequestCard: View {
    let request: FriendRequestSummary
    let theme: SocialTheme
    let isCanceling: Bool
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SocialAvatarThumb(imageName: nil, theme: theme, size: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(request.name)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    SocialTagChip(text: "Lv.\(request.level)", icon: "star.fill", tone: .theme(theme))
                    SocialTagChip(text: "承認待ち", icon: "clock.fill", tone: .neutral)
                }
            }

            Spacer(minLength: 4)

            Button(action: onCancel) {
                Group {
                    if isCanceling {
                        ProgressView()
                    } else {
                        Text("取り消す")
                            .font(.footnote.weight(.semibold))
                    }
                }
                .foregroundColor(SocialPalette.danger)
                .frame(minWidth: 72, minHeight: SocialMetrics.tapTarget)
                .background(SocialTone.danger.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            }
            .buttonStyle(.plain)
            .disabled(isCanceling)
            .accessibilityLabel("\(request.name)への申請を取り消す")
        }
        .socialCard(padding: 12)
    }
}

// MARK: - プレビュー

#if DEBUG
struct FriendListView_Previews: PreviewProvider {
    private static let ready = FriendSummary(
        id: "1",
        name: "たろう",
        level: 24,
        featuredAvatarName: nil,
        featuredAvatarAttack: 40,
        canBorrowToday: true
    )
    private static let used = FriendSummary(
        id: "2",
        name: "とてもながいなまえのフレンドさん",
        level: 7,
        featuredAvatarName: nil,
        featuredAvatarAttack: 0,
        canBorrowToday: false
    )

    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 10) {
                    FriendRowCard(
                        friend: ready,
                        theme: .friend,
                        isBorrowing: false,
                        isGreeting: false,
                        isCheering: false,
                        isRemoving: false,
                        selectedHelperOwnerUid: nil,
                        onBorrow: {},
                        onGreet: {},
                        onCheer: { _ in },
                        onRemove: {}
                    )
                    FriendRowCard(
                        friend: used,
                        theme: .friend,
                        isBorrowing: true,
                        isGreeting: false,
                        isCheering: false,
                        isRemoving: false,
                        selectedHelperOwnerUid: nil,
                        onBorrow: {},
                        onGreet: {},
                        onCheer: { _ in },
                        onRemove: {}
                    )
                    FriendRequestCard(
                        request: FriendRequestSummary(id: "3", name: "はなこ", level: 12),
                        theme: .friend,
                        isProcessing: false,
                        onAccept: {},
                        onReject: {}
                    )
                    FriendRequestCard(
                        request: FriendRequestSummary(id: "4", name: "じろう", level: 3),
                        theme: .friend,
                        isProcessing: true,
                        onAccept: {},
                        onReject: {}
                    )
                }
                .padding()
            }
            .socialScreen(.friend)
            .previewDisplayName("フレンド行 / ライト")

            ScrollView {
                VStack(spacing: 10) {
                    SocialSkeletonList(count: 2)
                    SocialEmptyState(
                        theme: .friend,
                        icon: "person.2",
                        title: "フレンドがまだいません",
                        message: "フレンドコードを交換すると、お互いの助っ人を借りられます。",
                        actionTitle: "コードを共有して追加する"
                    ) {}
                    .socialCard(padding: 0)
                }
                .padding()
            }
            .socialScreen(.friend)
            .preferredColorScheme(.dark)
            .previewDisplayName("読み込み・空 / ダーク")
        }
    }
}
#endif
