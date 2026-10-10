import SwiftUI

private enum UpdateStyle {
    static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.77, blue: 0.49, alpha: 1)
            : UIColor(red: 0.43, green: 0.30, blue: 0.12, alpha: 1)
    })
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
}

struct AppUpdateBellButton: View {
    let action: () -> Void
    @AppStorage(AppUpdateReadState.storageKey) private var readIDs = Data()

    private var isUnread: Bool {
        !AppUpdateReadState.contains(AppUpdate.latest.id, in: readIDs)
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(UpdateStyle.accent)
                .frame(width: 32, height: 32)
                .background(UpdateStyle.surface, in: Circle())
                .overlay(alignment: .topTrailing) {
                    if isUnread {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(UpdateStyle.surface, lineWidth: 2))
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("アップデート情報")
        .accessibilityValue(isUnread ? "未読のお知らせがあります" : "既読")
        .accessibilityHint("最新のアップデート情報を開きます")
        .accessibilityIdentifier("updates.home.entry")
    }
}

private struct UpdateNewBadge: View {
    var body: some View {
        Text("NEW")
            .font(.caption2.bold())
            .foregroundStyle(UpdateStyle.accent)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(UpdateStyle.accent.opacity(0.12), in: Capsule())
            .accessibilityLabel("未読")
    }
}

struct AppUpdateSheet: View {
    let update: AppUpdate
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AppUpdateDetailView(update: update, showsHistoryLink: true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("閉じる") { dismiss() }
                            .accessibilityIdentifier("updates.close")
                    }
                }
        }
        .tint(UpdateStyle.accent)
    }
}

struct AppUpdateDetailView: View {
    let update: AppUpdate
    var showsHistoryLink = false
    @AppStorage(AppUpdateReadState.storageKey) private var readIDs = Data()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("バージョン \(update.version)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(update.title)
                        .font(.title.bold())
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(update.introduction)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(update.features) { feature in
                    UpdateFeatureCard(feature: feature)
                }
                if showsHistoryLink {
                    NavigationLink {
                        AppUpdateHistoryView().appNavigationBackButton()
                    } label: {
                        Label("過去のアップデート", systemImage: "clock.arrow.circlepath")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("updates.history.entry")
                }
            }
            .padding(20)
        }
        .background(UpdateStyle.background)
        .navigationTitle("アップデート情報")
        .navigationBarTitleDisplayMode(.inline)
        .tint(UpdateStyle.accent)
        .onAppear {
            readIDs = AppUpdateReadState.markingRead(update.id, in: readIDs)
        }
        .accessibilityIdentifier("updates.detail")
    }
}

private struct UpdateFeatureCard: View {
    let feature: AppUpdate.Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: feature.symbol)
                    .font(.title3)
                    .foregroundStyle(UpdateStyle.accent)
                    .frame(width: 25)
                    .accessibilityHidden(true)
                Text(feature.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
            Text(feature.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let notice = feature.notice {
                Label(notice, systemImage: "hourglass")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(UpdateStyle.accent)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(UpdateStyle.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UpdateStyle.surface, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct AppUpdateHistoryView: View {
    @AppStorage(AppUpdateReadState.storageKey) private var readIDs = Data()

    var body: some View {
        List {
            ForEach(AppUpdate.history) { update in
                NavigationLink {
                    AppUpdateDetailView(update: update).appNavigationBackButton()
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("バージョン \(update.version)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !AppUpdateReadState.contains(update.id, in: readIDs) {
                                UpdateNewBadge()
                            }
                        }
                        Text(update.title.replacingOccurrences(of: "\n", with: ""))
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 6)
                }
                .accessibilityIdentifier("updates.history.\(update.id)")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("アップデート履歴")
        .navigationBarTitleDisplayMode(.inline)
        .tint(UpdateStyle.accent)
    }
}

#if DEBUG
struct AppUpdatePreview: View {
    @State private var presentedUpdate: AppUpdate? = AppUpdate.latest

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AppUpdateBellButton { presentedUpdate = AppUpdate.latest }
                NavigationLink("アップデート履歴") {
                    AppUpdateHistoryView().appNavigationBackButton()
                }
            }
            .padding(20)
            .navigationTitle("ホーム")
            .sheet(item: $presentedUpdate) { update in
                AppUpdateSheet(update: update)
            }
        }
        .defaultAppStorage(UserDefaults(suiteName: "updates.preview") ?? .standard)
    }
}

struct AppUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        AppUpdatePreview()
        AppUpdatePreview().preferredColorScheme(.dark)
        AppUpdatePreview()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
#endif
