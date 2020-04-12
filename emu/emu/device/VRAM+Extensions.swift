import Foundation
import Cocoa


extension VRAM {
  static var begin: UInt16 = 0x8000
  static var end: UInt16 = 0x9FFF
  static var size: UInt16 = end - begin + 1
  
  private static var tileIteration: [Int] = (0..<8).reversed()
  
  static var tileSize: UInt16 = 16
  static var tileLimit = 384
  
  class Tile {
    var rows: [Row]
    
    init() {
      rows = []
      tileIteration.forEach { _ in
        rows.append(Row())
      }
    }
    
    var stringRepresentation: String {
      return rows.map { $0.stringRepresentation }.joined(separator: "\n")
    }
    
    func updateRow(_ row: UInt16, low: UInt8, high: UInt8) {
      rows[row].update(low: low, high: high)
    }
    
    func render(canvas: inout BitmapCanvas, offset: NSPoint) {
      rows.enumerated().forEach { (i, el) in
        el.render(canvas: &canvas, offset: NSPoint(x: offset.x, y: offset.y + CGFloat(i)))
      }
    }
  }
  
  class Row {
    private var high: UInt8 = 0
    private var low: UInt8 = 0
    
    private(set) var pixelValues: [PixelValue]
    
    var stringRepresentation: String {
      return pixelValues.map { $0.stringRepresentation }.joined()
    }
    
    init() {
      pixelValues = []
      tileIteration.forEach { _ in
        pixelValues.append(.zero)
      }
    }
    
    func update(low: UInt8, high: UInt8) {
      self.low = low
      self.high = high
      
      recalculatePixelValues()
    }
    
    private func recalculatePixelValues() {
      tileIteration.forEach { pixelValues[$0] = PixelValue(lsb: low.bit($0), msb: high.bit($0)) }
    }
    
    func render(canvas: inout BitmapCanvas, offset: NSPoint) {
      tileIteration.forEach {
        let i = 7 - $0
        let el = pixelValues[$0]
        
        canvas.setColor(NSPoint(x: offset.x + CGFloat(i), y: offset.y), color: el.defaultColor)
      }
      
    }
  }
  
  enum PixelValue : String {
    case zero, one, two, three
    
    var stringRepresentation: String {
      switch self {
      case .zero: return "  "
      case .one: return "01"
      case .two: return "02"
      case .three: return "03"
      }
    }
    
    var defaultColor: NSColor {
      switch self {
      case .zero: return .white
      case .one: return .lightGray
      case .two: return .darkGray
      case .three: return .black
      }
    }
    
    init(lsb: UInt8, msb: UInt8) {
      switch (Int(lsb), Int(msb)) {
      case (0, 0): self = .zero
      case (1, 0): self = .one
      case (0, 1): self = .two
      default: self = .three
      }
    }
  }
}
