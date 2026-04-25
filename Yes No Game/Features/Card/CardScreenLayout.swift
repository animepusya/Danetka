//
//  CardScreenLayout.swift
//  Danetka
//
//  Created by Codex on 24.04.2026.
//

import SwiftUI

struct CardScreenLayout {
    struct Typography {
        let title: Font
        let primaryText: Font
        let secondaryText: Font
        let titleLineSpacing: CGFloat
        let bodyLineSpacing: CGFloat
    }

    struct TextPanelMetrics {
        let spacing: CGFloat
        let padding: CGFloat
        let cornerRadius: CGFloat
        let shadowRadius: CGFloat
    }

    struct TopControlsMetrics {
        let spacing: CGFloat
        let horizontalPadding: CGFloat
        let topPadding: CGFloat
        let splitViewBackButtonLeadingOffset: CGFloat
        let chipButton: DirectionalChipButton.Metrics
    }

    struct BottomControlsMetrics {
        let spacing: CGFloat
        let bottomPadding: CGFloat
        let maxWidth: CGFloat
        let hintButton: ButtonView.Metrics
        let expandableButton: ExpandableButtonView.Metrics
    }

    let typography: Typography
    let textPanel: TextPanelMetrics
    let topControls: TopControlsMetrics
    let bottomControls: BottomControlsMetrics
    let contentHorizontalPadding: CGFloat
    let contentMaxWidth: CGFloat
    let bottomScrollPadding: CGFloat

