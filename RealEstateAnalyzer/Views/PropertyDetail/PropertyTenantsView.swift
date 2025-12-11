//
//  PropertyTenantsView.swift
//  RealEstateAnalyzer
//
//  Арендаторы объекта недвижимости
//

import SwiftUI

// MARK: - Основной View

struct TenantsView: View {
    @Binding var tenants: [Tenant]
    let propertyArea: Double
    let onSave: () -> Void
    
    @Environment(\.horizontalSizeClass) var hSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Кнопка добавления
            HStack {
                Spacer()
                Button(action: {
                    // Сразу добавляем нового арендатора в массив
                    let newTenant = Tenant(name: "", income: nil, startDate: nil, endDate: nil, area: nil, indexation: nil, companyType: nil, deposit: nil, depositType: nil)
                    tenants.append(newTenant)
                    onSave()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Добавить")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            
            // Таблица или карточки арендаторов
            if tenants.isEmpty {
                Text("Нет арендаторов")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                if hSize == .compact {
                    // 📱 iPhone — компактные карточки
                    VStack(spacing: 8) {
                        ForEach(tenants.indices, id: \.self) { index in
                            TenantCardView(
                                tenant: Binding(
                                    get: { tenants[index] },
                                    set: { tenants[index] = $0 }
                                ),
                                propertyArea: propertyArea,
                                onDelete: {
                                    tenants.remove(at: index)
                                    onSave()
                                },
                                onEdit: {
                                    // Редактирование происходит inline, ничего не делаем
                                },
                                onSave: onSave
                            )
                        }
                    }
                } else {
                    // 💻 iPad / широкий экран — горизонтальная таблица
                    HorizontalTenantsTable(
                        tenants: $tenants,
                        propertyArea: propertyArea,
                        onSave: onSave,
                        onEdit: { tenant in
                            // Редактирование происходит inline, ничего не делаем
                        }
                    )
                }
            }
        }
        .padding()
    }
}

// MARK: - Константы

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()

// MARK: - Карточка арендатора для iPhone

struct TenantCardView: View {
    @Binding var tenant: Tenant
    let propertyArea: Double
    let onDelete: () -> Void
    let onEdit: () -> Void
    var onSave: (() -> Void)? = nil
    
    // Состояние для отслеживания активного поля редактирования
    @State private var activeEditingField: String? = nil
    @State private var showDeleteConfirmation = false
    
