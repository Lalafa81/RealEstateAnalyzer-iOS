//
//  PropertyTenantsView.swift
//  RealEstateAnalyzer
//
//  Арендаторы объекта недвижимости
//

import SwiftUI

struct TenantsView: View {
    @Binding var tenants: [Tenant]
    let propertyArea: Double
    let onSave: () -> Void
    
    @State private var showingAddTenant = false
    @State private var editingTenant: Tenant?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с кнопкой добавления
            HStack {
                Text("АРЕНДАТОРЫ")
                    .font(.headline)
                Spacer()
                Button(action: {
                    editingTenant = Tenant(name: "", income: nil, startDate: nil, endDate: nil, area: nil, indexation: nil)
                    showingAddTenant = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Добавить арендатора")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // Таблица арендаторов
            if tenants.isEmpty {
                Text("Нет арендаторов")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Заголовок таблицы
                        HStack(spacing: 12) {
                            Text("Компания")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 150, alignment: .leading)
                            Text("Доход")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 100, alignment: .trailing)
                            Text("Площадь")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 90, alignment: .trailing)
                            Text("% от общей")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 90, alignment: .trailing)
                            Text("Начало")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 100, alignment: .leading)
                            Text("Конец")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 100, alignment: .leading)
                            Text("Индексация")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 90, alignment: .trailing)
                            Text("")
                                .frame(width: 40)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray5))
                        
                        Divider()
                        
                        // Строки арендаторов (временно без фильтра для отладки)
                        ForEach(tenants) { tenant in
                            TenantRowView(
                                tenant: Binding(
                                    get: { tenant },
                                    set: { newTenant in
                                        if let index = tenants.firstIndex(where: { $0.id == newTenant.id }) {
                                            tenants[index] = newTenant
                                            onSave()
                                        }
                                    }
                                ),
                                propertyArea: propertyArea,
                                onDelete: {
                                    tenants.removeAll { $0.id == tenant.id }
                                    onSave()
                                },
                                onEdit: {
                                    editingTenant = tenant
                                    showingAddTenant = true
                                }
                            )
                            
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddTenant) {
            if editingTenant != nil {
                TenantEditView(
                    tenant: Binding(
                        get: { editingTenant! },
                        set: { editingTenant = $0 }
                    ),
                    onSave: {
                        guard let updatedTenant = editingTenant else {
                            print("❌ editingTenant is nil in onSave")
                            return
                        }
                        
                        print("💾 Сохранение арендатора:")
                        print("   ID: \(updatedTenant.id)")
                        print("   Имя: \(updatedTenant.name)")
                        print("   Доход: \(updatedTenant.income ?? 0)")
                        print("   Количество арендаторов ДО: \(tenants.count)")
                        
                        if let index = tenants.firstIndex(where: { $0.id == updatedTenant.id }) {
                            // Обновляем существующего арендатора
                            print("   ✅ Обновление существующего арендатора по индексу: \(index)")
                            tenants[index] = updatedTenant
                        } else {
                            // Добавляем нового арендатора
                            print("   ✅ Добавление нового арендатора")
                            tenants.append(updatedTenant)
                        }
                        
                        print("   Количество арендаторов ПОСЛЕ: \(tenants.count)")
                        
                        onSave()
                        showingAddTenant = false
                        editingTenant = nil
                    },
                    onCancel: {
                        print("❌ Отмена редактирования арендатора")
                        showingAddTenant = false
                        editingTenant = nil
                    }
                )
            }
        }
    }
}

struct TenantRowView: View {
    @Binding var tenant: Tenant
    let propertyArea: Double
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var isEditing = false
    
    var percentageOfTotal: Double {
        guard let area = tenant.area, propertyArea > 0 else { return 0 }
        return (area / propertyArea) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Компания
            Text(tenant.name.isEmpty ? "—" : tenant.name)
                .font(.subheadline)
                .frame(width: 150, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Доход
            Text((tenant.income ?? 0).formatCurrency())
                .font(.subheadline)
                .foregroundColor(.green)
                .frame(width: 100, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Площадь
            Text(tenant.area != nil ? String(format: "%.0f м²", tenant.area!) : "—")
                .font(.subheadline)
                .frame(width: 90, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // % от общей
            Text(String(format: "%.1f%%", percentageOfTotal))
                .font(.subheadline)
                .frame(width: 90, alignment: .trailing)
            
            // Начало
            Text(tenant.startDate ?? "—")
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Конец
            Text(tenant.endDate ?? "—")
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    onEdit()
                }
            
            // Индексация
            Text(tenant.indexation ?? "—")
                .font(.subheadline)
                .frame(width: 90, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Кнопка удаления
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .frame(width: 40)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

struct TenantEditView: View {
    @Binding var tenant: Tenant
    let onSave: () -> Void
    let onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editingName: String = ""
    @State private var editingIncome: String = ""
    @State private var editingArea: String = ""
    @State private var editingStartDate: String = ""
    @State private var editingEndDate: String = ""
    @State private var editingIndexation: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация об арендаторе")) {
                    TextField("Название компании", text: $editingName)
                    
                    HStack {
                        Text("Доход (₽/мес):")
                        Spacer()
                        TextField("0", text: $editingIncome)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Площадь (м²):")
                        Spacer()
                        TextField("0", text: $editingArea)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Начало (дд.мм.гггг):")
                        Spacer()
                        TextField("01.01.2023", text: $editingStartDate)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Конец (дд.мм.гггг):")
                        Spacer()
                        TextField("01.01.2024", text: $editingEndDate)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Индексация:")
                        Spacer()
                        TextField("5%", text: $editingIndexation)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 150)
                    }
                }
            }
            .navigationTitle("Редактирование арендатора")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(editingName.isEmpty)
                }
            }
            .onAppear {
                loadCurrentValues()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadCurrentValues() {
        editingName = tenant.name
        editingIncome = tenant.income != nil ? String(format: "%.0f", tenant.income!) : ""
        editingArea = tenant.area != nil ? String(format: "%.0f", tenant.area!) : ""
        editingStartDate = tenant.startDate ?? ""
        editingEndDate = tenant.endDate ?? ""
        editingIndexation = tenant.indexation ?? ""
    }
    
    private func saveChanges() {
        // Обновляем tenant через binding
        tenant.name = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Парсим доход с удалением пробелов
        let incomeString = editingIncome.replacingOccurrences(of: " ", with: "")
        if let incomeValue = Double(incomeString), incomeValue > 0 {
            tenant.income = incomeValue
        } else {
            tenant.income = nil
        }
        
        // Парсим площадь с удалением пробелов
        let areaString = editingArea.replacingOccurrences(of: " ", with: "")
        if let areaValue = Double(areaString), areaValue > 0 {
            tenant.area = areaValue
        } else {
            tenant.area = nil
        }
        
        // Валидация и форматирование дат
        let trimmedStartDate = editingStartDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEndDate = editingEndDate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        tenant.startDate = trimmedStartDate.isEmpty ? nil : trimmedStartDate
        tenant.endDate = trimmedEndDate.isEmpty ? nil : trimmedEndDate
        
        // Индексация
        let trimmedIndexation = editingIndexation.trimmingCharacters(in: .whitespacesAndNewlines)
        tenant.indexation = trimmedIndexation.isEmpty ? nil : trimmedIndexation
        
        // Вызываем onSave, который добавит/обновит арендатора в массиве
        onSave()
    }
}

