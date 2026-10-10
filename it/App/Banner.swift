//
//  Banner.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/30.
//

import GoogleMobileAds
import SwiftUI

struct BannerAdView: View {
    var body: some View {
        AdaptiveBannerAdView(
            productionAdUnitID: "ca-app-pub-4898800212808837/2438633524",
            placementName: "ホーム",
            format: .compact
        )
    }
}

struct BannerStortyView: View {
    var body: some View {
        AdaptiveBannerAdView(
            productionAdUnitID: "ca-app-pub-4898800212808837/5549995178",
            placementName: "ストーリー",
            format: .large
        )
    }
}

private enum AnchoredBannerFormat {
    case compact
    case large

    func adSize(for width: CGFloat) -> AdSize {
        switch self {
        case .compact:
            return currentOrientationAnchoredAdaptiveBanner(width: width)
        case .large:
            return largeAnchoredAdaptiveBanner(width: width)
        }
    }
}

private struct AdaptiveBannerAdView: View {
    let productionAdUnitID: String
    let placementName: String
    let format: AnchoredBannerFormat

    @State private var availableWidth: CGFloat = 0
    @State private var adHeight: CGFloat = 0

    private var adUnitID: String {
#if DEBUG
        return "ca-app-pub-3940256099942544/2435281174"
#else
        return productionAdUnitID
#endif
    }

    var body: some View {
        Group {
            if availableWidth > 0 {
                AdaptiveBannerContainer(
                    adUnitID: adUnitID,
                    placementName: placementName,
                    width: availableWidth,
                    format: format
                ) { newHeight in
                    guard abs(adHeight - newHeight) > 0.5 else { return }
                    adHeight = newHeight
                }
                .frame(width: availableWidth, height: adHeight)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: adHeight)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateWidth(geometry.size.width)
                    }
                    .onChange(of: geometry.size.width) { newWidth in
                        updateWidth(newWidth)
                    }
            }
        }
    }

    private func updateWidth(_ width: CGFloat) {
        let roundedWidth = floor(width)
        guard roundedWidth > 0, abs(availableWidth - roundedWidth) > 0.5 else { return }
        availableWidth = roundedWidth
    }
}

private struct AdaptiveBannerContainer: UIViewRepresentable {
    let adUnitID: String
    let placementName: String
    let width: CGFloat
    let format: AnchoredBannerFormat
    let onHeightChange: (CGFloat) -> Void

    func makeUIView(context: Context) -> BannerView {
        let adSize = format.adSize(for: width)
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = rootViewController()

        context.coordinator.loadedWidth = width
        notifyHeight(for: adSize)
        context.coordinator.loadWhenReady(bannerView)

        return bannerView
    }

    func updateUIView(_ bannerView: BannerView, context: Context) {
        bannerView.rootViewController = rootViewController()

        guard abs(context.coordinator.loadedWidth - width) > 0.5 else { return }

        let adSize = format.adSize(for: width)
        context.coordinator.loadedWidth = width
        bannerView.adSize = adSize
        notifyHeight(for: adSize)
        context.coordinator.loadWhenReady(bannerView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(placementName: placementName)
    }

    private func notifyHeight(for adSize: AdSize) {
        let height = cgSize(for: adSize).height
        DispatchQueue.main.async {
            onHeightChange(height)
        }
    }

    private func rootViewController() -> UIViewController? {
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        let window = activeScene?.windows.first { $0.isKeyWindow }
            ?? activeScene?.windows.first

        return window?.rootViewController
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        let placementName: String
        var loadedWidth: CGFloat = 0
        private weak var pendingBannerView: BannerView?
        private var isWaitingForPrivacyAuthorization = false

        init(placementName: String) {
            self.placementName = placementName
        }

        func loadWhenReady(_ bannerView: BannerView) {
            pendingBannerView = bannerView

            guard !isWaitingForPrivacyAuthorization else { return }
            isWaitingForPrivacyAuthorization = true

            AdvertisingPrivacyCoordinator.shared.performWhenReady { [weak self] in
                guard let self else { return }

                self.isWaitingForPrivacyAuthorization = false
                self.pendingBannerView?.load(Request())
                self.pendingBannerView = nil
            }
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("\(placementName)アダプティブ広告の読み込み成功")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("\(placementName)アダプティブ広告の読み込み失敗: \(error.localizedDescription)")
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
