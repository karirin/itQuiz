//
//  QuizGodList.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/31.
//

import SwiftUI

struct QuizGodList: View {
    @Binding var isPresenting: Bool
    let QuizGodList: [QuizQuestion] = [
        QuizQuestion(
            question: "ネットワークプロトコル「HTTP/3」で主に使用されるトランスポートプロトコルは何ですか？",
            choices: [
                "TCP",
                "TPP",
                "SCTP",
                "QUIC"
            ],
            correctAnswerIndex: 3,
            explanation: "HTTP/3では、以前のバージョンで使用されていたTCPの代わりにQUICプロトコルが使用されます。これにより、通信の効率と速度が向上しています。"
        ),
        QuizQuestion(
            question: "暗号学において、同じ平文を同じ鍵で暗号化したときに常に同じ暗号文を生成する暗号方式を何と言いますか？",
            choices: [
                "非対称暗号",
                "ハッシュ関数",
                "対称暗号",
                "ブロック暗号"
            ],
            correctAnswerIndex: 2,
            explanation: "対称暗号は、同じ鍵を使用して暗号化と復号を行います。したがって、同じ平文と同じ鍵を使用すると、常に同じ暗号文が生成されます。"
        ),
        QuizQuestion(
            question: "コンピュータビジョンにおいて、「畳み込みニューラルネットワーク（CNN）」の主要な用途は何ですか？",
            choices: [
                "音声認識",
                "テキスト解析",
                "画像認識",
                "時系列データ分析"
            ],
            correctAnswerIndex: 2,
            explanation: "畳み込みニューラルネットワーク（CNN）は、画像認識や物体検出など、視覚的なタスクに非常に効果的です。"
        ),
        QuizQuestion(
            question: "ブロックチェーン技術において、全てのトランザクションが全ノードで確認されるプロセスを何と言いますか？",
            choices: [
                "マイニング",
                "コンセンサス",
                "ハッシング",
                "暗号化"
            ],
            correctAnswerIndex: 1,
            explanation: "コンセンサスプロセスは、ブロックチェーンネットワーク上での全てのトランザクションが正しいものとして確認されるためのプロセスです。"
        ),
        QuizQuestion(
            question: "Linuxオペレーティングシステムにおいて、システムの起動時にカーネルが最初に実行するプログラムの名前は何ですか？",
            choices: [
                "bash",
                "systemd",
                "init",
                "grub"
            ],
            correctAnswerIndex: 2,
            explanation: "initはLinuxシステムが起動する際にカーネルによって最初に実行されるプログラムであり、システム初期化やデーモンプロセスの起動を担当します。"
        ),
        QuizQuestion(
            question: "「CAP定理」において、分散システムが同時に達成できないとされている2つの特性は何ですか？",
            choices: [
                "一貫性と分割耐性",
                "可用性と分割耐性",
                "一貫性と可用性",
                "パフォーマンスと信頼性"
            ],
            correctAnswerIndex: 0,
            explanation: "CAP定理は、分散システムにおいて、一貫性、可用性、分割耐性の3つの特性のうち、同時に2つしか達成できないと述べています。したがって、一貫性と分割耐性を同時に達成することはできません。"
        ),
        QuizQuestion(
            question: "暗号通貨の「51%攻撃」は何を意味しますか？",
            choices: [
                "ネットワークの51%以上を制御することでダブルスペンディングを可能にする攻撃",
                "51%以上のユーザーのアカウントをハッキングする攻撃",
                "51%以上のコンピューティングパワーを使って全てのマイニング報酬を獲得する攻撃",
                "トランザクションの51%を偽造する攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "51%攻撃は、攻撃者がネットワークのマイニングパワーの51%以上を制御することで、トランザクションの検証を操作し、ダブルスペンディングを可能にする攻撃を指します。"
        ),
        QuizQuestion(
            question: "「BlueKeep」は何のセキュリティ脆弱性を指しますか？",
            choices: [
                "Windows 10のセキュリティ脆弱性",
                "Windows Remote Desktop Servicesのセキュリティ脆弱性",
                "Android OSのセキュリティ脆弱性",
                "macOSのセキュリティ脆弱性"
            ],
            correctAnswerIndex: 1,
            explanation: "BlueKeepはWindows Remote Desktop Servicesに存在するセキュリティ脆弱性であり、攻撃者が任意のコードを実行し、システムを完全にコントロールできるようになる恐れがあります。"
        ),
        QuizQuestion(
            question: "「Dirty COW」はLinuxカーネルのどの部分に影響を与えるセキュリティ脆弱性ですか？",
            choices: [
                "ネットワークスタック",
                "ファイルシステム",
                "メモリ管理",
                "デバイスドライバ"
            ],
            correctAnswerIndex: 2,
            explanation: "Dirty COWはLinuxカーネルのメモリ管理システムに影響を与えるセキュリティ脆弱性で、権限昇格を引き起こす可能性があります。"
        ),
        QuizQuestion(
            question: "「Zero-Day Exploit」とは何ですか？",
            choices: [
                "脆弱性が発見されてから30日以内に利用されるエクスプロイト",
                "脆弱性がパッチで修正される前に利用されるエクスプロイト",
                "脆弱性が公にされてから1日以内に利用されるエクスプロイト",
                "未知の脆弱性を利用するエクスプロイト"
            ],
            correctAnswerIndex: 1,
            explanation: "Zero-Day Exploitは、脆弱性が開発者によって修正される前に、攻撃者がその脆弱性を利用することを指します。"
        ),
        QuizQuestion(
            question: "「Kubernetes」は何を管理するためのオープンソースプラットフォームですか？",
            choices: [
                "データベース",
                "コンテナ",
                "ネットワークデバイス",
                "ウェブサーバ"
            ],
            correctAnswerIndex: 1,
            explanation: "Kubernetesは、コンテナのデプロイメント、スケーリング、および運用を自動化するためのオープンソースプラットフォームです。"
        ),
        QuizQuestion(
            question: "「SHA-256」は何の略ですか？",
            choices: [
                "Secure Hash Algorithm 256-bit",
                "Symmetric Hash Algorithm 256-bit",
                "Secure Hypertext Algorithm 256-bit",
                "Symmetric Hypertext Algorithm 256-bit"
            ],
            correctAnswerIndex: 0,
            explanation: "SHA-256はSecure Hash Algorithm 256-bitの略で、一方向のハッシュ関数の一つです。"
        ),
        QuizQuestion(
            question: "「OAuth」は何のために使用されますか？",
            choices: [
                "パスワードベースの認証",
                "データベース暗号化",
                "サードパーティ認証",
                "ウイルススキャン"
            ],
            correctAnswerIndex: 2,
            explanation: "OAuthは、ユーザーが自分の情報を共有する際に安全にサードパーティのアプリケーションに認証情報を提供できるプロトコルです。"
        ),
        QuizQuestion(
            question: "「REST」の「S」は何を意味しますか？",
            choices: [
                "Simple",
                "Secure",
                "State",
                "Service"
            ],
            correctAnswerIndex: 2,
            explanation: "RESTはRepresentational State Transferの略であり、「S」は「State」を意味します。RESTfulなAPIでは、各リクエストは独立しており、以前のリクエストの状態に依存しません。"
        ),
        QuizQuestion(
            question: "「ビッグエンディアン」および「リトルエンディアン」は何に関連していますか？",
            choices: [
                "プロセッサのアーキテクチャ",
                "プログラミング言語",
                "ネットワークプロトコル",
                "データベース管理システム"
            ],
            correctAnswerIndex: 0,
            explanation: "ビッグエンディアンとリトルエンディアンは、プロセッサがデータをメモリに格納する際のバイト順を指します。ビッグエンディアンでは最も重要なバイトが最も低いアドレスに格納され、リトルエンディアンでは最も重要なバイトが最も高いアドレスに格納されます。"
        ),
        QuizQuestion(
            question: "「Quantum Supremacy」は何を指しますか？",
            choices: [
                "量子コンピュータが古典コンピュータよりも高速に特定の問題を解くことができる状態",
                "量子通信の最先端技術",
                "超伝導材料の新しいクラス",
                "量子暗号の安全性"
            ],
            correctAnswerIndex: 0,
            explanation: "「Quantum Supremacy」は、量子コンピュータが古典コンピュータよりも高速に特定の問題を解くことができる状態を指します。"
        ),
        QuizQuestion(
            question: "「CAP定理」で「C」は何を表しますか？",
            choices: [
                "Consistency",
                "Compatibility",
                "Concurrency",
                "Connectivity"
            ],
            correctAnswerIndex: 0,
            explanation: "CAP定理は、分散コンピューティングシステムにおいて「Consistency（一貫性）」、「Availability（可用性）」、「Partition tolerance（分断耐性）」の3つの特性の間でトレードオフが存在すると述べています。"
        ),
        QuizQuestion(
            question: "「DevOps」の主要な目的は何ですか？",
            choices: [
                "データベースのパフォーマンス最適化",
                "開発と運用の連携強化",
                "ソフトウェアのセキュリティ強化",
                "ユーザーインターフェースの改善"
            ],
            correctAnswerIndex: 1,
            explanation: "DevOpsは、ソフトウェアの開発（Dev）と運用（Ops）のプラクティスを統合し、コラボレーションと効率の向上を図ることを目的としています。"
        ),
        QuizQuestion(
            question: "「Blockchain」技術の主要な特徴は何ですか？",
            choices: [
                "中央集権化",
                "改ざん防止",
                "低いスケーラビリティ",
                "データの非永続性"
            ],
            correctAnswerIndex: 1,
            explanation: "Blockchainは、その不変性と改ざん防止の特性により知られています。一度ブロックチェーンにデータが追加されると、それを変更することは非常に困難です。"
        ),
        QuizQuestion(
            question: "「CIDR」の「CIDR」は何の略ですか？",
            choices: [
                "Classless Inter-Domain Routing",
                "Classful Inter-Domain Routing",
                "Classless Intra-Domain Routing",
                "Classful Intra-Domain Routing"
            ],
            correctAnswerIndex: 0,
            explanation: "CIDRはClassless Inter-Domain Routingの略で、IPアドレスを割り当てるための方法です。これにより、IPアドレスの使用がより柔軟になり、インターネットの成長に対応しやすくなりました。"
        ),
        QuizQuestion(
            question: "「メモリリーク」とは何を指しますか？",
            choices: [
                "プログラムが不要になったメモリ領域を解放しない状態",
                "メモリの物理的な故障",
                "データが意図せず外部に漏れ出る状態",
                "メモリが一定の閾値を超えたときにシステムがクラッシュする状態"
            ],
            correctAnswerIndex: 0,
            explanation: "メモリリークは、プログラムが不要になったメモリ領域を適切に解放しないことにより発生し、システムのパフォーマンスを低下させる可能性があります。"
        ),
        QuizQuestion(
            question: "「OAuth」とは何のためのプロトコルですか？",
            choices: [
                "電子メールの暗号化",
                "ファイル転送",
                "認証と認可",
                "ネットワークルーティング"
            ],
            correctAnswerIndex: 2,
            explanation: "OAuthは、ユーザーが第三者アプリケーションに対して認証および認可を提供できるようにするためのオープンスタンダードなプロトコルです。"
        ),
        QuizQuestion(
            question: "仮想マシンとコンテナの主な違いは何ですか？",
            choices: [
                "仮想マシンはハードウェアをエミュレートし、コンテナはOSレベルで実行されます",
                "コンテナはハードウェアをエミュレートし、仮想マシンはOSレベルで実行されます",
                "仮想マシンとコンテナは同じものです",
                "仮想マシンはクラウド専用、コンテナはオンプレミス専用です"
            ],
            correctAnswerIndex: 0,
            explanation: "仮想マシンはハードウェアをエミュレートし、完全なオペレーティングシステムを実行しますが、コンテナはオペレーティングシステムの一部を共有し、より軽量で効率的です。"
        ),
        QuizQuestion(
            question: "「REST」のAPIで「REST」は何の略ですか？",
            choices: [
                "Representational State Transfer",
                "Real-time Essential Software Technology",
                "Rapid Elastic Search Technology",
                "Reliable Electronic System Transmission"
            ],
            correctAnswerIndex: 0,
            explanation: "RESTはRepresentational State Transferの略で、シンプルでスケーラブルなウェブサービスを設計するためのアーキテクチャスタイルです。"
        ),
        QuizQuestion(
            question: "「Big O notation」で「O(n log n)」の計算複雑性はどのアルゴリズムでよく見られますか？",
            choices: [
                "バブルソート",
                "クイックソート",
                "線形探索",
                "バイナリサーチ"
            ],
            correctAnswerIndex: 1,
            explanation: "O(n log n)は、平均的な計算複雑性でクイックソートなどの効率的なソートアルゴリズムで見られます。"
        ),
        QuizQuestion(
            question: "デジタル署名を作成するのに一般的に使用される暗号化のタイプは何ですか？",
            choices: [
                "対称暗号化",
                "非対称暗号化",
                "ハッシュ関数",
                "ブロック暗号"
            ],
            correctAnswerIndex: 1,
            explanation: "デジタル署名では非対称暗号化が一般的に使用されます。公開鍵と秘密鍵のペアを使用してメッセージの真正性と完全性を確保します。"
        ),
        QuizQuestion(
            question: "「CAP定理」で「AP」は何を意味しますか？",
            choices: [
                "Availability and Partition Tolerance",
                "Atomicity and Partition Tolerance",
                "Availability and Performance",
                "Atomicity and Performance"
            ],
            correctAnswerIndex: 0,
            explanation: "CAP定理は、分散システムの基本的なトレードオフを説明するもので、「AP」は「Availability（可用性）」と「Partition Tolerance（パーティション耐性）」を意味します。"
        ),
        QuizQuestion(
            question: "Webアプリケーションのセキュリティで「XSS」は何の略ですか？",
            choices: [
                "Cross-Site Scripting",
                "Cross-System Security",
                "Cross-Site Security",
                "Cross-System Scripting"
            ],
            correctAnswerIndex: 0,
            explanation: "XSS（Cross-Site Scripting）は、攻撃者が悪意のあるスクリプトをウェブページに注入する攻撃です。ユーザーはそのページを表示する際にスクリプトが実行され、セキュリティが危険にさらされる可能性があります。"
        ),
        QuizQuestion(
            question: "データベースで「ACID」プロパティの「A」は何を表しますか？",
            choices: [
                "Atomicity",
                "Availability",
                "Associativity",
                "Authentication"
            ],
            correctAnswerIndex: 0,
            explanation: "ACIDプロパティの「A」は「Atomicity（原子性）」を表し、トランザクションが全部または全く実行されないことを保証します。"
        ),
        QuizQuestion(
            question: "ネットワークセキュリティで「DOS攻撃」は何を意味しますか？",
            choices: [
                "Denial Of Service",
                "Data Optimization Service",
                "Disk Operating System",
                "Data Output Stream"
            ],
            correctAnswerIndex: 0,
            explanation: "DOS攻撃（Denial Of Service）は、ネットワークリソースへのアクセスを妨害することを目的とした攻撃の一種です。"
        ),
        QuizQuestion(
            question: "REST API設計において、無状態性(Statelessness)とは何を意味しますか？",
            choices: [
                "各リクエストが他のリクエストと独立している",
                "サーバーがクライアントの状態を保持する",
                "データが暗号化されている",
                "データが圧縮されている"
            ],
            correctAnswerIndex: 0,
            explanation: "REST APIの無状態性(Statelessness)は、各リクエストが他のリクエストと独立しており、サーバーがクライアントの状態を保持しないことを意味します。"
        ),
        QuizQuestion(
            question: "「OAuth」は何のために使用されますか？",
            choices: [
                "暗号化",
                "認証と承認",
                "データベース管理",
                "ファイル圧縮"
            ],
            correctAnswerIndex: 1,
            explanation: "OAuthは、ユーザーの代わりに別のアプリケーションがリソースにアクセスするための安全な方法を提供する認証と承認のフレームワークです。"
        ),
        QuizQuestion(
            question: "「ビッグエンディアン」と「リトルエンディアン」の違いは何ですか？",
            choices: [
                "文字エンコーディングの違い",
                "データの圧縮方法の違い",
                "バイト順序の違い",
                "エラー検出方法の違い"
            ],
            correctAnswerIndex: 2,
            explanation: "「ビッグエンディアン」と「リトルエンディアン」はバイト順序が異なるコンピューターアーキテクチャを指します。ビッグエンディアンでは最も重要なバイトが最初に格納され、リトルエンディアンでは最も重要でないバイトが最初に格納されます。"
        ),
        QuizQuestion(
            question: "ブロックチェーンの「コンセンサスアルゴリズム」の主な目的は何ですか？",
            choices: [
                "データの暗号化",
                "トランザクションの承認と合意形成",
                "データベースのインデックス作成",
                "ファイルの圧縮"
            ],
            correctAnswerIndex: 1,
            explanation: "コンセンサスアルゴリズムは、ブロックチェーンネットワーク上のすべてのノードがトランザクションの正当性に同意するプロセスを指し、データの整合性とセキュリティを保つのに役立ちます。"
        ),
        QuizQuestion(
            question: "Linuxオペレーティングシステムにおいて、「chmod 755」コマンドは何を行いますか？",
            choices: [
                "ファイルを削除する",
                "ファイルのパーミッションを変更し、オーナーには読み書き実行の権限を、他のユーザーには読み込みと実行の権限を与える",
                "ファイルを圧縮する",
                "ネットワーク設定を変更する"
            ],
            correctAnswerIndex: 1,
            explanation: "「chmod 755」コマンドは、ファイルのパーミッションを変更し、オーナーには読み書き実行の権限を与え、グループと他のユーザーには読み込みと実行の権限を与えます。"
        ),
        QuizQuestion(
            question: "「Deadlock」または「デッドロック」とは何ですか？",
            choices: [
                "ディスクの障害",
                "プロセスまたはスレッドが互いにリソースの解放を待っている状態",
                "メモリの断片化",
                "ネットワークの遅延"
            ],
            correctAnswerIndex: 1,
            explanation: "デッドロックは、プロセスまたはスレッドが互いにリソースの解放を待っている状態を指し、これが原因でシステムが停止する可能性があります。"
        ),
        QuizQuestion(
            question: "「CAP定理」において、「C」は何を表しますか？",
            choices: [
                "Consistency（一貫性）",
                "Compression（圧縮）",
                "Concurrency（並行性）",
                "Connectivity（接続性）"
            ],
            correctAnswerIndex: 0,
            explanation: "CAP定理は、分散コンピューティングにおいて、一貫性（Consistency）、可用性（Availability）、およびパーティション耐性（Partition Tolerance）の三つの要素について説明しています。ここでの「C」は一貫性（Consistency）を表します。"
        ),
        QuizQuestion(
            question: "「Kubernetes」は何を管理するためのプラットフォームですか？",
            choices: [
                "データベース",
                "コンテナ",
                "ネットワーク",
                "ファイルシステム"
            ],
            correctAnswerIndex: 1,
            explanation: "Kubernetesはコンテナオーケストレーションプラットフォームであり、コンテナのデプロイメント、スケーリング、および運用を自動化するために使用されます。"
        ),
        QuizQuestion(
            question: "「Quantum Computing」で使用される「Qubit」は何を表しますか？",
            choices: [
                "クエリビット",
                "量子ビット",
                "クイックビット",
                "クオリティビット"
            ],
            correctAnswerIndex: 1,
            explanation: "Qubit（量子ビット）は量子コンピューティングにおいて、0と1の両方の状態を同時に取ることができるビットを指します。"
        ),
        QuizQuestion(
            question: "「SHA-256」は何の略ですか？",
            choices: [
                "Secure Hash Algorithm 256-bit",
                "Symmetric Hash Algorithm 256-bit",
                "Secure Hash Allocation 256-byte",
                "Symmetric Hash Allocation 256-byte"
            ],
            correctAnswerIndex: 0,
            explanation: "SHA-256はSecure Hash Algorithm 256-bitの略であり、256ビットのハッシュ値を生成する暗号学的ハッシュ関数です。"
        ),
        QuizQuestion(
            question: "「Polymorphism」はオブジェクト指向プログラミングのどの概念を指しますか？",
            choices: [
                "変数の複数の型を持つこと",
                "コードの隠蔽",
                "複数の形態を持つこと",
                "メモリの効率的な利用"
            ],
            correctAnswerIndex: 2,
            explanation: "ポリモーフィズムはオブジェクトが複数の形態を持つ能力を指し、同じインターフェースで異なるデータタイプやクラスのオブジェクトを操作できるようにします。"
        ),
        QuizQuestion(
            question: "「Big O Notation」で「O(n^2)」は何を表しますか？",
            choices: [
                "定数時間",
                "線形時間",
                "二次時間",
                "対数時間"
            ],
            correctAnswerIndex: 2,
            explanation: "「O(n^2)」は二次時間の計算複雑性を表し、アルゴリズムの実行時間が入力サイズの二乗に比例して増加することを意味します。"
        ),
        QuizQuestion(
            question: "「Blue Screen of Death (BSOD)」はどのオペレーティングシステムと関連していますか？",
            choices: [
                "Linux",
                "Windows",
                "macOS",
                "Android"
            ],
            correctAnswerIndex: 1,
            explanation: "Blue Screen of Death (BSOD)は、Windowsオペレーティングシステムにおいて、重大なエラーが発生したときに表示されるエラー画面です。"
        ),
        QuizQuestion(
            question: "「REST」のフルフォームは何ですか？",
            choices: [
                "Representational State Transfer",
                "Rapid Elastic Search Technology",
                "Real-time Secure Transfer",
                "Relational State Transfer"
            ],
            correctAnswerIndex: 0,
            explanation: "RESTはRepresentational State Transferの略で、分散システムにおいてクライアントとサーバー間の通信を行うためのアーキテクチャスタイルです。"
        ),
        QuizQuestion(
            question: "「DevOps」の主な目標は何ですか？",
            choices: [
                "開発と運用の分離",
                "ソフトウェアの品質向上",
                "開発と運用の連携強化",
                "開発サイクルの延長"
            ],
            correctAnswerIndex: 2,
            explanation: "DevOpsは、ソフトウェア開発（Dev）とIT運用（Ops）のプラクティスを統合することを目指しており、開発からリリースまでのプロセスを迅速かつ効率的にすることを目標としています。"
        ),
        QuizQuestion(
            question: "暗号通貨のブロックチェーンにおいて、新しいトランザクションを追加するプロセスを何と言いますか？",
            choices: [
                "ハッシング",
                "マイニング",
                "トークニング",
                "エンクリプティング"
            ],
            correctAnswerIndex: 1,
            explanation: "ブロックチェーンにおけるマイニングは、新しいトランザクションをブロックに追加し、ネットワーク全体で合意を形成するプロセスを指します。"
        ),
        QuizQuestion(
            question: "プログラミングにおいて、「Deadlock」は何を指しますか？",
            choices: [
                "コンパイルエラー",
                "実行時エラー",
                "プロセスやスレッドが永遠にブロックされる状態",
                "メモリリーク"
            ],
            correctAnswerIndex: 2,
            explanation: "デッドロックは、二つ以上のプロセスやスレッドが互いにリソースを持っているため、永遠にブロックされる状態を指します。"
        ),
        QuizQuestion(
            question: "「SQL Injection」攻撃とは何ですか？",
            choices: [
                "データベースに不正なSQLクエリを実行させる攻撃",
                "システムにマルウェアを注入する攻撃",
                "ネットワークパケットを改ざんする攻撃",
                "ユーザーのセッションを乗っ取る攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "SQLインジェクション攻撃は、攻撃者が不正なSQLクエリをデータベースに送信して、データを盗んだり、データベースを損傷したりする攻撃です。"
        ),
        QuizQuestion(
            question: "「Kubernetes」は何のために使用されますか？",
            choices: [
                "ウェブブラウジング",
                "コンテナオーケストレーション",
                "ソフトウェア開発",
                "ネットワークセキュリティ"
            ],
            correctAnswerIndex: 1,
            explanation: "Kubernetesはコンテナオーケストレーションツールであり、コンテナ化されたアプリケーションのデプロイ、スケーリング、および運用を自動化するために使用されます。"
        ),
        QuizQuestion(
            question: "「CAP定理」で「C」は何を表しますか？",
            choices: [
                "Consistency",
                "Concurrency",
                "Computation",
                "Connectivity"
            ],
            correctAnswerIndex: 0,
            explanation: "CAP定理では、「C」はConsistencyを表し、全てのノードが同じ時点で同じデータを持っていることを指します。"
        ),
        QuizQuestion(
            question: "「ビッグオー記法」において、アルゴリズムの実行時間が入力サイズnに対して線形に増加する場合、その複雑さをどのように表しますか？",
            choices: [
                "O(1)",
                "O(log n)",
                "O(n)",
                "O(n^2)"
            ],
            correctAnswerIndex: 2,
            explanation: "ビッグオー記法において、O(n)はアルゴリズムの実行時間または空間が入力サイズnに対して線形に増加することを表します。"
        ),
        QuizQuestion(
            question: "「HTTP/2」の主要な利点は何ですか？",
            choices: [
                "暗号化の強化",
                "単一のTCP接続を通じた多重化",
                "データの圧縮",
                "すべての上記"
            ],
            correctAnswerIndex: 1,
            explanation: "HTTP/2の主要な利点の一つは単一のTCP接続を通じて複数のリクエストとレスポンスを同時に送受信できる多重化です。これにより、ウェブページのロード時間が大幅に改善されます。"
        ),
        QuizQuestion(
            question: "「OAuth」は何のために使用されますか？",
            choices: [
                "データベースの管理",
                "オペレーティングシステム",
                "認可と認証",
                "ファイル圧縮"
            ],
            correctAnswerIndex: 2,
            explanation: "OAuthは、ユーザーが第三者のアプリケーションに対して特定のリソースへのアクセスを許可するための開放規格です。これにより、ユーザーはそのサービスの認証情報を直接第三者に提供することなく、サービスを利用できます。"
        ),
        QuizQuestion(
            question: "「REST」アーキテクチャにおいて、クライアントとサーバー間の通信を状態のない（stateless）とはどういう意味ですか？",
            choices: [
                "サーバーはクライアントの状態を保存しない",
                "クライアントはサーバーの状態を保存しない",
                "通信は暗号化されていない",
                "通信は非同期である"
            ],
            correctAnswerIndex: 0,
            explanation: "状態のない通信では、サーバーはクライアントの状態を保存しません。各リクエストは独立しており、過去のリクエストからの情報を必要としません。"
        ),
        QuizQuestion(
            question: "「Docker」において、コンテナ内のプロセスがホストOS上で直接実行される理由は何ですか？",
            choices: [
                "ハードウェアの仮想化を使用するため",
                "パフォーマンスを向上させるため",
                "セキュリティを強化するため",
                "ネットワーキングを簡素化するため"
            ],
            correctAnswerIndex: 1,
            explanation: "Dockerコンテナは、パフォーマンスの向上とオーバーヘッドの削減を目的として、ホストOS上で直接プロセスを実行します。これにより、仮想マシンに比べて軽量で効率的になります。"
        ),
        QuizQuestion(
            question: "「カーネル」はオペレーティングシステムのどの部分を指しますか？",
            choices: [
                "ユーザーインターフェイス",
                "デバイスドライバ",
                "コア機能と管理",
                "アプリケーションソフトウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "カーネルはオペレーティングシステムの中心的な部分で、ハードウェアとソフトウェアの間の通信を管理し、システムリソースを管理します。"
        ),
        QuizQuestion(
            question: "「デッドロック」とは何ですか？",
            choices: [
                "メモリリーク",
                "プログラムのクラッシュ",
                "プロセス間の相互依存による停止",
                "ディスクの断片化"
            ],
            correctAnswerIndex: 2,
            explanation: "デッドロックは、プロセス間でリソースが相互に依存している状態で、それぞれが他のプロセスが持っているリソースを待っているために進行が停止してしまう状態を指します。"
        ),
        QuizQuestion(
            question: "「ブロックチェーン」技術の主な特徴は何ですか？",
            choices: [
                "集中型データベース",
                "改ざん防止",
                "データの非暗号化",
                "高速トランザクション"
            ],
            correctAnswerIndex: 1,
            explanation: "ブロックチェーンは、データの改ざんを防ぐために設計されており、一度書き込まれたデータは後から変更することが非常に難しいです。"
        ),
        QuizQuestion(
            question: "「CIDR」表記において、「/24」は何を意味しますか？",
            choices: [
                "サブネットマスク 255.255.255.0",
                "256個のIPアドレス",
                "サブネット内の254個の使用可能なIPアドレス",
                "すべての上記"
            ],
            correctAnswerIndex: 3,
            explanation: "/24（CIDR表記）はサブネットマスク255.255.255.0を意味し、これにより256個のIPアドレス（サブネット内で使用可能なIPアドレスは254個）が利用可能になります。"
        ),
        QuizQuestion(
            question: "「DevOps」の主な目標は何ですか？",
            choices: [
                "ソフトウェアの開発と運用の分離",
                "ソフトウェアの開発サイクルの加速",
                "ソフトウェアテストの省略",
                "古い技術の維持"
            ],
            correctAnswerIndex: 1,
            explanation: "DevOpsはソフトウェアの開発（Dev）と運用（Ops）のプロセスを統合し、コラボレーションを促進することで、ソフトウェアの開発サイクルを速めることを目的としています。"
        )
    ]

    @State private var shuffledQuizList: [QuizQuestion]
    private var authManager = AuthManager()
    private var audioManager = AudioManager.shared


    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _shuffledQuizList = State(initialValue: QuizGodList.shuffled())
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        QuizView(quizzes: shuffledQuizList, quizLevel: .god, authManager: authManager,audioManager: audioManager,isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizGodList_Previews: PreviewProvider {
    static var previews: some View {
        QuizGodList(isPresenting: .constant(false))
    }
}

