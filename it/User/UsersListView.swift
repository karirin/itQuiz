////
////  UsersListView.swift
////  it
////
////  Created by Apple on 2024/12/15.
////
//
//import SwiftUI
//import Foundation
//import FirebaseDatabase
//import Combine
//
//class UsersViewModel: ObservableObject {
//    @Published var users: [User] = []
//    private var dbRef: DatabaseReference
//
//    init() {
//        self.dbRef = Database.database().reference().child("users") // "users" ノードに合わせて変更
//        fetchUsers()
//    }
//
//    func fetchUsers() {
//        dbRef.observe(.value) { snapshot, _ in
//            var fetchedUsers: [User] = []
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let userDict = childSnapshot.value as? [String: Any] {
//                    let user = User(id: childSnapshot.key, data: userDict)
//                    fetchedUsers.append(user)
//                }
//            }
//            // lastLoginDate の昇順でソート
//            fetchedUsers.sort { $0.lastLoginDate < $1.lastLoginDate }
//            DispatchQueue.main.async {
//                self.users = fetchedUsers
//            }
//        }
//    }
//}
//
//struct UsersListView: View {
//    @ObservedObject var viewModel = UsersViewModel()
//
//    var body: some View {
//        NavigationView {
//            List(viewModel.users) { user in
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(user.userName)
//                        .font(.headline)
//
//                    Text("レベル: \(user.level) | ランク: \(user.rank)")
//                        .font(.subheadline)
//
//                    Text("最終ログイン: \(formatDate(timeInterval: user.lastLoginDate))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//
//                    // アバターの表示
//                    if !user.avatars.isEmpty {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(user.avatars) { avatar in
//                                    VStack {
//                                        Text(avatar.name)
//                                            .font(.caption)
//                                        Text("ATK: \(avatar.attack)")
//                                        Text("HP: \(avatar.health)")
//                                    }
//                                    .padding(8)
//                                    .background(Color.blue.opacity(0.1))
//                                    .cornerRadius(8)
//                                }
//                            }
//                        }
//                        .frame(height: 60)
//                    }
//                }
//                .padding(.vertical, 8)
//            }
//            .navigationTitle("ユーザー一覧")
//        }
//    }
//
//    // 日付フォーマットのヘルパー関数
//    func formatDate(timeInterval: TimeInterval) -> String {
//        let date = Date(timeIntervalSince1970: timeInterval)
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        return formatter.string(from: date)
//    }
//}
//
//struct UsersListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersListView()
//    }
//}
