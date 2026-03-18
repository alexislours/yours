import SwiftUI

// MARK: - Color Helpers (uses shared asset catalog)

private enum ShareColor {
    static let bgPrimary = Color("bgPrimary")
    static let bgSurface = Color("bgSurface")
    static let textPrimary = Color("textPrimary")
    static let textTertiary = Color("textTertiary")
    static let textDisabled = Color("textDisabled")
    static let textOnAccent = Color("textOnAccent")
    static let accentPrimary = Color("accentPrimary")
    static let borderSubtle = Color("borderSubtle")
}

// MARK: - Share Form View

struct ShareFormView: View {
    let initialURL: String
    let initialTitle: String
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var title = ""
    @State private var note = ""
    @State private var priceText = ""
    @State private var urlString = ""
    @State private var selectedOccasion: GiftOccasion = .justBecause
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, note, price, url
    }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleField
                    occasionPicker
                    noteField
                    priceField
                    urlField
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .background(ShareColor.bgPrimary)
        .onAppear {
            urlString = initialURL
            if !initialTitle.isEmpty {
                title = initialTitle
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(ShareColor.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(String(localized: "Cancel", bundle: .main))

            Spacer()

            Text(String(localized: "Add an idea", bundle: .main))
                .font(.custom("Crimson Pro", size: 22, relativeTo: .title2).weight(.medium))
                .foregroundStyle(ShareColor.textPrimary)
                .tracking(-0.3)
                .lineLimit(1)

            Spacer()

            Button(action: save) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canSave ? ShareColor.accentPrimary : ShareColor.textDisabled)
            }
            .disabled(!canSave)
            .frame(width: 44, height: 44)
            .accessibilityLabel(String(localized: "Save", bundle: .main))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .background(ShareColor.bgPrimary)
    }

    // MARK: - Title

    private var titleField: some View {
        shareFormField(String(localized: "TITLE", bundle: .main), isFocused: focusedField == .title) {
            TextField(String(localized: "e.g. Vintage Polaroid camera", bundle: .main), text: $title)
                .font(.custom("Inter", size: 15, relativeTo: .body))
                .foregroundStyle(ShareColor.textPrimary)
                .focused($focusedField, equals: .title)
        }
    }

    // MARK: - Occasion Picker

    private var occasionPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "OCCASION", bundle: .main))
                .font(.custom("Inter", size: 11, relativeTo: .caption2).weight(.semibold))
                .foregroundStyle(ShareColor.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GiftOccasion.allCases) { occasion in
                        occasionChip(occasion)
                    }
                }
            }
        }
    }

    private func occasionChip(_ occasion: GiftOccasion) -> some View {
        let isSelected = selectedOccasion == occasion
        return Button {
            selectedOccasion = occasion
        } label: {
            HStack(spacing: 6) {
                Image(systemName: occasion.icon)
                    .font(.system(size: 12))
                Text(occasion.displayName)
                    .font(.custom("Inter", size: 13, relativeTo: .subheadline).weight(.medium))
            }
            .foregroundStyle(isSelected ? ShareColor.textOnAccent : Color(occasion.colorName))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color(occasion.colorName) : Color(occasion.colorName).opacity(0.12),
                in: Capsule()
            )
        }
        .buttonStyle(SharePressableStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Note

    private var noteField: some View {
        shareFormField(String(localized: "NOTE (OPTIONAL)", bundle: .main), isFocused: focusedField == .note) {
            TextField(String(localized: "Any details to remember", bundle: .main), text: $note, axis: .vertical)
                .font(.custom("Inter", size: 15, relativeTo: .body))
                .foregroundStyle(ShareColor.textPrimary)
                .lineLimit(2 ... 5)
                .focused($focusedField, equals: .note)
        }
    }

    // MARK: - Price

    private var priceField: some View {
        shareFormField(String(localized: "PRICE (OPTIONAL)", bundle: .main), isFocused: focusedField == .price) {
            HStack(spacing: 8) {
                Text(Self.currencySymbol)
                    .font(.custom("Inter", size: 15, relativeTo: .body))
                    .foregroundStyle(ShareColor.textTertiary)

                TextField("0.00", text: $priceText)
                    .font(.custom("Inter", size: 15, relativeTo: .body))
                    .foregroundStyle(ShareColor.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
            }
        }
    }

    private static let currencySymbol: String = {
        let code = Locale.current.currency?.identifier ?? "USD"
        let components = [NSLocale.Key.currencyCode.rawValue: code]
        let localeID = Locale.identifier(fromComponents: components)
        return Locale(identifier: localeID).currencySymbol ?? "$"
    }()

    // MARK: - URL

    private var urlField: some View {
        shareFormField(String(localized: "LINK", bundle: .main), isFocused: focusedField == .url) {
            TextField(String(localized: "e.g. amazon.com/...", bundle: .main), text: $urlString)
                .font(.custom("Inter", size: 15, relativeTo: .body))
                .foregroundStyle(ShareColor.textPrimary)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .url)
        }
    }

    // MARK: - Helpers

    private func shareFormField(
        _ label: String,
        isFocused: Bool,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.custom("Inter", size: 11, relativeTo: .caption2).weight(.semibold))
                .foregroundStyle(ShareColor.textTertiary)
                .accessibilityHidden(true)

            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(ShareColor.bgSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isFocused ? ShareColor.accentPrimary : ShareColor.borderSubtle,
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .accessibilityLabel(label)
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        let gift = PendingGift(
            title: trimmedTitle,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            priceString: trimmedPrice.isEmpty ? nil : trimmedPrice,
            urlString: trimmedURL.isEmpty ? nil : trimmedURL,
            occasion: selectedOccasion.rawValue,
            createdAt: .now
        )
        PendingGiftStore.append(gift)
        onSave()
    }
}

// MARK: - Button Style

private struct SharePressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
