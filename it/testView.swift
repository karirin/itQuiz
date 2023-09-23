//
//  testView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI
import AVFoundation
 
struct TestView: View {
    
    // AVAudioPlayerを宣言
    @State private var audioPlayer: AVAudioPlayer?
    
    func playSound() {
        // 効果音を再生するメソッド
        
        if let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Sound file not found")
        }
    }
    
    var body: some View {
        VStack {
            Button("Tap me!"){
                playSound()
            }
            .padding()
            .font(.largeTitle)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .padding(.all, 10)
        }
        .padding(.all, 10)
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
