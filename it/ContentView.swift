//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingGachaView: Bool = false
    @State private var isPresentingAvatarList: Bool = false
    @State private var audioPlayerKettei: AVAudioPlayer?
    @ObservedObject var audioManager = AudioManager.shared
    @State private var isSoundOn: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Spacer()
                Spacer()
                HStack{
                    Image(systemName: "person.circle")
                    Text("\(userName)")
                    Spacer()
                    Image("コイン")
                        .resizable()
                        .frame(width:20,height:20)
                    Text("+")
                    Text(" \(userMoney)")
                    Spacer()
                    Spacer()
                    Button(action: {
                        audioManager.toggleSound()
                        isSoundOn.toggle()
                    }) {
                        HStack {
                            if isSoundOn {
                                Image(systemName: "speaker.slash")
                                Text("音声オフ")
                            } else {
                                Image(systemName: "speaker.wave.2")
                                Text("音声オン")
                            }
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding()
//                ScrollView{
                    VStack{
                        ZStack{
                            Image("image")
                                .resizable()
                                .frame(height:150)
                                .padding(.top,50)
                                .opacity(0.5)
                            Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                .resizable()
                                .frame(width: 150,height:150)
                        }
                        
                        .font(.system(size: 24))
                        VStack{
                            HStack(alignment: .top){
                                    HStack(alignment: .top){
                                        Image("スター")
                                            .resizable()
                                            .frame(width: 25,height:20)
                                        Text("Lv：\(authManager.level)")
                                    }
                                
                                HStack(alignment: .top){
                                        Image("ハート")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                        VStack(spacing: 0){
                                            Text("体力：\(userHp + (avatar.first?["health"] as? Int ?? 0))")
                                                .multilineTextAlignment(.leading)
                                            HStack{
                                                Text("( + \(avatar.first?["health"] as? Int ?? 0)")
                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                                    .resizable()
                                                    .frame(width: 20,height:20)
                                                Text(")")
                                            }
                                        }
                                    }
                                HStack(alignment: .top){
                                        Image("ソード")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                        VStack(spacing: 0){
                                            Text("攻撃力：\(userAttack + (avatar.first?["attack"] as? Int ?? 0))")
                                                .multilineTextAlignment(.leading)
                                            HStack{
                                                Text("( + \(avatar.first?["attack"] as? Int ?? 0)")
                                                Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                                    .resizable()
                                                    .frame(width: 20,height:20)
                                                Text(")")
                                            }
                                        }
                                    }
                            }
                            HStack{
                                Text("経験値")
                                ProgressBar(value: Float(authManager.experience) / Float(authManager.level * 100))
                                    .frame(height: 20)
                                Text("\(authManager.experience) / \(authManager.level * 100)")
                            }.padding()
                        }
                        VStack{
                            Spacer()
                            Button(action: {
                                if isButtonEnabled {
                                    if let userId = authManager.currentUserId {
                                        authManager.saveLastClickedDate(userId: userId) { success in
                                            lastClickedDate = Date()
                                            isButtonEnabled = false
                                        }
                                    }
                                }
                                audioManager.playKetteiSound()
                                // 画面遷移のトリガーをオンにする
                                self.isPresentingQuizBeginnerList = true
                            }) {
                                HStack{
                                    Image("daily")
                                        .resizable()
                                        .frame(width: 40,height:40)
                                        .foregroundColor(.gray)
                                    Text("デイリーチャレンジ")
                                        .font(.system(size:24))
                                }
                                .padding(.vertical)
                            }
                            .frame(maxWidth: .infinity)
                            .background(isButtonEnabled ? .white : Color("lightGray"))
                            .disabled(!isButtonEnabled)
                            .foregroundColor(.gray)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                            .shadow(radius: 3)
                            .onTapGesture {
                                if isButtonEnabled {
                                    if let userId = authManager.currentUserId {
                                        authManager.saveLastClickedDate(userId: userId) { success in
                                            lastClickedDate = Date()
                                            isButtonEnabled = false
                                        }
                                    }
                                }
                            }
                            Spacer()
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    // 画面遷移のトリガーをオンにする
                                    self.isPresentingQuizList = true
                                }) {
                                    HStack{
                                        Image("quiz")
                                            .resizable()
                                            .frame(width: 35,height:35)
                                            .foregroundColor(.gray)
                                        Text("問題を解く")
                                            .font(.system(size:20))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical)
                                }
                                .background(.white)
                                .foregroundColor(.gray)
                                .cornerRadius(20)
                                .padding(.trailing,3)
                                .padding(.bottom)
                                
                                .shadow(radius: 3)
                                
                                Button(action: {
                                    audioManager.playSound()
                                    // 画面遷移のトリガーをオンにする
                                    self.isPresentingAvatarList = true
                                }) {
                                    HStack{
                                        Image("ボタンライム")
                                            .resizable()
                                            .frame(width: 35,height:35)
                                        Text("おとも")
                                            .font(.system(size:24))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical)
                                }
                                .background(.white)
                                .foregroundColor(.gray)
                                .cornerRadius(20)
                                .padding(.leading,5)
                                .padding(.bottom)
                                
                                .shadow(radius: 3)
                            }
                            .padding(.horizontal,12)
                            Spacer()
                            Button(action: {
                                // 画面遷移のトリガーをオンにする
                                self.isPresentingGachaView = true
                                audioManager.playSound()
                            }) {
                                HStack{
                                    Image("gacha")
                                        .resizable()
                                        .frame(width: 40,height:40)
                                        .foregroundColor(.gray)
                                    Text("ガチャをする")
                                        .font(.system(size:24))
                                }
                                .padding(.horizontal,5)
                                .padding(.vertical)
                            }
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .foregroundColor(.gray)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                            .shadow(radius: 3)
                            .onTapGesture {
                                audioManager.playSound()
                            }
                        }
                        .padding(.horizontal,5)
                        NavigationLink("", destination: QuizBeginnerList(isPresenting: $isPresentingQuizList).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginnerList)
                        NavigationLink("", destination: QuizManagerView(isPresenting: $isPresentingQuizList), isActive: $isPresentingQuizList)
                        NavigationLink("", destination: AvatarListView(), isActive: $isPresentingAvatarList)
                        NavigationLink("", destination: GachaView(), isActive: $isPresentingGachaView)
                    }
