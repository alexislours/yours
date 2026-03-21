import Foundation
import SwiftData

// MARK: - Import

extension DataExportImportService {
    static func importData(from url: URL, into person: Person, modelContext: ModelContext) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileData = try Data(contentsOf: url)

        if ZipArchive.isZip(fileData) {
            try importFromZip(fileData, into: person, modelContext: modelContext)
        } else {
            try importFromJSON(fileData, into: person, modelContext: modelContext)
        }
    }

    private static func importFromZip(_ data: Data, into person: Person, modelContext: ModelContext) throws {
        let entries = ZipArchive.extract(from: data)
        let byName = Dictionary(entries.map { ($0.filename, $0.data) }, uniquingKeysWith: { first, _ in first })

        guard let jsonData = byName["backup.json"] else {
            throw ImportError.missingBackupJSON
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let metadata = try decoder.decode(PersonExportMetadata.self, from: jsonData)

        apply(metadata: metadata, photoData: byName["photo.jpg"], to: person, modelContext: modelContext)
    }

    private static func importFromJSON(_ data: Data, into person: Person, modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let metadata = try decoder.decode(PersonExportMetadata.self, from: data)

        apply(metadata: metadata, photoData: nil, to: person, modelContext: modelContext)
    }

    private static func apply(metadata: PersonExportMetadata, photoData: Data?, to person: Person, modelContext: ModelContext) {
        person.name = metadata.name
        if let date = CalendarDateFormat.date(from: metadata.relationshipStart) {
            person.relationshipStart = date
        }
        if let gender = Person.Gender(rawValue: metadata.gender) {
            person.gender = gender
        }
        person.birthday = metadata.birthday.flatMap { CalendarDateFormat.date(from: $0) }
        if let photoData {
            person.photoData = photoData
        }
        importNotes(from: metadata, into: person, modelContext: modelContext)
        importDates(from: metadata, into: person, modelContext: modelContext)
        importGiftIdeas(from: metadata, into: person, modelContext: modelContext)
        importAskAbout(from: metadata, into: person, modelContext: modelContext)
        importLikeDislike(from: metadata, into: person, modelContext: modelContext)
        importClothingSizes(from: metadata, into: person, modelContext: modelContext)
        importAllergies(from: metadata, into: person, modelContext: modelContext)
        importFoodOrders(from: metadata, into: person, modelContext: modelContext)
        importQuirks(from: metadata, into: person, modelContext: modelContext)
        importTheirPeople(from: metadata, into: person, modelContext: modelContext)
        importPetNames(from: metadata, into: person, modelContext: modelContext)
        importDreams(from: metadata, into: person, modelContext: modelContext)
    }

    // MARK: - Import Helpers

    private static func importNotes(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedNotes = metadata.notes else { return }
        for note in person.notes ?? [] {
            modelContext.delete(note)
        }
        for data in importedNotes {
            let note = Note(body: data.body, person: person)
            note.createdAt = data.createdAt
            note.updatedAt = data.updatedAt
            modelContext.insert(note)
        }
    }

    private static func importDates(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.importantDates, existingItems: person.importantDates ?? [],
                categoryDatas: metadata.dateCategories
            ),
            modelContext: modelContext,
            createCategory: { DateCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let parsedDate = CalendarDateFormat.date(from: data.date) ?? .now
                let importantDate = ImportantDate(
                    title: data.title, date: parsedDate, note: data.note,
                    recurrenceFrequency: RecurrenceFrequency(rawValue: data.recurrenceFrequency) ?? .never,
                    predefinedCategory: ImportantDatePredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] }, person: person
                )
                importantDate.createdAt = data.createdAt
                importantDate.updatedAt = data.updatedAt
                return importantDate
            }
        )
    }

    private static func importGiftIdeas(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedGiftIdeas = metadata.giftIdeas else { return }
        for idea in person.giftIdeas ?? [] {
            modelContext.delete(idea)
        }
        var giftCategoryById: [String: GiftCategory] = [:]
        for catData in metadata.giftCategories ?? [] {
            let cat = GiftCategory(name: catData.name, sfSymbol: catData.sfSymbol, colorName: catData.colorName)
            modelContext.insert(cat)
            giftCategoryById[catData.id] = cat
        }
        for data in importedGiftIdeas {
            let linked = data.linkedDateTitle.flatMap { title in
                (person.importantDates ?? []).first { $0.title == title }
            }
            let idea = GiftIdea(
                title: data.title, note: data.note,
                price: data.price.flatMap { Decimal(string: $0) }, urlString: data.urlString,
                status: GiftStatus(rawValue: data.status) ?? .idea,
                predefinedCategory: data.predefinedCategory.flatMap { GiftOccasion(rawValue: $0) } ?? .justBecause,
                customCategory: data.customCategoryId.flatMap { giftCategoryById[$0] },
                linkedDate: linked, person: person
            )
            idea.createdAt = data.createdAt
            idea.updatedAt = data.updatedAt
            modelContext.insert(idea)
        }
    }

    private static func importAskAbout(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedAskAboutItems = metadata.askAboutItems else { return }
        for item in person.askAboutItems ?? [] {
            modelContext.delete(item)
        }
        for data in importedAskAboutItems {
            let item = AskAboutItem(title: data.title, person: person, dueDate: data.dueDate.flatMap { CalendarDateFormat.date(from: $0) })
            item.isDone = data.isDone
            item.createdAt = data.createdAt
            item.updatedAt = data.updatedAt ?? data.createdAt
            modelContext.insert(item)
        }
    }

    private static func importLikeDislike(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.likeDislikeItems, existingItems: person.likeDislikeItems ?? [],
                categoryDatas: metadata.likeDislikeCategories
            ),
            modelContext: modelContext,
            createCategory: { LikeDislikeCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let item = LikeDislikeItem(
                    name: data.name, note: data.note,
                    kind: LikeDislikeItem.Kind(rawValue: data.kind) ?? .like,
                    predefinedCategory: LikeDislikePredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] }, person: person
                )
                item.createdAt = data.createdAt
                item.updatedAt = data.updatedAt
                return item
            }
        )
    }

    private static func importClothingSizes(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.clothingSizeItems, existingItems: person.clothingSizeItems ?? [],
                categoryDatas: metadata.clothingSizeCategories
            ),
            modelContext: modelContext,
            createCategory: { ClothingSizeCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let item = ClothingSizeItem(
                    size: data.size, note: data.note,
                    predefinedCategory: ClothingSizePredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] }, person: person
                )
                item.createdAt = data.createdAt
                item.updatedAt = data.updatedAt
                return item
            }
        )
    }

    private static func importAllergies(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.allergyItems, existingItems: person.allergyItems ?? [],
                categoryDatas: metadata.allergyCategories
            ),
            modelContext: modelContext,
            createCategory: { AllergyCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let item = AllergyItem(
                    name: data.name, note: data.note,
                    predefinedCategory: AllergyPredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] }, person: person
                )
                item.createdAt = data.createdAt
                item.updatedAt = data.updatedAt
                return item
            }
        )
    }

    private static func importFoodOrders(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.foodOrderItems, existingItems: person.foodOrderItems ?? [],
                categoryDatas: metadata.foodOrderCategories
            ),
            modelContext: modelContext,
            createCategory: { FoodOrderCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let item = FoodOrderItem(
                    place: data.place, order: data.order, note: data.note,
                    predefinedCategory: FoodOrderPredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] },
                    sortOrder: data.sortOrder, person: person
                )
                item.createdAt = data.createdAt
                item.updatedAt = data.updatedAt
                return item
            }
        )
    }

    private static func importQuirks(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedQuirks = metadata.quirks else { return }
        for item in person.quirks ?? [] {
            modelContext.delete(item)
        }
        for data in importedQuirks {
            let item = Quirk(text: data.text, person: person)
            item.createdAt = data.createdAt
            item.updatedAt = data.updatedAt ?? data.createdAt
            modelContext.insert(item)
        }
    }

    private static func importTheirPeople(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        importCategorized(
            input: ImportInput(
                items: metadata.theirPeopleItems, existingItems: person.theirPeopleItems ?? [],
                categoryDatas: metadata.theirPeopleCategories
            ),
            modelContext: modelContext,
            createCategory: { TheirPeopleCategory(name: $0, sfSymbol: $1, colorName: $2) },
            createItem: { data, categoryById in
                let item = TheirPeopleItem(
                    name: data.name, note: data.note,
                    predefinedCategory: TheirPeoplePredefinedCategory(rawValue: data.predefinedCategory) ?? .other,
                    customCategory: data.customCategoryId.flatMap { categoryById[$0] }, person: person
                )
                item.createdAt = data.createdAt
                item.updatedAt = data.updatedAt
                return item
            }
        )
    }

    private static func importPetNames(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedPetNames = metadata.petNames else { return }
        for item in person.petNames ?? [] {
            modelContext.delete(item)
        }
        for data in importedPetNames {
            let item = PetName(text: data.text, person: person)
            item.createdAt = data.createdAt
            item.updatedAt = data.updatedAt
            modelContext.insert(item)
        }
    }

    private static func importDreams(from metadata: PersonExportMetadata, into person: Person, modelContext: ModelContext) {
        guard let importedDreams = metadata.dreams else { return }
        for item in person.dreams ?? [] {
            modelContext.delete(item)
        }
        for data in importedDreams {
            let item = Dream(text: data.text, person: person)
            item.createdAt = data.createdAt
            item.updatedAt = data.updatedAt
            modelContext.insert(item)
        }
    }
}
