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
    var rewardedAd: GADRewardedAd?
    @ObservedObject var authManager = AuthManager.shared

    override init() {
        super.init()
    }

    // リワード広告の読み込み
    func LoadReward() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-4898800212808837/5768331457", request: GADRequest()) { (ad, error) in
//        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { (ad, error) in
            if let _ = error {
                print("😭: 読み込みに失敗しました")
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
        let root = UIApplication.shared.windows.first?.rootViewController
        if let ad = rewardedAd {
            ad.present(fromRootViewController: root!, userDidEarnRewardHandler: {
                print("😍: 報酬を獲得しました")
                self.rewardLoaded = false
                self.authManager.addMoney(amount: 300)
            })
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.rewardLoaded = false
            self.LoadReward()
        }
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
