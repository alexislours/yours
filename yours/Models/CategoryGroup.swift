import SwiftUI

struct CategoryGroup<Item>: Identifiable {
    let key: String
    let name: String
    let icon: String
    let color: Color
    let items: [Item]

    var id: String {
        key
    }
}

extension CategoryGroup where Item: CategorizedItem {
    /// Groups items by category using CategorizedItem protocol properties.
    /// Sorts items within each group alphabetically by the given key path.
    static func grouped(
        from items: [Item],
        sortedBy namePath: KeyPath<Item, String>
    ) -> [CategoryGroup<Item>] {
        var groups: [String: [Item]] = [:]
        for item in items {
            groups[item.categoryGroupKey, default: []].append(item)
        }
        return groups.compactMap { key, items in
            let sorted = items.sorted {
                $0[keyPath: namePath].localizedCaseInsensitiveCompare($1[keyPath: namePath]) == .orderedAscending
            }
            guard let first = sorted.first else { return nil }
            return CategoryGroup(
                key: key, name: first.categoryDisplayName,
                icon: first.categoryIcon, color: first.categoryColor,
                items: sorted
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
