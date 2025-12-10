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
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        for tenant in tenants {
            guard let startDateStr = tenant.startDate else { continue }
            
            // Если endDate отсутствует (текущий договор), используем текущую дату
            let endDateStr = tenant.endDate ?? formatter.string(from: currentDate)
            
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
        year: Int? = nil
    ) -> FinancialData {
        let monthsDict = property.months
        
        let allYears = monthsDict.keys.compactMap { Int($0) }.sorted()
        let yearsToUse = year.map { [$0] } ?? allYears
        
        var incomes: [Double] = []
        var expensesMaintenance: [Double] = []
        var expensesOperating: [Double] = []
        var expensesOther: [Double] = []
        
        for y in yearsToUse {
            guard let yearData = monthsDict[String(y)] else { continue }
            
            // Сортируем месяцы, чтобы порядок был стабильным
            // Месяцы хранятся как "01", "02", ..., "12"
            let monthKeys = yearData.keys.sorted()
            
            for monthKey in monthKeys {
                guard let monthData = yearData[monthKey] else { continue }
                
                let income =
                    (monthData.income ?? 0) +
                    (monthData.incomeVariable ?? 0)
                
                let em = monthData.expensesMaintenance ?? 0
                let eo = monthData.expensesOperational ?? 0
                let eo2 = monthData.expensesOther ?? 0
                
                incomes.append(income)
                expensesMaintenance.append(em)
                expensesOperating.append(eo)
                expensesOther.append(eo2)
            }
        }
        
        let propertyTax = property.propertyTax ?? 0
        let insuranceCost = property.insuranceCost ?? 0
        
        // Подсчитываем месяцы с расходами (если хотя бы один тип расходов > 0)
        let allExpenses = zip(zip(expensesMaintenance, expensesOperating), expensesOther).map { $0.0.0 + $0.0.1 + $0.1 }
        let monthsWithExpense = allExpenses.filter { $0 > 0 }.count
        
        return FinancialData(
            incomes: incomes,
            expensesMaintenance: expensesMaintenance,
            expensesOperating: expensesOperating,
            expensesOther: expensesOther,
            propertyTax: propertyTax,
            insuranceCost: insuranceCost,
            monthsWithIncome: incomes.filter { $0 > 0 }.count,
            monthsWithExpense: monthsWithExpense,
            onlySelectedYear: (year != nil)
        )
    }
    
    // MARK: - Вычисление всех метрик
    
    static func computeAllMetrics(
        financialData: FinancialData,
        property: Property,
        includeMaintenance: Bool = true,
        includeOperating: Bool = true
    ) -> Analytics {
        let incomes = financialData.incomes
        let annualIncome = financialData.totalIncome()
        let annualExpense = financialData.totalExpenses(
            includeMaintenance: includeMaintenance,
            includeOperating: includeOperating
        )
        let propertyTax = financialData.propertyTax
        let insuranceCost = financialData.insuranceCost
        
        // Собираем объединенный массив расходов для расчета максимумов
        var allExpenses: [Double] = []
        for i in 0..<incomes.count {
            var expense: Double = 0
            
            // Административные расходы (техническое обслуживание)
            if includeMaintenance {
                expense += financialData.expensesMaintenance[safe: i] ?? 0
            }
            
            // Эксплуатационные расходы
            if includeOperating {
                expense += financialData.expensesOperating[safe: i] ?? 0
            }
            
            // Прочие расходы - всегда учитываются
            expense += financialData.expensesOther[safe: i] ?? 0
            
            allExpenses.append(expense)
        }
        
        let area = property.area > 0 ? property.area : 1
        // Для ROI и других метрик используем реальную цену, если она 0 - возвращаем 0 для ROI
        let price = property.purchasePrice
        
        // Средние значения
        // Когда onlySelectedYear = true: делим на количество месяцев с данными в выбранном году (но не больше 12)
        // Когда onlySelectedYear = false: делим на количество месяцев с данными за весь период
        // Это обеспечивает корректный расчет средних значений независимо от того, сколько месяцев данных есть
        let monthsForAverage = max(incomes.count, 1)
        let avgExpense = round((annualExpense / Double(monthsForAverage)) * 100) / 100
        let avgIncome = round((annualIncome / Double(monthsForAverage)) * 100) / 100
        
        // Срок владения
        let ownYears = ownershipDurationYears(purchaseDate: property.purchaseDate)
        
        // Загруженность
        let busyMonths = incomes.filter { $0 > 0 }.count
        let totalMonths = Int(ownYears * 12)
        let busyPercent = totalMonths > 0 ? round((Double(busyMonths) / Double(totalMonths) * 100) * 10) / 10 : 0
        
        // Месяцы с максимумами (ищем напрямую в property.months, чтобы получить год)
        let monthNames = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        let monthKeys = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        var maxIncomeValue: Double = 0
        var maxIncomeYear: Int?
        var maxIncomeMonthIndex: Int?
        
        var maxExpenseValue: Double = 0
        var maxExpenseYear: Int?
        var maxExpenseMonthIndex: Int?
        
        // Проходим по всем годам и месяцам
        let allYears = property.months.keys.compactMap { Int($0) }.sorted()
        for year in allYears {
            guard let yearData = property.months[String(year)] else { continue }
            let sortedMonthKeys = yearData.keys.sorted()
            
            for monthKey in sortedMonthKeys {
                guard let monthData = yearData[monthKey],
                      let monthIndex = monthKeys.firstIndex(of: monthKey) else { continue }
                
                // Доход
                let income = (monthData.income ?? 0) + (monthData.incomeVariable ?? 0)
                if income > maxIncomeValue {
                    maxIncomeValue = income
                    maxIncomeYear = year
                    maxIncomeMonthIndex = monthIndex
                }
                
                // Расход
                var expense: Double = 0
                if includeMaintenance {
                    expense += monthData.expensesMaintenance ?? 0
                }
                if includeOperating {
                    expense += monthData.expensesOperational ?? 0
                }
                expense += monthData.expensesOther ?? 0
                
                if expense > maxExpenseValue {
                    maxExpenseValue = expense
                    maxExpenseYear = year
                    maxExpenseMonthIndex = monthIndex
                }
            }
        }
        
        let maxIncomeMonth: String? = {
            guard let year = maxIncomeYear, let monthIndex = maxIncomeMonthIndex else { return nil }
            return "\(monthNames[monthIndex]) \(year)"
        }()
        
        let maxExpenseMonth: String? = {
            guard let year = maxExpenseYear, let monthIndex = maxExpenseMonthIndex else { return nil }
            return "\(monthNames[monthIndex]) \(year)"
        }()
        
        // Дополнительные метрики
        let rentPerM2 = incomePerSquareMeter(income: avgIncome, area: area)
        let incomeExpenseRatio = annualExpense > 0 ? round((annualIncome / annualExpense) * 100) / 100 : 0
        let profitPerM2 = area > 0 ? round(((avgIncome - avgExpense) / area) * 100) / 100 : 0
        
        // Концентрация арендаторов
        let tenantsIncomes = property.tenants.map { $0.income ?? 0 }
        let maxTenant = tenantsIncomes.max() ?? 0
        let sumTenants = tenantsIncomes.reduce(0, +)
        let tenantConcentration = sumTenants > 0 ? round((maxTenant / sumTenants * 100) * 10) / 10 : 0
        
        // IRR расчет
        let netCashFlow = (avgIncome - avgExpense) * 12
        let exitPrice = property.exitPrice ?? 0
        let irr = calculateIRR(
            investment: price,
            annualCashFlow: netCashFlow,
            holdingYears: ownYears > 0 ? ownYears : 1,
            exitPrice: exitPrice
        )
        
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
            roi: price > 0 ? cashOnCashReturn(cashFlow: netCashFlow, cashInvested: price) : 0,
            grm: price > 0 ? grossRentMultiplier(price: price, annualIncome: annualIncome) : nil,
            incomePerM2: incomePerSquareMeter(income: avgIncome, area: area),
            capRate: price > 0 ? capitalizationRate(
                income: avgIncome * 12,
                expenses: avgExpense * 12 + propertyTax + insuranceCost,
                price: price
            ) : 0,
            efficiency: efficiencyCoefficient(income: avgIncome, area: area),
            efficiencyLevel: efficiencyRating(efficiencyCoefficient(income: avgIncome, area: area)),
            payback: price > 0 ? paybackPeriod(investment: price, annualCashFlow: netCashFlow) : nil,
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
    
    /// Рассчитывает IRR (Internal Rate of Return) методом бисекции
    /// IRR - это ставка дисконтирования, при которой NPV = 0
    private static func calculateIRR(
        investment: Double,
        annualCashFlow: Double,
        holdingYears: Double,
        exitPrice: Double
    ) -> Double? {
        // Если нет инвестиции или отрицательный cash flow без exit price, IRR не может быть рассчитан
        guard investment > 0 else { return nil }
        
        // Если cash flow отрицательный и нет exit price, IRR не может быть рассчитан
        if annualCashFlow <= 0 && exitPrice <= 0 {
            return nil
        }
        
        // Функция для расчета NPV при заданной ставке дисконтирования
        func npv(rate: Double) -> Double {
            var npvValue = -investment // Начальная инвестиция (отрицательная)
            
            // Добавляем годовые cash flows
            let yearsCount = Int(holdingYears)
            if yearsCount >= 1 {
                for year in 1...yearsCount {
                    npvValue += annualCashFlow / pow(1.0 + rate, Double(year))
                }
            } else {
                // Если holdingYears < 1, используем пропорциональный расчет
                npvValue += annualCashFlow * holdingYears / pow(1.0 + rate, holdingYears)
            }
            
            // Добавляем exit price в последний год
            if exitPrice > 0 {
                npvValue += exitPrice / pow(1.0 + rate, holdingYears)
            }
            
            return npvValue
        }
        
        // Используем метод бисекции для поиска IRR
        // Диапазон поиска: от -0.99 (отрицательные 99%) до 10.0 (1000%)
        var low: Double = -0.99
        var high: Double = 10.0
        let tolerance: Double = 0.0001 // Точность расчета
        let maxIterations = 100
        
        // Проверяем границы
        let npvLow = npv(rate: low)
        let npvHigh = npv(rate: high)
        
        // Если оба значения одного знака, решение не найдено
        if npvLow * npvHigh > 0 {
            // Если NPV всегда положительный даже при -99%, возвращаем nil
            if npvLow > 0 {
                return nil
            }
            // Если NPV всегда отрицательный даже при 1000%, возвращаем nil
            return nil
        }
        
        // Итеративный поиск методом бисекции
        for _ in 0..<maxIterations {
            let mid = (low + high) / 2.0
            let npvMid = npv(rate: mid)
            
            if abs(npvMid) < tolerance {
                // Нашли решение с достаточной точностью
                return round(mid * 10000) / 100 // Округляем до 2 знаков после запятой в процентах
            }
            
            if npvMid > 0 {
                low = mid
            } else {
                high = mid
            }
        }
        
        // Если не нашли точное решение, возвращаем среднее значение
        let result = (low + high) / 2.0
        return round(result * 10000) / 100
    }
    
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

