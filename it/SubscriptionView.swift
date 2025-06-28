//
//  SubscriptionView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/10/22.
//

import SwiftUI
import StoreKit

class AppState: ObservableObject {
    @Published var isBannerVisible = true

    init() {
        DispatchQueue.main.async {
            self.checkSubscription()
        }
        
        Task {
            await checkCurrentSubscription()
        }
    }

     func checkCurrentSubscription() async {
         for await result in Transaction.currentEntitlements {
             switch result {
             case .verified(let transaction):
                 // サブスクリプションが有効であれば、必要なプロパティを更新
                 DispatchQueue.main.async {
                     // UI関連の更新はメインスレッドで行う
                     self.updateSubscriptionState(transaction: transaction)
                 }
             case .unverified:
                 // サブスクリプションが確認できない場合の処理
                 break
             }
         }
     }
    
    // サブスクリプションの状態に基づいてAppStateを更新するメソッド
    func updateSubscriptionState(transaction: StoreKit.Transaction) {
        // ここにサブスクリプションの状態に基づいたロジックを実装
        // 例: self.isBannerVisible = !transaction.isSubscribed
        print("test44")
    }
    
    func checkSubscription() {
        Task {
            do {
                let subscribed = try await self.isSubscribed()
//                print("subscribed:\(subscribed)")
                DispatchQueue.main.async {
                    self.isBannerVisible = !subscribed
//                    self.isBannerVisible = !true
                    print("self.isBannerVisible = !subscribed")
//                    print(self.isBannerVisible)
                }
            } catch {
                print("サブスクリプションの確認中にエラー: \(error)")
            }
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .unverified(_, verificationError):
            throw verificationError
        case let .verified(safe):
            return safe
        }
    }

    func getSubscriptionRenewalState(groupID: String) async throws -> [StoreKit.Product.SubscriptionInfo.RenewalState] {
      var results: [StoreKit.Product.SubscriptionInfo.RenewalState] = []
      let statuses = try await Product.SubscriptionInfo.status(for: groupID)
      for status in statuses {
        guard case .verified(let renewalInfo) = status.renewalInfo,
              case .verified(let transaction) = status.transaction
        else {
          continue
        }
        results.append(status.state)
      }
      return results
    }
      
    func isSubscribed() async throws -> Bool {
        var subscriptionGroupIds: [String] = []
        print("isSubscribed_1")
//        print("Transaction.currentEntitlements:\(Transaction.currentEntitlements)")
        for await result in Transaction.currentEntitlements {
            print("isSubscribed_2")
            let transaction = try self.checkVerified(result)
//            print("transaction:\(transaction)")
            guard let groupId = transaction.subscriptionGroupID else { continue }
//            print("groupId:\(groupId)")
            subscriptionGroupIds.append(groupId)
        }

        for groupId in subscriptionGroupIds {
            let renewalStates = try await getSubscriptionRenewalState(groupID: groupId)
//            print("renewalStates:\(renewalStates)")
            for state in renewalStates {
                switch state {
                case .subscribed, .inGracePeriod:
                    print("case subscribed inGracePeriod")
                    return true
                default:
                    print("default")
                    break
                }
            }
        }
        
        return false // サブスクリプションがない、または有効でない場合に false を返す
    }
}

enum SubscribeError: LocalizedError {
    case userCancelled // ユーザーによって購入がキャンセルされた
    case pending // クレジットカードが未設定などの理由で購入が保留された
    case productUnavailable // 指定した商品が無効
    case purchaseNotAllowed // OSの支払い機能が無効化されている
    case failedVerification // トランザクションデータの署名が不正
    case otherError // その他のエラー
}

class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPrivilegeEnabled: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var appState: AppState

    let productIdList = [
        "IT",
    ]

    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIdList)
            DispatchQueue.main.async {
                self.products = products
                print("self.products")
//                print(self.products)
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func enablePrivilege(productId: String) {
        DispatchQueue.main.async {
            self.isPrivilegeEnabled = true
            print("self.isPrivilegeEnabled")
//            print(self.isPrivilegeEnabled)
        }
    }

    func disablePrivilege() {
        DispatchQueue.main.async {
            self.isPrivilegeEnabled = false
            print("self.isPrivilegeEnabled")
//            print(self.isPrivilegeEnabled)
        }
    }
    
    func purchaseProduct(_ product: Product, showAlert: Binding<Bool>) async throws {
        do {
            let transaction = try await purchase(product: product)
            authManager.updatePreFlag(userId: authManager.currentUserId!, userPreFlag: 1){ success in
            }
            DispatchQueue.main.async {
                showAlert.wrappedValue = true
            }
            print("購入が完了しました: \(transaction)")
        } catch {
            print("購入中にエラーが発生しました: \(error)")
        }
    }
}

private func getErrorMessage(error: Error) -> String {
    switch error {
    case SubscribeError.userCancelled:
        print("ユーザーによって購入がキャンセルされました")
        return "ユーザーによって購入がキャンセルされました"
    case SubscribeError.pending:
        print("購入が保留されています")
        return "購入が保留されています"
    case SubscribeError.productUnavailable:
        print("指定した商品が無効です")
        return "指定した商品が無効です"
    case SubscribeError.purchaseNotAllowed:
        print("OSの支払い機能が無効化されています")
        return "OSの支払い機能が無効化されています"
    case SubscribeError.failedVerification:
        return "トランザクションデータの署名が不正です"
        print("トランザクションデータの署名が不正です")
    default:
        print("不明なエラーが発生しました")
        return "不明なエラーが発生しました"
    }
}


class ProductCell: UITableViewCell {
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var displayPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!

