//
//  AnswerSelectionView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/29.
//

import SwiftUI

struct AnswerSelectionView: View {
    let choices: [String]
    var action: (Int) -> Void

    var body: some View {
        VStack {
            
                Spacer()
                Spacer()
            ForEach(0..<choices.count, id: \.self) { index in
                
                    Spacer()
                Button(action: {
                    self.action(index)
                }) {
                    Text(self.choices[index])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
            }
            
                Spacer()
                Spacer()
        }
    }
}
