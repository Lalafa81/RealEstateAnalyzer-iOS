//
//  YearSelectorView.swift
//  RealEstateAnalyzer
//
//  Компонент для выбора года (глобальный селектор для всех финансовых блоков)
//

import SwiftUI

struct YearSelectorView: View {
    @Binding var selectedYear: Int
    @Binding var property: Property
    let onSave: () -> Void
    
    @State private var yearToDelete: Int? = nil
    @State private var showDeleteYearSheet = false
    
    var availableYears: [Int] {
        // Получаем года из property.months
        let years = property.months.keys.compactMap { Int($0) }.sorted()
        
        // Если годов нет, возвращаем текущий год
        if years.isEmpty {
            return [Calendar.current.component(.year, from: Date())]
        }
        
        return years
    }
    
    var minYear: Int {
        availableYears.first ?? Calendar.current.component(.year, from: Date())
    }
    
    var maxYear: Int {
        availableYears.last ?? Calendar.current.component(.year, from: Date())
    }
    
    private func addYear(_ year: Int) {
        // Создаём пустую запись для нового года
        var monthsCopy = property.months
        monthsCopy[String(year)] = [:]
        
        var updatedProperty = property
        updatedProperty.months = monthsCopy
        property = updatedProperty
        
        selectedYear = year
        onSave()
    }
    
    private func deleteYear(_ year: Int) {
        // Удаляем год из property.months
        var monthsCopy = property.months
        monthsCopy.removeValue(forKey: String(year))
        
        var updatedProperty = property
        updatedProperty.months = monthsCopy
        property = updatedProperty
        
        // Если удалили выбранный год, выбираем первый доступный
        let remainingYears = monthsCopy.keys.compactMap { Int($0) }.sorted()
        if let first = remainingYears.first {
            selectedYear = first
        }
        
        onSave()
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Стрелка влево
                Button(action: {
                    if let currentIndex = availableYears.firstIndex(of: selectedYear),
                       currentIndex > 0 {
                        selectedYear = availableYears[currentIndex - 1]
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
                .disabled(availableYears.firstIndex(of: selectedYear) == 0)
                
                // Года с прокруткой
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Кнопка добавления года слева
                            Button(action: {
                                addYear(minYear - 1)
                                withAnimation {
                                    proxy.scrollTo(selectedYear, anchor: .center)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            
                            // Существующие года
                            ForEach(availableYears, id: \.self) { year in
                                ZStack(alignment: .topTrailing) {
                                    // Кнопка выбора года
                                    Button(action: {
                                        selectedYear = year
                                        withAnimation {
                                            proxy.scrollTo(year, anchor: .center)
                                        }
                                    }) {
                                        Text(String(year))
                                            .font(.body)
                                            .fontWeight(year == selectedYear ? .semibold : .regular)
                                            .foregroundColor(year == selectedYear ? .white : .primary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(year == selectedYear ? Color.blue : Color(.systemGray5))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Кнопка удаления года (X) — показывает Sheet
                                    // Используем Button с явным contentShape и zIndex для надежного срабатывания
                                    Button(action: {
                                        yearToDelete = year
                                        showDeleteYearSheet = true
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                           
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width: 30, height: 30)
                                    .contentShape(Rectangle())
                                    .offset(x: 6, y: -6)
                                    .zIndex(10)
                                    .allowsHitTesting(true)
                                }
                                .id(year)
                            }
                            
                            // Кнопка добавления года справа
                            Button(action: {
                                addYear(maxYear + 1)
                                withAnimation {
                                    proxy.scrollTo(selectedYear, anchor: .center)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .onAppear {
                        proxy.scrollTo(selectedYear, anchor: .center)
                    }
                    .onChange(of: selectedYear) { newYear in
                        withAnimation {
                            proxy.scrollTo(newYear, anchor: .center)
                        }
                    }
                }
                
                // Стрелка вправо
                Button(action: {
                    if let currentIndex = availableYears.firstIndex(of: selectedYear),
                       currentIndex < availableYears.count - 1 {
                        selectedYear = availableYears[currentIndex + 1]
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
                .disabled(availableYears.firstIndex(of: selectedYear) == availableYears.count - 1)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onAppear {
            // Если выбранный год не в списке, выбираем первый доступный
            let years = availableYears
            if !years.contains(selectedYear) {
                selectedYear = years.first ?? Calendar.current.component(.year, from: Date())
            }
        }
        .sheet(isPresented: $showDeleteYearSheet) {
            if let year = yearToDelete {
                DeleteYearSheetView(
                    year: year,
                    isPresented: $showDeleteYearSheet,
                    onDelete: {
                        deleteYear(year)
                        yearToDelete = nil
                        showDeleteYearSheet = false
                    }
                )
            }
        }
    }
}
