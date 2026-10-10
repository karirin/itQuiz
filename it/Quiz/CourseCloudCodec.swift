import Foundation

/// Local persistence keeps snapshots. Cloud payloads reference bundled question IDs
/// whenever the exact edition is available, avoiding repeated question/explanation text.
enum CourseCloudCodec {
    static let compactKey = CodingUserInfoKey(rawValue: "courseCompactPayload")!

    static func encode<T: Encodable>(_ value: T) -> Any? {
        let encoder = JSONEncoder()
        encoder.userInfo[compactKey] = true
        guard let data = try? encoder.encode(value) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }

    static func decode<T: Decodable>(_ type: T.Type, from value: Any?) -> T? {
        guard let value, !(value is NSNull),
              let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

/// Baseline is the last acknowledged cloud state, not the last attempted write.
/// New edits during a request remain dirty; failed requests are retried after reconnect.
struct CourseSyncDelta {
    let progress: [String: CourseProgress]
    let freeClaim: CourseFreeClaim?
    let importedSourceIDs: [String]

    init(local: CourseCloudState, acknowledged: CourseCloudState) {
        progress = local.progress.filter { acknowledged.progress[$0.key] != $0.value }
        freeClaim = local.freeClaim != acknowledged.freeClaim ? local.freeClaim : nil
        importedSourceIDs = Array(Set(local.importedSourceIDs).subtracting(acknowledged.importedSourceIDs)).sorted()
    }

    var isEmpty: Bool { progress.isEmpty && freeClaim == nil && importedSourceIDs.isEmpty }
}
