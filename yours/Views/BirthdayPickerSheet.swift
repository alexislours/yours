import SwiftData
import SwiftUI

struct BirthdayPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    @State private var selectedDate: Date
    private let isEditing: Bool

    init(person: Person) {
        self.person = person
        let existing = person.birthday
        _selectedDate = State(initialValue: existing ?? Calendar.current.date(
            from: DateComponents(year: 1995, month: 1, day: 1)
        ) ?? .now)
        isEditing = existing != nil
    }

    var body: some View {
        VStack(spacing: Spacing.block) {
            // Drag indicator
            Capsule()
                .fill(Color.borderSubtle)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.md)

            Text(String(localized: "\(person.firstName)'s Birthday", comment: "Birthday picker: sheet title with person's first name"))
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.3)

            DatePicker(
                selection: $selectedDate,
                in: .distantPast ... Date.now,
                displayedComponents: .date
            ) {}
                .datePickerStyle(.graphical)
                .tint(Color.accentPrimary)
                .padding(Spacing.sm)
                .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )

            if let preview = previewText {
                Text(preview)
                    .font(.bodySmall)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            VStack(spacing: Spacing.lg) {
                Button {
                    BirthdayService.setBirthday(
                        date: selectedDate,
                        person: person,
                        in: modelContext
                    )
                    dismiss()
                } label: {
                    Text(String(localized: "Save", comment: "Generic save button"))
                        .font(.label)
                        .foregroundStyle(Color.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(Color.accentPrimary, in: Capsule())
                }

                if isEditing {
                    Button(role: .destructive) {
                        BirthdayService.removeBirthday(
                            person: person,
                            in: modelContext
                        )
                        dismiss()
                    } label: {
                        Text(String(localized: "Remove birthday", comment: "Birthday picker: destructive button to remove birthday"))
                            .font(.bodySmall)
                            .foregroundStyle(Color.error)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.bottom, Spacing.xxxl)
        .background(Color.bgPrimary)
        .presentationDetents([.large])
    }

    private var previewText: String? {
        let comps = Calendar.current.dateComponents([.month, .day], from: selectedDate)
        guard let month = comps.month, let day = comps.day else { return nil }
        let zodiac = ZodiacSign.from(month: month, day: day)
        let age = Calendar.current.dateComponents([.year], from: selectedDate, to: .now).year ?? 0
        let ageText = String(localized: "\(age) years old", comment: "Birthday picker: age display")
        return "\(ageText)  \(zodiac.label)"
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        BirthdayPickerSheet(person: .preview)
    }
}
