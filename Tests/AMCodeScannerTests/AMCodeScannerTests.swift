import XCTest
@testable import AMCodeScanner

final class AMCodeScannerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AMCodeScanner().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
