import XCTest
@testable import TwitterAuth

final class TwitterAuthTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TwitterAuth().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
