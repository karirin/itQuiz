import Foundation

enum CourseQuestionBenchmark {
    static func run() throws {
        let coldStart = ProcessInfo.processInfo.systemUptime
        _ = CourseQuestionIndex.candidates(topicID: "dns")
        let initializationMS = (ProcessInfo.processInfo.systemUptime - coldStart) * 1_000
        let topics = WeaknessCourseCatalog.topics
        let now = Date(timeIntervalSince1970: 1_791_000_000)
        var histories: [String: [String: CourseQuestionHistory]] = [:]
        var cloud = CourseCloudState()
        for topic in topics {
            let pool = CourseQuestionIndex.candidates(topicID: topic.id) + topic.practice + topic.checks
            let history = Dictionary(uniqueKeysWithValues: pool.enumerated().map {
                ($0.element.id, CourseQuestionHistory(lastSeenAt: now.addingTimeInterval(Double($0.offset) * -100),
                                                     correctCount: 2, incorrectCount: 1))
            })
            histories[topic.id] = history
            cloud.progress[topic.id] = CourseProgress(sourceQuestion: pool.first, mistakeCount: 1,
                                                       updatedAt: now, questionHistory: history)
        }
        let iterations = 10_000
        let start = ProcessInfo.processInfo.systemUptime
        var checksum = 0
        for offset in 0..<iterations {
            let topic = topics[offset % topics.count]
            checksum += CourseQuestionIndex.select(topic: topic, kind: .confirmation,
                original: cloud.progress[topic.id]?.sourceQuestion, history: histories[topic.id]!).count
        }
        let meanMS = (ProcessInfo.processInfo.systemUptime - start) * 1_000 / Double(iterations)
        let fullBytes = try JSONEncoder().encode(cloud).count
        let compactBytes = try JSONSerialization.data(withJSONObject: CourseCloudCodec.encode(cloud)!).count
        let oneTopicBytes = try JSONSerialization.data(withJSONObject: CourseCloudCodec.encode(cloud.progress["dns"]!)!).count
        precondition(checksum == iterations * 2)
        print(String(format: "Mac / optimized Swift: cache initialization %.3f ms; selection mean %.4f ms (%d iterations)",
                     initializationMS, meanMS, iterations))
        print("Representative 10-theme payload: snapshots \(fullBytes) B; ID payload \(compactBytes) B; changed DNS theme \(oneTopicBytes) B")
        print("Host measurements only; excludes iPhone rendering, network latency, and Firebase protocol overhead")
    }
}
