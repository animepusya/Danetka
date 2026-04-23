//
//  CategoryScrollView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 26.07.2025.
//

import SwiftUI

struct CategoryHScrollView: View {
    let category: Category
    let cards: [Card]
    let containerWidth: CGFloat

    let onOpenCategory: (Category) -> Void
    let onOpenCard: (Card, Category) -> Void

    private var cardLayout: AdaptiveCardLayout {
        AdaptiveCardLayout.horizontalRow(for: containerWidth)
    }

    var body: some View {
        let layout = cardLayout

        VStack(alignment: .leading, spacing: 0) {
            Button {
                onOpenCategory(category)
            } label: {
                HStack {
                    Text(category.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.graphite)
                        .padding(.horizontal)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.graphite.opacity(0.35))
                        .padding(.trailing, 20)
                }
            }
            .buttonStyle(.plain)

            SnappingHScrollView(
                itemWidth: layout.cardWidth,
                itemSpacing: layout.itemSpacing,
                horizontalPadding: layout.horizontalPadding,
                contentHeight: layout.contentHeight,
                snapDuration: 1.2
            ) {
                HStack(spacing: layout.itemSpacing) {
                    ForEach(cards) { card in
                        Button {
                            onOpenCard(card, category)
                        } label: {
                            IconCardView(
                                card: card,
                                width: layout.cardWidth,
                                height: layout.cardHeight
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, layout.rowVerticalPadding)
            }
            .frame(height: layout.contentHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let sampleCards = CardLoader.load().filter { $0.category == Category.military.rawValue }

    CategoryHScrollView(
        category: .military,
        cards: sampleCards,
        containerWidth: AdaptiveCardLayout.minimumTwoCardRowWidth,
        onOpenCategory: { _ in },
        onOpenCard: { _, _ in }
    )
}
