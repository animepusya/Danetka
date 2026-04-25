//
//  AdaptiveWindowLayout.swift
//  Danetka
//
//  Created by Codex on 25.04.2026.
//

import SwiftUI

struct AdaptiveWindowLayout {
    struct BackButtonAdjustment: Equatable {
        let leading: CGFloat
        let top: CGFloat

        static let none = BackButtonAdjustment(leading: 0, top: 0)
    }

    @MainActor
    static var isPad: Bool {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
        #else
        false
        #endif
    }

    @MainActor
    static func backButtonAdjustment(
        containerSize: CGSize,
        safeAreaInsets: EdgeInsets,
        horizontalSizeClass: UserInterfaceSizeClass?,
        controlScale: CGFloat = 1
    ) -> BackButtonAdjustment {
        guard isPadSplitView(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass
        ) else {
            return .none
        }

        return BackButtonAdjustment(
            leading: splitViewBackButtonLeadingOffset(for: containerSize.width),
            top: splitViewBackButtonTopOffset(
                controlScale: controlScale,
                safeAreaTop: safeAreaInsets.top
            )
        )
    }

    @MainActor
    static func isPadSplitView(
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

            if widthRatio < Metrics.splitViewSceneRatioTolerance {
                return true
            }
        }
        #endif

        return horizontalSizeClass == .compact && containerSize.width > Metrics.phoneMaximumWidth
    }
}

private extension AdaptiveWindowLayout {
    enum Metrics {
        static let phoneHorizontalPadding: CGFloat = 16
        static let phoneMaximumWidth: CGFloat = 430

        static let splitViewSceneRatioTolerance: CGFloat = 0.96
        static let splitViewMinimumReservedLeading: CGFloat = 84
        static let splitViewMaximumReservedLeading: CGFloat = 124
        static let splitViewReservedLeadingWidthRatio: CGFloat = 0.14
        static let splitViewMinimumTopOffset: CGFloat = 8
        static let splitViewMaximumTopOffset: CGFloat = 18
    }

    static func splitViewBackButtonLeadingOffset(for width: CGFloat) -> CGFloat {
        let reservedLeading = min(
            Metrics.splitViewMaximumReservedLeading,
            max(Metrics.splitViewMinimumReservedLeading, width * Metrics.splitViewReservedLeadingWidthRatio)
        )
        return max(0, reservedLeading - Metrics.phoneHorizontalPadding)
    }

    static func splitViewBackButtonTopOffset(
        controlScale: CGFloat,
        safeAreaTop: CGFloat
    ) -> CGFloat {
        let safeAreaInfluence = min(max(safeAreaTop * 0.2, 0), Metrics.splitViewMaximumTopOffset)
        let scaledOffset = Metrics.splitViewMinimumTopOffset * controlScale
        return min(
            Metrics.splitViewMaximumTopOffset,
            max(Metrics.splitViewMinimumTopOffset, scaledOffset + safeAreaInfluence)
        )
    }

    static func normalizedSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: min(size.width, size.height),
            height: max(size.width, size.height)
        )
    }
}
