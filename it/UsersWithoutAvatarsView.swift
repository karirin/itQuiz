//
//  UsersWithoutAvatarsView.swift
//  it
//
//  Created by Apple on 2024/12/12.
//

import SwiftUI

struct UsersWithoutAvatarsView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
//                    ProgressView("読み込み中...")
                } else if authManager.userNameTest == "" {
                    Text("アバターを持っていないユーザーはいません。")
                        .foregroundColor(.gray)
                } else {
                    List(authManager.usersWithoutAvatars) { user in
                        VStack(alignment: .leading) {
                            Text(user.userName)
                                .font(.headline)
                            Text("レベル: \(user.level)")
                                .font(.subheadline)
                            Text("経験値: \(user.experience)")
                                .font(.subheadline)
                            // 必要に応じて他のユーザー情報を表示
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("アバターなしユーザー一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        fetchUsers()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                fetchUsers()
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("エラー"), message: Text("ユーザー一覧の取得に失敗しました。"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    /// ユーザー一覧を取得する
    func fetchUsers() {
        isLoading = true
        authManager.fetchUsersWithoutAvatars { success in
            isLoading = false
            if !success {
                showError = true
            }
        }
    }
}

struct UsersWithoutAvatarsView_Previews: PreviewProvider {
    static var previews: some View {
        UsersWithoutAvatarsView()
    }
}
