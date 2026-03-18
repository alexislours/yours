import Foundation
import SwiftData

@Model
final class ImportantDate {
    var title: String = ""
    var date: Date = Date.now
    var note: String?
    var recurrenceFrequency: RecurrenceFrequency = RecurrenceFrequency.never
    var predefinedCategory: ImportantDatePredefinedCategory = ImportantDatePredefinedCategory.other
    var customCategory: DateCategory?
    var reminderEnabled: Bool = false
    var reminderDaysBefore: Int = 1
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    @Relationship(deleteRule: .nullify, inverse: \GiftIdea.linkedDate)
    var linkedGiftIdeas: [GiftIdea]?
    var person: Person?

    var isRecurring: Bool {
        recurrenceFrequency != .never
    }

    init(
        title: String,
        date: Date,
        note: String? = nil,
        recurrenceFrequency: RecurrenceFrequency = .never,
        predefinedCategory: ImportantDatePredefinedCategory = .other,
        customCategory: DateCategory? = nil,
        reminderEnabled: Bool = false,
        reminderDaysBefore: Int = 1,
        person: Person
    ) {
        self.title = title
        self.date = date
        self.note = note
        self.recurrenceFrequency = recurrenceFrequency
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        self.reminderEnabled = reminderEnabled
        self.reminderDaysBefore = reminderDaysBefore
        createdAt = .now
        updatedAt = .now
        self.person = person
    }
}

// MARK: - Recurrence Frequency

enum RecurrenceFrequency: String, CaseIterable, Codable {
    case never
    case weekly
    case monthly
    case yearly

    nonisolated var displayName: String {
        switch self {
        case .never: String(localized: "Never", comment: "Recurrence: does not repeat")
        case .weekly: String(localized: "Every week", comment: "Recurrence: repeats weekly")
        case .monthly: String(localized: "Every month", comment: "Recurrence: repeats monthly")
        case .yearly: String(localized: "Every year", comment: "Recurrence: repeats yearly")
        }
    }
}

// MARK: - Predefined Categories

enum ImportantDatePredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case birthday
    case anniversary
    case holiday
    case other

    nonisolated var displayName: String {
        switch self {
        case .birthday: String(localized: "Birthday", comment: "Date category: birthday")
        case .anniversary: String(localized: "Anniversary", comment: "Date category: anniversary")
        case .holiday: String(localized: "Holiday", comment: "Date category: holiday")
        case .other: String(localized: "Other", comment: "Date category: other")
        }
    }

    nonisolated var icon: String {
        switch self {
        case .birthday: "birthday.cake.fill"
        case .anniversary: "heart.fill"
        case .holiday: "star.fill"
        case .other: "calendar"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .birthday: "accentRose"
        case .anniversary: "accentSecondary"
        case .holiday: "caution"
        case .other: "textTertiary"
        }
    }
}

// MARK: - CategorizedItem

extension ImportantDate: CategorizedItem {
    var resolvedPredefinedCategory: ImportantDatePredefinedCategory {
        predefinedCategory
    }
}

// MARK: - Computed Properties

extension ImportantDate {
    /// Next occurrence of this date based on its recurrence frequency.
    var nextOccurrence: Date {
        guard isRecurring else { return date }

        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)

        switch recurrenceFrequency {
        case .never:
            return date
        case .weekly:
            return nextWeeklyOccurrence(calendar: calendar, now: now)
        case .monthly:
            return nextMonthlyOccurrence(calendar: calendar, now: now)
        case .yearly:
            return nextYearlyOccurrence(calendar: calendar, now: now)
        }
    }

    private func nextWeeklyOccurrence(calendar: Calendar, now: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let todayWeekday = calendar.component(.weekday, from: now)
        var daysUntil = weekday - todayWeekday
        if daysUntil < 0 { daysUntil += 7 }
        if daysUntil == 0, date <= now { daysUntil = 7 }
        return calendar.date(byAdding: .day, value: daysUntil, to: now) ?? date
    }

    private func nextMonthlyOccurrence(calendar: Calendar, now: Date) -> Date {
        let dayOfMonth = calendar.component(.day, from: date)
        var comps = calendar.dateComponents([.year, .month], from: now)
        comps.day = dayOfMonth

        if let thisMonth = calendar.date(from: comps), thisMonth >= now {
            return thisMonth
        }

        // Next month
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) {
            var nextComps = calendar.dateComponents([.year, .month], from: nextMonth)
            nextComps.day = dayOfMonth
            return calendar.date(from: nextComps) ?? date
        }
        return date
    }

    private func nextYearlyOccurrence(calendar: Calendar, now: Date) -> Date {
        let comps = calendar.dateComponents([.month, .day], from: date)

        var target = DateComponents()
        target.year = calendar.component(.year, from: now)
        target.month = comps.month
        target.day = comps.day

        if let thisYear = calendar.date(from: target), thisYear >= now {
            return thisYear
        }

        target.year = calendar.component(.year, from: now) + 1
        return calendar.date(from: target) ?? date
    }

    /// Days until next occurrence. 0 means today.
    var daysUntilNext: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        let next = calendar.startOfDay(for: nextOccurrence)
        return max(0, calendar.dateComponents([.day], from: now, to: next).day ?? 0)
    }

    /// Whether a one-time (non-recurring) date is in the past.
    var isPast: Bool {
        guard !isRecurring else { return false }
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        return date < now
    }

    var formattedDate: String {
        (isRecurring ? nextOccurrence : date).formatted(.dateTime.month(.wide).day().year())
    }

    var countdownText: String {
        let days = daysUntilNext
        if days == 0 { return String(localized: "Today", comment: "Countdown: event is today") }
        if days == 1 { return String(localized: "Tomorrow", comment: "Countdown: event is tomorrow") }
        return String(localized: "in \(days) days", comment: "Countdown: days until event")
    }

    var daysSinceText: String? {
        guard isPast else { return nil }
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        let then = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: then, to: now).day ?? 0
        if days == 0 { return String(localized: "Today", comment: "Days since: event was today") }
        if days == 1 { return String(localized: "1 day ago", comment: "Days since: event was yesterday") }
        return String(localized: "\(days) days ago", comment: "Days since: days after event")
    }
}
