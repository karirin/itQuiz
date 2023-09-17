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

    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    HStack{
                        Text("アイコン")
                            .bold()
                        Spacer()
                        Button(action: {
                            self.showingIconPicker.toggle()
                        }) {
                            Image(selectedIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                Text("必須入力では無いです")
                    .font(.system(size: 18))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top,5)
                Button(action: {
                    self.isImagePickerDisplay = true
                }) {
                    if let image = userIcon {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .scaledToFit()
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                        }
                        
                    }
                }
                
                Button("ユーザーを作成") {
                    let selectedIcon = userIcon ?? defaultImage
                    authManager.createUser(name: userName, icon: selectedIcon) // 変更
                }
                .padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color("green")))
                .padding()
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon, showingIconPicker: $showingIconPicker)
        }
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
