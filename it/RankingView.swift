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
    @Published var rankMatchUsers = [User]()
    @Published var displayedUserCount = 10
    @State private var rankNum: Int = 0
    @Published var userAnswerDataList = [UserAnswerData]()
    @ObservedObject var authManager = AuthManager.shared
    @Published var currentUserRank: Int?
    @Published var currentUserLevelRank: Int?
    @Published var userAvatarCounts: [UserAvatarCount] = []
    @Published var currentUserAvatarRank: Int?

    
    init() {
        fetchUsers()
//        fetchMonthlyAnswers()
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
                   let experience = data["experience"] as? Int{

                    // rankMatchPointが存在しない場合は、デフォルト値100を使用
                    let rankMatchPoint = data["rankMatchPoint"] as? Int ?? 100
                    let rank = data["rank"] as? Int ?? 1

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
                                    userAttack: userAttack, userFlag: 1, adminFlag: 0, rankMatchPoint: rankMatchPoint, rank: rank)
                    users.append(user)
                }
            }

            // レベルが高い順にソート
            self.users = users.sorted { $0.level > $1.level }
            DispatchQueue.main.async {
                self.calculateLevelRankings()
            }
            self.fetchMonthlyAnswers()
        }) { (error) in
    //        print("Error getting users: \(error.localizedDescription)")
        }
    }

    
