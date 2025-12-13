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
    case residential = "residential"
    case office = "office"
    case warehouse = "warehouse"
    case industrial = "industrial"
    case other = "other"
    
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
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        switch self {
        case .residential:
            return "type_residential".localized
        case .office:
            return "type_office".localized
        case .warehouse:
            return "type_warehouse".localized
        case .industrial:
            return "type_industrial".localized
        case .other:
            return "type_other".localized
        }
    }
    
    /// Возвращает отображаемое значение типа с учетом кастомного значения
    func displayValue(customType: String?) -> String {
        if self == .other, let custom = customType, !custom.isEmpty {
            return custom
        }
        return self.localizedName
    }
    
    /// Инициализатор с поддержкой старых значений (русские)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Поддержка старых значений на русском
        switch rawValue {
        case "Жилое", "residential":
            self = .residential
        case "Офисное", "office":
            self = .office
        case "Складское", "warehouse":
            self = .warehouse
        case "Производство", "industrial":
            self = .industrial
        case "Другое", "other":
            self = .other
        default:
            // Пытаемся найти по новому значению
            if let value = PropertyType(rawValue: rawValue) {
                self = value
            } else {
                // Fallback на other
                self = .other
            }
        }
    }
}

enum PropertyStatus: String, CaseIterable, Identifiable, Codable {
    case rented = "rented"
    case vacant = "vacant"
    case underRepair = "under_repair"
    case sold = "sold"
    
    var id: String { rawValue }
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        switch self {
        case .rented:
            return "status_rented".localized
        case .vacant:
            return "status_vacant".localized
        case .underRepair:
            return "status_under_repair".localized
        case .sold:
            return "status_sold".localized
        }
    }
    
    /// Инициализатор с поддержкой старых значений (русские)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Поддержка старых значений на русском
        switch rawValue {
        case "Сдано", "rented":
            self = .rented
        case "Свободно", "vacant":
            self = .vacant
        case "На ремонте", "under_repair":
            self = .underRepair
        case "Продано", "sold":
            self = .sold
        default:
            // Пытаемся найти по новому значению
            if let value = PropertyStatus(rawValue: rawValue) {
                self = value
            } else {
                // Fallback на vacant
                self = .vacant
            }
        }
    }
}

enum PropertyCondition: String, CaseIterable, Identifiable, Codable {
    case excellent = "excellent"
    case good = "good"
    case satisfactory = "satisfactory"
    case needsRepair = "needs_repair"
    
    var id: String { rawValue }
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        switch self {
        case .excellent:
            return "condition_excellent".localized
        case .good:
            return "condition_good".localized
        case .satisfactory:
            return "condition_satisfactory".localized
        case .needsRepair:
            return "condition_needs_repair".localized
        }
    }
    
    /// Инициализатор с поддержкой старых значений (русские)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Поддержка старых значений на русском
        switch rawValue {
        case "Отличное", "excellent":
            self = .excellent
        case "Хорошее", "good":
            self = .good
        case "Среднее", "satisfactory":
            self = .satisfactory
        case "Требует ремонта", "needs_repair":
            self = .needsRepair
        default:
            // Пытаемся найти по новому значению
            if let value = PropertyCondition(rawValue: rawValue) {
                self = value
            } else {
                // Fallback на excellent
                self = .excellent
            }
        }
    }
}

// MARK: - Area Unit

enum AreaUnit: String, CaseIterable, Identifiable, Codable, Hashable {
    case squareMeters = "m2"
    case squareFeet = "ft2"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .squareMeters:
            return "unit_square_meters".localized
        case .squareFeet:
            return "unit_square_feet".localized
        }
    }
    
    var symbol: String {
        switch self {
        case .squareMeters:
            return "м²"
        case .squareFeet:
            return "ft²"
        }
    }
    
    /// Конвертирует площадь из квадратных метров в выбранные единицы
    func convertFromMeters(_ meters: Double) -> Double {
        switch self {
        case .squareMeters:
            return meters
        case .squareFeet:
            return meters * 10.764 // 1 м² = 10.764 ft²
        }
    }
    
    /// Конвертирует площадь из выбранных единиц в квадратные метры
    func convertToMeters(_ value: Double) -> Double {
        switch self {
        case .squareMeters:
            return value
        case .squareFeet:
            return value / 10.764
        }
    }
}

// MARK: - Currency

