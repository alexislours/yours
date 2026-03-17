import Foundation

nonisolated enum CurrencyFormatting {
    /// The user's preferred currency code from settings, falling back to locale default.
    static var preferredCurrencyCode: String {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.currencyCode)
            ?? Locale.current.currency?.identifier
            ?? "USD"
    }

    /// The currency symbol for the user's preferred currency.
    static var preferredCurrencySymbol: String {
        let components = [NSLocale.Key.currencyCode.rawValue: preferredCurrencyCode]
        let localeID = Locale.identifier(fromComponents: components)
        return Locale(identifier: localeID).currencySymbol ?? "$"
    }

    /// Formats a decimal as currency using the user's preferred currency.
    static func format(_ value: Decimal) -> String? {
        value.formatted(.currency(code: preferredCurrencyCode))
    }
}
