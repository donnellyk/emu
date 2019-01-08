import Foundation

extension I {
  static func RLCA() -> Operation {
    return RLC(.a)
  }
  
  static func RLA() -> Operation {
    return RL(.a)
  }
  
  static func RRCA() -> Operation {
    return RRC(.a)
  }
  
  static func RRA() -> Operation {
    return RR(.a)
  }
  
  static func RLC(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let msb = value >> 7
      
      let newValue = (value << 1) | msb
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.n = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func RL(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let msb = value >> 7
      
      let newValue = (value << 1) | $0.registers.flags.c.bit
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.n = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func RRC(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let lsb = value & 0b1
      
      let newValue = (value >> 1) | (lsb << 7)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.n = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func RR(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let lsb = value & 0b1
      
      let newValue = ($0.registers.flags.c.bit << 7) | (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.n = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
}
