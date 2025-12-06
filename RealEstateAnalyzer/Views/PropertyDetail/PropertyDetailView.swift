//
//  PropertyDetailView.swift
//  RealEstateAnalyzer
//
//  Детальная страница объекта недвижимости
//

import SwiftUI

struct PropertyDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    let property: Property
    @State private var editableProperty: Property
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var includeAdmin = true
    @State private var includeOther = true
    
    init(property: Property) {
        self.property = property
        _editableProperty = State(initialValue: property)
    }
    
    // Аналитика пересчитывается автоматически при изменении editableProperty
    // Всегда рассчитывается для всего периода (все года)
    var analytics: Analytics {
        let financialData = MetricsCalculator.extractMonthlyFinancials(
            property: editableProperty,
            year: nil,
            includeAdmin: includeAdmin,
            includeOther: includeOther,
            onlySelectedYear: false
        )
        
        return MetricsCalculator.computeAllMetrics(financialData: financialData, property: editableProperty)
    }
    
    private func saveChanges() {
        // Сохраняем изменения в DataManager
        dataManager.updateProperty(editableProperty)
        print("✅ Данные сохранены, аналитика пересчитана")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок с редактируемыми полями
                HeaderView(
                    property: $editableProperty,
                    onSave: saveChanges
                )
                
                // Галерея изображений
                PropertyGalleryView(property: editableProperty)
                
                // Движение денежных средств
                CashFlowView(
                    property: $editableProperty,
                    selectedYear: $selectedYear,
                    onYearChanged: {
                        // При изменении года аналитика автоматически пересчитается
                        // толькоSelectedYear управляется отдельным toggle
                    },
                    onSave: saveChanges
                )
                
                // Аналитика
                AnalyticsView(
                    analytics: analytics,
                    includeAdmin: $includeAdmin,
                    includeOther: $includeOther
                )
                
                // Графики
                ChartsView(property: editableProperty, selectedYear: selectedYear)
                
                // Арендаторы
                TenantsView(
                    tenants: $editableProperty.tenants,
                    propertyArea: editableProperty.area,
                    onSave: saveChanges
                )
                
                // Календарь
                CalendarView(property: property)
            }
            .padding()
        }
        .navigationTitle(editableProperty.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        deleteProperty()
                    }) {
                        Label("Удалить объект", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func deleteProperty() {
        dataManager.deleteProperty(editableProperty)
        // Закрываем экран после удаления
        presentationMode.wrappedValue.dismiss()
    }
}
