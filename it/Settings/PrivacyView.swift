//
//  PrivacyView.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/27.
//

import SwiftUI

struct PrivacyView: View {
    private let sections: [(title: String, body: String)] = [
        ("個人情報の利用目的",
         "当サイトでは、お問い合わせや記事へのコメントの際、名前やメールアドレス等の個人情報を入力いただく場合がございます。 取得した個人情報は、お問い合わせに対する回答や必要な情報を電子メールなどでご連絡する場合に利用させていただくものであり、これらの目的以外では利用いたしません。"),
        ("広告について",
         "当サイトでは、第三者配信の広告サービス（Googleアドセンス）を利用しており、ユーザーの興味に応じた商品やサービスの広告を表示するため、クッキー（Cookie）を使用しております。 クッキーを使用することで当サイトはお客様のコンピュータを識別できるようになりますが、お客様個人を特定できるものではありません。Cookieを無効にする方法やGoogleアドセンスに関する詳細は「広告 – ポリシーと規約 – Google」をご確認ください。"),
        ("アクセス解析ツールについて",
         "当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を利用しています。 このGoogleアナリティクスはトラフィックデータの収集のためにクッキー（Cookie）を使用しております。 トラフィックデータは匿名で収集されており、個人を特定するものではありません。"),
        ("免責事項",
         "当サイトからのリンクやバナーなどで移動したサイトで提供される情報、サービス等について一切の責任を負いません。 また当サイトのコンテンツ・情報について、できる限り正確な情報を提供するように努めておりますが、正確性や安全性を保証するものではありません。情報が古くなっていることもございます。 当サイトに掲載された内容によって生じた損害等の一切の責任を負いかねますのでご了承ください。"),
        ("著作権について",
         "当サイトで掲載している文章や画像などにつきましては、無断転載することを禁止します。 当サイトは著作権や肖像権の侵害を目的としたものではありません。著作権や肖像権に関して問題がございましたら、お問い合わせフォームよりご連絡ください。迅速に対応いたします。"),
        ("リンクについて",
         "当サイトは基本的にリンクフリーです。リンクを行う場合の許可や連絡は不要です。 ただし、インラインフレームの使用や画像の直リンクはご遠慮ください。")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ヘッダー
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.orange)
                    }

                    Text("プライバシーポリシー")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 8)

                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: 4, height: 16)

                            Text(section.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }

                        Text(section.body)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitle("プライバシーポリシー", displayMode: .inline)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
