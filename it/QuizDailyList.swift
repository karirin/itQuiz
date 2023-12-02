//
//  QuizDailyList.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/14.
//

import SwiftUI

struct QuizDailyList: View {
    @Binding var isPresenting: Bool
    let QuizDailyList: [QuizQuestion] = [
        QuizQuestion(
                question: "コンピュータのCPUが直接参照する情報を保存する場所を何というか？",
                choices: [
                    "HDD",
                    "RAM",
                    "SSD",
                    "ROM"
                ],
                correctAnswerIndex: 1,
                explanation: "RAM（Random Access Memory）は、CPUが直接参照する情報を一時的に保存する場所です。"
            ),
            QuizQuestion(
                question: "OSの役割として正しくないものはどれか？",
                choices: [
                    "ハードウェアの制御",
                    "アプリケーションの実行",
                    "電源の供給",
                    "ファイルシステムの管理"
                ],
                correctAnswerIndex: 2,
                explanation: "電源の供給はOSの役割ではありません。"
            ),
            QuizQuestion(
                question: "インターネット上でコンピュータやネットワークを一意に識別するための番号を何というか？",
                choices: [
                    "URL",
                    "HTTP",
                    "IPアドレス",
                    "HTML"
                ],
                correctAnswerIndex: 2,
                explanation: "IPアドレスは、インターネット上でコンピュータやネットワークを一意に識別するための番号です。"
            ),
        QuizQuestion(
                question: "プログラムのバグを修正する作業を何というか？",
                choices: [
                    "デバッギング",
                    "エンコーディング",
                    "コンパイリング",
                    "エクスポーティング"
                ],
                correctAnswerIndex: 0,
                explanation: "プログラムのバグを修正する作業をデバッギングと言います。"
            ),
            QuizQuestion(
                question: "データベースの設計段階で、実際のテーブルやカラムを決定する段階を何というか？",
                choices: [
                    "論理設計",
                    "物理設計",
                    "外部設計",
                    "内部設計"
                ],
                correctAnswerIndex: 1,
                explanation: "データベースの物理設計では、実際のテーブルやカラムを決定します。"
            ),
            QuizQuestion(
                question: "オブジェクト指向プログラミングにおいて、オブジェクトの特性や振る舞いを定義したものを何というか？",
                choices: [
                    "メソッド",
                    "プロパティ",
                    "クラス",
                    "インスタンス"
                ],
                correctAnswerIndex: 2,
                explanation: "クラスはオブジェクトの特性や振る舞いを定義します。"
            ),
            QuizQuestion(
                question: "Webページの見た目やレイアウトを制御する技術は何か？",
                choices: [
                    "HTML",
                    "CSS",
                    "JavaScript",
                    "PHP"
                ],
                correctAnswerIndex: 1,
                explanation: "CSSはWebページの見た目やレイアウトを制御する技術です。"
            ),
            QuizQuestion(
                question: "プログラムの実行中に発生する予期しない事象を何というか？",
                choices: [
                    "エラー",
                    "バグ",
                    "例外",
                    "イベント"
                ],
                correctAnswerIndex: 2,
                explanation: "プログラムの実行中に発生する予期しない事象を例外と言います。"
            ),
            QuizQuestion(
                question: "インターネットの基盤となる技術を何というか？",
                choices: [
                    "HTTP",
                    "HTML",
                    "TCP/IP",
                    "FTP"
                ],
                correctAnswerIndex: 2,
                explanation: "インターネットの基盤となる技術はTCP/IPです。"
            ),
            QuizQuestion(
                question: "Java言語で文字列を扱うクラスは何か？",
                choices: [
                    "Str",
                    "StringBuffer",
                    "String",
                    "Text"
                ],
                correctAnswerIndex: 2,
                explanation: "Java言語で文字列を扱うクラスはStringです。"
            ),
            QuizQuestion(
                question: "データベースで、データの重複を避けるための制約を何というか？",
                choices: [
                    "外部キー",
                    "主キー",
                    "インデックス",
                    "参照整合性"
                ],
                correctAnswerIndex: 1,
                explanation: "データの重複を避けるための制約は主キーです。"
            ),
            QuizQuestion(
                question: "ソフトウェアの開発手法で、短いサイクルを繰り返しながら開発を進める方法を何というか？",
                choices: [
                    "ウォーターフォールモデル",
                    "スパイラルモデル",
                    "Vモデル",
                    "アジャイル開発"
                ],
                correctAnswerIndex: 3,
                explanation: "短いサイクルを繰り返しながら開発を進める方法はアジャイル開発です。"
            ),
            QuizQuestion(
                question: "OSの役割として正しくないものはどれか？",
                choices: [
                    "ハードウェアの制御",
                    "ファイルの管理",
                    "ネットワークの設定",
                    "ビジネスロジックの処理"
                ],
                correctAnswerIndex: 3,
                explanation: "ビジネスロジックの処理はアプリケーションの役割であり、OSの直接の役割ではありません。"
            ),
            QuizQuestion(
                question: "次のうち、非関係データベース管理システム(RDBMS)はどれか？",
                choices: [
                    "MySQL",
                    "MongoDB",
                    "Redis",
                    "Cassandra"
                ],
                correctAnswerIndex: 1,
                explanation: "MongoDBはドキュメント指向の非関係データベース管理システムです。"
            ),
            QuizQuestion(
                question: "次のうち、オープンソースのWebサーバソフトウェアはどれか？",
                choices: [
                    "IIS",
                    "Apache",
                    "WebLogic",
                    "WebSphere"
                ],
                correctAnswerIndex: 1,
                explanation: "ApacheはオープンソースのWebサーバソフトウェアです。"
            ),
            QuizQuestion(
                question: "プログラム内で、変数の値が変更されないようにする修飾子を何というか？",
                choices: [
                    "static",
                    "public",
                    "private",
                    "final"
                ],
                correctAnswerIndex: 3,
                explanation: "変数の値が変更されないようにする修飾子はfinalです。"
            ),
            QuizQuestion(
                question: "次のうち、動的なWebページの生成に使用されるスクリプト言語はどれか？",
                choices: [
                    "HTML",
                    "CSS",
                    "JavaScript",
                    "XML"
                ],
                correctAnswerIndex: 2,
                explanation: "動的なWebページの生成に使用されるスクリプト言語はJavaScriptです。"
            ),
            QuizQuestion(
                question: "オブジェクト指向プログラミングにおける「継承」の主な目的は何か？",
                choices: [
                    "コードの再利用",
                    "データの保護",
                    "効率的なメモリ使用",
                    "高速な実行速度"
                ],
                correctAnswerIndex: 0,
                explanation: "オブジェクト指向プログラミングにおける「継承」の主な目的はコードの再利用です。"
            ),
        QuizQuestion(
               question: "次のうち、オペレーティングシステム(OS)の役割ではないものはどれか？",
               choices: [
                   "プロセス管理",
                   "メモリ管理",
                   "画像編集",
                   "デバイス管理"
               ],
               correctAnswerIndex: 2,
               explanation: "画像編集はアプリケーションソフトウェアの役割であり、OSの役割ではありません。"
           ),
           QuizQuestion(
               question: "次のうち、プログラミング言語の1つであるのはどれか？",
               choices: [
                   "HTML",
                   "Python",
                   "HTTP",
                   "FTP"
               ],
               correctAnswerIndex: 1,
               explanation: "Pythonはプログラミング言語の1つです。"
           ),
           QuizQuestion(
               question: "ソフトウェアのバグを修正するためのソフトウェアの更新を何というか？",
               choices: [
                   "Upgrade",
                   "Patch",
                   "Install",
                   "Deploy"
               ],
               correctAnswerIndex: 1,
               explanation: "ソフトウェアのバグを修正するためのソフトウェアの更新をPatchと呼びます。"
           ),
           QuizQuestion(
               question: "次のうち、関係データベース管理システム(RDBMS)の特徴ではないものはどれか？",
               choices: [
                   "テーブル構造",
                   "非構造化データ",
                   "主キーと外部キー",
                   "正規化"
               ],
               correctAnswerIndex: 1,
               explanation: "非構造化データは、NoSQLデータベースの特徴の1つです。"
           ),
           QuizQuestion(
               question: "コンピュータネットワークにおいて、IPアドレスを動的に割り当てるプロトコルは何か？",
               choices: [
                   "DNS",
                   "DHCP",
                   "FTP",
                   "HTTP"
               ],
               correctAnswerIndex: 1,
               explanation: "DHCPは、IPアドレスを動的に割り当てるプロトコルです。"
           ),
           QuizQuestion(
               question: "次のうち、暗号技術を使用してデータの改ざんや盗聴を防ぐプロトコルはどれか？",
               choices: [
                   "HTTP",
                   "HTTPS",
                   "FTP",
                   "SMTP"
               ],
               correctAnswerIndex: 1,
               explanation: "HTTPSは、暗号技術を使用してデータの改ざんや盗聴を防ぐプロトコルです。"
           ),
           QuizQuestion( //長い
               question: "オブジェクト指向プログラミングにおける「カプセル化」とは何か？",
               choices: [
                   "複数のオブジェクトを一つにまとめること",
                   "オブジェクトの状態を外部から変更できないようにすること",
                   "一つのクラスから複数のクラスを作成すること",
                   "異なるデータ型を一つのクラスで扱うこと"
               ],
               correctAnswerIndex: 1,
               explanation: "カプセル化は、オブジェクトの状態を外部から変更できないようにすることを指します。"
           ),
           QuizQuestion(
               question: "次のうち、プログラムの実行中に発生する予期しない事態を扱うための仕組みは何か？",
               choices: [
                   "ループ",
                   "例外処理",
                   "再帰",
                   "ポリモーフィズム"
               ],
               correctAnswerIndex: 1,
               explanation: "例外処理は、プログラムの実行中に発生する予期しない事態を扱うための仕組みです。"
           ),
           QuizQuestion(
               question: "次のうち、データベースのテーブル間の関係を示すものはどれか？",
               choices: [
                   "インデックス",
                   "トランザクション",
                   "リレーション",
                   "ビュー"
               ],
               correctAnswerIndex: 2,
               explanation: "リレーションは、データベースのテーブル間の関係を示すものです。"
           ),
        QuizQuestion(
                        question: "どのプロトコルがファイル転送に一般的に使用されますか？",
                        choices: [
                            "HTTP",
                            "HTTPS",
                            "FTP",
                            "TCP"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "FTP（File Transfer Protocol）は、ネットワーク上でのファイル転送に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "OSIモデルの第3層は何ですか？",
                        choices: [
                            "トランスポート層",
                            "ネットワーク層",
                            "データリンク層",
                            "セッション層"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "OSIモデルの第3層はネットワーク層です。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語が主に統計計算とデータ分析に使用されますか？",
                        choices: [
                            "Java",
                            "C++",
                            "R",
                            "PHP"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Rは、統計計算とデータ分析に広く使用されるプログラミング言語です。"
                    ),
        QuizQuestion(
                        question: "インターネットの主なバックボーンプロトコルは何ですか？",
                        choices: [
                            "HTTP",
                            "FTP",
                            "TCP/IP",
                            "UDP"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "インターネットの主なバックボーンプロトコルはTCP/IPです。"
                    ),
        QuizQuestion(
                        question: "どのツールや技術がバージョン管理に使用されますか？",
                        choices: [
                            "Docker",
                            "Git",
                            "Kubernetes",
                            "Jenkins"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Gitは、ソースコードのバージョン管理に使用されるツールです。"
                    ),
        QuizQuestion(
                        question: "どのデータ構造が先入れ先出り（FIFO）の原則に従いますか？",
                        choices: [
                            "スタック",
                            "キュー",
                            "ツリー",
                            "グラフ"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "キューは、先入れ先出り（FIFO）の原則に従うデータ構造です。"
                    ),
        QuizQuestion(
                        question: "どのHTTPメソッドがリソースの作成に使用されますか？",
                        choices: [
                            "GET",
                            "POST",
                            "PUT",
                            "DELETE"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "POSTメソッドは、リソースの作成に使用されます。"
                    ),
        QuizQuestion(
                        question: "どのポート番号がHTTPに割り当てられていますか？",
                        choices: [
                            "21",
                            "22",
                            "80",
                            "443"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "HTTPはポート番号80を使用します。"
                    ),
        QuizQuestion(
                        question: "どのLinuxコマンドがディレクトリの内容を一覧表示しますか？",
                        choices: [
                            "cd",
                            "ls",
                            "mv",
                            "rm"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "lsコマンドは、ディレクトリの内容を一覧表示します。"
                    ),
        QuizQuestion(
                        question: "ソフトウェア開発において、ユニットテストは何をテストしますか？",
                        choices: [
                            "個々の関数やメソッド",
                            "システム全体",
                            "統合部分",
                            "ユーザーインターフェース"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "ユニットテストは、個々の関数やメソッドの動作をテストします。"
                    ),
        QuizQuestion(
                        question: "どのHTMLタグを使用して、順序なしリストを作成しますか？",
                        choices: [
                            "<ol>",
                            "<ul>",
                            "<li>",
                            "<dl>"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "<ul>タグは、順序なしリストを作成するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがWebサーバーとブラウザ間で安全な通信を提供しますか？",
                        choices: [
                            "HTTP",
                            "HTTPS",
                            "FTP",
                            "SMTP"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "HTTPSは、Webサーバーとブラウザ間で安全な通信を提供するプロトコルです。"
                    ),
        QuizQuestion(
                        question: "どのデータベース言語がデータの操作とクエリに使用されますか？",
                        choices: [
                            "HTML",
                            "CSS",
                            "SQL",
                            "XML"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "SQLは、データベースのデータ操作とクエリに使用される言語です。"
                    ),
        QuizQuestion(
                        question: "どのネットワークデバイスがデータパケットを転送しますか？",
                        choices: [
                            "ルーター",
                            "スイッチ",
                            "ハブ",
                            "モデム"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "ルーターは、データパケットを転送するネットワークデバイスです。"
                    ),
        QuizQuestion(
                        question: "どのソフトウェア開発フレームワークがRubyで書かれていますか？",
                        choices: [
                            "Django",
                            "Flask",
                            "Ruby on Rails",
                            "Spring Boot"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Ruby on Railsは、Rubyで書かれたソフトウェア開発フレームワークです。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがコンピュータのホスト名をIPアドレスに変換しますか？",
                        choices: [
                            "DHCP",
                            "DNS",
                            "FTP",
                            "HTTP"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "DNS（Domain Name System）は、コンピュータのホスト名をIPアドレスに変換するプロトコルです。"
                    ),
        QuizQuestion(
                        question: "どのプログラミングパラダイムが関数を第一級の市民として扱いますか？",
                        choices: [
                            "オブジェクト指向プログラミング",
                            "手続き型プログラミング",
                            "関数型プログラミング",
                            "論理プログラミング"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "関数型プログラミングでは、関数は第一級の市民として扱われます。"
                    ),
        QuizQuestion(
                        question: "どのツールがコンテナオーケストレーションに使用されますか？",
                        choices: [
                            "Docker",
                            "Kubernetes",
                            "Git",
                            "Jenkins"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Kubernetesは、コンテナオーケストレーションに使用されるツールです。"
                    ),
        QuizQuestion(
                        question: "どのアルゴリズム分類が問題の最適な解決策を見つけることを目的としていますか？",
                        choices: [
                            "ソートアルゴリズム",
                            "検索アルゴリズム",
                            "最適化アルゴリズム",
                            "暗号化アルゴリズム"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "最適化アルゴリズムは、問題の最適な解決策を見つけることを目的としています。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語がブラウザで実行されますか？",
                        choices: [
                            "Python",
                            "JavaScript",
                            "Ruby",
                            "C++"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "JavaScriptは、ブラウザで実行されるプログラミング言語です。"
                    ),
        QuizQuestion(
                        question: "プログラミング言語Javaは、どの種類の言語に分類されますか？",
                        choices: [
                            "コンパイル言語",
                            "スクリプト言語",
                            "マークアップ言語",
                            "アセンブリ言語"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "Javaはコンパイル言語の一つです。ソースコードは最初にバイトコードにコンパイルされ、その後、Java Virtual Machine (JVM)上で実行されます。"
                    ),
        QuizQuestion(
                        question: "クラウドコンピューティングのモデルの一つで、ユーザーがインフラストラクチャーを管理する必要がないものは何ですか？",
                        choices: [
                            "IaaS",
                            "PaaS",
                            "SaaS",
                            "FaaS"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "SaaS（Software as a Service）は、ユーザーがインフラストラクチャーを管理する必要がないクラウドコンピューティングのモデルです。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルが電子メールの送受信に使用されますか？",
                        choices: [
                            "HTTP",
                            "FTP",
                            "SMTP",
                            "DHCP"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "SMTP（Simple Mail Transfer Protocol）は、電子メールの送受信に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "ビットとバイトの関係は何ですか？",
                        choices: [
                            "1ビット = 8バイト",
                            "1バイト = 8ビット",
                            "1ビット = 1024バイト",
                            "1バイト = 1024ビット"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "1バイトは8ビットです。"
                    ),
        QuizQuestion(
                        question: "どのOSがオープンソースソフトウェアですか？",
                        choices: [
                            "Windows",
                            "macOS",
                            "Linux",
                            "MS-DOS"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Linuxはオープンソースのオペレーティングシステムです。"
                    ),
        QuizQuestion(
                        question: "SQLのどのコマンドを使用して、データベースからデータを取得しますか？",
                        choices: [
                            "INSERT",
                            "UPDATE",
                            "DELETE",
                            "SELECT"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "SELECT文は、データベースからデータを取得するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのネットワークトポロジーで、各デバイスが中央のハブに接続されていますか？",
                        choices: [
                            "スター",
                            "メッシュ",
                            "リング",
                            "バス"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "スタートポロジーでは、各デバイスが中央のハブに接続されています。"
                    ),
        QuizQuestion(
                        question: "どのソフトウェア開発手法が、定期的な短いイテレーションを使用しますか？",
                        choices: [
                            "ウォーターフォールモデル",
                            "アジャイル開発",
                            "スパイラルモデル",
                            "Vモデル"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "アジャイル開発は、定期的な短いイテレーションを使用するソフトウェア開発のアプローチです。"
                    ),
        QuizQuestion(
                        question: "IPv4アドレスは何ビットですか？",
                        choices: [
                            "16ビット",
                            "32ビット",
                            "64ビット",
                            "128ビット"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "IPv4アドレスは32ビットのアドレスです。"
                    ),
        QuizQuestion(
                        question: "どのHTMLタグを使用して、Webページに画像を挿入しますか？",
                        choices: [
                            "<img>",
                            "<picture>",
                            "<media>",
                            "<graphic>"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "<img>タグは、Webページに画像を挿入するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがWebブラウザとWebサーバー間の通信に使用されますか？",
                        choices: [
                            "FTP",
                            "HTTP",
                            "SMTP",
                            "TCP"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "HTTP（HyperText Transfer Protocol）は、WebブラウザとWebサーバー間の通信に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "RAIDのどのレベルがミラーリングを提供しますか？",
                        choices: [
                            "RAID 0",
                            "RAID 1",
                            "RAID 5",
                            "RAID 10"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "RAID 1は、データのミラーリングを提供するRAIDレベルです。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語が主にWeb開発に使用されますか？",
                        choices: [
                            "Python",
                            "JavaScript",
                            "C++",
                            "Java"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "JavaScriptは、クライアントサイドのスクリプティング言語として、主にWeb開発で使用されます。"
                    ),
        QuizQuestion(
                        question: "どのデータベース管理システムがオープンソースですか？",
                        choices: [
                            "Oracle Database",
                            "Microsoft SQL Server",
                            "MySQL",
                            "IBM Db2"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "MySQLは、オープンソースのリレーショナルデータベース管理システムです。"
                    ),
        QuizQuestion(
                        question: "どのソートアルゴリズムが最も効率的ですか？",
                        choices: [
                            "バブルソート",
                            "インサーションソート",
                            "クイックソート",
                            "セレクションソート"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "クイックソートは、平均的なケースで高い効率を持つソートアルゴリズムです。"
                    )
    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared


    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizDailyList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .daily, authManager: authManager,audioManager: audioManager,isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizDailyList_Previews: PreviewProvider {
    static var previews: some View {
        QuizDailyList(isPresenting: .constant(false))
    }
}
