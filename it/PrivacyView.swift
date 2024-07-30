//
//  PrivacyView.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/27.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("プライバシーポリシー")
                        .font(.title)
                        .bold()
                        .padding(.top)
                    
                    Text("個人情報の利用目的")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    
                    Text("当サイトでは、お問い合わせや記事へのコメントの際、名前やメールアドレス等の個人情報を入力いただく場合がございます。 取得した個人情報は、お問い合わせに対する回答や必要な情報を電子メールなどでご連絡する場合に利用させていただくものであり、これらの目的以外では利用いたしません。")
                        .font(.body)
                }
                Group {

                    
                    Text("広告について")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    Text("当サイトでは、第三者配信の広告サービス（Googleアドセンス）を利用しており、ユーザーの興味に応じた商品やサービスの広告を表示するため、クッキー（Cookie）を使用しております。 クッキーを使用することで当サイトはお客様のコンピュータを識別できるようになりますが、お客様個人を特定できるものではありません。Cookieを無効にする方法やGoogleアドセンスに関する詳細は「広告 – ポリシーと規約 – Google」をご確認ください。")
                        .font(.body)
                    
                    Text("アクセス解析ツールについて")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    Text("当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を利用しています。 このGoogleアナリティクスはトラフィックデータの収集のためにクッキー（Cookie）を使用しております。 トラフィックデータは匿名で収集されており、個人を特定するものではありません。")
                        .font(.body)
                    
                    Text("免責事項")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    Text("当サイトからのリンクやバナーなどで移動したサイトで提供される情報、サービス等について一切の責任を負いません。 また当サイトのコンテンツ・情報について、できる限り正確な情報を提供するように努めておりますが、正確性や安全性を保証するものではありません。情報が古くなっていることもございます。 当サイトに掲載された内容によって生じた損害等の一切の責任を負いかねますのでご了承ください。")
                        .font(.body)
                    
                    Text("著作権について")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    Text("当サイトで掲載している文章や画像などにつきましては、無断転載することを禁止します。 当サイトは著作権や肖像権の侵害を目的としたものではありません。著作権や肖像権に関して問題がございましたら、お問い合わせフォームよりご連絡ください。迅速に対応いたします。")
                        .font(.body)
                    
                    Text("リンクについて")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    Text("当サイトは基本的にリンクフリーです。リンクを行う場合の許可や連絡は不要です。 ただし、インラインフレームの使用や画像の直リンクはご遠慮ください。")
                        .font(.body)
                }
            }
                .padding()
        }
        .navigationBarTitle("ライセンス", displayMode: .inline)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
