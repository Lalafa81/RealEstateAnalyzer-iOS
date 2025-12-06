//
//  DataManager.swift
//  RealEstateAnalyzer
//
//  Менеджер данных - замена data_api.py
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var properties: [Property] = []
    @Published var settings: PropertyData.Settings?
    
    private let dataFileName = "data.json"
    private let assetMapFileName = "asset_map.json"
    
    private init() {}
    
    // MARK: - Генерация ID
    
    /// Генерирует следующий доступный ID в формате "001", "002", "003" и т.д.
    func generateNextID() -> String {
        // Извлекаем все числовые ID из существующих объектов
        let existingIDs = properties.compactMap { property -> Int? in
            // Пробуем распарсить ID как число
            if let numID = Int(property.id) {
                return numID
            }
            // Если ID не число (старый UUID), игнорируем его
            return nil
        }
        let maxID = existingIDs.max() ?? 0
        let nextID = maxID + 1
        return String(format: "%03d", nextID)
    }
    
    // MARK: - Загрузка данных
    
    /// Принудительно перезагружает данные из Bundle, удаляя старый файл из Documents
    func forceReloadFromBundle() {
        let documentsURL = getDocumentsURL().appendingPathComponent(dataFileName)
        
        // Удаляем старый файл из Documents
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            do {
                try FileManager.default.removeItem(at: documentsURL)
                print("🗑️ Удален старый файл из Documents")
            } catch {
                print("⚠️ Не удалось удалить файл: \(error)")
            }
        }
        
        // Загружаем из Bundle
        loadData()
    }
    
    func loadData() {
        let documentsURL = getDocumentsURL().appendingPathComponent(dataFileName)
        
        // СНАЧАЛА пробуем загрузить из Bundle (ресурсы проекта) - это приоритетный источник
        if let bundleURL = Bundle.main.url(forResource: "data", withExtension: "json") {
            print("📦 Найден data.json в Bundle: \(bundleURL.path)")
            if loadData(from: bundleURL) {
                // Копируем из bundle в Documents для дальнейшего использования
                // Но только если в Documents нет файла или он пустой
                if !FileManager.default.fileExists(atPath: documentsURL.path) {
                    copyFile(from: bundleURL, to: documentsURL)
                } else {
                    print("ℹ️ Файл в Documents уже существует, не перезаписываем")
                }
                return
            }
        } else {
            print("⚠️ Файл data.json не найден в Bundle")
        }
        
        // Если в Bundle нет или не загрузился, пробуем загрузить из Documents (пользовательские данные)
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            print("📁 Найден data.json в Documents: \(documentsURL.path)")
            if loadData(from: documentsURL) {
                // Проверяем, не являются ли это тестовые данные
                if isTestData() {
                    print("⚠️ Обнаружены тестовые данные в Documents, перезагружаем из Bundle")
                    try? FileManager.default.removeItem(at: documentsURL)
                    // Пробуем снова загрузить из Bundle
                    if let bundleURL = Bundle.main.url(forResource: "data", withExtension: "json") {
                        if loadData(from: bundleURL) {
                            copyFile(from: bundleURL, to: documentsURL)
                            return
                        }
                    }
                } else {
                    return
                }
            } else {
                print("⚠️ Файл в Documents не загрузился, удаляем его")
                // Удаляем поврежденный файл
                try? FileManager.default.removeItem(at: documentsURL)
            }
        } else {
            print("⚠️ Файл data.json не найден в Documents")
        }
        
        // Если ничего не найдено, загружаем тестовые данные
        print("❌ Файл данных не найден. Загружаем тестовые данные.")
        loadSampleData()
    }
    
    private func loadData(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            print("📊 Размер файла: \(data.count) байт")
            
            let decoder = JSONDecoder()
            let propertyData = try decoder.decode(PropertyData.self, from: data)
            self.properties = propertyData.objects
            self.settings = propertyData.settings
            
            // Мигрируем старые UUID в простые ID
            migrateIDsToSimpleFormat()
            
            // Мигрируем старые иконки на правильные SF Symbols
            migrateIconsToSFSymbols()
            
            // Если данных нет, возвращаем false
            if self.properties.isEmpty {
                print("⚠️ Файл найден, но объектов нет.")
                return false
            } else {
                print("✅ Загружено объектов: \(self.properties.count)")
                for (index, prop) in self.properties.enumerated() {
                    print("  \(index + 1). \(prop.name) (ID: \(prop.id))")
                }
                return true
            }
        } catch {
            print("❌ Ошибка загрузки данных из \(url.path): \(error)")
            return false
        }
    }
    
    /// Мигрирует старые иконки на правильные SF Symbols
    private func migrateIconsToSFSymbols() {
        var needsSave = false
        for i in 0..<properties.count {
            let currentIcon = properties[i].icon
            var newIcon: String
            var shouldUpdate = false
            
            if let icon = currentIcon {
                switch icon.lowercased() {
                case "warehouse":
                    newIcon = "archivebox.fill"
                    shouldUpdate = true
                case "house":
                    newIcon = "house.fill"
                    shouldUpdate = (icon != newIcon)
                case "building", "office":
                    newIcon = "building.2.fill"
                    shouldUpdate = true
                case "land", "земельный участок":
                    newIcon = "square.fill"
                    shouldUpdate = true
                default:
                    // Если это уже правильная SF Symbol, оставляем как есть
                    newIcon = icon
                    shouldUpdate = false
                }
            } else {
                // Если иконки нет, устанавливаем дефолтную
                newIcon = "house.fill"
                shouldUpdate = true
            }
            
            if shouldUpdate && properties[i].icon != newIcon {
                properties[i].icon = newIcon
                needsSave = true
            }
        }
        
        if needsSave {
            saveData()
            print("✅ Миграция иконок завершена")
        }
    }
    
    /// Мигрирует старые UUID в простой формат "001", "002", "003" и т.д.
    private func migrateIDsToSimpleFormat() {
        var needsMigration = false
        for i in 0..<properties.count {
            // Проверяем, является ли ID UUID (содержит дефисы и длинный)
            if properties[i].id.contains("-") || properties[i].id.count > 10 {
                needsMigration = true
                break
            }
        }
        
        if needsMigration {
            print("🔄 Миграция ID объектов в простой формат...")
            for i in 0..<properties.count {
                // Если ID не является числом, заменяем его на простой номер
                if Int(properties[i].id) == nil {
                    properties[i].id = String(format: "%03d", i + 1)
                }
            }
            // Сохраняем мигрированные данные
            saveData()
            print("✅ Миграция завершена")
        }
    }
    
    private func copyFile(from source: URL, to destination: URL) {
        do {
            try FileManager.default.copyItem(at: source, to: destination)
            print("✅ Файл скопирован из bundle в Documents")
        } catch {
            print("⚠️ Не удалось скопировать файл: \(error)")
        }
    }
    
    // MARK: - Проверка данных
    
    /// Проверяет, являются ли загруженные данные тестовыми
    private func isTestData() -> Bool {
        // Проверяем по характерным признакам тестовых данных
        let testNames = ["Квартира на Тверской", "Офис в БЦ", "Склад на окраине"]
        return properties.contains { property in
            testNames.contains(property.name)
        }
    }
    
    // MARK: - Тестовые данные
    
    /// Загружает тестовые данные для демонстрации функциональности
    func loadSampleData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let purchaseDate = formatter.string(from: currentDate.addingTimeInterval(-365 * 24 * 60 * 60 * 2)) // 2 года назад
        
        // Создаем данные за последние 12 месяцев
        var monthsData: [String: [String: Property.MonthData]] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        let monthNames = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        var yearData: [String: Property.MonthData] = [:]
        for month in monthNames {
            yearData[month] = Property.MonthData(
                income: Double.random(in: 50000...80000),
                incomeVariable: nil,
                expensesDirect: nil,
                expensesAdmin: Double.random(in: 5000...10000),
                expensesMaintenance: Double.random(in: 10000...20000),
                expensesUtilities: Double.random(in: 8000...15000),
                expensesFinancial: nil,
                expensesOperational: Double.random(in: 5000...10000),
                expensesOther: Double.random(in: 2000...5000)
            )
        }
        monthsData[String(currentYear)] = yearData
        
        // Объект 1: Квартира в Москве
        let property1 = Property(
            id: "001",
            name: "Квартира на Тверской",
            type: "Жилая",
            address: "г. Москва, ул. Тверская, д. 10, кв. 45",
            area: 65.5,
            purchasePrice: 12_500_000,
            purchaseDate: purchaseDate,
            status: "Сдано",
            source: "Покупка",
            tenants: [
                Tenant(
                    name: "Иванов Иван",
                    income: 75000,
                    startDate: "01.01.\(currentYear)",
                    endDate: "31.12.\(currentYear)",
                    area: 65.5,
                    indexation: "5%"
                )
            ],
            months: monthsData,
            propertyTax: 15000,
            insuranceCost: 12000,
            exitPrice: 13_500_000,
            icon: "house.fill"
        )
        
        // Объект 2: Офисное помещение
        let property2 = Property(
            id: "002",
            name: "Офис в БЦ",
            type: "Коммерческая",
            address: "г. Москва, ул. Ленина, д. 5, оф. 301",
            area: 120.0,
            purchasePrice: 25_000_000,
            purchaseDate: purchaseDate,
            status: "Сдано",
            source: "Покупка",
            tenants: [
                Tenant(
                    name: "ООО Компания",
                    income: 150000,
                    startDate: "01.01.\(currentYear)",
                    endDate: "31.12.\(currentYear)",
                    area: 120.0,
                    indexation: "3%"
                )
            ],
            months: monthsData,
            propertyTax: 30000,
            insuranceCost: 25000,
            exitPrice: 27_000_000,
            icon: "building.2.fill"
        )
        
        // Объект 3: Склад
        let property3 = Property(
            id: "003",
            name: "Склад на окраине",
            type: "Складская",
            address: "Московская обл., г. Химки, складской комплекс",
            area: 500.0,
            purchasePrice: 45_000_000,
            purchaseDate: purchaseDate,
            status: "Сдано",
            source: "Покупка",
            tenants: [
                Tenant(
                    name: "Логистика Плюс",
                    income: 400000,
                    startDate: "01.01.\(currentYear)",
                    endDate: "31.12.\(currentYear)",
                    area: 500.0,
                    indexation: "7%"
                )
            ],
            months: monthsData,
            propertyTax: 80000,
            insuranceCost: 60000,
            exitPrice: 50_000_000,
            icon: "archivebox.fill"
        )
        
        self.properties = [property1, property2, property3]
        self.settings = PropertyData.Settings(locale: "ru_RU", summaryCurrency: "RUB")
        
        print("✅ Загружено тестовых объектов: \(self.properties.count)")
        for (index, prop) in self.properties.enumerated() {
            print("  \(index + 1). \(prop.name) - \(prop.address)")
        }
        
        saveData()
    }
    
    // MARK: - Сохранение данных
    
    func saveData() {
        let url = getDocumentsURL().appendingPathComponent(dataFileName)
        
        let propertyData = PropertyData(objects: properties, settings: settings)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(propertyData)
            try data.write(to: url)
        } catch {
            print("Ошибка сохранения данных: \(error)")
        }
    }
    
    func saveAssetMap(_ assetMapData: [String: Any]) {
        let url = getDocumentsURL().appendingPathComponent(assetMapFileName)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: assetMapData, options: [.prettyPrinted, .sortedKeys])
            try jsonData.write(to: url)
        } catch {
            print("Ошибка сохранения карты активов: \(error)")
        }
    }
    
    // MARK: - CRUD операции
    
    func addProperty(_ property: Property) {
        // Если у объекта нет ID или ID не в формате "001", "002" и т.д., генерируем новый
        var newProperty = property
        if newProperty.id.isEmpty || Int(newProperty.id) == nil {
            newProperty.id = generateNextID()
        }
        properties.append(newProperty)
        saveData()
    }
    
    func updateProperty(_ property: Property) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties[index] = property
            print("💾 Обновление объекта: \(property.name)")
            saveData()
            print("✅ Данные сохранены в data.json")
        } else {
            print("⚠️ Объект с id \(property.id) не найден")
        }
    }
    
    func deleteProperty(_ property: Property) {
        properties.removeAll { $0.id == property.id }
        saveData()
    }
    
    // MARK: - Вспомогательные методы
    
    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}



