//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizInfoBasicListView: View {
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
            )
        ,
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
                    "NoSQL",
                    "Redis",
                    "Cassandra"
                ],
                correctAnswerIndex: 1,
                explanation: "NoSQLはドキュメント指向の非関係データベース管理システムです。"
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
                    ),
        // 追加 2024/3/4
        QuizQuestion(
            question: "Web開発におけるフロントエンドとバックエンドの主な違いは何か？",
            choices: [
                "フロントエンドはクライアントサイドの開発に関わり、バックエンドはサーバーサイドの開発に関わる",
                "フロントエンドはデータベース管理に専念し、バックエンドはユーザーインターフェースの設計に専念する",
                "フロントエンドはセキュリティ対策に関わり、バックエンドはパフォーマンス最適化に関わる",
                "フロントエンドはハードウェア設計に関わり、バックエンドはソフトウェア開発に関わる"
            ],
            correctAnswerIndex: 0,
            explanation: "フロントエンド開発はウェブサイトのユーザーインターフェースとユーザーエクスペリエンスを担当し、バックエンド開発はサーバー、アプリケーション、データベースの管理といったサーバーサイドの機能を担当します。"
        ),
         QuizQuestion(
            question: "プログラミングにおける「ポリモーフィズム」とは何か？",
            choices: [
                "ソースコードが複数のプログラミング言語で書かれていること",
                "単一のインターフェースを通じて異なるデータ型に対して同じ操作を適用できる能力",
                "プログラムが実行時にその形を変える能力",
                "異なる機能を持つ複数のオブジェクトが同じ名前のメソッドを使用すること"
            ],
            correctAnswerIndex: 1,
            explanation: "ポリモーフィズムはオブジェクト指向プログラミングの概念の一つで、異なるクラスのオブジェクトが同じインターフェースやメソッドを通じて操作されることを指します。"
        ),
         QuizQuestion(
            question: "クラウドコンピューティングにおいて、インフラストラクチャー（サーバー、ストレージなど）をサービスとして提供するモデルは何か？",
            choices: [
                "Software as a Service (SaaS)",
                "Platform as a Service (PaaS)",
                "Infrastructure as a Service (IaaS)",
                "Function as a Service (FaaS)"
            ],
            correctAnswerIndex: 2,
            explanation: "IaaSは、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルで、ユーザーはオンデマンドでインフラストラクチャーを利用し、管理することができます。"
        ),
         QuizQuestion(
            question: "ソフトウェア開発において、プロジェクトの進行状況や成果物を定期的に検証し、適宜調整を行うアプローチは何というか？",
            choices: [
                "ウォーターフォールモデル",
                "スクラム",
                "カンバン",
                "スパイラルモデル"
            ],
            correctAnswerIndex: 1,
            explanation: "スクラムは、短いスプリントと呼ばれる期間を設け、定期的にプロジェクトの進行状況や成果物を検証し、必要に応じて計画を調整するアジャイル開発のフレームワークです。"
        ),
         QuizQuestion(
            question: "ウェブアプリケーションでユーザーのセッション情報を一時的に保存するために主に使用される技術は何か？",
            choices: [
                "クッキー",
                "セッション",
                "ローカルストレージ",
                "キャッシュ"
            ],
            correctAnswerIndex: 1,
            explanation: "セッションは、サーバー側でユーザーのセッション情報を一時的に保存する技術で、ログイン状態の管理などに使用されます。"
        ),
         QuizQuestion(
            question: "インターネットのドメイン名システム(DNS)において、ドメイン名をIPアドレスに変換するサーバーは何と呼ばれるか？",
            choices: [
                "メールサーバー",
                "ファイルサーバー",
                "DNSサーバー",
                "Webサーバー"
            ],
            correctAnswerIndex: 2,
            explanation: "DNSサーバーは、インターネットのドメイン名システムにおいて、人間が覚えやすいドメイン名を機械が処理しやすいIPアドレスに変換する役割を持ちます。"
        ),
         QuizQuestion(
            question: "ネットワークセキュリティで用いられる、暗号化と復号化の鍵が異なる暗号方式は何か？",
            choices: [
                "対称鍵暗号方式",
                "非対称鍵暗号方式",
                "ハッシュ関数",
                "デジタル署名"
            ],
            correctAnswerIndex: 1,
            explanation: "非対称鍵暗号方式は、暗号化と復号化に異なる鍵（公開鍵と秘密鍵）を使用する方式で、インターネット上での安全なデータ交換に利用されます。"
        ),
         QuizQuestion(
            question: "ウェブ開発における「レスポンシブデザイン」の主な目的は何か？",
            choices: [
                "ウェブページのローディング時間を短縮する",
                "異なるデバイスサイズでの表示を最適化する",
                "ウェブサイトのセキュリティを強化する",
                "ウェブサイトの検索エンジン最適化（SEO）を改善する"
            ],
            correctAnswerIndex: 1,
            explanation: "レスポンシブデザインは、スマートフォン、タブレット、デスクトップなど、異なるデバイスサイズに対応し、ユーザーに適切な表示を提供するウェブデザインのアプローチです。"
        ),
          QuizQuestion(
             question: "ソフトウェアテストにおいて、実際のユーザー環境でソフトウェアの動作を評価するテストは何か？",
             choices: [
                 "ユニットテスト",
                 "統合テスト",
                 "システムテスト",
                 "受け入れテスト"
             ],
             correctAnswerIndex: 3,
             explanation: "受け入れテストは、実際のユーザー環境でソフトウェアが要件を満たしているかを確認するために行われ、製品がエンドユーザーに受け入れられるかを評価します。"
         ),
          QuizQuestion(
             question: "プログラミング言語における「ポリモーフィズム」とは何を指すか？",
             choices: [
                 "変数が複数の型の値を取る能力",
                 "一つのインターフェースに対して複数の実装を提供する能力",
                 "コードの実行速度を向上させる技術",
                 "エラーを自動的に修正する機能"
             ],
             correctAnswerIndex: 1,
             explanation: "ポリモーフィズムはオブジェクト指向プログラミングの概念の一つで、同一のインターフェースに対して異なる形式や動作を提供する能力を指します。"
         ),
          QuizQuestion(
             question: "クラウドコンピューティングにおいて、サーバー、ストレージ、ネットワークなどのコンピューティングリソースをオンデマンドで提供するサービスモデルは何か？",
             choices: [
                 "Software as a Service (SaaS)",
                 "Platform as a Service (PaaS)",
                 "Infrastructure as a Service (IaaS)",
                 "Function as a Service (FaaS)"
             ],
             correctAnswerIndex: 2,
             explanation: "IaaSは、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルです。ユーザーは必要に応じてリソースをスケールアップまたはダウンできます。"
         ),
          QuizQuestion(
             question: "Webアプリケーションにおける「RESTful API」とは、どのような特徴を持つAPIのことか？",
             choices: [
                 "ステートフルな通信を行うAPI",
                 "XMLベースのメッセージフォーマットを使用するAPI",
                 "HTTPメソッドを用いてリソースの状態を操作するAPI",
                 "専用のプロトコルを必要とするAPI"
             ],
             correctAnswerIndex: 2,
             explanation: "RESTful APIは、HTTPメソッド（GET、POST、PUT、DELETEなど）を用いてリソースの状態を操作し、Webサービスのインターフェースとして機能するAPIです。これにより、シンプルで柔軟なアプリケーション構築が可能になります。"
         ),
          QuizQuestion(
             question: "ブロックチェーン技術が最も注目されている用途は何か？",
             choices: [
                 "ソーシャルネットワーキング",
                 "オンライン広告",
                 "仮想通貨",
                 "クラウドストレージ"
             ],
             correctAnswerIndex: 2,
             explanation: "ブロックチェーン技術は、仮想通貨（特にビットコイン）の基盤技術として最も注目されています。この技術により、中央機関の介在なく取引の信頼性を保証することが可能になります。"
         ),
         QuizQuestion(
            question: "ソフトウェアテストにおいて、システム全体が要件を満たしているかどうかを検証するテストは何か？",
            choices: [
                "ユニットテスト",
                "インテグレーションテスト",
                "システムテスト",
                "受け入れテスト"
            ],
            correctAnswerIndex: 2,
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
                "CSS",
                "HTML",
                "JavaScript",
                "PHP"
            ],
            correctAnswerIndex: 2,
            explanation: "JavaScriptはクライアントサイドで実行されるスクリプト言語であり、ウェブサイトのユーザーインターフェースを動的に変更するために広く使用されています。"
        ),
         QuizQuestion(
            question: "ソフトウェア開発プロジェクトで使用される、製品のリリース前に発見されたバグを管理するプロセスは何というか？",
            choices: [
                "バグトラッキング",
                "パフォーマンスモニタリング",
                "コードレビュー",
                "バージョンコントロール"
            ],
            correctAnswerIndex: 0,
            explanation: "バグトラッキングは、ソフトウェア開発プロジェクトで発見されたバグを記録、追跡、管理するためのプロセスです。"
        ),
         QuizQuestion(
            question: "データを構造化する際に用いられる、キーと値のペアで構成されるデータ構造は何か？",
            choices: [
                "配列",
                "リスト",
                "マップ（辞書）",
                "セット"
            ],
            correctAnswerIndex: 2,
            explanation: "マップ（辞書）は、キーと値のペアでデータを構造化するために使用されるデータ構造です。キーを通じて値を効率的に検索できます。"
        ),
          QuizQuestion(
             question: "オンラインでのプライバシー保護と匿名性を高めるために使用されるネットワークは何か？",
             choices: ["VPN（Virtual Private Network）", "LAN（Local Area Network）", "WAN（Wide Area Network）", "TOR（The Onion Router）"],
             correctAnswerIndex: 3,
             explanation: "TOR（The Onion Router）ネットワークは、インターネット上でのプライバシー保護と匿名性を高めるために使用されます。ユーザーのトラフィックを複数のサーバーを介してルーティングすることで匿名性を提供します。"
         ),
          QuizQuestion(
             question: "オープンソースソフトウェアプロジェクトでソースコードの変更や貢献を追跡するために一般的に使用されるシステムは何か？",
             choices: ["Bugzilla", "Jira", "GitHub", "Trello"],
             correctAnswerIndex: 2,
             explanation: "GitHubは、ソフトウェア開発プロジェクトでソースコードの管理、変更追跡、貢献を容易にするために広く使用されるプラットフォームです。オープンソースプロジェクトでのコラボレーションに特に役立ちます。"
         ),
          QuizQuestion(
             question: "ソフトウェア開発プロジェクトにおける「スプリント」とは何か？",
             choices: ["開発チームが特定の機能を完成させるために設ける長期計画", "プロジェクトの最終段階での品質チェック", "短期間で特定の目標達成を目指すアジャイル開発の作業単位", "コードの最適化とリファクタリングを行う期間"],
             correctAnswerIndex: 2,
             explanation: "スプリントはアジャイルソフトウェア開発方法論において、通常1～4週間の固定期間で設定される作業単位であり、この期間内でチームはプロダクトバックログから選択した項目を完成させることを目指します。"
         ),
          QuizQuestion(
             question: "「ポリモーフィズム」とは、プログラミングにおいてどのような概念を指すか？",
             choices: ["異なるクラスのオブジェクトが同一のインターフェースを通じてアクセス可能である性質", "クラス間でコードを共有するためのメカニズム", "プログラムが実行時にデータ型を決定する能力", "オブジェクトが複数の形態を取ることができる性質"],
             correctAnswerIndex: 0,
             explanation: "ポリモーフィズムはオブジェクト指向プログラミングの重要な概念の一つで、異なるクラスのオブジェクトが同一のインターフェース（メソッド）を通じて操作できる性質を指します。これにより、プログラムの柔軟性と再利用性が向上します。"
         ),
          QuizQuestion(
             question: "ウェブページで動的なデータの取得と表示を容易にするJavaScriptライブラリはどれか？",
             choices: ["AngularJS", "jQuery", "React", "Vue.js"],
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
             choices: ["コードの品質を向上させる", "開発プロセスを高速化する", "チーム間のコラボレーションを改善する", "すべての上記"],
             correctAnswerIndex: 3,
             explanation: "継続的インテグレーションは、コードの品質を向上させ、開発プロセスを高速化し、チーム間のコラボレーションを改善することを目的としています。"
         ),
              QuizQuestion(
                 question: "データサイエンスにおいて、大量のデータからパターンや知識を抽出するプロセスを何というか？",
                 choices: ["データマイニング", "データベース管理", "データエントリ", "データアーキテクチャ"],
                 correctAnswerIndex: 0,
                 explanation: "データマイニングは、大量のデータセットから有用な情報や新しい知識を抽出する分析プロセスです。"
             ),
              QuizQuestion(
                 question: "ネットワークセキュリティにおいて、システム内での不正な活動やポリシー違反を検出するシステムは何か？",
                 choices: ["インシデント対応システム", "脆弱性管理システム", "侵入検知システム（IDS）", "リスク評価ツール"],
                 correctAnswerIndex: 2,
                 explanation: "侵入検知システム（IDS）は、システム内での不正な活動やポリシー違反を検出し、管理者に警告を発するセキュリティ技術です。"
             ),
              QuizQuestion(
                 question: "「ビッグデータ」とは何を指す用語か？",
                 choices: ["特定の業界における大量のデータ", "分析が困難なほど大規模で複雑なデータセット", "インターネット上で毎日生成されるデータ", "ストレージ容量を超えるデータ量"],
                 correctAnswerIndex: 1,
                 explanation: "ビッグデータは、従来のデータベース管理ツールやデータ処理アプリケーションでは取り扱いが困難なほどの大規模で複雑なデータセットを指します。ビッグデータの分析は、ビジネスの意思決定、科学研究、社会インフラの最適化など幅広い分野で利用されています。"
             ),
              QuizQuestion(
                 question: "モダンなWeb開発において、コンポーネントベースのアーキテクチャを提供するJavaScriptフレームワークはどれか？",
                 choices: ["Angular", "Bootstrap", "jQuery", "PHP"],
                 correctAnswerIndex: 0,
                 explanation: "Angularはコンポーネントベースのアーキテクチャを提供するモダンなJavaScriptフレームワークです。"
             ),
              QuizQuestion(
                 question: "ソフトウェアテストにおいて、「ブラックボックステスト」の特徴は何か？",
                 choices: ["内部構造を知らずにテストを行う", "コードレベルでのテストを行う", "開発者のみが実行できるテスト", "ソースコードの変更を伴うテスト"],
                 correctAnswerIndex: 0,
                 explanation: "ブラックボックステストは、アプリケーションの内部構造や動作を知らずに、インターフェイスを通じてテストを行う方法です。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングサービスで、完全に管理されたデータベースサービスを提供するものは何か？",
                 choices: ["IaaS", "PaaS", "SaaS", "DBaaS"],
                 correctAnswerIndex: 3,
                 explanation: "DBaaS（Database as a Service）は、完全に管理されたデータベースサービスを提供し、ユーザーはデータベースの管理に関する心配をする必要がありません。"
             ),
              QuizQuestion(
                 question: "モバイルアプリ開発において、iOSとAndroidアプリケーションの両方を開発するために使用されるクロスプラットフォームフレームワークは何か？",
                 choices: ["Xamarin", "React Native", "Flutter", "Kotlin"],
                 correctAnswerIndex: 2,
                 explanation: "Flutterは、iOSとAndroidの両方のプラットフォームに対応するアプリケーションを開発するためのクロスプラットフォームフレームワークです。"
             ),
              QuizQuestion(
                 question: "プログラミングにおいて、非同期処理を実装するためのJavaScriptの機能は何か？",
                 choices: ["Promises", "Callbacks", "Events", "AとBの両方"],
                 correctAnswerIndex: 3,
                 explanation: "JavaScriptでは、非同期処理を実装するためにPromisesやCallbacksが使用されます。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングの「パブリッククラウド」とは何か？",
                 choices: ["特定の組織が専用に使用するクラウドサービス", "複数のテナントが共有するクラウドサービス", "個人ユーザー向けの無料クラウドサービス", "インターネットを介さずに利用するクラウドサービス"],
                 correctAnswerIndex: 1,
                 explanation: "パブリッククラウドは、サービスプロバイダーがインターネットを通じて一般に提供するクラウドサービスの形態です。このモデルでは、複数の顧客（テナント）が物理的なリソースを共有しますが、セキュリティとプライバシーは仮想化技術によって保護されます。"
             ),
              QuizQuestion(
                 question: "クラウドコンピューティングサービスモデルのうち、最も基盤となるリソース（サーバーやストレージなど）を提供するものは何か？",
                 choices: ["ソフトウェアアズアサービス（SaaS）", "プラットフォームアズアサービス（PaaS）", "インフラストラクチャアズアサービス（IaaS）", "ファンクションアズアサービス（FaaS）"],
                 correctAnswerIndex: 2,
                 explanation: "インフラストラクチャアズアサービス（IaaS）は、クラウドコンピューティングのサービスモデルの一つで、仮想マシンやストレージ、ネットワークなどのコンピューティングインフラをインターネット経由で提供します。これにより、ユーザーは物理的なハードウェアを自身で管理する必要がなくなります。"
             ),
          QuizQuestion(
             question: "RESTful API設計において、リソースの新規作成に一般的に使用されるHTTPメソッドは何か？",
             choices: ["GET", "POST", "PUT", "DELETE"],
             correctAnswerIndex: 1,
             explanation: "POSTメソッドは、新しいリソースを作成するためにRESTful API設計で一般的に使用されます。"
         ),
          QuizQuestion(
             question: "Pythonプログラミングにおいて、リスト内包表記の主な目的は何か？",
             choices: ["リストの要素を並べ替えるため", "新しいリストを簡潔に生成するため", "リストから特定の要素を削除するため", "リストの各要素に関数を適用するため"],
             correctAnswerIndex: 1,
             explanation: "リスト内包表記は、新しいリストを生成するための簡潔な方法を提供します。"
         ),
          QuizQuestion(
             question: "Gitにおいて、リモートリポジトリの変更をローカルリポジトリに取り込むコマンドは何か？",
             choices: ["git push", "git pull", "git clone", "git commit"],
             correctAnswerIndex: 1,
             explanation: "git pullコマンドは、リモートリポジトリの変更を現在のローカルブランチに統合します。"
         ),
          QuizQuestion(
             question: "クラウドサービスモデルの一つで、インフラストラクチャ（仮想マシン、ストレージなど）を提供するサービスは何か？",
             choices: ["SaaS (Software as a Service)", "PaaS (Platform as a Service)", "IaaS (Infrastructure as a Service)", "FaaS (Function as a Service)"],
             correctAnswerIndex: 2,
             explanation: "IaaSは、クラウドコンピューティングのサービスモデルの一つで、サーバー、ストレージ、ネットワーキングなどのインフラストラクチャを提供します。"
         ),
          QuizQuestion(
             question: "ウェブページ内でスタイルシートが使用される目的は何か？",
             choices: ["サーバーとの通信を改善するため", "ページの構造を定義するため", "ページの見た目とフォーマットを制御するため", "ページのコンテンツを動的に変更するため"],
             correctAnswerIndex: 2,
             explanation: "スタイルシート（CSS）は、ウェブページの見た目とフォーマットを定義するために使用されます。"
         ),
         QuizQuestion(
            question: "次のうち、コンテナ化されたアプリケーションを管理するためのオープンソースプラットフォームはどれか？",
            choices: ["Docker", "Kubernetes", "Vagrant", "Ansible"],
            correctAnswerIndex: 1,
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
            choices: ["ファイアウォール", "アンチウイルス", "暗号化", "IDS（侵入検知システム）"],
            correctAnswerIndex: 2,
            explanation: "暗号化は、データを不可解な形式に変換することで、未承認のアクセスからデータを保護するセキュリティメカニズムです。"
        ),
         QuizQuestion(
            question: "Webアプリケーションのセキュリティに関して、SQLインジェクション攻撃を防ぐ最善の方法は何か？",
            choices: ["強力なパスワードポリシーを使用する", "ユーザー入力のサニタイズ", "SSL/TLSを使用する", "ファイアウォールを設定する"],
            correctAnswerIndex: 1,
            explanation: "ユーザーからの入力をサニタイズすることで、SQLインジェクション攻撃を防ぐことができます。"
        ),
         QuizQuestion(
            question: "Web開発でユーザーの入力フォームデータをサーバーに送信するために使用されるHTMLタグは何か？",
            choices: ["<input>", "<form>", "<submit>", "<post>"],
            correctAnswerIndex: 1,
            explanation: "<form>タグは、ユーザーの入力を収集してサーバーに送信するために使用されるHTML要素です。"
        ),
         QuizQuestion(
            question: "オブジェクト指向プログラミングにおいて、異なるクラスのオブジェクトが共通のインターフェースを通じてアクセスされる概念を何というか？",
            choices: ["エンカプセレーション", "継承", "ポリモーフィズム", "抽象化"],
            correctAnswerIndex: 2,
            explanation: "ポリモーフィズムは、異なるクラスのオブジェクトが共通のインターフェースを通じて操作されるオブジェクト指向の概念です。"
        ),
         QuizQuestion(
            question: "以下のうち、非同期JavaScriptとXMLの略称は何か？",
            choices: ["AJAX", "JSON", "XML", "HTTP"],
            correctAnswerIndex: 0,
            explanation: "AJAX（Asynchronous JavaScript and XML）は、Webページの一部を非同期に更新するために使用される技術です。"
        ),
         QuizQuestion(
            question: "次のうち、バージョン管理システムではないものはどれか？",
            choices: ["Git", "SVN", "Mercurial", "Kubernetes"],
            correctAnswerIndex: 3,
            explanation: "Kubernetesは、コンテナのオーケストレーションを行うシステムであり、バージョン管理システムではありません。"
        ),
         QuizQuestion(
            question: "データベースにおいて、2つ以上のテーブル間でデータの整合性を保つために使用される制約は何か？",
            choices: ["チェック制約", "ユニーク制約", "参照整合性制約", "プライマリキー制約"],
            correctAnswerIndex: 2,
            explanation: "参照整合性制約は、異なるテーブル間のデータの整合性を保つために使用されるデータベースの制約です。"
        ),
         QuizQuestion(
            question: "CSSにおける「フレックスボックス」の使用目的は何か？",
            choices: [
                "ページ上の要素の色を管理するため",
                "ドキュメントのメタデータを指定するため",
                "レスポンシブなウェブデザインを実現するため",
                "コンテンツ間のスペースを動的に調整するため"
            ],
            correctAnswerIndex: 3,
            explanation: "フレックスボックスは、コンテナ内のアイテムのレイアウトを柔軟に調整するために使用されます。"
        ),
         QuizQuestion(
            question: "ウェブ開発における「レスポンシブデザイン」とは何か？",
            choices: [
                "ウェブサイトがリクエストに即座に応答する設計",
                "異なる画面サイズに対応して適切に表示されるウェブページの設計",
                "ユーザーの操作に反応して動的にコンテンツを変更する設計",
                "高速なページ読み込みを実現するためのウェブサイト設計"
            ],
            correctAnswerIndex: 1,
            explanation: "レスポンシブデザインは、ウェブページがデバイスの画面サイズに応じて内容を適切に調整し、最適なユーザーエクスペリエンスを提供するためのアプローチです。これにより、スマートフォン、タブレット、デスクトップなど、あらゆるデバイスでウェブサイトが適切に表示されます。"
        ),
         QuizQuestion(
            question: "「データベース正規化」の主な目的は何か？",
            choices: [
                "データベースのパフォーマンスを向上させる",
                "データの整合性とセキュリティを確保する",
                "データの重複を排除し、データモデルのシンプルさを保つ",
                "データベースのサイズを小さくする"
            ],
            correctAnswerIndex: 2,
            explanation: "データベース正規化は、データの重複を排除し、データの整合性を保ちながら、データモデルのシンプルさと効率性を高めるために行われます。正規化により、更新の異常や挿入の異常、削除の異常を防ぎ、データベースの保守が容易になります。"
        ),
         QuizQuestion(
            question: "「ブロックチェーン」とは何か？",
            choices: [
                "高性能なデータベース技術",
                "分散型デジタル台帳技術",
                "新世代の暗号化技術",
                "データ分析のためのアルゴリズム"
            ],
            correctAnswerIndex: 1,
            explanation: "ブロックチェーンは、分散型のデジタル台帳技術であり、取引履歴などのデータを複数の参加者間で共有し、改ざんが困難な方法で記録することができます。仮想通貨をはじめとする多くの応用が存在します。"
        ),
         QuizQuestion(
            question: "「マシンラーニング」における「教師あり学習」とは何か？",
            choices: [
                "データセットから自動で特徴を学習するプロセス",
                "予めラベル付けされたデータを使用してモデルを学習させるプロセス",
                "データにラベルを付けることなくモデルを学習させるプロセス",
                "モデルが自己学習を行い、パフォーマンスを向上させるプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "教師あり学習は、入力データとそれに対応する正解（ラベル）を事前に用意し、このデータセットを使用してモデルを訓練するマシンラーニングの一種です。このプロセスを通じて、モデルは入力データから正解を予測する方法を学習します。"
        ),
         QuizQuestion(
            question: "ソフトウェアテストにおける「回帰テスト」とは何か？",
            choices: [
                "新しい機能をテストするためのプロセス",
                "ソフトウェアの異なるバージョン間での互換性を確認するテスト",
                "既にテストされたソフトウェアが、変更後も期待通りに動作することを確認するテスト",
                "ユーザーインターフェースのテスト"
            ],
            correctAnswerIndex: 2,
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
        QuizView(quizzes: shuffledQuizList, quizLevel: .infoBasic, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizInfoBasicListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizInfoBasicListView(isPresenting: .constant(false))
    }
}

