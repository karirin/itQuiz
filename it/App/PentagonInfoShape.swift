//
//  PentagonInfoShape.swift
//  Info
//
//  Created by Apple on 2024/03/10.
//

import SwiftUI

enum QuizInfoLevel {
    case beginner
    case beginnerStory1
    case beginnerStory2
    case beginnerStory3
    case intermediate
    case advanced
    case network
    case securInfoy
    case database
    case daily
    case god
    case incorrectAnswer
    case timeBeginner
    case timeIntermediate
    case timeAdvanced
    case itBasic
    case infoBasic
    case appliedBasic
    case itStrategy
    case infoStrategy
    case appliedStrategy
    case itTechnology
    case infoTechnology
    case appliedTechnology
    case itManagement
    case infoManagement
    case appliedManagement
    
    var description: String {
        switch self {
        case .beginner:
            return "beginner"
        case .intermediate:
            return "intermediate"
        case .advanced:
            return "advanced"
        case .network:
            return "network"
        case .securInfoy:
            return "securInfoy"
        case .database:
            return "database"
        case .daily:
            return "daily"
        case .god:
            return "god"
        case .incorrectAnswer:
            return "incorrectAnswer"
        case .timeBeginner:
            return "timeBeginner"
        case .timeIntermediate:
            return "timeIntermediate"
        case .timeAdvanced:
            return "timeAdvanced"
        case .beginnerStory1:
            return "beginnerStory1"
        case .beginnerStory2:
            return "beginnerStory2"
        case .beginnerStory3:
            return "beginnerStory3"
        case .itStrategy:
            return "itStrategy"
        case .infoStrategy:
            return "infoStrategy"
        case .appliedStrategy:
            return "appliedStrategy"
        case .itTechnology:
            return "itTechnology"
        case .infoTechnology:
            return "infoTechnology"
        case .appliedTechnology:
            return "appliedTechnology"
        case .itManagement:
            return "itManagement"
        case .infoManagement:
            return "infoManagement"
        case .appliedManagement:
            return "appliedManagement"
        case .itBasic:
            return "itBasic"
        case .infoBasic:
            return "infoBasic"
        case .appliedBasic:
            return "appliedBasic"
        }
    }
}

extension QuizInfoLevel: CaseIterable {
    static var allCases: [QuizInfoLevel] {
        return [.infoBasic, .infoStrategy, .infoTechnology, .infoManagement]
    }
}

struct PentagonInfoGraphShape: Shape {
    var quizData: [QuizInfoLevel: QuizData]

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 - 10
        let angle = (2 * CGFloat.pi) / 4

        var path = Path()

        for (i, level) in QuizInfoLevel.allCases.enumerated() {
            let data = quizData[level] ?? QuizData(answer: 1, correct: 0)
            let radius = baseRadius * data.correctRate
            let x = center.x + radius * cos(angle * CGFloat(i) - .pi / 2)
            let y = center.y + radius * sin(angle * CGFloat(i) - .pi / 2)
            let point = CGPoint(x: x, y: y)

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct PentagonInfoGraphLabelView: View {
    var label: String
    var index: Int

    var body: some View {
        GeometryReader { geometry in
            let angle = (2 * CGFloat.pi) / CGFloat(QuizInfoLevel.allCases.count) * CGFloat(index) - .pi / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 * 1.13

            let x = center.x + radius * cos(angle) - 20
            let y = center.y + radius * sin(angle) - 20

            Image("\(label)")
                .resizable()
                .frame(width: 40, height: 40)
                .offset(x: x, y: y)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct PentagonInfoGraphBackgroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        let angle = (2 * CGFloat.pi) / 4

        let scale: [CGFloat] = [0.2, 0.4, 0.6, 0.8, 1.0]
        var path = Path()

        // 目盛りの円を追加
        for factor in scale {
            let scaledRadius = radius * factor
            path.addEllipse(in: CGRect(x: center.x - scaledRadius, y: center.y - scaledRadius, width: scaledRadius * 2, height: scaledRadius * 2))
        }

        for i in 0..<4 {
            let x = center.x + radius * cos(angle * CGFloat(i) - .pi / 2)
            let y = center.y + radius * sin(angle * CGFloat(i) - .pi / 2)
            path.move(to: center)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

struct PentagonInfoGraphView: View {
    @State private var quizData = [QuizInfoLevel: QuizData]()
    let userId: String
    let labels: [String]
    
    let scaleNumbers: [CGFloat] = [0, 50, 100]
    let graphCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    let graphRadius = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
    
    var body: some View {
        GeometryReader { geometry in
            let graphCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2 - 170)
            let graphRadius = min(geometry.size.width, geometry.size.height) / 2 - 10
            let maxScaleValue: CGFloat = 100
            let scaleFactor = graphRadius / maxScaleValue

            ZStack {
                // 背景グラデーション
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.05), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: graphRadius
                        )
                    )
                    .frame(width: graphRadius * 2, height: graphRadius * 2)
                    .offset(y: -170)
                
                // 背景グリッド
                PentagonInfoGraphBackgroundShape()
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .padding()
                
                // データグラフ - グラデーション塗りつぶし
                PentagonInfoGraphShape(quizData: quizData)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.4),
                                Color.orange.opacity(0.2)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 0)
                
                // データグラフ - 枠線
                PentagonInfoGraphShape(quizData: quizData)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange,
                                Color.orange.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Color.orange.opacity(0.5), radius: 5, x: 0, y: 2)
                
                // データポイント
                ForEach(Array(QuizInfoLevel.allCases.enumerated()), id: \.offset) { (i, level) in
                    let data = quizData[level] ?? QuizData(answer: 1, correct: 0)
                    let radius = graphRadius * data.correctRate
                    let angle = (2 * CGFloat.pi) / 4 * CGFloat(i) - .pi / 2
                    let x = graphCenter.x + radius * cos(angle)
                    let y = graphCenter.y + radius * sin(angle)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.orange, lineWidth: 3)
                        )
                        .shadow(color: Color.orange.opacity(0.5), radius: 4, x: 0, y: 2)
                        .position(x: x, y: y + 170)
                }

