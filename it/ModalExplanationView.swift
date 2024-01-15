//
//  ModalExplanationView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/11.
//

import SwiftUI
import Firebase

struct ModalExplanationView: View {
        @Binding var isPresented: Bool
        @Binding var selectedAnswerIndex: Int?
        @ObservedObject var authManager = AuthManager.shared
        @State private var isContentView: Bool = false
        @State private var isDaily: Bool = false
    @Binding var showAlert: Bool
    @ObservedObject var audioManager:AudioManager
        var question: String
        var userAnswer: String
        var correctAnswer: String
        var explanation: String
        @Binding var currentQuizIndex: Int
        @Binding var userFlag: Int
        var pauseTimer: () -> Void
        var startTimer: () -> Void
        
        var body: some View {
            ZStack {
                    VStack(spacing: 15) {
                            HStack{
                              Spacer()
                              VStack{
                                  
                                  Button(action: {
                                      currentQuizIndex += 1
      //                                selectedAnswerIndex = nil
    //                                  startTimer()
                                      audioManager.playCancelSound()
                                      userFlag = 1
                                      authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1)
                                      showAlert = true
                                      isPresented = false
                                  }) {
                                      HStack{
                                          Image(systemName: "eye.slash")
                                              .foregroundColor(.black)
                                          Text("解説画面を非表示にする")
                                              .foregroundColor(.black)
                                      }
                                  }
                              }
                              .padding(15)
                              .background(Color.white)
                              .cornerRadius(20)
                              .shadow(radius: 10)
                              .padding(.trailing,15)
      //                        .padding(5)
                          }
                      VStack{
                        HStack{
                            if userAnswer == correctAnswer {
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                    .opacity(0.7)
                                    .foregroundColor(.red)
                                    .frame(width: 25)
                                Text("正解")
                                    .font(.system(size:26))
                                    .foregroundColor(Color("fontGray"))
                            } else {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .opacity(0.7)
                                    .foregroundColor(.blue)
                                    .frame(width: 25,height:25)
                                Text("不正解")
                                    .font(.system(size:26))
                                    .foregroundColor(Color("fontGray"))
                            }
                        }
                        HStack{
                            Text(" ")
                                .background(.gray)
                                .frame(width:10,height: 20)
                            Text("問題内容")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack {
                            Text(question)
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        Spacer()
                            .frame(height:10)
                        HStack{
                            Text(" ")
                                .background(.gray)
                                .frame(width:10,height: 20)
                            Text("あなたの回答")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack {
                            Text("\(userAnswer)")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack{
                            Text(" ")
                                .background(.gray)
                                .frame(width:10,height: 20)
                            Text("正解")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack {
                            Text("\(correctAnswer)")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack{
                            Text(" ")
                                .background(.gray)
                                .frame(width:10,height: 20)
                            Text("解説")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        HStack {
                            Text("\(explanation)")
                                .foregroundColor(Color("fontGray"))
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                            Button(action: {
                                currentQuizIndex += 1
                                isPresented = false
                                selectedAnswerIndex = nil
                                startTimer()
                                audioManager.playCancelSound()
                            }) {
                                HStack{
                                    Text("次の問題へ")
                                    
                                }
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                            }
                        }
                        //                    NavigationLink("", destination: QuizManagerView(isPresenting: .constant(false)).navigationBarBackButtonHidden(true), isActive: $isContentView)
                        
                        //                    Button(action: {
                        //                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                        //                        }
                        //                    }) {
                        //                        HStack {
                        //                            Image(systemName: "questionmark.circle")
                        //                            Text("　ヘルプ　　")
                        //                        }
                        //                            .padding(20)
                        //                            .foregroundColor(.black)
                        //                            .background(Color.white)
                        //                            .cornerRadius(8)
                        //                            .shadow(radius: 1)
                        //                    }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                    //                .overlay(
                    //                    // 「×」ボタンを右上に配置
                    //                    Button(action: {
                    //                        isPresented = false
                    //                    }) {
                    //                        Image(systemName: "xmark.circle.fill")
                    //                            .resizable()
                    //                            .frame(width: 50, height: 50)
                    //                            .foregroundColor(.gray)
                    //                            .background(.white)
                    //                            .cornerRadius(30)
                    //                            .padding()
                    //                    }
                    //                    .offset(x: 35, y: -35), // この値を調整してボタンを正しい位置に移動させます
                    //                    alignment: .topTrailing // 枠の右上を基準に位置を調整します
                    //                )
                    }
                                    .padding()
            }
            .onAppear {
                pauseTimer()  // モーダルが表示されたときにタイマーを一時停止
            }
        }
    }

//#Preview {
////    func pauseTimer() {
////        timer?.invalidate()
////    }
//
//    ModalExplanationView(isPresented: .constant(false), selectedAnswerIndex: .constant(0), question: "ああああああああああああああああああああああああああああああああああああああああああああ", userAnswer: "ああああああああああああああああああああああああああああああああああああああああああああ", correctAnswer: "ああああああああああああああああああああああああああああああああああああああああああああ", explanation: "ああああああああああああああああああああああああああああああああああああああああああああ", currentQuizIndex: .constant(0))
//}
