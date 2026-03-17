import SwiftUI

struct CategoryDisplayInfo {
    let label: String
    let icon: String
    let color: Color
}

struct CategoryPickerSection<Predefined: Hashable, Custom: Identifiable>: View {
    let title: String
    let predefinedCategories: [Predefined]
    let customCategories: [Custom]
    var hiddenCategories: [Predefined] = []
    let useCustomCategory: Bool
    let selectedPredefined: Predefined?
    let selectedCustomID: Custom.ID?
    let predefinedDisplay: (Predefined) -> CategoryDisplayInfo
    let customDisplay: (Custom) -> CategoryDisplayInfo
    let onSelectPredefined: (Predefined) -> Void
    let onSelectCustom: (Custom) -> Void
    let onManage: () -> Void

    @State private var showHiddenCategories = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            header
            chipScroll
            hiddenSection
        }
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)

            Spacer()

            Button(action: onManage) {
                Text(String(localized: "Manage", comment: "Category picker: button to manage categories"))
                    .font(.caption)
                    .foregroundStyle(Color.accentPrimary)
            }
        }
    }

    @State private var selectionCount = 0

    private var chipScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(predefinedCategories, id: \.self) { category in
                    let display = predefinedDisplay(category)
                    SelectableChip(
                        label: display.label,
                        icon: display.icon,
                        isSelected: !useCustomCategory && selectedPredefined == category,
                        selectedBackground: display.color,
                        unselectedForeground: display.color,
                        showBorder: false
                    ) {
                        selectionCount += 1
                        onSelectPredefined(category)
                    }
                }

                ForEach(customCategories) { cat in
                    let display = customDisplay(cat)
                    SelectableChip(
                        label: display.label,
                        icon: display.icon,
                        isSelected: useCustomCategory && selectedCustomID == cat.id,
                        selectedBackground: display.color,
                        unselectedForeground: display.color,
                        showBorder: false
                    ) {
                        selectionCount += 1
                        onSelectCustom(cat)
                    }
                }
            }
        }
        .hapticFeedback(.selection, trigger: selectionCount)
    }

    @ViewBuilder
    private var hiddenSection: some View {
        if !hiddenCategories.isEmpty {
            Button(action: { withOptionalAnimation(.easeInOut(duration: 0.25)) { showHiddenCategories.toggle() } }, label: {
                HStack(spacing: Spacing.xs) {
                    Text(String(localized: "Hidden", comment: "Category picker: section header for hidden categories"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textTertiary)
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 10, relativeTo: .caption2).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .rotationEffect(.degrees(showHiddenCategories ? 90 : 0))
                        .accessibilityHidden(true)
                }
            })
            .buttonStyle(.plain)

            if showHiddenCategories {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(hiddenCategories, id: \.self) { category in
                            let display = predefinedDisplay(category)
                            SelectableChip(
                                label: display.label,
                                icon: display.icon,
                                isSelected: !useCustomCategory && selectedPredefined == category,
                                selectedBackground: display.color,
                                unselectedForeground: display.color,
                                showBorder: false
                            ) {
                                selectionCount += 1
                                onSelectPredefined(category)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
