//
//  AccountLinkView.swift
//  it
//
//  匿名アカウントを Apple ID に連携し、機種変更や再インストール後もデータを引き継げるようにする。
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// Sign in with Apple のリクエストを1回実行し、Firebase 用の資格情報を返す。
final class AppleSignInRequest: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    struct Result {
        let credential: OAuthCredential
        let authorizationCode: String?
    }

    private var currentNonce: String?
    private var completion: ((Swift.Result<Result, Error>) -> Void)?
    /// ASAuthorizationController は delegate を弱参照するため、完了まで自身を保持する。
    private var retainedSelf: AppleSignInRequest?

    func start(completion: @escaping (Swift.Result<Result, Error>) -> Void) {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        self.completion = completion
        retainedSelf = self

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let tokenData = appleCredential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            finish(.failure(AccountLinkError.invalidAppleCredential))
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        let authorizationCode = appleCredential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
        finish(.success(Result(credential: credential, authorizationCode: authorizationCode)))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        finish(.failure(error))
    }

    private func finish(_ result: Swift.Result<Result, Error>) {
        let completion = completion
        self.completion = nil
        retainedSelf = nil
        DispatchQueue.main.async {
            completion?(result)
        }
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            guard status == errSecSuccess else { continue }
            if random < charset.count * (256 / charset.count) {
                result.append(charset[Int(random) % charset.count])
                remaining -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

enum AccountLinkError: LocalizedError {
    case invalidAppleCredential
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .invalidAppleCredential:
            return "Apple ID の情報を取得できませんでした。もう一度お試しください。"
        case .notSignedIn:
            return "アカウント情報を確認できませんでした。通信環境を確認してもう一度お試しください。"
        }
    }
}

enum AppleAccountService {
    static var isLinked: Bool {
        Auth.auth().currentUser?.providerData.contains { $0.providerID == AuthProviderID.apple.rawValue } ?? false
    }

    enum LinkOutcome {
        case linked
        /// この Apple ID には既に別のアカウント（以前の端末のデータ）がある。
        case existingAccountFound(AuthCredential)
        case cancelled
    }

    /// 現在の匿名アカウントに Apple ID を連携する。
    static func link(completion: @escaping (Swift.Result<LinkOutcome, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AccountLinkError.notSignedIn))
            return
        }

        AppleSignInRequest().start { result in
            switch result {
            case .failure(let error):
                if (error as? ASAuthorizationError)?.code == .canceled {
                    completion(.success(.cancelled))
                } else {
                    completion(.failure(error))
                }
            case .success(let apple):
                user.link(with: apple.credential) { _, error in
                    DispatchQueue.main.async {
                        if let error = error as NSError? {
                            if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue,
                               let updated = error.userInfo[AuthErrors.userInfoUpdatedCredentialKey] as? AuthCredential {
                                completion(.success(.existingAccountFound(updated)))
                            } else {
                                completion(.failure(error))
                            }
                            return
                        }
                        AuthManager.shared.user = Auth.auth().currentUser
                        completion(.success(.linked))
                    }
                }
            }
        }
    }

    /// Apple ID に紐づく既存アカウントへ切り替える（現在の端末のデータは使われなくなる）。
    static func restore(with credential: AuthCredential, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            DispatchQueue.main.async {
                if let result {
                    AuthManager.shared.user = result.user
                }
                completion(error)
            }
        }
    }

    /// アカウント削除時に、App Store の要件に従って Apple のトークンを失効させる。
    /// Apple ID を連携していないユーザーは何もしない。
    static func revokeIfLinked(completion: @escaping (Error?) -> Void) {
        guard isLinked else {
            completion(nil)
            return
        }

        AppleSignInRequest().start { result in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let apple):
                guard let code = apple.authorizationCode,
                      let user = Auth.auth().currentUser else {
                    completion(AccountLinkError.invalidAppleCredential)
                    return
                }
                // 直後に Firebase のアカウント自体も削除できるよう、再認証しておく。
                user.reauthenticate(with: apple.credential) { _, error in
                    if let error {
                        DispatchQueue.main.async { completion(error) }
                        return
                    }
                    Auth.auth().revokeToken(withAuthorizationCode: code) { error in
                        completion(error)
                    }
                }
            }
        }
    }
}

struct AccountLinkView: View {
    @State private var isLinked = AppleAccountService.isLinked
    @State private var isWorking = false
    @State private var pendingRestoreCredential: AuthCredential?
    @State private var alertMessage: String?
    @State private var didRestore = false
    @EnvironmentObject private var connectivity: ConnectivityMonitor

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: isLinked ? "checkmark.shield.fill" : "icloud.and.arrow.up.fill")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundColor(isLinked ? .green : .blue)
                    .padding(.top, 32)

                Text(isLinked ? "Apple ID と連携済みです" : "データを Apple ID に保存")
                    .font(.system(size: 22, weight: .bold))

                Text(isLinked
                     ? "機種変更や再インストールをしても、同じ Apple ID でサインインすればレベル・おとも・コインなどを引き継げます。"
                     : "今のままだと、機種変更やアプリの削除でレベル・おとも・コイン・フレンドなどのデータが消えてしまいます。Apple ID と連携すると、別の端末でも同じデータで遊べます。")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if !isLinked {
                    Button(action: link) {
                        HStack(spacing: 8) {
                            if isWorking {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "applelogo")
                            }
                            Text("Appleでサインインして連携")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(isWorking || !connectivity.isConnected)
                    .padding(.horizontal, 24)

                    Text("以前の端末で連携済みの場合は、同じボタンからデータを復元できます。")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if !connectivity.isConnected {
                        Text("連携にはインターネット接続が必要です")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("データの引き継ぎ")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "以前のデータが見つかりました",
            isPresented: Binding(
                get: { pendingRestoreCredential != nil },
                set: { if !$0 { pendingRestoreCredential = nil } }
            )
        ) {
            Button("以前のデータに切り替える", role: .destructive) {
                if let credential = pendingRestoreCredential {
                    restore(with: credential)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この Apple ID には以前の端末のデータが保存されています。切り替えると、この端末で今遊んでいるデータは使えなくなります。")
        }
        .alert(
            didRestore ? "データを復元しました" : "お知らせ",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func link() {
        isWorking = true
        AppleAccountService.link { result in
            isWorking = false
            switch result {
            case .success(.linked):
                isLinked = true
                alertMessage = "Apple ID と連携しました。これで機種変更をしてもデータを引き継げます。"
            case .success(.existingAccountFound(let credential)):
                pendingRestoreCredential = credential
            case .success(.cancelled):
                break
            case .failure(let error):
                alertMessage = "連携に失敗しました。\n\(error.localizedDescription)"
            }
        }
    }

    private func restore(with credential: AuthCredential) {
        isWorking = true
        AppleAccountService.restore(with: credential) { error in
            isWorking = false
            if let error {
                alertMessage = "復元に失敗しました。\n\(error.localizedDescription)"
                return
            }
            isLinked = true
            didRestore = true
            // 各画面がキャッシュしている旧アカウントの情報を確実に読み直すため、再起動を案内する。
            alertMessage = "以前のデータに切り替えました。すべての情報を反映するため、アプリを一度終了してから開き直してください。"
        }
    }
}
