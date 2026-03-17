import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("DataExportImportService", .tags(.services, .exportImport))
@MainActor
struct DataExportImportServiceTests {
    // MARK: - Export

    @Suite("Export")
    @MainActor
    struct Export {
        @Test("Produces a valid ZIP containing backup.json")
        func producesValidZip() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx, name: "Alice")

            let result = try DataExportImportService.export(person: person)
            let zipData = try Data(contentsOf: result.fileURL)

            #expect(ZipArchive.isZip(zipData))

            let entries = ZipArchive.extract(from: zipData)
            let filenames = entries.map(\.filename)
            #expect(filenames.contains("backup.json"))

            let jsonData = try #require(entries.first { $0.filename == "backup.json" }?.data)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadata = try decoder.decode(PersonExportMetadata.self, from: jsonData)
            #expect(metadata.name == "Alice")
        }

        @Test("Includes photo when present")
        func includesPhotoWhenPresent() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let fakePhoto = Data([0xFF, 0xD8, 0xFF, 0xE0])
            person.photoData = fakePhoto
            try ctx.save()

            let result = try DataExportImportService.export(person: person)
            let entries = ZipArchive.extract(from: try Data(contentsOf: result.fileURL))
            let photoEntry = entries.first { $0.filename == "photo.jpg" }
            #expect(photoEntry?.data == fakePhoto)
        }

        @Test("Omits photo when absent")
        func omitsPhotoWhenAbsent() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let result = try DataExportImportService.export(person: person)
            let entries = ZipArchive.extract(from: try Data(contentsOf: result.fileURL))
            let filenames = entries.map(\.filename)
            #expect(!filenames.contains("photo.jpg"))
        }
    }

    // MARK: - Import Errors

    @Suite("Import errors")
    @MainActor
    struct ImportErrors {
        @Test("Fails on missing backup.json")
        func failsOnMissingBackupJSON() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let zipData = ZipArchive.create(entries: [
                ZipEntry(filename: "other.txt", data: Data("hello".utf8)),
            ])
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("test-no-backup.zip")
            try zipData.write(to: url)

            #expect(throws: DataExportImportService.ImportError.missingBackupJSON) {
                try DataExportImportService.importData(from: url, into: person, modelContext: ctx)
            }
        }

        @Test("Fails on access denied")
        func failsOnAccessDenied() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let url = URL(string: "x-invalid://not-a-real-file")!

            #expect(throws: DataExportImportService.ImportError.accessDenied) {
                try DataExportImportService.importData(from: url, into: person, modelContext: ctx)
            }
        }
    }

    // MARK: - Import Reconstruction

    @Suite("Import reconstruction")
    @MainActor
    struct ImportReconstruction {
        @Test("Reconstructs all item types with correct relationships")
        func reconstructsAllItemTypes() throws {
            let ctx = TestSupport.makeContext()
            let source = try seedFullPerson(in: ctx)
            let result = try DataExportImportService.export(person: source)

            let target = TestSupport.seedPerson(in: ctx, name: "Empty")
            try DataExportImportService.importData(
                from: result.fileURL, into: target, modelContext: ctx
            )

            #expect(target.name == "Full Person")
            #expect(target.gender == .female)

            let note = try #require((target.notes ?? []).first)
            #expect(note.body == "Remember this")

            let date = try #require((target.importantDates ?? []).first)
            #expect(date.title == "Anniversary")
            #expect(date.isRecurring == true)
            #expect(date.predefinedCategory == .anniversary)

            let gift = try #require((target.giftIdeas ?? []).first)
            #expect(gift.title == "Watch")
            #expect(gift.price == Decimal(string: "99.99"))
            #expect(gift.status == .idea)

            let ask = try #require((target.askAboutItems ?? []).first)
            #expect(ask.title == "Favorite color?")

            let like = try #require((target.likeDislikeItems ?? []).first)
            #expect(like.name == "Jazz")
            #expect(like.kind == .like)

            let size = try #require((target.clothingSizeItems ?? []).first)
            #expect(size.size == "M")

            let allergy = try #require((target.allergyItems ?? []).first)
            #expect(allergy.name == "Peanuts")
            #expect(allergy.predefinedCategory == .food)

            let order = try #require((target.foodOrderItems ?? []).first)
            #expect(order.place == "Cafe")
            #expect(order.order == "Latte")

            let quirk = try #require((target.quirks ?? []).first)
            #expect(quirk.text == "Always late")

            let theirPerson = try #require((target.theirPeopleItems ?? []).first)
            #expect(theirPerson.name == "Mom")
            #expect(theirPerson.predefinedCategory == .mom)
        }

        @Test("Remaps custom category IDs correctly")
        func remapsCustomCategoryIds() throws {
            let ctx = TestSupport.makeContext()
            let source = TestSupport.seedPerson(in: ctx, name: "Source")

            let customCat = DateCategory(name: "Special", sfSymbol: "star", colorName: "yellow")
            ctx.insert(customCat)
            let importantDate = ImportantDate(
                title: "Custom Event",
                date: TestFixtures.referenceDate,
                recurrenceFrequency: .never,
                predefinedCategory: .other,
                customCategory: customCat,
                person: source
            )
            ctx.insert(importantDate)
            try ctx.save()

            let result = try DataExportImportService.export(person: source)

            let target = TestSupport.seedPerson(in: ctx, name: "Target")
            try DataExportImportService.importData(
                from: result.fileURL, into: target, modelContext: ctx
            )

            let targetDate = try #require((target.importantDates ?? []).first)
            let targetCat = try #require(targetDate.customCategory)
            #expect(targetCat.name == "Special")
            #expect(targetCat.sfSymbol == "star")
            #expect(targetCat.colorName == "yellow")
        }
    }

    // MARK: - Round-Trip

    @Suite("Round-trip")
    @MainActor
    struct RoundTrip {
        @Test("Export then import produces equivalent data")
        func roundTripProducesEquivalentData() throws {
            let ctx = TestSupport.makeContext()
            let source = try seedFullPerson(in: ctx)
            let fakePhoto = Data([0xFF, 0xD8, 0xFF, 0xE0])
            source.photoData = fakePhoto
            try ctx.save()

            let result = try DataExportImportService.export(person: source)

            let target = TestSupport.seedPerson(in: ctx, name: "Target")
            try DataExportImportService.importData(
                from: result.fileURL, into: target, modelContext: ctx
            )

            #expect(target.name == source.name)
            #expect(target.gender == source.gender)
            #expect(Calendar.current.isDate(target.relationshipStart, inSameDayAs: source.relationshipStart))
            #expect(Calendar.current.isDate(target.birthday!, inSameDayAs: source.birthday!))
            #expect(target.photoData == fakePhoto)
            #expect((target.notes ?? []).count == (source.notes ?? []).count)
            #expect((target.importantDates ?? []).count == (source.importantDates ?? []).count)
            #expect((target.giftIdeas ?? []).count == (source.giftIdeas ?? []).count)
            #expect((target.askAboutItems ?? []).count == (source.askAboutItems ?? []).count)
            #expect((target.likeDislikeItems ?? []).count == (source.likeDislikeItems ?? []).count)
            #expect((target.clothingSizeItems ?? []).count == (source.clothingSizeItems ?? []).count)
            #expect((target.allergyItems ?? []).count == (source.allergyItems ?? []).count)
            #expect((target.foodOrderItems ?? []).count == (source.foodOrderItems ?? []).count)
            #expect((target.quirks ?? []).count == (source.quirks ?? []).count)
            #expect((target.theirPeopleItems ?? []).count == (source.theirPeopleItems ?? []).count)
        }
    }
}

