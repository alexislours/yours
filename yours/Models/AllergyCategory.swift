import Foundation
import SwiftData

@Model
final class AllergyCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \AllergyItem.customCategory)
    var items: [AllergyItem]?

    init(name: String, sfSymbol: String, colorName: String) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.colorName = colorName
        createdAt = .now
        updatedAt = .now
    }

    var itemCount: Int {
        (items ?? []).count
    }

    static let curatedSymbols: [String] = [
        "fork.knife",
        "pills.fill",
        "wind",
        "leaf.fill",
        "square.grid.2x2.fill",
        "allergens.fill",
        "drop.fill",
        "nose",
        "eye",
        "hand.raised.fill",
        "cross.case.fill",
        "staroflife.fill",
        "heart.fill",
        "lungs.fill",
        "face.smiling",
        "sun.max.fill",
        "tree.fill",
        "cat.fill",
    ]
}

extension AllergyCategory: ManageableCategory {}
