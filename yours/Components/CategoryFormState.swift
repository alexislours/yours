import SwiftUI

@Observable
final class CategoryFormState<Predefined: Hashable, Custom: Identifiable> {
    var selectedPredefined: Predefined
    var selectedCustomCategory: Custom?
    var useCustomCategory = false
    var showManageCategories = false

    init(defaultPredefined: Predefined) {
        selectedPredefined = defaultPredefined
    }

    func selectPredefined(_ category: Predefined) {
        useCustomCategory = false
        selectedPredefined = category
        selectedCustomCategory = nil
    }

    func selectCustom(_ category: Custom) {
        useCustomCategory = true
        selectedCustomCategory = category
    }

    func populate(customCategory: Custom?, predefined: Predefined) {
        if let custom = customCategory {
            useCustomCategory = true
            selectedCustomCategory = custom
        } else {
            selectedPredefined = predefined
        }
    }
}
