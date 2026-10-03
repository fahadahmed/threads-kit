import CoreText
import SwiftUI
import Testing
@testable import ThreadsTokens

/// Typography: the bundled fonts, the six roles and the fixed-digit numeral (Claude Design v4 handoff §3).
struct TypographyTests {

    private static let fontsURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("Sources/ThreadsTokens/Resources/Fonts")

    // MARK: Fonts and licences

    @Test func theFiveStaticFontsAreBundledWithTheirPostScriptNames() throws {
        #expect(ThreadsFonts.postScriptNames == [
            "FrauncesDisplay-Regular", "FrauncesDisplay-Italic",
            "HankenGrotesk-Regular", "HankenGrotesk-SemiBold", "JetBrainsMono-Medium",
        ])
        for name in ThreadsFonts.postScriptNames {
            let file = Self.fontsURL.appendingPathComponent("\(name).ttf")
            #expect(FileManager.default.fileExists(atPath: file.path), "\(name).ttf")
        }
    }

    @Test func eachFontIsStaticSoSwiftUICanUseItWithoutSettingAxes() throws {
        for name in ThreadsFonts.postScriptNames {
            let url = Self.fontsURL.appendingPathComponent("\(name).ttf") as CFURL
            let descriptors = try #require(CTFontManagerCreateFontDescriptorsFromURL(url) as? [CTFontDescriptor])
            let font = CTFontCreateWithFontDescriptor(try #require(descriptors.first), 17, nil)
            let axes = CTFontCopyVariationAxes(font)
            let postScript = CTFontCopyPostScriptName(font) as String
            #expect(axes == nil, "\(name) still has variation axes")
            #expect(postScript == name)
        }
    }

    @Test func eachFontShipsWithItsOpenFontLicence() throws {
        for family in ["hankengrotesk", "fraunces", "jetbrainsmono"] {
            let text = try String(contentsOf: Self.fontsURL.appendingPathComponent("OFL-\(family).txt"), encoding: .utf8)
            #expect(text.contains("SIL OPEN FONT LICENSE Version 1.1"), "\(family)")
            #expect(text.contains("Project Authors"), "\(family)")
        }
    }

    @Test func registeringIsIdempotentAndFindsEveryFont() {
        let first = ThreadsFonts.registerAll()
        let second = ThreadsFonts.registerAll()
        #expect(first.isEmpty, "\(first)")
        #expect(second.isEmpty, "\(second)")                                    // already registered is not a failure
        for name in ThreadsFonts.postScriptNames {
            let font = CTFontCreateWithName(name as CFString, 17, nil)
            let postScript = CTFontCopyPostScriptName(font) as String
            #expect(postScript == name, "\(name) isn't available after registering")
        }
    }

    @Test func aMissingFontIsReportedNotSilentlyIgnored() throws {
        let empty = FileManager.default.temporaryDirectory.appendingPathComponent("threads-empty-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: empty, withIntermediateDirectories: true)
        let bundle = try #require(Bundle(path: empty.path))
        let failures = ThreadsFonts.registerAll(in: bundle)
        #expect(failures.count == ThreadsFonts.postScriptNames.count)
        #expect(failures.allSatisfy { $0.reason.contains("not found") })
    }

    // MARK: The six roles

    @Test func theRolesMatchTheHandoffTable() {
        func check(_ role: ThreadsType.Role, _ font: String, _ size: Double, _ style: Font.TextStyle, _ leading: Double,
                   tracking: Double = 0, upper: Bool = false) {
            let spec = ThreadsType.spec(for: role)
            #expect(spec.fontName == font)
            #expect(spec.pointSize == size)
            #expect(spec.textStyle == style)
            #expect(spec.leading == leading)
            #expect(spec.trackingEm == tracking)
            #expect(spec.isUppercase == upper)
        }
        check(.label, "JetBrainsMono-Medium", 12, .caption2, 1.35, tracking: 0.16, upper: true)
        check(.meta, "HankenGrotesk-Regular", 15, .subheadline, 1.35)
        check(.body, "HankenGrotesk-Regular", 17, .body, 1.6)
        check(.row, "HankenGrotesk-SemiBold", 18, .headline, 1.35)
        check(.lede, "HankenGrotesk-Regular", 19, .callout, 1.6)
        check(.display(.compact), "FrauncesDisplay-Regular", 28, .title2, 1.08)
        check(.display(.regular), "FrauncesDisplay-Regular", 34, .title, 1.08)
        check(.display(.large), "FrauncesDisplay-Regular", 38, .largeTitle, 1.08)
    }

    @Test func everyRoleScalesToTheLargestAccessibilitySizeExceptLabelWhichStopsAtXXLarge() {
        #expect(ThreadsType.spec(for: .label).maxSize == .xxLarge)
        for role in [ThreadsType.Role.meta, .body, .row, .lede, .display(.compact), .display(.regular), .display(.large)] {
            #expect(ThreadsType.spec(for: role).maxSize == nil, "\(role)")
        }
    }

    @Test func leadingIsPartOfTheRoleAndBecomesExtraLineSpacing() {
        // Core Text's natural line height is about 1.2 × the size; the role's leading is the CSS multiple.
        let body = ThreadsType.spec(for: .body)
        #expect(abs(body.extraLineSpacing(scaledSize: 17) - (1.6 - 1.2) * 17) < 0.0001)
        let display = ThreadsType.spec(for: .display(.regular))
        #expect(display.extraLineSpacing(scaledSize: 34) < 0)                      // tighter than natural
    }

    @Test func labelTrackingIsSixteenHundredthsOfAnEm() {
        let label = ThreadsType.spec(for: .label)
        #expect(abs(label.tracking(scaledSize: 12) - 1.92) < 0.0001)
        #expect(ThreadsType.spec(for: .body).tracking(scaledSize: 17) == 0)
    }

    // MARK: The fixed-digit numeral

    @Test func frauncesHasNoTabularFiguresSoDigitsDifferInWidth() {
        _ = ThreadsFonts.registerAll()
        let font = CTFontCreateWithName("FrauncesDisplay-Regular" as CFString, 100, nil)
        let widths = Set("0123456789".map { advance(of: $0, in: font) })
        #expect(widths.count > 1)                                                   // why `.monospacedDigit()` can't keep a timer still
    }

    @Test func theNumeralsDigitCellIsTheWidestDigitSoNothingJitters() {
        _ = ThreadsFonts.registerAll()
        let font = CTFontCreateWithName("FrauncesDisplay-Regular" as CFString, 100, nil)
        let widest = "0123456789".map { advance(of: $0, in: font) }.max() ?? 0
        let cell = ThreadsNumeral.digitCellWidth(fontName: "FrauncesDisplay-Regular", pointSize: 100)
        #expect(abs(cell - widest) < 0.01)
        #expect("0123456789".allSatisfy { advance(of: $0, in: font) <= cell + 0.01 })
    }

    @Test func theCellScalesWithTheSize() {
        _ = ThreadsFonts.registerAll()
        let small = ThreadsNumeral.digitCellWidth(fontName: "FrauncesDisplay-Regular", pointSize: 34)
        let large = ThreadsNumeral.digitCellWidth(fontName: "FrauncesDisplay-Regular", pointSize: 68)
        #expect(abs(large - 2 * small) < 0.05)
    }

    private func advance(of character: Character, in font: CTFont) -> Double {
        var glyph = CGGlyph()
        var unit = Array(String(character).utf16)
        CTFontGetGlyphsForCharacters(font, &unit, &glyph, 1)
        var advance = CGSize.zero
        CTFontGetAdvancesForGlyphs(font, .horizontal, &glyph, &advance, 1)
        return Double(advance.width)
    }
}
