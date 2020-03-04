import XCTest
@testable import DSCore

final class DSCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DSCore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
