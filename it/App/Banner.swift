//
//  Banner.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/30.
//

import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    private let adUnitID = "ca-app-pub-4898800212808837/2438633524"
    @State private var adHeight: CGFloat = 50
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = getRootViewController()
        
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        let parent: BannerAdView
        
        init(_ parent: BannerAdView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerAdView) {
            print("広告の読み込み成功")
        }
        
        func bannerView(_ bannerView: BannerAdView, didFailToReceiveAdWithError error: Error) {
            print("広告の読み込み失敗: \(error.localizedDescription)")
        }
    }
}

struct BannerStortyView: UIViewRepresentable {
//    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"
//    class GADBannerViewController: UIViewController, GADBannerViewDelegate {
//        var bannerView: GADBannerView!
//        let adUnitID = "ca-app-pub-4898800212808837/2438633524"
    private let adUnitID = "ca-app-pub-4898800212808837/5549995178"
    @State private var adHeight: CGFloat = 50
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = getRootViewController()
        
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        let parent: BannerStortyView
        
        init(_ parent: BannerStortyView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerStortyView) {
            print("広告の読み込み成功")
        }
        
        func bannerView(_ bannerView: BannerStortyView, didFailToReceiveAdWithError error: Error) {
            print("広告の読み込み失敗: \(error.localizedDescription)")
        }
    }
}

//struct BannerView: UIViewControllerRepresentable {
//    func makeUIViewController(context _: Context) -> UIViewController {
//        let viewController = GADBannerViewController()
//        return viewController
//    }
//
//    func updateUIViewController(_: UIViewController, context _: Context) {}
//}
//
//struct BannerStoryView: UIViewControllerRepresentable {
//    func makeUIViewController(context _: Context) -> UIViewController {
//        let viewController = GADBannerStoryViewController()
//        return viewController
//    }
//
//    func updateUIViewController(_: UIViewController, context _: Context) {}
//}
//
//class GADBannerViewController: UIViewController, GADBannerViewDelegate {
//    var bannerView: GADBannerView!
//    let adUnitID = "ca-app-pub-4898800212808837/2438633524"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        loadBanner()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
//            guard let self else { return }
//            self.loadBanner()
//        }
//    }
//
//    private func loadBanner() {
//        bannerView = GADBannerView(adSize: GADAdSizeBanner)  // GADBannerViewを使用
//        bannerView.adUnitID = adUnitID
//
//        bannerView.delegate = self
//        bannerView.rootViewController = self
//
//        let bannerWidth = view.frame.size.width
//        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)
//
//        let request = GADRequest()  // Requestではなく、GADRequestを使用
//        request.scene = view.window?.windowScene
//        bannerView.load(request)
//
//        setAdView(bannerView)
//    }
//
//    func setAdView(_ view: GADBannerView) {
//        bannerView = view
//        self.view.addSubview(bannerView)
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        let viewDictionary = ["_bannerView": bannerView!]
//        self.view.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "H:|[_bannerView]|",
//                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
//            )
//        )
//        self.view.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "V:|[_bannerView]|",
//                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
//            )
//        )
//    }
//}
//
//class GADBannerStoryViewController: UIViewController, GADBannerViewDelegate {
//    var bannerView: GADBannerView!
//    let adUnitID = "ca-app-pub-4898800212808837/5549995178"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        loadBanner()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
//            guard let self else { return }
//            self.loadBanner()
//        }
//    }
//
//    private func loadBanner() {
//        bannerView = GADBannerView(adSize: GADAdSizeBanner)  // GADBannerViewを使用
//        bannerView.adUnitID = adUnitID
//
//        bannerView.delegate = self
//        bannerView.rootViewController = self
//
//        let bannerWidth = view.frame.size.width
//        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)
//
//        let request = GADRequest()  // Requestではなく、GADRequestを使用
//        request.scene = view.window?.windowScene
//        bannerView.load(request)
//
//        setAdView(bannerView)
//    }
//
//    func setAdView(_ view: GADBannerView) {
//        bannerView = view
//        self.view.addSubview(bannerView)
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        let viewDictionary = ["_bannerView": bannerView!]
//        self.view.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "H:|[_bannerView]|",
//                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
//            )
//        )
//        self.view.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "V:|[_bannerView]|",
//                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
//            )
//        )
//    }
//}
