import SwiftUI

struct EditDeleteContextMenu: ViewModifier {
    let onEdit: () -> Void
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content.contextMenu {
            Button(action: onEdit, label: {
                Label(String(localized: "Edit", comment: "Context menu: edit item action"), systemImage: "pencil")
            })
            Button(role: .destructive, action: onDelete, label: {
                Label(String(localized: "Delete", comment: "Context menu: delete item action"), systemImage: "trash")
            })
        }
    }
}

extension View {
    func editDeleteContextMenu(onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) -> some View {
        modifier(EditDeleteContextMenu(onEdit: onEdit, onDelete: onDelete))
    }
}
