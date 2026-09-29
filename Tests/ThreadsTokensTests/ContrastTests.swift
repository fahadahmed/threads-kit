import Foundation
import Testing

/// These tests read the colorset JSON straight from the source tree, so they check
/// the values that ship rather than a runtime-resolved colour. Light and dark are
/// stored as separate entries in each `Contents.json`; a swapped pair is exactly the
/// kind of mistake a resolved-colour test would not localise.

private struct RGB {
    let r: Double, g: Double, b: Double, a: Double

    var hex: String {
        func h(_ c: Double) -> String { String(format: "%02X", Int((c * 255).rounded())) }
        return h(r) + h(g) + h(b)
    }

    var luminance: Double {
        func lin(_ c: Double) -> Double { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }
}

private enum Appearance: String, CaseIterable { case light, dark }

private func color(_ name: String, _ appearance: Appearance) throws -> RGB {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // ThreadsTokensTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // package root
    let url = root.appendingPathComponent(
        "Sources/ThreadsTokens/Resources/Colors.xcassets/\(name).colorset/Contents.json")
    let data = try Data(contentsOf: url)
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    let entries = try #require(json["colors"] as? [[String: Any]])

    let entry = try #require(entries.first { entry in
        let appearances = entry["appearances"] as? [[String: String]] ?? []
        let isDark = appearances.contains { $0["value"] == "dark" }
        return isDark == (appearance == .dark)
    }, "\(name) has no \(appearance.rawValue) entry")

    let components = try #require((entry["color"] as? [String: Any])?["components"] as? [String: String])
    func value(_ key: String) throws -> Double { try #require(Double(components[key] ?? "")) }
    return RGB(r: try value("red"), g: try value("green"), b: try value("blue"), a: try value("alpha"))
}

private func contrast(_ a: RGB, _ b: RGB) -> Double {
    let (hi, lo) = (max(a.luminance, b.luminance), min(a.luminance, b.luminance))
    return (hi + 0.05) / (lo + 0.05)
}

/// Text on a filled surface must clear WCAG AA (4.5:1) in both appearances.
@Test(arguments: [
    ("onAccent", "accent"),
    ("onAccent", "terra"),
    ("ink", "app"),
    ("ink2", "app"),
    ("ink3", "app"),
    ("terra", "app"),
], Appearance.allCases)
private func textPairsClearAA(pair: (String, String), appearance: Appearance) throws {
    let fg = try color(pair.0, appearance)
    let bg = try color(pair.1, appearance)
    let ratio = contrast(fg, bg)
    #expect(ratio >= 4.5, "\(pair.0) on \(pair.1) (\(appearance.rawValue)) is \(String(format: "%.2f", ratio)):1")
}

/// Guards the light/dark pairs that were once swapped, against the values drawn in the
/// Jamaal design (ThreadsKit Tokens page).
@Test func onAccentAndDeepAreNotSwapped() throws {
    #expect(try color("onAccent", .light).hex == "EAF3F6")
    #expect(try color("onAccent", .dark).hex == "16242E")
    #expect(try color("deep", .light).hex == "0C4767")
    #expect(try color("deep", .dark).hex == "071B27")
}
