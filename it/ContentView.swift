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
    @State private var userIcon: String = ""
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingGachaView: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerKettei: AVAudioPlayer?
    @EnvironmentObject var soundSettings: SoundSettings
    
    var body: some View {
        NavigationView {
                VStack {
                    Toggle(isOn: $soundSettings.isSoundOn) {
                        Text("音声: \(soundSettings.isSoundOn ? "オン" : "オフ")")
                    }
                    
                    HStack{
                        Image(systemName: "person.circle")
                        Text("\(userName)")
                        
                        Spacer()
                        Image("コイン")
                            .resizable()
                            .frame(width:20,height:20)
                        Text("+")
                        Text(" \(userMoney)")
                    }
                    .padding()
                    ScrollView{
                        ZStack{
                            Image("image")
                                .resizable()
                                .frame(height:150)
                                .padding(.top,50)
                                .opacity(0.5)
                            Image(userIcon.isEmpty ? "defaultIcon" : userIcon)
                                .resizable()
                                .frame(width: 150,height:150)
                        }
                                
                                    .font(.system(size: 24))
                        VStack{
                            HStack{
                                Image("スター")
                                    .resizable()
                                    .frame(width: 30,height:20)
                                Text("Lv：\(authManager.level)")
                                
                                    Image("ハート")
                                        .resizable()
                                        .frame(width: 20,height:20)
                                    Text("体力：\(userHp)")
                                
                                    Image("ソード")
                                        .resizable()
                                        .frame(width: 30,height:20)
                                    Text("攻撃力：\(userAttack)")
                            }
//                            HStack{
//                                Image("ハート")
//                                    .resizable()
//                                    .frame(width: 20,height:20)
//                                Text("体力：\(userHp)")
//                            }
//                            HStack{
//                                Image("ソード")
//                                    .resizable()
//                                    .frame(width: 30,height:20)
//                                Text("攻撃力：\(userAttack)")
//                            }
                            HStack{
                                Text("経験値")
                                ProgressBar(value: Float(authManager.experience) / Float(authManager.level * 100))
                                    .frame(height: 20)
                                Text("\(authManager.experience) / \(authManager.level * 100)")
                            }.padding()
                        }
                        
                    NavigationLink("", destination: QuizBeginnerList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginnerList)
                        
                        Button(action: {
                                            if isButtonEnabled {
                                                if let userId = authManager.currentUserId {
                                                    authManager.saveLastClickedDate(userId: userId) { success in
                                                        lastClickedDate = Date()
                                                        isButtonEnabled = false
                                                    }
                                                }
                                            }
                                            audioPlayerKettei?.play()
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
                        
                        Button(action: {
                                            audioPlayer?.play()
                                            // 画面遷移のトリガーをオンにする
                                            self.isPresentingQuizList = true
                                        }) {
                                            HStack{
                                                Image("quiz")
                                                    .resizable()
                                                    .frame(width: 40,height:40)
                                                    .foregroundColor(.gray)
                                                Text("問題を解く")
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
                                        playSound()
                                    }
                        
                        
                        
                        Button(action: {
                                            audioPlayer?.play()
                                            // 画面遷移のトリガーをオンにする
                                            self.isPresentingGachaView = true
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
                                        playSound()
                                    }
                        
                        NavigationLink("", destination: GachaView(), isActive: $isPresentingQuizBeginnerList)
                        NavigationLink("", destination: QuizManagerView(), isActive: $isPresentingQuizList)
                    }
                }
                        .background(Color("backgroudGray"))
               
            } .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onAppear {
            authManager.fetchUserInfo { (name, icon, money, hp, attack) in
                self.userName = name ?? ""
                self.userIcon = icon ?? ""
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
            }
            authManager.fetchUserExperienceAndLevel()
            if let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if let soundURL = Bundle.main.url(forResource: "soundKettei", withExtension: "mp3") {
                do {
                    audioPlayerKettei = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
        }
        .onReceive(soundSettings.$isSoundOn) { newValue in
            adjustVolume()
        }
            .background(Color("purple2").opacity(0.6))  // ここで背景色を設定
            .edgesIgnoringSafeArea(.all)  // 画面の端まで背景色を伸ばす
            }
    func playSound() {
        audioPlayer?.play()
    }
    func playSoundKettei() {
        audioPlayerKettei?.play()
    }
    func adjustVolume() {
        if soundSettings.isSoundOn {
            audioPlayer?.volume = 1.0
            audioPlayerKettei?.volume = 1.0
        } else {
            audioPlayer?.volume = 0.0
            audioPlayerKettei?.volume = 0.0
        }
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
    static var soundSettings = SoundSettings()
    
    static var previews: some View {
        ContentView()
            .environmentObject(soundSettings)
    }
}
