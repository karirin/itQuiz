//
//  UserListView.swift
//  it
//
//  Created by Apple on 2024/03/15.
//

import SwiftUI

struct RankMatchListView: View {
//    @ObservedObject var viewModel: RankingViewModel
    @ObservedObject var audioManager = AudioManager.shared
    @State private var rankNum: Int = 0
    @State private var isPresentingQuizRankMatch: Bool = false
    @State private var selectedUser: User? = nil
    @ObservedObject var authManager = AuthManager.shared
    @StateObject var viewModel = RankingViewModel()
    @State private var avatar: [[String: Any]] = []
    @State private var userName: String = ""
    @State private var showModal: Bool = true
    
    var body: some View {
        ZStack{
            VStack{
                if viewModel.rankMatchUsers.isEmpty {
                    // データがまだ読み込まれていない場合の表示
                    VStack{
                        ActivityIndicator()
                    }
                    .background(Color("Color2"))
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                } else {
                    HStack{
                        Image(getRankImageName(rank: authManager.rank))
                            .resizable()
                            .frame(width:50,height:50)
                        Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                            .resizable()
                            .frame(width: 50,height:50)
                        VStack(spacing: 3){
                            HStack{
                                Text("\(userName)")
                                    .font(.system(size: fontSize1(for: userName, isIPad: isIPad())))
                                Spacer()
                            }
                            rankMatchProgressBar(value: Double(authManager.rankMatchPoint), maxValue: Double((authManager.rank + 1) * 100))
                                .padding(.trailing)
                            let nextRankPointsNeeded = (authManager.rank + 1) * 100
                            let pointsToNextRank = nextRankPointsNeeded - authManager.rankMatchPoint
                            
                            HStack{
                                if pointsToNextRank > 0 {
                                    // まだ次のランクに到達していない場合
                                    Text("次のランクまで\(pointsToNextRank)ポイント")
                                        .font(.system(size: 13))
                                } else {
                                    // すでに次のランクに到達している、またはそれを超えている場合
                                    // 次の次のランクに必要なポイントを計算するなどの処理をここに追加
                                    // 例として、単純に次のランクに1を足して計算する
                                    let nextNextRankPointsNeeded = (authManager.rank + 2) * 100
                                    let pointsToNextNextRank = nextNextRankPointsNeeded - authManager.rankMatchPoint
                                    Text("次のランクまで\(pointsToNextNextRank)ポイント")
                                }
                                Spacer()
                            }
                        }
                        .onAppear{
                            print("authManager.rank:\(authManager.rank)")
                        }
                        Spacer()
                        Button(action: {
                            showModal = true
                            audioManager.playSound()
                        }) {
                            Image("ハテナ")
                                .resizable()
                                .frame(width:40,height:40)
                                .shadow(radius: 3)
                        }        
                        .sheet(isPresented: $showModal) {
                            // ここにビューシートとして表示する内容を書きます
                            RankMatchHelpView() // 表示するビューの名前に読み替えてください
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom,5)
                    ScrollView{
                        VStack {
                            ForEach(viewModel.rankMatchUsers.filter { $0.level >= 3 }) { user in
                                
                                HStack {
                                    ForEach(user.avatars.indices, id: \.self) { index in
                                        let avatarData = user.avatars[index]
                                        Image(getRankImageName(rank: user.rank))
                                            .resizable()
                                            .frame(width:50,height:50)
                                        
                                        if let name = avatarData["name"] as? String, let usedFlag = avatarData["usedFlag"] as? Int, usedFlag == 1 {
                                            Image(name)
                                                .resizable()
                                                .frame(width:50,height:50)
                                        }
                                    }
                                    VStack(spacing:5){
                                        HStack{
                                            Text(user.userName)
                                                .font(.system(size: fontSize1(for: user.userName, isIPad: isIPad())))
                                            
                                            Spacer()
                                        }
                                        HStack{
                                            ZStack{
                                                Image("ランク値")
                                                    .resizable()
                                                    .frame(width:80,height:20)
                                                Text("\(user.rankMatchPoint)")
                                                    .padding(.leading)
                                            }
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                    //                            }
                                    Button(action: {
                                        // 画面遷移のトリガーをオンにする
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            self.selectedUser = user
                                        }
                                        self.isPresentingQuizRankMatch = true
                                    }) {
                                        Image("対戦する")
                                            .resizable()
                                            .frame(width:100,height:35)
                                    }
                                }
                                .fullScreenCover(isPresented: $isPresentingQuizRankMatch) {
                                    if let user = selectedUser {
                                        RankMatchQuizListView(isPresenting: $isPresentingQuizRankMatch, user: user)
                                    } else {
                                        ActivityIndicator()
                                    }
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                            //                        if let currentUserLevelRank = viewModel.currentUserLevelRank {
                            //                            Text("あなたの順位: \(currentUserLevelRank)位")
                            //                                .font(.headline)
                            //                                .padding()
                            //                        }
                        }
                        //                .onAppear{
                        //                    print("viewModel.users:\(viewModel.users)")
                        //                }
                    }
                    
                }
            }
            
        }
        .onAppear{
                viewModel.rankMatchFetchUsers()
                authManager.fetchUserRankMatchPoint()
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
            }
        }
        .background(Color("Color2"))
        .foregroundColor(Color("fontGray"))
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
    
    func getRankImageName(rank: Int) -> String {
        switch rank {
        case 1:
            return "ブロンズ"
        case 2:
            return "シルバー"
        case 3:
            return "ゴールド"
        case 4:
            return "マスター"
        default:
            return "ブロンズ" // ランクが1-4以外の場合のデフォルト画像
        }
    }
}

struct rankMatchProgressBar: View {
    var value: Double
    var maxValue: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.3)
                    .foregroundColor(Color.blue)

                Rectangle()
                    .frame(width: CGFloat(self.value / self.maxValue) * geometry.size.width)
                    .foregroundColor(Color.blue)
                    .animation(.linear(duration: 1.0))
            }
        }
        .frame(height: 15)
        .cornerRadius(10)
    }
}

#Preview {
    RankMatchListView()
//    TopView()
}
