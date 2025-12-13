//
//  AnalyticsTabView.swift
//  RealEstateAnalyzer
//
//  Вкладка аналитики
//

import SwiftUI

struct AnalyticsTabView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            Section(header: Text("analytics_title".localized)) {
                StatisticsView(properties: dataManager.properties)
            }
        }
        .navigationTitle("tab_analytics".localized)
    }
}
