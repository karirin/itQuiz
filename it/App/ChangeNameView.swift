//
//  RankingView.swift
//  sukimaKanji
//
//  Created by Apple on 2024/06/23.
//

import SwiftUI
import Firebase
import FirebaseDatabase

struct ChangeNameView: View {
    @Binding var isPresented: Bool
    @Binding var isReturnBtn: Bool
    @Binding var tutorialNum: Int
    
    @State private var userName: String = ""
    @State private var showAlert = false
    @State private var isSaving = false // 保存中のインジケーター用
    
    @ObservedObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

    // 色の定義（アセットカタログがない場合のために定義していますが、既存のColor("Color2")などがあればそちらを使ってください）
    let mainColor = Color.blue // アプリのテーマカラーに変更してください
    let cardBackground = Color.white
    
    var body: some View {
        ZStack {
            // 背景のディム（暗くする）
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if isReturnBtn {
                        isPresented = false
                    }
                }
            
            // メインのカード
            VStack(spacing: 20) {
                
                // タイトルセクション
                VStack(spacing: 8) {
                    ZStack(alignment: .center) {
                        Text("名前を登録する")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // 閉じるボタンを右端に配置
                        if isReturnBtn {
                            HStack {
                                Spacer()
                                Button(action: {
                                    generateHapticFeedback()
                                    isPresented = false
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold)) // アイコンサイズ調整
                                        .foregroundColor(.black)
                                        .frame(width: 30, height: 30)
                                        .background(Color(UIColor.systemGray6)) // 薄いグレー背景
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("一度登録すると変更できません")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red) // 重要なので赤文字で強調
                }
                
                // 入力セクション
                VStack(alignment: .trailing, spacing: 5) {
                    TextField("名前を入力 (例: IT太郎)", text: $userName)
                        .padding()
                        .background(Color(UIColor.systemGray6)) // 薄いグレーの背景
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: userName) { newValue in
                            if newValue.count > 10 {
                                userName = String(newValue.prefix(10))
                            }
                        }
                    
                    Text("\(userName.count) / 10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
                
                // 登録ボタン
                Button(action: {
                    generateHapticFeedback()
                    isSaving = true
                    
                    // ロジックの修正: 完了後にアラートを出す
                    authManager.updateUserName(userName: userName) { success in
                        isSaving = false
                        if success {
                            showAlert = true
                        }
                    }
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text("登録する")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(userName.isEmpty ? Color.gray : mainColor)
                    .cornerRadius(25)
                }
                .disabled(userName.isEmpty || isSaving)
                .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                
            }
            .padding(25)
            .background(cardBackground)
            .cornerRadius(24)
            .shadow(radius: 20)
            .padding(.horizontal, 30)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("完了"),
                message: Text("名前が登録されました"),
                dismissButton: .default(Text("OK")) {
                    if !isReturnBtn {
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                            tutorialNum = 1
                            isPresented = false
                        }
                    } else {
                        isPresented = false
                    }
                }
            )
        }
    }
}

// プレビュー用
struct ChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用にダミーのAuthManagerが必要な場合のモックなどは適宜調整してください
        ChangeNameView(
            isPresented: .constant(true),
            isReturnBtn: .constant(true), // trueにすると×ボタンが見えます
            tutorialNum: .constant(0),
            authManager: AuthManager.shared
        )
    }
}
