//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizQuestion {
    var question: String
    var choices: [String]
    var correctAnswerIndex: Int
    var explanation: String
}

struct QuizBeginnerList: View {
    @Binding var isPresenting: Bool
//    let quizBeginnerList: [QuizQuestion] = [
//        QuizQuestion(
//                question: "どのプロトコルがコンピュータのホスト名をIPアドレスに変換しますか？",
//                choices: [
//                    "ああああああああああああああああああああああああああああああ",
//                    "DNS",
//                    "FTP",
//                    "HTTP"
//                ],
//                correctAnswerIndex: 1,
//                explanation: "DNS（Domain Name System）は、コンピュータのホスト名をIPアドレスに変換するプロトコルです。"
//            ),
//        ]
    let quizBeginnerList: [QuizQuestion] = [
//        QuizQuestion(
//            question: "あああああああああああああああああああああああああああああああああああああああああああああああああああああああああ",
//            choices: [
//                "電源ケーブル",
//                "Eメールの添付ファイル",
//                "モニター",
//                "キーボード"
//            ],
//            correctAnswerIndex: 1,
//            explanation: " Eメールの添付ファイルは、コンピュータウイルスの感染経路として非常に一般的です。不明な送信元からのメールの添付ファイルは開かないよう注意が必要です。"
//        )
        QuizQuestion(
            question: "コンピュータウイルスの感染経路として最も一般的なものは？",
            choices: [
                "電源ケーブル",
                "Eメールの添付ファイル",
                "モニター",
                "キーボード"
            ],
            correctAnswerIndex: 1,
            explanation: " Eメールの添付ファイルは、コンピュータウイルスの感染経路として非常に一般的です。不明な送信元からのメールの添付ファイルは開かないよう注意が必要です。"
        ),

        QuizQuestion(
            question: "クラウドコンピューティングのサービスモデルで、インフラストラクチャを提供するものは？",
            choices: [
                "SaaS",
                "PaaS",
                "IaaS",
                "FaaS"
            ],
            correctAnswerIndex: 2,
            explanation: "IaaS（Infrastructure as a Service）は、インフラストラクチャを提供するクラウドサービスモデルです。"
        ),

        QuizQuestion(
            question: "プロジェクト管理手法で、タスク間の依存関係を線で結んで表現するものは？",
            choices: [
                "ガントチャート",
                "PERT図",
                "フローチャート",
                "マトリックス図"
            ],
            correctAnswerIndex: 1,
            explanation: "PERT図は、タスク間の依存関係を線で結んで表現するプロジェクト管理手法です。"
        ),

        QuizQuestion(
            question: "情報セキュリティのリスクを評価する際、リスクの大きさを算出するための要素は？",
            choices: [
                "脅威 x 脆弱性",
                "脅威 + 脆弱性",
                "脅威 - 脆弱性",
                "脅威 / 脆弱性"
            ],
            correctAnswerIndex: 0,
            explanation: "情報セキュリティのリスクの大きさは、「脅威」と「脆弱性」の積によって算出されます。"
        ),

        QuizQuestion(
            question: "データベースで、一意にレコードを特定するためのキーを何というか？",
            choices: [
                "外部キー",
                "主キー",
                "候補キー",
                "参照キー"
            ],
            correctAnswerIndex: 1,
            explanation: "主キーは、データベースのテーブル内でレコードを一意に特定するためのキーです。"
        ),

        QuizQuestion(
            question: "システム開発のライフサイクルの中で、システムが正しく動作するかを確認するフェーズは？",
            choices: [
                "要件定義",
                "設計",
                "実装",
                "テスト"
            ],
            correctAnswerIndex: 3,
            explanation: "システム開発のライフサイクルにおいて、システムが正しく動作するかを確認するフェーズは「テスト」フェーズです。"
        ),

        QuizQuestion(
            question: "ネットワークのトポロジで、すべてのデバイスが中央のデバイスに直接接続されている形状は？",
            choices: [
                "スター型",
                "バス型",
                "リング型",
                "メッシュ型"
            ],
            correctAnswerIndex: 0,
            explanation: "スター型トポロジは、すべてのデバイスが中央のデバイスに直接接続されているネットワークの形状です。"
        ),

        QuizQuestion(
            question: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？",
            choices: [
                "B2B",
                "B2C",
                "C2C",
                "CRM"
            ],
            correctAnswerIndex: 3,
            explanation: "CRM（Customer Relationship Management）は、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うビジネスモデルです。"
        ),

        QuizQuestion(
            question: "システムのバックアップ方法で、最後のフルバックアップ以降の変更分だけを保存する方法は？",
            choices: [
                "フルバックアップ",
                "差分バックアップ",
                "増分バックアップ",
                "ミラーバックアップ"
            ],
            correctAnswerIndex: 1,
            explanation: "最後のフルバックアップ以降の変更分だけを保存する方法を「差分バックアップ」といいます。"
        ),

        QuizQuestion(
            question: "ソフトウェアのライセンスで、ソースコードが公開され、自由に改変や再配布が許可されているものは？",
            choices: [
                "フリーウェア",
                "シェアウェア",
                "オープンソース",
                "クローズドソース"
            ],
            correctAnswerIndex: 2,
            explanation: "ソースコードが公開され、自由に改変や再配布が許可されているソフトウェアのライセンスを「オープンソース」といいます。"
        ),

        QuizQuestion(
            question: "ネットワークのアドレスで、インターネット上のコンピュータやネットワークを一意に識別するための番号は？",
            choices: [
                "MACアドレス",
                "IPアドレス",
                "URL",
                "DNS"
            ],
            correctAnswerIndex: 1,
            explanation: "インターネット上のコンピュータやネットワークを一意に識別するための番号は「IPアドレス」といいます。"
        ),

        QuizQuestion(
            question: "プログラミングで、同じ処理を繰り返し実行する制御構造は？",
            choices: [
                "分岐",
                "ループ",
                "ジャンプ",
                "スイッチ"
            ],
            correctAnswerIndex: 1,
            explanation: "同じ処理を繰り返し実行する制御構造を「ループ」といいます。"
        ),

        QuizQuestion(
            question: "データベースのトランザクション処理で、一連の処理が全て完了するか、あるいは全てなかったことにする性質は？",
            choices: [
                "分離性",
                "持続性",
                "一貫性",
                "原子性"
            ],
            correctAnswerIndex: 3,
            explanation: "一連の処理が全て完了するか、あるいは全てなかったことにする性質を「原子性」といいます。"
        ),

        QuizQuestion(
            question: "情報セキュリティの方針やルールを組織全体に明確に伝えるための文書は？",
            choices: [
                "SLA",
                "SOP",
                "NDA",
                "情報セキュリティポリシー"
            ],
            correctAnswerIndex: 3,
            explanation: "情報セキュリティの3つの基本的な要素として、機密性、完全性に続くものは「可用性」といいます。"
        ),

        QuizQuestion(
            question: "システム開発の手法で、短い期間を設けて繰り返し開発を行う方法は？",
            choices: [
                "スクラム",
                "ウォーターフォール",
                "スパイラル",
                "カンバン"
            ],
            correctAnswerIndex: 0,
            explanation: "短い期間を設けて繰り返し開発を行う方法を「スクラム」といいます。"
        ),
        QuizQuestion(
            question: "情報セキュリティの3つの基本的な要素として、機密性、完全性に続くものは何か？",
            choices: [
                "可用性",
                "可視性",
                "可変性",
                "可搬性"
            ],
            correctAnswerIndex: 0,
            explanation: "情報セキュリティの3つの基本的な要素として、機密性、完全性に続くものは「可用性」といいます。"
        ),

        QuizQuestion(
            question: "ウェブページの閲覧時に、サーバーとクライアント間で情報のやり取りを暗号化するためのプロトコルは何か？",
            choices: [
                "FTP",
                "HTTP",
                "HTTPS",
                "SMTP"
            ],
            correctAnswerIndex: 2,
            explanation: "サーバーとクライアント間で情報のやり取りを暗号化するためのプロトコルは「HTTPS」といいます。"
        ),

        QuizQuestion(
            question: "情報システムの開発手法で、繰り返し開発を行いながら、少しずつシステムを成熟させていく方法を何というか？",
            choices: [
                "ウォーターフォールモデル",
                "スパイラルモデル",
                "V字モデル",
                "アジャイルモデル"
            ],
            correctAnswerIndex: 1,
            explanation: "繰り返し開発を行いながら、少しずつシステムを成熟させていく方法を「スパイラルモデル」といいます。"
        ),

        QuizQuestion(
            question: "データベースの中で、データの重複を避けるために、データを複数のテーブルに分割することを何というか？",
            choices: [
                "正規化",
                "最適化",
                "集約",
                "分散"
            ],
            correctAnswerIndex: 0,
            explanation: "データの重複を避けるために、データを複数のテーブルに分割することを「正規化」といいます。"
        ),
            QuizQuestion(
                question: "クラウドコンピューティングの3つの主なサービスモデルの1つでないものは？",
                choices: ["IaaS", "PaaS", "CaaS", "SaaS"],
                correctAnswerIndex: 2,
                explanation: "クラウドコンピューティングの3つの主なサービスモデルはIaaS、PaaS、およびSaaSです。CaaSは含まれません。"
            ),
            QuizQuestion(
                question: "システム開発のライフサイクルモデルの一つで、反復的に製品を改善していくモデルは何か？",
                choices: ["ウォーターフォールモデル", "スパイラルモデル", "Vモデル", "アジャイルモデル"],
                correctAnswerIndex: 1,
                explanation: "スパイラルモデルは、反復的に製品を改善していく開発モデルです。"
            ),
            QuizQuestion(
                question: "プロジェクト管理で使用される、タスクの進捗を視覚的に表すツールは？",
                choices: ["Gantt Chart", "PERT Chart", "Flow Chart", "Network Diagram"],
                correctAnswerIndex: 0,
                explanation: "Gantt Chartは、タスクの進捗を視覚的に表すツールの一つです。"
            ),
            QuizQuestion(
                question: "情報セキュリティのCIAトライアドの「I」は何を指すか？",
                choices: ["Integrity", "Information", "Infrastructure", "Internet"],
                correctAnswerIndex: 0,
                explanation: "CIAトライアドの「I」はIntegrity（完全性）を指します。"
            ),
            QuizQuestion(
                question: "ソフトウェアのバージョン管理システムの一つは？",
                choices: ["Git", "Bit", "Kit", "Sit"],
                correctAnswerIndex: 0,
                explanation: "Gitは、ソフトウェアのバージョン管理システムの一つです。"
            ),
            QuizQuestion(
                question: "インターネットの通信プロトコルは？",
                choices: ["HTTP", "FTP", "TCP/IP", "All of the above"],
                correctAnswerIndex: 3,
                explanation: "HTTP, FTP, TCP/IP など、すべてがインターネットの通信プロトコルです。"
            ),
            QuizQuestion(
                question: "オペレーティングシステムの一つは？",
                choices: ["Windows", "Doors", "Gates", "Walls"],
                correctAnswerIndex: 0,
                explanation: "Windowsは一般的なオペレーティングシステムの一つです。"
            ),
            QuizQuestion(
                question: "インターネットでの安全な通信を確保するプロトコルは？",
                choices: ["HTTP", "HTTPS", "HTTPT", "HTTPX"],
                correctAnswerIndex: 1,
                explanation: "HTTPSは、安全な通信を確保するためのプロトコルです。"
            ),
            QuizQuestion(
                question: "データベース管理システム(DBMS)の一つは？",
                choices: ["MySQL", "MySquare", "MyCircle", "MyTriangle"],
                correctAnswerIndex: 0,
                explanation: "MySQLは、リレーショナルデータベース管理システムの一つです。"
            ),
            QuizQuestion(
                question: "オブジェクト指向プログラミングの4つの主な特性の一つでないものは？",
                choices: ["継承", "カプセル化", "多態性", "分割"],
                correctAnswerIndex: 3,
                explanation: "オブジェクト指向プログラミングの主な特性には、継承、カプセル化、および多態性が含まれますが、分割は含まれません。"
            ),
            QuizQuestion(
                question: "プログラミング言語の一つは？",
                choices: ["Python", "Cobra", "Viper", "Mamba"],
                correctAnswerIndex: 0,
                explanation: "Pythonは、広く使用されているプログラミング言語の一つです。"
            ),
            QuizQuestion(
                question: "ソフトウェアテストの種類の一つは？",
                choices: ["ユニットテスト", "グループテスト", "ブロックテスト", "セグメントテスト"],
                correctAnswerIndex: 0,
                explanation: "ユニットテストは、ソフトウェアの個々の部分をテストするプロセスです。"
            ),
            QuizQuestion(
                question: "ソフトウェア開発手法の一つは？",
                choices: ["Scrum", "Jog", "Run", "Walk"],
                correctAnswerIndex: 0,
                explanation: "Scrumは、アジャイル開発の一形態で、イテラティブかつインクリメンタルな開発手法です。"
            ),
            QuizQuestion(
                question: "ウェブ開発で使用されるマークアップ言語は？",
                choices: ["HTML", "HTXL", "HTMLL", "HTMML"],
                correctAnswerIndex: 0,
                explanation: "HTMLは、ウェブページを作成するための標準的なマークアップ言語です。"
            ),
            QuizQuestion(
                question: "インターネットのドメイン名の一部として使用されるものは？",
                choices: [".com", ".net", ".org", "All of the above"],
                correctAnswerIndex: 3,
                explanation: ".com, .net, .org は、インターネットのドメイン名の一部として使用されるトップレベルドメインです。"
            ),
            QuizQuestion(
                question: "ネットワークのトポロジの一つは？",
                choices: ["スター", "ツリー", "メッシュ", "All of the above"],
                correctAnswerIndex: 3,
                explanation: "スター、ツリー、メッシュは、ネットワークのトポロジの種類です。"
            ),
            QuizQuestion(
                question: "ソフトウェアライセンスの一つは？",
                choices: ["GPL", "APL", "BPL", "CPL"],
                correctAnswerIndex: 0,
                explanation: "GPLは、ソフトウェアを自由に使用、修正、および配布することを許可するライセンスです。"
            ),
            QuizQuestion(
                question: "ウェブブラウザの一つは？",
                choices: ["Chrome", "Silver", "Gold", "Bronze"],
                correctAnswerIndex: 0,
                explanation: "Chromeは、Googleによって開発されたウェブブラウザです。"
            ),
            QuizQuestion(
                question: "ウェブ開発で使用されるスクリプト言語の一つは？",
                choices: ["JavaScript", "JavaNote", "JavaBook", "JavaPage"],
                correctAnswerIndex: 0,
                explanation: "JavaScriptは、ウェブページに対してインタラクティブな機能を追加するために使用されるプログラミング言語です。"
            ),
            QuizQuestion(
                question: "コンピュータネットワークの標準プロトコルの集合は何と呼ばれるか？",
                choices: ["Internet Protocol Suite", "Internet Protocol Set", "Internet Protocol Group", "Internet Protocol Bunch"],
                correctAnswerIndex: 0,
                explanation: "Internet Protocol Suiteは、インターネットプロトコルの集合を指します。"
            )
    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
    }

    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .beginner, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting)
    }
}

struct QuizList_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList(isPresenting: .constant(false))
    }
}
