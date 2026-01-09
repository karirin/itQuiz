//
//  TittlesView.swift
//  it
//
//  Modern achievement/title display with celebration animations
//

import SwiftUI
import Firebase

struct TittlesView: View {
    
    // MARK: - Item Model
    struct TitleItem: Identifiable {
        let name: String
        let titleName: String
        let description: String
        let rarity: TitleRarity
        var id: String { name }
    }
    
    // MARK: - Rarity
    enum TitleRarity {
        case bronze, silver, gold, platinum, diamond
        
        var color: Color {
            switch self {
            case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.3)
            case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
            case .gold: return Color(red: 1, green: 0.85, blue: 0.4)
            case .platinum: return Color(red: 0.4, green: 0.8, blue: 0.95)
            case .diamond: return Color(red: 0.9, green: 0.4, blue: 0.95)
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .bronze:
                return LinearGradient(
                    colors: [Color(red: 0.9, green: 0.6, blue: 0.4), Color(red: 0.7, green: 0.4, blue: 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .silver:
                return LinearGradient(
                    colors: [Color(red: 0.85, green: 0.85, blue: 0.9), Color(red: 0.6, green: 0.6, blue: 0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .gold:
                return LinearGradient(
                    colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.95, green: 0.7, blue: 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .platinum:
                return LinearGradient(
                    colors: [Color(red: 0.5, green: 0.9, blue: 1), Color(red: 0.3, green: 0.7, blue: 0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .diamond:
                return LinearGradient(
                    colors: [Color(red: 1, green: 0.5, blue: 1), Color(red: 0.7, green: 0.3, blue: 0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        var icon: String {
            switch self {
            case .bronze: return "star.fill"
            case .silver: return "star.circle.fill"
            case .gold: return "crown.fill"
            case .platinum: return "sparkles"
            case .diamond: return "diamond.fill"
            }
        }
    }
    
    // MARK: - Data
    let allTitles: [TitleItem] = [
        TitleItem(name: "レベル３", titleName: "スリースター", description: "レベル３を達成したことを讃える称号", rarity: .bronze),
        TitleItem(name: "レベル５", titleName: "ネオンスター", description: "レベル５を達成したことを讃える称号", rarity: .bronze),
        TitleItem(name: "レベル１０", titleName: "プラチナスター", description: "レベル１０を達成したことを讃える称号", rarity: .silver),
        TitleItem(name: "回答数３０", titleName: "ブロンズコイン", description: "問題の回答数が３０問を達成したことを讃える称号", rarity: .bronze),
        TitleItem(name: "回答数５０", titleName: "シルバーコイン", description: "問題の回答数が５０問を達成したことを讃える称号", rarity: .silver),
        TitleItem(name: "回答数１００", titleName: "ゴールドコイン", description: "問題の回答数が１００問を達成したことを讃える称号", rarity: .gold),
        TitleItem(name: "おとも１０種類制覇", titleName: "ライムコイン", description: "おともを１０種類仲間にしたことを讃える称号", rarity: .gold),
        TitleItem(name: "おとも２０種類制覇", titleName: "覚醒ライムの盾", description: "おともを２０種類仲間にしたことを讃える称号", rarity: .platinum),
        TitleItem(name: "ゴブリン", titleName: "ゴブリンの財宝", description: "ゴブリンリーダーを倒した者を称える称号", rarity: .gold),
        TitleItem(name: "ガルーラ", titleName: "神秘の海藻", description: "海獣ガルーラを倒した者を称える称号", rarity: .platinum),
        TitleItem(name: "ルーン", titleName: "神玉", description: "神竜ルーンを倒した者を称える称号", rarity: .diamond),
    ]
    
    // MARK: - State
    @State private var selectedTitle: TitleItem?
    @State private var userTitles: [String: Bool] = [:]
    @State private var showCelebration = false
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var isPresenting: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    var earnedCount: Int {
        userTitles.filter { $0.value }.count
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.08, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Background particles
            ParticleBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                // Selected title detail
                if let title = selectedTitle {
                    selectedTitleCard(title)
                        .padding(.top, 20)
                }
                
                // Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(allTitles) { title in
                            TitleCardView(
                                title: title,
                                isEarned: userTitles[title.name] == true,
                                isSelected: selectedTitle?.name == title.name
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedTitle = title
                                }
                                generateHapticFeedback()
                                audioManager.playSound()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 50)
                }
            }
            
            // Celebration overlay
            if showCelebration {
                CelebrationOverlay()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onAppear {
            fetchUserTitles()
            selectedTitle = allTitles.first
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("称号コレクション")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(earnedCount) / \(allTitles.count) 獲得済み")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Trophy icon with count
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.yellow)
                    
                    Text("\(earnedCount)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Selected Title Card
    private func selectedTitleCard(_ title: TitleItem) -> some View {
        let isEarned = userTitles[title.name] == true
        
        return VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Badge
                ZStack {
                    // Outer glow
                    if isEarned {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [title.rarity.color.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                    }
                    
                    // Badge circle
                    Circle()
                        .fill(isEarned ? title.rarity.gradient : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    // Badge border
                    Circle()
                        .stroke(
                            isEarned ? title.rarity.color : Color.gray.opacity(0.3),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                    
                    // Icon
                    Image(systemName: isEarned ? title.rarity.icon : "lock.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(isEarned ? .white : .gray)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(isEarned ? title.titleName : "???")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(isEarned ? .white : .gray)
                    
                    Text(title.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                    
                    // Rarity indicator
                    HStack(spacing: 4) {
                        Image(systemName: title.rarity.icon)
                            .font(.system(size: 12))
                        Text(rarityName(title.rarity))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(title.rarity.color)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isEarned ? title.rarity.color.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
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
    
    // MARK: - Helper Functions
    private func fetchUserTitles() {
        guard let userId = authManager.currentUserId else { return }
        let titlesRef = Database.database().reference().child("titles").child(userId)
        titlesRef.observeSingleEvent(of: .value) { snapshot in
            if let titles = snapshot.value as? [String: Bool] {
                self.userTitles = titles
            }
        }
    }
    
    private func rarityName(_ rarity: TitleRarity) -> String {
        switch rarity {
        case .bronze: return "ブロンズ"
        case .silver: return "シルバー"
        case .gold: return "ゴールド"
        case .platinum: return "プラチナ"
        case .diamond: return "ダイヤモンド"
        }
    }
}

// MARK: - Title Card View
struct TitleCardView: View {
    let title: TittlesView.TitleItem
    let isEarned: Bool
    let isSelected: Bool
    
    @State private var shimmer = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isEarned ?
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? title.rarity.color : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
                
                VStack(spacing: 12) {
                    // Badge
                    ZStack {
                        if isEarned && title.rarity == .diamond {
                            // Shimmer for diamond
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.purple, .pink, .blue, .purple],
                                        center: .center
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .blur(radius: 10)
                                .rotationEffect(.degrees(shimmer ? 360 : 0))
                        }
                        
                        Circle()
                            .fill(isEarned ? title.rarity.gradient : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: isEarned ? title.rarity.icon : "lock.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(isEarned ? .white : .gray)
                    }
                    
                    // Title name
                    Text(isEarned ? title.titleName : "???")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(isEarned ? .white : .gray)
                        .lineLimit(1)
                    
                    // Rarity dots
                    HStack(spacing: 4) {
                        ForEach(0..<rarityLevel, id: \.self) { _ in
                            Circle()
                                .fill(isEarned ? title.rarity.color : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(16)
                
                // Earned badge
                if isEarned {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.black).padding(-2))
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .frame(height: 150)
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            if isEarned && title.rarity == .diamond {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
        }
    }
    
    private var rarityLevel: Int {
        switch title.rarity {
        case .bronze: return 1
        case .silver: return 2
        case .gold: return 3
        case .platinum: return 4
        case .diamond: return 5
        }
    }
}

// MARK: - Particle Background
struct ParticleBackgroundView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .position(x: particle.x * geo.size.width, y: particle.y * geo.size.height)
            }
        }
        .onAppear {
            particles = (0..<30).map { _ in
                Particle(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 1...3),
                    opacity: Double.random(in: 0.1...0.3),
                    speed: Double.random(in: 2...5)
                )
            }
        }
    }
}

// MARK: - Celebration Overlay
struct CelebrationOverlay: View {
    @State private var confetti: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var color: Color
    }
    
    var body: some View {
        GeometryReader { geo in
            ForEach(confetti) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 16)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(x: piece.x * geo.size.width, y: piece.y * geo.size.height)
            }
        }
        .onAppear {
            confetti = (0..<50).map { _ in
                ConfettiPiece(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: -0.2...0),
                    rotation: Double.random(in: 0...360),
                    color: [Color.yellow, Color.purple, Color.blue, Color.green, Color.pink].randomElement()!
                )
            }
        }
    }
}

// MARK: - Preview
struct TittlesView_Previews: PreviewProvider {
    static var previews: some View {
        TittlesView(isPresenting: .constant(false))
    }
}
