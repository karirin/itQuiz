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
    let quizBeginnerList: [QuizQuestion] = [
        QuizQuestion(
            question: "AIを開発するベンチャー企業のA社が，資金調達を目的に，金融商品取引所に初めて上場することになった。このように，企業の未公開の株式を，新たに公開することを表す用語として，最も適切なものはどれか。",
            choices: [
                "IPO",
                "LBO",
                "TOB",
                "VC"
            ],
            correctAnswerIndex: 0,
            explanation: "IPO（Initial Public Offering）は、企業が初めて公開市場で株式を発行することを指します。"
            ),
        QuizQuestion(
            question: "次のうち、ウォーターフォールモデルの特徴として正しいものはどれか？",
            choices: [
                "各フェーズが終了すると次のフェーズに戻ることはできない。",
                "継続的にフィードバックを受け取りながら開発を進める。",
                "クライアントとのコミュニケーションは開始と終了のみで十分。",
                "開発途中でも頻繁にプロトタイプを作成する。"
            ],
            correctAnswerIndex: 0,
            explanation: "ウォーターフォールモデルは、各フェーズが順番に進行し、一度終了したフェーズには戻らないという特徴があります。"
        ),
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
        )
    ]

    @State private var shuffledQuizList: [QuizQuestion]

    init() {
        _shuffledQuizList = State(initialValue: quizBeginnerList.shuffled())
    }

    var body: some View {
        QuizView(quizzes: shuffledQuizList)
    }
}

struct QuizList_Previews: PreviewProvider {
    static var previews: some View {
        QuizBeginnerList()
    }
}