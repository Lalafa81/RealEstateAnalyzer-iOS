//
//  PropertyCashFlowView.swift
//  RealEstateAnalyzer
//
//  Движение денежных средств объекта недвижимости
//

import SwiftUI

// MARK: - Константы

private let monthNumbers = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
private let monthNames = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

// MARK: - Helper функции для расчетов

private func calculateIncome(from monthData: Property.MonthData) -> Double {
    return (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
}

private func calculateExpense(from monthData: Property.MonthData) -> Double {
    return (monthData.expensesMaintenance ?? 0) +
           (monthData.expensesOperational ?? 0) +
           (monthData.expensesOther ?? 0)
}

private func calculateCashFlow(for yearData: [String: Property.MonthData]) -> (income: Double, expense: Double) {
    var totalIncome: Double = 0
    var totalExpense: Double = 0
    
    for monthNum in monthNumbers {
        if let monthData = yearData[monthNum] {
            totalIncome += calculateIncome(from: monthData)
            totalExpense += calculateExpense(from: monthData)
        }
    }
    
    return (totalIncome, totalExpense)
}

// MARK: - Движение денежных средств

struct CashFlowView: View {
    @Binding var property: Property
    @Binding var selectedYear: Int
    let onSave: () -> Void
    
    init(property: Binding<Property>, selectedYear: Binding<Int>, onSave: @escaping () -> Void) {
        self._property = property
        self._selectedYear = selectedYear
        self.onSave = onSave
    }
    
    // Cashflow за выбранный год
    var totalCashFlow: Double {
        guard let yearData = property.months[String(selectedYear)] else {
            return 0
        }
        let result = calculateCashFlow(for: yearData)
        return result.income - result.expense
    }
    
    // Cashflow за весь период (все года)
    var totalCashFlowAllPeriods: Double {
        let years = property.months.keys.compactMap { Int($0) }.sorted()
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        
        for year in years {
            guard let yearData = property.months[String(year)] else { continue }
            let result = calculateCashFlow(for: yearData)
            totalIncome += result.income
            totalExpense += result.expense
        }
        
        return totalIncome - totalExpense
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                            .font(.system(size: 13, weight: .bold))
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
                            .font(.system(size: 14, weight: .bold)) //шрифт зеленого блока
                            .foregroundColor(totalCashFlowAllPeriods >= 0 ? .green : .red) //цвет зеленого большого текста
                        Text("₽")
                            .font(.system(size: 12))    //шрифт маленького текста
                            .foregroundColor(.secondary) //цвет маленького текста
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Таблица по месяцам
            CashFlowTableView(
                property: $property,
                selectedYear: selectedYear,
                onSave: onSave
            )
        }
        .padding(8)
    }
}

struct CashFlowTableView: View {
    @Binding var property: Property
    let selectedYear: Int
    let onSave: () -> Void
    
    @State private var editingMonth: String? = nil
    @State private var editingIncome: String = ""
    @State private var editingExpenseOther: String = ""
    @State private var showingDetailEditor = false
    
    // Состояния для popup (Double значения)
    @State private var popupIncomeBase: Double = 0
    @State private var popupIncomeVariable: Double = 0
    @State private var popupAdmin: Double = 0
    @State private var popupOperating: Double = 0
    @State private var popupOther: Double = 0
    
