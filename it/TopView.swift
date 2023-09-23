////
////  TopView.swift
////  it
////
////  Created by hashimo ryoya on 2023/09/22.
////
//
//import SwiftUI
//
//struct TopView: View {
//    static let samplePaymentDates: [Date] = [Date()]
//    
//    var body: some View {
//        VStack {
//            TabView {
//                ZStack {
//                    ContentView()
//                        .background(Color("sky"))
//                }
//                .tabItem {
//                    Image(systemName: "house")
//                        .padding()
//                    Text("ホーム")
//                        .padding()
//                }
//                
//                ZStack {
//                    QuizManagerView()
//                }
//                .tabItem {
//                    Image("ダンジョン")
////                        .resizable()
//                        .frame(width:1,height:1)
//                    Text("ダンジョン")
//                }
//                
//                GachaView()
//                    .tabItem {
//                        Image(systemName: "chart.pie")
//                        Text("グラフ")
//                    }
//                SettingsView()
//                    .tabItem {
//                        Image(systemName: "gearshape.fill")
//                        Text("設定")
//                    }
//            }
//        }
//    }
//}
//
//struct TopView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopView()
//    }
//}
