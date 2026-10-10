//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizInfoBasicListView: View {
    @Binding var isPresenting: Bool
    let isInfiniteMode: Bool
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
                question: "コンピュータのCPUが直接参照する情報を保存する場所を何というか？",
                choices: [
                    "HDD",
                    "ROM",
                    "SSD",
                    "RAM"
                ],
                correctAnswerIndex: 3,
                explanation: "RAM（Random Access Memory）は、CPUが直接参照する情報を一時的に保存する場所です。"
            ),
            QuizQuestion(
                question: "OSの役割として正しくないものはどれか？",
                choices: [
                    "電源の供給",
                    "ファイルシステムの管理",
                    "アプリケーションの実行",
                    "ハードウェアの制御"
                ],
                correctAnswerIndex: 0,
                explanation: "電源の供給はOSの役割ではありません。"
            ),
            QuizQuestion(
                question: "インターネット上でコンピュータやネットワークを一意に識別するための番号を何というか？",
                choices: [
                    "HTTP",
                    "IPアドレス",
                    "HTML",
                    "URL"
                ],
                correctAnswerIndex: 1,
                explanation: "IPアドレスは、インターネット上でコンピュータやネットワークを一意に識別するための番号です。"
            ),
        QuizQuestion(
                question: "プログラムのバグを修正する作業を何というか？",
                choices: [
                    "デバッギング",
                    "エンコーディング",
                    "エクスポーティング",
                    "コンパイリング"
                ],
                correctAnswerIndex: 0,
                explanation: "プログラムのバグを修正する作業をデバッギングと言います。"
            ),
            QuizQuestion(
                question: "データベースの設計段階で、実際のテーブルやカラムを決定する段階を何というか？",
                choices: [
                    "内部設計",
                    "論理設計",
                    "物理設計",
                    "外部設計"
                ],
                correctAnswerIndex: 2,
                explanation: "データベースの物理設計では、実際のテーブルやカラムを決定します。"
            ),
            QuizQuestion(
                question: "オブジェクト指向プログラミングにおいて、オブジェクトの特性や振る舞いを定義したものを何というか？",
                choices: [
                    "クラス",
                    "メソッド",
                    "プロパティ",
                    "インスタンス"
                ],
                correctAnswerIndex: 0,
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
            )
        ,
            QuizQuestion(
                question: "プログラムの実行中に発生する予期しない事象を何というか？",
                choices: [
                    "エラー",
                    "イベント",
                    "例外",
                    "バグ"
                ],
                correctAnswerIndex: 2,
                explanation: "プログラムの実行中に発生する予期しない事象を例外と言います。"
            ),
            QuizQuestion(
                question: "インターネットの基盤となる技術を何というか？",
                choices: [
                    "HTTP",
                    "HTML",
                    "FTP",
                    "TCP/IP"
                ],
                correctAnswerIndex: 3,
                explanation: "インターネットの基盤となる技術はTCP/IPです。"
            ),
            QuizQuestion(
                question: "Java言語で文字列を扱うクラスは何か？",
                choices: [
                    "String",
                    "StringBuffer",
                    "Str",
                    "Text"
                ],
                correctAnswerIndex: 0,
                explanation: "Java言語で文字列を扱うクラスはStringです。"
            ),
            QuizQuestion(
                question: "データベースで、データの重複を避けるための制約を何というか？",
                choices: [
                    "インデックス",
                    "主キー",
                    "参照整合性",
                    "外部キー"
                ],
                correctAnswerIndex: 1,
                explanation: "データの重複を避けるための制約は主キーです。"
            ),
            QuizQuestion(
                question: "ソフトウェアの開発手法で、短いサイクルを繰り返しながら開発を進める方法を何というか？",
                choices: [
                    "スパイラルモデル",
                    "ウォーターフォールモデル",
                    "アジャイル開発",
                    "Vモデル"
                ],
                correctAnswerIndex: 2,
                explanation: "短いサイクルを繰り返しながら開発を進める方法はアジャイル開発です。"
            ),
            QuizQuestion(
                question: "OSの役割として正しくないものはどれか？",
                choices: [
                    "ビジネスロジックの処理",
                    "ネットワークの設定",
                    "ファイルの管理",
                    "ハードウェアの制御"
                ],
                correctAnswerIndex: 0,
                explanation: "ビジネスロジックの処理はアプリケーションの役割であり、OSの直接の役割ではありません。"
            ),
            QuizQuestion(
                question: "次のうち、非関係データベース管理システム(RDBMS)はどれか？",
                choices: [
                    "Cassandra",
                    "MySQL",
                    "NoSQL",
                    "Redis"
                ],
                correctAnswerIndex: 2,
                explanation: "NoSQLはドキュメント指向の非関係データベース管理システムです。"
            ),
            QuizQuestion(
                question: "次のうち、オープンソースのWebサーバソフトウェアはどれか？",
                choices: [
                    "WebLogic",
                    "IIS",
                    "WebSphere",
                    "Apache"
                ],
                correctAnswerIndex: 3,
                explanation: "ApacheはオープンソースのWebサーバソフトウェアです。"
            ),
            QuizQuestion(
                question: "プログラム内で、変数の値が変更されないようにする修飾子を何というか？",
                choices: [
                    "static",
                    "public",
                    "final",
                    "private"
                ],
                correctAnswerIndex: 2,
                explanation: "変数の値が変更されないようにする修飾子はfinalです。"
            ),
            QuizQuestion(
                question: "次のうち、動的なWebページの生成に使用されるスクリプト言語はどれか？",
                choices: [
                    "XML",
                    "JavaScript",
                    "HTML",
                    "CSS"
                ],
                correctAnswerIndex: 1,
                explanation: "動的なWebページの生成に使用されるスクリプト言語はJavaScriptです。"
            ),
            QuizQuestion(
                question: "オブジェクト指向プログラミングにおける「継承」の主な目的は何か？",
                choices: [
                    "コードの再利用",
                    "データの保護",
                    "高速な実行速度",
                    "効率的なメモリ使用"
                ],
                correctAnswerIndex: 0,
                explanation: "オブジェクト指向プログラミングにおける「継承」の主な目的はコードの再利用です。"
            ),
        QuizQuestion(
               question: "次のうち、オペレーティングシステム(OS)の役割ではないものはどれか？",
               choices: [
                   "デバイス管理",
                   "メモリ管理",
                   "画像編集",
                   "プロセス管理"
               ],
               correctAnswerIndex: 2,
               explanation: "画像編集はアプリケーションソフトウェアの役割であり、OSの役割ではありません。"
           ),
           QuizQuestion(
               question: "次のうち、プログラミング言語の1つであるのはどれか？",
               choices: [
                   "HTML",
                   "HTTP",
                   "FTP",
                   "Python"
               ],
               correctAnswerIndex: 3,
               explanation: "Pythonはプログラミング言語の1つです。"
           ),
           QuizQuestion(
               question: "ソフトウェアのバグを修正するためのソフトウェアの更新を何というか？",
               choices: [
                   "Patch",
                   "Upgrade",
                   "Install",
                   "Deploy"
               ],
               correctAnswerIndex: 0,
               explanation: "ソフトウェアのバグを修正するためのソフトウェアの更新をPatchと呼びます。"
           ),
           QuizQuestion(
               question: "次のうち、関係データベース管理システム(RDBMS)の特徴ではないものはどれか？",
               choices: [
                   "非構造化データ",
                   "主キーと外部キー",
                   "正規化",
                   "テーブル構造"
               ],
               correctAnswerIndex: 0,
               explanation: "非構造化データは、NoSQLデータベースの特徴の1つです。"
           ),
           QuizQuestion(
               question: "コンピュータネットワークにおいて、IPアドレスを動的に割り当てるプロトコルは何か？",
               choices: [
                   "FTP",
                   "DHCP",
                   "DNS",
                   "HTTP"
               ],
               correctAnswerIndex: 1,
               explanation: "DHCPは、IPアドレスを動的に割り当てるプロトコルです。"
           ),
           QuizQuestion(
               question: "次のうち、暗号技術を使用してデータの改ざんや盗聴を防ぐプロトコルはどれか？",
               choices: [
                   "HTTP",
                   "FTP",
                   "SMTP",
                   "HTTPS"
               ],
               correctAnswerIndex: 3,
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
                   "ポリモーフィズム",
                   "再帰"
               ],
               correctAnswerIndex: 1,
               explanation: "例外処理は、プログラムの実行中に発生する予期しない事態を扱うための仕組みです。"
           ),
           QuizQuestion(
               question: "次のうち、データベースのテーブル間の関係を示すものはどれか？",
               choices: [
                   "リレーション",
                   "ビュー",
                   "トランザクション",
                   "インデックス"
               ],
               correctAnswerIndex: 0,
               explanation: "リレーションは、データベースのテーブル間の関係を示すものです。"
           ),
        QuizQuestion(
                        question: "どのプロトコルがファイル転送に一般的に使用されますか？",
                        choices: [
                            "HTTP",
                            "FTP",
                            "TCP",
                            "HTTPS"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "FTP（File Transfer Protocol）は、ネットワーク上でのファイル転送に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "OSIモデルの第3層は何ですか？",
                        choices: [
                            "トランスポート層",
                            "セッション層",
                            "データリンク層",
                            "ネットワーク層"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "OSIモデルの第3層はネットワーク層です。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語が主に統計計算とデータ分析に使用されますか？",
                        choices: [
                            "R",
                            "Java",
                            "C++",
                            "PHP"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "Rは、統計計算とデータ分析に広く使用されるプログラミング言語です。"
                    ),
        QuizQuestion(
                        question: "インターネットの主なバックボーンプロトコルは何ですか？",
                        choices: [
                            "FTP",
                            "TCP/IP",
                            "HTTP",
                            "UDP"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "インターネットの主なバックボーンプロトコルはTCP/IPです。"
                    ),
        QuizQuestion(
                        question: "どのツールや技術がバージョン管理に使用されますか？",
                        choices: [
                            "Git",
                            "Jenkins",
                            "Kubernetes",
                            "Docker"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "Gitは、ソースコードのバージョン管理に使用されるツールです。"
                    ),
        QuizQuestion(
                        question: "どのデータ構造が先入れ先出り（FIFO）の原則に従いますか？",
                        choices: [
                            "ツリー",
                            "グラフ",
                            "スタック",
                            "キュー"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "キューは、先入れ先出り（FIFO）の原則に従うデータ構造です。"
                    ),
        QuizQuestion(
                        question: "どのHTTPメソッドがリソースの作成に使用されますか？",
                        choices: [
                            "PUT",
                            "GET",
                            "DELETE",
                            "POST"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "POSTメソッドは、リソースの作成に使用されます。"
                    ),
        QuizQuestion(
                        question: "どのポート番号がHTTPに割り当てられていますか？",
                        choices: [
                            "22",
                            "21",
                            "80",
                            "443"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "HTTPはポート番号80を使用します。"
                    ),
        QuizQuestion(
                        question: "どのLinuxコマンドがディレクトリの内容を一覧表示しますか？",
                        choices: [
                            "ls",
                            "mv",
                            "rm",
                            "cd"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "lsコマンドは、ディレクトリの内容を一覧表示します。"
                    ),
        QuizQuestion(
                        question: "ソフトウェア開発において、ユニットテストは何をテストしますか？",
                        choices: [
                            "システム全体",
                            "ユーザーインターフェース",
                            "個々の関数やメソッド",
                            "統合部分"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "ユニットテストは、個々の関数やメソッドの動作をテストします。"
                    ),
        QuizQuestion(
                        question: "どのHTMLタグを使用して、順序なしリストを作成しますか？",
                        choices: [
                            "<ol>",
                            "<dl>",
                            "<li>",
                            "<ul>"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "<ul>タグは、順序なしリストを作成するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがWebサーバーとブラウザ間で安全な通信を提供しますか？",
                        choices: [
                            "HTTPS",
                            "SMTP",
                            "HTTP",
                            "FTP"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "HTTPSは、Webサーバーとブラウザ間で安全な通信を提供するプロトコルです。"
                    ),
        QuizQuestion(
                        question: "どのデータベース言語がデータの操作とクエリに使用されますか？",
                        choices: [
                            "HTML",
                            "SQL",
                            "CSS",
                            "XML"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "SQLは、データベースのデータ操作とクエリに使用される言語です。"
                    ),
        QuizQuestion(
                        question: "どのネットワークデバイスがデータパケットを転送しますか？",
                        choices: [
                            "ハブ",
                            "モデム",
                            "スイッチ",
                            "ルーター"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "ルーターは、データパケットを転送するネットワークデバイスです。"
                    ),
        QuizQuestion(
                        question: "どのソフトウェア開発フレームワークがRubyで書かれていますか？",
                        choices: [
                            "Spring Boot",
                            "Ruby on Rails",
                            "Django",
                            "Flask"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Ruby on Railsは、Rubyで書かれたソフトウェア開発フレームワークです。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがコンピュータのホスト名をIPアドレスに変換しますか？",
                        choices: [
                            "DHCP",
                            "HTTP",
                            "DNS",
                            "FTP"
                        ],
                        correctAnswerIndex: 2,
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
                            "Kubernetes",
                            "Jenkins",
                            "Docker",
                            "Git"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "Kubernetesは、コンテナオーケストレーションに使用されるツールです。"
                    ),
        QuizQuestion(
                        question: "どのアルゴリズム分類が問題の最適な解決策を見つけることを目的としていますか？",
                        choices: [
                            "検索アルゴリズム",
                            "暗号化アルゴリズム",
                            "最適化アルゴリズム",
                            "ソートアルゴリズム"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "最適化アルゴリズムは、問題の最適な解決策を見つけることを目的としています。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語がブラウザで実行されますか？",
                        choices: [
                            "C++",
                            "Ruby",
                            "Python",
                            "JavaScript"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "JavaScriptは、ブラウザで実行されるプログラミング言語です。"
                    ),
        QuizQuestion(
                        question: "プログラミング言語Javaは、どの種類の言語に分類されますか？",
                        choices: [
                            "マークアップ言語",
                            "スクリプト言語",
                            "コンパイル言語",
                            "アセンブリ言語"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Javaはコンパイル言語の一つです。ソースコードは最初にバイトコードにコンパイルされ、その後、Java Virtual Machine (JVM)上で実行されます。"
                    ),
        QuizQuestion(
                        question: "クラウドコンピューティングのモデルの一つで、ユーザーがインフラストラクチャーを管理する必要がないものは何ですか？",
                        choices: [
                            "FaaS",
                            "IaaS",
                            "SaaS",
                            "PaaS"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "SaaS（Software as a Service）は、ユーザーがインフラストラクチャーを管理する必要がないクラウドコンピューティングのモデルです。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルが電子メールの送受信に使用されますか？",
                        choices: [
                            "FTP",
                            "SMTP",
                            "DHCP",
                            "HTTP"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "SMTP（Simple Mail Transfer Protocol）は、電子メールの送受信に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "ビットとバイトの関係は何ですか？",
                        choices: [
                            "1バイト = 1024ビット",
                            "1ビット = 8バイト",
                            "1ビット = 1024バイト",
                            "1バイト = 8ビット"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "1バイトは8ビットです。"
                    ),
        QuizQuestion(
                        question: "どのOSがオープンソースソフトウェアですか？",
                        choices: [
                            "MS-DOS",
                            "macOS",
                            "Windows",
                            "Linux"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "Linuxはオープンソースのオペレーティングシステムです。"
                    ),
        QuizQuestion(
                        question: "SQLのどのコマンドを使用して、データベースからデータを取得しますか？",
                        choices: [
                            "DELETE",
                            "SELECT",
                            "INSERT",
                            "UPDATE"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "SELECT文は、データベースからデータを取得するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのネットワークトポロジーで、各デバイスが中央のハブに接続されていますか？",
                        choices: [
                            "リング",
                            "メッシュ",
                            "スター",
                            "バス"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "スタートポロジーでは、各デバイスが中央のハブに接続されています。"
                    ),
        QuizQuestion(
                        question: "どのソフトウェア開発手法が、定期的な短いイテレーションを使用しますか？",
                        choices: [
                            "スパイラルモデル",
                            "アジャイル開発",
                            "ウォーターフォールモデル",
                            "Vモデル"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "アジャイル開発は、定期的な短いイテレーションを使用するソフトウェア開発のアプローチです。"
                    ),
        QuizQuestion(
                        question: "IPv4アドレスは何ビットですか？",
                        choices: [
                            "128ビット",
                            "16ビット",
                            "32ビット",
                            "64ビット"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "IPv4アドレスは32ビットのアドレスです。"
                    ),
        QuizQuestion(
                        question: "どのHTMLタグを使用して、Webページに画像を挿入しますか？",
                        choices: [
                            "<graphic>",
                            "<media>",
                            "<img>",
                            "<picture>"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "<img>タグは、Webページに画像を挿入するために使用されます。"
                    ),
        QuizQuestion(
                        question: "どのプロトコルがWebブラウザとWebサーバー間の通信に使用されますか？",
                        choices: [
                            "TCP",
                            "FTP",
                            "SMTP",
                            "HTTP"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "HTTP（HyperText Transfer Protocol）は、WebブラウザとWebサーバー間の通信に使用されるプロトコルです。"
                    ),
        QuizQuestion(
                        question: "RAIDのどのレベルがミラーリングを提供しますか？",
                        choices: [
                            "RAID 1",
                            "RAID 5",
                            "RAID 0",
                            "RAID 10"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "RAID 1は、データのミラーリングを提供するRAIDレベルです。"
                    ),
        QuizQuestion(
                        question: "どのプログラミング言語が主にWeb開発に使用されますか？",
                        choices: [
                            "Python",
                            "Java",
                            "C++",
                            "JavaScript"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "JavaScriptは、クライアントサイドのスクリプティング言語として、主にWeb開発で使用されます。"
                    ),
        QuizQuestion(
                        question: "どのデータベース管理システムがオープンソースですか？",
                        choices: [
                            "Oracle Database",
                            "Microsoft SQL Server",
                            "IBM Db2",
                            "MySQL"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "MySQLは、オープンソースのリレーショナルデータベース管理システムです。"
                    ),
        QuizQuestion(
                        question: "どのソートアルゴリズムが最も効率的ですか？",
                        choices: [
                            "セレクションソート",
                            "バブルソート",
                            "クイックソート",
                            "インサーションソート"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "クイックソートは、平均的なケースで高い効率を持つソートアルゴリズムです。"
                    ),
        // 追加 2024/3/4
        QuizQuestion(
            question: "Web開発におけるフロントエンドとバックエンドの主な違いは何か？",
            choices: [
                "フロントエンドはセキュリティ対策に関わり、バックエンドはパフォーマンス最適化に関わる",
                "フロントエンドはクライアントサイドの開発に関わり、バックエンドはサーバーサイドの開発に関わる",
                "フロントエンドはデータベース管理に専念し、バックエンドはユーザーインターフェースの設計に専念する",
                "フロントエンドはハードウェア設計に関わり、バックエンドはソフトウェア開発に関わる"
            ],
            correctAnswerIndex: 1,
            explanation: "フロントエンド開発はウェブサイトのユーザーインターフェースとユーザーエクスペリエンスを担当し、バックエンド開発はサーバー、アプリケーション、データベースの管理といったサーバーサイドの機能を担当します。"
        ),
         QuizQuestion(
            question: "プログラミングにおける「ポリモーフィズム」とは何か？",
            choices: [
                "プログラムが実行時にその形を変える能力",
                "異なる機能を持つ複数のオブジェクトが同じ名前のメソッドを使用すること",
                "単一のインターフェースを通じて異なるデータ型に対して同じ操作を適用できる能力",
                "ソースコードが複数のプログラミング言語で書かれていること"
            ],
            correctAnswerIndex: 2,
            explanation: "ポリモーフィズムはオブジェクト指向プログラミングの概念の一つで、異なるクラスのオブジェクトが同じインターフェースやメソッドを通じて操作されることを指します。"
        ),
         QuizQuestion(
            question: "クラウドコンピューティングにおいて、インフラストラクチャー（サーバー、ストレージなど）をサービスとして提供するモデルは何か？",
            choices: [
                "Software as a Service (SaaS)",
                "Infrastructure as a Service (IaaS)",
                "Function as a Service (FaaS)",
                "Platform as a Service (PaaS)"
            ],
            correctAnswerIndex: 1,
            explanation: "IaaSは、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルで、ユーザーはオンデマンドでインフラストラクチャーを利用し、管理することができます。"
        ),
         QuizQuestion(
            question: "ソフトウェア開発において、プロジェクトの進行状況や成果物を定期的に検証し、適宜調整を行うアプローチは何というか？",
            choices: [
                "スクラム",
                "ウォーターフォールモデル",
                "カンバン",
                "スパイラルモデル"
            ],
            correctAnswerIndex: 0,
            explanation: "スクラムは、短いスプリントと呼ばれる期間を設け、定期的にプロジェクトの進行状況や成果物を検証し、必要に応じて計画を調整するアジャイル開発のフレームワークです。"
        ),
         QuizQuestion(
            question: "ウェブアプリケーションでユーザーのセッション情報を一時的に保存するために主に使用される技術は何か？",
            choices: [
                "クッキー",
                "キャッシュ",
                "セッション",
                "ローカルストレージ"
            ],
            correctAnswerIndex: 2,
            explanation: "セッションは、サーバー側でユーザーのセッション情報を一時的に保存する技術で、ログイン状態の管理などに使用されます。"
        ),
         QuizQuestion(
            question: "インターネットのドメイン名システム(DNS)において、ドメイン名をIPアドレスに変換するサーバーは何と呼ばれるか？",
            choices: [
                "メールサーバー",
                "ファイルサーバー",
                "Webサーバー",
                "DNSサーバー"
            ],
            correctAnswerIndex: 3,
            explanation: "DNSサーバーは、インターネットのドメイン名システムにおいて、人間が覚えやすいドメイン名を機械が処理しやすいIPアドレスに変換する役割を持ちます。"
        ),
         QuizQuestion(
            question: "ネットワークセキュリティで用いられる、暗号化と復号化の鍵が異なる暗号方式は何か？",
            choices: [
                "非対称鍵暗号方式",
                "デジタル署名",
                "ハッシュ関数",
                "対称鍵暗号方式"
            ],
            correctAnswerIndex: 0,
            explanation: "非対称鍵暗号方式は、暗号化と復号化に異なる鍵（公開鍵と秘密鍵）を使用する方式で、インターネット上での安全なデータ交換に利用されます。"
        ),
         QuizQuestion(
            question: "ウェブ開発における「レスポンシブデザイン」の主な目的は何か？",
            choices: [
                "ウェブサイトのセキュリティを強化する",
                "異なるデバイスサイズでの表示を最適化する",
                "ウェブページのローディング時間を短縮する",
                "ウェブサイトの検索エンジン最適化（SEO）を改善する"
            ],
            correctAnswerIndex: 1,
            explanation: "レスポンシブデザインは、スマートフォン、タブレット、デスクトップなど、異なるデバイスサイズに対応し、ユーザーに適切な表示を提供するウェブデザインのアプローチです。"
        ),
          QuizQuestion(
             question: "ソフトウェアテストにおいて、実際のユーザー環境でソフトウェアの動作を評価するテストは何か？",
             choices: [
                 "受け入れテスト",
                 "統合テスト",
                 "ユニットテスト",
                 "システムテスト"
             ],
             correctAnswerIndex: 0,
             explanation: "受け入れテストは、実際のユーザー環境でソフトウェアが要件を満たしているかを確認するために行われ、製品がエンドユーザーに受け入れられるかを評価します。"
         ),
          QuizQuestion(
             question: "プログラミング言語における「ポリモーフィズム」とは何を指すか？",
             choices: [
                 "一つのインターフェースに対して複数の実装を提供する能力",
                 "エラーを自動的に修正する機能",
                 "変数が複数の型の値を取る能力",
                 "コードの実行速度を向上させる技術"
             ],
             correctAnswerIndex: 0,
             explanation: "ポリモーフィズムはオブジェクト指向プログラミングの概念の一つで、同一のインターフェースに対して異なる形式や動作を提供する能力を指します。"
         ),
          QuizQuestion(
             question: "クラウドコンピューティングにおいて、サーバー、ストレージ、ネットワークなどのコンピューティングリソースをオンデマンドで提供するサービスモデルは何か？",
             choices: [
                 "Function as a Service (FaaS)",
                 "Platform as a Service (PaaS)",
                 "Software as a Service (SaaS)",
                 "Infrastructure as a Service (IaaS)"
             ],
             correctAnswerIndex: 3,
             explanation: "IaaSは、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルです。ユーザーは必要に応じてリソースをスケールアップまたはダウンできます。"
         ),
          QuizQuestion(
             question: "Webアプリケーションにおける「RESTful API」とは、どのような特徴を持つAPIのことか？",
             choices: [
                 "専用のプロトコルを必要とするAPI",
                 "XMLベースのメッセージフォーマットを使用するAPI",
                 "HTTPメソッドを用いてリソースの状態を操作するAPI",
                 "ステートフルな通信を行うAPI"
             ],
             correctAnswerIndex: 2,
             explanation: "RESTful APIは、HTTPメソッド（GET、POST、PUT、DELETEなど）を用いてリソースの状態を操作し、Webサービスのインターフェースとして機能するAPIです。これにより、シンプルで柔軟なアプリケーション構築が可能になります。"
         ),
          QuizQuestion(
             question: "ブロックチェーン技術が最も注目されている用途は何か？",
             choices: [
                 "クラウドストレージ",
                 "オンライン広告",
                 "ソーシャルネットワーキング",
                 "仮想通貨"
             ],
             correctAnswerIndex: 3,
             explanation: "ブロックチェーン技術は、仮想通貨（特にビットコイン）の基盤技術として最も注目されています。この技術により、中央機関の介在なく取引の信頼性を保証することが可能になります。"
         ),
         QuizQuestion(
            question: "ソフトウェアテストにおいて、システム全体が要件を満たしているかどうかを検証するテストは何か？",
            choices: [
                "インテグレーションテスト",
                "受け入れテスト",
                "ユニットテスト",
                "システムテスト"
            ],
            correctAnswerIndex: 3,
            explanation: "システムテストは、ソフトウェア開発プロセスにおいて、システム全体が設計要件やビジネス要件を満たしているかどうかを検証するテストフェーズです。この段階で、ソフトウェアの機能、セキュリティ、性能などが評価されます。"
        ),
         QuizQuestion(
            question: "データベースにおける「トランザクション」とは、どのようなものを指すか？",
            choices: [
                "データの一時的な保存領域",
                "データベース内のテーブルやカラム",
                "一連の操作が全てまたは全く実行される一つの単位",
                "データベースへのアクセスログ"
            ],
            correctAnswerIndex: 2,
            explanation: "トランザクションは、一連のデータベース操作が全て成功するか、一つでも失敗した場合は何も実行されないようにすることを保証するプロセスの単位です。これにより、データの整合性が保たれます。"
        ),
         QuizQuestion(
            question: "ウェブサイトのユーザーインターフェースを動的に変更するために使用される技術は何か？",
            choices: [
                "JavaScript",
                "CSS",
                "PHP",
                "HTML"
            ],
            correctAnswerIndex: 0,
            explanation: "JavaScriptはクライアントサイドで実行されるスクリプト言語であり、ウェブサイトのユーザーインターフェースを動的に変更するために広く使用されています。"
        ),
         QuizQuestion(
            question: "ソフトウェア開発プロジェクトで使用される、製品のリリース前に発見されたバグを管理するプロセスは何というか？",
            choices: [
                "パフォーマンスモニタリング",
                "コードレビュー",
                "バグトラッキング",
                "バージョンコントロール"
            ],
            correctAnswerIndex: 2,
            explanation: "バグトラッキングは、ソフトウェア開発プロジェクトで発見されたバグを記録、追跡、管理するためのプロセスです。"
        ),
         QuizQuestion(
            question: "データを構造化する際に用いられる、キーと値のペアで構成されるデータ構造は何か？",
            choices: [
                "リスト",
                "セット",
                "配列",
                "マップ（辞書）"
            ],
            correctAnswerIndex: 3,
            explanation: "マップ（辞書）は、キーと値のペアでデータを構造化するために使用されるデータ構造です。キーを通じて値を効率的に検索できます。"
        ),
          QuizQuestion(
             question: "オンラインでのプライバシー保護と匿名性を高めるために使用されるネットワークは何か？",
             choices: ["TOR（The Onion Router）", "VPN（Virtual Private Network）", "LAN（Local Area Network）", "WAN（Wide Area Network）"],
             correctAnswerIndex: 0,
             explanation: "TOR（The Onion Router）ネットワークは、インターネット上でのプライバシー保護と匿名性を高めるために使用されます。ユーザーのトラフィックを複数のサーバーを介してルーティングすることで匿名性を提供します。"
         ),
          QuizQuestion(
             question: "オープンソースソフトウェアプロジェクトでソースコードの変更や貢献を追跡するために一般的に使用されるシステムは何か？",
             choices: ["Jira", "Bugzilla", "Trello", "GitHub"],
             correctAnswerIndex: 3,
             explanation: "GitHubは、ソフトウェア開発プロジェクトでソースコードの管理、変更追跡、貢献を容易にするために広く使用されるプラットフォームです。オープンソースプロジェクトでのコラボレーションに特に役立ちます。"
         ),
          QuizQuestion(
             question: "ソフトウェア開発プロジェクトにおける「スプリント」とは何か？",
             choices: ["短期間で特定の目標達成を目指すアジャイル開発の作業単位", "コードの最適化とリファクタリングを行う期間", "プロジェクトの最終段階での品質チェック", "開発チームが特定の機能を完成させるために設ける長期計画"],
             correctAnswerIndex: 0,
             explanation: "スプリントはアジャイルソフトウェア開発方法論において、通常1～4週間の固定期間で設定される作業単位であり、この期間内でチームはプロダクトバックログから選択した項目を完成させることを目指します。"
         ),
          QuizQuestion(
             question: "「ポリモーフィズム」とは、プログラミングにおいてどのような概念を指すか？",
             choices: ["異なるクラスのオブジェクトが同一のインターフェースを通じてアクセス可能である性質", "プログラムが実行時にデータ型を決定する能力", "クラス間でコードを共有するためのメカニズム", "オブジェクトが複数の形態を取ることができる性質"],
             correctAnswerIndex: 0,
             explanation: "ポリモーフィズムはオブジェクト指向プログラミングの重要な概念の一つで、異なるクラスのオブジェクトが同一のインターフェース（メソッド）を通じて操作できる性質を指します。これにより、プログラムの柔軟性と再利用性が向上します。"
         ),
          QuizQuestion(
             question: "ウェブページで動的なデータの取得と表示を容易にするJavaScriptライブラリはどれか？",
             choices: ["Vue.js", "jQuery", "React", "AngularJS"],
             correctAnswerIndex: 1,
             explanation: "jQueryは、ウェブページでの動的なデータの取得と表示を容易にするために広く使用されている軽量なJavaScriptライブラリです。"
         ),
          QuizQuestion(
             question: "コンピュータセキュリティにおいて、未承認のアクセスからシステムを保護するプロセスを何というか？",
             choices: ["エンクリプション", "認証", "ファイアウォール", "インシデント対応"],
             correctAnswerIndex: 2,
             explanation: "ファイアウォールは、未承認のアクセスからシステムを保護するための物理的または論理的なデバイスであり、ネットワークセキュリティの基本的な要素の一つです。"
         ),
          QuizQuestion(
             question: "ソフトウェア開発における「継続的インテグレーション」の目的は何か？",
             choices: ["チーム間のコラボレーションを改善する", "コードの品質を向上させる", "開発プロセスを高速化する", "すべての上記"],
             correctAnswerIndex: 3,
             explanation: "継続的インテグレーションは、コードの品質を向上させ、開発プロセスを高速化し、チーム間のコラボレーションを改善することを目的としています。"
         ),
              QuizQuestion(
                 question: "データサイエンスにおいて、大量のデータからパターンや知識を抽出するプロセスを何というか？",
                 choices: ["データマイニング", "データアーキテクチャ", "データエントリ", "データベース管理"],
                 correctAnswerIndex: 0,
                 explanation: "データマイニングは、大量のデータセットから有用な情報や新しい知識を抽出する分析プロセスです。"
             ),
              QuizQuestion(
                 question: "ネットワークセキュリティにおいて、システム内での不正な活動やポリシー違反を検出するシステムは何か？",
                 choices: ["脆弱性管理システム", "インシデント対応システム", "侵入検知システム（IDS）", "リスク評価ツール"],
                 correctAnswerIndex: 2,
                 explanation: "侵入検知システム（IDS）は、システム内での不正な活動やポリシー違反を検出し、管理者に警告を発するセキュリティ技術です。"
             ),
              QuizQuestion(
                 question: "「ビッグデータ」とは何を指す用語か？",
                 choices: ["ストレージ容量を超えるデータ量", "分析が困難なほど大規模で複雑なデータセット", "特定の業界における大量のデータ", "インターネット上で毎日生成されるデータ"],
                 correctAnswerIndex: 1,
                 explanation: "ビッグデータは、従来のデータベース管理ツールやデータ処理アプリケーションでは取り扱いが困難なほどの大規模で複雑なデータセットを指します。ビッグデータの分析は、ビジネスの意思決定、科学研究、社会インフラの最適化など幅広い分野で利用されています。"
             ),
              QuizQuestion(
                 question: "モダンなWeb開発において、コンポーネントベースのアーキテクチャを提供するJavaScriptフレームワークはどれか？",
                 choices: ["PHP", "jQuery", "Bootstrap", "Angular"],
                 correctAnswerIndex: 3,
                 explanation: "Angularはコンポーネントベースのアーキテクチャを提供するモダンなJavaScriptフレームワークです。"
             ),
              QuizQuestion(
                 question: "ソフトウェアテストにおいて、「ブラックボックステスト」の特徴は何か？",
                 choices: ["開発者のみが実行できるテスト", "内部構造を知らずにテストを行う", "コードレベルでのテストを行う", "ソースコードの変更を伴うテスト"],
                 correctAnswerIndex: 1,
                 explanation: "ブラックボックステストは、アプリケーションの内部構造や動作を知らずに、インターフェイスを通じてテストを行う方法です。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングサービスで、完全に管理されたデータベースサービスを提供するものは何か？",
                 choices: ["DBaaS", "SaaS", "PaaS", "IaaS"],
                 correctAnswerIndex: 0,
                 explanation: "DBaaS（Database as a Service）は、完全に管理されたデータベースサービスを提供し、ユーザーはデータベースの管理に関する心配をする必要がありません。"
             ),
              QuizQuestion(
                 question: "モバイルアプリ開発において、iOSとAndroidアプリケーションの両方を開発するために使用されるクロスプラットフォームフレームワークは何か？",
                 choices: ["Flutter", "Xamarin", "Kotlin", "React Native"],
                 correctAnswerIndex: 0,
                 explanation: "Flutterは、iOSとAndroidの両方のプラットフォームに対応するアプリケーションを開発するためのクロスプラットフォームフレームワークです。"
             ),
              QuizQuestion(
                 question: "プログラミングにおいて、非同期処理を実装するためのJavaScriptの機能は何か？",
                 choices: ["Promises", "Events", "AとBの両方", "Callbacks"],
                 correctAnswerIndex: 2,
                 explanation: "JavaScriptでは、非同期処理を実装するためにPromisesやCallbacksが使用されます。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングの「パブリッククラウド」とは何か？",
                 choices: ["インターネットを介さずに利用するクラウドサービス", "個人ユーザー向けの無料クラウドサービス", "複数のテナントが共有するクラウドサービス", "特定の組織が専用に使用するクラウドサービス"],
                 correctAnswerIndex: 2,
                 explanation: "パブリッククラウドは、サービスプロバイダーがインターネットを通じて一般に提供するクラウドサービスの形態です。このモデルでは、複数の顧客（テナント）が物理的なリソースを共有しますが、セキュリティとプライバシーは仮想化技術によって保護されます。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングサービスモデルのうち、最も基盤となるリソース（サーバーやストレージなど）を提供するものは何か？",
                 choices: ["ソフトウェアアズアサービス（SaaS）", "インフラストラクチャアズアサービス（IaaS）", "プラットフォームアズアサービス（PaaS）", "ファンクションアズアサービス（FaaS）"],
                 correctAnswerIndex: 1,
                 explanation: "インフラストラクチャアズアサービス（IaaS）は、クラウドコンピューティングのサービスモデルの一つで、仮想マシンやストレージ、ネットワークなどのコンピューティングインフラをインターネット経由で提供します。これにより、ユーザーは物理的なハードウェアを自身で管理する必要がなくなります。"
             ),
          QuizQuestion(
             question: "RESTful API設計において、リソースの新規作成に一般的に使用されるHTTPメソッドは何か？",
             choices: ["GET", "PUT", "DELETE", "POST"],
             correctAnswerIndex: 3,
             explanation: "POSTメソッドは、新しいリソースを作成するためにRESTful API設計で一般的に使用されます。"
         ),
          QuizQuestion(
             question: "Pythonプログラミングにおいて、リスト内包表記の主な目的は何か？",
             choices: ["リストから特定の要素を削除するため", "新しいリストを簡潔に生成するため", "リストの各要素に関数を適用するため", "リストの要素を並べ替えるため"],
             correctAnswerIndex: 1,
             explanation: "リスト内包表記は、新しいリストを生成するための簡潔な方法を提供します。"
         ),
          QuizQuestion(
             question: "Gitにおいて、リモートリポジトリの変更をローカルリポジトリに取り込むコマンドは何か？",
             choices: ["git commit", "git pull", "git push", "git clone"],
             correctAnswerIndex: 1,
             explanation: "git pullコマンドは、リモートリポジトリの変更を現在のローカルブランチに統合します。"
         ),
          QuizQuestion(
             question: "クラウドサービスモデルの一つで、インフラストラクチャ（仮想マシン、ストレージなど）を提供するサービスは何か？",
             choices: ["PaaS (Platform as a Service)", "FaaS (Function as a Service)", "SaaS (Software as a Service)", "IaaS (Infrastructure as a Service)"],
             correctAnswerIndex: 3,
             explanation: "IaaSは、クラウドコンピューティングのサービスモデルの一つで、サーバー、ストレージ、ネットワーキングなどのインフラストラクチャを提供します。"
         ),
          QuizQuestion(
             question: "ウェブページ内でスタイルシートが使用される目的は何か？",
             choices: ["ページのコンテンツを動的に変更するため", "ページの見た目とフォーマットを制御するため", "サーバーとの通信を改善するため", "ページの構造を定義するため"],
             correctAnswerIndex: 1,
             explanation: "スタイルシート（CSS）は、ウェブページの見た目とフォーマットを定義するために使用されます。"
         ),
         QuizQuestion(
            question: "次のうち、コンテナ化されたアプリケーションを管理するためのオープンソースプラットフォームはどれか？",
            choices: ["Docker", "Ansible", "Vagrant", "Kubernetes"],
            correctAnswerIndex: 3,
            explanation: "Kubernetesは、コンテナ化されたアプリケーションのデプロイメント、スケーリング、および管理を自動化するオープンソースプラットフォームです。"
        ),
         QuizQuestion(
            question: "JavaScriptで非同期処理を実現するために使用されるオブジェクトは何か？",
            choices: ["Promise", "Observable", "Async/Await", "Callback"],
            correctAnswerIndex: 0,
            explanation: "Promiseは、JavaScriptで非同期処理の最終的な完了（または失敗）およびその結果の値を表します。"
        ),
         QuizQuestion(
            question: "情報セキュリティにおいて、未承認のデータアクセスを防止するために使用されるメカニズムは何か？",
            choices: ["IDS（侵入検知システム）", "暗号化", "ファイアウォール", "アンチウイルス"],
            correctAnswerIndex: 1,
            explanation: "暗号化は、データを不可解な形式に変換することで、未承認のアクセスからデータを保護するセキュリティメカニズムです。"
        ),
         QuizQuestion(
            question: "Web開発でユーザーの入力フォームデータをサーバーに送信するために使用されるHTMLタグは何か？",
            choices: ["<form>", "<submit>", "<input>", "<post>"],
            correctAnswerIndex: 0,
            explanation: "<form>タグは、ユーザーの入力を収集してサーバーに送信するために使用されるHTML要素です。"
        ),
         QuizQuestion(
            question: "オブジェクト指向プログラミングにおいて、異なるクラスのオブジェクトが共通のインターフェースを通じてアクセスされる概念を何というか？",
            choices: ["ポリモーフィズム", "継承", "抽象化", "エンカプセレーション"],
            correctAnswerIndex: 0,
            explanation: "ポリモーフィズムは、異なるクラスのオブジェクトが共通のインターフェースを通じて操作されるオブジェクト指向の概念です。"
        ),
         QuizQuestion(
            question: "以下のうち、非同期JavaScriptとXMLの略称は何か？",
            choices: ["XML", "AJAX", "JSON", "HTTP"],
            correctAnswerIndex: 1,
            explanation: "AJAX（Asynchronous JavaScript and XML）は、Webページの一部を非同期に更新するために使用される技術です。"
        ),
         QuizQuestion(
            question: "次のうち、バージョン管理システムではないものはどれか？",
            choices: ["SVN", "Git", "Kubernetes", "Mercurial"],
            correctAnswerIndex: 2,
            explanation: "Kubernetesは、コンテナのオーケストレーションを行うシステムであり、バージョン管理システムではありません。"
        ),
         QuizQuestion(
            question: "データベースにおいて、2つ以上のテーブル間でデータの整合性を保つために使用される制約は何か？",
            choices: ["プライマリキー制約", "参照整合性制約", "ユニーク制約", "チェック制約"],
            correctAnswerIndex: 1,
            explanation: "参照整合性制約は、異なるテーブル間のデータの整合性を保つために使用されるデータベースの制約です。"
        ),
         QuizQuestion(
            question: "CSSにおける「フレックスボックス」の使用目的は何か？",
            choices: [
                "レスポンシブなウェブデザインを実現するため",
                "ドキュメントのメタデータを指定するため",
                "コンテンツ間のスペースを動的に調整するため",
                "ページ上の要素の色を管理するため"
            ],
            correctAnswerIndex: 2,
            explanation: "フレックスボックスは、コンテナ内のアイテムのレイアウトを柔軟に調整するために使用されます。"
        ),
         QuizQuestion(
            question: "ウェブ開発における「レスポンシブデザイン」とは何か？",
            choices: [
                "高速なページ読み込みを実現するためのウェブサイト設計",
                "ウェブサイトがリクエストに即座に応答する設計",
                "ユーザーの操作に反応して動的にコンテンツを変更する設計",
                "異なる画面サイズに対応して適切に表示されるウェブページの設計"
            ],
            correctAnswerIndex: 3,
            explanation: "レスポンシブデザインは、ウェブページがデバイスの画面サイズに応じて内容を適切に調整し、最適なユーザーエクスペリエンスを提供するためのアプローチです。これにより、スマートフォン、タブレット、デスクトップなど、あらゆるデバイスでウェブサイトが適切に表示されます。"
        ),
         QuizQuestion(
            question: "「データベース正規化」の主な目的は何か？",
            choices: [
                "データの重複を排除し、データモデルのシンプルさを保つ",
                "データベースのサイズを小さくする",
                "データベースのパフォーマンスを向上させる",
                "データの整合性とセキュリティを確保する"
            ],
            correctAnswerIndex: 0,
            explanation: "データベース正規化は、データの重複を排除し、データの整合性を保ちながら、データモデルのシンプルさと効率性を高めるために行われます。正規化により、更新の異常や挿入の異常、削除の異常を防ぎ、データベースの保守が容易になります。"
        ),
         QuizQuestion(
            question: "「ブロックチェーン」とは何か？",
            choices: [
                "データ分析のためのアルゴリズム",
                "新世代の暗号化技術",
                "高性能なデータベース技術",
                "分散型デジタル台帳技術"
            ],
            correctAnswerIndex: 3,
            explanation: "ブロックチェーンは、分散型のデジタル台帳技術であり、取引履歴などのデータを複数の参加者間で共有し、改ざんが困難な方法で記録することができます。仮想通貨をはじめとする多くの応用が存在します。"
        ),
         QuizQuestion(
            question: "「マシンラーニング」における「教師あり学習」とは何か？",
            choices: [
                "データにラベルを付けることなくモデルを学習させるプロセス",
                "モデルが自己学習を行い、パフォーマンスを向上させるプロセス",
                "予めラベル付けされたデータを使用してモデルを学習させるプロセス",
                "データセットから自動で特徴を学習するプロセス"
            ],
            correctAnswerIndex: 2,
            explanation: "教師あり学習は、入力データとそれに対応する正解（ラベル）を事前に用意し、このデータセットを使用してモデルを訓練するマシンラーニングの一種です。このプロセスを通じて、モデルは入力データから正解を予測する方法を学習します。"
        ),
         QuizQuestion(
            question: "ソフトウェアテストにおける「回帰テスト」とは何か？",
            choices: [
                "ソフトウェアの異なるバージョン間での互換性を確認するテスト",
                "新しい機能をテストするためのプロセス",
                "ユーザーインターフェースのテスト",
                "既にテストされたソフトウェアが、変更後も期待通りに動作することを確認するテスト"
            ],
            correctAnswerIndex: 3,
            explanation: "回帰テストは、ソフトウェアやその部分が新しいコードの変更や追加によって影響を受けていないことを確認するために行われます。これにより、新たなバグが導入されていないか、また既存の機能が依然として正しく動作しているかを検証します。"
        ),
         QuizQuestion(
            question: "「サイバーセキュリティ」において、「エンドポイントセキュリティ」とは何を指すか？",
            choices: [
                "ネットワーク全体のセキュリティを管理するシステム",
                "ユーザーのデバイスやコンピュータを保護するためのセキュリティ対策",
                "データセンター内のサーバーを保護するセキュリティ技術",
                "インターネットトラフィックを監視し、攻撃を防ぐシステム"
            ],
            correctAnswerIndex: 1,
            explanation: "エンドポイントセキュリティは、組織のネットワークに接続される各デバイス（エンドポイント）に対するセキュリティ対策を指します。これには、マルウェア対策、ファイアウォール、侵入検知システムなどが含まれ、エンドポイントを通じた攻撃からネットワークを保護します。"
        ),
        QuizQuestion(
            question: "8ビットの符号付き整数を2の補数で表す。16進数D6が表す10進数はどれか。",
            choices: [
                "-214",
                "42",
                "-42",
                "214"
            ],
            correctAnswerIndex: 2,
            explanation: "8ビットの16進数D6は2進数11010110である。最上位ビットが1なので負数であり、符号なし値214から256を引くと214－256＝-42となる。42は符号を無視した誤り、214は符号なし解釈、-214は補数変換の扱いを取り違えている。要点は、nビット2の補数の負数は符号なし値から2のn乗を引いて求めることである。"
        ),

        QuizQuestion(
            question: "社員120人のうち、表計算研修の受講者は68人、データベース研修の受講者は57人、両方の受講者は31人である。どちらの研修も受講していない社員は何人か。",
            choices: [
                "94人",
                "5人",
                "26人",
                "37人"
            ],
            correctAnswerIndex: 2,
            explanation: "少なくとも一方を受講した人数は、和集合の公式から68＋57－31＝94人である。したがって、どちらも受講していない人数は120－94＝26人となる。5人は両受講者を二重に引いた誤り、37人は片方との差、94人は少なくとも一方の人数である。集合の重なりは一度だけ数えることを覚える。"
        ),

        QuizQuestion(
            question: "小数部を4ビットとする符号なし固定小数点数で、2進数101101.0110を表したときの10進数はどれか。",
            choices: [
                "22.6875",
                "45.75",
                "45.375",
                "45.1875"
            ],
            correctAnswerIndex: 2,
            explanation: "整数部101101は32＋8＋4＋1＝45、小数部.0110は1/4＋1/8＝0.375なので、合計は45.375である。22.6875はビット位置を一つずらした値、45.1875は小数部の重みを誤った値、45.75は.1100と取り違えた値である。固定小数点では小数点の左右で各桁の重みを明確にする。"
        ),

        QuizQuestion(
            question: "ある処理は成功すれば利益900万円、失敗すれば損失300万円となる。成功確率が0.4のとき、この処理の期待損益は何万円か。",
            choices: [
                "300万円",
                "60万円",
                "180万円",
                "420万円"
            ],
            correctAnswerIndex: 2,
            explanation: "期待損益は、各結果の損益に確率を掛けて合計する。900×0.4＋(-300)×0.6＝360－180＝180万円である。60万円は確率の掛け方を誤った値、300万円は損失額そのもの、420万円は損失を正として加えた値である。期待値では利益と損失の符号を区別し、全結果を確率加重する。"
        ),

        QuizQuestion(
            question: "記号A、B、Cの出現確率がそれぞれ1/2、1/4、1/4である。最短の2進接頭符号を割り当てたとき、1記号当たりの平均符号長は何ビットか。",
            choices: [
                "2.0ビット",
                "1.5ビット",
                "1.75ビット",
                "1.0ビット"
            ],
            correctAnswerIndex: 1,
            explanation: "確率1/2のAに1ビット、確率1/4のBとCに2ビットを割り当てれば、例えば0、10、11という接頭符号になる。平均符号長は1×1/2＋2×1/4＋2×1/4＝1.5ビットである。1.0は3記号を区別できず、2.0は固定長、1.75は確率加重の誤りである。高確率記号を短くするのが可変長符号の基本である。"
        ),

        QuizQuestion(
            question: "7ビットのデータに1ビットの偶数パリティを付加した。受信した8ビット列に1ビットだけ誤りが生じた場合について、正しい説明はどれか。",
            choices: [
                "誤ったビット位置を特定できる。",
                "誤りを自動的に訂正できる。",
                "誤りを検出できない。",
                "誤りの発生は検出できるが、誤ったビット位置は特定できない。"
            ],
            correctAnswerIndex: 3,
            explanation: "偶数パリティでは、1ビット反転すると1の個数の偶奇が変わるので、誤りの発生は検出できる。しかし、どのビットが反転したかを示す情報はないため位置特定や訂正はできない。検出できないのは偶数個の誤りなどの場合であり、位置特定や訂正にはハミング符号など追加の冗長情報が必要である。"
        ),

        QuizQuestion(
            question: "状態Xでは入力0でX、入力1でYへ遷移し、状態Yでは入力0でX、入力1でYへ遷移する有限オートマトンがある。初期状態をXとし、入力列10110を順に与えた後の状態はどれか。",
            choices: [
                "状態Y",
                "状態X",
                "入力列によって決まらない。",
                "途中で停止する。"
            ],
            correctAnswerIndex: 1,
            explanation: "この遷移では、現在状態にかかわらず入力0ならX、入力1ならYとなる。したがって最終入力だけを見ればよく、入力列10110の末尾は0なので最終状態はXである。Yは末尾を1と見誤った場合、決まらないという選択肢は遷移規則を無視しており、停止条件も定義されていない。状態遷移は入力を左から順に適用する。"
        ),

        QuizQuestion(
            question: "1秒間に8,000回標本化し、各標本を12ビットで量子化したモノラル音声を、圧縮せずに30秒記録する。データ量は何kバイトか。ただし、1kバイト＝1,000バイトとする。",
            choices: [
                "2,880kバイト",
                "360kバイト",
                "288kバイト",
                "45kバイト"
            ],
            correctAnswerIndex: 1,
            explanation: "データ量は8,000回/秒×12ビット×30秒＝2,880,000ビットである。8で割ると360,000バイト、指定により360kバイトとなる。45kバイトは12ビットを無視した値、288kバイトはビットからバイトへの変換ミス、2,880kバイトはビット値をそのままバイトとした誤りである。標本化周波数、量子化ビット数、時間を掛ける。"
        ),

        QuizQuestion(
            question: "空のキューQに対して、enqueue(4)、enqueue(7)、dequeue()、enqueue(2)、dequeue()を順に実行する。最後のdequeue()で取り出される値はどれか。",
            choices: [
                "7",
                "取り出せない。",
                "2",
                "4"
            ],
            correctAnswerIndex: 0,
            explanation: "キューはFIFOである。4、7を格納した後、最初のdequeueで4を取り出す。続いて2を格納すると先頭から7、2となり、最後のdequeueでは7が取り出される。2はLIFOと混同した場合、4は最初の取出し値、取り出せないという選択肢は要素数を追跡していない。キューでは追加は末尾、取出しは先頭で行う。"
        ),

        QuizQuestion(
            question: "二分木の各節に、根をM、Mの左の子をF、右の子をT、Fの左の子をB、右の子をHと格納した。この木を中間順で走査した結果はどれか。",
            choices: [
                "B、F、H、M、T",
                "M、T、F、H、B",
                "M、F、B、H、T",
                "B、H、F、T、M"
            ],
            correctAnswerIndex: 0,
            explanation: "中間順走査は、左部分木、根、右部分木の順である。Fの部分木はB、F、Hとなり、その後に根M、右部分木TをたどるのでB、F、H、M、Tとなる。Mから始める並びは先行順、根を最後にする並びは後行順に近く、残る並びも左右の位置関係を崩している。三つの代表的な走査順を区別する。"
        ),

        QuizQuestion(
            question: "要素数600のデータを、バケット数1,000のハッシュ表に格納している。負荷率を「要素数÷バケット数」とすると、負荷率は幾らか。",
            choices: [
                "1.67",
                "0.6",
                "0.4",
                "600"
            ],
            correctAnswerIndex: 1,
            explanation: "定義どおり、負荷率は600÷1,000＝0.6である。0.4は空きバケットの割合、1.67は分子と分母を逆にした値、600は要素数そのものである。負荷率が高くなるほど衝突が増えやすいが、実際の性能はハッシュ関数や衝突処理法にも依存する。問題文で示された定義をそのまま式にすることが重要である。"
        ),

        QuizQuestion(
            question: "次の処理で、命令x ← x＋1は何回実行されるか。\n整数型: i, j, x\nx ← 0\nfor (iを1から6まで1ずつ増やす)\n  for (jを1からiまで1ずつ増やす)\n    x ← x＋1\n  endfor\nendfor",
            choices: [
                "36回",
                "18回",
                "21回",
                "6回"
            ],
            correctAnswerIndex: 2,
            explanation: "内側の繰返し回数は外側のiに等しいので、総回数は1＋2＋3＋4＋5＋6＝21回である。6回は外側だけを数えた値、18回は平均を誤った値、36回は常に6回ずつ実行するとみなした値である。上限が変化する二重ループでは、各回の実行回数を列挙して総和を求める。一般に1からnまでの和はn(n＋1)/2である。"
        ),

        QuizQuestion(
            question: "同じキーをもつ要素の相対的な順序を、整列後も維持することが保証される整列アルゴリズムはどれか。",
            choices: [
                "ヒープソート",
                "マージソート",
                "一般的なクイックソート",
                "選択ソート"
            ],
            correctAnswerIndex: 1,
            explanation: "マージソートは、併合時に同値なら元の並びを優先する実装によって安定整列にでき、一般に安定な整列法として扱われる。選択ソートは最小要素との交換で同値要素の順序が変わり得る。ヒープソートも木の再構成で順序を保たず、一般的なクイックソートも分割交換で順序が変わり得る。安定性は複合キー整列で重要である。"
        ),

        QuizQuestion(
            question: "昇順に整列済みの要素数1,000の配列を二分探索する。探索範囲を毎回ほぼ半分にするとき、最悪の場合の比較回数の上限として最も近いものはどれか。",
            choices: [
                "5回",
                "10回",
                "100回",
                "500回"
            ],
            correctAnswerIndex: 1,
            explanation: "2の10乗＝1,024なので、1,000要素の探索範囲は約10回の比較で1要素まで絞り込める。5回では最大32区分しか扱えず、100回や500回は線形探索に近い過大な値である。二分探索の比較回数は要素数nに対しておおむねlog2 nで増える。ただし、適用には配列が探索キーで整列済みであることが必要である。"
        ),

        QuizQuestion(
            question: "要素番号が1から始まる配列a＝{3, 8, 2, 5, 7}に対し、次の処理を行う。終了後のaはどれか。\n整数型: i, t\nfor (iを1から2まで1ずつ増やす)\n  t ← a[i]\n  a[i] ← a[6－i]\n  a[6－i] ← t\nendfor",
            choices: [
                "{3, 8, 2, 5, 7}",
                "{5, 7, 2, 3, 8}",
                "{7, 5, 2, 8, 3}",
                "{8, 3, 2, 7, 5}"
            ],
            correctAnswerIndex: 2,
            explanation: "i＝1でa[1]とa[5]を交換し、{7,8,2,5,3}となる。i＝2でa[2]とa[4]を交換し、{7,5,2,8,3}となる。中央のa[3]は変化しない。ほかの選択肢は交換相手の添字6－iを誤ったり、交換を片方向の代入として扱ったりしている。この処理は配列の両端から対応要素を交換して逆順にする。"
        ),

        QuizQuestion(
            question: "次の関数gcd(84, 30)の戻り値はどれか。\n○整数型: gcd(整数型: x, 整数型: y)\n  整数型: r\n  while (y ≠ 0)\n    r ← x mod y\n    x ← y\n    y ← r\n  endwhile\n  return x",
            choices: [
                "6",
                "30",
                "12",
                "2"
            ],
            correctAnswerIndex: 0,
            explanation: "84 mod 30＝24、30 mod 24＝6、24 mod 6＝0となる。yが0になった時点のxは6なので戻り値は6である。これはユークリッドの互除法で最大公約数を求める処理である。2は途中の剰余を誤算した値、12は84と30の公約数ではなく、30は初期の第2引数をそのまま返した値である。剰余が0になる直前の除数が最大公約数となる。"
        ),

        QuizQuestion(
            question: "次の再帰関数f(5)を呼び出したとき、関数fは最初の呼出しを含めて合計何回呼び出されるか。\n○整数型: f(整数型: n)\n  if (n ≦ 1)\n    return 1\n  else\n    return f(n－2)＋1\n  endif",
            choices: [
                "5回",
                "4回",
                "3回",
                "2回"
            ],
            correctAnswerIndex: 2,
            explanation: "呼出しはf(5)→f(3)→f(1)となり、f(1)で条件n≦1を満たして終了する。したがって最初の呼出しを含めて3回である。2回は終端呼出しを数えておらず、4回や5回はnが1ずつ減ると誤解した値である。再帰問題では、引数がどのように変化し、どの条件で停止するかを呼出し列として追跡する。"
        ),

        QuizQuestion(
            question: "逆ポーランド表記「6 2 3 ＋ × 4 －」をスタックで評価した結果はどれか。",
            choices: [
                "14",
                "20",
                "26",
                "44"
            ],
            correctAnswerIndex: 2,
            explanation: "6を積み、2と3を積んで加算すると5になる。次に6×5＝30を積み、4を積んで30－4＝26となる。14は演算順序を通常の中置記法のように扱った値、20は最後の減算を誤った値、44は加減算の結合を誤っている。逆ポーランド表記では、演算子が現れたら直前の二つの値を取り出し、順序を保って計算する。"
        ),

        QuizQuestion(
            question: "単方向リストで、節点Pの直後に新しい節点Nを挿入する。P.nextが元々指していた節点を失わない正しい代入順序はどれか。",
            choices: [
                "N.next ← P.next の後に P.next ← N",
                "P.next ← N の後に N.next ← P.next",
                "N.next ← P の後に P.next ← N",
                "P ← N の後に N.next ← P.next"
            ],
            correctAnswerIndex: 0,
            explanation: "先にN.nextへP.nextの旧値を保存し、その後P.nextをNへ変更すれば、P→N→旧後続節点という連結になる。先にP.nextをNへ変えると、続くN.next←P.nextでN自身を指す可能性がある。N.next←Pは逆向きの連結となり、P←Nは局所変数の参照を変えるだけでリストを挿入できない。参照更新では失われるリンクを先に退避する。"
        ),

        QuizQuestion(
            question: "論理式 not (P or Q) と常に同じ真理値をとる式はどれか。",
            choices: [
                "(not P) and (not Q)",
                "(not P) or (not Q)",
                "P and Q",
                "P or Q"
            ],
            correctAnswerIndex: 0,
            explanation: "ド・モルガンの法則により、論理和全体の否定は各項を否定した論理積に変換されるので、not(P or Q)＝(not P) and (not Q)である。(not P) or (not Q)はnot(P and Q)に等しい。P and QとP or Qは否定がなく、元の式とは一致しない。否定を括弧内へ分配するときは、andとorを相互に入れ替える。"
        ),

        QuizQuestion(
            question: "10進小数0.1を2進浮動小数点で有限桁に丸めて保持し、これを10回加算した。結果が厳密に1.0にならないことがある主な理由はどれか。",
            choices: [
                "10回加算すると必ず桁あふれするから。",
                "浮動小数点数では加算が定義されていないから。",
                "符号ビットが加算のたびに反転するから。",
                "0.1は2進数では循環小数となり、有限桁への丸め誤差が累積するから。"
            ],
            correctAnswerIndex: 3,
            explanation: "10進数0.1は2進数で有限桁に表せず、循環する値を有限の仮数部へ丸めて格納する。その近似値を繰り返し加算すると誤差が累積し、厳密な1.0と一致しない場合がある。加算自体は定義されており、値の大きさから桁あふれも通常起こらず、符号ビットも反転しない。金額などでは誤差を考慮した表現を選ぶ。"
        ),

        QuizQuestion(
            question: "頂点A、B、C、Dをもつ重み付き無向グラフがある。辺の重みはA-B＝4、A-C＝9、B-C＝2、B-D＝7、C-D＝3である。AからDまでの最短距離は幾らか。",
            choices: [
                "9",
                "12",
                "7",
                "10"
            ],
            correctAnswerIndex: 0,
            explanation: "候補経路を比較すると、A-B-Dは4＋7＝11、A-C-Dは9＋3＝12、A-B-C-Dは4＋2＋3＝9であり、最短距離は9である。7はB-Dの辺だけを見た値、10は経路の加算誤り、12はA-C-Dの距離である。最短経路では直結辺だけでなく、途中の小さい重みを組み合わせた経路も確認する。"
        ),

        QuizQuestion(
            question: "伝送速度が24Mビット/秒、伝送効率が75%の回線で、実データ90Mビットを送信するのに必要な時間は何秒か。遅延は無視する。",
            choices: [
                "5秒",
                "3.75秒",
                "6.67秒",
                "4秒"
            ],
            correctAnswerIndex: 0,
            explanation: "実効伝送速度は24×0.75＝18Mビット/秒である。したがって送信時間は90÷18＝5秒となる。3.75秒は効率を時間に直接掛けた値、4秒は90÷24を丸めた値、6.67秒は効率を逆方向に扱った値である。オーバヘッドを含む回線では、まず公称速度に伝送効率を掛けて実効速度を求める。"
        ),

        QuizQuestion(
            question: "室温を目標値に保つ制御で、実際の室温をセンサで測り、目標値との差に応じてヒータ出力を調整する方式はどれか。",
            choices: [
                "フィードバック制御",
                "シーケンス制御",
                "フィードフォワード制御",
                "オープンループ制御"
            ],
            correctAnswerIndex: 0,
            explanation: "実測した室温を目標値と比較し、その偏差を小さくするよう出力を調整するのでフィードバック制御である。フィードフォワード制御は外乱を予測して先回りして操作し、シーケンス制御は定めた順序や条件で動作を進める。オープンループ制御は出力結果を入力側へ戻さない。目標値と実測値の差を利用する点が識別の要点である。"
        ),

        QuizQuestion(
            question: "最高周波数が3kHzの信号を、標本化定理を満たして標本化する。理論上必要な標本化周波数の下限はどれか。",
            choices: [
                "9kHz",
                "6kHz",
                "1.5kHz",
                "3kHz"
            ],
            correctAnswerIndex: 1,
            explanation: "標本化定理では、標本化周波数を信号に含まれる最高周波数の2倍以上にする必要がある。したがって下限は3×2＝6kHzである。1.5kHzは半分、3kHzは同じ周波数で不足し、9kHzは条件を満たすが下限ではない。実際の装置ではフィルタ特性などを考慮して下限より余裕をもたせる。"
        ),

        QuizQuestion(
            question: "要素番号が1から始まる整数配列a＝{2, 3, 2, 5, 3, 2}に対し、次の処理を行う。終了後のcount[2]の値はどれか。countの全要素は0で初期化されている。\nfor (iを1から6まで1ずつ増やす)\n  count[a[i]] ← count[a[i]]＋1\nendfor",
            choices: [
                "3",
                "2",
                "6",
                "1"
            ],
            correctAnswerIndex: 0,
            explanation: "配列aの各値を添字として対応するcount要素を1ずつ増やす処理である。値2はa[1]、a[3]、a[6]の3回出現するのでcount[2]＝3となる。1は初回だけを数えた値、2は値3の出現回数、6は全要素数である。頻度表では、データ値を配列の添字として利用し、出現のたびに対応するカウンタを更新する。"
        ),

        QuizQuestion(
            question: "次の処理を実行した後のsの値はどれか。\n整数型: n, s\nn ← 13\ns ← 0\nwhile (n ＞ 0)\n  s ← s＋(n mod 2)\n  n ← n ÷ 2  /* 小数点以下切捨て */\nendwhile",
            choices: [
                "13",
                "2",
                "4",
                "3"
            ],
            correctAnswerIndex: 3,
            explanation: "13を2で割りながら剰余を加える。13 mod 2＝1、6 mod 2＝0、3 mod 2＝1、1 mod 2＝1なので、s＝3である。これは13の2進表現1101に含まれる1の個数を数える処理である。2や4は剰余列の集計誤り、13は初期値を返したとみなす誤りである。整数除算と剰余を組み合わせると基数変換やビット数計算ができる。"
        ),

        QuizQuestion(
            question: "関数に配列のコピーを渡し、関数内でその配列要素を変更した。呼出し元の配列を変更しない受渡し方式はどれか。",
            choices: [
                "参照渡し",
                "値渡し",
                "ポインタ渡し",
                "共有参照による受渡し"
            ],
            correctAnswerIndex: 1,
            explanation: "値渡しでは実引数の値のコピーが仮引数へ渡されるため、関数内でコピーを変更しても呼出し元の配列には影響しない。参照渡し、ポインタ渡し、共有参照による受渡しでは、同じ実体へ到達できるため変更が呼出し元へ反映され得る。実際の言語では配列の扱いが異なるので、問題文で定義された受渡し方式を確認することが重要である。"
        ),

        QuizQuestion(
            question: "コンパイラ方式と比較したインタプリタ方式の一般的な特徴として、適切なものはどれか。",
            choices: [
                "実行前に必ず機械語の実行ファイルを生成する。",
                "ソースプログラムがなくても解釈実行できる。",
                "どのプログラムでもコンパイラ方式より実行速度が速い。",
                "命令を逐次解釈して実行するので、修正直後に実行しやすい。"
            ],
            correctAnswerIndex: 3,
            explanation: "インタプリタ方式はソースの命令を逐次解釈して実行するため、編集後すぐ試しやすい。一方、一般に実行のたびに解釈処理が入り、コンパイル済みコードより遅くなることがある。実行ファイルの事前生成はコンパイラ方式の特徴であり、解釈には通常ソース又は中間表現が必要である。方式の違いは翻訳時期と実行方法にある。"
        ),

        QuizQuestion(
            question: "ある符号集合の最小ハミング距離が3である。この符号で保証できる能力として適切なものはどれか。",
            choices: [
                "3ビット誤りの訂正",
                "2ビット誤りの訂正",
                "1ビット誤りの訂正",
                "任意個数の誤りの訂正"
            ],
            correctAnswerIndex: 2,
            explanation: "最小ハミング距離dの符号は、床((d－1)/2)ビットまでの誤り訂正を保証できる。d＝3なので床(2/2)＝1ビットである。2ビット以上の訂正には少なくとも距離5が必要であり、3ビットや任意個数の訂正も保証できない。なお、検出だけならd－1＝2ビットまで可能である。検出能力と訂正能力を混同しない。"
        )
    ]
        
    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager.shared
    private var audioManager = AudioManager.shared

    init(isPresenting: Binding<Bool>, isInfiniteMode: Bool = false) {
        _isPresenting = isPresenting
        self.isInfiniteMode = isInfiniteMode
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .infoBasic, isInfiniteMode: isInfiniteMode, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizInfoBasicListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizInfoBasicListView(isPresenting: .constant(false))
    }
}
