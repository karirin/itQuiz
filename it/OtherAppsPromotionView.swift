//
//  OtherAppsPromotionView.swift
//  it
//
//  Created by Apple on 2025/02/16.
//

import SwiftUI

struct OtherAppsPromotionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("他のおすすめアプリ")
                    .font(.title2)
                ForEach(OtherApp.allApps) { app in
                    Link(destination: URL(string: app.appStoreLink)!) {
                        VStack{
                            ZStack{
                                HStack(spacing: 16) {
                                    Image(app.name)
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(15)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(app.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(app.description2)
                                            .font(.system(size:15))
                                            .foregroundStyle(Color(.black))
                                        //                                        .lineLimit(3)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                            }
                            Divider()
                        }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color("Color2"))
    }
}

#Preview {
    OtherAppsPromotionView()
}
