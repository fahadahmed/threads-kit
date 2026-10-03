import CoreText
import SwiftUI

/// Six type roles (Claude Design v4 handoff §3). Leading is part of each role and isn't exposed to callers;
/// every role scales with Dynamic Type up to the largest accessibility size, except `label`, which stops at
/// `.xxLarge`. Apply one with `.threadsType(.body)`.
public enum ThreadsType {

    public enum DisplaySize: Sendable { case compact, regular, large }

    public enum Role: Sendable {
        /// Eyebrows, chip labels, times: JetBrains Mono, tracked, uppercase.
        case label
        /// A row's secondary line.
        case meta
        /// All prose.
        case body
        /// A task or habit title.
        case row
        /// Sheet intros and empty states.
        case lede
        /// Screen titles and the timer numeral: Fraunces.
        case display(DisplaySize)
    }

    public struct Spec: Equatable, Sendable {
        public let fontName: String
        public let pointSize: Double
        /// What the role scales relative to.
        public let textStyle: Font.TextStyle
        /// The line height as a multiple of the size.
        public let leading: Double
        /// Letter-spacing in em.
        public let trackingEm: Double
        public let isUppercase: Bool
        /// The largest Dynamic Type size, or `nil` for no cap.
        public let maxSize: DynamicTypeSize?

        /// Core Text's natural line height is about 1.2 × the size; SwiftUI takes the extra.
        public func extraLineSpacing(scaledSize: Double) -> Double { (leading - 1.2) * scaledSize }

        public func tracking(scaledSize: Double) -> Double { trackingEm * scaledSize }
    }

    /// Fraunces Display Italic, for an emphasised fragment of a display line ("gently paced.").
    public static let displayItalicFontName = "FrauncesDisplay-Italic"

    public static func spec(for role: Role) -> Spec {
        switch role {
        case .label:
            Spec(fontName: "JetBrainsMono-Medium", pointSize: 12, textStyle: .caption2, leading: 1.35, trackingEm: 0.16, isUppercase: true, maxSize: .xxLarge)
        case .meta:
            Spec(fontName: "HankenGrotesk-Regular", pointSize: 15, textStyle: .subheadline, leading: 1.35, trackingEm: 0, isUppercase: false, maxSize: nil)
        case .body:
            Spec(fontName: "HankenGrotesk-Regular", pointSize: 17, textStyle: .body, leading: 1.6, trackingEm: 0, isUppercase: false, maxSize: nil)
        case .row:
            Spec(fontName: "HankenGrotesk-SemiBold", pointSize: 18, textStyle: .headline, leading: 1.35, trackingEm: 0, isUppercase: false, maxSize: nil)
        case .lede:
            Spec(fontName: "HankenGrotesk-Regular", pointSize: 19, textStyle: .callout, leading: 1.6, trackingEm: 0, isUppercase: false, maxSize: nil)
        case .display(let size):
            switch size {
            case .compact: Spec(fontName: "FrauncesDisplay-Regular", pointSize: 28, textStyle: .title2, leading: 1.08, trackingEm: 0, isUppercase: false, maxSize: nil)
            case .regular: Spec(fontName: "FrauncesDisplay-Regular", pointSize: 34, textStyle: .title, leading: 1.08, trackingEm: 0, isUppercase: false, maxSize: nil)
            case .large: Spec(fontName: "FrauncesDisplay-Regular", pointSize: 38, textStyle: .largeTitle, leading: 1.08, trackingEm: 0, isUppercase: false, maxSize: nil)
            }
        }
    }
}

public extension View {
    /// Applies a type role: its font (scaling with Dynamic Type), tracking, line spacing, case and size cap.
    func threadsType(_ role: ThreadsType.Role) -> some View {
        modifier(ThreadsTypeModifier(spec: ThreadsType.spec(for: role)))
    }
}

private struct ThreadsTypeModifier: ViewModifier {
    let spec: ThreadsType.Spec
    @ScaledMetric private var size: CGFloat

    init(spec: ThreadsType.Spec) {
        self.spec = spec
        _size = ScaledMetric(wrappedValue: CGFloat(spec.pointSize), relativeTo: spec.textStyle)
    }

    func body(content: Content) -> some View {
        content
            .font(.custom(spec.fontName, size: spec.pointSize, relativeTo: spec.textStyle))
            .tracking(spec.tracking(scaledSize: Double(size)))
            .lineSpacing(spec.extraLineSpacing(scaledSize: Double(size)))
            .textCase(spec.isUppercase ? .uppercase : nil)
            .dynamicTypeSize(...(spec.maxSize ?? .accessibility5))
    }
}

/// A numeral whose digits each sit in a cell as wide as the font's widest digit, so a counting timer
/// doesn't jitter. Fraunces has **no tabular figures** (its digits differ in width), so `.monospacedDigit()`
/// can't do this for the display face; this is the display role's "monospaced digits".
public struct ThreadsNumeral: View {
    private let text: String
    private let size: ThreadsType.DisplaySize
    @ScaledMetric private var scaled: CGFloat

    public init(_ text: String, size: ThreadsType.DisplaySize = .large) {
        self.text = text
        self.size = size
        let spec = ThreadsType.spec(for: .display(size))
        _scaled = ScaledMetric(wrappedValue: CGFloat(spec.pointSize), relativeTo: spec.textStyle)
    }

    /// The width of the widest digit of `fontName` at `pointSize`.
    public static func digitCellWidth(fontName: String, pointSize: Double) -> Double {
        ThreadsFonts.registerAll()
        let font = CTFontCreateWithName(fontName as CFString, CGFloat(pointSize), nil)
        var widest = 0.0
        for digit in "0123456789".utf16 {
            var unit = digit
            var glyph = CGGlyph()
            guard CTFontGetGlyphsForCharacters(font, &unit, &glyph, 1) else { continue }
            var advance = CGSize.zero
            CTFontGetAdvancesForGlyphs(font, .horizontal, &glyph, &advance, 1)
            widest = max(widest, Double(advance.width))
        }
        return widest
    }

    public var body: some View {
        let spec = ThreadsType.spec(for: .display(size))
        let cell = CGFloat(Self.digitCellWidth(fontName: spec.fontName, pointSize: Double(scaled)))
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                Text(String(character))
                    .threadsType(.display(size))
                    .frame(width: character.isWholeNumber ? cell : nil)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
