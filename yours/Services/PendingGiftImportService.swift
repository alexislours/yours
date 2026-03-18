import Foundation
import os.log
import SwiftData

private let logger = Logger(subsystem: "com.alexislours.yours", category: "PendingGiftImport")

@MainActor
enum PendingGiftImportService {
    static func importPending(for person: Person, in context: ModelContext) {
        let pending = PendingGiftStore.loadAndClearAll()
        guard !pending.isEmpty else { return }

        for gift in pending {
            let occasion = GiftOccasion(rawValue: gift.occasion) ?? .justBecause
            let price: Decimal? = gift.priceString.flatMap { Decimal(string: $0) }

            let idea = GiftIdea(
                title: gift.title,
                note: gift.note,
                price: price,
                urlString: gift.urlString,
                predefinedCategory: occasion,
                person: person
            )
            context.insert(idea)
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to save imported gifts, re-queuing: \(error.localizedDescription)")
            for gift in pending {
                PendingGiftStore.append(gift)
            }
        }
    }
}
