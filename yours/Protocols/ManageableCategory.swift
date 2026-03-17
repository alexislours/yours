import SwiftData
import SwiftUI

@MainActor
protocol ManageableCategory: AnyObject {
    var name: String { get set }
    var sfSymbol: String { get set }
    var colorName: String { get set }
    var updatedAt: Date { get set }
    var color: Color { get }
    var itemCount: Int { get }
    static var curatedSymbols: [String] { get }

    init(name: String, sfSymbol: String, colorName: String)
}
