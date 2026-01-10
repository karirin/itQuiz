//
//  RankingView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/01.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RankedUser: Identifiable {
    let id: String
    let user: User
    let position: Int
    var rank: Int?

    init(user: User, position: Int) {
        self.id = user.id
        self.user = user
        self.position = position
    }
}

class RankingViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var rankMatchUsers = [User]()
    @Published var displayedUserCount = 10
    @State private var rankNum: Int = 0
    @Published var userAnswerDataList = [UserAnswerData]()
    @ObservedObject var authManager = AuthManager.shared
    @Published var currentUserRank: Int?
    @Published var currentUserLevelRank: Int?
    @Published var currentStoryUser: Int?
    @Published var currentUserStory: Int?
    @Published var userAvatarCounts: [UserAvatarCount] = []
    @Published var currentUserAvatarRank: Int?
    @Published var rankedUsers = [User]()
    @Published var currentUserRankRank: Int?

    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []

            guard let usersData = snapshot.value as? [String: [String: Any]] else { return }

            for (userId, data) in usersData {
                if let userName = data["userName"] as? String,
                   let userMoney = data["userMoney"] as? Int,
                   let userHp = data["userHp"] as? Int,
                   let userAttack = data["userAttack"] as? Int,
                   let level = data["level"] as? Int,
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

                    let user = User(id: userId, userName: userName, level: level, experience: experience, avatars: filteredAvatars, userMoney: userMoney, userHp: userHp, userAttack: userAttack, userFlag: 1, adminFlag: 0, rankMatchPoint: rankMatchPoint, rank: rank)
                    users.append(user)
                }
            }

            self.users = users.sorted { $0.level > $1.level }
            self.rankedUsers = users.sorted { $0.rankMatchPoint > $1.rankMatchPoint }
            
            DispatchQueue.main.async {
                self.calculateLevelRankings()
                self.calculateRankRankings()
            }
            self.fetchMonthlyAnswers()
        }) { (error) in }
    }
    
    @Published var storys: [String: Story] = [:]
    @Published var storyUsers: [RankedUser] = []
    
    struct Story: Codable {
        let lastActiveTime: Double?
        let position: Int
        let stamina: Int
    }
    
    func fetchStorys() {
        Database.database().reference().child("storys").observe(.value) { [weak self] snapshot in
            var tempStorys: [String: Story] = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let position = value["position"] as? Int,
                   let stamina = value["stamina"] as? Int {
                    let lastActiveTime = value["lastActiveTime"] as? Double
                    let story = Story(lastActiveTime: lastActiveTime, position: position, stamina: stamina)
                    tempStorys[childSnapshot.key] = story
                }
            }
            DispatchQueue.main.async {
                self?.storys = tempStorys
                self?.updateRankedUsers() { success in
                    if success {
                        self!.storyUsers = self!.storyUsers.sorted { $0.position > $1.position }
                        if let currentStoryUserIndex = self!.storyUsers.firstIndex(where: { $0.id == self!.authManager.currentUserId }) {
                            self!.currentStoryUser = currentStoryUserIndex + 1
                        }
                        self!.assignRanks()
                    }
                }
            }
        }
    }
    
    private func assignRanks() {
        var currentRank = 1
        var previousPosition: Int? = nil
        var sameRankCount = 0
        for (index, user) in storyUsers.enumerated() {
            if let prevPos = previousPosition {
                if user.position == prevPos {
                    storyUsers[index].rank = currentRank
                    sameRankCount += 1
                } else {
                    currentRank += sameRankCount + 1
                    storyUsers[index].rank = currentRank
                    sameRankCount = 0
                }
            } else {
                storyUsers[index].rank = currentRank
            }
            previousPosition = user.position
        }
    }
    
    func updateRankedUsers(completion: @escaping (Bool) -> Void) {
        let ranked = users.compactMap { user -> RankedUser? in
            guard let story = storys[user.id] else { return nil }
            return RankedUser(user: user, position: story.position)
        }.sorted { $1.position < $0.position }

        DispatchQueue.main.async {
            self.storyUsers = ranked
            self.updateCurrentUserRank()
            completion(true)
        }
    }
    
    func updateCurrentUserRank() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        if let index = storyUsers.firstIndex(where: { $0.user.id == currentUserID }) {
            currentUserLevelRank = index + 1
        }
    }
    
    private func calculateRankRankings() {
        if let currentUserIndex = rankedUsers.firstIndex(where: { $0.id == self.authManager.currentUserId }) {
            self.currentUserRankRank = currentUserIndex + 1
        }
    }
    
    func rankMatchFetchUsers() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []
            guard let usersData = snapshot.value as? [String: [String: Any]] else { return }
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
            
            self.rankMatchUsers = users
            DispatchQueue.main.async { self.calculateLevelRankings() }
            self.fetchMonthlyAnswers()
        }) { _ in }
    }

    private func calculateLevelRankings() {
        let sortedUsers = users.sorted {
            if $0.level == $1.level {
                return $0.experience == $1.experience ? $0.id < $1.id : $0.experience > $1.experience
            }
            return $0.level > $1.level
        }
        if let currentUserIndex = sortedUsers.firstIndex(where: { $0.id == self.authManager.currentUserId }) {
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
            guard let answersData = snapshot.value as? [String: AnyObject] else { return }

            for (userId, categoriesData) in answersData {
                guard let categories = categoriesData as? [String: [String: Int]] else { continue }
                var totalAnswersForMonth = 0
                for (_, dates) in categories {
                    for (date, count) in dates {
                        if date.hasPrefix(currentMonth) { totalAnswersForMonth += count }
                    }
                }
                answerCounts[userId] = totalAnswersForMonth
            }
        
            DispatchQueue.main.async {
                self.userAnswerDataList = self.users.compactMap { user in
                    let avatarName = user.avatars.first?["name"] as? String ?? ""
                    guard let answerCount = answerCounts[user.id] else { return nil }
                    return UserAnswerData(userId: user.id, userName: user.userName, answerCount: answerCount, avatarName: avatarName)
                }.sorted { $0.answerCount > $1.answerCount }.prefix(10).map { $0 }
            }
            
            DispatchQueue.main.async {
                let sortedAnswerCounts = answerCounts.sorted {
                    $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
                }
                let maxRank = sortedAnswerCounts.count
                let userRankings = sortedAnswerCounts.enumerated().map { (index, element) -> (userId: String, rank: Int) in
                    (element.key, element.value > 0 ? index + 1 : maxRank)
                }
                if let currentUserRanking = userRankings.first(where: { $0.userId == self.authManager.currentUserId }) {
                    self.currentUserRank = currentUserRanking.rank
                }
            }
        })
    }

    func fetchUsersByAvatarCount() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            var userAvatarCounts: [UserAvatarCount] = []
            guard let usersData = snapshot.value as? [String: [String: Any]] else { return }

            for (userId, data) in usersData {
                if let userName = data["userName"] as? String,
                   let avatarsData = data["avatars"] as? [String: [String: Any]] {
                    var totalAvatarCount = 0
                    var usedAvatarName: String? = nil

                    for (_, avatarData) in avatarsData {
                        if let count = avatarData["count"] as? Int { totalAvatarCount += count }
                        if avatarData["usedFlag"] as? Int == 1, usedAvatarName == nil {
                            usedAvatarName = avatarData["name"] as? String
                        }
                    }

                    userAvatarCounts.append(UserAvatarCount(userId: userId, userName: userName, avatarCount: totalAvatarCount, avatarName: usedAvatarName ?? "defaultAvatar"))
                }
            }

            self.userAvatarCounts = userAvatarCounts.sorted { $0.avatarCount > $1.avatarCount }
            if let currentUserIndex = self.userAvatarCounts.firstIndex(where: { $0.userId == self.authManager.currentUserId }) {
                self.currentUserAvatarRank = currentUserIndex + 1
            }
        })
    }
    
    func showMoreUsers() { displayedUserCount = 10 }
}

