import Foundation

// MARK: COMPUTED VARS
extension MMU {
  var lcdc: LCDC {
    return LCDC(read(.lcdc))
  }
  
  var stat: STAT {
    return STAT(read(.stat))
  }
}

// MARK: DEFINITIONS
extension MMU {
  struct LCDC {
    var value: UInt8
    
    init(_ value: UInt8) {
      self.value = value
    }
    
    var bgDisplayFlag: Bool {
      return value.test(0)
    }
    
    var objFlag: Bool {
      return value.test(1)
    }
    
    var objBlockCompFlag: Bool {
      return value.test(2)
    }
    
    var bgCodeAreaFlag: Bool {
      return value.test(3)
    }
    
    var bgCharAreaFlag: Bool {
      return value.test(4)
    }
    
    var windowFlag: Bool {
      return value.test(5)
    }
    
    var windowCodeAreaFlag: Bool {
      return value.test(6)
    }
    
    var stopFlag: Bool {
      return value.test(7)
    }
  }
  
  struct STAT {
    var value: UInt8
    
    init(_ value: UInt8) {
      self.value = value
    }
    
    var mode: PPU.Mode {
      return PPU.Mode(rawValue: value & 0x02)!
    }
    
    var matchFlag: Bool {
      return value.test(2)
    }
    
    // TODO: Interrupts?!
  }
}

extension MMU.LCDC {
  var objBlockCompMode: PPU.ObjBlockMode {
    return objBlockCompFlag ? .mode16 : .mode8
  }
  
  var bgCodeArea: UInt16 {
    return bgCodeAreaFlag ? 0x9800 : 0x9C00
  }
  
  var bgCharArea: UInt16 {
    return bgCharAreaFlag ? 0x8800 : 0x8000
  }
  
  var windowCodeArea: UInt16 {
    return windowCodeAreaFlag ? 0x9800 : 0x9C00
  }
  
  static func checkStopFlag(old: UInt8, new: UInt8) -> Bool {
    let oldBit7 = old.test(7)
    let newBit7 = new.test(7)
    
    switch (oldBit7, newBit7) {
    case (true, false):
      return true
      
    default:
      return false
    }
  }
}
