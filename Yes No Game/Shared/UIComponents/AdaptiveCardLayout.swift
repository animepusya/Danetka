//
//  AdaptiveCardLayout.swift
//  Danetka
//
//  Created by Руслан Меланин on 23.04.2026.
//

import SwiftUI

struct AdaptiveCardLayout: Equatable {
    static let minimumCardWidth: CGFloat = 160
    static let minimumCardHeight: CGFloat = 220
    static let cardAspectRatio: CGFloat = minimumCardWidth / minimumCardHeight

    static let defaultVisibleCardCount: Int = 2
    static let defaultHorizontalPadding: CGFloat = 16
    static let defaultItemSpacing: CGFloat = 16
    static let defaultRowVerticalPadding: CGFloat = 12

    let availableWidth: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let itemSpacing: CGFloat
    let horizontalPadding: CGFloat
    let rowVerticalPadding: CGFloat

    var contentHeight: CGFloat {
        cardHeight + (rowVerticalPadding * 2)
    }

    static var minimumTwoCardRowWidth: CGFloat {
        minimumRequiredWidth(
            visibleCardCount: defaultVisibleCardCount,
            minimumCardWidth: minimumCardWidth,
            horizontalPadding: defaultHorizontalPadding,
            itemSpacing: defaultItemSpacing
        )
    }

    static func horizontalRow(
        for availableWidth: CGFloat,
        visibleCardCount: Int = defaultVisibleCardCount,
        minimumCardWidth: CGFloat = minimumCardWidth,
        horizontalPadding: CGFloat = defaultHorizontalPadding,
        itemSpacing: CGFloat = defaultItemSpacing,
        rowVerticalPadding: CGFloat = defaultRowVerticalPadding
    ) -> AdaptiveCardLayout {
        let minimumWidth = minimumRequiredWidth(
            visibleCardCount: visibleCardCount,
            minimumCardWidth: minimumCardWidth,
            horizontalPadding: horizontalPadding,
            itemSpacing: itemSpacing
        )
        let resolvedWidth = max(availableWidth.rounded(.down), minimumWidth)
        let reservedWidth = (horizontalPadding * 2) + (itemSpacing * CGFloat(max(visibleCardCount - 1, 0)))
        let totalCardWidth = max(resolvedWidth - reservedWidth, minimumCardWidth * CGFloat(visibleCardCount))
        let cardWidth = max(minimumCardWidth, (totalCardWidth / CGFloat(visibleCardCount)).rounded(.down))
        let cardHeight = (cardWidth / Self.cardAspectRatio).rounded(.down)

        return AdaptiveCardLayout(
            availableWidth: resolvedWidth,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            itemSpacing: itemSpacing,
            horizontalPadding: horizontalPadding,
            rowVerticalPadding: rowVerticalPadding
        )
    }

    private static func minimumRequiredWidth(
        visibleCardCount: Int,
        minimumCardWidth: CGFloat,
        horizontalPadding: CGFloat,
        itemSpacing: CGFloat
    ) -> CGFloat {
        let totalSpacing = itemSpacing * CGFloat(max(visibleCardCount - 1, 0))
        return (minimumCardWidth * CGFloat(visibleCardCount)) + totalSpacing + (horizontalPadding * 2)
    }
}
