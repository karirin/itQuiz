//
//  PentagonShape.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/30.
//

import SwiftUI

enum QuizBossLevel {
    case goburin
    case kaijyu
    case shinjyu
    case none
    
    var description: String {
        switch self {
        case .goburin:
            return "goburin"
        case .kaijyu:
            return "kaijyu"
        case .shinjyu:
            return "shinjyu"
        case .none:
            return "none"
        }
    }
}
    
enum QuizLevel {
    case beginner
    case beginnerStory1
    case beginnerStory2
    case beginnerStory3
    case intermediate
    case advanced
    case network
    case security
    case database
    case daily
    case god
    case incorrectAnswer
    case incorrectITAnswer
    case incorrectInfoAnswer
    case incorrectAppliedAnswer
    case incorrectESAnswer
    case incorrectITStrategyAnswer
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
    case mugen
    case computerSystem
    case softHard
    case netwarkTusin
    case ESsecurity
    case kikaku
    case sekkei
    case kaihatu
    case unyouhoshu
    
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
        case .security:
            return "security"
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
        case .incorrectITAnswer:
            return "incorrectITAnswer"
        case .incorrectInfoAnswer:
            return "incorrectInfoAnswer"
        case .incorrectAppliedAnswer:
            return "incorrectAppliedAnswer"
        case .itBasic:
            return "itBasic"
        case .infoBasic:
            return "infoBasic"
        case .appliedBasic:
            return "appliedBasic"
        case .mugen:
            return "mugen"
        case .computerSystem:
            return "computerSystem"
        case .softHard:
            return "softHard"
        case .netwarkTusin:
            return "netwarkTusin"
        case .ESsecurity:
            return "ESsecurity"
        case .kikaku:
            return "kikaku"
        case .sekkei:
            return "sekkei"
        case .kaihatu:
            return "kaihatu"
        case .unyouhoshu:
            return "unyouhoshu"
        case .incorrectESAnswer:
            return "incorrectESAnswer"
        case .incorrectITStrategyAnswer:
            return "incorrectITStrategyAnswer"
        }
    }
}

extension QuizLevel: CaseIterable {
    static var allCases: [QuizLevel] {
        return [.beginner, .intermediate, .advanced, .god, .network, .security, .database]
        // 除外したいケースをここで除外
    }
}

struct PentagonGraphShape: Shape {
    var quizData: [QuizLevel: QuizData]

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 - 10
        let angle = (2 * CGFloat.pi) / 7

        var path = Path()

