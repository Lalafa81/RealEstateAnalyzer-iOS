//
//  DeletePropertySheetView.swift
//  RealEstateAnalyzer
//
//  Кастомный sheet для удаления объекта в стиле Apple Music/Settings
//

import SwiftUI

struct DeletePropertySheetView: View {
    let propertyName: String
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("delete_property_title".localized)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(String(format: "delete_property_message".localized, propertyName))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                if #available(iOS 15.0, *) {
                    Button("cancel".localized) {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button(role: .destructive) {
                        onDelete()
                        isPresented = false
                    } label: {
                        Text("delete_property_action".localized)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button("cancel".localized) {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    
                    Button(action: {
                        onDelete()
                        isPresented = false
                    }) {
                        Text("delete".localized)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(24)
        .modifier(SheetModifier())
    }
}

