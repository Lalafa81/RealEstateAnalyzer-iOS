//
//  PropertyHeaderView.swift
//  RealEstateAnalyzer
//
//  Шапка объекта недвижимости с редактируемыми полями
//

import SwiftUI

struct HeaderView: View {
    @Binding var property: Property
    @Binding var isEditing: Bool
    let onSave: () -> Void
    
    @State private var editingName: String = ""
    @State private var editingId: String = ""
    @State private var editingAddress: String = ""
    @State private var editingArea: String = ""
    @State private var editingPurchasePrice: String = ""
    @State private var editingPurchaseDate: Date = Date()
    @State private var editingPropertyTax: String = ""
    @State private var editingInsuranceCost: String = ""
    @State private var editingExitPrice: String = ""
    
    // DateFormatter для преобразования String <-> Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // Binding для преобразования String (property.purchaseDate) <-> Date (editingPurchaseDate)
    private var purchaseDateBinding: Binding<Date> {
        Binding(
            get: {
                if let date = dateFormatter.date(from: property.purchaseDate) {
                    return date
                }
                return Date() // Возвращаем текущую дату, если не удалось распарсить
            },
            set: { newDate in
                property.purchaseDate = dateFormatter.string(from: newDate)
            }
        )
    }
    
    // Используем enum'ы вместо массивов строк
    
