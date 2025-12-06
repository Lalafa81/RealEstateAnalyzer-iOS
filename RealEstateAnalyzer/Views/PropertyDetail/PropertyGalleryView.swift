//
//  PropertyGalleryView.swift
//  RealEstateAnalyzer
//
//  Галерея изображений объекта недвижимости
//

import SwiftUI

struct PropertyGalleryView: View {
    let property: Property
    @State private var selectedImageIndex: Int = 0
    
    // Извлекаем все изображения из property.gallery и property.image (base64)
    var images: [String] {
        var allImages: [String] = []
        
        // Добавляем основное изображение, если оно есть
        if let mainImage = property.image {
            allImages.append(mainImage)
        }
        
        // Добавляем изображения из галереи
        if let galleryImages = property.gallery {
            allImages.append(contentsOf: galleryImages)
        }
        
        return allImages
    }
    
    var body: some View {
        if !images.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Галерея")
                    .font(.headline)
                
                if images.count == 1 {
                    // Одно изображение
                    if let imageData = decodeBase64Image(images[0]) {
                        Image(uiImage: imageData)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }
                } else {
                    // Несколько изображений с прокруткой
                    TabView(selection: $selectedImageIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            if let imageData = decodeBase64Image(images[index]) {
                                Image(uiImage: imageData)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // Декодирует base64 строку в UIImage
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
        // Убираем префикс "data:image/jpeg;base64," если он есть
        let base64 = base64String.contains(",") 
            ? String(base64String.split(separator: ",").last ?? "")
            : base64String
        
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
}

