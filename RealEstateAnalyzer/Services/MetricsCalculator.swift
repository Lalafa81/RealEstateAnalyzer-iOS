//
//  MetricsCalculator.swift
//  RealEstateAnalyzer
//
//  Калькулятор метрик - замена metrics.py
//

import Foundation

class MetricsCalculator {
    
    // MARK: - Базовые финансовые показатели
    
    static func capitalizationRate(income: Double, expenses: Double, price: Double) -> Double {
        let noi = income - expenses
        return price > 0 ? round((noi / price) * 100 * 100) / 100 : 0
    }
    
    static func cashOnCashReturn(cashFlow: Double, cashInvested: Double) -> Double {
        return cashInvested > 0 ? round((cashFlow / cashInvested) * 100 * 100) / 100 : 0
    }
    
    static func grossRentMultiplier(price: Double, annualIncome: Double) -> Double? {
        return annualIncome > 0 ? round((price / annualIncome) * 100) / 100 : nil
    }
    
    static func debtServiceCoverageRatio(income: Double, expenses: Double, debtService: Double) -> Double? {
        let noi = income - expenses
        return debtService > 0 ? round((noi / debtService) * 100) / 100 : nil
    }
    
    // MARK: - Показатели эффективности
    
    static func incomePerSquareMeter(income: Double, area: Double) -> Double {
        return area > 0 ? round((income / area) * 100) / 100 : 0
    }
    
    static func efficiencyCoefficient(income: Double, area: Double) -> Double {
        return round((income / max(area, 1)) * 100) / 100
    }
    
    static func efficiencyRating(_ value: Double) -> String {
        if value >= 500 { return "высокий" }
        if value >= 250 { return "средний" }
        return "низкий"
    }
    
    // MARK: - Показатели окупаемости
    
    static func paybackPeriod(investment: Double, annualCashFlow: Double) -> Double? {
        return annualCashFlow > 0 ? round((investment / annualCashFlow) * 100) / 100 : nil
    }
    
    // MARK: - Показатели риска
    
    static func incomeVolatility(_ incomes: [Double]) -> (Double, String) {
        guard !incomes.isEmpty else { return (0, "низкая") }
        
        let validIncomes = incomes.filter { $0 > 0 }
        guard !validIncomes.isEmpty else { return (0, "низкая") }
        
        let mean = validIncomes.reduce(0, +) / Double(validIncomes.count)
        guard mean > 0 else { return (0, "низкая") }
        
        let variance = validIncomes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(validIncomes.count)
        let stdDev = sqrt(variance)
        let volatility = round((stdDev / mean) * 100) / 100
        
        let level: String
        if volatility < 0.1 {
            level = "низкая"
        } else if volatility < 0.5 {
            level = "умеренно"
        } else {
            level = "высокая"
        }
        
        return (volatility, level)
    }
    
    static func tenantRiskAssessment(_ tenants: [Tenant]) -> String {
        var maxYears: Double = 0
        
        for tenant in tenants {
            guard let startDateStr = tenant.startDate,
                  let endDateStr = tenant.endDate else { continue }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            if let startDate = formatter.date(from: startDateStr),
               let endDate = formatter.date(from: endDateStr) {
                let months = Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 0
                let years = Double(months) / 12.0
                maxYears = max(maxYears, years)
            }
        }
        
        if maxYears < 1 { return "высокий" }
        if maxYears < 3 { return "средний" }
        return "низкий"
    }
    
    // MARK: - Извлечение финансовых данных
    
