import SwiftData
import SwiftUI

extension View {
    func deleteConfirmation<Item: PersistentModel>(
        _ title: String,
        item: Binding<Item?>,
        message: String = "This cannot be undone.",
        onDelete: @escaping (Item) -> Void
    ) -> some View {
        alert(title, isPresented: Binding(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )) {
            Button(String(localized: "Delete", comment: "Destructive action button to delete an item"), role: .destructive) {
                HapticFeedback.impact(.heavy)
                if let value = item.wrappedValue {
                    onDelete(value)
                    item.wrappedValue = nil
                }
            }
            Button(String(localized: "Cancel", comment: "Generic cancel button"), role: .cancel) { item.wrappedValue = nil }
        } message: {
            Text(message)
        }
    }

    func deleteConfirmation(
        _ title: String,
        isPresented: Binding<Bool>,
        buttonLabel: String = String(localized: "Delete", comment: "Destructive action button to delete an item"),
        onDelete: @escaping () -> Void
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button(buttonLabel, role: .destructive) {
                HapticFeedback.impact(.heavy)
                onDelete()
            }
            Button(String(localized: "Cancel", comment: "Generic cancel button"), role: .cancel) {}
        } message: {
            Text(String(localized: "This cannot be undone.", comment: "Delete confirmation: warning that deletion is permanent"))
        }
    }
}
