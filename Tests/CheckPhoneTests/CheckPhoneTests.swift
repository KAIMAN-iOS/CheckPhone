import XCTest
@testable import CheckPhone

final class CheckPhoneTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CheckPhone().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
