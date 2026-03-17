import Foundation
import SwiftData

@Model
final class ClothingSizeItem {
    var size: String = ""
    var note: String?
    var predefinedCategory: ClothingSizePredefinedCategory = ClothingSizePredefinedCategory.other
    var customCategory: ClothingSizeCategory?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(
        size: String,
        note: String? = nil,
        predefinedCategory: ClothingSizePredefinedCategory = .other,
        customCategory: ClothingSizeCategory? = nil,
        person: Person
    ) {
        self.size = size
        self.note = note
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        createdAt = .now
        updatedAt = .now
        self.person = person
    }
}

// MARK: - Predefined Categories

enum ClothingSizePredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case tops
    case bottoms
    case shoes
    case dresses
    case outerwear
    case underwear
    case bras
    case rings
    case hats
    case gloves
    case other

    nonisolated var displayName: String {
        switch self {
        case .tops: "Tops"
        case .bottoms: "Bottoms"
        case .shoes: "Shoes"
        case .dresses: "Dresses"
        case .outerwear: "Outerwear"
        case .underwear: "Underwear"
        case .bras: "Bras"
        case .rings: "Rings"
        case .hats: "Hats"
        case .gloves: "Gloves"
        case .other: "Other"
        }
    }

    nonisolated var icon: String {
        switch self {
        case .tops: "tshirt.fill"
        case .bottoms: "figure.stand"
        case .shoes: "shoe.fill"
        case .dresses: "figure.stand.dress"
        case .outerwear: "cloud.snow"
        case .underwear: "hanger"
        case .bras: "infinity"
        case .rings: "ring"
        case .hats: "hat.widebrim"
        case .gloves: "hand.raised.fill"
        case .other: "square.grid.2x2"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .tops: "slate"
        case .bottoms: "dusk"
        case .shoes: "terracotta"
        case .dresses: "lavender"
        case .outerwear: "eucalyptus"
        case .underwear: "rose"
        case .bras: "amber"
        case .rings: "ochre"
        case .hats: "sage"
        case .gloves: "clay"
        case .other: "slate"
        }
    }

    nonisolated var placeholder: String {
        switch self {
        case .tops: "S, M, L, XL or 38, 40..."
        case .bottoms: "28, 30, 32 or S, M, L..."
        case .shoes: "US 10, EU 43..."
        case .dresses: "2, 4, 6 or XS, S, M..."
        case .outerwear: "S, M, L, XL..."
        case .underwear: "S, M, L..."
        case .bras: "32B, 34C, 36D..."
        case .rings: "US 6, EU 52..."
        case .hats: "S, M, L or 7 1/4..."
        case .gloves: "XS, S, M, L, XL..."
        case .other: "Size..."
        }
    }
}

// MARK: - CategorizedItem

extension ClothingSizeItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: ClothingSizePredefinedCategory {
        predefinedCategory
    }
}
