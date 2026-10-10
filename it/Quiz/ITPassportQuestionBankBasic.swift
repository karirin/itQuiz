import Foundation

extension ITPassportQuestionBank {
    static let basic: [QuizQuestion] = [
        QuizQuestion(
            id: "it.81badc8090217681c8fe2458",
            question: "コンピュータウイルスの感染経路として最も一般的なものは？",
            choices: [
                "電源ケーブル",
                "キーボード",
                "モニター",
                "Eメールの添付ファイル"
            ],
            correctAnswerIndex: 3,
            explanation: " Eメールの添付ファイルは、コンピュータウイルスの感染経路として非常に一般的です。不明な送信元からのメールの添付ファイルは開かないよう注意が必要です。"
        ),

        QuizQuestion(
            id: "it.aa7dcb0efe93a0a3959cc8f1",
            question: "クラウドコンピューティングのサービスモデルで、インフラストラクチャを提供するものは？",
            choices: [
                "IaaS",
                "FaaS",
                "PaaS",
                "SaaS"
            ],
            correctAnswerIndex: 0,
            explanation: "IaaS（Infrastructure as a Service）は、インフラストラクチャを提供するクラウドサービスモデルです。"
        ),

        QuizQuestion(
            id: "it.ab20d3176ad946f55a8769fa",
            question: "プロジェクト管理手法で、タスク間の依存関係を線で結んで表現するものは？",
            choices: [
                "PERT図",
                "フローチャート",
                "マトリックス図",
                "ガントチャート"
            ],
            correctAnswerIndex: 0,
            explanation: "PERT図は、タスク間の依存関係を線で結んで表現するプロジェクト管理手法です。"
        ),

        QuizQuestion(
            id: "it.0abc6c2330db01481a7bb874",
            question: "情報セキュリティのリスクを評価する際、リスクの大きさを算出するための要素は？",
            choices: [
                "脅威 x 脆弱性",
                "脅威 + 脆弱性",
                "脅威 / 脆弱性",
                "脅威 - 脆弱性"
            ],
            correctAnswerIndex: 0,
            explanation: "情報セキュリティのリスクの大きさは、「脅威」と「脆弱性」の積によって算出されます。"
        ),

        QuizQuestion(
            id: "it.07f62dce63db4583f3e89b5f",
            question: "データベースで、一意にレコードを特定するためのキーを何というか？",
            choices: [
                "参照キー",
                "外部キー",
                "主キー",
                "候補キー"
            ],
            correctAnswerIndex: 2,
            explanation: "主キーは、データベースのテーブル内でレコードを一意に特定するためのキーです。"
        )
        ,

        QuizQuestion(
            id: "it.4a7418a02c522fca1c34f5fc",
            question: "システム開発のライフサイクルの中で、システムが正しく動作するかを確認するフェーズは？",
            choices: [
                "実装",
                "要件定義",
                "設計",
                "テスト"
            ],
            correctAnswerIndex: 3,
            explanation: "システム開発のライフサイクルにおいて、システムが正しく動作するかを確認するフェーズは「テスト」フェーズです。"
        ),

        QuizQuestion(
            id: "it.de2888e2b0bc37bdc0d56492",
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
            id: "it.3c9b612efa5fc6f730c5679d",
            question: "ビジネスモデルで、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うモデルは？",
            choices: [
                "B2B",
                "CRM",
                "C2C",
                "B2C"
            ],
            correctAnswerIndex: 1,
            explanation: "CRM（Customer Relationship Management）は、顧客との長期的な関係を築くことを重視し、継続的なサービス提供を行うビジネスモデルです。"
        ),

        QuizQuestion(
            id: "it.d82e979ddb1f554dcbf2d769",
            question: "システムのバックアップ方法で、最後のフルバックアップ以降の変更分だけを保存する方法は？",
            choices: [
                "フルバックアップ",
                "差分バックアップ",
                "ミラーバックアップ",
                "増分バックアップ"
            ],
            correctAnswerIndex: 1,
            explanation: "最後のフルバックアップ以降の変更分だけを保存する方法を「差分バックアップ」といいます。"
        ),

        QuizQuestion(
            id: "it.eaa5e5f72caf39d82e4d6b61",
            question: "ソフトウェアのライセンスで、ソースコードが公開され、自由に改変や再配布が許可されているものは？",
            choices: [
                "オープンソース",
                "シェアウェア",
                "フリーウェア",
                "クローズドソース"
            ],
            correctAnswerIndex: 0,
            explanation: "ソースコードが公開され、自由に改変や再配布が許可されているソフトウェアのライセンスを「オープンソース」といいます。"
        ),

        QuizQuestion(
            id: "it.23ac1d379e7784f0a8208306",
            question: "ネットワークのアドレスで、インターネット上のコンピュータやネットワークを一意に識別するための番号は？",
            choices: [
                "URL",
                "IPアドレス",
                "DNS",
                "MACアドレス"
            ],
            correctAnswerIndex: 1,
            explanation: "インターネット上のコンピュータやネットワークを一意に識別するための番号は「IPアドレス」といいます。"
        ),

        QuizQuestion(
            id: "it.27e11ba39a8c2118a862fd96",
            question: "プログラミングで、同じ処理を繰り返し実行する制御構造は？",
            choices: [
                "ループ",
                "分岐",
                "スイッチ",
                "ジャンプ"
            ],
            correctAnswerIndex: 0,
            explanation: "同じ処理を繰り返し実行する制御構造を「ループ」といいます。"
        ),

        QuizQuestion(
            id: "it.a26f33f224d68e625f233a40",
            question: "データベースのトランザクション処理で、一連の処理が全て完了するか、あるいは全てなかったことにする性質は？",
            choices: [
                "原子性",
                "一貫性",
                "持続性",
                "分離性"
            ],
            correctAnswerIndex: 0,
            explanation: "一連の処理が全て完了するか、あるいは全てなかったことにする性質を「原子性」といいます。"
        ),

        QuizQuestion(
            id: "it.3420dec24a53ddd8da5516b4",
            question: "情報セキュリティの方針やルールを組織全体に明確に伝えるための文書は？",
            choices: [
                "情報セキュリティポリシー",
                "SLA",
                "SOP",
                "NDA"
            ],
            correctAnswerIndex: 0,
            explanation: "情報セキュリティの3つの基本的な要素として、機密性、完全性に続くものは「可用性」といいます。"
        ),

        QuizQuestion(
            id: "it.a855ec95cde5007008920e9a",
            question: "システム開発の手法で、短い期間を設けて繰り返し開発を行う方法は？",
            choices: [
                "スパイラル",
                "スクラム",
                "カンバン",
                "ウォーターフォール"
            ],
            correctAnswerIndex: 1,
            explanation: "短い期間を設けて繰り返し開発を行う方法を「スクラム」といいます。"
        ),
        QuizQuestion(
            id: "it.e70f710e4ed251066757704b",
            question: "情報セキュリティの3つの基本的な要素として、機密性、完全性に続くものは何か？",
            choices: [
                "可用性",
                "可視性",
                "可搬性",
                "可変性"
            ],
            correctAnswerIndex: 0,
            explanation: "情報セキュリティポリシーは、組織の情報セキュリティの方針やルールを明確に伝えるための文書です。このポリシーは、機密性、完全性、および可用性を保護するための基本的な指針と規則を提供します。"
        ),

        QuizQuestion(
            id: "it.c3024902570d6e8df001e717",
            question: "ウェブページの閲覧時に、サーバーとクライアント間で情報のやり取りを暗号化するためのプロトコルは何か？",
            choices: [
                "SMTP",
                "HTTPS",
                "FTP",
                "HTTP"
            ],
            correctAnswerIndex: 1,
            explanation: "サーバーとクライアント間で情報のやり取りを暗号化するためのプロトコルは「HTTPS」といいます。"
        ),

        QuizQuestion(
            id: "it.60103acfaf037011b9bf6df7",
            question: "情報システムの開発手法で、繰り返し開発を行いながら、少しずつシステムを成熟させていく方法を何というか？",
            choices: [
                "ウォーターフォールモデル",
                "スパイラルモデル",
                "アジャイルモデル",
                "V字モデル"
            ],
            correctAnswerIndex: 1,
            explanation: "繰り返し開発を行いながら、少しずつシステムを成熟させていく方法を「スパイラルモデル」といいます。"
        ),

        QuizQuestion(
            id: "it.8c155749a100a9723547565f",
            question: "データベースの中で、データの重複を避けるために、データを複数のテーブルに分割することを何というか？",
            choices: [
                "分散",
                "最適化",
                "集約",
                "正規化"
            ],
            correctAnswerIndex: 3,
            explanation: "データの重複を避けるために、データを複数のテーブルに分割することを「正規化」といいます。"
        ),
            QuizQuestion(
            id: "it.e3948a82f84bcdb4f5466b56",
                question: "クラウドコンピューティングの3つの主なサービスモデルの1つでないものは？",
                choices: ["IaaS", "CaaS", "SaaS", "PaaS"],
                correctAnswerIndex: 1,
                explanation: "クラウドコンピューティングの3つの主なサービスモデルはIaaS、PaaS、およびSaaSです。CaaSは含まれません。"
            ),
            QuizQuestion(
            id: "it.0e0a3ed558ec7963237f640d",
                question: "システム開発のライフサイクルモデルの一つで、反復的に製品を改善していくモデルは何か？",
                choices: ["スパイラルモデル", "ウォーターフォールモデル", "Vモデル", "アジャイルモデル"],
                correctAnswerIndex: 0,
                explanation: "スパイラルモデルは、反復的に製品を改善していく開発モデルです。"
            ),
            QuizQuestion(
            id: "it.43419b8ed93221f89866899d",
                question: "プロジェクト管理で使用される、タスクの進捗を視覚的に表すツールは？",
                choices: ["PERT Chart", "Flow Chart", "Network Diagram", "Gantt Chart"],
                correctAnswerIndex: 3,
                explanation: "Gantt Chartは、タスクの進捗を視覚的に表すツールの一つです。"
            ),
            QuizQuestion(
            id: "it.7fc8a018343e1ff67f139c1c",
                question: "情報セキュリティのCIAトライアドの「I」は何を指すか？",
                choices: ["Infrastructure", "Information", "Integrity", "Internet"],
                correctAnswerIndex: 2,
                explanation: "CIAトライアドの「I」はIntegrity（完全性）を指します。"
            ),
            QuizQuestion(
            id: "it.7a978fbdaee98b4f8bd25ba1",
                question: "ソフトウェアのバージョン管理システムの一つは？",
                choices: ["Git", "Kit", "Sit", "Bit"],
                correctAnswerIndex: 0,
                explanation: "Gitは、ソフトウェアのバージョン管理システムの一つです。"
            ),
            QuizQuestion(
            id: "it.619771b87c50aca2cf10c15d",
                question: "インターネットの通信プロトコルは？",
                choices: ["HTTP", "FTP", "All of the above", "TCP/IP"],
                correctAnswerIndex: 2,
                explanation: "HTTP, FTP, TCP/IP など、すべてがインターネットの通信プロトコルです。"
            ),
            QuizQuestion(
            id: "it.5c52b7c11f037fedb0696c30",
                question: "オペレーティングシステムの一つは？",
                choices: ["Gates", "Walls", "Doors", "Windows"],
                correctAnswerIndex: 3,
                explanation: "Windowsは一般的なオペレーティングシステムの一つです。"
            ),
            QuizQuestion(
            id: "it.8824f83719d100bf8511c933",
                question: "インターネットでの安全な通信を確保するプロトコルは？",
                choices: ["HTTP", "HTTPT", "HTTPX", "HTTPS"],
                correctAnswerIndex: 3,
                explanation: "HTTPSは、安全な通信を確保するためのプロトコルです。"
            ),
            QuizQuestion(
            id: "it.bb3762f520ade34470835179",
                question: "データベース管理システム(DBMS)の一つは？",
                choices: ["MySQL", "MyTriangle", "MyCircle", "MySquare"],
                correctAnswerIndex: 0,
                explanation: "MySQLは、リレーショナルデータベース管理システムの一つです。"
            ),
            QuizQuestion(
            id: "it.9478a27252f92d4233341bbb",
                question: "オブジェクト指向プログラミングの4つの主な特性の一つでないものは？",
                choices: ["多態性", "継承", "カプセル化", "分割"],
                correctAnswerIndex: 3,
                explanation: "オブジェクト指向プログラミングの主な特性には、継承、カプセル化、および多態性が含まれますが、分割は含まれません。"
            ),
            QuizQuestion(
            id: "it.c85953b87ec71024eaf78ffe",
                question: "機械学習で用いられることが多いプログラミング言語の一つは？",
                choices: ["Cobra", "Viper", "Python", "Mamba"],
                correctAnswerIndex: 2,
                explanation: "Pythonは、広く使用されているプログラミング言語の一つです。"
            ),
            QuizQuestion(
            id: "it.3294c43ce36ded2bd5a4823e",
                question: "ソフトウェアテストの種類の一つは？",
                choices: ["グループテスト", "セグメントテスト", "ブロックテスト", "ユニットテスト"],
                correctAnswerIndex: 3,
                explanation: "ユニットテストは、ソフトウェアの個々の部分をテストするプロセスです。"
            ),
            QuizQuestion(
            id: "it.341b7343e87cb24bcbf18870",
                question: "ソフトウェア開発手法の一つは？",
                choices: ["Run", "Walk", "Scrum", "Jog"],
                correctAnswerIndex: 2,
                explanation: "Scrumは、アジャイル開発の一形態で、イテラティブかつインクリメンタルな開発手法です。"
            ),
            QuizQuestion(
            id: "it.caa2bf38364d73317e948206",
                question: "ウェブ開発で使用されるマークアップ言語は？",
                choices: ["HTMLL", "HTML", "HTMML", "HTXL"],
                correctAnswerIndex: 1,
                explanation: "HTMLは、ウェブページを作成するための標準的なマークアップ言語です。"
            ),
            QuizQuestion(
            id: "it.ede0ee2c66eecf7ff839cabc",
                question: "インターネットのドメイン名の一部として使用されるものは？",
                choices: [".net", ".com", ".org", "All of the above"],
                correctAnswerIndex: 3,
                explanation: ".com, .net, .org は、インターネットのドメイン名の一部として使用されるトップレベルドメインです。"
            ),
            QuizQuestion(
            id: "it.5aaeb7252dc5b44331bd48d6",
                question: "ネットワークのトポロジの一つは？",
                choices: ["ツリー", "メッシュ", "All of the above", "スター"],
                correctAnswerIndex: 2,
                explanation: "スター、ツリー、メッシュは、ネットワークのトポロジの種類です。"
            ),
            QuizQuestion(
            id: "it.666d987aa95909261d2675a2",
                question: "ソフトウェアライセンスの一つは？",
                choices: ["APL", "CPL", "GPL", "BPL"],
                correctAnswerIndex: 2,
                explanation: "GPLは、ソフトウェアを自由に使用、修正、および配布することを許可するライセンスです。"
            ),
            QuizQuestion(
            id: "it.257a5d7b75327587422c62f8",
                question: "ウェブブラウザの一つは？",
                choices: ["Chrome", "Bronze", "Gold", "Silver"],
                correctAnswerIndex: 0,
                explanation: "Chromeは、Googleによって開発されたウェブブラウザです。"
            ),
            QuizQuestion(
            id: "it.102fba1d175643654c065507",
                question: "ウェブ開発で使用されるスクリプト言語の一つは？",
                choices: ["JavaNote", "JavaPage", "JavaScript", "JavaBook"],
                correctAnswerIndex: 2,
                explanation: "JavaScriptは、ウェブページに対してインタラクティブな機能を追加するために使用されるプログラミング言語です。"
            ),
            QuizQuestion(
            id: "it.1b785832744b25b2f2d05cc3",
                question: "コンピュータネットワークの標準プロトコルの集合は何と呼ばれるか？",
                choices: ["Internet Protocol Suite", "Internet Protocol Group", "Internet Protocol Set", "Internet Protocol Bunch"],
                correctAnswerIndex: 0,
                explanation: "Internet Protocol Suiteは、インターネットプロトコルの集合を指します。"
            ),
                         
        QuizQuestion(
            id: "it.6f522001f0b558b39f619e56",
               question: "ウェブサイトを作成する際に、構造を定義するために使用される言語は何か？",
               choices: [
                   "HTML",
                   "PHP",
                   "JavaScript",
                   "CSS"
               ],
               correctAnswerIndex: 0,
               explanation: "HTML（HyperText Markup Language）は、ウェブページの構造を定義するために使用される標準的なマークアップ言語です。"
           ),
           QuizQuestion(
            id: "it.01d7ab0a9a92a7cc2eec4b76",
               question: "コンピュータネットワークにおける「MACアドレス」の主な目的は何か？",
               choices: [
                   "インターネット接続のセキュリティを強化する",
                   "ネットワーク上のデバイスを物理的に識別する",
                   "デバイスの物理的な位置を特定する",
                   "ネットワーク上のデバイス間のデータ転送速度を制御する"
               ],
               correctAnswerIndex: 1,
               explanation: "MACアドレス（Media Access Control Address）は、ネットワーク上のデバイスを物理的に識別するための一意の識別子です。"
           ),
           QuizQuestion(
            id: "it.4f686c47ba00e58e5e08157d",
               question: "ウェブ開発において、クライアントサイドスクリプトを実行するために主に使用される言語は何か？",
               choices: [
                   "C++",
                   "Python",
                   "Java",
                   "JavaScript"
               ],
               correctAnswerIndex: 3,
               explanation: "JavaScriptは、ウェブブラウザ内でクライアントサイドスクリプトを実行するために広く使用されているプログラミング言語です。"
           ),
           QuizQuestion(
            id: "it.05bd0bea3b194c62a0efef28",
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
            id: "it.aab535158107fb9e196584fd",
               question: "インターネット上で安全に情報を送受信するために使用されるプロトコルは何か？",
               choices: [
                   "FTP",
                   "SMTP",
                   "HTTP",
                   "HTTPS"
               ],
               correctAnswerIndex: 3,
               explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、SSL/TLSによる暗号化を利用してインターネット上でデータを安全に送受信するためのプロトコルです。"
           ),
           QuizQuestion(
            id: "it.1cd31fd38da0d10a9c60f567",
               question: "ネットワークセキュリティで使用される「ファイアウォール」とは何をする装置またはソフトウェアか？",
               choices: [
                   "不正アクセスを防ぎ、ネットワークへの入退出を管理する",
                   "インターネットの速度を向上させる",
                   "データのバックアップを取る",
                   "ウイルスを検出して除去する"
               ],
               correctAnswerIndex: 0,
               explanation: "ファイアウォールは、不正アクセスからネットワークを保護し、許可された通信のみを通過させるセキュリティ装置またはソフトウェアです。"
           ),
           QuizQuestion(
            id: "it.b92a26ef4ed49bd637e25eb2",
               question: "オブジェクト指向プログラミングにおいて、複数の基底クラスから継承を行うことを何というか？",
               choices: [
                   "多重継承",
                   "エンカプセレーション",
                   "インターフェース",
                   "ポリモーフィズム"
               ],
               correctAnswerIndex: 0,
               explanation: "多重継承は、一つのクラスが複数の基底クラスから継承を行うオブジェクト指向プログラミングの特徴です。"
           ),
           QuizQuestion(
            id: "it.1a488a34586b65aeedfcd867",
               question: "コンピュータプログラムにおいて、エラーが発生した際にプログラムの実行を安全に停止させるための機構は何か？",
               choices: [
                   "マクロ",
                   "例外処理",
                   "ループ",
                   "コールバック"
               ],
               correctAnswerIndex: 1,
               explanation: "例外処理は、エラーが発生した際にプログラムの実行を安全に制御し、適切に処理するためのプログラミングの機構です。"
           ),
           QuizQuestion(
            id: "it.e4a9438a4067dc3fdf302b2b",
               question: "Webページのアドレスを指定するために使用されるテキストは何か？",
               choices: [
                   "DNS",
                   "IPアドレス",
                   "URI",
                   "URL"
               ],
               correctAnswerIndex: 3,
               explanation: "URL（Uniform Resource Locator）は、Webページのアドレスを指定するために使用されるテキスト形式のアドレスです。"
           ),
           QuizQuestion(
            id: "it.c8c98eb6449502ad68a4eaed",
               question: "プログラミングにおいて、同じ種類のデータを連続して格納するデータ構造は何か？",
               choices: [
                   "リスト",
                   "マップ",
                   "セット",
                   "配列"
               ],
               correctAnswerIndex: 3,
               explanation: "配列は、同じ種類のデータを連続して格納するための基本的なデータ構造で、固定されたサイズを持ちます。"
           ),
           QuizQuestion(
            id: "it.45967404aefc1e7f1b681692",
               question: "ソフトウェア開発における「リファクタリング」とは何か？",
               choices: [
                   "ソフトウェアのバグを修正するプロセス",
                   "ソフトウェアの機能を追加するプロセス",
                   "コードの可読性や構造を改善するプロセス",
                   "コードのパフォーマンスを向上させるプロセス"
               ],
               correctAnswerIndex: 2,
               explanation: "リファクタリングは、ソフトウェアの外部の振る舞いを変えることなく、内部の構造や可読性を改善するプロセスです。"
           ),
           QuizQuestion(
            id: "it.b879dde0b1f86033cc6a38c4",
               question: "「MVC」とは何の略称か？",
               choices: [
                   "Multiple Vector Configurations",
                   "Main Virtual Computer",
                   "Model View Controller",
                   "Managed Virtual Connectivity"
               ],
               correctAnswerIndex: 2,
               explanation: "MVCはModel View Controllerの略で、ソフトウェア開発におけるアーキテクチャパターンの一つです。"
           ),
           QuizQuestion(
            id: "it.4b2669ef16cfa0b40ec8e2b2",
               question: "インターネット通信において「SSL」とは何のために使われるか？",
               choices: [
                   "ウェブページのスピードアップ",
                   "ソーシャルメディアの統合",
                   "検索エンジンの最適化",
                   "データの暗号化"
               ],
               correctAnswerIndex: 3,
               explanation: "SSL（Secure Sockets Layer）は、インターネット上でデータを安全に送受信するために使用される暗号化プロトコルです。"
           ),
           QuizQuestion(
            id: "it.8ab8084ef3651cfa755c5b51",
               question: "「クラウドコンピューティング」において、ユーザーが自分のプラットフォームやアプリケーションをホストできるサービスモデルは何か？",
               choices: [
                   "SaaS",
                   "PaaS",
                   "IaaS",
                   "FaaS"
               ],
               correctAnswerIndex: 1,
               explanation: "PaaS（Platform as a Service）は、開発者がアプリケーションを開発、実行、管理できるプラットフォームやツールを提供するクラウドサービスモデルです。"
           ),
           QuizQuestion(
            id: "it.3601b7f54a221cfdb53bc322",
               question: "ソフトウェア開発において、「アジャイル」とは何か？",
               choices: [
                   "短いサイクルでの繰り返しにより柔軟に開発を進める方法",
                   "開発プロセスを一度に完成させる方法",
                   "開発プロジェクトを長期間にわたって計画する方法",
                   "コードの量を最小限に抑えるプログラミングスタイル"
               ],
               correctAnswerIndex: 0,
               explanation: "アジャイル開発は、変更に対応しやすい柔軟な開発プロセスを可能にする方法論で、短いサイクルでの繰り返しを特徴とします。"
           ),
           QuizQuestion(
            id: "it.46d9daa20a34cdb646aaf849",
               question: "インターネットプロトコルスイートのうち、エンドツーエンドのデータ伝送を担う層はどれか？",
               choices: [
                   "ネットワークインターフェース層",
                   "アプリケーション層",
                   "トランスポート層",
                   "インターネット層"
               ],
               correctAnswerIndex: 2,
               explanation: "トランスポート層は、エンドツーエンドでのデータ伝送とデータフローの制御を担当する層です。"
           ),
           QuizQuestion(
            id: "it.1895f660d8afb4fcf7c0be5b",
               question: "ウェブページのコンテンツを動的に更新するために使われる技術は何か？",
               choices: [
                   "PHP",
                   "JavaScript",
                   "CSS",
                   "HTML"
               ],
               correctAnswerIndex: 1,
               explanation: "JavaScriptは、クライアントサイドでウェブページのコンテンツを動的に更新するために使用されるプログラミング言語です。"
           ),
           QuizQuestion(
            id: "it.c7b7a3e8693a7cef93604f53",
               question: "コンピュータネットワークにおいて、複数のネットワークを接続する装置は何か？",
               choices: [
                   "ブリッジ",
                   "ルーター",
                   "ハブ",
                   "スイッチ"
               ],
               correctAnswerIndex: 1,
               explanation: "ルーターは、異なるネットワーク間でデータパケットを転送し、ネットワークを接続する装置です。"
           ),
           QuizQuestion(
            id: "it.e25022af0602c6d3b86c92f5",
               question: "データベースの正規化において、非効率的なデータの重複を排除し、データ構造を最適化する目的は何か？",
               choices: [
                   "データのセキュリティを向上させる",
                   "クエリのパフォーマンスを向上させる",
                   "データの整合性を保つ",
                   "すべての上記"
               ],
               correctAnswerIndex: 3,
               explanation: "データベースの正規化は、データの整合性を保ち、セキュリティを向上させ、クエリのパフォーマンスを向上させることを目的としています。"
           ),
           QuizQuestion(
            id: "it.8efc160ed3a3ee032865a386",
               question: "ウェブ開発において、動的コンテンツの生成によく使用されるプログラミング言語はどれか？",
               choices: [
                   "HTML",
                   "PHP",
                   "JavaScript",
                   "CSS"
               ],
               correctAnswerIndex: 1,
               explanation: "PHPはサーバーサイドで動作し、動的なウェブページの生成に広く使用されるプログラミング言語です。"
           ),
           QuizQuestion(
            id: "it.31aa6c782932518cdc62b846",
               question: "コンピュータネットワークにおける「ファイアウォール」の主な目的は何か？",
               choices: [
                   "データのバックアップ",
                   "インターネット速度の向上",
                   "メールのフィルタリング",
                   "不正アクセスの防止"
               ],
               correctAnswerIndex: 3,
               explanation: "ファイアウォールは、不正アクセスやネットワーク上の不要なトラフィックを防ぐためのセキュリティシステムです。"
           ),
           QuizQuestion(
            id: "it.05cf0dbf013f8653a9856861",
               question: "ソフトウェア開発における「アジャイル」とは、何に重点を置いた開発手法か？",
               choices: [
                   "柔軟性と迅速な対応",
                   "長期計画",
                   "プロセス",
                   "文書化"
               ],
               correctAnswerIndex: 0,
               explanation: "アジャイル開発は、変化に柔軟に対応し、短い開発サイクルを通じて迅速に製品を改善していく手法です。"
           ),
           QuizQuestion(
            id: "it.c89df9798f9f6aa1263e8076",
               question: "「クラウドストレージ」サービスの利点は何か？",
               choices: [
                   "データのリモートアクセス",
                   "高速なデータアクセス",
                   "ローカルストレージの節約",
                   "すべての上記"
               ],
               correctAnswerIndex: 3,
               explanation: "クラウドストレージサービスは、ローカルストレージの節約、どこからでもデータへのアクセス、高速なデータアクセスを提供します。"
           ),
           QuizQuestion(
            id: "it.7ad501e7a84856d14d58b454",
               question: "プログラミングにおいて、エラーが発生しやすいコードの部分を何と呼ぶか？",
               choices: [
                   "ホットスポット",
                   "コードスメル",
                   "リスクエリア",
                   "バグゾーン"
               ],
               correctAnswerIndex: 1,
               explanation: "コードスメルは、将来的にバグや問題を引き起こす可能性がある、プログラムの中で品質が低い部分を指します。"
           ),
          QuizQuestion(
            id: "it.a38d3b9baa8a77823bddeed1",
              question: "オペレーティングシステム(OS)の主な役割は何か？",
              choices: [
                  "ソフトウェアの開発",
                  "ウェブサイトのホスティング",
                  "電子メールの送受信",
                  "ハードウェアとソフトウェアの仲介"
              ],
              correctAnswerIndex: 3,
              explanation: "オペレーティングシステムは、ハードウェアリソースの管理と、アプリケーションソフトウェアがハードウェアと対話できるようにする役割を持っています。"
          ),
          QuizQuestion(
            id: "it.8703068d61e9a7499cd8d6ac",
              question: "ネットワークでの「IPアドレス」の役割は何か？",
              choices: [
                  "デバイスの識別",
                  "データの圧縮",
                  "プログラミング",
                  "ゲームの開発"
              ],
              correctAnswerIndex: 0,
              explanation: "IPアドレスは、インターネット上のデバイスを一意に識別するために使用されます。"
          ),
          QuizQuestion(
            id: "it.4722f77bed95644375bc93e8",
              question: "オブジェクト指向プログラミングの特徴ではないものは？",
              choices: [
                  "カプセル化",
                  "直列化",
                  "継承",
                  "多様性"
              ],
              correctAnswerIndex: 1,
              explanation: "直列化はオブジェクト指向プログラミングの特徴ではなく、オブジェクトの状態を保存または転送可能な形式に変換するプロセスを指します。"
          ),
          QuizQuestion(
            id: "it.6a3020b4a0c18e6d3b48bbd8",
              question: "「フィッシング攻撃」とは何か？",
              choices: [
                  "コンピュータに物理的な損害を与える行為",
                  "不正な方法で個人情報を盗み出す詐欺行為",
                  "インターネット速度を遅くする攻撃",
                  "ウイルスをメールで送信する行為"
              ],
              correctAnswerIndex: 1,
              explanation: "フィッシング攻撃は、偽のウェブサイトやメールなどを用いて、ユーザーから個人情報を騙し取る詐欺行為です。"
          ),
          QuizQuestion(
            id: "it.93989abd0d106a265ff259e8",
              question: "ソフトウェア開発プロジェクトで、要件収集と分析を行うフェーズはどれか？",
              choices: [
                  "実装",
                  "要件定義",
                  "テスト",
                  "設計"
              ],
              correctAnswerIndex: 1,
              explanation: "要件定義フェーズでは、プロジェクトの目的、機能、システムの要件などを収集し、分析します。"
          ),
          QuizQuestion(
            id: "it.8106740eab9462f1f627c793",
              question: "コンピュータネットワークにおいて、データを送受信するために使われるデバイスは？",
              choices: [
                  "ストレージ",
                  "プロセッサ",
                  "モデム",
                  "マザーボード"
              ],
              correctAnswerIndex: 2,
              explanation: "モデムは、インターネットなどのネットワークにデバイスを接続し、データの送受信を可能にするデバイスです。"
          ),
          QuizQuestion(
            id: "it.b35d6360ec02918d75814d4c",
              question: "Webページを構成する基本的な3つの技術とは何か？",
              choices: [
                  "Apache、Nginx、IIS",
                  "PHP、Python、Ruby",
                  "HTML、CSS、JavaScript",
                  "MySQL、MongoDB、PostgreSQL"
              ],
              correctAnswerIndex: 2,
              explanation: "HTMLはページの構造を、CSSはスタイリングを、JavaScriptはインタラクティブな動作をそれぞれ担当します。"
          ),
          QuizQuestion(
            id: "it.2d3381f5f11cf8dd9faa246e",
              question: "インターネット上で安全なデータのやりとりを保証するために使用されるプロトコルはどれか？",
              choices: [
                  "HTTPS",
                  "SMTP",
                  "HTTP",
                  "FTP"
              ],
              correctAnswerIndex: 0,
              explanation: "HTTPS（Hyper Text Transfer Protocol Secure）は、SSL/TLSを用いて通信を暗号化し、安全なデータ交換を実現します。"
          ),
          QuizQuestion(
            id: "it.207ed29e13ff47e2304a58bb",
              question: "プログラミング言語Pythonでリスト内の全要素を合計する関数はどれか？",
              choices: [
                  "add()",
                  "total()",
                  "sum()",
                  "combine()"
              ],
              correctAnswerIndex: 2,
              explanation: "Pythonの組み込み関数sum()は、イテラブル（例えばリスト）内の全要素の合計を計算します。"
          ),
          QuizQuestion(
            id: "it.5f10fa9dda7aced3c73eebe9",
              question: "インターネットで情報を検索するために使用されるプログラムは何か？",
              choices: [
                  "ウェブデベロッパー",
                  "ウェブブラウザ",
                  "ウェブデザイナー",
                  "ウェブサーバー"
              ],
              correctAnswerIndex: 1,
              explanation: "ウェブブラウザは、インターネットで情報を検索し、ウェブページを表示するために使用されるプログラムです。"
          ),
          QuizQuestion(
            id: "it.cb17e52697c1a4b09b51a160",
              question: "コンピュータプログラムのバグを見つけて修正するプロセスを何というか？",
              choices: [
                  "テスト実行",
                  "デバッギング",
                  "コンパイリング",
                  "リファクタリング"
              ],
              correctAnswerIndex: 1,
              explanation: "デバッギングは、コンピュータプログラムのバグを見つけて修正するプロセスです。"
          ),
          QuizQuestion(
            id: "it.71d098c874aa56c662e5273f",
              question: "ウェブ開発でスタイルとレイアウトを定義するために使用される言語は何か？",
              choices: [
                  "CSS",
                  "Python",
                  "HTML",
                  "JavaScript"
              ],
              correctAnswerIndex: 0,
              explanation: "CSS（Cascading Style Sheets）は、ウェブページのスタイルとレイアウトを定義するために使用される言語です。"
          ),
          QuizQuestion(
            id: "it.054275cd6dfa6407073be318",
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
            id: "it.79f3699b31642806bceaa150",
              question: "ネットワークにおけるIPアドレスの役割は何か？",
              choices: [
                  "ネットワークのセキュリティを強化する",
                  "ネットワーク上のデバイスを識別する",
                  "ネットワーク上でのプリンター共有を可能にする",
                  "ネットワークの速度を向上させる"
              ],
              correctAnswerIndex: 1,
              explanation: "IPアドレスは、インターネットプロトコルネットワーク上の各デバイスを一意に識別するために使用される数値のラベルです。"
          ),

                     
        QuizQuestion(
            id: "it.fa78fc17efa7e3251aefaf5c",
            question: "ランサムウェアとは何か？",
            choices: [
                "データを暗号化し、身代金を要求するマルウェア",
                "ネットワーク上のデータを監視するソフトウェア",
                "コンピュータの動作を高速化するソフトウェア",
                "不正アクセスを検知するシステム"
            ],
            correctAnswerIndex: 0,
            explanation: "ランサムウェアは、感染したコンピュータ上のデータを暗号化し、復号と引き換えに金銭（身代金）を要求するマルウェアです。"
        ),
        QuizQuestion(
            id: "it.c760dbe314778a2de8609f05",
            question: "ソフトウェアの「ウォーターフォールモデル」の特徴として正しいものはどれか？",
            choices: [
                "各フェーズを順番に実施し、前のフェーズに戻らない",
                "短いサイクルで機能をリリースする",
                "各フェーズを反復して開発を進める",
                "顧客と毎週ミーティングを行う"
            ],
            correctAnswerIndex: 0,
            explanation: "ウォーターフォールモデルは、要件定義→設計→実装→テスト→運用という各フェーズを順番に実施し、原則として前のフェーズに戻らない開発手法です。"
        ),
        QuizQuestion(
            id: "it.4ef9f78bf90656a33c30fc54",
            question: "ネットワークにおける「LANとWAN」の説明として正しいものはどれか？",
            choices: [
                "LANは有線のみ、WANは無線のみ",
                "LANは広域ネットワーク、WANは構内ネットワーク",
                "LANは構内ネットワーク、WANは広域ネットワーク",
                "LANとWANは同じ意味で使われる"
            ],
            correctAnswerIndex: 2,
            explanation: "LAN（Local Area Network）は建物内などの構内ネットワーク、WAN（Wide Area Network）は地理的に離れた場所を結ぶ広域ネットワークです。"
        ),
        QuizQuestion(
            id: "it.b3737f7cccdaeefdd2e24be7",
            question: "「IoT（Internet of Things）」の説明として正しいものはどれか？",
            choices: [
                "様々な物がインターネットに接続される概念",
                "インターネット上の仮想通貨取引",
                "AIによる自動翻訳システム",
                "クラウド上でのデータ保管サービス"
            ],
            correctAnswerIndex: 0,
            explanation: "IoT（モノのインターネット）は、家電・センサー・自動車など様々な物がインターネットに接続され、データを収集・活用する概念です。"
        ),
        QuizQuestion(
            id: "it.f59dae9bfc410b892942c602",
            question: "「AI（人工知能）」における「機械学習」の説明として正しいものはどれか？",
            choices: [
                "ロボットが自律的に動く技術",
                "コンピュータが人間の言語を翻訳する技術",
                "データから自動的にパターンや規則を学習する手法",
                "人間がすべてのルールをプログラムする手法"
            ],
            correctAnswerIndex: 2,
            explanation: "機械学習は、コンピュータが大量のデータを分析し、人間が明示的にプログラムしなくてもパターンや規則を自動的に学習する技術です。"
        ),
        QuizQuestion(
            id: "it.0bd7c0ff885b221c20b61b2d",
            question: "「マルウェア」とは何の総称か？",
            choices: [
                "古くなったソフトウェア",
                "無料のソフトウェア",
                "悪意のあるソフトウェア全般",
                "テスト用のソフトウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "マルウェア（Malware）は、「malicious（悪意のある）」と「software（ソフトウェア）」の合成語で、ウイルス・ワーム・トロイの木馬・ランサムウェアなど悪意のあるソフトウェア全般の総称です。"
        ),
        QuizQuestion(
            id: "it.6e2291c94109f12edfdae6ad",
            question: "「ディープラーニング（深層学習）」について正しい説明はどれか？",
            choices: [
                "インターネット上の情報を検索する技術",
                "多層のニューラルネットワークを用いた機械学習",
                "データを単純な統計で分析する手法",
                "人間が明示したルールに基づいて動作する"
            ],
            correctAnswerIndex: 1,
            explanation: "ディープラーニングは、人間の脳の神経回路を模した多層のニューラルネットワークを用いて、画像認識・音声認識などの高度なパターン認識を行う機械学習の一手法です。"
        ),
        QuizQuestion(
            id: "it.acd0d0f4ceab431297b73ec3",
            question: "「ソーシャルエンジニアリング」の説明として正しいものはどれか？",
            choices: [
                "SNSを活用したマーケティング手法",
                "技術的な手段を使わず、人の心理や行動を悪用して情報を騙し取る手口",
                "社会インフラのシステム開発手法",
                "複数のエンジニアが協力して開発する手法"
            ],
            correctAnswerIndex: 1,
            explanation: "ソーシャルエンジニアリングは、技術的な攻撃ではなく、電話・なりすましなど人の心理や信頼を悪用してパスワードや機密情報を不正に入手する攻撃手法です。"
        ),
        QuizQuestion(
            id: "it.cf331f1d2bb0a159d121c9fe",
            question: "「ブロックチェーン」の説明として正しいものはどれか？",
            choices: [
                "動画コンテンツを配信する技術",
                "ウイルスをブロックする技術",
                "取引データをチェーン状に連結して分散管理する技術",
                "ファイルを暗号化して保管する技術"
            ],
            correctAnswerIndex: 2,
            explanation: "ブロックチェーンは、取引データをブロック単位でまとめ、チェーン状に連結して複数のノードで分散管理する技術で、改ざんが非常に困難です。暗号通貨などに使われます。"
        ),
        QuizQuestion(
            id: "it.a743fa8468b067ba3917399c",
            question: "「レスポンシブウェブデザイン」の説明として正しいものはどれか？",
            choices: [
                "表示速度を最優先に設計されたWebデザイン",
                "セキュリティを重視したWebデザイン",
                "視覚障がい者向けに音声読み上げを最適化したデザイン",
                "PC・スマートフォン・タブレットなど様々な画面サイズに対応するデザイン手法"
            ],
            correctAnswerIndex: 3,
            explanation: "レスポンシブウェブデザインは、1つのHTMLファイルでPC・スマートフォン・タブレットなど異なる画面サイズや解像度に柔軟に対応するWebデザイン手法です。"
        ),
        QuizQuestion(
            id: "it.aa0f1952e151c1999af5e7ec",
            question: "「DoS攻撃（Denial of Service）」の説明として正しいものはどれか？",
            choices: [
                "大量のリクエストを送りつけてサービスを利用不能にする攻撃",
                "パスワードを盗み取る攻撃",
                "ネットワーク上の通信を盗聴する攻撃",
                "Webサイトの見た目を改ざんする攻撃"
            ],
            correctAnswerIndex: 0,
            explanation: "DoS攻撃は、ターゲットのサーバーやネットワークに大量のリクエストを送りつけることで過負荷状態にし、正規ユーザーがサービスを利用できなくする攻撃です。"
        ),
        QuizQuestion(
            id: "it.a189bedcaa5ae302a6f862da",
            question: "「フィッシング詐欺」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのデータを消去する攻撃",
                "偽のWebサイトや電子メールで個人情報を騙し取る詐欺",
                "コンピュータの処理を遅くする攻撃",
                "ネットワーク上の通信を傍受する攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "フィッシング詐欺は、銀行や通販サイトなどを装った偽のメールやWebサイトに誘導し、IDやパスワード・クレジットカード番号などを騙し取る詐欺の手口です。"
        ),
        QuizQuestion(
            id: "it.3b83a17ab162c5ad85521ab3",
            question: "「OS（オペレーティングシステム）」の役割として正しいものはどれか？",
            choices: [
                "ウイルスを除去するためのソフトウェア",
                "文書作成専用のソフトウェア",
                "ハードウェアとアプリケーションソフトの間で資源を管理する基本ソフトウェア",
                "インターネットに接続するためだけのソフトウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "OS（オペレーティングシステム）は、CPU・メモリ・ストレージなどのハードウェアを管理し、アプリケーションが動作する基盤を提供する基本ソフトウェアです。Windows・macOS・iOSなどが代表例です。"
        ),
        QuizQuestion(
            id: "it.6f3032bbe7da05ca1649a05f",
            question: "「Webブラウザ」の役割として正しいものはどれか？",
            choices: [
                "コンピュータのウイルスを検出するソフトウェア",
                "電子メールを送受信するソフトウェア",
                "WebサイトのHTMLを解釈して画面に表示するソフトウェア",
                "ファイルを圧縮・解凍するソフトウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "WebブラウザはHTMLやCSS・JavaScriptなどで書かれたWebページのデータを解釈し、画面に表示するソフトウェアです。Chrome・Safari・Edge・Firefoxなどが代表例です。"
        ),
        QuizQuestion(
            id: "it.a8f7eff8dd46d180598ffe76",
            question: "「URL（Uniform Resource Locator）」の説明として正しいものはどれか？",
            choices: [
                "ファイルの種類を示す拡張子",
                "ウイルスの種類を識別するコード",
                "インターネット上のリソースの場所を示すアドレス",
                "コンピュータを一意に識別する番号"
            ],
            correctAnswerIndex: 2,
            explanation: "URLはインターネット上のWebページや画像・ファイルなどのリソースがどこにあるかを示す住所のようなものです。「https://www.example.com」の形式で表されます。"
        ),
        QuizQuestion(
            id: "it.c888e8300acb09674cbd536f",
            question: "「スパムメール」の説明として正しいものはどれか？",
            choices: [
                "添付ファイルのないメール",
                "暗号化されて読めないメール",
                "文字だけで画像のないメール",
                "受信者の意図に関わらず大量に送りつけられる迷惑メール"
            ],
            correctAnswerIndex: 3,
            explanation: "スパムメールは、受信者の同意なく大量に送りつけられる迷惑メールです。広告・詐欺・ウイルス感染を目的としたものが多く、フィルタリング機能で対策します。"
        ),
        QuizQuestion(
            id: "it.e0e6d2b2726b67dfe657b576",
            question: "「QRコード」の説明として正しいものはどれか？",
            choices: [
                "バーコードの一種で、1次元のシマ模様でデータを表す",
                "磁気テープに情報を記録したカード",
                "ICチップにデータを記録したカード",
                "2次元の正方形模様でURLや文字列などのデータを表すコード"
            ],
            correctAnswerIndex: 3,
            explanation: "QRコード（Quick Response Code）は、縦横2次元の正方形パターンでURLや文字列などのデータを表すコードです。スマートフォンのカメラで読み取ることができます。"
        ),
        QuizQuestion(
            id: "it.250f1d0473d79a18373a5952",
            question: "「デジタルデバイド」の説明として正しいものはどれか？",
            choices: [
                "インターネットの通信速度の差",
                "デジタルデータを暗号化する技術",
                "ITを利用できる人とできない人との間に生じる格差",
                "デジタル機器を分解すること"
            ],
            correctAnswerIndex: 2,
            explanation: "デジタルデバイドは、インターネットやコンピュータなどのIT機器・サービスを使いこなせる人とそうでない人の間に生じる経済的・社会的格差のことです。"
        ),
        QuizQuestion(
            id: "it.cb75c9c1ee79b42ba0d3e230",
            question: "安全なパスワードの設定方法として最も適切なものはどれか？",
            choices: [
                "覚えやすいように生年月日を使う",
                "全サービスで同じパスワードを使う",
                "英数字・記号を組み合わせた長いパスワードを複数のサービスで使い分ける",
                "4桁の数字のみのパスワードを設定する"
            ],
            correctAnswerIndex: 2,
            explanation: "安全なパスワードは、英字（大文字・小文字）・数字・記号を組み合わせ、十分な長さを持ち、サービスごとに異なるものを使用することが重要です。推測されやすい個人情報は避けましょう。"
        ),
        QuizQuestion(
            id: "it.78a2383367861b3d25c5cdfa",
            question: "「ウイルス対策ソフト（セキュリティソフト）」の主な目的はどれか？",
            choices: [
                "コンピュータの処理速度を上げる",
                "インターネットの接続速度を上げる",
                "データを自動的にクラウドに保存する",
                "マルウェアの検出・削除やリアルタイムの脅威防御を行う"
            ],
            correctAnswerIndex: 3,
            explanation: "ウイルス対策ソフトは、ウイルス・スパイウェア・ランサムウェアなどのマルウェアをリアルタイムで検出・削除し、コンピュータをセキュリティ脅威から守るソフトウェアです。"
        ),
        QuizQuestion(
            id: "it.9414015f054c673b9dd30b22",
            question: "「クラウドストレージ」の説明として正しいものはどれか？",
            choices: [
                "USBメモリにデータを保存するサービス",
                "インターネット上のサーバーにデータを保存・共有できるサービス",
                "ネットワーク上のプリンターにデータを送るサービス",
                "コンピュータ内蔵のSSDやHDDにデータを保存する"
            ],
            correctAnswerIndex: 1,
            explanation: "クラウドストレージは、インターネット経由でデータをサーバーに保存・管理できるサービスです。どこからでもアクセス可能で、デバイス間での共有も容易です。iCloud・Google Drive・OneDriveなどが代表例です。"
        ),
        QuizQuestion(
            id: "it.dd9a1b0a80e79655257bc3e9",
            question: "「スパイウェア」の説明として正しいものはどれか？",
            choices: [
                "Webサイトの表示を高速化するソフトウェア",
                "ユーザーの行動や個人情報を秘密裏に収集・送信する悪意あるソフトウェア",
                "コンピュータの処理速度を上げるソフトウェア",
                "メールを自動送信するソフトウェア"
            ],
            correctAnswerIndex: 1,
            explanation: "スパイウェアは、ユーザーの同意なくインストールされ、閲覧履歴・キー入力・個人情報などを秘密裏に収集して外部に送信するマルウェアです。"
        ),
        QuizQuestion(
            id: "it.730c73cf240b30d170fce9b1",
            question: "「情報リテラシー」の説明として正しいものはどれか？",
            choices: [
                "情報を適切に収集・評価・活用できる能力",
                "高速タイピングができる技術",
                "プログラミングができる能力",
                "コンピュータを修理できる技術"
            ],
            correctAnswerIndex: 0,
            explanation: "情報リテラシーは、必要な情報を収集・選択・評価し、目的に応じて適切に活用できる能力のことです。情報の真偽を見極め、発信・共有する際の倫理的な判断も含まれます。"
        ),
        QuizQuestion(
            id: "it.31b9b294ed163fb4f6be6fab",
            question: "「アプリケーションソフトウェア」の説明として正しいものはどれか？",
            choices: [
                "コンピュータの起動時に読み込まれるプログラム",
                "OSの一部として提供されるシステムプログラム",
                "コンピュータのハードウェアを直接制御するソフトウェア",
                "特定の業務や目的のためにOSの上で動作するソフトウェア"
            ],
            correctAnswerIndex: 3,
            explanation: "アプリケーションソフトウェアは、文書作成・表計算・ゲームなど特定の目的のためにOSの上で動作するソフトウェアです。OSなどのシステムソフトウェアとは区別されます。"
        ),
        QuizQuestion(
            id: "it.ed036a99fb2ed60b8d489682",
            question: "「ソフトウェアのアップデート（更新）」を行う主な理由として正しいものはどれか？",
            choices: [
                "コンピュータの見た目を変えるため",
                "インターネットの速度を上げるため",
                "コンピュータのデータを削除するため",
                "セキュリティの脆弱性修正や機能改善を行うため"
            ],
            correctAnswerIndex: 3,
            explanation: "ソフトウェアのアップデートは、発見されたセキュリティの脆弱性（セキュリティホール）の修正、不具合の修正、新機能の追加が主な目的です。特にセキュリティパッチは速やかに適用することが重要です。"
        ),
        QuizQuestion(
            id: "it.aec8610cffd79d5e425f75f9",
            question: "「不正アクセス」の説明として正しいものはどれか？",
            choices: [
                "インターネットの通信速度が遅くなること",
                "権限のない者がコンピュータやシステムに無断で侵入すること",
                "ソフトウェアが正常に動作しなくなること",
                "メールが誤って送信されること"
            ],
            correctAnswerIndex: 1,
            explanation: "不正アクセスは、正当な権限を持たない者が他人のコンピュータやシステムに無断で侵入する行為です。日本では「不正アクセス禁止法」により禁止されています。"
        ),
        QuizQuestion(
            id: "it.b36fdcb5e404a08ee6a9f270",
            question: "「SNS（ソーシャルネットワーキングサービス）」を利用する上でのリスクとして適切なものはどれか？",
            choices: [
                "ウイルスが自動的に増殖する",
                "コンピュータのストレージが不足する",
                "インターネットの速度が低下する",
                "個人情報の意図しない公開やなりすまし被害に遭う可能性がある"
            ],
            correctAnswerIndex: 3,
            explanation: "SNSでは、投稿した個人情報が広範囲に拡散したり、アカウントを乗っ取られてなりすまし被害に遭う可能性があります。プライバシー設定の確認や、不審なリンクへのアクセスに注意が必要です。"
        ),
        QuizQuestion(
            id: "it.6b5ccea5d41dba0631d7e97a",
            question: "「情報セキュリティの3要素（CIAトライアド）」に含まれないものはどれか？",
            choices: ["完全性（Integrity）", "可用性（Availability）", "機密性（Confidentiality）", "拡張性（Scalability）"],
            correctAnswerIndex: 3,
            explanation: "情報セキュリティの3要素（CIAトライアド）は、機密性（許可された人だけがアクセス可能）・完全性（情報が正確で改ざんされていない）・可用性（必要なときに利用可能）の3つです。拡張性は含まれません。"
        ),
        QuizQuestion(
            id: "it.d1b2176b53152c6c6589a742",
            question: "「コンピュータウイルス」と「ワーム」の違いとして正しいものはどれか？",
            choices: [
                "ウイルスはWindowsのみに感染し、ワームはMacのみに感染する",
                "ウイルスは他のファイルに寄生して感染し、ワームは自己複製してネットワーク経由で拡散する",
                "ウイルスとワームはまったく同じもの",
                "ウイルスは有害で、ワームは無害"
            ],
            correctAnswerIndex: 1,
            explanation: "ウイルスは既存のファイルやプログラムに寄生して感染を広げます。ワームは単独で動作し、ネットワークを通じて自己複製・拡散するマルウェアです。どちらも有害ですが動作の仕組みが異なります。"
        ),
        QuizQuestion(
            id: "it.4f35ce678ea50d5a2317d4c7",
            question: "「データのバックアップ」が重要な理由として最も適切なものはどれか？",
            choices: [
                "ストレージの容量を増やすため",
                "コンピュータの動作を速くするため",
                "障害・事故・ランサムウェア被害に備えてデータを復元できるようにするため",
                "インターネットの速度を向上させるため"
            ],
            correctAnswerIndex: 2,
            explanation: "バックアップは、ハードウェア故障・誤操作・災害・ランサムウェア被害などによりデータが失われた場合に復元できるよう、データのコピーを別の場所に保存しておくことです。定期的なバックアップが重要です。"
        ),
        QuizQuestion(
            id: "it.46f45283dfdae01e926dd45d",
            question: "「二段階認証」と「パスワード認証のみ」を比較したとき、二段階認証の利点はどれか？",
            choices: [
                "パスワードが漏れても第二の認証要素がないとログインできないため安全性が高い",
                "ログインが速くなる",
                "インターネット接続が不要になる",
                "パスワードを覚えなくてよくなる"
            ],
            correctAnswerIndex: 0,
            explanation: "二段階認証は、パスワードに加えてSMSワンタイムパスワードや認証アプリなど別の認証を組み合わせる方法です。パスワードが流出しても、第二の認証がなければ不正ログインを防げます。"
        ),
        QuizQuestion(
            id: "it.465aa76a346c749831f5ee13",
            question: "データ容量の単位として、大きい順に正しく並んでいるものはどれか？",
            choices: [
                "MB → GB → TB → KB",
                "KB → MB → GB → TB",
                "TB → GB → MB → KB",
                "GB → MB → KB → TB"
            ],
            correctAnswerIndex: 2,
            explanation: "データ容量の単位は小さい順にKB（キロバイト）→MB（メガバイト）→GB（ギガバイト）→TB（テラバイト）です。それぞれ約1000倍の関係にあります（正確には1024倍）。"
        ),
        QuizQuestion(
            id: "it.87f3940bbb4f7d055bfca997",
            question: "公共の場所の「フリーWi-Fi（公衆無線LAN）」を利用する際の注意点として正しいものはどれか？",
            choices: [
                "利用すると自動的にウイルスに感染する",
                "通信内容が傍受される可能性があるため、重要な情報の送受信は避けるべきだ",
                "フリーWi-Fiはインターネットに接続できない",
                "誰でも自由に使えるため、セキュリティのリスクはまったくない"
            ],
            correctAnswerIndex: 1,
            explanation: "フリーWi-Fiは暗号化されていない場合があり、同じネットワーク上の第三者に通信内容を傍受されるリスクがあります。インターネットバンキングや個人情報の入力は避け、VPNの利用が推奨されます。"
        ),
        QuizQuestion(
            id: "it.8fb5934ce3ce92c068500645",
            question: "「Bluetooth（ブルートゥース）」の説明として正しいものはどれか？",
            choices: [
                "データを長距離で無線転送する通信規格",
                "インターネットに接続するための有線規格",
                "衛星を使った位置情報サービス",
                "数メートル〜数十メートルの近距離で機器同士をワイヤレス接続する通信規格"
            ],
            correctAnswerIndex: 3,
            explanation: "Bluetoothは、スマートフォン・イヤホン・キーボードなどの機器を近距離でワイヤレス接続するための無線通信規格です。消費電力が低く、ケーブル不要で手軽に使えます。"
        ),
        QuizQuestion(
            id: "it.1ba37a66e9b1afc3fe54ed33",
            question: "「電子商取引（EC：Electronic Commerce）」の説明として正しいものはどれか？",
            choices: [
                "電子機器の修理サービス",
                "会社の電子文書管理システム",
                "電子部品の製造・販売",
                "インターネットなどのネットワークを通じて行われる商品やサービスの売買"
            ],
            correctAnswerIndex: 3,
            explanation: "電子商取引（EC）は、インターネットを通じて商品やサービスを売買する取引形態です。Amazon・楽天などのネットショッピング、デジタルコンテンツの販売などが代表例です。"
        ),
        QuizQuestion(
            id: "it.2b7c242e952d401bac4735d6",
            question: "「検索エンジン」の説明として正しいものはどれか？",
            choices: [
                "ファイルをダウンロードするためのソフトウェア",
                "電子メールを送るためのシステム",
                "コンピュータのCPUの別名",
                "インターネット上の情報を収集・整理し、キーワードで検索できるサービス"
            ],
            correctAnswerIndex: 3,
            explanation: "検索エンジンは、インターネット上のWebページを自動収集・整理し、ユーザーがキーワードを入力することで関連情報を素早く見つけられるサービスです。Google・Yahoo!・Bingなどが代表例です。"
        ),
        QuizQuestion(
            id: "it.702710bff7defd9cb1d310ee",
            question: "電子メールの「CC」と「BCC」の違いとして正しいものはどれか？",
            choices: [
                "CCはメインの宛先、BCCは返信先",
                "BCCはファイルを添付するための項目",
                "CCはすべての受信者に宛先が見えるが、BCCは他の受信者に宛先が見えない",
                "CCとBCCはまったく同じ機能"
            ],
            correctAnswerIndex: 2,
            explanation: "CC（カーボンコピー）はすべての受信者が他の受信者を確認できます。BCC（ブラインドカーボンコピー）は受信者のアドレスが他の受信者に見えないため、一斉送信時のプライバシー保護に使われます。"
        ),
        QuizQuestion(
            id: "it.3b501a064851f13369b1eaf1",
            question: "ファイルの「拡張子」の役割として正しいものはどれか？",
            choices: [
                "ファイルの種類や形式を識別するためのファイル名の末尾の文字列",
                "ファイルのサイズを示す",
                "ファイルの保存場所を示す",
                "ファイルの作成者を示す"
            ],
            correctAnswerIndex: 0,
            explanation: "拡張子はファイル名の末尾に「.」（ドット）で区切られた文字列で、ファイルの種類を示します。.docx（Word文書）・.pdf（PDF）・.jpg（画像）・.mp4（動画）などがあります。"
        ),
        QuizQuestion(
            id: "it.f1b0cfc5087f99524ae97413",
            question: "「プライバシーポリシー」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのセキュリティ設定",
                "企業や組織が個人情報をどのように収集・利用・管理するかを示した方針",
                "インターネット接続の料金体系",
                "Webサイトの利用規約"
            ],
            correctAnswerIndex: 1,
            explanation: "プライバシーポリシーは、企業・組織がユーザーの個人情報（氏名・メアドなど）をどのような目的で収集し、どう管理・利用するかを明示した方針文書です。Webサービス利用前に確認することが重要です。"
        ),
        QuizQuestion(
            id: "it.79b903c445c0234bd451cccf",
            question: "WebサイトのCookie（クッキー）の基本的な役割として正しいものはどれか？",
            choices: [
                "コンピュータをウイルスから守る",
                "Webサイトの画像を高速表示する",
                "ユーザーのログイン状態や設定などをブラウザに一時保存する",
                "インターネットの通信を暗号化する"
            ],
            correctAnswerIndex: 2,
            explanation: "Cookieはウェブサーバーがブラウザに保存する小さなデータです。ログイン状態の維持・カートの内容保存・サイトの設定記憶などに使われます。第三者Cookieは広告のターゲティングにも利用されます。"
        ),
        QuizQuestion(
            id: "it.7461eb63032750ad23041a8b",
            question: "「5G（第5世代移動通信システム）」の特徴として正しいものはどれか？",
            choices: [
                "Wi-Fiと同じ規格で屋内専用",
                "4Gと比べて通信速度が遅いが安定している",
                "テキストメッセージのみ送受信できる通信規格",
                "超高速・超低遅延・多数同時接続を実現する通信規格"
            ],
            correctAnswerIndex: 3,
            explanation: "5Gは第5世代移動通信システムで、4Gと比べて超高速（最大20Gbps）・超低遅延・多数同時接続が特徴です。自動運転・遠隔医療・スマートファクトリーなどへの活用が期待されています。"
        ),
        QuizQuestion(
            id: "it.0e92ac9e2b36d701503310ec",
            question: "「GPS（全地球測位システム）」の説明として正しいものはどれか？",
            choices: [
                "複数の衛星からの電波を受信して現在地を特定するシステム",
                "ネットワークのセキュリティを管理するシステム",
                "インターネットの通信速度を測定するシステム",
                "コンピュータのグラフィック処理システム"
            ],
            correctAnswerIndex: 0,
            explanation: "GPSは複数の人工衛星から発信される電波を受信し、三角測量の原理で受信者の現在位置（緯度・経度・高度）を算出するシステムです。カーナビやスマートフォンの地図アプリに活用されています。"
        ),
        QuizQuestion(
            id: "it.bada5900179d84bb4ceb96ef",
            question: "「デジタル」と「アナログ」の違いとして正しいものはどれか？",
            choices: [
                "デジタルは0と1の離散値で情報を表し、アナログは連続した値で情報を表す",
                "デジタルは古い技術で、アナログは新しい技術",
                "デジタルは音声専用で、アナログは映像専用",
                "デジタルとアナログは同じ意味"
            ],
            correctAnswerIndex: 0,
            explanation: "デジタルは情報を0と1の組み合わせ（離散的な値）で表します。アナログは連続した値で情報を表します。CDはデジタル、レコードはアナログの例です。デジタルは劣化しにくく複製が容易という特徴があります。"
        ),
        QuizQuestion(
            id: "it.630db0a091448f9529e2759d",
            question: "「圧縮ファイル（ZIP形式など）」を使う主な目的はどれか？",
            choices: [
                "ファイルのウイルスを除去するため",
                "ファイルを暗号化してセキュリティを高めるため",
                "ファイルをクラウドに自動でアップロードするため",
                "複数ファイルをまとめてファイルサイズを小さくするため"
            ],
            correctAnswerIndex: 3,
            explanation: "ZIP等の圧縮形式は、データを効率よく符号化してファイルサイズを小さくし、複数のファイルを1つにまとめることができます。メール添付やダウンロードの際に転送量を削減するために使われます。"
        ),
        QuizQuestion(
            id: "it.292204b50f9a575005febcf1",
            question: "「ダウンロード」と「アップロード」の違いとして正しいものはどれか？",
            choices: [
                "ダウンロードとアップロードは同じ意味",
                "ダウンロードは有料で、アップロードは無料",
                "ダウンロードはデータを作成し、アップロードはデータを削除すること",
                "ダウンロードはサーバーから手元の機器にデータを取り込み、アップロードは手元の機器からサーバーにデータを送ること"
            ],
            correctAnswerIndex: 3,
            explanation: "ダウンロードはサーバー（インターネット側）からスマートフォンやPCにデータを受け取ることです。アップロードは逆に、手元のデータをサーバーに送信することです。"
        ),
        QuizQuestion(
            id: "it.72613ac6cfde47725acfc68b",
            question: "「アクセシビリティ」のIT分野における説明として正しいものはどれか？",
            choices: [
                "Webサイトの表示速度を向上させること",
                "インターネットの接続を制限すること",
                "高齢者・障がい者を含む誰もがITシステムやWebサービスを利用しやすくすること",
                "システムへの不正アクセスを防ぐこと"
            ],
            correctAnswerIndex: 2,
            explanation: "アクセシビリティは、視覚・聴覚・運動機能に障がいのある方や高齢者も含め、誰もが使いやすいようにシステムやWebサービスを設計・提供することです。音声読み上げ対応・文字サイズ変更などが例です。"
        ),
        QuizQuestion(
            id: "it.dd22270818f80a66f26e3af0",
            question: "「サブスクリプション（サブスク）」サービスの説明として正しいものはどれか？",
            choices: [
                "一回限りの購入で利用できるデジタルコンテンツ",
                "無料で提供されるサービス全般",
                "月額・年額などの定額料金を払って継続的にサービスを利用する形態",
                "一度購入すると永久に使えるソフトウェアの販売形態"
            ],
            correctAnswerIndex: 2,
            explanation: "サブスクリプションは、月額・年額などの定額を支払うことで、期間中はサービスを継続的に利用できるビジネスモデルです。音楽・動画配信・ソフトウェアなど様々な分野で普及しています。"
        ),
        QuizQuestion(
            id: "it.4e6b73ef1355ddd996b72950",
            question: "「VR（バーチャルリアリティ）」の説明として正しいものはどれか？",
            choices: [
                "インターネットを使ったリモートワーク技術",
                "ウイルスを仮想環境で検査する技術",
                "現実世界にデジタル情報を重ねて表示する技術",
                "専用ゴーグルなどを使って人工的に作られた仮想空間に没入できる技術"
            ],
            correctAnswerIndex: 3,
            explanation: "VR（仮想現実）は、専用のヘッドセットなどを装着することで、コンピュータが作り出した仮想空間に完全に没入できる技術です。ゲーム・医療・教育・訓練シミュレーションなどに活用されています。"
        ),
        QuizQuestion(
            id: "it.5bc89d9c9f291bc2711f1318",
            question: "「AR（拡張現実）」の説明として正しいものはどれか？",
            choices: [
                "コンピュータが作り出した仮想空間に完全没入する技術",
                "リアルタイムで映像を遠隔配信する技術",
                "現実の視界にデジタル情報を重ねて表示する技術",
                "人工知能が人間の代わりに作業する技術"
            ],
            correctAnswerIndex: 2,
            explanation: "AR（拡張現実）は、スマートフォンのカメラや専用グラスを通じて、現実の風景にデジタル情報を重ねて表示する技術です。ポケモンGOや家具の配置シミュレーションアプリなどが身近な例です。"
        ),
        QuizQuestion(
            id: "it.df4468a81907f185710d7386",
            question: "「ICカード」の説明として正しいものはどれか？",
            choices: [
                "磁気テープにデータを記録したカード",
                "IC（集積回路）チップを内蔵し、データの読み書きができるカード",
                "インターネットに接続するためのカード",
                "クレジットカードの別名"
            ],
            correctAnswerIndex: 1,
            explanation: "ICカードは、プラスチックカードにIC（集積回路）チップを埋め込んだカードです。Suica・PASMOなどの交通系カード、マイナンバーカード、クレジットカードなどに使われています。磁気カードより大容量でセキュリティも高いです。"
        ),
        QuizQuestion(
            id: "it.4b1b9dfaa31bdc5b23e8bd67",
            question: "「スマートフォン決済（QRコード決済・タッチ決済）」の説明として正しいものはどれか？",
            choices: [
                "スマートフォンでレシートを撮影して管理すること",
                "スマートフォンを使って現金なしでキャッシュレスで支払いを行うこと",
                "スマートフォンでインターネットショッピングをすること",
                "スマートフォンを使って電話で商品を注文すること"
            ],
            correctAnswerIndex: 1,
            explanation: "スマートフォン決済は、PayPay・LINE PayなどのQRコード読み取りや、NFC（非接触通信）を使ったタッチ決済で、スマートフォンを財布代わりにキャッシュレス支払いができるサービスです。"
        ),
        QuizQuestion(
            id: "it.36fc9515a3e9e8a3488bde1f",
            question: "「情報漏洩」が発生した場合の問題として最も適切なものはどれか？",
            choices: [
                "インターネット接続ができなくなる",
                "個人情報や機密情報が外部に流出し、プライバシー侵害や信頼失墜につながる",
                "ファイルが自動的に削除される",
                "コンピュータの処理速度が低下する"
            ],
            correctAnswerIndex: 1,
            explanation: "情報漏洩は、個人情報・顧客データ・企業機密などが外部に流出する事故です。プライバシーの侵害、経済的損失、信頼失墜につながります。USBの紛失・不正アクセス・内部不正などが原因となります。"
        ),
        QuizQuestion(
            id: "it.e9397af9b7ea551f7cfe7cb4",
            question: "「e-Learning（イーラーニング）」の説明として正しいものはどれか？",
            choices: [
                "電子機器の修理を専門に行う職業",
                "学校でのプログラミング教育の総称",
                "インターネットやコンピュータを活用した学習形態",
                "電子書籍を使った読書活動"
            ],
            correctAnswerIndex: 2,
            explanation: "e-Learningは、コンピュータやインターネットを活用した学習形態です。時間・場所を選ばず、動画・テスト・教材を活用して学べます。企業研修・資格取得・語学学習など幅広く活用されています。"
        ),
        QuizQuestion(
            id: "it.7c47cc9d5e281d623f38e5ac",
            question: "「マルチメディア」の説明として正しいものはどれか？",
            choices: [
                "複数の画面でコンピュータを操作すること",
                "テキスト・画像・音声・動画など複数の媒体を組み合わせた情報表現",
                "複数のコンピュータをネットワークで繋げること",
                "複数のOSを1台のコンピュータで動かすこと"
            ],
            correctAnswerIndex: 1,
            explanation: "マルチメディアは、文字・静止画・音声・動画・アニメーションなど複数のメディア（媒体）を組み合わせてコンピュータで扱う情報表現のことです。Webサイト・デジタル教材・ゲームなどに活用されています。"
        ),
        QuizQuestion(
            id: "it.89e9675c7753cecd87ae21a6",
            question: "「オープンデータ」の説明として正しいものはどれか？",
            choices: [
                "インターネット上に違法にアップロードされたデータ",
                "企業の内部情報を社員だけが閲覧できるデータ",
                "政府や公共機関などが無償で公開し、誰でも自由に利用・再配布できるデータ",
                "パスワードなしでアクセスできるWebサイト"
            ],
            correctAnswerIndex: 2,
            explanation: "オープンデータは、政府・自治体・研究機関などが公開する、誰でも自由に利用・加工・再配布できるデータです。統計データ・地図・行政情報などが含まれ、新しいサービス開発や研究に活用されています。"
        ),
        QuizQuestion(
            id: "it.0f3a68dfffdbc39d15d5f1ef",
            question: "「スマートスピーカー（AIスピーカー）」の説明として正しいものはどれか？",
            choices: [
                "Bluetoothで接続するポータブルスピーカー",
                "音声で操作でき、AIアシスタントが質問応答や家電操作などを行うスピーカー",
                "防水機能を持つ屋外用スピーカー",
                "高音質の音楽再生専用スピーカー"
            ],
            correctAnswerIndex: 1,
            explanation: "スマートスピーカーはAIアシスタントを内蔵したスピーカーで、音声で話しかけることで天気・ニュース・音楽再生・スマート家電の操作などができます。Amazon Echo（Alexa）・Google Nest（Google アシスタント）などが代表例です。"
        ),
        QuizQuestion(
            id: "it.ce88b145570f0a006e27c1c8",
            question: "「チャットボット」の説明として正しいものはどれか？",
            choices: [
                "チャットアプリのアイコン（ボット）",
                "不正なチャットメッセージを送るウイルス",
                "自動的に会話に応答するAIプログラム",
                "チャット履歴を保存するソフトウェア"
            ],
            correctAnswerIndex: 2,
            explanation: "チャットボットは、ユーザーからのテキスト・音声の入力に対してAIが自動的に応答するプログラムです。企業のカスタマーサポート・ECサイトの問い合わせ・予約受付などに活用されています。"
        ),
        QuizQuestion(
            id: "it.df8dd441725194f3ca6af46a",
            question: "「生体認証（バイオメトリクス認証）」の説明として正しいものはどれか？",
            choices: [
                "医療機関だけで使われる認証方法",
                "生年月日を使ってログインする認証方法",
                "指紋・顔・虹彩など人体固有の特徴を使って本人を確認する認証方法",
                "ペットの情報を使って認証する方法"
            ],
            correctAnswerIndex: 2,
            explanation: "生体認証は、指紋・顔・虹彩・声紋など人体に固有の特徴を使って本人確認を行う認証方式です。パスワードのように忘れたり盗まれたりするリスクが低く、スマートフォンのロック解除や入退室管理に使われています。"
        ),
        QuizQuestion(
            id: "it.2ec83874828f087038a4fcda",
            question: "「インターネットバンキング」の説明として正しいものはどれか？",
            choices: [
                "銀行ATMでの現金引き出しサービス",
                "インターネット経由で残高照会・振込・各種手続きができる銀行サービス",
                "インターネット上で仮想通貨を管理するサービス",
                "銀行が提供するインターネット接続サービス"
            ],
            correctAnswerIndex: 1,
            explanation: "インターネットバンキングは、PCやスマートフォンからインターネット経由で残高照会・振込・定期預金・各種設定変更などの銀行手続きが行えるサービスです。24時間利用可能ですが、フィッシング詐欺への注意が必要です。"
        ),
        QuizQuestion(
            id: "it.b4c6a9dc9e8609ecb5d4ec9d",
            question: "「ストリーミング」サービスの説明として正しいものはどれか？",
            choices: [
                "データをCDに焼いて再生する方式",
                "データを受信しながらリアルタイムで再生する方式",
                "データをUSBメモリで転送する方式",
                "データを全てダウンロードしてから再生する方式"
            ],
            correctAnswerIndex: 1,
            explanation: "ストリーミングは、動画・音楽などのデータを端末にすべてダウンロードせず、受信しながら順次再生する方式です。Netflix・YouTube・Spotifyなどがこの方式を採用しており、大容量のデータを保存せずに楽しめます。"
        ),
        QuizQuestion(
            id: "it.89ce52faab2430cfcd046f6c",
            question: "「ウェアラブルデバイス」の説明として正しいものはどれか？",
            choices: [
                "洗濯できる電子機器",
                "折り畳み可能なタブレット",
                "持ち運べるノートパソコン",
                "身に着けて使用するコンピュータデバイス"
            ],
            correctAnswerIndex: 3,
            explanation: "ウェアラブルデバイスは、腕・頭・体など身体に装着して使用するコンピュータ機器の総称です。スマートウォッチ・フィットネストラッカー・スマートグラスなどが代表例で、健康管理や通知確認などに使われます。"
        ),
        QuizQuestion(
            id: "it.f9a6880c09ee3ee96ef354a4",
            question: "「メタバース」の説明として正しいものはどれか？",
            choices: [
                "AR技術を使った地図アプリ",
                "コンピュータのメモリを増設すること",
                "メタデータを管理するデータベースシステム",
                "インターネット上に構築された、人々が集まり交流できる仮想的な三次元空間"
            ],
            correctAnswerIndex: 3,
            explanation: "メタバースは、インターネット上に構築された仮想三次元空間で、アバターを通じて他者と交流したり、ゲーム・ショッピング・仕事・イベント参加などができる空間です。VRヘッドセットや一般的なPCからアクセスできます。"
        ),
        QuizQuestion(
            id: "it.17b0f44909583fe5bf804f74",
            question: "「NFC（Near Field Communication）」の説明として正しいものはどれか？",
            choices: [
                "数センチメートル以内の近距離で非接触通信できる技術",
                "次世代の光ファイバー通信規格",
                "数キロメートル先まで通信できる長距離無線技術",
                "スマートフォン専用の無線充電規格"
            ],
            correctAnswerIndex: 0,
            explanation: "NFCは10cm程度の非常に近い距離で機器同士が無線通信できる技術です。Suicaなどの交通系ICカードへのタッチ・スマートフォン決済・名刺交換などに活用されています。"
        ),
        QuizQuestion(
            id: "it.b8fc80f64068838c85b971ca",
            question: "「ネットいじめ」に関する説明として正しいものはどれか？",
            choices: [
                "オンライン広告をクリックしないこと",
                "インターネット上で商品の悪いレビューを書くこと",
                "オンラインゲームの対戦で負けること",
                "SNSや掲示板などを通じて特定の人を傷つけたり嫌がらせをしたりする行為"
            ],
            correctAnswerIndex: 3,
            explanation: "ネットいじめは、SNS・チャット・掲示板などを通じて誹謗中傷・個人情報の暴露・仲間外れなどを行う行為です。書き込みは半永久的に残る可能性があり、深刻な心理的ダメージを与えます。"
        ),
        QuizQuestion(
            id: "it.1fd0f01d57613d9e16bdcf71",
            question: "「ワンクリック詐欺」の説明として正しいものはどれか？",
            choices: [
                "サイトをクリックしただけで不当に料金を請求する詐欺",
                "マウスをクリックできなくするウイルス",
                "一クリックでパスワードを盗む攻撃",
                "一回のクリックで商品を購入させる正規サービス"
            ],
            correctAnswerIndex: 0,
            explanation: "ワンクリック詐欺は、アダルトサイトや動画サイトのリンクをクリックしただけで「登録完了」と表示し、不当な料金を請求する詐欺です。無視することが基本的な対処法で、連絡すると状況が悪化する場合があります。"
        ),
        QuizQuestion(
            id: "it.b0814f8332967f9686dbeb59",
            question: "「情報モラル」の説明として正しいものはどれか？",
            choices: [
                "コンピュータのプログラミング能力",
                "情報通信を利用する際に求められる倫理観や思いやり・マナー",
                "情報セキュリティの専門資格",
                "情報処理の技術的スキル"
            ],
            correctAnswerIndex: 1,
            explanation: "情報モラルは、SNS・メール・Web利用時に他者を傷つけない・プライバシーを守る・著作権を尊重するなど、情報社会において求められる倫理観・マナー・責任感のことです。"
        ),
        QuizQuestion(
            id: "it.305f98ce344da0e1cd767b41",
            question: "「フェイクニュース（偽情報）」への対処法として最も適切なものはどれか？",
            choices: [
                "SNSで流れてきた情報はすべて正しいのですぐシェアする",
                "インターネットの情報は全て信用しない",
                "情報源を確認し、複数の信頼できる情報源で裏付けを取ってから判断する",
                "テレビのニュースだけを信頼すればよい"
            ],
            correctAnswerIndex: 2,
            explanation: "フェイクニュース対策には、情報源（誰が発信しているか）の確認、複数の信頼できるメディアでの裏付け確認（ファクトチェック）が重要です。SNSで拡散された情報でも正確とは限りません。"
        ),
        QuizQuestion(
            id: "it.6ace8edbc49c8aceeb2e47a1",
            question: "「クラウドソーシング」の説明として正しいものはどれか？",
            choices: [
                "インターネットを通じて不特定多数の人々に仕事を発注・受注するサービス",
                "複数の会社が共同でシステムを開発すること",
                "クラウドストレージのデータを整理するサービス",
                "クラウドサービスの外部委託"
            ],
            correctAnswerIndex: 0,
            explanation: "クラウドソーシングはインターネット上で仕事の発注者と受注者をマッチングするサービスです。デザイン・ライティング・プログラミングなど様々な仕事を、場所を問わず依頼・受注できます。"
        ),
        QuizQuestion(
            id: "it.2421cd31428c6413f973cd1c",
            question: "「AIアシスタント（Siri・Googleアシスタント等）」の説明として正しいものはどれか？",
            choices: [
                "AIが自動的に株式取引を行うシステム",
                "人間のアシスタントがオンラインで作業を代行するサービス",
                "音声や文字の指示を受けてスケジュール管理・検索・操作補助などを行うAI",
                "チャット形式でプログラミングを学ぶAIサービス"
            ],
            correctAnswerIndex: 2,
            explanation: "AIアシスタントは、音声または文字での指示を理解して、天気確認・スケジュール管理・アプリ起動・調べ物などを自動で行うAIです。iPhoneのSiri、AndroidのGoogleアシスタント、AmazonのAlexaが代表例です。"
        ),
        QuizQuestion(
            id: "it.52b9fec0c3a0781226dafcdb",
            question: "「スマートシティ」の説明として正しいものはどれか？",
            choices: [
                "高層ビルが多い大都市のこと",
                "電力消費量を最小化した省エネ都市",
                "ICTやAI・IoTを活用して都市の機能を効率化し、住民の生活の質を向上させる都市",
                "スマートフォンの普及率が高い都市"
            ],
            correctAnswerIndex: 2,
            explanation: "スマートシティは、IoT・AI・ビッグデータなどのデジタル技術を都市インフラ（交通・電力・医療・行政など）に活用し、効率化・環境負荷低減・住民サービス向上を目指す次世代都市の概念です。"
        ),
        QuizQuestion(
            id: "it.65aa1fcc302bee345e77d27f",
            question: "「ドローン」のIT・社会活用例として正しいものはどれか？",
            choices: [
                "ワイヤレス充電を行う装置",
                "インターネットの通信速度を上げる装置",
                "農業・物流・災害調査・空撮などに活用される無人航空機",
                "データセンターの冷却装置"
            ],
            correctAnswerIndex: 2,
            explanation: "ドローン（無人航空機）は、農薬散布・物流配送・インフラ点検・災害時の捜索・空撮など幅広い分野で活用されています。AI・GPSと組み合わせることで自律飛行も可能です。"
        ),
        QuizQuestion(
            id: "it.cb23c9d47ceb9ec85df7ab2f",
            question: "「マイナンバー（個人番号）」の説明として正しいものはどれか？",
            choices: [
                "銀行口座の番号",
                "会社員に割り当てられる社員番号",
                "日本に住む全ての人に割り当てられた12桁の個人識別番号",
                "運転免許証の番号"
            ],
            correctAnswerIndex: 2,
            explanation: "マイナンバーは、日本に住む全ての人（外国人を含む）に割り当てられた12桁の番号で、社会保障・税・災害対策の行政手続きを効率化するために使われます。マイナンバーカードには顔写真付きICカードが使われます。"
        ),
        QuizQuestion(
            id: "it.babe9e190b811d64180fe77e",
            question: "「パスワードマネージャー」の主な目的はどれか？",
            choices: [
                "複数のサービスのパスワードを暗号化して安全に一元管理するツール",
                "パスワードを全て削除するツール",
                "パスワードを他人に共有するツール",
                "パスワードを定期的に自動変更する"
            ],
            correctAnswerIndex: 0,
            explanation: "パスワードマネージャーは、各サービスの異なるパスワードを暗号化して安全に保管し、必要なときに自動入力してくれるツールです。強力なパスワードを使い分けながら、覚える負担を軽減できます。"
        ),
        QuizQuestion(
            id: "it.cf557f1236c75b00fd152eaf",
            question: "「セキュリティパッチ」の説明として正しいものはどれか？",
            choices: [
                "ネットワークの通信を暗号化するソフトウェア",
                "ウイルス感染した際に表示される警告メッセージ",
                "発見されたソフトウェアの脆弱性（セキュリティホール）を修正するプログラム",
                "コンピュータの物理的な傷を修復するシール"
            ],
            correctAnswerIndex: 2,
            explanation: "セキュリティパッチはOSやソフトウェアで発見されたセキュリティ上の欠陥（脆弱性）を修正するためのプログラムです。適用が遅れると攻撃者に悪用されるリスクがあるため、速やかなアップデートが重要です。"
        ),
        QuizQuestion(
            id: "it.4a85bdf51abf66574f8fab1b",
            question: "「フリーウェア」と「シェアウェア」の違いとして正しいものはどれか？",
            choices: [
                "フリーウェアとシェアウェアはまったく同じ意味",
                "フリーウェアは有料で、シェアウェアは無料",
                "フリーウェアは無料で利用できるが、シェアウェアは試用後に購入が求められる",
                "フリーウェアはオープンソースで、シェアウェアはクローズドソース"
            ],
            correctAnswerIndex: 2,
            explanation: "フリーウェアは無料で使えるソフトウェアです。シェアウェアは一定期間または機能制限付きで試用でき、継続利用や全機能の使用には購入（ライセンス料の支払い）が必要なソフトウェアです。"
        ),
        QuizQuestion(
            id: "it.ca4c963a7f9986318c8eb1fc",
            question: "「ソフトウェアライセンス」の説明として正しいものはどれか？",
            choices: [
                "ソフトウェアを開発するための資格",
                "ソフトウェアの使用権・条件・制限を定めた許諾契約",
                "ソフトウェアの価格表",
                "ソフトウェアの動作環境に関する仕様書"
            ],
            correctAnswerIndex: 1,
            explanation: "ソフトウェアライセンスは、そのソフトウェアをどのような条件で使用できるかを定めた許諾契約です。インストール可能な台数・用途の制限・再配布の可否などが規定されています。無断コピーはライセンス違反になります。"
        ),
        QuizQuestion(
            id: "it.85300a4935abf701132ed6f9",
            question: "「ポッドキャスト」の説明として正しいものはどれか？",
            choices: [
                "ゲームのBGMを配信するサービス",
                "ライブ中継専用の動画配信サービス",
                "ポータブル音楽プレーヤーの一種",
                "インターネット上で配信される音声や動画のエピソードシリーズ"
            ],
            correctAnswerIndex: 3,
            explanation: "ポッドキャストは、インターネット上で配信される音声（一部動画）コンテンツのシリーズです。ニュース・教育・エンタメなど多様なジャンルがあり、スマートフォンで通勤中などにいつでも聴けるのが特徴です。"
        ),
        QuizQuestion(
            id: "it.0da345e05246c486e404f0df",
            question: "「オンライン会議ツール（Web会議）」の特徴として正しいものはどれか？",
            choices: [
                "インターネットを通じて離れた場所の人々がリアルタイムで映像・音声で会話できる",
                "同じ部屋に集まらないと利用できない",
                "テキストチャットのみで音声は使えない",
                "1対1の通話のみで複数人では利用できない"
            ],
            correctAnswerIndex: 0,
            explanation: "オンライン会議ツールは、インターネット経由でリアルタイムの映像・音声通話・画面共有・チャットができるサービスです。Zoom・Microsoft Teams・Google Meetなどが代表例で、場所を問わず会議や打ち合わせが可能です。"
        ),
        QuizQuestion(
            id: "it.11e15d83cc1d07d8ec05ae23",
            question: "「デジタルウェルネス（デジタルウェルビーイング）」の説明として正しいものはどれか？",
            choices: [
                "デジタルコンテンツで健康情報を提供するサービス",
                "高性能なデジタル医療機器のこと",
                "健康保険の電子申請サービス",
                "スマートフォンやSNSの使い過ぎを見直し、テクノロジーと健全な関係を築くこと"
            ],
            correctAnswerIndex: 3,
            explanation: "デジタルウェルネスは、スマートフォンやSNSへの過度な依存・利用時間の管理・画面の見過ぎによる睡眠障害など、テクノロジーが心身に与える影響を意識し、バランスのとれた使い方を目指す考え方です。"
        ),
    ]
}
