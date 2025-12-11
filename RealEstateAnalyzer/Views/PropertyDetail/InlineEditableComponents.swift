//
//  InlineEditableComponents.swift
//  RealEstateAnalyzer
//
//  Компоненты для inline редактирования полей в карточке объекта
//

import SwiftUI

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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
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
                            .foregroundColor(.blue.opacity(0.6))
                        Text(text.isEmpty ? "Не указано" : text)
                            .font(.subheadline)
                            .foregroundColor(text.isEmpty ? .secondary : .primary)
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
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
                            .foregroundColor(.blue.opacity(0.6))
                        Text(displayValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
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
                DatePicker("", selection: $editingDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                    .scaleEffect(0.85) // РАЗМЕР: уменьшаем размер DatePicker, чтобы шрифт не увеличивался
                    .onChange(of: editingDate) { newDate in
                        // Автоматически сохраняем и закрываем календарь при выборе даты
                        let newDateString = dateFormatter.string(from: newDate)
                        onSave(newDateString)
                        activeField = nil
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
                            .foregroundColor(.blue.opacity(0.6))
                        Text(dateString.isEmpty ? "Не указано" : dateString)
                            .font(.subheadline)
                            .foregroundColor(dateString.isEmpty ? .secondary : .primary)
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
                                HStack(alignment: .center) {
                                    Text(displayValue(option))
                                        .font(.caption2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(nil)
                                    Spacer()
                                    if tempSelection.id == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        // Пустое место для выравнивания
                                        Color.clear
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                .frame(minHeight: 24)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tempSelection.id == option.id ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(.primary)
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
                            .foregroundColor(.blue.opacity(0.6))
                        Text(displayValue(selection))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
            }
        }
    }
}



// MARK: - Inline редактирование типа объекта с кастомным вводом

struct InlineEditablePropertyType: View {
    let fieldId: String
    @Binding var type: PropertyType
    @Binding var customType: String?
    let label: String
    @Binding var activeField: String?
    let onSave: () -> Void
    
    @State private var tempType: PropertyType
    @State private var tempCustomType: String
    
    init(fieldId: String, type: Binding<PropertyType>, customType: Binding<String?>, label: String, activeField: Binding<String?>, onSave: @escaping () -> Void) {
        self.fieldId = fieldId
        self._type = type
        self._customType = customType
        self.label = label
        self._activeField = activeField
        self.onSave = onSave
        _tempType = State(initialValue: type.wrappedValue)
        _tempCustomType = State(initialValue: customType.wrappedValue ?? "")
    }
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    private var displayValue: String {
        let currentType = type
        let currentCustomType = customType
        return currentType.displayValue(customType: currentCustomType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    // Выбор типа из списка
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(PropertyType.allCases) { option in
                            Button(action: {
                                tempType = option
                                if option != .other {
                                    tempCustomType = ""
                                }
                            }) {
                                HStack(alignment: .center) {
                                    Text(option.rawValue)
                                        .font(.caption2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(nil)
                                    Spacer()
                                    if tempType.id == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        // Пустое место для выравнивания
                                        Color.clear
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                .frame(minHeight: 24)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tempType.id == option.id ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(.primary)
                                .cornerRadius(6)
                            }
                        }
                    }
                    
                    // Поле для ввода вручную, если выбрано "Другое"
                    if tempType == .other {
                        TextField("Введите назначение", text: $tempCustomType)
                            .font(.caption2)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            tempType = type
                            tempCustomType = customType ?? ""
                            activeField = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            type = tempType
                            customType = (tempType == .other && !tempCustomType.isEmpty) ? tempCustomType : nil
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
                    tempType = type
                    tempCustomType = customType ?? ""
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue.opacity(0.6))
                        Text(displayValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
            }
        }
    }
}
