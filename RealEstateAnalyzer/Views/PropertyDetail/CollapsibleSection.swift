//
//  CollapsibleSection.swift
//  RealEstateAnalyzer
//
//  Переиспользуемый компонент для сворачиваемых секций
//

import SwiftUI

struct CollapsibleSection<Content: View>: View {
    let title: String
    var icon: String? = nil
    var collapsedContent: (() -> AnyView)? = nil
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content
    
    init(
        title: String,
        icon: String? = nil,
        isExpanded: Binding<Bool>,
        collapsedContent: (() -> AnyView)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.collapsedContent = collapsedContent
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DisclosureGroup(isExpanded: $isExpanded) {
                content()
            } label: {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(.purple)
                    }
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    if let collapsedContent = collapsedContent, !isExpanded {
                        collapsedContent()
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

