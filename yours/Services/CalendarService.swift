import EventKit

@MainActor
final class CalendarService {
    static let shared = CalendarService()

    private(set) var eventStore = EKEventStore()

    private init() {}

    enum AccessResult {
        case granted
        case denied
        case permanentlyDenied
    }

    func requestAccess() async -> AccessResult {
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .denied || status == .restricted {
            return .permanentlyDenied
        }
        do {
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            return granted ? .granted : .denied
        } catch {
            return .denied
        }
    }

    func makeEvent(from importantDate: ImportantDate) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = importantDate.title
        event.isAllDay = true
        event.startDate = importantDate.nextOccurrence
        event.endDate = importantDate.nextOccurrence
        event.notes = importantDate.note
        event.calendar = eventStore.defaultCalendarForNewEvents

        if let rule = makeRecurrenceRule(from: importantDate.recurrenceFrequency) {
            event.recurrenceRules = [rule]
        }

        return event
    }

    private func makeRecurrenceRule(from frequency: RecurrenceFrequency) -> EKRecurrenceRule? {
        let ekFrequency: EKRecurrenceFrequency? = switch frequency {
        case .never: nil
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        }
        guard let ekFrequency else { return nil }
        return EKRecurrenceRule(recurrenceWith: ekFrequency, interval: 1, end: nil)
    }
}
