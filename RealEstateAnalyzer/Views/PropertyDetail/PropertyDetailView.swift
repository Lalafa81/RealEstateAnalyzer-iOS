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
    @State private var onlySelectedYear = false
    @State private var includeMaintenance = true
    @State private var includeOperating = true
    
    init(property: Property) {
        self.property = property
        _editableProperty = State(initialValue: property)
    }
    
    // Аналитика пересчитывается автоматически при изменении editableProperty
    // Может рассчитываться для всего периода или только для выбранного года
    var analytics: Analytics {
        let financialData = MetricsCalculator.extractMonthlyFinancials(
            property: editableProperty,
            year: onlySelectedYear ? selectedYear : nil
        )
        
        return MetricsCalculator.computeAllMetrics(
            financialData: financialData,
            property: editableProperty,
            includeMaintenance: includeMaintenance,
            includeOperating: includeOperating
        )
    }
    
    private func saveChanges() {
        // Сохраняем изменения в DataManager
        dataManager.updateProperty(editableProperty)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // ID объекта - серым текстом на границе окна
                Text("ID: \(editableProperty.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                
                // Заголовок с inline редактированием полей
                HeaderView(
                    property: $editableProperty,
                    onSave: saveChanges
                )
                
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
                
                // Арендаторы
                TenantsView(
                    tenants: $editableProperty.tenants,
                    propertyArea: editableProperty.area,
                    onSave: saveChanges
                )
                
                // Аналитика
                AnalyticsView(
                    analytics: analytics,
                    onlySelectedYear: $onlySelectedYear,
                    includeMaintenance: $includeMaintenance,
                    includeOperating: $includeOperating
                )
                
                // Графики
                ChartsView(property: editableProperty, selectedYear: selectedYear)
                
                // Галерея изображений (в самом низу)
                PropertyGalleryView(
                    property: $editableProperty,
                    onSave: saveChanges
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
        }
        .navigationBarTitleDisplayMode(.inline)
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
