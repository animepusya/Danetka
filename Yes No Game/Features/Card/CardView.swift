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

    private let bottomOverlayPadding: CGFloat = 180
    private let hintAnchorId = "hintAnchorId"
    private let topAnchorId = "topAnchorId"

    var body: some View {
        VStack {
            if let card = viewModel.currentCard {

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 20) {

                            Color.clear
                                .frame(height: 1)
                                .id(topAnchorId)

                            Text(card.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.black.opacity(0.5))
                                        .shadow(radius: 5)
                                )
                                .padding(.horizontal)

                            Text(card.description)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.black.opacity(0.5))
                                        .shadow(radius: 5)
                                )
                                .padding(.horizontal)

                            if viewModel.showHint {
                                Text(card.hint)
                                    .id(hintAnchorId)
                                    .font(.body)
                                    .foregroundColor(.yellow)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.black.opacity(0.5))
                                            .shadow(radius: 5)
                                    )
                                    .padding(.horizontal)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                        }
                        .padding(.bottom, bottomOverlayPadding)
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
                    HStack(spacing: 10) {
                        DirectionalChipButton(
                            title: "nav.back",
                            direction: .back,
                            action: { dismiss() },
                            style: .neutral
                        )
                        
                        Spacer()
                        
                        if viewModel.isRandomMode {
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
                                isDisabled: isButtonDisabled
                            )
                        }
                    }
                    .padding([.top, .horizontal])
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 10) {
                        ButtonView(
                            title: viewModel.showHint ? "card.hide_hint" : "card.hint",
                            action: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    viewModel.showHint.toggle()
                                }
                            },
                            backgroundColor: Color.sand.opacity(0.65),
                            isDisabled: false
                        )

                        ExpandableButtonView(
                            title: "card.full_story",
                            explanation: card.explanation,
                            backgroundColor: .sand,
                            isExpanded: $isAnswerExpanded
                        )
                    }
                    .padding(.bottom, 10)
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
        .navigationBarHidden(true)
    }
}

#Preview {
    let allCards = CardLoader.load()
    let militaryCards = allCards.filter { $0.category == Category.military.rawValue }
    CardView(viewModel: CardViewModel(cards: militaryCards))
}

