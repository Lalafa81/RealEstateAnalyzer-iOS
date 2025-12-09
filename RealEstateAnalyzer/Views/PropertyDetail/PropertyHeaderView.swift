//
//  PropertyHeaderView.swift
//  RealEstateAnalyzer
//
//  Шапка объекта недвижимости с inline редактированием полей прямо в карточке
//

import SwiftUI

struct HeaderView: View {
    @Binding var property: Property
    let onSave: () -> Void
    
    // Состояние для отслеживания активного поля редактирования
    @State private var activeEditingField: String? = nil
    
    // DateFormatter для преобразования String <-> Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Блок с информацией
            VStack(alignment: .leading, spacing: 0) {
                // Режим просмотра с inline редактированием
                VStack(alignment: .leading, spacing: 6) {
                    // Первая строка: Иконка и название
                    HStack(spacing: 12) {
                        Image(systemName: property.type.iconName)
                            .foregroundColor(.purple)
                            .font(.title)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if activeEditingField == "name" {
                                    HStack {
                                        TextField("", text: Binding(
                                            get: { property.name },
                                            set: { property.name = $0 }
                                        ))
                                        .font(.headline)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        
                                        Button(action: {
                                            activeEditingField = nil
                                        }) {
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
                                    HStack {
                                        Text(property.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Button(action: {
                                            activeEditingField = "name"
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                if activeEditingField == "address" {
                                    HStack {
                                        TextField("", text: Binding(
                                            get: { property.address },
                                            set: { property.address = $0 }
                                        ))
                                        .font(.subheadline)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        
                                        Button(action: {
                                            activeEditingField = nil
                                        }) {
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
                                    HStack {
                                        Text(property.address)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Button(action: {
                                            activeEditingField = "address"
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Основная информация в две колонки
                    LazyVGrid(columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ], alignment: .leading, spacing: 8) {
                        InlineEditableText(
                            fieldId: "id",
                            text: property.id,
                            label: "ID",
                            activeField: $activeEditingField,
                            onSave: { newValue in
                                property.id = newValue
                                onSave()
                            }
                        )
                        
                        InlineEditablePicker(
                            fieldId: "type",
                            selection: $property.type,
                            label: "Назначение",
                            options: PropertyType.allCases,
                            displayValue: { $0.rawValue },
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
                        
                        if let tax = property.propertyTax, tax > 0 {
                            InlineEditableNumber(
                                fieldId: "propertyTax",
                                value: tax,
                                label: "Налоги (в год)",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.propertyTax = newValue > 0 ? newValue : nil
                                    onSave()
                                }
                            )
                        } else {
                            InlineEditableNumberOptional(
                                fieldId: "propertyTax",
                                label: "Налоги (в год)",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.propertyTax = newValue
                                    onSave()
                                }
                            )
                        }
                        
                        if let insurance = property.insuranceCost, insurance > 0 {
                            InlineEditableNumber(
                                fieldId: "insuranceCost",
                                value: insurance,
                                label: "Страхование (в год)",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.insuranceCost = newValue > 0 ? newValue : nil
                                    onSave()
                                }
                            )
                        } else {
                            InlineEditableNumberOptional(
                                fieldId: "insuranceCost",
                                label: "Страхование (в год)",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.insuranceCost = newValue
                                    onSave()
                                }
                            )
                        }
                        
                        if let exitPrice = property.exitPrice, exitPrice > 0 {
                            InlineEditableNumber(
                                fieldId: "exitPrice",
                                value: exitPrice,
                                label: "Ожидаемая цена продажи",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.exitPrice = newValue > 0 ? newValue : nil
                                    onSave()
                                }
                            )
                        } else {
                            InlineEditableNumberOptional(
                                fieldId: "exitPrice",
                                label: "Ожидаемая цена продажи",
                                formatter: { $0.formatCurrency() },
                                activeField: $activeEditingField,
                                onSave: { newValue in
                                    property.exitPrice = newValue
                                    onSave()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                }
            }
            .padding(.top, 6)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// MARK: - Inline Editable Components

struct InlineEditableText: View {
    let fieldId: String
    let text: String
    let label: String
    @Binding var activeField: String?
    let onSave: (String) -> Void
    
    @State private var editingText: String = ""
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                HStack {
                    TextField("", text: $editingText)
                        .font(.subheadline)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Button(action: {
                        editingText = text
                        activeField = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Отмена" (красный крестик)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        onSave(editingText)
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Принять" (зеленая галочка)
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: {
                    editingText = text
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(text.isEmpty ? "Не указано" : text)
                            .font(.subheadline)
                            .foregroundColor(text.isEmpty ? .secondary : (fieldId == "id" ? .blue : .primary))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct InlineEditableNumber: View {
    let fieldId: String
    let value: Double
    let label: String
    var suffix: String = ""
    var formatter: ((Double) -> String)? = nil
    @Binding var activeField: String?
    let onSave: (Double) -> Void
    
    @State private var editingText: String = ""
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var displayValue: String {
        if let formatter = formatter {
            return formatter(value)
        }
        return String(format: "%.0f", value) + suffix
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                HStack {
                    TextField("", text: $editingText)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !suffix.isEmpty {
                        Text(suffix)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        editingText = String(format: "%.0f", value)
                        activeField = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Отмена" (красный крестик)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if let newValue = Double(editingText) {
                            onSave(newValue)
                        }
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Принять" (зеленая галочка)
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: {
                    editingText = String(format: "%.0f", value)
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(displayValue)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct InlineEditableNumberOptional: View {
    let fieldId: String
    let label: String
    var formatter: ((Double) -> String)? = nil
    @Binding var activeField: String?
    let onSave: (Double?) -> Void
    
    @State private var editingText: String = ""
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                HStack {
                    TextField("", text: $editingText)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Button(action: {
                        editingText = ""
                        activeField = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Отмена" (красный крестик)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if editingText.isEmpty {
                            onSave(nil)
                        } else if let newValue = Double(editingText) {
                            onSave(newValue)
                        }
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Принять" (зеленая галочка)
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: {
                    editingText = ""
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("Не указано")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct InlineEditableDate: View {
    let fieldId: String
    let dateString: String
    let label: String
    let dateFormatter: DateFormatter
    @Binding var activeField: String?
    let onSave: (String) -> Void
    
    @State private var editingDate: Date = Date()
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                HStack {
                    DatePicker("", selection: $editingDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Button(action: {
                        if let date = dateFormatter.date(from: dateString) {
                            editingDate = date
                        }
                        activeField = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Отмена" (красный крестик)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        let newDateString = dateFormatter.string(from: editingDate)
                        onSave(newDateString)
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline) // РАЗМЕР кнопки "Принять" (зеленая галочка)
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: {
                    if let date = dateFormatter.date(from: dateString) {
                        editingDate = date
                    }
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(dateString.isEmpty ? "Не указано" : dateString)
                            .font(.subheadline)
                            .foregroundColor(dateString.isEmpty ? .secondary : .blue)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct InlineEditablePicker<T: Hashable & Identifiable>: View {
    let fieldId: String
    @Binding var selection: T
    let label: String
    let options: [T]
    let displayValue: (T) -> String
    @Binding var activeField: String?
    let onSave: () -> Void
    
    @State private var tempSelection: T
    
    init(fieldId: String, selection: Binding<T>, label: String, options: [T], displayValue: @escaping (T) -> String, activeField: Binding<String?>, onSave: @escaping () -> Void) {
        self.fieldId = fieldId
        self._selection = selection
        self.label = label
        self.options = options
        self.displayValue = displayValue
        self._activeField = activeField
        self.onSave = onSave
        _tempSelection = State(initialValue: selection.wrappedValue)
    }
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(options) { option in
                            Button(action: {
                                tempSelection = option
                            }) {
                                HStack {
                                    Text(displayValue(option))
                                        .font(.caption2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(nil)
                                    Spacer()
                                    if tempSelection.id == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tempSelection.id == option.id ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(tempSelection.id == option.id ? .blue : .primary)
                                .cornerRadius(6)
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            tempSelection = selection
                            activeField = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            selection = tempSelection
                            onSave()
                            activeField = nil
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
            } else {
                Button(action: {
                    tempSelection = selection
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(displayValue(selection))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
            }
        }
    }
}
