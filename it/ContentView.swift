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
                        Image(systemName: "person.circle")
                        Text("\(userName)")
                        Text("レベル: \(authManager.level)")
                        Spacer()
                        Image(systemName: "bitcoinsign.circle")
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
                                
                        HStack{
                            Text("経験値")
                            ProgressBar(value: Float(authManager.experience) / Float(authManager.level * 100))
                                .frame(height: 20)
                            Text("\(authManager.experience) / \(authManager.level * 100)")
                        }.padding()
                        
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
                                            // 画面遷移のトリガーをオンにする
                                            self.isPresentingQuizBeginnerList = true
                                        }) {
                                            HStack{
                                                Image("daily")
                                                    .resizable()
                                                    .frame(width: 50,height:50)
                                                    .foregroundColor(.gray)
                                                
                                                Text("デイリーチャレンジ")
                                                    .font(.system(size:28))
                                                    
                                            }
                                            .padding(.horizontal,5)
                                            .padding(.vertical)
                                        }
                                        .frame(maxWidth: .infinity)
                            .background(isButtonEnabled ? Color("lightRed") : Color("lightGray"))
                                .foregroundColor(.gray)
                                .cornerRadius(20)
                    .padding(.horizontal)
                    .shadow(radius: 1)
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
                        
                        NavigationLink(destination: QuizManagerView()) {
                            HStack{
                                Image("quiz")
                                    .resizable()
                                    .frame(width: 50,height:50)
                                .foregroundColor(.gray)
                                Text("問題を解く")
                                    .font(.system(size:28))
                                    .foregroundColor(.gray)
                            }.frame(maxWidth: .infinity)
                            .padding()
                                    }
                        .background(Color("lightGreen"))
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 1)
                        .padding(.horizontal)

                        
                        NavigationLink(destination: GachaView()) {
                                                    HStack{
                                                        Image("gacha")
                                                            .resizable()
                                                            .frame(width: 50,height:50)
                                                        .foregroundColor(.gray)
                                                        Text("ガチャをする")
                                                            .font(.system(size:28))
                                                            .foregroundColor(.gray)
                                                    }.frame(maxWidth: .infinity)
                                                    .padding()
                                                            }
                                                .background(Color("purple"))
                                                .cornerRadius(20)
                                                .frame(maxWidth: .infinity)
                                                .shadow(radius: 1)
                                                .padding(.horizontal)
                    }
                }
                        .background(Color("backgroundGray"))
               
            } .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onAppear {
            authManager.fetchUserInfo { (name, icon, money) in
                self.userName = name ?? ""
                self.userIcon = icon ?? ""
                self.userMoney = money ?? 0
            }
            authManager.fetchUserExperienceAndLevel()
//            if let userId = authManager.currentUserId {
//                authManager.fetchLastClickedDate(userId: userId) { date in
//                    lastClickedDate = date
//                    let calendar = Calendar.current
//                    print(calendar)
//                    if let lastDate = lastClickedDate {
//                        print("test:\(calendar.isDateInToday(lastDate))")
//                        if calendar.isDateInToday(lastDate) {
//                            isButtonEnabled = false
//                        }
//                    } else {
//                        print("lastClickedDate is nil")
//                    }
//                }
//            }
//            isIntermediateQuizActive = authManager.level >= 10
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
