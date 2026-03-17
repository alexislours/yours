import SwiftUI
import WidgetKit

@main
struct YoursWidgetBundle: WidgetBundle {
    var body: some Widget {
        DateCountdownWidget()
        RelationshipDurationWidget()
    }
}
