import Foundation
import SwiftData

enum DataExportImportService {
    struct ExportResult {
        let fileURL: URL
    }

    struct CategoryInfo {
        let name: String
        let sfSymbol: String
        let colorName: String
    }

    struct ExportedCategory {
        let id: String
        let name: String
        let sfSymbol: String
        let colorName: String
    }

    struct CategoryMap<T: AnyObject> {
        private var idMap: [ObjectIdentifier: String] = [:]
        private(set) var exported: [ExportedCategory] = []

        mutating func register(_ cat: T, name: String, sfSymbol: String, colorName: String) {
            let key = ObjectIdentifier(cat)
            guard idMap[key] == nil else { return }
            let id = UUID().uuidString
            idMap[key] = id
            exported.append(ExportedCategory(id: id, name: name, sfSymbol: sfSymbol, colorName: colorName))
        }

        func id(for cat: T) -> String? {
            idMap[ObjectIdentifier(cat)]
        }
    }

    static func exportCategorized<Item, Category: AnyObject, ExportData>(
        items: [Item],
        categoryOf: (Item) -> Category?,
        categoryInfo: (Category) -> CategoryInfo,
        mapItem: (Item, CategoryMap<Category>) -> ExportData
    ) -> (items: [ExportData], categories: [CategoryExportData]) {
        var catMap = CategoryMap<Category>()
        for item in items {
            guard let cat = categoryOf(item) else { continue }
            let info = categoryInfo(cat)
            catMap.register(cat, name: info.name, sfSymbol: info.sfSymbol, colorName: info.colorName)
        }
        let exportedItems = items.map { mapItem($0, catMap) }
        let categories = catMap.exported.map {
            CategoryExportData(id: $0.id, name: $0.name, sfSymbol: $0.sfSymbol, colorName: $0.colorName)
        }
        return (exportedItems, categories)
    }

    struct ImportInput<Item, ExportData> {
        let items: [ExportData]?
        let existingItems: [Item]
        let categoryDatas: [CategoryExportData]?
    }

    static func importCategorized<Item: PersistentModel, Category: PersistentModel, ExportData>(
        input: ImportInput<Item, ExportData>,
        modelContext: ModelContext,
        createCategory: (String, String, String) -> Category,
        createItem: (ExportData, [String: Category]) -> Item
    ) {
        guard let items = input.items else { return }
        for item in input.existingItems {
            modelContext.delete(item)
        }
        var categoryById: [String: Category] = [:]
        for catData in input.categoryDatas ?? [] {
            let cat = createCategory(catData.name, catData.sfSymbol, catData.colorName)
            modelContext.insert(cat)
            categoryById[catData.id] = cat
        }
        for data in items {
            let item = createItem(data, categoryById)
            modelContext.insert(item)
        }
    }
}

// MARK: - Errors

extension DataExportImportService {
    enum ImportError: LocalizedError {
        case accessDenied
        case missingBackupJSON

        var errorDescription: String? {
            switch self {
            case .accessDenied:
                "Could not access the selected file."
            case .missingBackupJSON:
                "backup.json not found in archive."
            }
        }
    }
}
