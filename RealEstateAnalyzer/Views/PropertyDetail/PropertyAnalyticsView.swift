//
//  PropertyAnalyticsView.swift
//  RealEstateAnalyzer
//
//  Аналитика объекта недвижимости
//

import SwiftUI
import UIKit

struct AnalyticsView: View {
    let analytics: Analytics
    @Binding var onlySelectedYear: Bool
    @Binding var includeMaintenance: Bool
    @Binding var includeOperating: Bool
    
    @State private var showingFormula: String? = nil
    @State private var buttonPosition: CGPoint? = nil
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
            // Настройки аналитики
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("analytics_only_selected_year".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $onlySelectedYear)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 30, height: 15)
                    }
                    HStack(spacing: 6) {
                        Text("analytics_include_maintenance".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $includeMaintenance)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 30, height: 15)
                    }
                    HStack(spacing: 6) {
                        Text("analytics_include_operating".localized)
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
            SectionView(title: "analytics_section_basic".localized) {
                MetricRow(
                    label: "analytics_metric_monthly_income".localized,
                    value: analytics.monthlyIncome.formatCurrency(),
                    note: "analytics_note_monthly_income".localized,
                    formula: "analytics_formula_monthly_income".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_monthly_expenses".localized,
                    value: analytics.monthlyExpenses.formatCurrency(),
                    note: "analytics_note_monthly_expenses".localized,
                    formula: "analytics_formula_monthly_expenses".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_profit_per_m2".localized,
                    value: String(format: "%.2f ₽", analytics.profitPerM2),
                    note: "analytics_note_profit_per_m2".localized,
                    formula: "analytics_formula_profit_per_m2".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_efficiency".localized,
                    value: String(format: "%.2f (%@)", analytics.efficiency, analytics.efficiencyLevel),
                    note: "analytics_note_efficiency".localized,
                    formula: "analytics_formula_efficiency".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
            }
            
            // II. ДОХОДНОСТЬ И ИНВЕСТИЦИОННАЯ ПРИВЛЕКАТЕЛЬНОСТЬ
            SectionView(title: "analytics_section_profitability".localized) {
                MetricRow(
                    label: "analytics_metric_roi".localized,
                    value: String(format: "%.2f%%", analytics.roi),
                    note: "analytics_note_roi".localized,
                    formula: "analytics_formula_roi".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_cap_rate".localized,
                    value: String(format: "%.2f%%", analytics.capRate),
                    note: "analytics_note_cap_rate".localized,
                    formula: "analytics_formula_cap_rate".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                if let grm = analytics.grm {
                    MetricRow(
                        label: "analytics_metric_grm".localized,
                        value: String(format: "%.2f", grm),
                        note: "analytics_note_grm".localized,
                        formula: "analytics_formula_grm".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
                if let payback = analytics.payback {
                    MetricRow(
                        label: "analytics_metric_payback".localized,
                        value: String(format: "%.2f %@", payback, "unit_years".localized),
                        note: "analytics_note_payback".localized,
                        formula: "analytics_formula_payback".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
                if let irr = analytics.irr {
                    MetricRow(
                        label: "analytics_metric_irr".localized,
                        value: String(format: "%.2f%%", irr),
                        note: "analytics_note_irr".localized,
                        formula: "analytics_formula_irr".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
                if let equityMultiple = analytics.equityMultiple {
                    MetricRow(
                        label: "analytics_metric_equity_multiple".localized,
                        value: String(format: "%.2f", equityMultiple),
                        note: "analytics_note_equity_multiple".localized,
                        formula: "analytics_formula_equity_multiple".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
            }
            
            // III. НАДЁЖНОСТЬ И РИСК
            SectionView(title: "analytics_section_reliability".localized) {
                MetricRow(
                    label: "analytics_metric_tenant_risk".localized,
                    value: analytics.tenantRisk,
                    note: "analytics_note_tenant_risk".localized,
                    formula: "analytics_formula_tenant_risk".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_busy_percent".localized,
                    value: String(format: "%.1f%%", analytics.busyPercent),
                    note: "analytics_note_busy_percent".localized,
                    formula: "analytics_formula_busy_percent".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_volatility".localized,
                    value: String(format: "%.2f (%@)", analytics.volatility, analytics.volatilityLevel),
                    note: "analytics_note_volatility".localized,
                    formula: "analytics_formula_volatility".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                MetricRow(
                    label: "analytics_metric_concentration".localized,
                    value: String(format: "%.1f%%", analytics.tenantConcentration),
                    note: "analytics_note_concentration".localized,
                    formula: "analytics_formula_concentration".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                if let breakEven = analytics.breakEvenOccupancy {
                    MetricRow(
                        label: "analytics_metric_break_even".localized,
                        value: String(format: "%.1f%%", breakEven),
                        note: "analytics_note_break_even".localized,
                        formula: "analytics_formula_break_even".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
            }
            
            // IV. ВРЕМЕННЫЕ И СТРУКТУРНЫЕ ПОКАЗАТЕЛИ
            SectionView(title: "analytics_section_temporal".localized) {
                MetricRow(
                    label: "analytics_metric_own_years".localized,
                    value: String(format: "%.1f %@", analytics.ownYears, "unit_years".localized),
                    note: "analytics_note_own_years".localized,
                    formula: "analytics_formula_own_years".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
                if let maxIncomeMonth = analytics.maxIncomeMonth {
                    MetricRow(
                        label: "analytics_metric_max_income".localized,
                        value: maxIncomeMonth,
                        note: "analytics_note_max_income".localized,
                        formula: "analytics_formula_max_income".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
                if let maxExpenseMonth = analytics.maxExpenseMonth {
                    MetricRow(
                        label: "analytics_metric_max_expense".localized,
                        value: maxExpenseMonth,
                        note: "analytics_note_max_expense".localized,
                        formula: "analytics_formula_max_expense".localized,
                        onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                    )
                }
                MetricRow(
                    label: "analytics_metric_income_expense_ratio".localized,
                    value: String(format: "%.2f", analytics.incomeExpenseRatio),
                    note: "analytics_note_income_expense_ratio".localized,
                    formula: "analytics_formula_income_expense_ratio".localized,
                    onShowFormula: { formula, position in
                        showingFormula = formula
                        buttonPosition = position
                    }
                )
            }
            }
            .padding()
            
            // Overlay для справки по центру экрана
            if let formula = showingFormula {
                FormulaHelpView(
                    formula: formula,
                    buttonPosition: buttonPosition,
                    isPresented: Binding(
                        get: { showingFormula != nil },
                        set: { 
                            if !$0 { 
                                showingFormula = nil
                                buttonPosition = nil
                            }
                        }
                    )
                )
                .ignoresSafeArea()
            }
        }
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
    let onShowFormula: ((String, CGPoint) -> Void)?
    
    init(label: String, value: String, note: String, formula: String? = nil, onShowFormula: ((String, CGPoint) -> Void)? = nil) {
        self.label = label
        self.value = value
        self.note = note
        self.formula = formula
        self.onShowFormula = onShowFormula
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
                    GeometryReader { geometry in
                        Button(action: {
                            // Получаем глобальную позицию кнопки
                            let buttonFrame = geometry.frame(in: .global)
                            let buttonCenter = CGPoint(
                                x: buttonFrame.midX,
                                y: buttonFrame.midY
                            )
                            onShowFormula?(formula, buttonCenter)
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 20, height: 20)
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

