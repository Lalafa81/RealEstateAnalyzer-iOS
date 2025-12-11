//
//  FullScreenChartPlaceholder.swift
//  RealEstateAnalyzer
//
//  Placeholder для полноэкранного графика
//

import SwiftUI

struct FullScreenChartPlaceholder: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Полноэкранный график в разработке")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

