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
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
        VStack {
            Group{
                Button(action: {
                    audioManager.playKetteiSound()
                    // 画面遷移のトリガーをオンにする
                    self.isPresentingQuizBeginner = true
                }) {
                    Image("IT基礎知識の問題の初級")
                        .resizable()
                        .frame(height: 80)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)
            }
            Button(action: {
                  audioManager.playKetteiSound()
                  self.isPresentingQuizIntermediate = true
              }) {
                  Image("IT基礎知識の問題の中級")
                      .resizable()
                      .frame(height: 80)
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal)
              .padding(.bottom)
              .shadow(radius: 3)
            
            Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizAdvanced = true
                }) {
                    Image("IT基礎知識の問題の上級")
                        .resizable()
                        .frame(height: 80)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
                .shadow(radius: 3)

                NavigationLink("", destination: QuizAdvancedList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizAdvanced)

                // ネットワーク系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizNetwork = true
                }) {
                    createButtonLabel(text: "ネットワーク系の問題", imageName: "networkBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
                NavigationLink("", destination: QuizNetworkList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizNetwork)

                // セキュリティ系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizSecurity = true
                }) {
                    createButtonLabel(text: "セキュリティ系の問題", imageName: "securityBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)

                NavigationLink("", destination: QuizIntermediateList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizSecurity) // 適切な遷移先に変更してください

                // データベース系の問題
                Button(action: {
                    audioManager.playKetteiSound()
                    self.isPresentingQuizDatabase = true
                }) {
                    createButtonLabel(text: "データベース系の問題", imageName: "databaseBackground") // 画像名を適切に変更してください
                }
                .disabled(authManager.level >= 10)
                .padding(.horizontal)
            Group{
                NavigationLink("", destination: QuizIntermediateList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizDatabase) // 適切な遷移先に変更してください
                NavigationLink("", destination: QuizBeginnerList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizBeginner) // 適切な遷移先に変更してください
                NavigationLink("", destination: QuizIntermediateList(isPresenting: $isPresenting).navigationBarBackButtonHidden(true), isActive: $isPresentingQuizIntermediate) // 適切な遷移先に変更してください
            }
            
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
        QuizManagerView(isPresenting: .constant(false))
    }
}
