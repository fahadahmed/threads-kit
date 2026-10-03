import CoreText
import Foundation

/// The bundled typefaces: Hanken Grotesk (UI and body), Fraunces (display) and JetBrains Mono (labels),
/// all under the SIL Open Font License (the licences ship beside the fonts).
///
/// They are **static instances**, cut from the upstream variable fonts, because SwiftUI can't set a
/// variable font's axes at runtime: Fraunces at weight 500, optical size 36, SOFT 60 and WONK 1 (the
/// design's display setting; "opsz auto" can't be reproduced, so 36 sits in the middle of the 28–38 pt
/// display sizes), Hanken Grotesk at 400 and 600, JetBrains Mono at 500.
public enum ThreadsFonts {

    /// The PostScript names, which is what `Font.custom` looks up.
    public static let postScriptNames = [
        "FrauncesDisplay-Regular", "FrauncesDisplay-Italic",
        "HankenGrotesk-Regular", "HankenGrotesk-SemiBold", "JetBrainsMono-Medium",
    ]

    /// A font that couldn't be registered.
    public struct Failure: Error, CustomStringConvertible, Sendable {
        public let name: String
        public let reason: String
        public var description: String { "\(name): \(reason)" }
    }

    /// Registers every bundled font for the process. Call it once at launch, before the first view. It is
    /// idempotent: a font that is already registered is not a failure. Returns the failures (none when
    /// everything is available).
    @discardableResult
    public static func registerAll() -> [Failure] { registerAll(in: .module) }

    /// The same, from a given bundle (so a missing font can be tested).
    static func registerAll(in bundle: Bundle) -> [Failure] {
        var failures: [Failure] = []
        for name in postScriptNames {
            guard let url = bundle.url(forResource: name, withExtension: "ttf")
                ?? bundle.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                failures.append(Failure(name: name, reason: "not found in the bundle"))
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let cfError = error?.takeRetainedValue()
                let alreadyRegistered = cfError.map { CFErrorGetCode($0) == CTFontManagerError.alreadyRegistered.rawValue } ?? false
                if !alreadyRegistered {
                    failures.append(Failure(name: name, reason: cfError.map { CFErrorCopyDescription($0) as String } ?? "unknown error"))
                }
            }
        }
        return failures
    }
}
