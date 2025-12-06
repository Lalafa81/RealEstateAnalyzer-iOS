//
//  PropertyCalendarView.swift
//  RealEstateAnalyzer
//
//  Календарь объекта недвижимости
//

import SwiftUI

struct CalendarView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Календарь")
                .font(.headline)
            
            Text("Календарь доходов/расходов будет реализован в следующей версии")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

