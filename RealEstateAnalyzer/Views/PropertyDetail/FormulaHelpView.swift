//
//  FormulaHelpView.swift
//  RealEstateAnalyzer
//
//  Справка с формулой расчета
//

import SwiftUI
import UIKit

struct FormulaHelpView: View {
    let formula: String
    let buttonPosition: CGPoint?
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let popupHeight: CGFloat = 280 // Примерная высота pop-up
            let popupWidth: CGFloat = 320
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            
            // Автоматическое позиционирование относительно кнопки
            let (popupX, popupY): (CGFloat, CGFloat) = {
                guard let buttonPos = buttonPosition else {
                    // Если позиция не известна, центрируем
                    return (geometry.size.width / 2, geometry.size.height / 2)
                }
                
                // Определяем оптимальную позицию pop-up относительно кнопки
                let spacing: CGFloat = 20 // Отступ от кнопки
                let popupHalfHeight = popupHeight / 2
                let popupHalfWidth = popupWidth / 2
                
                // X: центрируем по горизонтали экрана
                let x = min(max(popupHalfWidth + 20, screenWidth / 2), screenWidth - popupHalfWidth - 20)
                
                // Y: позиционируем относительно кнопки
                var y: CGFloat
                
                // Если кнопка в нижней части экрана (ниже 60%)
                if buttonPos.y > screenHeight * 0.6 {
                    // Показываем pop-up выше кнопки
                    y = buttonPos.y - popupHalfHeight - spacing
                    // Но не выше верхней границы экрана
                    y = max(popupHalfHeight + 20, y)
                } else {
                    // Показываем pop-up ниже кнопки
                    y = buttonPos.y + popupHalfHeight + spacing
                    // Но не ниже нижней границы экрана
                    y = min(screenHeight - popupHalfHeight - 20, y)
                }
                
                // Преобразуем глобальные координаты в локальные координаты GeometryReader
                let localY = y - geometry.frame(in: .global).minY
                
                return (x, max(popupHalfHeight + 20, min(geometry.size.height - popupHalfHeight - 20, localY)))
            }()
            
            ZStack {
                // Компактное pop-up окно с автоматическим позиционированием
                VStack(spacing: 16) {
                    // Иконка
                    Image(systemName: "function")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    // Заголовок
                    Text("Формула расчета")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // Формула
                    Text(formula)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    
                    // Кнопка с галочкой
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: popupWidth)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .position(x: popupX, y: popupY)
            }
        }
    }
}

