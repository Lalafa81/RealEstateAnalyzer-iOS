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
    /// Получает код валюты из настроек приложения или возвращает значение по умолчанию
    private static func getCurrencyCode() -> String {
        return DataManager.shared.settings?.summaryCurrency ?? "RUB"
    }
    
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
    
    /// Форматирует число в сокращенном формате с локализованной валютой и единицами
    /// Примеры: "240 тыс ₽" (ru), "240K $" (en-US), "240K €" (en-EU)
    /// - Parameter currencyCode: Код валюты из настроек приложения (если не указан, берется из settings.summaryCurrency)
    func formatShortCurrencyLocalized(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? Self.getCurrencyCode()
        let locale = Locale.current // Используем системную локаль для форматирования
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        // Получаем символ валюты из настроек приложения (code), но форматируем по системной локали
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = locale // Форматирование по системной локали
        let currencySymbol = formatter.currencySymbol ?? code
        
        // Определяем единицы измерения (тыс/млн для русского, K/M для английского)
        let isRussian = locale.identifier.hasPrefix("ru") || locale.identifier.hasPrefix("uk") || locale.identifier.hasPrefix("be")
        let thousandUnit = isRussian ? "тыс" : "K"
        let millionUnit = isRussian ? "млн" : "M"
        
        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            if millions.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(millions)) \(millionUnit) \(currencySymbol)"
            } else {
                return "\(sign)\(String(format: "%.1f", millions)) \(millionUnit) \(currencySymbol)"
            }
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(thousands)) \(thousandUnit) \(currencySymbol)"
            } else {
                return "\(sign)\(String(format: "%.1f", thousands)) \(thousandUnit) \(currencySymbol)"
            }
        } else {
            // Для значений меньше 1000 используем полный формат с валютой
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: self)) ?? "\(sign)\(Int(absValue)) \(currencySymbol)"
        }
    }
    
    /// Форматирует число как валюту с символом валюты
    /// - Parameter currencyCode: Код валюты из настроек приложения (если не указан, берется из settings.summaryCurrency)
    /// Использует системную локаль (Locale.current) для форматирования (разделители, порядок символа и т.д.)
    /// но код валюты берется из настроек приложения
    func formatCurrencyWithSymbol(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? Self.getCurrencyCode()
        let locale = Locale.current // Используем системную локаль для форматирования
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code // Код валюты из настроек приложения
        formatter.locale = locale // Форматирование по системной локали (разделители, порядок символа)
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? formatCurrency()
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

extension String {
    /// Локализованная строка
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Локализованная строка с аргументами
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

extension DateFormatter {
    /// Возвращает массив локализованных полных названий месяцев
    static func localizedMonthNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        var months: [String] = []
        for i in 1...12 {
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: i, day: 1))!
            formatter.dateFormat = "MMMM"
            months.append(formatter.string(from: date))
        }
        return months
    }
    
    /// Возвращает массив локализованных коротких названий месяцев
    static func localizedShortMonthNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        var months: [String] = []
        for i in 1...12 {
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: i, day: 1))!
            formatter.dateFormat = "MMM"
            months.append(formatter.string(from: date))
        }
        return months
    }
}

