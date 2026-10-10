import Foundation

/// Records what the learner finished today on this device, so the recovery home can tell
/// "all done today" from "nothing scheduled today". It never affects allowances or schedules.
enum ReviewDailyActivityLog {
    private static let lock = NSLock()

    private struct Day: Codable {
        var day: String
        var activities: [ReviewDailyActivity]
    }

    private static func key(userID: String) -> String { "reviewDailyActivity.v1.\(userID)" }

    static func today(userID: String, now: Date = Date(), defaults: UserDefaults = .standard) -> [ReviewDailyActivity] {
        lock.lock(); defer { lock.unlock() }
        return load(userID: userID, now: now, defaults: defaults).activities
    }

    static func record(_ activity: ReviewDailyActivity, userID: String, defaults: UserDefaults = .standard) {
        lock.lock(); defer { lock.unlock() }
        var stored = load(userID: userID, now: activity.completedAt, defaults: defaults)
        stored.activities.append(activity)
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: key(userID: userID))
        }
    }

    private static func load(userID: String, now: Date, defaults: UserDefaults) -> Day {
        let day = DailyReviewStore.dayKey(for: now)
        guard let data = defaults.data(forKey: key(userID: userID)),
              let stored = try? JSONDecoder().decode(Day.self, from: data),
              stored.day == day else { return Day(day: day, activities: []) }
        return stored
    }
}
