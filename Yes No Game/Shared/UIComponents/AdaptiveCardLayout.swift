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
    static let defaultGridPreferredCardWidth: CGFloat = 320
    static let defaultMaximumGridColumnCount: Int = 4

    let availableWidth: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let itemSpacing: CGFloat
    let horizontalPadding: CGFloat
    let rowVerticalPadding: CGFloat
    let columnCount: Int

    var contentHeight: CGFloat {
        cardHeight + (rowVerticalPadding * 2)
    }

    var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.fixed(cardWidth), spacing: itemSpacing),
            count: columnCount
        )
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
        fixedColumnLayout(
            for: availableWidth,
            columnCount: visibleCardCount,
            minimumCardWidth: minimumCardWidth,
            horizontalPadding: horizontalPadding,
            itemSpacing: itemSpacing,
            rowVerticalPadding: rowVerticalPadding
        )
    }

    static func verticalGrid(
        for availableWidth: CGFloat,
        minimumCardWidth: CGFloat = minimumCardWidth,
        horizontalPadding: CGFloat = defaultHorizontalPadding,
        itemSpacing: CGFloat = defaultItemSpacing,
        rowVerticalPadding: CGFloat = defaultRowVerticalPadding,
        preferredCardWidth: CGFloat = defaultGridPreferredCardWidth,
        maximumColumnCount: Int = defaultMaximumGridColumnCount
    ) -> AdaptiveCardLayout {
        let columnCount = gridColumnCount(
            for: availableWidth,
            minimumCardWidth: minimumCardWidth,
            preferredCardWidth: preferredCardWidth,
            horizontalPadding: horizontalPadding,
            itemSpacing: itemSpacing,
            maximumColumnCount: maximumColumnCount
        )

        return fixedColumnLayout(
            for: availableWidth,
            columnCount: columnCount,
            minimumCardWidth: minimumCardWidth,
            horizontalPadding: horizontalPadding,
            itemSpacing: itemSpacing,
            rowVerticalPadding: rowVerticalPadding
        )
    }

    private static func fixedColumnLayout(
        for availableWidth: CGFloat,
        columnCount: Int,
        minimumCardWidth: CGFloat,
        horizontalPadding: CGFloat,
        itemSpacing: CGFloat,
        rowVerticalPadding: CGFloat
    ) -> AdaptiveCardLayout {
        let columnCount = max(columnCount, 1)
        let minimumWidth = minimumRequiredWidth(
            visibleCardCount: columnCount,
            minimumCardWidth: minimumCardWidth,
            horizontalPadding: horizontalPadding,
            itemSpacing: itemSpacing
        )
        let resolvedWidth = max(availableWidth.rounded(.down), minimumWidth)
        let reservedWidth = (horizontalPadding * 2) + (itemSpacing * CGFloat(max(columnCount - 1, 0)))
        let totalCardWidth = max(resolvedWidth - reservedWidth, minimumCardWidth * CGFloat(columnCount))
        let cardWidth = max(minimumCardWidth, (totalCardWidth / CGFloat(columnCount)).rounded(.down))
        let cardHeight = (cardWidth / Self.cardAspectRatio).rounded(.down)

        return AdaptiveCardLayout(
            availableWidth: resolvedWidth,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            itemSpacing: itemSpacing,
            horizontalPadding: horizontalPadding,
            rowVerticalPadding: rowVerticalPadding,
            columnCount: columnCount
        )
    }

    private static func gridColumnCount(
        for availableWidth: CGFloat,
        minimumCardWidth: CGFloat,
        preferredCardWidth: CGFloat,
        horizontalPadding: CGFloat,
        itemSpacing: CGFloat,
        maximumColumnCount: Int
    ) -> Int {
        let usableWidth = max(0, availableWidth.rounded(.down) - (horizontalPadding * 2))
        let minimumFittingColumnCount = fittingColumnCount(
            for: usableWidth,
            cardWidth: minimumCardWidth,
            itemSpacing: itemSpacing
        )
        let preferredColumnCount = fittingColumnCount(
            for: usableWidth,
            cardWidth: max(preferredCardWidth, minimumCardWidth),
            itemSpacing: itemSpacing
        )
        let minimumUsefulColumnCount = min(defaultVisibleCardCount, minimumFittingColumnCount)
        let resolvedColumnCount = max(minimumUsefulColumnCount, preferredColumnCount)

        return min(max(maximumColumnCount, 1), max(resolvedColumnCount, 1))
    }

    private static func fittingColumnCount(
        for usableWidth: CGFloat,
        cardWidth: CGFloat,
        itemSpacing: CGFloat
    ) -> Int {
        guard cardWidth > 0 else { return 1 }
        let widthWithTrailingSpacing = usableWidth + itemSpacing
        let columnWidthWithSpacing = cardWidth + itemSpacing
        return max(Int((widthWithTrailingSpacing / columnWidthWithSpacing).rounded(.down)), 1)
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
