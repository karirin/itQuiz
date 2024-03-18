//
//  QuizBeginnerStoryView.swift
//  it
//
//  Created by Apple on 2024/02/14.
//

import SwiftUI

class QuizBeginnerStoryViewModel: ObservableObject {
    
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
            
            // 追加の問題 2024/3/4
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
                  question: "データベースで「外部キー」の役割は何か？",
                  choices: [
                      "テーブル内のレコードを一意に識別する",
                      "テーブル間の関係を表す",
                      "データの整合性を保つ",
                      "両方BとC"
                  ],
                  correctAnswerIndex: 3,
                  explanation: "外部キーは、異なるテーブル間の関係を表し、関連するデータ間の整合性を保つ役割を持っています。"
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
              )
        ]
            
        @State var shuffledQuizList: [QuizQuestion]


        init() {
            _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
        }
}

struct QuizBeginnerStory1List: View {
    @ObservedObject var viewModel: QuizBeginnerStoryViewModel
    var authManager = AuthManager()
    var audioManager = AudioManager.shared
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>, viewModel: QuizBeginnerStoryViewModel) {
           self._isPresenting = isPresenting
           self.viewModel = viewModel // viewModelを初期化
       }
    
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: viewModel.shuffledQuizList, quizLevel: .beginnerStory1, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizBeginnerStory2List: View {
    @ObservedObject var viewModel: QuizBeginnerStoryViewModel
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>, viewModel: QuizBeginnerStoryViewModel) {
           self._isPresenting = isPresenting
           self.viewModel = viewModel // viewModelを初期化
       }
    
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: viewModel.shuffledQuizList, quizLevel: .beginnerStory2, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizBeginnerStory3List: View {
    @ObservedObject var viewModel: QuizBeginnerStoryViewModel
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared
    @Binding var isPresenting: Bool
    
    init(isPresenting: Binding<Bool>, viewModel: QuizBeginnerStoryViewModel) {
           self._isPresenting = isPresenting
           self.viewModel = viewModel // viewModelを初期化
       }
    
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: viewModel.shuffledQuizList, quizLevel: .beginnerStory3, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizBeginnerStoryList_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用のViewModelのインスタンスを作成
        let viewModel = QuizBeginnerStoryViewModel()
        // このインスタンスをTestビューの初期化時に渡す
        QuizBeginnerStory1List(isPresenting: .constant(false), viewModel: viewModel)
    }
}
