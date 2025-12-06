//
//  PropertyCalendarView.swift
//  RealEstateAnalyzer
//
//  Календарь объектов недвижимости (заглушка)
//

import SwiftUI

struct CalendarView: View {
    let properties: [Property]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Календарь событий")
                .font(.headline)
            
            Text("Календарь доходов/расходов находится в разработке")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

