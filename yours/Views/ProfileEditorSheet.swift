import SwiftData
import SwiftUI
import UIKit

struct ProfileEditorSheet: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss

    @State private var nameDraft: String
    @State private var showingPhotoPicker = false
    @State private var avatarImage: Image?
    @State private var avatarID = UUID()
    @FocusState private var nameFieldFocused: Bool

    init(person: Person) {
        self.person = person
        _nameDraft = State(initialValue: person.name)
    }

    private var canSave: Bool {
        nameDraft.nonBlank != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: Text(String(localized: "Edit Profile", comment: "Profile editor: sheet title")), dismiss: dismiss) {
                Button(action: {
                    commitChanges()
                    dismiss()
                }, label: {
                    Image(systemName: "checkmark")
                        .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                        .foregroundStyle(canSave ? Color.accentPrimary : Color.textDisabled)
                })
                .disabled(!canSave)
                .accessibilityLabel(Text("Save", comment: "Profile editor: save button accessibility label"))
            }
            .padding(.horizontal, Spacing.xxxl)

            ScrollView {
                VStack(spacing: Spacing.xxxl) {
                    // Avatar with photo change
                    VStack(spacing: Spacing.lg) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(
                                name: nameDraft.isEmpty ? person.name : nameDraft,
                                size: 100,
                                image: avatarImage
                            )
                            .id(avatarID)

                            Button { showingPhotoPicker = true } label: {
                                Image(systemName: "camera.fill")
                                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                                    .foregroundStyle(Color.textOnAccent)
                                    .frame(width: 32, height: 32)
                                    .background(Color.accentPrimary, in: Circle())
                                    .overlay(Circle().strokeBorder(Color.bgPrimary, lineWidth: 2))
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                            .accessibilityLabel(Text("Change photo", comment: "Profile editor: camera button accessibility label"))
                            .offset(x: 2, y: 2)
                        }
                    }
                    .padding(.top, Spacing.xl)

                    // Name field
                    VStack(spacing: Spacing.xs) {
                        TextField("Name", text: $nameDraft)
                            .font(.heading1)
                            .foregroundStyle(Color.accentPrimary)
                            .multilineTextAlignment(.center)
                            .focused($nameFieldFocused)
                            .tracking(-0.3)

                        Rectangle()
                            .fill(nameFieldFocused ? Color.accentPrimary : Color.borderSubtle)
                            .frame(height: 1)
                            .padding(.horizontal, Spacing.block)
                            .animation(.motionAware(.easeInOut(duration: 0.2)), value: nameFieldFocused)
                    }

                    // Fields
                    VStack(spacing: Spacing.xxxl) {
                        fieldSection(String(localized: "GENDER", comment: "Profile editor: gender section header")) {
                            VStack(spacing: Spacing.sm) {
                                genderPill(String(localized: "Woman", comment: "Profile editor: female gender option"), value: .female)
                                genderPill(String(localized: "Man", comment: "Profile editor: male gender option"), value: .male)
                                genderPill(
                                    String(localized: "Non-binary", comment: "Profile editor: non-binary gender option"),
                                    value: .other
                                )
                            }
                            .hapticFeedback(.selection, trigger: person.gender)
                        }

                        fieldSection(String(localized: "TOGETHER SINCE",
                                            comment: "Profile editor: relationship start date section header")) {
                            VStack(spacing: Spacing.sm) {
                                DatePicker(
                                    selection: $person.relationshipStart,
                                    in: ...Date(),
                                    displayedComponents: .date
                                ) {}
                                    .datePickerStyle(.graphical)
                                    .tint(Color.accentPrimary)
                                    .labelsHidden()
                                    .padding(Spacing.sm)
                                    .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.xl))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.xl)
                                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                                    )

                                Text(person.durationDescription)
                                    .font(.caption)
                                    .foregroundStyle(Color.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xxxl)
                }
                .padding(.bottom, Spacing.block)
            }
        }
        .background(Color.bgPrimary)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task {
            guard let data = person.photoData else { return }
            if let decoded = await decodeImage(from: data) {
                avatarImage = decoded
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            ImagePickerSheet { uiImage in
                Task {
                    let resized = await Task.detached {
                        uiImage.resizedTo512()
                    }.value
                    person.photoData = resized.jpegData(compressionQuality: 0.8)
                    withOptionalAnimation(.easeInOut(duration: 0.35)) {
                        avatarImage = Image(uiImage: resized)
                        avatarID = UUID()
                    }
                }
            }
        }
    }

    // MARK: - Components

    private func fieldSection(
        _ label: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(label)
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)
                .tracking(LetterSpacing.sectionLabel)

            content()
        }
    }

    @ViewBuilder
    private func genderPill(_ label: String, value: Person.Gender) -> some View {
        let isSelected = person.gender == value
        Button { person.gender = value } label: {
            Text(label)
                .font(.bodyDefault)
                .foregroundStyle(isSelected ? Color.accentPrimary : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
        }
        .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(
                    isSelected ? Color.accentPrimary : Color.borderSubtle,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .animation(.motionAware(.easeInOut(duration: 0.2)), value: isSelected)
    }

    // MARK: - Actions

    private func commitChanges() {
        if let trimmed = nameDraft.nonBlank {
            person.name = trimmed
        }
    }
}

#Preview {
    ProfileEditorSheet(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