    // このプロパティに取得したProductインスタンスをセットする
    var product: Product? {
        didSet {
            print("ProductCell")
            displayNameLabel.text = product?.displayName
            descriptionLabel.text = product?.description
            displayPriceLabel.text = product?.displayPrice
            periodLabel.text = ""
            if let period = product?.subscription?.subscriptionPeriod {
                periodLabel.text = "\(period.value) \(period.unit)"
            }
        }
    }
}

func updateSubscriptionStatus() async {
    var validSubscription: StoreKit.Transaction?
    print("updateSubscriptionStatus1")
    for await verificationResult in Transaction.currentEntitlements {
        print("updateSubscriptionStatus2")
        if case .verified(let transaction) = verificationResult,
           transaction.productType == .autoRenewable && !transaction.isUpgraded {
            print("updateSubscriptionStatus3")
            validSubscription = transaction
        }
    }
}


func purchase(product: Product) async throws -> StoreKit.Transaction  {
    print("purchase1")
    // Product.PurchaseResultの取得
    let purchaseResult: Product.PurchaseResult
    do {
        print("purchase2")
        purchaseResult = try await product.purchase()
    } catch Product.PurchaseError.productUnavailable {
        print("purchase3")
        throw SubscribeError.productUnavailable
    } catch Product.PurchaseError.purchaseNotAllowed {
        print("purchase4")
        throw SubscribeError.purchaseNotAllowed
    } catch {
        print("purchase5")
        throw SubscribeError.otherError
    }

    // VerificationResultの取得
    let verificationResult: VerificationResult<StoreKit.Transaction>
    switch purchaseResult {
    case .success(let result):
        print("purchaseResult1")
        verificationResult = result
    case .userCancelled:
        print("purchaseResult2")
        throw SubscribeError.userCancelled
    case .pending:
        print("purchaseResult3")
        throw SubscribeError.pending
    @unknown default:
        print("purchaseResult4")
        throw SubscribeError.otherError
    }

    // Transactionの取得
    switch verificationResult {
    case .verified(let transaction):
        print("verificationResult1")
        return transaction
    case .unverified:
        print("verificationResult2")
        throw SubscribeError.failedVerification
    }
}

func observeTransactionUpdates() {
    print("observeTransactionUpdates1")
    Task(priority: .background) {
        print("observeTransactionUpdates2")
        for await verificationResult in Transaction.updates {
            print("observeTransactionUpdates3")
            guard case .verified(let transaction) = verificationResult else {
                print("observeTransactionUpdates4")
                continue
            }

            await transaction.finish()
        }
    }
}

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @StateObject var appState = AppState()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager:AudioManager
    @State private var showAlert = false

    var body: some View {
        ScrollView { // Listの代わりにScrollViewを使用
            VStack { // VStackで各要素を縦に並べる
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        audioManager.playCancelSound()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("fontGray"))
                        Text("戻る")
                            .foregroundColor(Color("fontGray"))
                    }
                    .padding(.leading).buttonStyle(.plain)
                    Spacer()
                    Text("プレミアムプラン")
                        .font(.system(size:24))
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        audioManager.playCancelSound()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("fontGray"))
                        Text("戻る")
                            .foregroundColor(Color("fontGray"))
                    }
                    .padding(.leading)
                    .opacity(0)
                }
                .padding(.top)
                HStack{
                    Text("プレミアムプランに加入すると\n下記特典が受けられます")
                        .font(.system(size:22))
                    Spacer()
                }.padding()
                VStack{
                    HStack{
                        Image(systemName: "rectangle.badge.xmark")
                            .resizable()
                            .frame(width:40,height:30)
                            .fontWeight(.bold)
                    Text("広告が非表示になります")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        Spacer()
                    }
                }.padding(.leading)
                    .font(.system(size:16))
                    .padding(.bottom)
                Text("※プレミアムプランはいつでも解約できます")
                        .font(.system(size: 18))
                        .padding(.bottom)
                ForEach(viewModel.products, id: \.id) { product in
                    VStack{ // 各商品情報をVStackで囲む
//                        if product.displayName == "広告非表示" {
                                Button(action: {
                                    Task {
                                        do {
                                            try await AppStore.sync()
                                            try await viewModel.purchaseProduct(product, showAlert: $showAlert)
                                            appState.isBannerVisible = false
                                        } catch {
                                            print("購入処理中にエラーが発生しました: \(error)")
                                        }
                                    }
                                }) {
//                                    Text("サブスクリプション登録")
                                    Image("広告非表示ボタン")
                                        .resizable()
                                        .frame(width:250,height:80)
                                }.shadow(radius: 3)
                                .padding(.bottom)
                    }
                }
                
            Button(action: {
                Task {
                    do {
                        try await AppStore.sync()
                    } catch {
                        print("購入処理中にエラーが発生しました: \(error)")
                    }
                }
            }) {
                Text("購入を復元する")
                    .fontWeight(.semibold)
                    .frame(height:40)
                    .padding(3)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(24)
                    .shadow(radius: 3)
                    .padding(.top)
            }
                HStack{
                    Text("解約時は")
                    NavigationLink(destination: WebView(urlString: "https://support.apple.com/ja-jp/HT202039")) {
                        Text("こちら")
                            .foregroundStyle(Color.blue)
                    }
                    Text("をご参考ください")
                }.font(.system(size: 18))
                    .padding(.top)
                HStack{
                    Spacer()
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Text("利用規約")
                        }
                    }
                    Spacer()
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Text("プライバシーポリシー")
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .foregroundStyle(Color.blue)
            }
            .onAppear {
                Task {
                    await viewModel.loadProducts()
                }
            }
        }
        .foregroundColor(Color("fontGray"))
        .frame(maxHeight:.infinity)
        .background(Color("Color2"))
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(audioManager: AudioManager())
    }
}
