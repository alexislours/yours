import Foundation

// MARK: - Calendar Date Helpers

enum CalendarDateFormat {
    private static let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.timeZone = .current
        return fmt
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        formatter.date(from: string)
    }
}

// MARK: - Export / Import Models

struct PersonExportMetadata: Codable {
    let name: String
    let relationshipStart: String
    let gender: String
    var birthday: String?
    var notes: [NoteExportData]?
    var importantDates: [ImportantDateExportData]?
    var dateCategories: [CategoryExportData]?
    var giftIdeas: [GiftIdeaExportData]?
    var giftCategories: [CategoryExportData]?
    var askAboutItems: [AskAboutItemExportData]?
    var likeDislikeItems: [LikeDislikeItemExportData]?
    var likeDislikeCategories: [CategoryExportData]?
    var clothingSizeItems: [ClothingSizeItemExportData]?
    var clothingSizeCategories: [CategoryExportData]?
    var allergyItems: [AllergyItemExportData]?
    var allergyCategories: [CategoryExportData]?
    var foodOrderItems: [FoodOrderItemExportData]?
    var foodOrderCategories: [CategoryExportData]?
    var quirks: [QuirkExportData]?
    var theirPeopleItems: [TheirPeopleItemExportData]?
    var theirPeopleCategories: [CategoryExportData]?
}

struct NoteExportData: Codable {
    let id: String
    let body: String
    let createdAt: Date
    let updatedAt: Date
}

struct ImportantDateExportData: Codable {
    let id: String
    let title: String
    let date: String
    let note: String?
    let recurrenceFrequency: String
    let predefinedCategory: String
    let customCategoryId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CategoryExportData: Codable {
    let id: String
    let name: String
    let sfSymbol: String
    let colorName: String
}

struct GiftIdeaExportData: Codable {
    let id: String
    let title: String
    let note: String?
    let price: String?
    let urlString: String?
    let status: String
    let predefinedCategory: String?
    let customCategoryId: String?
    let linkedDateTitle: String?
    let createdAt: Date
    let updatedAt: Date
}

struct AskAboutItemExportData: Codable {
    let id: String
    let title: String
    let isDone: Bool
    let dueDate: String?
    let createdAt: Date
    var updatedAt: Date?
}

struct LikeDislikeItemExportData: Codable {
    let id: String
    let name: String
    let note: String?
    let kind: String
    let predefinedCategory: String
    let customCategoryId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct ClothingSizeItemExportData: Codable {
    let id: String
    let size: String
    let note: String?
    let predefinedCategory: String
    let customCategoryId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct AllergyItemExportData: Codable {
    let id: String
    let name: String
    let note: String?
    let predefinedCategory: String
    let customCategoryId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct FoodOrderItemExportData: Codable {
    let id: String
    let place: String
    let order: String
    let note: String?
    let predefinedCategory: String
    let customCategoryId: String?
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
}

struct QuirkExportData: Codable {
    let id: String
    let text: String
    let createdAt: Date
    var updatedAt: Date?
}

struct TheirPeopleItemExportData: Codable {
    let id: String
    let name: String
    let note: String?
    let predefinedCategory: String
    let customCategoryId: String?
    let createdAt: Date
    let updatedAt: Date
}
