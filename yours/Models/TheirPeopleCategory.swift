import Foundation
import SwiftData

@Model
final class TheirPeopleCategory {
    var name: String = ""
    var sfSymbol: String = ""
    var colorName: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \TheirPeopleItem.customCategory)
    var items: [TheirPeopleItem]?

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
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "figure.stand",
        "figure.child",
        "face.smiling.fill",
        "heart.fill",
        "house.fill",
        "briefcase.fill",
        "graduationcap.fill",
        "stethoscope",
        "paintbrush.fill",
        "music.note",
        "sportscourt.fill",
        "fork.knife",
        "airplane",
        "star.fill",
        "square.grid.2x2.fill",
    ]
}

extension TheirPeopleCategory: ManageableCategory {}
