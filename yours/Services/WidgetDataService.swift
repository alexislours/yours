import SwiftData
import UIKit
import WidgetKit

@MainActor
protocol WidgetReloading {
    func reloadAllTimelines()
}

extension WidgetCenter: WidgetReloading {}

@MainActor
enum WidgetDataService {
    private static var lastPhotoData: Data?
    private static var lastDownsizedPhoto: Data?

    static func sync(
        modelContext: ModelContext,
        widgetReloader: WidgetReloading = WidgetCenter.shared
    ) {
        let descriptor = FetchDescriptor<Person>()
        let persons = (try? modelContext.fetch(descriptor)) ?? []
        let person = persons.first

        let payload = WidgetPayload(
            person: person.map(mapPerson),
            upcomingDates: person.map(mapDates) ?? [],
            lastUpdated: .now
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(payload) else { return }
        if SharedDefaults.write(data) {
            widgetReloader.reloadAllTimelines()
        }
    }

    private static func mapPerson(_ person: Person) -> WidgetPersonData {
        WidgetPersonData(
            name: person.name,
            relationshipStart: person.relationshipStart,
            durationDescription: person.durationDescription,
            formattedStartDate: person.relationshipStart.formatted(
                .dateTime.month(.wide).day().year()
            ),
            photoData: downsizePhoto(person.photoData),
            hasCompletedOnboarding: true
        )
    }

    private static func mapDates(_ person: Person) -> [WidgetDateData] {
        person.upcomingDates.prefix(5).map { date in
            WidgetDateData(
                title: date.title,
                icon: date.categoryIcon,
                daysUntilNext: date.daysUntilNext,
                countdownText: date.countdownText,
                isToday: date.daysUntilNext == 0
            )
        }
    }

    private static func downsizePhoto(_ data: Data?) -> Data? {
        guard let data else {
            lastPhotoData = nil
            lastDownsizedPhoto = nil
            return nil
        }

        if data == lastPhotoData, let cached = lastDownsizedPhoto {
            return cached
        }

        guard let image = UIImage(data: data) else { return nil }

        let maxSize: CGFloat = 300
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        let result = resized.jpegData(compressionQuality: 0.7)

        lastPhotoData = data
        lastDownsizedPhoto = result

        return result
    }
}
