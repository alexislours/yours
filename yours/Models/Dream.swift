import Foundation
import SwiftData

@Model
final class Dream {
    var text: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(text: String, person: Person) {
        self.text = text
        createdAt = .now
        updatedAt = .now
        self.person = person
    }

    var formattedDate: String {
        createdAt.formatted(.dateTime.month(.wide).year())
    }
}
