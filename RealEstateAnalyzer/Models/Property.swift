//
//  Property.swift
//  RealEstateAnalyzer
//
//  Модель объекта недвижимости
//

import Foundation

// MARK: - Модель для хранения изображений объектов

struct PropertyImages: Codable {
    var images: [String: PropertyImageData] // [propertyId: PropertyImageData]
    
    struct PropertyImageData: Codable {
        var coverImage: String? // Имя файла основного фото объекта (независимо от галереи)
        var gallery: [String] // Массив имен файлов для галереи (например, ["property_002_gallery_0.jpg", ...])
    }
    
    init() {
        self.images = [:]
    }
}

// MARK: - Enums для типов, статусов и состояний

enum PropertyType: String, CaseIterable, Identifiable, Codable {
    case residential = "Жилое"
    case office = "Офисное"
    case warehouse = "Складское"
    case industrial = "Производство"
    case other = "Другое"
    
    var id: String { rawValue }
    
    /// Возвращает SF Symbol для назначения помещения
    var iconName: String {
        switch self {
        case .residential:
            return "house"
        case .office:
            return "building.2"
        case .warehouse:
            return "shippingbox"
        case .industrial:
            return "gearshape.2"
        case .other:
            return "square.grid.2x2"
        }
    }
}

enum PropertyStatus: String, CaseIterable, Identifiable, Codable {
    case rented = "Сдано"
    case vacant = "Свободно"
    case underRepair = "На ремонте"
    case sold = "Продано"
    
    var id: String { rawValue }
}

enum PropertyCondition: String, CaseIterable, Identifiable, Codable {
    case excellent = "Отличное"
    case good = "Хорошее"
    case satisfactory = "Среднее"
    case needsRepair = "Требует ремонта"
    
    var id: String { rawValue }
}

struct Property: Identifiable, Codable {
    var id: String
    var name: String
    var type: PropertyType
    var address: String
    var area: Double
    var purchasePrice: Double
    var purchaseDate: String
    var status: PropertyStatus
    var source: String? // Источник объекта (может отсутствовать в JSON)
    var tenants: [Tenant]
    var months: [String: [String: MonthData]]
    var propertyTax: Double?
    var insuranceCost: Double?
    var exitPrice: Double?
    var condition: PropertyCondition? // Состояние объекта
    var icon: String? // Иконка объекта (warehouse, house и т.д.)
    var image: String? // Base64-кодированное изображение объекта (data:image/jpeg;base64,...)
    var gallery: [String]? // Массив base64-кодированных изображений для галереи
    
    struct MonthData: Codable {
        // Доходы
        var income: Double?              // Постоянный доход
        var incomeVariable: Double?       // Переменный доход
        
        // Расходы
        var expensesMaintenance: Double?  // Административные расходы (техническое обслуживание)
        var expensesOperational: Double?  // Эксплуатационные расходы
        var expensesOther: Double?       // Прочие расходы
        
        enum CodingKeys: String, CodingKey {
            case income
            case incomeVariable = "income_variable"
            case expensesMaintenance = "expenses_maintenance"
            case expensesOperational = "expenses_operational"
            case expensesOther = "expenses_other"
        }
    }
}

// Тип компании арендатора
enum CompanyType: String, Codable, CaseIterable, Identifiable {
    case ip = "ИП"
    case ooo = "ООО"
    
    var id: String { rawValue }
}

// Тип депозита
enum DepositType: String, Codable, Identifiable {
    case oneMonth = "1 месяц"
    case twoMonths = "2 месяца"
    case custom = "Вручную"
    
    var id: String { rawValue }
}

struct Tenant: Identifiable, Codable {
    var id = UUID()
    var name: String
    var income: Double?
    var startDate: String?
    var endDate: String?
    var area: Double?
    var indexation: String?
    var companyType: CompanyType?
    var deposit: Double?
    var depositType: DepositType?
    var isArchived: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, income, startDate, endDate, area, indexation, companyType, deposit, depositType, isArchived
    }
    
    // Обычный инициализатор для создания Tenant вручную
    init(id: UUID = UUID(), name: String, income: Double? = nil, startDate: String? = nil, endDate: String? = nil, area: Double? = nil, indexation: String? = nil, companyType: CompanyType? = nil, deposit: Double? = nil, depositType: DepositType? = nil, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.income = income
        self.startDate = startDate
        self.endDate = endDate
        self.area = area
        self.indexation = indexation
        self.companyType = companyType
        self.deposit = deposit
        self.depositType = depositType
        self.isArchived = isArchived
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
        
        // Обрабатываем companyType
        if let companyTypeValue = try? container.decode(CompanyType.self, forKey: .companyType) {
            companyType = companyTypeValue
        } else if let companyTypeString = try? container.decode(String.self, forKey: .companyType),
                  !companyTypeString.isEmpty {
            companyType = CompanyType(rawValue: companyTypeString)
        } else {
            companyType = nil
        }
        
        // Обрабатываем deposit
        if let depositValue = try? container.decode(Double.self, forKey: .deposit) {
            deposit = depositValue
        } else if let depositString = try? container.decode(String.self, forKey: .deposit),
                  !depositString.isEmpty,
                  let depositDouble = Double(depositString) {
            deposit = depositDouble
        } else {
            deposit = nil
        }
        
        // Обрабатываем depositType
        if let depositTypeValue = try? container.decode(DepositType.self, forKey: .depositType) {
            depositType = depositTypeValue
        } else if let depositTypeString = try? container.decode(String.self, forKey: .depositType),
                  !depositTypeString.isEmpty {
            depositType = DepositType(rawValue: depositTypeString)
        } else {
            depositType = nil
        }
        
        // Обрабатываем isArchived: может отсутствовать в старых данных
        isArchived = (try? container.decode(Bool.self, forKey: .isArchived)) ?? false
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

