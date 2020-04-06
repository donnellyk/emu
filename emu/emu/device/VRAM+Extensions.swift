import Foundation

extension VRAM {
  static var begin: UInt16 = 0x8000
  static var end: UInt16 = 0x9FFF
  static var size: UInt16 = end - begin + 1
  
  private static var standardRange: Range<Int> = (0..<8)
  
  static var tileSize: UInt16 = 16
  static var tileLimit = 384
  
  class Tile {
    var rows: [Row]
    
    init() {
      rows = []
      standardRange.forEach { _ in
        rows.append(Row())
      }
    }
    
    var stringRepresentation: String {
      return rows.map { $0.stringRepresentation }.joined(separator: "\n")
    }
    
    func updateRow(_ row: UInt16, low: UInt8, high: UInt8) {
      rows[row].update(low: low, high: high)
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
      standardRange.forEach { _ in
        pixelValues.append(.zero)
      }
    }
    
    func update(low: UInt8, high: UInt8) {
      self.low = low
      self.high = high
      
      recalculatePixelValues()
    }
    
    private func recalculatePixelValues() {
      standardRange.forEach {
        let i = UInt8(clamping: $0)
        
        let mask = 1 << (7 - i)
        let lsb = low & mask
        let msb = high & mask
        
        pixelValues[i] = PixelValue(lsb: lsb, msb: msb)
      }
    }
  }
  
  enum PixelValue : String {
    case zero, one, two, three
    
    var stringRepresentation: String {
      switch self {
      case .zero: return "0"
      case .one: return "1"
      case .two: return "2"
      case .three: return "3"
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