    // Парсинг индексации из строки (например, "5%" -> 5.0)
    private func parseIndexation(_ value: String) -> Double {
        let cleaned = value.replacingOccurrences(of: "%", with: "").replacingOccurrences(of: " ", with: "")
        return Double(cleaned) ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Заголовок с названием и кнопкой удаления
            HStack {
                if activeEditingField == "name" {
                    HStack {
                        TextField("", text: Binding(
                            get: { tenant.name },
                            set: { tenant.name = $0 }
                        ))
                        .font(.headline)
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
                            onSave?()
                            activeEditingField = nil
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                } else {
                    HStack {
                        Button(action: { activeEditingField = "name" }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.blue.opacity(0.6))
                        }
                        Text(tenant.name.isEmpty ? "Без названия" : tenant.name)
                            .font(.headline)
                            .strikethrough(tenant.isArchived)
                            .opacity(tenant.isArchived ? 0.6 : 1)
                        Spacer()
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Удалить арендатора?"),
                    message: Text("Вы уверены, что хотите удалить арендатора \"\(tenant.name.isEmpty ? "Без названия" : tenant.name)\"? Это действие нельзя отменить."),
                    primaryButton: .destructive(Text("Удалить")) {
                        onDelete()
                    },
                    secondaryButton: .cancel(Text("Отмена"))
                )
            }
            
            // Мини-таблица 2x3 с inline редактированием
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 4) {
                // Доход
                TenantInlineEditableNumber(
                    fieldId: "income",
                    value: tenant.income ?? 0,
                    label: "Доход",
                    valueColor: .green,
                    formatter: { $0.formatCurrency() },
                    activeField: $activeEditingField,
                    onSave: { newValue in
                        tenant.income = newValue > 0 ? newValue : nil
                        onSave?()
                    }
                )
                
                // Площадь
                TenantInlineEditableNumber(
                    fieldId: "area",
                    value: tenant.area ?? 0,
                    label: "Площадь",
                    suffix: " м²",
                    activeField: $activeEditingField,
                    onSave: { newValue in
                        tenant.area = newValue > 0 ? newValue : nil
                        onSave?()
                    }
                )
                
                // Начало
                TenantInlineEditableDate(
                    fieldId: "startDate",
                    dateString: tenant.startDate ?? "",
                    label: "Начало",
                    dateFormatter: dateFormatter,
                    activeField: $activeEditingField,
                    onSave: { newValue in
                        tenant.startDate = newValue.isEmpty ? nil : newValue
                        onSave?()
                    }
                )
                
                // Конец
                TenantInlineEditableDate(
                    fieldId: "endDate",
                    dateString: tenant.endDate ?? "",
                    label: "Конец",
                    dateFormatter: dateFormatter,
                    activeField: $activeEditingField,
                    onSave: { newValue in
                        tenant.endDate = newValue.isEmpty ? nil : newValue
                        onSave?()
                    }
                )
                
                // Компания
                TenantInlineEditableCompanyType(
                    fieldId: "companyType",
                    selection: Binding(
                        get: { tenant.companyType ?? .ip },
                        set: { tenant.companyType = $0 }
                    ),
                    label: "Компания",
                    activeField: $activeEditingField,
                    onSave: { onSave?() }
                )
                
                // Индексация
                TenantInlineEditableNumber(
                    fieldId: "indexation",
                    value: parseIndexation(tenant.indexation ?? ""),
                    label: "Индексация",
                    suffix: "%",
                    activeField: $activeEditingField,
                    onSave: { newValue in
                        tenant.indexation = newValue > 0 ? String(format: "%.0f%%", newValue) : nil
                        onSave?()
                    }
                )
                
                // Депозит
                TenantInlineEditableDeposit(
                    fieldId: "deposit",
                    deposit: $tenant.deposit,
                    depositType: $tenant.depositType,
                    income: tenant.income,
                    label: "Депозит",
                    activeField: $activeEditingField,
                    onSave: { onSave?() }
                )
            }
            .font(.subheadline)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
}

// MARK: - Inline редактируемые компоненты для карточки арендатора

struct TenantInlineEditableText: View {
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
        VStack(alignment: .leading, spacing: 2) {
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
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        onSave(editingText)
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
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
                        Text(text.isEmpty ? "—" : text)
                            .font(.subheadline)
                            .foregroundColor(text.isEmpty ? .secondary : .primary)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct TenantInlineEditableNumber: View {
    let fieldId: String
    let value: Double
    let label: String
    var suffix: String = ""
    var valueColor: Color = .primary
    var formatter: ((Double) -> String)? = nil
    @Binding var activeField: String?
    let onSave: (Double) -> Void
    
    @State private var editingText: String = ""
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var displayValue: String {
        if value == 0 {
            return "—"
        }
        if let formatter = formatter {
            return formatter(value)
        }
        return String(format: "%.0f", value) + suffix
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
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
                        editingText = value > 0 ? String(format: "%.0f", value) : ""
                        activeField = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if let newValue = Double(editingText) {
                            onSave(newValue)
                        }
                        activeField = nil
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: {
                    editingText = value > 0 ? String(format: "%.0f", value) : ""
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue.opacity(0.6))
                        Text(displayValue)
                            .font(.subheadline)
                            .foregroundColor(value == 0 ? .secondary : valueColor)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Inline редактирование даты с календарем

struct TenantInlineEditableDate: View {
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
        VStack(alignment: .leading, spacing: 2) {
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
                    } else {
                        editingDate = Date()
                    }
                    activeField = fieldId
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue.opacity(0.6))
                        Text(dateString.isEmpty ? "—" : dateString)
                            .font(.subheadline)
                            .foregroundColor(dateString.isEmpty ? .secondary : .primary)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Горизонтальная таблица для iPad

struct HorizontalTenantsTable: View {
    @Binding var tenants: [Tenant]
    let propertyArea: Double
    let onSave: () -> Void
    let onEdit: (Tenant) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                // Заголовок таблицы
                HStack(spacing: 12) {
                    Text("Компания")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 150, alignment: .leading)
                    Text("Доход")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .trailing)
                    Text("Площадь")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 90, alignment: .trailing)
                    Text("Компания")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 70, alignment: .trailing)
                    Text("Депозит")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .trailing)
                    Text("Начало")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .leading)
                    Text("Конец")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .leading)
                    Text("Индексация")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 90, alignment: .trailing)
                    Text("")
                        .frame(width: 40)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray5))
                
                Divider()
                
                // Строки арендаторов
                ForEach(tenants) { tenant in
                    TenantRowView(
                        tenant: Binding(
                            get: { tenant },
                            set: { newTenant in
                                if let index = tenants.firstIndex(where: { $0.id == newTenant.id }) {
                                    tenants[index] = newTenant
                                    onSave()
                                }
                            }
                        ),
                        propertyArea: propertyArea,
                        onDelete: {
                            tenants.removeAll { $0.id == tenant.id }
                            onSave()
                        },
                        onEdit: {
                            onEdit(tenant)
                        }
                    )
                    
                    Divider()
                }
            }
        }
    }
}

// MARK: - Компоненты для редактирования компании и депозита

struct TenantInlineEditableCompanyType: View {
    let fieldId: String
    @Binding var selection: CompanyType
    let label: String
    @Binding var activeField: String?
    let onSave: () -> Void
    
    @State private var tempSelection: CompanyType
    
