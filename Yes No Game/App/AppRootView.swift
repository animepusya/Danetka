//
//  AppRootView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 08.08.2025.
//

import SwiftUI

struct AppRootView: View {
    @State private var showLaunchScreen = true
    
    @State private var selectedSection: AppSection = .categories
    @StateObject private var mainViewModel = MainViewModel()
    
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(selectedSection.titleKey)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.graphite)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        AppMenuView(
                            selectedSection: selectedSection,
                            onSelectSection: { selected in
                                selectedSection = selected
                                if selected != .categories { path.removeAll() }
                            },
                            onRandomCard: {
                                if let route = mainViewModel.makeRandomCardRoute() {
                                    if mainViewModel.spoilerPrompt == nil {
                                        path.append(route)
                                    }
                                }
                            }
                        )
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .category(let category):
                        CategoryVScrollView(
                            category: category,
                            cards: mainViewModel.cards(for: category),
                            onOpenCard: { card, cat in
                                if let route = mainViewModel.makeCardRoute(card, in: cat, isRandomMode: false) {
                                    if mainViewModel.spoilerPrompt == nil {
                                        path.append(route)
                                    }
                                }
                            }
                        )
                        
                    case .card(let card, let allCards, let isRandomMode):
                        CardView(
                            viewModel: CardViewModel(
                                singleCard: card,
                                allCards: allCards,
                                isRandomMode: isRandomMode
                            )
                        )
                    }
                }
                .sheet(item: $mainViewModel.spoilerPrompt) { prompt in
                    SpoilerWarningSheet(
                        category: prompt.category,
                        onContinue: {
                            if let route = mainViewModel.consumePendingRoute(dontShowAgain: false) {
                                path.append(route)
                            }
                        },
                        onDontShowAgain: {
                            if let route = mainViewModel.consumePendingRoute(dontShowAgain: true) {
                                path.append(route)
                            }
                        }
                    )
                }
        }
        .overlay {
            if showLaunchScreen {
                LaunchOverlayView {
                    showLaunchScreen = false
                }
                .transition(.identity)
                .zIndex(1)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch selectedSection {
        case .categories:
            MainView(
                viewModel: mainViewModel,
                onOpenCategory: { category in
                    if let route = mainViewModel.makeCategoryRoute(category) {
                        if mainViewModel.spoilerPrompt == nil {
                            path.append(route)
                        }
                    }
                },
                onOpenCard: { card, category in
                    if let route = mainViewModel.makeCardRoute(card, in: category, isRandomMode: false) {
                        if mainViewModel.spoilerPrompt == nil {
                            path.append(route)
                        }
                    }
                }
            )
            
        case .settings:
            SettingsView()
            
        case .rules:
            RulesView()
        }
    }
}
