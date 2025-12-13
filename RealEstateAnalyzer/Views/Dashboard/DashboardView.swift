//
//  DashboardView.swift
//  RealEstateAnalyzer
//
//  Главный экран со списком объектов
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddProperty = false
    
    var body: some View {
        List {
            // Общая статистика
            Section(header: Text("statistics_title".localized)) {
                StatisticsView(properties: dataManager.properties)
                    .environmentObject(dataManager)
            }
            
            // Календарь на ближайшие дни
            Section(header: Text("calendar_title".localized)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("calendar_development".localized)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                }
            }
            
            // Список объектов
            Section(header: Text("properties_title".localized)) {
                ForEach(Array(dataManager.properties.enumerated()), id: \.element.id) { index, property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        PropertyRowView(property: property, index: index + 1)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .navigationTitle("real_estate_title".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddProperty = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProperty) {
            NewPropertySheet(
                isPresented: $showingAddProperty,
                onCreate: { property in
                    dataManager.addProperty(property)
                }
            )
        }
    }
    
}

struct StatisticsView: View {
    let properties: [Property]
    @EnvironmentObject var dataManager: DataManager
    
    var totalObjects: Int { properties.count }
    var totalPortfolioValue: Double {
        properties.reduce(0) { $0 + $1.purchasePrice }
    }
    var totalArea: Double {
        properties.reduce(0) { $0 + $1.area }
    }
    // Кэшируем вычисленные аналитики для каждого свойства, чтобы не вычислять несколько раз
    private var propertyAnalytics: [(financialData: FinancialData, analytics: Analytics)] {
        properties.map { property in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            let analytics = MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
            return (financialData, analytics)
        }
    }
    
    var totalIncome: Double {
        propertyAnalytics.reduce(0) { $0 + $1.financialData.totalIncome() }
    }
    
    var totalExpenses: Double {
        propertyAnalytics.reduce(0) { $0 + $1.financialData.totalExpenses() }
    }
    
    var totalProfit: Double { totalIncome - totalExpenses }
    
    // Общая функция для вычисления средних значений метрик
    private func averageMetric(_ keyPath: KeyPath<Analytics, Double>) -> Double {
        let values = propertyAnalytics.map { $0.analytics[keyPath: keyPath] }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
    
    var averageROI: Double {
        averageMetric(\.roi)
    }
    
    var averageCapRate: Double {
        averageMetric(\.capRate)
    }
    
    var averageOccupancy: Double {
        averageMetric(\.busyPercent)
    }
    
    var averageHoldingPeriod: Double {
        averageMetric(\.ownYears)
    }
    
    var totalExitValue: Double {
        properties.reduce(0) { $0 + ($1.exitPrice ?? 0) }
    }
    
    var averagePricePerM2: Double {
        guard totalArea > 0 else { return 0 }
        return totalPortfolioValue / totalArea
    }
    
    // Получаем валюту из настроек для статистики
    private var defaultCurrency: String {
        dataManager.settings?.summaryCurrency ?? "RUB"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                StatRow(label: "stat_properties_count".localized, value: "\(totalObjects)")
                StatRow(label: "stat_portfolio_value".localized, value: totalPortfolioValue.formatCurrencyWithSymbol(currencyCode: defaultCurrency))
                StatRow(label: "stat_total_area".localized, value: String(format: "%.0f %@", totalArea.formatArea(), Double.getAreaUnitName()))
                StatRow(label: "stat_total_income".localized, value: totalIncome.formatCurrencyWithSymbol(currencyCode: defaultCurrency))
                StatRow(label: "stat_total_expenses".localized, value: totalExpenses.formatCurrencyWithSymbol(currencyCode: defaultCurrency))
                StatRow(label: "stat_net_profit".localized, value: totalProfit.formatCurrencyWithSymbol(currencyCode: defaultCurrency))
                StatRow(label: "stat_average_roi".localized, value: String(format: "%.2f%%", averageROI))
                StatRow(label: "stat_average_cap_rate".localized, value: String(format: "%.2f%%", averageCapRate))
                StatRow(label: "stat_average_occupancy".localized, value: String(format: "%.1f%%", averageOccupancy))
                StatRow(label: "stat_average_holding_period".localized, value: String(format: "%.1f %@", averageHoldingPeriod, "unit_years".localized))
            }
            Group {
                StatRow(label: "stat_exit_value".localized, value: totalExitValue > 0 ? totalExitValue.formatCurrencyWithSymbol(currencyCode: defaultCurrency) : "empty".localized)
                StatRow(label: "stat_average_price_per_m2".localized, value: averagePricePerM2.formatCurrencyWithSymbol(currencyCode: defaultCurrency) + " / " + Double.getAreaUnitName())
            }
        }
        .padding(.vertical, 4)
    }
}


struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .font(.system(size: 14))
    }
}

struct PropertyRowView: View {
    let property: Property
    let index: Int
    @EnvironmentObject var dataManager: DataManager
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(spacing: 8) {
            // Название с иконкой по левому краю сверху
            HStack(spacing: 6) {
                Text(property.name)
                    .font(.headline)
                
                // Значок листика, если есть заметки
                if let notes = property.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            
            // Основной контент
            HStack(alignment: .top, spacing: 12) {
                // Номер объекта
                Text("\(index)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Миниатюра изображения или плейсхолдер - фиксированная ширина
                PropertyImagePlaceholder(propertyId: property.id) {
                    // При нажатии открываем ImagePicker
                    showingImagePicker = true
                }
                .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Компактный pill-style статус
                    Text(property.status.localizedName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(statusTextColor(for: property.status))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusBackgroundColor(for: property.status))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Доход, ROI и площадь справа в три строки
                VStack(alignment: .trailing, spacing: 2) {
                    if let analytics = calculateQuickMetrics() {
                        // Доход: желтый если 0, иначе синий
                        let incomeColor: Color = analytics.monthlyIncome == 0 ? .yellow : .blue
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(incomeColor)
                            Text(analytics.monthlyIncome.formatShortCurrencyWithPrefix(currencyCode: property.getCurrencyCode()))
                                .font(.subheadline)
                                .foregroundColor(incomeColor)
                        }
                        
                        // ROI: красный если отрицательный, иначе зеленый
                        let roiColor: Color = analytics.roi < 0 ? .red : .green
                        let roiValue: String = {
                            let roi = analytics.roi
                            if roi > 1000 {
                                return ">1000"
                            } else if roi < -1000 {
                                return "<-1000"
                            } else {
                                return String(format: "%.1f", roi)
                            }
                        }()
                        Text("ROI: \(roiValue)%")
                            .font(.subheadline)
                            .foregroundColor(roiColor)
                    }
                    
                    // Площадь
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(property.area.formatArea()) \(Double.getAreaUnitName())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                sourceType: sourceType,
                onImagePicked: { image in
                    // Сохраняем как cover image (основное фото объекта), а не в галерею
                    let success = dataManager.setPropertyCoverImage(propertyId: property.id, image: image)
                    if success {
                        // Принудительно обновляем UI после успешного добавления
                        dataManager.refreshImages()
                    }
                }
            )
        }
    }
    
    private func calculateQuickMetrics() -> Analytics? {
        let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
        return MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
    }
    
    // Цвета для статуса (объединены в одну структуру для избежания дублирования switch)
    private struct StatusColors {
        let text: Color
        let background: Color
        
        static func forStatus(_ status: PropertyStatus) -> StatusColors {
            switch status {
            case .rented:
                return StatusColors(text: .green, background: .green.opacity(0.15))
            case .vacant:
                return StatusColors(text: .secondary, background: Color(.systemGray5))
            case .underRepair:
                return StatusColors(text: .orange, background: .orange.opacity(0.15))
            case .sold:
                return StatusColors(text: .secondary, background: Color(.systemGray5))
            }
        }
    }
    
    private func statusTextColor(for status: PropertyStatus) -> Color {
        StatusColors.forStatus(status).text
    }
    
    private func statusBackgroundColor(for status: PropertyStatus) -> Color {
        StatusColors.forStatus(status).background
    }
}


