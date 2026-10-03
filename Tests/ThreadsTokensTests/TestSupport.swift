import Foundation
import Testing

/// Reads colorset JSON straight from the source tree, so tests check the values that ship.
struct AssetRGB: Equatable {
    let r: Double, g: Double, b: Double, a: Double

    var hex: String {
        func h(_ c: Double) -> String { String(format: "%02X", Int((c * 255).rounded())) }
        return h(r) + h(g) + h(b)
    }

    var luminance: Double {
        func lin(_ c: Double) -> Double { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }

    /// This colour composited over an opaque background.
    func over(_ bg: AssetRGB) -> AssetRGB {
        AssetRGB(r: r * a + bg.r * (1 - a), g: g * a + bg.g * (1 - a), b: b * a + bg.b * (1 - a), a: 1)
    }

    init(r: Double, g: Double, b: Double, a: Double = 1) { self.r = r; self.g = g; self.b = b; self.a = a }

    init(hex: String) {
        func c(_ i: Int) -> Double { Double(Int(hex.dropFirst(i * 2).prefix(2), radix: 16) ?? 0) / 255 }
        self.init(r: c(0), g: c(1), b: c(2))
    }
}

enum Look: String, CaseIterable { case light, dark }

let catalogURL: URL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()   // ThreadsTokensTests
    .deletingLastPathComponent()   // Tests
    .deletingLastPathComponent()   // package root
    .appendingPathComponent("Sources/ThreadsTokens/Resources/Colors-Jamaal.xcassets")

func assetColor(_ name: String, _ look: Look) throws -> AssetRGB {
    let url = catalogURL.appendingPathComponent("\(name).colorset/Contents.json")
    let json = try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    let entries = try #require(json["colors"] as? [[String: Any]])
    let entry = try #require(entries.first { entry in
        let isDark = (entry["appearances"] as? [[String: String]] ?? []).contains { $0["value"] == "dark" }
        return isDark == (look == .dark)
    }, "\(name) has no \(look.rawValue) entry")
    let components = try #require((entry["color"] as? [String: Any])?["components"] as? [String: String])
    func value(_ key: String) throws -> Double { try #require(Double(components[key] ?? "")) }
    return AssetRGB(r: try value("red"), g: try value("green"), b: try value("blue"), a: try value("alpha"))
}

func contrastRatio(_ a: AssetRGB, _ b: AssetRGB) -> Double {
    let (hi, lo) = (max(a.luminance, b.luminance), min(a.luminance, b.luminance))
    return (hi + 0.05) / (lo + 0.05)
}
