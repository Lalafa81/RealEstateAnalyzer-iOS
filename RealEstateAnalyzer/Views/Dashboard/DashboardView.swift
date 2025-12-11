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
            Section(header: Text("Общая статистика")) {
                StatisticsView(properties: dataManager.properties)
            }
            
            // Календарь (в разработке)
            Section(header: Text("Календарь")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Календарь событий находится в разработке")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                }
            }
            
            // Список объектов
            Section(header: Text("Объекты недвижимости")) {
                ForEach(Array(dataManager.properties.enumerated()), id: \.element.id) { index, property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        PropertyRowView(property: property, index: index + 1)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .navigationTitle("Недвижимость")
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
    
    var totalObjects: Int { properties.count }
    var totalPortfolioValue: Double {
        properties.reduce(0) { $0 + $1.purchasePrice }
    }
    var totalArea: Double {
        properties.reduce(0) { $0 + $1.area }
    }
    var totalIncome: Double {
        properties.reduce(0) { sum, property in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            return sum + financialData.totalIncome()
        }
    }
    var totalExpenses: Double {
        properties.reduce(0) { sum, property in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            return sum + financialData.totalExpenses()
        }
    }
    var totalProfit: Double { totalIncome - totalExpenses }
    
    // Средние показатели
    var averageROI: Double {
        let rois = properties.compactMap { property -> Double? in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            let analytics = MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
            return analytics.roi
        }
        guard !rois.isEmpty else { return 0 }
        return rois.reduce(0, +) / Double(rois.count)
    }
    
    var averageCapRate: Double {
        let capRates = properties.compactMap { property -> Double? in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            let analytics = MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
            return analytics.capRate
        }
        guard !capRates.isEmpty else { return 0 }
        return capRates.reduce(0, +) / Double(capRates.count)
    }
    
    var averageOccupancy: Double {
        let occupancies = properties.compactMap { property -> Double? in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            let analytics = MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
            return analytics.busyPercent
        }
        guard !occupancies.isEmpty else { return 0 }
        return occupancies.reduce(0, +) / Double(occupancies.count)
    }
    
    var averageHoldingPeriod: Double {
        let periods = properties.compactMap { property -> Double? in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            let analytics = MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
            return analytics.ownYears
        }
        guard !periods.isEmpty else { return 0 }
        return periods.reduce(0, +) / Double(periods.count)
    }
    
    var totalExitValue: Double {
        properties.reduce(0) { $0 + ($1.exitPrice ?? 0) }
    }
    
    var averagePricePerM2: Double {
        guard totalArea > 0 else { return 0 }
        return totalPortfolioValue / totalArea
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                StatRow(label: "Количество объектов", value: "\(totalObjects)")
                StatRow(label: "Стоимость портфеля", value: totalPortfolioValue.formatCurrency())
                StatRow(label: "Общая площадь", value: String(format: "%.0f м²", totalArea))
                StatRow(label: "Суммарный доход", value: totalIncome.formatCurrency())
                StatRow(label: "Общие расходы", value: totalExpenses.formatCurrency())
                StatRow(label: "Чистая прибыль", value: totalProfit.formatCurrency())
                StatRow(label: "Средний ROI", value: String(format: "%.2f%%", averageROI))
                StatRow(label: "Средний Cap Rate", value: String(format: "%.2f%%", averageCapRate))
                StatRow(label: "Средняя загруженность", value: String(format: "%.1f%%", averageOccupancy))
                StatRow(label: "Средний срок владения", value: String(format: "%.1f лет", averageHoldingPeriod))
            }
            Group {
                StatRow(label: "Стоимость выхода", value: totalExitValue > 0 ? totalExitValue.formatCurrency() : "—")
                StatRow(label: "Средняя цена за м²", value: String(format: "%.0f", averagePricePerM2))
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
                Image(systemName: property.type.iconName)
                    .foregroundColor(.purple)
                    .font(.subheadline)
                    .frame(width: 16)
                Text(property.name)
                    .font(.headline)
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
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Компактный pill-style статус
                    Text(property.status.rawValue)
                        .font(.system(size: 11, weight: .medium))
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
                        Text("Д: \(analytics.monthlyIncome.formatShortCurrency())")
                            .font(.caption)
                            .foregroundColor(incomeColor)
                        
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
                            .font(.caption)
                            .foregroundColor(roiColor)
                    }
                    
                    // Площадь
                    Text("П: \(String(format: "%.0f", property.area)) м²")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
    
    // Цвет текста для статуса
    private func statusTextColor(for status: PropertyStatus) -> Color {
        switch status {
        case .rented:
            return Color.green
        case .vacant:
            return Color.secondary
        case .underRepair:
            return Color.orange
        case .sold:
            return Color.secondary
        }
    }
    
    // Цвет фона для статуса
    private func statusBackgroundColor(for status: PropertyStatus) -> Color {
        switch status {
        case .rented:
            return Color.green.opacity(0.15)
        case .vacant:
            return Color(.systemGray5)
        case .underRepair:
            return Color.orange.opacity(0.15)
        case .sold:
            return Color(.systemGray5)
        }
    }
}


