import SwiftUI

/// Two durations and one curve. With Reduce Motion both are zero and a sheet cross-fades instead.
public enum ThreadsMotion {
    public enum Kind: Sendable { case state, surface }

    /// A press, a check, a chip: 140 ms.
    public static let stateDuration: Double = 0.140
    /// A surface arriving (a sheet, a screen): 260 ms.
    public static let surfaceDuration: Double = 0.260
    /// `cubic-bezier(0, 0, 0.2, 1)`.
    public static let curve: [Double] = [0, 0, 0.2, 1]

    public static func duration(_ kind: Kind, reduceMotion: Bool) -> Double {
        if reduceMotion { return 0 }
        return kind == .state ? stateDuration : surfaceDuration
    }

    /// The animation for a kind, or `nil` under Reduce Motion.
    public static func animation(_ kind: Kind, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .timingCurve(curve[0], curve[1], curve[2], curve[3], duration: duration(kind, reduceMotion: false))
    }
}

public extension View {
    /// Animates changes of `value` with Threads motion, honouring Reduce Motion.
    func threadsAnimation<V: Equatable>(_ kind: ThreadsMotion.Kind, value: V) -> some View {
        modifier(ThreadsAnimationModifier(kind: kind, value: value))
    }
}

private struct ThreadsAnimationModifier<V: Equatable>: ViewModifier {
    let kind: ThreadsMotion.Kind
    let value: V
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(ThreadsMotion.animation(kind, reduceMotion: reduceMotion), value: value)
    }
}
