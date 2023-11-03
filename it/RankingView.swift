//
//  RankingView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/01.
//

import SwiftUI
import Firebase

class RankingViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var displayedUserCount = 4
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []

            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Could not parse users data")
                return
            }

            for (userId, data) in usersData {
                if let userName = data["userName"] as? String,
                   let userMoney = data["userMoney"] as? Int,
                   let userHp = data["userHp"] as? Int,
                   let userAttack = data["userAttack"] as? Int,
                   let level = data["level"] as? Int,
                   let experience = data["experience"] as? Int {

                    // アバターデータがあればフィルタリング
                    var filteredAvatars: [[String: Any]] = []
                    if let avatarsData = data["avatars"] as? [String: [String: Any]] {
                        for (_, avatarData) in avatarsData {
                            if avatarData["usedFlag"] as? Int == 1 {
                                filteredAvatars.append(avatarData)
                            }
                        }
                    }

                    let user = User(id: userId,
                                    userName: userName,
                                    level: level,
                                    experience: experience,
                                    avatars: filteredAvatars,
                                    userMoney: userMoney,
                                    userHp: userHp,
                                    userAttack: userAttack)
                    users.append(user)
                }
            }

            // レベルが高い順にソート
            self.users = users.sorted { $0.level > $1.level }
        }) { (error) in
            print("Error getting users: \(error.localizedDescription)")
        }
    }
    
    func showMoreUsers() {
        displayedUserCount = 10  // 表示するユーザー数を10に更新
    }

}

struct TopFourRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        VStack {
            // ここにトップ4用のデザインを追加
            ForEach(viewModel.users.prefix(4), id: \.id) { user in
                HStack {
                    // トップ4のユーザーデザイン
                    Text(user.userName)
                    Spacer()
                    Text("レベル: \(user.level)")
                }
            }
        }
    }
}

struct TopTenRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        List(viewModel.users.prefix(10), id: \.id) { user in
            HStack {
                Text(user.userName)
                Spacer()
                Text("レベル: \(user.level)")
            }
        }
        .navigationTitle("トップ10ランキング")
    }
}

struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TopFourRankingView(viewModel: viewModel)
                
                NavigationLink(destination: TopTenRankingView(viewModel: viewModel)) {
                    Text("TOP10まで確認する")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("ランキング")
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
