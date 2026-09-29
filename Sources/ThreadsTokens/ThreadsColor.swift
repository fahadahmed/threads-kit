import SwiftUI

/// Semantic color tokens — the cool palette (teal accent, blue-based ink,
/// terracotta demoted to secondary "terra"). This supersedes the earlier
/// ceramic/warm palette across Jamaal, Riqa, and Hashiya.
///
/// Each name is one asset in Colors.xcassets with a light and dark
/// appearance baked in. Never reference a raw hex from a view — if a color
/// you need isn't listed here, add a new asset-catalog entry, don't reach
/// for `.opacity()` or a literal at the call site.
public extension Color {
    enum Threads {
        // MARK: Surface
        public static let app  = c("app")   // page background
        public static let card = c("card")  // card/panel surface

        // MARK: Ink (text)
        public static let ink  = c("ink")   // primary text
        public static let ink2 = c("ink2")  // secondary text
        public static let ink3 = c("ink3")  // tertiary/muted text

        // MARK: Accent
        public static let accent   = c("accent")    // primary accent — teal
        public static let onAccent = c("onAccent")  // text/icons on top of accent
        public static let terra    = c("terra")     // secondary accent — terracotta

        // MARK: Elevation / overlay
        public static let deep    = c("deep")     // deepest elevated surface
        public static let glassOn = c("glassOn")  // tint for glass/blur overlays (the Jamaal design calls this `selected`)

        // MARK: Border
        // Alpha is baked into the asset itself — apply directly, no extra .opacity().
        public static let line  = c("line")   // subtle border
        public static let line2 = c("line2")  // stronger border

        // MARK: On-surface
        public static let onDeep = c("onDeep")  // text/icons on `deep`; the same in both appearances

        // MARK: Pressed
        // A press is a fill change — never movement, never `.opacity()`.
        public static let terraPress  = c("terraPress")   // pressed fill for terra
        public static let accentPress = c("accentPress")  // pressed fill for accent

        // MARK: Density (heatmap)
        // Three filled steps plus a miss. Cells are graphics, not text: never put a numeral in one.
        public static let d1     = c("d1")      // light
        public static let d2     = c("d2")      // mid
        public static let d3     = c("d3")      // full
        public static let missed = c("missed")  // a closed / missed cell

        // MARK: Glass
        // Alpha is baked into the asset; the blur itself stays constant.
        public static let glass = c("glass")    // glass material tint

        // MARK: Destructive
        // A soft fill with alert-coloured text — never a filled alert button (only terra is filled).
        public static let alert     = c("alert")
        public static let alertSoft = c("alertSoft")

        // MARK: Derived states (no dedicated token in the source palette)
        // Pressed/hover: a fixed blend for colours that have no dedicated pressed
        // token. Prefer `terraPress` / `accentPress` where they apply.
        public static func pressed(_ base: Color) -> Color {
            base.opacity(0.85)
        }

        /// Focus ring reuses `accent` directly — no separate token exists.
        public static let focusRing = accent

        private static func c(_ name: String) -> Color {
            Color(name, bundle: .module)
        }
    }
}

/// `--shadow` from the source palette: a single elevation value, not a
/// multi-step scale like the previous contract had.
/// Light: `0 18px 40px -26px rgba(6,32,46,0.42)`
/// Dark:  `0 22px 50px -28px rgba(0,0,0,0.7)`
public enum ThreadsShadow {
    public static func apply<V: View>(to view: V, colorScheme: ColorScheme) -> some View {
        let color = colorScheme == .dark
            ? Color.black.opacity(0.7)
            : Color(red: 6/255, green: 32/255, blue: 46/255).opacity(0.42)
        let radius: CGFloat = colorScheme == .dark ? 25 : 20
        let y: CGFloat = colorScheme == .dark ? 22 : 18
        return view.shadow(color: color, radius: radius, x: 0, y: y)
    }
}

public extension View {
    func threadsShadow() -> some View {
        modifier(ThreadsShadowModifier())
    }
}

private struct ThreadsShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        ThreadsShadow.apply(to: content, colorScheme: colorScheme)
    }
}
