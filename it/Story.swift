//
//  Test.swift
//  it
//
//  Created by Apple on 2024/02/14.
//

import SwiftUI

//
//  GachaManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/10.
//

import SwiftUI
import AVFoundation

struct Story: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var audioPlayerKettei: AVAudioPlayer?
    @State private var isPresentingQuizBeginner: Bool = false
    @State private var isPresentingQuizIntermediate: Bool = false
    @State private var isPresentingQuizBeginnerStory1: Bool = false
    @State private var isPresentingQuizBeginnerStory2: Bool = false
    @State private var isPresentingQuizSecurity: Bool = false
    @State private var isPresentingQuizDatabase: Bool = false
    @State private var isPresentingQuizBeginnerStory3: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var animationFinished: Bool = false
    @State private var showAnimation1: Bool = false
    @State private var showAnimation2: Bool = false
    @State private var showModal1: Bool = false
    @State private var showModal2: Bool = false
    @ObservedObject var viewModel: QuizBeginnerStoryViewModel
    
    init(isPresenting: Binding<Bool>, viewModel: QuizBeginnerStoryViewModel) {
        self._isPresenting = isPresenting
        self.viewModel = viewModel
    }


    var body: some View {
        ZStack{
            VStack {
                Button(action: {
                    audioManager.playKetteiSound()
                    showAnimation1 = true
                    if authManager.story == 1 {
                        authManager.updateStory(story: 2) { success in
                            if success {
                                print("ストーリーが正常に更新されました。")
                            } else {
                                print("ストーリーの更新に失敗しました。")
                            }
                        }
                    }
                }) {
//                                        Image("IT基礎知識の問題の中級")
                    Image("物語のはじまりボタン")
                        .resizable()
                        .frame(height: isIPad() ? 200 : 70)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
                
                
                if authManager.story >= 2 {
                    Button(action: {
                        audioManager.playKetteiSound()
                        self.isPresentingQuizBeginnerStory1 = true
                    }) {
                        //                    Image("IT基礎知識の問題の上級")
                        Image("隣町までおつかい1")
                            .resizable()
                            .frame(height: isIPad() ? 200 : 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 3)
                    .fullScreenCover(isPresented: $isPresentingQuizBeginnerStory1) {
                        QuizBeginnerStory1List(isPresenting: $isPresentingQuizBeginnerStory1, viewModel: viewModel)
                    }
                }
                if authManager.story >= 3 {
                    Button(action: {
                        audioManager.playKetteiSound()
                        self.isPresentingQuizBeginnerStory2 = true
                    }) {
                        //                    Image("データベース系の問題")
                        Image("隣町までおつかい2")
                            .resizable()
                            .frame(height: isIPad() ? 200 : 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 3)
                    .fullScreenCover(isPresented: $isPresentingQuizBeginnerStory2) {
                        QuizBeginnerStory2List(isPresenting: $isPresentingQuizBeginnerStory2, viewModel: viewModel)
                    }
                }
                if authManager.story >= 4 {
                    // ネットワーク系の問題
                    Button(action: {
                        audioManager.playKetteiSound()
                        self.isPresentingQuizBeginnerStory3 = true
                    }) {
                        //                    Image("ネットワーク系の問題")
                        Image("隣町までおつかい3")
                            .resizable()
                            .frame(height: isIPad() ? 200 : 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 1)
                    .fullScreenCover(isPresented: $isPresentingQuizBeginnerStory3) {
                        QuizBeginnerStory3List(isPresenting: $isPresentingQuizBeginnerStory3, viewModel: viewModel)
                    }
                }
                if authManager.story >= 5 {
                    // セキュリティ系の問題
                    Button(action: {
                        audioManager.playKetteiSound()
                        showAnimation2 = true
                        authManager.updateStory(story: 6) { success in
                            if success {
                                print("ストーリーが正常に更新されました。")
                            } else {
                                print("ストーリーの更新に失敗しました。")
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showModal2 = true
                        }
                    }) {
                        //                    Image("セキュリティ系の問題")
                        Image("出会いボタン")
                            .resizable()
                            .frame(height: isIPad() ? 200 : 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 3)
                }
                Spacer()
            }
                if showModal1 {
                    ZStack{
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        VStack{
                            VStack{
                                Text("ストーリーへようこそ！")
                                    .font(.system(size:24))
                                Image("ストーリーモード")
                                    .resizable()
                                    .frame(width:200,height: 200)
                                HStack{
                                    Text("ダンジョンをクリアして物語を進めよう！")
                                        .font(.system(size: isSmallDevice() ? 17 : 18))
                                }
                            }
                            .frame(width: isSmallDevice() ? 330: 340, height:360)
                                .background(Color("Color2"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .shadow(radius: 10)
                            HStack{
                                Spacer()
                                Button(action: {
                                    audioManager.playKetteiSound()
                                    showModal1 = false
                                    authManager.updateStory(story: 1) { success in
                                        if success {
                                            print("ストーリーが正常に更新されました。")
                                        } else {
                                            print("ストーリーの更新に失敗しました。")
                                        }
                                    }
                                }) {
                                    HStack{
                                       
                                        //                    Image("セキュリティ系の問題")
                                        Text("ストーリーモードを始める")
                                        //                                      .fixedSize(horizontal: false, vertical: true)
                                        //                                .lineLimit(nil)
                                        Image(systemName: "chevron.right.2")
                                    }.padding(20)
                                        .background(Color("Color2"))
                                        .foregroundColor(Color("fontGray"))
                                    //                                .cornerRadius(5)
                                    //                                .padding(.trailing)
                                    //                                .shadow(radius: 3)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .padding(.trailing,20)
                            }
                        }
                        
                    }
                    
                }
            if showModal2 {
                ZStack{
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    VStack{
                        VStack{
                            Text("ストーリモードクリア！！")
                                .font(.system(size:24))
                            Image("ストーリーモード")
                                .resizable()
                                .frame(width:200,height: 200)
                            HStack{
                                
                            Text("今後のアップデートでストーリーが追加されるのでご期待ください!!!")
                                .font(.system(size: isSmallDevice() ? 17 : 18))
                                
                            }.padding()
                            
                        }
                        .frame(width: isSmallDevice() ? 330: 340, height:360)
                        .background(Color("Color2"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 15)
                        )
                        
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        HStack{
                            Spacer()
                            Button(action: {
                                audioManager.playKetteiSound()
                                showModal2 = false
                            }) {
                                HStack{
                                    
                                    //                    Image("セキュリティ系の問題")
                                    Text("閉じる")
                                    //                                      .fixedSize(horizontal: false, vertical: true)
                                    //                                .lineLimit(nil)
                                    Image(systemName: "chevron.right.2")
                                }.padding(20)
                                    .background(Color("Color2"))
                                    .foregroundColor(Color("fontGray"))
                                //                                .cornerRadius(5)
                                //                                .padding(.trailing)
                                //                                .shadow(radius: 3)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding(.trailing,20)
                        }
                    }
                    .foregroundColor(Color("fontGray"))
                }
            }
            if showAnimation1 {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                TestAnimationView(showAnimation: $showAnimation1)
                VStack{
                    HStack{
                        Button(action: {
                            showAnimation1 = false
                        }) {
                            Image("スキップ")
                                .resizable()
                                .frame(width:200,height:60)
                                .padding(.top,20)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    Spacer()
                }
                .foregroundColor(Color("fontGray"))
            }
            
            if showAnimation2 {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                TestAnimation1View(showAnimation: $showAnimation2)
                VStack{
                    HStack{
                        Button(action: {
                            showAnimation2 = false
                        }) {
                            Image("スキップ")
                                .resizable()
                                .frame(width:200,height:60)
                                .padding(.top,20)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    Spacer()
                }
            }
        }
        .onTapGesture {
            audioManager.playSound()
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
        .onChange(of: animationFinished) { finished in
            if finished {
                self.showAnimation1 = false
                self.showAnimation2 = false
            }
        }
        .onChange(of: isPresentingQuizBeginnerStory1) { flag in
            authManager.fetchUserStory()
        }
        .onChange(of: isPresentingQuizBeginnerStory2) { flag in
            authManager.fetchUserStory()
        }
        .onChange(of: isPresentingQuizBeginnerStory3) { flag in
            authManager.fetchUserStory()
        }
        .onAppear {
            isIntermediateQuizActive = authManager.level >= 10
            if let soundURL = Bundle.main.url(forResource: "soundKettei", withExtension: "mp3") {
                do {
                    audioPlayerKettei = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            if audioManager.isMuted {
                audioPlayerKettei?.volume = 0
            } else {
                audioPlayerKettei?.volume = 1.0
            }
            authManager.fetchUserStory()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if authManager.story != 1 && authManager.story != 2 && authManager.story != 3 && authManager.story != 4 && authManager.story != 5 && authManager.story != 6 {
                    showModal1 = true
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//            audioManager.playCancelSound()
//        }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(Color("fontGray"))
//            Text("戻る")
//                .foregroundColor(Color("fontGray"))
//        })
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("ストーリー")
//                    .font(.system(size: 20)) // ここでフォントサイズを指定
//            }
//        }
    }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}


struct Story_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用のViewModelのインスタンスを作成
        let viewModel = QuizBeginnerStoryViewModel()
        // このインスタンスをTestビューの初期化時に渡す
        Story(isPresenting: .constant(false), viewModel: viewModel)
    }
}
