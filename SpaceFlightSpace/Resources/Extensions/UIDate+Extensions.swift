//
//  UIDate+Extensions.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import Foundation

enum DateFormatStyle: String {
    case dayMonthYearTime = "dd MMM yyyy, HH:mm"
    case shortDateTime = "dd/MM/yyyy HH:mm"
    case onlyDate = "dd/MM/yyyy"
    case onlyTime = "HH:mm"
    case isoDate = "yyyy-MM-dd'T'HH:mm:ssZ"
}

extension Date {
    func formattedString(using style: DateFormatStyle = .dayMonthYearTime, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.rawValue
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}


