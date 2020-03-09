import XCTest
@testable import RLTextField

final class RLTextFieldTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RLTextField().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
