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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Графики")
                .font(.headline)
            
            // Мини-график доходов/расходов по месяцам
            MiniChartView(property: property, selectedYear: selectedYear)
        }
    }
}

struct MiniChartView: View {
    let property: Property
    let selectedYear: Int
    
    // Получаем данные по месяцам для выбранного года
    var monthlyData: [(month: String, income: Double, expense: Double)] {
        let monthNames = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        let monthKeys = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        guard let yearData = property.months[String(selectedYear)] else {
            return monthNames.enumerated().map { (monthNames[$0.offset], 0.0, 0.0) }
        }
        
        var result: [(month: String, income: Double, expense: Double)] = []
        
        for (index, monthKey) in monthKeys.enumerated() {
            if let monthData = yearData[monthKey] {
                let income = (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                
                // Расходы: 3 вида
                let expense =
                    (monthData.expensesMaintenance ?? 0) +
                    (monthData.expensesOperational ?? 0) +
                    (monthData.expensesOther ?? 0)
                
                result.append((month: monthNames[index], income: income, expense: expense))
            } else {
                result.append((month: monthNames[index], income: 0.0, expense: 0.0))
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Доходы и расходы за \(String(selectedYear))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<12, id: \.self) { index in
                        let data = monthlyData[index]
                        VStack(spacing: 2) {
                            // Доходы (зеленый) - сверху
                            if data.income > 0 {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: maxValue > 0 ? CGFloat(data.income / maxValue) * geometry.size.height * 0.5 : 0)
                            }
                            
                            // Расходы (красный) - снизу
                            if data.expense > 0 {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(height: maxValue > 0 ? CGFloat(data.expense / maxValue) * geometry.size.height * 0.5 : 0)
                            }
                            
                            // Подпись месяца
                            Text(data.month)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .frame(height: 20)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 180)
            
            // Легенда
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    Text("Доходы")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                    Text("Расходы")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

