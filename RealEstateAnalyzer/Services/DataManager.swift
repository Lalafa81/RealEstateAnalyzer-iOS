//
//  DataManager.swift
//  RealEstateAnalyzer
//
//  Менеджер данных - замена data_api.py
//

import Foundation
import Combine
import UIKit

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
        let maxID = properties.compactMap { Int($0.id) }.max() ?? 0
        return String(format: "%03d", maxID + 1)
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
                migrateIconsToSFSymbols()
                return
            } else {
                // Если файл поврежден, НЕ удаляем его сразу - возможно, это временная проблема
                // Пытаемся загрузить резервную копию
                let backupURL = documentsURL.appendingPathExtension("backup")
                if FileManager.default.fileExists(atPath: backupURL.path) {
                    if loadData(from: backupURL) {
                        // Восстанавливаем из резервной копии
                        try? FileManager.default.copyItem(at: backupURL, to: documentsURL)
                        loadImages()
                        migrateIconsToSFSymbols()
                        return
                    }
                }
                // Только если резервной копии нет, удаляем поврежденный файл
                print("Предупреждение: файл данных поврежден, но резервной копии нет")
                // НЕ удаляем файл автоматически - пусть пользователь решает
            }
        }
        
        // 2. Если в Documents нет файла → пробуем взять data.json из Bundle
        if let bundleURL = Bundle.main.url(forResource: "data", withExtension: "json") {
            if loadData(from: bundleURL) {
                // Копируем Bundle → Documents и читаем
                copyFile(from: bundleURL, to: documentsURL)
                loadImages()
                migrateIconsToSFSymbols()
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
            
            // Возвращаем true даже если массив пустой - это валидное состояние
            return true
        } catch {
            print("Ошибка загрузки данных из \(url.path): \(error)")
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
        // Изображения хранятся отдельно в images.json и файлах
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
            // Сначала сохраняем во временный файл, потом переименовываем - это атомарная операция
            let tempURL = url.appendingPathExtension("tmp")
            try data.write(to: tempURL)
            // Если успешно записали, заменяем старый файл
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            try FileManager.default.moveItem(at: tempURL, to: url)
        } catch {
            print("КРИТИЧЕСКАЯ ОШИБКА сохранения данных: \(error)")
            // Пытаемся сохранить хотя бы во временный файл для восстановления
            let backupURL = url.appendingPathExtension("backup")
            if let backupData = try? encoder.encode(propertyData) {
                try? backupData.write(to: backupURL)
            }
        }
    }
    
    // MARK: - Работа с изображениями
    
    /// Получает URL директории для хранения изображений
    private func getImagesDirectory() -> URL {
        let documentsURL = getDocumentsURL()
        let imagesDir = documentsURL.appendingPathComponent("images", isDirectory: true)
        
        // Создаем директорию, если её нет
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    /// Генерирует уникальное имя файла для изображения
    private func generateImageFileName(propertyId: String, isCover: Bool = false) -> String {
        let uuid = UUID().uuidString
        let prefix = isCover ? "cover" : "gallery"
        return "property_\(propertyId)_\(prefix)_\(uuid).jpg"
    }
    
    /// Сохраняет UIImage как файл и возвращает имя файла
    func saveImageFile(_ image: UIImage, propertyId: String, isCover: Bool = false) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let fileName = generateImageFileName(propertyId: propertyId, isCover: isCover)
        let fileURL = getImagesDirectory().appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            return nil
        }
    }
    
    /// Загружает UIImage из файла по имени
    func loadImageFile(_ fileName: String) -> UIImage? {
        let fileURL = getImagesDirectory().appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    /// Удаляет файл изображения
    func deleteImageFile(_ fileName: String) {
        let fileURL = getImagesDirectory().appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
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
            
            // Очищаем дубликаты имен файлов в галереях
            cleanDuplicateFilenames()
            
            return true
        } catch {
            return false
        }
    }
    
    /// Удаляет дубликаты имен файлов из галерей и исключает cover image из галереи
    /// ВАЖНО: Не удаляет физические файлы - только чистит JSON от лишних ссылок
    private func cleanDuplicateFilenames() {
        var needsSave = false
        var newImages = propertyImages.images // Работаем с копией словаря
        
        for (propertyId, imageData) in propertyImages.images {
            let coverImageFileName = imageData.coverImage
            
            // Используем Set для удаления дубликатов, сохраняя порядок
            // И исключаем cover image из галереи
            var seen = Set<String>()
            let uniqueGallery = imageData.gallery.filter { fileName in
                // Исключаем cover image из галереи
                if fileName == coverImageFileName {
                    needsSave = true
                    return false
                }
                
                // Убираем дубликаты из JSON, но НЕ удаляем физический файл
                // Дубликат - это просто повторяющаяся ссылка на один и тот же файл
                if seen.contains(fileName) {
                    needsSave = true
                    return false
                } else {
                    seen.insert(fileName)
                    return true
                }
            }
            
            // Если были удалены дубликаты или cover image, обновляем галерею
            if uniqueGallery != imageData.gallery {
                newImages[propertyId] = PropertyImages.PropertyImageData(
                    coverImage: coverImageFileName,
                    gallery: uniqueGallery
                )
                needsSave = true
            }
        }
        
        // Сохраняем изменения, если были удалены дубликаты
        if needsSave {
            propertyImages.images = newImages
            saveImages()
        }
    }
    
    func saveImages() {
        let documentsURL = getDocumentsURL().appendingPathComponent(imagesFileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(propertyImages)
            // Атомарное сохранение через временный файл
            let tempURL = documentsURL.appendingPathExtension("tmp")
            try data.write(to: tempURL)
            if FileManager.default.fileExists(atPath: documentsURL.path) {
                try? FileManager.default.removeItem(at: documentsURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: documentsURL)
        } catch {
            print("Ошибка сохранения изображений: \(error)")
            // Пытаемся сохранить резервную копию
            let backupURL = documentsURL.appendingPathExtension("backup")
            if let backupData = try? encoder.encode(propertyImages) {
                try? backupData.write(to: backupURL)
            }
        }
    }
    
    /// Получает основное фото объекта (cover image)
    func getPropertyCoverImage(propertyId: String) -> UIImage? {
        guard let imageData = propertyImages.images[propertyId],
              let coverFileName = imageData.coverImage else {
            return nil
        }
        return loadImageFile(coverFileName)
    }
    
    /// Устанавливает основное фото объекта (cover image)
    func setPropertyCoverImage(propertyId: String, image: UIImage) -> Bool {
        guard let fileName = saveImageFile(image, propertyId: propertyId, isCover: true) else {
            return false
        }
        
        // Получаем текущие данные или создаем новые
        var imageData = propertyImages.images[propertyId] ?? PropertyImages.PropertyImageData(coverImage: nil, gallery: [])
        
        // Удаляем старое cover image, если есть
        if let oldCoverFileName = imageData.coverImage {
            deleteImageFile(oldCoverFileName)
            // Удаляем старое cover image из галереи, если оно там есть
            imageData.gallery.removeAll { $0 == oldCoverFileName }
        }
        
        // Убеждаемся, что новый cover image не в галерее
        imageData.gallery.removeAll { $0 == fileName }
        
        // Устанавливаем новый cover image
        imageData.coverImage = fileName
        propertyImages.images[propertyId] = imageData
        saveImages()
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("PropertyImagesUpdated"), object: nil, userInfo: ["propertyId": propertyId])
        }
        
        return true
    }
    
    /// Получает имена файлов галереи для объекта (без дубликатов и без cover image)
    func getPropertyGallery(propertyId: String) -> [String] {
        guard let imageData = propertyImages.images[propertyId] else {
            return []
        }
        
        // Исключаем cover image из галереи
        let coverImageFileName = imageData.coverImage
        
        // Убираем дубликаты и исключаем cover image
        var seen = Set<String>()
        return imageData.gallery.filter { fileName in
            // Исключаем cover image из галереи
            if fileName == coverImageFileName {
                return false
            }
            if seen.contains(fileName) {
                return false
            } else {
                seen.insert(fileName)
                return true
            }
        }
    }
    
    /// Получает массив UIImage для галереи объекта
    func getPropertyGalleryImages(propertyId: String) -> [UIImage] {
        let fileNames = getPropertyGallery(propertyId: propertyId)
        return fileNames.compactMap { loadImageFile($0) }
    }
    
    /// Обновляет галерею для объекта
    func updatePropertyGallery(propertyId: String, gallery: [String]) {
        // Сохраняем cover image при обновлении галереи
        let existingCoverImage = propertyImages.images[propertyId]?.coverImage
        
        // Убеждаемся, что cover image не попадает в галерею
        let filteredGallery = gallery.filter { $0 != existingCoverImage }
        
        let imageData = PropertyImages.PropertyImageData(coverImage: existingCoverImage, gallery: filteredGallery)
        propertyImages.images[propertyId] = imageData
        saveImages()
        // Уведомляем об изменении для обновления UI
        DispatchQueue.main.async {
            self.objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("PropertyImagesUpdated"), object: nil, userInfo: ["propertyId": propertyId])
        }
    }
    
    /// Принудительно обновляет UI после изменения изображений
    func refreshImages() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("PropertyImagesUpdated"), object: nil)
        }
    }
    
    /// Добавляет UIImage в галерею объекта
    func addPropertyGalleryImage(propertyId: String, image: UIImage) -> Bool {
        let currentGallery = getPropertyGallery(propertyId: propertyId)
        
        guard let fileName = saveImageFile(image, propertyId: propertyId, isCover: false) else {
            return false
        }
        
        var newGallery = currentGallery
        newGallery.append(fileName)
        updatePropertyGallery(propertyId: propertyId, gallery: newGallery)
        return true
    }
    
    /// Удаляет изображения для объекта (удаляет и файлы, и записи в JSON)
    func deletePropertyImages(propertyId: String) {
        guard let imageData = propertyImages.images[propertyId] else {
            return
        }
        
        // Удаляем cover image
        if let coverFileName = imageData.coverImage {
            deleteImageFile(coverFileName)
        }
        
        // Удаляем файлы галереи
        for fileName in imageData.gallery {
            deleteImageFile(fileName)
        }
        
        // Удаляем записи из JSON
        propertyImages.images.removeValue(forKey: propertyId)
        saveImages()
    }
    
    /// Удаляет одно изображение из галереи по имени файла
    func deletePropertyImage(propertyId: String, fileName: String) {
        var gallery = getPropertyGallery(propertyId: propertyId)
        
        guard let index = gallery.firstIndex(of: fileName) else {
            return
        }
        
        // Удаляем файл
        deleteImageFile(fileName)
        
        // Удаляем из массива
        gallery.remove(at: index)
        
        // Обновляем JSON
        updatePropertyGallery(propertyId: propertyId, gallery: gallery)
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
        var newProperty = property
        if newProperty.id.isEmpty {
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