// MARK: - モダンタブビュー
struct ModernTopTabView: View {
    let list: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<list.count, id: \.self) { index in
                Button(action: {
                    generateHapticFeedback()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = index }
                }) {
                    VStack(spacing: 8) {
                        Text(list[index])
                            .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                            .foregroundColor(selectedTab == index ? .blue : Color("fontGray").opacity(0.6))
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(selectedTab == index
                                ? LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4))
    }
}

// MARK: - ランキングカード
struct RankingCard: View {
    let rank: Int
    let userName: String
    let avatarName: String
    let value: String
    let valueIcon: String
    let isCurrentUser: Bool
    @State private var appearAnimation = false
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0)
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return Color.gray
        }
    }
    
    private var rankGradient: LinearGradient {
        switch rank {
        case 1: return LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0), Color(red: 1.0, green: 0.7, blue: 0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2: return LinearGradient(colors: [Color(red: 0.85, green: 0.85, blue: 0.85), Color(red: 0.65, green: 0.65, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3: return LinearGradient(colors: [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.gray, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var rankBadge: some View {
        Group {
            if rank <= 3 {
                ZStack {
                    Circle().fill(rankGradient).frame(width: 44, height: 44)
                    Text("\(rank)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                }.shadow(color: rankColor.opacity(0.4), radius: 6, x: 0, y: 3)
            } else {
                ZStack {
                    Circle().fill(Color(.systemGray5)).frame(width: 44, height: 44)
                    Text("\(rank)").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Color("fontGray"))
                }
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            rankBadge
            
            Image(avatarName)
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
                .clipShape(Circle())
                .overlay(Circle().stroke(isCurrentUser ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isCurrentUser ? 3 : 1))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(userName).font(.system(size: 15, weight: .semibold)).foregroundColor(Color("fontGray")).lineLimit(1)
                if isCurrentUser { Text("あなた").font(.system(size: 11, weight: .medium)).foregroundColor(.blue) }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                if valueIcon.hasPrefix("checkmark") {
                    Image(systemName: valueIcon).font(.system(size: 16, weight: .semibold)).foregroundColor(.blue)
                } else {
                    Image(valueIcon).resizable().scaledToFit().frame(width: 22, height: 22)
                }
                Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color("fontGray"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color(.systemGray6)))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(isCurrentUser ? Color.blue.opacity(0.05) : Color.white).shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isCurrentUser ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1.5))
        .scaleEffect(appearAnimation ? 1.0 : 0.95)
        .opacity(appearAnimation ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(rank) * 0.05)) { appearAnimation = true }
        }
    }
}

// MARK: - 現在のユーザー順位バナー
struct CurrentUserRankBanner: View {
    let rank: Int
    let type: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            Text("あなたの\(type)順位").font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.9))
            Spacer()
            Text("\(rank)位").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.top, 8)
    }
}

