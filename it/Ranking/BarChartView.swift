//
//  BarChartView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/20.
//

import SwiftUI
import Firebase
import Charts

struct DailyData {
    let date: String
    let count: Int

    init(date: Date, count: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.string(from: date)
        self.count = count
    }
}

struct BarChartView: View {
    @ObservedObject var authManager: AuthManager
    let sampleData = createSampleData()
    @State private var currentDate = Date()
    @State var data: [DailyData] = []
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var isDataAvailable = false
    @State private var isLoading: Bool = true
    @State private var preFlag: Bool = false
    @State private var userPreFlag: Int = 0
    @State private var animateChart = false
    
    private var displayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private var yearMonthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private var fullDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月 d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    func formattedDate(from dateString: String) -> String {
        if let date = dateFormatter.date(from: dateString) {
            return fullDateFormatter.string(from: date)
        }
        return ""
    }

    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ヘッダー
                HStack(spacing: 16) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    Text(yearMonthFormatter.string(from: currentDate))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                if isLoading {
                    VStack {
                        CustomSpinner2()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if !isDataAvailable {
                        VStack(spacing: 24) {
                            Image("ライムグラフ")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                            
                            Text("\(Text(monthFormatter.string(from: currentDate)))はデータがありません")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("fontGray").opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.width > 0 {
                                        changeMonth(by: -1)
                                    } else {
                                        changeMonth(by: 1)
                                    }
                                }
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // グラフカード
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: "chart.bar.fill")
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.blue, .cyan],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        
                                        Text("学習グラフ")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color("fontGray"))
                                    }
                                    
                                    Chart {
                                        ForEach(data, id: \.date) { dailyData in
                                            BarMark(
                                                x: .value("Date", dailyData.date),
                                                y: .value("Count", animateChart ? dailyData.count : 0)
                                            )
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.8),
                                                        Color.cyan.opacity(0.6),
                                                        Color.purple.opacity(0.4)
                                                    ],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(position: .bottom, values: .automatic) { value in
                                            if let dateStr = value.as(String.self),
                                               let date = dateFormatter.date(from: dateStr),
                                               Calendar.current.component(.day, from: date) % 3 == 0 {
                                                AxisValueLabel(displayFormatter.string(from: date))
                                                    .foregroundStyle(Color("fontGray").opacity(0.5))
                                                    .font(.system(size: 11, weight: .medium))
                                            } else {
                                                AxisValueLabel("")
                                            }
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { value in
                                            AxisValueLabel()
                                                .foregroundStyle(Color("fontGray").opacity(0.5))
                                                .font(.system(size: 11, weight: .medium))
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                                .foregroundStyle(Color.gray.opacity(0.15))
                                        }
                                    }
                                    .frame(height: 240)
                                    .padding(.top, 8)
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                                )
                                .padding(.horizontal, 20)
                                
                                // 凡例カード
                                HStack(spacing: 32) {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.15))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "calendar")
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.red, .orange],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        
                                        Text("日付")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color("fontGray"))
                                    }
                                    Spacer()
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.15))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "checkmark.square.fill")
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.blue, .cyan],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        
                                        Text("回答数")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color("fontGray"))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                                )
                                .padding(.horizontal, 20)
                                
                                // データリスト
                                VStack(spacing: 12) {
                                    ForEach(data.filter { $0.count != 0 }, id: \.date) { item in
                                        HStack {
                                            HStack(spacing: 14) {
                                                ZStack {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [Color.red.opacity(0.15), Color.orange.opacity(0.1)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .frame(width: 44, height: 44)
                                                    
                                                    Image(systemName: "calendar.circle.fill")
                                                        .foregroundStyle(
                                                            LinearGradient(
                                                                colors: [.red, .orange],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .font(.system(size: 22))
                                                }
                                                
                                                Text(formattedDate(from: item.date))
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color("fontGray"))
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 6) {
                                                Text("\(item.count)")
                                                    .font(.system(size: 28, weight: .bold))
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: [.blue, .cyan],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                Text("問")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(Color("fontGray").opacity(0.5))
                                                    .padding(.top, 6)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            }
                            .padding(.top, 8)
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.width > 0 {
                                        changeMonth(by: -1)
                                    } else {
                                        changeMonth(by: 1)
                                    }
                                }
                        )
                    }
                }
            }
        }
        .onAppear {
            fetchData(userId: authManager.currentUserId!, for: currentDate)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animateChart = true
            }
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    static func createSampleData() -> [DailyData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return [
            DailyData(date: dateFormatter.date(from: "2023-12-01")!, count: 10),
            DailyData(date: dateFormatter.date(from: "2023-12-02")!, count: 15),
            DailyData(date: dateFormatter.date(from: "2023-12-03")!, count: 20)
        ]
    }
    
    private var dataFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    func displayDate(from dateString: String) -> String {
        if let date = dataFormatter.date(from: dateString) {
            return displayFormatter.string(from: date)
        }
        return ""
    }
    
    func shouldDisplayLabel(for date: Date) -> Bool {
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: date)
        return [1, 6, 11, 16, 21, 26].contains(dayComponent)
    }
    
    func changeMonth(by months: Int) {
        animateChart = false
        if let newDate = Calendar.current.date(byAdding: .month, value: months, to: currentDate) {
            currentDate = newDate
            fetchData(userId: authManager.currentUserId!, for: newDate)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateChart = true
            }
        }
    }
    
    func fetchData(userId: String, for date: Date) {
        let ref = Database.database().reference(withPath: "answers").child(userId)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        let dateComponents = DateComponents(year: year, month: month)
        let startDate = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: startDate)!

        ref.observe(.value, with: { snapshot in
            var dailyTotals = [String: Int]()

            if let userDict = snapshot.value as? [String: Any] {
                for (_, categoryDict) in userDict {
                    if let categoryDict = categoryDict as? [String: Any] {
                        for (date, count) in categoryDict {
                            if let count = count as? Int {
                                dailyTotals[date, default: 0] += count
                            }
                        }
                    }
                }
            }

            self.data = range.compactMap { day -> DailyData? in
                let dateComponents = DateComponents(year: year, month: month, day: day)
                let date = Calendar.current.date(from: dateComponents)!
                let count = dailyTotals[dateFormatter.string(from: date)] ?? 0
                return DailyData(date: date, count: count)
            }
            self.isDataAvailable = self.data.contains { $0.count > 0 }
            self.isLoading = false
        })
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = createSampleData()
        BarChartView(authManager: AuthManager(), data: sampleData)
    }

    static func createSampleData() -> [DailyData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return [
            DailyData(date: dateFormatter.date(from: "2023-12-01")!, count: 10),
            DailyData(date: dateFormatter.date(from: "2023-12-02")!, count: 15),
            DailyData(date: dateFormatter.date(from: "2023-12-03")!, count: 20)
        ]
    }
}
