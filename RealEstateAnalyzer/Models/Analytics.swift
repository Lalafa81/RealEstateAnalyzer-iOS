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
    var incomes: [Double]
    var expenses: [Double]
    var annualIncome: Double
    var annualExpense: Double
    var propertyTax: Double
    var insuranceCost: Double
    var monthsWithIncome: Int
    var monthsWithExpense: Int
    var onlySelectedYear: Bool
}

