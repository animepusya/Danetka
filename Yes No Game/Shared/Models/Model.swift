//
//  Model.swift
//  Yes No Game
//
//  Created by Руслан Меланин on 26.07.2025.
//

import Foundation

struct Card: Identifiable, Codable, Hashable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let hint: String
    let explanation: String
    let imageName: String?
    let imageUrl: String?
}

enum Category: String, CaseIterable, Hashable {
    case ordinary = "Ordinary"
    case horror = "Horror"
    case science = "Science"
    case anime = "Anime"
    case military = "Military"
    case films = "Films"
    case cartoons = "Cartoons"
    case travel = "Travel"
    case literature = "Literature"

    var title: String {
            NSLocalizedString("category.\(rawValue.lowercased())", comment: "")
    }
    
    var isFree: Bool {
        switch self {
        case .ordinary, .horror: return true
        default: return false
        }
    }
    
    var productId: String? {
        guard !isFree else { return nil }
        return "danetka.category.\(rawValue.lowercased())"
    }
    
    static let unlockAllProductId = "danetka.all_categories"
}
