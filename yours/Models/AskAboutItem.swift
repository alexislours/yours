import Foundation
import SwiftData

@Model
final class AskAboutItem {
    var title: String = ""
    var isDone: Bool = false
    var dueDate: Date?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(title: String, person: Person, dueDate: Date? = nil) {
        self.title = title
        isDone = false
        self.dueDate = dueDate
        createdAt = .now
        updatedAt = .now
        self.person = person
    }

    var formattedDueDate: String? {
        guard let dueDate else { return nil }
        let calendar = Calendar.current

        if calendar.isDateInToday(dueDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        } else if dueDate < calendar.startOfDay(for: .now) {
            return "Overdue"
        } else if calendar.isDate(dueDate, equalTo: .now, toGranularity: .year) {
            return "By \(dueDate.formatted(.dateTime.month(.abbreviated).day()))"
        } else {
            return "By \(dueDate.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
    }

    var isOverdue: Bool {
        guard let dueDate else { return false }
        return !isDone && dueDate < Calendar.current.startOfDay(for: .now)
    }
}
