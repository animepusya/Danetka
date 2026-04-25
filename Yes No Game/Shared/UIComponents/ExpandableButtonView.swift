//
//  ExpandableButton.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 30.07.2025.
//

import SwiftUI

struct ExpandableButtonView: View {
    struct Metrics {
        let titleFont: Font
        let explanationFont: Font
        let stackSpacing: CGFloat
        let explanationPadding: CGFloat
        let verticalPadding: CGFloat
        let horizontalPadding: CGFloat
        let outerHorizontalPadding: CGFloat
        let cornerRadius: CGFloat
        let explanationCornerRadius: CGFloat
        let shadowRadius: CGFloat
        let shadowY: CGFloat

        static let standard = Metrics(
            titleFont: .title3,
            explanationFont: .body,
            stackSpacing: 10,
            explanationPadding: 12,
            verticalPadding: 14,
            horizontalPadding: 14,
            outerHorizontalPadding: 16,
            cornerRadius: 16,
            explanationCornerRadius: 12,
            shadowRadius: 4,
            shadowY: 2
        )
    }

    let title: LocalizedStringKey
    let explanation: String
    let backgroundColor: Color
    @Binding var isExpanded: Bool
    var metrics: Metrics = .standard

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.35)) {
                isExpanded.toggle()
            }
        }) {
            VStack(spacing: metrics.stackSpacing) {
                Text(title)
                    .font(metrics.titleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black.opacity(0.85))

                if isExpanded {
                    Text(explanation)
                        .font(metrics.explanationFont)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(metrics.explanationPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: metrics.explanationCornerRadius)
                                .fill(Color.black.opacity(0.35))
                        )
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, metrics.verticalPadding)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(metrics.cornerRadius)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: metrics.shadowRadius,
                x: 0,
                y: metrics.shadowY
            )
            .padding(.horizontal, metrics.outerHorizontalPadding)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExpandableButtonPreview()
}

struct ExpandableButtonPreview: View {
    @State private var isExpanded = false

    var body: some View {
        ExpandableButtonView(
            title: "card.full_story",
            explanation: "Text tipa explanation i ewe bolwe texta dl9 primera choto ya ne ponyal pochemu tut vse tak krasivo a pri ispolzovanii kakoy to trash proishodit i ne tak kruta srazu vyglyadit a net vse taki tut toje trash mne nujen .alignment and .padding",
            backgroundColor: .blue,
            isExpanded: $isExpanded
        )
        .padding()
        .background(Color.gray.opacity(0.15))
    }
}
