import SwiftUI

/// An opaque-channel shadow colour as the design gives it: 0–255 channels and an alpha.
public struct ThreadsShadowColor: Equatable, Sendable {
    public let red: Double, green: Double, blue: Double, alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }

    public var color: Color { Color(red: red / 255, green: green / 255, blue: blue / 255).opacity(alpha) }
}

/// The three elevations. `lift` and `float` are shadows; `hair` is a one-point line in `line`.
public enum ThreadsElevation: CaseIterable, Sendable {
    case lift, float, hair

    /// A CSS-style shadow: offset `y`, `blur`, and a (negative) `spread`.
    public struct Spec: Equatable, Sendable {
        public let y: Double
        public let blur: Double
        public let spread: Double
        public let color: ThreadsShadowColor

        /// SwiftUI's shadow radius is half the CSS blur.
        public var shadowRadius: Double { blur / 2 }
    }

    public func spec(for scheme: ColorScheme) -> Spec {
        let light = ThreadsShadowColor(red: 6, green: 32, blue: 46, alpha: 0)
        let dark = ThreadsShadowColor(red: 0, green: 0, blue: 0, alpha: 0.70)
        switch (self, scheme) {
        case (.lift, .dark), (.float, .dark):
            return Spec(y: 22, blur: 50, spread: -28, color: dark)
        case (.lift, _):
            return Spec(y: 18, blur: 40, spread: -26, color: ThreadsShadowColor(red: 6, green: 32, blue: 46, alpha: 0.42))
        case (.float, _):
            return Spec(y: 10, blur: 26, spread: -14, color: ThreadsShadowColor(red: 6, green: 32, blue: 46, alpha: 0.50))
        case (.hair, _):
            return Spec(y: 1, blur: 0, spread: 0, color: light)
        }
    }
}

public extension View {
    /// Applies an elevation. SwiftUI's `.shadow` can't take a negative spread, so the shadow is cast by
    /// the shape inset by that spread, behind the view; `hair` draws a one-point `line` along the bottom.
    func threadsElevation<S: InsettableShape>(_ elevation: ThreadsElevation, in shape: S) -> some View {
        modifier(ThreadsElevationModifier(elevation: elevation, shape: shape))
    }
}

private struct ThreadsElevationModifier<S: InsettableShape>: ViewModifier {
    let elevation: ThreadsElevation
    let shape: S
    @Environment(\.colorScheme) private var scheme
    @Environment(\.threads) private var palette

    func body(content: Content) -> some View {
        let spec = elevation.spec(for: scheme)
        if elevation == .hair {
            content.overlay(alignment: .bottom) { palette.line.frame(height: 1) }
        } else {
            content.background {
                shape.inset(by: -spec.spread)
                    .fill(spec.color.color)
                    .shadow(color: spec.color.color, radius: spec.shadowRadius, x: 0, y: spec.y)
            }
        }
    }
}