    // Доступные иконки для объектов
    let availableIcons: [(name: String, sfSymbol: String)] = [
        ("Дом", "house.fill"),
        ("Здание", "building.2.fill"),
        ("Склад", "archivebox.fill"),
        ("Офис", "building.2.crop.circle.fill"),
        ("Участок", "square.fill"),
        ("Магазин", "storefront.fill"),
        ("Гараж", "carport.fill")
    ]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Кнопка редактирования вне блока
            HStack {
                Spacer()
                Button(isEditing ? "Сохранить" : "Редактировать") {
                    if isEditing {
                        saveChanges()
                        isEditing = false
                    } else {
                        loadCurrentValues()
                        isEditing = true
                    }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            // Блок с информацией
            VStack(alignment: .leading, spacing: 0) {
                if isEditing {
                // Режим редактирования - используем Form для удобства
                ScrollView {
                    Form {
                        Section(header: Text("Основная информация")) {
                            // Иконка
                            HStack {
                                Text("Иконка")
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { property.icon ?? "house.fill" },
                                    set: { property.icon = $0 }
                                )) {
                                    ForEach(availableIcons, id: \.sfSymbol) { icon in
                                        HStack {
                                            Image(systemName: icon.sfSymbol)
                                            Text(icon.name)
                                        }
                                        .tag(icon.sfSymbol)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // Название
                            HStack {
                                Text("Название")
                                Spacer()
                                TextField("Склад на Апаринках", text: $editingName)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // ID
                            HStack {
                                Text("ID")
                                Spacer()
                                TextField("ID", text: $editingId)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Тип
                            Picker("Тип", selection: $property.type) {
                                ForEach(PropertyType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            // Адрес
                            HStack {
                                Text("Адрес")
                                Spacer()
                                TextField("г. Москва, ...", text: $editingAddress)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Площадь
                            HStack {
                                Text("Площадь")
                                Spacer()
                                TextField("1000", text: $editingArea)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                Text("м²")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Покупка")) {
                            // Цена покупки
                            HStack {
                                Text("Цена покупки")
                                Spacer()
                                TextField("25000000", text: $editingPurchasePrice)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Дата покупки
                            DatePicker(
                                "Дата покупки",
                                selection: purchaseDateBinding,
                                displayedComponents: .date
                            )
                            
                            // Статус
                            Picker("Статус", selection: $property.status) {
                                ForEach(PropertyStatus.allCases) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            // Состояние
                            Picker("Состояние", selection: Binding(
                                get: { property.condition ?? .excellent },
                                set: { property.condition = $0 }
                            )) {
                                ForEach(PropertyCondition.allCases) { condition in
                                    Text(condition.rawValue).tag(condition)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Финансы")) {
                            // Налоги
                            HStack {
                                Text("Налоги (в год)")
                                Spacer()
                                TextField("0", text: $editingPropertyTax)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Страхование
                            HStack {
                                Text("Страхование (в год)")
                                Spacer()
                                TextField("0", text: $editingInsuranceCost)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Ожидаемая цена продажи
                            HStack {
                                Text("Ожидаемая цена продажи")
                                Spacer()
                                TextField("0", text: $editingExitPrice)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .frame(minHeight: 500)
                }
            } else {
                // Режим просмотра - компактное отображение
                VStack(alignment: .leading, spacing: 12) {
                    // Первая строка: Иконка и название
                    HStack(spacing: 12) {
                        Image(systemName: property.icon.getIconName())
                            .foregroundColor(.purple)
                            .font(.title)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property.name)
                                .font(.headline)
                            Text(property.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Основная информация в две колонки
                    LazyVGrid(columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ], alignment: .leading, spacing: 16) {
                        InfoCell(label: "ID", value: property.id)
                        InfoCell(label: "Тип", value: property.type.rawValue)
                        InfoCell(label: "Площадь", value: "\(Int(property.area)) м²")
                        InfoCell(label: "Статус", value: property.status.rawValue)
                        InfoCell(label: "Цена покупки", value: property.purchasePrice.formatCurrency())
                        InfoCell(label: "Дата покупки", value: property.purchaseDate)
                        InfoCell(label: "Состояние", value: property.condition?.rawValue ?? "Не указано")
                        if let tax = property.propertyTax, tax > 0 {
                            InfoCell(label: "Налоги (в год)", value: tax.formatCurrency())
                        }
                        if let insurance = property.insuranceCost, insurance > 0 {
                            InfoCell(label: "Страхование (в год)", value: insurance.formatCurrency())
                        }
                        if let exitPrice = property.exitPrice, exitPrice > 0 {
                            InfoCell(label: "Ожидаемая цена продажи", value: exitPrice.formatCurrency())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            }
            .padding(.top, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .onAppear {
            if !isEditing {
                loadCurrentValues()
            }
        }
    }
    
    // Вспомогательный компонент для отображения информации
    struct InfoCell: View {
        let label: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
    
    private func loadCurrentValues() {
        editingName = property.name
        editingId = property.id
        editingAddress = property.address
        editingArea = String(format: "%.0f", property.area)
        editingPurchasePrice = String(format: "%.0f", property.purchasePrice)
        // Преобразуем строку даты в Date
        if let date = dateFormatter.date(from: property.purchaseDate) {
            editingPurchaseDate = date
        } else {
            editingPurchaseDate = Date() // Если не удалось распарсить, используем текущую дату
        }
        editingPropertyTax = String(format: "%.0f", property.propertyTax ?? 0)
        editingInsuranceCost = String(format: "%.0f", property.insuranceCost ?? 0)
        editingExitPrice = String(format: "%.0f", property.exitPrice ?? 0)
    }
    
    private func saveChanges() {
        // Обновляем все поля
        property.name = editingName
        property.id = editingId
        property.address = editingAddress
        property.area = Double(editingArea) ?? property.area
        property.purchasePrice = Double(editingPurchasePrice) ?? property.purchasePrice
        // Дата уже обновляется через purchaseDateBinding, но на всякий случай обновим явно
        property.purchaseDate = dateFormatter.string(from: editingPurchaseDate)
        property.propertyTax = Double(editingPropertyTax).flatMap { $0 > 0 ? $0 : nil }
        property.insuranceCost = Double(editingInsuranceCost).flatMap { $0 > 0 ? $0 : nil }
        property.exitPrice = Double(editingExitPrice).flatMap { $0 > 0 ? $0 : nil }
        
        onSave()
    }
}

