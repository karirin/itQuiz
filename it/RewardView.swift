//
//  RewardView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/30.
//

import SwiftUI
import GoogleMobileAds

class Reward: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var rewardLoaded: Bool = false
    @Published var rewardEarned: Bool = false // この行を追加
    var rewardedAd: GADRewardedAd?
    @ObservedObject var authManager = AuthManager.shared

    override init() {
        super.init()
        LoadReward() // 初期化時に広告をロード
    }

    // リワード広告の読み込み
    func LoadReward() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-4898800212808837/5768331457", request: GADRequest()) { (ad, error) in
//        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { (ad, error) in //テスト
            if let _ = error {
                print("😭: 読み込みに失敗しましたaaa")
                self.rewardLoaded = false
                return
            }
            print("😍: 読み込みに成功しました")
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    // リワード広告の表示
    func ShowReward() {
        if let root = UIApplication.shared.windows.first?.rootViewController {
            if let ad = rewardedAd {
                ad.present(fromRootViewController: root, userDidEarnRewardHandler: {
                    print("😍: 報酬を獲得しました")
                    self.authManager.addMoney(amount: 300)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.rewardEarned = true
//                        print("self.rewardEarned:\(self.rewardEarned)")
//                    }
                    self.LoadReward()
                })
            } else {
                print("😭: 広告の準備ができていませんでした")
                LoadReward()
            }
        }
    }
    
    // リワード広告の表示
    func ExAndMoReward() {
        if let root = UIApplication.shared.windows.first?.rootViewController {
            if let ad = rewardedAd {
                ad.present(fromRootViewController: root, userDidEarnRewardHandler: {
                    print("ExAndMoReward 😍: 報酬を獲得しました")
                    self.authManager.updateRewardFlag(userId: self.authManager.currentUserId!, userFlag: 2)
                    let now = Date()
                            UserDefaults.standard.set(now, forKey: "rewardAcquiredDate")
                    self.resetupdateRewardFlag()
                    // 報酬を得た後に、新しい広告をロードする
                    self.LoadReward()
                })
            } else {
                print("ExAndMoReward 😭: 広告の準備ができていませんでした")
                // 広告がない場合はロードする
                LoadReward()
            }
        }
    }
    
    func checkRewardReset() {
        print("checkRewardReset")
        if let rewardDate = UserDefaults.standard.object(forKey: "rewardAcquiredDate") as? Date {
            if Date().timeIntervalSince(rewardDate) >= 3600 { // 1時間経過しているかチェック
                self.authManager.updateRewardFlag(userId: self.authManager.currentUserId!, userFlag: 1)
            }
        }
    }
    
    func resetupdateRewardFlag() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { // 3600秒（1時間）後
            self.authManager.updateRewardFlag(userId: self.authManager.currentUserId!, userFlag: 1)
            print("💰: Moneyが0にリセットされました")
        }
    }
    
    // 広告が閉じられたときに呼ばれるデリゲートメソッド
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("広告が閉じられました。新しい広告をロードします。")
        self.rewardLoaded = false // 必要に応じて、UIの更新をトリガする
        LoadReward()
    }

}

struct RewardView: View {
    @ObservedObject var reward = Reward()
    var body: some View {
        Button(action: {
            reward.ShowReward()
        }) {
            Text(reward.rewardLoaded ? "リワード広告表示" : "読み込み中...")
        }
        .onAppear() {
            reward.LoadReward()
        }
        .disabled(!reward.rewardLoaded)
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
    }
}
