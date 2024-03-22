//
//  GachaView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI
import Firebase

class GachaManager {

struct Item {
    let name: String
    let attack: Int
    let probability: Int
    let health: Int
    let rarity: Rarity
}

enum Rarity: Int {
    case normal = 40
    case rare = 30
    case Rrare = 45
    case superRare = 20
    case RsuperRare = 35
    case ultraRare = 10
    case RultraRare = 19
    case legendRare = 1
    
    var displayString: String {
        switch self {
        case .normal:
            return "ノーマル"
        case .rare, .Rrare:
            return "レア"
        case .superRare, .RsuperRare:
            return "スーパーレア"
        case .ultraRare, .RultraRare:
            return "ウルトラレア"
        case .legendRare:
            return "レジェンドレア"
        }
    }
}
    
    var items: [Item]
    var mode: GachaMode
    
    init(mode: GachaMode) {
        self.mode = mode
        switch mode {
        case .normal:
            self.items = [
                Item(name: "ネッキー", attack: 10,probability: 25, health: 20, rarity: .normal),
                Item(name: "ピョン吉", attack: 15,probability: 25, health: 15, rarity: .normal),
                Item(name: "ルイーカ", attack: 20,probability: 25, health: 10, rarity: .normal),
                Item(name: "もりこう", attack: 20,probability: 25, health: 100, rarity: .normal),
                Item(name: "うっさん", attack: 25,probability: 25, health: 150, rarity: .normal),
                Item(name: "キリキリン", attack: 30,probability: 25, health: 200, rarity: .normal),
                Item(name: "カゲロウ", attack: 35,probability: 10, health: 220, rarity: .rare),
                Item(name: "ライム", attack: 40,probability: 10, health: 240, rarity: .rare),
                Item(name: "ラオン", attack: 45,probability: 10, health: 260, rarity: .rare),
                Item(name: "レッドドラゴン", attack: 47,probability: 5, health: 280, rarity: .superRare),
                Item(name: "ブルードラゴン", attack: 48,probability: 5, health: 285, rarity: .superRare),
                Item(name: "レインボードラゴン", attack: 50, probability: 3,health: 300, rarity: .ultraRare)
            ]
        case .rare:
            self.items = [
                Item(name: "忍太", attack: 20,probability: 25, health: 210, rarity: .Rrare),
                Item(name: "ぴょこん", attack: 20,probability: 25, health: 215, rarity: .Rrare),
                Item(name: "かみ蔵", attack: 20,probability: 25, health: 220, rarity: .Rrare),
                Item(name: "キャット夫人", attack: 25,probability: 25, health: 225, rarity: .Rrare),
                Item(name: "ミッチー", attack: 30,probability: 25, health: 240, rarity: .Rrare),
                Item(name: "ライム兄", attack: 40,probability: 10, health: 250, rarity: .Rrare),
                Item(name: "幸福のパンダ", attack: 47,probability: 5, health: 260, rarity: .Rrare),
                Item(name: "英雄デル", attack: 50,probability: 10, health: 300, rarity: .RsuperRare),
                Item(name: "覚醒 ライム", attack: 56,probability: 10, health: 300, rarity: .RsuperRare),
                Item(name: "七福神 玉", attack: 72,probability: 5, health: 350, rarity: .RultraRare),
                Item(name: "七福神 福天丸", attack: 75,probability: 3, health: 380, rarity: .RultraRare),
                Item(name: "七福神 金満徳", attack: 100,probability: 3, health: 500, rarity: .legendRare)
            ]
        }
    }

//var items: [Item] = [
//    Item(name: "ネッキー", attack: 10,probability: 25, health: 20, rarity: .normal),
//    Item(name: "ピョン吉", attack: 15,probability: 25, health: 15, rarity: .normal),
//    Item(name: "ルイーカ", attack: 20,probability: 25, health: 10, rarity: .normal),
//    Item(name: "もりこう", attack: 20,probability: 25, health: 100, rarity: .normal),
//    Item(name: "うっさん", attack: 25,probability: 25, health: 150, rarity: .normal),
//    Item(name: "キリキリン", attack: 30,probability: 25, health: 200, rarity: .normal),
//    Item(name: "カゲロウ", attack: 35,probability: 10, health: 220, rarity: .rare),
//    Item(name: "ライム", attack: 40,probability: 10, health: 240, rarity: .rare),
//    Item(name: "ラオン", attack: 45,probability: 10, health: 260, rarity: .rare),
//    Item(name: "レッドドラゴン", attack: 47,probability: 5, health: 280, rarity: .superRare),
//    Item(name: "ブルードラゴン", attack: 48,probability: 5, health: 285, rarity: .superRare),
//    Item(name: "レインボードラゴン", attack: 50, probability: 3,health: 300, rarity: .ultraRare)
//]

    enum GachaMode {
        case normal
        case rare
    }
    
// itemsリストをシャッフルする関数
  func shuffleItems() {
      items.shuffle()
  }

  func drawGacha() -> Item {
      let totalProbability = items.map { $0.probability }.reduce(0, +)
      let randomNumber = Int.random(in: 0..<totalProbability)
      var accumulatedProbability = 0
      @ObservedObject var authManager = AuthManager.shared
      
      for item in items {
          accumulatedProbability += item.probability
          if randomNumber < accumulatedProbability {
              let selectedAvatar = Avatar(name: item.name, attack: item.attack, health: item.health , usedFlag: 0 ,count: 1)
              authManager.addAvatarToUser(avatar: selectedAvatar) { success in
                 if success {
                     print("Avatar successfully added!")
                 } else {
                     print("Failed to add avatar.")
                 }
             }
              return item
          }
      }
      return items[0] // 念のためのデフォルトのアイテムを返す
  }
}


