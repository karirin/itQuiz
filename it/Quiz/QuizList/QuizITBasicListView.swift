//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizITBasicList: View {
    @Binding var isPresenting: Bool
    let quizBeginnerList: [QuizQuestion] = [
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
        )
        ,

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
            explanation: "情報セキュリティポリシーは、組織の情報セキュリティの方針やルールを明確に伝えるための文書です。このポリシーは、機密性、完全性、および可用性を保護するための基本的な指針と規則を提供します。"
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
                question: "機械学習で用いられることが多いプログラミング言語の一つは？",
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
            ),
        // 2024/3/4 追加の問題
        QuizQuestion(
               question: "ウェブサイトを作成する際に、構造を定義するために使用される言語は何か？",
               choices: [
                   "CSS",
                   "JavaScript",
                   "HTML",
                   "PHP"
               ],
               correctAnswerIndex: 2,
               explanation: "HTML（HyperText Markup Language）は、ウェブページの構造を定義するために使用される標準的なマークアップ言語です。"
           ),
           QuizQuestion(
               question: "コンピュータネットワークにおける「MACアドレス」の主な目的は何か？",
               choices: [
                   "デバイスの物理的な位置を特定する",
                   "ネットワーク上のデバイス間のデータ転送速度を制御する",
                   "ネットワーク上のデバイスを物理的に識別する",
                   "インターネット接続のセキュリティを強化する"
               ],
               correctAnswerIndex: 2,
               explanation: "MACアドレス（Media Access Control Address）は、ネットワーク上のデバイスを物理的に識別するための一意の識別子です。"
           ),
           QuizQuestion(
               question: "ウェブ開発において、クライアントサイドスクリプトを実行するために主に使用される言語は何か？",
               choices: [
                   "C++",
                   "Java",
                   "JavaScript",
                   "Python"
               ],
               correctAnswerIndex: 2,
               explanation: "JavaScriptは、ウェブブラウザ内でクライアントサイドスクリプトを実行するために広く使用されているプログラミング言語です。"
           ),
           QuizQuestion(
               question: "コンピュータの主記憶装置として使用される、電源が切れるとデータが失われるメモリは何か？",
               choices: [
                   "ROM",
                   "SSD",
                   "HDD",
                   "RAM"
               ],
               correctAnswerIndex: 3,
               explanation: "RAM（Random Access Memory）は、データの読み書きが高速に行える一時的なデータ記憶装置で、電源が切れるとデータが失われます。"
           ),
           QuizQuestion(
               question: "インターネット上で安全に情報を送受信するために使用されるプロトコルは何か？",
               choices: [
                   "HTTP",
                   "FTP",
                   "HTTPS",
                   "SMTP"
               ],
               correctAnswerIndex: 2,
               explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、SSL/TLSによる暗号化を利用してインターネット上でデータを安全に送受信するためのプロトコルです。"
           ),
           QuizQuestion(
               question: "ネットワークセキュリティで使用される「ファイアウォール」とは何をする装置またはソフトウェアか？",
               choices: [
                   "ウイルスを検出して除去する",
                   "不正アクセスを防ぎ、ネットワークへの入退出を管理する",
                   "データのバックアップを取る",
                   "インターネットの速度を向上させる"
               ],
               correctAnswerIndex: 1,
               explanation: "ファイアウォールは、不正アクセスからネットワークを保護し、許可された通信のみを通過させるセキュリティ装置またはソフトウェアです。"
           ),
           QuizQuestion(
               question: "オブジェクト指向プログラミングにおいて、複数の基底クラスから継承を行うことを何というか？",
               choices: [
                   "インターフェース",
                   "ポリモーフィズム",
                   "エンカプセレーション",
                   "多重継承"
               ],
               correctAnswerIndex: 3,
               explanation: "多重継承は、一つのクラスが複数の基底クラスから継承を行うオブジェクト指向プログラミングの特徴です。"
           ),
           QuizQuestion(
               question: "コンピュータプログラムにおいて、エラーが発生した際にプログラムの実行を安全に停止させるための機構は何か？",
               choices: [
                   "ループ",
                   "例外処理",
                   "マクロ",
                   "コールバック"
               ],
               correctAnswerIndex: 1,
               explanation: "例外処理は、エラーが発生した際にプログラムの実行を安全に制御し、適切に処理するためのプログラミングの機構です。"
           ),
           QuizQuestion(
               question: "Webページのアドレスを指定するために使用されるテキストは何か？",
               choices: [
                   "IPアドレス",
                   "URL",
                   "URI",
                   "DNS"
               ],
               correctAnswerIndex: 1,
               explanation: "URL（Uniform Resource Locator）は、Webページのアドレスを指定するために使用されるテキスト形式のアドレスです。"
           ),
           QuizQuestion(
               question: "プログラミングにおいて、同じ種類のデータを連続して格納するデータ構造は何か？",
               choices: [
                   "配列",
                   "リスト",
                   "マップ",
                   "セット"
               ],
               correctAnswerIndex: 0,
               explanation: "配列は、同じ種類のデータを連続して格納するための基本的なデータ構造で、固定されたサイズを持ちます。"
           ),
           QuizQuestion(
               question: "ソフトウェア開発における「リファクタリング」とは何か？",
               choices: [
                   "ソフトウェアの機能を追加するプロセス",
                   "コードのパフォーマンスを向上させるプロセス",
                   "コードの可読性や構造を改善するプロセス",
                   "ソフトウェアのバグを修正するプロセス"
               ],
               correctAnswerIndex: 2,
               explanation: "リファクタリングは、ソフトウェアの外部の振る舞いを変えることなく、内部の構造や可読性を改善するプロセスです。"
           ),
           QuizQuestion(
               question: "「MVC」とは何の略称か？",
               choices: [
                   "Model View Controller",
                   "Main Virtual Computer",
                   "Managed Virtual Connectivity",
                   "Multiple Vector Configurations"
               ],
               correctAnswerIndex: 0,
               explanation: "MVCはModel View Controllerの略で、ソフトウェア開発におけるアーキテクチャパターンの一つです。"
           ),
           QuizQuestion(
               question: "インターネット通信において「SSL」とは何のために使われるか？",
               choices: [
                   "検索エンジンの最適化",
                   "データの暗号化",
                   "ウェブページのスピードアップ",
                   "ソーシャルメディアの統合"
               ],
               correctAnswerIndex: 1,
               explanation: "SSL（Secure Sockets Layer）は、インターネット上でデータを安全に送受信するために使用される暗号化プロトコルです。"
           ),
           QuizQuestion(
               question: "「クラウドコンピューティング」において、ユーザーが自分のプラットフォームやアプリケーションをホストできるサービスモデルは何か？",
               choices: [
                   "IaaS",
                   "PaaS",
                   "SaaS",
                   "FaaS"
               ],
               correctAnswerIndex: 1,
               explanation: "PaaS（Platform as a Service）は、開発者がアプリケーションを開発、実行、管理できるプラットフォームやツールを提供するクラウドサービスモデルです。"
           ),
           QuizQuestion(
               question: "ソフトウェア開発において、「アジャイル」とは何か？",
               choices: [
                   "開発プロジェクトを長期間にわたって計画する方法",
                   "開発プロセスを一度に完成させる方法",
                   "短いサイクルでの繰り返しにより柔軟に開発を進める方法",
                   "コードの量を最小限に抑えるプログラミングスタイル"
               ],
               correctAnswerIndex: 2,
               explanation: "アジャイル開発は、変更に対応しやすい柔軟な開発プロセスを可能にする方法論で、短いサイクルでの繰り返しを特徴とします。"
           ),
           QuizQuestion(
               question: "インターネットプロトコルスイートのうち、エンドツーエンドのデータ伝送を担う層はどれか？",
               choices: [
                   "アプリケーション層",
                   "トランスポート層",
                   "インターネット層",
                   "ネットワークインターフェース層"
               ],
               correctAnswerIndex: 1,
               explanation: "トランスポート層は、エンドツーエンドでのデータ伝送とデータフローの制御を担当する層です。"
           ),
           QuizQuestion(
               question: "ウェブページのコンテンツを動的に更新するために使われる技術は何か？",
               choices: [
                   "CSS",
                   "HTML",
                   "JavaScript",
                   "PHP"
               ],
               correctAnswerIndex: 2,
               explanation: "JavaScriptは、クライアントサイドでウェブページのコンテンツを動的に更新するために使用されるプログラミング言語です。"
           ),
           QuizQuestion(
               question: "コンピュータネットワークにおいて、複数のネットワークを接続する装置は何か？",
               choices: [
                   "ルーター",
                   "スイッチ",
                   "ハブ",
                   "ブリッジ"
               ],
               correctAnswerIndex: 0,
               explanation: "ルーターは、異なるネットワーク間でデータパケットを転送し、ネットワークを接続する装置です。"
           ),
           QuizQuestion(
               question: "データベースの正規化において、非効率的なデータの重複を排除し、データ構造を最適化する目的は何か？",
               choices: [
                   "データの整合性を保つ",
                   "データのセキュリティを向上させる",
                   "クエリのパフォーマンスを向上させる",
                   "すべての上記"
               ],
               correctAnswerIndex: 3,
               explanation: "データベースの正規化は、データの整合性を保ち、セキュリティを向上させ、クエリのパフォーマンスを向上させることを目的としています。"
           ),
           QuizQuestion(
               question: "ウェブ開発において、動的コンテンツの生成によく使用されるプログラミング言語はどれか？",
               choices: [
                   "HTML",
                   "CSS",
                   "JavaScript",
                   "PHP"
               ],
               correctAnswerIndex: 3,
               explanation: "PHPはサーバーサイドで動作し、動的なウェブページの生成に広く使用されるプログラミング言語です。"
           ),
           QuizQuestion(
               question: "コンピュータネットワークにおける「ファイアウォール」の主な目的は何か？",
               choices: [
                   "データのバックアップ",
                   "インターネット速度の向上",
                   "不正アクセスの防止",
                   "メールのフィルタリング"
               ],
               correctAnswerIndex: 2,
               explanation: "ファイアウォールは、不正アクセスやネットワーク上の不要なトラフィックを防ぐためのセキュリティシステムです。"
           ),
           QuizQuestion(
               question: "ソフトウェア開発における「アジャイル」とは、何に重点を置いた開発手法か？",
               choices: [
                   "長期計画",
                   "文書化",
                   "プロセス",
                   "柔軟性と迅速な対応"
               ],
               correctAnswerIndex: 3,
               explanation: "アジャイル開発は、変化に柔軟に対応し、短い開発サイクルを通じて迅速に製品を改善していく手法です。"
           ),
           QuizQuestion(
               question: "「クラウドストレージ」サービスの利点は何か？",
               choices: [
                   "高速なデータアクセス",
                   "ローカルストレージの節約",
                   "データのリモートアクセス",
                   "すべての上記"
               ],
               correctAnswerIndex: 3,
               explanation: "クラウドストレージサービスは、ローカルストレージの節約、どこからでもデータへのアクセス、高速なデータアクセスを提供します。"
           ),
           QuizQuestion(
               question: "プログラミングにおいて、エラーが発生しやすいコードの部分を何と呼ぶか？",
               choices: [
                   "バグゾーン",
                   "リスクエリア",
                   "ホットスポット",
                   "コードスメル"
               ],
               correctAnswerIndex: 3,
               explanation: "コードスメルは、将来的にバグや問題を引き起こす可能性がある、プログラムの中で品質が低い部分を指します。"
           ),
          QuizQuestion(
              question: "オペレーティングシステム(OS)の主な役割は何か？",
              choices: [
                  "ソフトウェアの開発",
                  "ハードウェアとソフトウェアの仲介",
                  "ウェブサイトのホスティング",
                  "電子メールの送受信"
              ],
              correctAnswerIndex: 1,
              explanation: "オペレーティングシステムは、ハードウェアリソースの管理と、アプリケーションソフトウェアがハードウェアと対話できるようにする役割を持っています。"
          ),
          QuizQuestion(
              question: "ネットワークでの「IPアドレス」の役割は何か？",
              choices: [
                  "データの圧縮",
                  "デバイスの識別",
                  "プログラミング",
                  "ゲームの開発"
              ],
              correctAnswerIndex: 1,
              explanation: "IPアドレスは、インターネット上のデバイスを一意に識別するために使用されます。"
          ),
          QuizQuestion(
              question: "オブジェクト指向プログラミングの特徴ではないものは？",
              choices: [
                  "カプセル化",
                  "継承",
                  "多様性",
                  "直列化"
              ],
              correctAnswerIndex: 3,
              explanation: "直列化はオブジェクト指向プログラミングの特徴ではなく、オブジェクトの状態を保存または転送可能な形式に変換するプロセスを指します。"
          ),
          QuizQuestion(
              question: "「フィッシング攻撃」とは何か？",
              choices: [
                  "コンピュータに物理的な損害を与える行為",
                  "不正な方法で個人情報を盗み出す詐欺行為",
                  "ウイルスをメールで送信する行為",
                  "インターネット速度を遅くする攻撃"
              ],
              correctAnswerIndex: 1,
              explanation: "フィッシング攻撃は、偽のウェブサイトやメールなどを用いて、ユーザーから個人情報を騙し取る詐欺行為です。"
          ),
          QuizQuestion(
              question: "ソフトウェア開発プロジェクトで、要件収集と分析を行うフェーズはどれか？",
              choices: [
                  "設計",
                  "実装",
                  "テスト",
                  "要件定義"
              ],
              correctAnswerIndex: 3,
              explanation: "要件定義フェーズでは、プロジェクトの目的、機能、システムの要件などを収集し、分析します。"
          ),
          QuizQuestion(
              question: "コンピュータネットワークにおいて、データを送受信するために使われるデバイスは？",
              choices: [
                  "モデム",
                  "プロセッサ",
                  "ストレージ",
                  "マザーボード"
              ],
              correctAnswerIndex: 0,
              explanation: "モデムは、インターネットなどのネットワークにデバイスを接続し、データの送受信を可能にするデバイスです。"
          ),
          QuizQuestion(
              question: "Webページを構成する基本的な3つの技術とは何か？",
              choices: [
                  "HTML、CSS、JavaScript",
                  "PHP、Python、Ruby",
                  "MySQL、MongoDB、PostgreSQL",
                  "Apache、Nginx、IIS"
              ],
              correctAnswerIndex: 0,
              explanation: "HTMLはページの構造を、CSSはスタイリングを、JavaScriptはインタラクティブな動作をそれぞれ担当します。"
          ),
          QuizQuestion(
              question: "インターネット上で安全なデータのやりとりを保証するために使用されるプロトコルはどれか？",
              choices: [
                  "HTTP",
                  "HTTPS",
                  "FTP",
                  "SMTP"
              ],
              correctAnswerIndex: 1,
              explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、SSL/TLSを用いて通信を暗号化し、安全なデータ交換を実現します。"
          ),
          QuizQuestion(
              question: "プログラミング言語Pythonでリスト内の全要素を合計する関数はどれか？",
              choices: [
                  "sum()",
                  "total()",
                  "combine()",
                  "add()"
              ],
              correctAnswerIndex: 0,
              explanation: "Pythonの組み込み関数sum()は、イテラブル（例えばリスト）内の全要素の合計を計算します。"
          ),
          QuizQuestion(
              question: "インターネットで情報を検索するために使用されるプログラムは何か？",
              choices: [
                  "ウェブサーバー",
                  "ウェブブラウザ",
                  "ウェブデザイナー",
                  "ウェブデベロッパー"
              ],
              correctAnswerIndex: 1,
              explanation: "ウェブブラウザは、インターネットで情報を検索し、ウェブページを表示するために使用されるプログラムです。"
          ),
          QuizQuestion(
              question: "コンピュータプログラムのバグを見つけて修正するプロセスを何というか？",
              choices: [
                  "コンパイリング",
                  "デバッギング",
                  "リファクタリング",
                  "テスト実行"
              ],
              correctAnswerIndex: 1,
              explanation: "デバッギングは、コンピュータプログラムのバグを見つけて修正するプロセスです。"
          ),
          QuizQuestion(
              question: "ウェブ開発でスタイルとレイアウトを定義するために使用される言語は何か？",
              choices: [
                  "HTML",
                  "CSS",
                  "JavaScript",
                  "Python"
              ],
              correctAnswerIndex: 1,
              explanation: "CSS（Cascading Style Sheets）は、ウェブページのスタイルとレイアウトを定義するために使用される言語です。"
          ),
          QuizQuestion(
              question: "プログラミングにおいて、同じコードを繰り返し実行しないようにするプラクティスは何か？",
              choices: [
                  "コードクローニング",
                  "コードリファクタリング",
                  "コードリサイクル",
                  "DRY（Don't Repeat Yourself）"
              ],
              correctAnswerIndex: 3,
              explanation: "DRY（Don't Repeat Yourself）は、同じコードを繰り返し実行しないようにするプログラミングのプラクティスです。"
          ),
          QuizQuestion(
              question: "ネットワークにおけるIPアドレスの役割は何か？",
              choices: [
                  "ネットワーク上のデバイスを識別する",
                  "ネットワークの速度を向上させる",
                  "ネットワークのセキュリティを強化する",
                  "ネットワーク上でのプリンター共有を可能にする"
              ],
              correctAnswerIndex: 0,
              explanation: "IPアドレスは、インターネットプロトコルネットワーク上の各デバイスを一意に識別するために使用される数値のラベルです。"
          ),

        // 追加問題（基礎理解）
        QuizQuestion(
            question: "ランサムウェアとは何か？",
            choices: [
                "コンピュータの動作を高速化するソフトウェア",
                "データを暗号化し、身代金を要求するマルウェア",
                "ネットワーク上のデータを監視するソフトウェア",
                "不正アクセスを検知するシステム"
            ],
            correctAnswerIndex: 1,
            explanation: "ランサムウェアは、感染したコンピュータ上のデータを暗号化し、復号と引き換えに金銭（身代金）を要求するマルウェアです。"
        ),
        QuizQuestion(
            question: "ソフトウェアの「ウォーターフォールモデル」の特徴として正しいものはどれか？",
            choices: [
                "各フェーズを反復して開発を進める",
                "各フェーズを順番に実施し、前のフェーズに戻らない",
                "顧客と毎週ミーティングを行う",
                "短いサイクルで機能をリリースする"
            ],
            correctAnswerIndex: 1,
            explanation: "ウォーターフォールモデルは、要件定義→設計→実装→テスト→運用という各フェーズを順番に実施し、原則として前のフェーズに戻らない開発手法です。"
        ),
        QuizQuestion(
            question: "ネットワークにおける「LANとWAN」の説明として正しいものはどれか？",
            choices: [
                "LANは広域ネットワーク、WANは構内ネットワーク",
                "LANは構内ネットワーク、WANは広域ネットワーク",
                "LANとWANは同じ意味で使われる",
                "LANは有線のみ、WANは無線のみ"
            ],
            correctAnswerIndex: 1,
            explanation: "LAN（Local Area Network）は建物内などの構内ネットワーク、WAN（Wide Area Network）は地理的に離れた場所を結ぶ広域ネットワークです。"
        ),
        QuizQuestion(
            question: "「IoT（Internet of Things）」の説明として正しいものはどれか？",
            choices: [
                "インターネット上の仮想通貨取引",
                "様々な物がインターネットに接続される概念",
                "クラウド上でのデータ保管サービス",
                "AIによる自動翻訳システム"
            ],
            correctAnswerIndex: 1,
            explanation: "IoT（モノのインターネット）は、家電・センサー・自動車など様々な物がインターネットに接続され、データを収集・活用する概念です。"
        ),
        QuizQuestion(
            question: "「AI（人工知能）」における「機械学習」の説明として正しいものはどれか？",
            choices: [
                "人間がすべてのルールをプログラムする手法",
                "データから自動的にパターンや規則を学習する手法",
                "ロボットが自律的に動く技術",
                "コンピュータが人間の言語を翻訳する技術"
            ],
            correctAnswerIndex: 1,
            explanation: "機械学習は、コンピュータが大量のデータを分析し、人間が明示的にプログラムしなくてもパターンや規則を自動的に学習する技術です。"
        ),
        QuizQuestion(
            question: "「マルウェア」とは何の総称か？",
            choices: [
                "古くなったソフトウェア",
                "悪意のあるソフトウェア全般",
                "無料のソフトウェア",
                "テスト用のソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "マルウェア（Malware）は、「malicious（悪意のある）」と「software（ソフトウェア）」の合成語で、ウイルス・ワーム・トロイの木馬・ランサムウェアなど悪意のあるソフトウェア全般の総称です。"
        ),
        QuizQuestion(
            question: "「ディープラーニング（深層学習）」について正しい説明はどれか？",
            choices: [
                "人間が明示したルールに基づいて動作する",
                "多層のニューラルネットワークを用いた機械学習",
                "データを単純な統計で分析する手法",
                "インターネット上の情報を検索する技術"
            ],
            correctAnswerIndex: 1,
            explanation: "ディープラーニングは、人間の脳の神経回路を模した多層のニューラルネットワークを用いて、画像認識・音声認識などの高度なパターン認識を行う機械学習の一手法です。"
        ),
        QuizQuestion(
            question: "「ソーシャルエンジニアリング」の説明として正しいものはどれか？",
            choices: [
                "SNSを活用したマーケティング手法",
                "技術的な手段を使わず、人の心理や行動を悪用して情報を騙し取る手口",
                "社会インフラのシステム開発手法",
                "複数のエンジニアが協力して開発する手法"
            ],
            correctAnswerIndex: 1,
            explanation: "ソーシャルエンジニアリングは、技術的な攻撃ではなく、電話・なりすましなど人の心理や信頼を悪用してパスワードや機密情報を不正に入手する攻撃手法です。"
        ),
        QuizQuestion(
            question: "「ブロックチェーン」の説明として正しいものはどれか？",
            choices: [
                "ウイルスをブロックする技術",
                "取引データをチェーン状に連結して分散管理する技術",
                "動画コンテンツを配信する技術",
                "ファイルを暗号化して保管する技術"
            ],
            correctAnswerIndex: 1,
            explanation: "ブロックチェーンは、取引データをブロック単位でまとめ、チェーン状に連結して複数のノードで分散管理する技術で、改ざんが非常に困難です。暗号通貨などに使われます。"
        ),
        QuizQuestion(
            question: "「レスポンシブウェブデザイン」の説明として正しいものはどれか？",
            choices: [
                "表示速度を最優先に設計されたWebデザイン",
                "PC・スマートフォン・タブレットなど様々な画面サイズに対応するデザイン手法",
                "視覚障がい者向けに音声読み上げを最適化したデザイン",
                "セキュリティを重視したWebデザイン"
            ],
            correctAnswerIndex: 1,
            explanation: "レスポンシブウェブデザインは、1つのHTMLファイルでPC・スマートフォン・タブレットなど異なる画面サイズや解像度に柔軟に対応するWebデザイン手法です。"
        ),
        QuizQuestion(
            question: "「DoS攻撃（Denial of Service）」の説明として正しいものはどれか？",
            choices: [
                "パスワードを盗み取る攻撃",
                "大量のリクエストを送りつけてサービスを利用不能にする攻撃",
                "ネットワーク上の通信を盗聴する攻撃",
                "Webサイトの見た目を改ざんする攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "DoS攻撃は、ターゲットのサーバーやネットワークに大量のリクエストを送りつけることで過負荷状態にし、正規ユーザーがサービスを利用できなくする攻撃です。"
        ),
        QuizQuestion(
            question: "「フィッシング詐欺」の説明として正しいものはどれか？",
            choices: [
                "コンピュータの処理を遅くする攻撃",
                "偽のWebサイトや電子メールで個人情報を騙し取る詐欺",
                "ネットワーク上の通信を傍受する攻撃",
                "コンピュータのデータを消去する攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "フィッシング詐欺は、銀行や通販サイトなどを装った偽のメールやWebサイトに誘導し、IDやパスワード・クレジットカード番号などを騙し取る詐欺の手口です。"
        ),
        QuizQuestion(
            question: "「OS（オペレーティングシステム）」の役割として正しいものはどれか？",
            choices: [
                "インターネットに接続するためだけのソフトウェア",
                "ハードウェアとアプリケーションソフトの間で資源を管理する基本ソフトウェア",
                "文書作成専用のソフトウェア",
                "ウイルスを除去するためのソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "OS（オペレーティングシステム）は、CPU・メモリ・ストレージなどのハードウェアを管理し、アプリケーションが動作する基盤を提供する基本ソフトウェアです。Windows・macOS・iOSなどが代表例です。"
        ),
        QuizQuestion(
            question: "「Webブラウザ」の役割として正しいものはどれか？",
            choices: [
                "電子メールを送受信するソフトウェア",
                "WebサイトのHTMLを解釈して画面に表示するソフトウェア",
                "コンピュータのウイルスを検出するソフトウェア",
                "ファイルを圧縮・解凍するソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "WebブラウザはHTMLやCSS・JavaScriptなどで書かれたWebページのデータを解釈し、画面に表示するソフトウェアです。Chrome・Safari・Edge・Firefoxなどが代表例です。"
        ),
        QuizQuestion(
            question: "「URL（Uniform Resource Locator）」の説明として正しいものはどれか？",
            choices: [
                "コンピュータを一意に識別する番号",
                "インターネット上のリソースの場所を示すアドレス",
                "ウイルスの種類を識別するコード",
                "ファイルの種類を示す拡張子"
            ],
            correctAnswerIndex: 1,
            explanation: "URLはインターネット上のWebページや画像・ファイルなどのリソースがどこにあるかを示す住所のようなものです。「https://www.example.com」の形式で表されます。"
        ),
        QuizQuestion(
            question: "「スパムメール」の説明として正しいものはどれか？",
            choices: [
                "暗号化されて読めないメール",
                "受信者の意図に関わらず大量に送りつけられる迷惑メール",
                "添付ファイルのないメール",
                "文字だけで画像のないメール"
            ],
            correctAnswerIndex: 1,
            explanation: "スパムメールは、受信者の同意なく大量に送りつけられる迷惑メールです。広告・詐欺・ウイルス感染を目的としたものが多く、フィルタリング機能で対策します。"
        ),
        QuizQuestion(
            question: "「QRコード」の説明として正しいものはどれか？",
            choices: [
                "バーコードの一種で、1次元のシマ模様でデータを表す",
                "2次元の正方形模様でURLや文字列などのデータを表すコード",
                "磁気テープに情報を記録したカード",
                "ICチップにデータを記録したカード"
            ],
            correctAnswerIndex: 1,
            explanation: "QRコード（Quick Response Code）は、縦横2次元の正方形パターンでURLや文字列などのデータを表すコードです。スマートフォンのカメラで読み取ることができます。"
        ),
        QuizQuestion(
            question: "「デジタルデバイド」の説明として正しいものはどれか？",
            choices: [
                "デジタル機器を分解すること",
                "ITを利用できる人とできない人との間に生じる格差",
                "デジタルデータを暗号化する技術",
                "インターネットの通信速度の差"
            ],
            correctAnswerIndex: 1,
            explanation: "デジタルデバイドは、インターネットやコンピュータなどのIT機器・サービスを使いこなせる人とそうでない人の間に生じる経済的・社会的格差のことです。"
        ),
        QuizQuestion(
            question: "安全なパスワードの設定方法として最も適切なものはどれか？",
            choices: [
                "覚えやすいように生年月日を使う",
                "英数字・記号を組み合わせた長いパスワードを複数のサービスで使い分ける",
                "全サービスで同じパスワードを使う",
                "4桁の数字のみのパスワードを設定する"
            ],
            correctAnswerIndex: 1,
            explanation: "安全なパスワードは、英字（大文字・小文字）・数字・記号を組み合わせ、十分な長さを持ち、サービスごとに異なるものを使用することが重要です。推測されやすい個人情報は避けましょう。"
        ),
        QuizQuestion(
            question: "「ウイルス対策ソフト（セキュリティソフト）」の主な目的はどれか？",
            choices: [
                "コンピュータの処理速度を上げる",
                "マルウェアの検出・削除やリアルタイムの脅威防御を行う",
                "インターネットの接続速度を上げる",
                "データを自動的にクラウドに保存する"
            ],
            correctAnswerIndex: 1,
            explanation: "ウイルス対策ソフトは、ウイルス・スパイウェア・ランサムウェアなどのマルウェアをリアルタイムで検出・削除し、コンピュータをセキュリティ脅威から守るソフトウェアです。"
        ),
        QuizQuestion(
            question: "「クラウドストレージ」の説明として正しいものはどれか？",
            choices: [
                "コンピュータ内蔵のSSDやHDDにデータを保存する",
                "インターネット上のサーバーにデータを保存・共有できるサービス",
                "USBメモリにデータを保存するサービス",
                "ネットワーク上のプリンターにデータを送るサービス"
            ],
            correctAnswerIndex: 1,
            explanation: "クラウドストレージは、インターネット経由でデータをサーバーに保存・管理できるサービスです。どこからでもアクセス可能で、デバイス間での共有も容易です。iCloud・Google Drive・OneDriveなどが代表例です。"
        ),
        QuizQuestion(
            question: "「スパイウェア」の説明として正しいものはどれか？",
            choices: [
                "コンピュータの処理速度を上げるソフトウェア",
                "ユーザーの行動や個人情報を秘密裏に収集・送信する悪意あるソフトウェア",
                "メールを自動送信するソフトウェア",
                "Webサイトの表示を高速化するソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "スパイウェアは、ユーザーの同意なくインストールされ、閲覧履歴・キー入力・個人情報などを秘密裏に収集して外部に送信するマルウェアです。"
        ),
        QuizQuestion(
            question: "「情報リテラシー」の説明として正しいものはどれか？",
            choices: [
                "プログラミングができる能力",
                "情報を適切に収集・評価・活用できる能力",
                "コンピュータを修理できる技術",
                "高速タイピングができる技術"
            ],
            correctAnswerIndex: 1,
            explanation: "情報リテラシーは、必要な情報を収集・選択・評価し、目的に応じて適切に活用できる能力のことです。情報の真偽を見極め、発信・共有する際の倫理的な判断も含まれます。"
        ),
        QuizQuestion(
            question: "「アプリケーションソフトウェア」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのハードウェアを直接制御するソフトウェア",
                "特定の業務や目的のためにOSの上で動作するソフトウェア",
                "OSの一部として提供されるシステムプログラム",
                "コンピュータの起動時に読み込まれるプログラム"
            ],
            correctAnswerIndex: 1,
            explanation: "アプリケーションソフトウェアは、文書作成・表計算・ゲームなど特定の目的のためにOSの上で動作するソフトウェアです。OSなどのシステムソフトウェアとは区別されます。"
        ),
        QuizQuestion(
            question: "「ソフトウェアのアップデート（更新）」を行う主な理由として正しいものはどれか？",
            choices: [
                "コンピュータの見た目を変えるため",
                "セキュリティの脆弱性修正や機能改善を行うため",
                "コンピュータのデータを削除するため",
                "インターネットの速度を上げるため"
            ],
            correctAnswerIndex: 1,
            explanation: "ソフトウェアのアップデートは、発見されたセキュリティの脆弱性（セキュリティホール）の修正、不具合の修正、新機能の追加が主な目的です。特にセキュリティパッチは速やかに適用することが重要です。"
        ),
        QuizQuestion(
            question: "「不正アクセス」の説明として正しいものはどれか？",
            choices: [
                "インターネットの通信速度が遅くなること",
                "権限のない者がコンピュータやシステムに無断で侵入すること",
                "ソフトウェアが正常に動作しなくなること",
                "メールが誤って送信されること"
            ],
            correctAnswerIndex: 1,
            explanation: "不正アクセスは、正当な権限を持たない者が他人のコンピュータやシステムに無断で侵入する行為です。日本では「不正アクセス禁止法」により禁止されています。"
        ),
        QuizQuestion(
            question: "「SNS（ソーシャルネットワーキングサービス）」を利用する上でのリスクとして適切なものはどれか？",
            choices: [
                "インターネットの速度が低下する",
                "個人情報の意図しない公開やなりすまし被害に遭う可能性がある",
                "コンピュータのストレージが不足する",
                "ウイルスが自動的に増殖する"
            ],
            correctAnswerIndex: 1,
            explanation: "SNSでは、投稿した個人情報が広範囲に拡散したり、アカウントを乗っ取られてなりすまし被害に遭う可能性があります。プライバシー設定の確認や、不審なリンクへのアクセスに注意が必要です。"
        ),
        QuizQuestion(
            question: "「情報セキュリティの3要素（CIAトライアド）」に含まれないものはどれか？",
            choices: ["機密性（Confidentiality）", "完全性（Integrity）", "可用性（Availability）", "拡張性（Scalability）"],
            correctAnswerIndex: 3,
            explanation: "情報セキュリティの3要素（CIAトライアド）は、機密性（許可された人だけがアクセス可能）・完全性（情報が正確で改ざんされていない）・可用性（必要なときに利用可能）の3つです。拡張性は含まれません。"
        ),
        QuizQuestion(
            question: "「コンピュータウイルス」と「ワーム」の違いとして正しいものはどれか？",
            choices: [
                "ウイルスは有害で、ワームは無害",
                "ウイルスは他のファイルに寄生して感染し、ワームは自己複製してネットワーク経由で拡散する",
                "ウイルスはWindowsのみに感染し、ワームはMacのみに感染する",
                "ウイルスとワームはまったく同じもの"
            ],
            correctAnswerIndex: 1,
            explanation: "ウイルスは既存のファイルやプログラムに寄生して感染を広げます。ワームは単独で動作し、ネットワークを通じて自己複製・拡散するマルウェアです。どちらも有害ですが動作の仕組みが異なります。"
        ),
        QuizQuestion(
            question: "「データのバックアップ」が重要な理由として最も適切なものはどれか？",
            choices: [
                "コンピュータの動作を速くするため",
                "障害・事故・ランサムウェア被害に備えてデータを復元できるようにするため",
                "ストレージの容量を増やすため",
                "インターネットの速度を向上させるため"
            ],
            correctAnswerIndex: 1,
            explanation: "バックアップは、ハードウェア故障・誤操作・災害・ランサムウェア被害などによりデータが失われた場合に復元できるよう、データのコピーを別の場所に保存しておくことです。定期的なバックアップが重要です。"
        ),
        QuizQuestion(
            question: "「二段階認証」と「パスワード認証のみ」を比較したとき、二段階認証の利点はどれか？",
            choices: [
                "ログインが速くなる",
                "パスワードが漏れても第二の認証要素がないとログインできないため安全性が高い",
                "パスワードを覚えなくてよくなる",
                "インターネット接続が不要になる"
            ],
            correctAnswerIndex: 1,
            explanation: "二段階認証は、パスワードに加えてSMSワンタイムパスワードや認証アプリなど別の認証を組み合わせる方法です。パスワードが流出しても、第二の認証がなければ不正ログインを防げます。"
        ),
        QuizQuestion(
            question: "データ容量の単位として、大きい順に正しく並んでいるものはどれか？",
            choices: [
                "GB → MB → KB → TB",
                "TB → GB → MB → KB",
                "KB → MB → GB → TB",
                "MB → GB → TB → KB"
            ],
            correctAnswerIndex: 1,
            explanation: "データ容量の単位は小さい順にKB（キロバイト）→MB（メガバイト）→GB（ギガバイト）→TB（テラバイト）です。それぞれ約1000倍の関係にあります（正確には1024倍）。"
        ),
        QuizQuestion(
            question: "公共の場所の「フリーWi-Fi（公衆無線LAN）」を利用する際の注意点として正しいものはどれか？",
            choices: [
                "誰でも自由に使えるため、セキュリティのリスクはまったくない",
                "通信内容が傍受される可能性があるため、重要な情報の送受信は避けるべきだ",
                "利用すると自動的にウイルスに感染する",
                "フリーWi-Fiはインターネットに接続できない"
            ],
            correctAnswerIndex: 1,
            explanation: "フリーWi-Fiは暗号化されていない場合があり、同じネットワーク上の第三者に通信内容を傍受されるリスクがあります。インターネットバンキングや個人情報の入力は避け、VPNの利用が推奨されます。"
        ),
        QuizQuestion(
            question: "「Bluetooth（ブルートゥース）」の説明として正しいものはどれか？",
            choices: [
                "インターネットに接続するための有線規格",
                "数メートル〜数十メートルの近距離で機器同士をワイヤレス接続する通信規格",
                "衛星を使った位置情報サービス",
                "データを長距離で無線転送する通信規格"
            ],
            correctAnswerIndex: 1,
            explanation: "Bluetoothは、スマートフォン・イヤホン・キーボードなどの機器を近距離でワイヤレス接続するための無線通信規格です。消費電力が低く、ケーブル不要で手軽に使えます。"
        ),
        QuizQuestion(
            question: "「電子商取引（EC：Electronic Commerce）」の説明として正しいものはどれか？",
            choices: [
                "電子部品の製造・販売",
                "インターネットなどのネットワークを通じて行われる商品やサービスの売買",
                "電子機器の修理サービス",
                "会社の電子文書管理システム"
            ],
            correctAnswerIndex: 1,
            explanation: "電子商取引（EC）は、インターネットを通じて商品やサービスを売買する取引形態です。Amazon・楽天などのネットショッピング、デジタルコンテンツの販売などが代表例です。"
        ),
        QuizQuestion(
            question: "「検索エンジン」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのCPUの別名",
                "インターネット上の情報を収集・整理し、キーワードで検索できるサービス",
                "電子メールを送るためのシステム",
                "ファイルをダウンロードするためのソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "検索エンジンは、インターネット上のWebページを自動収集・整理し、ユーザーがキーワードを入力することで関連情報を素早く見つけられるサービスです。Google・Yahoo!・Bingなどが代表例です。"
        ),
        QuizQuestion(
            question: "電子メールの「CC」と「BCC」の違いとして正しいものはどれか？",
            choices: [
                "CCとBCCはまったく同じ機能",
                "CCはすべての受信者に宛先が見えるが、BCCは他の受信者に宛先が見えない",
                "CCはメインの宛先、BCCは返信先",
                "BCCはファイルを添付するための項目"
            ],
            correctAnswerIndex: 1,
            explanation: "CC（カーボンコピー）はすべての受信者が他の受信者を確認できます。BCC（ブラインドカーボンコピー）は受信者のアドレスが他の受信者に見えないため、一斉送信時のプライバシー保護に使われます。"
        ),
        QuizQuestion(
            question: "ファイルの「拡張子」の役割として正しいものはどれか？",
            choices: [
                "ファイルのサイズを示す",
                "ファイルの種類や形式を識別するためのファイル名の末尾の文字列",
                "ファイルの作成者を示す",
                "ファイルの保存場所を示す"
            ],
            correctAnswerIndex: 1,
            explanation: "拡張子はファイル名の末尾に「.」（ドット）で区切られた文字列で、ファイルの種類を示します。.docx（Word文書）・.pdf（PDF）・.jpg（画像）・.mp4（動画）などがあります。"
        ),
        QuizQuestion(
            question: "「プライバシーポリシー」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのセキュリティ設定",
                "企業や組織が個人情報をどのように収集・利用・管理するかを示した方針",
                "インターネット接続の料金体系",
                "Webサイトの利用規約"
            ],
            correctAnswerIndex: 1,
            explanation: "プライバシーポリシーは、企業・組織がユーザーの個人情報（氏名・メアドなど）をどのような目的で収集し、どう管理・利用するかを明示した方針文書です。Webサービス利用前に確認することが重要です。"
        ),
        QuizQuestion(
            question: "WebサイトのCookie（クッキー）の基本的な役割として正しいものはどれか？",
            choices: [
                "コンピュータをウイルスから守る",
                "ユーザーのログイン状態や設定などをブラウザに一時保存する",
                "Webサイトの画像を高速表示する",
                "インターネットの通信を暗号化する"
            ],
            correctAnswerIndex: 1,
            explanation: "Cookieはウェブサーバーがブラウザに保存する小さなデータです。ログイン状態の維持・カートの内容保存・サイトの設定記憶などに使われます。第三者Cookieは広告のターゲティングにも利用されます。"
        ),
        QuizQuestion(
            question: "「5G（第5世代移動通信システム）」の特徴として正しいものはどれか？",
            choices: [
                "4Gと比べて通信速度が遅いが安定している",
                "超高速・超低遅延・多数同時接続を実現する通信規格",
                "Wi-Fiと同じ規格で屋内専用",
                "テキストメッセージのみ送受信できる通信規格"
            ],
            correctAnswerIndex: 1,
            explanation: "5Gは第5世代移動通信システムで、4Gと比べて超高速（最大20Gbps）・超低遅延・多数同時接続が特徴です。自動運転・遠隔医療・スマートファクトリーなどへの活用が期待されています。"
        ),
        QuizQuestion(
            question: "「GPS（全地球測位システム）」の説明として正しいものはどれか？",
            choices: [
                "インターネットの通信速度を測定するシステム",
                "複数の衛星からの電波を受信して現在地を特定するシステム",
                "コンピュータのグラフィック処理システム",
                "ネットワークのセキュリティを管理するシステム"
            ],
            correctAnswerIndex: 1,
            explanation: "GPSは複数の人工衛星から発信される電波を受信し、三角測量の原理で受信者の現在位置（緯度・経度・高度）を算出するシステムです。カーナビやスマートフォンの地図アプリに活用されています。"
        ),
        QuizQuestion(
            question: "「デジタル」と「アナログ」の違いとして正しいものはどれか？",
            choices: [
                "デジタルは古い技術で、アナログは新しい技術",
                "デジタルは0と1の離散値で情報を表し、アナログは連続した値で情報を表す",
                "デジタルは音声専用で、アナログは映像専用",
                "デジタルとアナログは同じ意味"
            ],
            correctAnswerIndex: 1,
            explanation: "デジタルは情報を0と1の組み合わせ（離散的な値）で表します。アナログは連続した値で情報を表します。CDはデジタル、レコードはアナログの例です。デジタルは劣化しにくく複製が容易という特徴があります。"
        ),
        QuizQuestion(
            question: "「圧縮ファイル（ZIP形式など）」を使う主な目的はどれか？",
            choices: [
                "ファイルを暗号化してセキュリティを高めるため",
                "複数ファイルをまとめてファイルサイズを小さくするため",
                "ファイルをクラウドに自動でアップロードするため",
                "ファイルのウイルスを除去するため"
            ],
            correctAnswerIndex: 1,
            explanation: "ZIP等の圧縮形式は、データを効率よく符号化してファイルサイズを小さくし、複数のファイルを1つにまとめることができます。メール添付やダウンロードの際に転送量を削減するために使われます。"
        ),
        QuizQuestion(
            question: "「ダウンロード」と「アップロード」の違いとして正しいものはどれか？",
            choices: [
                "ダウンロードはデータを作成し、アップロードはデータを削除すること",
                "ダウンロードはサーバーから手元の機器にデータを取り込み、アップロードは手元の機器からサーバーにデータを送ること",
                "ダウンロードとアップロードは同じ意味",
                "ダウンロードは有料で、アップロードは無料"
            ],
            correctAnswerIndex: 1,
            explanation: "ダウンロードはサーバー（インターネット側）からスマートフォンやPCにデータを受け取ることです。アップロードは逆に、手元のデータをサーバーに送信することです。"
        ),
        QuizQuestion(
            question: "「アクセシビリティ」のIT分野における説明として正しいものはどれか？",
            choices: [
                "Webサイトの表示速度を向上させること",
                "高齢者・障がい者を含む誰もがITシステムやWebサービスを利用しやすくすること",
                "システムへの不正アクセスを防ぐこと",
                "インターネットの接続を制限すること"
            ],
            correctAnswerIndex: 1,
            explanation: "アクセシビリティは、視覚・聴覚・運動機能に障がいのある方や高齢者も含め、誰もが使いやすいようにシステムやWebサービスを設計・提供することです。音声読み上げ対応・文字サイズ変更などが例です。"
        ),
        QuizQuestion(
            question: "「サブスクリプション（サブスク）」サービスの説明として正しいものはどれか？",
            choices: [
                "一度購入すると永久に使えるソフトウェアの販売形態",
                "月額・年額などの定額料金を払って継続的にサービスを利用する形態",
                "無料で提供されるサービス全般",
                "一回限りの購入で利用できるデジタルコンテンツ"
            ],
            correctAnswerIndex: 1,
            explanation: "サブスクリプションは、月額・年額などの定額を支払うことで、期間中はサービスを継続的に利用できるビジネスモデルです。音楽・動画配信・ソフトウェアなど様々な分野で普及しています。"
        ),
        QuizQuestion(
            question: "「VR（バーチャルリアリティ）」の説明として正しいものはどれか？",
            choices: [
                "現実世界にデジタル情報を重ねて表示する技術",
                "専用ゴーグルなどを使って人工的に作られた仮想空間に没入できる技術",
                "インターネットを使ったリモートワーク技術",
                "ウイルスを仮想環境で検査する技術"
            ],
            correctAnswerIndex: 1,
            explanation: "VR（仮想現実）は、専用のヘッドセットなどを装着することで、コンピュータが作り出した仮想空間に完全に没入できる技術です。ゲーム・医療・教育・訓練シミュレーションなどに活用されています。"
        ),
        QuizQuestion(
            question: "「AR（拡張現実）」の説明として正しいものはどれか？",
            choices: [
                "コンピュータが作り出した仮想空間に完全没入する技術",
                "現実の視界にデジタル情報を重ねて表示する技術",
                "人工知能が人間の代わりに作業する技術",
                "リアルタイムで映像を遠隔配信する技術"
            ],
            correctAnswerIndex: 1,
            explanation: "AR（拡張現実）は、スマートフォンのカメラや専用グラスを通じて、現実の風景にデジタル情報を重ねて表示する技術です。ポケモンGOや家具の配置シミュレーションアプリなどが身近な例です。"
        ),
        QuizQuestion(
            question: "「ICカード」の説明として正しいものはどれか？",
            choices: [
                "インターネットに接続するためのカード",
                "IC（集積回路）チップを内蔵し、データの読み書きができるカード",
                "磁気テープにデータを記録したカード",
                "クレジットカードの別名"
            ],
            correctAnswerIndex: 1,
            explanation: "ICカードは、プラスチックカードにIC（集積回路）チップを埋め込んだカードです。Suica・PASMOなどの交通系カード、マイナンバーカード、クレジットカードなどに使われています。磁気カードより大容量でセキュリティも高いです。"
        ),
        QuizQuestion(
            question: "「スマートフォン決済（QRコード決済・タッチ決済）」の説明として正しいものはどれか？",
            choices: [
                "スマートフォンを使って電話で商品を注文すること",
                "スマートフォンを使って現金なしでキャッシュレスで支払いを行うこと",
                "スマートフォンでレシートを撮影して管理すること",
                "スマートフォンでインターネットショッピングをすること"
            ],
            correctAnswerIndex: 1,
            explanation: "スマートフォン決済は、PayPay・LINE PayなどのQRコード読み取りや、NFC（非接触通信）を使ったタッチ決済で、スマートフォンを財布代わりにキャッシュレス支払いができるサービスです。"
        ),
        QuizQuestion(
            question: "「情報漏洩」が発生した場合の問題として最も適切なものはどれか？",
            choices: [
                "コンピュータの処理速度が低下する",
                "個人情報や機密情報が外部に流出し、プライバシー侵害や信頼失墜につながる",
                "インターネット接続ができなくなる",
                "ファイルが自動的に削除される"
            ],
            correctAnswerIndex: 1,
            explanation: "情報漏洩は、個人情報・顧客データ・企業機密などが外部に流出する事故です。プライバシーの侵害、経済的損失、信頼失墜につながります。USBの紛失・不正アクセス・内部不正などが原因となります。"
        ),
        QuizQuestion(
            question: "「e-Learning（イーラーニング）」の説明として正しいものはどれか？",
            choices: [
                "電子機器の修理を専門に行う職業",
                "インターネットやコンピュータを活用した学習形態",
                "学校でのプログラミング教育の総称",
                "電子書籍を使った読書活動"
            ],
            correctAnswerIndex: 1,
            explanation: "e-Learningは、コンピュータやインターネットを活用した学習形態です。時間・場所を選ばず、動画・テスト・教材を活用して学べます。企業研修・資格取得・語学学習など幅広く活用されています。"
        ),
        QuizQuestion(
            question: "「マルチメディア」の説明として正しいものはどれか？",
            choices: [
                "複数のコンピュータをネットワークで繋げること",
                "テキスト・画像・音声・動画など複数の媒体を組み合わせた情報表現",
                "複数のOSを1台のコンピュータで動かすこと",
                "複数の画面でコンピュータを操作すること"
            ],
            correctAnswerIndex: 1,
            explanation: "マルチメディアは、文字・静止画・音声・動画・アニメーションなど複数のメディア（媒体）を組み合わせてコンピュータで扱う情報表現のことです。Webサイト・デジタル教材・ゲームなどに活用されています。"
        ),
        QuizQuestion(
            question: "「オープンデータ」の説明として正しいものはどれか？",
            choices: [
                "パスワードなしでアクセスできるWebサイト",
                "政府や公共機関などが無償で公開し、誰でも自由に利用・再配布できるデータ",
                "企業の内部情報を社員だけが閲覧できるデータ",
                "インターネット上に違法にアップロードされたデータ"
            ],
            correctAnswerIndex: 1,
            explanation: "オープンデータは、政府・自治体・研究機関などが公開する、誰でも自由に利用・加工・再配布できるデータです。統計データ・地図・行政情報などが含まれ、新しいサービス開発や研究に活用されています。"
        ),
        QuizQuestion(
            question: "「スマートスピーカー（AIスピーカー）」の説明として正しいものはどれか？",
            choices: [
                "高音質の音楽再生専用スピーカー",
                "音声で操作でき、AIアシスタントが質問応答や家電操作などを行うスピーカー",
                "Bluetoothで接続するポータブルスピーカー",
                "防水機能を持つ屋外用スピーカー"
            ],
            correctAnswerIndex: 1,
            explanation: "スマートスピーカーはAIアシスタントを内蔵したスピーカーで、音声で話しかけることで天気・ニュース・音楽再生・スマート家電の操作などができます。Amazon Echo（Alexa）・Google Nest（Google アシスタント）などが代表例です。"
        ),
        QuizQuestion(
            question: "「チャットボット」の説明として正しいものはどれか？",
            choices: [
                "チャットアプリのアイコン（ボット）",
                "自動的に会話に応答するAIプログラム",
                "不正なチャットメッセージを送るウイルス",
                "チャット履歴を保存するソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "チャットボットは、ユーザーからのテキスト・音声の入力に対してAIが自動的に応答するプログラムです。企業のカスタマーサポート・ECサイトの問い合わせ・予約受付などに活用されています。"
        ),
        QuizQuestion(
            question: "「生体認証（バイオメトリクス認証）」の説明として正しいものはどれか？",
            choices: [
                "生年月日を使ってログインする認証方法",
                "指紋・顔・虹彩など人体固有の特徴を使って本人を確認する認証方法",
                "医療機関だけで使われる認証方法",
                "ペットの情報を使って認証する方法"
            ],
            correctAnswerIndex: 1,
            explanation: "生体認証は、指紋・顔・虹彩・声紋など人体に固有の特徴を使って本人確認を行う認証方式です。パスワードのように忘れたり盗まれたりするリスクが低く、スマートフォンのロック解除や入退室管理に使われています。"
        ),
        QuizQuestion(
            question: "「インターネットバンキング」の説明として正しいものはどれか？",
            choices: [
                "銀行ATMでの現金引き出しサービス",
                "インターネット経由で残高照会・振込・各種手続きができる銀行サービス",
                "インターネット上で仮想通貨を管理するサービス",
                "銀行が提供するインターネット接続サービス"
            ],
            correctAnswerIndex: 1,
            explanation: "インターネットバンキングは、PCやスマートフォンからインターネット経由で残高照会・振込・定期預金・各種設定変更などの銀行手続きが行えるサービスです。24時間利用可能ですが、フィッシング詐欺への注意が必要です。"
        ),
        QuizQuestion(
            question: "「ストリーミング」サービスの説明として正しいものはどれか？",
            choices: [
                "データを全てダウンロードしてから再生する方式",
                "データを受信しながらリアルタイムで再生する方式",
                "データをCDに焼いて再生する方式",
                "データをUSBメモリで転送する方式"
            ],
            correctAnswerIndex: 1,
            explanation: "ストリーミングは、動画・音楽などのデータを端末にすべてダウンロードせず、受信しながら順次再生する方式です。Netflix・YouTube・Spotifyなどがこの方式を採用しており、大容量のデータを保存せずに楽しめます。"
        ),
        QuizQuestion(
            question: "「ウェアラブルデバイス」の説明として正しいものはどれか？",
            choices: [
                "持ち運べるノートパソコン",
                "身に着けて使用するコンピュータデバイス",
                "洗濯できる電子機器",
                "折り畳み可能なタブレット"
            ],
            correctAnswerIndex: 1,
            explanation: "ウェアラブルデバイスは、腕・頭・体など身体に装着して使用するコンピュータ機器の総称です。スマートウォッチ・フィットネストラッカー・スマートグラスなどが代表例で、健康管理や通知確認などに使われます。"
        ),
        QuizQuestion(
            question: "「メタバース」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのメモリを増設すること",
                "インターネット上に構築された、人々が集まり交流できる仮想的な三次元空間",
                "メタデータを管理するデータベースシステム",
                "AR技術を使った地図アプリ"
            ],
            correctAnswerIndex: 1,
            explanation: "メタバースは、インターネット上に構築された仮想三次元空間で、アバターを通じて他者と交流したり、ゲーム・ショッピング・仕事・イベント参加などができる空間です。VRヘッドセットや一般的なPCからアクセスできます。"
        ),
        QuizQuestion(
            question: "「NFC（Near Field Communication）」の説明として正しいものはどれか？",
            choices: [
                "数キロメートル先まで通信できる長距離無線技術",
                "数センチメートル以内の近距離で非接触通信できる技術",
                "次世代の光ファイバー通信規格",
                "スマートフォン専用の無線充電規格"
            ],
            correctAnswerIndex: 1,
            explanation: "NFCは10cm程度の非常に近い距離で機器同士が無線通信できる技術です。Suicaなどの交通系ICカードへのタッチ・スマートフォン決済・名刺交換などに活用されています。"
        ),
        QuizQuestion(
            question: "「ネットいじめ」に関する説明として正しいものはどれか？",
            choices: [
                "オンラインゲームの対戦で負けること",
                "SNSや掲示板などを通じて特定の人を傷つけたり嫌がらせをしたりする行為",
                "インターネット上で商品の悪いレビューを書くこと",
                "オンライン広告をクリックしないこと"
            ],
            correctAnswerIndex: 1,
            explanation: "ネットいじめは、SNS・チャット・掲示板などを通じて誹謗中傷・個人情報の暴露・仲間外れなどを行う行為です。書き込みは半永久的に残る可能性があり、深刻な心理的ダメージを与えます。"
        ),
        QuizQuestion(
            question: "「ワンクリック詐欺」の説明として正しいものはどれか？",
            choices: [
                "一回のクリックで商品を購入させる正規サービス",
                "サイトをクリックしただけで不当に料金を請求する詐欺",
                "マウスをクリックできなくするウイルス",
                "一クリックでパスワードを盗む攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "ワンクリック詐欺は、アダルトサイトや動画サイトのリンクをクリックしただけで「登録完了」と表示し、不当な料金を請求する詐欺です。無視することが基本的な対処法で、連絡すると状況が悪化する場合があります。"
        ),
        QuizQuestion(
            question: "「情報モラル」の説明として正しいものはどれか？",
            choices: [
                "情報処理の技術的スキル",
                "情報通信を利用する際に求められる倫理観や思いやり・マナー",
                "情報セキュリティの専門資格",
                "コンピュータのプログラミング能力"
            ],
            correctAnswerIndex: 1,
            explanation: "情報モラルは、SNS・メール・Web利用時に他者を傷つけない・プライバシーを守る・著作権を尊重するなど、情報社会において求められる倫理観・マナー・責任感のことです。"
        ),
        QuizQuestion(
            question: "「フェイクニュース（偽情報）」への対処法として最も適切なものはどれか？",
            choices: [
                "SNSで流れてきた情報はすべて正しいのですぐシェアする",
                "情報源を確認し、複数の信頼できる情報源で裏付けを取ってから判断する",
                "テレビのニュースだけを信頼すればよい",
                "インターネットの情報は全て信用しない"
            ],
            correctAnswerIndex: 1,
            explanation: "フェイクニュース対策には、情報源（誰が発信しているか）の確認、複数の信頼できるメディアでの裏付け確認（ファクトチェック）が重要です。SNSで拡散された情報でも正確とは限りません。"
        ),
        QuizQuestion(
            question: "「クラウドソーシング」の説明として正しいものはどれか？",
            choices: [
                "クラウドサービスの外部委託",
                "インターネットを通じて不特定多数の人々に仕事を発注・受注するサービス",
                "クラウドストレージのデータを整理するサービス",
                "複数の会社が共同でシステムを開発すること"
            ],
            correctAnswerIndex: 1,
            explanation: "クラウドソーシングはインターネット上で仕事の発注者と受注者をマッチングするサービスです。デザイン・ライティング・プログラミングなど様々な仕事を、場所を問わず依頼・受注できます。"
        ),
        QuizQuestion(
            question: "「AIアシスタント（Siri・Googleアシスタント等）」の説明として正しいものはどれか？",
            choices: [
                "人間のアシスタントがオンラインで作業を代行するサービス",
                "音声や文字の指示を受けてスケジュール管理・検索・操作補助などを行うAI",
                "AIが自動的に株式取引を行うシステム",
                "チャット形式でプログラミングを学ぶAIサービス"
            ],
            correctAnswerIndex: 1,
            explanation: "AIアシスタントは、音声または文字での指示を理解して、天気確認・スケジュール管理・アプリ起動・調べ物などを自動で行うAIです。iPhoneのSiri、AndroidのGoogleアシスタント、AmazonのAlexaが代表例です。"
        ),
        QuizQuestion(
            question: "「スマートシティ」の説明として正しいものはどれか？",
            choices: [
                "高層ビルが多い大都市のこと",
                "ICTやAI・IoTを活用して都市の機能を効率化し、住民の生活の質を向上させる都市",
                "スマートフォンの普及率が高い都市",
                "電力消費量を最小化した省エネ都市"
            ],
            correctAnswerIndex: 1,
            explanation: "スマートシティは、IoT・AI・ビッグデータなどのデジタル技術を都市インフラ（交通・電力・医療・行政など）に活用し、効率化・環境負荷低減・住民サービス向上を目指す次世代都市の概念です。"
        ),
        QuizQuestion(
            question: "「ドローン」のIT・社会活用例として正しいものはどれか？",
            choices: [
                "インターネットの通信速度を上げる装置",
                "農業・物流・災害調査・空撮などに活用される無人航空機",
                "データセンターの冷却装置",
                "ワイヤレス充電を行う装置"
            ],
            correctAnswerIndex: 1,
            explanation: "ドローン（無人航空機）は、農薬散布・物流配送・インフラ点検・災害時の捜索・空撮など幅広い分野で活用されています。AI・GPSと組み合わせることで自律飛行も可能です。"
        ),
        QuizQuestion(
            question: "「マイナンバー（個人番号）」の説明として正しいものはどれか？",
            choices: [
                "銀行口座の番号",
                "日本に住む全ての人に割り当てられた12桁の個人識別番号",
                "運転免許証の番号",
                "会社員に割り当てられる社員番号"
            ],
            correctAnswerIndex: 1,
            explanation: "マイナンバーは、日本に住む全ての人（外国人を含む）に割り当てられた12桁の番号で、社会保障・税・災害対策の行政手続きを効率化するために使われます。マイナンバーカードには顔写真付きICカードが使われます。"
        ),
        QuizQuestion(
            question: "「パスワードマネージャー」の主な目的はどれか？",
            choices: [
                "パスワードを定期的に自動変更する",
                "複数のサービスのパスワードを暗号化して安全に一元管理するツール",
                "パスワードを全て削除するツール",
                "パスワードを他人に共有するツール"
            ],
            correctAnswerIndex: 1,
            explanation: "パスワードマネージャーは、各サービスの異なるパスワードを暗号化して安全に保管し、必要なときに自動入力してくれるツールです。強力なパスワードを使い分けながら、覚える負担を軽減できます。"
        ),
        QuizQuestion(
            question: "「セキュリティパッチ」の説明として正しいものはどれか？",
            choices: [
                "コンピュータの物理的な傷を修復するシール",
                "発見されたソフトウェアの脆弱性（セキュリティホール）を修正するプログラム",
                "ウイルス感染した際に表示される警告メッセージ",
                "ネットワークの通信を暗号化するソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "セキュリティパッチはOSやソフトウェアで発見されたセキュリティ上の欠陥（脆弱性）を修正するためのプログラムです。適用が遅れると攻撃者に悪用されるリスクがあるため、速やかなアップデートが重要です。"
        ),
        QuizQuestion(
            question: "「フリーウェア」と「シェアウェア」の違いとして正しいものはどれか？",
            choices: [
                "フリーウェアは有料で、シェアウェアは無料",
                "フリーウェアは無料で利用できるが、シェアウェアは試用後に購入が求められる",
                "フリーウェアとシェアウェアはまったく同じ意味",
                "フリーウェアはオープンソースで、シェアウェアはクローズドソース"
            ],
            correctAnswerIndex: 1,
            explanation: "フリーウェアは無料で使えるソフトウェアです。シェアウェアは一定期間または機能制限付きで試用でき、継続利用や全機能の使用には購入（ライセンス料の支払い）が必要なソフトウェアです。"
        ),
        QuizQuestion(
            question: "「ソフトウェアライセンス」の説明として正しいものはどれか？",
            choices: [
                "ソフトウェアを開発するための資格",
                "ソフトウェアの使用権・条件・制限を定めた許諾契約",
                "ソフトウェアの価格表",
                "ソフトウェアの動作環境に関する仕様書"
            ],
            correctAnswerIndex: 1,
            explanation: "ソフトウェアライセンスは、そのソフトウェアをどのような条件で使用できるかを定めた許諾契約です。インストール可能な台数・用途の制限・再配布の可否などが規定されています。無断コピーはライセンス違反になります。"
        ),
        QuizQuestion(
            question: "「ポッドキャスト」の説明として正しいものはどれか？",
            choices: [
                "ゲームのBGMを配信するサービス",
                "インターネット上で配信される音声や動画のエピソードシリーズ",
                "ポータブル音楽プレーヤーの一種",
                "ライブ中継専用の動画配信サービス"
            ],
            correctAnswerIndex: 1,
            explanation: "ポッドキャストは、インターネット上で配信される音声（一部動画）コンテンツのシリーズです。ニュース・教育・エンタメなど多様なジャンルがあり、スマートフォンで通勤中などにいつでも聴けるのが特徴です。"
        ),
        QuizQuestion(
            question: "「オンライン会議ツール（Web会議）」の特徴として正しいものはどれか？",
            choices: [
                "同じ部屋に集まらないと利用できない",
                "インターネットを通じて離れた場所の人々がリアルタイムで映像・音声で会話できる",
                "テキストチャットのみで音声は使えない",
                "1対1の通話のみで複数人では利用できない"
            ],
            correctAnswerIndex: 1,
            explanation: "オンライン会議ツールは、インターネット経由でリアルタイムの映像・音声通話・画面共有・チャットができるサービスです。Zoom・Microsoft Teams・Google Meetなどが代表例で、場所を問わず会議や打ち合わせが可能です。"
        ),
        QuizQuestion(
            question: "「デジタルウェルネス（デジタルウェルビーイング）」の説明として正しいものはどれか？",
            choices: [
                "高性能なデジタル医療機器のこと",
                "スマートフォンやSNSの使い過ぎを見直し、テクノロジーと健全な関係を築くこと",
                "デジタルコンテンツで健康情報を提供するサービス",
                "健康保険の電子申請サービス"
            ],
            correctAnswerIndex: 1,
            explanation: "デジタルウェルネスは、スマートフォンやSNSへの過度な依存・利用時間の管理・画面の見過ぎによる睡眠障害など、テクノロジーが心身に与える影響を意識し、バランスのとれた使い方を目指す考え方です。"
        ),
    ]
        
    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager.shared
    private var audioManager = AudioManager.shared

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .itBasic, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizITBasicList_Previews: PreviewProvider {
    static var previews: some View {
        QuizITBasicList(isPresenting: .constant(false))
    }
}
