import SwiftUI

struct NoResultsView: View {
    let icon: String?
    let title: String
    let subtitle: String?

    /// Icon-based variant (GiftIdeasView, FoodOrdersView style)
    init(icon: String, message: String) {
        self.icon = icon
        title = message
        subtitle = nil
    }

    /// Text-only variant (NotesView, QuirksView, AskAboutView, ImportantDatesView style)
    init(title: String, subtitle: String) {
        icon = nil
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: icon != nil ? Spacing.md : Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.custom(FontFamily.ui, size: 28, relativeTo: .title).weight(.light))
                    .foregroundStyle(Color.textTertiary)
            }

            if subtitle != nil {
                Text(title)
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)
            } else {
                Text(title)
                    .font(.bodyDefault)
                    .foregroundStyle(Color.textSecondary)
            }

            if let subtitle {
                Text(subtitle)
                    .font(.bodySmall)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, icon != nil ? Spacing.xxxl : 0)
    }
}
