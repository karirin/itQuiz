//
//  TimeAdvancedList.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/04.
//

import SwiftUI

struct TimeAdvancedList: View {
    @Binding var isPresenting: Bool
    let TimeAdvancedList: [QuizQuestion] = [
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
        question: "オブジェクト指向プログラミングにおいて、継承の概念が主にどの目的で使用されますか？",
        choices: [
        "コードの重複を減らす",
        "パフォーマンスを向上させる",
        "データベースを管理する",
        "エラーを修正する"
        ],
        correctAnswerIndex: 0,
        explanation: "継承は、オブジェクト指向プログラミングにおいて、コードの重複を減らす主な目的で使用されます。"
        ),
        QuizQuestion(
        question: "どのプロトコルがリアルタイム通信をサポートしていますか？",
        choices: [
        "HTTP",
        "FTP",
        "SMTP",
        "RTP"
        ],
        correctAnswerIndex: 3,
        explanation: "RTP（Real-Time Transport Protocol),はリアルタイム通信をサポートするプロトコルです。"
        ),
        QuizQuestion(
        question: "どのソフトウェア開発手法が定期的なリリースと継続的なフィードバックに重点を置いていますか？",
        choices: [
        "ウォーターフォールモデル",
        "アジャイル開発",
        "スパイラルモデル",
        "Vモデル"
        ],
        correctAnswerIndex: 1,
        explanation: "アジャイル開発は、定期的なリリースと継続的なフィードバックに重点を置いています。"
        ),
        QuizQuestion(
        question: "どのツールがバージョン管理に使用されますか？",
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
        question: "どのデータベース言語がデータの操作とクエリに使用されますか？",
        choices: [
        "HTML",
        "CSS",
        "SQL",
        "XML"
        ],
        correctAnswerIndex: 2,
        explanation: "SQLは、データの操作とクエリに使用されるデータベース言語です。"
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
        question: "どのプロトコルがコンピュータのホスト名をIPアドレスに変換しますか？",
        choices: [
        "DHCP",
        "DNS",
        "FTP",
        "HTTP"
        ],
        correctAnswerIndex: 1,
        explanation: "DNS（Domain Name System),は、コンピュータのホスト名をIPアドレスに変換するプロトコルです。"
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
        explanation: "関数型プログラミングは、関数を第一級の市民として扱います。"
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
        question: "どの暗号アルゴリズムが公開鍵暗号方式に分類されますか？",
        choices: [
        "AES",
        "DES",
        "RSA",
        "3DES"
        ],
        correctAnswerIndex: 2,
        explanation: "RSAは、公開鍵暗号方式に分類される暗号アルゴリズムです。"
        ),

        QuizQuestion(
        question: "どのプロトコルがセッション層のプロトコルですか？",
        choices: [
        "IP",
        "TCP",
        "RPC",
        "ARP"
        ],
        correctAnswerIndex: 2,
        explanation: "RPC（Remote Procedure Call）は、セッション層のプロトコルです。"
        ),

        QuizQuestion(
        question: "どのアーキテクチャパターンが、プレゼンテーション層とビジネスロジック層とデータアクセス層に分割しますか？",
        choices: [
        "MVC",
        "MVP",
        "MVVM",
        "3層アーキテクチャ"
        ],
        correctAnswerIndex: 3,
        explanation: "3層アーキテクチャは、プレゼンテーション層、ビジネスロジック層、データアクセス層に分割します。"
        ),

        QuizQuestion(
        question: "どのソフトウェア開発手法が、継続的なフィードバックと頻繁なイテレーションを強調しますか？",
        choices: [
        "ウォーターフォールモデル",
        "アジャイル開発",
        "スパイラルモデル",
        "Vモデル"
        ],
        correctAnswerIndex: 1,
        explanation: "アジャイル開発は、継続的なフィードバックと頻繁なイテレーションを強調するソフトウェア開発手法です。"
        ),

        QuizQuestion(
        question: "IPv6アドレスは何ビットですか？",
        choices: [
        "32ビット",
        "64ビット",
        "128ビット",
        "256ビット"
        ],
        correctAnswerIndex: 2,
        explanation: "IPv6アドレスは128ビットです。"
        ),

        QuizQuestion(
        question: "どのデータベーストランザクションの特性を「一貫性」が表しますか？",
        choices: [
        "Atomicity",
        "Consistency",
        "Isolation",
        "Durability"
        ],
        correctAnswerIndex: 1,
        explanation: "一貫性は、データベーストランザクションの特性「Consistency」を表します。"
        ),

        QuizQuestion(
        question: "どのネットワークトポロジーで、各ノードがリング状に接続されていますか？",
        choices: [
        "スター",
        "メッシュ",
        "リング",
        "バス"
        ],
        correctAnswerIndex: 2,
        explanation: "リングトポロジーでは、各ノードがリング状に接続されています。"
        ),

        QuizQuestion(
        question: "どのソフトウェアライセンスがソースコードの変更と再配布を許可しますか？",
        choices: [
        "GPL",
        "MIT",
        "Apache",
        "すべての上記"
        ],
        correctAnswerIndex: 3,
        explanation: "GPL、MIT、およびApacheライセンスは、ソースコードの変更と再配布を許可します。"
        ),

        QuizQuestion(
        question: "どのプロトコルがホスト名をIPアドレスに変換しますか？",
        choices: [
        "DHCP",
        "DNS",
        "FTP",
        "HTTP"
        ],
        correctAnswerIndex: 1,
        explanation: "DNS（Domain Name System）は、ホスト名をIPアドレスに変換するプロトコルです。"
        ),

        QuizQuestion(
        question: "どのプログラミングパラダイムがオブジェクトとその相互作用に焦点を当てていますか？",
        choices: [
        "オブジェクト指向プログラミング",
        "手続き型プログラミング",
        "関数型プログラミング",
        "論理プログラミング"
        ],
        correctAnswerIndex: 0,
        explanation: "オブジェクト指向プログラミングは、オブジェクトとその相互作用に焦点を当てています。"
        ),
        QuizQuestion(
        question: "どの暗号化アルゴリズムが公開鍵暗号方式に分類されますか？",
        choices: [
        "AES",
        "DES",
        "RSA",
        "3DES"
        ],
        correctAnswerIndex: 2,
        explanation: "RSAは公開鍵暗号方式に分類される暗号化アルゴリズムです。"
        ),

