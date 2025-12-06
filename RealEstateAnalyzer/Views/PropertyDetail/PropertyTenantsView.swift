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
            if tenants.filter({ !$0.name.isEmpty }).isEmpty {
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
                            Text("$/мес")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 80, alignment: .trailing)
                            Text("Площадь")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 80, alignment: .trailing)
                            Text("% от общей")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 80, alignment: .trailing)
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
                                .frame(width: 80, alignment: .trailing)
                            Text("")
                                .frame(width: 40)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray5))
                        
                        Divider()
                        
                        // Строки арендаторов
                        ForEach(tenants.filter { !$0.name.isEmpty }) { tenant in
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
        .sheet(isPresented: $showingAddTenant) {
            if let tenant = editingTenant {
                TenantEditView(
                    tenant: Binding(
                        get: { tenant },
                        set: { newTenant in
                            editingTenant = newTenant
                        }
                    ),
                    onSave: {
                        if let index = tenants.firstIndex(where: { $0.id == tenant.id }) {
                            tenants[index] = editingTenant ?? tenant
                        } else {
                            tenants.append(editingTenant ?? tenant)
                        }
                        onSave()
                        showingAddTenant = false
                        editingTenant = nil
                    },
                    onCancel: {
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
            
            // $/мес
            Text(formatCurrency(tenant.income ?? 0))
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // Площадь
            Text(tenant.area != nil ? String(format: "%.0f", tenant.area!) : "—")
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
                .onTapGesture {
                    onEdit()
                }
            
            // % от общей
            Text(String(format: "%.1f%%", percentageOfTotal))
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
            
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
                .frame(width: 80, alignment: .trailing)
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
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "$\(formatted)"
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
                        Text("Доход ($/мес):")
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
        tenant.name = editingName
        tenant.income = Double(editingIncome).flatMap { $0 > 0 ? $0 : nil }
        tenant.area = Double(editingArea).flatMap { $0 > 0 ? $0 : nil }
        tenant.startDate = editingStartDate.isEmpty ? nil : editingStartDate
        tenant.endDate = editingEndDate.isEmpty ? nil : editingEndDate
        tenant.indexation = editingIndexation.isEmpty ? nil : editingIndexation
        onSave()
    }
}

