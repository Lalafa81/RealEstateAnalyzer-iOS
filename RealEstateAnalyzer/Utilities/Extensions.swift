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
    /// Форматирует число как валюту (с пробелами для тысяч, без символа валюты)
    func formatCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
    }
    
    /// Форматирует число как валюту с символом валюты (старый метод, оставлен для совместимости)
    func formattedCurrency(currencyCode: String = "RUB") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Optional where Wrapped == String {
    /// Получает имя SF Symbol для иконки объекта недвижимости
    func getIconName() -> String {
        guard let icon = self else { return "house" }
        
        switch icon.lowercased() {
        case "warehouse", "складская", "склад":
            return "shippingbox"
        case "house", "жилая", "дом":
            return "house"
        case "building", "office", "торговая", "торговое":
            return "building.2"
        case "land", "земельный участок", "земля", "участок":
            return "square"
        case "store", "магазин":
            return "storefront"
        case "garage", "гараж":
            return "carport"
        case "other", "другое":
            return "square.grid.2x2"
        default:
            return "house"
        }
    }
}

extension Array {
    /// Безопасный доступ к элементу массива по индексу
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    static let appPurple = Color(red: 0.75, green: 0.67, blue: 1.0) // #bfaaff
    static let appGreen = Color(red: 0.64, green: 0.79, blue: 0.64) // #a3caa2
    static let appPink = Color(red: 1.0, green: 0.73, blue: 1.0) // #ffbaff
}

