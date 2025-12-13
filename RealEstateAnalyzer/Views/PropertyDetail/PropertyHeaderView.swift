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
    
    @State private var activeEditingField: String? = nil
    
    var collapsedView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(property.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(property.status.localizedName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text("\(property.area.formatArea()) \(Double.getAreaUnitName())")
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
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 12) {
                        inlineTextField(
                            fieldId: "name",
                            text: Binding(
                                get: { property.name },
                                set: { property.name = String($0.prefix(30)) }
                            ),
                            label: "field_name".localized,
                            maxLength: 30
                        )
                        .frame(maxWidth: .infinity)
                        
                        inlineTextField(
                            fieldId: "address",
                            text: Binding(
                                get: { property.address },
                                set: { property.address = String($0.prefix(50)) }
                            ),
                            label: "field_address".localized,
                            maxLength: 50
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ], alignment: .leading, spacing: 8) {
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
                            suffix: " \(Double.getAreaUnitName())",
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
                        
                        floorsField()
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    
                    InlineEditablePicker(
                        fieldId: "currency",
                        selection: Binding(
                            get: { Currency(rawValue: property.currency ?? "RUB") ?? .rub },
                            set: { property.currency = $0.rawValue }
                        ),
                        label: "field_currency".localized,
                        options: Currency.allCases,
                        displayValue: { $0.displayName },
                        activeField: $activeEditingField,
                        onSave: { onSave() }
                    )
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    
                    inlineTextField(
                        fieldId: "notes",
                        text: Binding(
                            get: { property.notes ?? "" },
                            set: {
                                let limited = String($0.prefix(200))
                                property.notes = limited.isEmpty ? nil : limited
                            }
                        ),
                        label: "field_notes".localized,
                        maxLength: 200,
                        placeholder: "field_add_notes".localized,
                        font: .caption,
                        lineLimit: 2
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                }
            }
            .padding(.top, 6)
        }
        .padding(8)
    }
    
    @ViewBuilder
    private func inlineTextField(
        fieldId: String,
        text: Binding<String>,
        label: String,
        maxLength: Int,
        placeholder: String? = nil,
        font: Font = .subheadline,
        lineLimit: Int? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if activeEditingField == fieldId {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("", text: Binding(
                            get: { text.wrappedValue },
                            set: { text.wrappedValue = String($0.prefix(maxLength)) }
                        ))
                        .font(font)
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
                    
                    Text("\(text.wrappedValue.count)/\(maxLength)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Button(action: { activeEditingField = fieldId }) {
                    HStack(spacing: 4) {
                        let displayText = text.wrappedValue.isEmpty ? (placeholder ?? "not_specified".localized) : text.wrappedValue
                        Group {
                            if let limit = lineLimit {
                                Text(displayText)
                                    .font(font)
                                    .foregroundColor(text.wrappedValue.isEmpty ? .secondary : .primary)
                                    .lineLimit(limit)
                            } else {
                                Text(displayText)
                                    .font(font)
                                    .foregroundColor(text.wrappedValue.isEmpty ? .secondary : .primary)
                            }
                        }
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    @ViewBuilder
    private func floorsField() -> some View {
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
                                if let intValue = Int($0) {
                                    property.floors = intValue
                                } else if $0.isEmpty {
                                    property.floors = nil
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
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
