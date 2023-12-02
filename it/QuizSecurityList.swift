//
//  QuizSecurityList.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/06.
//

import SwiftUI

struct QuizSecurityList: View {
    @Binding var isPresenting: Bool
    let QuizSecurityList: [QuizQuestion] = [
        QuizQuestion(
            question: "コンピュータウイルスがメールに添付されているファイルを開くことで感染するタイプのウイルスは何と呼ばれるか？",
            choices: [
                "ワーム",
                "トロイの木馬",
                "メールウイルス",
                "ランサムウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "メールウイルスは、メールの添付ファイルを通じて拡散するウイルスです。"
        ),

        QuizQuestion(
            question: "未承認のアクセスからシステムを保護するためのソフトウェアは何と呼ばれるか？",
            choices: [
                "アンチウイルスソフトウェア",
                "ファイアウォール",
                "マルウェア",
                "スパイウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "ファイアウォールは、不正なアクセスや攻撃からシステムを保護するソフトウェアまたはハードウェアです。"
        ),

        QuizQuestion(
            question: "ウェブサイトのセキュリティを強化するためのプロトコルは何か？",
            choices: [
                "HTTP",
                "HTTPS",
                "FTP",
                "SMTP"
            ],
            correctAnswerIndex: 1,
            explanation: "HTTPSは、ウェブサイトのセキュリティを強化するためのプロトコルで、通信を暗号化します。"
        ),

        QuizQuestion(
            question: "フィッシング攻撃が一般的に行われるプラットフォームは何か？",
            choices: [
                "メール",
                "ポスター",
                "手紙",
                "ラジオ"
            ],
            correctAnswerIndex: 0,
            explanation: "フィッシング攻撃は通常、偽のメールを通じて行われ、受信者を詐欺的なウェブサイトに誘導します。"
        ),

        QuizQuestion(
            question: "パスワードを安全に保つための一般的なアドバイスは何か？",
            choices: [
                "同じパスワードを使用する",
                "パスワードに個人情報を使用する",
                "パスワードを定期的に変更する",
                "パスワードを書いて財布に入れる"
            ],
            correctAnswerIndex: 2,
            explanation: "パスワードを定期的に変更することは、アカウントのセキュリティを高める一般的なアドバイスです。"
        ),
        QuizQuestion(
            question: "2要素認証では、通常、何を使用しますか？",
            choices: [
                "何かを知っているものと何かを持っているもの",
                "何かを知っているものと何かを感じるもの",
                "何かを持っているものと何かを感じるもの",
                "何かを知っているものと何かを食べるもの"
            ],
            correctAnswerIndex: 0,
            explanation: "2要素認証では、「何かを知っているもの」（例：パスワード）と「何かを持っているもの」（例：スマートフォン）を使用します。"
        ),

        QuizQuestion(
            question: "セキュリティの3つの主要な要素は何ですか？",
            choices: [
                "機密性、完全性、可用性",
                "機密性、可用性、非再び認証",
                "完全性、非再び認証、機密性",
                "可用性、非再び認証、完全性"
            ],
            correctAnswerIndex: 0,
            explanation: "セキュリティの3つの主要な要素は、機密性、完全性、および可用性（CIAトライアドとも呼ばれます）です。"
        ),

        QuizQuestion(
            question: "次のうち、最も強力なパスワードはどれですか？",
            choices: [
                "123456",
                "password",
                "Qw3rT!yU1oP$",
                "abcdef"
            ],
            correctAnswerIndex: 2,
            explanation: "Qw3rT!yU1oP$は、大文字、小文字、数字、特殊文字を含む複雑なパスワードであり、最も強力と考えられます。"
        ),

        QuizQuestion(
            question: "VPNは何の略ですか？",
            choices: [
                "Virtual Private Network",
                "Vivid Protocol Node",
                "Virtual Public Node",
                "Vivid Private Network"
            ],
            correctAnswerIndex: 0,
            explanation: "VPNはVirtual Private Networkの略で、インターネット上で仮想的なプライベートネットワーク接続を作成します。"
        ),

        QuizQuestion(
            question: "次のうち、ネットワーク攻撃の一種である「中間者攻撃」は何ですか？",
            choices: [
                "攻撃者が通信を傍受してデータを盗む",
                "攻撃者がネットワークに無限のデータを送り込む",
                "攻撃者がネットワークに偽のアクセスポイントを設置する",
                "攻撃者がユーザーのパスワードを推測する"
            ],
            correctAnswerIndex: 0,
            explanation: "中間者攻撃は、攻撃者が2者間の通信を傍受し、時にはそのデータを改ざんするタイプの攻撃です。"
        ),
        QuizQuestion(
            question: "どのセキュリティプロトコルがWi-Fiネットワークを保護しますか？",
            choices: [
                "HTTPS",
                "WPA3",
                "SSL",
                "TLS"
            ],
            correctAnswerIndex: 1,
            explanation: "WPA3（Wi-Fi Protected Access 3）は、Wi-Fiネットワークを保護するためのセキュリティプロトコルです。"
        ),

        QuizQuestion(
            question: "次のうち、最も安全なパスワード管理の方法は何ですか？",
            choices: [
                "すべてのパスワードを紙に書く",
                "1つの強力なパスワードをすべてのアカウントで使用する",
                "パスワードマネージャーを使用する",
                "パスワードをメールで送信する"
            ],
            correctAnswerIndex: 2,
            explanation: "パスワードマネージャーを使用することは、多くの異なる強力なパスワードを安全に管理する効果的な方法です。"
        ),

        QuizQuestion(
            question: "サイバーセキュリティの「ソーシャルエンジニアリング」攻撃とは何ですか？",
            choices: [
                "ネットワークを物理的に破壊する",
                "ソフトウェアの脆弱性を利用する",
                "人間の心理を利用して情報を盗む",
                "コンピューターウイルスを作成する"
            ],
            correctAnswerIndex: 2,
            explanation: "ソーシャルエンジニアリングは、攻撃者が人間の心理を利用して機密情報を盗むタイプの攻撃です。"
        ),

        QuizQuestion(
            question: "「DDoS攻撃」とは何を意味しますか？",
            choices: [
                "データベース破壊攻撃",
                "分散サービス拒否攻撃",
                "データデリート攻撃",
                "ディレクトリ削除攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "DDoS攻撃（Distributed Denial of Service attack）は、多数のシステムを利用してターゲットのシステムやネットワークリソースに対してオーバーロードを引き起こし、サービスを利用できなくする攻撃です。"
        ),

        QuizQuestion(
            question: "「エンドポイントセキュリティ」は何を保護しますか？",
            choices: [
                "ネットワークのエッジ",
                "ユーザーのデバイス",
                "データベース",
                "サーバー"
            ],
            correctAnswerIndex: 1,
            explanation: "エンドポイントセキュリティは、ユーザーのデバイス（エンドポイント）を保護し、これらのデバイスがネットワークに安全にアクセスできるようにします。"
        ),
        QuizQuestion(
            question: "「マルウェア」とは何の略語ですか？",
            choices: [
                "Malicious Software",
                "Multiple Software",
                "Mail Software",
                "Manual Software"
            ],
            correctAnswerIndex: 0,
            explanation: "「マルウェア」は「Malicious Software」の略で、悪意を持って作成され、コンピューターシステムを傷つけるソフトウェアを指します。"
        ),

        QuizQuestion(
            question: "次のうち、パスワード攻撃の一種である「ブルートフォース攻撃」とは何ですか？",
            choices: [
                "すべての可能なパスワードの組み合わせを試す攻撃",
                "ユーザーに偽のログインページを表示する攻撃",
                "ユーザーからパスワードを直接聞き出す攻撃",
                "ユーザーのキーストロークを記録する攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "ブルートフォース攻撃は、攻撃者がすべての可能なパスワードの組み合わせを試してアカウントにアクセスしようとする攻撃です。"
        ),

        QuizQuestion(
            question: "「セキュリティポリシー」の主な目的は何ですか？",
            choices: [
                "組織のセキュリティ要件を定義し、手順を確立する",
                "組織の利益を最大化する",
                "組織のマーケティング戦略を計画する",
                "組織のITコストを削減する"
            ],
            correctAnswerIndex: 0,
            explanation: "セキュリティポリシーの主な目的は、組織のセキュリティ要件を定義し、セキュリティ手順を確立することです。"
        ),

        QuizQuestion(
            question: "「バックドア」攻撃とは何ですか？",
            choices: [
                "正規の認証を迂回してシステムにアクセスする手法",
                "システムのフロントエンドを攻撃する手法",
                "システムを物理的に破壊する手法",
                "システムのデータを公開する手法"
            ],
            correctAnswerIndex: 0,
            explanation: "「バックドア」攻撃は、攻撃者が正規の認証プロセスを迂回してシステムにアクセスする手法を指します。"
        ),

        QuizQuestion(
            question: "「暗号化」の主な目的は何ですか？",
            choices: [
                "データのサイズを減らす",
                "データを保護し、不正なアクセスから安全にする",
                "データをコピーする",
                "データを削除する"
            ],
            correctAnswerIndex: 1,
            explanation: "「暗号化」の主な目的は、データを保護し、不正なアクセスや漏洩から安全にすることです。"
        ),
        QuizQuestion(
            question: "「フィッシング」攻撃とは何ですか？",
            choices: [
                "ユーザーを欺いて機密情報を盗む試み",
                "ネットワークに過剰なトラフィックを送り込む攻撃",
                "システムの脆弱性を利用して侵入する攻撃",
                "ウイルスをメール添付ファイルで送る攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "「フィッシング」は、攻撃者がユーザーを欺いて機密情報（例：ユーザー名やパスワード）を盗む試みを指します。"
        ),

        QuizQuestion(
            question: "「Ransomware（ランサムウェア）」攻撃とは何ですか？",
            choices: [
                "データを暗号化し、解除のための身代金を要求する攻撃",
                "ユーザーを欺いて個人情報を盗む攻撃",
                "ネットワークに過剰なトラフィックを送り込む攻撃",
                "システムの脆弱性を利用して侵入する攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "「Ransomware」攻撃は、攻撃者がユーザーのデータを暗号化し、その解除のための身代金を要求するタイプのマルウェア攻撃です。"
        ),

        QuizQuestion(
            question: "セキュリティの「ホワイトハット」とは何ですか？",
            choices: [
                "システムを破壊するハッカー",
                "セキュリティホールを悪用するハッカー",
                "セキュリティを向上させるためにハッキングするエキスパート",
                "ウイルスを作成するハッカー"
            ],
            correctAnswerIndex: 2,
            explanation: "「ホワイトハット」は、セキュリティを向上させるためにハッキングを行うエキスパートを指します。彼らは、システムの脆弱性を発見し、それを修正または報告します。"
        ),

        QuizQuestion(
            question: "「ファイアウォール」の主な機能は何ですか？",
            choices: [
                "不正なネットワークトラフィックをブロックする",
                "ウイルスを作成する",
                "データを暗号化する",
                "ネットワークのスピードを向上させる"
            ],
            correctAnswerIndex: 0,
            explanation: "「ファイアウォール」の主な機能は、不正なネットワークトラフィックをブロックし、許可されたトラフィックのみを通過させることです。"
        ),

        QuizQuestion(
            question: "「セキュアソケットレイヤー（SSL）」の主な目的は何ですか？",
            choices: [
                "ウェブトラフィックを暗号化する",
                "ウェブトラフィックを高速化する",
                "ウェブトラフィックをブロックする",
                "ウェブトラフィックをリダイレクトする"
            ],
            correctAnswerIndex: 0,
            explanation: "「セキュアソケットレイヤー（SSL）」の主な目的は、ウェブトラフィックを暗号化し、データの安全な送受信を可能にすることです。"
        ),
        QuizQuestion(
            question: "ゼロデイ攻撃とは何ですか？",
            choices: [
                "未知の脆弱性を利用した攻撃",
                "メールを利用した攻撃",
                "ウェブサイトをクローンする攻撃",
                "パスワードを総当たりで攻撃する手法"
            ],
            correctAnswerIndex: 0,
            explanation: "ゼロデイ攻撃は、開発者自体がまだ認識していない脆弱性を悪用した攻撃を指します。"
        ),

        QuizQuestion(
            question: "マルチファクター認証とは何ですか？",
            choices: [
                "パスワードのみを使用した認証",
                "2つ以上の認証要素を使用した認証",
                "フェイスIDのみを使用した認証",
                "指紋認証のみを使用した認証"
            ],
            correctAnswerIndex: 1,
            explanation: "マルチファクター認証は、2つ以上の異なるタイプの認証要素（何かを知っているもの、何かを持っているもの、何かであるもの）を使用してアクセスを許可します。"
        ),

        QuizQuestion(
            question: "ハニーポットとは何ですか？",
            choices: [
                "ハッカーを引き寄せてトラップにかけるシステム",
                "ウイルスを検出するソフトウェア",
                "データを暗号化する技術",
                "ファイアウォールを強化するアプリケーション"
            ],
            correctAnswerIndex: 0,
            explanation: "ハニーポットは、攻撃者を誘引し、その手法を研究したり、システムを守ったりするための意図的に脆弱なシステムまたはデータです。"
        ),

        QuizQuestion(
            question: "ディープパケットインスペクション（DPI）の主な用途は何ですか？",
            choices: [
                "パケットのペイロードを解析して通信を監視する",
                "パケットを高速転送する",
                "パケットを暗号化する",
                "パケットを削除する"
            ],
            correctAnswerIndex: 0,
            explanation: "ディープパケットインスペクションは、ネットワークパケットのペイロード（実際のデータコンテンツ）を解析し、フィルタリング、ルーティング、または通信の監視に使用します。"
        ),

        QuizQuestion(
            question: "サイバーセキュリティの「ブラックハット」とは何ですか？",
            choices: [
                "セキュリティを向上させるためにハッキングするエキスパート",
                "システムを破壊または悪用する目的でハッキングする人物",
                "セキュリティソフトウェアを開発するエンジニア",
                "コンピュータネットワークを設計するエキスパート"
            ],
            correctAnswerIndex: 1,
            explanation: "ブラックハットハッカーは、個人的な利益や悪意を持ってシステムを攻撃し、データを盗んだり、システムを破壊したりします。"
        ),
        QuizQuestion(
            question: "「サイバーセキュリティ」の主な目的は何ですか？",
            choices: [
                "データの保護と情報システムのセキュリティの確保",
                "データの共有とアクセスの容易化",
                "システムのパフォーマンスを向上させる",
                "新しいソフトウェアを開発する"
            ],
            correctAnswerIndex: 0,
            explanation: "「サイバーセキュリティ」の主な目的は、データの保護と情報システムのセキュリティを確保することです。"
        ),

//        QuizQuestion(
//            question: "「ボットネット」とは何ですか？",
//            choices: [
//                "インターネットに接続されたデバイスのネットワーク",
//                "悪意のあるアクターによって制御されるコンピュータのネットワーク",
//                "セキュアなウェブブラウジングを提供するネットワーク",
//                "高速なインターネット接続を提供するネットワーク"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "「ボットネット」は、悪意のあるアクター（ハッカー）によって制御され、しばしば不正な活動（例：DDoS攻撃、スパム送信）に利用されるコンピュータのネットワークを指します。"
//        ),

        QuizQuestion(
            question: "「2FA」は何の略語ですか？",
            choices: [
                "2 Factor Authentication",
                "2 Frequency Authentication",
                "2 Form Authentication",
                "2 Frame Authentication"
            ],
            correctAnswerIndex: 0,
            explanation: "「2FA」は「2 Factor Authentication」の略で、通常、何かを「知っている」もの（パスワードなど）と何かを「持っている」もの（スマートフォンなど）を使用した認証方法を指します。"
        ),

        QuizQuestion(
            question: "「VPN」を使用する主な理由は何ですか？",
            choices: [
                "インターネット速度を向上させる",
                "プライバシーを保護し、安全な通信を提供する",
                "コンピュータのパフォーマンスを向上させる",
                "ウイルスから保護する"
            ],
            correctAnswerIndex: 1,
            explanation: "「VPN」（Virtual Private Network）の主な使用理由は、プライバシーを保護し、安全な通信を提供することです。VPNは、インターネット接続を暗号化し、ユーザーのオンライン活動を保護します。"
        ),

        QuizQuestion(
            question: "「暗号化」のプロセスで使用される「キー」とは何ですか？",
            choices: [
                "データをロック/アンロックするためのコードまたはパスワード",
                "データを保存するためのデバイス",
                "データを送信するためのツール",
                "データを分析するためのアルゴリズム"
            ],
            correctAnswerIndex: 0,
            explanation: "「キー」は、暗号化のプロセスで使用され、データを「ロック」（暗号化）および「アンロック」（復号）するためのコードまたはパスワードを指します。キーは、データのセキュリティを保護するために極めて重要です。"
        ),
        QuizQuestion(
            question: "「ブルートフォース攻撃」を防ぐための一般的な方法は何ですか？",
            choices: [
                "強力なパスワードを使用する",
                "同じパスワードを使用する",
                "パスワードを共有する",
                "パスワードを書いて机の上に置く"
            ],
            correctAnswerIndex: 0,
            explanation: "強力なパスワード（複雑で、推測が難しいもの）を使用することは、ブルートフォース攻撃（総当たり攻撃）を防ぐ基本的な方法です。"
        ),

        QuizQuestion(
            question: "「ワーム」はどのようにコンピュータシステムに影響を与えますか？",
            choices: [
                "システムを自己複製して拡散する",
                "システムを冷却する",
                "システムの速度を向上させる",
                "システムを物理的に破壊する"
            ],
            correctAnswerIndex: 0,
            explanation: "コンピュータワームは、ネットワークを通じてシステム間で自己複製し、拡散するマルウェアの一種です。"
        ),

        QuizQuestion(
            question: "「フィッシング」攻撃の一般的な目標は何ですか？",
            choices: [
                "ユーザーから機密情報を盗む",
                "ユーザーにギフトを提供する",
                "ユーザーのコンピュータの速度を向上させる",
                "ユーザーに友情を提供する"
            ],
            correctAnswerIndex: 0,
            explanation: "フィッシング攻撃の主な目的は、ユーザーを欺いて機密情報（例えば、ログイン情報、クレジットカード情報など）を盗むことです。"
        ),

        QuizQuestion(
            question: "「セキュリティパッチ」は何を目的としていますか？",
            choices: [
                "ソフトウェアの新機能を追加する",
                "ソフトウェアの脆弱性を修正する",
                "ソフトウェアのパフォーマンスを低下させる",
                "ソフトウェアをアンインストールする"
            ],
            correctAnswerIndex: 1,
            explanation: "セキュリティパッチは、ソフトウェアの脆弱性を修正し、セキュリティを強化することを目的としています。"
        ),
        QuizQuestion(
            question: "「VPN」の主要な利用目的は何ですか？",
            choices: [
                "インターネットブラウジングの安全性とプライバシーを高める",
                "コンピュータの処理速度を向上させる",
                "新しいソフトウェアをインストールする",
                "コンピュータのグラフィックを向上させる"
            ],
            correctAnswerIndex: 0,
            explanation: "VPN（Virtual Private Network）は、インターネットブラウジングの安全性とプライバシーを高めるために使用されます。"
        ),

        QuizQuestion(
            question: "「2FA」は何の略語ですか？",
            choices: [
                "2 Factor Authentication",
                "2 Frequency Authentication",
                "2 Form Authentication",
                "2 Frame Authentication"
            ],
            correctAnswerIndex: 0,
            explanation: "2FAは、「2 Factor Authentication」の略で、二つの異なるタイプの認証要素を使用してアクセスを確認します。"
        ),

        QuizQuestion(
            question: "「サイバーセキュリティ」における「エンドポイント」は何を指しますか？",
            choices: [
                "ネットワークの最終的な目的地",
                "ネットワークに接続されているデバイス",
                "ネットワークの主要なルーター",
                "ネットワークのデータセンター"
            ],
            correctAnswerIndex: 1,
            explanation: "エンドポイントは、ネットワークに接続されているデバイス（コンピュータ、スマートフォンなど）を指します。"
        ),

        QuizQuestion(
            question: "「暗号化」されたデータを元に戻すプロセスを何と呼びますか？",
            choices: [
                "デコード",
                "デクリプト",
                "アンロック",
                "デコンパイル"
            ],
            correctAnswerIndex: 1,
            explanation: "「暗号化」されたデータを元に戻すプロセスは「デクリプト（復号）」と呼ばれます。"
        ),

        QuizQuestion(
            question: "「IoT」デバイスは何ですか？",
            choices: [
                "Internet of Thingsのデバイス",
                "Internal Operating Technologyのデバイス",
                "Instant Online Transferのデバイス",
                "Intelligent Operating Terminalのデバイス"
            ],
            correctAnswerIndex: 0,
            explanation: "「IoT」デバイスは、「Internet of Things」のデバイスで、インターネットに接続され、データを送受信できる物理的なオブジェクトを指します。"
        ),
        QuizQuestion(
            question: "「ボットネット」とは何ですか？",
            choices: [
                "インターネットに接続されたロボット",
                "マルウェアに感染し、攻撃者に制御されるコンピュータネットワーク",
                "セキュアなインターネットネットワーク",
                "高速なインターネット接続"
            ],
            correctAnswerIndex: 1,
            explanation: "ボットネットは、マルウェアに感染し、攻撃者に制御されるコンピュータネットワークを指します。"
        ),

        QuizQuestion(
            question: "「セキュリティパッチ」とは何ですか？",
            choices: [
                "新しいセキュリティ機能を追加するソフトウェアアップデート",
                "セキュリティの脆弱性を修正するソフトウェアアップデート",
                "セキュリティシステムを無効にするソフトウェア",
                "セキュリティシステムをバイパスするハードウェアデバイス"
            ],
            correctAnswerIndex: 1,
            explanation: "セキュリティパッチは、ソフトウェアのセキュリティの脆弱性を修正するアップデートを指します。"
        ),

        QuizQuestion(
            question: "「フィッシング」攻撃の一般的な手法は何ですか？",
            choices: [
                "ユーザーに偽のウェブサイトやメールを送り、情報を盗む",
                "ユーザーのコンピュータにマルウェアをインストールする",
                "ユーザーのコンピュータを物理的に盗む",
                "ユーザーのコンピュータをハッキングして情報を盗む"
            ],
            correctAnswerIndex: 0,
            explanation: "フィッシング攻撃では、攻撃者は通常、ユーザーに偽のウェブサイトやメールを送り、信用情報やログイン情報などを盗みます。"
        ),

        QuizQuestion(
            question: "「ホワイトリスト」とは何ですか？",
            choices: [
                "許可されていないアプリケーションやユーザーのリスト",
                "許可されているアプリケーションやユーザーのリスト",
                "危険なウェブサイトのリスト",
                "安全なウェブサイトのリスト"
            ],
            correctAnswerIndex: 1,
            explanation: "ホワイトリストは、システムにアクセスが許可されているアプリケーションやユーザーのリストを指します。"
        ),

        QuizQuestion(
            question: "「ブルートフォース攻撃」の対策として効果的なのは何ですか？",
            choices: [
                "パスワードの複雑化",
                "アンチウイルスソフトウェアのインストール",
                "ファイアウォールの強化",
                "セキュリティパッチの適用"
            ],
            correctAnswerIndex: 0,
            explanation: "ブルートフォース攻撃の対策として特に効果的なのは、パスワードの複雑化（長さ、大文字・小文字の使用、数字や特殊文字の使用など）です。"
        ),
        QuizQuestion(
            question: "「正規化」の主な目的は何ですか？",
            choices: [
                "データの重複を減らし、データの整合性を保つ",
                "データベースのサイズを増やす",
                "データベースのパフォーマンスを低下させる",
                "データベースのセキュリティを弱める"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化は、データの重複を減らし、データの整合性を保つためのプロセスです。"
        ),

        QuizQuestion(
            question: "「インデックス」の主な利点は何ですか？",
            choices: [
                "クエリのパフォーマンスを向上させる",
                "データベースのサイズを増やす",
                "データベースのセキュリティを弱める",
                "データの重複を増やす"
            ],
            correctAnswerIndex: 0,
            explanation: "インデックスは、データベース内のデータの検索速度を向上させ、クエリのパフォーマンスを向上させるために使用されます。"
        ),

        QuizQuestion(
            question: "「リレーショナルデータベース」の特徴は何ですか？",
            choices: [
                "データをテーブル形式で保存する",
                "データを非構造化フォーマットで保存する",
                "データを単一の大きなストレージに保存する",
                "データをキーバリューストアに保存する"
            ],
            correctAnswerIndex: 0,
            explanation: "リレーショナルデータベースは、データをテーブル形式で保存し、テーブル間の関係を使用してデータを関連付けます。"
        ),

        QuizQuestion(
            question: "「プライマリキー」の役割は何ですか？",
            choices: [
                "テーブルの各レコードを一意に識別する",
                "テーブルのすべてのレコードを同じにする",
                "テーブルのデータを暗号化する",
                "テーブルのデータを圧縮する"
            ],
            correctAnswerIndex: 0,
            explanation: "プライマリキーは、テーブルの各レコードを一意に識別するための一つまたは複数のフィールドです。"
        ),

        QuizQuestion(
            question: "「OLAP」は何の略語ですか？",
            choices: [
                "Online Analytical Processing",
                "Offline Analytical Processing",
                "Online Application Processing",
                "Offline Application Processing"
            ],
            correctAnswerIndex: 0,
            explanation: "OLAPは「Online Analytical Processing」の略で、複雑なクエリを高速に実行するためのデータベースの処理方式を指します。"
        )


    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared


    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizSecurityList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .security, authManager: authManager,audioManager: audioManager,isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizSecurityList_Previews: PreviewProvider {
    static var previews: some View {
        QuizSecurityList(isPresenting: .constant(false))
    }
}
