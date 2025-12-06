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
    let onSave: () -> Void
    @State private var selectedImageIndex: Int = 0
    @State private var showingImagePicker = false
    @State private var showingFullScreen = false
    @State private var fullScreenImageIndex = 0
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
                        ForEach(0..<images.count, id: \.self) { index in
                            GalleryImageView(
                                base64String: images[index],
                                index: index,
                                onTap: {
                                    fullScreenImageIndex = index
                                    showingFullScreen = true
                                },
                                onDelete: {
                                    deleteImage(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
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
                onDelete: { index in
                    deleteImage(at: index)
                    if fullScreenImageIndex >= images.count {
                        fullScreenImageIndex = max(0, images.count - 1)
                    }
                }
            )
        }
    }
    
    // Добавляет новое изображение
    private func addImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let base64String = imageData.base64EncodedString()
        let base64WithPrefix = "data:image/jpeg;base64,\(base64String)"
        
        // Если основного изображения нет, используем его
        if property.image == nil {
            property.image = base64WithPrefix
        } else {
            // Иначе добавляем в галерею
            if property.gallery == nil {
                property.gallery = []
            }
            property.gallery?.append(base64WithPrefix)
        }
        
        onSave()
    }
    
    // Удаляет изображение по индексу
    private func deleteImage(at index: Int) {
        if index == 0 && property.image != nil {
            // Удаляем основное изображение
            property.image = nil
            // Если есть галерея, первое изображение становится основным
            if let gallery = property.gallery, !gallery.isEmpty {
                property.image = gallery[0]
                property.gallery = Array(gallery.dropFirst())
            }
        } else {
            // Удаляем из галереи
            let galleryIndex = property.image != nil ? index - 1 : index
            if var gallery = property.gallery, galleryIndex >= 0 && galleryIndex < gallery.count {
                gallery.remove(at: galleryIndex)
                property.gallery = gallery.isEmpty ? nil : gallery
            }
        }
        
        onSave()
    }
    
    // Декодирует base64 строку в UIImage
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
        let base64 = base64String.contains(",") 
            ? String(base64String.split(separator: ",").last ?? "")
            : base64String
        
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
}

// Компонент для отображения одного изображения в галерее
struct GalleryImageView: View {
    let base64String: String
    let index: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Изображение
            if let imageData = decodeBase64Image(base64String) {
                Image(uiImage: imageData)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(12)
                    .onTapGesture {
                        onTap()
                    }
            }
            
            // Кнопка удаления
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(8)
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
    
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
        let base64 = base64String.contains(",") 
            ? String(base64String.split(separator: ",").last ?? "")
            : base64String
        
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
}

// Полноэкранный просмотр изображений
struct FullScreenImageView: View {
    let images: [String]
    @Binding var currentIndex: Int
    let onDelete: (Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    if let imageData = decodeBase64Image(images[index]) {
                        Image(uiImage: imageData)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                    }
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
                HStack {
                    Spacer()
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Удалить изображение?"),
                primaryButton: .destructive(Text("Удалить")) {
                    onDelete(currentIndex)
                    if currentIndex >= images.count {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
    
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
        let base64 = base64String.contains(",") 
            ? String(base64String.split(separator: ",").last ?? "")
            : base64String
        
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: imageData)
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
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

