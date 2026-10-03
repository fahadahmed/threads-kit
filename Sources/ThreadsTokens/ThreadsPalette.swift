import SwiftUI

/// The names every product palette must provide.
///
/// A palette is a **conformance, not a copy**: this protocol declares every name, so a product that
/// leaves one out gets a compile error instead of a missing colour at runtime. Views take colours
/// from the palette in the environment (`@Environment(\.threads)`), never from a raw hex.
///
/// Names stay separate even where two values match in one appearance (`terra` / `line`,
/// `accent` / `d3` in dark): they mean different things.
public protocol ThreadsPalette: Sendable {
    // Surface
    /// The screen ground.
    var app: Color { get }
    /// The content surface.
    var card: Color { get }
    /// The timer and focus ground.
    var deep: Color { get }
    /// Type on `deep`; the same in both appearances.
    var onDeep: Color { get }
    /// An opaque selected task row (the content layer).
    var selected: Color { get }

    // Ink
    /// Titles.
    var ink: Color { get }
    /// Body.
    var ink2: Color { get }
    /// Labels and meta. The 4.5:1 floor.
    var ink3: Color { get }

    // Action
    /// The primary action. **The only filled button colour**, one filled button per surface.
    var terra: Color { get }
    var terraPress: Color { get }
    /// Done / settled.
    var accent: Color { get }
    var accentPress: Color { get }
    /// Type on a filled `terra` or `accent`. It flips dark in dark mode: never hardcode white.
    var onAccent: Color { get }

    // Density (habit grids)
    var d1: Color { get }
    var d2: Color { get }
    var d3: Color { get }
    /// A missed day. Not an error.
    var missed: Color { get }

    // Lines and glass
    /// Hairlines. Ships **with alpha**; apply directly.
    var line: Color { get }
    /// The tint of an action surface (the tab bar, toolbars, the capture bar, secondary buttons).
    var glass: Color { get }

    // Destructive
    /// Destructive **text**. There is no red anywhere else.
    var alert: Color { get }
    /// Destructive soft fill: never a filled red button.
    var alertSoft: Color { get }

    // Status roles
    var success: Color { get }
    var warning: Color { get }
    var lapsed: Color { get }
    var info: Color { get }
}

/// The status roles default to the colours Jamaal maps them to; another palette may override them.
public extension ThreadsPalette {
    var success: Color { accent }
    var warning: Color { terra }
    var lapsed: Color { missed }
    var info: Color { ink2 }
}

/// Colours that are derived rather than named (docs/design handoff §2).
public extension ThreadsPalette {
    /// A strong border: `ink` at 24%.
    var line2: Color { ink.opacity(0.24) }

    /// The edge of a glass surface: `line` in light, white at 16% in dark.
    var glassEdge: Color {
        Color.threadsDynamic(light: line, dark: Color.white.opacity(0.16))
    }

    /// The veil behind a sheet: `rgba(4,26,38,0.32)` in light, `rgba(0,0,0,0.45)` in dark.
    var scrim: Color {
        Color.threadsDynamic(
            light: Color(red: 4 / 255, green: 26 / 255, blue: 38 / 255).opacity(0.32),
            dark: Color.black.opacity(0.45)
        )
    }
}

extension Color {
    /// A colour that resolves to `light` or `dark` with the appearance, for derived values that no asset covers.
    static func threadsDynamic(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        Color(UIColor { traits in traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
        #elseif canImport(AppKit)
        Color(NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        })
        #else
        light
        #endif
    }
}

private struct ThreadsPaletteKey: EnvironmentKey {
    static let defaultValue: any ThreadsPalette = JamaalPalette()
}

public extension EnvironmentValues {
    /// The palette views draw with. Jamaal's, unless a product sets its own.
    var threads: any ThreadsPalette {
        get { self[ThreadsPaletteKey.self] }
        set { self[ThreadsPaletteKey.self] = newValue }
    }
}
