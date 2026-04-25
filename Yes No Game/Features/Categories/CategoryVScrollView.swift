//
//  CategoryCardsView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 04.08.2025.
//

import SwiftUI

struct CategoryVScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let category: Category
    let cards: [Card]
    let onOpenCard: (Card, Category) -> Void

    private let topControlsSpacing: CGFloat = 10
    private let topControlsPadding: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            let cardLayout = AdaptiveCardLayout.verticalGrid(for: geometry.size.width)
            let backButtonAdjustment = AdaptiveWindowLayout.backButtonAdjustment(
                containerSize: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets,
                horizontalSizeClass: horizontalSizeClass
            )

            VStack(alignment: .leading, spacing: cardLayout.itemSpacing) {
                HStack(spacing: topControlsSpacing) {
                    DirectionalChipButton(
                        title: "nav.back",
                        direction: .back,
                        action: { dismiss() },
                        style: .neutral
                    )
                    .padding(.leading, backButtonAdjustment.leading)

                    Spacer()
                }
                .padding(.top, topControlsPadding + backButtonAdjustment.top)
                .padding(.horizontal, topControlsPadding)

                ScrollView {
                    LazyVGrid(columns: cardLayout.gridColumns, spacing: cardLayout.itemSpacing) {
                        ForEach(cards) { card in
                            Button {
                                onOpenCard(card, category)
                            } label: {
                                IconCardView(
                                    card: card,
                                    width: cardLayout.cardWidth,
                                    height: cardLayout.cardHeight
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, cardLayout.horizontalPadding)
                    .padding(.vertical, cardLayout.rowVerticalPadding)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .background(
                Image("mainmenu")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let viewModel = MainViewModel()
    let sampleCategory: Category = .military
    let sampleCards = viewModel.cards(for: sampleCategory)

    CategoryVScrollView(
        category: sampleCategory,
        cards: sampleCards,
        onOpenCard: { _, _ in }
    )
}
