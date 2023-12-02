//
//  Interstitial.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/28.
//

import SwiftUI
import GoogleMobileAds

class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    @Published var flag: Bool = false
    @Published var wasAdDismissed = false
    
    var interstitialAd: GADInterstitialAd?

    override init() {
        super.init()
    }

    // リワード広告の読み込み
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { [self] (ad, error) in
            if let _ = error {
                print("😭: 読み込みに失敗しました")
                print("広告の読み込みに失敗しました: \(error!.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("😍: 読み込みに成功しましたああ")
            self.interstitialAdLoaded = true
            self.flag = true
            print("flag:\(flag)")
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    // インタースティシャル広告の表示
    func presentInterstitial() {
        let root = UIApplication.shared.windows.first?.rootViewController
        if let ad = interstitialAd {
            ad.present(fromRootViewController: root!)
            self.interstitialAdLoaded = false
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.loadInterstitial()
        }
    }
    // 失敗通知
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false // 広告表示時に false に設定
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false // 広告閉じた時に false に設定
        self.wasAdDismissed = true
//        loadInterstitial()  新しい広告をロード
    }
}

struct Interstitial1: View {
    
        @ObservedObject var interstitial = Interstitial()
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }        
        .onAppear {
            if !interstitial.interstitialAdLoaded {
                interstitial.loadInterstitial()
            }
        }
        .onChange(of: interstitial.interstitialAdLoaded) { isLoaded in
            if isLoaded {
                interstitial.presentInterstitial()
            }
        }
    }
}

#Preview {
    Interstitial1()
}
