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

    var body: some View {
        VStack {
            // 選択されたアイテムを大きく表示
            if let selected = selectedItem {
                VStack {
                    Text(selected.name)
                        .font(.system(size:24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                        ZStack{
                            Image(selected.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .cornerRadius(15)
                            if selected.usedFlag == 1 {
                                Image("おとも選択中")
                                    .resizable()
                                    .frame(width: 80, height: 40)
                                    .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 4.7)
                            } else {
                                Button(action: {
                                    audioManager.playSound()
                                    self.switchingAvatar = selected
                                    self.showingAlert1 = true
                                }) {
                                    Image("おとも切り替え")
                                        .resizable()
                                        .frame(width: 80, height: 40)
                                        .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 21.0)
                                }
                                .alert(isPresented: $showingAlert1) {
                                    Alert(
                                        title: Text("おともを切り替えますか？"),
                                        primaryButton: .default(Text("はい"), action: {
                                            // はいを選択した場合、usedFlagを更新
                                            if let switchingAvatar = switchingAvatar {
                                                authManager.switchAvatar(to: switchingAvatar) { success in
                                                    if success {
                                                        print("Avatar successfully added!")
                                                    } else {
                                                        print("Failed to add avatar.")
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
                        .frame(height:180)
                        HStack{
                            Image("ハート")
                                .resizable()
                                .frame(width: 20,height:20)
                            Text("\(selected.health)")
                                .font(.system(size:24))
                                .foregroundColor(Color("fontGray"))
                            Image("ソード")
                                .resizable()
                                .frame(width: 25,height:20)
                            Text("\(selected.attack)")
                                .font(.system(size:24))
                                .foregroundColor(Color("fontGray"))
                        }
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(authManager.avatars, id: \.name) { avatar in
                        VStack{
                            ZStack{
                                if avatar.usedFlag == 1 {
                                                Color("Color")
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(8)
                                            }
                                Button(action: {
                                    // ここにおともを切り替えるコードを書く
                                    self.switchingAvatar = avatar
                                    if selectedItem == avatar {
                                        // 2回目のタップでアラートを表示
                                        self.switchingAvatar = avatar
                                        self.showingAlert2 = true
                                    }
                                    selectedItem = avatar
                                    audioManager.playSound()
                                }) {
                                    Image(avatar.name) // avatarのnameを使用
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .padding(5)
                                        .cornerRadius(8)
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image("クロス")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("\(avatar.count)")
                                            .font(.system(size:38))
                                            .foregroundColor(Color("fontGray"))
                                    }
                                    .padding(.trailing,5)
                                }
                            }
                            
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((selectedItem?.name == avatar.name) ? Color.gray : Color.clear, lineWidth: 4)
                            )
                        }
                        .alert(isPresented: $showingAlert2) {
                            Alert(
                                title: Text("おともを切り替えますか？"),
                                primaryButton: .default(Text("はい"), action: {
                                    // はいを選択した場合、usedFlagを更新
                                    if let switchingAvatar = switchingAvatar {
                                        authManager.switchAvatar(to: switchingAvatar) { success in
                                            if success {
                                                print("Avatar successfully added!")
                                            } else {
                                                print("Failed to add avatar.")
                                            }
                                        }
                                    }
                                    audioManager.playChangeSound()
                                }),
                                secondaryButton: .cancel(Text("キャンセル"))
                            )
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .onReceive(authManager.$avatars) { newAvatars in
                        // avatarsが更新されたときに呼ばれる
                        if let updatedAvatar = newAvatars.first(where: { $0.usedFlag == 1 }) {
//                            print(updatedAvatar)
                            self.selectedItem = updatedAvatar
                        }
                    }
            .onAppear {
                authManager.fetchAvatars {
                    if let defaultAvatar = authManager.avatars.first(where: { $0.usedFlag == 1 }) {
                        self.selectedItem = defaultAvatar
                    }
                }
            }
Spacer()
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
        AvatarListView(isPresenting: .constant(false))
    }
}