    static func extractMonthlyFinancials(
        property: Property,
        year: Int?,
        includeAdmin: Bool = true,
        includeOther: Bool = true,
        onlySelectedYear: Bool = false
    ) -> FinancialData {
        let monthsDict = property.months
        let years = monthsDict.keys.compactMap { Int($0) }.sorted()
        
        // Если onlySelectedYear = true, используем year для фильтрации
        // Если onlySelectedYear = false, обрабатываем все года (year игнорируется)
        let targetYear: Int? = onlySelectedYear ? (year ?? Calendar.current.component(.year, from: Date())) : nil
        
        var incomes: [Double] = []
        var expenses: [Double] = []
        
        for y in years {
            // Если onlySelectedYear = true, пропускаем года, которые не равны targetYear
            // Если onlySelectedYear = false, обрабатываем все года
            if let target = targetYear, onlySelectedYear {
                if y != target {
                    continue
                }
            }
            
            guard let yearData = monthsDict[String(y)] else { continue }
            
            for monthData in yearData.values {
                let income = (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                incomes.append(income)
                
                // Используем новые поля, если они есть
                let admin = monthData.expensesAdmin ?? 0
                let maintenance = monthData.expensesMaintenance ?? 0
                let utilities = monthData.expensesUtilities ?? 0
                let financial = monthData.expensesFinancial ?? 0
                let operational = monthData.expensesOperational ?? 0
                let other = monthData.expensesOther ?? 0
                
                let hasNewFields = admin > 0 || maintenance > 0 || utilities > 0 || financial > 0 || operational > 0
                
                var expense: Double
                if hasNewFields {
                    expense = utilities
                    if includeAdmin {
                        expense += admin + maintenance + financial + operational
                    }
                    if includeOther {
                        expense += other
                    }
                } else {
                    // Старая логика для обратной совместимости
                    expense = monthData.expensesDirect ?? 0
                    if includeAdmin {
                        expense += monthData.expensesAdmin ?? 0
                    }
                    if includeOther {
                        expense += other
                    }
                }
                expenses.append(expense)
            }
        }
        
        let propertyTax = property.propertyTax ?? 0
        let insuranceCost = property.insuranceCost ?? 0
        let annualExpense = expenses.reduce(0, +) + propertyTax + insuranceCost
        let annualIncome = incomes.reduce(0, +)
        
        let monthsWithIncome = incomes.filter { $0 > 0 }.count
        let monthsWithExpense = expenses.filter { $0 > 0 }.count
        
        return FinancialData(
            incomes: incomes,
            expenses: expenses,
            annualIncome: annualIncome,
            annualExpense: annualExpense,
            propertyTax: propertyTax,
            insuranceCost: insuranceCost,
            monthsWithIncome: monthsWithIncome,
            monthsWithExpense: monthsWithExpense,
            onlySelectedYear: onlySelectedYear
        )
    }
    
    // MARK: - Вычисление всех метрик
    
    static func computeAllMetrics(financialData: FinancialData, property: Property) -> Analytics {
        let incomes = financialData.incomes
        let expenses = financialData.expenses
        let annualIncome = financialData.annualIncome
        let annualExpense = financialData.annualExpense
        let propertyTax = financialData.propertyTax
        let insuranceCost = financialData.insuranceCost
        let monthsWithIncome = financialData.monthsWithIncome
        let monthsWithExpense = financialData.monthsWithExpense
        let onlySelectedYear = financialData.onlySelectedYear
        
        let area = property.area > 0 ? property.area : 1
        let price = property.purchasePrice > 0 ? property.purchasePrice : 1
        
        // Средние значения
        let avgExpense = round((annualExpense / Double(onlySelectedYear ? 12 : max(monthsWithExpense, 1))) * 100) / 100
        let avgIncome = round((annualIncome / Double(onlySelectedYear ? 12 : max(monthsWithIncome, 1))) * 100) / 100
        
        // Срок владения
        let ownYears = ownershipDurationYears(purchaseDate: property.purchaseDate)
        
        // Загруженность
        let busyMonths = incomes.filter { $0 > 0 }.count
        let totalMonths = Int(ownYears * 12)
        let busyPercent = totalMonths > 0 ? round((Double(busyMonths) / Double(totalMonths) * 100) * 10) / 10 : 0
        
        // Месяцы с максимумами
        let monthNames = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
        let maxIncome = incomes.max() ?? 0
        let maxExpense = expenses.max() ?? 0
        let maxIncomeMonth = incomes.isEmpty ? nil : monthNames[incomes.firstIndex(of: maxIncome)! % 12]
        let maxExpenseMonth = expenses.isEmpty ? nil : monthNames[expenses.firstIndex(of: maxExpense)! % 12]
        
        // Дополнительные метрики
        let rentPerM2 = incomePerSquareMeter(income: avgIncome, area: area)
        let incomeExpenseRatio = annualExpense > 0 ? round((annualIncome / annualExpense) * 100) / 100 : 0
        let profitPerM2 = area > 0 ? round(((avgIncome - avgExpense) / area) * 100) / 100 : 0
        
        // Концентрация арендаторов
        let tenantsIncomes = property.tenants.compactMap { $0.income ?? 0 }
        let maxTenant = tenantsIncomes.max() ?? 0
        let sumTenants = tenantsIncomes.reduce(0, +)
        let tenantConcentration = sumTenants > 0 ? round((maxTenant / sumTenants * 100) * 10) / 10 : 0
        
        // IRR (упрощенная версия, без numpy-financial)
        let netCashFlow = (avgIncome - avgExpense) * 12
        let exitPrice = property.exitPrice ?? 0
        // IRR требует итеративного решения, упрощаем
        let irr: Double? = nil // TODO: Реализовать расчет IRR
        
        // Equity Multiple
        let holdingYears = ownYears > 0 ? ownYears : 1
        let equityMultiple = price > 0 ? round(((netCashFlow * holdingYears + exitPrice) / price) * 100) / 100 : nil
        
        // Break-Even Occupancy
        let breakEvenOccupancy = annualIncome > 0 ? round((annualExpense / annualIncome * 100) * 10) / 10 : nil
        
        // Волатильность
        let (volatility, volatilityLevel) = incomeVolatility(incomes)
        
        return Analytics(
            monthlyIncome: avgIncome,
            monthlyExpenses: avgExpense,
            roi: cashOnCashReturn(cashFlow: netCashFlow, cashInvested: price),
            grm: grossRentMultiplier(price: price, annualIncome: annualIncome),
            incomePerM2: incomePerSquareMeter(income: avgIncome, area: area),
            capRate: capitalizationRate(
                income: avgIncome * 12,
                expenses: avgExpense * 12 + propertyTax + insuranceCost,
                price: price
            ),
            efficiency: efficiencyCoefficient(income: avgIncome, area: area),
            efficiencyLevel: efficiencyRating(efficiencyCoefficient(income: avgIncome, area: area)),
            payback: paybackPeriod(investment: price, annualCashFlow: netCashFlow),
            tenantRisk: tenantRiskAssessment(property.tenants),
            volatility: volatility,
            volatilityLevel: volatilityLevel,
            busyMonths: busyMonths,
            busyPercent: busyPercent,
            rentPerM2: rentPerM2,
            maxIncomeMonth: maxIncomeMonth,
            maxExpenseMonth: maxExpenseMonth,
            incomeExpenseRatio: incomeExpenseRatio,
            tenantConcentration: tenantConcentration,
            ownYears: ownYears,
            irr: irr,
            equityMultiple: equityMultiple,
            breakEvenOccupancy: breakEvenOccupancy,
            profitPerM2: profitPerM2
        )
    }
    
    // MARK: - Вспомогательные функции
    
    private static func ownershipDurationYears(purchaseDate: String) -> Double {
        guard !purchaseDate.isEmpty else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let purchaseDt = formatter.date(from: purchaseDate) else {
            // Попробуем другой формат
            formatter.dateFormat = "yyyy-MM-dd"
            guard let purchaseDt2 = formatter.date(from: purchaseDate) else { return 0 }
            let components = Calendar.current.dateComponents([.year, .month], from: purchaseDt2, to: Date())
            return Double(components.year ?? 0) + Double(components.month ?? 0) / 12.0
        }
        
        let components = Calendar.current.dateComponents([.year, .month], from: purchaseDt, to: Date())
        return Double(components.year ?? 0) + Double(components.month ?? 0) / 12.0
    }
}

