import SwiftUI

struct StampAnimationView: View {
    @State private var showSecondImage = false
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var loginCount: Int
      
      var body: some View {
          VStack {
              ZStack {
                  Image("ログインボーナス\(loginCount)日目")
                      .resizable()
                      .scaledToFit()
                      .cornerRadius(10)
                      .opacity(1)
                      .animation(.easeInOut(duration: 2), value: showSecondImage)
                  // 最初の画像
                  Image("ログインボーナス\(loginCount)日目")
                      .resizable()
                      .scaledToFit()
                      .cornerRadius(10)
                      .opacity(showSecondImage ? 0 : 1)
                      .animation(.easeInOut(duration: 2), value: showSecondImage)
                  
                  // 二つ目の画像
                  Image("ログインボーナス\(loginCount)日目done")
                      .resizable()
                      .scaledToFit()
                      .cornerRadius(10)
                      .opacity(showSecondImage ? 1 : 0)
                      .animation(.easeInOut(duration: 2), value: showSecondImage)
              }
              .padding(10)
              .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                      audioManager.playTittleSound()
                  }
                  withAnimation(.easeInOut(duration: 3)) {
                      showSecondImage = true
                  }
              }
          }
      }
}

struct StampAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        StampAnimationView(loginCount: .constant(4))
    }
}

