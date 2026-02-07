//
//  CategoryCardsView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 04.08.2025.
//

import SwiftUI

struct CategoryVScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showPaywall = false

    let category: Category
    let cards: [Card]
    let onOpenCard: (Card, Category) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                DirectionalChipButton(
                    title: "nav.back",
                    direction: .back,
                    action: { dismiss() },
                    style: .neutral
                )
                Spacer()
            }
            .padding([.top, .horizontal])

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cards) { card in
                        Button {
                            // ✅ единая логика: либо открываем, либо paywall
                            if purchases.hasAccess(to: category) {
                                onOpenCard(card, category)
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            IconCardView(card: card)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .background(
            Image("mainmenu")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .onAppear {
            if !purchases.hasAccess(to: category) {
                showPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(category: category)
                .environmentObject(purchases)
        }
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
