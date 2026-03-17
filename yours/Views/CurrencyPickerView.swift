import SwiftUI

struct CurrencyPickerView: View {
    struct CurrencyInfo {
        let code: String
        let name: String
        let symbol: String
    }

    @Environment(\.dismiss) private var dismiss
    @Binding var currencyCode: String
    @State private var searchText = ""

    private static let currencies: [CurrencyInfo] = {
        let codes = Locale.commonISOCurrencyCodes
        let locale = Locale.current
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return codes.compactMap { code in
            guard let name = locale.localizedString(forCurrencyCode: code) else { return nil }
            formatter.currencyCode = code
            let symbol = formatter.currencySymbol ?? code
            return CurrencyInfo(code: code, name: name, symbol: symbol)
        }
        .sorted { $0.name < $1.name }
    }()

    private var filtered: [CurrencyInfo] {
        guard !searchText.isEmpty else { return Self.currencies }
        return Self.currencies.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            List {
                searchBar
                    .plainListRow(top: Spacing.lg, bottom: Spacing.sm)

                ForEach(filtered, id: \.code) { currency in
                    Button(action: {
                        currencyCode = currency.code
                    }, label: {
                        HStack(spacing: Spacing.md) {
                            Text(currency.symbol)
                                .font(.custom(FontFamily.ui, size: 15, relativeTo: .callout).weight(.medium))
                                .foregroundStyle(Color.textTertiary)
                                .frame(width: 36, alignment: .center)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.name)
                                    .font(.bodyDefault)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.textPrimary)

                                Text(currency.code)
                                    .font(.caption)
                                    .foregroundStyle(Color.textTertiary)
                            }

                            Spacer()

                            if currencyCode == currency.code {
                                Image(systemName: "checkmark")
                                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(.semibold))
                                    .foregroundStyle(Color.accentPrimary)
                                    .accessibilityHidden(true)
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                        .contentShape(Rectangle())
                    })
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(currencyCode == currency.code ? .isSelected : [])
                }
                .plainListRow(top: 0, bottom: 0)
            }
            .appListStyle()
        }
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
    }

    private var header: some View {
        DetailHeader(
            title: Text(String(localized: "Currency", comment: "Currency picker: screen title")),
            dismiss: dismiss
        )
        .padding(.horizontal, Spacing.xxxl)
    }

    private var searchBar: some View {
        SearchBar(
            placeholder: String(localized: "Search currencies", comment: "Currency picker: search bar placeholder"),
            text: $searchText
        )
    }
}
