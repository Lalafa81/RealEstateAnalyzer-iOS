//
//  PropertyHeaderView.swift
//  RealEstateAnalyzer
//
//  Шапка объекта недвижимости с редактируемыми полями
//

import SwiftUI

struct HeaderView: View {
    @Binding var property: Property
    let onSave: () -> Void
    
    @State private var editingName: String = ""
    @State private var editingId: String = ""
    @State private var editingAddress: String = ""
    @State private var editingArea: String = ""
    @State private var editingPurchasePrice: String = ""
    @State private var editingPurchaseDate: String = ""
    @State private var editingPropertyTax: String = ""
    @State private var editingInsuranceCost: String = ""
    @State private var editingExitPrice: String = ""
    @State private var isEditing = false
    
    let propertyTypes = ["Жилая", "Коммерческая", "Промышленная", "Земельный участок"]
    let statusOptions = ["Сдано", "Свободно", "На ремонте", "Продано"]
    let conditionOptions = ["Отличное", "Хорошее", "Удовлетворительное", "Требует ремонта"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack {
                Text("НЕДВИЖИМОСТЬ")
                    .font(.headline)
                Spacer()
                Button(isEditing ? "Сохранить" : "Редактировать") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
                .font(.subheadline)
            }
            
            Divider()
            
            // Первая строка: Название, ID, Тип
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Название:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("Название", text: $editingName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(property.name)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ID:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("ID", text: $editingId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(property.id)
                            .font(.subheadline)
                    }
                }
                .frame(width: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Тип:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        Picker("Тип", selection: Binding(
                            get: { property.type },
                            set: { property.type = $0 }
                        )) {
                            ForEach(propertyTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Text(property.type)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Вторая строка: Адрес, Площадь
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Адрес:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("Адрес", text: $editingAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(property.address)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Площадь:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        HStack {
                            TextField("0", text: $editingArea)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("м²")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("\(Int(property.area)) м²")
                            .font(.subheadline)
                    }
                }
                .frame(width: 120)
            }
            
            // Третья строка: Цена покупки, Дата покупки, Статус
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Цена покупки:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    if isEditing {
                        TextField("0", text: $editingPurchasePrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(formatCurrency(property.purchasePrice))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Дата покупки:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("дд.мм.гггг", text: $editingPurchaseDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(property.purchaseDate)
                            .font(.subheadline)
                    }
                }
                .frame(width: 140)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Статус:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        Picker("Статус", selection: Binding(
                            get: { property.status },
                            set: { property.status = $0 }
                        )) {
                            ForEach(statusOptions, id: \.self) { status in
                                Text(status).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Text(property.status)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Четвертая строка: Состояние, Налоги
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Состояние:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        Picker("Состояние", selection: Binding(
                            get: { property.condition ?? "Отличное" },
                            set: { property.condition = $0 }
                        )) {
                            ForEach(conditionOptions, id: \.self) { condition in
                                Text(condition).tag(condition)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Text(property.condition ?? "Не указано")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Налоги (в год):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("0", text: $editingPropertyTax)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(formatCurrency(property.propertyTax ?? 0))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Пятая строка: Страхование, Ожидаемая цена продажи
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Страхование (в год):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("0", text: $editingInsuranceCost)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(formatCurrency(property.insuranceCost ?? 0))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ожидаемая цена продажи:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("0", text: $editingExitPrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(formatCurrency(property.exitPrice ?? 0))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            if !isEditing {
                loadCurrentValues()
            }
        }
    }
    
    private func startEditing() {
        loadCurrentValues()
        isEditing = true
    }
    
    private func loadCurrentValues() {
        editingName = property.name
        editingId = property.id
        editingAddress = property.address
        editingArea = String(format: "%.0f", property.area)
        editingPurchasePrice = String(format: "%.0f", property.purchasePrice)
        editingPurchaseDate = property.purchaseDate
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
        property.purchaseDate = editingPurchaseDate
        property.propertyTax = Double(editingPropertyTax).flatMap { $0 > 0 ? $0 : nil }
        property.insuranceCost = Double(editingInsuranceCost).flatMap { $0 > 0 ? $0 : nil }
        property.exitPrice = Double(editingExitPrice).flatMap { $0 > 0 ? $0 : nil }
        
        isEditing = false
        onSave()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

