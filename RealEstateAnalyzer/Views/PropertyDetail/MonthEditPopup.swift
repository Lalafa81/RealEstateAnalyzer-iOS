//
//  MonthEditPopup.swift
//  RealEstateAnalyzer
//
//  Popup для редактирования детальных данных месяца в стиле FormulaHelpView
//

import SwiftUI
import UIKit

// MARK: - Blur View для iOS 14.2+

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return effectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Month Edit Popup

struct MonthEditPopup: View {
    @Binding var isPresented: Bool
    @Binding var incomeBase: Double
    @Binding var incomeVariable: Double
    @Binding var admin: Double
    @Binding var operating: Double
    @Binding var other: Double
    
    let monthTitle: String
    let onSave: () -> Void
    
    // Временные строковые значения для TextField (iOS 14.2 совместимость)
    @State private var incomeBaseText: String = ""
    @State private var incomeVariableText: String = ""
    @State private var adminText: String = ""
    @State private var operatingText: String = ""
    @State private var otherText: String = ""
    
    var totalIncome: Double {
        let base = Double(incomeBaseText) ?? 0
        let variable = Double(incomeVariableText) ?? 0
        return base + variable
    }
    
    var totalExpense: Double {
        let a = Double(adminText) ?? 0
        let o = Double(operatingText) ?? 0
        let ot = Double(otherText) ?? 0
        return a + o + ot
    }
    
    init(isPresented: Binding<Bool>, incomeBase: Binding<Double>, incomeVariable: Binding<Double>, admin: Binding<Double>, operating: Binding<Double>, other: Binding<Double>, monthTitle: String, onSave: @escaping () -> Void) {
        self._isPresented = isPresented
        self._incomeBase = incomeBase
        self._incomeVariable = incomeVariable
        self._admin = admin
        self._operating = operating
        self._other = other
        self.monthTitle = monthTitle
        self.onSave = onSave
        
        // Инициализируем строковые значения
        _incomeBaseText = State(initialValue: String(format: "%.0f", incomeBase.wrappedValue))
        _incomeVariableText = State(initialValue: String(format: "%.0f", incomeVariable.wrappedValue))
        _adminText = State(initialValue: String(format: "%.0f", admin.wrappedValue))
        _operatingText = State(initialValue: String(format: "%.0f", operating.wrappedValue))
        _otherText = State(initialValue: String(format: "%.0f", other.wrappedValue))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемненный фон с тапом для закрытия
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                
                // Popup окно
                VStack(spacing: 3) { // РАЗМЕР: spacing между элементами
                    // Header с иконкой слева и заголовком
                    HStack(alignment: .center, spacing: 8) {
                        // Иконка в левом верхнем углу
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 18)) // РАЗМЕР: иконка (компактно)
                            .foregroundColor(.blue)
                        
                        // Заголовок
                        Text("Редактирование: \(monthTitle)")
                            .font(.subheadline) // РАЗМЕР: шрифт заголовка
                            .fontWeight(.semibold)
                            .lineLimit(1) // РАЗМЕР: одна строка
                        
                        Spacer()
                    }
                    .padding(.top, 6) // РАЗМЕР: отступ сверху (компактно)
                    .padding(.horizontal, 16) // РАЗМЕР: горизонтальный отступ
                    .padding(.bottom, 2) // РАЗМЕР: небольшой отступ снизу для разделения
                    
