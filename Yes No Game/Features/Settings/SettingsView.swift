//
//  AboutView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 19.01.2026.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.openURL) private var openURL
    
    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                sectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings.description_title")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("settings.description")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                    }
                }

                sectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings.app_title")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button(action: openSystemSettings) {
                            HStack {
                                Label("settings.language", systemImage: "globe")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .opacity(0.9)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)

                        dividerLine()

                        HStack {
                            Label("settings.version", systemImage: "number")
                                .foregroundColor(.white)

                            Spacer()

                            Text(appVersionText)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .font(.body)
                        
                        dividerLine()

                        Link(destination: URL(string: "https://animepusya.github.io/legal/danetka/privacypolicy")!) {
                            HStack {
                                Label("settings.privacy_policy", systemImage: "hand.raised")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .opacity(0.9)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                        }
                    }
                }

                sectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings.purchases_title")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button(action: {
                            Task { await purchases.buyUnlockAll() }
                        }) {
                            HStack {
                                Label("settings.unlock_all", systemImage: "lock.open")
                                Spacer()
                                Text(purchases.priceText(for: Category.unlockAllProductId) ?? "$4.99")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)

                        dividerLine()
                        
                        Button(action: {
                            Task { await purchases.restorePurchases() }
                        }) {
                            HStack {
                                Label("settings.restore_purchases", systemImage: "arrow.clockwise")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }

                sectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings.contact_title")
                            .font(.headline)
                            .foregroundColor(.white)

                        contactLink(
                            title: "Email",
                            systemImage: "envelope",
                            urlString: "mailto:rus.melanin@mail.ru"
                        )

                        dividerLine()

                        contactLink(
                            title: "GitHub",
                            systemImage: "link",
                            urlString: "https://github.com/animepusya"
                        )

                        dividerLine()

                        contactLink(
                            title: "Telegram",
                            systemImage: "paperplane",
                            urlString: "https://t.me/animepusya"
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            .padding(.horizontal, 16)
        }
        .background(
            Image("mainmenu")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .task {
            await purchases.loadProductsIfNeeded()
        }
    }
    
    

    private func openSystemSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }

    private func sectionCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.5))
                .shadow(radius: 5)
        )
    }

    private func dividerLine() -> some View {
        Divider().overlay(Color.white.opacity(0.25))
    }

    private func contactLink(title: String, systemImage: String, urlString: String) -> some View {
        Link(destination: URL(string: urlString)!) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .opacity(0.9)
            }
            .contentShape(Rectangle())
            .foregroundColor(.white)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseManager())
}

