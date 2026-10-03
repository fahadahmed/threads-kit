import SwiftUI
import Testing
@testable import ThreadsTokens

/// The 21 names and the five category colours, checked against the Claude Design v4 handoff.
struct PaletteTests {

    /// name, light hex, light alpha, dark hex, dark alpha.
    static let table: [(String, String, Double, String, Double)] = [
        ("app", "EFF4F0", 1, "12303F", 1), ("card", "FFFFFF", 1, "FFFFFF", 0.05),
        ("deep", "0C4767", 1, "071B27", 1), ("onDeep", "EAF3F6", 1, "EAF3F6", 1),
        ("ink", "0A3A53", 1, "E7F1F4", 1), ("ink2", "14506E", 1, "BCD3DA", 1), ("ink3", "3F6E80", 1, "8FAAB4", 1),
        ("terra", "9A4F2E", 1, "DDA080", 1), ("terraPress", "7E3F24", 1, "C08868", 1),
        ("accent", "1F6A58", 1, "8FCBB8", 1), ("accentPress", "175245", 1, "74B3A0", 1),
        ("onAccent", "EAF3F6", 1, "16242E", 1),
        ("d1", "D3E3DB", 1, "2B4A46", 1), ("d2", "71A393", 1, "4E7D72", 1), ("d3", "0C4767", 1, "8FCBB8", 1),
        ("missed", "E3BEAB", 1, "6B4A38", 1),
        ("line", "0A3A53", 0.14, "E7F1F4", 0.14), ("glass", "FFFFFF", 0.62, "FFFFFF", 0.09),
        ("selected", "FFFFFF", 1, "1D4052", 1),
        ("alert", "A32E22", 1, "F09A90", 1), ("alertSoft", "F2D4CE", 1, "5A2A22", 1),
        ("catBlue", "2F5E9E", 1, "9DB9E8", 1), ("catOchre", "836312", 1, "D8BA6A", 1),
        ("catPlum", "7B4474", 1, "D5A6CC", 1), ("catSlate", "52636E", 1, "AEBCC6", 1),
    ]

    @Test(arguments: table)
    func everyTokenMatchesTheHandoff(row: (String, String, Double, String, Double)) throws {
        let light = try assetColor(row.0, .light), dark = try assetColor(row.0, .dark)
        #expect(light.hex == row.1, "\(row.0) light")
        #expect(dark.hex == row.3, "\(row.0) dark")
        #expect(abs(light.a - row.2) < 0.002, "\(row.0) light alpha")
        #expect(abs(dark.a - row.4) < 0.002, "\(row.0) dark alpha")
    }

    @Test func theCatalogHoldsExactlyTheNamesAndNoStrays() throws {
        let present = try FileManager.default.contentsOfDirectory(atPath: catalogURL.path)
            .filter { $0.hasSuffix(".colorset") }.map { String($0.dropLast(9)) }
        #expect(Set(present) == Set(Self.table.map(\.0)))
        #expect(!present.contains("line2"))           // derived from ink, not an asset
        #expect(!present.contains("glassOn"))         // renamed `selected`
    }

    // MARK: Contrast

    @Test(arguments: [
        ("onAccent", "accent"), ("onAccent", "terra"), ("onAccent", "terraPress"), ("onAccent", "accentPress"),
        ("ink", "app"), ("ink2", "app"), ("ink3", "app"), ("terra", "app"), ("accent", "app"),
        ("ink", "selected"), ("ink2", "selected"),
        ("onDeep", "deep"), ("alert", "alertSoft"),
    ], Look.allCases)
    func textPairsClearAA(pair: (String, String), look: Look) throws {
        let ratio = contrastRatio(try assetColor(pair.0, look), try assetColor(pair.1, look))
        #expect(ratio >= 4.5, "\(pair.0) on \(pair.1) (\(look.rawValue)) is \(String(format: "%.2f", ratio)):1")
    }