//    func fetchUsers() {
//        let usersRef = Database.database().reference().child("users")
//        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            var users: [User] = []
//
//            guard let usersData = snapshot.value as? [String: [String: Any]] else {
//                print("Error: Could not parse users data")
//                return
//            }
//
//            for (userId, data) in usersData {
//                if let userName = data["userName"] as? String,
//                   let userMoney = data["userMoney"] as? Int,
//                   let userHp = data["userHp"] as? Int,
//                   let userAttack = data["userAttack"] as? Int,
//                   let level = data["level"] as? Int,
//                   let experience = data["experience"] as? Int {
//                    
//                    // rankMatchPointが存在しない場合は100をデフォルト値として使用
//                    let rankMatchPoint = data["rankMatchPoint"] as? Int ?? 100
//
//                    var filteredAvatars: [[String: Any]] = []
//                    if let avatarsData = data["avatars"] as? [String: [String: Any]] {
//                        for (_, avatarData) in avatarsData {
//                            if avatarData["usedFlag"] as? Int == 1 {
//                                filteredAvatars.append(avatarData)
//                            }
//                        }
//                    }
//
//                    let user = User(id: userId,
//                                    userName: userName,
//                                    level: level,
//                                    experience: experience,
//                                    avatars: filteredAvatars,
//                                    userMoney: userMoney,
//                                    userHp: userHp,
//                                    userAttack: userAttack, userFlag: 1,adminFlag: 0, rankMatchPoint: rankMatchPoint)
//                    users.append(user)
//                }
//            }
//
//            // レベルが高い順にソート
//            self.users = users.sorted { $0.level > $1.level }
//            DispatchQueue.main.async {
//                        self.calculateLevelRankings()
//                    }
//            self.fetchMonthlyAnswers()
//        }) { (error) in
//            // エラーハンドリング
//        }
//    }
    
    func rankMatchFetchUsers() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []
            
            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Could not parse users data")
                return
            }
            
            guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
            
            var currentUserRank: Int? = nil
            for (userId, data) in usersData {
                if userId == currentUserUID {
                    currentUserRank = data["rank"] as? Int ?? 1
                    break
                }
            }
            
            let sameRankUsers = usersData.filter { $1["rank"] as? Int == currentUserRank && $0 != currentUserUID }
            let otherUsers = usersData.filter { $1["rank"] as? Int != currentUserRank && $0 != currentUserUID }
            
            for array in [sameRankUsers, otherUsers] {
                for (userId, data) in array {
                    if let userName = data["userName"] as? String,
                       let userMoney = data["userMoney"] as? Int,
                       let userHp = data["userHp"] as? Int,
                       let userAttack = data["userAttack"] as? Int,
                       let level = data["level"] as? Int,
                       let experience = data["experience"] as? Int {
                        // rankMatchPointが存在しない場合は100をデフォルト値として使用
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
                        
                        let user = User(id: userId, userName: userName, level: level, experience: experience, avatars: filteredAvatars, userMoney: userMoney, userHp: userHp, userAttack: userAttack, userFlag: 1, adminFlag: 0, rankMatchPoint: rankMatchPoint, rank: rank)
                        users.append(user)
                    }
                }
            }
            
            // ここでユーザーリストの更新とその他の処理を行います
            self.rankMatchUsers = users
            DispatchQueue.main.async {
                self.calculateLevelRankings()
            }
            self.fetchMonthlyAnswers()
        }) { (error) in
            // エラーハンドリング
        }
    }


    
    private func calculateLevelRankings() {
        // ユーザーをレベルが高い順にソート（レベルが同じ場合は経験値でソート、それでも同じ場合はIDでソート）
        let sortedUsers = users.sorted {
            if $0.level == $1.level {
                return $0.experience == $1.experience ? $0.id < $1.id : $0.experience > $1.experience
            }
            return $0.level > $1.level
        }
//        print("sortedUsers:\(sortedUsers)")

        // ログイン中のユーザーの順位を見つける
        if let currentUserIndex = sortedUsers.firstIndex(where: { $0.id == self.authManager.currentUserId }) {
//            print("currentUserIndex:\(currentUserIndex)")
            // 順位はインデックス+1（配列は0から始まるため）
            self.currentUserLevelRank = currentUserIndex + 1
        }
    }
    
    func fetchMonthlyAnswers() {
        let answersRef = Database.database().reference().child("answers")
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: now)

        answersRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            var answerCounts: [String: Int] = [:]

            guard let answersData = snapshot.value as? [String: AnyObject] else {
                print("Error: Could not parse answers data")
                return
            }

            for (userId, categoriesData) in answersData {
                guard let categories = categoriesData as? [String: [String: Int]] else {
                    continue
                }

                var totalAnswersForMonth = 0
                for (_, dates) in categories {
                    for (date, count) in dates {
                        if date.hasPrefix(currentMonth) {
                            totalAnswersForMonth += count
                        }
                    }
                }
                answerCounts[userId] = totalAnswersForMonth
            }
        
            DispatchQueue.main.async {
                self.userAnswerDataList = self.users.compactMap { user in
                    // ユーザーのアバター情報から、表示に使用するアバターの名前を選択します。
                    // ここではシンプルに最初のアバターの名前を使用しています。
                    let avatarName = user.avatars.first?["name"] as? String ?? ""
                    guard let answerCount = answerCounts[user.id] else { return nil }
                    return UserAnswerData(userId: user.id, userName: user.userName, answerCount: answerCount, avatarName: avatarName)
                }
                .sorted { $0.answerCount > $1.answerCount }
                .prefix(10)
                .map { $0 }
            }
            DispatchQueue.main.async {
                // ここでuserAnswerDataListが更新された後...
                let sortedAnswerCounts = answerCounts.sorted {
                    if $0.value == $1.value {
                        return $0.key < $1.key // 回答数が同じ場合はユーザーIDでソート
                    }
                    return $0.value > $1.value // まずは回答数で降順にソート
                }
                let maxRank = sortedAnswerCounts.count // 最下位の順位
                let userRankings = sortedAnswerCounts.enumerated().map { (index, element) -> (userId: String, rank: Int) in
                    let rank = element.value > 0 ? index + 1 : maxRank // 回答数が0の場合は最下位
                    return (element.key, rank)
                }
                // ログインユーザーの順位を見つける
                if let currentUserRanking = userRankings.first(where: { $0.userId == self.authManager.currentUserId }) {
                    // ここでログインユーザーの順位が currentUserRanking.rank に格納される
                    self.currentUserRank = currentUserRanking.rank
                }
            }
        })
    }

    func fetchUsersByAvatarCount() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            var userAvatarCounts: [UserAvatarCount] = []

            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Could not parse users data")
                return
            }

            for (userId, data) in usersData {
                if let userName = data["userName"] as? String,
                   let avatarsData = data["avatars"] as? [String: [String: Any]] {
                    var totalAvatarCount = 0 // アバターの合計数を保持する変数
                    var usedAvatarName: String? = nil // 使用中のアバター名

                    // アバターデータをループして合計を計算
                    for (_, avatarData) in avatarsData {
                        if let count = avatarData["count"] as? Int {
                            totalAvatarCount += count // 各アバターのcountを合算
                        }
                        if avatarData["usedFlag"] as? Int == 1, usedAvatarName == nil {
                            usedAvatarName = avatarData["name"] as? String // 使用中のアバター名を設定
                        }
                    }

                    let userAvatarCount = UserAvatarCount(
                        userId: userId,
                        userName: userName,
                        avatarCount: totalAvatarCount,
                        avatarName: usedAvatarName ?? "defaultAvatar" // 使用中のアバター名がない場合はデフォルト名を使用
                    )
                    userAvatarCounts.append(userAvatarCount)
                }
            }

            // アバター数が多い順にソート
            self.userAvatarCounts = userAvatarCounts.sorted(by: { $0.avatarCount > $1.avatarCount })
            
            // ログインユーザーの順位を計算
            if let currentUserIndex = self.userAvatarCounts.firstIndex(where: { $0.userId == self.authManager.currentUserId }) {
                self.currentUserAvatarRank = currentUserIndex + 1
            }
        })
    }
    
    func showMoreUsers() {
        displayedUserCount = 10  // 表示するユーザー数を10に更新
    }

}

