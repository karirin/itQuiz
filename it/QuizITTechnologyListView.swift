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
//          QuizQuestion(
//           question: "IPv6アドレスの長さは何ビットか？",
//           choices: [
//             "32ビット",
//             "64ビット",
//             "128ビット",
//             "256ビット"
//           ],
//           correctAnswerIndex: 2,
//           explanation: "IPv6アドレスは128ビットの長さがあり、より広大なアドレス空間を提供し、インターネットの成長を支える設計となっています。"
//         ),
//
//          QuizQuestion(
//           question: "オペレーティングシステム(OS)の主な役割は何か？",
//           choices: [
//             "文書作成ソフトウェアを提供する",
//             "ネットワーク接続の速度を上げる",
//             "ハードウェアとアプリケーションソフトウェアの仲介役をする",
//             "ウイルスからコンピュータを守る"
//           ],
//           correctAnswerIndex: 2,
//           explanation: "オペレーティングシステムは、コンピュータのハードウェアリソースを管理し、アプリケーションソフトウェアがこれらのリソースを効率的に利用できるようにする仲介者の役割を果たします。"
//         ),
//          QuizQuestion(
//           question: "ビッグデータの「3V」とは何を指すか？",
//           choices: [
//             "Velocity, Variety, Volume",
//             "Validity, Veracity, Value",
//             "Visibility, Velocity, Volume",
//             "Volume, Value, Veracity"
//           ],
//           correctAnswerIndex: 0,
//           explanation: "ビッグデータの「3V」は、データの大量性（Volume）、多様性（Variety）、速度（Velocity）を指し、ビッグデータを定義する上で重要な3つの特徴を表しています。"
//         ),
//          QuizQuestion(
//           question: "RDBMSの「R」は何を意味しているか？",
//           choices: [
//             "Rapid",
//             "Relational",
//             "Real-time",
//             "Recoverable"
//           ],
//           correctAnswerIndex: 1,
//           explanation: "RDBMSはRelational Database Management Systemの略で、関係型データベース管理システムを意味します。これは、データを表形式で管理し、行と列の関係を利用して効率的な検索と更新を行うシステムです。"
//         ),
//          QuizQuestion(
//           question: "ソフトウェア開発における「アジャイル」とは何か？",
//           choices: [
//             "プログラミング言語の一種",
//             "開発プロジェクトを迅速かつ柔軟に進める方法論",
//             "ソフトウェアのバグを自動的に修正するツール",
//             "データを安全に暗号化する技術"
//           ],
//           correctAnswerIndex: 1,
//           explanation: "アジャイルソフトウェア開発は、短い開発サイクル（スプリント）を通じて迅速かつ柔軟にソフトウェア開発プロジェクトを進めるための方法論です。顧客のフィードバックを積極的に取り入れ、変化に迅速に対応します。"
//         ),
//
//          QuizQuestion(
//           question: "次のうち、機密データを暗号化して安全に通信するために使用されるプロトコルはどれか？",
//           choices: [
//             "HTTP",
//             "HTTPS",
//             "FTP",
//             "SMTP"
//           ],
//           correctAnswerIndex: 1,
//           explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、通信を暗号化することによって、データの盗聴や改ざんを防ぐために使用されるプロトコルです。"
//         ),
//          QuizQuestion(
//           question: "クラウドコンピューティングのサービスモデルで、インフラストラクチャ（サーバーやストレージなど）をインターネット経由で提供するものは何か？",
//           choices: [
//             "Software as a Service (SaaS)",
//             "Platform as a Service (PaaS)",
//             "Infrastructure as a Service (IaaS)",
//             "Database as a Service (DaaS)"
//           ],
//           correctAnswerIndex: 2,
//           explanation: "IaaS（Infrastructure as a Service）は、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドサービスモデルです。"
//         ),
//          QuizQuestion(
//           question: "デジタル証明書を発行することで、ウェブサイトの身元を証明し、通信の安全を保証する組織は何か？",
//           choices: [
//             "インターネットサービスプロバイダ",
//             "ネットワーク管理者",
//             "認証局（Certificate Authority, CA）",
//             "ウェブホスティングサービス"
//           ],
//           correctAnswerIndex: 2,
//           explanation: "認証局（CA）は、デジタル証明書を発行することによって、ウェブサイトの身元を証明し、通信が安全であることを保証する組織です。"
//         )

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
