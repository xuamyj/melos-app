import SwiftUI

enum TrackColor: Int, CaseIterable, Codable {
    case lightOrange = 0
    case periwinkle = 1
    case lightYellow = 2
    case softTerracotta = 3
    case skyBlue = 4
    case lightKellyGreen = 5
    case lavender = 6

    var color: Color {
        switch self {
        case .lightOrange:     return Color(red: 1.0, green: 0.8, blue: 0.5)
        case .periwinkle:      return Color(red: 0.6, green: 0.6, blue: 0.9)
        case .lightYellow:     return Color(red: 1.0, green: 0.96, blue: 0.65)
        case .softTerracotta:  return Color(red: 0.88, green: 0.52, blue: 0.43)
        case .skyBlue:         return Color(red: 0.53, green: 0.81, blue: 0.92)
        case .lightKellyGreen: return Color(red: 0.56, green: 0.87, blue: 0.56)
        case .lavender:        return Color(red: 0.78, green: 0.64, blue: 0.87)
        }
    }

    static func forIndex(_ index: Int) -> TrackColor {
        let safeIndex = index % allCases.count
        return TrackColor(rawValue: safeIndex) ?? .lightOrange
    }
}
