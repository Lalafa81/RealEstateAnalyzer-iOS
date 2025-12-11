//
//  DeleteYearSheetView.swift
//  RealEstateAnalyzer
//
//  Кастомный sheet для удаления года в стиле Apple Music/Settings
//

import SwiftUI

struct SheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

struct DeleteYearSheetView: View {
    let year: Int
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Удалить год \(String(year))?")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Все данные за этот год будут удалены.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                if #available(iOS 15.0, *) {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Text("Удалить")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    
                    Button(action: {
                        onDelete()
                    }) {
                        Text("Удалить")
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