    init(fieldId: String, selection: Binding<CompanyType>, label: String, activeField: Binding<String?>, onSave: @escaping () -> Void) {
        self.fieldId = fieldId
        self._selection = selection
        self.label = label
        self._activeField = activeField
        self.onSave = onSave
        _tempSelection = State(initialValue: selection.wrappedValue)
    }
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(CompanyType.allCases, id: \.id) { option in
                            Button(action: {
                                tempSelection = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
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
                            .foregroundColor(.blue.opacity(0.6))
                        Text(selection.rawValue)
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

struct TenantInlineEditableDeposit: View {
    let fieldId: String
    @Binding var deposit: Double?
    @Binding var depositType: DepositType?
    let income: Double?
    let label: String
    @Binding var activeField: String?
    let onSave: () -> Void
    
    @State private var tempDeposit: Double?
    @State private var tempDepositType: DepositType?
    @State private var customDepositText: String = ""
    
    init(fieldId: String, deposit: Binding<Double?>, depositType: Binding<DepositType?>, income: Double?, label: String, activeField: Binding<String?>, onSave: @escaping () -> Void) {
        self.fieldId = fieldId
        self._deposit = deposit
        self._depositType = depositType
        self.income = income
        self.label = label
        self._activeField = activeField
        self.onSave = onSave
        _tempDeposit = State(initialValue: deposit.wrappedValue)
        _tempDepositType = State(initialValue: depositType.wrappedValue ?? .custom)
        _customDepositText = State(initialValue: deposit.wrappedValue != nil ? String(format: "%.0f", deposit.wrappedValue!) : "")
    }
    
    private var isEditing: Bool {
        activeField == fieldId
    }
    
    private var displayValue: String {
        if let deposit = deposit {
            return deposit.formatCurrency()
        }
        return "—"
    }
    
    private func calculateDeposit() {
        guard let income = income, income > 0 else { return }
        
        switch tempDepositType {
        case .oneMonth:
            tempDeposit = income
        case .twoMonths:
            tempDeposit = income * 2
        case .custom:
            if let value = Double(customDepositText) {
                tempDeposit = value
            } else {
                tempDeposit = nil
            }
        case .none:
            tempDeposit = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    // Выбор типа депозита
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach([DepositType.oneMonth, DepositType.twoMonths, DepositType.custom], id: \.id) { option in
                            Button(action: {
                                tempDepositType = option
                                if option != .custom {
                                    calculateDeposit()
                                }
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                        .font(.caption2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(nil)
                                    Spacer()
                                    if tempDepositType?.id == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tempDepositType?.id == option.id ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(.primary)
                                .cornerRadius(6)
                            }
                        }
                    }
                    
                    // Поле для ввода вручную
                    if tempDepositType == .custom {
                        TextField("Сумма депозита", text: $customDepositText)
                            .keyboardType(.decimalPad)
                            .font(.caption2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: customDepositText) { _ in
                                calculateDeposit()
                            }
                    }
                    
                    // Показываем вычисленное значение
                    if let deposit = tempDeposit {
                        Text("Депозит: \(deposit.formatCurrency())")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            tempDeposit = deposit
                            tempDepositType = depositType
                            customDepositText = deposit != nil ? String(format: "%.0f", deposit!) : ""
                            activeField = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            deposit = tempDeposit
                            depositType = tempDepositType
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
                    tempDeposit = deposit
                    tempDepositType = depositType ?? .custom
                    customDepositText = deposit != nil ? String(format: "%.0f", deposit!) : ""
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

// MARK: - Строка таблицы для iPad

struct TenantRowView: View {
    @Binding var tenant: Tenant
    let propertyArea: Double
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Компания
            Text(tenant.name.isEmpty ? "—" : tenant.name)
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 150, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Доход
            Text((tenant.income ?? 0).formatCurrency())
                .font(.subheadline)
                .foregroundColor(.green)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 100, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Площадь
            Text(tenant.area != nil ? String(format: "%.0f м²", tenant.area!) : "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 90, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Тип компании
            Text(tenant.companyType?.rawValue ?? "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 70, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Депозит
            Text(tenant.deposit != nil ? tenant.deposit!.formatCurrency() : "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 100, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Начало
            Text(tenant.startDate ?? "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Конец
            Text(tenant.endDate ?? "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Индексация
            Text(tenant.indexation ?? "—")
                .font(.subheadline)
                .strikethrough(tenant.isArchived)
                .opacity(tenant.isArchived ? 0.5 : 1.0)
                .frame(width: 90, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Кнопка удаления
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .frame(width: 40)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .opacity(tenant.isArchived ? 0.6 : 1.0)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Удалить арендатора?"),
                message: Text("Вы уверены, что хотите удалить арендатора \"\(tenant.name.isEmpty ? "Без названия" : tenant.name)\"? Это действие нельзя отменить."),
                primaryButton: .destructive(Text("Удалить")) {
                    onDelete()
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
}
