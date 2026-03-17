import SwiftUI

struct EditDeleteSwipeActions: ViewModifier {
    let onEdit: () -> Void
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive, action: onDelete) {
                    Label(String(localized: "Delete", comment: "Swipe action: delete item"), systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
                .tint(Color.error)

                Button(action: onEdit) {
                    Label(String(localized: "Edit", comment: "Swipe action: edit item"), systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }
                .tint(Color.accentSecondary)
            }
    }
}

extension View {
    func editDeleteSwipeActions(onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) -> some View {
        modifier(EditDeleteSwipeActions(onEdit: onEdit, onDelete: onDelete))
    }
}
