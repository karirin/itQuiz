//
//  RareGachaView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/09.
//

import SwiftUI
import Firebase

//class RareGachaManager {
//
//struct Item {
//    let name: String
//    let attack: Int
//    let probability: Int
//    let health: Int
//    let rarity: Rarity
//}
//
//enum Rarity: Int {
//    case normal = 40
//    case rare = 30
//    case superRare = 20
//    case ultraRare = 10
//    case legendRare = 1
//    
//    var displayString: String {
//        switch self {
//        case .normal:
//            return "ノーマル" // 任意の文字列を返す
//        case .rare:
//            return "レア"
//        case .superRare:
//            return "スーパーレア"
//        case .ultraRare:
//            return "ウルトラレア"
//        case .legendRare:
//            return "レジェンドレア"
//        }
//    }
//}
//
//var items: [Item] = [
//    Item(name: "忍太", attack: 20,probability: 25, health: 210, rarity: .rare),
//    Item(name: "ぴょこん", attack: 20,probability: 25, health: 215, rarity: .rare),
//    Item(name: "かみ蔵", attack: 20,probability: 25, health: 220, rarity: .rare),
//    Item(name: "キャット夫人", attack: 25,probability: 25, health: 225, rarity: .rare),
//    Item(name: "ミッチー", attack: 30,probability: 25, health: 240, rarity: .rare),
//    Item(name: "ライム兄", attack: 40,probability: 10, health: 250, rarity: .rare),
//    Item(name: "幸福のパンダ", attack: 47,probability: 5, health: 260, rarity: .rare),
//    Item(name: "英雄デル", attack: 50,probability: 10, health: 300, rarity: .superRare),
//    Item(name: "覚醒ライム", attack: 56,probability: 10, health: 300, rarity: .superRare),
//    Item(name: "七福神 玉", attack: 72,probability: 5, health: 350, rarity: .ultraRare),
//    Item(name: "七福神 福天丸", attack: 75,probability: 3, health: 380, rarity: .ultraRare),
//    Item(name: "七福神 金満徳", attack: 100,probability: 3, health: 500, rarity: .legendRare)
//]
//
//// itemsリストをシャッフルする関数
//  func shuffleItems() {
//      items.shuffle()
//  }
//
//  func drawGacha() -> Item {
//      let totalProbability = items.map { $0.probability }.reduce(0, +)
//      let randomNumber = Int.random(in: 0..<totalProbability)
//      var accumulatedProbability = 0
//      @ObservedObject var authManager = AuthManager.shared
//      
//      for item in items {
//          accumulatedProbability += item.probability
//          if randomNumber < accumulatedProbability {
//              let selectedAvatar = Avatar(name: item.name, attack: item.attack, health: item.health , usedFlag: 0 ,count: 1)
//              authManager.addAvatarToUser(avatar: selectedAvatar) { success in
//                 if success {
//                     print("Avatar successfully added!")
//                 } else {
//                     print("Failed to add avatar.")
//                 }
//             }
//              return item
//          }
//      }
//      return items[0] // 念のためのデフォルトのアイテムを返す
//  }
//}


