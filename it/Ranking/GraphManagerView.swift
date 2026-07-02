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
    let list: [String] = ["回答数(月間)","正答率"]
    @State private var selectedTab: Int = 0
    @State private var preFlag: Bool = false
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack{
            if isLoading {
                VStack{
                    ActivityIndicator()
                }
                .background(Color("Color2"))
                .frame(maxWidth: .infinity,maxHeight: .infinity)
            } else {
                if appState.isBannerVisible && authManager.currentUserId != "dzarHuAdiXXLtDjtwIRvIfVhA1A2" {
                    VStack{
                        TopTabView(list: list, selectedTab: $selectedTab)
                        TabView(selection: $selectedTab,
                                content: {

                            BarChartView(authManager: authManager, data: sampleData)
                                .navigationViewStyle(StackNavigationViewStyle())
                                .tag(0)

                            //    PentagonView(authManager: authManager, flag: .constant(false))
                            PentagonManagerView()
                                .tag(1)
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    .blur(radius: 6)

                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .onTapGesture {
                            preFlag = true
                        }

                    // プレミアム案内カード
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 8, y: 4)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("プレミアム限定機能")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(Color("fontGray"))

                        Text("プレミアムプランに登録すると\n毎日の回答数や問題の正答率を\nグラフで確認できます")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Button(action: {
                            generateHapticFeedback()
                            preFlag = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 15, weight: .bold))
                                Text("プレミアムプランを見る")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color(hex: "ff8c00").opacity(0.4), radius: 8, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                    .padding(.horizontal, 32)
                }
                else{
                    VStack{
                        TopTabView(list: list, selectedTab: $selectedTab)
                        TabView(selection: $selectedTab,
                                content: {
                            
                            BarChartView(authManager: authManager, data: sampleData)
                                .navigationViewStyle(StackNavigationViewStyle())
                                .tag(0)
                            
                            //    PentagonView(authManager: authManager, flag: .constant(false))
                            PentagonManagerView()
                                .tag(1)
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $preFlag) {
            PreView(audioManager: audioManager)
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
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