// MARK: - Helpers

@MainActor
private func seedFullPerson(in ctx: ModelContext) throws -> Person {
    let person = TestSupport.seedPerson(
        in: ctx,
        name: "Full Person",
        relationshipStart: TestFixtures.sampleRelationshipStart,
        gender: .female
    )

    person.birthday = TestFixtures.sampleBirthday

    TestSupport.seedNote(in: ctx, body: "Remember this", person: person)

    TestSupport.seedImportantDate(
        in: ctx,
        title: "Anniversary",
        date: TestFixtures.futureDate(daysFromNow: 60),
        recurrenceFrequency: .yearly,
        predefinedCategory: .anniversary,
        person: person
    )

    TestSupport.seedGiftIdea(
        in: ctx,
        title: "Watch",
        price: Decimal(string: "99.99"),
        person: person
    )

    TestSupport.seedAskAboutItem(in: ctx, title: "Favorite color?", person: person)
    TestSupport.seedLikeDislike(in: ctx, name: "Jazz", kind: .like, person: person)

    let clothingSize = ClothingSizeItem(size: "M", person: person)
    ctx.insert(clothingSize)

    let allergy = AllergyItem(name: "Peanuts", predefinedCategory: .food, person: person)
    ctx.insert(allergy)

    let foodOrder = FoodOrderItem(place: "Cafe", order: "Latte", person: person)
    ctx.insert(foodOrder)

    TestSupport.seedQuirk(in: ctx, text: "Always late", person: person)

    let theirPerson = TheirPeopleItem(name: "Mom", predefinedCategory: .mom, person: person)
    ctx.insert(theirPerson)

    try ctx.save()
    return person
}
