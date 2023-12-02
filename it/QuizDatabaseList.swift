//
//  QuizDatabaseList.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/07.
//

import SwiftUI

struct QuizDatabaseList: View {
    @Binding var isPresenting: Bool
//    let QuizDatabaseList: [QuizQuestion] = [
//        QuizQuestion(
//            question: "「SQLインジェクション」攻撃とは何ですか？",
//            choices: [
//                "データベースに不正なSQLクエリを挿入し、データを操る攻撃",
//                "データベースのサイズを増加させる攻撃",
//                "データベースの接続を遮断する攻撃",
//                "データベースのバックアップを削除する攻撃"
//            ],
//            correctAnswerIndex: 0,
//            explanation: "SQLインジェクションは、攻撃者がデータベースに不正なSQLクエリを挿入し、データを操るタイプの攻撃です。"
//        )
//    ]
    let QuizDatabaseList: [QuizQuestion] = [
        QuizQuestion(
            question: "SQLは何の略語ですか？",
            choices: [
                "Structured Query Language",
                "Sequential Question Language",
                "Simplified Quality Language",
                "Secure Quick Language"
            ],
            correctAnswerIndex: 0,
            explanation: "SQLはStructured Query Languageの略で、データベースから情報を取得、挿入、更新、削除するための言語です。"
        ),

        QuizQuestion(
            question: "「プライマリキー」とは何ですか？",
            choices: [
                "データベーステーブルの各レコードを一意に識別するキー",
                "データベーステーブルのすべてのレコードを識別するキー",
                "データベースのセキュリティを強化するキー",
                "データベースのパスワード"
            ],
            correctAnswerIndex: 0,
            explanation: "プライマリキーは、データベーステーブルの各レコードを一意に識別するためのキーです。"
        ),

//        QuizQuestion(
//            question: "「正規化」とは何ですか？",
//            choices: [
//                "データベースのパフォーマンスを向上させるプロセス",
//                "データベースのサイズを減らすプロセス",
//                "データベース内のデータの重複を排除し、データの整合性を保つプロセス",
//                "データベースを暗号化するプロセス"
//            ],
//            correctAnswerIndex: 2,
//            explanation: "正規化は、データベース内のデータの重複を排除し、データの整合性を保つプロセスです。"
//        ),

        QuizQuestion(
            question: "「インデックス」とは何ですか？",
            choices: [
                "データベースのサイズ",
                "データベースのパフォーマンスを向上させるためのデータ構造",
                "データベースのバージョン",
                "データベースのパスワード"
            ],
            correctAnswerIndex: 1,
            explanation: "インデックスは、データベースの検索パフォーマンスを向上させるためのデータ構造です。"
        ),

        QuizQuestion(
            question: "「リレーショナルデータベース」の主な特徴は何ですか？",
            choices: [
                "データがテーブル形式で格納される",
                "データが非構造化で格納される",
                "データがツリー構造で格納される",
                "データが単一の大きなテーブルで格納される"
            ],
            correctAnswerIndex: 0,
            explanation: "リレーショナルデータベースの主な特徴は、データがテーブル形式で格納され、テーブル間で関連性を持つことです。"
        ),
        QuizQuestion(
            question: "「外部キー」とは何ですか？",
            choices: [
                "他のテーブルとの関連を定義するキー",
                "テーブルの主キー",
                "データベースのアクセスキー",
                "データベースの暗号化キー"
            ],
            correctAnswerIndex: 0,
            explanation: "外部キーは、他のテーブルとの関連を定義するキーで、テーブル間のリレーションシップを確立します。"
        ),

        QuizQuestion(
            question: "「ビュー」とは何ですか？",
            choices: [
                "データベースの可視化ツール",
                "一つ以上のテーブルから得られる仮想的なテーブル",
                "データベースのインデックス",
                "データベースのバックアップ"
            ],
            correctAnswerIndex: 1,
            explanation: "ビューは、一つ以上のテーブルから得られる仮想的なテーブルで、特定のデータのサブセットを提供します。"
        ),

        QuizQuestion(
            question: "「ストアドプロシージャ」とは何ですか？",
            choices: [
                "データベースのサイズを減らすプロセス",
                "データベースに保存され、再利用可能なSQLコードのブロック",
                "データベースのデータを暗号化するプロセス",
                "データベースのデータをバックアップするプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "ストアドプロシージャは、データベースに保存され、再利用可能なSQLコードのブロックで、一連の操作を実行します。"
        ),

        QuizQuestion(
            question: "「トランザクション」とは何ですか？",
            choices: [
                "データベースの一連の操作",
                "データベースのバックアップ",
                "データベースのリストア",
                "データベースのサイズ"
            ],
            correctAnswerIndex: 0,
            explanation: "トランザクションは、データベースの一連の操作で、すべての操作が成功するか、いずれも実行されないかのどちらかです。"
        ),

//        QuizQuestion(
//            question: "「データベーストリガー」の主な用途は何ですか？",
//            choices: [
//                "データベースのサイズを測定する",
//                "特定のイベントが発生したときに自動的に実行されるアクションを定義する",
//                "データベースのパフォーマンスを向上させる",
//                "データベースのデータを暗号化する"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "データベーストリガーは、特定のイベント（例えば、行の挿入、更新、または削除）が発生したときに自動的に実行されるアクションを定義します。"
//        ),
        QuizQuestion(
            question: "「正規化」とは何ですか？",
            choices: [
                "データベースのパフォーマンスを向上させるプロセス",
                "データベース内のデータの重複を排除し、データの整合性を保つプロセス",
                "データベースのサイズを減らすプロセス",
                "データベースのセキュリティを強化するプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "正規化は、データベース内のデータの重複を排除し、データの整合性を保つプロセスです。"
        ),

        QuizQuestion(
            question: "「インデックス」とは何ですか？",
            choices: [
                "データベースのサイズを測定するツール",
                "データベースのデータ検索を高速化するためのデータ構造",
                "データベースのデータを暗号化するツール",
                "データベースのバックアップを作成するツール"
            ],
            correctAnswerIndex: 1,
            explanation: "インデックスは、データベースのデータ検索を高速化するためのデータ構造です。"
        ),

        QuizQuestion(
            question: "「リレーショナルデータベース」の主な特徴は何ですか？",
            choices: [
                "データがテーブル形式で保存される",
                "データが非構造化で保存される",
                "データがキーと値のペアで保存される",
                "データが階層形式で保存される"
            ],
            correctAnswerIndex: 0,
            explanation: "リレーショナルデータベースの主な特徴は、データがテーブル形式で保存され、テーブル間でリレーションシップを持つことです。"
        ),

        QuizQuestion(
            question: "「プライマリキー」の主な目的は何ですか？",
            choices: [
                "データベースのデータを暗号化する",
                "テーブルの各行を一意に識別する",
                "データベースのパフォーマンスを向上させる",
                "データベースのサイズを減らす"
            ],
            correctAnswerIndex: 1,
            explanation: "プライマリキーの主な目的は、テーブルの各行を一意に識別することです。"
        ),
        QuizQuestion(
            question: "「外部キー」の主な用途は何ですか？",
            choices: [
                "テーブル間のリレーションシップを定義する",
                "データベースのサイズを減らす",
                "データベースのパフォーマンスを向上させる",
                "データベースのデータを暗号化する"
            ],
            correctAnswerIndex: 0,
            explanation: "外部キーは、テーブル間のリレーションシップを定義し、一つのテーブルのフィールドが別のテーブルのプライマリキーを参照することです。"
        ),

        QuizQuestion(
            question: "「データウェアハウス」は何を指しますか？",
            choices: [
                "大量のデータを保存、管理、分析するためのシステム",
                "小規模なデータベースを管理するシステム",
                "データベースのバックアップを保存するシステム",
                "データベースのセキュリティを管理するシステム"
            ],
            correctAnswerIndex: 0,
            explanation: "データウェアハウスは、大量のデータを保存、管理、分析するためのシステムで、ビジネスインテリジェンス活動をサポートします。"
        ),

        QuizQuestion(
            question: "「トランザクション」の主な特徴は何ですか？",
            choices: [
                "分割不可、一貫性、分離性、持続性",
                "分割可能、一貫性、非分離性、非持続性",
                "分割不可、非一貫性、分離性、持続性",
                "分割不可、一貫性、非分離性、持続性"
            ],
            correctAnswerIndex: 0,
            explanation: "トランザクションは、分割不可（Atomicity）、一貫性（Consistency）、分離性（Isolation）、持続性（Durability）の特徴（ACID特性）を持ちます。"
        ),

        QuizQuestion(
            question: "「NoSQLデータベース」の主な特徴は何ですか？",
            choices: [
                "スキーマレスでスケーラビリティが高い",
                "固定スキーマを持ち、スケーラビリティが低い",
                "固定スキーマを持ち、スケーラビリティが高い",
                "スキーマレスでスケーラビリティが低い"
            ],
            correctAnswerIndex: 0,
            explanation: "NoSQLデータベースは、スキーマレスでスケーラビリティが高く、非リレーショナルデータベースの一種です。"
        ),

        QuizQuestion(
            question: "「ビュー」に関する正しい説明は何ですか？",
            choices: [
                "データベースの物理的なデータ構造",
                "一つ以上のテーブルから派生した仮想テーブル",
                "データベースのデータをバックアップするプロセス",
                "データベースのデータを暗号化するプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "ビューは、一つ以上のテーブルから派生した仮想テーブルで、特定のデータを表示するためのクエリを保存します。"
        ),
        QuizQuestion(
            question: "「正規化」の主な目的は何ですか？",
            choices: [
                "データベース内のデータの重複を減らす",
                "データベースのサイズを増やす",
                "データベースのパフォーマンスを低下させる",
                "データベースのセキュリティを弱める"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化は、データベース内のデータの重複を減らし、データの整合性を保つためのプロセスです。"
        ),

        QuizQuestion(
            question: "SQLの「JOIN」操作は何を行いますか？",
            choices: [
                "テーブルを結合して、関連する列に基づいてデータを抽出する",
                "テーブルからデータを削除する",
                "テーブルに新しいデータを挿入する",
                "テーブルのデータを更新する"
            ],
            correctAnswerIndex: 0,
            explanation: "SQLの「JOIN」操作は、異なるテーブルを結合し、関連する列に基づいてデータを抽出します。"
        ),

        QuizQuestion(
            question: "「インデックス」の主な利点は何ですか？",
            choices: [
                "データの検索速度を向上させる",
                "データベースのサイズを増やす",
                "データの挿入速度を向上させる",
                "データベースのセキュリティを強化する"
            ],
            correctAnswerIndex: 0,
            explanation: "インデックスの主な利点は、データの検索速度を向上させることです。"
        ),

        QuizQuestion(
            question: "「プライマリキー」の特徴は何ですか？",
            choices: [
                "テーブル内の各レコードを一意に識別する",
                "テーブル内のデータを暗号化する",
                "テーブル内のデータをバックアップする",
                "テーブル内のデータを削除する"
            ],
            correctAnswerIndex: 0,
            explanation: "プライマリキーは、テーブル内の各レコードを一意に識別するためのキーです。"
        ),

        QuizQuestion(
            question: "「ストアドプロシージャ」は何ですか？",
            choices: [
                "データベース内に保存され、再利用可能なSQLコードブロック",
                "データベースのサイズを減らすテクニック",
                "データベースのデータを暗号化するプロセス",
                "データベースのデータをバックアップするプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "ストアドプロシージャは、データベース内に保存され、再利用可能なSQLコードブロックで、一連の操作を実行します。"
        ),
        QuizQuestion(
            question: "「エンティティ関連モデリング」の主な目的は何ですか？",
            choices: [
                "データベースの構造を視覚的に表現する",
                "データベースのサイズを減らす",
                "データベースのパフォーマンスを向上させる",
                "データベースを暗号化する"
            ],
            correctAnswerIndex: 0,
            explanation: "エンティティ関連モデリングは、データベースの構造を視覚的に表現し、エンティティ間の関連を明示的にする手法です。"
        ),

        QuizQuestion(
            question: "「データベーストリガー」は何ですか？",
            choices: [
                "データベースのサイズを測定するツール",
                "特定のイベントに応じて自動的に実行されるプロシージャ",
                "データベースのデータを削除するプロセス",
                "データベースのデータを暗号化するプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "データベーストリガーは、特定のイベント（例えば、行の挿入、更新、または削除）が発生したときに自動的に実行されるプロシージャまたは関数です。"
        ),

        QuizQuestion(
            question: "「ビュー」の主な用途は何ですか？",
            choices: [
                "データベースのデータを視覚的に表示する",
                "データベースのデータをバックアップする",
                "データベースのデータを暗号化する",
                "データベースのデータを削除する"
            ],
            correctAnswerIndex: 0,
            explanation: "ビューは、一つ以上のテーブルから得られる結果セットを表し、ユーザーがデータを視覚的に表示する手段を提供します。"
        ),

        QuizQuestion(
            question: "「OLAP」は何の略語ですか？",
            choices: [
                "Online Analytical Processing",
                "Offline Analytical Processing",
                "Online Application Programming",
                "Offline Application Programming"
            ],
            correctAnswerIndex: 0,
            explanation: "OLAPは「Online Analytical Processing」の略で、複雑なクエリを迅速に実行するためのデータベース処理のアプローチを指します。"
        ),

        QuizQuestion(
            question: "「シャーディング」の主な目的は何ですか？",
            choices: [
                "データベースのデータを暗号化する",
                "データベースのデータを複数のデータベースに分割する",
                "データベースのデータをバックアップする",
                "データベースのデータを削除する"
            ],
            correctAnswerIndex: 1,
            explanation: "シャーディングは、データベースのデータを複数のデータベースまたはインスタンスに分割し、パフォーマンスと管理の向上を図るテクニックです。"
        ),
        QuizQuestion(
            question: "「正規化」の主な目的は何ですか？",
            choices: [
                "データの重複を減らし、データの整合性を保つ",
                "データベースのサイズを増やす",
                "データベースのパフォーマンスを低下させる",
                "データベースのセキュリティを低下させる"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化は、データの重複を減らし、データの整合性を保つためのプロセスです。"
        ),

        QuizQuestion(
            question: "SQLの「JOIN」操作は何をしますか？",
            choices: [
                "テーブルを結合して新しいテーブルを作成する",
                "テーブルからデータを削除する",
                "テーブルのデータを更新する",
                "テーブルのデータを暗号化する"
            ],
            correctAnswerIndex: 0,
            explanation: "SQLの「JOIN」操作は、二つ以上のテーブルを特定の条件に基づいて結合し、新しいテーブルを作成します。"
        ),

        QuizQuestion(
            question: "「インデックス」の主な用途は何ですか？",
            choices: [
                "データベースのデータを暗号化する",
                "データベースのデータをバックアップする",
                "データベースのクエリパフォーマンスを向上させる",
                "データベースのサイズを減らす"
            ],
            correctAnswerIndex: 2,
            explanation: "インデックスは、データベースのクエリパフォーマンスを向上させるためのデータ構造です。"
        ),

        QuizQuestion(
            question: "「プライマリキー」の特徴は何ですか？",
            choices: [
                "テーブル内で一意でなければならない",
                "テーブル内で重複を許す",
                "テーブル内でNULLを許す",
                "テーブル内で変更可能である"
            ],
            correctAnswerIndex: 0,
            explanation: "プライマリキーは、テーブル内で一意でなければならず、各レコードを一意に識別します。"
        ),

        QuizQuestion(
            question: "「ストアドプロシージャ」は何ですか？",
            choices: [
                "データベースに保存されたプログラム",
                "データベースのサイズを測定するツール",
                "データベースのデータを暗号化するプロセス",
                "データベースのデータを削除するプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "ストアドプロシージャは、データベースに保存され、必要に応じて実行できるプログラムまたはルーチンです。"
        ),
        QuizQuestion(
            question: "「外部キー」の主な目的は何ですか？",
            choices: [
                "テーブル間の関連を定義する",
                "データを暗号化する",
                "データベースのパフォーマンスを向上させる",
                "データベースのサイズを減らす"
            ],
            correctAnswerIndex: 0,
            explanation: "外部キーは、テーブル間の関連を定義し、参照整合性を保つために使用されます。"
        ),

        QuizQuestion(
            question: "「ビュー」の主な用途は何ですか？",
            choices: [
                "データベースのデータをバックアップする",
                "一つ以上のテーブルから得られる結果セットを表す",
                "データベースのデータを削除する",
                "データベースのデータを暗号化する"
            ],
            correctAnswerIndex: 1,
            explanation: "ビューは、一つ以上のテーブルから得られる結果セットを表し、単一のテーブルのように使用できます。"
        ),

        QuizQuestion(
            question: "「トランザクション」がコミットされると、何が起こりますか？",
            choices: [
                "トランザクションの変更がロールバックされます",
                "トランザクションの変更がデータベースに永続的に保存されます",
                "トランザクションが開始されます",
                "トランザクションが一時停止します"
            ],
            correctAnswerIndex: 1,
            explanation: "トランザクションがコミットされると、そのトランザクションによる変更がデータベースに永続的に保存されます。"
        ),

        QuizQuestion(
            question: "「データウェアハウス」の主な特徴は何ですか？",
            choices: [
                "リアルタイムのデータ処理",
                "大量の歴史データを保存し、分析をサポートする",
                "トランザクションデータのみを保存する",
                "小規模なデータセットの分析"
            ],
            correctAnswerIndex: 1,
            explanation: "データウェアハウスは、大量の歴史データを保存し、ビジネスインテリジェンスと分析をサポートするシステムです。"
        ),

        QuizQuestion(
            question: "「NoSQLデータベース」は何を特徴としますか？",
            choices: [
                "厳格なスキーマと関係モデル",
                "スキーマレスまたは動的スキーマ",
                "小規模なデータセット",
                "低いスケーラビリティ"
            ],
            correctAnswerIndex: 1,
            explanation: "NoSQLデータベースは、スキーマレスまたは動的スキーマを特徴とし、大規模なデータセットと高いスケーラビリティをサポートします。"
        ),
        QuizQuestion(
            question: "「正規化」の主な目的は何ですか？",
            choices: [
                "データベース内のデータ冗長性を減らす",
                "データベースのサイズを増やす",
                "データベースのパフォーマンスを低下させる",
                "データベースのセキュリティを弱める"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化の主な目的は、データベース内のデータ冗長性を減らし、データの整合性を保つことです。"
        ),

        QuizQuestion(
            question: "SQLの「INNER JOIN」の操作は何をしますか？",
            choices: [
                "2つのテーブルのすべての行を結合します",
                "2つのテーブルの共通の行のみを結合します",
                "2つのテーブルの異なる行を結合します",
                "テーブルの行を削除します"
            ],
            correctAnswerIndex: 1,
            explanation: "INNER JOINは、2つのテーブルの共通の行（一致する行）のみを結合します。"
        ),

        QuizQuestion(
            question: "「インデックス」の主な利点は何ですか？",
            choices: [
                "データの検索速度を向上させる",
                "データの挿入速度を向上させる",
                "データベースのサイズを増やす",
                "データベースのセキュリティを強化する"
            ],
            correctAnswerIndex: 0,
            explanation: "インデックスの主な利点は、データの検索速度を向上させることです。"
        ),

        QuizQuestion(
            question: "SQLの「ALTER TABLE」ステートメントは何をしますか？",
            choices: [
                "テーブルの構造を変更する",
                "テーブルのデータを削除する",
                "テーブルのデータを検索する",
                "テーブルのデータをソートする"
            ],
            correctAnswerIndex: 0,
            explanation: "ALTER TABLEステートメントは、テーブルの構造を変更するために使用されます（例：列の追加、削除、データタイプの変更など）。"
        ),

        QuizQuestion(
            question: "「プライマリキー」の特徴は何ですか？",
            choices: [
                "NULL値を持つことができる",
                "テーブル内で一意でなければならない",
                "テーブル内で重複を持つことができる",
                "複数のプライマリキーをテーブルに持つことができる"
            ],
            correctAnswerIndex: 1,
            explanation: "プライマリキーは、テーブル内で一意でなければならず、NULL値を持つことはできません。"
        ),
        QuizQuestion(
            question: "「外部キー」の主な目的は何ですか？",
            choices: [
                "テーブル間の関連を定義する",
                "データベースのサイズを増やす",
                "テーブルのデータを暗号化する",
                "テーブルのデータを圧縮する"
            ],
            correctAnswerIndex: 0,
            explanation: "外部キーは、テーブル間の関連を定義し、参照整合性を保つために使用されます。"
        ),

        QuizQuestion(
            question: "「ビュー」(View)とは何ですか？",
            choices: [
                "データベースの物理的なコピー",
                "一つ以上のテーブルから得られる仮想的なテーブル",
                "データベースのバックアップ",
                "データベースのセキュリティポリシー"
            ],
            correctAnswerIndex: 1,
            explanation: "ビューは、一つ以上のテーブルから得られる仮想的なテーブルで、SQLクエリに基づいています。"
        ),

        QuizQuestion(
            question: "「ストアドプロシージャ」の主な利点は何ですか？",
            choices: [
                "データベースサーバー上でロジックを実行できる",
                "データベースのサイズを減らす",
                "データベースのセキュリティを弱める",
                "データベースのパフォーマンスを低下させる"
            ],
            correctAnswerIndex: 0,
            explanation: "ストアドプロシージャの主な利点は、データベースサーバー上でロジックを実行でき、ネットワークトラフィックを減らし、パフォーマンスを向上させることです。"
        ),

        QuizQuestion(
            question: "「トランザクション」の特徴は何ですか？",
            choices: [
                "一連の操作が全てまたは全く実行されない",
                "一連の操作が部分的に実行される",
                "データベースのサイズを増やす",
                "データベースのパフォーマンスを低下させる"
            ],
            correctAnswerIndex: 0,
            explanation: "トランザクションは、一連の操作が全て実行されるか、全く実行されない（ACID特性を持つ）ことを保証します。"
        ),

        QuizQuestion(
            question: "「シャーディング」(Sharding)とは何ですか？",
            choices: [
                "データベースを複数の部分に分割するプロセス",
                "データベースをバックアップするプロセス",
                "データベースを暗号化するプロセス",
                "データベースを圧縮するプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "シャーディングは、データベースを複数の部分（シャード）に分割するプロセスで、各シャードは独立して動作し、パフォーマンスを向上させます。"
        ),


    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared


    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizDatabaseList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .database, authManager: authManager,audioManager: audioManager,isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizDatabaseList_Previews: PreviewProvider {
    static var previews: some View {
        QuizDatabaseList(isPresenting: .constant(false))
    }
}
