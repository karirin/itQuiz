import Foundation

/// ITパスポートの定番テーマで操作と解説を体験する。3問の成績から資格全体の実力は推定しない。
enum InitialPracticeContent {
    static let practiceVersion = "it_passport_basics_v1"
    static let stepTitles = ["経営戦略", "情報セキュリティ", "ネットワーク"]
    static let learningTopics = [
        "SWOT分析で経営環境を整理する",
        "情報セキュリティの3要素を知る",
        "DNSの役割を理解する"
    ]
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            id: "onboarding.itpassport.swot.v1",
            question: "経営戦略を考えるために、自社の「強み・弱み」と、外部環境の「機会・脅威」を整理する分析手法はどれか。",
            choices: ["SWOT分析", "PPM分析", "ABC分析", "BSC（バランススコアカード）"],
            correctAnswerIndex: 0,
            explanation: "SWOT分析は、強み（Strengths）、弱み（Weaknesses）、機会（Opportunities）、脅威（Threats）の4つから経営環境を整理する手法です。\n\n強み・弱みは自社の内部環境、機会・脅威は市場や競合などの外部環境を表します。\n\nPPM分析は事業への資源配分、ABC分析は重要度に応じた分類、BSCは複数の視点からの業績評価に用います。"
        ),
        QuizQuestion(
            id: "onboarding.itpassport.confidentiality.v1",
            question: "顧客情報を閲覧できる人を、権限をもつ担当者だけに限定した。主に高めようとしている情報セキュリティの要素はどれか。",
            choices: ["完全性", "可用性", "機密性", "保守性"],
            correctAnswerIndex: 2,
            explanation: "機密性は、許可された人だけが情報にアクセスできることです。顧客情報の閲覧権限を限定するのは、機密性を高める対策です。\n\n情報セキュリティの基本となる3要素は、機密性・完全性・可用性です。完全性は情報が正確で不正に改ざんされていないこと、可用性は必要なときに情報やシステムを利用できることを表します。\n\n保守性は、システムの修正や変更のしやすさを表す品質特性です。"
        ),
        QuizQuestion(
            id: "onboarding.itpassport.dns.v1",
            question: "インターネットで、example.comのようなドメイン名から、対応するIPアドレスを調べる仕組みはどれか。",
            choices: ["SMTP", "DNS", "DHCP", "HTTP"],
            correctAnswerIndex: 1,
            explanation: "DNS（Domain Name System）は、ドメイン名とIPアドレスを対応付ける仕組みです。人が覚えやすいドメイン名から、通信先のIPアドレスを調べる処理を「名前解決」といいます。\n\nSMTPはメールの送信、DHCPはIPアドレスなどのネットワーク設定の自動割当て、HTTPはWebのデータのやり取りに使います。"
        )
    ]
}
