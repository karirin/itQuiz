//
//  Interstitial.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/28.
//

import SwiftUI
import GoogleMobileAds

class InterstitialStory: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    @Published var flag: Bool = false
    @Published var wasAdDismissed = false
    
    var interstitialAd: InterstitialAd?
    
    func loadInterstitial(completion: ((Bool) -> Void)? = nil) {
        guard AdvertisingPrivacyCoordinator.shared.isReady else {
            AdvertisingPrivacyCoordinator.shared.performWhenReady { [weak self] in
                self?.loadInterstitial(completion: completion)
            }
            return
        }

//      GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { (ad, error) in //テスト
        InterstitialAd.load(with: "ca-app-pub-4898800212808837/6252239732", request: Request()) { (ad, error) in
        if let _ = error {
          print("loadInterstitial 😭: 読み込みに失敗しました　ストーリー")
          print("loadInterstitial 広告の読み込みに失敗しました　ストーリー: \(error!.localizedDescription)")
          self.interstitialAdLoaded = false
          completion?(false)
          return
        }
        print("loadInterstitial 😍: 読み込みに成功しましたああ　ストーリー")
        self.interstitialAdLoaded = true
        self.interstitialAd = ad
        self.interstitialAd?.fullScreenContentDelegate = self
        completion?(true)
      }
    }
    
    func presentInterstitial(from viewController: UIViewController) {
      guard let fullScreenAd = interstitialAd else {
        return print("Ad wasn't ready　ストーリー")
      }

        guard let presenter = AdPresenterResolver.resolve(preferred: viewController) else { return }
        fullScreenAd.present(from: presenter)
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called　ストーリー")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called　ストーリー")
    }
    
    // 失敗通知
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました　ストーリー")
        self.interstitialAdLoaded = false
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました　ストーリー")
//        self.interstitialAdLoaded = false // 広告表示時に false に設定
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
        self.wasAdDismissed = true
        self.interstitialAd = nil
    }
}

struct AdViewControllerRepresentableStory: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}

struct Interstitial1Story: View {
    private let adViewControllerRepresentable = AdViewControllerRepresentableStory()
    @StateObject private var interstitial = Interstitial()
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
    }
}

#Preview {
    Interstitial1Story()
}
