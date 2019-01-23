import Foundation

extension Array {
  subscript (_ index: UInt16) -> Element {
    get {
      return self[Int(index)]
    }
    set {
      self[Int(index)] = newValue
    }
  }
  
  subscript (_ index: UInt8) -> Element {
    get {
      return self[Int(index)]
    }
    set {
      self[Int(index)] = newValue
    }
  }
}

extension UInt16 {
  var toHex: String {
    return "0x" + String(format:"%02X", self)
  }
  
  init(high: UInt8, low: UInt8) {
    self = (UInt16(high) << 8) | UInt16(low)
  }
  
  func split() -> (high: UInt8, low: UInt8) {
    return (UInt8(self >> 8), UInt8(self & 0xff))
  }
  
  
}

extension Bool {
  var bit: UInt8 {
    get {
      return self ? 1 : 0
    }
    set {
      self = (newValue == 1)
    }
  }
}

