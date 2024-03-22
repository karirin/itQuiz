//
//  QuizITStrategyListView.swift
//  it
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

struct QuizITStrategyListView: View {
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
            question: "知的財産権における「著作権」とは、どのようなものを保護する権利か？",
            choices: [
              "発明や発見",
              "企業のロゴやブランド名",
              "文学作品や音楽作品などの創作物",
              "特定の商標やサービスマーク"
            ],
            correctAnswerIndex: 2,
            explanation: "著作権は、文学作品、音楽作品、映画、美術作品などの創作物に対して、その創作者に与えられる権利で、他人による無断の使用を制限します。"
        ),
        QuizQuestion(
            question: "組織がデータ保護のために取り組むべき基本的なセキュリティ対策は何か？",
            choices: [
              "すべての従業員をIT部門に配置する",
              "年に一度セキュリティ監査を実施する",
              "ファイアウォールとアンチウイルスの使用",
              "データのバックアップを取らない政策を採用する"
            ],
            correctAnswerIndex: 2,
            explanation: "組織がデータを保護するためには、ファイアウォールとアンチウイルスソフトウェアを使用することが基本的なセキュリティ対策として推奨されます。これにより、不正アクセスやマルウェアからデータを守ることができます。"
        ),
        QuizQuestion(
            question: "企業がビジネスプロセスを効率化し、コスト削減を実現するためによく使用するITソリューションは何か？",
            choices: [
              "ソーシャルネットワークサービス",
              "エンタープライズリソースプランニング（ERP）システム",
              "パーソナルコンピュータ",
              "仮想現実（VR）技術"
            ],
            correctAnswerIndex: 1,
            explanation: "エンタープライズリソースプランニング（ERP）システムは、企業の財務管理、人事、製造、供給チェーン管理など、さまざまなビジネスプロセスを統合し、効率化およびコスト削減を実現するために広く使用されています。"
        ),
        QuizQuestion(
            question: "プライバシーマーク制度の目的は何か？",
            choices: [
              "企業の収益向上を支援する",
              "個人情報の適切な保護と管理を行う組織に与えられる認証マーク",
              "企業の製品品質を保証する",
              "企業のセキュリティレベルを評価する"
            ],
            correctAnswerIndex: 1,
            explanation: "プライバシーマーク制度は、個人情報の適切な保護と管理を行っていることを示す認証マークであり、消費者に対してその組織が個人情報を適切に扱っていることを示すために用いられます。"
        )
            ,

        QuizQuestion(
            question: "ビジネスコンティニュイティ計画（BCP）の主な目的は何か？",
            choices: [
              "経営者の責任を軽減する",
              "ITシステムの更新頻度を高める",
              "災害発生時に事業を継続するための準備",
              "従業員の業務効率を向上させる"
            ],
            correctAnswerIndex: 2,
            explanation: "ビジネスコンティニュイティ計画（BCP）は、災害や緊急事態が発生した際に事業の中断を最小限に抑え、迅速な事業の再開と継続を可能にするための計画です。"
        ),
        QuizQuestion(
            question: "ブロックチェーン技術の特徴として正しいものはどれか？",
            choices: [
              "中央集権的管理が必要",
              "データの改ざんが容易",
              "トランザクションの透明性と不変性を提供",
              "高速なデータ処理速度"
            ],
            correctAnswerIndex: 2,
            explanation: "ブロックチェーン技術は、データの改ざんが困難であり、トランザクションの透明性と不変性を提供することが特徴です。これにより、信頼性の高いデジタルトランザクションが可能になります。"
        ),
        QuizQuestion(
            question: "サイバーセキュリティにおいて「フィッシング」はどのような攻撃か？",
            choices: [
              "システムの脆弱性を利用した攻撃",
              "偽の電子メールやウェブサイトを使用して個人情報を盗む攻撃",
              "大量のデータを不正にダウンロードする攻撃",
              "ウイルスやマルウェアを配布する攻撃"
            ],
            correctAnswerIndex: 1,
            explanation: "フィッシングは、偽の電子メールやウェブサイトを通じて、ユーザーから個人情報や金融情報を騙し取る詐欺的な攻撃方法です。"
        ),
        QuizQuestion(
            question: "ソフトウェア開発における「ウォーターフォールモデル」とは何か？",
            choices: [
              "継続的なフィードバックを取り入れる反復的な開発プロセス",
              "開発の各段階を順番に進める線形的な開発モデル",
              "ランダムにタスクを選択して進める柔軟な開発手法",
              "ユーザー参加型の開発プロセス"
            ],
            correctAnswerIndex: 1,
            explanation: "ウォーターフォールモデルは、ソフトウェア開発のプロセスを要件定義、設計、実装、テスト、運用という順番で線形に進める開発モデルです。各段階が完了するまで次の段階に進めません。"
        ),

        QuizQuestion(
            question: "情報システムの導入プロジェクトでリスク管理を行う主な理由は何か？",
            choices: [
              "プロジェクトのコストを増加させるため",
              "プロジェクトの進行を遅らせるため",
              "予期せぬ問題への対応計画を準備するため",
              "プロジェクトチームのモチベーションを高めるため"
            ],
            correctAnswerIndex: 2,
            explanation: "リスク管理は、予期せぬ問題が発生した場合に備えて対応計画を準備することで、プロジェクトのリスクを最小限に抑えることを目的としています。"
        ),
        QuizQuestion(
            question: "IT戦略策定において重要なのは、次のうちどれか？",
            choices: [
              "競争相手の戦略をコピーすること",
              "最新技術を盲目的に導入すること",
              "ビジネス目標とIT目標の整合性を確保すること",
              "IT予算を可能な限り削減すること"
            ],
            correctAnswerIndex: 2,
            explanation: "IT戦略策定の際には、ビジネス目標とIT目標が一致していることを確認し、ビジネスの成功を支えるITの活用を目指すことが重要です。"
        ),
        QuizQuestion(
            question: "情報システムの監査の目的は何か？",
            choices: [
              "すべてのシステムエラーを特定すること",
              "情報システムの効率性と有効性を評価すること",
              "IT部門のスタッフを評価すること",
              "未使用のソフトウェアライセンスを削減すること"
            ],
            correctAnswerIndex: 1,
            explanation: "情報システムの監査の目的は、システムの効率性、有効性、セキュリティ、および規制遵守の状況を評価し、改善のための推奨事項を提供することです。"
        ),
        QuizQuestion(
            question: "クラウドサービスモデル「PaaS」の特徴は何か？",
            choices: [
              "インフラストラクチャのみを提供する",
              "アプリケーションの実行環境を提供する",
              "ソフトウェアアプリケーションを提供する",
              "ネットワーク機器を提供する"
            ],
            correctAnswerIndex: 1,
            explanation: "PaaS（Platform as a Service）は、アプリケーションの開発、テスト、デプロイメント、管理を行うためのプラットフォームと環境を提供します。"
        ),

        QuizQuestion(
            question: "情報技術基盤ライブラリ（ITIL）の目的は何か？",
            choices: [
              "情報セキュリティ管理体制を構築する",
              "ITサービス管理のベストプラクティスを提供する",
              "プログラミングスキルを向上させる",
              "ITプロジェクトの開発速度を向上させる"
            ],
            correctAnswerIndex: 1,
            explanation: "ITILの目的は、ITサービス管理（ITSM）におけるベストプラクティスを提供し、組織が効率的かつ効果的なITサービスを提供するのを支援することです。"
        ),
        QuizQuestion(
            question: "非機能要件とは何か？",
            choices: [
              "システムが実行する具体的な機能やタスク",
              "システムの性能や信頼性などの品質属性",
              "開発プロジェクトのコスト",
              "ユーザーインターフェースのデザイン"
            ],
            correctAnswerIndex: 1,
            explanation: "非機能要件は、システムの性能、信頼性、保守性などの品質属性を指し、システムがどのように動作するかを定義します。"
        ),
        QuizQuestion(
            question: "マルチテナンシーとは何か？",
            choices: [
              "複数の顧客が単一のインスタンスのソフトウェアを共有すること",
              "一つの企業が複数のITサービスを同時に利用すること",
              "一つのデータセンターを複数の企業が共有すること",
              "ソフトウェアが複数のプラットフォームで動作すること"
            ],
            correctAnswerIndex: 0,
            explanation: "マルチテナンシーは、クラウドコンピューティングなどの環境において、複数の顧客（テナント）が同一のアプリケーションインスタンスやインフラを共有することを指します。"
        ),
        QuizQuestion(
            question: "ステークホルダー管理の主な目的は何か？",
            choices: [
              "すべてのステークホルダーをプロジェクトから排除する",
              "ステークホルダーの期待とプロジェクトの目標を調和させる",
              "プロジェクトの利益を最大化する",
              "ステークホルダーの数を最小限に抑える"
            ],
            correctAnswerIndex: 1,
            explanation: "ステークホルダー管理の主な目的は、ステークホルダーの期待とプロジェクトの目標を調和させ、関係者間のコミュニケーションを効果的に管理することです。"
        ),

        QuizQuestion(
            question: "顧客関係管理（CRM）システムの主な利点は何か？",
            choices: [
              "生産プロセスの自動化",
              "顧客との関係強化と顧客満足度の向上",
              "セキュリティの強化",
              "製品の品質向上"
            ],
            correctAnswerIndex: 1,
            explanation: "CRMシステムの主な利点は、顧客データを統合し分析することで顧客との関係を強化し、顧客満足度を向上させることです。"
        ),
        QuizQuestion(
            question: "ITガバナンスの目的は何か？",
            choices: [
              "ITリスクを最小限に抑える",
              "ITとビジネス戦略の整合性を確保する",
              "ITコストを削減する",
              "ITプロジェクトの成功率を高める"
            ],
            correctAnswerIndex: 1,
            explanation: "ITガバナンスの目的は、ITとビジネス戦略の整合性を確保し、IT投資の価値を最大化し、ビジネスリスクを管理することです。"
        ),
        QuizQuestion(
            question: "プロジェクトマネジメントで用いられる「トリプルコンストレイント」とは何を指すか？",
            choices: [
              "スコープ、品質、リスク",
              "スコープ、時間、コスト",
              "時間、コスト、品質",
              "リスク、コスト、時間"
            ],
            correctAnswerIndex: 1,
            explanation: "トリプルコンストレイントは、プロジェクトのスコープ、時間、コストの三つの制約条件を指し、これらのバランスを管理することがプロジェクト成功の鍵です。"
        ),
        QuizQuestion(
            question: "ビジネスプロセスリエンジニアリング（BPR）の目的は何か？",
            choices: [
              "従業員の生産性を向上させる",
              "組織内の情報流通を改善する",
              "ビジネスプロセスを根本から再設計し、効率化する",
              "新しいビジネスモデルを開発する"
            ],
            correctAnswerIndex: 2,
            explanation: "BPRの目的は、既存のビジネスプロセスを根本から見直し、再設計することで効率を大幅に向上させることにあります。"
        ),
        QuizQuestion(
            question: "ERP（Enterprise Resource Planning）システムの主な目的は何か？",
            choices: [
              "企業の財務管理を強化する",
              "顧客関係管理を改善する",
              "企業のリソースを統合し効率化する",
              "企業のセキュリティ体制を向上させる"
            ],
            correctAnswerIndex: 2,
            explanation: "ERPシステムの主な目的は、財務、製造、人事、供給チェーンなど企業の様々なリソースを統合し、全体の運営を効率化することです。"
        ),
