//
//  PropertyChartsView.swift
//  RealEstateAnalyzer
//
//  Графики объекта недвижимости
//

import SwiftUI

struct ChartsView: View {
    let property: Property
    let selectedYear: Int
    
    @State private var showFullChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок с кнопкой развернуть
            HStack {
                Text("charts_income_expenses_for".localized(selectedYear))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showFullChart = true
                }) {
                    HStack(spacing: 4) {
                        Text("charts_expand".localized)
                            .font(.caption)
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .opacity(0.7)
                }
            }
            .padding(.horizontal, 4)
            
            // Мини-график доходов/расходов по месяцам
            MiniChartView(property: property, selectedYear: selectedYear, showFullChart: $showFullChart)
        }
        .padding(6)
        .sheet(isPresented: $showFullChart) {
            FullScreenChartPlaceholder()
        }
    }
}

struct MiniChartView: View {
    let property: Property
    let selectedYear: Int
    @Binding var showFullChart: Bool
    
    @State private var selectedMonth: Int? = nil
    
    // Получаем данные по месяцам для выбранного года
    var monthlyData: [(month: String, monthIndex: Int, income: Double, expense: Double)] {
        let monthNames = DateFormatter.localizedShortMonthNames()
        let monthKeys = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        guard let yearData = property.months[String(selectedYear)] else {
            return monthNames.enumerated().map { (monthNames[$0.offset], $0.offset, 0.0, 0.0) }
        }
        
        var result: [(month: String, monthIndex: Int, income: Double, expense: Double)] = []
        
        for (index, monthKey) in monthKeys.enumerated() {
            if let monthData = yearData[monthKey] {
                let income = (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                
                // Расходы: 3 вида
                let expense =
                    (monthData.expensesMaintenance ?? 0) +
                    (monthData.expensesOperational ?? 0) +
                    (monthData.expensesOther ?? 0)
                
                result.append((month: monthNames[index], monthIndex: index, income: income, expense: expense))
            } else {
                result.append((month: monthNames[index], monthIndex: index, income: 0.0, expense: 0.0))
            }
        }
        
        return result
    }
    
    var maxValue: Double {
        let maxIncome = monthlyData.map { $0.income }.max() ?? 0
        let maxExpense = monthlyData.map { $0.expense }.max() ?? 0
        return max(maxIncome, maxExpense)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<12, id: \.self) { index in
                        let data = monthlyData[index]
                        let isSelected = selectedMonth == index
                        
                        VStack(spacing: 0) {
                            // Доходы (зеленый) - сверху
                            if data.income > 0 {
                                Rectangle()
                                    .fill(isSelected ? Color.green.opacity(0.8) : Color.green)
                                    .frame(height: maxValue > 0 ? CGFloat(data.income / maxValue) * geometry.size.height * 0.75 : 0)
                            }
                            
                            // Расходы (красный) - снизу
                            if data.expense > 0 {
                                Rectangle()
                                    .fill(isSelected ? Color.red.opacity(0.8) : Color.red)
                                    .frame(height: maxValue > 0 ? CGFloat(data.expense / maxValue) * geometry.size.height * 0.75 : 0)
                            }
                            
                            // Подпись месяца
                            Text(data.month)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(height: 12)
                                .padding(.top, 1)
                        }
                        .frame(maxWidth: .infinity)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
                        .onTapGesture {
                            if selectedMonth == index {
                                selectedMonth = nil
                            } else {
                                selectedMonth = index
                            }
                        }
                    }
                }
            }
            .frame(height: 198)
            
            // Строка информации о выбранном месяце
            if let selectedIndex = selectedMonth, selectedIndex < monthlyData.count {
                let data = monthlyData[selectedIndex]
                let netCashFlow = data.income - data.expense
                Text("\(String(format: "cash_flow_income_label".localized)): \(data.income.formatCurrencyWithSymbol(currencyCode: property.getCurrencyCode())) · \(String(format: "cash_flow_expenses_label".localized)): \(data.expense.formatCurrencyWithSymbol(currencyCode: property.getCurrencyCode())) · \(String(format: "cash_flow_net_label".localized)): \(netCashFlow.formatCurrencyWithSymbol(currencyCode: property.getCurrencyCode()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
            
            // Легенда
            HStack(spacing: 14) {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    Text("cash_flow_income_legend".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                    Text("cash_flow_expenses_legend".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

