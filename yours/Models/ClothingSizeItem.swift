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
        case .tops: String(localized: "Tops", comment: "Clothing size category: tops")
        case .bottoms: String(localized: "Bottoms", comment: "Clothing size category: bottoms")
        case .shoes: String(localized: "Shoes", comment: "Clothing size category: shoes")
        case .dresses: String(localized: "Dresses", comment: "Clothing size category: dresses")
        case .outerwear: String(localized: "Outerwear", comment: "Clothing size category: outerwear")
        case .underwear: String(localized: "Underwear", comment: "Clothing size category: underwear")
        case .bras: String(localized: "Bras", comment: "Clothing size category: bras")
        case .rings: String(localized: "Rings", comment: "Clothing size category: rings")
        case .hats: String(localized: "Hats", comment: "Clothing size category: hats")
        case .gloves: String(localized: "Gloves", comment: "Clothing size category: gloves")
        case .other: String(localized: "Other", comment: "Clothing size category: other")
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
        case .tops: String(localized: "S, M, L, XL or 38, 40...", comment: "Size placeholder: tops")
        case .bottoms: String(localized: "28, 30, 32 or S, M, L...", comment: "Size placeholder: bottoms")
        case .shoes: String(localized: "US 10, EU 43...", comment: "Size placeholder: shoes")
        case .dresses: String(localized: "2, 4, 6 or XS, S, M...", comment: "Size placeholder: dresses")
        case .outerwear: String(localized: "S, M, L, XL...", comment: "Size placeholder: outerwear")
        case .underwear: String(localized: "S, M, L...", comment: "Size placeholder: underwear")
        case .bras: String(localized: "32B, 34C, 36D...", comment: "Size placeholder: bras")
        case .rings: String(localized: "US 6, EU 52...", comment: "Size placeholder: rings")
        case .hats: String(localized: "S, M, L or 7 1/4...", comment: "Size placeholder: hats")
        case .gloves: String(localized: "XS, S, M, L, XL...", comment: "Size placeholder: gloves")
        case .other: String(localized: "Size...", comment: "Size placeholder: other")
        }
    }
}

// MARK: - CategorizedItem

extension ClothingSizeItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: ClothingSizePredefinedCategory {
        predefinedCategory
    }
}
