//
//  AvatarListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/26.
//

import SwiftUI
import Firebase

struct AvatarListView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    @State private var selectedItem: String? = "もりこう"
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // グリッドのレイアウトを定義
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    

    
    var body: some View {
        VStack {
            // 選択されたアイテムを大きく表示
            if let selected = selectedItem {
                Image(selected)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(15)
                    .padding()
            }
            
            // LazyVGridを使用してグリッドビューを作成
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(authManager.avatars, id: \.name) { avatar in
                        
//                        Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
//                            .resizable()  // 画像のサイズを変更可能にする
//                            .aspectRatio(contentMode: .fit)  // 画像のアスペクト比を保持
//                            .frame(width: 100, height: 100)  // 画像のフレームサイズを設定
//                            .padding(5)
//                            .cornerRadius(8)
//                            .overlay(
//                                // 選択されたアイテムの周りを光らせる
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(selectedItem == avatar ? Color.gray : Color.clear, lineWidth: 4)
//                            )
//                            .onTapGesture {
//                                // アイテムをタップしたときのアクション
//                                selectedItem = avatar
//                            }
                    }
                }
                .onAppear {
                        authManager.fetchAvatars()
                    print("authManager.fetchAvatars():\(authManager.fetchAvatars())")
                }
                .padding()
            }
        }
        .background(Color("Color2"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
            Text("戻る")
                .foregroundColor(.gray)
        })
    }
}

struct OtomoListView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarListView()
    }
}
