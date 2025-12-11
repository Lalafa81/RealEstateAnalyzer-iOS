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
                // Показываем миниатюру с кнопкой удаления, если есть фото
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Кнопка удаления (X) в правом верхнем углу
                    Button(action: {
                        _ = dataManager.deletePropertyCoverImage(propertyId: propertyId)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
                    .offset(x: 4, y: -4)
                    .zIndex(1)
                }
            } else {
                // Показываем плейсхолдер, если фото нет
                ZStack {
                    // Белый фон
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 54, height: 54)
                    
                    // Пунктирная обводка
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            Color.blue.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1, dash: [4])
                        )
                        .frame(width: 54, height: 54)
                    
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