// MARK: - ローディングビュー
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 4).frame(width: 50, height: 50)
                Circle().trim(from: 0, to: 0.7)
                    .stroke(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            Text("読み込み中...").font(.system(size: 14, weight: .medium)).foregroundColor(Color("fontGray").opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
        .onAppear { isAnimating = true }
    }
}

// MARK: - ランクランキングビュー
struct RankRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        if viewModel.rankedUsers.isEmpty { LoadingView() }
        else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(viewModel.rankedUsers.prefix(viewModel.displayedUserCount).enumerated()), id: \.element.id) { index, user in
                        RankingCard(rank: index + 1, userName: user.userName, avatarName: user.avatars.first?["name"] as? String ?? "defaultIcon", value: "\(user.rankMatchPoint)", valueIcon: "ランクマッチマーク", isCurrentUser: user.id == viewModel.authManager.currentUserId)
                    }
                    if let currentUserRankRank = viewModel.currentUserRankRank { CurrentUserRankBanner(rank: currentUserRankRank, type: "ランク値") }
                }.padding(.horizontal, 16).padding(.vertical, 12)
            }.background(Color(red: 0.96, green: 0.96, blue: 0.98))
        }
    }
}

// MARK: - ストーリーランキングビュー
struct StoryRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var isReturnFlag: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
            if viewModel.storyUsers.isEmpty { LoadingView() }
            else {
                VStack(spacing: 0) {
                    if isReturnFlag {
                        HStack {
                            Button(action: { generateHapticFeedback(); presentationMode.wrappedValue.dismiss() }) {
                                HStack(spacing: 4) { Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)); Text("戻る").font(.system(size: 16, weight: .medium)) }.foregroundColor(.blue)
                            }
                            Spacer()
                            Text("ダンジョンランキング").font(.system(size: 18, weight: .bold)).foregroundColor(Color("fontGray"))
                            Spacer()
                            HStack(spacing: 4) { Image(systemName: "chevron.left"); Text("戻る") }.opacity(0)
                        }.padding(.horizontal, 16).padding(.vertical, 12).background(Color.white)
                    }
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(viewModel.storyUsers.prefix(10).enumerated()), id: \.element.id) { index, rankedUser in
                                RankingCard(rank: rankedUser.rank ?? (index + 1), userName: rankedUser.user.userName, avatarName: rankedUser.user.avatars.first?["name"] as? String ?? "defaultIcon", value: "\(rankedUser.position)コマ", valueIcon: "足場1", isCurrentUser: rankedUser.user.id == viewModel.authManager.currentUserId)
                            }
                            if let currentStoryUser = viewModel.currentStoryUser { CurrentUserRankBanner(rank: currentStoryUser, type: "ダンジョン") }
                        }.padding(.horizontal, 16).padding(.vertical, 12)
                    }
                }
            }
        }.onAppear { viewModel.fetchStorys() }
    }
}

