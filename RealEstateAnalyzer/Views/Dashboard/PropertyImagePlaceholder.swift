//
//  PropertyImagePlaceholder.swift
//  RealEstateAnalyzer
//
//  Компонент для отображения миниатюры изображения объекта или плейсхолдера
//

import SwiftUI
import UIKit

struct PropertyImagePlaceholder: View {
    let propertyId: String
    let onTap: () -> Void
    @EnvironmentObject var dataManager: DataManager
    @State private var coverImage: UIImage? = nil
    
    // Обновляем изображение при изменении dataManager или propertyId
    private func updateCoverImage() {
        // Используем отдельное cover image, а не первое фото из галереи
        coverImage = dataManager.getPropertyCoverImage(propertyId: propertyId)
    }
    
    var body: some View {
        Group {
            if let image = coverImage {
                // Показываем миниатюру, если есть фото
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Показываем плейсхолдер, если фото нет
                ZStack {
                    // Белый фон
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                    
                    // Пунктирная обводка
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            Color.blue.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1, dash: [4])
                        )
                        .frame(width: 48, height: 48)
                    
                    // Иконка plus по центру
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.blue.opacity(0.7))
                }
            }
        }
        .onTapGesture {
            onTap()
        }
        .onAppear {
            updateCoverImage()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PropertyImagesUpdated"))) { _ in
            updateCoverImage()
        }
    }
}