                // ラベル
                ForEach(Array(QuizInfoLevel.allCases.enumerated()), id: \.offset) { (i, _) in
                    PentagonInfoGraphLabelView(label: labels[i], index: i)
                    .padding(40)
                }
                
                // 目盛りの数字 - モダンスタイル
                ForEach(scaleNumbers, id: \.self) { scaleValue in
                    let scaledRadius = scaleFactor * scaleValue
                    let numberPosition = CGPoint(x: graphCenter.x, y: graphCenter.y - scaledRadius)
                    
                    Text("\(Int(scaleValue))")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray.opacity(0.7))
                        .position(numberPosition)
                        .offset(x: -30, y: 170)
                }
            }
            .onAppear {
                RateManager.shared.fetchInfoQuizData(userId: userId) { data in
                    self.quizData = data
                }
            }
        }
    }
}

struct PentagonInfoView: View {
    @ObservedObject var authManager : AuthManager
    @State private var quizData = [QuizInfoLevel: QuizData]()
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var flag: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // グラフエリア
            PentagonInfoGraphView(
                userId: authManager.currentUserId!,
                labels: ["基本情報技術者試験基礎理解", "基本情報技術者試験ストラテジ", "基本情報技術者試験テクノロジ", "基本情報技術者試験マネジメント"]
            )
            .padding(.top, 30)
            
            // データリストエリア
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Image("beginnerMonster1")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("ダンジョンの種類")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text("正答率")
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding()
                .background(Color("Color2").opacity(0.5))
                
                // スクロールリスト
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(QuizInfoLevel.allCases, id: \.self) { level in
                            if let quizDataForLevel = quizData[level] {
                                HStack(alignment: .center, spacing: 12) {
                                    // カテゴリーボタン
                                    Image("\(level.description)ボタン")
                                        .resizable()
                                        .frame(width: 200, height: 40)
                                    
                                    Spacer()
                                    
                                    // 正答率 - モダンスタイル
                                    Text("\(quizDataForLevel.correctPerRate, specifier: "%.0f")%")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(percentageColor(for: quizDataForLevel.correctPerRate))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.05))
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            .foregroundColor(Color("fontGray"))
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Color2"), Color("Color2").opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            RateManager.shared.fetchInfoQuizData(userId: authManager.currentUserId!) { data in
                self.quizData = data
            }
            self.flag = true
        }
        .onChange(of: flag) { flag in
            RateManager.shared.fetchInfoQuizData(userId: authManager.currentUserId!) { data in
                self.quizData = data
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // 正答率に応じた色を返すヘルパー関数
    private func percentageColor(for percentage: CGFloat) -> Color {
        switch percentage {
        case 80...100:
            return Color.green
        case 60..<80:
            return Color.orange
        case 40..<60:
            return Color.yellow
        default:
            return Color.red
        }
    }
}

struct PentagonInfoShape_Previews: PreviewProvider {
    static let dummyAuthManager = AuthManager()
    static var previews: some View {
        PentagonInfoView(authManager: dummyAuthManager, flag: .constant(false))
    }
}
