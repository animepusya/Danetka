//
//  ChipButton.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 21.01.2026.
//

import SwiftUI

struct DirectionalChipButton: View {
    struct Metrics {
        let font: Font
        let contentSpacing: CGFloat
        let verticalPadding: CGFloat
        let horizontalPadding: CGFloat
        let shadowRadius: CGFloat
        let shadowY: CGFloat

        static let standard = Metrics(
            font: .subheadline.weight(.semibold),
            contentSpacing: 6,
            verticalPadding: 8,
            horizontalPadding: 12,
            shadowRadius: 4,
            shadowY: 2
        )
    }

    enum Direction {
        case back
        case forward
    }

    let title: LocalizedStringKey
    let direction: Direction
    let action: () -> Void

    var style: Style = .neutral
    var isDisabled: Bool = false
    var metrics: Metrics = .standard

    enum Style {
        case neutral
        case accent
    }

    var body: some View {
        Button(action: action) {
            content
                .font(metrics.font)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(foregroundColor)
                .padding(.vertical, metrics.verticalPadding)
                .padding(.horizontal, metrics.horizontalPadding)
                .background(background)
                .clipShape(Capsule())
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: metrics.shadowRadius,
                    x: 0,
                    y: metrics.shadowY
                )
                .opacity(isDisabled ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var content: some View {
        switch direction {
        case .back:
            HStack(spacing: metrics.contentSpacing) {
                Image(systemName: "chevron.left")
                Text(title)
            }

        case .forward:
            HStack(spacing: metrics.contentSpacing) {
                Text(title)
                Image(systemName: "chevron.right")
            }
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .neutral:
            return .white
        case .accent:
            return Color.black.opacity(0.85)
        }
    }

    private var background: some View {
        Group {
            switch style {
            case .neutral:
                Capsule().fill(Color.black.opacity(0.35))
            case .accent:
                Capsule().fill(Color.sand)
            }
        }
    }
}
#Preview {
    DirectionalChipButton(title: "Hello", direction: .back, action: {})
}