        QuizQuestion(
        question: "どのプロトコルがネットワーク層で動作しますか？",
        choices: [
        "TCP",
        "UDP",
        "IP",
        "HTTP"
        ],
        correctAnswerIndex: 2,
        explanation: "IP（Internet Protocol）はネットワーク層で動作するプロトコルです。"
        ),

        QuizQuestion(
        question: "どのアルゴリズムがNP完全な問題ですか？",
        choices: [
        "バブルソート",
        "クイックソート",
        "トラベリングセールスマン問題",
        "バイナリサーチ"
        ],
        correctAnswerIndex: 2,
        explanation: "トラベリングセールスマン問題はNP完全な問題です。"
        ),

        QuizQuestion(
        question: "どのソフトウェア開発手法が反復的かつ増分的なアプローチを採用していますか？",
        choices: [
        "アジャイル",
        "ウォーターフォール",
        "Vモデル",
        "スパイラルモデル"
        ],
        correctAnswerIndex: 0,
        explanation: "アジャイルは反復的かつ増分的なアプローチを採用したソフトウェア開発手法です。"
        ),

        QuizQuestion(
        question: "どのネットワークトポロジーで、各ノードがリング状に接続されていますか？",
        choices: [
        "スター",
        "バス",
        "リング",
        "メッシュ"
        ],
        correctAnswerIndex: 2,
        explanation: "リングトポロジーでは、各ノードがリング状に接続されています。"
        ),

        QuizQuestion(
        question: "どのプロトコルが、ホスト間の接続の確立、維持、終了を管理しますか？",
        choices: [
        "IP",
        "TCP",
        "UDP",
        "ICMP"
        ],
        correctAnswerIndex: 1,
        explanation: "TCP（Transmission Control Protocol）は、ホスト間の接続の確立、維持、終了を管理するプロトコルです。"
        ),
        QuizQuestion(
        question: "どのプロトコルがリアルタイム通信をサポートしていますか？",
        choices: [
        "HTTP",
        "FTP",
        "SMTP",
        "RTP"
        ],
        correctAnswerIndex: 3,
        explanation: "RTP（Real-Time Transport Protocol）は、リアルタイム通信をサポートするプロトコルです。"
        ),

        QuizQuestion(
        question: "どのアルゴリズムが非決定的多項式時間で問題を解決しますか？",
        choices: [
        "P",
        "NP",
        "NP完全",
        "NP困難"
        ],
        correctAnswerIndex: 1,
        explanation: "NP（非決定的多項式時間）は、非決定的多項式時間で問題を解決するアルゴリズムのクラスです。"
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
        explanation: "Ruby on RailsはRubyで書かれたソフトウェア開発フレームワークです。"
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
        question: "どのデータベース言語がデータの操作とクエリに使用されますか？",
        choices: [
        "HTML",
        "CSS",
        "SQL",
        "XML"
        ],
        correctAnswerIndex: 2,
        explanation: "SQL（Structured Query Language）は、データの操作とクエリに使用されるデータベース言語です。"
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
        question: "どのプログラミング言語が主にWeb開発に使用されますか？",
        choices: [
        "Python",
        "JavaScript",
        "C++",
        "Java"
        ],
        correctAnswerIndex: 1,
        explanation: "JavaScriptは、主にWeb開発に使用されるプログラミング言語です。"
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
        explanation: "ポート番号80は、HTTP（HyperText Transfer Protocol）に割り当てられています。"
        ),
        QuizQuestion(
        question: "CAP定理において、分散システムが同時に実現できないものはどれですか？",
        choices: [
        "一貫性と可用性",
        "分割耐性と一貫性",
        "可用性と分割耐性",
        "一貫性、可用性、分割耐性"
        ],
        correctAnswerIndex: 3,
        explanation: "CAP定理によれば、分散システムは一貫性、可用性、分割耐性の3つを同時に実現することはできません。"
        ),

        QuizQuestion(
        question: "ランダムフォレストアルゴリズムはどのタイプの学習アルゴリズムですか？",
        choices: [
        "教師なし学習",
        "教師あり学習",
        "半教師あり学習",
        "強化学習"
        ],
        correctAnswerIndex: 1,
        explanation: "ランダムフォレストは教師あり学習の一種です。"
        ),

        QuizQuestion(
        question: "ハッシュ関数のどの特性が、小さな入力の変更が出力に大きな変更を引き起こすことを保証しますか？",
        choices: [
        "可逆性",
        "非可逆性",
        "耐衝突性",
        "アバランシュ効果"
        ],
        correctAnswerIndex: 3,
        explanation: "アバランシュ効果は、ハッシュ関数の入力の小さな変更が出力に大きな変更を引き起こすことを保証する特性です。"
        ),

        QuizQuestion(
        question: "量子コンピューティングでは、量子ビットは何と呼ばれますか？",
        choices: [
        "qbyte",
        "qbit",
        "quantbit",
        "qubit"
        ],
        correctAnswerIndex: 3,
        explanation: "量子コンピューティングでは、量子ビットはqubitと呼ばれます。"
        ),

        QuizQuestion(
        question: "どの暗号化アルゴリズムが公開鍵暗号化を使用しますか？",
        choices: [
        "AES",
        "DES",
        "RSA",
        "Blowfish"
        ],
        correctAnswerIndex: 2,
        explanation: "RSAは公開鍵暗号化を使用する暗号化アルゴリズムです。"
        ),

        QuizQuestion(
        question: "オブジェクト指向プログラミングにおいて、オブジェクト間のメッセージの送受信を何と呼びますか？",
        choices: [
        "継承",
        "ポリモーフィズム",
        "カプセル化",
        "メッセージパッシング"
        ],
        correctAnswerIndex: 3,
        explanation: "オブジェクト指向プログラミングでは、オブジェクト間のメッセージの送受信をメッセージパッシングと呼びます。"
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
        question: "どのソートアルゴリズムが最悪の場合の時間複雑度がO(n^2)ですか？",
        choices: [
        "マージソート",
        "ヒープソート",
        "クイックソート",
        "バブルソート"
        ],
        correctAnswerIndex: 3,
        explanation: "バブルソートの最悪の場合の時間複雑度はO(n^2)です。"
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
        explanation: "MySQLはオープンソースのデータベース管理システムです。"
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
        explanation: "HTTPS（HyperText Transfer Protocol Secure）は、Webサーバーとブラウザ間で安全な通信を提供するプロトコルです。"
        ),
        QuizQuestion(
        question: "ハイパーバイザーがホストする仮想マシンのタイプは何ですか？",
        choices: [
        "Type-1 ハイパーバイザー",
        "Type-2 ハイパーバイザー",
        "Type-3 ハイパーバイザー",
        "Type-4 ハイパーバイザー"
        ],
        correctAnswerIndex: 0,
        explanation: "Type-1 ハイパーバイザーは、物理ハードウェア上で直接実行され、仮想マシンをホストします。"
        ),

