import SwiftUI

struct CategorizedItemRow<Trailing: View>: View {
    let name: String
    let subtitle: String?
    let note: String?
    let onTap: () -> Void
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(2)
                    }
                    if let note, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(Color.textTertiary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                trailing()
                    .accessibilityHidden(true)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
