//
//  NewPropertySheet.swift
//  RealEstateAnalyzer
//
//  Bottom Sheet для создания нового объекта недвижимости в стиле iOS
//

import SwiftUI
import UIKit

// MARK: - New Property Sheet (iOS 16+ Bottom Sheet Style)

struct NewPropertySheet: View {
    @Binding var isPresented: Bool
    let onCreate: (Property) -> Void
    
    @State private var name = ""
    @State private var address = ""
    @State private var area = ""
    @State private var purchaseDate = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Верхняя часть с иконкой и заголовком
                    VStack(spacing: 8) {
                        // Иконка
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        
                        // Заголовок
                        Text("new_property_title".localized)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Подзаголовок
                        Text("new_property_subtitle".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    
                    // Секция "Основное"
                    VStack(alignment: .leading, spacing: 0) {
                        Section(header: Text("Основное")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)) {
                            
                            VStack(spacing: 0) {
                                // Название
                                sheetField("field_name".localized, text: $name, placeholder: "")
                                
                                Divider()
                                    .padding(.leading, 20)
                                
                                // Адрес
                                sheetField("field_address".localized, text: $address, placeholder: "")
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    // Секция "Параметры"
                    VStack(alignment: .leading, spacing: 0) {
                        Section(header: Text("Параметры")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)) {
                            
                            VStack(spacing: 0) {
                                // Площадь
                                sheetField("new_property_area_placeholder".localized, text: $area, placeholder: "0", keyboardType: .decimalPad)
                                
                                Divider()
                                    .padding(.leading, 20)
                                
                                // Дата покупки
                                sheetDateField("field_purchase_date".localized, date: $purchaseDate)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    // Кнопка создания (с отступом от низа)
                    Button(action: {
                        createProperty()
                    }) {
                        Text("new_property_create".localized)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(name.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("cancel".localized) {
                        isPresented = false
                    }
                }
            }
        }
        .modifier(BottomSheetModifier())
    }
    
    // Вспомогательная функция для создания поля с линией снизу
    private func sheetField(_ label: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(width: 120, alignment: .leading)
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            
            // Линия снизу
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .padding(.leading, 20)
        }
    }
    
    // Поле для DatePicker
    private func sheetDateField(_ label: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(width: 120, alignment: .leading)
                
                DatePicker("", selection: date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
    }
    
    private func createProperty() {
        // Используем валюту из настроек по умолчанию
        let defaultCurrency = DataManager.shared.settings?.summaryCurrency ?? "RUB"
        
        let newProperty = Property(
            id: "", // Пустой ID - DataManager сам сгенерирует правильный формат "001", "002" и т.д.
            name: name,
            type: .residential, // Дефолтное значение, можно изменить в деталях
            customType: nil,
            address: address,
            area: Double(area) ?? 0,
            purchasePrice: 0, // Можно настроить позже
            purchaseDate: dateFormatter.string(from: purchaseDate),
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
            gallery: nil,
            currency: defaultCurrency
        )
        onCreate(newProperty)
        isPresented = false
    }
}

// MARK: - Bottom Sheet Modifier для iOS 16+
struct BottomSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.height(420), .medium])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

