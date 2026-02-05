//
//  PaywallView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 27.01.2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager

    let category: Category

    @State private var isBusy = false
    @State private var errorText: String?

    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                Text(category.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("paywall.subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                VStack(spacing: 10) {
                    if let pid = category.productId {
                        ActionButtonView(
                            title: "paywall.unlock_category",
                            trailingText: purchases.priceText(for: pid) ?? "$1.99",
                            style: .primary,
                            isDisabled: isBusy,
                            isLoading: isBusy
                        ) {
                            Task { await buyCategory(pid) }
                        }
                    }
                    
                    ActionButtonView(
                        title: "paywall.unlock_all",
                        trailingText: purchases.priceText(for: Category.unlockAllProductId) ?? "$4.99",
                        style: .secondary,
                        isDisabled: isBusy,
                        isLoading: isBusy
                    ) {
                        Task { await buyAll() }
                    }
                    
                    ActionButtonView(
                        title: "paywall.restore",
                        trailingSystemImage: "arrow.clockwise",
                        style: .secondary,
                        isDisabled: isBusy,
                        isLoading: isBusy
                    ) {
                        Task { await restore() }
                    }
                }
                
                Button("paywall.close") { dismiss() }
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .presentationDetents([.medium])
        .task {
            await purchases.loadProductsIfNeeded()
        }
        .onChange(of: purchases.ownedProductIds) { _, _ in
            if purchases.hasAccess(to: category) {
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func buyCategory(_ productId: String) async {
        await runBusyAction {
            await purchases.buy(category: category)
        }
    }

    private func buyAll() async {
        await runBusyAction {
            await purchases.buyUnlockAll()
        }
    }

    private func restore() async {
        await runBusyAction {
            await purchases.restorePurchases()
            if !purchases.hasAccess(to: category) {
                errorText = NSLocalizedString("paywall.restore_none", comment: "")
            }
        }
    }

    private func runBusyAction(_ action: @escaping () async -> Void) async {
        errorText = nil
        isBusy = true
        defer { isBusy = false }
        await action()
    }
}

#Preview {
    PaywallView(category: .anime)
        .environmentObject(PurchaseManager())
}
