//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var userName: String = ""
    @State private var userIcon: String = ""
    @State private var userMoney: Int = 0
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date?
    @State private var isPresentingQuizBeginnerList: Bool = false
    @State private var isIntermediateQuizActive: Bool = false
    
    var body: some View {
        NavigationView {
                VStack {
                    HStack{
                        Spacer()
                        Image(systemName: "bitcoinsign.circle")
                        Text("+")
                        Text(" \(userMoney)")
                    }
                    .padding()
                    ScrollView{
                    Image(userIcon.isEmpty ? "defaultIcon" : userIcon)
                    
                    Text("\(userName)")
                        .font(.system(size: 24))
                    
                    Text("レベル: \(authManager.level)")
                        .font(.system(size: 20))
                    
                    ProgressBar(value: Float(authManager.experience) / Float(authManager.level * 100))
                        .frame(height: 20)
                        .padding([.leading, .trailing], 20)
                    
                    Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                        .font(.system(size: 16))
                        NavigationLink(destination: QuizBeginnerList().navigationBarBackButtonHidden(true)) {
                        Text("初級レベルの問題")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                        NavigationLink(destination: QuizIntermediateList().navigationBarBackButtonHidden(true), isActive: $isIntermediateQuizActive) {
                                        Text("中級レベルの問題")
                                            .padding()
                                            .background(authManager.level >= 10 ? Color.white : Color.gray)
                                            .foregroundColor(.gray)
                                            .cornerRadius(10)
                                            .shadow(radius: 1)
                                            .disabled(authManager.level < 10)
                                    }
                        
                        Button(action: {
                                            if isButtonEnabled {
                                                if let userId = authManager.currentUserId {
                                                    authManager.saveLastClickedDate(userId: userId) { success in
                                                        lastClickedDate = Date()
                                                        isButtonEnabled = false
                                                    }
                                                }
                                            }
                                            // 画面遷移のトリガーをオンにする
                                            self.isPresentingQuizBeginnerList = true
                                        }) {
                                            Text("初級レベルの問題 - デイリーチャレンジ")
                                                .padding()
                                                .background(isButtonEnabled ? Color.red : Color.gray)
                                                .foregroundColor(.gray)
                                                .cornerRadius(10)
                                                .shadow(radius: 1)
                                        }
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
                        NavigationLink("", destination: QuizBeginnerList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginnerList)
                        NavigationLink(destination: GachaView()) {
                                        Text("ガチャを回す")
                                            .padding()
                                            .foregroundColor(.gray)
                                            .cornerRadius(10)
                                            .shadow(radius: 1)
                                    }
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
            }
        .onAppear {
            authManager.fetchUserInfo { (name, icon, money) in
                self.userName = name ?? ""
                self.userIcon = icon ?? ""
                self.userMoney = money ?? 0
            }
            authManager.fetchUserExperienceAndLevel()
            if let userId = authManager.currentUserId {
                authManager.fetchLastClickedDate(userId: userId) { date in
                    lastClickedDate = date
                    let calendar = Calendar.current
                    print(calendar)
                    if let lastDate = lastClickedDate {
                        print("test:\(calendar.isDateInToday(lastDate))")
                        if calendar.isDateInToday(lastDate) {
                            isButtonEnabled = false
                        }
                    } else {
                        print("lastClickedDate is nil")
                    }
                }
            }
            isIntermediateQuizActive = authManager.level >= 10
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
