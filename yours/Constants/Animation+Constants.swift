import SwiftUI
import UIKit

extension Animation {
    /// Standard fade for empty state transitions
    static var emptyState: Animation {
        reduceMotion ? .default : .easeInOut(duration: 0.3)
    }

    /// Spring for list item reordering/insertion/deletion
    static var listReorder: Animation {
        reduceMotion ? .default : .spring(response: 0.35, dampingFraction: 0.9)
    }

    /// Spring for expand/collapse toggles
    static var expandCollapse: Animation {
        reduceMotion ? .default : .spring(response: 0.3, dampingFraction: 0.8)
    }

    /// Gentle entrance for home screen content
    static var homeEntrance: Animation {
        reduceMotion ? .default : .easeOut(duration: 0.45)
    }

    /// Wraps an inline animation so it falls back to `.default` when Reduce Motion is on.
    static func motionAware(_ animation: Animation) -> Animation {
        reduceMotion ? .default : animation
    }

    private static var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

/// Runs `body` with `animation` when Reduce Motion is off, or without animation when it is on.
func withOptionalAnimation<Result>(
    _ animation: Animation? = .default,
    _ body: () throws -> Result
) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    }
    return try withAnimation(animation, body)
}