enum Currency: String, CaseIterable, Identifiable, Codable, Hashable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"
    case chf = "CHF"
    case aud = "AUD"
    case cad = "CAD"
    
    var id: String { rawValue }
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        let key = "currency_\(rawValue.lowercased())"
        return key.localized
    }
    
    /// Символ валюты
    var symbol: String {
        // Используем специальные локали для получения правильных символов валют
        let locale: Locale
        switch self {
        case .rub:
            locale = Locale(identifier: "ru_RU")
        case .usd:
            locale = Locale(identifier: "en_US")
        case .eur:
            locale = Locale(identifier: "de_DE")
        case .gbp:
            locale = Locale(identifier: "en_GB")
        case .jpy:
            locale = Locale(identifier: "ja_JP")
        case .cny:
            locale = Locale(identifier: "zh_CN")
        case .chf:
            locale = Locale(identifier: "de_CH")
        case .aud:
            locale = Locale(identifier: "en_AU")
        case .cad:
            locale = Locale(identifier: "en_CA")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = rawValue
        formatter.locale = locale
        let symbol = formatter.currencySymbol ?? rawValue
        
        // Если получили код валюты вместо символа, используем известные символы
        if symbol == rawValue {
            switch self {
            case .rub:
                return "₽"
            case .usd:
                return "$"
            case .eur:
                return "€"
            case .gbp:
                return "£"
            case .jpy:
                return "¥"
            case .cny:
                return "¥"
            case .chf:
                return "CHF"
            case .aud:
                return "A$"
            case .cad:
                return "C$"
            }
        }
        
        return symbol
    }
    
    /// Полное название валюты с символом (например, "₽ Российский рубль", "$ Доллар США")
    var displayName: String {
        return "\(symbol) \(localizedName)"
    }
}

struct Property: Identifiable, Codable {
    var id: String
    var name: String
    var type: PropertyType
    var customType: String? // Кастомное значение типа, если выбрано "Другое"
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
    var notes: String? // Заметки об объекте (максимум 200 символов)
    var floors: Int? // Этажность: от 1 до 1 = "1 этаж", от 1 до 2 = "двухэтажное", -1 = "подвал"
    var currency: String? // Валюта объекта (код валюты, например "RUB", "USD", "EUR")
    
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
    case ip = "ip"
    case ooo = "ooo"
    case other = "individual"
    
    var id: String { rawValue }
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        switch self {
        case .ip:
            return "company_ip".localized
        case .ooo:
            return "company_ooo".localized
        case .other:
            return "company_individual".localized
        }
    }
}

// Тип депозита
enum DepositType: String, Codable, Identifiable {
    case oneMonth = "one_month"
    case twoMonths = "two_months"
    case custom = "custom"
    
    var id: String { rawValue }
    
    /// Локализованное отображаемое значение
    var localizedName: String {
        switch self {
        case .oneMonth:
            return "deposit_one_month".localized
        case .twoMonths:
            return "deposit_two_months".localized
        case .custom:
            return "deposit_custom".localized
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
    var companyType: CompanyType?
    var deposit: Double?
    var depositType: DepositType?
    var isArchived: Bool = false
    var moveToArchiveDate: String? // Дата перемещения в архив (опционально)
    
    enum CodingKeys: String, CodingKey {
        case name, income, startDate, endDate, area, indexation, companyType, deposit, depositType, isArchived, moveToArchiveDate
    }
    
    // Обычный инициализатор для создания Tenant вручную
    init(id: UUID = UUID(), name: String, income: Double? = nil, startDate: String? = nil, endDate: String? = nil, area: Double? = nil, indexation: String? = nil, companyType: CompanyType? = nil, deposit: Double? = nil, depositType: DepositType? = nil, isArchived: Bool = false, moveToArchiveDate: String? = nil) {
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
        self.moveToArchiveDate = moveToArchiveDate
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
        
        // Обрабатываем companyType с поддержкой старых значений
        if let companyTypeString = try? container.decode(String.self, forKey: .companyType),
                  !companyTypeString.isEmpty {
            // Поддержка старых значений на русском
            switch companyTypeString {
            case "ИП", "ip":
                companyType = .ip
            case "ООО", "ooo":
                companyType = .ooo
            case "Физ. лицо", "individual":
                companyType = .other
            default:
            companyType = CompanyType(rawValue: companyTypeString)
            }
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
        
        // Обрабатываем depositType с поддержкой старых значений
        if let depositTypeString = try? container.decode(String.self, forKey: .depositType),
                  !depositTypeString.isEmpty {
            // Поддержка старых значений на русском
            switch depositTypeString {
            case "1 месяц", "one_month":
                depositType = .oneMonth
            case "2 месяца", "two_months":
                depositType = .twoMonths
            case "Вручную", "custom":
                depositType = .custom
            default:
            depositType = DepositType(rawValue: depositTypeString)
            }
        } else {
            depositType = nil
        }
        
        // Обрабатываем isArchived: может отсутствовать в старых данных
        isArchived = (try? container.decode(Bool.self, forKey: .isArchived)) ?? false
        
        // Обрабатываем moveToArchiveDate: может быть строкой или пустой строкой
        if let archiveDateValue = try? container.decode(String.self, forKey: .moveToArchiveDate),
           !archiveDateValue.isEmpty {
            moveToArchiveDate = archiveDateValue
        } else {
            moveToArchiveDate = nil
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
        var areaUnit: String? // "m2" или "ft2"
    }
    
    // Игнорируем неизвестные ключи при декодировании
    enum CodingKeys: String, CodingKey {
        case objects
        case settings
        // Не включаем calendarEvents, asset_map и другие дополнительные поля
    }
}

