//
//  GraphManagerView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/29.
//

import SwiftUI
import AVFoundation

struct GraphManagerView: View {
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
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    let sampleData = createSampleData()
    
//    init(isPresenting: Binding<Bool>) {
//        _isPresenting = isPresenting
//        _lastClickedDate = State(initialValue: Date())
//    }


    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                Image("グラフ説明")
                    .resizable()
                    .frame(height: 300)
                Spacer()
                    Button(action: {
                        audioManager.playSound()
                        // 画面遷移のトリガーをオンにする
                        self.isPresentingQuizBeginner = true
                    }) {
                        //                        Image("IT基礎知識の問題の初級")
                        Image("グラフ選択肢1")
                            .resizable()
                            .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 10)
                    
                    Spacer()
                    Button(action: {
                        audioManager.playSound()
                        self.isPresentingQuizIntermediate = true
                    }) {
                        //                    Image("IT基礎知識の問題の中級")
                        Image("グラフ選択肢2")
                            .resizable()
                            .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 10)
                    
                    Spacer()
                    NavigationLink("", destination: PentagonView(authManager: authManager, flag: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner) // 適切な遷移先に変更してください
                    NavigationLink("", destination: BarChartView(authManager: authManager, data: sampleData).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
                }
            }
            //        .onTapGesture {
            //            audioManager.playSound()
            //        }
        
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
        .onAppear {
          
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
    static func createSampleData() -> [DailyData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return [
            DailyData(date: dateFormatter.date(from: "2023-12-01")!, count: 10),
            DailyData(date: dateFormatter.date(from: "2023-12-02")!, count: 15),
            DailyData(date: dateFormatter.date(from: "2023-12-03")!, count: 20)
        ]
    }
}


struct GraphManagerView_Previews: PreviewProvider {
    static var previews: some View {
        GraphManagerView()
    }
}


