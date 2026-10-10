//
//  SubModalView.swift
//  it
//
//  Created by Apple on 2024/02/26.
//

import SwiftUI
import StoreKit

struct SubModalView: View {
    @Binding var isSoundOn: Bool
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var showHomeModal: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    var pauseTimer: () -> Void
    var resumeTimer: () -> Void
    @Binding var userFlag: Int
    @StateObject private var viewModel = SubscriptionViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var didLogPaywallView = false
    @State private var didLogPaywallReady = false
    @State private var didLogPaywallDismiss = false
    @State private var paywallDisplayID = UUID().uuidString
    @State private var selectedProduct: Product? = nil
    @State private var isPurchasing = false
    @State private var didPurchase = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    private let source: PremiumPaywallSource = .quiz

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Header
                        VStack(spacing: 8) {
                            HStack(spacing: 5) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 11))
                                Text("プレミアムプラン")
                                    .font(.system(size: 12, weight: .black))
                            }
                            .foregroundColor(PremiumPalette.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(PremiumPalette.goldGradient))

                            Text(source.headline)
                                .font(.system(size: 19, weight: .black))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(source.detail)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.72))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 6) {
                                PremiumTrustChip(icon: "checkmark.shield.fill", text: "いつでも解約OK")
                                PremiumTrustChip(icon: "applelogo", text: "App Store決済")
                            }
                            .padding(.top, 2)
                        }
                        .padding(.top, 20)

                        PremiumComparisonTable()

                        // Plan Selection
                        if viewModel.productLoadState != .loaded {
                            ProductLoadStatusView(
                                state: viewModel.productLoadState,
                                message: viewModel.productLoadErrorMessage,
                                retry: retryProductLoad
                            )
                        } else {
                            VStack(spacing: 10) {
                                ForEach(sortProductsByPeriod(viewModel.products), id: \.id) { product in
                                    PlanSelectionCard(
                                        product: product,
                                        isSelected: selectedProduct?.id == product.id,
                                        introOffer: viewModel.introOffer(for: product),
                                        allProducts: viewModel.products
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedProduct = product
                                        }
                                        PremiumAnalytics.logPlanSelect(
                                            product: product,
                                            source: source,
                                            displayID: paywallDisplayID,
                                            method: "manual"
                                        )
                                    }
                                }
                            }
                        }

                        // Footer links
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text("購入復元は")
                                    .foregroundColor(.white.opacity(0.6))
                                Button("こちら") {
                                    Task {
                                        PremiumAnalytics.logRestoreStart(source: source, displayID: paywallDisplayID)
                                        do {
                                            try await AppStore.sync()
                                            await appState.refreshSubscriptionState()
                                            PremiumAnalytics.logRestoreSuccess(
                                                source: source,
                                                displayID: paywallDisplayID,
                                                restoredSubscription: appState.isSubscribed
                                            )
                                        } catch {
                                            PremiumAnalytics.logRestoreError(
                                                source: source,
                                                displayID: paywallDisplayID,
                                                error: error
                                            )
                                            print("購入処理中にエラーが発生しました: \(error)")
                                        }
                                    }
                                }
                                .foregroundColor(.cyan)
                                Text("・解約は")
                                    .foregroundColor(.white.opacity(0.6))
                                if let cancelURL = URL(string: "https://support.apple.com/ja-jp/HT202039") {
                                    Link("こちら", destination: cancelURL)
                                        .foregroundColor(.cyan)
                                }
                            }
                            .font(.system(size: 12))

                            HStack(spacing: 12) {
                                Button("利用規約") {
                                    showTerms = true
                                }
                                Text("・")
                                    .foregroundColor(.white.opacity(0.4))
                                Button("プライバシーポリシー") {
                                    showPrivacy = true
                                }
                            }
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                }

                // Purchase CTA
                VStack(spacing: 0) {
                    Divider().overlay(Color.white.opacity(0.2))
                    Button(action: purchaseSelectedProduct) {
                        HStack(spacing: 10) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "2D1F14")))
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                            }

                            VStack(spacing: 2) {
                                Text(purchaseButtonTitle)
                                    .font(.system(size: 16, weight: .bold))
                                Text(purchaseButtonCaption)
                                    .font(.system(size: 10))
                                    .multilineTextAlignment(.center)
                                    .opacity(0.8)
                            }
                        }
                        .foregroundColor(PremiumPalette.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(PremiumPalette.goldGradient)
                                .shadow(color: Color(hex: "FFB020").opacity(0.45), radius: 10, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedProduct == nil || isPurchasing)
                    .opacity(selectedProduct == nil ? 0.6 : 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                PremiumPalette.backdropTop,
                                PremiumPalette.backdropMid,
                                PremiumPalette.backdropBottom
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(PremiumPalette.gold.opacity(0.35), lineWidth: 1.2)
            )
            .frame(maxHeight: min(UIScreen.main.bounds.height * 0.82, 640))
            .padding()
            .shadow(radius: 10)
            .overlay(
                // 「×」ボタンを右上に配置
                Button(action: {
                    generateHapticFeedback()
                    logPaywallDismissIfNeeded(reason: "close_button")
                    isPresented = false
                    resumeTimer()
                    audioManager.playCancelSound()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.black.opacity(0.55)))
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .padding()
                }
                .offset(x: 10, y: -15),
                alignment: .topTrailing
            )
        }
        .onAppear {
            pauseTimer() // モーダルが表示されたときにタイマーを一時停止
            if !didLogPaywallView {
                PremiumAnalytics.logPaywallView(source: source, displayID: paywallDisplayID)
                didLogPaywallView = true
            }
            if userFlag == 0 {
                isSoundOn = true
            } else {
                isSoundOn = false
            }
            Task {
                await loadProductsAndConfigurePaywall(selectionMethod: "default")
            }
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                logPaywallDismissIfNeeded(reason: didPurchase ? "purchase_success" : "parent_dismiss")
            }
        }
        .sheet(isPresented: $showTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if didPurchase {
                        logPaywallDismissIfNeeded(reason: "purchase_success")
                        isPresented = false
                        resumeTimer()
                    }
                }
            )
        }
    }

    private var purchaseButtonTitle: String {
        guard let product = selectedProduct else {
            return "プランを選択してください"
        }
        if let intro = viewModel.introOffer(for: product) {
            return intro.ctaTitle
        }
        let periodLabel: String
        switch product.subscription?.subscriptionPeriod.unit {
        case .week: periodLabel = "週額"
        case .month: periodLabel = "月額"
        case .year: periodLabel = "年額"
        default: periodLabel = ""
        }
        return "\(periodLabel)\(product.displayPrice)で始める"
    }

    /// トライアル時は期間と終了後の価格を明示する（App Store 審査ガイドライン 3.1.2 の要件）
    private var purchaseButtonCaption: String {
        if let product = selectedProduct,
           let intro = viewModel.introOffer(for: product) {
            return intro.disclosureText
        }
        return "自動更新・いつでも解約できます"
    }

    private func purchaseSelectedProduct() {
        guard let product = selectedProduct, !isPurchasing else { return }
        generateHapticFeedback()
        isPurchasing = true
        PremiumAnalytics.logPlanSelect(
            product: product,
            source: source,
            displayID: paywallDisplayID,
            method: "purchase_button"
        )
        PremiumAnalytics.logPurchaseStart(product: product, source: source, displayID: paywallDisplayID)
        let startsFreeTrial = viewModel.introOffer(for: product)?.isFreeTrial == true
        Task {
            do {
                let transaction = try await viewModel.purchaseProduct(product)
                PremiumAnalytics.logPurchaseSuccess(
                    product: product,
                    transaction: transaction,
                    isFreeTrial: startsFreeTrial,
                    source: source,
                    displayID: paywallDisplayID
                )
                didPurchase = true
                alertTitle = "プレミアムプラン登録ありがとうございます！"
                alertMessage = "プレミアム機能が利用できるようになりました"
                showAlert = true
            } catch SubscribeError.userCancelled {
                PremiumAnalytics.logPurchaseCancel(product: product, source: source, displayID: paywallDisplayID)
            } catch SubscribeError.pending {
                PremiumAnalytics.logPurchasePending(product: product, source: source, displayID: paywallDisplayID)
                alertTitle = "購入は保留中です"
                alertMessage = SubscribeError.pending.errorDescription ?? "承認後に自動的に反映されます"
                showAlert = true
            } catch {
                PremiumAnalytics.logPurchaseError(product: product, source: source, displayID: paywallDisplayID, error: error)
                alertTitle = "購入できませんでした"
                alertMessage = (error as? LocalizedError)?.errorDescription
                    ?? "購入処理中にエラーが発生しました。もう一度お試しください"
                showAlert = true
            }
            isPurchasing = false
        }
    }

    private func retryProductLoad() {
        Task {
            await loadProductsAndConfigurePaywall(selectionMethod: "retry_default")
        }
    }

    @MainActor
    private func loadProductsAndConfigurePaywall(selectionMethod: String) async {
        await viewModel.loadProducts()
        guard viewModel.productLoadState == .loaded else { return }

        if !didLogPaywallReady {
            let monthlyTrialEligible = viewModel.products.contains { product in
                product.subscription?.subscriptionPeriod.unit == .month
                    && viewModel.introOffer(for: product)?.isFreeTrial == true
            }
            PremiumAnalytics.logPaywallReady(
                source: source,
                displayID: paywallDisplayID,
                products: viewModel.products,
                missingProductCount: viewModel.missingProductCount,
                loadAttemptCount: viewModel.productLoadAttemptCount,
                hasEligibleMonthlyTrial: monthlyTrialEligible
            )
            didLogPaywallReady = true
        }

        let defaultProduct = viewModel.products.first(where: {
            $0.subscription?.subscriptionPeriod.unit == .month
        }) ?? sortProductsByPeriod(viewModel.products).first

        guard selectedProduct == nil else { return }
        guard let product = defaultProduct else { return }
        selectedProduct = product
        PremiumAnalytics.logPlanSelect(
            product: product,
            source: source,
            displayID: paywallDisplayID,
            method: selectionMethod
        )
    }

    private func logPaywallDismissIfNeeded(reason: String) {
        guard !didLogPaywallDismiss else { return }
        didLogPaywallDismiss = true
        PremiumAnalytics.logPaywallDismiss(
            source: source,
            displayID: paywallDisplayID,
            reason: reason,
            selectedProductID: selectedProduct?.id
        )
    }
}
//
//struct ModalView1_Previews: PreviewProvider {
//    @State static private var isPresenting = true
//    static var previews: some View {
//        SubModalView(isSoundOn: .constant(true), isPresented: .constant(true), isPresenting: $isPresenting, audioManager: AudioManager(), showHomeModal: .constant(true), userFlag: .constant(1))
////ModalView()
//    }
//}
