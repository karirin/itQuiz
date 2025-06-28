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
        let name: String  // これが一意の識別子として機能します
        let attack: String
        let probability: Int
        let health: String
        let rarity: Rarity
        var id: String { name }  // Identifiable の要件を満たすために name を id として使用
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
                return "ノーマル" // 任意の文字列を返す
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
    }
    
    let allItems: [Item] = [
        Item(name: "レベル３", attack: "スリースター", probability: 25,health: "レベル３を達成したことを讃える称号", rarity: .normal),
        Item(name: "レベル５", attack: "ネオンスター", probability: 25,health: "レベル５を達成したことを讃える称号", rarity: .normal),
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
    // アラートを表示するかどうかを制御するState変数
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    // 切り替えるアバターを保持するState変数
    @State private var switchingAvatar: Avatar?
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
    }
    
    // グリッドのレイアウトを定義
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var userTitles: [String: Bool] = [:] // ユーザーの称号データ

    // ユーザーの称号データを取得する関数
    func fetchUserTitles(userId: String) {
        let titlesRef = Database.database().reference().child("titles").child(userId)
        titlesRef.observeSingleEvent(of: .value) { snapshot in
            if let titles = snapshot.value as? [String: Bool] {
                self.userTitles = titles
//                print("self.userTitles:\(self.userTitles)")
            }
        }
    }

    var body: some View {
        VStack {
            // 選択されたアイテムを大きく表示
            if let selected = selectedItem {
                if userTitles[selected.name] == true {
                    ZStack{
//                        Image("\(selected.rarity.displayString)")
//                            .resizable()
//                            .frame(width: 70,height:70)
//                            .padding(.trailing,240)
//                            .padding(.bottom,100)
                        VStack {
                            Text(selected.attack)
                                .font(.system(size:28))
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray)
                            Image(selected.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .cornerRadius(15)
                                .frame(height:180)
                            Text(selected.health)
                                .font(.system(size:24))
                                .foregroundColor(Color("fontGray"))
                                .padding(.horizontal)
                                .frame(height:60)
//                            HStack{
//                                Image("ハート")
//                                    .resizable()
//                                    .frame(width: 20,height:20)
//                                Text("\(selected.health)")
//                                    .font(.system(size:24))
//                                    .foregroundColor(Color("fontGray"))
//                                Image("ソード")
//                                    .resizable()
//                                    .frame(width: 25,height:20)
//                                Text("\(selected.attack)")
//                                    .font(.system(size:24))
//                                    .foregroundColor(Color("fontGray"))
//                            }
                        }
                    }
                    
                }else{
                    ZStack{
//                        Image("\(selected.rarity.displayString)")
//                            .resizable()
//                            .frame(width: 70,height:70)
//                            .padding(.trailing,240)
//                            .padding(.bottom,100)
                        VStack {
                            Text("???")
                                .font(.system(size:28))
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray)
                            Image("\(selected.name)_シルエット")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .cornerRadius(15)
                                .frame(height:180)
                            Text(selected.health)
                                .font(.system(size:24))
                                .foregroundColor(Color("fontGray"))
                                .padding(.horizontal)
                                .frame(height:60)
//                            HStack{
//                                Image("ハート")
//                                    .resizable()
//                                    .frame(width: 20,height:20)
//                                Text("???")
//                                    .font(.system(size:24))
//                                    .foregroundColor(Color("fontGray"))
//                                Image("ソード")
//                                    .resizable()
//                                    .frame(width: 25,height:20)
//                                Text("???")
//                                    .font(.system(size:24))
//                                    .foregroundColor(Color("fontGray"))
//                            }
                        }
                    }
                }
            }
            ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(allItems) { item in
                                VStack{
                                    // ユーザーが持っているアバターの判定
//                                    if authManager.avatars.contains(where: { $0.name == item.name }) {
                                    if userTitles[item.name] == true {
                                        // ユーザーが持っているアバターの画像を表示
                                        Button(action: {
                                            selectedItem = item
                                            audioManager.playSound()
                                        }) {
                                            Image(item.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                                .padding(5)
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        // ユーザーが持っていないアバターのシルエットを表示
                                        Button(action: {
                                            selectedItem = item
                                            audioManager.playSound()
                                        }) {
                                            Image("\(item.name)_シルエット") // シルエット画像は適宜用意してください
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                }
                                .overlay(
                                   RoundedRectangle(cornerRadius: 10)
                                       .stroke((selectedItem?.name == item.name) ? Color.gray : Color.clear, lineWidth: 4)
                               )
                            }
                        }
                    }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .onAppear {
                self.fetchUserTitles(userId: authManager.currentUserId ?? "")
                authManager.fetchAvatars {
                    for item in allItems {
                        let contains = authManager.avatars.contains(where: { $0.name == item.name })
                    }
                }
            }
Spacer()
        }
        .padding(.top,5)
        .onAppear {
            self.selectedItem = Item(name: "レベル３", attack: "スリースター", probability: 25,health: "レベル３を達成したことを讃える称号", rarity: .normal)
        }
        .background(Color(hue: 0.557, saturation: 0.098, brightness: 1.0))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        }).buttonStyle(.plain)
        .navigationTitle("称号一覧")
        .navigationBarTitleDisplayMode(.inline)
        }
    }

#Preview {
    TittlesView(isPresenting: .constant(false))
}
