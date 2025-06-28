//
//  ModalReturnView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/18.
//

import SwiftUI

struct ModalReturnView: View {
            @Binding var isPresented: Bool
    //        @ObservedObject var authManager = AuthManager.shared
            @State private var isContentView: Bool = false
            @State private var isDaily: Bool = false
            var pauseTimer: () -> Void
            var startTimer: () -> Void
            @State private var isButtonActive = true

            
            var body: some View {
                ZStack {
                    VStack(spacing: 15) {
                        HStack{
                                Image(systemName: "xmark")
                                    .resizable()
                                    .opacity(0.7)
                                    .foregroundColor(.blue)
                                    .frame(width: 20,height:20)
                                Text("すみません、回答結果が取得できませんでした。")
                            }
                        
                        HStack{
                            Spacer()
                            Button(action: {
                                if isButtonActive {
//                                    currentQuizIndex += 1
                                    isPresented = false
//                                    selectedAnswerIndex = nil
                                    startTimer()
                                }
                            }) {
                                HStack{
                                    Text("戻る")
                                    
                                }
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 1)
                            }
                            .disabled(!isButtonActive).buttonStyle(.plain)
                        }
                        }
                        
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                
                .onAppear {
                    pauseTimer()  // モーダルが表示されたときにタイマーを一時停止
                }
                }
            }

