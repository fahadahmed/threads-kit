import SwiftUI
import Testing
@testable import ThreadsTokens

@Test func focusRingMatchesAccent() {
    // Sanity check the derived token stays wired to its source.
    #expect(Color.Threads.focusRing == Color.Threads.accent)
}
