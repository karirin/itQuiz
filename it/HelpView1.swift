//
//  HelpView2.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/16.
//

import SwiftUI

struct HelpView: View {
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
                        .frame(width:50,height: 50)
                })
                
                
                //.shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                .sheet(isPresented: $isSheetPresented, content: {
                    SwipeableView()
                    
                })
            }
        }
    }
}

struct SwipeableView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                FirstView()
                    .tag(0)
                SecondView()
                    .tag(1)
//                ThirdView()
//                    .tag(2)
//                FourthView()
//                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            
            
            CustomPageIndicator2(numberOfPages: 2, currentPage: $selectedTab)
                .padding(.bottom)
        }.background(Color("Color2"))
    }
}

struct CustomPageIndicator2: View {
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

struct FirstView: View {
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
            Spacer()
            Image("トップ画面チュートリアル")
                .resizable()
                .scaledToFit()
            Spacer()
            VStack{
                HStack{
                    Image("レベル").resizable()
                        .frame(width:20,height:20)
                    Text("：ユーザーのレベルになります")
                    Spacer()
                }
                HStack{
                    Image("ハート").resizable()
                        .frame(width:20,height:20)
                    Text("：ユーザーの体力になります")
                    Spacer()
                }
                HStack{
                Image("ソード").resizable()
                    .frame(width:20,height:20)
                    Text("：ユーザーの攻撃力になります")
                    Spacer()
                }
                HStack{
                    HStack{
                        Text("( + 20")
                        Image("ネッキー")
                            .resizable()
                            .frame(width: 20,height:20)
                        Text(")：")
                    }
                    Spacer()
                }
                Text("選択中のおともの体力と攻撃力がプラスされていることを表しています")
            }.padding()
                .padding(.bottom,20)
            }
        .foregroundColor(Color("fontGray"))
    }
}


struct SecondView: View {
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
            HStack{
                Text("各メニュー説明")
                    .font(.system(size: 24))
                Spacer()
            }
            .padding(.leading)
            ScrollView{
                VStack{
                HStack{
                    Image("ダンジョンボタン")
                        .resizable()
                        .frame(width:70, height:70)
                        .padding(.horizontal)
                    Spacer()
                }
                Text("難易度、種類別のクイズを選ぶことができます　")
                
                HStack{
                    Image("ガチャボタン")
                        .resizable()
                        .frame(width:200, height:70)
                        .padding(.horizontal)
                    Spacer()
                }
                Text("ガチャを回すことがで新しいおともを手に入れることができます")
                
                HStack{
                    Image("おとも図鑑ボタン")
                        .resizable()
                        .frame(width:200, height:70)
                        .padding(.horizontal)
                    Spacer()
                }
                Text("手に入れたおともを確認することができます")
                    
                HStack{
                    Image("称号ボタン")
                        .resizable()
                        .frame(width:200, height:70)
                        .padding(.horizontal)
                    Spacer()
                }
                Text("手に入れた称号を確認することができます")
                
                        HStack{
                            Image(systemName: "square.grid.2x2")
                                .resizable()
                                .frame(width:30, height:30)
                            Text("おとも一覧")
                                .font(.system(size: 24))
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.top)
                        Text("選択中のおともを変えることができます　　　　　　　　　　　　　　")
                            .padding(.leading)
                        HStack{
                            Image(systemName: "chart.pie")
                                .resizable()
                                .frame(width:30, height:30)
                            Text("分析")
                                .font(.system(size: 24))
                            Spacer()
                        }.padding(.leading).padding(.top)
                        Text("日々の回答数や正答率をグラフで確認することができます")
                            .padding(.leading,11)
                    }
            
                .padding(.horizontal)
            }
        }
        .foregroundColor(Color("fontGray"))
    }
}

struct ThirdView: View {
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

struct FourthView: View {
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


struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
//    FirstView()
//        SecondView()
    }
}
