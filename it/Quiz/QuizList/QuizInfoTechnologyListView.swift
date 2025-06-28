//
//  QuizInfoTechnologyListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct QuizInfoTechnologyListView: View {
    @Binding var isPresenting: Bool
//    let quizBeginnerList: [QuizQuestion] = [
//        QuizQuestion(
//            question: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？あああああああああああああああああああ",
//            choices: [
//                "B2B",
//                "B2C",
//                "C2C",
//                "CRM"
//            ],
//            correctAnswerIndex: 3,
//            explanation: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？ああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ"
//        ),
//        QuizQuestion(
//            question: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？あああああああああああああああああああ",
//            choices: [
//                "B2B",
//                "B2C",
//                "C2C",
//                "CRM"
//            ],
//            correctAnswerIndex: 3,
//            explanation: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？ああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ"
//        )
//        ]
//    let quizBeginnerList: [QuizQuestion] = [
//        QuizQuestion(
//            question: "ネットワークのアドレスで、インターネット上のコンピュータやネットワークを一意に識別するための番号は？",
//            choices: [
//                "MACアドレス",
//                "IPアドレス",
//                "URL",
//                "DNS"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "インターネット上のコンピュータやネットワークを一意に識別するための番号は「IPアドレス」といいます。"
//        )
//    ]
    let quizBeginnerList: [QuizQuestion] = [
////        QuizQuestion(
////            question: "あああああああああああああああああああああああああああああああああああああああああああああああああああああああああ",
////            choices: [
////                "電源ケーブル",
////                "Eメールの添付ファイル",
////                "モニター",
////                "キーボード"
////            ],
////            correctAnswerIndex: 1,
////            explanation: " Eメールの添付ファイルは、コンピュータウイルスの感染経路として非常に一般的です。不明な送信元からのメールの添付ファイルは開かないよう注意が必要です。"
////        )
        QuizQuestion(
           question: "コンピュータネットワークで使用される「TCP/IPプロトコル」の役割は何か？",
           choices: [
             "データリンクの確立と管理",
             "インターネット上でのデータの断片化と再構成",
             "データの安全な暗号化と復号",
             "データの正確な送受信を確保する通信プロトコルスイート"
           ],
           correctAnswerIndex: 3,
           explanation: "TCP/IPプロトコルスイートは、インターネット上でデータを送受信するための標準的な通信プロトコル群です。TCP（Transmission Control Protocol）はデータの正確な送受信を保証し、IP（Internet Protocol）はデータパケットの送り先を指定します。"
       ),
         QuizQuestion(
           question: "クラウドコンピューティングのサービスモデルでないものはどれか？",
           choices: [
             "IaaS（Infrastructure as a Service）",
             "PaaS（Platform as a Service）",
             "DaaS（Data as a Service）",
             "FaaS（Function as a Service）"
           ],
           correctAnswerIndex: 2,
           explanation: "クラウドコンピューティングの一般的なサービスモデルにはIaaS、PaaS、SaaS（Software as a Service）が含まれます。DaaSは一般的なクラウドサービスモデルではなく、特に「データ」を提供するサービスを指すことがありますが、標準的なサービスモデルとしてはSaaSが正しい選択肢となります。FaaS（Function as a Service）もクラウドサービスの一つであり、サーバレスコンピューティングを提供します。"
       ),
         QuizQuestion(
           question: "「ビットコイン」はどのような技術に基づいているか？",
           choices: [
             "ブロックチェーン",
             "人工知能",
             "クラウドストレージ",
             "量子コンピューティング"
           ],
           correctAnswerIndex: 0,
           explanation: "ビットコインはブロックチェーン技術に基づいています。ブロックチェーンは、取引の記録を連鎖的につなげたデータベース技術で、その透明性と改ざんの困難さから、デジタル通貨などで広く利用されています。"
       ),
         QuizQuestion(
           question: "データベースにおいて「正規化」の目的は何か？",
           choices: [
             "データの重複を減らし、整合性を保つ",
             "データベースのアクセス速度を向上させる",
             "データの暗号化を強化する",
             "データベースのストレージ容量を増加させる"
           ],
           correctAnswerIndex: 0,
           explanation: "正規化は、データベース設計のプロセスで、データの重複を減らし、データの整合性を保つことを目的としています。これにより、データベースの管理が容易になり、データの矛盾を防ぐことができます。"
         )
        ,

         QuizQuestion(
           question: "「オブジェクト指向プログラミング」の特徴の一つでないものはどれか？",
           choices: [
             "カプセル化",
             "継承",
             "ポリモーフィズム",
             "直列化"
           ],
           correctAnswerIndex: 3,
           explanation: "オブジェクト指向プログラミングの主要な特徴はカプセル化、継承、ポリモーフィズムです。直列化は、オブジェクトを一連のバイトに変換してファイルやネットワークを通じて送受信するためのプロセスであり、オブジェクト指向の特徴ではありません。"
       ),
         QuizQuestion(
           question: "ソフトウェアテストにおいて「ブラックボックステスト」の主な特徴は何か？",
           choices: [
             "内部構造や動作を詳細に調べてテストを行う",
             "実装に関わらず、入出力を基にテストを行う",
             "プログラムのソースコードを直接編集してエラーを修正する",
             "テスト対象の外部からのみアクセスを許可してテストを行う"
           ],
           correctAnswerIndex: 1,
           explanation: "ブラックボックステストは、ソフトウェアの内部構造や動作の知識なしに、外部インタフェースを通じて入出力が期待どおりに動作するかをテストする方法です。主に仕様や要件を満たしているかを確認するために使用されます。"
       ),
         QuizQuestion(
           question: "「MVCモデル」とは何か、その構成要素は何か？",
           choices: [
             "Model、View、Controllerの3つの要素からなるソフトウェア設計パターン",
             "Memory、Variable、Constantの3つのプログラミング要素",
             "Management、Verification、Configurationの3つのシステム管理技術",
             "Module、Vector、Classの3つのプログラミング概念"
           ],
           correctAnswerIndex: 0,
           explanation: "MVCモデルはModel（モデル）、View（ビュー）、Controller（コントローラー）の3つの要素からなるソフトウェア設計パターンで、アプリケーションの構造を論理的に分離することで、開発、保守、拡張がしやすい構造を提供します。"
       ),
         QuizQuestion(
           question: "「プロジェクトマネジメント」で用いられる「WBS」の意味は何か？",
           choices: [
             "Wide Band Spectrum",
             "Work Breakdown Structure",
             "Wireless Broadcast System",
             "Web Based Software"
           ],
           correctAnswerIndex: 1,
           explanation: "WBS（Work Breakdown Structure）は、プロジェクトを成果物や作業項目に分解し、管理しやすい構造にするための手法です。プロジェクトの全体像を把握し、各タスクを明確にすることで、計画的な管理を可能にします。"
         ),

         QuizQuestion(
           question: "「サンドボックス」とは何か、その目的は何か？",
           choices: [
             "メールで送られてくるスパムをフィルタリングするシステム",
             "プログラムやコードを隔離した環境で実行し、システム全体への影響を防ぐ技術",
             "インターネット上で匿名で活動するためのツール",
             "大量のデータを効率的に処理するためのデータベース管理システム"
           ],
           correctAnswerIndex: 1,
           explanation: "サンドボックスは、不確かなプログラムやコードを安全に実行するために、それらを隔離した環境内で実行する技術です。これにより、悪意のあるコードがシステム全体に影響を及ぼすことを防ぎます。"
       ),
         QuizQuestion(
           question: "データベースのACID特性について、正しくない説明はどれか？",
           choices: [
             "Atomicity（原子性）: トランザクション内の全ての操作が完了するか、または一つも実行されないことを保証する",
             "Consistency（一貫性）: トランザクションの前後でデータベースの状態が整合性を保つこと",
             "Isolation（独立性）: 複数のトランザクションが同時に実行される場合、それらが互いに影響を与えないこと",
             "Diversity（多様性）: データベースが異なる種類のデータを扱えること"
           ],
           correctAnswerIndex: 3,
           explanation: "ACID特性は、Atomicity（原子性）、Consistency（一貫性）、Isolation（独立性）、Durability（持続性）の4つの特性を指します。Diversity（多様性）はACID特性には含まれません。"
       ),
         QuizQuestion(
           question: "クラウドサービスのモデル「SaaS」で提供されるものは何か？",
           choices: [
             "物理的なコンピューティングインフラストラクチャ",
             "データストレージとデータベース管理システム",
             "インターネット経由でのソフトウェアの使用",
             "開発プラットフォームとツール"
           ],
           correctAnswerIndex: 2,
           explanation: "SaaS（Software as a Service）は、インターネットを介してアクセスできるソフトウェアを提供するクラウドサービスのモデルです。ユーザーは、ソフトウェアを自分のコンピュータにインストールせずに、ウェブブラウザ経由でアプリケーションを使用できます。"
       ),
         QuizQuestion(
           question: "ネットワーク上での「DHCP」の役割は何か？",
           choices: [
             "データを暗号化する",
             "デバイスに動的にIPアドレスを割り当てる",
             "ネットワークトラフィックを監視する",
             "不正アクセスを防ぐ"
           ],
           correctAnswerIndex: 1,
           explanation: "DHCP（Dynamic Host Configuration Protocol）は、ネットワーク上のデバイスに対して動的にIPアドレスを割り当てるプロトコルです。これにより、手動でIPアドレスを設定する必要がなくなり、ネットワーク管理が簡易化されます。"
       ),
         QuizQuestion(
           question: "ソフトウェア開発において「ユニットテスト」とは何か？",
           choices: [
             "全体のシステムが要件を満たしているかを確認するテスト",
             "アプリケーションのユーザーインターフェイスが適切に機能するかをテストする",
             "個々のソフトウェアコンポーネントやモジュールが正しく動作するかを検証するテスト",
             "異なるシステム間でデータが正確に伝達されるかをチェックするテスト"
           ],
           correctAnswerIndex: 2,
           explanation: "ユニットテストは、ソフトウェア開発のテストフェーズの一部であり、個々のソフトウェアコンポーネントやモジュールが仕様通りに正しく動作するかを検証することに重点を置いたテストです。これにより、開発の早い段階でエラーを発見し、修正することが可能になります。"
       ),

         QuizQuestion(
           question: "ネットワークセキュリティにおける「DMZ（非武装地帯）」の目的は何か？",
           choices: [
             "インターネットからの直接的なアクセスが必要なサーバーを内部ネットワークから分離する",
             "ネットワーク内の全てのデータを暗号化する",
             "ネットワーク攻撃を自動的に検出してブロックする",
             "ネットワーク内のデバイス間での通信速度を向上させる"
           ],
           correctAnswerIndex: 0,
           explanation: "DMZ（非武装地帯）は、インターネットからの直接的なアクセスが必要なサーバー（例えば、ウェブサーバーやメールサーバー）を内部ネットワークから物理的または論理的に分離することで、セキュリティを強化するために使用されます。"
       ),
         QuizQuestion(
           question: "コンピュータウイルスとは異なる、マルウェアの一種である「トロイの木馬」の主な特徴は何か？",
           choices: [
             "自己増殖を行う",
             "有用なソフトウェアに見せかけてシステムに侵入する",
             "ネットワーク経由で拡散する",
             "実行されると画面をロックする"
           ],
           correctAnswerIndex: 1,
           explanation: "トロイの木馬は、有用なソフトウェアやファイルに見せかけることでユーザーによるダウンロードや実行を促し、その後、不正な活動を行うマルウェアの一種です。自己増殖は行わず、拡散のためには人間の介入が必要です。"
       ),
         QuizQuestion(
           question: "「ソフトウェアのライセンス」に関する説明で正しいものはどれか？",
           choices: [
             "ソフトウェアを購入すると、ソフトウェアの所有権がユーザーに移る",
             "オープンソースソフトウェアは、商用利用が一切禁止されている",
             "ソフトウェアライセンスは、ユーザーがソフトウェアを使用する権利を提供する",
             "全てのソフトウェアは、再配布が自由に許可されている"
           ],
           correctAnswerIndex: 2,
           explanation: "ソフトウェアライセンスは、ユーザーがそのソフトウェアを使用する権利を与えるものです。ソフトウェアを購入した場合、所有権が移るのではなく、使用権が与えられるだけであり、ライセンスには使用条件が定められています。"
       ),
         QuizQuestion(
           question: "IPv4アドレスの枯渇に対処するための技術として適切なものはどれか？",
           choices: [
             "NAT（Network Address Translation）",
             "SSL（Secure Sockets Layer）",
             "DHCP（Dynamic Host Configuration Protocol）",
             "FTP（File Transfer Protocol）"
           ],
           correctAnswerIndex: 0,
           explanation: "NAT（Network Address Translation）は、プライベートIPアドレスとパブリックIPアドレスを変換することで、複数のデバイスがインターネットに接続する際に使用するパブリックIPアドレスの数を削減し、IPv4アドレスの枯渇問題に対処する技術です。"
       ),
         QuizQuestion(
           question: "「ビッグエンディアン」と「リトルエンディアン」の違いは何か？",
           choices: [
             "データの圧縮率の違い",
             "データをメモリに格納する際のバイト順序の違い",
             "プロセッサの演算速度の違い",
             "ネットワークの通信速度の違い"
           ],
           correctAnswerIndex: 1,
           explanation: "「ビッグエンディアン」と「リトルエンディアン」は、データをメモリに格納する際のバイト順序が異なることを指します。ビッグエンディアンは最も重要なバイト（ビッグエンド）を先頭に置き、リトルエンディアンは最も重要でないバイト（リトルエンド）を先頭に置きます。"
       ),

         QuizQuestion(
           question: "暗号技術における「ハッシュ関数」の主な用途は何か？",
           choices: [
             "データの暗号化と復号",
             "データの完全性確認",
             "データの圧縮",
             "データの分類"
           ],
           correctAnswerIndex: 1,
           explanation: "ハッシュ関数はデータの完全性を確認するために使用されます。任意の長さのデータから固定長のハッシュ値を生成し、この値を用いてデータが改ざんされていないかを検証できます。"
       ),
         QuizQuestion(
           question: "コンピューターネットワークにおける「ファイアウォール」の機能は何か？",
           choices: [
             "データの暗号化",
             "不正アクセスからネットワークを保護",
             "データの圧縮",
             "データ転送速度の向上"
           ],
           correctAnswerIndex: 1,
           explanation: "ファイアウォールは、不正アクセスからネットワークを保護するために使用されます。外部からの不正な通信を遮断し、内部ネットワークのセキュリティを確保する役割を持っています。"
       ),
         QuizQuestion(
           question: "「ビッグデータ」を分析する際に使用されるプログラミング言語はどれか？",
           choices: [
             "HTML",
             "Python",
             "CSS",
             "JavaScript"
           ],
           correctAnswerIndex: 1,
           explanation: "Pythonはビッグデータの分析に広く使用されるプログラミング言語の一つです。豊富なデータ分析ライブラリとフレームワークを持ち、データの収集、処理、分析、可視化などの作業を効率的に行うことができます。"
       ),
         QuizQuestion(
           question: "「SSL/TLS」の主な目的は何か？",
           choices: [
             "ウェブページの速度向上",
             "データベースの管理",
             "インターネット通信のセキュリティ強化",
             "ユーザー認証の実施"
           ],
           correctAnswerIndex: 2,
           explanation: "SSL（Secure Sockets Layer）およびTLS（Transport Layer Security）は、インターネット上でデータを安全に送受信するためのプロトコルです。これらは通信の暗号化を提供し、データの盗聴や改ざんを防ぎます。"
       ),
         QuizQuestion(
           question: "「クラウドストレージ」サービスの特徴は何か？",
           choices: [
             "オンプレミスのデータセンターでデータを管理",
             "物理的なストレージデバイスにデータを保存",
             "インターネットを通じてデータを保存、アクセス可能",
             "データのローカルバックアップを強制"
           ],
           correctAnswerIndex: 2,
           explanation: "クラウドストレージサービスは、インターネットを通じてどこからでもデータへのアクセスや保存を可能にします。これにより、物理的なストレージデバイスに依存することなく、柔軟かつ効率的なデータ管理が可能になります。"
       ),
//
         QuizQuestion(
           question: "ソフトウェア開発における「アジャイル開発手法」とは何か？",
           choices: [
             "事前に詳細な計画を立て、その計画に従って開発を進める手法",
             "変更に対応しやすいよう短い開発サイクルを繰り返しながら開発を進める手法",
             "最初にすべての機能を完全に開発し、後から修正を加えていく手法",
             "ユーザーの要望に応えるために、開発終了後に要件を調整する手法"
           ],
           correctAnswerIndex: 1,
           explanation: "アジャイル開発手法は、変更に対応しやすいという特徴を持ち、短い開発サイクルを繰り返し実施することで、継続的に製品を改善していく開発方法です。これにより、市場やユーザーの要求の変化に迅速に対応することが可能になります。"
       ),
         QuizQuestion(
           question: "「SQLインジェクション」とはどのような攻撃方法か？",
           choices: [
             "ウェブサイトに不正なSQL文を注入して、データベースを操作する攻撃",
             "メールを通じてウイルスを送り込む攻撃",
             "システムの脆弱性を利用して、不正にアクセスする攻撃",
             "ネットワーク上で情報を傍受する攻撃"
           ],
           correctAnswerIndex: 0,
           explanation: "SQLインジェクション攻撃は、ウェブアプリケーションに不正なSQLクエリを注入し、データベースを不正に操作するセキュリティ攻撃方法です。これにより、機密情報の漏洩やデータベースの破壊などの被害を引き起こすことがあります。"
       ),
         QuizQuestion(
           question: "「クラウドコンピューティング」におけるPaaSの特徴とは何か？",
           choices: [
             "物理的なハードウェア資源を提供するサービス",
             "アプリケーションの実行環境や開発ツールを提供するサービス",
             "インターネット経由でソフトウェアを提供するサービス",
             "データの保存やバックアップを行うサービス"
           ],
           correctAnswerIndex: 1,
           explanation: "PaaS（Platform as a Service）は、アプリケーションの開発、実行、管理に必要なプラットフォームをインターネット経由で提供するクラウドコンピューティングのサービスモデルです。これにより、開発者はインフラストラクチャの管理に関わることなく、アプリケーション開発に集中できます。"
       ),
         QuizQuestion(
           question: "公開鍵暗号方式で用いられる「鍵ペア」について正しい説明はどれか？",
           choices: [
             "公開鍵と秘密鍵の両方でデータを暗号化し、どちらか一方で復号する",
             "公開鍵で暗号化したデータは、その公開鍵でのみ復号できる",
             "公開鍵で暗号化したデータは、対応する秘密鍵でのみ復号できる",
             "秘密鍵で暗号化したデータは、どの公開鍵でも復号できる"
           ],
           correctAnswerIndex: 2,
           explanation: "公開鍵暗号方式では、公開鍵で暗号化したデータは、それに対応する秘密鍵でのみ復号可能です。この方式により、安全にデータの送受信を行うことができます。"
       ),
         QuizQuestion(
           question: "RDBMSにおける正規化の主な目的は何か？",
           choices: [
             "データの重複を排除し、効率的なデータベース構造を実現する",
             "データベースのパフォーマンスを向上させる",
             "SQLクエリの実行速度を速める",
             "データベースのセキュリティを強化する"
           ],
           correctAnswerIndex: 0,
           explanation: "正規化は、データの重複を排除し、データベース内のデータの整合性を保つことを主目的としています。これにより、効率的なデータベース構造を実現し、データの管理を容易にします。"
       ),
         QuizQuestion(
           question: "クラウドコンピューティングのサービスモデル「IaaS」で提供されるリソースは何か？",
           choices: [
             "プラットフォーム",
             "ソフトウェア",
             "インフラストラクチャ",
             "データベース"
           ],
           correctAnswerIndex: 2,
           explanation: "IaaS（Infrastructure as a Service）は、仮想マシンやストレージなどのインフラストラクチャリソースをクラウド経由で提供するサービスモデルです。利用者は、これらのリソースを自由に設定し、利用することができます。"
       ),
         QuizQuestion(
           question: "ビッグデータの「3V」に該当しないものはどれか？",
           choices: [
             "Volume（ボリューム）",
             "Velocity（速度）",
             "Variety（多様性）",
             "Verification（検証）"
           ],
           correctAnswerIndex: 3,
           explanation: "ビッグデータを説明する際によく引用される「3V」はVolume（大量）、Velocity（高速）、Variety（多様性）の3つです。Verification（検証）は、「3V」には含まれません。"
       ),

         QuizQuestion(
           question: "OSI参照モデルのトランスポート層が提供する機能は何か？",
           choices: [
             "データリンクの確立、維持、解除",
             "端末間の通信制御",
             "ネットワーク間のルーティング",
             "エンドツーエンドの信頼性のあるデータ転送"
           ],
           correctAnswerIndex: 3,
           explanation: "トランスポート層は、エンドツーエンドでの信頼性のあるデータ転送を提供する。これには、データの分割、送信側と受信側でのデータの再組み立て、エラーの検出と修正などが含まれる。"
       ),
         QuizQuestion(
           question: "デジタル証明書を発行する組織は何と呼ばれる？",
           choices: [
             "認証局(CA)",
             "レジストラ",
             "ISP",
             "DNSプロバイダ"
           ],
           correctAnswerIndex: 0,
           explanation: "デジタル証明書は認証局(CA)によって発行され、個人や組織の公開鍵とそれが実際にその個人や組織に属していることの証明を提供する。"
       ),
         QuizQuestion(
           question: "プログラミングにおける「ポリモーフィズム」とは何か？",
           choices: [
             "同じインターフェースの下でのデータ型の多様性",
             "オブジェクト指向プログラミングの一種",
             "関数の引数を動的に変更すること",
             "複数のクラス間でメソッドを共有すること"
           ],
           correctAnswerIndex: 0,
           explanation: "ポリモーフィズムは、プログラミング言語の特性の一つで、異なるクラスのオブジェクトが同じインターフェースやメソッドを持つことができる概念を指す。これにより、コードの再利用性が向上し、柔軟なプログラミングが可能になる。"
       ),
         QuizQuestion(
           question: "IPv6アドレスの特徴は何か？",
           choices: [
             "32ビットアドレス",
             "48ビットアドレス",
             "64ビットアドレス",
             "128ビットアドレス"
           ],
           correctAnswerIndex: 3,
           explanation: "IPv6アドレスは128ビットの長さを持ち、これにより膨大な数のユニークなIPアドレスを提供することができる。IPv4の32ビットアドレス体系を大きく拡張し、インターネットの成長を支える。"
       )



    ]
        
    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .infoTechnology, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizInfoTechnologyListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizInfoTechnologyListView(isPresenting: .constant(false))
    }
}
