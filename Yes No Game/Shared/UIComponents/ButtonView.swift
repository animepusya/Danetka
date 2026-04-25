//
//  ButtonView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 28.07.2025.
//

import SwiftUI

struct ButtonView: View {
    struct Metrics {
        let font: Font
        let verticalPadding: CGFloat
        let horizontalPadding: CGFloat
        let cornerRadius: CGFloat
        let shadowRadius: CGFloat
        let shadowY: CGFloat

        static let standard = Metrics(
            font: .title3,
            verticalPadding: 14,
            horizontalPadding: 16,
            cornerRadius: 16,
            shadowRadius: 4,
            shadowY: 2
        )
    }

    let title: LocalizedStringKey
    let action: () -> Void
    var backgroundColor: Color = .sand
    var isDisabled: Bool = false
    var metrics: Metrics = .standard

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(metrics.font)
                .fontWeight(.semibold)
                .foregroundColor(Color.black.opacity(0.85))
                .padding(.vertical, metrics.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(backgroundColor.opacity(isDisabled ? 0.45 : 1))
                .cornerRadius(metrics.cornerRadius)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: metrics.shadowRadius,
                    x: 0,
                    y: metrics.shadowY
                )
                .padding(.horizontal, metrics.horizontalPadding)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    ButtonView(title: "Жми", action: { print("Кнопка работает") })
}
