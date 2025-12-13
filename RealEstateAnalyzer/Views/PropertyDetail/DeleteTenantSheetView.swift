//
//  DeleteTenantSheetView.swift
//  RealEstateAnalyzer
//
//  Кастомный sheet для удаления арендатора в стиле Apple Music/Settings
//

import SwiftUI

struct DeleteTenantSheetView: View {
    let tenantName: String
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("delete_tenant_title".localized)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(String(format: "delete_tenant_message".localized, tenantName))
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
                        Text("delete".localized)
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

