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
                    Text(property.status.localizedName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text("\(String(format: "%.0f", property.area)) \("unit_square_meters".localized)")
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
                            Text("field_name".localized)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if activeEditingField == "name" {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        TextField("", text: Binding(
                                            get: { property.name },
                                            set: { 
                                                // Ограничиваем до 30 символов
                                                property.name = String($0.prefix(30))
                                            }
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
                                    
                                    Text("\(property.name.count)/30")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: { activeEditingField = "name" }) {
                                    HStack(spacing: 4) {
                                        Text(property.name.isEmpty ? "not_specified".localized : property.name)
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
                            Text("field_address".localized)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if activeEditingField == "address" {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        TextField("", text: Binding(
                                            get: { property.address },
                                            set: { 
                                                // Ограничиваем до 50 символов
                                                property.address = String($0.prefix(50))
                                            }
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
                                    
                                    Text("\(property.address.count)/50")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: { activeEditingField = "address" }) {
                                    HStack(spacing: 4) {
                                        Text(property.address.isEmpty ? "not_specified".localized : property.address)
                                            .font(.subheadline)
                                            .foregroundColor(property.address.isEmpty ? .secondary : .primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(PlainButtonStyle())
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
                        // Левая колонка
                        InlineEditablePropertyType(
                            fieldId: "type",
                            type: $property.type,
                            customType: $property.customType,
                            label: "field_type".localized,
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditablePicker(
                            fieldId: "status",
                            selection: $property.status,
                            label: "field_status".localized,
                            options: PropertyStatus.allCases,
                            displayValue: { $0.localizedName },
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditableNumber(
                            fieldId: "purchasePrice",
                            value: property.purchasePrice,
                            label: "field_purchase_price".localized,
                            formatter: { $0.formatCurrency() },
                            activeField: $activeEditingField,
                            onSave: { newValue in
                                property.purchasePrice = newValue
                                onSave()
                            }
                        )
                        
                        // Optional поля с условным рендерингом
                        optionalField(
                            value: property.propertyTax,
                            fieldId: "propertyTax",
                            label: "field_property_tax".localized,
                            activeField: $activeEditingField,
                            onSave: { property.propertyTax = $0; onSave() }
                        )
                        
                        optionalField(
                            value: property.exitPrice,
                            fieldId: "exitPrice",
                            label: "field_exit_price".localized,
                            activeField: $activeEditingField,
                            onSave: { property.exitPrice = $0; onSave() }
                        )
                        
                        InlineEditableNumber(
                            fieldId: "area",
                            value: property.area,
                            label: "field_area".localized,
                            suffix: " \("unit_square_meters".localized)",
                            activeField: $activeEditingField,
                            onSave: { newValue in
                                property.area = newValue
                                onSave()
                            }
                        )
                        
                        InlineEditablePicker(
                            fieldId: "condition",
                            selection: Binding(
                                get: { property.condition ?? .excellent },
                                set: { property.condition = $0 }
                            ),
                            label: "field_condition".localized,
                            options: PropertyCondition.allCases,
                            displayValue: { $0.localizedName },
                            activeField: $activeEditingField,
                            onSave: { onSave() }
                        )
                        
                        InlineEditableDate(
                            fieldId: "purchaseDate",
                            dateString: property.purchaseDate,
                            label: "field_purchase_date".localized,
                            dateFormatter: dateFormatter,
                            activeField: $activeEditingField,
                            onSave: { newDateString in
                                property.purchaseDate = newDateString
                                onSave()
                            }
                        )
                        
                        optionalField(
                            value: property.insuranceCost,
                            fieldId: "insuranceCost",
                            label: "field_insurance".localized,
                            activeField: $activeEditingField,
                            onSave: { property.insuranceCost = $0; onSave() }
                        )
                        
                        // Поле этажности в правой колонке
                        VStack(alignment: .leading, spacing: 3) {
                            Text("field_floors".localized)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if activeEditingField == "floors" {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        TextField("", text: Binding(
                                            get: { 
                                                if let floors = property.floors {
                                                    return String(floors)
                                                }
                                                return ""
                                            },
                                            set: { 
                                                if let value = Int($0) {
                                                    property.floors = value == 0 ? nil : value
                                                } else if $0.isEmpty {
                                                    property.floors = nil
                                                }
                                            }
                                        ))
                                        .font(.subheadline)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .keyboardType(.numbersAndPunctuation)
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
                                }
                            } else {
                                Button(action: { activeEditingField = "floors" }) {
                                    HStack(spacing: 4) {
                                        Text(formatFloors(property.floors))
                                            .font(.subheadline)
                                            .foregroundColor(property.floors == nil ? .secondary : .primary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    
                    // Поле для заметок внизу хедера на всю ширину
                    VStack(alignment: .leading, spacing: 3) {
                        Text("field_notes".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if activeEditingField == "notes" {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("", text: Binding(
                                    get: { property.notes ?? "" },
                                    set: { 
                                        // Ограничиваем до 200 символов
                                        let limited = String($0.prefix(200))
                                        property.notes = limited.isEmpty ? nil : limited
                                    }
                                ))
                                .font(.caption)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color(.systemBackground))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                
                                HStack {
                                    Text("\((property.notes ?? "").count)/200")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
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
                            }
                        } else {
                            Button(action: { activeEditingField = "notes" }) {
                                HStack(spacing: 4) {
                                    Text(property.notes?.isEmpty == false ? property.notes! : "field_add_notes".localized)
                                        .font(.caption)
                                        .foregroundColor(property.notes?.isEmpty == false ? .primary : .secondary)
                                        .lineLimit(2)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                }
            }
            .padding(.top, 6)
        }
        .padding(8)
    }
    
    // MARK: - Helper функции
    
    private func formatFloors(_ floors: Int?) -> String {
        guard let floors = floors else {
            return "not_specified".localized
        }
        
        if floors == -1 {
            return "floors_basement".localized
        } else if floors == 1 {
            return "floors_one".localized
        } else if floors == 2 {
            return "floors_two".localized
        } else {
            return String(format: "floors_many".localized, floors)
        }
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
