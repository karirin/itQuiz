//
//  CheckUsersListView.swift
//  it
//
//  Created by Apple on 2024/12/15.
//

import SwiftUI
import Firebase

class CheckUser: Identifiable {
    var id: String
    var userName: String
    var level: Int
    var experience: Int
    var avatars: [[String: Any]]
    var userMoney: Int
    var userHp: Int
    var userAttack: Int
    var userFlag: Int
    var adminFlag: Int
    var rankMatchPoint: Int
    var rank: Int
    var lastLoginDate: TimeInterval

    init(id: String, userName: String, level: Int, experience: Int, avatars: [[String: Any]], userMoney: Int, userHp: Int, userAttack: Int, userFlag: Int, adminFlag: Int, rankMatchPoint: Int, rank: Int, lastLoginDate: TimeInterval) {
        self.id = id
        self.userName = userName
        self.level = level
        self.experience = experience
        self.avatars = avatars
        self.userMoney = userMoney
        self.userHp = userHp
        self.userAttack = userAttack
        self.userFlag = userFlag
        self.adminFlag = adminFlag
        self.rankMatchPoint = rankMatchPoint
        self.rank = rank
        self.lastLoginDate = lastLoginDate
    }

    // 日付フォーマット用のコンピューテッドプロパティ
    var lastLoginDateFormatted: String {
        let date = Date(timeIntervalSince1970: lastLoginDate)
        return CheckUser.dateFormatter.string(from: date)
    }

    // 静的なDateFormatterを使用してパフォーマンスを向上
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // カスタムフォーマット
        formatter.locale = Locale(identifier: "ja_JP") // ロケールを日本に設定（必要に応じて変更）
        formatter.timeZone = TimeZone.current // 現在のタイムゾーンを使用
        return formatter
    }()
}

struct CheckUsersListView: View {
    @State private var rankNum: Int = 0
    @State var checkUsers = [CheckUser]()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(Array(checkUsers.prefix(500).enumerated()), id: \.element.id) { index, user in
                    HStack {
                        // ユーザーのランキングを表示
                        if (index == 0 || index == 1 || index == 2) {
                            Image("\(index)")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.trailing)
                        } else {
                            if index != 9 {
                                Text("\(index + 1)位")
                                    .font(.system(size: 40))
                                    .padding(.trailing, 5)
                            } else {
                                Text("\(index + 1)位")
                                    .font(.system(size: 30))
                                    .padding(.trailing, 5)
                            }
                        }
                        ForEach(user.avatars.indices, id: \.self) { index in
                            let avatarData = user.avatars[index]
                            //                                // 辞書から値を取り出し、適切にキャストします。
                            if let name = avatarData["name"] as? String, let usedFlag = avatarData["usedFlag"] as? Int, usedFlag == 1 {
                                Image(name)
                                    .resizable()
                                    .frame(width:50,height:50)
                            }
                        }
                        Text(user.userName)
                            .font(.system(size: fontSize1(for: user.userName, isIPad: isIPad())))
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Image("星")
                                    .resizable()
                                    .frame(width: 23, height: 23)
                                Text("\(user.level)レベル")
                            }
                        }
                        .font(.system(size: 16))
                    }
                    .padding(.horizontal)
                    
                    // 最終ログイン日時の表示
                    Text("最終ログイン: \(user.lastLoginDateFormatted)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    Divider()
                }
            }
            .onAppear {
                fetchUsers()
            }
        }
        .background(Color("Color2"))
        .foregroundColor(Color("fontGray"))
    }
    
    func fetchUsers() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [CheckUser] = []

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
                   let lastLoginDate = data["lastLoginDate"] as? TimeInterval,
                   let experience = data["experience"] as? Int {
                    
                    let rankMatchPoint = data["rankMatchPoint"] as? Int ?? 100
                    let rank = data["rank"] as? Int ?? 1

                    var filteredAvatars: [[String: Any]] = []
                    if let avatarsData = data["avatars"] as? [String: [String: Any]] {
                        for (_, avatarData) in avatarsData {
                            if avatarData["usedFlag"] as? Int == 1 {
                                filteredAvatars.append(avatarData)
                            }
                        }
                    }

                    let user = CheckUser(
                        id: userId,
                        userName: userName,
                        level: level,
                        experience: experience,
                        avatars: filteredAvatars,
                        userMoney: userMoney,
                        userHp: userHp,
                        userAttack: userAttack,
                        userFlag: 1,
                        adminFlag: 0,
                        rankMatchPoint: rankMatchPoint,
                        rank: rank,
                        lastLoginDate: lastLoginDate
                    )
//                    if userName.isEmpty {
                        print("user     :\(user)")
                        users.append(user)
//                    }
                }
            }

            checkUsers = users.sorted { $0.lastLoginDate > $1.lastLoginDate }
        }) { (error) in
            print("Error getting users: \(error.localizedDescription)")
        }
    }
    
    func fontSize(for name: String) -> CGFloat {
        let baseFontSize: CGFloat = 24 // ベースとなるフォントサイズ
        let length = name.count // ユーザー名の文字数
        let fontSize = max(baseFontSize - CGFloat(length - 10) * 0.5, 12) // 文字数が10を超えるごとにフォントサイズを0.5小さくし、最小サイズを12にします
        return fontSize
    }

    func fontSize1(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 28 : 24 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 12 {
                return baseFontSize - 14
            } else if text.count >= 10 {
                return baseFontSize - 12
            } else if text.count >= 8 {
                return baseFontSize - 10
            } else if text.count >= 6 {
                return baseFontSize - 8
            } else if text.count >= 4 {
                return baseFontSize
            } else {
                return baseFontSize + 4
            }
        }
    }

    // デバイスがiPadかどうかを判定するヘルパー関数
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

struct CheckUsersListView_Previews: PreviewProvider {
    static var previews: some View {
        CheckUsersListView()
    }
}
