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
    
    var body: some View {
        NavigationView {
            DashboardView()
        }
    }
}

