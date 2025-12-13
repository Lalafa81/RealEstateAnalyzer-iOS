//
//  CalendarTabView.swift
//  RealEstateAnalyzer
//
//  Вкладка календаря
//

import SwiftUI

struct CalendarTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("calendar_development".localized)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("tab_calendar".localized)
    }
}
