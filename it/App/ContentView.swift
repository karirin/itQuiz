//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//  Updated UI/UX Design 2026
//

import SwiftUI
import AVFoundation
import UserNotifications

// MARK: - Modern UI Components

/// モダンなユーザー名表示
struct ModernUserNameBar: View {
    let userName: String
    let streakCount: Int
    let badgeLabels: [String]
    let onTapRegister: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .semibold))
                    )

                if userName.isEmpty {
                    Button(action: onTapRegister) {
                        HStack(spacing: 4) {
                            Text("名前を登録")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                } else {
                    Text(userName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("fontGray"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                }
            }

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

/// モダンなコインバー
struct ModernCoinBar: View {
    let coins: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            // コインアイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: .orange.opacity(0.5), radius: 3, x: 0, y: 2)
                
                Text("¢")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text("\(coins)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color("fontGray"))
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .onChange(of: coins) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
}

/// モダンなレベル表示と経験値バー
struct ModernLevelBar: View {
    let level: Int
    let experience: Int
    let maxExperience: Int
    
    private var progress: CGFloat {
        guard maxExperience > 0 else { return 0 }
        return CGFloat(experience) / CGFloat(maxExperience)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // レベルバッジ
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .purple.opacity(0.4), radius: 4, x: 0, y: 2)
                
                VStack(spacing: -2) {
                    Text("Lv")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(level)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // 経験値バー
            ProgressExpBar(level: level, experience: experience)
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    Text("経験値")
//                        .font(.system(size: 11, weight: .medium))
//                        .foregroundColor(.secondary)
//                    Spacer()
//                    Text("\(experience) / \(maxExperience)")
//                        .font(.system(size: 11, weight: .semibold, design: .rounded))
//                        .foregroundColor(Color("fontGray"))
//                }
//                
//                GeometryReader { geometry in
//                    ZStack(alignment: .leading) {
//                        // 背景
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(Color.gray.opacity(0.2))
//                        
//                        // プログレス
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(
//                                LinearGradient(
//                                    colors: [Color.blue, Color.purple],
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .frame(width: geometry.size.width * progress)
//                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
//                        
//                        // シャイン効果
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(
//                                LinearGradient(
//                                    colors: [.white.opacity(0.3), .clear],
//                                    startPoint: .top,
//                                    endPoint: .center
//                                )
//                            )
//                            .frame(width: geometry.size.width * progress)
//                    }
//                }
//                .frame(height: 12)
//            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

/// モダンなステータスカード
struct ModernStatusCard: View {
    let avatarName: String
    let hp: Int
    let baseHp: Int
    let bonusHp: Int
    let attack: Int
    let baseAttack: Int
    let bonusAttack: Int
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: isSmallDevice() ? 0 : -20) {
                ZStack{
                    Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isSmallDevice() ? 150 : 200)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 5, y: 5)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: 0)
                }
                .padding(.trailing, isSmallDevice() ? 20 : 20)
                HStack{
                    VStack{
                        VStack(spacing:0){
                            ZStack {
                                Image("ハートバー")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: isSmallDevice() ? 40 : 40)
                                Text("\(baseHp as? Int ?? 0)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 20))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .padding(.leading,45)
                                    .padding(.top,10)
                            }
                            HStack(spacing:3){
                                ZStack{
                                    Image("上昇バー１")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: isSmallDevice() ? 30 : 30)
                                    HStack(spacing: 0){
                                        Text("＋\(bonusHp as? Int ?? 0)")
                                            .padding(.top,3)
                                            .font(.system(size: 18))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .fixedSize(horizontal: true, vertical: false)
                                        Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:isSmallDevice() ? 30 : 40)
                                            .padding(.top,8)
                                    }
                                    .padding(.leading,40)
                                    .frame(minWidth: isSmallDevice() ? 92 : 108, alignment: .leading)
                                }.padding(.leading,40)
                            }
                        }
                        VStack(spacing:0){
                            ZStack {
                                Image("攻撃バー")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height:isSmallDevice() ? 40 : 40)
                                Text("\(baseAttack as? Int ?? 0)")
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading,45)
                                    .padding(.top,8)
                                    .font(.system(size: 20))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            HStack(spacing:3){
                                ZStack{
                                    Image("上昇バー２")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:isSmallDevice() ? 30 : 30)
                                    HStack(spacing: 0){
                                        Text("＋\(bonusAttack as? Int ?? 0)")
                                            .padding(.top,3)
                                            .font(.system(size:18))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .fixedSize(horizontal: true, vertical: false)
                                        Image(avatarName.isEmpty ? "defaultIcon" : (avatarName as? String) ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:isSmallDevice() ? 30 : 40)
                                            .padding(.top,8)
                                    }
                                    .padding(.leading,40)
                                    .frame(minWidth: isSmallDevice() ? 92 : 108, alignment: .leading)
                                }.padding(.leading,40)
                            }
                        }
                    }
                }
                .padding(.top, isSmallDevice() ? 10 : 0)
            }
        }
    }
}

/// ステータス行コンポーネント
struct ModernStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int
    let bonus: Int
    let avatarName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // メインステータス
            HStack(spacing: 8) {
                // アイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(value)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color("fontGray"))
                }
                
                Spacer()
            }
            
            // ボーナス表示
            if bonus > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("+\(bonus)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Image(avatarName.isEmpty ? "defaultIcon" : avatarName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
    }
}

/// モダンなお問い合わせボタン
struct ModernHelpButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("ヘルプ")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Compact Home Components

private enum CompactHomePalette {
    static let canvas = Color(uiColor: .systemGroupedBackground)
    static let card = Color(uiColor: .secondarySystemGroupedBackground)
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let divider = Color(uiColor: .separator).opacity(0.28)
    static let shadow = Color.black.opacity(0.07)
}

private enum CompactHomeIcon {
    case asset(String)
    case symbol(String)
}

private struct CompactHomeSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(CompactHomePalette.primaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(.thinMaterial)
                        .overlay {
                            Capsule()
                                .fill(Color.white.opacity(0.48))
                        }
                }
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.88), lineWidth: 0.8)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(height: 1)
                .shadow(color: Color.black.opacity(0.16), radius: 1, x: 0, y: 1)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

