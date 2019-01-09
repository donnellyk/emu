import Foundation

enum Register {
  case a, b, c, d, e, h, l
  case bc, de, hl
  
  var is16Bit: Bool {
    switch self {
    case .bc, .de, .hl:
      return true
    default:
      return false
    }
  }
  
  var is8Bit: Bool {
    switch self {
    case .bc, .de, .hl:
      return false
    default:
      return true
    }
  }
  
  func set(_ value: UInt8, in cpu: CPU) {
    switch self {
    case .a:
      cpu.registers.a = value
    case .b:
      cpu.registers.b = value
    case .c:
      cpu.registers.c = value
    case .d:
      cpu.registers.d = value
    case .e:
      cpu.registers.e = value
    case .h:
      cpu.registers.h = value
    case .l:
      cpu.registers.l = value
    default:
      fatalError("Can not write UInt8 to non 8-bit register")
    }
  }
  
  func set(_ value: UInt16, in cpu: CPU) {
    switch self {
    case .bc:
      cpu.registers.bc = value
    case .de:
      cpu.registers.de = value
    case .hl:
      cpu.registers.hl = value
    default:
      fatalError("Can not write UInt16 to 8-bit register")
    }
  }
  
  func get(from cpu: CPU) -> UInt8 {
    switch self {
    case .a:
      return cpu.registers.a
    case .b:
      return cpu.registers.b
    case .c:
      return cpu.registers.c
    case .d:
      return cpu.registers.d
    case .e:
      return cpu.registers.e
    case .h:
      return cpu.registers.h
    case .l:
      return cpu.registers.l
    case .hl:
      return cpu.mmu.read(get16(cpu))
    default:
      fatalError("Can not read UInt8 from 16-bit register")
    }
  }
  
  func get(from cpu:CPU) -> UInt16 {
    switch self {
    case .bc:
      return cpu.registers.bc
    case .de:
      return cpu.registers.de
    case .hl:
      return cpu.registers.hl
    default:
      return UInt16(get8(cpu))
    }
  }
  
  func get8(_ cpu: CPU) -> UInt8 {
    return get(from: cpu)
  }
  
  func get16(_ cpu: CPU) -> UInt16 {
    return get(from: cpu)
  }
}

public extension CPU {
  class Flags {
    var z: Bool = false
    var n: Bool = false
    var h: Bool = false
    var c: Bool = false
    
    var byteValue: UInt8 {
      return z.bit << 7 |
        n.bit << 6 |
        h.bit << 5 |
        c.bit << 4
    }
    
    func set(z: Bool, n: Bool, h: Bool, c: Bool) {
      self.z = z
      self.n = n
      self.h = h
      self.c = c
    }
  }
  
  class Registers {
    var a:UInt8 = 0
    var b:UInt8 = 0
    var c:UInt8 = 0
    var d:UInt8 = 0
    var e:UInt8 = 0
    var h:UInt8 = 0
    var l:UInt8 = 0
    
    var flags = Flags()
    
    var pc:UInt16 = 0
    var sp:UInt16 = 0
    
    
    
    var af:UInt16 {
      return join(a, flags.byteValue)
    }
    
    
    var bc: UInt16 {
      get {
        return join(b, c)
      }
      set {
        (b, c) = split(newValue)
      }
    }
    
    var de: UInt16 {
      get {
        return join(d, e)
      }
      set {
        (d, e) = split(newValue)
      }
    }
    
    var hl: UInt16 {
      get {
        return join(h, l)
      }
      set {
        (h, l) = split(newValue)
      }
    }
    
    private func split(_ value:UInt16) -> (high: UInt8, low: UInt8) {
      return (UInt8(value >> 8), UInt8(value & 0xff))
    }
    
    private func join(_ high: UInt8, _ low: UInt8) -> UInt16 {
      return (UInt16(high) << 8) | UInt16(low)
    }
    
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