    /// **A known gap in the design, flagged rather than papered over.** `ink3` on the *dark* `selected` row
    /// is 4.4965:1, 0.0035 short of AA. It is fine on every other surface (5.6:1 on `app`, 4.9:1 on `card`).
    /// If Design nudges `selected` or `ink3`, this test fails and should be folded into the AA list above.
    @Test func ink3OnTheDarkSelectedRowIsJustUnderAA() throws {
        let ratio = contrastRatio(try assetColor("ink3", .dark), try assetColor("selected", .dark))
        #expect(ratio >= 4.49 && ratio < 4.5, "is \(String(format: "%.4f", ratio)):1")
        #expect(contrastRatio(try assetColor("ink3", .light), try assetColor("selected", .light)) >= 4.5)
    }

    /// A category's name is drawn in ink beside its dot, but the colour also has to hold up as text.
    @Test(arguments: ["accent", "catBlue", "catOchre", "catPlum", "catSlate"], Look.allCases)
    func categoryColoursClearAAOnTheSurfaces(name: String, look: Look) throws {
        let fg = try assetColor(name, look)
        let app = try assetColor("app", look)
        let card = try assetColor("card", look).over(app)
        #expect(contrastRatio(fg, app) >= 4.5, "\(name) on app (\(look.rawValue))")
        #expect(contrastRatio(fg, card) >= 4.5, "\(name) on card (\(look.rawValue))")
    }

    @Test(arguments: ["accent", "catBlue", "catOchre", "catPlum", "catSlate"])
    func categoryColoursClearAAOnTheLightIPadSidebar(name: String) throws {
        #expect(contrastRatio(try assetColor(name, .light), AssetRGB(hex: "E4ECE7")) >= 4.5)
    }

    @Test func onAccentAndDeepAreNotSwapped() throws {
        #expect(try assetColor("onAccent", .light).hex == "EAF3F6")
        #expect(try assetColor("onAccent", .dark).hex == "16242E")
        #expect(try assetColor("deep", .light).hex == "0C4767")
        #expect(try assetColor("deep", .dark).hex == "071B27")
    }

    @Test func destructiveIsASoftFillWithAlertTextAndNothingElseIsRed() throws {
        let soft = try assetColor("alertSoft", .light)
        let alert = try assetColor("alert", .light)
        #expect(soft.luminance > alert.luminance)                          // a pale fill under darker text
        #expect(contrastRatio(alert, soft) >= 4.5)
    }

    // MARK: The palette in code

    @Test func theStatusRolesDefaultToWhatJamaalMapsThemTo() {
        let palette = JamaalPalette()
        #expect(palette.success == palette.accent)
        #expect(palette.warning == palette.terra)
        #expect(palette.lapsed == palette.missed)
        #expect(palette.info == palette.ink2)
    }

    @Test func derivedColoursComeFromTheNamedOnes() {
        let palette = JamaalPalette()
        #expect(palette.line2 == palette.ink.opacity(0.24))
    }

    @Test func aPaletteThatProvidesEveryNameConformsAndGetsTheStatusDefaults() {
        struct Minimal: ThreadsPalette {
            let app = Color.white, card = Color.white, deep = Color.black, onDeep = Color.white, selected = Color.white
            let ink = Color.black, ink2 = Color.black, ink3 = Color.gray
            let terra = Color.orange, terraPress = Color.orange, accent = Color.green, accentPress = Color.green, onAccent = Color.white
            let d1 = Color.gray, d2 = Color.gray, d3 = Color.black, missed = Color.red
            let line = Color.gray, glass = Color.white, alert = Color.red, alertSoft = Color.pink
        }
        let palette = Minimal()
        #expect(palette.success == palette.accent)                             // a missing name is a compile error; the roles have defaults
    }

    // MARK: Categories

    @Test func thereAreFiveCategoryColoursInThePickersOrderWithoutTerra() {
        #expect(JamaalPalette.categories.map(\.key) == ["accent", "blue", "ochre", "plum", "slate"])
    }

    @Test func theTealCategoryIsTheAccent() {
        #expect(JamaalPalette.categoryColor(forKey: "accent") == JamaalPalette().accent)
    }

    @Test func anUnknownKeyWrittenByANewerAppReadsAsSlate() {
        #expect(JamaalPalette.categoryColor(forKey: "chartreuse") == JamaalPalette.categoryColor(forKey: "slate"))
        #expect(JamaalPalette.categoryColor(forKey: "blue") != JamaalPalette.categoryColor(forKey: "slate"))
    }
}
