# ThreadsKit

Shared design-token package for the fhdamd.dev product ecosystem — currently consumed by **Jamaal**, with **Riqa** and **Hashiya** planned to follow. Distributed as a Swift Package.

## What this is

A thin, dependency-free layer of design tokens as native SwiftUI values: colours with light and dark baked into an asset catalog, spacing, radii, hit targets, elevation and motion. This is `ThreadsTokens` only; a `ThreadsUI` component library is planned but not started.

The source of truth is the Claude Design v4 handoff for Jamaal (the `ThreadsKit Tokens` page and `docs/design/README.md` in the `jamaal-app` repo).

## Status — 2.0

- ✅ **Palette contract** — a `ThreadsPalette` protocol declaring all 21 names plus four status roles, with `JamaalPalette` as the only conformance.
- ✅ **Category colours** — five Jamaal-only label colours, outside the palette's names.
- ✅ **Space, radius, hit** — named steps, paddings, radii and the 44 pt target.
- ✅ **Elevation** — `lift`, `float`, `hair`, including the negative-spread emulation SwiftUI lacks.
- ✅ **Motion** — 140 ms and 260 ms on one curve, Reduce Motion aware.
- 🚧 **Typography** — six roles over Hanken Grotesk, Fraunces and JetBrains Mono, with the fonts bundled. Next release.
- ⛔️ **ThreadsUI (components)** — intentionally not started. Begins only once a real Jamaal screen has shipped on tokens alone.

## Installation

In Xcode: **File → Add Package Dependency...** → paste this repo's URL → choose **"Up to Next Major Version"** starting at `2.0.0` → add `ThreadsTokens` to your target.

```swift
dependencies: [
    .package(url: "https://github.com/fahadahmed/threads-kit.git", from: "2.0.0")
]
```

## Usage

Views take colours from the palette in the environment, never from a hex or a literal point value:

```swift
import SwiftUI
import ThreadsTokens

struct ExampleCard: View {
    @Environment(\.threads) private var threads

    var body: some View {
        Text("Hello")
            .foregroundStyle(threads.ink)
            .padding(ThreadsSpace.rowPadding)
            .background(threads.card, in: RoundedRectangle(cornerRadius: ThreadsRadius.card))
            .threadsElevation(.lift, in: RoundedRectangle(cornerRadius: ThreadsRadius.card))
    }
}
```

`\.threads` defaults to `JamaalPalette()`. Dark mode needs no branching: each colour resolves with the appearance, like a system colour.

## The palette

A palette is a **conformance, not a copy**: `ThreadsPalette` declares every name, so a product that leaves one out gets a compile error, not a missing colour. Names stay separate even where two values match in one appearance (`terra` / `line`, `accent` / `d3` in dark).

| Name | Role |
|---|---|
| `app`, `card`, `deep`, `onDeep`, `selected` | Screen ground · content surface · timer ground · type on it · an opaque selected row |
| `ink`, `ink2`, `ink3` | Titles · body · labels and meta (the 4.5:1 floor) |
| `terra`, `terraPress` | The primary action — **the only filled button colour**, one filled button per surface |
| `accent`, `accentPress`, `onAccent` | Done / settled · type on a filled `terra` or `accent` (flips dark in dark mode: never hardcode white) |
| `d1`, `d2`, `d3`, `missed` | Habit-grid density and a missed day (not an error) |
| `line`, `glass` | Hairlines (alpha baked in) · the tint of an action surface |
| `alert`, `alertSoft` | Destructive **text** and its soft fill — never a filled red button |
| `success`, `warning`, `lapsed`, `info` | Status roles; default to `accent`, `terra`, `missed`, `ink2` |

**Derived, not assets:** `line2` (`ink` at 24%), `glassEdge` (`line` in light, white 16% in dark) and `scrim` (`rgba(4,26,38,.32)` light, `rgba(0,0,0,.45)` dark).

**Categories** (Jamaal only): `JamaalPalette.categories` — `accent` (teal), `blue`, `ochre`, `plum`, `slate` — each at least 4.5:1 as text on `app`, `card` and the iPad sidebar. `JamaalPalette.categoryColor(forKey:)` maps a stored key to its colour; an unknown key reads as slate. `terra` is deliberately not a category colour: it carries warning and overload.

## Space, elevation, motion

- **Space:** `gutter` 26 · `section` 22 · `row` 14 · `tight` 10 · `hair` 4; row padding 12×14, chip 9×20, pill button 12×20. **Radii:** cell 3, field 8, card 14, pill (a `Capsule`). **Hit:** 44 pt, 28 pt for a Mac pointer; `.threadsHitTarget()`.
- **Elevation:** `.threadsElevation(.lift | .float | .hair, in: shape)`. `.shadow` can't take a negative spread, so the shadow is cast by the shape inset by it, behind the view.
- **Motion:** `ThreadsMotion.stateDuration` 140 ms and `surfaceDuration` 260 ms on `cubic-bezier(0, 0, 0.2, 1)`; `.threadsAnimation(.state, value:)` honours Reduce Motion (both become instant).

## Known gap in the design

`ink3` on the **dark** `selected` row is 4.4965:1, 0.0035 short of AA (it is fine everywhere else). A test pins it, so when Design nudges either colour the test fails and the pair joins the AA list.

## Migrating from 1.x (a major release)

| 1.x | 2.0 |
|---|---|
| `Color.Threads.ink` etc. | `@Environment(\.threads).ink` (or `JamaalPalette().ink`) |
| `Color.Threads.glassOn` | `selected` |
| `Color.Threads.line2` | `palette.line2` (derived) |
| `Color.Threads.focusRing`, `.pressed(_:)` | removed: use `accent` and the `*Press` colours |
| `ThreadsShadow`, `.threadsShadow()` | `.threadsElevation(_:in:)` |

## Versioning

Semantic versioning, strictly:
- **Patch** (`x.y.z`) — bug fixes, no API change.
- **Minor** — additive, non-breaking (a new colour, a new role).
- **Major** — anything that renames or removes an existing token. `2.0.0` is exactly that: the contract moved from `Color.Threads` to a palette protocol.

Jamaal, Riqa and Hashiya will all depend on this package, so a major bump means checking and updating all three deliberately.

## Contributing / local development

```bash
git clone https://github.com/fahadahmed/threads-kit.git
cd threads-kit
swift build
swift test
```

`Package.swift` can also be opened directly in Xcode for standalone builds, tests and SwiftUI previews.

## License

MIT — see [LICENSE](LICENSE).
