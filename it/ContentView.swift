//
//  ContentView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: QuizBeginnerList()) {
                    Text("初級レベルの問題")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