        QuizQuestion(
        question: "量子エンタングルメントが利用される量子コンピューティングのアルゴリズムは何ですか？",
        choices: [
        "グローバーのアルゴリズム",
        "ショーアのアルゴリズム",
        "ベルンスタイン・ヴァジラニアルゴリズム",
        "デュッチ–ジョサアルゴリズム"
        ],
        correctAnswerIndex: 1,
        explanation: "ショーアのアルゴリズムは、量子エンタングルメントと超位置を利用して、整数を素因数分解します。"
        ),

        QuizQuestion(
        question: "ホモモーフィック暗号化の主な利点は何ですか？",
        choices: [
        "高速な暗号化",
        "暗号文上での計算",
        "量子耐性",
        "低い計算コスト"
        ],
        correctAnswerIndex: 1,
        explanation: "ホモモーフィック暗号化の主な利点は、暗号文上で直接計算を行う能力です。"
        ),

        QuizQuestion(
        question: "どのネットワークトポロジーが各ノードがリング状に接続されている？",
        choices: [
        "スター",
        "バス",
        "リング",
        "メッシュ"
        ],
        correctAnswerIndex: 2,
        explanation: "リングトポロジーでは、各ノードがリング状に接続されています。"
        ),

        QuizQuestion(
        question: "ノンブロッキングI/Oはどのプログラミングパラダイムに関連していますか？",
        choices: [
        "オブジェクト指向プログラミング",
        "関数型プログラミング",
        "イベント駆動プログラミング",
        "手続き型プログラミング"
        ],
        correctAnswerIndex: 2,
        explanation: "ノンブロッキングI/Oは、イベント駆動プログラミングに関連しています。"
        ),

        QuizQuestion(
        question: "ZKP (Zero Knowledge Proof) は何を保証しますか？",
        choices: [
        "データの整合性",
        "データの可用性",
        "データの機密性",
        "証明者が特定の情報を知っていることの証明、情報自体を開示せずに"
        ],
        correctAnswerIndex: 3,
        explanation: "ZKPは、証明者が特定の情報を知っていることを証明するために使用されますが、情報自体は開示されません。"
        ),

        QuizQuestion(
        question: "量子コンピューターにおいて、量子ビットの状態を変更する操作は何と呼ばれますか？",
        choices: [
        "量子変調",
        "量子回転",
        "量子エンタングルメント",
        "量子テレポーテーション"
        ],
        correctAnswerIndex: 1,
        explanation: "量子コンピューターでは、量子ビットの状態を変更する操作は量子回転と呼ばれます。"
        ),

        QuizQuestion(
        question: "どのアルゴリズムがNP完全問題ですか？",
        choices: [
        "ダイクストラのアルゴリズム",
        "旅行商人問題",
        "バブルソート",
        "バイナリサーチ"
        ],
        correctAnswerIndex: 1,
        explanation: "旅行商人問題は、NP完全問題の一例です。"
        ),

        QuizQuestion(
        question: "どのデータベースモデルが「ノード」と「エッジ」の概念を使用しますか？",
        choices: [
        "リレーショナルデータベース",
        "ドキュメント指向データベース",
        "キー値ストア",
        "グラフデータベース"
        ],
        correctAnswerIndex: 3,
        explanation: "グラフデータベースは、「ノード」と「エッジ」の概念を使用します。"
        ),

        QuizQuestion(
        question: "どのプロトコルがブロックチェーンネットワークで使用されますか？",
        choices: [
        "HTTP",
        "FTP",
        "SMTP",
        "P2P"
        ],
        correctAnswerIndex: 3,
        explanation: "ブロックチェーンネットワークでは、P2P（Peer-to-Peer）プロトコルが使用されます。"
        ),
        
        QuizQuestion(
        question: "CAP定理において、分散システムが同時に確保できない2つの保証は何ですか？",
        choices: [
        "一貫性と可用性",
        "分割耐性と一貫性",
        "可用性と分割耐性",
        "一貫性と性能"
        ],
        correctAnswerIndex: 2,
        explanation: "CAP定理によれば、分散システムは一貫性、可用性、分割耐性の3つのうち、同時に2つしか確保できません。"
        ),

        QuizQuestion(
        question: "量子コンピューターが古典的なコンピューターより優れているタスクは何ですか？",
        choices: [
        "テキスト処理",
        "グラフィックスレンダリング",
        "整数の素因数分解",
        "データベースのクエリ"
        ],
        correctAnswerIndex: 2,
        explanation: "量子コンピューターは、整数の素因数分解のような特定の計算タスクで古典的なコンピューターより優れています。"
        ),

        QuizQuestion(
        question: "どの暗号学的ツールが、公開鍵暗号と秘密鍵暗号の両方を使用しますか？",
        choices: [
        "ハイブリッド暗号",
        "対称暗号",
        "非対称暗号",
        "ハッシュ関数"
        ],
        correctAnswerIndex: 0,
        explanation: "ハイブリッド暗号は、公開鍵暗号と秘密鍵暗号の両方を使用します。"
        ),

        QuizQuestion(
        question: "どのプロトコルが、Webサーバーとブラウザ間で安全な通信を提供しますか？",
        choices: [
        "HTTP",
        "HTTPS",
        "FTP",
        "SMTP"
        ],
        correctAnswerIndex: 1,
        explanation: "HTTPSプロトコルは、Webサーバーとブラウザ間で安全な通信を提供します。"
        ),

