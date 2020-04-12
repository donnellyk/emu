import XCTest
@testable import emu

class ConvienceTests: XCTestCase {
  func testBit() {
    let one: UInt8 = 0b00000001
    
    XCTAssertEqual(one.bit(0), 1)
    XCTAssertEqual(one.bit(1), 0)
    XCTAssertEqual(one.bit(2), 0)
    XCTAssertEqual(one.bit(3), 0)
    XCTAssertEqual(one.bit(4), 0)
    XCTAssertEqual(one.bit(5), 0)
    XCTAssertEqual(one.bit(6), 0)
    XCTAssertEqual(one.bit(7), 0)
    
    let two: UInt8 = 0xFF
    XCTAssertEqual(two.bit(0), 1)
    XCTAssertEqual(two.bit(1), 1)
    XCTAssertEqual(two.bit(2), 1)
    XCTAssertEqual(two.bit(3), 1)
    XCTAssertEqual(two.bit(4), 1)
    XCTAssertEqual(two.bit(5), 1)
    XCTAssertEqual(two.bit(6), 1)
    XCTAssertEqual(two.bit(7), 1)
  }
}
