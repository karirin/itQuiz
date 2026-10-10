//
//  IntroOfferInfo.swift
//  it
//
//  無料トライアル（イントロダクトリーオファー）の表示用情報。
//
//  設計方針:
//  - App Store Connect 側にオファーが未設定、またはユーザーが対象外の場合は
//    このイニシャライザが nil を返し、呼び出し側は従来どおりの表示にフォールバックする。
//  - 購入処理そのものには一切関与しない。イントロオファーは StoreKit が
//    product.purchase() 実行時に自動適用するため、コード側で渡す必要はない。
//

import Foundation
import StoreKit

struct IntroOfferInfo: Equatable {
    /// 無料トライアルかどうか（有料の割引オファーの場合は false）
    let isFreeTrial: Bool
    /// 「7日間」など、オファー期間の表記
    let periodText: String
    /// プランカードのバッジ用。「7日間無料」など
    let badgeText: String
    /// 購入ボタン用。「7日間無料で始める」など
    let ctaTitle: String
    /// 購入ボタン下の注意書き。トライアル期間と終了後の価格を必ず含む
    let disclosureText: String
    /// プランカードのサブ行。「7日間無料 → その後 年額¥9,800」など
    let cardSubtitle: String

    init?(product: Product) {
        guard let subscription = product.subscription,
              let offer = subscription.introductoryOffer else { return nil }

        let offerPeriod = Self.periodText(
            unit: offer.period.unit,
            value: offer.period.value * max(offer.periodCount, 1)
        )
        guard !offerPeriod.isEmpty else { return nil }

        let renewalLabel = Self.renewalLabel(for: subscription.subscriptionPeriod.unit)
        let renewalPrice = renewalLabel.isEmpty
            ? product.displayPrice
            : "\(renewalLabel)\(product.displayPrice)"

        self.periodText = offerPeriod

        if offer.paymentMode == .freeTrial {
            self.isFreeTrial = true
            self.badgeText = "\(offerPeriod)無料"
            self.ctaTitle = "\(offerPeriod)無料で始める"
            self.cardSubtitle = "\(offerPeriod)無料 → その後 \(renewalPrice)"
            self.disclosureText = "\(offerPeriod)無料。終了後は\(renewalPrice)で自動更新・いつでも解約できます"
        } else if offer.paymentMode == .payAsYouGo {
            self.isFreeTrial = false
            self.badgeText = "初回割引"
            self.ctaTitle = "\(offer.displayPrice)で始める"
            self.cardSubtitle = "最初の\(offerPeriod)は\(offer.displayPrice) → その後 \(renewalPrice)"
            self.disclosureText = "最初の\(offerPeriod)は\(offer.displayPrice)。以降は\(renewalPrice)で自動更新・いつでも解約できます"
        } else if offer.paymentMode == .payUpFront {
            self.isFreeTrial = false
            self.badgeText = "初回割引"
            self.ctaTitle = "\(offer.displayPrice)で始める"
            self.cardSubtitle = "\(offerPeriod)\(offer.displayPrice) → その後 \(renewalPrice)"
            self.disclosureText = "\(offerPeriod)を\(offer.displayPrice)で利用でき、以降は\(renewalPrice)で自動更新・いつでも解約できます"
        } else {
            // 将来 StoreKit に新しい paymentMode が増えた場合は
            // 誤った表示を出さず、従来表示にフォールバックする
            return nil
        }
    }

    // MARK: - Helpers

    private static func periodText(unit: Product.SubscriptionPeriod.Unit, value: Int) -> String {
        guard value > 0 else { return "" }
        switch unit {
        case .day:
            return "\(value)日間"
        case .week:
            // 「1週間無料」より「7日間無料」の方が短さが伝わりにくい誤解を生まない
            return "\(value * 7)日間"
        case .month:
            return "\(value)ヶ月間"
        case .year:
            return "\(value)年間"
        default:
            return ""
        }
    }

    private static func renewalLabel(for unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .week: return "週額"
        case .month: return "月額"
        case .year: return "年額"
        default: return ""
        }
    }
}
