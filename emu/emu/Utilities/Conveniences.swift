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

extension UInt8 {
  func get(bits: UInt8...) -> UInt8 {
    return bits.reduce(0) { (r, e) in
      return (r << 1) | bit(e)
    }
  }
  
  func bit(_ number: Int) -> UInt8 {
    return bit(UInt8(clamping: number))
  }
  
  func bit(_ number: UInt8) -> UInt8 {
    return (self >> number) & UInt8(0b1)
  }
  
  func test(_ number: Int) -> Bool {
    return test(UInt8(clamping: number))
  }
  
  func test(_ number: UInt8) -> Bool {
    return bit(number) == 1
  }
  
  mutating func set(_ number: UInt8, value: Bool) {
    if value {
      set(number)
    } else {
      res(number)
    }
  }
  
  mutating func set(_ number: UInt8) {
    self = self | (UInt8(0b1) << number)
  }
  
  mutating func res(_ number: UInt8) {
    self = self & ~(UInt8(0b1) << number)
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

