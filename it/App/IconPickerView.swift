//
//  IconPickerView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Binding var showingIconPicker: Bool  // この行を追加
    let icons = ["user1", "user2", "user3","user4", "user5", "user6","user7", "user8", "user9","user10"]

    var body: some View {
        VStack {
            Text("アイコンを選択してください")
                .font(.system(size: 26))
                .fontWeight(.bold)
                .padding(.top,15)
            Text("メモをする人物に一番近いアイコンを設定してください")
                .font(.system(size: 18))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top,5)
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<icons.count / 3) { rowIndex in
                        HStack(spacing: 20) {
                            ForEach(0..<3) { colIndex in
                                let iconIndex = rowIndex * 3 + colIndex
                                if iconIndex < icons.count {
                                    Button(action: {
                                        self.selectedIcon = icons[iconIndex]
                                        self.showingIconPicker = false // アイコンを選択した後、ピッカーを閉じる
                                    }) {
                                        Image(icons[iconIndex])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    @State static var icon: String = "icon1" // Stateを使用して変数を作成
    @State static var isShowing: Bool = true // この行を追加

    static var previews: some View {
        IconPickerView(selectedIcon: $icon, showingIconPicker: $isShowing) // $isShowingを使用してBindingを渡す
    }
}
