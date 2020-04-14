import XCTest
@testable import emu

class TileTests: XCTestCase {

  func testRow() {
    let row = VRAM.Row()
    row.update(low: 0b11110011, high: 0b0000000)
    XCTAssertEqual(row.stringRepresentation, "XXXXXXXX____XXXX")
    
    row.update(low: 0b11110011, high: 0b0001100)
    XCTAssertEqual(row.stringRepresentation, "XXXXXXXXYYYYXXXX")
  }
  
  func testRowRender() {
    let row = VRAM.Row()
    row.update(low: 0b11110011, high: 0b0000000)
    
    var canvas = BitmapCanvas(8, 1)
    row.render(canvas: &canvas, offset: NSPoint(x: 0, y: 0))
        
    XCTAssertEqual(canvas[0,0].hexValue, "#000000")
    XCTAssertEqual(canvas[0,1].hexValue, "#000000")
    XCTAssertEqual(canvas[0,2].hexValue, "#000000")
    XCTAssertEqual(canvas[0,3].hexValue, "#000000")
    XCTAssertEqual(canvas[0,4].hexValue, "#FFFFFF")
    XCTAssertEqual(canvas[0,5].hexValue, "#FFFFFF")
    XCTAssertEqual(canvas[0,6].hexValue, "#000000")
    XCTAssertEqual(canvas[0,7].hexValue, "#000000")
  }
}
