//
//  SignUp.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/23.
//

import SwiftUI

struct SignUp: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var userName: String = ""
    @State private var showImagePicker: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                    HStack{
                    Text("名前を入力してください")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                    }
                Text("20文字以下で入力してください")
                            .font(.system(size: 18))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top,5)
                    HStack {
                        Spacer()
                        ZStack(alignment: .trailing) {
                TextField("名前", text: $userName)
                        .onChange(of: userName) { newValue in
                            if newValue.count > 20 {
                                userName = String(newValue.prefix(20))
                            }
                        }
                                .font(.system(size: 30))
                                .padding(.trailing, userName.isEmpty ? 0 : 40)
                            if !userName.isEmpty {
                                                   Button(action: {
                                                       self.userName = ""
                                                   }) {
                                                       Image(systemName: "xmark.circle.fill")
                                                           .foregroundColor(.gray)
                                                   }
                                                   .font(.system(size: 30))
                                                   .padding(.trailing, 5) // バツ印の位置を調整
                                               }
                                           }
                        .padding()
                                Spacer() // this will push the TextField to the center
                        Spacer()
                                                }
                    .padding()
                Text("\(userName.count)/20")
                       .font(.system(size: 30))
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                                       .padding(.bottom)
                NavigationLink(destination: ImagePickerView(userName: $userName), isActive: $showImagePicker) {
                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        ZStack {
                            // ボタンの背景
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .frame(width: 140, height: 70)
                                .shadow(radius: 3) // ここで影をつけます
                            Text("次へ")
                        }
                    }
                    
                    .font(.system(size:26))
                    .foregroundColor(Color.gray)
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(userName.isEmpty ? Color.gray : Color.white))
                    .opacity(userName.isEmpty ? 0.5 : 1.0)
                }.disabled(userName.isEmpty)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ImagePickerView: View {
    @Binding var userName: String
    @State private var avator: UIImage?
    @State private var isImagePickerDisplay = false
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showProfileCreation: Bool = false // 追加
    @State private var selectedIcon: String = "ネッキー"
    @State private var showingIconPicker = false
    let defaultImage = UIImage(named: "defaultProfileImage")
    @State private var selectedAvatar: Avatar? // 選択したアバターを保持するプロパティ
    let avatars = [
        Avatar(name: "ネッキー", attack: 10, health: 20, usedFlag: 1, count: 1),
        Avatar(name: "ピョン吉", attack: 15, health: 15, usedFlag: 0, count: 1),
        Avatar(name: "ルイーカ", attack: 20, health: 10, usedFlag: 0, count: 1)
    ]
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToContentView: Bool = false

    var body: some View {
        NavigationView{
            VStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                        Text("戻る")
                            .foregroundColor(.black)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.leading)
                }
                Spacer()
                HStack{
                    Text("おともを選択してください")
                            .font(.system(size:28))
                }
                Spacer()
                if let selected = selectedAvatar {
                    VStack {
                        Text(selected.name)
                            .font(.system(size:24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                        Image(selected.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 180)
                            .cornerRadius(15)
                        HStack{
                            Image("ハート")
                                .resizable()
                                .frame(width: 20,height:20)
                            Text("\(selected.health)")
                                .font(.system(size:24))
                            Image("ソード")
                                .resizable()
                                .frame(width: 25,height:20)
                            Text("\(selected.attack)")
                                .font(.system(size:24))
                        }
                    }
                }
                Spacer()
                    HStack() {
                        ForEach(avatars, id: \.name) { avatar in
                            Button(action: {
                                self.selectedAvatar = avatar
                            }) {
                                Image(avatar.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(10)
                                    .border(Color.blue, width: selectedAvatar?.name == avatar.name ? 2 : 0)
                            }
                        }
                    }
                Spacer()
                Button(action: {
                    let selectedAvatar = Avatar(name: self.selectedAvatar?.name ?? "ネッキー", attack: 20, health: 20 ,usedFlag: 1, count:1)
                    authManager.saveUserToDatabase(userName: userName) { success in
                        if success {
                            authManager.addAvatarToUser(avatar: selectedAvatar) { success in
                                if success {
                                    self.navigateToContentView = true
                                } else {
                                    // アバターの追加に失敗した場合の処理をここに書く
                                }
                            }
                        } else {
                            // ユーザー情報の保存に失敗した場合の処理をここに書く
                        }
                    }
                }) {
                    ZStack {
                    // ボタンの背景
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(width: 300, height: 70)
                        .shadow(radius: 3) // ここで影をつけます
                    Text("ユーザーを作成")
                        .shadow(radius: 0)
                }
                    }
                    .padding(.vertical,20)
                    .padding(.horizontal,35)
                    .font(.system(size:26))
                    .foregroundColor(Color("fontGray"))
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(.white))
                    .padding()
                
            Spacer()
//                Spacer()
                }
            
                .background(
//                    NavigationLink("", destination: ContentView(isPresentingQuizBeginnerList: .constant(false), isPresentingAvatarList: .constant(false)).navigationBarBackButtonHidden(true), isActive: $navigateToContentView)
                    NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToContentView)
                        .hidden() // NavigationLinkを非表示にする
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear{
            self.selectedAvatar = avatars[0]
        }
        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.black)
//            Text("戻る")
//                .foregroundColor(.black)
//        })
    }
}

struct SignUp_Previews: PreviewProvider {
    @State static var userName: String = "りょうや" // ここでダミーのユーザー名を設定
    @State static var defaultImage = UIImage(named: "defaultProfileImage")

    static var previews: some View {
         SignUp()
//        ImagePickerView(userName: $userName) // ダミーのユーザー名を渡す
//        ProfileCreationView(userName: $userName, userIcon: $defaultImage)
    }
}
