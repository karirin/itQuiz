//
//  QuizManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/20.
//

import SwiftUI

struct QuizManagerView: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date = Date()
    
    init() {
        _lastClickedDate = State(initialValue: Date())
    }

    var body: some View {
        VStack {
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
        }
        .onAppear {
            if let userId = authManager.currentUserId {
                authManager.fetchLastClickedDate(userId: userId) { date in
                    if let unwrappedDate = date {
                        lastClickedDate = unwrappedDate
                        let calendar = Calendar.current
                        if calendar.isDateInToday(unwrappedDate) {
                            isButtonEnabled = false
                        }
                    } else {
                        print("lastClickedDate is nil")
                    }
                }
            }
            isIntermediateQuizActive = authManager.level >= 10
        }
    }
}


struct QuizManagerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizManagerView()
    }
}
