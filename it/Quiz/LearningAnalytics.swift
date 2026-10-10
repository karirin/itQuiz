import Foundation

enum AccuracyExam: String, CaseIterable, Identifiable {
    case it, info, applied

    var id: String { rawValue }
    var title: String {
        switch self {
        case .it: return "ITパスポート"
        case .info: return "基本情報"
        case .applied: return "応用情報"
        }
    }
    func key(for area: AccuracyArea) -> String { rawValue + area.rawValue }
    var reviewKey: String {
        switch self {
        case .it: return "incorrectITAnswer"
        case .info: return "incorrectInfoAnswer"
        case .applied: return "incorrectAppliedAnswer"
        }
    }
    var areaKeys: [String] { AccuracyArea.allCases.map { key(for: $0) } }
    var activityKeys: [String] { areaKeys + [reviewKey] }
}

enum AccuracyArea: String, CaseIterable, Identifiable {
    case basic = "Basic", strategy = "Strategy", technology = "Technology", management = "Management"

    var id: String { rawValue }
    var title: String {
        switch self {
        case .basic: return "基礎理解"
        case .strategy: return "ストラテジ"
        case .technology: return "テクノロジ"
        case .management: return "マネジメント"
        }
    }
    var symbol: String {
        switch self {
        case .basic: return "book.closed.fill"
        case .strategy: return "lightbulb.fill"
        case .technology: return "cpu"
        case .management: return "person.2.fill"
        }
    }
}

struct LearningCount: Equatable {
    var answers: Int
    var correct: Int

    init(answers: Int = 0, correct: Int = 0) {
        self.answers = max(0, answers)
        self.correct = min(max(0, answers), max(0, correct))
    }
    var rate: Double? { answers > 0 ? Double(correct) / Double(answers) : nil }
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(answers: lhs.answers + rhs.answers, correct: lhs.correct + rhs.correct)
    }
}

enum LearningPeriod: Int, CaseIterable, Identifiable {
    case week = 7, month = 30, all = 0
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .week: return "直近7日"
        case .month: return "直近30日"
        case .all: return "累計"
        }
    }
}

struct LearningDay: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}

enum LearningDates {
    /// Gregorian keys agree with the existing answers/yyyy-MM-dd records in every locale.
    static func calendar(timeZone: TimeZone = .current) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.firstWeekday = 2
        return calendar
    }
    static func key(_ date: Date, calendar: Calendar = calendar()) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    static func days(ending date: Date, count: Int, calendar: Calendar = calendar()) -> [Date] {
        let end = calendar.startOfDay(for: date)
        guard count > 0 else { return [] }
        return (0..<count).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: end) }
    }
    static func weekStart(_ date: Date, calendar: Calendar = calendar()) -> Date {
        let start = calendar.startOfDay(for: date)
        let offset = (calendar.component(.weekday, from: start) + 5) % 7
        return calendar.date(byAdding: .day, value: -offset, to: start)!
    }
}

struct LearningRecommendation {
    enum Reason { case unexplored, sampling, weakness, balanced }
    let area: AccuracyArea
    let reason: Reason
    let count: LearningCount

    static func make(exam: AccuracyExam, counts: [String: LearningCount]) -> Self {
        let records = AccuracyArea.allCases.map { ($0, counts[exam.key(for: $0)] ?? LearningCount()) }
        if let record = records.first(where: { $0.1.answers == 0 }) {
            return Self(area: record.0, reason: .unexplored, count: record.1)
        }
        if let record = records.filter({ $0.1.answers < 10 }).min(by: { $0.1.answers < $1.1.answers }) {
            return Self(area: record.0, reason: .sampling, count: record.1)
        }
        let weakest = records.min { $0.1.rate! < $1.1.rate! }!
        let strongest = records.map { $0.1.rate! }.max()!
        return Self(area: weakest.0, reason: strongest - weakest.1.rate! >= 0.1 ? .weakness : .balanced, count: weakest.1)
    }
}

struct LearningHistory {
    var totals: [String: LearningCount] = [:]
    /// level -> day -> count; preserves the original activity history.
    var answers: [String: [String: Int]] = [:]
    /// day -> level -> counts; recorded from this version onwards.
    var daily: [String: [String: LearningCount]] = [:]

    func counts(exam: AccuracyExam, period: LearningPeriod, now: Date, calendar: Calendar = LearningDates.calendar()) -> [String: LearningCount] {
        if period == .all { return totals.filter { exam.areaKeys.contains($0.key) } }
        return counts(keys: exam.areaKeys, days: LearningDates.days(ending: now, count: period.rawValue, calendar: calendar), calendar: calendar)
    }

    /// Weight each area's accuracy by its answer count; review answers are excluded.
    func overallCount(exam: AccuracyExam, period: LearningPeriod, now: Date, calendar: Calendar = LearningDates.calendar()) -> LearningCount {
        counts(exam: exam, period: period, now: now, calendar: calendar).values.reduce(LearningCount(), +)
    }

    func counts(keys: [String], days: [Date], calendar: Calendar = LearningDates.calendar()) -> [String: LearningCount] {
        var result: [String: LearningCount] = [:]
        for day in days {
            for key in keys {
                result[key, default: LearningCount()] = result[key, default: LearningCount()] + (daily[LearningDates.key(day, calendar: calendar)]?[key] ?? LearningCount())
            }
        }
        return result
    }

    func activity(exam: AccuracyExam, dates: [Date], calendar: Calendar = LearningDates.calendar()) -> [LearningDay] {
        dates.map { date in
            let key = LearningDates.key(date, calendar: calendar)
            return LearningDay(date: date, count: exam.activityKeys.reduce(0) { $0 + max(0, answers[$1]?[key] ?? 0) })
        }
    }

    /// Compare weighted rates only when both periods have enough answers and complete dated records.
    func change(exam: AccuracyExam, period: LearningPeriod, now: Date, calendar: Calendar = LearningDates.calendar()) -> Double? {
        guard period != .all else { return nil }
        let days = LearningDates.days(ending: now, count: period.rawValue * 2, calendar: calendar)
        let previous = Array(days.prefix(period.rawValue))
        let current = Array(days.suffix(period.rawValue))
        func completeCount(_ dates: [Date]) -> LearningCount? {
            let recorded = counts(keys: exam.areaKeys, days: dates, calendar: calendar).values.reduce(LearningCount(), +)
            let original = dates.reduce(0) { sum, date in
                sum + exam.areaKeys.reduce(0) { $0 + max(0, answers[$1]?[LearningDates.key(date, calendar: calendar)] ?? 0) }
            }
            guard recorded.answers >= 10, recorded.answers == original else { return nil }
            return recorded
        }
        guard let before = completeCount(previous)?.rate, let after = completeCount(current)?.rate else { return nil }
        return (after - before) * 100
    }
}
