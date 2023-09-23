//
//  SignUp.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/23.
//

import SwiftUI

struct SignUp: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var userName: String = "りょうた"
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
                        Text("次へ")
                    }
                        .disabled(userName.isEmpty)
                        .padding(.vertical,10)
                        .padding(.horizontal,25)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25)
                            .fill(userName.isEmpty ? Color.gray : Color.red))
                        .opacity(userName.isEmpty ? 0.5 : 1.0)
                        .padding()
                }
            }
        }
    }
}

struct ImagePickerView: View {
    @Binding var userName: String
    @State private var userIcon: UIImage?
    @State private var isImagePickerDisplay = false
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showProfileCreation: Bool = false // 追加
    @State private var selectedIcon: String = "user1"
    @State private var showingIconPicker = false
    let defaultImage = UIImage(named: "defaultProfileImage")
    let icons = ["user1", "user2", "user3"]
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToContentView: Bool = false

    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    Text("アバターを選択してください")
                            .font(.system(size:28))
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<icons.count) { rowIndex in
                            HStack(spacing: 20) {
                                ForEach(0..<3) { colIndex in
                                    let iconIndex = rowIndex * 3 + colIndex
                                    if iconIndex < icons.count {
                                        Button(action: {
                                            self.selectedIcon = icons[iconIndex]
                                        }) {
                                            Image(icons[iconIndex])
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 90, height: 300)
                                            .padding(10)
                                                .border(Color.blue, width: selectedIcon == icons[iconIndex] ? 2 : 0)
                                        }
                                        .padding(.vertical, 10)

                                    }
                                }
                            }
                        }
                    }
                }
                
                Button("ユーザーを作成") {
                        let selectedIconName = selectedIcon
                        authManager.saveUserToDatabase(userName: userName, userIcon: selectedIconName)
                        self.navigateToContentView = true // ユーザーをデータベースに保存した後、ContentViewへの遷移をトリガー
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,25)
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(Color.red))
                    .padding()
                }
                .background(
                    NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToContentView)
                        .hidden() // NavigationLinkを非表示にする
                )
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
