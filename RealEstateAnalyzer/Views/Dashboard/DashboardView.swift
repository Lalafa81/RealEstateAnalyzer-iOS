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
            return sum + financialData.annualIncome
        }
    }
    var totalExpenses: Double {
        properties.reduce(0) { sum, property in
            let financialData = MetricsCalculator.extractMonthlyFinancials(property: property, year: nil)
            return sum + financialData.annualExpense
        }
    }
    var totalProfit: Double { totalIncome - totalExpenses }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatRow(label: "Количество объектов:", value: "\(totalObjects)")
            StatRow(label: "Стоимость портфеля:", value: formatCurrency(totalPortfolioValue))
            StatRow(label: "Общая площадь:", value: String(format: "%.0f м²", totalArea))
            StatRow(label: "Суммарный доход:", value: formatCurrency(totalIncome))
            StatRow(label: "Общие расходы:", value: formatCurrency(totalExpenses))
            StatRow(label: "Чистая прибыль:", value: formatCurrency(totalProfit))
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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
        }
        .font(.system(size: 14))
    }
}

struct PropertyRowView: View {
    let property: Property
    let index: Int
    
    // Маппинг старых иконок на правильные SF Symbols
    private func getIconName(_ icon: String?) -> String {
        guard let icon = icon else { return "house.fill" }
        
        // Маппинг старых названий на правильные SF Symbols
        switch icon.lowercased() {
        case "warehouse":
            return "archivebox.fill"
        case "house":
            return "house.fill"
        case "building", "office":
            return "building.2.fill"
        case "land", "земельный участок":
            return "square.fill"
        default:
            // Если это уже правильная SF Symbol, возвращаем как есть
            return icon
        }
    }
    
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
                    Image(systemName: getIconName(property.icon))
                        .foregroundColor(.purple)
                        .font(.subheadline)
                    Text(property.name)
                        .font(.headline)
                }
                
                Text(property.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Text(property.status)
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
    @State private var type = "Жилая"
    @State private var address = ""
    @State private var area = ""
    @State private var purchasePrice = ""
    @State private var purchaseDate = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $name)
                    TextField("Тип", text: $type)
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
            status: "Сдано",
            source: "",
            tenants: [],
            months: [:],
            propertyTax: nil,
            insuranceCost: nil,
            exitPrice: nil,
            icon: nil
        )
        dataManager.addProperty(newProperty)
        presentationMode.wrappedValue.dismiss()
    }
}

