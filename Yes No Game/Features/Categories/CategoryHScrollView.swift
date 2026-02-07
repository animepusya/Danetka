//
//  CategoryScrollView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 26.07.2025.
//

import SwiftUI

struct CategoryHScrollView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showPaywall = false

    let category: Category
    let cards: [Card]

    let onOpenCategory: (Category) -> Void
    let onOpenCard: (Card, Category) -> Void

    var body: some View {
        let hasAccess = purchases.hasAccess(to: category)

        VStack(alignment: .leading, spacing: 0) {

            Button {
                if hasAccess { onOpenCategory(category) }
                else { showPaywall = true }
            } label: {
                HStack {
                    Text(category.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.graphite)
                        .padding(.horizontal)

                    Spacer()

                    if !hasAccess {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.graphite.opacity(0.5))
                            Text(purchases.priceText(for: category.productId ?? "") ?? "$1.99")
                                .font(.caption)
                                .foregroundColor(.graphite.opacity(0.6))
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.graphite.opacity(0.35))
                        .padding(.trailing, 20)
                }
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                let cardWidth: CGFloat = 160
                let horizontalPadding: CGFloat = 16
                let available = geo.size.width - (horizontalPadding * 2)
                let computedSpacing = max(16, available - (cardWidth * 2))
                
                SnappingHScrollView(
                    itemWidth: cardWidth,
                    itemSpacing: computedSpacing,
                    horizontalPadding: horizontalPadding,
                    contentHeight: 220 + 24,
                    snapDuration: 1.2
                ) {
                    HStack(spacing: computedSpacing) {
                        ForEach(cards) { card in
                            Button {
                                if hasAccess { onOpenCard(card, category) }
                                else { showPaywall = true }
                            } label: {
                                IconCardView(card: card)
                                    .frame(width: cardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .frame(height: 220 + 24)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(category: category)
                .environmentObject(purchases)
        }
    }
}

#Preview {
    let sampleCards = CardLoader.load().filter { $0.category == Category.military.rawValue }

    CategoryHScrollView(
        category: .military,
        cards: sampleCards,
        onOpenCategory: { _ in },
        onOpenCard: { _, _ in }
    )
    .environmentObject(PurchaseManager())
}
