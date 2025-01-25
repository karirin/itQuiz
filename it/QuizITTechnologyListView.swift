//
//  QuizITTechnologyListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct QuizITTechnologyListView: View {
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
           question: "知的財産権における「著作権」とは、どのようなものを保護する権利か？",
           choices: [
             "発明や発見",
             "企業のロゴやブランド名",
             "文学作品や音楽作品などの創作物",
             "特定の商標やサービスマーク"
           ],
           correctAnswerIndex: 2,
           explanation: "著作権は、文学作品、音楽作品、映画、美術作品などの創作物に対して、その創作者に与えられる権利で、他人による無断の使用を制限します。"
         ),
          QuizQuestion(
           question: "組織がデータ保護のために取り組むべき基本的なセキュリティ対策は何か？",
           choices: [
             "すべての従業員をIT部門に配置する",
             "年に一度セキュリティ監査を実施する",
             "ファイアウォールとアンチウイルスの使用",
             "データのバックアップを取らない政策を採用する"
           ],
           correctAnswerIndex: 2,
           explanation: "組織がデータを保護するためには、ファイアウォールとアンチウイルスソフトウェアを使用することが基本的なセキュリティ対策として推奨されます。これにより、不正アクセスやマルウェアからデータを守ることができます。"
         ),
          QuizQuestion(
           question: "企業がビジネスプロセスを効率化し、コスト削減を実現するためによく使用するITソリューションは何か？",
           choices: [
             "ソーシャルネットワークサービス",
             "エンタープライズリソースプランニング（ERP）システム",
             "パーソナルコンピュータ",
             "仮想現実（VR）技術"
           ],
           correctAnswerIndex: 1,
           explanation: "エンタープライズリソースプランニング（ERP）システムは、企業の財務管理、人事、製造、供給チェーン管理など、さまざまなビジネスプロセスを統合し、効率化およびコスト削減を実現するために広く使用されています。"
         ),
          QuizQuestion(
           question: "プライバシーマーク制度の目的は何か？",
           choices: [
             "企業の収益向上を支援する",
             "個人情報の適切な保護と管理を行う組織に与えられる認証マーク",
             "企業の製品品質を保証する",
             "企業のセキュリティレベルを評価する"
           ],
           correctAnswerIndex: 1,
           explanation: "プライバシーマーク制度は、個人情報の適切な保護と管理を行っていることを示す認証マークであり、消費者に対してその組織が個人情報を適切に扱っていることを示すために用いられます。"
         )
        ,

          QuizQuestion(
           question: "Web開発において、クライアントサイドで動作するスクリプト言語はどれか？",
           choices: [
             "Java",
             "C#",
             "JavaScript",
             "PHP"
           ],
           correctAnswerIndex: 2,
           explanation: "JavaScriptは、Webページのクライアントサイドで動作するスクリプト言語で、ユーザーのインタラクションを豊かにするために使用されます。"
         ),
          QuizQuestion(
           question: "コンピュータネットワークの構成要素で、データの送受信に使われる物理的な媒体は何か？",
           choices: [
             "ルーター",
             "スイッチ",
             "伝送媒体",
             "ファイアウォール"
           ],
           correctAnswerIndex: 2,
           explanation: "伝送媒体は、コンピュータネットワークにおいてデータを送受信するために使用される物理的な媒体を指し、有線（例：イーサネットケーブル）と無線（例：無線信号）があります。"
         ),
          QuizQuestion(
           question: "情報セキュリティの三要素ではないものはどれか？",
           choices: [
             "機密性",
             "可用性",
             "追跡可能性",
             "完全性"
           ],
           correctAnswerIndex: 2,
           explanation: "情報セキュリティの三要素は機密性、完全性、可用性であり、これらは情報を保護するための基本原則です。追跡可能性は情報セキュリティの三要素には含まれません。"
         ),
          QuizQuestion(
           question: "ソフトウェアライセンスの種類で、複製、配布、修正が自由に許可されるものは何か？",
           choices: [
             "フリーウェア",
             "シェアウェア",
             "オープンソースソフトウェア",
             "コマーシャルソフトウェア"
           ],
           correctAnswerIndex: 2,
           explanation: "オープンソースソフトウェアは、ソースコードが公開されており、誰でも自由に複製、配布、修正することが許可されています。これはコミュニティによる共同開発を促進します。"
         ),

          QuizQuestion(
           question: "プログラミング言語の特性において、同じ操作をデータの集合に対して一括で行う機能を何というか？",
           choices: [
             "オブジェクト指向",
             "手続き型",
             "ポリモーフィズム",
             "マップリデュース"
           ],
           correctAnswerIndex: 3,
           explanation: "マップリデュースは、大規模なデータセットに対して並列処理を行うためのプログラミングモデルであり、データの集合に対して同じ操作を一括で行う機能を提供します。"
         ),
          QuizQuestion(
           question: "ITプロジェクトにおける「ステークホルダー」とは、どのような立場の人々を指すか？",
           choices: [
             "プロジェクトの成果に直接的な影響を受ける人々",
             "プロジェクトの資金提供者のみ",
             "プロジェクトチームのメンバーのみ",
             "プロジェクト管理者のみ"
           ],
           correctAnswerIndex: 0,
           explanation: "ステークホルダーは、プロジェクトの成果に直接的または間接的な影響を受ける、あるいは影響を与えることができる全ての個人やグループを指します。これには資金提供者、顧客、プロジェクトチームメンバー、ユーザーなどが含まれます。"
         ),
          QuizQuestion(
           question: "インターネットで使用されるプロトコルで、メール送信に使われるものは何か？",
           choices: [
             "HTTP",
             "FTP",
             "SMTP",
             "TCP"
           ],
           correctAnswerIndex: 2,
           explanation: "SMTP（Simple Mail Transfer Protocol）は、インターネット上でメールを送信するために使用されるプロトコルです。"
         ),
          QuizQuestion(
           question: "ソフトウェアテストの種類で、アプリケーションの異なる部分が正しく連携するかを確認するテストは何か？",
           choices: [
             "ユニットテスト",
             "統合テスト",
             "システムテスト",
             "受け入れテスト"
           ],
           correctAnswerIndex: 1,
           explanation: "統合テストは、ソフトウェアまたはそのシステムの異なる部分やモジュールが適切に連携し合い、正しく機能するかを検証するテストプロセスです。"
         ),

          QuizQuestion(
           question: "データベースにおいて、データの一貫性を保つために用いられる制約の一つは何か？",
           choices: [
             "トランザクション制御",
             "外部キー制約",
             "データ暗号化",
             "バックアップと復元"
           ],
           correctAnswerIndex: 1,
           explanation: "外部キー制約は、データベース内の異なるテーブル間でデータの整合性を保つために使用される。これにより、参照されるテーブルに存在しない値を参照テーブルが持つことを防ぐ。"
         ),
          QuizQuestion(
           question: "ソフトウェア開発手法の一つで、継続的な顧客のフィードバックを元に、短い開発サイクルを繰り返してソフトウェアを開発する方法は何か？",
           choices: [
             "ウォーターフォールモデル",
             "スパイラルモデル",
             "アジャイル開発",
             "ディバイドアンドコンカー"
           ],
           correctAnswerIndex: 2,
           explanation: "アジャイル開発は、継続的な顧客のフィードバックを反映しつつ、短い開発サイクル（イテレーション）を繰り返し、柔軟かつ迅速にソフトウェアを開発していく方法です。"
         ),
          QuizQuestion(
           question: "次のうち、プロジェクト管理においてリスク評価の一部として考慮されるべきではないものはどれか？",
           choices: [
             "プロジェクトスコープの変更",
             "技術的障害",
             "市場競争",
             "プロジェクトチームの士気"
           ],
           correctAnswerIndex: 2,
           explanation: "市場競争はプロジェクト管理のリスク評価において直接的なファクターではありません。通常、リスク評価では、プロジェクトの範囲、技術的な課題、チームのパフォーマンスなど、プロジェクトの成功に直接影響する要因を考慮します。"
         ),
          QuizQuestion(
           question: "情報セキュリティポリシーの目的の一つは何か？",
           choices: [
             "組織の情報技術の使用方法を制限する",
             "情報資産の保護とセキュリティリスクの管理",
             "従業員のプライバシーを侵害する",
             "セキュリティ違反者を罰する"
           ],
           correctAnswerIndex: 1,
           explanation: "情報セキュリティポリシーの主な目的は、組織の情報資産を保護し、セキュリティリスクを効果的に管理することにあります。これには、セキュリティ違反の予防、検出、対応戦略の定義が含まれます。"
         ),

          QuizQuestion(
           question: "クラウドサービスモデルのうち、最も管理が必要なサービスはどれか？",
           choices: [
             "Software as a Service (SaaS)",
             "Platform as a Service (PaaS)",
             "Infrastructure as a Service (IaaS)",
             "Function as a Service (FaaS)"
           ],
           correctAnswerIndex: 2,
           explanation: "IaaS（Infrastructure as a Service）は、基盤となるインフラストラクチャを提供するクラウドサービスであり、利用者が最も多くの管理作業を必要とします。SaaSやPaaSに比べ、ネットワーク設定やサーバーの管理など、より広範な制御をユーザーが行う必要があります。"
         ),
          QuizQuestion(
           question: "プロジェクト管理で使用される「WBS」とは何の略か？",
           choices: [
             "Wide Bandwidth System",
             "Work Breakdown Structure",
             "Web Based Software",
             "Workflow Baseline Strategy"
           ],
           correctAnswerIndex: 1,
           explanation: "WBS（Work Breakdown Structure）は、プロジェクトを構成する作業を階層的に分解し表示することで、プロジェクトの全体像を把握しやすくするためのツールです。"
         ),
          QuizQuestion(
           question: "情報セキュリティ管理で「CIAトライアド」とは何を指すか？",
           choices: [
             "Confidentiality, Integrity, Availability",
             "Control, Investigation, Authorization",
             "Cyber Intelligence Agency",
             "Classification, Identification, Authentication"
           ],
           correctAnswerIndex: 0,
           explanation: "CIAトライアドは情報セキュリティの3つの基本原則を指し、Confidentiality（機密性）、Integrity（完全性）、Availability（可用性）を意味します。これらは情報セキュリティを実現するための重要な要素です。"
         ),
          QuizQuestion(
           question: "ソフトウェアのライフサイクル内で、要件定義フェーズの目的は何か？",
           choices: [
             "プロジェクト計画を立てる",
             "ソフトウェアの設計を行う",
             "最終製品をテストする",
             "ユーザーのニーズとシステム要件を明確にする"
           ],
           correctAnswerIndex: 3,
           explanation: "要件定義フェーズでは、開発するソフトウェアが満たすべきユーザーのニーズとシステム要件を収集し、分析して明確にします。これにより、開発プロセスの基礎となる要件が定義されます。"
         ),

          QuizQuestion(
           question: "無線LANのセキュリティで最も一般的に使用される暗号化技術は何か？",
           choices: [
             "WEP",
             "WPA2",
             "SSH",
             "AES"
           ],
           correctAnswerIndex: 1,
           explanation: "WPA2（Wi-Fi Protected Access 2）は、無線LANのセキュリティを確保するために最も一般的に使用される暗号化技術であり、WEPよりも高度なセキュリティを提供します。"
         ),
          QuizQuestion(
           question: "次のうち、ブロックチェーン技術の主要な特徴ではないものはどれか？",
           choices: [
             "透明性",
             "変更不可能性",
             "集中管理",
             "分散化"
           ],
           correctAnswerIndex: 2,
           explanation: "ブロックチェーン技術の特徴は、透明性、変更不可能性、および分散化にあります。集中管理はブロックチェーンの特徴ではなく、むしろその逆を指します。"
         ),
          QuizQuestion(
           question: "次のうち、マルウェアの一種ではないものはどれか？",
           choices: [
             "トロイの木馬",
             "スパイウェア",
             "フィッシング",
             "ランサムウェア"
           ],
           correctAnswerIndex: 2,
           explanation: "フィッシングは、詐欺的な手段を用いて個人情報を盗み出す攻撃手法であり、マルウェア（悪意のあるソフトウェア）そのものではありません。"
         ),
          QuizQuestion(
           question: "IPv6アドレスの長さは何ビットか？",
           choices: [
             "32ビット",
             "64ビット",
             "128ビット",
             "256ビット"
           ],
           correctAnswerIndex: 2,
           explanation: "IPv6アドレスは128ビットの長さがあり、より広大なアドレス空間を提供し、インターネットの成長を支える設計となっています。"
         ),

          QuizQuestion(
           question: "オペレーティングシステム(OS)の主な役割は何か？",
           choices: [
             "文書作成ソフトウェアを提供する",
             "ネットワーク接続の速度を上げる",
             "ハードウェアとアプリケーションソフトウェアの仲介役をする",
             "ウイルスからコンピュータを守る"
           ],
           correctAnswerIndex: 2,
           explanation: "オペレーティングシステムは、コンピュータのハードウェアリソースを管理し、アプリケーションソフトウェアがこれらのリソースを効率的に利用できるようにする仲介者の役割を果たします。"
         ),
          QuizQuestion(
           question: "ビッグデータの「3V」とは何を指すか？",
           choices: [
             "Velocity, Variety, Volume",
             "Validity, Veracity, Value",
             "Visibility, Velocity, Volume",
             "Volume, Value, Veracity"
           ],
           correctAnswerIndex: 0,
           explanation: "ビッグデータの「3V」は、データの大量性（Volume）、多様性（Variety）、速度（Velocity）を指し、ビッグデータを定義する上で重要な3つの特徴を表しています。"
         ),
          QuizQuestion(
           question: "RDBMSの「R」は何を意味しているか？",
           choices: [
             "Rapid",
             "Relational",
             "Real-time",
             "Recoverable"
           ],
           correctAnswerIndex: 1,
           explanation: "RDBMSはRelational Database Management Systemの略で、関係型データベース管理システムを意味します。これは、データを表形式で管理し、行と列の関係を利用して効率的な検索と更新を行うシステムです。"
         ),
          QuizQuestion(
           question: "ソフトウェア開発における「アジャイル」とは何か？",
           choices: [
             "プログラミング言語の一種",
             "開発プロジェクトを迅速かつ柔軟に進める方法論",
             "ソフトウェアのバグを自動的に修正するツール",
             "データを安全に暗号化する技術"
           ],
           correctAnswerIndex: 1,
           explanation: "アジャイルソフトウェア開発は、短い開発サイクル（スプリント）を通じて迅速かつ柔軟にソフトウェア開発プロジェクトを進めるための方法論です。顧客のフィードバックを積極的に取り入れ、変化に迅速に対応します。"
         ),

          QuizQuestion(
           question: "次のうち、機密データを暗号化して安全に通信するために使用されるプロトコルはどれか？",
           choices: [
             "HTTP",
             "HTTPS",
             "FTP",
             "SMTP"
           ],
           correctAnswerIndex: 1,
           explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、通信を暗号化することによって、データの盗聴や改ざんを防ぐために使用されるプロトコルです。"
         ),
          QuizQuestion(
           question: "クラウドコンピューティングのサービスモデルで、インフラストラクチャ（サーバーやストレージなど）をインターネット経由で提供するものは何か？",
           choices: [
             "Software as a Service (SaaS)",
             "Platform as a Service (PaaS)",
             "Infrastructure as a Service (IaaS)",
             "Database as a Service (DaaS)"
           ],
           correctAnswerIndex: 2,
           explanation: "IaaS（Infrastructure as a Service）は、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドサービスモデルです。"
         ),
          QuizQuestion(
           question: "デジタル証明書を発行することで、ウェブサイトの身元を証明し、通信の安全を保証する組織は何か？",
           choices: [
             "インターネットサービスプロバイダ",
             "ネットワーク管理者",
             "認証局（Certificate Authority, CA）",
             "ウェブホスティングサービス"
           ],
           correctAnswerIndex: 2,
           explanation: "認証局（CA）は、デジタル証明書を発行することによって、ウェブサイトの身元を証明し、通信が安全であることを保証する組織です。"
         ),
        QuizQuestion(
            question: "PC において, 電力供給を断つと記憶内容が失われるメモリ又は記憶媒体はどれか。",
            choices: [
                "DVD-RAM",
                "ROM",
                "DRAM",
                "フラッシュメモリ"
            ],
            correctAnswerIndex: 2,
            explanation: "DRAMは揮発性メモリであり、電力供給が断たれるとデータが失われます。"
        ),
        QuizQuestion(
            question: "暗号化方式の特徴について記した表において, 表中の a〜d に入れる字句の適切な組合せはどれか。",
            choices: [
                "共通鍵暗号方式 公開鍵暗号方式 遅い 速い",
                "共通鍵暗号方式 公開鍵暗号方式 速い 遅い",
                "公開鍵暗号方式 共通鍵暗号方式 遅い 速い",
                "公開鍵暗号方式 共通鍵暗号方式 速い 遅い"
            ],
            correctAnswerIndex: 1,
            explanation: "共通鍵暗号方式は暗号化鍵と復号鍵が同一であり、処理速度が速い。一方、公開鍵暗号方式は鍵が異なり、処理速度が遅い。"
        ),
        QuizQuestion(
            question: "文書作成ソフトや表計算ソフトなどにおいて, 一連の操作手順をあらかじめ定義しておき, 実行する機能はどれか。",
            choices: [
                "オートコンプリート",
                "ソースコード",
                "プラグアンドプレイ",
                "マクロ"
            ],
            correctAnswerIndex: 3,
            explanation: "マクロは一連の操作手順を自動化する機能です。"
        ),
        QuizQuestion(
            question: "OCRの役割として,適切なものはどれか。",
            choices: [
                "10cm程度の近距離にある機器間で無線通信する。",
                "印刷文字や手書き文字を認識し, テキストデータに変換する。",
                "デジタル信号処理によって, 人工的に音声を作り出す。",
                "利用者の指先などが触れたパネル上の位置を検出する。"
            ],
            correctAnswerIndex: 1,
            explanation: "OCR（Optical Character Recognition）は印刷文字や手書き文字を認識してテキストデータに変換します。"
        ),
        QuizQuestion(
            question: "関係データベースを構成する要素の関係を表す図において,図中のa〜cに入れる字句の適切な組合せはどれか。",
            choices: [
                "表 フィールド レコード",
                "表表 フィールド レコード",
                "フィールド 表 レコード",
                "レコード 表 フィールド"
            ],
            correctAnswerIndex: 3,
            explanation: "関係データベースでは、表がデータの集合、フィールドが項目、レコードが各データの行を表します。"
        ),
        QuizQuestion(
            question: "cookie を説明したものはどれか。",
            choices: [
                "Web サイトが, Web ブラウザを通じて訪問者のPCにデータを書き込んで保存する仕組み又は保存されるデータのこと",
                "Web ブラウザが, アクセスした Web ページをファイルとして PC のハードディスクに一時的に保存する仕組み又は保存されるファイルのこと",
                "Web ページ上で, Web サイトの紹介などを目的に掲載されている画像のこと",
                "ブログの機能の一つで、リンクを張った相手に対してその旨を通知する仕組みのこと"
            ],
            correctAnswerIndex: 0,
            explanation: "CookieはWebサイトがブラウザを通じてユーザーのPCにデータを保存する仕組みまたはそのデータを指します。"
        ),
        QuizQuestion(
            question: "SSD の全てのデータを消去し、復元できなくする方法として用いられているものはどれか。",
            choices: [
                "Secure Erase",
                "セキュアブート",
                "磁気消去",
                "データクレンジング"
            ],
            correctAnswerIndex: 0,
            explanation: "Secure EraseはSSDの全データを消去し、復元不可能にする方法として広く用いられています。"
        ),
        QuizQuestion(
            question: "情報セキュリティのリスクマネジメントにおけるリスクへの対応を, リスク共有, リスク回避, リスク保有及びリスク低減の四つに分類するとき,リスク共有の例として,適切なものはどれか。",
            choices: [
                "災害によるシステムの停止時間を短くするために, 遠隔地にバックアップセンターを設置する。",
                "情報漏えいによって発生する損害賠償や事故処理の損失補填のために, サイバー保険に加入する。",
                "電子メールによる機密ファイルの流出を防ぐために, ファイルを添付した電子メールの送信には上司の許可を必要とする仕組みにする。",
                "ノートPCの紛失や盗難による情報漏えいを防ぐために, HDD を暗号化する。"
            ],
            correctAnswerIndex: 1,
            explanation: "サイバー保険に加入することで、リスクを第三者と共有するリスク共有の例となります。"
        ),
        QuizQuestion(
            question: "AI における機械学習の学習方法に関する次の記述中の ac に入れる字句の適切な組合せはどれか。",
            choices: [
                "回帰 分類 クラスタリング",
                "クラスタリング 分類 回帰",
                "分類 回帰 クラスタリング",
                "分類 クラスタリング 回帰"
            ],
            correctAnswerIndex: 3,
            explanation: "教師あり学習は分類や回帰、教師なし学習はクラスタリングを指します。"
        ),
        QuizQuestion(
            question: "PKI における CA (Certificate Authority) の役割に関する記述として適切なものはどれか。",
            choices: [
                "インターネットと内部ネットワークの間にあって, 内部ネットワーク上のコンピュータに代わってインターネットにアクセスする。",
                "インターネットと内部ネットワークの間にあって, パケットフィルタリング機能などを用いてインターネットから内部ネットワークへの不正アクセスを防ぐ。",
                "利用者に指定されたドメイン名を基に IP アドレスとドメイン名の対応付けを行い、利用者を目的のサーバにアクセスさせる。",
                "利用者の公開鍵に対する公開鍵証明書の発行や失効を行い, 鍵の正当性を保証する。"
            ],
            correctAnswerIndex: 3,
            explanation: "CAは公開鍵証明書を発行・失効し、公開鍵の正当性を保証する役割を担います。"
        ),
        QuizQuestion(
            question: "情報デザインで用いられる概念であり, 部屋のドアノブの形で開閉の仕方を示唆するというような, 人間の適切な行動を誘発する知覚可能な手掛かりのことを何と呼ぶか。",
            choices: [
                "NUI (Natural User Interface)",
                "ウィザード",
                "シグニファイア",
                "マルチタッチ"
            ],
            correctAnswerIndex: 2,
            explanation: "シグニファイアはユーザーに対してどのように操作すべきかを示す視覚的な手掛かりのことを指します。"
        ),
        QuizQuestion(
            question: "障害に備えるために, 4台のHDD を使い, 1台分の容量をパリティ情報の記録に使用する RAID5を構成する。 1台のHDDの容量が1Tバイトのとき, 実効データ容量はおよそ何バイトか。",
            choices: [
                "2T",
                "3T",
                "4T",
                "5T"
            ],
            correctAnswerIndex: 1,
            explanation: "RAID5ではN台のディスクのうち1台分がパリティ用として使用されるため、実効容量は3Tとなります。"
        ),
        QuizQuestion(
            question: "ESSID をステルス化することによって得られる効果として,適切なものはどれか。",
            choices: [
                "アクセスポイントと端末間の通信を暗号化できる。",
                "アクセスポイントに接続してくる端末を認証できる。",
                "アクセスポイントへの不正接続リスクを低減できる。",
                "アクセスポイントを介さず, 端末同士で直接通信できる。"
            ],
            correctAnswerIndex: 2,
            explanation: "ESSIDをステルス化すると、ネットワークの存在が周囲に見えにくくなり、不正接続のリスクを低減できます。"
        ),
        QuizQuestion(
            question: "インターネットで使用されているドメイン名の説明として, 適切なものはどれか。",
            choices: [
                "Web 閲覧や電子メールを送受信するアプリケーションが使用する通信規約の名前",
                "コンピュータやネットワークなどを識別するための名前",
                "通信を行うアプリケーションを識別するための名前",
                "電子メールの宛先として指定する相手の名前"
            ],
            correctAnswerIndex: 1,
            explanation: "ドメイン名はコンピュータやネットワークを識別するための名前です。"
        ),
        QuizQuestion(
            question: "IoT 機器のセキュリティ対策のうち, ソーシャルエンジニアリング対策として 最も適切なものはどれか。",
            choices: [
                "IoT 機器とサーバとの通信は, 盗聴を防止するために常に暗号化通信で行う。",
                "IoT 機器の脆弱性を突いた攻撃を防止するために, 機器のメーカーから最新のファームウェアを入手してアップデートを行う。",
                "IoT 機器へのマルウェア感染を防止するためにマルウェア対策ソフトを導入する。",
                "IoT 機器を廃棄するときは, 内蔵されている記憶装置からの情報漏えいを防ぐために物理的に破壊する。"
            ],
            correctAnswerIndex: 1,
            explanation: "ソーシャルエンジニアリング対策として、最新のファームウェアを適用し脆弱性を修正することが有効です。"
        ),
        QuizQuestion(
            question: "トランザクション処理に関する記述のうち, 適切なものはどれか。",
            choices: [
                "コミットとは, トランザクションが正常に処理されなかったときに, データベースをトランザクション開始前の状態に戻すことである。",
                "排他制御とは, トランザクションが正常に処理されたときに, データベースの内容を確定させることである。",
                "ロールバックとは、複数のトランザクションが同時に同一データを更新しようとしたときに, データの矛盾が起きないようにすることである。",
                "ログとは,データベースの更新履歴を記録したファイルのことである。"
            ],
            correctAnswerIndex: 3,
            explanation: "ログはデータベースの更新履歴を記録したもので、トランザクションの管理に使用されます。他の選択肢は定義が誤っています。"
        ),
        QuizQuestion(
            question: "情報セキュリティの3要素である機密性, 完全性及び可用性と,それらを確保するための対策の例 a〜c の適切な組合せはどれか。",
            choices: [
                "可用性 完全性 機密性",
                "可用性 機密性 完全性",
                "完全性 機密性可用性",
                "機密性 完全性 可用性"
            ],
            correctAnswerIndex: 3,
            explanation: "アクセス制御は機密性、デジタル署名は完全性、ディスクの二重化は可用性を確保する対策です。"
        ),
        QuizQuestion(
            question: "スマートフォンなどのタッチパネルで広く採用されている方式であり,指がタッチパネルの表面に近づいたときに、その位置を検出する方式はどれか。",
            choices: [
                "感圧式",
                "光学式",
                "静電容量方式",
                "電磁誘導方式"
            ],
            correctAnswerIndex: 2,
            explanation: "静電容量方式は指が近づいた位置を検出するタッチパネル方式です。"
        ),
        QuizQuestion(
            question: "出所が不明のプログラムファイルの使用を避けるために, その発行元を調べたい。 このときに確認する情報として, 適切なものはどれか。",
            choices: [
                "そのプログラムファイルのアクセス権",
                "そのプログラムファイルの所有者情報",
                "そのプログラムファイルのデジタル署名",
                "そのプログラムファイルのハッシュ値"
            ],
            correctAnswerIndex: 2,
            explanation: "デジタル署名は発行元の確認やファイルの改ざんチェックに使用されます。"
        ),
        QuizQuestion(
            question: "企業などの内部ネットワークとインターネットとの間にあって, セキュリティを確保するために内部ネットワークの PC に代わって, インターネット上の Web サーバにアクセスするものはどれか。",
            choices: [
                "DNS サーバ",
                "NTP サーバ",
                "ストリーミングサーバ",
                "プロキシサーバ"
            ],
            correctAnswerIndex: 3,
            explanation: "プロキシサーバは内部ネットワークのPCに代わってインターネット上のサーバにアクセスし、セキュリティを強化します。"
        ),
        QuizQuestion(
            question: "OSS (Open Source Software) に関する記述として, 適切なものだけを全て挙げたものはどれか。",
            choices: [
                "OSS を利用して作成したソフトウェアを販売することができる。",
                "ソースコードが公開されたソフトウェアは全てOSS である。",
                "著作権が放棄されているソフトウェアである。"
            ],
            correctAnswerIndex: 0,
            explanation: "OSSではソースコードが公開されていますが、必ずしも全てが著作権放棄ではありません。OSSを利用して作成したソフトウェアを販売することは可能です。"
        ),
       
        QuizQuestion(
            question: "ISMS クラウドセキュリティ認証に関する記述として, 適切なものはどれか。",
            choices: [
                "一度認証するだけで, 複数のクラウドサービスやシステムなどを利用できるようにする認証の仕組み",
                "クラウドサービスについて, クラウドサービス固有の管理策が実施されていることを認証する制度",
                "個人情報について適切な保護措置を講ずる体制を整備しているクラウド事業者などを評価して, 事業活動に関してプライバシーマークの使用を認める制度",
                "利用者がクラウドサービスへログインするときの環境, IP アドレスなどに基づいて状況を分析し, リスクが高いと判断された場合に追加の認証を行う仕組み"
            ],
            correctAnswerIndex: 1,
            explanation: "ISMSクラウドセキュリティ認証は、クラウドサービス固有の管理策が実施されていることを認証する制度です。"
        ),
        QuizQuestion(
            question: "1から6までの六つの目をもつサイコロを3回投げたとき, 1回も1の目が出ない確率は幾らか。",
            choices: [
                "5/216",
                "7/216",
                "72/216",
                "125/216"
            ],
            correctAnswerIndex: 3,
            explanation: "サイコロ1回で1が出ない確率は5/6。3回連続で1が出ない確率は(5/6)^3 = 125/216。"
        ),
        QuizQuestion(
            question: "IoT エリアネットワークでも利用され, IoT デバイスからの無線通信をほかの IoT デバイスが中継することを繰り返し, リレー方式で通信をすることによって広範囲の通信を実現する技術はどれか。",
            choices: [
                "GPS",
                "MIMO",
                "キャリアアグリゲーション",
                "マルチホップ"
            ],
            correctAnswerIndex: 3,
            explanation: "マルチホップはデバイス間でデータを中継し、広範囲の通信を可能にする技術です。"
        ),
        QuizQuestion(
            question: "PDCA モデルに基づいて ISMS を運用している組織において, C (Check) で実施することの例として, 適切なものはどれか。",
            choices: [
                "業務内容の監査結果に基づいた是正処置として, サーバの監視方法を変更する。",
                "具体的な対策と目標を決めるために, サーバ室内の情報資産を洗い出す。",
                "サーバ管理者の業務内容を第三者が客観的に評価する。",
                "定められた運用手順に従ってサーバの動作を監視する。"
            ],
            correctAnswerIndex: 2,
            explanation: "C (Check) は監視や評価を行う段階であり、第三者による業務内容の評価が該当します。"
        ),
        QuizQuestion(
            question: "JavaScript に関する記述として、 適切なものはどれか。",
            choices: [
                "Web ブラウザ上に, 動的な振る舞いなどを組み込むことができる。",
                "Web ブラウザではなく, Web サーバ上だけで動作する。",
                "実行するためには, あらかじめコンパイルする必要がある。",
                "名前のとおり, Javaのスクリプト版である。"
            ],
            correctAnswerIndex: 0,
            explanation: "JavaScriptはWebブラウザ上で動的な振る舞いを実現するために使用されます。"
        ),
        QuizQuestion(
            question: "システムの利用者認証に関する記述のうち, 適切なものはどれか。",
            choices: [
                "1回の認証で, 複数のサーバやアプリケーションなどへのログインを実現する仕組みを,チャレンジレスポンス認証という。",
                "指紋や声紋など, 身体的な特徴を利用して本人認証を行う仕組みを, シングルサインオンという。",
                "情報システムが利用者の本人確認のために用いる, 数字列から成る暗証番号のことを, PIN という。",
                "特定の数字や文字の並びではなく, 位置についての情報を覚えておき、 認証時には画面に表示された表の中で, 自分が覚えている位置に並んでいる数字や文字をパスワードとして入力する方式を, 多要素認証という。"
            ],
            correctAnswerIndex: 2,
            explanation: "PINは個人識別番号のことで、利用者の本人確認に用いられます。"
        ),
        QuizQuestion(
            question: "セキュリティ対策として使用される WAF の説明として、 適切なものはどれか。",
            choices: [
                "ECなどのWebサイトにおいて, Webアプリケーションソフトウェアの脆弱性を突いた攻撃からの防御や、不審なアクセスのパターンを検知する仕組み",
                "インターネットなどの公共のネットワークを用いて, 専用線のようなセキュアな通信環境を実現する仕組み",
                "情報システムにおいて, 機密データを特定して監視することによって, 機密データの紛失や外部への漏えいを防止する仕組み",
                "ファイアウォールを用いて, インターネットと企業の内部ネットワークとの間に緩衝領域を作る仕組み"
            ],
            correctAnswerIndex: 0,
            explanation: "WAF（Web Application Firewall）はWebアプリケーションを保護するために使用され、脆弱性を突いた攻撃から防御します。"
        ),
        QuizQuestion(
            question: "職場で不要になった PC を廃棄する場合の情報漏えい対策として、最も適切なものはどれか。",
            choices: [
                "OS が用意しているファイル削除の機能を使って, PC 内のデータファイルを全て削除する。",
                "PC にインストールされているアプリケーションを、全てアンインストールする。",
                "PC に内蔵されている全ての記憶装置を論理フォーマットする。",
                "専用ソフトなどを使って, PC に内蔵されている全ての記憶装置の内容を消去するために, ランダムなデータを規定回数だけ上書きする。"
            ],
            correctAnswerIndex: 3,
            explanation: "ランダムなデータを複数回上書きすることで、データの復元を困難にします。"
        ),
        QuizQuestion(
            question: "インターネットに接続されているサーバが, 1台でメール送受信機能と Web アクセス機能の両方を提供しているとき,端末のアプリケーションプログラムがそのどちらの機能を利用するかをサーバに指定するために用いるものはどれか。",
            choices: [
                "IP アドレス",
                "ドメイン",
                "ポート番号",
                "ホスト名"
            ],
            correctAnswerIndex: 2,
            explanation: "ポート番号を指定することで、サーバ上のどのサービス（メールやWeb）を利用するかを指定します。"
        ),
        QuizQuestion(
            question: "AI の関連技術であるディープラーニングに用いられる技術として, 最も適切なものはどれか。",
            choices: [
                "ソーシャルネットワーク",
                "ニューラルネットワーク",
                "フィージビリティスタディ",
                "フォールトトレラント"
            ],
            correctAnswerIndex: 1,
            explanation: "ディープラーニングはニューラルネットワークを基盤とした技術です。"
        ),
        QuizQuestion(
            question: "ランサムウェアに関する記述として,最も適切なものはどれか。",
            choices: [
                "PC に外部から不正にログインするための侵入路をひそかに設置する。",
                "PC のファイルを勝手に暗号化し, 復号のためのキーを提供することなどを条件に金銭を要求する。",
                "Web ブラウザを乗っ取り、オンラインバンキングなどの通信に割り込んで不正送金などを行う。",
                "自らネットワークを経由して感染を広げる機能をもち, まん延していく。"
            ],
            correctAnswerIndex: 1,
            explanation: "ランサムウェアはファイルを暗号化し、復号のための金銭を要求するマルウェアです。"
        ),
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
        QuizView(quizzes: shuffledQuizList, quizLevel: .itTechnology, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizITTechnologyListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizITTechnologyListView(isPresenting: .constant(false))
    }
}