//        QuizQuestion(
//            question: "デジタルトランスフォーメーション（DX）の推進において重要なのは、次のうちどれか？",
//            choices: [
//              "従来の業務プロセスの維持",
//              "テクノロジーの選択と導入",
//              "組織文化の変革",
//              "短期的な利益の最大化"
//            ],
//            correctAnswerIndex: 2,
//            explanation: "デジタルトランスフォーメーションを成功させるには、テクノロジーの導入だけでなく、組織文化の変革も重要です。これにより、変化に適応し続ける柔軟な組織を作ることができます。"
//        ),
//        QuizQuestion(
//            question: "情報セキュリティ管理で最も重要な原則は何か？",
//            choices: [
//              "機密性、完全性、可用性",
//              "監査性、責任追跡性、透明性",
//              "スケーラビリティ、パフォーマンス、信頼性",
//              "コスト削減、効率化、利益最大化"
//            ],
//            correctAnswerIndex: 0,
//            explanation: "情報セキュリティ管理の最も基本的な原則は「機密性、完全性、可用性」です。これらはセキュリティの三要素として知られ、情報資産を保護する上で極めて重要です。"
//        ),
//        QuizQuestion(
//            question: "ビッグデータの3Vとは何を指すか？",
//            choices: [
//              "速度（Velocity）、容量（Volume）、種類（Variety）",
//              "可視性（Visibility）、価値（Value）、ボリューム（Volume）",
//              "検証（Verification）、価値（Value）、多様性（Variety）",
//              "ボリューム（Volume）、速度（Velocity）、多様性（Variety）"
//            ],
//            correctAnswerIndex: 3,
//            explanation: "ビッグデータの3Vは「ボリューム（Volume：大量のデータ）、速度（Velocity：高速なデータ処理）、多様性（Variety：さまざまな形式のデータ）」を指し、ビッグデータを特徴づける主な要素です。"
//        ),
//
//        QuizQuestion(
//            question: "ポーターの5つの力モデルにおいて、新規参入の脅威が低い業界の特徴は何か？",
//            choices: [
//              "参入障壁が低い",
//              "市場が成熟している",
//              "参入障壁が高い",
//              "競争が少ない"
//            ],
//            correctAnswerIndex: 2,
//            explanation: "ポーターの5つの力モデルでは、参入障壁が高い業界では新規参入の脅威が低く、既存の企業はより安定した競争環境を享受できます。"
//        ),
//        QuizQuestion(
//            question: "バランススコアカードの4つの視点は何か？",
//            choices: [
//              "財務、顧客、内部プロセス、学習と成長",
//              "財務、市場、効率性、イノベーション",
//              "顧客、競争、技術、財務",
//              "市場、効率性、人材、研究開発"
//            ],
//            correctAnswerIndex: 0,
//            explanation: "バランススコアカードは、財務、顧客、内部プロセス、学習と成長の4つの視点から組織のパフォーマンスを測定するフレームワークです。"
//        ),
//        QuizQuestion(
//            question: "クラウドコンピューティングの導入がビジネスにもたらす主な利点は何か？",
//            choices: [
//              "データセキュリティの強化",
//              "固定費の削減と柔軟なスケーリング",
//              "ITスタッフの増員",
//              "ハードウェアの耐久性向上"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "クラウドコンピューティングを採用することで、企業は固定費を削減し、需要に応じてリソースを柔軟にスケーリングすることができます。"
//        ),
//        QuizQuestion(
//            question: "アジャイル開発方法論の特徴は何か？",
//            choices: [
//              "事前に詳細な計画を立てる",
//              "変更に対して柔軟に対応する",
//              "長期のプロジェクトスケジュールに従う",
//              "一度に大きなリリースを行う"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "アジャイル開発方法論は、変更に対して柔軟に対応し、短い開発サイクル（スプリント）を通じて頻繁に製品をリリースすることを特徴とします。"
//        ),
//
//        QuizQuestion(
//            question: "ビジネスにおけるIT戦略の主な目的は何か？",
//            choices: [
//              "技術の進化に対応する",
//              "企業の業績を向上させる",
//              "新しいITシステムの導入",
//              "セキュリティリスクを管理する"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "ビジネスにおけるIT戦略の主な目的は、情報技術を活用して企業の業績を向上させることです。"
//        ),
//        QuizQuestion(
//            question: "SWOT分析において「O」は何を表すか？",
//            choices: [
//              "弱点",
//              "機会",
//              "脅威",
//              "強み"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "SWOT分析において「O」は機会（Opportunities）を表し、外部環境に存在する、活用すれば組織に利益をもたらす可能性のある要素です。"
//        ),
//        QuizQuestion(
//            question: "情報システム投資の効果を測定するために一般的に使用される指標は何か？",
//            choices: [
//              "顧客満足度",
//              "ROI（投資収益率）",
//              "市場シェア",
//              "従業員の生産性"
//            ],
//            correctAnswerIndex: 1,
//            explanation: "ROI（Return on Investment）は、投資によって得られた利益を投資額で割って計算することで、情報システム投資の効果を測定するために一般的に使用される指標です。"
//        ),
//        QuizQuestion(
//            question: "プロジェクトマネジメントにおいて、プロジェクトの範囲を定義する重要性は何か？",
//            choices: [
//              "コストを削減する",
//              "リスクを特定する",
//              "プロジェクトの目標と成果物を明確にする",
//              "利害関係者の期待を管理する"
//            ],
//            correctAnswerIndex: 2,
//            explanation: "プロジェクトの範囲を定義することは、プロジェクトの目標と成果物を明確にし、それによってプロジェクトチームの作業方向性を統一する上で重要です。"
//        )



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
        QuizView(quizzes: shuffledQuizList, quizLevel: .itStrategy, authManager: authManager, audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
    }
}

struct QuizITStrategyListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizITStrategyListView(isPresenting: .constant(false))
    }
}

