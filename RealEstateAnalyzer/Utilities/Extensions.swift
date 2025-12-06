//
//  Extensions.swift
//  RealEstateAnalyzer
//
//  Расширения для удобства работы
//

import Foundation
import SwiftUI

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

extension Double {
    func formattedCurrency(currencyCode: String = "RUB") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Color {
    static let appPurple = Color(red: 0.75, green: 0.67, blue: 1.0) // #bfaaff
    static let appGreen = Color(red: 0.64, green: 0.79, blue: 0.64) // #a3caa2
    static let appPink = Color(red: 1.0, green: 0.73, blue: 1.0) // #ffbaff
}

