//
//  RealEstateAnalyzerApp.swift
//  RealEstateAnalyzer
//
//  Created on iOS 14.2
//

import SwiftUI

@main
struct RealEstateAnalyzerApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    dataManager.loadData()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    @State private var languageChangeID = UUID()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка: Дашборд недвижимости
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("tab_dashboard".localized)
            }
            .tag(0)
            
            // Вкладка: Календарь
            NavigationView {
                CalendarTabView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("tab_calendar".localized)
            }
            .tag(1)
            
            // Вкладка: Аналитика
            NavigationView {
                AnalyticsTabView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("tab_analytics".localized)
            }
            .tag(2)
            
            // Вкладка: Настройки
            NavigationView {
                SettingsTabView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("tab_settings".localized)
            }
            .tag(3)
        }
        .id(languageChangeID) // Обновляем весь UI при изменении языка
        .onAppear {
            // Настройка цвета вкладок на серый
            UITabBar.appearance().unselectedItemTintColor = .gray
            UITabBar.appearance().backgroundColor = .white
        }
        .onChange(of: dataManager.settings?.locale) { _ in
            // Обновляем UI при изменении языка в настройках
            languageChangeID = UUID()
        }
        .onChange(of: dataManager.settings?.summaryCurrency) { _ in
            // Обновляем UI при изменении валюты в настройках
            languageChangeID = UUID()
        }
        .onChange(of: dataManager.settings?.areaUnit) { _ in
            // Обновляем UI при изменении единиц измерения площади
            languageChangeID = UUID()
        }
    }
}

