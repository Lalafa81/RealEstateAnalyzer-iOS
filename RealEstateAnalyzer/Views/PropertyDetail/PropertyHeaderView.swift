//
//  PropertyHeaderView.swift
//  RealEstateAnalyzer
//
//  Шапка объекта недвижимости с inline редактированием полей прямо в карточке
//

import SwiftUI

// MARK: - Константы

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()

// MARK: - Header View

struct HeaderView: View {
    @Binding var property: Property
    let onSave: () -> Void
    
    // Состояние для отслеживания активного поля редактирования
    @State private var activeEditingField: String? = nil
    
    // Свёрнутое представление хедера
    var collapsedView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Название
                Text(property.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Адрес
                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Статус и площадь
                HStack(spacing: 8) {
                    Text(property.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text("\(String(format: "%.0f", property.area)) м²")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Блок с информацией
            VStack(alignment: .leading, spacing: 0) {
                // Режим просмотра с inline редактированием
                VStack(alignment: .leading, spacing: 6) {
                    // Первая строка: Название и адрес параллельно
                    HStack(alignment: .top, spacing: 12) {
                        // Название
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Название")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if activeEditingField == "name" {
                                HStack {
                                    TextField("", text: Binding(
                                        get: { property.name },
                                        set: { property.name = $0 }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    
                                    Button(action: { activeEditingField = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        onSave()
                                        activeEditingField = nil
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                }
                            } else {
                                Button(action: { activeEditingField = "name" }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.blue.opacity(0.6))
                                        Text(property.name.isEmpty ? "Не указано" : property.name)
                                            .font(.subheadline)
                                            .foregroundColor(property.name.isEmpty ? .secondary : .primary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Адрес
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Адрес")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if activeEditingField == "address" {
                                HStack {
                                    TextField("", text: Binding(
                                        get: { property.address },
                                        set: { property.address = $0 }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    
                                    Button(action: { activeEditingField = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        onSave()
                                        activeEditingField = nil
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                }
                            } else {
                                Button(action: { activeEditingField = "address" }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.blue.opacity(0.6))
                                        Text(property.address.isEmpty ? "Не указано" : property.address)
                                            .font(.subheadline)
                                            .foregroundColor(property.address.isEmpty ? .secondary : .primary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Основная информация в две колонки
                    LazyVGrid(columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ], alignment: .leading, spacing: 8) {
                        InlineEditablePropertyType(
                            fieldId: "type",
                            type: $property.type,
                            customType: $property.customType,
                            label: "Назначение",
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditableNumber(
                            fieldId: "area",
                            value: property.area,
                            label: "Площадь",
                            suffix: " м²",
                            activeField: $activeEditingField,
                            onSave: { newValue in
                                property.area = newValue
                                onSave()
                            }
                        )
                        
                        InlineEditablePicker(
                            fieldId: "status",
                            selection: $property.status,
                            label: "Статус",
                            options: PropertyStatus.allCases,
                            displayValue: { $0.rawValue },
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditablePicker(
                            fieldId: "condition",
                            selection: Binding(
                                get: { property.condition ?? .excellent },
                                set: { property.condition = $0 }
                            ),
                            label: "Состояние",
                            options: PropertyCondition.allCases,
                            displayValue: { $0.rawValue },
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditableNumber(
                            fieldId: "purchasePrice",
                            value: property.purchasePrice,
                            label: "Цена покупки",
                            formatter: { $0.formatCurrency() },
                            activeField: $activeEditingField,
                            onSave: { newValue in
                                property.purchasePrice = newValue
                                onSave()
                            }
                        )
                        
                        InlineEditableDate(
                            fieldId: "purchaseDate",
                            dateString: property.purchaseDate,
                            label: "Дата покупки",
                            dateFormatter: dateFormatter,
                            activeField: $activeEditingField,
                            onSave: { newDateString in
                                property.purchaseDate = newDateString
                                onSave()
                            }
                        )
                        
                        // Optional поля с условным рендерингом
                        optionalField(
                            value: property.propertyTax,
                            fieldId: "propertyTax",
                            label: "Налоги (в год)",
                            activeField: $activeEditingField,
                            onSave: { property.propertyTax = $0; onSave() }
                        )
                        
                        optionalField(
                            value: property.insuranceCost,
                            fieldId: "insuranceCost",
                            label: "Страхование (в год)",
                            activeField: $activeEditingField,
                            onSave: { property.insuranceCost = $0; onSave() }
                        )
                        
                        optionalField(
                            value: property.exitPrice,
                            fieldId: "exitPrice",
                            label: "Ожидаемая цена продажи",
                            activeField: $activeEditingField,
                            onSave: { property.exitPrice = $0; onSave() }
                        )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                }
            }
            .padding(.top, 6)
        }
        .padding(8)
    }
    
    // MARK: - Helper функции
    
    @ViewBuilder
    private func optionalField(
        value: Double?,
        fieldId: String,
        label: String,
        activeField: Binding<String?>,
        onSave: @escaping (Double?) -> Void
    ) -> some View {
        if let value = value, value > 0 {
            InlineEditableNumber(
                fieldId: fieldId,
                value: value,
                label: label,
                formatter: { $0.formatCurrency() },
                activeField: activeField,
                onSave: { onSave($0 > 0 ? $0 : nil) }
            )
        } else {
            InlineEditableNumberOptional(
                fieldId: fieldId,
                label: label,
                formatter: { $0.formatCurrency() },
                activeField: activeField,
                onSave: onSave
            )
        }
    }
}
