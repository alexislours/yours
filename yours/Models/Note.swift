import Foundation
import SwiftData

@Model
final class Note {
    var body: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(body: String, person: Person) {
        self.body = body
        createdAt = .now
        updatedAt = .now
        self.person = person
    }

    var firstLine: String {
        let line = body.components(separatedBy: .newlines).first ?? body
        return line.trimmingCharacters(in: .whitespaces)
    }

    var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(createdAt) {
            return "Today at \(createdAt.formatted(.dateTime.hour().minute()))"
        } else if calendar.isDateInYesterday(createdAt) {
            return "Yesterday at \(createdAt.formatted(.dateTime.hour().minute()))"
        } else if calendar.isDate(createdAt, equalTo: .now, toGranularity: .year) {
            return createdAt.formatted(.dateTime.month(.abbreviated).day())
        } else {
            return createdAt.formatted(.dateTime.month(.abbreviated).day().year())
        }
    }
}