struct MekaGachaView: View {
    @State private var obtainedItem: GachaManager.Item? = nil
    @State private var obtainedRareItem: GachaManager.Item? = nil
    private let gachaManager = GachaManager(mode: .meka)
    @State private var animationFinished: Bool = false
    @State private var showAnimation: Bool = false
    @State private var showResult: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager.shared
    @State private var isGachaButtonDisabled: Bool = false
    @State private var userMoney: Int = 0
    @ObservedObject var audioManager = AudioManager.shared
//    @ObservedObject var reward = Reward()
    @StateObject var reward = Reward()
    @State private var showLoginModal: Bool = false
//    @State private var isShowingActivityIndicator: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showCoinModal: Bool = false
    @State private var showUnCoinModal: Bool = false
    @State private var otomo10flag: Bool = false
    @State private var otomo20flag: Bool = false
    @State private var otomoallflag: Bool = false
    @State private var showAlert: Bool = false
    

    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: { 
                        generateHapticFeedback()
                        self.presentationMode.wrappedValue.dismiss()
                        audioManager.playCancelSound()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("fontGray"))
                        Text("戻る")
                            .foregroundColor(Color("fontGray"))
                    }
                    .padding(.leading)
                    Spacer()
                    ZStack {
                        Image("コインバー")
                            .resizable()
                            .frame(width:80,height:30)
                        Text(" \(userMoney)")
                            .foregroundColor(Color("fontGray"))
                            .padding(.leading,25)
                            .padding(.top,3)
                    }
                    Button(action: { 
                        generateHapticFeedback()
                    audioManager.playSound()
                    self.showCoinModal = true
                    showUnCoinModal = false
                    }) {
                    Image("コイン購入")
                    .resizable()
                    .frame(maxWidth:110,maxHeight:35)
                    .shadow(radius: 3)
                    }
                    .padding(.top,3)
                }
                .foregroundColor(Color("fontGray"))
                .padding(.trailing)
                // ガチャの結果を表示
                if showResult, let item = obtainedItem {  // showResultを使用して制御
                    VStack{
                        ZStack{
                            Image("ガチャ背景5")
                                .resizable()
                                .frame(maxWidth: .infinity,maxHeight:280)
                            Image("\(item.rarity.displayString)")
                                .resizable()
                                .frame(width: 70,height:70)
                                .padding(.trailing,230)
                                .padding(.bottom,40)
                            Text("\(item.name)")
                                .foregroundColor(Color("fontGray"))
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .padding(.bottom,190)
                            Image("\(item.name)")
                                .resizable()
                                .frame(width: 150,height:150)
                                .padding(.top,70)
                        }
                        
                        HStack{
                            ZStack {
                                Image("ハートバー")
                                    .resizable()
                                    .frame(width:140,height:50)
                                Text("\(item.health)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 26))
                                    .foregroundColor(Color("fontGray"))
                                    .padding(.leading,65)
                                    .padding(.top,15)
                            }
                            ZStack {
                                Image("攻撃バー")
                                    .resizable()
                                    .frame(width:136,height:48)
                                Text("\(item.attack)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 26))
                                    .foregroundColor(Color("fontGray"))
                                    .padding(.leading,65)
                                    .padding(.top,10)
                            }
                        }
                        .foregroundColor(Color("fontGray"))
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        VStack{
                            Button(action: { 
                        generateHapticFeedback()
                                //                            authManager.decreaseUserMoney { success in
                                authManager.decreaseRareUserMoney { success in
                                    if success {
                                        print("User money decreased successfully.")
                                    } else {
                                        print("Failed to decrease user money.")
                                    }
                                }
                                self.showAnimation = true
                                self.gachaManager.shuffleItems()
                                // ガチャを引く処理を非同期で実行
                                self.obtainedRareItem = self.gachaManager.drawGacha()
                                DispatchQueue.global().async {
                                    // UIの更新はメインスレッドで実行
                                    DispatchQueue.main.async {
                                        //                                self.isShowingActivityIndicator = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                            self.obtainedItem = self.obtainedRareItem
                                            animationFinished = true
                                            self.showResult = true
                                        }
                                    }
                                }
                            }){
                                if(isGachaButtonDisabled){
                                    Image("もう一度ガチャる")
                                        .resizable()
                                        .frame(width:210,height:100)
                                }else{
                                    Image("もう一度ガチャる白黒")
                                        .resizable()
                                        .frame(width:210,height:100)
                                }
                            }
                            .disabled(!isGachaButtonDisabled)
                            
                            Image("600コイン")
                                .resizable()
                                .frame(maxWidth:130,maxHeight:50)
                        }
                        Spacer()
                        Button(action: { 
                        generateHapticFeedback()
                            reward.ShowReward()
                        }) {
                            Image("獲得")
                                .resizable()
                                .frame(maxWidth:110,maxHeight:110)
                        }
                        .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
                        .shadow(radius: 10)
                        .onChange(of: reward.rewardEarned) { rewardEarned in
                            showAlert = rewardEarned
//                            print("onChange reward.rewardEarned:\(reward.rewardEarned)")
                        }
                        .onAppear() {
                            reward.LoadReward()
                        }
                        Spacer()
                    }
                    Spacer()
                } else {
                    ScrollView{
                        Image("メカガチャトップ")
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(10)
                            .padding()
                        Spacer()
                        HStack{
                            Spacer()
                            VStack{
                                Button(action: { 
                        generateHapticFeedback()
                                    self.showResult = false
                                    //                                authManager.decreaseUserMoney { success in
                                    authManager.decreaseRareUserMoney { success in
                                        if success {
                                            print("User money decreased successfully.")
                                        } else {
                                            print("Failed to decrease user money.")
                                        }
                                    }
                                    self.showAnimation = true
                                    self.gachaManager.shuffleItems()
                                    //                            self.obtainedItem = self.gachaManager.drawGacha()
                                    self.obtainedRareItem = self.gachaManager.drawGacha()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.showResult = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                            self.obtainedItem = self.obtainedRareItem
                                            animationFinished = true
                                        }
                                    }
                                }) {
                                    if(isGachaButtonDisabled){
                                        Image("ガチャる")
                                            .resizable()
                                            .frame(width:210,height:100)
                                    }else{
                                        Image("ガチャる白黒")
                                            .resizable()
                                            .frame(width:210,height:100)
                                    }
                                }
                                .shadow(radius: 10)
                                .disabled(!isGachaButtonDisabled)
                                Image("600コイン")
                                    .resizable()
                                    .frame(maxWidth:130,maxHeight:50)
                            }
                            Spacer()
                            Button(action: { 
                        generateHapticFeedback()
                                reward.ShowReward()
                            }) {
                                Image("獲得")
                                    .resizable()
                                    .frame(maxWidth:110,maxHeight:110)
                            }
                            .shadow(radius: 10)
                            .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
                            .onChange(of: reward.rewardEarned) { rewardEarned in
                                showAlert = rewardEarned
//                                print("onchange reward.rewardEarned:\(reward.rewardEarned)")
                            }
//                            .alert(isPresented: $showAlert) {
//                                Alert(
//                                    title: Text("報酬獲得！"),
//                                    message: Text("300コイン獲得しました。"),
//                                    dismissButton: .default(Text("OK"), action: {
//                                        // アラートを閉じるアクション
//                                        showAlert = false // アラートの表示状態を更新
//                                        reward.rewardEarned = false // 必要に応じてrewardEarnedも更新
//                                    })
//                                )
//                            }
                            .onAppear() {
                                reward.LoadReward()
                            }
                            Spacer()
                        }
                        Spacer()
                        Image("レア卵レア度")
                            .resizable()
                            .frame(maxWidth:350 , maxHeight:120)
                    }
                    Spacer()
                }
            }
            if showLoginModal {
            ZStack {
            Color.black.opacity(0.7)
            .edgesIgnoringSafeArea(.all)
            RewardModalView(audioManager: audioManager, isPresented: $showLoginModal)
            }
            }
            if showCoinModal {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack{
                        if showUnCoinModal {
                            VStack{
                                HStack{
                                    Image("コインが無い")
                                        .resizable()
                                        .frame(width:70,height: 70)
                                    VStack(alignment: .leading, spacing:15){
                                        HStack{
                                            Text("コインが足りません")
                                            Spacer()
                                        }
                                        Text("ご購入することもできます")
                                            .font(.system(size: isSmallDevice() ? 17 : 18))
                                    }
                                    
                                }.padding()
                            }.frame(width: isSmallDevice() ? 330: 340, height:120)
                                .background(Color("Color2"))
                                .font(.system(size: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .shadow(radius: 10)
                        }
                        CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
                    }
                }
            }
            if otomo10flag {
            ModalTittleView(showLevelUpModal: $otomo10flag, authManager: authManager, tittleNumber: .constant(01))
            }
              if otomo20flag {
            ModalTittleView(showLevelUpModal: $otomo20flag, authManager: authManager, tittleNumber: .constant(02))
            }
            if showLoginModal {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    RewardModalView(audioManager: audioManager, isPresented: $showLoginModal)
                }
            }
        }
        
        .alert(isPresented: $showAlert) { // rewardEarnedがtrueになった時にアラートを表示
            Alert(
                title: Text("報酬獲得！"),
                message: Text("300コイン獲得しました。"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
//            print("onAppear:\(reward.rewardEarned)")
            authManager.getUserMoney { userMoney in
//                print(userMoney)
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 600){
                    isGachaButtonDisabled = false
                }else{
                    isGachaButtonDisabled = true
                }
            }
        }
        .onChange(of: showAnimation) { userMoney in
            authManager.getUserMoney { userMoney in
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 600){
                    isGachaButtonDisabled = false
                     showCoinModal = true
                     showUnCoinModal = true
                }else{
                    isGachaButtonDisabled = true
                }
            }
            countAvatarsForUser(userId: authManager.currentUserId!) { avatarCount in
//                print("ユーザーのアバターの数: \(avatarCount)")
                if avatarCount > 9 {
                    authManager.checkTitles(userId: authManager.currentUserId!, title: "おとも１０種類制覇") { exists in
                        if !exists {
                            otomo10flag = true
                            authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "おとも１０種類制覇")
                        }
                    }
                }
                if avatarCount > 19 {
                    authManager.checkTitles(userId: authManager.currentUserId!, title: "おとも２０種類制覇") { exists in
                        if !exists {
                            otomo20flag = true
                            authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "おとも２０種類制覇")
                        }
                    }
                }
            }
        }
        .onChange(of: showLoginModal) { userMoney in
            authManager.getUserMoney { userMoney in
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 600){
                    isGachaButtonDisabled = false
                }else{
                    isGachaButtonDisabled = true
                }
            }
        }
        .onChange(of: showLoginModal) { newValue in
            if newValue {
                // リワード広告がロードされているかチェック
                if reward.rewardLoaded {
                    // 広告を表示する
                    reward.ShowReward()
                } else {
                    // 広告をロードする
                    reward.LoadReward()
                    // ロードが完了したら、状態をチェックしてから再度表示する
                    // ※ LoadReward メソッドが非同期でロードの完了を通知するようになっている必要があります
                }
            }
        }

        .frame(maxWidth: .infinity,maxHeight: .infinity)