                    // Поля доходов
                    Group {
                        VStack(alignment: .leading, spacing: 1) { // РАЗМЕР: spacing между лейблом и полем
                            Text("Базовый доход")
                                .font(.caption2) // РАЗМЕР: шрифт лейбла
                                .foregroundColor(.secondary)
                            TextField("0", text: $incomeBaseText)
                                .keyboardType(.decimalPad)
                                .font(.caption2) // РАЗМЕР: шрифт в поле
                                .frame(height: 26) // РАЗМЕР: фиксированная высота поля (финальное уменьшение)
                                .padding(.horizontal, 6) // РАЗМЕР: горизонтальный padding в поле (уменьшено)
                                .background(Color(.systemGray6))
                                .cornerRadius(4) // РАЗМЕР: скругление поля (уменьшено)
                        }
                        .padding(.horizontal, 16) // РАЗМЕР: горизонтальный отступ
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Переменный доход")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", text: $incomeVariableText)
                                .keyboardType(.decimalPad)
                                .font(.caption2)
                                .frame(height: 26) // РАЗМЕР: фиксированная высота поля (финальное уменьшение)
                                .padding(.horizontal, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 16)
                        
                        // Итого доход
                        HStack {
                            Text("Итого доход")
                                .font(.footnote) // РАЗМЕР: шрифт итого
                                .fontWeight(.semibold)
                            Spacer()
                            Text(totalIncome.formatCurrency())
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 1) // РАЗМЕР: вертикальный отступ для итого (еще уменьшено)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Поля расходов
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Административные")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", text: $adminText)
                                .keyboardType(.decimalPad)
                                .font(.caption2) // РАЗМЕР: шрифт в поле
                                .frame(height: 26) // РАЗМЕР: фиксированная высота поля (финальное уменьшение)
                                .padding(.horizontal, 6) // РАЗМЕР: горизонтальный padding в поле (уменьшено)
                                .background(Color(.systemGray6))
                                .cornerRadius(4) // РАЗМЕР: скругление поля (уменьшено)
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Эксплуатационные")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", text: $operatingText)
                                .keyboardType(.decimalPad)
                                .font(.caption2)
                                .frame(height: 26) // РАЗМЕР: фиксированная высота поля (финальное уменьшение)
                                .padding(.horizontal, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Прочие")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", text: $otherText)
                                .keyboardType(.decimalPad)
                                .font(.caption2)
                                .frame(height: 26) // РАЗМЕР: фиксированная высота поля (финальное уменьшение)
                                .padding(.horizontal, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 16)
                        
                        // Итого расход
                        HStack {
                            Text("Итого расход")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(totalExpense.formatCurrency())
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 1)
                    }
                    
                    // Кнопка закрытия
                    Text("Готово")
                        .font(.caption2) // РАЗМЕР: шрифт кнопки
                        .fontWeight(.semibold)
                        .frame(height: 26) // РАЗМЕР: фиксированная высота кнопки (финальное уменьшение)
                        .padding(.horizontal, 20) // РАЗМЕР: горизонтальный padding кнопки
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(5) // РАЗМЕР: скругление кнопки
                        .contentShape(Rectangle())
                        .onTapGesture {
                            saveAndDismiss()
                        }
                        .padding(.bottom, 4) // РАЗМЕР: отступ снизу (финальное уменьшение)
                }
                .frame(maxWidth: 300) // РАЗМЕР: максимальная ширина popup (расширено)
                .background(
                    ZStack {
                        BlurView(style: .systemUltraThinMaterial)
                        Color(.systemBackground).opacity(0.92)
                    }
                )
                .cornerRadius(16) // РАЗМЕР: скругление popup
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
        }
        .onAppear {
            // Обновляем строковые значения при появлении
            incomeBaseText = String(format: "%.0f", incomeBase)
            incomeVariableText = String(format: "%.0f", incomeVariable)
            adminText = String(format: "%.0f", admin)
            operatingText = String(format: "%.0f", operating)
            otherText = String(format: "%.0f", other)
        }
    }
    
    private func saveAndDismiss() {
        // Синхронизируем строковые значения с Double перед сохранением
        incomeBase = Double(incomeBaseText) ?? 0
        incomeVariable = Double(incomeVariableText) ?? 0
        admin = Double(adminText) ?? 0
        operating = Double(operatingText) ?? 0
        other = Double(otherText) ?? 0
        onSave()
        isPresented = false
    }
}
