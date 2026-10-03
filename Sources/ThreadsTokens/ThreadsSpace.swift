import SwiftUI

/// Named spacing steps. Views never use a literal point value (docs/design handoff §4).
public enum ThreadsSpace {
    /// The side margin: a *minimum*. Resolve each edge against its own safe-area or layout-margin inset
    /// (iPhone Duo's are asymmetric).
    public static let gutter: CGFloat = 26
    public static let section: CGFloat = 22
    /// The workhorse gap.
    public static let row: CGFloat = 14
    public static let tight: CGFloat = 10
    public static let hair: CGFloat = 4

    /// A task or habit row: 12 × 14.
    public static let rowPadding = EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
    /// A chip: 9 × 20.
    public static let chipPadding = EdgeInsets(top: 9, leading: 20, bottom: 9, trailing: 20)
    /// A pill button: 12 × 20.
    public static let pillButtonPadding = EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
}

/// Corner radii. Every button, chip and checkbox is a pill (a `Capsule`). The 30–48 pt radii in the
/// design frames are device bezels and are not tokens.
public enum ThreadsRadius {
    /// A density-grid cell.
    public static let cell: CGFloat = 3
    /// A field or inline block.
    public static let field: CGFloat = 8
    /// A card, a selected row, a sheet.
    public static let card: CGFloat = 14
    public static var pill: Capsule { Capsule() }
}

/// Hit targets. A visual mark stays 20–22 pt and gets a 44 pt `contentShape`.
public enum ThreadsHit {
    public static let minimum: CGFloat = 44
    /// The pointer target on Mac.
    public static let pointer: CGFloat = 28
}

public extension View {
    /// Gives a small mark the 44 pt target.
    func threadsHitTarget() -> some View {
        frame(minWidth: ThreadsHit.minimum, minHeight: ThreadsHit.minimum).contentShape(Rectangle())
    }
}
