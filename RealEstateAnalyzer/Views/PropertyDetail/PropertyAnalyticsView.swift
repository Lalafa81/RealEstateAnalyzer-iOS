//
//  PropertyAnalyticsView.swift
//  RealEstateAnalyzer
//
//  Аналитика объекта недвижимости
//

import SwiftUI

struct AnalyticsView: View {
    let analytics: Analytics
    @Binding var onlySelectedYear: Bool
    @Binding var includeMaintenance: Bool
    @Binding var includeOperating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Заголовок
            Text("Аналитика")
                .font(.title2)
                .fontWeight(.bold)
            
            // Настройки аналитики
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Только выбранный год")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $onlySelectedYear)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 30, height: 15)
                    }
                    HStack(spacing: 6) {
                        Text("Включать техобслуживание")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $includeMaintenance)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 30, height: 15)
                    }
                    HStack(spacing: 6) {
                        Text("Включать эксплуатационные")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $includeOperating)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 30, height: 15)
                    }
                }
            }
            
            // I. БАЗОВЫЕ ПОКАЗАТЕЛИ ОБЪЕКТА
            SectionView(title: "I. БАЗОВЫЕ ПОКАЗАТЕЛИ ОБЪЕКТА") {
                MetricRow(
                    label: "Ежемесячный доход",
                    value: analytics.monthlyIncome.formatCurrency(),
                    note: "Показывает средний доход за месяц.",
                    formula: "Ежемесячный доход = Годовой доход / Количество месяцев"
                )
                MetricRow(
                    label: "Ежемесячные расходы",
                    value: analytics.monthlyExpenses.formatCurrency(),
                    note: "Показывает средние расходы за месяц.",
                    formula: "Ежемесячные расходы = Годовой расход / Количество месяцев"
                )
                MetricRow(
                    label: "Рентабельность м²",
                    value: String(format: "%.2f ₽", analytics.profitPerM2),
                    note: "Оценивает прибыль с одного квадратного метра.",
                    formula: "Рентабельность м² = (Средний доход - Средний расход) / Площадь"
                )
                MetricRow(
                    label: "Коэф. эффективности",
                    value: String(format: "%.2f (%@)", analytics.efficiency, analytics.efficiencyLevel),
                    note: "Отражает эффективность использования площади.",
                    formula: "Коэффициент эффективности = Средний доход / Площадь"
                )
            }
            
            // II. ДОХОДНОСТЬ И ИНВЕСТИЦИОННАЯ ПРИВЛЕКАТЕЛЬНОСТЬ
            SectionView(title: "II. ДОХОДНОСТЬ И ИНВЕСТИЦИОННАЯ ПРИВЛЕКАТЕЛЬНОСТЬ") {
                MetricRow(
                    label: "ROI",
                    value: String(format: "%.2f%%", analytics.roi),
                    note: "Расчитывает доходность вложений за год.",
                    formula: "ROI = ((Средний доход - Средний расход) × 12 / Цена покупки) × 100%"
                )
                MetricRow(
                    label: "Cap Rate",
                    value: String(format: "%.2f%%", analytics.capRate),
                    note: "Определяет доходность объекта без учёта кредита и налогов.",
                    formula: "Cap Rate = (NOI / Цена покупки) × 100%\n\nNOI = Годовой доход - Годовой расход - Налоги - Страхование"
                )
                if let grm = analytics.grm {
                    MetricRow(
                        label: "GRM",
                        value: String(format: "%.2f", grm),
                        note: "Индикатор позволяет оценить, за сколько лет окупится объект при текущем доходе (без учета расходов).",
                        formula: "GRM = Цена покупки / Годовой доход"
                    )
                }
                if let payback = analytics.payback {
                    MetricRow(
                        label: "Окупаемость",
                        value: String(format: "%.2f лет", payback),
                        note: "Оценивает, через сколько лет окупится инвестиция.",
                        formula: "Окупаемость = Цена покупки / Годовой чистый cash flow\n\nГодовой cash flow = (Средний доход - Средний расход) × 12"
                    )
                }
                if let irr = analytics.irr {
                    MetricRow(
                        label: "IRR",
                        value: String(format: "%.2f%%", irr),
                        note: "Демонстрирует реальную доходность инвестиции с учетом времени.",
                        formula: "IRR — ставка дисконтирования, при которой NPV = 0\n\nNPV = -Инвестиция + Σ(Годовой cash flow / (1 + IRR)^год) + Цена продажи / (1 + IRR)^срок_владения"
                    )
                }
                if let equityMultiple = analytics.equityMultiple {
                    MetricRow(
                        label: "Equity Multiple",
                        value: String(format: "%.2f", equityMultiple),
                        note: "Отражает, во сколько раз увеличится капитал за период владения.",
                        formula: "Equity Multiple = (Годовой cash flow × Срок владения + Цена продажи) / Цена покупки"
                    )
                }
            }
            
            // III. НАДЁЖНОСТЬ И РИСК
            SectionView(title: "III. НАДЁЖНОСТЬ И РИСК") {
                MetricRow(
                    label: "Риск арендатора",
                    value: analytics.tenantRisk,
                    note: "Оценивает уровень риска на основе максимального срока контракта арендаторов.",
                    formula: "Риск оценивается по максимальному сроку контракта:\n• < 1 года → высокий риск\n• 1-3 года → средний риск\n• > 3 лет → низкий риск"
                )
                MetricRow(
                    label: "Загруженность",
                    value: String(format: "%.1f%%", analytics.busyPercent),
                    note: "Определяет процент месяцев с доходом от общего периода владения.",
                    formula: "Загруженность = (Месяцы с доходом > 0 / Общее количество месяцев) × 100%"
                )
                MetricRow(
                    label: "Волатильность дохода",
                    value: String(format: "%.2f (%@)", analytics.volatility, analytics.volatilityLevel),
                    note: "Отражает стабильность дохода.",
                    formula: "Волатильность = Стандартное отклонение доходов / Среднее значение доходов\n\n• < 0.1 → низкая волатильность\n• 0.1-0.5 → умеренная\n• > 0.5 → высокая"
                )
                MetricRow(
                    label: "Концентрация",
                    value: String(format: "%.1f%%", analytics.tenantConcentration),
                    note: "Оценивает долю самого крупного арендатора в общем доходе.",
                    formula: "Концентрация = (Максимальный доход арендатора / Сумма всех доходов арендаторов) × 100%"
                )
                if let breakEven = analytics.breakEvenOccupancy {
                    MetricRow(
                        label: "Break-Even Occupancy",
                        value: String(format: "%.1f%%", breakEven),
                        note: "Позволяет оценить минимальный процент загрузки для безубыточности.",
                        formula: "Break-Even Occupancy = (Годовой расход / Годовой доход) × 100%"
                    )
                }
            }
            
            // IV. ВРЕМЕННЫЕ И СТРУКТУРНЫЕ ПОКАЗАТЕЛИ
            SectionView(title: "IV. ВРЕМЕННЫЕ И СТРУКТУРНЫЕ ПОКАЗАТЕЛИ") {
                MetricRow(
                    label: "Срок владения",
                    value: String(format: "%.1f лет", analytics.ownYears),
                    note: "Отражает, сколько лет прошло с момента покупки объекта.",
                    formula: "Срок владения = (Текущая дата - Дата покупки) / 365"
                )
                if let maxIncomeMonth = analytics.maxIncomeMonth {
                    MetricRow(
                        label: "Макс. доход",
                        value: maxIncomeMonth,
                        note: "Показывает месяц и год с максимальным доходом за весь период.",
                        formula: "Максимальный доход = max(доходы по всем месяцам)\n\nОпределяется месяц и год с наибольшим значением дохода."
                    )
                }
                if let maxExpenseMonth = analytics.maxExpenseMonth {
                    MetricRow(
                        label: "Макс. расход",
                        value: maxExpenseMonth,
                        note: "Показывает месяц и год с максимальными расходами за весь период.",
                        formula: "Максимальный расход = max(расходы по всем месяцам)\n\nОпределяется месяц и год с наибольшим значением расходов."
                    )
                }
                MetricRow(
                    label: "Доход / Расход",
                    value: String(format: "%.2f", analytics.incomeExpenseRatio),
                    note: "Расчитывает соотношение доходов к расходам.",
                    formula: "Доход / Расход = Годовой доход / Годовой расход\n\nЗначение > 1 означает прибыльность, < 1 — убыточность."
                )
            }
        }
        .padding()
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 8)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let note: String
    let formula: String?
    
    @State private var showingFormula = false
    
    init(label: String, value: String, note: String, formula: String? = nil) {
        self.label = label
        self.value = value
        self.note = note
        self.formula = formula
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label + ":")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if let formula = formula {
                    Button(action: {
                        showingFormula = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .alert(isPresented: $showingFormula) {
                        Alert(
                            title: Text("Формула расчета"),
                            message: Text(formula),
                            dismissButton: .default(Text("Понятно"))
                        )
                    }
                }
            }
            Text(note)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.vertical, 4)
    }
}


