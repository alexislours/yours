import SwiftUI

struct FilterChipBar: View {
    let options: [(id: String, label: String)]
    @Binding var selectedFilter: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                SelectableChip(
                    label: String(localized: "All", comment: "Filter chip: label to show all items without filtering"),
                    isSelected: selectedFilter == nil,
                    unselectedBackground: .bgSurface
                ) {
                    selectedFilter = nil
                }

                ForEach(options, id: \.id) { option in
                    SelectableChip(label: option.label, isSelected: selectedFilter == option.id, unselectedBackground: .bgSurface) {
                        selectedFilter = selectedFilter == option.id ? nil : option.id
                    }
                }
            }
        }
        .hapticFeedback(.selection, trigger: selectedFilter)
    }
}