//                }
            }
                        .background(Color("Color2"))
               
            } .frame(maxWidth: .infinity,maxHeight: .infinity)
            .onAppear {
            // 1. lastClickedDateを取得
            authManager.fetchLastClickedDate(userId: authManager.currentUserId ?? "") { lastDate in
                if let lastDate = lastDate {
                    // 2. 現在の日時との差を計算
                    let currentDate = Date()
                    let timeInterval = currentDate.timeIntervalSince(lastDate)
                    
                    // 3. 24時間以上経過しているか確認
                    if timeInterval >= 86400 {  // 86400秒 = 24時間
                        isButtonEnabled = true
                    } else {
                        isButtonEnabled = false
                    }
                } else {
                    isButtonEnabled = true
                }
            }
            authManager.fetchUserInfo { (name, avatar, money, hp, attack) in
                         self.userName = name ?? ""
                         self.avatar = avatar ?? [[String: Any]]()
                print(self.avatar)
                         self.userMoney = money ?? 0
                         self.userHp = hp ?? 100
                         self.userAttack = attack ?? 20
                     }
            authManager.fetchAvatars {
                self.avatar = authManager.avatars.map { avatar in
                    return ["name": avatar.name]
                }
            }
             authManager.fetchUserExperienceAndLevel()
        }
            .background(Color("purple2").opacity(0.6))  // ここで背景色を設定
            .edgesIgnoringSafeArea(.all)  // 画面の端まで背景色を伸ばす
            }
        }

struct ProgressBar: View {
    var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .animation(.linear)
            }
        }.cornerRadius(45.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
