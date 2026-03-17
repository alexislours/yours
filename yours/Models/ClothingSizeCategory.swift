import Foundation
import SwiftData

@Model
final class ClothingSizeCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \ClothingSizeItem.customCategory)
    var items: [ClothingSizeItem]?

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
        "tshirt.fill",
        "shoe.fill",
        "hanger",
        "figure.dress.line.vertical.figure",
        "cloud.snow",
        "figure.walk",
        "hat.cap.fill",
        "eyeglasses",
        "bag.fill",
        "sparkles",
        "star.fill",
        "heart.fill",
        "ruler",
        "scissors",
        "paintpalette.fill",
        "tag.fill",
        "crown.fill",
        "gym.bag.fill",
    ]
}

extension ClothingSizeCategory: ManageableCategory {}