private struct HomeModeTile: View {
    let title: String
    let artworkName: String
    var aspectRatio: CGFloat = 1.9
    var artworkVerticalPadding: CGFloat = 4
    var artworkContentBounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    var stretchesArtworkToFrame = false
    var isComingSoon = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.34), Color.white.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                GeometryReader { geometry in
                    // 透明な余白を除く。横並びのボタンは絵の幅・高さを共通の枠に揃える。
                    let sourceSize = UIImage(named: artworkName)?.size ?? CGSize(width: 1, height: 1)
                    let contentWidth = sourceSize.width * artworkContentBounds.width
                    let contentHeight = sourceSize.height * artworkContentBounds.height
                    let scale = min(geometry.size.width / contentWidth, geometry.size.height / contentHeight)
                    let scaleX = stretchesArtworkToFrame ? geometry.size.width / contentWidth : scale
                    let scaleY = stretchesArtworkToFrame ? geometry.size.height / contentHeight : scale

                    Image(artworkName)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: sourceSize.width * scaleX, height: sourceSize.height * scaleY)
                        .offset(
                            x: (geometry.size.width - contentWidth * scaleX) / 2
                                - sourceSize.width * artworkContentBounds.minX * scaleX,
                            y: (geometry.size.height - contentHeight * scaleY) / 2
                                - sourceSize.height * artworkContentBounds.minY * scaleY
                        )
                        .saturation(isComingSoon ? 0 : 1)
                        .opacity(isComingSoon ? 0.55 : 1)
                }
                .clipped()
                .padding(.horizontal, 8)
                .padding(.vertical, artworkVerticalPadding)

                if isComingSoon {
                    Text("準備中")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.75), in: Capsule())
                }
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(PressedEffectStyle())
        .disabled(isComingSoon)
        .accessibilityLabel(isComingSoon ? "\(title)、準備中" : title)
        .accessibilityIdentifier("home.mode.\(title)")
    }
}

