import Foundation
import os

enum RedactingLog {
    private static let logger = Logger(subsystem: "com.personal.ordertracker", category: "app")

    static func info(_ message: String) {
        logger.info("\(sanitize(message), privacy: .public)")
    }

    static func error(_ message: String) {
        logger.error("\(sanitize(message), privacy: .public)")
    }

    static func sanitize(_ message: String) -> String {
        var result = message
        let patterns = [
            #"(?i)(password|пароль|token|cookie|sms|code|код)\s*[:=]\s*\S+"#,
            #"\+?\d{10,15}"#,
            #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..<result.endIndex, in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "[REDACTED]")
            }
        }
        return result
    }
}
