//
//  TitleListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/20.
//

import SwiftUI
import Firebase

struct Title {
    let name: String
    let condition: String
    let description: String
}

struct TitleListView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var earnedTitles: [Title] = []

    var body: some View {
        List(earnedTitles, id: \.name) { title in
            VStack(alignment: .leading) {
                Text(title.name).font(.headline)
                Text(title.description).font(.subheadline)
            }
        }
//        .onAppear(perform: loadTitles)
    }

//    func loadTitles() {
//        authManager.fetchEarnedTitles { titles in
//            self.earnedTitles = titles
//        }
//    }
}


struct TitleListView_Previews: PreviewProvider {
    static var previews: some View {
        TitleListView()
    }
}
