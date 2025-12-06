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
    var source: String? // Источник объекта (может отсутствовать в JSON)
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
    
    // Обычный инициализатор для создания Tenant вручную
    init(id: UUID = UUID(), name: String, income: Double? = nil, startDate: String? = nil, endDate: String? = nil, area: Double? = nil, indexation: String? = nil) {
        self.id = id
        self.name = name
        self.income = income
        self.startDate = startDate
        self.endDate = endDate
        self.area = area
        self.indexation = indexation
    }
    
    // Кастомный декодер для обработки пустых строк как nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        
        // Обрабатываем income: может быть Double, строкой или пустой строкой
        if let incomeValue = try? container.decode(Double.self, forKey: .income) {
            income = incomeValue
        } else if let incomeString = try? container.decode(String.self, forKey: .income),
                  !incomeString.isEmpty,
                  let incomeDouble = Double(incomeString) {
            income = incomeDouble
        } else {
            income = nil
        }
        
        // Обрабатываем startDate: может быть строкой или пустой строкой
        if let startDateValue = try? container.decode(String.self, forKey: .startDate),
           !startDateValue.isEmpty {
            startDate = startDateValue
        } else {
            startDate = nil
        }
        
        // Обрабатываем endDate: может быть строкой или пустой строкой
        if let endDateValue = try? container.decode(String.self, forKey: .endDate),
           !endDateValue.isEmpty {
            endDate = endDateValue
        } else {
            endDate = nil
        }
        
        // Обрабатываем area: может быть Double, строкой или пустой строкой
        if let areaValue = try? container.decode(Double.self, forKey: .area) {
            area = areaValue
        } else if let areaString = try? container.decode(String.self, forKey: .area),
                  !areaString.isEmpty,
                  let areaDouble = Double(areaString) {
            area = areaDouble
        } else {
            area = nil
        }
        
        // Обрабатываем indexation: может быть строкой или пустой строкой
        if let indexationValue = try? container.decode(String.self, forKey: .indexation),
           !indexationValue.isEmpty {
            indexation = indexationValue
        } else {
            indexation = nil
        }
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

