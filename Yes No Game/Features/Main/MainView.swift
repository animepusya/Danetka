//
//  MainView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 29.07.2025.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    let onOpenCategory: (Category) -> Void
    let onOpenCard: (Card, Category) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.categoriesWithCards, id: \.self) { category in
                    CategoryHScrollView(
                        category: category,
                        cards: viewModel.cards(for: category),
                        onOpenCategory: { cat in
                            onOpenCategory(cat)
                        },
                        onOpenCard: { card, cat in
                            onOpenCard(card, cat)
                        }
                    )
                }
            }
            .padding(.vertical)
        }
        .task {
            await viewModel.refreshRemoteContentOnce()
        }
        .background(
            Image("mainmenu")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    MainView(
        viewModel: MainViewModel(),
        onOpenCategory: { _ in },
        onOpenCard: { _, _ in }
    )
}
