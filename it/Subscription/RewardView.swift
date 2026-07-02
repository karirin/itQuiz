//
//  RewardView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/30.
//

import SwiftUI
import GoogleMobileAds

class Reward: NSObject, FullScreenContentDelegate, ObservableObject {
    private enum Placement {
        case standard
        case story
    }

    @Published var rewardLoaded: Bool = false
    @Published var rewardEarned: Bool = false
    var rewardedAd: RewardedAd?
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var viewModel: PositionViewModel = PositionViewModel.shared
    private var currentPlacement: Placement = .standard

    override init() {
        super.init()
//        LoadReward() // 初期化時に広告をロード
    }

    private func loadReward(for placement: Placement) {
        currentPlacement = placement

        let adUnitID: String
        switch placement {
        case .standard:
            adUnitID = "ca-app-pub-4898800212808837/5768331457"
        case .story:
            adUnitID = "ca-app-pub-4898800212808837/6563091309"
        }

        RewardedAd.load(with: adUnitID, request: Request()) { (ad, error) in
            if let error = error {
                let label = placement == .story ? "LoadStoryReward" : "LoadReward"
                print("\(label) 😭: 読み込みに失敗しました: \(error.localizedDescription)")
                self.rewardLoaded = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.loadReward(for: placement)
                }
                return
            }
            let label = placement == .story ? "LoadStoryReward" : "LoadReward"
            print("\(label) 😍: 読み込みに成功しました")
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    private func reloadCurrentReward() {
        loadReward(for: currentPlacement)
    }

    // リワード広告の読み込み
    func LoadReward() {
        loadReward(for: .standard)
    }
    
    func LoadStoryReward() {
        loadReward(for: .story)
    }

    // リワード広告の表示
    func ShowReward() {
        if let root = UIApplication.shared.windows.first?.rootViewController {
            if let ad = rewardedAd {
                ad.present(from: root, userDidEarnRewardHandler: {
                    print("😍: 報酬を獲得しました")
                    self.authManager.addMoney(amount: 300)
                    self.rewardEarned = true
                })
            } else {
                print("😭: 広告の準備ができていませんでした")
                reloadCurrentReward()
            }
        }
    }
    
    func ShowSutaminaReward() {
        if let root = UIApplication.shared.windows.first?.rootViewController {
            if let ad = rewardedAd {
                ad.present(from: root, userDidEarnRewardHandler: { [self] in
                    print("😍: 報酬を獲得しました")
                    viewModel.recoverStamina(by: 30)
                    self.rewardEarned = true
                })
            } else {
                print("😭: 広告の準備ができていませんでした")
                reloadCurrentReward()
            }
        }
    }
    
    // リワード広告の表示
    func ExAndMoReward() {
        if let root = UIApplication.shared.windows.first?.rootViewController {
            if let ad = rewardedAd {
                ad.present(from: root, userDidEarnRewardHandler: {
                    print("ExAndMoReward 😍: 報酬を獲得しました")
                    self.authManager.activateOneHourBoost { success in
                        guard success else { return }
                        self.rewardEarned = true
                        print("::::::\(self.rewardEarned)")
                    }
                })
            } else {
                print("ExAndMoReward 😭: 広告の準備ができていませんでした")
                reloadCurrentReward()
            }
        }
    }
    
    func checkRewardReset() {
        print("checkRewardReset")
        self.authManager.syncRewardBoostState()
    }
    
    func resetupdateRewardFlag() {
        self.authManager.syncRewardBoostState()
    }
    
    // 広告が閉じられたときに呼ばれるデリゲートメソッド
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("広告が閉じられました。新しい広告をロードします。")
        self.rewardLoaded = false
        self.rewardedAd = nil
        reloadCurrentReward()
    }

}

struct RewardView: View {
    @ObservedObject var reward = Reward()
    var body: some View {
        Button(action: { 
                        generateHapticFeedback()
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
