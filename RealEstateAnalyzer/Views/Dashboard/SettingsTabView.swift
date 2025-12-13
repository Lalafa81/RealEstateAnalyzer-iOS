//
//  SettingsTabView.swift
//  RealEstateAnalyzer
//
//  Вкладка настроек
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        List {
            Section(header: Text("settings_title".localized)) {
                Text("settings_coming_soon".localized)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("tab_settings".localized)
    }
}
