//
//  HelpView2.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/16.
//

import SwiftUI

struct RankMatchHelpView: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack{
            Image(systemName: "circle.fill")
                .cornerRadius(30.0)
                .font(.system(size: 30))
                .foregroundColor(.white)
            VStack {
                Button(action: {
                    self.isSheetPresented = true
                }, label:  {
//                    Image(systemName: "questionmark.circle")
//                        .cornerRadius(30.0)
//                        .foregroundColor(Color("fontGray"))
//                        .font(.system(size: 40))
                    Image("ハテナ")
                        .resizable()
                        .frame(width:40,height: 40)
                })
                
                
                //.shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                .sheet(isPresented: $isSheetPresented, content: {
                    RankMatchSwipeableView()
                })
            }
        }
    }
}

struct RankMatchSwipeableView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                RankMatchFirstView()
                    .tag(0)
                RankMatchSecondView()
                    .tag(1)
//                RankMatchThirdView()
//                    .tag(2)
//                RankMatchFourthView()
//                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            
            
            RankMatchCustomPageIndicator(numberOfPages: 2, currentPage: $selectedTab)
                .padding(.bottom)
        }.background(Color("Color2"))
    }
}

struct RankMatchCustomPageIndicator: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.primary : Color.gray)
                    .frame(width: 10, height: 10)
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct RankMatchFirstView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("ランクマッチについて")
                Spacer()
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .opacity(0)
                Spacer()
            }
            .background(Color("fontGray"))
            .foregroundColor(.white)
            Image("ランクマッチの説明１")
                .resizable()
                .scaledToFit()
            Image("ランクマッチの説明２")
                .resizable()
                .scaledToFit()
            Spacer()
            }
        .foregroundColor(Color("fontGray"))
    }
}


struct RankMatchSecondView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("ランクマッチについて")
                Spacer()
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .opacity(0)
                Spacer()
            }
            .background(Color("fontGray"))
            .foregroundColor(.white)
            Image("ランクマッチの説明３")
                .resizable()
                .scaledToFit()
            Image("ランクマッチの説明４")
                .resizable()
                .scaledToFit()
            Spacer()
        }
        .foregroundColor(Color("fontGray"))
    }
}

struct RankMatchThirdView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Text("")
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            Spacer()
            Image("チュートリアル３")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
            VStack{
                Text(" 目標が選択されたら、スタートボタンをクリックして記録を開始します。")
                Text("  カウントアップタイマーで記録が終わったら、完了ボタンをクリックしてください。")
            }.padding()
                .padding(.bottom,10)
        }
    }
}

struct RankMatchFourthView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Text("")
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            Spacer()
            VStack{
                Image("チュートリアル４")
                    .resizable()
                    .scaledToFit()
                //.frame(width: 500, height: 500)
                
            }
            .padding(.top,40)
            Spacer()
            VStack{
                Text("現在の目標に対する合計記録時間と今回の記録時間が表示されます。")
                Text("もし記録に関するメモがあれば、入力してください。最後に、戻るボタンをクリックして積み上げ記録の追加を完了させます。")
            }
            .padding()
            .padding(.bottom,10)
        }
    }
}


struct RankMatchHelpHelpView_Previews: PreviewProvider {
    static var previews: some View {
        RankMatchHelpView()
//    FirstView()
//        SecondView()
    }
}

