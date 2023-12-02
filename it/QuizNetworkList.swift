//
//  QuizNetworkList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI

struct QuizNetworkList: View {
    @Binding var isPresenting: Bool
    let QuizNetworkList: [QuizQuestion] = [
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
            correctAnswerIndex: 2,
            explanation: "UNIQUEはデータベースの制約の一つで、特定の列または列の組合せにおいて、各行がユニークな値、つまり重複しない値を持つことを保証します。"
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
        ),
        
        QuizQuestion(
            question: "ネットワークでのフレームの衝突を検出する技術は何ですか？",
            choices: [
                "CSMA/CD",
                "CSMA/CA",
                "OSPF",
                "RIP"
            ],
            correctAnswerIndex: 0,
            explanation: "CSMA/CD (Carrier Sense Multiple Access with Collision Detection) は、イーサネットネットワークでのフレームの衝突を検出する技術です。"
        ),

        QuizQuestion(
            question: "ネットワークデバイスの中で、データリンク層で動作するものは何ですか？",
            choices: [
                "ルータ",
                "スイッチ",
                "ハブ",
                "モデム"
            ],
            correctAnswerIndex: 1,
            explanation: "スイッチはデータリンク層で動作し、MACアドレスを使用してフレームの転送を行います。"
        ),

        QuizQuestion(
            question: "ネットワークの帯域幅を最適化する技術は何ですか？",
            choices: [
                "QoS",
                "VLAN",
                "NAT",
                "RIP"
            ],
            correctAnswerIndex: 0,
            explanation: "QoS (Quality of Service) は、ネットワークの帯域幅を最適化し、特定の通信に優先的に帯域幅を割り当てる技術です。"
        ),

        QuizQuestion(
            question: "ネットワークでの暗号化と認証を提供するプロトコルは何ですか？",
            choices: [
                "HTTP",
                "FTP",
                "SSH",
                "DNS"
            ],
            correctAnswerIndex: 2,
            explanation: "SSH (Secure Shell) は、ネットワーク上での暗号化と認証を提供するプロトコルです。"
        ),

        QuizQuestion(
            question: "ネットワークのトラフィックを監視するためのプロトコルは何ですか？",
            choices: [
                "SNMP",
                "SMTP",
                "SIP",
                "RTP"
            ],
            correctAnswerIndex: 0,
            explanation: "SNMP (Simple Network Management Protocol) は、ネットワークデバイスの監視と管理のためのプロトコルです。"
        ),

        QuizQuestion(
            question: "ネットワークの中で、最も広範囲のエリアをカバーするものは何ですか？",
            choices: [
                "LAN",
                "WAN",
                "MAN",
                "PAN"
            ],
            correctAnswerIndex: 1,
            explanation: "WAN (Wide Area Network) は、広範囲のエリアをカバーするネットワークです。"
        ),

        QuizQuestion(
            question: "ネットワークでのデータの転送速度を測定する単位は何ですか？",
            choices: [
                "バイト",
                "ビット",
                "メガバイト",
                "ギガバイト"
            ],
            correctAnswerIndex: 1,
            explanation: "ネットワークでのデータ転送速度は通常、ビット/秒 (bps) という単位で測定されます。"
        ),

        QuizQuestion(
            question: "ネットワークでのデータの転送方法の中で、一度に一つのビットを転送するものは何ですか？",
            choices: [
                "シリアル転送",
                "パラレル転送",
                "同期転送",
                "非同期転送"
            ],
            correctAnswerIndex: 0,
            explanation: "シリアル転送は、一度に一つのビットを連続して転送する方法です。"
        ),

        QuizQuestion(
            question: "ネットワークの中で、データをセグメントに分割する役割を持つ層は何ですか？",
            choices: [
                "トランスポート層",
                "ネットワーク層",
                "データリンク層",
                "アプリケーション層"
            ],
            correctAnswerIndex: 0,
            explanation: "トランスポート層は、データをセグメントに分割し、エンドツーエンドの通信を確立する役割を持っています。"
        ),

        QuizQuestion(
            question: "ネットワークの中で、エンドツーエンドの通信を確立する役割を持つ層は何ですか？",
            choices: [
                "トランスポート層",
                "ネットワーク層",
                "データリンク層",
                "アプリケーション層"
            ],
            correctAnswerIndex: 0,
            explanation: "トランスポート層は、エンドツーエンドの通信を確立し、データのセグメント化や再組み立てを行う役割を持っています。"
        )

    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared


    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizNetworkList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .network, authManager: authManager,audioManager: audioManager,isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizNetworkList_Previews: PreviewProvider {
    static var previews: some View {
        QuizNetworkList(isPresenting: .constant(false))
    }
}
