//
//  Property.swift
//  RealEstateAnalyzer
//
//  Модель объекта недвижимости
//

import Foundation

struct Property: Identifiable, Codable {
    var id: String
    var name: String
    var type: String
    var address: String
    var area: Double
    var purchasePrice: Double
    var purchaseDate: String
    var status: String
    var source: String
    var tenants: [Tenant]
    var months: [String: [String: MonthData]]
    var propertyTax: Double?
    var insuranceCost: Double?
    var exitPrice: Double?
    var condition: String? // Состояние объекта (Отличное, Хорошее, Требует ремонта и т.д.)
    var icon: String? // Иконка объекта (warehouse, house и т.д.)
    var image: String? // Base64-кодированное изображение объекта (data:image/jpeg;base64,...)
    var gallery: [String]? // Массив base64-кодированных изображений для галереи
    
    struct MonthData: Codable {
        var income: Double?
        var incomeVariable: Double?
        var expensesDirect: Double?
        var expensesAdmin: Double?
        var expensesMaintenance: Double?
        var expensesUtilities: Double?
        var expensesFinancial: Double?
        var expensesOperational: Double?
        var expensesOther: Double?
        
        enum CodingKeys: String, CodingKey {
            case income
            case incomeVariable = "income_variable"
            case expensesDirect = "expenses_direct"
            case expensesAdmin = "expenses_admin"
            case expensesMaintenance = "expenses_maintenance"
            case expensesUtilities = "expenses_utilities"
            case expensesFinancial = "expenses_financial"
            case expensesOperational = "expenses_operational"
            case expensesOther = "expenses_other"
        }
    }
}

struct Tenant: Identifiable, Codable {
    var id = UUID()
    var name: String
    var income: Double?
    var startDate: String?
    var endDate: String?
    var area: Double?
    var indexation: String?
    
    enum CodingKeys: String, CodingKey {
        case name, income, startDate, endDate, area, indexation
    }
}

struct PropertyData: Codable {
    var objects: [Property]
    var settings: Settings?
    // Игнорируем дополнительные поля: calendarEvents, asset_map и т.д.
    
    struct Settings: Codable {
        var locale: String?
        var currency: String?
        var summaryCurrency: String?
    }
    
    // Игнорируем неизвестные ключи при декодировании
    enum CodingKeys: String, CodingKey {
        case objects
        case settings
        // Не включаем calendarEvents, asset_map и другие дополнительные поля
    }
}

