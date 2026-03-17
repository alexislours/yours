import Foundation
import SwiftData

@Model
final class DateCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \ImportantDate.customCategory)
    var dates: [ImportantDate]?

    init(name: String, sfSymbol: String, colorName: String) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.colorName = colorName
        createdAt = .now
        updatedAt = .now
    }

    var itemCount: Int {
        (dates ?? []).count
    }
}

// MARK: - Curated Palettes

extension DateCategory: ManageableCategory {}

extension DateCategory {
    static let curatedSymbols: [String] = [
        "star.fill",
        "heart.fill",
        "flag.fill",
        "mappin",
        "suitcase.fill",
        "graduationcap.fill",
        "party.popper.fill",
        "medal.fill",
        "stroller.fill",
        "house.fill",
        "briefcase.fill",
        "leaf.fill",
        "pawprint.fill",
        "music.note",
        "trophy.fill",
        "camera.fill",
        "book.fill",
        "gift.fill",
    ]
}
