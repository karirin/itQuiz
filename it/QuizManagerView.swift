//
//  QuizManagerView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/20.
//

import SwiftUI
import AVFoundation

struct QuizManagerView: View {
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
    @State private var isSoundOn: Bool = true
    @EnvironmentObject var soundSettings: SoundSettings
    
    init() {
        _lastClickedDate = State(initialValue: Date())
    }

    var body: some View {
        VStack {
            Button(action: {
                                audioPlayerKettei?.play()
                                // 画面遷移のトリガーをオンにする
                                self.isPresentingQuizBeginner = true
                            }) {
                                HStack{
                                    Text("IT基礎知識の問題（初級）")
                                        .font(.system(size:24))
                                        
                                }
                                .padding(.horizontal,5)
                                .padding(.vertical)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                Image("beginnerBackground")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .opacity(1)
                                )
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .cornerRadius(10)
        .padding(.horizontal)
                    .padding(.bottom)
            
            .shadow(radius: 3)
            .onTapGesture {
                            playSound()
                        }
            
            Button(action: {
                  audioPlayerKettei?.play()
                  self.isPresentingQuizIntermediate = true
              }) {
                  HStack {
                      Text("IT基礎知識の問題（中級）")
                          .font(.system(size: 24))
                          .fontWeight(.bold)
                          .foregroundColor(.white)
                  }
                  .padding(.horizontal, 5)
                  .padding(.vertical)
                  .frame(maxWidth: .infinity)
                  .background(
                      Image("intermediateBackground")
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .opacity(0.8)
                  )
                  .background(authManager.level >= 5 ? Color.white : Color("lightGray"))
                  .cornerRadius(10)
                  .shadow(radius: 1)
                  .disabled(authManager.level >= 5)
              }
              .padding(.horizontal)
            
            
            Button(action: {
                    audioPlayerKettei?.play()
                    self.isPresentingQuizAdvanced = true
                }) {
                    createButtonLabel(text: "IT基礎知識の問題（上級）", imageName: "advancedBackground")
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
                NavigationLink("", destination: QuizAdvancedList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)

                // ネットワーク系の問題
                Button(action: {
                    audioPlayerKettei?.play()
                    self.isPresentingQuizNetwork = true
                }) {
                    createButtonLabel(text: "ネットワーク系の問題", imageName: "networkBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
                NavigationLink("", destination: QuizNetworkList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizNetwork)

                // セキュリティ系の問題
                Button(action: {
                    audioPlayerKettei?.play()
                    self.isPresentingQuizSecurity = true
                }) {
                    createButtonLabel(text: "セキュリティ系の問題", imageName: "securityBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
                NavigationLink("", destination: QuizIntermediateList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizSecurity) // 適切な遷移先に変更してください

                // データベース系の問題
                Button(action: {
                    audioPlayerKettei?.play()
                    self.isPresentingQuizDatabase = true
                }) {
                    createButtonLabel(text: "データベース系の問題", imageName: "databaseBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
            Group{
                NavigationLink("", destination: QuizIntermediateList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizDatabase) // 適切な遷移先に変更してください
                NavigationLink("", destination: QuizBeginnerList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner) // 適切な遷移先に変更してください
                NavigationLink("", destination: QuizIntermediateList().navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
            }
            
        }
        .frame(maxWidth:.infinity)
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
        }
    }
    
    func playSound() {
        audioPlayerKettei?.play()
    }
    
    func createButtonLabel(text: String, imageName: String) -> some View {
        Text(text)
            .font(.system(size: 24))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.8)
            )
            .cornerRadius(10)
            .shadow(radius: 1)
    }

}


struct QuizManagerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizManagerView()
    }
}
