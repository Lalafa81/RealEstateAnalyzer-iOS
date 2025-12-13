//
//  SettingsTabView.swift
//  RealEstateAnalyzer
//
//  Вкладка настроек
//

import SwiftUI

struct SettingsTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCurrency: Currency = .rub
    @State private var selectedLocale: String = "ru"
    @State private var selectedAreaUnit: AreaUnit = .squareMeters
    @State private var refreshID = UUID()
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    private var availableLocales: [(String, String)] {
        [
            ("ru", "settings_language_russian".localized),
            ("en", "settings_language_english".localized)
        ]
    }
    
    var body: some View {
        List {
            // Секция валюты
            Section(header: Text("settings_currency_section".localized)) {
                Picker("settings_default_currency".localized, selection: $selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.displayName).tag(currency)
                    }
                }
                .onChange(of: selectedCurrency) { _ in
                    updateCurrency(selectedCurrency.rawValue)
                }
                
                Text("settings_currency_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Показываем текущую выбранную валюту
                HStack {
                    Text("settings_current_currency".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedCurrency.displayName)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Секция единиц измерения
            Section(header: Text("settings_units_section".localized)) {
                Picker("settings_area_unit".localized, selection: $selectedAreaUnit) {
                    ForEach(AreaUnit.allCases) { unit in
                        Text(unit.localizedName).tag(unit)
                    }
                }
                .onChange(of: selectedAreaUnit) { _ in
                    updateAreaUnit(selectedAreaUnit.rawValue)
                }
                
                Text("settings_area_unit_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Показываем текущую выбранную единицу
                HStack {
                    Text("settings_current_area_unit".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedAreaUnit.localizedName)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Секция локализации
            Section(header: Text("settings_locale_section".localized)) {
                Picker("settings_language".localized, selection: $selectedLocale) {
                    ForEach(availableLocales, id: \.0) { locale in
                        Text(locale.1).tag(locale.0)
                    }
                }
                .onChange(of: selectedLocale) { _ in
                    updateLocale(selectedLocale)
                }
                
                Text("settings_locale_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Показываем текущий выбранный язык
                HStack {
                    Text("settings_current_language".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedLocale == "ru" ? "settings_language_russian".localized : "settings_language_english".localized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Секция данных
            Section(header: Text("settings_data_section".localized)) {
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Text("settings_export_data".localized)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
                
                Text("settings_export_data_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    dataManager.forceReloadFromBundle()
                }) {
                    HStack {
                        Text("settings_reload_data".localized)
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.red)
                    }
                }
                
                Text("settings_reload_data_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Информация о размере данных
                HStack {
                    Text("settings_data_size".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(getDataSize())
                        .font(.caption)
                        .foregroundColor(.secondary)
            }
        }
            
            // Информация о приложении
            Section(header: Text("settings_about_section".localized)) {
                HStack {
                    Text("settings_version".localized)
                    Spacer()
                    Text(Bundle.appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("settings_build_number".localized)
                    Spacer()
                    Text(Bundle.buildNumber)
                        .foregroundColor(.secondary)
                }
            }
        }
        .id(refreshID) // Принудительное обновление при изменении языка
        .navigationTitle("tab_settings".localized)
        .onAppear {
            loadCurrentSettings()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }
    
    private func loadCurrentSettings() {
        // Загружаем текущую валюту из настроек
        if let currencyCode = dataManager.settings?.summaryCurrency,
           let currency = Currency(rawValue: currencyCode) {
            selectedCurrency = currency
        }
        
        // Загружаем текущую локаль
        if let locale = dataManager.settings?.locale {
            selectedLocale = locale
        }
        
        // Загружаем текущую единицу измерения площади
        if let areaUnitCode = dataManager.settings?.areaUnit,
           let areaUnit = AreaUnit(rawValue: areaUnitCode) {
            selectedAreaUnit = areaUnit
        }
    }
    
    private func updateCurrency(_ currencyCode: String) {
        if dataManager.settings == nil {
            dataManager.settings = PropertyData.Settings(locale: selectedLocale, currency: nil, summaryCurrency: currencyCode, areaUnit: selectedAreaUnit.rawValue)
        } else {
            dataManager.settings?.summaryCurrency = currencyCode
        }
        dataManager.saveData()
        
        // Обновляем UI для применения новой валюты
        refreshID = UUID()
    }
    
    private func updateLocale(_ locale: String) {
        if dataManager.settings == nil {
            dataManager.settings = PropertyData.Settings(locale: locale, currency: nil, summaryCurrency: selectedCurrency.rawValue, areaUnit: selectedAreaUnit.rawValue)
        } else {
            dataManager.settings?.locale = locale
        }
        dataManager.saveData()
        
        // Обновляем UI для применения нового языка
        refreshID = UUID()
    }
    
    private func updateAreaUnit(_ areaUnitCode: String) {
        if dataManager.settings == nil {
            dataManager.settings = PropertyData.Settings(locale: selectedLocale, currency: nil, summaryCurrency: selectedCurrency.rawValue, areaUnit: areaUnitCode)
        } else {
            dataManager.settings?.areaUnit = areaUnitCode
        }
        dataManager.saveData()
        
        // Обновляем UI для применения новой единицы измерения
        refreshID = UUID()
    }
    
    private func exportData() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataFileURL = documentsURL.appendingPathComponent("data.json")
        
        if FileManager.default.fileExists(atPath: dataFileURL.path) {
            shareItems = [dataFileURL]
            showShareSheet = true
        }
    }
    
    private func getDataSize() -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataFileURL = documentsURL.appendingPathComponent("data.json")
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: dataFileURL.path),
           let fileSize = attributes[.size] as? Int64 {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: fileSize)
        }
        return "—"
    }
}

// MARK: - ShareSheet для экспорта данных
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
