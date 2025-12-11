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
    @State private var isAnalyticsExpanded = false
    @State private var isTenantsExpanded = false
    @State private var isCashFlowExpanded = false
    @State private var isChartsExpanded = false
    @State private var isHeaderExpanded = false
    @State private var isGalleryExpanded = false
    @State private var showDeletePropertyConfirmation = false
    
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
                
                // Хедер объекта (сворачиваемая секция)
                CollapsibleSection(
                    title: "Объект",
                    icon: editableProperty.type.iconName,
                    isExpanded: $isHeaderExpanded,
                    collapsedContent: {
                        AnyView(
                            HStack(spacing: 4) {
                                Text(editableProperty.status.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                                Text("\(String(format: "%.0f", editableProperty.area)) м²")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                    }
                ) {
                    HeaderView(
                        property: $editableProperty,
                        onSave: saveChanges
                    )
                }
                
                // Арендаторы (раскрывающаяся вкладка)
                VStack(alignment: .leading, spacing: 0) {
                    DisclosureGroup(isExpanded: $isTenantsExpanded) {
                        TenantsView(
                            tenants: $editableProperty.tenants,
                            propertyArea: editableProperty.area,
                            onSave: saveChanges
                        )
                    } label: {
                        HStack {
                            Image(systemName: "person.2")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("Арендаторы")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Выбор года (глобальный селектор)
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(.black)
                        Text("Выбор года")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    YearSelectorView(
                        selectedYear: $selectedYear,
                        property: $editableProperty,
                        onSave: saveChanges
                    )
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Движение денежных средств (раскрывающаяся вкладка)
                VStack(alignment: .leading, spacing: 0) {
                    DisclosureGroup(isExpanded: $isCashFlowExpanded) {
                        CashFlowView(
                            property: $editableProperty,
                            selectedYear: $selectedYear,
                            onSave: saveChanges
                        )
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("Движение денежных средств")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Графики (раскрывающаяся вкладка)
                VStack(alignment: .leading, spacing: 0) {
                    DisclosureGroup(isExpanded: $isChartsExpanded) {
                        ChartsView(property: editableProperty, selectedYear: selectedYear)
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("Графики")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Аналитика (раскрывающаяся вкладка)
                VStack(alignment: .leading, spacing: 0) {
                    DisclosureGroup(isExpanded: $isAnalyticsExpanded) {
                        AnalyticsView(
                            analytics: analytics,
                            onlySelectedYear: $onlySelectedYear,
                            includeMaintenance: $includeMaintenance,
                            includeOperating: $includeOperating
                        )
                    } label: {
                        HStack {
                            Image(systemName: "chart.pie")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("Аналитика")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Галерея изображений (сворачиваемая секция)
                CollapsibleSection(
                    title: "Галерея",
                    icon: "photo.on.rectangle",
                    isExpanded: $isGalleryExpanded,
                    collapsedContent: {
                        AnyView(
                            Text(dataManager.getPropertyGallery(propertyId: editableProperty.id).isEmpty ? "Нет изображений" : "\(dataManager.getPropertyGallery(propertyId: editableProperty.id).count) фото")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        )
                    }
                ) {
                    PropertyGalleryView(
                        property: $editableProperty,
                        onSave: saveChanges
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDeletePropertyConfirmation) {
            DeletePropertySheetView(
                propertyName: editableProperty.name,
                isPresented: $showDeletePropertyConfirmation,
                onDelete: {
                    deleteProperty()
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showDeletePropertyConfirmation = true
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
