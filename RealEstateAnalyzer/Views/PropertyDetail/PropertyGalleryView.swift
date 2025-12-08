//
//  PropertyGalleryView.swift
//  RealEstateAnalyzer
//
//  Галерея изображений объекта недвижимости
//

import SwiftUI
import UIKit

struct PropertyGalleryView: View {
    @Binding var property: Property
    @EnvironmentObject var dataManager: DataManager
    let onSave: () -> Void
    @State private var selectedImageIndex: Int = 0
    @State private var showingImagePicker = false
    @State private var showingFullScreen = false
    @State private var fullScreenImageIndex = 0
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var refreshID = UUID() // Для принудительного обновления view
    
    // Структура для хранения изображения с его индексом и именем файла
    struct ImageWithInfo: Identifiable {
        let id: String      // Уникальный ID для SwiftUI (fileName_index)
        let fileName: String // Реальное имя файла для DataManager
        let image: UIImage
        let index: Int
    }
    
    // Извлекаем все изображения с информацией о файлах
    var imagesWithInfo: [ImageWithInfo] {
        let galleryFileNames = dataManager.getPropertyGallery(propertyId: property.id)
        
        return galleryFileNames.enumerated().compactMap { index, fileName in
            guard let image = dataManager.loadImageFile(fileName) else {
                return nil
            }
            // id делаем уникальным даже при дублях имён
            let uniqueId = "\(fileName)_\(index)"
            return ImageWithInfo(id: uniqueId, fileName: fileName, image: image, index: index)
        }
    }
    
    // Извлекаем все изображения как UIImage из файлов через DataManager (для совместимости)
    var images: [UIImage] {
        imagesWithInfo.map { $0.image }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Галерея")
                    .font(.headline)
                Spacer()
                
                // Кнопка добавления изображения
                Menu {
                    Button(action: {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    }) {
                        Label("Выбрать из галереи", systemImage: "photo.on.rectangle")
                    }
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button(action: {
                            sourceType = .camera
                            showingImagePicker = true
                        }) {
                            Label("Сделать фото", systemImage: "camera")
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            
            if images.isEmpty {
                // Пустая галерея
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Нет изображений")
                        .foregroundColor(.secondary)
                    Text("Нажмите + чтобы добавить")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color(.systemGray5))
                .cornerRadius(12)
            } else {
                // Сетка изображений
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(imagesWithInfo, id: \.id) { item in
                            GalleryImageView(
                                image: item.image,
                                index: item.index,
                                onTap: {
                                    fullScreenImageIndex = item.index
                                    showingFullScreen = true
                                },
                                onDelete: {
                                    deleteImage(fileName: item.fileName)
                                }
                            )
                            .id(item.id)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .id(refreshID) // Принудительное обновление при изменении refreshID
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                addImage(image)
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            FullScreenImageView(
                images: images,
                currentIndex: $fullScreenImageIndex,
                onDelete: { _ in } // Пустой обработчик, так как удаление убрано
            )
            .id(refreshID) // Принудительное обновление fullScreen view
        }
    }
    
    // Добавляет новое изображение
    private func addImage(_ image: UIImage) {
        // Закрываем picker сразу, чтобы избежать повторных вызовов
        showingImagePicker = false
        
        // Все изображения добавляются в галерею
        _ = dataManager.addPropertyGalleryImage(propertyId: property.id, image: image)
        
        // Обновляем view
        refreshID = UUID()
        onSave()
    }
    
    // Удаляет изображение по имени файла
    private func deleteImage(fileName: String) {
        // Удаляем из DataManager
        dataManager.deletePropertyImage(propertyId: property.id, fileName: fileName)
        
        // Принудительно обновляем view
        refreshID = UUID()
        
        // Обновляем fullScreenImageIndex если нужно
        if fullScreenImageIndex >= imagesWithInfo.count {
            fullScreenImageIndex = max(0, imagesWithInfo.count - 1)
        }
        
        // Сохраняем изменения
        onSave()
    }
}

// Компонент для отображения одного изображения в галерее
struct GalleryImageView: View {
    let image: UIImage
    let index: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Изображение
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(12)
            
            // Кнопка удаления
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(6)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Удалить изображение?"),
                primaryButton: .destructive(Text("Удалить")) {
                    onDelete()
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
}

// Полноэкранный просмотр изображений
struct FullScreenImageView: View {
    let images: [UIImage]
    @Binding var currentIndex: Int
    let onDelete: (Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

// UIImagePickerController wrapper для SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        private var hasCalledCallback = false
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Предотвращаем повторные вызовы
            guard !hasCalledCallback else {
                picker.dismiss(animated: true)
                return
            }
            
            if let image = info[.originalImage] as? UIImage {
                hasCalledCallback = true
                picker.dismiss(animated: true) {
                    self.onImagePicked(image)
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

