//
//  CardsRepository.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 27.01.2026.
//

import Foundation

final class CardsRepository {
    static let shared = CardsRepository()
    private init() {}

    private let manifestURL = URL(string: "https://raw.githubusercontent.com/animepusya/YNG-content/refs/heads/main/manifest.json")!
    private lazy var client = RemoteContentClient(manifestURL: manifestURL)
    private let cache = CardsDiskCache()

    private let versionKey = "remote_cards_content_version"

    // MARK: - Public

    func loadCardsDataFallbackToBundle() -> Data? {
        let lang = preferredLang()

        // 1) cache (current lang)
        if let data = cache.read(lang: lang) { return data }

        // 2) bundle (current lang)
        if let data = bundleCardsData(lang: lang) { return data }

        // 3) fallback
        let fallback = fallbackLang(for: lang)
        if let data = cache.read(lang: fallback) { return data }
        return bundleCardsData(lang: fallback)
    }

    func refreshIfNeeded() async throws -> Bool {
        let manifest = try await client.fetchManifest()

        let currentVersion = UserDefaults.standard.integer(forKey: versionKey)
        guard manifest.contentVersion > currentVersion else { return false }

        try await downloadAndCache(lang: "ru", manifest: manifest)
        try await downloadAndCache(lang: "en", manifest: manifest)

        UserDefaults.standard.set(manifest.contentVersion, forKey: versionKey)
        return true
    }
    
    func prefetchImages(from cards: [Card]) {
        let strings = cards.compactMap { $0.imageUrl }.filter { $0.hasPrefix("http") }

        Task.detached(priority: .background) {
            for s in strings {
                guard let url = URL(string: s) else { continue }

                if let cached = ImageDiskCache.shared.load(for: url), !cached.isEmpty {
                    continue
                }

                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    ImageDiskCache.shared.save(data, for: url)
                } catch {
                    // ignore
                }
            }
        }
    }


    // MARK: - Private

    private func downloadAndCache(lang: String, manifest: ContentManifest) async throws {
        guard let path = manifest.cardsPaths[lang] else { return }
        let cardsData = try await client.fetchCardsData(path: path)

        // validation
        _ = try JSONDecoder().decode([Card].self, from: cardsData)

        try cache.write(cardsData, lang: lang)
    }

    private func preferredLang() -> String {
        let id = (Locale.preferredLanguages.first ?? "en").lowercased()
        return id.hasPrefix("ru") ? "ru" : "en"
    }

    private func fallbackLang(for lang: String) -> String {
        lang == "ru" ? "en" : "ru"
    }

    private func bundleCardsData(lang: String) -> Data? {
        guard let url = Bundle.main.url(forResource: "cards_\(lang)", withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }
}
