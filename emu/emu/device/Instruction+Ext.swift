import Foundation

extension I {
  static func rlca() -> Operation {
    return rlc(.a)
  }
  
  static func rla() -> Operation {
    return rl(.a)
  }
  
  static func rrca() -> Operation {
    return rrc(.a)
  }
  
  static func rra() -> Operation {
    return rr(.a)
  }
  
  static func rlc(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let msb = value >> 7
      
      let newValue = (value << 1) | msb
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func rl(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let msb = value >> 7
      
      let newValue = (value << 1) | $0.registers.flags.c.bit
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = msb == 1
    }
  }
  
  static func rrc(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let lsb = value & 0b1
      
      let newValue = (value >> 1) | (lsb << 7)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func rr(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let lsb = value & 0b1
      
      let newValue = ($0.registers.flags.c.bit << 7) | (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func sla(_ register: Register) -> Operation {
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
  
  static func sra(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
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
  
  static func srl(_ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let lsb = value & 0b1
      
      let newValue = (value >> 1)
      
      register.set(newValue, in: $0)
      
      $0.registers.flags.z = newValue == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = lsb == 1
    }
  }
  
  static func bit(_ number: UInt8, _ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let bit = (value >> number) & UInt8(0b1)
      
      $0.registers.flags.z = bit == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = true
    }
  }
  
  static func set(_ number: UInt8, _ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let bit = UInt8(0b1) << number
      
      register.set(value | bit, in: $0)
    }
  }
  
  static func res(_ number: UInt8, _ register: Register) -> Operation {
    return {
      let value = register.get8($0)
      let bit = ~(UInt8(0b1) << number)
      
      register.set(value & bit, in: $0)
    }
  }
}