        for (i, level) in QuizLevel.allCases.enumerated() {
            let data = quizData[level] ?? QuizData(answer: 1, correct: 0)
            let radius = baseRadius * data.correctRate // 正解率に基づく半径
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

//struct PentagonGraphLabelView: View {
//    var label: String
//    var index: Int
//    var radius: CGFloat
//
//    var body: some View {
//        let angle = (2 * CGFloat.pi) / 7 * CGFloat(index) - .pi / 2
//        let x = cos(angle) * radius - 0
//        let y = sin(angle) * radius
//
//        return Image("\(label)")
//            .resizable()
//            .frame(width:40,height:40)
//            .position(x: x + radius + 30, y: y + radius + 5)
//    }
//}

//struct PentagonGraphLabelView: View {
//    var label: String
//    var index: Int
//    var radius: CGFloat
//
//    var body: some View {
//        GeometryReader { geometry in
//            let angle = (2 * CGFloat.pi) / CGFloat(QuizLevel.allCases.count) * CGFloat(index) - .pi / 2
//            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
//            let labelRadius = radius - 20 // ラベルのために半径を少し短くする
//            let x = center.x + labelRadius * cos(angle) // ラベルの幅の半分を引く
//            let y = center.y + labelRadius * sin(angle) // ラベルの高さの半分を引く
//
//            Image("\(label)")
//                .resizable()
//                .frame(width: 40, height: 40)
//                .position(x: x, y: y)
//        }
//    }
//}

struct PentagonGraphLabelView: View {
    var label: String
    var index: Int
    // radius パラメータを削除して、ビューのサイズに基づいて計算するようにします

    var body: some View {
        GeometryReader { geometry in
            let angle = (2 * CGFloat.pi) / CGFloat(QuizLevel.allCases.count) * CGFloat(index) - .pi / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            // ビューのサイズに基づいて radius を計算します
            let radius = min(geometry.size.width, geometry.size.height) / 2 * 1.13 // 85% をラベルの配置に使用します

            let x = center.x + radius * cos(angle) - 20
            let y = center.y + radius * sin(angle) - 20

            Image("\(label)")
                .resizable()
                .frame(width: 40, height: 40)
                // ラベルの中心が正しい位置に来るように調整します
//                .offset(x: radius * cos(angle) + 178, y: radius * sin(angle) + 155)
//                .offset(x: radius * cos(angle) + 0, y: radius * sin(angle) + 0)
                .offset(x:x,y:y)
                // position ではなく offset を使って配置することで、
                // より詳細な位置調整が可能になります
        }
        
    }
}


struct PentagonGraphBackgroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        let angle = (2 * CGFloat.pi) / 7

        // ここから追加
        let scale: [CGFloat] = [0.1,0.2,0.3, 0.4,0.5, 0.6,0.7, 0.8,0.9, 1.0]
        var path = Path()

        // 目盛りの円を追加
        for factor in scale {
            let scaledRadius = radius * factor
            path.addEllipse(in: CGRect(x: center.x - scaledRadius, y: center.y - scaledRadius, width: scaledRadius * 2, height: scaledRadius * 2))
        }
        // ここまで追加

        for i in 0..<7 {
            let x = center.x + radius * cos(angle * CGFloat(i) - .pi / 2)
            let y = center.y + radius * sin(angle * CGFloat(i) - .pi / 2)
            path.move(to: center)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}


struct PentagonGraphView: View {
    @State private var quizData = [QuizLevel: QuizData]()
    let userId: String
    let labels: [String]
    
    let scaleNumbers: [CGFloat] = [0, 50, 100]
    let graphCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    let graphRadius = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
    
    var body: some View {
            GeometryReader { geometry in
                let graphCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2 - 170)
                // graphRadiusの最大値を100とするための計算
                let graphRadius = min(geometry.size.width, geometry.size.height) / 2 - 10
                let maxScaleValue: CGFloat = 100 // スケールの最大値
                let scaleFactor = graphRadius / maxScaleValue // スケールファクター

                ZStack {
                    PentagonGraphBackgroundShape()
                                    .stroke(Color.gray, lineWidth: 1)
                    PentagonGraphShape(quizData: quizData)
                        .fill(Color.orange.opacity(0.2)) // 先に塗りつぶしを適用
                           .overlay(
                               PentagonGraphShape(quizData: quizData)
                                   .stroke(Color.orange, lineWidth: 2)
                           )

                    ForEach(Array(QuizLevel.allCases.enumerated()), id: \.offset) { (i, _) in
                        PentagonGraphLabelView(label: labels[i], index: i)
                    }
                    // 目盛りの数字を表示する
                    ForEach(scaleNumbers, id: \.self) { scaleValue in
                        // スケール値に基づいて半径を計算
                        let scaledRadius = scaleFactor * scaleValue
                        
                        // centerをgraphCenterに修正
                        let numberPosition = CGPoint(x: graphCenter.x, y: graphCenter.y - scaledRadius)
                        
                        // Text Viewを使って数字を表示
                        Text("\(Int(scaleValue))") // "%.1f" から整数に変更
                            .position(numberPosition)
                            .offset(x: -25, y: 170) // Textの位置を適宜調整
                    }
                }
                .onAppear {
                    RateManager.shared.fetchQuizData(userId: userId) { data in
                        self.quizData = data
                    }
                }
            }
        }
    }

struct PentagonView: View {
    @ObservedObject var authManager : AuthManager
    @State private var quizData = [QuizLevel: QuizData]()
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var flag: Bool
    var body: some View {
        VStack{
            PentagonGraphView(userId: authManager.currentUserId!, labels: ["初級", "中級", "上級", "神級", "ネットワーク", "セキュリティ","データベース"])
                .padding(.top,30)
            VStack(spacing: 0) {
                HStack{
                    Image("beginnerMonster1")
                        .resizable()
                        .frame(width:30,height:30)
                    Text("ダンジョンの種類")
                    Spacer()
                    Text("正答率")
                }
                .font(.system(size: 18))
                .padding()
                ScrollView{
                    ForEach(QuizLevel.allCases, id: \.self) { level in
                        if let quizDataForLevel = quizData[level] {
                            VStack{
                                HStack{
                                    Image("\(level.description)選択肢")
                                        .resizable()
                                        .frame(width: 200,height: 40)
                                    Spacer()
                                    Text("\(quizDataForLevel.correctPerRate, specifier: "%.0f")%")
                                        .font(.system(size: 22))
                                }
                                .padding(.horizontal)
                            Divider()
                            }
                        }
                    }
                }
            }
            .padding(.top)
            
            .foregroundColor(Color("fontGray"))
        }.background(Color("Color2"))
        .onAppear {
//            print("currentuser:\(authManager.currentUserId)")
            RateManager.shared.fetchQuizData(userId: authManager.currentUserId!) { data in
                self.quizData = data
//                print("self.quizData:\(self.quizData)")
            }
            self.flag = true
        }
        .onChange(of: flag) { flag in
            RateManager.shared.fetchQuizData(userId: authManager.currentUserId!) { data in
                self.quizData = data
//                print("self.quizData:\(self.quizData)")
            }
        }
        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//            audioManager.playCancelSound()
//        }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.gray)
//            Text("戻る")
//                .foregroundColor(Color("fontGray"))
//        })
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("ダンジョン別の正答率")
//                    .font(.system(size: 20)) // ここでフォントサイズを指定
//            }
//        }
    }
}

struct PentagonShape_Previews: PreviewProvider {
    static let dummyAuthManager = AuthManager()
    static var previews: some View {
//        PentagonGraphView(userId: "VQ0MZw8snHSY23rOXbhN9wxORF42", labels: ["初級", "中級", "上級", "ネットワーク", "セキュリティ","データベース", "デイリー", "神級", "初級(タイムアタック)", "中級(タイムアタック)", "上級(タイムアタック)"])
//        PentagonGraphView(userId: "VQ0MZw8snHSY23rOXbhN9wxORF42", labels: ["初級", "中級", "上級", "神級", "ネットワーク", "セキュリティ","データベース"])
        PentagonView(authManager: dummyAuthManager, flag: .constant(false))
    }
}