struct LevelRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    @State private var rankNum: Int = 0
    
    var body: some View {
        if viewModel.userAnswerDataList.isEmpty {
            // データがまだ読み込まれていない場合の表示
            VStack{
            ActivityIndicator()
        }
            .background(Color("Color2"))
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        } else {
            ScrollView{
                VStack {
                    ForEach(Array(viewModel.users.prefix(viewModel.displayedUserCount).enumerated()), id: \.element.id) { index, user in
                        
                        HStack {
                            // ユーザーのランキングを表示
                            if (index==0||index==1||index==2){
                                Image("\(index)")
                                    .resizable()
                                    .frame(width:50,height:50)
                                    .padding(.trailing)
                            }else{
                                if index != 9{
                                    Text("\(index + 1)位")
                                        .font(.system(size:40))
                                        .padding(.trailing, 5)
                                }else{
                                    Text("\(index + 1)位")
                                        .font(.system(size:30))
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
                            VStack{
                                //                            Spacer()
                                Text("レベル: \(user.level)")
                                    .font(.system(size:20))
                            }
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                    if let currentUserLevelRank = viewModel.currentUserLevelRank {
                        Text("あなたの順位: \(currentUserLevelRank)位")
                            .font(.headline)
                            .padding()
                    }
                }
                
                .onAppear{
                    print("viewModel.users:\(viewModel.users)")
                }
            }
            .background(Color("Color2"))
            .foregroundColor(Color("fontGray"))
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
//print(text)
//        print(baseFontSize)
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

}

struct UserAnswerData {
    let userId: String
    let userName: String
    var answerCount: Int
    let avatarName: String // アバターの名前を保持するプロパティ
}

struct MonthlyAnswersRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {

            if viewModel.userAnswerDataList.isEmpty {
                // データがまだ読み込まれていない場合の表示
                VStack{
                ActivityIndicator()
            }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
            } else {
                // データが読み込まれた後の表示
                ScrollView {
                VStack {
                    ForEach(0..<viewModel.userAnswerDataList.count, id: \.self) { index in
                        let userAnswerData = viewModel.userAnswerDataList[index]
                        HStack {
                            if (index==0||index==1||index==2){
                                Image("\(index)")
                                    .resizable()
                                    .frame(width:50,height:50)
                                    .padding(.trailing)
                            }else{
                                if index != 9{
                                    Text("\(index + 1)位")
                                        .font(.system(size:40))
                                        .padding(.trailing, 5)
                                }else{
                                    Text("\(index + 1)位")
                                        .font(.system(size:30))
                                        .padding(.trailing, 5)
                                }
                            }
                            // アバターの表示にはavatarNameを使用
                            Image(userAnswerData.avatarName)
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text(userAnswerData.userName)
                                .font(.system(size: fontSize(for: userAnswerData.userName, isIPad: isIPad())))
                            Spacer()
                            Text("回答数: \(userAnswerData.answerCount)")
                                .font(.system(size: 20))
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                    if let rank = viewModel.currentUserRank {
                       Text("あなたの順位: \(rank)位")
                           .font(.headline)
                           .padding()
                   }
            }
                .foregroundColor(Color("fontGray"))
                }
        }
    }
    
    // テキストサイズを決定する関数
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 28 : 24 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)
//print(text)
//        print(baseFontSize)
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
}

struct UserAvatarCount {
    let userId: String
    let userName: String
    let avatarCount: Int
    let avatarName: String
}

struct AvatarRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        if viewModel.userAnswerDataList.isEmpty {
            // データがまだ読み込まれていない場合の表示
            VStack{
                ActivityIndicator()
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        } else {
        ScrollView {
            ForEach(Array(viewModel.userAvatarCounts.prefix(10).enumerated()), id: \.element.userId) { index, userAvatarCount in

                    HStack {
                        if (index==0||index==1||index==2){
                            Image("\(index)")
                                .resizable()
                                .frame(width:50,height:50)
                                .padding(.trailing)
                        }else{
                            if index != 9{
                                Text("\(index + 1)位")
                                    .font(.system(size:40))
                                    .padding(.trailing, 5)
                            }else{
                                Text("\(index + 1)位")
                                    .font(.system(size:30))
                                    .padding(.trailing, 5)
                            }
                        }
                        Image(userAvatarCount.avatarName)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(userAvatarCount.userName)
                            .font(.system(size: fontSize(for: userAvatarCount.userName, isIPad: isIPad())))
                        Spacer()
                        Text("おとも：\(userAvatarCount.avatarCount)")
                            .font(.system(size: 20))
                    }
                    .padding(.horizontal)
                    Divider()

                
                
                
                }
            if let rank = viewModel.currentUserAvatarRank {
                Text("あなたの順位: \(rank)位")
                    .font(.headline)
                    .padding()
            }
                }        .foregroundColor(Color("fontGray"))
                .onAppear {
                    viewModel.fetchUsersByAvatarCount()
                }

          
        }
    }
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 28 : 24 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)
//print(text)
//        print(baseFontSize)
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
}

struct TopTabView: View {
    let list: [String]
    @Binding var selectedTab: Int

    var body: some View {
        
        HStack(spacing: 0) {
            ForEach(0 ..< list.count, id: \.self) { row in
                Button(action: {
                    withAnimation {
                        selectedTab = row
                    }
                }, label: {
                    VStack(spacing: 0) {
                        HStack {
                            Text(list[row])
                                .font(Font.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("fontGray"))
                        }
                        .frame(
                            width: (UIScreen.main.bounds.width / CGFloat(list.count)),
                            height: 48 - 3
                        )
                        Rectangle()
                            .fill(selectedTab == row ? Color("loading") : Color.clear)
                            .frame(height: 3)
                    }
                    .fixedSize()
                })
            }
        }
        .frame(height: 48)
        .background(Color.white)
        .compositingGroup()
        .shadow(color: .primary.opacity(0.2), radius: 3, x: 4, y: 4)
    }
}


struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()
    @ObservedObject var audioManager : AudioManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var canSwipe: Bool = false
    let list: [String] = ["レベル", "回答数(月間)", "おともの数"]
    
    var body: some View {
        NavigationView {
            VStack{
                TopTabView(list: list, selectedTab: $selectedTab)
               
                TabView(selection: $selectedTab,
                                    content: {
                    LevelRankingView(viewModel: viewModel)
                        .padding(.top)
                                    .tag(0)
                    MonthlyAnswersRankingView(viewModel: viewModel)
                        .padding(.top)
                                    .tag(1)
                    AvatarRankingView(viewModel: viewModel)
                        .padding(.top)
                                    .tag(2)
                            })
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                LevelRankingView(viewModel: viewModel)
            }
            .background(Color("Color2"))
        }
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
        .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ランキング")
                        .font(.system(size: 20)) // ここでフォントサイズを指定
                        .foregroundColor(Color("fontGray"))
                }
            }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView(audioManager: AudioManager())
    }
}
