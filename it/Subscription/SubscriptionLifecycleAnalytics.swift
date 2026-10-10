import Foundation
import FirebaseAnalytics
import StoreKit

/// StoreKitトランザクション単位で無料体験開始と更新課金を分けて記録する。
enum SubscriptionLifecycleAnalytics {
    private enum Key {
        static let processedTransactionIDs = "subscription.analytics.processedTransactionIDs"
        static let trialOriginalTransactionIDs = "subscription.analytics.trialOriginalTransactionIDs"
    }

    /// App Store Server Notificationsと端末内の匿名Firebaseユーザーを照合するためのUUID。
    /// Firebase UIDそのものはAppleへ送らず、端末内に生成した対応値だけを保持する。
    static func appAccountToken(for userID: String?) -> UUID? {
        guard let userID, !userID.isEmpty else { return nil }
        let storageKey = "subscription.appAccountToken.\(userID)"
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let token = UUID(uuidString: saved) {
            return token
        }

        let token = UUID()
        UserDefaults.standard.set(token.uuidString, forKey: storageKey)
        return token
    }

    static func record(
        transaction: StoreKit.Transaction,
        source: String,
        paywallDisplayID: String = "none",
        expectedFreeTrial: Bool? = nil
    ) {
        let transactionID = String(transaction.id)
        var processed = Set(UserDefaults.standard.stringArray(forKey: Key.processedTransactionIDs) ?? [])
        guard !processed.contains(transactionID) else { return }

        let originalID = String(transaction.originalID)
        var trialOriginalIDs = Set(UserDefaults.standard.stringArray(forKey: Key.trialOriginalTransactionIDs) ?? [])
        let paymentMode = transaction.offerPaymentModeStringRepresentation ?? "none"
        let isFreeTrial = expectedFreeTrial
            ?? paymentMode.localizedCaseInsensitiveContains("free")
        let isInitialPurchase = transaction.id == transaction.originalID

        var parameters: [String: Any] = [
            "product_id": transaction.productID,
            "transaction_id": transactionID,
            "original_transaction_id": originalID,
            "source": source,
            "entry_point": source,
            "paywall_display_id": paywallDisplayID,
            "offer_type": offerTypeName(transaction.offerType),
            "offer_payment_mode": paymentMode,
            "is_trial_start": isInitialPurchase && isFreeTrial ? 1 : 0
        ]
        if let expirationDate = transaction.expirationDate {
            parameters["expiration_at"] = Int(expirationDate.timeIntervalSince1970)
        }

        if isInitialPurchase {
            Analytics.logEvent("subscription_started", parameters: parameters)
            if isFreeTrial {
                trialOriginalIDs.insert(originalID)
                UserDefaults.standard.set(Array(trialOriginalIDs), forKey: Key.trialOriginalTransactionIDs)
            }
        } else {
            Analytics.logEvent("subscription_renewed", parameters: parameters)
            if trialOriginalIDs.contains(originalID) {
                parameters["conversion_source"] = "free_trial"
                Analytics.logEvent("trial_converted", parameters: parameters)
                trialOriginalIDs.remove(originalID)
                UserDefaults.standard.set(Array(trialOriginalIDs), forKey: Key.trialOriginalTransactionIDs)
            }
        }

        processed.insert(transactionID)
        // 長期間利用してもUserDefaultsが増え続けないよう直近100件に制限する。
        UserDefaults.standard.set(Array(processed.suffix(100)), forKey: Key.processedTransactionIDs)
    }

    private static func offerTypeName(_ offerType: StoreKit.Transaction.OfferType?) -> String {
        switch offerType {
        case .introductory: return "introductory"
        case .promotional: return "promotional"
        case .code: return "code"
        case .winBack: return "win_back"
        case .none: return "none"
        default: return "unknown"
        }
    }
}