        QuizQuestion(
        question: "どのアルゴリズムが、大規模なデータセットで最も効率的ですか？",
        choices: [
        "バブルソート",
        "選択ソート",
        "クイックソート",
        "挿入ソート"
        ],
        correctAnswerIndex: 2,
        explanation: "クイックソートは、大規模なデータセットで一般的に最も効率的なソートアルゴリズムの一つです。"
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
        explanation: "MySQLは、オープンソースのデータベース管理システムです。"
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
        explanation: "Rは、主に統計計算とデータ分析に使用されるプログラミング言語です。"
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
        question: "どのプロトコルがコンピュータのホスト名をIPアドレスに変換しますか？",
        choices: [
        "HTTP",
        "DNS",
        "DHCP",
        "FTP"
        ],
        correctAnswerIndex: 1,
        explanation: "DNS（Domain Name System）は、コンピュータのホスト名をIPアドレスに変換するプロトコルです。"
        ),
        QuizQuestion(
        question: "どのプロトコルが、ネットワーク上のデバイス間で時刻情報を同期しますか？",
        choices: [
        "NTP",
        "SMTP",
        "FTP",
        "HTTP"
        ],
        correctAnswerIndex: 0,
        explanation: "NTP（Network Time Protocol）は、ネットワーク上のデバイス間で時刻情報を同期するプロトコルです。"
        ),

        QuizQuestion(
        question: "どのプロトコルが、ネットワークリソースへの安全なリモートアクセスを提供しますか？",
        choices: [
        "HTTP",
        "SSH",
        "FTP",
        "SMTP"
        ],
        correctAnswerIndex: 1,
        explanation: "SSH（Secure Shell）は、ネットワークリソースへの安全なリモートアクセスを提供するプロトコルです。"
        ),

        QuizQuestion(
        question: "どの暗号アルゴリズムが、公開鍵と秘密鍵のペアを使用しますか？",
        choices: [
        "AES",
        "RSA",
        "DES",
        "3DES"
        ],
        correctAnswerIndex: 1,
        explanation: "RSAは、公開鍵と秘密鍵のペアを使用する暗号アルゴリズムです。"
        ),

        QuizQuestion(
        question: "どのネットワークトポロジーで、各デバイスが中央のハブに接続されていますか？",
        choices: [
        "スター",
        "リング",
        "バス",
        "メッシュ"
        ],
        correctAnswerIndex: 0,
        explanation: "スタートポロジーでは、各デバイスが中央のハブに接続されています。"
        ),

        QuizQuestion(
        question: "どのプログラミングパラダイムが、状態や変更可能なデータを避けることを重視しますか？",
        choices: [
        "オブジェクト指向プログラミング",
        "手続き型プログラミング",
        "関数型プログラミング",
        "論理プログラミング"
        ],
        correctAnswerIndex: 2,
        explanation: "関数型プログラミングは、状態や変更可能なデータを避けることを重視するプログラミングパラダイムです。"
        ),

        QuizQuestion(
        question: "どのプロトコルが、ホスト名をIPアドレスに変換しますか？",
        choices: [
        "HTTP",
        "DNS",
        "DHCP",
        "FTP"
        ],
        correctAnswerIndex: 1,
        explanation: "DNS（Domain Name System）は、ホスト名をIPアドレスに変換するプロトコルです。"
        ),

        QuizQuestion(
        question: "どのアルゴリズムが、データの整合性を確認するために使用されますか？",
        choices: [
        "RSA",
        "SHA-256",
        "AES",
        "3DES"
        ],
        correctAnswerIndex: 1,
        explanation: "SHA-256は、データの整合性を確認するために使用されるハッシュ関数です。"
        ),

        QuizQuestion(
        question: "どのデータベースモデルが、親子関係のツリー構造を使用しますか？",
        choices: [
        "階層型データベース",
        "リレーショナルデータベース",
        "ネットワークデータベース",
        "オブジェクト指向データベース"
        ],
        correctAnswerIndex: 0,
        explanation: "階層型データベースモデルは、親子関係のツリー構造を使用します。"
        ),

        QuizQuestion(
        question: "どのプロトコルが、インターネット上でファイルを転送するために使用されますか？",
        choices: [
        "HTTP",
        "FTP",
        "TCP",
        "UDP"
        ],
        correctAnswerIndex: 1,
        explanation: "FTP（File Transfer Protocol）は、インターネット上でファイルを転送するために使用されるプロトコルです。"
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
        explanation: "アジャイル開発は、定期的な短いイテレーションを使用するソフトウェア開発手法です。"
        ),
        //追加　2024/3/4

