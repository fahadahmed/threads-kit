import SwiftUI

/// Jamaal's palette: the cool palette (teal accent, blue-based ink, terracotta as the one action
/// colour), light and dark baked into `Colors-Jamaal.xcassets`. The only conformance that exists.
public struct JamaalPalette: ThreadsPalette {
    public init() {}

    public var app: Color { c("app") }
    public var card: Color { c("card") }
    public var deep: Color { c("deep") }
    public var onDeep: Color { c("onDeep") }
    public var selected: Color { c("selected") }

    public var ink: Color { c("ink") }
    public var ink2: Color { c("ink2") }
    public var ink3: Color { c("ink3") }

    public var terra: Color { c("terra") }
    public var terraPress: Color { c("terraPress") }
    public var accent: Color { c("accent") }
    public var accentPress: Color { c("accentPress") }
    public var onAccent: Color { c("onAccent") }

    public var d1: Color { c("d1") }
    public var d2: Color { c("d2") }
    public var d3: Color { c("d3") }
    public var missed: Color { c("missed") }

    public var line: Color { c("line") }
    public var glass: Color { c("glass") }

    public var alert: Color { c("alert") }
    public var alertSoft: Color { c("alertSoft") }

    private func c(_ name: String) -> Color { Color(name, bundle: .module) }
}

/// A task category's label colour. Jamaal only, and user-assigned, so it sits **outside** the
/// palette's names. A label is always a dot plus the name in ink: colour is never the only signal.
public struct ThreadsCategoryColor: Sendable {
    /// The key a category stores (`TaskCategory.colorKey` in Jamaal): `accent`, `blue`, `ochre`, `plum`, `slate`.
    public let key: String
    public let color: Color
}

public extension JamaalPalette {
    /// The five category colours, in the order the picker offers them. `terra` is deliberately not
    /// among them: it carries warning and overload. Each clears 4.5:1 as text on `app`, `card` and the
    /// iPad sidebar.
    static let categories: [ThreadsCategoryColor] = [
        ThreadsCategoryColor(key: "accent", color: Color("accent", bundle: .module)),   // catTeal is the accent
        ThreadsCategoryColor(key: "blue", color: Color("catBlue", bundle: .module)),
        ThreadsCategoryColor(key: "ochre", color: Color("catOchre", bundle: .module)),
        ThreadsCategoryColor(key: "plum", color: Color("catPlum", bundle: .module)),
        ThreadsCategoryColor(key: "slate", color: Color("catSlate", bundle: .module)),
    ]

    /// The colour for a stored key. An unknown key (written by a newer app) reads as slate.
    static func categoryColor(forKey key: String) -> Color {
        (categories.first { $0.key == key } ?? categories[categories.count - 1]).color
    }
}