    var monthlyData: [(month: String, monthNum: String, income: Double, expense: Double, monthData: Property.MonthData?)] {
        let yearData = property.months[String(selectedYear)] ?? [:]
        
        return monthNumbers.enumerated().map { index, monthNum in
            if let monthData = yearData[monthNum] {
                return (month: monthNames[index], monthNum: monthNum, 
                       income: calculateIncome(from: monthData),
                       expense: calculateExpense(from: monthData),
                       monthData: monthData)
            } else {
                return (month: monthNames[index], monthNum: monthNum, income: 0, expense: 0, monthData: nil)
            }
        }
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
        } else {
            // Если данных нет, показываем 0
            editingIncome = "0"
            editingExpenseOther = "0"
        }
    }
    
    /// Сохранение данных месяца (простое редактирование)
    private func saveMonthData(monthNum: String) {
        let yearKey = String(selectedYear)
        var monthsCopy = property.months
        var yearData = monthsCopy[yearKey] ?? [:]
        var monthData = yearData[monthNum] ?? Property.MonthData()
        
        // Простое редактирование: только базовый доход и прочий расход
        monthData.income = (Double(editingIncome) ?? 0) > 0 ? Double(editingIncome) ?? nil : nil
        monthData.expensesOther = (Double(editingExpenseOther) ?? 0) > 0 ? Double(editingExpenseOther) ?? nil : nil
        
        yearData[monthNum] = monthData
        monthsCopy[yearKey] = yearData
        property.months = monthsCopy
        editingMonth = nil
        onSave()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок таблицы
            HStack(spacing: 0) {
                Text("Месяц")
                    .font(.subheadline) // РАЗМЕР ШРИФТА заголовка
                    .fontWeight(.semibold)
                    .frame(width: 70, alignment: .leading) // ШИРИНА колонки "Месяц"
                    .padding(.leading, 8) // ОТСТУП слева
                
                Spacer()
                
                Text("Доход")
                    .font(.subheadline) // РАЗМЕР ШРИФТА заголовка
                    .fontWeight(.semibold)
                    .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Доход"
                
                Text("Расход")
                    .font(.subheadline) // РАЗМЕР ШРИФТА заголовка
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
                        .font(.subheadline) // РАЗМЕР ШРИФТА месяца
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
                            .font(.subheadline) // РАЗМЕР ШРИФТА в поле редактирования
                        
                        // Расход → прочий расход (expensesOther) - можно редактировать напрямую
                        TextField("Расход", text: $editingExpenseOther)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90) // ШИРИНА поля "Расход"
                            .font(.subheadline) // РАЗМЕР ШРИФТА в поле редактирования
                            .foregroundColor(.red)
                        
                        Button(action: {
                            saveMonthData(monthNum: data.monthNum)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption) // РАЗМЕР иконки кнопки
                        }
                        .frame(width: 28) // ШИРИНА кнопки (галочка)
                        
                        Button(action: {
                            // Загружаем данные для popup
                            let yearKey = String(selectedYear)
                            if let yearData = property.months[yearKey],
                               let monthData = yearData[data.monthNum] {
                                popupIncomeBase = monthData.income ?? 0
                                popupIncomeVariable = monthData.incomeVariable ?? 0
                                popupAdmin = monthData.expensesMaintenance ?? 0
                                popupOperating = monthData.expensesOperational ?? 0
                                popupOther = monthData.expensesOther ?? 0
                            } else {
                                popupIncomeBase = 0
                                popupIncomeVariable = 0
                                popupAdmin = 0
                                popupOperating = 0
                                popupOther = 0
                            }
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
                            .font(.subheadline) // РАЗМЕР ШРИФТА значения дохода
                            .foregroundColor(.green)
                            .frame(width: 90, alignment: .trailing) // ШИРИНА колонки "Доход"
                            .contentShape(Rectangle())
                            .onTapGesture {
                                startEditing(monthNum: data.monthNum, income: data.income, expense: data.expense)
                            }
                        
                        Text(data.expense.formatCurrency())
                            .font(.subheadline) // РАЗМЕР ШРИФТА значения расхода
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
        .overlay(
            Group {
                if showingDetailEditor, let monthNum = editingMonth {
                    MonthEditPopup(
                        isPresented: $showingDetailEditor,
                        incomeBase: $popupIncomeBase,
                        incomeVariable: $popupIncomeVariable,
                        admin: $popupAdmin,
                        operating: $popupOperating,
                        other: $popupOther,
                        monthTitle: monthlyData.first(where: { $0.monthNum == monthNum })?.month ?? "",
                        onSave: {
                            // Сохраняем данные из popup
                            let yearKey = String(selectedYear)
                            var monthsCopy = property.months
                            var yearData = monthsCopy[yearKey] ?? [:]
                            var monthData = yearData[monthNum] ?? Property.MonthData()
                            
                            monthData.income = popupIncomeBase > 0 ? popupIncomeBase : nil
                            monthData.incomeVariable = popupIncomeVariable > 0 ? popupIncomeVariable : nil
                            monthData.expensesMaintenance = popupAdmin > 0 ? popupAdmin : nil
                            monthData.expensesOperational = popupOperating > 0 ? popupOperating : nil
                            monthData.expensesOther = popupOther > 0 ? popupOther : nil
                            
                            yearData[monthNum] = monthData
                            monthsCopy[yearKey] = yearData
                            property.months = monthsCopy
                            editingMonth = nil
                            onSave()
                        }
                    )
                }
            }
        )
    }
}
