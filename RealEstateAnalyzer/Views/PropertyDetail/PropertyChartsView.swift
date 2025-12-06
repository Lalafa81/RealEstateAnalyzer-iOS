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
            
            // Мини-график доходов/расходов
            MiniChartView(property: property, selectedYear: selectedYear)
        }
    }
}

struct MiniChartView: View {
    let property: Property
    let selectedYear: Int
    
    var body: some View {
        // Всегда показываем данные только за выбранный год
        let financialData = MetricsCalculator.extractMonthlyFinancials(
            property: property,
            year: selectedYear,
            includeAdmin: true,
            includeOther: true,
            onlySelectedYear: true
        )
        let maxValue = max(financialData.incomes.max() ?? 0, financialData.expenses.max() ?? 0)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Доходы и расходы за \(selectedYear)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<min(12, financialData.incomes.count), id: \.self) { index in
                        VStack(spacing: 2) {
                            // Доходы (зеленый)
                            if index < financialData.incomes.count {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: maxValue > 0 ? CGFloat(financialData.incomes[index] / maxValue) * geometry.size.height : 0)
                            }
                            
                            // Расходы (красный)
                            if index < financialData.expenses.count {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(height: maxValue > 0 ? CGFloat(financialData.expenses[index] / maxValue) * geometry.size.height : 0)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

