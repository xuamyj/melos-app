import Foundation

struct AppSettings: Codable {
    var skipIntervalSeconds: Int

    static let `default` = AppSettings(skipIntervalSeconds: 15)
    static let skipIntervalOptions = [5, 10, 15, 30]
}
