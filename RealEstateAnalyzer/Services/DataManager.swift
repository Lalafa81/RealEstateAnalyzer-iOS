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
    private let imagesFileName = "images.json"
    
    // Кэш изображений
    private var propertyImages: PropertyImages = PropertyImages()
    
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
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            try? FileManager.default.removeItem(at: documentsURL)
        }
        
        // Загружаем из Bundle
        loadData()
    }
    
    func loadData() {
        let documentsURL = getDocumentsURL().appendingPathComponent(dataFileName)
        
        // 1. Если есть файл в Documents → читаем его и используем (это всегда пользовательские данные)
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            if loadData(from: documentsURL) {
                loadImages()
                return
            } else {
                // Если файл поврежден, удаляем его
                try? FileManager.default.removeItem(at: documentsURL)
            }
        }
        
        // 2. Если в Documents нет файла → пробуем взять data.json из Bundle
        if let bundleURL = Bundle.main.url(forResource: "data", withExtension: "json") {
            if loadData(from: bundleURL) {
                // Копируем Bundle → Documents и читаем
                copyFile(from: bundleURL, to: documentsURL)
                loadImages()
                return
            }
        }
        
        // 3. Если и в Bundle нет → создаём тестовые данные и сразу сохраняем в Documents
        loadSampleData()
        loadImages()
    }
    
    private func loadData(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let propertyData = try decoder.decode(PropertyData.self, from: data)
            self.properties = propertyData.objects
            self.settings = propertyData.settings
            
            migrateIDsToSimpleFormat()
            migrateIconsToSFSymbols()
            
            return !self.properties.isEmpty
        } catch {
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
            for i in 0..<properties.count {
                if Int(properties[i].id) == nil {
                    properties[i].id = String(format: "%03d", i + 1)
                }
            }
            saveData()
        }
    }
    
    private func copyFile(from source: URL, to destination: URL) {
        try? FileManager.default.copyItem(at: source, to: destination)
    }
    
    // MARK: - Тестовые данные (fallback, если нет Bundle/data.json)
    
    /// Создает пустые данные (fallback, если нет файла ни в Documents, ни в Bundle)
    func loadSampleData() {
        self.properties = []
        self.settings = PropertyData.Settings(locale: "ru", summaryCurrency: "RUB")
        saveData()
    }
    
    // MARK: - Сохранение данных
    
    func saveData() {
        let url = getDocumentsURL().appendingPathComponent(dataFileName)
        
        // Создаем копию properties без изображений для сохранения в data.json
        var propertiesWithoutImages = properties
        for i in 0..<propertiesWithoutImages.count {
            propertiesWithoutImages[i].image = nil
            propertiesWithoutImages[i].gallery = nil
        }
        
        let propertyData = PropertyData(objects: propertiesWithoutImages, settings: settings)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(propertyData)
            try data.write(to: url)
        } catch {
            // Ошибка сохранения данных
        }
    }
    
    // MARK: - Работа с изображениями
    
    private func loadImages() {
        let documentsURL = getDocumentsURL().appendingPathComponent(imagesFileName)
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            if loadImages(from: documentsURL) {
                return
            }
        }
        
        if let bundleURL = Bundle.main.url(forResource: "images", withExtension: "json") {
            if loadImages(from: bundleURL) {
                return
            }
        }
        
        propertyImages = PropertyImages()
    }
    
    private func loadImages(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            propertyImages = try decoder.decode(PropertyImages.self, from: data)
            return true
        } catch {
            return false
        }
    }
    
    func saveImages() {
        let documentsURL = getDocumentsURL().appendingPathComponent(imagesFileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(propertyImages)
            try data.write(to: documentsURL)
            
            if let bundleURL = Bundle.main.url(forResource: "data", withExtension: "json") {
                let projectDir = bundleURL.deletingLastPathComponent()
                let projectURL = projectDir.appendingPathComponent(imagesFileName)
                try? data.write(to: projectURL)
            }
        } catch {
            // Ошибка сохранения изображений
        }
    }
    
    /// Получает изображения для объекта
    func getPropertyImages(propertyId: String) -> (image: String?, gallery: [String]?) {
        guard let imageData = propertyImages.images[propertyId] else {
            return (nil, nil)
        }
        return (imageData.image, imageData.gallery)
    }
    
    /// Обновляет изображения для объекта
    func updatePropertyImages(propertyId: String, image: String?, gallery: [String]?) {
        var imageData = PropertyImages.PropertyImageData()
        imageData.image = image
        imageData.gallery = gallery
        propertyImages.images[propertyId] = imageData
        saveImages()
    }
    
    /// Удаляет изображения для объекта
    func deletePropertyImages(propertyId: String) {
        propertyImages.images.removeValue(forKey: propertyId)
        saveImages()
    }
    
    func saveAssetMap(_ assetMapData: [String: Any]) {
        let url = getDocumentsURL().appendingPathComponent(assetMapFileName)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: assetMapData, options: [.prettyPrinted, .sortedKeys])
            try jsonData.write(to: url)
        } catch {
            // Ошибка сохранения карты активов
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
            saveData()
        }
    }
    
    func deleteProperty(_ property: Property) {
        properties.removeAll { $0.id == property.id }
        deletePropertyImages(propertyId: property.id)
        saveData()
    }
    
    // MARK: - Вспомогательные методы
    
    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
