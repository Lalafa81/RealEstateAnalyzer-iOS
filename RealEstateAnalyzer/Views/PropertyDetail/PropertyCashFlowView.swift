//
//  PropertyCashFlowView.swift
//  RealEstateAnalyzer
//
//  Движение денежных средств объекта недвижимости
//

import SwiftUI

// MARK: - Движение денежных средств

struct CashFlowView: View {
    @Binding var property: Property
    @Binding var selectedYear: Int
    let onYearChanged: (() -> Void)?
    let onSave: () -> Void
    
    init(property: Binding<Property>, selectedYear: Binding<Int>, onYearChanged: (() -> Void)? = nil, onSave: @escaping () -> Void) {
        self._property = property
        self._selectedYear = selectedYear
        self.onYearChanged = onYearChanged
        self.onSave = onSave
    }
    
    // Cashflow за выбранный год
    var totalCashFlow: Double {
        let monthNumbers = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        guard let yearData = property.months[String(selectedYear)] else {
            return 0
        }
        
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        
        for monthNum in monthNumbers {
            if let monthData = yearData[monthNum] {
                totalIncome += (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                
                // Расходы: 3 вида
                let monthExpense =
                    (monthData.expensesMaintenance ?? 0) +
                    (monthData.expensesOperational ?? 0) +
                    (monthData.expensesOther ?? 0)
                totalExpense += monthExpense
            }
        }
        
        return totalIncome - totalExpense
    }
    
    // Cashflow за весь период (все года)
    var totalCashFlowAllPeriods: Double {
        let monthNumbers = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        let years = property.months.keys.compactMap { Int($0) }.sorted()
        
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        
        for year in years {
            guard let yearData = property.months[String(year)] else { continue }
            
            for monthNum in monthNumbers {
                if let monthData = yearData[monthNum] {
                    totalIncome += (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                    
                    // Расходы: 3 вида
                    let monthExpense =
                        (monthData.expensesMaintenance ?? 0) +
                        (monthData.expensesOperational ?? 0) +
                        (monthData.expensesOther ?? 0)
                    totalExpense += monthExpense
                }
            }
        }
        
        return totalIncome - totalExpense
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ДВИЖЕНИЕ ДЕНЕЖНЫХ СРЕДСТВ")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // Итоговые значения (чистый cashflow)
            HStack(spacing: 6) {
                // Cashflow за выбранный год
                VStack(spacing: 2) {
                    Text("Чистый cashflow за \(String(selectedYear)) год")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(totalCashFlow.formatCurrency())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(totalCashFlow >= 0 ? .green : .red)
                        Text("₽")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
                
                // Cashflow за весь период
                VStack(spacing: 2) {
                    Text("Чистый cashflow за весь период")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(totalCashFlowAllPeriods.formatCurrency())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(totalCashFlowAllPeriods >= 0 ? .green : .red)
                        Text("₽")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Выбор года
            YearPickerView(
                selectedYear: $selectedYear,
                property: $property,
                onYearChanged: onYearChanged,
                onSave: onSave
            )
            
            // Таблица по месяцам
            CashFlowTableView(
                property: $property,
                selectedYear: selectedYear,
                onSave: onSave
            )
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct YearPickerView: View {
    @Binding var selectedYear: Int
    @Binding var property: Property
    let onYearChanged: (() -> Void)?
    let onSave: () -> Void
    
    init(selectedYear: Binding<Int>, property: Binding<Property>, onYearChanged: (() -> Void)? = nil, onSave: @escaping () -> Void) {
        self._selectedYear = selectedYear
        self._property = property
        self.onYearChanged = onYearChanged
        self.onSave = onSave
    }
    
    var availableYears: [Int] {
        let years = property.months.keys.compactMap { Int($0) }.sorted()
        // Если нет данных, добавляем текущий год
        if years.isEmpty {
            return [Calendar.current.component(.year, from: Date())]
        }
        // Добавляем текущий год, если его нет
        let currentYear = Calendar.current.component(.year, from: Date())
        var allYears = Set(years)
        allYears.insert(currentYear)
        return Array(allYears).sorted()
    }
    
    var minYear: Int {
        availableYears.first ?? Calendar.current.component(.year, from: Date())
    }
    
    var maxYear: Int {
        availableYears.last ?? Calendar.current.component(.year, from: Date())
    }
    
    private func addYear(_ year: Int) {
        if property.months[String(year)] == nil {
            property.months[String(year)] = [:]
            onSave()
        }
        selectedYear = year
        onYearChanged?()
    }
    
    private func deleteYear(_ year: Int) {
        let wasSelected = selectedYear == year
        property.months.removeValue(forKey: String(year))
        
        // Если удалили выбранный год, выбираем другой
        if wasSelected {
            // Получаем обновленный список годов после удаления
            let remainingYears = property.months.keys.compactMap { Int($0) }.sorted()
            if let newYear = remainingYears.first {
                selectedYear = newYear
            } else {
                // Если это был последний год, добавляем текущий
                let currentYear = Calendar.current.component(.year, from: Date())
                addYear(currentYear)
                return // addYear уже вызывает onSave
            }
        }
        onSave()
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Стрелка влево
            Button(action: {
                if let currentIndex = availableYears.firstIndex(of: selectedYear),
                   currentIndex > 0 {
                    selectedYear = availableYears[currentIndex - 1]
                    onYearChanged?()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
            .disabled(availableYears.firstIndex(of: selectedYear) == 0)
            
            // Года с прокруткой
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Кнопка добавления года слева
                        Button(action: {
                            addYear(minYear - 1)
                        }) {
                            VStack(spacing: 2) {
                                Text("+")
                                    .font(.caption)
                                Text(String(minYear - 1))
                                    .font(.subheadline)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        
                        // Существующие года
                        ForEach(availableYears, id: \.self) { year in
                            HStack(spacing: 4) {
                                Button(action: {
                                    selectedYear = year
                                    onYearChanged?()
                                    // Прокручиваем к выбранному году
                                    withAnimation {
                                        proxy.scrollTo(year, anchor: .center)
                                    }
                                }) {
                                    Text(String(year))
                                        .font(.subheadline)
                                        .fontWeight(year == selectedYear ? .bold : .regular)
                                        .foregroundColor(year == selectedYear ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(year == selectedYear ? Color.blue : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                
                                // Крестик для удаления года
                                Button(action: {
                                    deleteYear(year)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .id(year) // Добавляем id для прокрутки
                        }
                        
                        // Кнопка добавления года справа
                        Button(action: {
                            addYear(maxYear + 1)
                        }) {
                            VStack(spacing: 2) {
                                Text("+")
                                    .font(.caption)
                                Text(String(maxYear + 1))
                                    .font(.subheadline)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .onAppear {
                    // Прокручиваем к выбранному году при появлении
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(selectedYear, anchor: .center)
                        }
                    }
                }
                .onChange(of: selectedYear) { newYear in
                    // Прокручиваем к выбранному году при изменении
                    withAnimation {
                        proxy.scrollTo(newYear, anchor: .center)
                    }
                }
            }
            
            // Стрелка вправо
            Button(action: {
                if let currentIndex = availableYears.firstIndex(of: selectedYear),
                   currentIndex < availableYears.count - 1 {
                    selectedYear = availableYears[currentIndex + 1]
                    onYearChanged?()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
            .disabled(availableYears.firstIndex(of: selectedYear) == availableYears.count - 1)
        }
    }
}

struct CashFlowTableView: View {
    @Binding var property: Property
    let selectedYear: Int
    let onSave: () -> Void
    
    @State private var editingMonth: String? = nil
    @State private var editingIncome: String = ""
    @State private var editingIncomeVariable: String = ""
    @State private var editingExpenseMaintenance: String = ""
    @State private var editingExpenseOperational: String = ""
    @State private var editingExpenseOther: String = ""
    @State private var showingDetailEditor = false
    
    var monthlyData: [(month: String, monthNum: String, income: Double, expense: Double, monthData: Property.MonthData?)] {
        let monthNames = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        let monthNumbers = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        let yearData = property.months[String(selectedYear)] ?? [:]
        
        var result: [(month: String, monthNum: String, income: Double, expense: Double, monthData: Property.MonthData?)] = []
        
        for (index, monthNum) in monthNumbers.enumerated() {
            if let monthData = yearData[monthNum] {
                let income = (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                
                // Расходы: 3 вида
                let expense =
                    (monthData.expensesMaintenance ?? 0) +
                    (monthData.expensesOperational ?? 0) +
                    (monthData.expensesOther ?? 0)
                
                result.append((month: monthNames[index], monthNum: monthNum, income: income, expense: expense, monthData: monthData))
            } else {
                result.append((month: monthNames[index], monthNum: monthNum, income: 0, expense: 0, monthData: nil))
            }
        }
        
        return result
    }
    
    private func startEditing(monthNum: String, income: Double, expense: Double) {
        editingMonth = monthNum
        
        // Загружаем данные для простого редактирования
        let yearKey = String(selectedYear)
        if let yearData = property.months[yearKey],
           let monthData = yearData[monthNum] {
            // Для простого редактирования: доход → базовый доход, расход → прочий расход
            editingIncome = String(format: "%.0f", monthData.income ?? 0)
            editingExpenseOther = String(format: "%.0f", monthData.expensesOther ?? 0)
            
            // Загружаем все поля для детального редактора (на случай открытия через 3 точки)
            editingIncomeVariable = String(format: "%.0f", monthData.incomeVariable ?? 0)
            editingExpenseMaintenance = String(format: "%.0f", monthData.expensesMaintenance ?? 0)
            editingExpenseOperational = String(format: "%.0f", monthData.expensesOperational ?? 0)
        } else {
            // Если данных нет, показываем 0
            editingIncome = "0"
            editingExpenseOther = "0"
            editingIncomeVariable = "0"
            editingExpenseMaintenance = "0"
            editingExpenseOperational = "0"
        }
    }
    
    /// Сохранение при простом редактировании (доход → income, расход → expensesOther)
    private func saveMonthDataSimple(monthNum: String) {
        let incomeValue = Double(editingIncome) ?? 0
        let expenseOtherValue = Double(editingExpenseOther) ?? 0
        
        let yearKey = String(selectedYear)
        
        // Создаем полную копию словаря months, чтобы SwiftUI заметил изменение
        var monthsCopy = property.months
        var yearData = monthsCopy[yearKey] ?? [:]
        
        // Получаем существующие данные или создаем новые
        var monthData = yearData[monthNum] ?? Property.MonthData()
        
        // Сохраняем только базовый доход и прочий расход
        monthData.income = incomeValue > 0 ? incomeValue : nil
        monthData.expensesOther = expenseOtherValue > 0 ? expenseOtherValue : nil
        // Остальные поля не трогаем (сохраняем существующие значения)
        
        yearData[monthNum] = monthData
        monthsCopy[yearKey] = yearData
        
        // Обновляем property через binding - создаем новую копию, чтобы SwiftUI заметил изменение
        property.months = monthsCopy
        
        editingMonth = nil
        
        // Сохраняем изменения в data.json - это обновит аналитику автоматически
        onSave()
    }
    
    /// Сохранение при детальном редактировании (все поля)
    private func saveMonthData(monthNum: String) {
        // Парсим все значения
        let incomeValue = Double(editingIncome) ?? 0
        let incomeVariableValue = Double(editingIncomeVariable) ?? 0
        let expenseMaintenanceValue = Double(editingExpenseMaintenance) ?? 0
        let expenseOperationalValue = Double(editingExpenseOperational) ?? 0
        let expenseOtherValue = Double(editingExpenseOther) ?? 0
        
        let yearKey = String(selectedYear)
        
        // Создаем полную копию словаря months, чтобы SwiftUI заметил изменение
        var monthsCopy = property.months
        var yearData = monthsCopy[yearKey] ?? [:]
        
        // Получаем существующие данные или создаем новые
        var monthData = yearData[monthNum] ?? Property.MonthData()
        
        // Сохраняем все поля (сохраняем даже 0, чтобы явно указать отсутствие значения)
        monthData.income = incomeValue > 0 ? incomeValue : nil
        monthData.incomeVariable = incomeVariableValue > 0 ? incomeVariableValue : nil
        monthData.expensesMaintenance = expenseMaintenanceValue > 0 ? expenseMaintenanceValue : nil
        monthData.expensesOperational = expenseOperationalValue > 0 ? expenseOperationalValue : nil
        monthData.expensesOther = expenseOtherValue > 0 ? expenseOtherValue : nil
        
        yearData[monthNum] = monthData
        monthsCopy[yearKey] = yearData
        
        // Обновляем property через binding - создаем новую копию, чтобы SwiftUI заметил изменение
        property.months = monthsCopy
        
        editingMonth = nil
        
        // Сохраняем изменения в data.json - это обновит аналитику автоматически
        onSave()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок таблицы
            HStack(spacing: 0) {
                Text("Месяц")
                    .font(.footnote) // РАЗМЕР ШРИФТА заголовка
                    .fontWeight(.semibold)
                    .frame(width: 70, alignment: .leading) // ШИРИНА колонки "Месяц"
                    .padding(.leading, 8) // ОТСТУП слева
                
                Spacer()
                
                Text("Доход")
                    .font(.footnote) // РАЗМЕР ШРИФТА заголовка
                    .fontWeight(.semibold)
                    .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Доход"
                
                Text("Расход")
                    .font(.footnote) // РАЗМЕР ШРИФТА заголовка
                    .fontWeight(.semibold)
                    .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Расход"
                
                // Невидимые placeholder'ы для кнопок, чтобы сохранить ширину
                Color.clear
                    .frame(width: 28) // ШИРИНА кнопки (галочка)
                
                Color.clear
                    .frame(width: 28) // ШИРИНА кнопки (три точки)
                    .padding(.trailing, 8) // ОТСТУП справа
            }
            .padding(.vertical, 6) // ВЕРТИКАЛЬНЫЙ ОТСТУП заголовка
            .background(Color(.systemGray5))
            
            Divider()
            
            // Строки таблицы
            ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, data in
                HStack(spacing: 0) {
                    Text(data.month)
                        .font(.footnote) // РАЗМЕР ШРИФТА месяца
                        .frame(width: 70, alignment: .leading) // ШИРИНА колонки "Месяц"
                        .padding(.leading, 8) // ОТСТУП слева
                    
                    Spacer()
                    
                    if editingMonth == data.monthNum {
                        // Режим редактирования - упрощенный (прямое редактирование)
                        // Доход → базовый доход (income)
                        TextField("Доход", text: $editingIncome)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 90) // ШИРИНА поля "Доход"
                            .font(.footnote) // РАЗМЕР ШРИФТА в поле редактирования
                        
                        // Расход → прочий расход (expensesOther) - можно редактировать напрямую
                        TextField("Расход", text: $editingExpenseOther)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90) // ШИРИНА поля "Расход"
                            .font(.footnote) // РАЗМЕР ШРИФТА в поле редактирования
                            .foregroundColor(.red)
                        
                        Button(action: {
                            saveMonthDataSimple(monthNum: data.monthNum)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption) // РАЗМЕР иконки кнопки
                        }
                        .frame(width: 28) // ШИРИНА кнопки (галочка)
                        
                        Button(action: {
                            showingDetailEditor = true
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption) // РАЗМЕР иконки кнопки
                        }
                        .frame(width: 28) // ШИРИНА кнопки (три точки)
                        .padding(.trailing, 8) // ОТСТУП справа
                    } else {
                        // Режим просмотра - резервируем место для кнопок, чтобы ширина не менялась
                        Text(data.income.formatCurrency())
                            .font(.footnote) // РАЗМЕР ШРИФТА значения дохода
                            .foregroundColor(.green)
                            .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Доход"
                            .contentShape(Rectangle())
                            .onTapGesture {
                                startEditing(monthNum: data.monthNum, income: data.income, expense: data.expense)
                            }
                        
                        Text(data.expense.formatCurrency())
                            .font(.footnote) // РАЗМЕР ШРИФТА значения расхода
                            .foregroundColor(.red)
                            .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Расход"
                            .contentShape(Rectangle())
                            .onTapGesture {
                                startEditing(monthNum: data.monthNum, income: data.income, expense: data.expense)
                            }
                        
                        // Невидимые placeholder'ы для кнопок, чтобы сохранить ширину
                        Color.clear
                            .frame(width: 28) // ШИРИНА placeholder кнопки (галочка)
                        
                        Color.clear
                            .frame(width: 28) // ШИРИНА placeholder кнопки (три точки)
                            .padding(.trailing, 8) // ОТСТУП справа
                    }
                }
                .padding(.vertical, 4) // ВЕРТИКАЛЬНЫЙ ОТСТУП строки
                
                if index < monthlyData.count - 1 {
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .sheet(isPresented: $showingDetailEditor) {
            if let monthNum = editingMonth {
                MonthDetailEditorView(
                    monthNum: monthNum,
                    monthName: monthlyData.first(where: { $0.monthNum == monthNum })?.month ?? "",
                    property: $property,
                    selectedYear: selectedYear,
                    editingIncome: $editingIncome,
                    editingIncomeVariable: $editingIncomeVariable,
                    editingExpenseMaintenance: $editingExpenseMaintenance,
                    editingExpenseOperational: $editingExpenseOperational,
                    editingExpenseOther: $editingExpenseOther,
                    onSave: {
                        saveMonthData(monthNum: monthNum)
                        showingDetailEditor = false
                    }
                )
            }
        }
    }
    
}

// MARK: - Детальный редактор месяца

struct MonthDetailEditorView: View {
    let monthNum: String
    let monthName: String
    @Binding var property: Property
    let selectedYear: Int
    @Binding var editingIncome: String
    @Binding var editingIncomeVariable: String
    @Binding var editingExpenseMaintenance: String
    @Binding var editingExpenseOperational: String
    @Binding var editingExpenseOther: String
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Доходы за \(monthName) \(selectedYear)")) {
                    HStack {
                        Text("Базовый доход:")
                        Spacer()
                        TextField("0", text: $editingIncome)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Переменный доход:")
                        Spacer()
                        TextField("0", text: $editingIncomeVariable)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Итого доход:")
                            .font(.system(.subheadline, design: .default).weight(.semibold))
                        Spacer()
                        Text(((Double(editingIncome) ?? 0) + (Double(editingIncomeVariable) ?? 0)).formatCurrency())
                            .font(.system(.subheadline, design: .default).weight(.semibold))
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("Расходы за \(monthName) \(selectedYear)")) {
                    HStack {
                        Text("Административные расходы:")
                        Spacer()
                        TextField("0", text: $editingExpenseMaintenance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Эксплуатационные расходы:")
                        Spacer()
                        TextField("0", text: $editingExpenseOperational)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Прочие расходы:")
                        Spacer()
                        TextField("0", text: $editingExpenseOther)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Итого расход:")
                            .font(.system(.subheadline, design: .default).weight(.semibold))
                        Spacer()
                        Text((
                            (Double(editingExpenseMaintenance) ?? 0) +
                            (Double(editingExpenseOperational) ?? 0) +
                            (Double(editingExpenseOther) ?? 0)
                        ).formatCurrency())
                        .font(.system(.subheadline, design: .default).weight(.semibold))
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Редактирование: \(monthName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .font(.system(.body, design: .default).weight(.semibold))
                }
            }
        }
    }
    
}