struct GachaView: View {
    @State private var obtainedItem: GachaManager.Item? = nil
    @State private var obtainedRareItem: GachaManager.Item? = nil
    private let gachaManager = GachaManager(mode: .normal)
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
    @State private var otomo10flag: Bool = false
    @State private var otomo20flag: Bool = false
    @State private var otomoallflag: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showCoinModal: Bool = false
    @State private var showUnCoinModal: Bool = false
    @State private var showAlert: Bool = false
//    @State private var isShowingActivityIndicator: Bool = false

    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: {
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
                    Image("コイン")
                        .resizable()
                        .frame(width:20,height:20)
                        .padding(.top,3)
                    Text("+").padding(.top,3)
                    Text(" \(userMoney)").padding(.top,3)
                    Button(action: {
                        audioManager.playSound()
                        self.showCoinModal = true
                        showUnCoinModal = false
                    }) {
                        Image("コイン購入")
                            .resizable()
                            .frame(maxWidth:110,maxHeight:40)
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
                            Image("ハート")
                                .resizable()
                                .frame(width: 30,height:30)
                            Text("体力：\(item.health)")
                                .font(.system(size: 24))
                            Image("ソード")
                                .resizable()
                                .frame(width: 40,height:30)
                            Text("攻撃力：\(item.attack)")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(Color("fontGray"))
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        VStack{
                        Button(action: {
                            authManager.decreaseUserMoney { success in
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
                        
                        Image("300コイン")
                            .resizable()
                            .frame(maxWidth:150,maxHeight:50)
                    }
                        Spacer()
                        Button(action: {
                            reward.ShowReward()
                        }) {
                            if reward.rewardLoaded {
                                Image("獲得")
                                    .resizable()
                                    .frame(maxWidth:110,maxHeight:110)
                            } else {
                                Image("獲得白黒")
                                    .resizable()
                                    .frame(maxWidth:110,maxHeight:110)
                            }
                        }
                        .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
                        .onChange(of: reward.rewardEarned) { rewardEarned in
                            showAlert = rewardEarned
                            print("onChange reward.rewardEarned:\(reward.rewardEarned)")
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("報酬獲得！"),
                                message: Text("300コイン獲得しました。"),
                                dismissButton: .default(Text("OK"), action: {
                                    // アラートを閉じるアクション
                                    showAlert = false // アラートの表示状態を更新
                                    reward.rewardEarned = false // 必要に応じてrewardEarnedも更新
                                })
                            )
                        }
                        .onAppear() {
                            reward.LoadReward()
                        }
                        .shadow(radius: 10)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ScrollView{
                        Image("ガチャ")
                            .resizable()
                            .frame(width: frameSize().width, height: frameSize().height)
                        Spacer()
                        HStack{
                            Spacer()
                            VStack{
                                Button(action: {
                                    self.showResult = false
                                    authManager.decreaseUserMoney { success in
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
                                            .frame(width: frameSize2().width, height: frameSize2().height)
                                    }else{
                                        Image("ガチャる白黒")
                                            .resizable()
                                            .frame(width: frameSize2().width, height: frameSize2().height)
                                    }
                                }
                                .shadow(radius: 10)
                                .disabled(!isGachaButtonDisabled)
                                Image("300コイン")
                                    .resizable()
                                    .frame(maxWidth:150,maxHeight:50)
                            }
                            Spacer()
                            Button(action: {
                                reward.ShowReward()
                            }) {
                                if reward.rewardLoaded {
                                    Image("獲得")
                                        .resizable()
                                        .frame(maxWidth:110,maxHeight:110)
                                } else {
                                    Image("獲得白黒")
                                        .resizable()
                                        .frame(maxWidth:110,maxHeight:110)
                                }
                            }
                            .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
                            .onChange(of: reward.rewardEarned) { rewardEarned in
                                showAlert = rewardEarned
//                                print("onChange reward.rewardEarned:\(rewardEarned)")
                            }
                            .onAppear() {
                                reward.LoadReward()
                            }
//                                .onAppear() {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 1秒後に
//                                                        self.isButtonClickable = true // ボタンをクリック可能に設定
//                                                    }
//                                reward.LoadReward()
//                            }
                            //                        .disabled(!reward.rewardLoaded)
                            .shadow(radius: 10)
                            Spacer()
                        }
                        Spacer()
                        Image("卵レア度")
                            .resizable()
                            .frame(width: frameSize4().width, height: frameSize4().height)
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
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("報酬獲得！"),
                message: Text("300コイン獲得しました。"),
                dismissButton: .default(Text("OK"), action: {
                    // アラートを閉じるアクション
                    showAlert = false // アラートの表示状態を更新
                    reward.rewardEarned = false // 必要に応じてrewardEarnedも更新
                })
            )
        }
        .onAppear {
            authManager.getUserMoney { userMoney in
//                print(userMoney)
                self.userMoney = userMoney
                // ここで userMoney を使用する
                if(userMoney < 300){
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
                if(userMoney < 300){
                    isGachaButtonDisabled = false
                    showCoinModal = true
                    showUnCoinModal = true
                }else{
                    isGachaButtonDisabled = true
                }
            }
            countAvatarsForUser(userId: authManager.currentUserId!) { avatarCount in
                print("ユーザーのアバターの数: \(avatarCount)")
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
                if(userMoney < 300){
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
        .navigationBarBackButtonHidden(true)
//                .navigationBarItems(leading: Button(action: {
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

struct GachaView_Previews: PreviewProvider {
    static var previews: some View {
        GachaView()
    }
}
