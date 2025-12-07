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
            AddPropertyView()
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(label: "Количество объектов", value: "\(totalObjects)", formula: "Общее количество объектов в портфеле")
            StatCard(label: "Стоимость портфеля", value: totalPortfolioValue.formatCurrency(), formula: "Сумма всех цен покупки объектов")
            StatCard(label: "Общая площадь", value: String(format: "%.0f м²", totalArea), formula: "Сумма площадей всех объектов")
            StatCard(label: "Суммарный доход", value: totalIncome.formatCurrency(), formula: "Сумма всех доходов по всем объектам за весь период")
            StatCard(label: "Общие расходы", value: totalExpenses.formatCurrency(), formula: "Сумма всех расходов по всем объектам за весь период")
            StatCard(label: "Чистая прибыль", value: totalProfit.formatCurrency(), formula: "Чистая прибыль = Суммарный доход - Общие расходы")
            StatCard(label: "Средний ROI", value: String(format: "%.2f%%", averageROI), formula: "ROI = ((Средний доход - Средний расход) × 12 / Цена покупки) × 100%")
            StatCard(label: "Средний Cap Rate", value: String(format: "%.2f%%", averageCapRate), formula: "Cap Rate = (NOI / Цена покупки) × 100%\n\nNOI = Годовой доход - Годовой расход - Налоги - Страхование")
            StatCard(label: "Средняя загруженность", value: String(format: "%.1f%%", averageOccupancy), formula: "Загруженность = (Месяцы с доходом > 0 / Общее количество месяцев) × 100%")
            StatCard(label: "Средний срок владения", value: String(format: "%.1f лет", averageHoldingPeriod), formula: "Срок владения = (Текущая дата - Дата покупки) / 365")
            StatCard(label: "Стоимость выхода", value: totalExitValue > 0 ? totalExitValue.formatCurrency() : "—", formula: "Сумма всех цен продажи (exitPrice) объектов.\n\nЦена продажи — это планируемая или фактическая стоимость объекта при продаже.")
            StatCard(label: "Средняя цена за м²", value: String(format: "%.0f", averagePricePerM2), formula: "Средняя цена за м² = Стоимость портфеля / Общая площадь")
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let formula: String
    
    @State private var showingFormula = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
                Button(action: {
                    showingFormula = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .alert(isPresented: $showingFormula) {
            Alert(
                title: Text("Формула расчета"),
                message: Text(formula),
                dismissButton: .default(Text("Понятно"))
            )
        }
    }
}

struct PropertyRowView: View {
    let property: Property
    let index: Int
    
    
    var body: some View {
        HStack {
            // Номер объекта
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                // Название с иконкой
                HStack(spacing: 6) {
                    Image(systemName: property.type.iconName)
                        .foregroundColor(.purple)
                        .font(.subheadline)
                    Text(property.name)
                        .font(.headline)
                }
                
                Text(property.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Text(property.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if let analytics = calculateQuickMetrics() {
                        Text("ROI: \(String(format: "%.1f", analytics.roi))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func calculateQuickMetrics() -> Analytics? {
        let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
        return MetricsCalculator.computeAllMetrics(financialData: financialData, property: property)
    }
}

struct AddPropertyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var type: PropertyType = .residential
    @State private var address = ""
    @State private var area = ""
    @State private var purchasePrice = ""
    @State private var purchaseDate = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $name)
                    Picker("Назначение", selection: $type) {
                        ForEach(PropertyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Адрес", text: $address)
                    TextField("Площадь (м²)", text: $area)
                        .keyboardType(.decimalPad)
                    TextField("Цена покупки", text: $purchasePrice)
                        .keyboardType(.decimalPad)
                    TextField("Дата покупки (дд.мм.гггг)", text: $purchaseDate)
                }
            }
            .navigationTitle("Новый объект")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveProperty()
                    }
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
        }
    }
    
    private func saveProperty() {
        let newProperty = Property(
            id: "", // ID будет сгенерирован автоматически в addProperty
            name: name,
            type: type,
            address: address,
            area: Double(area) ?? 0,
            purchasePrice: Double(purchasePrice) ?? 0,
            purchaseDate: purchaseDate,
            status: .rented,
            source: "",
            tenants: [],
            months: [:],
            propertyTax: nil,
            insuranceCost: nil,
            exitPrice: nil,
            condition: nil,
            icon: nil,
            image: nil,
            gallery: nil
        )
        dataManager.addProperty(newProperty)
        presentationMode.wrappedValue.dismiss()
    }
}