    @MainActor
    static func make(
        containerSize: CGSize,
        safeAreaInsets: EdgeInsets,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> CardScreenLayout {
        let isPad = Device.current.isPad
        let isSplitView = Device.current.isPadSplitView(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass
        )
        let scale = resolvedScale(
            for: containerSize.width,
            isPad: isPad,
            isSplitView: isSplitView
        )

        func scaled(_ value: CGFloat) -> CGFloat {
            guard isPad else { return value }
            return (value * scale).rounded(.toNearestOrAwayFromZero)
        }

        let typography = Typography(
            title: isPad
                ? .system(size: scaled(Base.titleFontSize), weight: .bold)
                : .largeTitle,
            primaryText: isPad
                ? .system(size: scaled(Base.bodyFontSize), weight: .regular)
                : .body,
            secondaryText: isPad
                ? .system(size: scaled(Base.bodyFontSize), weight: .regular)
                : .body,
            titleLineSpacing: isPad ? scaled(Base.titleLineSpacing) : 0,
            bodyLineSpacing: isPad ? scaled(Base.bodyLineSpacing) : 0
        )

        let contentHorizontalPadding = isPad
            ? scaled(Base.iPadContentHorizontalPadding)
            : Base.phoneHorizontalPadding
        let contentMaxWidth = isPad
            ? min(
                max(containerSize.width - (contentHorizontalPadding * 2), Base.minimumReadableWidth),
                maxContentWidth(for: containerSize.width, scale: scale)
            )
            : .infinity

        let splitViewBackButtonLeadingOffset = isSplitView
            ? splitViewBackButtonLeadingOffset(for: containerSize.width)
            : 0
        let splitViewTopOffset = isSplitView
            ? splitViewBackButtonTopOffset(scale: scale, safeAreaTop: safeAreaInsets.top)
            : 0

        return CardScreenLayout(
            typography: typography,
            textPanel: TextPanelMetrics(
                spacing: scaled(Base.textPanelSpacing),
                padding: scaled(Base.textPanelPadding),
                cornerRadius: scaled(Base.textPanelCornerRadius),
                shadowRadius: scaled(Base.textPanelShadowRadius)
            ),
            topControls: TopControlsMetrics(
                spacing: scaled(Base.topControlsSpacing),
                horizontalPadding: Base.phoneHorizontalPadding,
                topPadding: Base.topControlsTopPadding + splitViewTopOffset,
                splitViewBackButtonLeadingOffset: splitViewBackButtonLeadingOffset,
                chipButton: DirectionalChipButton.Metrics(
                    font: isPad
                        ? .system(size: scaled(Base.chipFontSize), weight: .semibold)
                        : .subheadline.weight(.semibold),
                    contentSpacing: scaled(Base.chipContentSpacing),
                    verticalPadding: scaled(Base.chipVerticalPadding),
                    horizontalPadding: scaled(Base.chipHorizontalPadding),
                    shadowRadius: scaled(Base.controlShadowRadius),
                    shadowY: scaled(Base.controlShadowY)
                )
            ),
            bottomControls: BottomControlsMetrics(
                spacing: scaled(Base.bottomControlsSpacing),
                bottomPadding: scaled(Base.bottomControlsBottomPadding),
                maxWidth: isPad
                    ? min(
                        max(0, containerSize.width - (scaled(Base.iPadBottomControlsSideMargin) * 2)),
                        Base.iPadBottomControlsMaxWidth
                    )
                    : .infinity,
                hintButton: ButtonView.Metrics(
                    font: isPad
                        ? .system(size: scaled(Base.primaryButtonFontSize), weight: .semibold)
                        : .title3,
                    verticalPadding: scaled(Base.primaryButtonVerticalPadding),
                    horizontalPadding: scaled(Base.phoneHorizontalPadding),
                    cornerRadius: scaled(Base.primaryButtonCornerRadius),
                    shadowRadius: scaled(Base.controlShadowRadius),
                    shadowY: scaled(Base.controlShadowY)
                ),
                expandableButton: ExpandableButtonView.Metrics(
                    titleFont: isPad
                        ? .system(size: scaled(Base.primaryButtonFontSize), weight: .semibold)
                        : .title3,
                    explanationFont: isPad
                        ? .system(size: scaled(Base.bodyFontSize), weight: .regular)
                        : .body,
                    stackSpacing: scaled(Base.expandableStackSpacing),
                    explanationPadding: scaled(Base.expandableExplanationPadding),
                    verticalPadding: scaled(Base.primaryButtonVerticalPadding),
                    horizontalPadding: scaled(Base.expandableHorizontalPadding),
                    outerHorizontalPadding: scaled(Base.phoneHorizontalPadding),
                    cornerRadius: scaled(Base.primaryButtonCornerRadius),
                    explanationCornerRadius: scaled(Base.expandableExplanationCornerRadius),
                    shadowRadius: scaled(Base.controlShadowRadius),
                    shadowY: scaled(Base.controlShadowY)
                )
            ),
            contentHorizontalPadding: contentHorizontalPadding,
            contentMaxWidth: contentMaxWidth,
            bottomScrollPadding: scaled(Base.bottomScrollPadding)
        )
    }
}

fileprivate extension CardScreenLayout {
    enum Base {
        static let phoneHorizontalPadding: CGFloat = 16
        static let iPadContentHorizontalPadding: CGFloat = 20
        static let minimumReadableWidth: CGFloat = 320

        static let titleFontSize: CGFloat = 34
        static let bodyFontSize: CGFloat = 17
        static let primaryButtonFontSize: CGFloat = 20
        static let chipFontSize: CGFloat = 15

        static let titleLineSpacing: CGFloat = 3
        static let bodyLineSpacing: CGFloat = 4

        static let textPanelSpacing: CGFloat = 20
        static let textPanelPadding: CGFloat = 16
        static let textPanelCornerRadius: CGFloat = 16
        static let textPanelShadowRadius: CGFloat = 5

        static let topControlsSpacing: CGFloat = 10
        static let topControlsTopPadding: CGFloat = 16
        static let chipContentSpacing: CGFloat = 6
        static let chipVerticalPadding: CGFloat = 8
        static let chipHorizontalPadding: CGFloat = 12

        static let bottomControlsSpacing: CGFloat = 10
        static let bottomControlsBottomPadding: CGFloat = 10
        static let iPadBottomControlsSideMargin: CGFloat = 32
        static let iPadBottomControlsMaxWidth: CGFloat = 920
        static let primaryButtonVerticalPadding: CGFloat = 14
        static let primaryButtonCornerRadius: CGFloat = 16
        static let expandableStackSpacing: CGFloat = 10
        static let expandableHorizontalPadding: CGFloat = 14
        static let expandableExplanationPadding: CGFloat = 12
        static let expandableExplanationCornerRadius: CGFloat = 12

        static let controlShadowRadius: CGFloat = 4
        static let controlShadowY: CGFloat = 2
        static let bottomScrollPadding: CGFloat = 180

        static let iPadScaleLowerWidth: CGFloat = 390
        static let iPadScaleUpperWidth: CGFloat = 1180
        static let iPadMinimumScale: CGFloat = 1.28
        static let iPadFullscreenMinimumScale: CGFloat = 1.68
        static let iPadMaximumScale: CGFloat = 2.05
        static let iPadSplitViewMaximumScale: CGFloat = 1.64

        static let splitViewSceneRatioTolerance: CGFloat = 0.96
        static let splitViewMinimumReservedLeading: CGFloat = 84
        static let splitViewMaximumReservedLeading: CGFloat = 124
        static let splitViewReservedLeadingWidthRatio: CGFloat = 0.14
        static let splitViewMinimumTopOffset: CGFloat = 8
        static let splitViewMaximumTopOffset: CGFloat = 18
    }

    static func resolvedScale(for width: CGFloat, isPad: Bool, isSplitView: Bool) -> CGFloat {
        guard isPad else { return 1 }

        let progress = normalized(
            value: width,
            lowerBound: Base.iPadScaleLowerWidth,
            upperBound: Base.iPadScaleUpperWidth
        )
        var scale = Base.iPadMinimumScale + ((Base.iPadMaximumScale - Base.iPadMinimumScale) * progress)

        if isSplitView {
            scale = min(scale, Base.iPadSplitViewMaximumScale)
        } else {
            scale = max(scale, Base.iPadFullscreenMinimumScale)
        }

        return min(max(scale, Base.iPadMinimumScale), Base.iPadMaximumScale)
    }

    static func maxContentWidth(for width: CGFloat, scale: CGFloat) -> CGFloat {
        let spaciousWidthBonus = max(0, scale - Base.iPadFullscreenMinimumScale) * 360
        let maxWidth = 900 + spaciousWidthBonus
        return min(maxWidth, max(width - (Base.iPadContentHorizontalPadding * 2), Base.minimumReadableWidth))
    }

    static func splitViewBackButtonLeadingOffset(for width: CGFloat) -> CGFloat {
        let reservedLeading = min(
            Base.splitViewMaximumReservedLeading,
            max(Base.splitViewMinimumReservedLeading, width * Base.splitViewReservedLeadingWidthRatio)
        )
        return max(0, reservedLeading - Base.phoneHorizontalPadding)
    }

    static func splitViewBackButtonTopOffset(scale: CGFloat, safeAreaTop: CGFloat) -> CGFloat {
        let safeAreaInfluence = min(max(safeAreaTop * 0.2, 0), Base.splitViewMaximumTopOffset)
        let scaledOffset = Base.splitViewMinimumTopOffset * scale
        return min(
            Base.splitViewMaximumTopOffset,
            max(Base.splitViewMinimumTopOffset, scaledOffset + safeAreaInfluence)
        )
    }

    static func normalized(value: CGFloat, lowerBound: CGFloat, upperBound: CGFloat) -> CGFloat {
        guard upperBound > lowerBound else { return 0 }
        let rawValue = (value - lowerBound) / (upperBound - lowerBound)
        return min(max(rawValue, 0), 1)
    }
}

private struct Device {
    static let current = Device()

    @MainActor
    var isPad: Bool {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
        #else
        false
        #endif
    }

    @MainActor
    func isPadSplitView(
        containerSize: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        guard isPad else { return false }

        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
            let sceneSize = normalizedSize(scene.coordinateSpace.bounds.size)
            let containerSize = normalizedSize(containerSize)
            let screenSize = normalizedSize(scene.screen.bounds.size)
            let sceneWidthRatio = sceneSize.width / max(screenSize.width, 1)
            let containerWidthRatio = containerSize.width / max(screenSize.width, 1)
            let widthRatio = min(sceneWidthRatio, containerWidthRatio)

            if widthRatio < CardScreenLayout.Base.splitViewSceneRatioTolerance {
                return true
            }
        }
        #endif

        return horizontalSizeClass == .compact && containerSize.width > 430
    }

    private func normalizedSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: min(size.width, size.height),
            height: max(size.width, size.height)
        )
    }
}
