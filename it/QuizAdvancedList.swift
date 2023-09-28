//
//  QuizAdvancedList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI

struct QuizAdvancedList: View {
    let QuizAdvancedList: [QuizQuestion] = [
        QuizQuestion(
            question: "プロジェクト管理において、プロジェクトの進捗を可視化するためのツールは何か？",
            choices: [
                "Gantt Chart",
                "PERT Chart",
                "Flow Chart",
                "Pie Chart"
            ],
            correctAnswerIndex: 0,
            explanation: "Gantt Chart（ガントチャート）は、プロジェクトの進捗を可視化するためのツールです。"
        ),

        QuizQuestion(
            question: "ソフトウェアテストの中で、プログラムの内部構造を考慮してテストを行う手法は何か？",
            choices: [
                "ブラックボックステスト",
                "ホワイトボックステスト",
                "グレーボックステスト",
                "ユーザーアクセプタンステスト"
            ],
            correctAnswerIndex: 1,
            explanation: "ホワイトボックステストは、プログラムの内部構造を考慮してテストを行う手法です。"
        ),

        QuizQuestion(
            question: "データベースの正規化で、部分関数従属性を排除するのは何正規形か？",
            choices: [
                "第一正規形",
                "第二正規形",
                "第三正規形",
                "BCNF"
            ],
            correctAnswerIndex: 1,
            explanation: "第二正規形は、部分関数従属性を排除する正規形です。"
        ),

        QuizQuestion(
            question: "プロジェクトのリスクを評価する際に、リスクの発生確率と影響度を掛け合わせた値を何というか？",
            choices: [
                "リスク係数",
                "リスク指数",
                "リスクマトリックス",
                "リスクスコア"
            ],
            correctAnswerIndex: 3,
            explanation: "リスクスコアは、リスクの発生確率と影響度を掛け合わせた値です。"
        ),

        QuizQuestion(
            question: "プロジェクトのスコープ、時間、コストを「三角形」に例える表現は何か？",
            choices: [
                "プロジェクトピラミッド",
                "プロジェクトダイヤモンド",
                "プロジェクト三角形",
                "プロジェクトマトリックス"
            ],
            correctAnswerIndex: 2,
            explanation: "プロジェクト三角形は、プロジェクトのスコープ、時間、コストを「三角形」に例える表現です。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発において、継続的にビルドとテストを行うプラクティスは何か？",
            choices: [
                "継続的インテグレーション",
                "継続的デリバリー",
                "継続的デプロイメント",
                "継続的監視"
            ],
            correctAnswerIndex: 0,
            explanation: "継続的インテグレーションは、ソフトウェア開発において継続的にビルドとテストを行うプラクティスです。"
        ),

        QuizQuestion(
            question: "データベースにおいて、複数のテーブルから必要なデータを取り出すSQL文は何か？",
            choices: [
                "INSERT",
                "UPDATE",
                "SELECT",
                "DELETE"
            ],
            correctAnswerIndex: 2,
            explanation: "SELECT文は、データベースから必要なデータを取り出すSQL文です。"
        ),

        QuizQuestion(
            question: "プロジェクト管理で、プロジェクトの成果物がステークホルダーの要求を満たしているかを確認するプロセスは何か？",
            choices: [
                "品質保証",
                "品質管理",
                "品質監査",
                "品質検証"
            ],
            correctAnswerIndex: 3,
            explanation: "品質検証は、プロジェクトの成果物がステークホルダーの要求を満たしているかを確認するプロセスです。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発において、一つの機能を最初から最後まで短期間で開発する手法は何か？",
            choices: [
                "スクラム",
                "エクストリームプログラミング",
                "カンバン",
                "ウォーターフォール"
            ],
            correctAnswerIndex: 1,
            explanation: "エクストリームプログラミング（XP）は、一つの機能を最初から最後まで短期間で開発する手法です。"
        ),

        QuizQuestion(
            question: "データベースで、一つのテーブル内の特定の列に重複したデータを許さない制約は何か？",
            choices: [
                "PRIMARY KEY",
                "FOREIGN KEY",
                "UNIQUE",
                "NOT NULL"
            ],
            correctAnswerIndex: 0,
            explanation: "PRIMARY KEY制約は、一つのテーブル内の特定の列に重複したデータを許さない制約です。"
        ),

        QuizQuestion(
            question: "プロジェクト管理で、プロジェクトの成果物をステークホルダーに引き渡すプロセスは何か？",
            choices: [
                "クロージング",
                "イニシエーション",
                "プランニング",
                "実行"
            ],
            correctAnswerIndex: 0,
            explanation: "クロージングは、プロジェクトの成果物をステークホルダーに引き渡すプロセスです。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発で、プロジェクトの進捗状況を毎日共有する短いミーティングは何か？",
            choices: [
                "スプリントレビュー",
                "デイリースクラム",
                "スプリントプランニング",
                "レトロスペクティブ"
            ],
            correctAnswerIndex: 1,
            explanation: "デイリースクラムは、プロジェクトの進捗状況を毎日共有する短いミーティングです。"
        ),

        QuizQuestion(
            question: "データベースで、テーブル間の関係性を定義する制約は何か？",
            choices: [
                "PRIMARY KEY",
                "FOREIGN KEY",
                "UNIQUE",
                "NOT NULL"
            ],
            correctAnswerIndex: 1,
            explanation: "FOREIGN KEY制約は、テーブル間の関係性を定義する制約です。"
        ),

        QuizQuestion(
            question: "プロジェクト管理で、プロジェクトの目的やスコープを明確にする文書は何か？",
            choices: [
                "プロジェクト計画書",
                "プロジェクト憲章",
                "プロジェクトスコープ",
                "プロジェクトスケジュール"
            ],
            correctAnswerIndex: 1,
            explanation: "プロジェクト憲章は、プロジェクトの目的やスコープを明確にする文書です。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発で、コードの変更を継続的に本番環境に適用するプラクティスは何か？",
            choices: [
                "継続的インテグレーション",
                "継続的デリバリー",
                "継続的デプロイメント",
                "継続的監視"
            ],
            correctAnswerIndex: 2,
            explanation: "継続的デプロイメントは、コードの変更を継続的に本番環境に適用するプラクティスです。"
        ),

        QuizQuestion(
            question: "データベースで、データの一貫性を確保するための4つの特性（ACID）のうち、「分離性」を表す頭文字は何か？",
            choices: [
                "A",
                "C",
                "I",
                "D"
            ],
            correctAnswerIndex: 2,
            explanation: "「分離性」は、ACIDの特性の中で「I」（Isolation）で表されます。"
        ),

        QuizQuestion(
            question: "プロジェクト管理で、プロジェクトの各フェーズが何を必要とするかを示す文書は何か？",
            choices: [
                "WBS",
                "RACIマトリックス",
                "リソースカレンダー",
                "リソースプラン"
            ],
            correctAnswerIndex: 3,
            explanation: "リソースプランは、プロジェクトの各フェーズが何を必要とするかを示す文書です。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発で、プロジェクトの進捗状況や問題点を可視化するボードは何か？",
            choices: [
                "スプリントボード",
                "カンバンボード",
                "タスクボード",
                "プロジェクトボード"
            ],
            correctAnswerIndex: 1,
            explanation: "カンバンボードは、プロジェクトの進捗状況や問題点を可視化するボードです。"
        ),

        QuizQuestion(
            question: "データベースで、一貫性を保ちながらデータを複数のテーブルに分割する手法は何か？",
            choices: [
                "正規化",
                "非正規化",
                "パーティショニング",
                "シャーディング"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化は、一貫性を保ちながらデータを複数のテーブルに分割する手法です。"
        )

    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()

    init() {
        _shuffledQuizList = State(initialValue: QuizAdvancedList.shuffled())
    }

    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .advanced, authManager: authManager)
    }
}

struct QuizAdvancedList_Previews: PreviewProvider {
    static var previews: some View {
        QuizAdvancedList()
    }
}
