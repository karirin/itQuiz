//
//  QuizITManagementListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct QuizITManagementListView: View {
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
           question: "プロジェクト管理において、コミュニケーション計画が重要である理由は何か？",
           choices: [
             "プロジェクトの費用を計算するため",
             "全ステークホルダー間で情報が正確かつタイムリーに共有されることを保証するため",
             "プロジェクトチームの会議をスケジュールするため",
             "最新の技術トレンドについて学ぶため"
           ],
           correctAnswerIndex: 1,
           explanation: "コミュニケーション計画は、プロジェクトに関わるすべてのステークホルダー間で情報が正確かつ迅速に共有されることを保証し、誤解を防ぎ、プロジェクトの成功をサポートするために重要です。"
       ),
         QuizQuestion(
           question: "ITサービス管理（ITSM）において「サービスレベル管理」の役割は何か？",
           choices: [
             "新しいITサービスを開発する",
             "ITサービスとビジネス要件の間の合意されたレベルのサービスを維持する",
             "ITスタッフのトレーニングを管理する",
             "ソフトウェアライセンスを監査する"
           ],
           correctAnswerIndex: 1,
           explanation: "サービスレベル管理は、ITサービスとビジネスユーザー間のサービスレベル合意（SLA）に基づき、合意されたレベルのサービスが提供され続けることを保証する役割を持ちます。"
       ),
         QuizQuestion(
           question: "「ビッグデータ」の分析がビジネスに提供する主な価値は何か？",
           choices: [
             "従業員の個人情報の保護",
             "データストレージコストの削減",
             "意思決定プロセスの改善と新しいビジネス機会の発見",
             "社内のITインフラの管理"
           ],
           correctAnswerIndex: 2,
           explanation: "ビッグデータの分析は、膨大なデータセットから価値ある洞察を引き出し、意思決定プロセスを改善し、未探索のビジネス機会を発見することで、ビジネスに大きな価値を提供します。"
       ),
         QuizQuestion(
           question: "「クラウドコンピューティング」の主要なサービスモデルでないものは何か？",
           choices: [
             "ソフトウェアアズアサービス（SaaS）",
             "プラットフォームアズアサービス（PaaS）",
             "インフラストラクチャアズアサービス（IaaS）",
             "データアズアサービス（DaaS）"
           ],
           correctAnswerIndex: 3,
           explanation: "クラウドコンピューティングの主要なサービスモデルにはSaaS、PaaS、IaaSがありますが、「データアズアサービス（DaaS）」は一般的に認識されている主要なサービスモデルではありません。"
       ),

         QuizQuestion(
           question: "情報システム投資の効果を評価する際に用いられる指標の一つは何か？",
           choices: [
             "総所有コスト（TCO）",
             "平均処理時間",
             "システムアップタイム率",
             "データ転送速度"
           ],
           correctAnswerIndex: 0,
           explanation: "総所有コスト（TCO）は、情報システム投資の効果を評価する際に考慮される重要な指標であり、システムの購入、導入、運用、保守までの全コストを含みます。"
       ),
         QuizQuestion(
           question: "組織における知識管理の主な目的は何か？",
           choices: [
             "組織の知識を集約し、共有する",
             "従業員の社会保障番号を管理する",
             "組織の利益を最大化する",
             "コンピュータウイルスから保護する"
           ],
           correctAnswerIndex: 0,
           explanation: "知識管理の主な目的は、組織内で培われた知識を集約し、効果的に共有・活用することによって、組織全体のパフォーマンス向上を図ることです。"
       ),
         QuizQuestion(
           question: "組織がデジタル化を推進する主な理由は何か？",
           choices: [
             "紙の使用を増やすため",
             "プロセス効率化と意思決定の改善",
             "従業員の退職を促す",
             "外部とのコミュニケーションを制限する"
           ],
           correctAnswerIndex: 1,
           explanation: "組織がデジタル化を推進する主な理由は、業務プロセスの効率化を図り、データに基づいた迅速かつ正確な意思決定を支援することにあります。"
       ),
         QuizQuestion(
           question: "リスクマネジメントプロセスにおいて、リスク評価後に通常行われるステップは何か？",
           choices: [
             "リスクの無視",
             "リスク対応計画の策定",
             "リスク評価のやり直し",
             "プロジェクトの中止"
           ],
           correctAnswerIndex: 1,
           explanation: "リスク評価の後、リスク対応計画を策定することは、識別されたリスクに対して効果的な管理策を定め、リスクの影響を最小限に抑えるための重要なステップです。"
       ),

         QuizQuestion(
           question: "経営戦略の立案において、外部環境分析に用いられるフレームワークは何か？",
           choices: [
             "バランススコアカード",
             "SWOT分析",
             "PEST分析",
             "5フォースモデル"
           ],
           correctAnswerIndex: 2,
           explanation: "PEST分析は、政治（Political）、経済（Economic）、社会（Social）、技術（Technological）の観点から外部環境を分析するフレームワークであり、経営戦略の立案に有効です。"
       ),
         QuizQuestion(
           question: "ITプロジェクトにおけるスコープクリープを防止するための最良の方法は何か？",
           choices: [
             "全ての要求を最初から受け入れる",
             "プロジェクト計画を一度も変更しない",
             "要求管理プロセスを確立する",
             "プロジェクトの終了後に要求を評価する"
           ],
           correctAnswerIndex: 2,
           explanation: "要求管理プロセスを確立することで、プロジェクトのスコープに関する変更を適切に管理し、スコープクリープを防止することができます。"
       ),
         QuizQuestion(
           question: "ビジネスプロセス管理（BPM）の主な目的は何か？",
           choices: [
             "従業員のモチベーションを向上させる",
             "ビジネスプロセスを通じて組織のパフォーマンスを向上させる",
             "新しいビジネスモデルを開発する",
             "組織内の情報技術（IT）の使用を制限する"
           ],
           correctAnswerIndex: 1,
           explanation: "ビジネスプロセス管理（BPM）は、ビジネスプロセスを効果的に設計、実装、監視、最適化することで、組織のパフォーマンスと効率性を向上させることを目指しています。"
       ),
         QuizQuestion(
           question: "クラウドサービスモデル「IaaS」の特徴は何か？",
           choices: [
             "アプリケーションの提供",
             "プラットフォームの提供",
             "インフラストラクチャの提供",
             "ソフトウェアの開発ツールの提供"
           ],
           correctAnswerIndex: 2,
           explanation: "IaaS（Infrastructure as a Service）は、仮想化されたコンピューティングリソースをインターネット経由で提供するクラウドサービスモデルです。これにより、ユーザーはサーバー、ストレージ、ネットワークなどのインフラストラクチャを必要に応じて利用できます。"
       ),

         QuizQuestion(
           question: "マネジメントにおける「PDCAサイクル」の目的は何か？",
           choices: [
             "プロジェクトの初期計画のみを行う",
             "組織の利益を最大化する",
             "継続的な改善プロセスを実施する",
             "従業員の業務負担を軽減する"
           ],
           correctAnswerIndex: 2,
           explanation: "PDCAサイクルは、プラン（Plan）、ドゥ（Do）、チェック（Check）、アクト（Act）の4段階で構成され、継続的な改善プロセスを実現することを目的としています。"
       ),
         QuizQuestion(
           question: "情報セキュリティマネジメントシステム（ISMS）の導入が目指す主な目標は何か？",
           choices: [
             "全てのセキュリティインシデントを完全に排除する",
             "組織の情報セキュリティを継続的に改善する",
             "セキュリティ対策のコストを削減する",
             "組織の情報セキュリティ責任者を指名する"
           ],
           correctAnswerIndex: 1,
           explanation: "ISMSの導入目標は、組織の情報セキュリティを管理し、リスクを適切に評価、処理して継続的に改善することにあります。"
       ),
         QuizQuestion(
           question: "アジャイル開発方法論における主な特徴は何か？",
           choices: [
             "計画に厳密に従うこと",
             "変更に対する柔軟性と迅速な適応",
             "プロジェクトの開始前にすべての要件を定義する",
             "長期的なプロジェクト計画の重視"
           ],
           correctAnswerIndex: 1,
           explanation: "アジャイル開発方法論は、変更に対して柔軟に対応し、迅速に適応することを重視します。これにより、顧客のニーズに合わせた製品やサービスを効率的に提供できます。"
       ),
         QuizQuestion(
           question: "「KPI（重要業績評価指標）」を設定する主な理由は何か？",
           choices: [
             "従業員に対する報酬の決定",
             "組織の目標達成度を測定し、管理する",
             "組織の弱点のみを特定する",
             "競合他社との比較"
           ],
           correctAnswerIndex: 1,
           explanation: "KPIの設定は、組織の戦略的目標に対する進捗状況を測定し、管理するために行われます。これにより、目標達成に向けた具体的な行動が促されます。"
       ),

         QuizQuestion(
           question: "経営資源計画（ERP）システムの導入によって期待される主な利点は何か？",
           choices: [
             "社内の文書管理のみを改善する",
             "経営資源の統合とプロセスの効率化",
             "従業員の満足度を測定する",
             "競合他社の戦略を分析する"
           ],
           correctAnswerIndex: 1,
           explanation: "ERPシステムの導入は、財務、人事、製造、供給チェーン管理など、企業内の様々な業務プロセスを統合し、全体の効率化を図ることが主な目的です。"
       ),
         QuizQuestion(
           question: "ビジネスインテリジェンス（BI）ツールの使用が企業にもたらす主な利点は何か？",
           choices: [
             "全従業員の生産性を個別に向上させる",
             "データからの洞察を通じて意思決定を支援する",
             "顧客データのプライバシーを保護する",
             "企業のITインフラストラクチャを簡素化する"
           ],
           correctAnswerIndex: 1,
           explanation: "ビジネスインテリジェンス（BI）ツールは、膨大なデータを分析し、そのデータから洞察を得ることで、より良い意思決定を行うのを支援します。"
       ),
         QuizQuestion(
           question: "デジタルトランスフォーメーションの目的は何か？",
           choices: [
             "既存のITシステムの完全な廃止",
             "新しいテクノロジーの採用によるビジネスモデルの変革",
             "全従業員に対するデジタルデバイスの提供",
             "社内プロセスの文書化のみ"
           ],
           correctAnswerIndex: 1,
           explanation: "デジタルトランスフォーメーションの目的は、新しいデジタルテクノロジーを採用し、それを活用してビジネスモデルを変革し、顧客体験を改善することにあります。"
       ),
         QuizQuestion(
           question: "プロジェクトの成功を評価する際に重要な指標は何か？",
           choices: [
             "プロジェクトの開始日のみ",
             "予算内での完了、時間内での完了、および目標の達成",
             "使用されたテクノロジーの種類",
             "プロジェクトチームの人数"
           ],
           correctAnswerIndex: 1,
           explanation: "プロジェクトの成功は、予算内での完了、時間内での完了、およびプロジェクトの目標の達成という三つの主要な指標によって測定されます。"
       ),

         QuizQuestion(
           question: "組織の内部統制の一環として実施される「セグリゲーション・オブ・デューティーズ（職務の分離）」の主な目的は何か？",
           choices: [
             "業務効率の向上",
             "職員のスキル向上",
             "不正行為や誤りのリスクの軽減",
             "コミュニケーションの促進"
           ],
           correctAnswerIndex: 2,
           explanation: "職務の分離は、一人の個人が業務プロセスの重要な側面を完全に制御することを防ぎ、不正行為や誤りのリスクを軽減することを目的としています。"
       ),
         QuizQuestion(
           question: "企業がクラウドコンピューティングを採用する主な理由は何か？",
           choices: [
             "データのローカル保存を強化するため",
             "ITリソースへのアクセスを制限するため",
             "コスト削減とスケーラビリティ",
             "社内ITスタッフの数を増やすため"
           ],
           correctAnswerIndex: 2,
           explanation: "クラウドコンピューティングを採用する主な理由は、コストの削減と資源の需要に基づいてリソースをスケールアップまたはスケールダウンできるスケーラビリティを実現するためです。"
       ),
         QuizQuestion(
           question: "「バランススコアカード」の目的は何か？",
           choices: [
             "組織の財務状況のみを評価する",
             "従業員のパフォーマンスを個別に評価する",
             "組織のパフォーマンスを複数の視点から総合的に評価する",
             "市場の競争状況を分析する"
           ],
           correctAnswerIndex: 2,
           explanation: "バランススコアカードは、財務、顧客、内部プロセス、学習と成長の4つの視点から組織のパフォーマンスを総合的に評価するフレームワークです。"
       ),
         QuizQuestion(
           question: "「ポートフォリオ管理」における主な目的は何か？",
           choices: [
             "個々のプロジェクトの成功のみを保証する",
             "プロジェクトマネージャーのスキルを向上させる",
             "組織全体の戦略的目標達成に貢献するプロジェクトの選定と管理",
             "ITインフラの維持管理"
           ],
           correctAnswerIndex: 2,
           explanation: "ポートフォリオ管理の目的は、組織の戦略的目標と密接に関連するプロジェクトやプログラムを選定し、これらを効果的に管理することで、組織の全体的な目標達成を支援することです。"
       ),

         QuizQuestion(
           question: "ビジネスプロセスの再設計(BPR)の主な目的は何か？",
           choices: [
             "従業員の満足度を向上させる",
             "組織の文化を変革する",
             "プロセスを根本から見直し、劇的なパフォーマンス改善を達成する",
             "既存のITシステムを最大限に活用する"
           ],
           correctAnswerIndex: 2,
           explanation: "ビジネスプロセスの再設計(BPR)は、企業の業務プロセスを根本から再考し、劇的な改善を目指すことを目的としています。これにより、コスト削減、サービスの質の向上、時間の短縮などの効果が期待されます。"
       ),
         QuizQuestion(
           question: "ITガバナンスの目的は何か？",
           choices: [
             "IT投資の回収期間を短縮する",
             "ITリソースの効果的な管理と利用を保証する",
             "IT部門の人員を削減する",
             "全てのITプロジェクトを内製化する"
           ],
           correctAnswerIndex: 1,
           explanation: "ITガバナンスの目的は、ITリソースの効果的な管理と利用を通じて、組織の戦略と目標の達成を支援することにあります。これには、リスクの管理、リソースの最適化、価値の提供が含まれます。"
       ),
         QuizQuestion(
           question: "データマイニングとは何か？",
           choices: [
             "データセンターの物理的な構造を設計するプロセス",
             "大量のデータからパターンや知識を抽出するプロセス",
             "データベースから不要なデータを削除するプロセス",
             "データを暗号化するプロセス"
           ],
           correctAnswerIndex: 1,
           explanation: "データマイニングは、大量のデータセットを分析して、隠れたパターン、関連性、またはトレンドを見つけ出すプロセスです。これは、意思決定支援に役立つ貴重な洞察を提供します。"
       ),
         QuizQuestion(
           question: "ITプロジェクトにおけるステークホルダーマネジメントの目的は何か？",
           choices: [
             "プロジェクトのスコープを決定する",
             "ステークホルダーの期待を管理し、満足させる",
             "プロジェクトのコストを管理する",
             "プロジェクトのリスクを評価する"
           ],
           correctAnswerIndex: 1,
           explanation: "ステークホルダーマネジメントの目的は、プロジェクトに関わるすべてのステークホルダーの期待を理解し、適切に管理して、彼らの要求と満足を確保することです。これにより、プロジェクトの成功率が高まります。"
       ),

         QuizQuestion(
           question: "効果的なリーダーシップスタイルを選択する際に考慮すべき要因は何か？",
           choices: [
             "リーダーの個人的な好みのみ",
             "プロジェクトの予算とスケジュール",
             "チームメンバーのスキルとモチベーション",
             "プロジェクトの地理的な位置"
           ],
           correctAnswerIndex: 2,
           explanation: "効果的なリーダーシップスタイルを選択する際には、チームメンバーのスキルセットとモチベーションを考慮することが重要です。これにより、チームの生産性と満足度を最大化できます。"
       ),
         QuizQuestion(
           question: "組織における情報セキュリティポリシーの目的は何か？",
           choices: [
             "すべての従業員にITスキルを提供する",
             "情報資産の保護とセキュリティ違反の予防",
             "組織の収益を増加させる",
             "競合他社との情報共有"
           ],
           correctAnswerIndex: 1,
           explanation: "情報セキュリティポリシーの主な目的は、組織の情報資産を保護し、セキュリティ違反を予防することにあります。これにより、機密性、完全性、可用性が保たれます。"
       ),
         QuizQuestion(
           question: "「アウトソーシング」の主な利点は何か？",
           choices: [
             "組織内のコミュニケーションを改善する",
             "組織のコアビジネスに集中し、コスト削減を実現する",
             "すべての業務を社内で完結させる",
             "新しい技術の導入を避ける"
           ],
           correctAnswerIndex: 1,
           explanation: "アウトソーシングは、非核心業務を外部の専門企業に委託することで、組織がコアビジネスに集中し、運営コストの削減を図ることができる主な利点があります。"
       ),
         QuizQuestion(
           question: "プロジェクト管理における「クリティカルパス」とは何か？",
           choices: [
             "プロジェクト完了に最も短い時間を要する一連の活動",
             "最もコストがかかる活動のシーケンス",
             "リスクが最も高い活動のリスト",
             "プロジェクトチームにとって最も重要なタスク"
           ],
           correctAnswerIndex: 0,
           explanation: "クリティカルパスは、プロジェクト完了に最も長い時間を要する一連の依存関係のあるタスクです。これを特定することで、プロジェクトの最短完了時間を計算することができます。"
       ),

         QuizQuestion(
           question: "プロジェクトのリスク管理プロセスにおいて、リスクの特定後に行うべき次のステップは何か？",
           choices: [
             "リスクの定量化",
             "リスク対策の実施",
             "リスクの評価",
             "リスクモニタリング"
           ],
           correctAnswerIndex: 2,
           explanation: "リスクの特定後、それらのリスクを評価することで、リスクの影響と発生確率を理解し、適切な管理策を計画できます。"
       ),
         QuizQuestion(
           question: "プロジェクトチーム内でコミュニケーションを改善するために役立つツールはどれか？",
           choices: [
             "PERTチャート",
             "ガントチャート",
             "ステークホルダー分析",
             "デイリースタンドアップミーティング"
           ],
           correctAnswerIndex: 3,
           explanation: "デイリースタンドアップミーティングは、チームメンバーが進捗状況を共有し、障害を迅速に識別するための効果的なコミュニケーション手法です。"
       ),
         QuizQuestion(
           question: "変更管理において、変更リクエストが承認された後に行うべきプロセスは何か？",
           choices: [
             "変更の実施",
             "変更の監査",
             "変更の記録",
             "変更のレビュー"
           ],
           correctAnswerIndex: 0,
           explanation: "変更リクエストが承認された後、計画に従ってその変更を実施する必要があります。これにより、変更が管理された状態で適切に行われます。"
       ),
         QuizQuestion(
           question: "情報システムの監査において主に評価されるのはどれか？",
           choices: [
             "組織の利益",
             "システムの利用者満足度",
             "システムのセキュリティと効率性",
             "システムの開発コスト"
           ],
           correctAnswerIndex: 2,
           explanation: "情報システムの監査では、主にシステムのセキュリティ、信頼性、データの整合性、効率性が評価されます。"
       ),

         QuizQuestion(
           question: "プロジェクトマネジメントにおいて、プロジェクトの範囲を定義し、管理するプロセスを何というか？",
           choices: [
             "スコープマネジメント",
             "コストマネジメント",
             "タイムマネジメント",
             "クオリティマネジメント"
           ],
           correctAnswerIndex: 0,
           explanation: "スコープマネジメントは、プロジェクトの範囲を明確に定義し、その範囲内でプロジェクトが進行するようにするためのプロセスです。"
       ),
         QuizQuestion(
           question: "組織の情報セキュリティを維持するために、従業員に対して定期的に行うべきはどれか？",
           choices: [
             "ネットワークの監視",
             "セキュリティポリシーの更新",
             "セキュリティ教育と訓練",
             "システムの自動更新"
           ],
           correctAnswerIndex: 2,
           explanation: "セキュリティ教育と訓練は、従業員が情報セキュリティの重要性を理解し、セキュリティ違反を防ぐための行動を取ることができるようにするために必要です。"
       ),
         QuizQuestion(
           question: "ITサービスマネジメント（ITSM）フレームワークで知られているものはどれか？",
           choices: [
             "SCRUM",
             "ISO 27001",
             "ITIL",
             "COBIT"
           ],
           correctAnswerIndex: 2,
           explanation: "ITIL（ITインフラストラクチャライブラリ）は、ITサービスマネジメント（ITSM）のベストプラクティスを提供するフレームワークです。"
       ),
         QuizQuestion(
           question: "SWOT分析において、組織の内部環境を評価するために分析される2つの要素は何か？",
           choices: [
             "強みと機会",
             "強みと脅威",
             "強みと弱み",
             "機会と脅威"
           ],
           correctAnswerIndex: 2,
           explanation: "SWOT分析では、組織の内部環境を評価するために「強み（Strengths）」と「弱み（Weaknesses）」が分析されます。"
       )


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
        QuizView(quizzes: shuffledQuizList, quizLevel: .itManagement, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizITManagementListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizITManagementListView(isPresenting: .constant(false))
    }
}