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
                        .scaleEffect(0.85) // РАЗМЕР: уменьшаем размер DatePicker, чтобы шрифт не увеличивался
                    
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
                            .foregroundColor(.blue)
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