//        .navigationBarBackButtonHidden(true)
//                .navigationBarItems(leading: Button(action: { 
//                        generateHapticFeedback()
//                    self.presentationMode.wrappedValue.dismiss()
//                    audioManager.playCancelSound()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(Color("fontGray"))
//                    Text("戻る")
//                        .foregroundColor(Color("fontGray"))
//                })
        .background(Color("Color2"))
           .onChange(of: animationFinished) { finished in
               if finished {
                   self.showAnimation = false
               }
           }
           .fullScreenCover(isPresented: $showAnimation) {
//               GachaAnimationView(showAnimation: $showAnimation, rarity: obtainedRareItem?.rarity) // この行を変更
               GachaAnimationView(showAnimation: $showAnimation, rarity: obtainedRareItem?.rarity) // この行を変更
           }
        
       }
    func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
    }
    func isSmallDevice() -> Bool {
    return UIScreen.main.bounds.width < 390
    }
    // フレームサイズを調整する関数
    func frameSize() -> CGSize {
    if isIPad() {
    // iPadの場合のサイズ
    return CGSize(width: 700, height: 560)
    } else {
    // iPhoneやその他のデバイスの場合のサイズ
    return CGSize(width: 350, height: 280)
    }
    }
    func frameSize2() -> CGSize {
    if isIPad() {
    // iPadの場合のサイズ
    return CGSize(width: 450, height: 260)
    } else {
    // iPhoneやその他のデバイスの場合のサイズ
    return CGSize(width: 210, height: 100)
    }
    }
    func frameSize3() -> CGSize {
    if isIPad() {
    // iPadの場合のサイズ
    return CGSize(width: 300, height: 300)
    } else {
    // iPhoneやその他のデバイスの場合のサイズ
    return CGSize(width: 110, height: 110)
    }
    }
    func frameSize4() -> CGSize {
    if isIPad() {
    // iPadの場合のサイズ
    return CGSize(width: 800, height: 300)
    } else {
    // iPhoneやその他のデバイスの場合のサイズ
    return CGSize(width: 350, height: 120)
    }
    }
    func countAvatarsForUser(userId: String, completion: @escaping (Int) -> Void) {
        let avatarsRef = Database.database().reference().child("users").child(userId).child("avatars")
        avatarsRef.observeSingleEvent(of: .value, with: { snapshot in
            // アバターの数をカウント
            let avatarCount = snapshot.childrenCount
            completion(Int(avatarCount))
        })
    }

}

struct MekaGachaView_Previews: PreviewProvider {
    static var previews: some View {
        MekaGachaView()
    }
}

