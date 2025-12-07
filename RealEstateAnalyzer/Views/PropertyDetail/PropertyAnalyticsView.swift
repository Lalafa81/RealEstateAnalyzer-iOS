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
        VStack(alignment: .leading, spacing: 20) {
            // Заголовок с настройками справа
            HStack {
                Text("Аналитика")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Настройки аналитики
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
                MetricRow(label: "Ежемесячный доход", value: analytics.monthlyIncome.formatCurrency(), note: "(Доходы за год / 12)")
                MetricRow(label: "Ежемесячные расходы", value: analytics.monthlyExpenses.formatCurrency(), note: "(Расходы за год / 12)")
                MetricRow(label: "Рентабельность м²", value: String(format: "%.2f ₽", analytics.profitPerM2), note: "(прибыль / площадь)")
                MetricRow(label: "Коэф. эффективности", value: String(format: "%.2f (%@)", analytics.efficiency, analytics.efficiencyLevel), note: "(Средний доход / площадь)")
            }
            
            // II. ДОХОДНОСТЬ И ИНВЕСТИЦИОННАЯ ПРИВЛЕКАТЕЛЬНОСТЬ
            SectionView(title: "II. ДОХОДНОСТЬ И ИНВЕСТИЦИОННАЯ ПРИВЛЕКАТЕЛЬНОСТЬ") {
                MetricRow(label: "ROI", value: String(format: "%.2f%%", analytics.roi), note: "Показывает доходность вложений за год.")
                MetricRow(label: "Cap Rate", value: String(format: "%.2f%%", analytics.capRate), note: "Показывает доходность объекта без учёта кредита и налогов.")
                if let grm = analytics.grm {
                    MetricRow(label: "GRM", value: String(format: "%.2f", grm), note: "(Цена / Годовой доход)")
                }
                if let payback = analytics.payback {
                    MetricRow(label: "Окупаемость", value: String(format: "%.2f лет", payback), note: "(Цена / (Средний доход - Средний расход))")
                }
                if let irr = analytics.irr {
                    MetricRow(label: "IRR", value: String(format: "%.2f%%", irr), note: "([-инвестиции, доход1, ..., доходN + цена продажи])")
                }
                if let equityMultiple = analytics.equityMultiple {
                    MetricRow(label: "Equity Multiple", value: String(format: "%.2f", equityMultiple), note: "((Чистый доход + цена продажи) / Инвестиции)")
                }
            }
            
            // III. НАДЁЖНОСТЬ И РИСК
            SectionView(title: "III. НАДЁЖНОСТЬ И РИСК") {
                MetricRow(label: "Риск арендатора", value: analytics.tenantRisk, note: "(Оценивается по сроку контракта)")
                MetricRow(label: "Загруженность", value: String(format: "%.1f%%", analytics.busyPercent), note: "(Процент месяцев с доходом больше нуля от общего количества месяцев.)")
                MetricRow(label: "Волатильность дохода", value: String(format: "%.2f (%@)", analytics.volatility, analytics.volatilityLevel), note: "(std(доходов) / mean(доходов))")
                MetricRow(label: "Концентрация", value: String(format: "%.1f%%", analytics.tenantConcentration), note: "(Макс. аренда / Σаренд)")
                if let breakEven = analytics.breakEvenOccupancy {
                    MetricRow(label: "Break-Even Occupancy", value: String(format: "%.1f%%", breakEven), note: "(Расходы / Потенциальный доход)")
                }
            }
            
            // IV. ВРЕМЕННЫЕ И СТРУКТУРНЫЕ ПОКАЗАТЕЛИ
            SectionView(title: "IV. ВРЕМЕННЫЕ И СТРУКТУРНЫЕ ПОКАЗАТЕЛИ") {
                MetricRow(label: "Срок владения", value: String(format: "%.1f лет", analytics.ownYears), note: "((Сегодня - дата покупки) / 365)")
                if let maxIncomeMonth = analytics.maxIncomeMonth {
                    MetricRow(label: "Макс. доход", value: maxIncomeMonth, note: "(Месяц с максимумом)")
                }
                if let maxExpenseMonth = analytics.maxExpenseMonth {
                    MetricRow(label: "Макс. расход", value: maxExpenseMonth, note: "(Месяц с максимумом)")
                }
                MetricRow(label: "Доход / Расход", value: String(format: "%.2f", analytics.incomeExpenseRatio), note: "(Доходы / ΣРасходы)")
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
            }
            Text(note)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.vertical, 4)
    }
}


