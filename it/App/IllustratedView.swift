//
//  IllustratedViewUpdated.swift
//  it
//
//  Modern redesign with card-based UI, smooth animations, and premium feel
//

import SwiftUI
import Firebase

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
        case normal, rare, superRare, ultraRare, legendRare
        
        var displayString: String {
            switch self {
            case .normal: return "ノーマル"
            case .rare: return "レア"
            case .superRare: return "スーパーレア"
            case .ultraRare: return "ウルトラレア"
            case .legendRare: return "レジェンド"
            }
        }
        
        var color: Color {
            switch self {
            case .normal: return Color(red: 0.6, green: 0.6, blue: 0.65)
            case .rare: return Color(red: 0.3, green: 0.5, blue: 0.9)
            case .superRare: return Color(red: 0.6, green: 0.3, blue: 0.9)
            case .ultraRare: return Color(red: 0.95, green: 0.6, blue: 0.2)
            case .legendRare: return Color(red: 0.95, green: 0.8, blue: 0.2)
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
            }
        }
    }
    
    // MARK: - Data
    let allItems: [Item] = [
        Item(name: "ネッキー", attack: 10, probability: 25, health: 20, rarity: .normal),
        Item(name: "ピョン吉", attack: 15, probability: 25, health: 15, rarity: .normal),
        Item(name: "ルイーカ", attack: 20, probability: 25, health: 10, rarity: .normal),
        Item(name: "もりこう", attack: 20, probability: 25, health: 100, rarity: .normal),
        Item(name: "うっさん", attack: 25, probability: 25, health: 150, rarity: .normal),
        Item(name: "キリキリン", attack: 30, probability: 25, health: 200, rarity: .normal),
        Item(name: "カゲロウ", attack: 35, probability: 10, health: 220, rarity: .rare),
        Item(name: "ライム", attack: 40, probability: 10, health: 240, rarity: .rare),
        Item(name: "ラオン", attack: 45, probability: 10, health: 260, rarity: .rare),
        Item(name: "ぴょこん", attack: 20, probability: 25, health: 220, rarity: .rare),
        Item(name: "忍太", attack: 20, probability: 25, health: 210, rarity: .rare),
        Item(name: "かみ蔵", attack: 20, probability: 25, health: 220, rarity: .rare),
        Item(name: "キャット夫人", attack: 25, probability: 25, health: 225, rarity: .rare),
        Item(name: "ミッチー", attack: 30, probability: 25, health: 240, rarity: .rare),
        Item(name: "ライム兄", attack: 40, probability: 10, health: 250, rarity: .rare),
        Item(name: "幸福のパンダ", attack: 47, probability: 5, health: 260, rarity: .rare),
        Item(name: "メカマウス", attack: 20, probability: 25, health: 210, rarity: .rare),
        Item(name: "メカドック", attack: 20, probability: 25, health: 215, rarity: .rare),
        Item(name: "メカベアー", attack: 20, probability: 25, health: 220, rarity: .rare),
        Item(name: "ロボン", attack: 25, probability: 25, health: 225, rarity: .rare),
        Item(name: "ロボノコ", attack: 30, probability: 25, health: 240, rarity: .rare),
        Item(name: "ロボカー", attack: 40, probability: 10, health: 250, rarity: .rare),
        Item(name: "バースト", attack: 47, probability: 5, health: 260, rarity: .rare),
        Item(name: "レッドドラゴン", attack: 47, probability: 5, health: 280, rarity: .superRare),
        Item(name: "ブルードラゴン", attack: 48, probability: 5, health: 285, rarity: .superRare),
        Item(name: "英雄デル", attack: 50, probability: 10, health: 300, rarity: .superRare),
        Item(name: "覚醒 ライム", attack: 56, probability: 10, health: 300, rarity: .superRare),
        Item(name: "古代ロボ マーク", attack: 30, probability: 10, health: 600, rarity: .superRare),
        Item(name: "メカライオネル", attack: 70, probability: 10, health: 200, rarity: .superRare),
        Item(name: "レインボードラゴン", attack: 50, probability: 3, health: 300, rarity: .ultraRare),
        Item(name: "七福神 玉", attack: 72, probability: 5, health: 350, rarity: .ultraRare),
        Item(name: "七福神 福天丸", attack: 75, probability: 3, health: 380, rarity: .ultraRare),
        Item(name: "ロボ長 バーグ", attack: 60, probability: 5, health: 400, rarity: .ultraRare),
        Item(name: "悪意ロボ ルーク", attack: 70, probability: 3, health: 450, rarity: .ultraRare),
        Item(name: "七福神 金満徳", attack: 100, probability: 3, health: 500, rarity: .legendRare),
        Item(name: "究極完全体バーグ", attack: 200, probability: 3, health: 400, rarity: .legendRare)
    ]
    
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
                        if isOwned && item.rarity == .legendRare {
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
                        
                        Image(isOwned ? item.name : "\(item.name)_シルエット")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .opacity(isOwned ? 1 : 0.4)
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
            if isOwned && item.rarity == .legendRare {
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
                    
                    Image(isOwned ? item.name : "\(item.name)_シルエット")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: item.rarity.color.opacity(0.5), radius: 20, x: 0, y: 10)
                        .offset(y: floatAnimation ? -10 : 10)
                        .opacity(isOwned ? 1 : 0.5)
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
