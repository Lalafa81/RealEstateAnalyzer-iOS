//
//  Extensions.swift
//  RealEstateAnalyzer
//
//  Расширения для удобства работы
//

import Foundation
import SwiftUI

// MARK: - Area Unit Extensions

extension Double {
    /// Форматирует площадь с учетом выбранных единиц измерения
    func formatArea() -> String {
        let areaUnit = DataManager.shared.settings?.areaUnit ?? "m2"
        let unit = AreaUnit(rawValue: areaUnit) ?? .squareMeters
        let convertedValue = unit.convertFromMeters(self)
        return String(format: "%.0f", convertedValue)
    }
    
    /// Возвращает символ единицы измерения площади
    static func getAreaUnitSymbol() -> String {
        let areaUnit = DataManager.shared.settings?.areaUnit ?? "m2"
        let unit = AreaUnit(rawValue: areaUnit) ?? .squareMeters
        return unit.symbol
    }
    
    /// Возвращает локализованное название единицы измерения площади
    static func getAreaUnitName() -> String {
        let areaUnit = DataManager.shared.settings?.areaUnit ?? "m2"
        let unit = AreaUnit(rawValue: areaUnit) ?? .squareMeters
        return unit.localizedName
    }
}

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
    
    /// Получает символ валюты по коду валюты
    private static func getCurrencySymbol(for code: String) -> String {
        if let currency = Currency(rawValue: code) {
            return currency.symbol
        }
        // Fallback: используем NumberFormatter с русской локалью для получения символа
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.currencySymbol ?? code
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
    
    /// Форматирует число в сокращенном формате для дохода с символом валюты перед числом
    /// Примеры: "$217.1k", "€240.5k", "₽150.2k"
    /// - Parameter currencyCode: Код валюты из настроек приложения (если не указан, берется из settings.summaryCurrency)
    func formatShortCurrencyWithPrefix(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? Self.getCurrencyCode()
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        // Получаем символ валюты через Currency enum
        let currencySymbol = Self.getCurrencySymbol(for: code)
        
        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            if millions.truncatingRemainder(dividingBy: 0.1) == 0 {
                return "\(sign)\(currencySymbol)\(Int(millions))M"
            } else {
                return "\(sign)\(currencySymbol)\(String(format: "%.1f", millions))M"
            }
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            if thousands.truncatingRemainder(dividingBy: 0.1) == 0 {
                return "\(sign)\(currencySymbol)\(Int(thousands))k"
            } else {
                return "\(sign)\(currencySymbol)\(String(format: "%.1f", thousands))k"
            }
        } else {
            // Для значений меньше 1000 используем полный формат
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ""
            formatter.maximumFractionDigits = 0
            let formattedNumber = formatter.string(from: NSNumber(value: absValue)) ?? "\(Int(absValue))"
            return "\(sign)\(currencySymbol)\(formattedNumber)"
        }
    }
    
    /// Форматирует число как валюту с символом валюты
    /// - Parameter currencyCode: Код валюты из настроек приложения (если не указан, берется из settings.summaryCurrency)
    /// Использует системную локаль (Locale.current) для форматирования (разделители, порядок символа и т.д.)
    /// но код валюты берется из настроек приложения
    func formatCurrencyWithSymbol(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? Self.getCurrencyCode()
        let locale = Locale.current // Используем системную локаль для форматирования
        let currencySymbol = Self.getCurrencySymbol(for: code)
        
        // Форматируем число с пробелами для тысяч
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        let formattedNumber = formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
        
        // Определяем порядок символа валюты в зависимости от локали
        // Для русской локали символ обычно после числа, для английской - перед
        let isRussian = locale.identifier.hasPrefix("ru") || locale.identifier.hasPrefix("uk") || locale.identifier.hasPrefix("be")
        if isRussian {
            return "\(formattedNumber) \(currencySymbol)"
        } else {
            return "\(currencySymbol)\(formattedNumber)"
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

extension String {
    /// Получает Bundle для локализации на основе настроек приложения
    private static func getLocalizationBundle() -> Bundle {
        let localeCode = DataManager.shared.settings?.locale ?? "ru"
        guard let path = Bundle.main.path(forResource: localeCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback на системную локаль или русскую
            return Bundle.main
        }
        return bundle
    }
    
    /// Локализованная строка (использует локаль из настроек приложения)
    var localized: String {
        let bundle = Self.getLocalizationBundle()
        return NSLocalizedString(self, bundle: bundle, comment: "")
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
        // Используем локаль из настроек приложения, если доступна
        if let localeCode = DataManager.shared.settings?.locale {
            formatter.locale = Locale(identifier: localeCode == "ru" ? "ru_RU" : "en_US")
        } else {
            formatter.locale = Locale.current
        }
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
        // Используем локаль из настроек приложения, если доступна
        if let localeCode = DataManager.shared.settings?.locale {
            formatter.locale = Locale(identifier: localeCode == "ru" ? "ru_RU" : "en_US")
        } else {
            formatter.locale = Locale.current
        }
        var months: [String] = []
        for i in 1...12 {
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: i, day: 1))!
            formatter.dateFormat = "MMM"
            months.append(formatter.string(from: date))
        }
        return months
    }
}

extension Property {
    /// Получает код валюты объекта или значение по умолчанию из настроек
    func getCurrencyCode() -> String {
        return currency ?? DataManager.shared.settings?.summaryCurrency ?? "RUB"
    }
}

// MARK: - App Version Extensions

extension Bundle {
    /// Получает версию приложения из Info.plist
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Получает номер сборки из Info.plist
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

