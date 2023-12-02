//
//  QuizAdvancedList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/22.
//

import SwiftUI

struct QuizAdvancedList: View {
    @Binding var isPresenting: Bool
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
        )

        
        
    ]
    
    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared
    
    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizAdvancedList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .advanced, authManager: authManager,audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizAdvancedList_Previews: PreviewProvider {
    static var previews: some View {
        QuizAdvancedList(isPresenting: .constant(false))
    }
}
