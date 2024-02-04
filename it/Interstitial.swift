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
//    func loadInterstitial() {
//        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-4898800212808837/3001013957", request: GADRequest()) { [self] (ad, error) in
//        print("loadInterstitial")
////        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { (ad, error) in
//            if let _ = error {
//                print("loadInterstitial 😭: 読み込みに失敗しました")
//                print("loadInterstitial 広告の読み込みに失敗しました: \(error!.localizedDescription)")
//                self.interstitialAdLoaded = false
//                return
//            }
//            print("loadInterstitial 😍: 読み込みに成功しましたああ")
//            print("loadInterstitial self.interstitialAdLoaded1:\(self.interstitialAdLoaded)")
//            self.interstitialAdLoaded = true
//            print("loadInterstitial self.interstitialAdLoaded2:\(self.interstitialAdLoaded)")
//            self.flag = true
//            print("loadInterstitial flag:\(self.flag)")
//            self.interstitialAd = ad
//            self.interstitialAd?.fullScreenContentDelegate = self
//        }
//    }

    func loadInterstitial() {
      GADInterstitialAd.load(
        withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()
      ) { ad, error in
        if let error = error {
          return print("Failed to load ad with error: \(error.localizedDescription)")
        }

        self.interstitialAd = ad
      }
    }

    // インタースティシャル広告の表示
//    func presentInterstitial() {
//        let root = UIApplication.shared.windows.first?.rootViewController
//        if let ad = interstitialAd {
//            ad.present(fromRootViewController: root!)
////            self.wasAdDismissed = true
////            self.interstitialAdLoaded = false
//        } else {
//            print("😭: 広告の準備ができていませんでした")
//            self.interstitialAdLoaded = false
//            self.loadInterstitial { isLoaded in
//                if isLoaded {
//                    print("広告が正常にロードされました")
//                    // 必要に応じて広告を表示するなど、次のステップを実行
//                } else {
//                    print("広告のロードに失敗しました")
//                }
//            }
//        }
//    }
    
    func presentInterstitial(from viewController: UIViewController) {
      guard let fullScreenAd = interstitialAd else {
        return print("Ad wasn't ready")
      }

      fullScreenAd.present(fromRootViewController: viewController)
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
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
//        self.interstitialAdLoaded = false // 広告表示時に false に設定
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false // 広告閉じた時に false に設定
        self.wasAdDismissed = true
//        loadInterstitial()  // 新しい広告をロード
    }
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}

struct Interstitial1: View {
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
        @ObservedObject var interstitial = Interstitial()
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .background {
                        // Add the adViewControllerRepresentable to the background so it
                        // doesn't influence the placement of other views in the view hierarchy.
                        adViewControllerRepresentable
                          .frame(width: .zero, height: .zero)
                      }
        }
        .onAppear {
            interstitial.loadInterstitial()
            interstitial.presentInterstitial(from: adViewControllerRepresentable.viewController)
        }
//        .onChange(of: interstitial.interstitialAdLoaded) { isLoaded in
//            if isLoaded {
//                interstitial.presentInterstitial()
//            }
//        }
    }
}

#Preview {
    Interstitial1()
}
