//
//  Date+Extension.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/27.
//

import Foundation

extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        let prefLanguage = Locale.preferredLanguages[0]

        dateFormatter.locale = NSLocale(localeIdentifier: prefLanguage) as Locale
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self).capitalized
    }
}
