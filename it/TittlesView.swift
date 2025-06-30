//
//  TittlesView.swift
//  itQuiz
//
//  Created by hashimo ryoya on 2024/01/04.
//

import SwiftUI
import Firebase

struct TittlesView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    struct Item: Identifiable {
        let name: String
        let attack: String
        let probability: Int
        let health: String
        let rarity: Rarity
        var id: String { name }
    }

    enum Rarity {
        case normal
        case rare
        case superRare
        case ultraRare
        case legendRare
        
        var displayString: String {
            switch self {
            case .normal:
                return "ノーマル"
            case .rare:
                return "レア"
            case .superRare:
                return "スーパーレア"
            case .ultraRare:
                return "ウルトラレア"
            case .legendRare:
                return "レジェンドレア"
            }
        }
        
        var color: Color {
            switch self {
            case .normal:
                return Color.gray
            case .rare:
                return Color.blue
            case .superRare:
                return Color.purple
            case .ultraRare:
                return Color.orange
            case .legendRare:
                return Color.red
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .normal:
                return Color.gray.opacity(0.1)
            case .rare:
                return Color.blue.opacity(0.1)
            case .superRare:
                return Color.purple.opacity(0.1)
            case .ultraRare:
                return Color.orange.opacity(0.1)
            case .legendRare:
                return Color.red.opacity(0.1)
            }
        }
    }
    
    let allItems: [Item] = [
        Item(name: "レベル３", attack: "スリースター", probability: 25, health: "レベル３を達成したことを讃える称号", rarity: .normal),
        Item(name: "レベル５", attack: "ネオンスター", probability: 25, health: "レベル５を達成したことを讃える称号", rarity: .normal),
        Item(name: "レベル１０", attack: "プラチナスター", probability: 25, health: "レベル１０を達成したことを讃える称号", rarity: .normal),
        Item(name: "回答数３０", attack: "ブロンズコイン", probability: 25, health: "問題の回答数が３０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "回答数５０", attack: "シルバーコイン", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "回答数１００", attack: "ゴールドコイン", probability: 25, health: "問題の回答数が１００問を達成したことを讃える称号", rarity: .normal),
        Item(name: "おとも１０種類制覇", attack: "ライムコイン", probability: 10, health: "おともを１０種類仲間にしたことを讃える称号", rarity: .rare),
        Item(name: "おとも２０種類制覇", attack: "覚醒ライムの盾", probability: 10, health: "おともを２０種類仲間にしたことを讃える称号", rarity: .rare),
        Item(name: "ゴブリン", attack: "ゴブリンの財宝", probability: 10, health: "ゴブリンリーダーを倒した者を称える称号", rarity: .rare),
        Item(name: "ガルーラ", attack: "神秘の海藻", probability: 10, health: "海獣ガルーラを倒した者を称える称号", rarity: .rare),
        Item(name: "ルーン", attack: "神玉", probability: 10, health: "神竜ルーンを倒した者を称える称号", rarity: .rare),
    ]
    
    @State private var selectedItem: Item?
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @State private var switchingAvatar: Avatar?
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var userTitles: [String: Bool] = [:]

    func fetchUserTitles(userId: String) {
        let titlesRef = Database.database().reference().child("titles").child(userId)
        titlesRef.observeSingleEvent(of: .value) { snapshot in
            if let titles = snapshot.value as? [String: Bool] {
                self.userTitles = titles
            }
        }
    }

    var body: some View {
        VStack{
            // 詳細表示エリア
            titleDetailView
            ScrollView {
                VStack(spacing: 30) {
                    // 称号グリッド
                    titleGridView
                }
            }
        }
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.94, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            generateHapticFeedback()
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                Text("戻る")
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
            }
        })
        .navigationTitle("称号一覧")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.selectedItem = allItems.first
            self.fetchUserTitles(userId: authManager.currentUserId ?? "")
            authManager.fetchAvatars {
                for item in allItems {
                    let contains = authManager.avatars.contains(where: { $0.name == item.name })
                }
            }
        }
    }
    
    // 詳細表示ビュー
    private var titleDetailView: some View {
        VStack {
            if let selected = selectedItem {
                VStack(spacing: 20) {
                    
                    if userTitles[selected.name] == true {
                        // 取得済み称号の表示
                        VStack(spacing: 16) {
                            Text(selected.attack)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Image(selected.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            Text(selected.health)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 10)
                        }
                    } else {
                        // 未取得称号の表示
                        VStack(spacing: 16) {
                            Text("???")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.05))
                                    .frame(height: 160)
                                
                                Image("\(selected.name)_シルエット")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .opacity(0.6)
                            }
                            
                            Text(selected.health)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(selected.rarity.color.opacity(0.3), lineWidth: 2)
                )
            }
        }
    }
    
    // グリッドビュー
    private var titleGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allItems) { item in
                    titleCardView(for: item)
                }
            }
        }.padding(5)
    }
    
    // 個別称号カードビュー
    private func titleCardView(for item: Item) -> some View {
        VStack(spacing: 8) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        userTitles[item.name] == true ?
                        Color.white :
                        Color.gray.opacity(0.1)
                    )
                    .frame(height: 100)
                
                // 画像
                if userTitles[item.name] == true {
                    Image(item.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image("\(item.name)_シルエット")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(0.5)
                }
                
                // 取得済みバッジ
                if userTitles[item.name] == true {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            
            
            // 称号名（省略表示）
            Text(item.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(userTitles[item.name] == true ? .primary : .secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(item.rarity.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            selectedItem?.name == item.name ?
                            item.rarity.color :
                            Color.clear,
                            lineWidth: 3
                        )
                )
        )
        .scaleEffect(selectedItem?.name == item.name ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedItem?.name == item.name)
        .onTapGesture {
            generateHapticFeedback()
            selectedItem = item
            audioManager.playSound()
        }
    }
}

#Preview {
//    TittlesView(isPresenting: .constant(false))
    TopView()
}
