# ThreadsKit

Shared design-token package for the fhdamd.dev product ecosystem — currently consumed by **Jamaal**, with **Riqa** and **Hashiya** planned to follow. Distributed as a Swift Package.

## What this is

A thin, dependency-free layer exposing the Threads design system's color tokens as native SwiftUI `Color` values, each with a light and dark appearance baked in via an Xcode asset catalog — not hardcoded hex. This is `ThreadsTokens` only; a `ThreadsUI` component library is planned but not started (see [Status](#status) below).

## Status

- ✅ **Color tokens** — 12 semantic colors, light + dark, ported from the current Threads web palette.
- ✅ **Shadow** — single elevation value (`--shadow`), color-scheme aware.
- 🚧 **Typography** — not yet bundled. See [Fonts](#fonts) below for why this isn't a simple port.
- 🚧 **Spacing / radius scale** — not yet ported from the web system.
- ⛔️ **ThreadsUI (components)** — intentionally not started. Begins only once a real Jamaal screen has shipped on tokens alone, so the component set reflects actual need rather than a guess.

## Installation

In Xcode: **File → Add Package Dependency...** → paste this repo's URL → choose **"Up to Next Major Version"** starting at `1.0.0` → add `ThreadsTokens` to your target.

```swift
// Package.swift, if you're adding this to another Swift package
dependencies: [
    .package(url: "https://github.com/fahadahmed/threads-kit.git", from: "1.0.0")
]
```

## Usage

```swift
import SwiftUI
import ThreadsTokens

struct ExampleCard: View {
    var body: some View {
        Text("Hello")
            .foregroundStyle(Color.Threads.ink)
            .padding()
            .background(Color.Threads.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.Threads.line, lineWidth: 1)
            )
            .threadsShadow()
    }
}
```

Dark mode requires no branching in your view code — each token resolves to the correct appearance automatically based on the environment's color scheme, the same as any system color like `.primary`.

## Token reference

| Token | Role |
|---|---|
| `Color.Threads.app` | Page / window background |
| `Color.Threads.card` | Card, panel, and sheet surfaces |
| `Color.Threads.ink` | Primary text and icons |
| `Color.Threads.ink2` | Secondary text |
| `Color.Threads.ink3` | Tertiary / muted text |
| `Color.Threads.accent` | Primary accent (teal) |
| `Color.Threads.onAccent` | Text/icons placed on top of `accent` |
| `Color.Threads.terra` | Secondary accent (terracotta) |
| `Color.Threads.deep` | Deepest elevated surface |
| `Color.Threads.glassOn` | Tint for glass/blur overlays |
| `Color.Threads.line` | Subtle border |
| `Color.Threads.line2` | Stronger border |
| `Color.Threads.focusRing` | Focus indicator — aliased to `accent` |
| `Color.Threads.pressed(_:)` | Derived pressed/hover state for any base color (opacity blend — no dedicated token exists upstream) |
| `ThreadsShadow` / `.threadsShadow()` | Single elevation shadow, color-scheme aware |

**Not included, by design:** dedicated success/warning/error/info color tokens. The source palette doesn't define them — plausibly deliberate, consistent with a non-punitive design intent that avoids colored severity signaling. If a consuming app genuinely needs status colors, that's a decision to make explicitly when it comes up, not something to add speculatively here.

## Fonts

Not bundled yet. Two things need resolving first, not just a copy-paste port:

1. The display typeface is used at a specific variable-font width axis that Core Text can't set from SwiftUI at runtime — it needs to be **instanced into a static font file** with a font tool before it can be bundled.
2. **Font licensing must be confirmed** for every typeface before it ships inside the app binary.

## Versioning

Semantic versioning, strictly:
- **Patch** (`1.0.x`) — bug fixes, no API change.
- **Minor** (`1.x.0`) — additive, non-breaking (e.g. a new color token).
- **Major** (`x.0.0`) — anything that renames or removes an existing token. The move from the previous ceramic palette (bone/terracotta/sage/charcoal) to the current cool palette (teal accent, blue-based ink) is exactly the kind of change that warrants a major bump.

Since Jamaal, Riqa, and Hashiya will all depend on this package, a major version bump means checking and updating all three consumers deliberately — don't let them drift onto different major versions of the palette unintentionally.

## Contributing / local development

```bash
git clone https://github.com/fahadahmed/threads-kit.git
cd threads-kit
swift build
swift test
```

`Package.swift` can also be opened directly in Xcode for standalone builds, tests, and SwiftUI previews — no consuming app required.

## License

MIT — see [LICENSE](LICENSE).