private struct CompactHomeFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: CompactHomeIcon
    let accent: Color
    var badge: Int = 0
    var progress: Double? = nil
    var progressLabel: String? = nil
    var artworkName: String? = nil
    var artworkIsSquare: Bool = false
    var artworkIsWide: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if let artworkName {
                artworkView(artworkName)
                    .overlay(alignment: .topTrailing) {
                        notificationBadge
                            .padding(10)
                    }
            } else {
                HStack(spacing: 10) {
                    iconView
                        .overlay(alignment: .topTrailing) {
                            notificationBadge
                                .offset(x: 4, y: -4)
                        }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(CompactHomePalette.primaryText)
                            .lineLimit(1)

                        if let progress {
                            HStack(spacing: 6) {
                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color(uiColor: .systemGray5))
                                        Capsule()
                                            .fill(accent)
                                            .frame(width: proxy.size.width * min(max(progress, 0), 1))
                                    }
                                }
                                .frame(height: 5)

                                if let progressLabel {
                                    Text(progressLabel)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(accent)
                                        .lineLimit(1)
                                }
                            }
                        } else {
                            Text(subtitle)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(CompactHomePalette.secondaryText)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.34),
                                            Color.white.opacity(0.12)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .buttonStyle(PressedEffectStyle())
        .accessibilityLabel(
            badge > 0
                ? "\(title)、\(subtitle)、新着\(badge)件"
                : "\(title)、\(subtitle)"
        )
    }

    @ViewBuilder
    private func artworkView(_ name: String) -> some View {
        if artworkIsSquare {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                GeometryReader { proxy in
                    Image(name)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                .padding(8)
            }
            .aspectRatio(1.22, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else if artworkIsWide {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                GeometryReader { proxy in
                    Image(name)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .padding(6)
            }
            .aspectRatio(3.65, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            Image(name)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    @ViewBuilder
    private var notificationBadge: some View {
        if badge > 0 {
            Text("\(min(badge, 99))")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .frame(minWidth: 19, minHeight: 19)
                .background(Color(red: 0.96, green: 0.32, blue: 0.43), in: Capsule())
                .accessibilityLabel("通知\(badge)件")
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .asset(let name):
            Image(name)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(accent, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
    }
}

private struct CompactHomeProfileCard: View {
    let userName: String
    let avatarName: String
    let coins: Int
    let level: Int
    let experience: Int
    let maxExperience: Int
    let hp: Int
    let hpBonus: Int
    let attack: Int
    let attackBonus: Int
    let registerName: () -> Void
    let showUpdates: () -> Void

    private var progress: Double {
        guard maxExperience > 0 else { return 0 }
        return min(max(Double(experience) / Double(maxExperience), 0), 1)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Color.clear
                .frame(width: 72, height: 82)
                .overlay(
                    Image(avatarName.isEmpty ? "defaultIcon" : avatarName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 108, height: 123)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 4) {
                    Text(userName.isEmpty ? "ゲスト" : userName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(CompactHomePalette.primaryText)
                        .lineLimit(1)

                    if userName.isEmpty {
                        Button(action: registerName) {
                            Label("名前を登録", systemImage: "pencil")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.pink)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.1), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                    }

                    Spacer(minLength: 4)

                    Label("\(coins)", systemImage: "dollarsign.circle.fill")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.64, green: 0.43, blue: 0.04))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color.yellow.opacity(0.2), in: Capsule())

                    AppUpdateBellButton(action: showUpdates)
                }

                HStack(spacing: 8) {
                    Text("Lv.\(level)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.indigo)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.indigo.opacity(0.1), in: Capsule())

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(uiColor: .systemGray5))
                            Capsule()
                                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * progress)
                        }
                    }
                    .frame(height: 7)

                    Text("\(experience) / \(maxExperience)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(CompactHomePalette.secondaryText)
                        .monospacedDigit()
                }

                HStack(spacing: 8) {
                    statChip(symbol: "heart.fill", title: "HP \(hp)", bonus: hpBonus, color: .pink)
                    statChip(symbol: "bolt.fill", title: "攻撃 \(attack)", bonus: attackBonus, color: .orange)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.34),
                                    Color.white.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private func statChip(symbol: String, title: String, bonus: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .fixedSize()
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)

            if bonus > 0 {
                Spacer(minLength: 0)

                HStack(spacing: 3) {
                    Image(avatarName.isEmpty ? "defaultIcon" : avatarName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .fixedSize()

                    Text("+\(bonus)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(width: 54, height: 24)
                .background(Color.white.opacity(0.58), in: Capsule())
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(3)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("おともによる補正、プラス\(bonus)")
            }
        }
        .font(.system(size: 9.5, weight: .bold))
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.1), in: Capsule())
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preference Key
struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject private var missionManager = MissionManager.shared
    @ObservedObject private var friendManager = FriendManager.shared
    @ObservedObject private var battleManager = BattleManager.shared
    @ObservedObject private var guildManager = GuildManager.shared
    @ObservedObject private var storyViewModel = PositionViewModel.shared
    @ObservedObject private var notificationRouter = AppNotificationRouter.shared
    @ObservedObject private var pushNotificationService = PushNotificationService.shared
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userCsFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isPresentingSettingList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    @State private var storyAdventureDestination: AdventureMapStyle?
    @State private var isPresentingGachaView: Bool = false
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingContactView: Bool = false
    @State private var isPresentingTimeAttakView: Bool = false
    @State private var isPresentingTittleView: Bool = false
    @State private var isPresentingIllustratedView: Bool = false
    @State private var isPresentingPentagonView: Bool = false
    @State private var isPresentingRankingView: Bool = false
    @State private var isPresentingFriendView: Bool = false
    @State private var isPresentingGuildView: Bool = false
    @State private var isPresentingWeeklyLeagueView: Bool = false
    @State private var isPresentingReviewFromNotification: Bool = false
    @State private var isPresentingITReview: Bool = false
    @State private var isPresentingInitialDiagnostic: Bool = false
    @State private var initialPracticeSessionID = UUID()
    @State private var initialLearningFlow = InitialLearningFlow(
        hasSeenWelcome: UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
        hasPendingNameRegistration: UserDefaults.standard.bool(forKey: "onboarding.needsNameRegistration")
    )
    @ObservedObject private var learningTour = InitialLearningTour.shared
    @AppStorage("growth.analytics.initialDiagnosticCompleted") private var hasCompletedInitialPractice = false
    @AppStorage("onboarding.hasSeenReviewReminder") private var hasSeenReviewReminder = false
    @AppStorage("onboarding.offersInitialPractice") private var offersInitialPractice = false
    @AppStorage("onboarding.needsNameRegistration") private var needsInitialNameRegistration = false
    @State private var isPresentingDailyQuickQuiz: Bool = false
    @State private var reviewSummary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)
    @State private var dailyReviewProgress: DailyReviewProgress?
    @State private var dailyQuickQuizProgress: DailyQuickQuizProgress?
    @State private var dailyLearningLoadedUserId: String?
    @State private var dailyLearningContext: LearningEntryContext?
    @State private var scheduledReviewContext: LearningEntryContext?
    @State private var recordedLearningImpressions: Set<String> = []
    @State private var reviewSummaryRequestID = UUID()
    @State private var friendInitialSection: FriendListInitialSection = .friends
    @State private var weeklyLeagueNotificationLaunch: WeeklyLeagueNotificationLaunch?
    @State private var isPresentingMissionView: Bool = false
    @State private var audioPlayerKettei: AVAudioPlayer?
    @ObservedObject var audioManager = AudioManager.shared
    @State private var isSoundOn: Bool = true
    @State private var isLoading: Bool = true
    @State private var isShowingLoginBonus = false
    @State private var showLoginModal: Bool = false
    @StateObject private var interstitial = Interstitial()
    @StateObject private var reward = Reward()
    @State private var rewardFlag: Int = 0
    @State private var customerFlag: Bool = false
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @State private var preFlag: Bool = false
    @State private var helpFlag: Bool = false
    @State private var csFlag: Bool = false
    @State private var isInitializingUser = false
    @State private var hasInitializedUserForSession = false
    @State private var selectedAvatar: Avatar?
    @State private var isUserExists: Bool? = nil
    @State private var showLoginBonus: Bool = false
    @State private var isPresentingTraining: Bool = false
    @State private var currentBonus: Int = 0
    @State private var loginCount: Int = 0
    @State private var showCoinAlert: Bool = false
    @State private var isSignUpFlag: Bool = true
    @State private var updateNameFlag: Bool = false
    @State private var offlineFeatureNotice: String?
    @State private var presentedAppUpdate: AppUpdate?
    @AppStorage(AppUpdateReadState.storageKey) private var readAppUpdateIDs = Data()
    @AppStorage(AppUpdateReadState.automaticPresentationKey) private var automaticallyPresentedUpdateID = ""

    private static let homeLoadingTimeout: TimeInterval = 8

    @State private var showLoginBonusModern: Bool = false
    @State private var isCheckingLoginBonus = false
    @State private var hasPresentedLoginBonusThisSession = false
    @State private var hasPendingLoginBonus = false

    // 経験値の最大値（レベルに応じて変更可能）
    private var maxExperience: Int {
        return 100 // または authManager から取得
    }
    
    private var avatarName: String {
        return avatar.first?["name"] as? String ?? ""
    }
    
    private var avatarBonusHp: Int {
        return avatar.first?["health"] as? Int ?? 0
    }
    
    private var avatarBonusAttack: Int {
        return avatar.first?["attack"] as? Int ?? 0
    }

    private var streakBadgeLabels: [String] {
        var badges: [String] = []
        if loginCount >= 100 {
            badges.append("100日")
        }
        if loginCount >= 30 {
            badges.append("30日")
        }
        if loginCount >= 7 {
            badges.append("7日")
        }
        return badges
    }

    private var guildMissionProgress: Double? {
        guard let mission = guildManager.mission, mission.target > 0 else { return nil }
        return Double(mission.correctTotal) / Double(mission.target)
    }

    private var guildProgressLabel: String? {
        guard let progress = guildMissionProgress else { return nil }
        return "達成\(Int(min(max(progress, 0), 1) * 100))%"
    }

    private var friendNotificationCount: Int {
        friendManager.incomingRequests.count + friendManager.pendingThanksCount
    }

    private var guildNotificationCount: Int {
        let claimableMissions = guildManager.missionProgresses.filter {
            $0.isCompleted && !$0.isClaimed
        }.count
        return claimableMissions + guildManager.claimableRankRewards.count
    }

    private var homeNotificationCount: Int {
        missionManager.totalClaimableCount
            + friendNotificationCount
            + battleManager.incomingBattles.count
            + guildNotificationCount
    }

    private var challengeSectionHeader: some View {
        CompactHomeSectionHeader(title: "挑戦する")
    }

    private var navigationLinks: some View {
        Group {
            NavigationLink("", destination: ManagerListView(isPresenting: $isPresentingQuizList).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizList)
            NavigationLink("", destination: StoryView(isReturnActive: .constant(true), isPresented: $isPresentingTraining).navigationBarBackButtonHidden(true), isActive: $isPresentingTraining)
            NavigationLink("", destination: GachaManagerView(isPresenting: $isPresentingGachaView), isActive: $isPresentingGachaView)
            NavigationLink("", destination: IllustratedView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingIllustratedView)
            NavigationLink("", destination: TittlesView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingTittleView)
            NavigationLink("", destination: RankingView(audioManager: audioManager).navigationBarBackButtonHidden(true), isActive: $isPresentingRankingView)
            NavigationLink("", destination: FriendListView(initialSection: friendInitialSection), isActive: $isPresentingFriendView)
            NavigationLink("", destination: GuildEntryView(), isActive: $isPresentingGuildView)
            NavigationLink("", destination: WeeklyLeagueView(notificationLaunch: weeklyLeagueNotificationLaunch), isActive: $isPresentingWeeklyLeagueView)
            NavigationLink("", destination: QuizIncorrectAnswerListView(isPresenting: $isPresentingReviewFromNotification, learningContext: scheduledReviewContext).id(scheduledReviewContext?.flowID).navigationBarBackButtonHidden(true), isActive: $isPresentingReviewFromNotification)
            NavigationLink("", destination: QuizITIncorrectAnswerListView(
                isPresenting: $isPresentingITReview,
                isDailyReview: true,
                learningContext: dailyLearningContext
            ).id(dailyLearningContext?.flowID).navigationBarBackButtonHidden(true), isActive: $isPresentingITReview)
            NavigationLink("", destination: QuizITBasicList(isPresenting: $isPresentingInitialDiagnostic, questionLimit: 3, isInitialDiagnostic: true).id(initialPracticeSessionID).navigationBarBackButtonHidden(true), isActive: $isPresentingInitialDiagnostic)
            NavigationLink("", destination: QuizITBasicList(isPresenting: $isPresentingDailyQuickQuiz, questionLimit: 3, learningContext: dailyLearningContext).id(dailyLearningContext?.flowID).navigationBarBackButtonHidden(true), isActive: $isPresentingDailyQuickQuiz)
            NavigationLink("", destination: MissionView(), isActive: $isPresentingMissionView)
        }
        .frame(width: 0, height: 0)
        .hidden()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    SlimeFullScreenLoadingView()
                } else {
                    VStack(spacing: 0) {
                        // 広告バナー
                        if connectivity.isConnected && appState.shouldShowAds {
                            BannerAdView()
                        }

                        if !connectivity.isConnected {
                            OfflineStatusBanner()
                        }
                        
                        ZStack(alignment: .top) {
                            navigationLinks

                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 10) {
                                    CompactHomeProfileCard(
                                        userName: userName,
                                        avatarName: avatarName,
                                        coins: userMoney,
                                        level: authManager.level,
                                        experience: authManager.experience,
                                        maxExperience: maxExperience,
                                        hp: userHp + avatarBonusHp,
                                        hpBonus: avatarBonusHp,
                                        attack: userAttack + avatarBonusAttack,
                                        attackBonus: avatarBonusAttack,
                                        registerName: {
                                            openOnlineFeature("名前の登録") {
                                                updateNameFlag = true
                                            }
                                        },
                                        showUpdates: {
                                            generateHapticFeedback()
                                            presentedAppUpdate = AppUpdate.latest
                                        }
                                    )
                                    .onChange(of: updateNameFlag) { _ in
                                        refreshUserProfile()
                                    }

                                    if offersInitialPractice && !hasCompletedInitialPractice {
                                        InitialPracticeHomeCard(action: startInitialPractice)
                                    }

                                    ForEach(homeLearningActivities) { activity in
                                        homeLearningEntry(activity)
                                            .onAppear { recordLearningImpression(activity) }
                                            .onChange(of: activity) { updated in recordLearningImpression(updated) }
                                    }

                                    challengeSectionHeader

                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 2),
                                        spacing: 6
                                    ) {
                                        HomeModeTile(
                                            title: "学習モード",
                                            artworkName: "HomeTrainingButtonLandscapeV2",
                                            artworkContentBounds: CGRect(x: 8.0 / 1728, y: 6.0 / 910,
                                                                         width: 1712.0 / 1728, height: 881.0 / 910),
                                            stretchesArtworkToFrame: true
                                        ) {
                                            generateHapticFeedback()
                                            learningTour.advance(from: .home)
                                            isPresentingQuizList = true
                                            audioManager.playSound()
                                        }
                                        .learningTourTarget(.home)
                                        .accessibilityIdentifier("learningTour.openLearningMode")

                                        HomeModeTile(
                                            title: "ダンジョン",
                                            artworkName: "HomeDungeonButtonLandscapeV2",
                                            artworkContentBounds: CGRect(x: 11.0 / 1728, y: 31.0 / 910,
                                                                         width: 1706.0 / 1728, height: 838.0 / 910),
                                            stretchesArtworkToFrame: true
                                        ) {
                                            generateHapticFeedback()
                                            openOnlineFeature("ダンジョン") {
                                                isPresentingTraining = true
                                                audioManager.playSound()
                                            }
                                        }
                                    }

                                    HomeModeTile(
                                        title: "ストーリーモード",
                                        artworkName: "HomeStoryButtonLandscapeV2",
                                        aspectRatio: 4.3,
                                        artworkVerticalPadding: 1,
                                        artworkContentBounds: CGRect(x: 5.0 / 1923, y: 187.0 / 818,
                                                                     width: 1913.0 / 1923, height: 439.0 / 818)
                                    ) {
                                        openHomeFeature("ストーリーモード") {
                                            storyAdventureDestination = .storybook
                                        }
                                    }

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible(), spacing: 8),
                                            GridItem(.flexible(), spacing: 8)
                                        ],
                                        spacing: 8
                                    ) {
                                        CompactHomeFeatureCard(
                                            title: "週間リーグ",
                                            subtitle: battleManager.incomingBattles.isEmpty
                                                ? "今週の順位を確認"
                                                : "対戦できみの番です",
                                            icon: .asset("HomeWeeklyLeagueIcon"),
                                            accent: Color(red: 0.82, green: 0.59, blue: 0.04),
                                            badge: battleManager.incomingBattles.count
                                        ) {
                                            openSocialFeature("週間リーグ") { isPresentingWeeklyLeagueView = true }
                                        }

                                        CompactHomeFeatureCard(
                                            title: "ミッション",
                                            subtitle: missionManager.totalClaimableCount > 0
                                                ? "達成報酬を受け取ろう"
                                                : "今日の目標を確認",
                                            icon: .asset("HomeMissionIcon"),
                                            accent: Color(red: 0.25, green: 0.48, blue: 0.95),
                                            badge: missionManager.totalClaimableCount
                                        ) {
                                            openOnlineFeature("ミッション") { isPresentingMissionView = true }
                                        }
                                    }

                                    CompactHomeSectionHeader(title: "あつめる")

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible(), spacing: 8),
                                            GridItem(.flexible(), spacing: 8)
                                        ],
                                        spacing: 8
                                    ) {
                                        CompactHomeFeatureCard(
                                            title: "ガチャ",
                                            subtitle: "コインでおともを獲得",
                                            icon: .asset("HomeGachaIcon"),
                                            accent: .pink
                                        ) {
                                            openHomeFeature("ガチャ") { isPresentingGachaView = true }
                                        }

                                        CompactHomeFeatureCard(
                                            title: "ランキング",
                                            subtitle: "みんなの記録を確認",
                                            icon: .asset("HomeRankingIcon"),
                                            accent: .purple
                                        ) {
                                            openHomeFeature("ランキング") { isPresentingRankingView = true }
                                        }

                                        CompactHomeFeatureCard(
                                            title: "おとも図鑑",
                                            subtitle: "集めたおともを見る",
                                            icon: .asset("HomeCompanionDexIcon"),
                                            accent: .teal
                                        ) {
                                            openHomeFeature("おとも図鑑") { isPresentingIllustratedView = true }
                                        }

                                        CompactHomeFeatureCard(
                                            title: "称号",
                                            subtitle: "実績で称号を獲得",
                                            icon: .asset("HomeTitleIcon"),
                                            accent: .orange
                                        ) {
                                            openHomeFeature("称号") { isPresentingTittleView = true }
                                        }
                                    }

                                    CompactHomeSectionHeader(title: "みんなで")

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible(), spacing: 8),
                                            GridItem(.flexible(), spacing: 8)
                                        ],
                                        spacing: 8
                                    ) {
                                        CompactHomeFeatureCard(
                                            title: "フレンド",
                                            subtitle: friendNotificationCount == 0
                                                ? "フレンドとつながろう"
                                                : "新着情報があります",
                                            icon: .asset("HomeFriendIcon"),
                                            accent: Color(red: 0.94, green: 0.35, blue: 0.65),
                                            badge: friendNotificationCount
                                        ) {
                                            openSocialFeature("フレンド") { isPresentingFriendView = true }
                                        }

                                        CompactHomeFeatureCard(
                                            title: "ギルド",
                                            subtitle: guildManager.guild?.name ?? "仲間と一緒に強くなろう",
                                            icon: .asset("HomeGuildIcon"),
                                            accent: Color(red: 0.05, green: 0.71, blue: 0.49),
                                            badge: guildNotificationCount,
                                            progress: guildMissionProgress,
                                            progressLabel: guildProgressLabel
                                        ) {
                                            openSocialFeature("ギルド") { isPresentingGuildView = true }
                                        }

                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                            }
                            // iPhone SEなど縦幅の小さい端末では、TabViewのフローティングバーが
                            // 最後の「フレンド」「ギルド」に重なる。末尾をバーの上まで
                            // スクロールできるだけの非操作領域を確保する。
                            .safeAreaInset(edge: .bottom, spacing: 0) {
                                Color.clear
                                    .frame(height: 88)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                        .background {
                            // 背景のアスペクト比でホームや広告の領域を押し広げない。
                            GeometryReader { geometry in
                                Image("HomeBackgroundAdventure")
                                    .resizable()
                                    .interpolation(.high)
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            }
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                        }
                    }
                }
                
                // MARK: - Overlays
                if showLoginBonus {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showLoginBonus = false
                            showCoinAlert = true
                        }
                    StampAnimationView(loginCount: $loginCount)
                        .onTapGesture {
                            showLoginBonus = false
                            showCoinAlert = true
                        }
                }
                
                if showLoginBonusModern {
                    LoginBonusModernView(
                        isPresented: $showLoginBonusModern,
                        loginCount: loginCount,
                        currentBonus: currentBonus,
                        authManager: authManager,
                        onCollected: {
                            // コイン表示を更新
                            authManager.getUserMoney { money in
                                self.userMoney = money
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }

                if let offlineFeatureNotice {
                    VStack {
                        Spacer()
                        OfflineFeatureNotice(featureName: offlineFeatureNotice)
                            .padding(.bottom, 28)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(200)
                }
                
                if customerFlag {
                    ReviewView(isPresented: $customerFlag, helpFlag: $helpFlag)
                }
                
                if csFlag {
                    HelpModalView(isPresented: $csFlag)
                }
                
                if helpFlag {
                    HelpModalView(isPresented: $helpFlag)
                }
                
                if updateNameFlag {
                    ChangeNameView(isPresented: $updateNameFlag, isReturnBtn: .constant(true), tutorialNum: .constant(0), authManager: authManager)
                }

                if initialLearningFlow.phase == .welcome {
                    TutorialModalView(
                        onStartPractice: startInitialPractice,
                        onSkip: {
                            GrowthAnalytics.logOnboardingAction("skip")
                            offersInitialPractice = true
                            needsInitialNameRegistration = true
                            AdvertisingPrivacyCoordinator.shared.isInitialLearningActive = true
                            initialLearningFlow.skipWelcome(canOfferNameRegistration: userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            if initialLearningFlow.phase != .nameRegistration { needsInitialNameRegistration = false }
                            UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                            continueHomePresentations()
                        }
                    )
                    .zIndex(300)
                }

                if initialLearningFlow.phase == .nameRegistration {
                    ChangeNameView(
                        isPresented: Binding(
                            get: { initialLearningFlow.phase == .nameRegistration },
                            set: { if !$0 { finishInitialNameRegistration() } }
                        ),
                        isReturnBtn: .constant(true), tutorialNum: .constant(0), authManager: authManager,
                        isInitialRegistration: true,
                        registrationUnavailableMessage: !connectivity.isConnected
                            ? "名前の登録には通信が必要です。あとからホームで登録できます。"
                            : (!hasInitializedUserForSession ? "アカウントを準備しています。あとからホームで登録することもできます。" : nil),
                        onNameSaved: { userName = $0 }
                    )
                    .zIndex(340)
                }

                if initialLearningFlow.phase == .reminder {
                    ReviewReminderOptInView(
                        plan: InitialLearningPlanStore.load(userID: authManager.currentUserId ?? InitialLearningPlanStore.localGuestID)
                            ?? InitialLearningPlan(completedAt: Date(), incorrectCount: 0)
                    ) {
                        initialLearningFlow.finishReminder()
                        continueHomePresentations()
                    }
                    .zIndex(350)
                }
            }
            .fontWeight(.bold)
            .background(Color("Color2"))
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(
            TapGesture().onEnded {
                guard !updateNameFlag, initialLearningFlow.phase != .nameRegistration else { return }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        )
        .alert(isPresented: $showCoinAlert) {
            Alert(
                title: Text("ログインボーナス！！"),
                message: Text("\(currentBonus)コイン獲得しました"),
                dismissButton: .default(Text("OK")) {
                }
            )
        }
        .onAppear {

            GrowthAnalytics.logFirstOpenIfNeeded()
            resumeLearningTourIfNeeded()

            refreshReviewSummary()
            handlePendingNotificationIfNeeded()
            scheduleHomeLoadingFallback()

            if !connectivity.isConnected {
                isLoading = false
                return
            }
            initializeUserIfNeeded()
        }
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager, source: .ad)
        }
        .fullScreenCover(item: $storyAdventureDestination) { style in
            StoryAdventureEntryView(mapStyle: style)
        }
        .sheet(item: $presentedAppUpdate, onDismiss: continueHomePresentations) { update in
            AppUpdateSheet(update: update)
        }
        .onChange(of: showCoinAlert) { userMoney in
            authManager.getUserMoney { userMoney in
                self.userMoney = userMoney
            }
        }
        .onChange(of: authManager.money) { money in
            userMoney = money
        }
        .onChange(of: isPresentingInitialDiagnostic) { isPresenting in
            guard !isPresenting else { return }
            refreshReviewSummary()
            initialLearningFlow.finishPractice(
                completed: hasCompletedInitialPractice,
                canOfferReminder: !hasSeenReviewReminder,
                canOfferSpotlight: !learningTour.hasCompleted,
                canOfferNameRegistration: needsInitialNameRegistration && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
            if initialLearningFlow.phase == .spotlight { learningTour.start() }
            if initialLearningFlow.phase == .reminder {
                hasSeenReviewReminder = true
            }
            continueHomePresentations()
        }
        .onChange(of: learningTour.isActive) { active in
            guard !active, initialLearningFlow.phase == .spotlight else { return }
            if learningTour.exit == .home {
                DispatchQueue.main.async {
                    isPresentingQuizList = false
                    finishLearningTourIfHomeVisible()
                }
            } else {
                finishLearningTourIfHomeVisible()
            }
        }
        .onChange(of: userName) { name in
            if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                needsInitialNameRegistration = false
                if initialLearningFlow.phase == .nameRegistration { finishInitialNameRegistration() }
            }
        }
        .onChange(of: canPresentHomePrompt) { canPresent in
            if canPresent { continueHomePresentations() }
        }
        .onChange(of: isPresentingDailyQuickQuiz) { isPresenting in
            if !isPresenting { refreshReviewSummary() }
        }
        .onChange(of: isPresentingReviewFromNotification) { isPresenting in
            if !isPresenting { refreshReviewSummary() }
        }
        .onChange(of: isPresentingITReview) { isPresenting in
            if !isPresenting { refreshReviewSummary() }
        }
        .onChange(of: appState.isSubscribed) { _ in
            refreshReviewSummary()
        }
        .onChange(of: canRecordLearningImpressions) { visible in
            if visible { homeLearningActivities.forEach { recordLearningImpression($0) } }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            refreshReviewSummary()
        }
        .onChange(of: isPresentingQuizList) { isPresenting in
            if !isPresenting {
                refreshReviewSummary()
                if learningTour.isActive { learningTour.restartAtHome() }
                finishLearningTourIfHomeVisible()
            }
            if connectivity.isConnected {
                fetchUserInfoIfNeeded(isPresenting: isPresenting)
                authManager.fetchUserExperienceAndLevel()
                authManager.fetchUserRewardFlag()
            }
        }
        .onChange(of: isPresentingFriendView) { isPresenting in
            if !isPresenting { friendInitialSection = .friends }
        }
        .onChange(of: isPresentingWeeklyLeagueView) { isPresenting in
            if !isPresenting { weeklyLeagueNotificationLaunch = nil }
        }
        .onChange(of: homeNotificationCount) { count in
            AppIconBadgeCoordinator.update(count: count)
        }
        .onReceive(notificationRouter.$pendingDestination) { destination in
            guard destination != nil else { return }
            handlePendingNotificationIfNeeded()
        }
        .onChange(of: isPresentingAvatarList) { isPresenting in
            if connectivity.isConnected {
                fetchUserInfoIfNeeded(isPresenting: isPresenting)
                authManager.fetchUserExperienceAndLevel()
                authManager.fetchUserRewardFlag()
            }
        }
        .onChange(of: isPresentingTraining) { isPresenting in
            if connectivity.isConnected {
                fetchUserInfoIfNeeded(isPresenting: isPresenting)
                authManager.fetchUserExperienceAndLevel()
                authManager.fetchUserRewardFlag()
            }
        }
        .onChange(of: connectivity.isConnected) { isConnected in
            refreshReviewSummary()
            if isConnected {
                initializeUserIfNeeded()
            } else {
                isLoading = false
                showLoginBonus = false
                showLoginBonusModern = false
                preFlag = false
            }
        }
        .onChange(of: authManager.user?.uid) { userId in
            refreshReviewSummary()
            hasInitializedUserForSession = false
            isInitializingUser = false
            hasPresentedLoginBonusThisSession = false
            hasPendingLoginBonus = false
            isCheckingLoginBonus = false
            guard userId != nil, connectivity.isConnected else { return }
            initializeUserIfNeeded()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            guard connectivity.isConnected else {
                refreshReviewSummary()
                return
            }
            if hasInitializedUserForSession {
                refreshHomeStatus()
            } else {
                initializeUserIfNeeded()
            }
        }
        .background(Color("purple2").opacity(0.6))
        .edgesIgnoringSafeArea(.all)
        .learningTourOverlay(step: .home, target: .home)
    }

    private func resumeLearningTourIfNeeded() {
        guard offersInitialPractice, hasCompletedInitialPractice, !learningTour.hasCompleted,
              initialLearningFlow.phase == .home else { return }
        initialLearningFlow.resumeSpotlight()
        AdvertisingPrivacyCoordinator.shared.isInitialLearningActive = true
        learningTour.start()
    }

    private func finishInitialNameRegistration() {
        guard initialLearningFlow.phase == .nameRegistration else { return }
        needsInitialNameRegistration = false
        initialLearningFlow.finishNameRegistration()
        if initialLearningFlow.phase == .spotlight {
            learningTour.start()
        } else {
            resumeLearningTourIfNeeded()
        }
        if initialLearningFlow.phase == .reminder { hasSeenReviewReminder = true }
        continueHomePresentations()
    }

    private func finishLearningTourIfHomeVisible() {
        guard initialLearningFlow.phase == .spotlight, !learningTour.isActive, !isPresentingQuizList else { return }
        initialLearningFlow.finishSpotlight(canOfferReminder: !hasSeenReviewReminder)
        if initialLearningFlow.phase == .reminder { hasSeenReviewReminder = true }
        continueHomePresentations()
    }

    private func startInitialPractice() {
        guard initialLearningFlow.phase == .welcome || initialLearningFlow.phase == .home else { return }
        GrowthAnalytics.logOnboardingAction("start_diagnostic")
        initialLearningFlow.startPractice()
        if !UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
            needsInitialNameRegistration = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        offersInitialPractice = true
        AdvertisingPrivacyCoordinator.shared.isInitialLearningActive = true
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
        initialPracticeSessionID = UUID()
        isPresentingInitialDiagnostic = true
    }

    private func continueHomePresentations() {
        guard initialLearningFlow.allowsHomePrompts, !isPresentingInitialDiagnostic else { return }
        handlePendingNotificationIfNeeded()
        presentLoginBonusIfEligible()
        guard canPresentHomePrompt, !isCheckingLoginBonus, !hasPendingLoginBonus else { return }
        if presentAppUpdateIfEligible() { return }
        AdvertisingPrivacyCoordinator.shared.isInitialLearningActive = false
        AdvertisingPrivacyCoordinator.shared.prepareIfPossible()
    }

    private func initializeUserIfNeeded() {
        guard connectivity.isConnected else {
            isLoading = false
            return
        }
        guard let userId = authManager.currentUserId else {
            isLoading = false
            authManager.anonymousSignIn {}
            return
        }
        if hasInitializedUserForSession {
            loadInitializedHome()
            return
        }
        guard !isInitializingUser else { return }

        isInitializingUser = true
        authManager.initializeUserIfNeeded(userName: userName) { result in
            guard authManager.currentUserId == userId else { return }
            isInitializingUser = false
            guard result != .failed else {
                isLoading = false
                return
            }

            hasInitializedUserForSession = true
            isUserExists = true
            if result == .created {
                isSignUpFlag = false
            }
            loadInitializedHome()
        }
    }

    /// 初期化の確定後にだけ、プロフィールとログイン報酬を読み込む。
    private func loadInitializedHome() {
        guard hasInitializedUserForSession, connectivity.isConnected else { return }
        refreshHomeStatus()
        appState.checkSubscription()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if appState.shouldShowAds {
                executeProcessEveryFortyTimes()
            }
        }
        authManager.fetchFeedbackPromptOptOutCampaign { optOutCampaign in
            guard let optOutCampaign,
                  optOutCampaign != FeedbackPromptPolicy.currentCampaign else { return }
            executeProcessEveryThreeTimes()
            executeProcessEveryfifTimes()
        }
        authManager.fetchUserRewardFlag()
        reward.checkRewardReset()
        authManager.fetchUserInfo { name, avatar, money, hp, attack, _ in
            self.userName = name ?? ""
            self.avatar = avatar ?? []
            self.userMoney = money ?? 0
            self.userHp = hp ?? 100
            self.userAttack = attack ?? 20
            self.isLoading = false
            presentLoginBonusIfEligible()
        }
        authManager.fetchCurrentLoginStreak { streakCount in
            self.loginCount = streakCount
        }
        authManager.fetchAvatars {
            self.avatar = authManager.avatars.map { ["name": $0.name] }
        }
        authManager.fetchUserExperienceAndLevel()
    }
    
    private func fetchUserInfoIfNeeded(isPresenting: Bool) {
        if !isPresenting && connectivity.isConnected && hasInitializedUserForSession {
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, _) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
            }
            authManager.fetchCurrentLoginStreak { streakCount in
                self.loginCount = streakCount
            }
        }
    }

    private func scheduleHomeLoadingFallback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.homeLoadingTimeout) {
            guard isLoading else { return }
            print("Home loading timed out. Showing the home screen with available data.")
            isLoading = false
        }
    }

    private func refreshUserProfile() {
        guard !updateNameFlag, connectivity.isConnected, hasInitializedUserForSession else { return }
        authManager.fetchUserInfo { name, avatar, money, hp, attack, _ in
            self.userName = name ?? ""
            self.avatar = avatar ?? []
            self.userMoney = money ?? 0
            self.userHp = hp ?? 100
            self.userAttack = attack ?? 20
        }
    }

    private func refreshHomeStatus() {
        guard hasInitializedUserForSession, connectivity.isConnected else { return }
        AppIconBadgeCoordinator.update(count: homeNotificationCount)
        friendManager.observeIncomingRequests()
        friendManager.fetchPendingThanks()
        battleManager.fetchMyBattles()
        guildManager.fetchMyGuild()
        missionManager.fetchMissions { _ in }
        refreshReviewSummary()
    }

    @ViewBuilder
    private func homeLearningEntry(_ activity: HomeLearningActivity) -> some View {
        if case .scheduledReview = activity {
            DailyLearningCard(activity: activity, isSubscribed: appState.isSubscribed) { startDailyLearning(activity) }
        } else {
            DailyReviewPillButton(activity: activity, isSubscribed: appState.isSubscribed) { startDailyLearning(activity) }
        }
    }

    private var canRecordLearningImpressions: Bool {
        canPresentHomePrompt
    }

    private func recordLearningImpression(_ activity: HomeLearningActivity) {
        guard canRecordLearningImpressions, let userId = authManager.currentUserId else { return }
        // 同じホーム上の再描画・非同期データ更新を表示回数として水増ししない。
        let key = "\(userId)|\(DailyReviewStore.dayKey(for: Date()))|\(activity.id)|\(activity.stateName)"
        guard recordedLearningImpressions.insert(key).inserted else { return }
        GrowthAnalytics.logDailyLearningCardView(activity)
    }

    private var homeLearningActivities: [HomeLearningActivity] {
        guard let userId = authManager.currentUserId,
              dailyLearningLoadedUserId == userId else { return [] }
        return HomeLearningActivity.available(
            dailyReview: dailyReviewProgress,
            quickQuiz: dailyQuickQuizProgress,
            scheduledReviewCount: reviewSummary.dueCount,
            isSubscribed: appState.isSubscribed
        ).filter { activity in
            // 解き直しとテーマ確認は共通の「苦手克服」入口にまとめる。
            if case .scheduledReview = activity { return false }
            // 初回体験と未開始の「今日の3問」を同時に並べない。
            if case .quickQuiz = activity,
               offersInitialPractice && !hasCompletedInitialPractice,
               dailyQuickQuizProgress == nil {
                return false
            }
            return true
        }
    }

    private func startDailyLearning(_ activity: HomeLearningActivity, source: LearningEntryContext.Source = .home) {
        guard !activity.isCompleted else { return }
        let context = LearningEntryContext(source: source, activity: activity.analyticsActivity)
        GrowthAnalytics.logDailyLearningAction(activity: activity, context: context)
        dailyLearningContext = context

        switch activity {
        case .savedITReview:
            generateHapticFeedback()
            isPresentingITReview = true
            audioManager.playSound()
        case .quickQuiz:
            generateHapticFeedback()
            isPresentingDailyQuickQuiz = true
            audioManager.playSound()
        case .scheduledReview:
#if DEBUG
            scheduledReviewContext = context
            openOnlineFeature("苦手克服") {
                isPresentingReviewFromNotification = true
                audioManager.playSound()
            }
#endif
        }
    }

    private func refreshReviewSummary() {
        let requestID = UUID()
        reviewSummaryRequestID = requestID
        reviewSummary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)
        guard let userId = authManager.currentUserId else {
            dailyReviewProgress = nil
            dailyQuickQuizProgress = nil
            dailyLearningLoadedUserId = nil
            return
        }
        dailyQuickQuizProgress = DailyQuickQuizStore.progress(state: DailyQuickQuizStore.load(userId: userId), now: Date())

        let localQuestions = LocalIncorrectAnswerStore.questions(
            userId: userId,
            category: .itPassport
        )
        dailyReviewProgress = Self.dailyReviewProgress(userId: userId, questions: localQuestions, subscribed: appState.isSubscribed)
        dailyLearningLoadedUserId = userId
        guard appState.isSubscribed, connectivity.isConnected else { return }
        fetchITIncorrectAnswers(userId: userId) { remoteQuestions in
            DispatchQueue.main.async {
                guard reviewSummaryRequestID == requestID,
                      authManager.currentUserId == userId else { return }
                dailyReviewProgress = Self.dailyReviewProgress(
                    userId: userId,
                    questions: LocalIncorrectAnswerStore.merged(local: localQuestions, remote: remoteQuestions),
                    subscribed: appState.isSubscribed
                )
            }
        }
        ReviewScheduleService.fetchSummary(userId: userId) { summary in
            DispatchQueue.main.async {
                guard reviewSummaryRequestID == requestID,
                      authManager.currentUserId == userId else { return }
                self.reviewSummary = summary
            }
        }
    }

    private static func dailyReviewProgress(userId: String, questions: [QuizQuestion], subscribed: Bool) -> DailyReviewProgress? {
        if !subscribed {
            let remaining = ReviewAccessPolicy.remaining(userID: userId)
            let answered = ReviewAccessPolicy.dailyFreeLimit - remaining
            let available = ReviewAccessPolicy.available(questions, userID: userId, subscribed: false).count
            guard answered + available > 0 else { return nil }
            return DailyReviewProgress(incorrectCount: questions.count, questionCount: answered + available, answeredCount: answered)
        }
        var state = DailyReviewStore.startOrResume(
            state: DailyReviewStore.load(userId: userId), shuffledAvailableKeys: questions.map(\.dailyReviewKey),
            now: Date(), questionLimit: questions.count)
        state.questionKeys = Array(Set(state.questionKeys).union(questions.map(\.dailyReviewKey)))
        guard !state.questionKeys.isEmpty else { return nil }
        return DailyReviewStore.progress(state: state, availableKeys: questions.map(\.dailyReviewKey), now: Date())
    }

    private func openSocialFeature(_ featureName: String, action: () -> Void) {
        generateHapticFeedback()
        openOnlineFeature(featureName) {
            action()
            audioManager.playSound()
        }
    }

    private func openHomeFeature(_ featureName: String, action: () -> Void) {
        generateHapticFeedback()
        openOnlineFeature(featureName) {
            action()
            audioManager.playSound()
        }
    }

    /// 非同期で報酬が返った時点でも、練習や別の画面を開いていないか確認する。
    private var canPresentHomePrompt: Bool {
        scenePhase == .active && !isLoading && initialLearningFlow.allowsHomePrompts
            && !isPresentingInitialDiagnostic && !updateNameFlag
            && !isPresentingDailyQuickQuiz && !isPresentingQuizList
            && !isPresentingITReview && !isPresentingReviewFromNotification
            && !isPresentingFriendView && !isPresentingWeeklyLeagueView
            && !isPresentingGuildView && !isPresentingTraining
            && !isPresentingAvatarList && !isPresentingMissionView
            && !isPresentingGachaView && !isPresentingIllustratedView
            && !isPresentingRankingView && !isPresentingTittleView
            && storyAdventureDestination == nil
            && presentedAppUpdate == nil
            && !preFlag && !customerFlag && !csFlag && !helpFlag
            && !showLoginBonusModern && !showLoginBonus && !showCoinAlert
    }

    private func presentLoginBonusIfEligible() {
        guard connectivity.isConnected,
              hasInitializedUserForSession,
              !isInitializingUser,
              canPresentHomePrompt,
              UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
              !isCheckingLoginBonus,
              !hasPresentedLoginBonusThisSession else { return }

        if hasPendingLoginBonus {
            hasPendingLoginBonus = false
            hasPresentedLoginBonusThisSession = true
            showLoginBonusModern = true
            return
        }

        isCheckingLoginBonus = true
        let requestUserID = authManager.currentUserId
        authManager.shouldShowLoginBonus { shouldShow in
            DispatchQueue.main.async {
                guard authManager.currentUserId == requestUserID else { return }
                guard shouldShow, canPresentHomePrompt else {
                    isCheckingLoginBonus = false
                    if !shouldShow { resumeAdvertisingIfEligible() }
                    return
                }

                authManager.checkAndGrantLoginBonus500 { success in
                    DispatchQueue.main.async {
                        guard authManager.currentUserId == requestUserID else { return }
                        isCheckingLoginBonus = false
                        guard success else {
                            resumeAdvertisingIfEligible()
                            return
                        }
                        loginCount = authManager.loginCount
                        currentBonus = authManager.loginBonus
                        hasPendingLoginBonus = true
                        presentLoginBonusIfEligible()
                    }
                }
            }
        }
    }

    private func resumeAdvertisingIfEligible() {
        guard canPresentHomePrompt else { return }
        if presentAppUpdateIfEligible() { return }
        AdvertisingPrivacyCoordinator.shared.isInitialLearningActive = false
        AdvertisingPrivacyCoordinator.shared.prepareIfPossible()
    }

    private func presentAppUpdateIfEligible() -> Bool {
        guard canPresentHomePrompt, !isCheckingLoginBonus, !hasPendingLoginBonus,
              automaticallyPresentedUpdateID != AppUpdate.latest.id,
              !AppUpdateReadState.contains(AppUpdate.latest.id, in: readAppUpdateIDs),
              UserDefaults.standard.bool(forKey: "hasSeenTutorial") else { return false }
        automaticallyPresentedUpdateID = AppUpdate.latest.id
        presentedAppUpdate = AppUpdate.latest
        return true
    }

    private func openOnlineFeature(_ featureName: String, action: () -> Void) {
        guard connectivity.isConnected else {
            withAnimation {
                offlineFeatureNotice = featureName
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    if offlineFeatureNotice == featureName {
                        offlineFeatureNotice = nil
                    }
                }
            }
            return
        }
        action()
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func saveLastLoginDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginDate")
    }
    
    func saveLoginBonusReceivedDate() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastLoginBonusReceivedDate")
    }
    
    func executeProcessEveryThreeTimes() {
        if advanceLaunchCounter(key: "launchCount", every: 15) {
            customerFlag = true
        }
    }
    
    private func handlePendingNotificationIfNeeded() {
        guard canPresentHomePrompt,
              UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
              let destination = notificationRouter.consume() else { return }

        switch destination {
        case .review:
#if DEBUG
            if appState.isSubscribed {
                scheduledReviewContext = LearningEntryContext(source: .notification, activity: .scheduledReview)
                isPresentingReviewFromNotification = true
                return
            }
#endif
            // 通知からも途中の3問を再開し、当日の達成を別の学習で上書きしない。
            refreshReviewSummary()
            if let activity = homeLearningActivities.first {
                startDailyLearning(activity, source: .notification)
            }
        case .dailyLearning:
            refreshReviewSummary()
            if let activity = homeLearningActivities.first {
                startDailyLearning(activity, source: .notification)
            }
        case .friendRequests:
            friendInitialSection = .requests
            isPresentingFriendView = true
        case .weeklyLeague:
            weeklyLeagueNotificationLaunch = nil
            isPresentingWeeklyLeagueView = true
        case .battleInvitations:
            weeklyLeagueNotificationLaunch = .invitations
            isPresentingWeeklyLeagueView = true
        case .battleResult(let battleId):
            weeklyLeagueNotificationLaunch = .battleResult(battleId)
            isPresentingWeeklyLeagueView = true
        case .weeklyLeagueResult:
            weeklyLeagueNotificationLaunch = .leagueResult
            isPresentingWeeklyLeagueView = true
        case .guild:
            isPresentingGuildView = true
        }
    }

    func executeProcessEveryfifTimes() {
        if advanceLaunchCounter(key: "launchCSCount", every: 10) {
            csFlag = true
        }
    }
    
    func executeProcessEveryFortyTimes() {
        if advanceLaunchCounter(key: "launchPreCount", every: 10) {
            preFlag = true
        }
    }

    /// 起動回数カウンタを起動ごとに1回だけ進め、表示タイミングなら販促枠を確保して true を返す。
    /// 他のポップアップに枠を取られた場合はカウンタを進めず、次回の起動で改めて表示する。
    private func advanceLaunchCounter(key: String, every interval: Int) -> Bool {
        guard canPresentHomePrompt,
              LaunchPromptGate.shared.shouldCountLaunch(for: key) else { return false }
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: key) + 1
        let isDue = count % interval == 0
        if isDue && !LaunchPromptGate.shared.claim() {
            return false
        }
        defaults.set(count, forKey: key)
        return isDue
    }
    
    func checkForLoginBonus() -> Bool {
        let defaults = UserDefaults.standard
        let lastLoginDate = defaults.object(forKey: "lastLoginDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastLoginDate, to: Date())
        if let days = components.day, days > 0 {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Button Style
struct PressedEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Progress Bar (HP用など)
struct ProgressBar: View {
    var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.green))
                
                Rectangle()
                    .frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(.green))
            }
        }
        .cornerRadius(45.0)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(AppState())
            .environmentObject(ConnectivityMonitor.shared)
    }
}