                 QuizQuestion(
                 question: "Webアプリケーションのセキュリティを高めるために、ユーザーが入力したデータを検証し、実行する前に適切にエスケープするプラクティスは何と呼ばれるか？",
                 choices: [
                 "データサニタイゼーション",
                 "クロスサイトスクリプティング",
                 "セッションハイジャック",
                 "データマイニング"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "データサニタイゼーションは、Webアプリケーションのセキュリティを高めるために、ユーザーが入力したデータを検証し、実行する前に適切にエスケープするプラクティスです。"
                 ),
                 QuizQuestion(
                 question: "コンテナ化されたアプリケーションのデプロイメント、スケーリング、運用を自動化するオープンソースのシステムは何か？",
                 choices: [
                 "Docker",
                 "Kubernetes",
                 "Vagrant",
                 "Ansible"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "Kubernetesは、コンテナ化されたアプリケーションのデプロイメント、スケーリング、運用を自動化するオープンソースのシステムです。"
                 ),
                 QuizQuestion(
                 question: "デジタルコンテンツの著作権保護技術で、不正コピーを防止するために使用される制約は何と呼ばれるか？",
                 choices: [
                 "デジタルライツマネジメント(DRM)",
                 "パブリックドメイン",
                 "オープンソースライセンス",
                 "コピーレフト"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "デジタルライツマネジメント(DRM)は、デジタルコンテンツの著作権保護技術で、不正コピーを防止するために使用される制約です。"
                 ),
                 QuizQuestion(
                 question: "大規模データセンターにおけるサーバーのリソースを動的に割り当て、利用する技術は何と呼ばれるか？",
                 choices: [
                 "バーチャルリアリティ",
                 "クラウドコンピューティング",
                 "量子コンピューティング",
                 "分散コンピューティング"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "クラウドコンピューティングは、大規模データセンターにおけるサーバーのリソースを動的に割り当て、利用する技術です。"
                 ),
                 QuizQuestion(
                 question: "プログラミングにおいて、複数の入力に対して一つの出力を生成する関数型プログラミングの概念は何と呼ばれるか？",
                 choices: [
                 "カリー化",
                 "エンクロージャ",
                 "ポリモーフィズム",
                 "オーバーローディング"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "カリー化は、プログラミングにおいて、複数の入力に対して一つの出力を生成する関数型プログラミングの概念です。"
                 ),

                 QuizQuestion(
                 question: "ブロックチェーン技術において、取引の正当性を確認し、新たなブロックをチェーンに追加するプロセスを何と呼ぶか？",
                 choices: [
                 "マイニング",
                 "ハッシング",
                 "トークニング",
                 "エンコーディング"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "マイニングは、ブロックチェーン技術において、取引の正当性を確認し、新たなブロックをチェーンに追加するプロセスです。"
                 ),
                 QuizQuestion(
                 question: "オペレーティングシステム(OS)のコンテキストで、複数のプログラムが同時に実行されるように見せる技術は何か？",
                 choices: [
                 "マルチタスキング",
                 "マルチプロセッシング",
                 "バッチ処理",
                 "シングルタスキング"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "マルチタスキングは、オペレーティングシステムのコンテキストで、複数のプログラムが同時に実行されるように見せる技術です。"
                 ),
                 QuizQuestion(
                 question: "インターネットの基盤となるプロトコルで、IPアドレスを使用してデータパケットを送受信するものは何か？",
                 choices: [
                 "TCP",
                 "UDP",
                 "IP",
                 "FTP"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "IP（Internet Protocol）は、インターネットの基盤となるプロトコルで、IPアドレスを使用してデータパケットを送受信するものです。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェア開発において、コードの品質を維持し改善するために、同僚によるコードレビューを行うプラクティスは何と呼ばれるか？",
                 choices: [
                 "ペアプログラミング",
                 "コードシェアリング",
                 "コードレビュー",
                 "アジャイル開発"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "コードレビューは、ソフトウェア開発において、コードの品質を維持し改善するために、同僚によるコードレビューを行うプラクティスです。"
                 ),
                 QuizQuestion(
                 question: "データ分析において、大量のデータから有用な情報を抽出し、意思決定を支援するプロセスを何と呼ぶか？",
                 choices: [
                 "データマイニング",
                 "データエントリー",
                 "データベース管理",
                 "データエンコーディング"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "データマイニングは、データ分析において、大量のデータから有用な情報を抽出し、意思決定を支援するプロセスです。"
                 ),


                 QuizQuestion(
                 question: "プログラミング言語における「イミュータブルオブジェクト」とは、どのような特性を持つオブジェクトか？",
                 choices: [
                 "生成後、その状態を変更できる",
                 "生成後、その状態を変更できない",
                 "動的にプロパティを追加できる",
                 "実行時に型を変更できる"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "イミュータブルオブジェクトは、生成後、その状態を変更できない特性を持つオブジェクトです。"
                 ),
                 QuizQuestion(
                 question: "デジタル署名を検証するために必要なキーはどれか？",
                 choices: [
                 "公開鍵",
                 "秘密鍵",
                 "対称鍵",
                 "非対称鍵"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "デジタル署名を検証するためには、公開鍵が必要です。"
                 ),
                 QuizQuestion(
                 question: "DevOpsの実践において、ソフトウェアのリリースプロセスを自動化し、効率化するために使用される技術は何か？",
                 choices: [
                 "マイクロサービス",
                 "継続的インテグレーション/継続的デリバリー",
                 "サービスメッシュ",
                 "コンテナオーケストレーション"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "継続的インテグレーション/継続的デリバリー（CI/CD）は、DevOpsの実践において、ソフトウェアのリリースプロセスを自動化し、効率化するために使用される技術です。"
                 ),
                 QuizQuestion(
                 question: "コンピュータネットワークにおいて、データを送信する際に使用される、データの一時的な保管場所を何と呼ぶか？",
                 choices: [
                 "バッファ",
                 "キャッシュ",
                 "レジスタ",
                 "クエリ"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "バッファは、コンピュータネットワークにおいて、データを送信する際に使用される、データの一時的な保管場所を指します。"
                 ),
                 QuizQuestion(
                 question: "ウェブ開発におけるREST APIでよく使用されるHTTPメソッドで、リソースを更新するために用いられるものは何か？",
                 choices: [
                 "GET",
                 "POST",
                 "PUT",
                 "DELETE"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "PUTメソッドは、ウェブ開発におけるREST APIで、リソースを更新するために用いられるHTTPメソッドです。"
                 ),


                 QuizQuestion(
                 question: "Webアプリケーションにおいて、サーバーからクライアントへの効率的なリアルタイム通信を実現する技術は何か？",
                 choices: [
                 "AJAX",
                 "WebSocket",
                 "REST API",
                 "SOAP"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "WebSocketは、Webアプリケーションにおいて、サーバーからクライアントへの効率的なリアルタイム通信を実現する技術です。"
                 ),
                 QuizQuestion(
                 question: "コンピューターネットワークにおいて、ネットワーク内のデバイスが他のデバイスを識別するために使用する一意の番号は何か？",
                 choices: [
                 "IPアドレス",
                 "MACアドレス",
                 "ポート番号",
                 "SSID"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "MACアドレスは、コンピューターネットワークにおいて、ネットワーク内のデバイスが他のデバイスを識別するために使用する一意の番号です。"
                 ),
                 QuizQuestion(
                 question: "データサイエンスにおいて、機械学習モデルが未知のデータに対して正確に予測する能力を何と呼ぶか？",
                 choices: [
                 "過学習",
                 "一般化能力",
                 "バイアス",
                 "バリアンス"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "一般化能力は、データサイエンスにおいて、機械学習モデルが未知のデータに対して正確に予測する能力を指します。"
                 ),
                 QuizQuestion(
                 question: "クラウドサービスにおいて、短期間で大量のコンピューティングリソースを動的に割り当て、使用する概念を何と呼ぶか？",
                 choices: [
                 "マルチテナンシー",
                 "オートスケーリング",
                 "サービス指向アーキテクチャ",
                 "クラウドバースティング"
                 ],
                 correctAnswerIndex: 3,
                 explanation: "クラウドバースティングは、クラウドサービスにおいて、短期間で大量のコンピューティングリソースを動的に割り当て、使用する概念です。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェアエンジニアリングの原則において、コード変更時に他の部分への影響を最小限に抑える設計原則は何か？",
                 choices: [
                 "DRY（Don't Repeat Yourself）",
                 "KISS（Keep It Simple, Stupid）",
                 "YAGNI（You Aren't Gonna Need It）",
                 "Loose Coupling"
                 ],
                 correctAnswerIndex: 3,
                 explanation: "Loose Coupling（疎結合）は、ソフトウェアエンジニアリングの原則において、コード変更時に他の部分への影響を最小限に抑える設計原則です。"
                 ),


                 QuizQuestion(
                 question: "ソフトウェアテストにおいて、システム全体が仕様通りに動作することを確認するテストは何か？",
                 choices: [
                 "ユニットテスト",
                 "統合テスト",
                 "システムテスト",
                 "受け入れテスト"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "システムテストは、ソフトウェアテストの段階の一つで、システム全体が仕様通りに動作することを確認するテストです。"
                 ),
                 QuizQuestion(
                 question: "分散システム設計において、システムの部分が障害に対してどのように耐性を持つかを指す用語は何か？",
                 choices: [
                 "スケーラビリティ",
                 "フォールトトレランス",
                 "ロードバランシング",
                 "キャッシュコヒーレンス"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "フォールトトレランスは、分散システム設計において、システムの部分が障害に対してどのように耐性を持つかを指す用語です。"
                 ),
                 QuizQuestion(
                 question: "暗号化技術において、データを元に戻すことなく、一方向にのみ変換する関数のことを何と呼ぶか？",
                 choices: [
                 "対称暗号化",
                 "非対称暗号化",
                 "ハッシュ関数",
                 "ブロックチェーン"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "ハッシュ関数は、暗号化技術において、データを元に戻すことなく、一方向にのみ変換する関数のことを指します。"
                 ),
                 QuizQuestion(
                 question: "プログラミングにおいて、コードの実行を一時停止し、特定の条件が満たされるまで待機させる機能は何と呼ばれるか？",
                 choices: [
                 "ポーリング",
                 "スレッド",
                 "同期",
                 "セマフォ"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "ポーリングは、プログラミングにおいて、コードの実行を一時停止し、特定の条件が満たされるまで待機させる機能です。"
                 ),
                 QuizQuestion(
                 question: "情報セキュリティの三要素の一つで、情報が権限のない者によって見られたり改ざんされたりしないことを保証する要素は何か？",
                 choices: [
                 "機密性",
                 "完全性",
                 "可用性",
                 "認証性"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "機密性は、情報セキュリティの三要素の一つで、情報が権限のない者によって見られたり改ざんされたりしないことを保証する要素です。"
                 ),



                 QuizQuestion(
                 question: "データベース設計において、異なるテーブル間でデータの整合性を保つために用いられるキーは何か？",
                 choices: [
                 "プライマリーキー",
                 "フォーリンキー",
                 "ユニークキー",
                 "セカンダリーキー"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "フォーリンキーは、データベース設計において、異なるテーブル間でデータの整合性を保つために用いられるキーです。"
                 ),
                 QuizQuestion(
                 question: "クラウドコンピューティングにおけるサービスモデルで、アプリケーションの開発とデプロイメントをサポートするプラットフォームを提供するのは何か？",
                 choices: [
                 "IaaS",
                 "PaaS",
                 "SaaS",
                 "FaaS"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "PaaS（Platform as a Service）は、クラウドコンピューティングにおけるサービスモデルで、アプリケーションの開発とデプロイメントをサポートするプラットフォームを提供します。"
                 ),
                 QuizQuestion(
                 question: "インターネットセキュリティにおいて、ユーザーのアクティビティを追跡し、ユーザーに関するデータを収集するためによく使われる小さなデータファイルは何か？",
                 choices: [
                 "トークン",
                 "クッキー",
                 "セッション",
                 "キャッシュ"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "クッキーは、インターネットセキュリティにおいて、ユーザーのアクティビティを追跡し、ユーザーに関するデータを収集するためによく使われる小さなデータファイルです。"
                 ),
                 QuizQuestion(
                 question: "プログラミング言語において、あるオブジェクトが別のオブジェクトのインターフェースを実装することなく、そのオブジェクトとして機能する能力は何と呼ばれるか？",
                 choices: [
                 "継承",
                 "ポリモーフィズム",
                 "カプセル化",
                 "ダックタイピング"
                 ],
                 correctAnswerIndex: 3,
                 explanation: "ダックタイピングは、プログラミング言語において、あるオブジェクトが別のオブジェクトのインターフェースを実装することなく、そのオブジェクトとして機能する能力を指します。"
                 ),
                 QuizQuestion(
                 question: "ネットワークセキュリティにおいて、内部ネットワークと外部ネットワーク（例えばインターネット）の間で不正アクセスを防ぐデバイスは何か？",
                 choices: [
                 "ルーター",
                 "スイッチ",
                 "ファイアウォール",
                 "プロキシサーバー"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "ファイアウォールは、ネットワークセキュリティにおいて、内部ネットワークと外部ネットワークの間で不正アクセスを防ぐデバイスです。"
                 ),




                 QuizQuestion(
                 question: "ビッグデータ技術において、リアルタイムデータ処理を可能にする分散ストリーム処理フレームワークは何か？",
                 choices: [
                 "Hadoop",
                 "MongoDB",
                 "Apache Kafka",
                 "Apache Spark"
                 ],
                 correctAnswerIndex: 3,
                 explanation: "Apache Sparkは、ビッグデータ技術において、リアルタイムデータ処理を可能にする分散ストリーム処理フレームワークです。"
                 ),
                 QuizQuestion(
                 question: "Web開発において、クライアント側のスクリプト言語として最も一般的に使用される言語は何か？",
                 choices: [
                 "Java",
                 "Python",
                 "JavaScript",
                 "PHP"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "JavaScriptは、Web開発において、クライアント側のスクリプト言語として最も一般的に使用される言語です。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェアエンジニアリングにおいて、システムやソフトウェアの要件を収集し分析する初期段階を何と呼ぶか？",
                 choices: [
                 "要件定義",
                 "設計",
                 "実装",
                 "テスト"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "要件定義は、ソフトウェアエンジニアリングにおいて、システムやソフトウェアの要件を収集し分析する初期段階です。"
                 ),
                 QuizQuestion(
                 question: "プログラミングにおいて、複数のスレッドやプロセスが同時に同一のリソースを安全にアクセスすることを可能にする概念は何か？",
                 choices: [
                 "並行処理",
                 "マルチスレッド",
                 "同期",
                 "デッドロック"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "同期は、プログラミングにおいて、複数のスレッドやプロセスが同時に同一のリソースを安全にアクセスすることを可能にする概念です。"
                 ),
                 QuizQuestion(
                 question: "情報セキュリティにおいて、システムやネットワークに存在する潜在的な脅威を特定し、評価するプロセスは何と呼ばれるか？",
                 choices: [
                 "脆弱性評価",
                 "侵入テスト",
                 "リスク評価",
                 "セキュリティ監査"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "脆弱性評価は、情報セキュリティにおいて、システムやネットワークに存在する潜在的な脅威を特定し、評価するプロセスです。"
                 ),


                 QuizQuestion(
                 question: "マイクロサービスアーキテクチャにおいて、個々のサービス間でデータを非同期に交換するために使用されるパターンは何か？",
                 choices: [
                 "APIゲートウェイ",
                 "サービスディスカバリ",
                 "イベントソーシング",
                 "メッセージキュー"
                 ],
                 correctAnswerIndex: 3,
                 explanation: "メッセージキューは、マイクロサービスアーキテクチャにおいて、個々のサービス間でデータを非同期に交換するために使用されるパターンです。"
                 ),
                 QuizQuestion(
                 question: "暗号化技術における「対称鍵暗号化」とは異なり、公開鍵と秘密鍵の二つの鍵を用いる暗号化方式は何か？",
                 choices: [
                 "AES",
                 "RSA",
                 "SHA-256",
                 "DES"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "RSAは、公開鍵と秘密鍵の二つの鍵を用いる、対称鍵暗号化とは異なる暗号化方式です。"
                 ),
                 QuizQuestion(
                 question: "プログラミングにおいて、実行時にプログラムが操作するデータの量に基づいて、メモリ使用量が変化するデータ構造は何か？",
                 choices: [
                 "スタック",
                 "キュー",
                 "動的配列",
                 "静的配列"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "動的配列は、実行時にプログラムが操作するデータの量に基づいて、メモリ使用量が変化するデータ構造です。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェア開発プロジェクトにおいて、プロジェクトの利害関係者が合意形成を行うために用いられる、ビジュアルな表現方法は何か？",
                 choices: [
                 "フローチャート",
                 "ガントチャート",
                 "UML",
                 "ワークブレイクダウン構造（WBS）"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "UML（Unified Modeling Language）は、ソフトウェア開発プロジェクトにおいて、プロジェクトの利害関係者が合意形成を行うために用いられるビジュアルな表現方法です。"
                 ),
                 QuizQuestion(
                 question: "インターネットプロトコルスイートにおける、エラーメッセージやネットワークの診断に使用されるプロトコルは何か？",
                 choices: [
                 "TCP",
                 "UDP",
                 "ICMP",
                 "ARP"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "ICMP（Internet Control Message Protocol）は、インターネットプロトコルスイートにおいて、エラーメッセージやネットワークの診断に使用されるプロトコルです。"
                 ),


                 QuizQuestion(
                 question: "分散システムにおいて、データの整合性を維持しながら読み書きの遅延を許容する設計原則は何か？",
                 choices: [
                 "ACID",
                 "CAP定理",
                 "BASE",
                 "CRUD"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "BASE（基本的に利用可能、ソフトステート、最終的な整合性）は、分散システムにおいて、データの整合性を維持しながら読み書きの遅延を許容する設計原則です。"
                 ),
                 QuizQuestion(
                 question: "オブジェクト指向設計の原則で、「SOLID」の「S」は何を表すか？",
                 choices: [
                 "シングルトンパターン",
                 "シングルレスポンシビリティプリンシプル",
                 "シンクロナイズドステート",
                 "ステートフルサービス"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "SOLIDの「S」はシングルレスポンシビリティプリンシプルを表し、クラスは1つの責任しか持つべきではないという原則です。"
                 ),
                 QuizQuestion(
                 question: "ビッグデータ分析でよく使用される、大量のデータセットを分散処理するためのJavaフレームワークは何か？",
                 choices: [
                 "Django",
                 "Hadoop",
                 "Rails",
                 "Spring"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "Hadoopは、大量のデータセットを分散処理するためのオープンソースのJavaフレームワークです。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェア開発で、「アジャイル」の対義語とされる開発手法は何か？",
                 choices: [
                 "ウォーターフォールモデル",
                 "スパイラルモデル",
                 "Vモデル",
                 "イテレーティブモデル"
                 ],
                 correctAnswerIndex: 0,
                 explanation: "ウォーターフォールモデルは、ソフトウェア開発で「アジャイル」の対義語とされる開発手法で、一連の段階を順序立てて進む手法です。"
                 ),
                 QuizQuestion(
                 question: "コンピューターネットワークにおいて、エンドツーエンドのデータ転送を保証するプロトコルは何か？",
                 choices: [
                 "HTTP",
                 "TCP",
                 "UDP",
                 "IP"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "TCP（Transmission Control Protocol）は、コンピューターネットワークにおいて、エンドツーエンドのデータ転送を保証するプロトコルです。"
                 ),



                 QuizQuestion(
                 question: "クラウドコンピューティングのサービスモデルで、仮想化されたコンピューティングリソースをインターネット経由で提供するのは何か？",
                 choices: [
                 "Software as a Service (SaaS)",
                 "Platform as a Service (PaaS)",
                 "Infrastructure as a Service (IaaS)",
                 "Function as a Service (FaaS)"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "Infrastructure as a Service (IaaS) は、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルです。"
                 ),
                 QuizQuestion(
                 question: "Webアプリケーションにおいて、サーバー側でセッション情報を保持せずに状態を管理する方法は何か？",
                 choices: [
                 "セッション管理",
                 "クッキー",
                 "トークンベース認証",
                 "OAuth認証"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "トークンベース認証は、Webアプリケーションにおいて、サーバー側でセッション情報を保持せずに状態を管理する方法です。"
                 ),
                 QuizQuestion(
                 question: "プログラムのバグを特定して修正するプロセスを何と呼ぶか？",
                 choices: [
                 "コンパイリング",
                 "デバッグ",
                 "リファクタリング",
                 "パフォーマンスチューニング"
                 ],
                 correctAnswerIndex: 1,
                 explanation: "デバッグは、プログラムのバグを特定して修正するプロセスです。"
                 ),
                 QuizQuestion(
                 question: "ソフトウェア開発における「リファクタリング」の目的は何か？",
                 choices: [
                 "新機能を追加する",
                 "パフォーマンスを向上させる",
                 "コードの可読性や構造を改善する",
                 "セキュリティを強化する"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "リファクタリングの目的は、コードの可読性や構造を改善することです。"
                 ),
                 QuizQuestion(
                 question: "データベースにおける「トランザクション」の特性を保証するための概念は何か？",
                 choices: [
                 "SQL",
                 "CRUD",
                 "ACID",
                 "BASE"
                 ],
                 correctAnswerIndex: 2,
                 explanation: "ACID（原子性、一貫性、分離性、持続性）は、データベースにおける「トランザクション」の特性を保証するための概念です。"
                 ),



        QuizQuestion(
            question: "クラウドコンピューティングサービスモデル「IaaS」の全称は何か？",
            choices: [
                "Internet as a Service",
                "Infrastructure as a Service",
                "Information as a Service",
                "Integration as a Service"
            ],
            correctAnswerIndex: 1,
            explanation: "IaaS（Infrastructure as a Service）は、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドコンピューティングのサービスモデルです。"
        ),

        QuizQuestion(
            question: "暗号化において、同一の鍵を暗号化と復号に使用する方式は何か？",
            choices: [
                "公開鍵暗号方式",
                "対称鍵暗号方式",
                "非対称鍵暗号方式",
                "ハッシュ関数"
            ],
            correctAnswerIndex: 1,
            explanation: "対称鍵暗号方式では、同一の鍵を暗号化と復号の両方に使用します。これにより、高速な処理が可能ですが、鍵の配送がセキュリティの課題となります。"
        ),

        QuizQuestion(
            question: "ビッグデータの「3V」とは、どの3つの特性を指すか？",
            choices: [
                "Volume, Velocity, Variety",
                "Validity, Volatility, Vision",
                "Virtual, Vital, Visual",
                "Vulnerability, Vast, Value"
            ],
            correctAnswerIndex: 0,
            explanation: "ビッグデータの「3V」は、Volume（ボリューム）、Velocity（速度）、Variety（多様性）の3つの特性を指します。これらはビッグデータを特徴づける重要な要素です。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発において、ソースコードの変更が他の部分に予期せぬ影響を与えないようにするプラクティスは何か？",
            choices: [
                "コードレビュー",
                "ユニットテスト",
                "連続統合",
                "リファクタリング"
            ],
            correctAnswerIndex: 1,
            explanation: "ユニットテストは、ソフトウェア開発において、ソースコードの小さな部分が正しく動作することを確認するプラクティスです。これにより、変更が他の部分に予期せぬ影響を与えるのを防ぎます。"
        ),

        QuizQuestion(
            question: "REST APIの設計原則において、リソースの状態を変更するために推奨されるHTTPメソッドは何か？",
            choices: [
                "GET",
                "POST",
                "PUT",
                "DELETE"
            ],
            correctAnswerIndex: 2,
            explanation: "REST APIの設計原則において、リソースの状態を変更するためにはPUTメソッドが推奨されます。PUTメソッドは、リソースの更新または置換に使用されます。"
        ),

        QuizQuestion(
            question: "データサイエンスプロジェクトにおいて、データの前処理に含まれる一般的なステップは何か？",
            choices: [
                "クラスタリング",
                "データクレンジング",
                "データ可視化",
                "アルゴリズム選択"
            ],
            correctAnswerIndex: 1,
            explanation: "データサイエンスプロジェクトにおけるデータの前処理では、データクレンジングが一般的なステップです。これには、欠損値の処理、異常値の検出と修正、データの標準化や正規化などが含まれます。"
        ),

        QuizQuestion(
            question: "ブロックチェーン技術において、トランザクションが永続的に記録され、改ざんが困難である性質を何と呼ぶか？",
            choices: [
                "透明性",
                "分散性",
                "不変性",
                "匿名性"
            ],
            correctAnswerIndex: 2,
            explanation: "ブロックチェーン技術において、トランザクションが永続的に記録され、改ざんが困難である性質を不変性（Immutability）と呼びます。これはブロックチェーンの核心的な特徴の一つです。"
        ),


        QuizQuestion(
            question: "サイバーセキュリティにおいて、フィッシング攻撃を防ぐためのベストプラクティスは何ですか？",
            choices: [
                "パスワードを定期的に変更する",
                "セキュリティパッチを定期的に適用する",
                "不審なメールには応答しない",
                "公開Wi-Fiを頻繁に使用する"
            ],
            correctAnswerIndex: 2,
            explanation: "フィッシング攻撃は、不審なメールやウェブサイトを通じて個人情報を盗もうとする試みです。不審なメールに応答しないことは、これらの攻撃を防ぐための重要なステップです。"
        ),

        QuizQuestion(
            question: "ソフトウェア開発において、「リファクタリング」とは何を指しますか？",
            choices: [
                "新機能を追加すること",
                "既存のコードの構造を改善すること",
                "ソフトウェアのバージョンをアップグレードすること",
                "デバッグプロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "リファクタリングは、外から見たときのソフトウェアの動作を変えることなく、内部のコード構造を改善するプロセスです。これは可読性の向上、保守性の強化、および将来的な拡張性の確保を目的としています。"
        ),

        QuizQuestion(
            question: "DevOps文化において、CI/CDパイプラインのCIは何を意味しますか？",
            choices: [
                "継続的インプルーブメント",
                "継続的インテグレーション",
                "コンフィギュレーションインターフェース",
                "コンピュータインタラクション"
            ],
            correctAnswerIndex: 1,
            explanation: "継続的インテグレーション(CI)は、ソフトウェア開発プロセスにおいて、開発者がコード変更を頻繁にメインラインに統合するプラクティスです。これにより、ソフトウェアの品質を早期に検証し、問題を早期に発見することができます。"
        )
             
             

        
        
    ]
    
    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: TimeAdvancedList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .timeAdvanced, authManager: authManager,audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct TimeAdvancedList_Previews: PreviewProvider {
    static var previews: some View {
        TimeAdvancedList(isPresenting: .constant(false))
    }
}
