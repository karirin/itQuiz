//
//  QuizAppliedTechnologyListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct QuizAppliedTechnologyListView: View {
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
            question: "「マイクロフロントエンド」とは何か？",
            choices: [
              "フロントエンドアプリケーションを小さく独立した部分に分割する設計アプローチ",
              "特定のマイクロプロセッサに最適化されたフロントエンド開発技術",
              "小規模なウェブサイトのためのデザイン手法",
              "データを微細なパーツに分割して処理するプログラミング手法"
            ],
            correctAnswerIndex: 0,
            explanation: "マイクロフロントエンドは、大規模なフロントエンドアプリケーションをより小さく、再利用可能で、独立したユニットに分割する開発手法です。これにより、チームは各部分を独立して開発、テスト、デプロイすることができ、より柔軟で効率的な開発プロセスを実現します。"
        ),
        QuizQuestion(
            question: "「サービスメッシュ」とは何か？",
            choices: [
              "マイクロサービス間の通信を管理するためのインフラストラクチャ層",
              "クラウドサービスを統合するための新しいプロトコル",
              "データセンター内の物理的なサーバー配置を最適化する方法",
              "ウェブサービスのセキュリティを強化するためのツール"
            ],
            correctAnswerIndex: 0,
            explanation: "サービスメッシュは、マイクロサービスアーキテクチャ内でのサービス間通信を制御、管理するために設計された専用のインフラストラクチャ層です。これにより、開発者はサービスの開発に集中でき、通信のセキュリティ、監視、負荷分散などの機能をサービスメッシュが担当します。"
        ),
        QuizQuestion(
            question: "「コンテナオーケストレーション」とは何か？",
            choices: [
              "コンテナ化されたアプリケーションのデプロイメント、管理、スケーリングを自動化するプロセス",
              "音楽制作のためのソフトウェアコンテナ技術",
              "データセンターでの物理的なコンテナの管理方法",
              "ウェブサイトのコンテンツを効率的に配信するための技術"
            ],
            correctAnswerIndex: 0,
            explanation: "コンテナオーケストレーションは、コンテナ化されたアプリケーションのライフサイクルを管理するプロセスです。これには、アプリケーションのデプロイメント、スケーリング、ロードバランシング、ログ管理などが含まれ、主に自動化ツールを使用して行われます。"
        ),
        QuizQuestion(
            question: "「サイバーレジリエンス」とは何か？",
            choices: [
              "サイバー攻撃や技術的な障害から回復するための組織の能力",
              "サイバーセキュリティ技術の最新トレンド",
              "インターネットのスピードを向上させる新技術",
              "デジタルデバイスの耐久性をテストするプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "サイバーレジリエンスは、サイバー攻撃や技術的障害から組織が効果的に回復し、その影響を最小限に抑える能力を指します。これは、予防的なセキュリティ対策だけでなく、事後の対応計画や回復策も含む概念です。"
        )
        ,
        QuizQuestion(
            question: "「データレイク」とは何か？",
            choices: [
              "構造化されていない大量の生データを格納するためのリポジトリ",
              "データを冷却するための物理的な施設",
              "データベース管理のための新しいプロトコル",
              "データセキュリティを高めるための技術"
            ],
            correctAnswerIndex: 0,
            explanation: "データレイクは、大量の生データをそのままの形式で格納できるリポジトリです。構造化されていないデータや半構造化されたデータを含み、後で分析や処理のために利用できます。"
        ),

        QuizQuestion(
            question: "「API（アプリケーションプログラミングインターフェイス）」の主な目的は何か？",
            choices: [
              "異なるソフトウェア間でのデータのやり取りと機能の利用を可能にする",
              "ウェブサイトのデザインを改善する",
              "コンピューターのハードウェア性能を向上させる",
              "インターネットの速度を高める"
            ],
            correctAnswerIndex: 0,
            explanation: "APIは、異なるソフトウェアアプリケーション間でデータを交換したり、互いの機能を利用したりするためのインターフェースを提供します。これにより、開発者は特定のサービスやデータに簡単にアクセスし、利用することができます。"
        ),
        QuizQuestion(
            question: "データの「正規化」とは何か？",
            choices: [
              "データベース内のデータを整理し、重複を排除するプロセス",
              "データをより高速に処理するための技術",
              "データを暗号化する方法",
              "データベースからデータを削除するプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "正規化は、データベース設計のプロセスであり、データの整理、重複の排除、データの一貫性と整合性を保つために行われます。これにより、データベースの効率的な使用と管理が可能になります。"
        ),
        QuizQuestion(
            question: "「クラウドネイティブ」技術の利点は何か？",
            choices: [
              "クラウド環境で最適化されたアプリケーションの開発、運用を可能にする",
              "ローカルストレージのコスト削減",
              "物理的なサーバーのセットアップが不要になる",
              "インターネット接続が不要になる"
            ],
            correctAnswerIndex: 0,
            explanation: "クラウドネイティブ技術は、クラウド環境に特化して設計されたアプリケーションやサービスを開発・運用するアプローチであり、スケーラビリティ、柔軟性、迅速なデプロイメントなどの利点を提供します。"
        ),

        QuizQuestion(
            question: "クラウドコンピューティングのモデル「ハイブリッドクラウド」とは何か？",
            choices: [
              "プライベートクラウドとパブリッククラウドの両方を組み合わせた環境",
              "複数のパブリッククラウドサービスを組み合わせた環境",
              "完全にプライベートなクラウド環境",
              "物理的なサーバーとクラウドサーバーが独立している環境"
            ],
            correctAnswerIndex: 0,
            explanation: "ハイブリッドクラウドは、プライベートクラウドとパブリッククラウドの技術を組み合わせて利用することで、それぞれの環境の利点を最大化するクラウドコンピューティングモデルです。"
        ),
        QuizQuestion(
            question: "「ドメイン駆動設計（DDD）」の目的は何か？",
            choices: [
              "ソフトウェアの問題領域をモデリングし、実世界の複雑さを管理する",
              "ウェブサイトのドメイン名を効率的に管理する",
              "データベースのドメインを最適化する",
              "ネットワークドメインのセキュリティを強化する"
            ],
            correctAnswerIndex: 0,
            explanation: "ドメイン駆動設計（DDD）は、複雑なビジネスドメインを取り扱うソフトウェアプロジェクトにおいて、実世界の問題領域を理解し、それをソフトウェア設計に反映させるアプローチです。"
        ),
        QuizQuestion(
            question: "「ソフトウェアアジャイル開発」の一環として行われる「スプリントレビュー」の目的は何か？",
            choices: [
              "スプリント期間中に開発された機能をレビューし、ステークホルダーのフィードバックを得る",
              "開発チームのパフォーマンスを評価する",
              "次のスプリントで修正するバグをリストアップする",
              "プロジェクトの予算をレビューし、調整する"
            ],
            correctAnswerIndex: 0,
            explanation: "スプリントレビューは、アジャイル開発のスプリント終了時に行われ、開発された機能をステークホルダーにデモンストレーションし、彼らのフィードバックを得ることを目的としています。"
        ),
        QuizQuestion(
            question: "サイバーセキュリティにおいて「エンドポイント保護」とは何を指すか？",
            choices: [
              "ネットワークに接続される全デバイス（エンドポイント）をセキュリティ脅威から保護する手法",
              "インターネットの終端点を保護する技術",
              "データ転送の最終段階での暗号化技術",
              "クラウドサービスへのアクセスを保護する技術"
            ],
            correctAnswerIndex: 0,
            explanation: "エンドポイント保護は、ネットワークに接続された全てのデバイス（PC、スマートフォン、タブレットなど）をマルウェアやハッキングといったセキュリティ脅威から保護するためのサイバーセキュリティ手法です。"
        ),
        QuizQuestion(
            question: "「ビジネスインテリジェンス（BI）」の目的は何か？",
            choices: [
              "ビジネスの意思決定をサポートするためにデータ分析と情報の可視化を行う",
              "新しいビジネスモデルを開発する",
              "企業のマーケティング戦略を改善する",
              "企業の財務状態を監視する"
            ],
            correctAnswerIndex: 0,
            explanation: "ビジネスインテリジェンス（BI）は、データを収集、分析し、それをビジネスの意思決定プロセスをサポートするための洞察や情報に変換するプロセスです。"
        ),

        QuizQuestion(
            question: "エッジコンピューティングとは何か？",
            choices: [
              "データ処理をデータソースに近いネットワークの端に配置することで、レスポンス時間を短縮し、帯域幅の使用量を減らす技術",
              "データセンター内のサーバーで全てのデータ処理を行う従来の方法",
              "高速なインターネット接続を通じてリモートサーバーにアクセスする技術",
              "仮想現実環境を作成するための技術"
            ],
            correctAnswerIndex: 0,
            explanation: "エッジコンピューティングは、データ処理をデータソースに近い場所で行うことにより、レスポンス時間を短縮し、ネットワークの帯域幅使用量を減らすことを目的とした技術です。"
        ),
        QuizQuestion(
            question: "「量子コンピューティング」の主な特徴は何か？",
            choices: [
              "従来のビットではなく量子ビットを使用して情報を処理し、複雑な計算を非常に高速に行う能力",
              "高性能グラフィックカードを使用してビデオゲームのパフォーマンスを向上させる技術",
              "データをクラウドに保存し、どこからでもアクセスできるようにするサービス",
              "インターネットの速度を向上させる技術"
            ],
            correctAnswerIndex: 0,
            explanation: "量子コンピューティングは、従来のビットではなく量子ビット（qubit）を使用して情報を処理することで、一部の種類の計算を現在のコンピューターよりもはるかに高速に実行できる技術です。"
        ),
        QuizQuestion(
            question: "デジタル変換（デジタルトランスフォーメーション）とは何か？",
            choices: [
              "組織がデジタル技術を利用して業務プロセス、文化、顧客体験を根本的に変革すること",
              "アナログ信号をデジタル信号に変換するプロセス",
              "デジタルマーケティング戦略を実行すること",
              "新しいソフトウェア開発手法を学ぶこと"
            ],
            correctAnswerIndex: 0,
            explanation: "デジタル変換（デジタルトランスフォーメーション）は、組織がデジタル技術を採用し、それを通じて業務プロセス、企業文化、顧客体験を根本的に改革し、改善することを指します。"
        ),
        QuizQuestion(
            question: "サイバーセキュリティにおける「フィッシング攻撃」とは何か？",
            choices: [
              "詐欺的な手法を用いて個人情報を盗み出す行為",
              "コンピューターシステムに対する物理的な攻撃",
              "高度なコンピューティング技術を用いたデータ分析プロセス",
              "ウイルス対策ソフトウェアをテストするプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "フィッシング攻撃は、詐欺的なメールやウェブサイトを使って、ユーザーから個人情報や財務情報などを騙し取るサイバーセキュリティ攻撃の一種です。"
        ),
        QuizQuestion(
            question: "「ブルートフォース攻撃」とは何か？",
            choices: [
              "総当たり攻撃とも呼ばれ、可能な全てのパスワードや暗号鍵の組み合わせを試してアクセスを試みる方法",
              "ウェブサイトに大量のリクエストを送りつけてサービスを停止させる攻撃",
              "メールを通じてマルウェアを拡散する攻撃",
              "ネットワーク上の脆弱性を探索して侵入する攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "ブルートフォース攻撃は、総当たり方式を用いて、パスワードや暗号鍵の全ての可能性を一つずつ試していくことで、システムへの不正アクセスを試みる攻撃手法です。"
        ),

        QuizQuestion(
            question: "IPv6の導入による主な改善点は何か？",
            choices: [
              "より多くのデバイスに対して一意のIPアドレスを割り当てられるようになる",
              "インターネットの速度が大幅に向上する",
              "ウイルスやマルウェアからの保護が強化される",
              "ウェブサイトのデザインが向上する"
            ],
            correctAnswerIndex: 0,
            explanation: "IPv6の導入により、ほぼ無限とも言える数の一意のIPアドレスが利用可能になり、これによりインターネット上のデバイス数の増加に対応できます。"
        ),
        QuizQuestion(
            question: "ソフトウェア開発での「ユニットテスト」の目的は何か？",
            choices: [
              "個々のコンポーネントや関数が正しく動作することを確認する",
              "アプリケーションのユーザーインターフェイスをテストする",
              "ネットワークのセキュリティを評価する",
              "ソフトウェアのインストールプロセスをテストする"
            ],
            correctAnswerIndex: 0,
            explanation: "ユニットテストは、ソフトウェア開発プロセスにおいて、個々のコンポーネントや関数が仕様通りに正しく動作するかを確認するために行われます。"
        ),
        QuizQuestion(
            question: "クラウドコンピューティングの「スケーラビリティ」とは何を意味するか？",
            choices: [
              "リソースを必要に応じて柔軟に増減できる能力",
              "データを安全に保管する能力",
              "アプリケーションの開発速度を向上させる能力",
              "ネットワークの速度を最適化する能力"
            ],
            correctAnswerIndex: 0,
            explanation: "スケーラビリティは、システムやアプリケーションの利用者数や負荷が増えた場合に、リソースを追加または削減して対応できるクラウドコンピューティングの重要な特性です。"
        ),
        QuizQuestion(
            question: "「データマイニング」とは何か？",
            choices: [
              "大量のデータからパターンや関連性を抽出するプロセス",
              "インターネットから情報を収集するプロセス",
              "データベース内のデータを物理的に掘り出すプロセス",
              "コンピューターのCPUを使用して暗号通貨を生成するプロセス"
            ],
            correctAnswerIndex: 0,
            explanation: "データマイニングは、大規模なデータセットから有用な情報や新たな知見を発見するための分析技術で、パターン認識、統計学、機械学習などを用います。"
        ),
        QuizQuestion(
            question: "「DevOps」とは何か？",
            choices: [
              "開発（Dev）と運用（Ops）の協力を促進する文化と実践のセット",
              "新しいプログラミング言語",
              "データベース管理システム",
              "ネットワークセキュリティプロトコル"
            ],
            correctAnswerIndex: 0,
            explanation: "DevOpsは、ソフトウェアの開発（Dev）と運用（Ops）のチームが連携して作業する文化、ツール、実践のセットを指し、ソフトウェアのリリースと更新を迅速かつ効率的に行うことを目的としています。"
        ),
//
        QuizQuestion(
            question: "マイクロサービスアーキテクチャの主な利点は何か？",
            choices: [
              "システムの各部分を独立して開発、デプロイ、スケールできる柔軟性",
              "データ処理速度の大幅な向上",
              "セキュリティリスクの自動排除",
              "単一のデータベースでのデータ統合"
            ],
            correctAnswerIndex: 0,
            explanation: "マイクロサービスアーキテクチャは、システムを小さなサービスに分割し、それぞれを独立して開発、デプロイ、スケールできるようにすることで、システム全体の柔軟性とメンテナンス性を向上させます。"
        ),
        QuizQuestion(
            question: "ソフトウェア開発において「リファクタリング」の目的は何か？",
            choices: [
              "コードの内部構造を改善し、理解しやすく保守しやすくする",
              "新機能を追加する",
              "データベースのパフォーマンスを向上させる",
              "ネットワークのセキュリティを強化する"
            ],
            correctAnswerIndex: 0,
            explanation: "リファクタリングは、外部から見たプログラムの振る舞いを変えずに、コードの内部構造を整理し改善することで、コードの可読性と保守性を向上させるプロセスです。"
        ),
        QuizQuestion(
            question: "ビッグデータ分析で用いられる「Hadoop」の特徴は何か？",
            choices: [
              "大規模なデータセットの分散処理とストレージを可能にするフレームワーク",
              "グラフィックデザイン専用のソフトウェア",
              "リアルタイムの通信を提供するネットワークプロトコル",
              "ウェブページの作成を容易にするマークアップ言語"
            ],
            correctAnswerIndex: 0,
            explanation: "Hadoopは、大規模なデータセットを複数のコンピューターで分散処理し、効率的に扱うためのオープンソースフレームワークです。"
        ),
        QuizQuestion(
            question: "デジタル署名の主な目的は何か？",
            choices: [
              "電子文書の真正性、完全性、送信者の否認防止を保証する",
              "文書の読み込み速度を向上させる",
              "電子メールの自動分類を行う",
              "データベースの自動バックアップを実行する"
            ],
            correctAnswerIndex: 0,
            explanation: "デジタル署名は、電子文書が改ざんされていないこと、送信者が文書の内容を承認していること、および送信者が後でその送信を否認できないことを保証するために使用されます。"
        ),

        QuizQuestion(
            question: "クラウドストレージサービスの利点は何か？",
            choices: [
              "データのリモートアクセス、共有、バックアップの容易さ",
              "コンピューターの処理速度の向上",
              "オフラインでのデータアクセス",
              "ローカルストレージの物理的な拡張"
            ],
            correctAnswerIndex: 0,
            explanation: "クラウドストレージサービスは、インターネット経由でどこからでもデータにアクセスし、共有、バックアップすることを可能にします。"
        ),
        QuizQuestion(
            question: "プログラミング言語Pythonの特徴は何か？",
            choices: [
              "高レベル、動的型付け、汎用のプログラミング言語",
              "低レベルプログラミング専用言語",
              "グラフィックデザイン専用言語",
              "ネットワーク設定専用言語"
            ],
            correctAnswerIndex: 0,
            explanation: "Pythonは、読みやすく学びやすい高レベルで動的型付けされた汎用のプログラミング言語です。"
        ),
        QuizQuestion(
            question: "情報セキュリティの原則「CIAトライアド」とは何を指すか？",
            choices: [
              "機密性、完全性、可用性",
              "コード、インターネット、アクセス",
              "コンピューティング、イノベーション、アプリケーション",
              "クライアント、インフラ、アーキテクチャ"
            ],
            correctAnswerIndex: 0,
            explanation: "CIAトライアドは、情報セキュリティの基本原則であり、機密性（Confidentiality）、完全性（Integrity）、可用性（Availability）を指します。"
        ),
        QuizQuestion(
            question: "「IoT」が意味するものは何か？",
            choices: [
              "インターネットオブシングス：物理的なデバイスをインターネットに接続する技術",
              "インタラクティブオンラインテスト",
              "インターネットオペレーションチーム",
              "イノベーションオブテクノロジー"
            ],
            correctAnswerIndex: 0,
            explanation: "IoT（インターネットオブシングス）は、家電製品やセンサーなど、物理的なデバイスをインターネットに接続し、データの収集や交換を可能にする技術です。"
        ),
        QuizQuestion(
            question: "プロジェクト管理の文脈での「スクラム」は何を指すか？",
            choices: [
              "アジャイル開発のための反復的なフレームワーク",
              "プロジェクトの遅延を管理する技術",
              "コンピューターネットワークのセキュリティプロトコル",
              "データベース管理システム"
            ],
            correctAnswerIndex: 0,
            explanation: "スクラムは、アジャイルソフトウェア開発のためのフレームワークであり、小チームでの協力を促進し、反復的かつ増分的なプロセスを通じて製品を開発します。"
        ),

        QuizQuestion(
            question: "ブロックチェーン技術の主な特徴は何か？",
            choices: [
              "分散型台帳技術による透明性と改ざん防止",
              "データの高速処理",
              "単一の管理者によるデータ管理",
              "高度なグラフィック処理能力"
            ],
            correctAnswerIndex: 0,
            explanation: "ブロックチェーン技術は、分散型台帳技術を用いてデータの透明性を確保し、データの改ざんを防ぐことが特徴です。"
        ),
        QuizQuestion(
            question: "仮想現実（VR）と拡張現実（AR）の違いは何か？",
            choices: [
              "VRは完全な仮想世界を作り出し、ARは現実世界にデジタル情報を重ね合わせる",
              "VRは主に教育に使用され、ARはゲームに使用される",
              "VRはデータ分析に使用され、ARはデータベース管理に使用される",
              "VRとARは同じ技術であり、違いはない"
            ],
            correctAnswerIndex: 0,
            explanation: "仮想現実（VR）はユーザーを完全に仮想環境に没入させるのに対し、拡張現実（AR）は現実世界にデジタル要素を追加して拡張します。"
        ),
        QuizQuestion(
            question: "コンテナ技術によるソフトウェア開発の利点は何か？",
            choices: [
              "アプリケーションの移植性の向上と環境依存性の削減",
              "データの自動バックアップ",
              "グラフィックデザインの向上",
              "インターネット接続速度の向上"
            ],
            correctAnswerIndex: 0,
            explanation: "コンテナ技術は、異なる環境間でのアプリケーションの実行を容易にし、環境依存性を削減することで開発と運用の効率を向上させます。"
        ),
        QuizQuestion(
            question: "サイバーセキュリティにおける「ファイアウォール」の機能は何か？",
            choices: [
              "不正アクセスからネットワークを保護する",
              "データの自動バックアップを提供する",
              "インターネットの速度を向上させる",
              "ユーザーのウェブブラウジングを追跡する"
            ],
            correctAnswerIndex: 0,
            explanation: "ファイアウォールは、不正アクセスから内部ネットワークを保護するためのセキュリティシステムで、許可された通信のみを通過させます。"
        ),
        QuizQuestion(
            question: "ソフトウェア開発プロセスにおける「デバッグ」の目的は何か？",
            choices: [
              "ソフトウェアからバグやエラーを特定し修正する",
              "ソフトウェアのパフォーマンスを向上させる",
              "ソフトウェアのセキュリティを向上させる",
              "ソフトウェアのユーザーインターフェースを改善する"
            ],
            correctAnswerIndex: 0,
            explanation: "デバッグは、ソフトウェア開発プロセスにおいて、プログラムからバグやエラーを特定し、それらを修正する活動です。"
        ),

        QuizQuestion(
            question: "クラウドコンピューティングにおけるIaaS、PaaS、SaaSの違いは何か？",
            choices: [
              "IaaSはインフラストラクチャを提供し、PaaSはプラットフォームを提供し、SaaSはソフトウェアを提供する",
              "すべてのコンピューターの速度を向上させるサービス",
              "インターネットセキュリティを提供するサービス",
              "オンラインでのデータ共有を可能にするサービス"
            ],
            correctAnswerIndex: 0,
            explanation: "クラウドコンピューティングサービスは、IaaS（Infrastructure as a Service）、PaaS（Platform as a Service）、SaaS（Software as a Service）の3つの主要なカテゴリに分類され、それぞれインフラストラクチャ、プラットフォーム、ソフトウェアをクラウド経由で提供します。"
        ),
        QuizQuestion(
            question: "ビッグデータの3Vとは何か？",
            choices: [
              "ボリューム、バラエティ、ベロシティ",
              "ビジュアル、バリュー、ヴォイス",
              "バーチャル、ビジョン、ヴァリデーション",
              "ボルテージ、ベクトル、ビネット"
            ],
            correctAnswerIndex: 0,
            explanation: "ビッグデータの3Vは、大量のデータ量（ボリューム）、様々な種類のデータ（バラエティ）、高速なデータ生成と処理（ベロシティ）を指します。"
        ),
        QuizQuestion(
            question: "ソフトウェア開発におけるアジャイル方法論の特徴は何か？",
            choices: [
              "短いスプリントでの反復的な開発と顧客との頻繁なコラボレーション",
              "長期計画に基づく一括開発",
              "コーディング標準の強化",
              "ソフトウェアの自動テストとデプロイメント"
            ],
            correctAnswerIndex: 0,
            explanation: "アジャイル方法論は、短い開発サイクル（スプリント）を通じて反復的にソフトウェアを開発し、顧客との頻繁なコラボレーションを重視します。"
        ),
        QuizQuestion(
            question: "機械学習における教師あり学習と教師なし学習の違いは何か？",
            choices: [
              "教師あり学習はラベル付きデータを使用し、教師なし学習はラベルのないデータを使用する",
              "教師あり学習は自動で行われ、教師なし学習は手動で行われる",
              "教師あり学習はテストのためだけに使用され、教師なし学習は実際の問題解決のために使用される",
              "教師あり学習は高速ながら教師なし学習は遅い"
            ],
            correctAnswerIndex: 0,
            explanation: "教師あり学習はラベル付きデータを使用してモデルを訓練し、特定の出力を予測することを学びます。一方、教師なし学習はラベルのないデータを使用してデータセット内のパターンや関連性を見つけ出します。"
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
            explanation: "IPアドレスは、インターネットプロトコルネットワーク上の各デバイスを一意に識別するために使用されます。"
        ),
        QuizQuestion(
            question: "暗号技術における公開鍵と秘密鍵の役割は何か？",
            choices: [
              "公開鍵はデータの暗号化に、秘密鍵はそのデータの復号に使用される",
              "公開鍵と秘密鍵はデータの速度を向上させるために使用される",
              "公開鍵はネットワークのセキュリティを強化するために使用される",
              "秘密鍵はネットワーク上でのプリンター共有を可能にする"
            ],
            correctAnswerIndex: 0,
            explanation: "公開鍵暗号方式では、公開鍵はデータの暗号化に使用され、そのデータを復号するためには秘密鍵が必要です。"
        ),
        QuizQuestion(
            question: "OSI参照モデルでのトランスポート層の主な機能は何か？",
            choices: [
              "データリンクの確立と維持",
              "アプリケーション間のデータ伝送の信頼性を提供する",
              "メディアアクセス制御",
              "ネットワーク間のルーティング"
            ],
            correctAnswerIndex: 1,
            explanation: "トランスポート層は、エンドツーエンドでのデータ伝送の信頼性を提供し、データの正確な送受信を保証します。"
        ),
        QuizQuestion(
            question: "データベース管理システム(DBMS)の目的は何か？",
            choices: [
              "データの保存と検索を効率的に行う",
              "ネットワークの速度を向上させる",
              "システムのセキュリティを強化する",
              "企業の財務状態を分析する"
            ],
            correctAnswerIndex: 0,
            explanation: "データベース管理システム(DBMS)は、データの効率的な保存、検索、更新を可能にするソフトウェアです。"
        ),


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
        QuizView(quizzes: shuffledQuizList, quizLevel: .appliedTechnology, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizAppliedTechnologyListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizAppliedTechnologyListView(isPresenting: .constant(false))
    }
}
