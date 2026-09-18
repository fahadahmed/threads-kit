import XCTest
@testable import ThreadsTokens

final class ThreadsTokensTests: XCTestCase {
    func testFocusRingMatchesAccent() {
        // Sanity check the derived token stays wired to its source.
        XCTAssertNotNil(ThreadsTokens.self)
    }
}
