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
    
    @State private var selectedItem: Avatar?
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    
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
                    HStack {
                        Image(selected.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(15)
                            .padding()
                        Group{
                            Text("\(selected.health)")
                            Text("\(selected.attack)")
                        }
                    }
                }            // LazyVGridを使用してグリッドビューを作成
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(authManager.avatars, id: \.name) { avatar in
//                        VStack{
//                            ZStack{
//                                Group{
//                                    Image(avatar.name) // avatarのnameを使用
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 100, height: 100)
//                                        .padding(5)
//                                        .cornerRadius(8)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .stroke(selectedItem == avatar.name ? Color.gray : Color.clear, lineWidth: 4)
//                                        )
//                                }
//                                VStack {
//                                    Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Image("クロス")
//                                            .resizable()
//                                            .frame(width: 20, height: 20)
//                                        Text("\(avatar.count)")
//                                         .font(.system(size:38))
//                                    }
//                                    .padding(.trailing,5)
//                                }
//                            }
//                        }
//                        .onTapGesture {
//                            selectedItem = avatar
//                        }
                    }
                }
                .onAppear {
                        authManager.fetchAvatars()
                }
                .padding()
            }
        }
        .background(Color("Color2"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        })
    }
}

struct OtomoListView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarListView()
    }
}