// MARK: - レベルランキングビュー
struct LevelRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        if viewModel.users.isEmpty { LoadingView() }
        else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(viewModel.users.prefix(viewModel.displayedUserCount).enumerated()), id: \.element.id) { index, user in
                        RankingCard(rank: index + 1, userName: user.userName, avatarName: user.avatars.first?["name"] as? String ?? "defaultIcon", value: "Lv.\(user.level)", valueIcon: "星", isCurrentUser: user.id == viewModel.authManager.currentUserId)
                    }
                    if let currentUserLevelRank = viewModel.currentUserLevelRank { CurrentUserRankBanner(rank: currentUserLevelRank, type: "レベル") }
                }.padding(.horizontal, 16).padding(.vertical, 12)
            }.background(Color(red: 0.96, green: 0.96, blue: 0.98))
        }
    }
}

struct UserAnswerData {
    let userId: String
    let userName: String
    var answerCount: Int
    let avatarName: String
}

// MARK: - 月間回答数ランキングビュー
struct MonthlyAnswersRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        if viewModel.userAnswerDataList.isEmpty { LoadingView() }
        else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(viewModel.userAnswerDataList.enumerated()), id: \.element.userId) { index, data in
                        RankingCard(rank: index + 1, userName: data.userName, avatarName: data.avatarName, value: "\(data.answerCount)問", valueIcon: "checkmark.square", isCurrentUser: data.userId == viewModel.authManager.currentUserId)
                    }
                    if let rank = viewModel.currentUserRank { CurrentUserRankBanner(rank: rank, type: "回答数") }
                }.padding(.horizontal, 16).padding(.vertical, 12)
            }.background(Color(red: 0.96, green: 0.96, blue: 0.98))
        }
    }
}

struct UserAvatarCount {
    let userId: String
    let userName: String
    let avatarCount: Int
    let avatarName: String
}

// MARK: - アバターランキングビュー
struct AvatarRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        if viewModel.userAvatarCounts.isEmpty { LoadingView() }
        else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(viewModel.userAvatarCounts.prefix(10).enumerated()), id: \.element.userId) { index, data in
                        RankingCard(rank: index + 1, userName: data.userName, avatarName: data.avatarName, value: "\(data.avatarCount)体", valueIcon: "ライム", isCurrentUser: data.userId == viewModel.authManager.currentUserId)
                    }
                    if let rank = viewModel.currentUserAvatarRank { CurrentUserRankBanner(rank: rank, type: "アバター") }
                }.padding(.horizontal, 16).padding(.vertical, 12)
            }.background(Color(red: 0.96, green: 0.96, blue: 0.98)).onAppear { viewModel.fetchUsersByAvatarCount() }
        }
    }
}

// MARK: - 互換性のため
struct TopTabView: View {
    let list: [String]
    @Binding var selectedTab: Int
    var body: some View { ModernTopTabView(list: list, selectedTab: $selectedTab) }
}

// MARK: - メインランキングビュー
struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()
    @ObservedObject var audioManager: AudioManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    let list: [String] = ["レベル", "回答数(月間)", "ダンジョン"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ModernTopTabView(list: list, selectedTab: $selectedTab)
                TabView(selection: $selectedTab) {
                    LevelRankingView(viewModel: viewModel).tag(0)
                    MonthlyAnswersRankingView(viewModel: viewModel).tag(1)
                    StoryRankingView(viewModel: viewModel, isReturnFlag: .constant(false)).tag(2)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }.background(Color(red: 0.96, green: 0.96, blue: 0.98))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { generateHapticFeedback(); presentationMode.wrappedValue.dismiss(); audioManager.playCancelSound() }) {
            HStack(spacing: 4) { Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)); Text("戻る").font(.system(size: 16, weight: .medium)) }.foregroundColor(.blue)
        }).buttonStyle(.plain)
        .navigationTitle("ランキング")
        .navigationBarTitleDisplayMode(.inline)
        .gesture(DragGesture().onEnded { value in if value.translation.width > 80 { presentationMode.wrappedValue.dismiss() } })
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView(audioManager: AudioManager())
    }
}
