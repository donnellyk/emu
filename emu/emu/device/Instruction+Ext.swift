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
      let value = getValue(register, in: $0)
      let msb = value >> 7
      
      let newValue = (value << 1) | msb
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func RL(_ register: Register) -> Operation {
    return {
      let value = getValue(register, in: $0)
      let msb = value >> 7
      
      let newValue = (value << 1) | $0.registers.flags.c.bit
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func RRC(_ register: Register) -> Operation {
    return {
      let value = getValue(register, in: $0)
      let lsb = value & 0b1
      
      let newValue = (value >> 1) | (lsb << 7)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func RR(_ register: Register) -> Operation {
    return {
      let value = getValue(register, in: $0)
      let lsb = value & 0b1
      
      let newValue = ($0.registers.flags.c.bit << 7) | (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func SLA(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let msb = value >> 7
      
      let new = value << 1
      
      register.set(new, in: $0)
      
      $0.registers.flags.z = new == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c.bit = msb
    }
  }
  
  static func SRA(_ register: Register) -> Operation {
    return {
      let value = getValue(register, in: $0)
      let lsb = value & 0b1
      let msb = value & 0x80
      
      let newValue = msb | (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func SRL(_ register: Register) -> Operation {
    return {
      let value = getValue(register, in: $0)
      let lsb = value & 0b1
      
      let newValue = (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func Bit(_ number: UInt8, _ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let bit = (value >> number) & UInt8(0b1)
      
      $0.registers.flags.z = bit == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = true
    }
  }
  
  static func Set(_ number: UInt8, _ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let bit = UInt8(0b1) << number
      
      register.set(value | bit, in: $0)
    }
  }
}
