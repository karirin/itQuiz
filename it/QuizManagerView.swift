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
                Text("IT基礎知識の問題（初級）")
                
                .frame(maxWidth:.infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }.padding(.horizontal)
            NavigationLink(destination: QuizIntermediateList().navigationBarBackButtonHidden(true)) {
                Text("IT基礎知識の問題（中級）")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(authManager.level >= 5 ? Color.white : Color("lightGray"))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(authManager.level >= 5)
            }.padding(.horizontal)
            NavigationLink(destination: QuizAdvancedList().navigationBarBackButtonHidden(true)) {
                Text("IT基礎知識の問題（上級）")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(authManager.level >= 10 ? Color.white : Color("lightGray"))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(authManager.level >= 10)
            }.padding(.horizontal)
            NavigationLink(destination: QuizNetworkList().navigationBarBackButtonHidden(true)) {
                Text("ネットワーク系の問題")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(authManager.level >= 10 ? Color.white : Color("lightGray"))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(authManager.level >= 10)
            }.padding(.horizontal)
            NavigationLink(destination: QuizIntermediateList().navigationBarBackButtonHidden(true)) {
                Text("セキュリティ系の問題")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(authManager.level >= 10 ? Color.white : Color("lightGray"))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(authManager.level >= 10)
            }.padding(.horizontal)
            NavigationLink(destination: QuizIntermediateList().navigationBarBackButtonHidden(true)) {
                Text("データベース系の問題")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(authManager.level >= 10 ? Color.white : Color("lightGray"))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(authManager.level >= 10)
            }.padding(.horizontal)
        }
        .frame(maxWidth:.infinity)
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
