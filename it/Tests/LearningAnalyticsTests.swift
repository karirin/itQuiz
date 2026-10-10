import Foundation

@main
enum LearningAnalyticsTests {
    static func main() {
        var checks = 0
        func check(_ value: Bool, _ message: String) {
            precondition(value, message)
            checks += 1
        }
        let calendar = LearningDates.calendar(timeZone: TimeZone(identifier: "Asia/Tokyo")!)
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 3, hour: 10))!
        let dates = LearningDates.days(ending: now, count: 14, calendar: calendar)
        check(dates.count == 14 && Set(dates).count == 14, "日付を重複なく作る")
        check(LearningDates.key(dates[0], calendar: calendar) == "2026-09-20", "月をまたいでも14日間")
        check(LearningDates.key(LearningDates.weekStart(now, calendar: calendar), calendar: calendar) == "2026-09-28", "週間目標は月曜始まり")
        check(LearningDates.days(ending: now, count: 0).isEmpty, "0日間を安全に扱う")
        check(LearningCount(answers: -3, correct: 10) == LearningCount(), "不正な負数を除外")
        check(LearningCount(answers: 3, correct: 10).correct == 3, "正解数は回答数を超えない")
        check(LearningCount().rate == nil, "未回答を0%としない")

        var history = LearningHistory()
        for (index, date) in dates.enumerated() {
            let day = LearningDates.key(date, calendar: calendar)
            history.daily[day] = [
                "itBasic": LearningCount(answers: 10, correct: index < 7 ? 5 : 8),
                "infoBasic": LearningCount(answers: 100, correct: 100),
                "incorrectITAnswer": LearningCount(answers: 2, correct: 1)
            ]
            history.answers["itBasic", default: [:]][day] = 10
            history.answers["infoBasic", default: [:]][day] = 100
            history.answers["incorrectITAnswer", default: [:]][day] = 2
        }
        let current = history.counts(exam: .it, period: .week, now: now, calendar: calendar)
        check(current["itBasic"] == LearningCount(answers: 70, correct: 56), "直近7日を正確に集計")
        check(current["infoBasic"] == nil && current["incorrectITAnswer"] == nil, "分野別正答率には他試験と復習を混ぜない")
        check(history.overallCount(exam: .it, period: .week, now: now, calendar: calendar) == LearningCount(answers: 70, correct: 56),
              "無料の正答率は直近7日の選択した試験の演習だけを集計する")
        check(history.overallCount(exam: .info, period: .week, now: now, calendar: calendar).rate == 1,
              "基本情報への切り替えでITパスポートを混ぜない")
        check(history.overallCount(exam: .applied, period: .week, now: now, calendar: calendar).rate == nil,
              "記録がない試験は0%としない")
        check(abs(history.change(exam: .it, period: .week, now: now, calendar: calendar)! - 30) < 0.0001, "直前の7日間と重み付き比較")
        let activity = history.activity(exam: .it, dates: dates, calendar: calendar)
        check(activity.allSatisfy { $0.count == 12 }, "選択した試験の演習と復習だけを活動に含める")
        history.answers["itBasic"]?[LearningDates.key(dates[0], calendar: calendar)] = 20
        check(history.change(exam: .it, period: .week, now: now, calendar: calendar) == nil, "旧データが混在する不完全な期間は比較しない")
        check(history.change(exam: .it, period: .all, now: now, calendar: calendar) == nil, "累計に期間比較を出さない")
        history.totals = ["itBasic": LearningCount(answers: 1000, correct: 650)]
        check(history.counts(exam: .it, period: .all, now: now)["itBasic"]?.answers == 1000, "累計の既存記録を保存")

        var weighted = LearningHistory()
        let previousDay = LearningDates.key(dates[0], calendar: calendar)
        let currentDay = LearningDates.key(now, calendar: calendar)
        weighted.daily = [
            previousDay: ["itBasic": LearningCount(answers: 90, correct: 90), "itStrategy": LearningCount(answers: 10, correct: 0)],
            currentDay: ["itBasic": LearningCount(answers: 10, correct: 10), "itStrategy": LearningCount(answers: 90, correct: 0)]
        ]
        weighted.answers = ["itBasic": [previousDay: 90, currentDay: 10], "itStrategy": [previousDay: 10, currentDay: 90]]
        check(weighted.overallCount(exam: .it, period: .week, now: now, calendar: calendar).rate == 0.1,
              "無料の全体正答率は分野別の単純平均ではなく10問正解/100問回答とする")
        var legacyOnly = LearningHistory()
        legacyOnly.totals = ["itBasic": LearningCount(answers: 1000, correct: 650)]
        legacyOnly.answers = ["itBasic": [currentDay: 1000]]
        check(legacyOnly.overallCount(exam: .it, period: .week, now: now, calendar: calendar).rate == nil,
              "日付別の正解数がない過去データから直近7日の正答率を推測しない")
        check(abs(weighted.change(exam: .it, period: .week, now: now, calendar: calendar)! + 80) < 0.0001,
              "分野の割合を単純平均せず、回答数で重み付けする")
        weighted.daily[currentDay] = ["itBasic": LearningCount(answers: 1, correct: 1)]
        check(weighted.change(exam: .it, period: .week, now: now, calendar: calendar) == nil,
              "片方が10問未満なら増減を断定しない")

        var counts = Dictionary(uniqueKeysWithValues: AccuracyArea.allCases.map {
            (AccuracyExam.it.key(for: $0), LearningCount(answers: 100, correct: 80))
        })
        counts["itTechnology"] = LearningCount(answers: 1, correct: 0)
        var recommendation = LearningRecommendation.make(exam: .it, counts: counts)
        check(recommendation.area == .technology && recommendation.reason == .sampling, "1問の不正解を苦手と断定しない")
        counts["itStrategy"] = LearningCount()
        recommendation = LearningRecommendation.make(exam: .it, counts: counts)
        check(recommendation.area == .strategy && recommendation.reason == .unexplored, "未回答分野への挑戦を優先")
        counts["itStrategy"] = LearningCount(answers: 100, correct: 80)
        counts["itTechnology"] = LearningCount(answers: 30, correct: 12)
        recommendation = LearningRecommendation.make(exam: .it, counts: counts)
        check(recommendation.area == .technology && recommendation.reason == .weakness, "十分な回答のある苦手分野を推薦")
        counts["itTechnology"] = LearningCount(answers: 100, correct: 80)
        check(LearningRecommendation.make(exam: .it, counts: counts).reason == .balanced, "差がないとき苦手と表示しない")

        let dstCalendar = LearningDates.calendar(timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        let dstDate = dstCalendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!
        let dstDays = LearningDates.days(ending: dstDate, count: 7, calendar: dstCalendar)
        check(Set(dstDays.map { LearningDates.key($0, calendar: dstCalendar) }).count == 7, "夏時間も1日を86400秒として扱わない")
        print("Learning analytics checks passed (\(checks) checks)")
    }
}
