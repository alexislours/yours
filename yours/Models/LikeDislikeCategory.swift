import Foundation
import SwiftData

@Model
final class LikeDislikeCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \LikeDislikeItem.customCategory)
    var items: [LikeDislikeItem]?

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
        "music.note",
        "tv",
        "book.fill",
        "figure.run",
        "airplane",
        "tshirt.fill",
        "sportscourt.fill",
        "pawprint.fill",
        "paintpalette.fill",
        "leaf.fill",
        "person.fill",
        "square.grid.2x2.fill",
        "star.fill",
        "heart.fill",
        "cup.and.saucer.fill",
        "gamecontroller.fill",
        "camera.fill",
    ]
}

extension LikeDislikeCategory: ManageableCategory {}
