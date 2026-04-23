//
//  SnappingHScrollView.swift
//  Danetka
//
//  Created by Руслан Меланин on 07.02.2026.
//

import SwiftUI
import UIKit

// Горизонтальный UIScrollView с докручиванием (snapping) ПОСЛЕ отпускания.
// Во время скролла — свободно, без примагничивания.
// После остановки — плавно, медленно выравнивает карточку к левому padding.
struct SnappingHScrollView<Content: View>: UIViewRepresentable {

    let itemWidth: CGFloat
    let itemSpacing: CGFloat
    let horizontalPadding: CGFloat
    let contentHeight: CGFloat

    // Длительность плавного выравнивания (сек)
    let snapDuration: TimeInterval

    // Опционально: минимальная скорость, при которой лучше дать инерции “прокатиться”
    let velocityThreshold: CGFloat

    let content: Content

    init(
        itemWidth: CGFloat,
        itemSpacing: CGFloat,
        horizontalPadding: CGFloat,
        contentHeight: CGFloat,
        snapDuration: TimeInterval = 0.9,
        velocityThreshold: CGFloat = 0.15,
        @ViewBuilder content: () -> Content
    ) {
        self.itemWidth = itemWidth
        self.itemSpacing = itemSpacing
        self.horizontalPadding = horizontalPadding
        self.contentHeight = contentHeight
        self.snapDuration = snapDuration
        self.velocityThreshold = velocityThreshold
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        scrollView.decelerationRate = .normal

        scrollView.delegate = context.coordinator

        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding
        )

        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        let hostHeightConstraint = host.view.heightAnchor.constraint(equalToConstant: contentHeight)

        scrollView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            hostHeightConstraint,
            host.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])

        context.coordinator.hostingController = host
        context.coordinator.scrollView = scrollView
        context.coordinator.hostHeightConstraint = hostHeightConstraint
        context.coordinator.applyInitialOffsetIfNeeded()
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.itemWidth = itemWidth
        context.coordinator.itemSpacing = itemSpacing
        context.coordinator.horizontalPadding = horizontalPadding
        context.coordinator.contentHeight = contentHeight
        context.coordinator.snapDuration = snapDuration
        context.coordinator.velocityThreshold = velocityThreshold

        uiView.contentInset.left = horizontalPadding
        uiView.contentInset.right = horizontalPadding
        context.coordinator.hostHeightConstraint?.constant = contentHeight

        context.coordinator.hostingController?.rootView = content
        context.coordinator.hostingController?.view.invalidateIntrinsicContentSize()
        context.coordinator.hostingController?.view.setNeedsLayout()
        context.coordinator.hostingController?.view.layoutIfNeeded()
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        context.coordinator.applyInitialOffsetIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            itemWidth: itemWidth,
            itemSpacing: itemSpacing,
            horizontalPadding: horizontalPadding,
            contentHeight: contentHeight,
            snapDuration: snapDuration,
            velocityThreshold: velocityThreshold
        )
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var itemWidth: CGFloat
        var itemSpacing: CGFloat
        var horizontalPadding: CGFloat
        var contentHeight: CGFloat
        var snapDuration: TimeInterval
        var velocityThreshold: CGFloat

        weak var scrollView: UIScrollView?
        var hostingController: UIHostingController<Content>?
        var hostHeightConstraint: NSLayoutConstraint?

        private var isSnapping = false
        private var animator: UIViewPropertyAnimator?
        private var didApplyInitialOffset = false

        init(
            itemWidth: CGFloat,
            itemSpacing: CGFloat,
            horizontalPadding: CGFloat,
            contentHeight: CGFloat,
            snapDuration: TimeInterval,
            velocityThreshold: CGFloat
        ) {
            self.itemWidth = itemWidth
            self.itemSpacing = itemSpacing
            self.horizontalPadding = horizontalPadding
            self.contentHeight = contentHeight
            self.snapDuration = snapDuration
            self.velocityThreshold = velocityThreshold
        }

        private func nearestSnappedOffsetX(for scrollView: UIScrollView) -> CGFloat {
            let stride = itemWidth + itemSpacing

            let rawX = scrollView.contentOffset.x + scrollView.contentInset.left
            let index = (rawX / stride).rounded()

            let snappedX = index * stride - scrollView.contentInset.left
            return max(-scrollView.contentInset.left, snappedX)
        }

        private func animateSnapIfNeeded(scrollView: UIScrollView) {
            guard !isSnapping else { return }

            let targetX = nearestSnappedOffsetX(for: scrollView)
            let currentX = scrollView.contentOffset.x

            if abs(targetX - currentX) < 0.5 { return }

            isSnapping = true
            animator?.stopAnimation(true)

            let targetPoint = CGPoint(x: targetX, y: scrollView.contentOffset.y)

            let animator = UIViewPropertyAnimator(duration: snapDuration, curve: .easeOut) {
                scrollView.setContentOffset(targetPoint, animated: false)
                scrollView.layoutIfNeeded()
            }

            animator.addCompletion { [weak self] _ in
                self?.isSnapping = false
            }

            self.animator = animator
            animator.startAnimation()
        }
        
        func applyInitialOffsetIfNeeded() {
            guard let scrollView, !didApplyInitialOffset else { return }
            didApplyInitialOffset = true

            let x = -scrollView.contentInset.left

            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            }
        }


        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            animator?.stopAnimation(true)
            isSnapping = false
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                animateSnapIfNeeded(scrollView: scrollView)
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            animateSnapIfNeeded(scrollView: scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            isSnapping = false
        }
    }
}
