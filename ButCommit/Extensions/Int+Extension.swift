//
//  Int+Extension.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/28.
//

import Foundation

extension Int {
    func getEmoji() -> String {
        switch self {
        case 1 ..< 4:
            return "🌱"
        case 4 ..< 10:
            return "🌿"
        case 10 ..< 100:
            return "🌳"
        default:
            return "🔥"
        }
    }
}
