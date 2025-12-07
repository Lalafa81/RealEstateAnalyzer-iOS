//
//  Analytics.swift
//  RealEstateAnalyzer
//
//  Модель аналитики объекта недвижимости
//

import Foundation

struct Analytics: Codable {
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var roi: Double
    var grm: Double?
    var incomePerM2: Double
    var capRate: Double
    var efficiency: Double
    var efficiencyLevel: String
    var payback: Double?
    var tenantRisk: String
    var volatility: Double
    var volatilityLevel: String
    var busyMonths: Int
    var busyPercent: Double
    var rentPerM2: Double
    var maxIncomeMonth: String?
    var maxExpenseMonth: String?
    var incomeExpenseRatio: Double
    var tenantConcentration: Double
    var ownYears: Double
    var irr: Double?
    var equityMultiple: Double?
    var breakEvenOccupancy: Double?
    var profitPerM2: Double
}

struct FinancialData {
    let incomes: [Double]
    
    let expensesMaintenance: [Double]
    let expensesOperating: [Double]
    let expensesOther: [Double]
    
    let propertyTax: Double
    let insuranceCost: Double
    
    let monthsWithIncome: Int
    let monthsWithExpense: Int
    let onlySelectedYear: Bool
}

extension FinancialData {
    func totalExpenses(
        includeMaintenance: Bool = true,
        includeOperating: Bool = true
    ) -> Double {
        var total: Double = 0
        
        // Административные расходы (техническое обслуживание)
        if includeMaintenance {
            total += expensesMaintenance.reduce(0, +)
        }
        
        // Эксплуатационные расходы
        if includeOperating {
            total += expensesOperating.reduce(0, +)
        }
        
        // Прочие расходы - всегда учитываются
        total += expensesOther.reduce(0, +)
        
        return total + propertyTax + insuranceCost
    }
    
    func totalIncome() -> Double {
        incomes.reduce(0, +)
    }
}

