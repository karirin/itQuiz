//
//  GachaManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/10.
//

import SwiftUI
import AVFoundation

struct GachaManagerView: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date = Date()
    @State private var audioPlayerKettei: AVAudioPlayer?
    @State private var isPresentingQuizBeginner: Bool = false
    @State private var isPresentingQuizIntermediate: Bool = false
    @State private var isPresentingQuizAdvanced: Bool = false
    @State private var isPresentingQuizNetwork: Bool = false
    @State private var isPresentingQuizSecurity: Bool = false
    @State private var isPresentingQuizDatabase: Bool = false
    @State private var isPresentingQuizGod: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
            VStack {
                Spacer()
                Image("ガチャ一覧")
                    .resizable()
                    .frame(height: 130)
                Spacer()
                    .frame(height:30)
                ScrollView{
                    HStack{
                        Image("300コイン")
                            .resizable()
                            .frame(maxWidth:150,maxHeight:60)
                        Spacer()
                    }
                    .padding(.leading)
                    Button(action: {
                        audioManager.playSound()
                        // 画面遷移のトリガーをオンにする
                        self.isPresentingQuizBeginner = true
                    }) {
                        //                        Image("IT基礎知識の問題の初級")
                        Image("ガチャ一覧ボタン")
                            .resizable()
                            .frame(height: 130)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 10)
                    
                    
                    HStack{
                        Image("600コイン")
                            .resizable()
                            .frame(maxWidth:150,maxHeight:60)
                        Spacer()
                    }
                    .padding(.leading)
                    Button(action: {
                        audioManager.playSound()
                        self.isPresentingQuizIntermediate = true
                    }) {
                        //                    Image("IT基礎知識の問題の中級")
                        Image("レアガチャ一覧ボタン")
                            .resizable()
                            .frame(height: 130)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 10)
                    
                    Spacer()
                    NavigationLink("", destination: GachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner) // 適切な遷移先に変更してください
                    NavigationLink("", destination: RareGachaView().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
                }
            }
        .onTapGesture {
            audioManager.playSound()
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
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
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("fontGray"))
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ガチャ一覧")
                    .font(.system(size: 20)) // ここでフォントサイズを指定
            }
        }
    }
}


struct GachaManagerView_Previews: PreviewProvider {
    static var previews: some View {
        GachaManagerView(isPresenting: .constant(false))
    }
}

