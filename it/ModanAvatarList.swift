//
//  ModernAvatarListView.swift
//  it
//
//  Updated for modern design
//

import SwiftUI
import Firebase

struct AvatarListView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    @State private var selectedItem: Avatar?
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @State private var switchingAvatar: Avatar?
    @Binding var isPresenting: Bool
    @Namespace private var heroAnimation
    @State private var showDetailView = false
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    // アダプティブグリッドレイアウト
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 85), spacing: 12)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // グラデーション背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Color2").opacity(0.8),
                        Color("Color").opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    // ヘッダー
                    headerView
                    
                    // 選択されたアバターの詳細表示
                    if let selected = selectedItem {
                        selectedAvatarDetailView(selected: selected, geometry: geometry)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // アバターグリッド
                    avatarGridView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onReceive(authManager.$avatars) { newAvatars in
            if let updatedAvatar = newAvatars.first(where: { $0.usedFlag == 1 }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.selectedItem = updatedAvatar
                }
            }
        }
        .onAppear {
            authManager.fetchAvatars {
                if let defaultAvatar = authManager.avatars.first(where: { $0.usedFlag == 1 }) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.selectedItem = defaultAvatar
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("おとも一覧")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("fontGray"), Color("fontGray").opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    // MARK: - Selected Avatar Detail View
    private func selectedAvatarDetailView(selected: Avatar, geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // アバター画像とステータス
            ZStack {
                // 背景カード
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 0) {
                    HStack{
                        Text(selected.name)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("fontGray"))
                        Spacer()
                        
                        statusBadge(selected: selected)
                    }
                    .padding(10)
                    // アバター画像
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color("Color").opacity(0.3), Color("Color").opacity(0.1)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(selected.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .matchedGeometryEffect(id: selected.name, in: heroAnimation)
                        
                    }
                    
                    // ステータス表示
                    HStack(spacing: 24) {
//                        statCard(icon: "heart.fill", value: selected.health, color: .red, label: "HP")
//                        statCard(icon: "bolt.fill", value: selected.attack, color: .orange, label: "攻撃")
//                        statCard(icon: "star.fill", value: selected.count, color: .yellow, label: "レベル")
                        ZStack {
                            Image("ハートバー")
                                .resizable()
                                .frame(width:120,height:40)
                            Text("\(selected.health)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 26))
                                .foregroundColor(Color("fontGray"))
                                .padding(.leading,65)
                                .padding(.top,15)
                        }
                        ZStack {
                            Image("攻撃バー")
                                .resizable()
                                .frame(width:116,height:40)
                            Text("\(selected.attack)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 26))
                                .foregroundColor(Color("fontGray"))
                                .padding(.leading,65)
                                .padding(.top,15)
                        }.padding(.top,5)
                    }
                }
                .padding(10)
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 230)
    }
    
    // MARK: - Status Badge
    private func statusBadge(selected: Avatar) -> some View {
        Group {
            if selected.usedFlag == 1 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("選択中")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(16)
            } else {
                Button(action: {
                    generateHapticFeedback()
                    audioManager.playSound()
                    self.switchingAvatar = selected
                    self.showingAlert1 = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("切り替え")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
                .alert(isPresented: $showingAlert1) {
                    Alert(
                        title: Text("おともを切り替えますか？"),
                        primaryButton: .default(Text("はい"), action: {
                            if let switchingAvatar = switchingAvatar {
                                authManager.switchAvatar(to: switchingAvatar) { success in
                                    if success {
                                        print("Avatar successfully switched!")
                                    } else {
                                        print("Failed to switch avatar.")
                                    }
                                }
                            }
                            audioManager.playChangeSound()
                        }),
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(icon: String, value: Int, color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 30, height: 30)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Text("\(value)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("fontGray"))
            
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
        }
    }
    
    private func gridCard(icon: String, value: Int, color: Color, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 20, height: 20)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 10, weight: .semibold))
            }
            
            Text("\(value)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("fontGray"))
        }
    }
    
    // MARK: - Avatar Grid View
    private var avatarGridView: some View {
        VStack(alignment: .leading, spacing:10) {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(authManager.avatars, id: \.name) { avatar in
                        avatarGridItem(avatar: avatar)
                    }
                }.padding(8)
            }
        }.padding(.top,12)
    }
    
    // MARK: - Avatar Grid Item
    private func avatarGridItem(avatar: Avatar) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playSound()
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if selectedItem == avatar {
                    self.switchingAvatar = avatar
                    self.showingAlert2 = true
                } else {
                    selectedItem = avatar
                }
            }
        }) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: selectedItem?.name == avatar.name ? Color.blue.opacity(0.3) : Color.black.opacity(0.08),
                        radius: selectedItem?.name == avatar.name ? 8 : 4,
                        x: 0,
                        y: selectedItem?.name == avatar.name ? 4 : 2
                    )
                
                VStack(spacing: 8) {
                    // アバター画像
                    ZStack {
                        if avatar.usedFlag == 1 {
                            Circle()
                                .stroke(Color.green, lineWidth: 3)
                                .frame(width: 70, height: 70)
                        }
                        
                        Image(avatar.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
//                            .matchedGeometryEffect(id: avatar.name, in: heroAnimation)
                    }
                    
                    // カウント表示
                    HStack(spacing:5) {
                        HStack(spacing:5) {
                            Image("HPマーク")
                                .resizable()
                                .scaledToFit()
                                .frame(width:20)
                            Text("\(avatar.health)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: fontSize(for: avatar.health)))
                                .foregroundColor(Color("fontGray"))
                                .padding(.top,5)
                        }
                        HStack(spacing:5) {
                            Image("攻撃マーク")
                                .resizable()
                                .scaledToFit()
                                .frame(width:20)
                            Text("\(avatar.attack)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: fontSize(for: avatar.attack)))
                                .foregroundColor(Color("fontGray"))
                                .padding(.top,5)
                        }
                    }
                }
                .padding(.vertical, 12)
                
                // 選択インジケーター
                if selectedItem?.name == avatar.name {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 2)
                }
                
                // 使用中インジケーター
                if avatar.usedFlag == 1 {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 8, weight: .bold))
                                )
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .alert(isPresented: $showingAlert2) {
            Alert(
                title: Text("おともを切り替えますか？"),
                primaryButton: .default(Text("はい"), action: {
                    if let switchingAvatar = switchingAvatar {
                        authManager.switchAvatar(to: switchingAvatar) { success in
                            if success {
                                print("Avatar successfully switched!")
                            } else {
                                print("Failed to switch avatar.")
                            }
                        }
                    }
                    audioManager.playChangeSound()
                }),
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }
    
    private func fontSize(for value: Int) -> CGFloat {
        if value >= 100 { // 3桁以上
            return 12
        } else {
            return 14
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playCancelSound()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("戻る")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color("fontGray"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct AvatarListView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarListView(isPresenting: .constant(false))
    }
}
