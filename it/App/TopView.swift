//
//  TopView.swift
//  it
//
//  Modern TabView with custom tab bar design
//

import SwiftUI

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs: [(icon: String, title: String)] = [
        ("house.fill", "ホーム"),
        ("map.fill", "ダンジョン"),
        ("square.grid.2x2.fill", "おとも"),
        ("chart.pie.fill", "分析"),
        ("gearshape.fill", "設定")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index,
                    animation: animation
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    generateHapticFeedback()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Blur background
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.3, blue: 0.95),
                                    Color(red: 0.3, green: 0.5, blue: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .matchedGeometryEffect(id: "TAB_BACKGROUND", in: animation)
                        .shadow(color: Color.purple.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(width: 48, height: 48)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Top View 
struct TopView: View {
    @State private var selectedTab: Int = 0
    @State private var isPresentingAvatarList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @StateObject private var storyViewModel = PositionViewModel.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.1, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Tab content
            TabView(selection: $selectedTab) {
                ContentView()
                    .tag(0)
                
                StoryView(isReturnActive: .constant(false), isPresented: .constant(false))
                    .tag(1)
                
                AvatarListView(isPresenting: $isPresentingAvatarList)
                    .tag(2)
                
                GraphManagerView()
                    .tag(3)
                
                SettingView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom tab bar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                storyViewModel.handleAppWentToBackground()
            case .active:
                storyViewModel.handleAppBecameActive()
            default:
                break
            }
        }
    }
}

// MARK: - Floating Tab Bar (Alternative)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, selectedIcon: String)] = [
        ("house", "house.fill"),
        ("map", "map.fill"),
        ("square.grid.2x2", "square.grid.2x2.fill"),
        ("chart.pie", "chart.pie.fill"),
        ("gearshape", "gearshape.fill")
    ]
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    generateHapticFeedback()
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            // Selection indicator
                            if selectedTab == index {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.5, green: 0.3, blue: 0.95),
                                                Color(red: 0.3, green: 0.5, blue: 0.95)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.purple.opacity(0.5), radius: 8, x: 0, y: 4)
                            }
                            
                            Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedTab == index ? .white : .gray)
                        }
                        .frame(width: 44, height: 44)
                        
                        // Dot indicator
                        Circle()
                            .fill(selectedTab == index ? Color.purple : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Glass effect
                Capsule()
                    .fill(.ultraThinMaterial)
                
                Capsule()
                    .fill(Color.black.opacity(0.3))
                
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Dock Style Tab Bar
struct DockStyleTabBar: View {
    @Binding var selectedTab: Int
    @State private var hoverIndex: Int? = nil
    
    let tabs: [(icon: String, label: String, color: Color)] = [
        ("house.fill", "ホーム", Color.blue),
        ("map.fill", "ダンジョン", Color.red),
        ("sparkles", "おとも", Color.purple),
        ("chart.bar.fill", "分析", Color.green),
        ("gearshape.fill", "設定", Color.gray)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<tabs.count, id: \.self) { index in
                DockIcon(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    color: tabs[index].color,
                    isSelected: selectedTab == index,
                    isHovered: hoverIndex == index
                )
                .scaleEffect(selectedTab == index ? 1.15 : (hoverIndex == index ? 1.1 : 1.0))
                .offset(y: selectedTab == index ? -8 : 0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        selectedTab = index
                    }
                    generateHapticFeedback()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.4))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.5), radius: 25, x: 0, y: 15)
    }
}

// MARK: - Dock Icon
struct DockIcon: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let isHovered: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background glow
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.5), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                }
                
                // Icon background
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [color, color.opacity(0.7)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: isSelected ? color.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Selection indicator dot
            Circle()
                .fill(isSelected ? color : Color.clear)
                .frame(width: 5, height: 5)
        }
    }
}

func generateHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

// MARK: - Preview
struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(AppState())
    }
}
