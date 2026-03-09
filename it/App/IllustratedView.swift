//
//  IllustratedViewUpdated.swift
//  it
//
//  Modern redesign with card-based UI, smooth animations, and premium feel
//

import SwiftUI
import Firebase
import UIKit

// MARK: - Illustrated View Updated
struct IllustratedView: View {
    
    // MARK: - Item Model
    struct Item: Identifiable {
        let name: String
        let attack: Int
        let probability: Int
        let health: Int
        let rarity: Rarity
        var id: String { name }
    }
    
    // MARK: - Rarity Enum
    enum Rarity: CaseIterable {
        case normal, rare, superRare, ultraRare, legendRare, mythic
        
        var displayString: String {
            switch self {
            case .normal: return "ノーマル"
            case .rare: return "レア"
            case .superRare: return "スーパーレア"
            case .ultraRare: return "ウルトラレア"
            case .legendRare: return "レジェンド"
            case .mythic: return "ゴットレア"
            }
        }
        
        var color: Color {
            switch self {
            case .normal: return Color(red: 0.6, green: 0.6, blue: 0.65)
            case .rare: return Color(red: 0.3, green: 0.5, blue: 0.9)
            case .superRare: return Color(red: 0.6, green: 0.3, blue: 0.9)
            case .ultraRare: return Color(red: 0.95, green: 0.6, blue: 0.2)
            case .legendRare: return Color(red: 0.95, green: 0.8, blue: 0.2)
            case .mythic: return Color(red: 0.95, green: 0.95, blue: 0.95)
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .normal:
                return LinearGradient(
                    colors: [Color(red: 0.5, green: 0.5, blue: 0.55), Color(red: 0.4, green: 0.4, blue: 0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .rare:
                return LinearGradient(
                    colors: [Color(red: 0.3, green: 0.5, blue: 0.95), Color(red: 0.2, green: 0.4, blue: 0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .superRare:
                return LinearGradient(
                    colors: [Color(red: 0.7, green: 0.3, blue: 0.95), Color(red: 0.5, green: 0.2, blue: 0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ultraRare:
                return LinearGradient(
                    colors: [Color(red: 1, green: 0.6, blue: 0.2), Color(red: 0.9, green: 0.4, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .legendRare:
                return LinearGradient(
                    colors: [Color(red: 1, green: 0.9, blue: 0.3), Color(red: 0.95, green: 0.7, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .mythic:
                return LinearGradient(
                    colors: [Color.white, Color(red: 1, green: 0.92, blue: 0.55), Color(red: 0.9, green: 0.75, blue: 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        var backgroundGradient: LinearGradient {
            switch self {
            case .normal:
                return LinearGradient(
                    colors: [Color(red: 0.2, green: 0.2, blue: 0.25), Color(red: 0.15, green: 0.15, blue: 0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .rare:
                return LinearGradient(
                    colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.08, green: 0.1, blue: 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .superRare:
                return LinearGradient(
                    colors: [Color(red: 0.2, green: 0.1, blue: 0.3), Color(red: 0.15, green: 0.08, blue: 0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ultraRare:
                return LinearGradient(
                    colors: [Color(red: 0.25, green: 0.15, blue: 0.1), Color(red: 0.2, green: 0.1, blue: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .legendRare:
                return LinearGradient(
                    colors: [Color(red: 0.25, green: 0.22, blue: 0.1), Color(red: 0.2, green: 0.18, blue: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .mythic:
                return LinearGradient(
                    colors: [Color(red: 0.28, green: 0.28, blue: 0.32), Color(red: 0.16, green: 0.14, blue: 0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // MARK: - Data
    let allItems: [Item] = IllustratedView.buildAllItems()
    
    // MARK: - State
    @State private var selectedItem: Item?
    @State private var selectedRarity: Rarity? = nil
    @State private var showDetail = false
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var isPresenting: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    private static func buildAllItems() -> [Item] {
        let managers = [
            GachaManager(mode: .normal),
            GachaManager(mode: .rare),
            GachaManager(mode: .meka),
            GachaManager(mode: .god)
        ]
        
        var seenNames = Set<String>()
        
        return managers
            .flatMap(\.catalogItems)
            .compactMap { item in
                guard seenNames.insert(item.name).inserted else {
                    return nil
                }
                
                return Item(
                    name: item.name,
                    attack: item.attack,
                    probability: item.probability,
                    health: item.health,
                    rarity: Rarity(gachaRarity: item.rarity)
                )
            }
    }
    
    var filteredItems: [Item] {
        if let rarity = selectedRarity {
            return allItems.filter { $0.rarity == rarity }
        }
        return allItems
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Rarity filter
                rarityFilterView
                    .padding(.vertical, 12)
                
                // Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredItems) { item in
                            ItemCardView(
                                item: item,
                                isOwned: authManager.avatars.contains(where: { $0.name == item.name }),
                                isSelected: selectedItem?.name == item.name
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedItem = item
                                    showDetail = true
                                }
                                generateHapticFeedback()
                                audioManager.playSound()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            
            // Detail overlay
            if showDetail, let item = selectedItem {
                DetailOverlayView(
                    item: item,
                    isOwned: authManager.avatars.contains(where: { $0.name == item.name }),
                    onClose: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDetail = false
                        }
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 && !showDetail {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onAppear {
            authManager.fetchAvatars {}
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("おとも図鑑")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(authManager.avatars.count) / \(allItems.count) 収集済み")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Collection progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(authManager.avatars.count) / CGFloat(allItems.count))
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(Double(authManager.avatars.count) / Double(allItems.count) * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Rarity Filter View
    private var rarityFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "すべて",
                    isSelected: selectedRarity == nil,
                    color: .white
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedRarity = nil
                    }
                }
                
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    FilterChip(
                        title: rarity.displayString,
                        isSelected: selectedRarity == rarity,
                        color: rarity.color
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedRarity = rarity
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: {
            generateHapticFeedback()
            presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("戻る")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

private extension IllustratedView.Rarity {
    init(gachaRarity: GachaRarity) {
        switch gachaRarity {
        case .normal:
            self = .normal
        case .rare, .Rrare, .mekaRare, .godRare:
            self = .rare
        case .superRare, .RsuperRare, .mekaSuperRare, .godSuperRare:
            self = .superRare
        case .ultraRare, .RultraRare, .mekaUltraRare, .godUltraRare:
            self = .ultraRare
        case .legendRare, .mekaLegendRare, .godLegendRare:
            self = .legendRare
        case .godMythicRare:
            self = .mythic
        }
    }
}

private extension IllustratedView.Item {
    var imageName: String {
        AvatarAssetResolver.imageName(for: name, owned: true)
    }
    
    var silhouetteImageName: String {
        AvatarAssetResolver.imageName(for: name, owned: false)
    }
}

private enum AvatarAssetResolver {
    static func imageName(for name: String, owned: Bool) -> String {
        let primaryName = owned ? name : "\(name)_シルエット"
        if UIImage(named: primaryName) != nil {
            return primaryName
        }
        
        if let fallback = UIImage(named: name) != nil ? name : nil {
            return fallback
        }
        
        return "questionmark.circle.fill"
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : color.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color.opacity(0.8) : color.opacity(0.15))
                )
                .overlay(
                    Capsule()
                        .stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Item Card View
struct ItemCardView: View {
    let item: IllustratedView.Item
    let isOwned: Bool
    let isSelected: Bool
    
    @State private var shimmer = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background glow for owned items
                if isOwned {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(item.rarity.color.opacity(0.2))
                        .blur(radius: 8)
                }
                
                // Card background
                RoundedRectangle(cornerRadius: 16)
                    .fill(item.rarity.backgroundGradient)
                
                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ?
                        item.rarity.color :
                        Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
                
                VStack(spacing: 8) {
                    // Character image
                    ZStack {
                        if isOwned && (item.rarity == .legendRare || item.rarity == .mythic) {
                            // Shimmer effect for legend
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.yellow, .orange, .yellow, .white, .yellow],
                                        center: .center
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .blur(radius: 15)
                                .rotationEffect(.degrees(shimmer ? 360 : 0))
                        }
                        
                        avatarImage(width: 70, height: 70)
                    }
                    
                    // Rarity indicator
                    HStack(spacing: 2) {
                        ForEach(0..<rarityStars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(item.rarity.color)
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 120)
            
            // Name
            Text(isOwned ? item.name : "???")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(isOwned ? .white : .white.opacity(0.4))
                .lineLimit(1)
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            if isOwned && (item.rarity == .legendRare || item.rarity == .mythic) {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
        }
    }
    
    private var rarityStars: Int {
        switch item.rarity {
        case .normal: return 1
        case .rare: return 2
        case .superRare: return 3
        case .ultraRare: return 4
        case .legendRare: return 5
        case .mythic: return 6
        }
    }
    
    @ViewBuilder
    private func avatarImage(width: CGFloat, height: CGFloat) -> some View {
        let imageName = isOwned ? item.imageName : item.silhouetteImageName
        
        if imageName == "questionmark.circle.fill" {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(.white.opacity(isOwned ? 0.9 : 0.35))
        } else {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .opacity(isOwned ? 1 : 0.4)
        }
    }
}

// MARK: - Detail Overlay View
struct DetailOverlayView: View {
    let item: IllustratedView.Item
    let isOwned: Bool
    let onClose: () -> Void
    
    @State private var appear = false
    @State private var floatAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Detail card
            VStack(spacing: 24) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
                
                // Rarity badge
                Text(item.rarity.displayString)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(item.rarity.gradient)
                    )
                
                // Character
                ZStack {
                    // Glow effect
                    if isOwned {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [item.rarity.color.opacity(0.5), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(glowAnimation ? 1.1 : 0.9)
                    }
                    
                    avatarImage(width: 180, height: 180)
                        .shadow(color: item.rarity.color.opacity(0.5), radius: 20, x: 0, y: 10)
                        .offset(y: floatAnimation ? -10 : 10)
                }
                
                // Name
                Text(isOwned ? item.name : "???")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Stats
                if isOwned {
                    HStack(spacing: 40) {
                        StatDisplay(
                            icon: "heart.fill",
                            value: item.health,
                            label: "HP",
                            color: .red
                        )
                        
                        StatDisplay(
                            icon: "bolt.fill",
                            value: item.attack,
                            label: "ATK",
                            color: .blue
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.15, blue: 0.2),
                                Color(red: 0.1, green: 0.1, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(item.rarity.color.opacity(0.5), lineWidth: 2)
                    )
            )
            .padding(.horizontal, 32)
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatAnimation = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private func avatarImage(width: CGFloat, height: CGFloat) -> some View {
        let imageName = isOwned ? item.imageName : item.silhouetteImageName
        
        if imageName == "questionmark.circle.fill" {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(.white.opacity(isOwned ? 0.9 : 0.4))
        } else {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .opacity(isOwned ? 1 : 0.5)
        }
    }
}

// MARK: - Stat Display
struct StatDisplay: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Preview
struct IllustratedViewUpdated_Previews: PreviewProvider {
    static var previews: some View {
        IllustratedView(isPresenting: .constant(false))
    }
}
