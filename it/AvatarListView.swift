//
//  AvatarListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/26.
//

import SwiftUI
import Firebase

struct AvatarListView1: View {
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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("おとも一覧")
                    .font(.system(size: 20))
                    .foregroundColor(Color("fontGray"))
                Spacer()
            }
            .padding()
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
                                .frame(height: 160)
                                .cornerRadius(15)
                            if selected.usedFlag == 1 {
                                Image("おとも選択中")
                                    .resizable()
                                    .frame(width: 80, height: 40)
                                    .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 6.0)
                            } else {
                                Button(action: { 
                        generateHapticFeedback()
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
                        .frame(height:140)
                        HStack{
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
                                    .padding(.top,10)
                            }.padding(.top,5)
                        }
//                        .padding(.top)
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(authManager.avatars, id: \.name) { avatar in
                        VStack{
                            ZStack{
                                if avatar.usedFlag == 1 {
                                                Color("Color")
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(8)
                                            }
                                Button(action: { 
                        generateHapticFeedback()
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
                                        .frame(width: 80, height: 80)
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
                .padding(.horizontal)
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
                        generateHapticFeedback()
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        }).buttonStyle(.plain)
        }
    }

struct OtomoListView1_Previews: PreviewProvider {
    static var previews: some View {
        AvatarListView1(isPresenting: .constant(false))
    }
}
