//
//  CardView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 26.07.2025.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var viewModel: CardViewModel
    @State private var isAnswerExpanded = false
    @State private var isButtonDisabled = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let hintAnchorId = "hintAnchorId"
    private let topAnchorId = "topAnchorId"

    var body: some View {
        GeometryReader { geometry in
            let layout = CardScreenLayout.make(
                containerSize: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets,
                horizontalSizeClass: horizontalSizeClass
            )

            VStack {
                if let card = viewModel.currentCard {

                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(alignment: .leading, spacing: layout.textPanel.spacing) {

                                Color.clear
                                    .frame(height: 1)
                                    .id(topAnchorId)

                                textPanel(layout: layout) {
                                    Text(card.title)
                                        .font(layout.typography.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(layout.typography.titleLineSpacing)
                                }

                                textPanel(layout: layout) {
                                    Text(card.description)
                                        .font(layout.typography.primaryText)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(layout.typography.bodyLineSpacing)
                                }

                                if viewModel.showHint {
                                    textPanel(layout: layout) {
                                        Text(card.hint)
                                            .id(hintAnchorId)
                                            .font(layout.typography.secondaryText)
                                            .foregroundColor(.yellow)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(layout.typography.bodyLineSpacing)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                                }
                            }
                            .padding(.horizontal, layout.contentHorizontalPadding)
                            .frame(maxWidth: layout.contentMaxWidth, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.bottom, layout.bottomScrollPadding)
                        }
                        .onChange(of: viewModel.showHint) { _, show in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    if show {
                                        proxy.scrollTo(hintAnchorId, anchor: .top)
                                    } else {
                                        proxy.scrollTo(topAnchorId, anchor: .top)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.currentCard?.id) { _, _ in
                            isAnswerExpanded = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(topAnchorId, anchor: .top)
                                }
                            }
                        }
                        .onChange(of: isAnswerExpanded) { _, expanded in
                            guard expanded, viewModel.showHint else { return }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    proxy.scrollTo(hintAnchorId, anchor: .top)
                                }
                            }
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        topControls(layout: layout)
                            .padding(.top, layout.topControls.topPadding)
                            .padding(.horizontal, layout.topControls.horizontalPadding)
                    }
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: layout.bottomControls.spacing) {
                            ButtonView(
                                title: viewModel.showHint ? "card.hide_hint" : "card.hint",
                                action: {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        viewModel.showHint.toggle()
                                    }
                                },
                                backgroundColor: Color.sand.opacity(0.65),
                                isDisabled: false,
                                metrics: layout.bottomControls.hintButton
                            )

                            ExpandableButtonView(
                                title: "card.full_story",
                                explanation: card.explanation,
                                backgroundColor: .sand,
                                isExpanded: $isAnswerExpanded,
                                metrics: layout.bottomControls.expandableButton
                            )
                        }
                        .frame(maxWidth: layout.bottomControls.maxWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, layout.bottomControls.bottomPadding)
                    }
                    .background(
                        ZStack {
                            if let url = card.imageUrl, !url.isEmpty {
                                RemoteCardImage(urlString: url)
                            } else if let name = card.imageName, !name.isEmpty {
                                Image(name)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.black
                            }
                            Color.black.opacity(0.4)
                        }
                        .ignoresSafeArea()
                    )
                    .animation(.easeInOut(duration: 0.4), value: viewModel.showHint)
                    .animation(.easeInOut(duration: 0.35), value: isAnswerExpanded)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func textPanel<Content: View>(
        layout: CardScreenLayout,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(layout.textPanel.padding)
            .background(
                RoundedRectangle(cornerRadius: layout.textPanel.cornerRadius)
                    .fill(Color.black.opacity(0.5))
                    .shadow(radius: layout.textPanel.shadowRadius)
            )
    }

    private func topControls(layout: CardScreenLayout) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: layout.topControls.spacing) {
                backButton(layout: layout)

                Spacer()

                if viewModel.isRandomMode {
                    nextButton(layout: layout)
                }
            }

            VStack(alignment: .leading, spacing: layout.topControls.spacing) {
                HStack {
                    backButton(layout: layout)
                    Spacer()
                }

                if viewModel.isRandomMode {
                    HStack {
                        Spacer()
                        nextButton(layout: layout)
                    }
                }
            }
        }
    }

    private func backButton(layout: CardScreenLayout) -> some View {
        DirectionalChipButton(
            title: "nav.back",
            direction: .back,
            action: { dismiss() },
            style: .neutral,
            metrics: layout.topControls.chipButton
        )
        .padding(.leading, layout.topControls.splitViewBackButtonLeadingOffset)
    }

    private func nextButton(layout: CardScreenLayout) -> some View {
        DirectionalChipButton(
            title: "nav.next",
            direction: .forward,
            action: {
                guard !isButtonDisabled else { return }

                isButtonDisabled = true
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.nextCard()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isButtonDisabled = false
                }
            },
            style: .accent,
            isDisabled: isButtonDisabled,
            metrics: layout.topControls.chipButton
        )
    }
}

#Preview {
    let allCards = CardLoader.load()
    let militaryCards = allCards.filter { $0.category == Category.military.rawValue }
    CardView(viewModel: CardViewModel(cards: militaryCards))
}
