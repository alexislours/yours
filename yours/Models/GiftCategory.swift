import Foundation
import SwiftData

@Model
final class GiftCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \GiftIdea.customCategory)
    var giftIdeas: [GiftIdea]?

    init(name: String, sfSymbol: String, colorName: String) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.colorName = colorName
        createdAt = .now
        updatedAt = .now
    }

    var itemCount: Int {
        (giftIdeas ?? []).count
    }

    static let curatedSymbols: [String] = [
        "gift.fill",
        "bag.fill",
        "cart.fill",
        "tshirt.fill",
        "shoe.fill",
        "camera.macro",
        "gamecontroller.fill",
        "book.fill",
        "paintbrush.fill",
        "wrench.and.screwdriver.fill",
        "cup.and.saucer.fill",
        "fork.knife",
        "leaf.fill",
        "pawprint.fill",
        "figure.run",
        "dumbbell.fill",
        "camera.fill",
        "music.note",
    ]
}

extension GiftCategory: ManageableCategory {}
