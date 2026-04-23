//
//  IconCardView.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 28.07.2025.
//

import SwiftUI

struct IconCardView: View {
    let card: Card
    let width: CGFloat
    let height: CGFloat
    
    init(
        card: Card,
        width: CGFloat = AdaptiveCardLayout.minimumCardWidth,
        height: CGFloat? = nil
    ) {
        self.card = card
        self.width = width
        self.height = height ?? (width / AdaptiveCardLayout.cardAspectRatio).rounded(.down)
    }
    
    private var artworkSource: CardArtworkSource {
        if let url = card.imageUrl, !url.isEmpty {
            return .remote(url)
        }
        
        if let name = card.imageName, !name.isEmpty {
            return .local(name)
        }
        
        return .placeholder
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CardArtworkView(source: artworkSource)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            Text(card.title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .shadow(radius: 4)
        }
        .frame(width: width, height: height)
        .shadow(radius: 6)
    }
}

private enum CardArtworkSource {
    case remote(String)
    case local(String)
    case placeholder
}

private struct CardArtworkView: View {
    let source: CardArtworkSource
    
    var body: some View {
        switch source {
        case .remote(let urlString):
            RemoteCardArtworkView(urlString: urlString)
        case .local(let imageName):
            CardArtworkImageView(image: Image(imageName))
        case .placeholder:
            ArtworkPlaceholderView()
        }
    }
}

private struct RemoteCardArtworkView: View {
    let urlString: String
    @StateObject private var loader = RemoteImageLoader()
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                CardArtworkImageView(image: Image(uiImage: uiImage))
            } else {
                ArtworkPlaceholderView()
            }
        }
        .task(id: urlString) {
            loader.loadFromCacheOrNetwork(urlString)
        }
    }
}

private struct CardArtworkImageView: View {
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct ArtworkPlaceholderView: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.15))
            .overlay {
                Image(systemName: "photo")
                    .imageScale(.large)
                    .opacity(0.4)
            }
    }
}

#Preview {
    IconCardView(card: Card(id: 5, category: "Military",
                            title: "Бас Бас Бас это Хардбас",
                            description: "Солдаты стояли на крыше и стреляли в небо. Это спасло город.",
                            hint: "Они стреляли не по врагу.",
                            explanation: "Солдаты запускали сигнальные ракеты, чтобы показать сбитому пилоту, где находится база. Пилот вернулся, сообщил координаты врага — и это спасло город.",
                            imageName: nil,
                            imageUrl: "https://animepusya.github.io/YNG-content/images/missedMeeting.png"))
}
