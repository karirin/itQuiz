//
//  RankingView.swift
//  sukimaKanji
//
//  Created by Apple on 2024/06/23.
//

import SwiftUI
import Firebase

struct ChangeNameView: View {
    @Binding var isPresented: Bool
    @Binding var tutorialNum: Int
//    @Binding var userName: String
    @State private var userName: String = ""
    @State private var showAlert = false
    @ObservedObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    if !userName.isEmpty {
//                        showAlert = true
//                        isPresented = false
//                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
//                            tutorialNum = 1
//                            // データベースのアップデートが成功したかどうかをハンドリング
//                        }
//                    }
//                }
            VStack{
                HStack{
                    Spacer()
                    VStack {
                        Text("名前を登録する")
                            .font(.system(size:22))
                        Text("※１度登録すると変更することができません")
                            .font(.system(size:14))
                            .padding(.vertical,5)
                    }
                    Spacer()
                }
                .padding(.top)
                
                VStack(alignment: .center){
                    TextField("太郎", text: $userName)
                        .onChange(of: userName) { newValue in
                            if newValue.count > 10 {
                                userName = String(newValue.prefix(10))
                            }
                        }
                        .padding(5)
                        .padding(.leading)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text("\(userName.count) / 10")
                        .font(.system(size: 20))
                        .font(.caption)
                    Button(action: {
                        authManager.updateUserName(userName: userName) { success in
                            if success {
                                showAlert = true
                            }
                        }
                        showAlert = true
                    }, label: {
                        Text("登録する")
                            .fontWeight(.semibold)
                            .frame(width: 130, height:40)
                            .foregroundColor(Color.white)
                            .background(Color.gray)
                            .cornerRadius(24)
                    })
                    .shadow(radius: 3)
                    .padding(.top,5)
                    .padding(.bottom,10)
                    .opacity(userName.isEmpty ? 0.5 : 1.0)
                    .disabled(userName.isEmpty)
                }
            }
        .foregroundColor(Color("fontGray"))
        .padding()
        .background(Color("Color2"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 5)
        )
        .padding(20)
        .cornerRadius(20)
        .shadow(radius: 10)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(""),
                message: Text("名前が登録されました"),
                dismissButton: .default(Text("OK")) {
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                        tutorialNum = 1
                        isPresented = false
                    }
                }
            )
        }
            
        }
    }

    func saveName() {
        let ref = Database.database().reference()
        ref.child("users").child(authManager.currentUserId!).child("userName").setValue(userName) { error, _ in
            if let error = error {
                print("Failed to save name: \(error.localizedDescription)")
            } else {
                print("Successfully saved name")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ChangeNameView_Previews: PreviewProvider {
    
    static var previews: some View {
        @ObservedObject var authManager = AuthManager.shared
//        ChangeNameView(isPresented: .constant(false), tutorialNum: .constant(1), userName: .constant("name"))
        ChangeNameView(isPresented: .constant(false), tutorialNum: .constant(1), authManager: authManager)
    }
}
