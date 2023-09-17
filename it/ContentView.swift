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
    
    var body: some View {
        NavigationView {
                VStack {
                        Image("\(userIcon)")
                    
                        Text("\(userName)")
                        .font(.system(size: 24))
                    
                    Text("レベル: \(authManager.level)")
                                 .font(.system(size: 20))
                             
                             ProgressBar(value: Float(authManager.experience % 100) / 100.0)
                                 .frame(height: 20)
                                 .padding([.leading, .trailing], 20)
                             
                             Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                                 .font(.system(size: 16))
                    NavigationLink(destination: QuizBeginnerList()) {
                        Text("初級レベルの問題")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
            }
        .onAppear {
            authManager.fetchUserInfo { (name, icon) in
                self.userName = name ?? ""
                self.userIcon = icon ?? ""
            }
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
    static var previews: some View {
        ContentView()
    }
}
