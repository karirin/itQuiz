//
//  QuizIntermediateList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/19.
//

import SwiftUI

struct QuizIntermediateList: View {
    let QuizIntermediateList: [QuizQuestion] = [
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
               question: "次のうち、クラウドコンピューティングのサービスモデルで、ユーザーがアプリケーションを開発・実行するためのプラットフォームを提供するものはどれか？",
               choices: [
                   "IaaS",
                   "PaaS",
                   "SaaS",
                   "FaaS"
               ],
               correctAnswerIndex: 1,
               explanation: "PaaSは、ユーザーがアプリケーションを開発・実行するためのプラットフォームを提供するクラウドサービスモデルです。"
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
           )
    ]

    @State private var shuffledQuizList: [QuizQuestion]

    init() {
        _shuffledQuizList = State(initialValue: QuizIntermediateList.shuffled())
    }

    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .intermediate)
    }
}

struct QuizIntermediateList_Previews: PreviewProvider {
    static var previews: some View {
        QuizIntermediateList()
    }
}
