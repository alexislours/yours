import Foundation

// MARK: - Export

extension DataExportImportService {
    static func export(person: Person) throws -> ExportResult {
        let notes = exportNotes(person)
        let dates = exportDates(person)
        let gifts = exportGiftIdeas(person)
        let askAbout = exportAskAbout(person)
        let likeDislike = exportLikeDislike(person)
        let clothingSizes = exportClothingSizes(person)
        let allergies = exportAllergies(person)
        let foodOrders = exportFoodOrders(person)
        let quirks = exportQuirks(person)
        let theirPeople = exportTheirPeople(person)
        let petNames = exportPetNames(person)

        let metadata = PersonExportMetadata(
            name: person.name,
            relationshipStart: CalendarDateFormat.string(from: person.relationshipStart),
            gender: person.gender.rawValue,
            birthday: person.birthday.map { CalendarDateFormat.string(from: $0) },
            notes: notes.isEmpty ? nil : notes,
            importantDates: dates.dates.isEmpty ? nil : dates.dates,
            dateCategories: dates.categories.isEmpty ? nil : dates.categories,
            giftIdeas: gifts.ideas.isEmpty ? nil : gifts.ideas,
            giftCategories: gifts.categories.isEmpty ? nil : gifts.categories,
            askAboutItems: askAbout.isEmpty ? nil : askAbout,
            likeDislikeItems: likeDislike.items.isEmpty ? nil : likeDislike.items,
            likeDislikeCategories: likeDislike.categories.isEmpty ? nil : likeDislike.categories,
            clothingSizeItems: clothingSizes.items.isEmpty ? nil : clothingSizes.items,
            clothingSizeCategories: clothingSizes.categories.isEmpty ? nil : clothingSizes.categories,
            allergyItems: allergies.items.isEmpty ? nil : allergies.items,
            allergyCategories: allergies.categories.isEmpty ? nil : allergies.categories,
            foodOrderItems: foodOrders.items.isEmpty ? nil : foodOrders.items,
            foodOrderCategories: foodOrders.categories.isEmpty ? nil : foodOrders.categories,
            quirks: quirks.isEmpty ? nil : quirks,
            theirPeopleItems: theirPeople.items.isEmpty ? nil : theirPeople.items,
            theirPeopleCategories: theirPeople.categories.isEmpty ? nil : theirPeople.categories,
            petNames: petNames.isEmpty ? nil : petNames
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(metadata)

        var entries: [ZipEntry] = [ZipEntry(filename: "backup.json", data: jsonData)]
        if let photoData = person.photoData {
            entries.append(ZipEntry(filename: "photo.jpg", data: photoData))
        }

        let zipData = ZipArchive.create(entries: entries)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("yours-backup.zip")
        try zipData.write(to: tempURL, options: [.atomic, .completeFileProtection])

        return ExportResult(fileURL: tempURL)
    }

    // MARK: - Export Helpers

    private static func exportNotes(_ person: Person) -> [NoteExportData] {
        (person.notes ?? []).map {
            NoteExportData(id: UUID().uuidString, body: $0.body, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
    }

    private static func exportDates(_ person: Person) -> (
        dates: [ImportantDateExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.importantDates ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                ImportantDateExportData(
                    id: UUID().uuidString, title: item.title, date: CalendarDateFormat.string(from: item.date), note: item.note,
                    recurrenceFrequency: item.recurrenceFrequency.rawValue, predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportGiftIdeas(_ person: Person) -> (
        ideas: [GiftIdeaExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.giftIdeas ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { idea, catMap in
                GiftIdeaExportData(
                    id: UUID().uuidString, title: idea.title, note: idea.note,
                    price: idea.price.map { "\($0)" }, urlString: idea.urlString,
                    status: idea.status.rawValue, predefinedCategory: idea.predefinedCategory.rawValue,
                    customCategoryId: idea.customCategory.flatMap { catMap.id(for: $0) },
                    linkedDateTitle: idea.linkedDate?.title, createdAt: idea.createdAt, updatedAt: idea.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportAskAbout(_ person: Person) -> [AskAboutItemExportData] {
        (person.askAboutItems ?? []).map {
            AskAboutItemExportData(
                id: UUID().uuidString, title: $0.title, isDone: $0.isDone,
                dueDate: $0.dueDate.map { CalendarDateFormat.string(from: $0) }, createdAt: $0.createdAt, updatedAt: $0.updatedAt
            )
        }
    }

    private static func exportLikeDislike(_ person: Person) -> (
        items: [LikeDislikeItemExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.likeDislikeItems ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                LikeDislikeItemExportData(
                    id: UUID().uuidString, name: item.name, note: item.note,
                    kind: item.kind.rawValue, predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportClothingSizes(_ person: Person) -> (
        items: [ClothingSizeItemExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.clothingSizeItems ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                ClothingSizeItemExportData(
                    id: UUID().uuidString, size: item.size, note: item.note,
                    predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportAllergies(_ person: Person) -> (
        items: [AllergyItemExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.allergyItems ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                AllergyItemExportData(
                    id: UUID().uuidString, name: item.name, note: item.note,
                    predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportFoodOrders(_ person: Person) -> (
        items: [FoodOrderItemExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.foodOrderItems ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                FoodOrderItemExportData(
                    id: UUID().uuidString, place: item.place, order: item.order, note: item.note,
                    predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    sortOrder: item.sortOrder, createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportQuirks(_ person: Person) -> [QuirkExportData] {
        (person.quirks ?? []).map {
            QuirkExportData(id: UUID().uuidString, text: $0.text, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
    }

    private static func exportTheirPeople(_ person: Person) -> (
        items: [TheirPeopleItemExportData], categories: [CategoryExportData]
    ) {
        let result = exportCategorized(
            items: person.theirPeopleItems ?? [],
            categoryOf: \.customCategory,
            categoryInfo: { CategoryInfo(name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName) },
            mapItem: { item, catMap in
                TheirPeopleItemExportData(
                    id: UUID().uuidString, name: item.name, note: item.note,
                    predefinedCategory: item.predefinedCategory.rawValue,
                    customCategoryId: item.customCategory.flatMap { catMap.id(for: $0) },
                    createdAt: item.createdAt, updatedAt: item.updatedAt
                )
            }
        )
        return (result.items, result.categories)
    }

    private static func exportPetNames(_ person: Person) -> [PetNameExportData] {
        (person.petNames ?? []).map {
            PetNameExportData(id: UUID().uuidString, text: $0.text, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
    }
}
