import Foundation
import SwiftData

@Model
final class FoodOrderCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \FoodOrderItem.customCategory)
    var items: [FoodOrderItem]?

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
        "cup.and.saucer.fill",
        "fork.knife",
        "takeoutbag.and.cup.and.straw.fill",
        "wineglass.fill",
        "birthday.cake.fill",
        "leaf.fill",
        "flame.fill",
        "carrot.fill",
        "fish.fill",
        "mug.fill",
        "popcorn.fill",
        "frying.pan.fill",
        "refrigerator.fill",
        "cart.fill",
        "bag.fill",
        "star.fill",
        "heart.fill",
        "square.grid.2x2.fill",
    ]
}

extension FoodOrderCategory: ManageableCategory {}
