import Foundation

extension I {
  static var extInstructions: [Instruction] = [
    // 0x0n
    Instruction(opcode: 0x00, operation: rlc(.b), cycles: 8),
    Instruction(opcode: 0x01, operation: rlc(.c), cycles: 8),
    Instruction(opcode: 0x02, operation: rlc(.d), cycles: 8),
    Instruction(opcode: 0x03, operation: rlc(.e), cycles: 8),
    Instruction(opcode: 0x04, operation: rlc(.h), cycles: 8),
    Instruction(opcode: 0x05, operation: rlc(.l), cycles: 8),
    Instruction(opcode: 0x06, operation: rlc(.hl), cycles: 16),
    Instruction(opcode: 0x07, operation: rlc(.a), cycles: 8),
    Instruction(opcode: 0x08, operation: rrc(.b), cycles: 8),
    Instruction(opcode: 0x09, operation: rrc(.c), cycles: 8),
    Instruction(opcode: 0x0A, operation: rrc(.d), cycles: 8),
    Instruction(opcode: 0x0B, operation: rrc(.e), cycles: 8),
    Instruction(opcode: 0x0C, operation: rrc(.h), cycles: 8),
    Instruction(opcode: 0x0D, operation: rrc(.l), cycles: 8),
    Instruction(opcode: 0x0E, operation: rrc(.hl), cycles: 16),
    Instruction(opcode: 0x0F, operation: rrc(.a), cycles: 8),
    
    // 0x1n
    Instruction(opcode: 0x10, operation: rl(.b), cycles: 8),
    Instruction(opcode: 0x11, operation: rl(.c), cycles: 8),
    Instruction(opcode: 0x12, operation: rl(.d), cycles: 8),
    Instruction(opcode: 0x13, operation: rl(.e), cycles: 8),
    Instruction(opcode: 0x14, operation: rl(.h), cycles: 8),
    Instruction(opcode: 0x15, operation: rl(.l), cycles: 8),
    Instruction(opcode: 0x16, operation: rl(.hl), cycles: 16),
    Instruction(opcode: 0x17, operation: rl(.a), cycles: 8),
    Instruction(opcode: 0x18, operation: rr(.b), cycles: 8),
    Instruction(opcode: 0x19, operation: rr(.c), cycles: 8),
    Instruction(opcode: 0x1A, operation: rr(.d), cycles: 8),
    Instruction(opcode: 0x1B, operation: rr(.e), cycles: 8),
    Instruction(opcode: 0x1C, operation: rr(.h), cycles: 8),
    Instruction(opcode: 0x1D, operation: rr(.l), cycles: 8),
    Instruction(opcode: 0x1E, operation: rr(.hl), cycles: 16),
    Instruction(opcode: 0x1F, operation: rr(.a), cycles: 8),
    
    // 0x2n
    Instruction(opcode: 0x20, operation: sla(.b), cycles: 8),
    Instruction(opcode: 0x21, operation: sla(.c), cycles: 8),
    Instruction(opcode: 0x22, operation: sla(.d), cycles: 8),
    Instruction(opcode: 0x23, operation: sla(.e), cycles: 8),
    Instruction(opcode: 0x24, operation: sla(.h), cycles: 8),
    Instruction(opcode: 0x25, operation: sla(.l), cycles: 8),
    Instruction(opcode: 0x26, operation: sla(.hl), cycles: 16),
    Instruction(opcode: 0x27, operation: sla(.a), cycles: 8),
    Instruction(opcode: 0x28, operation: sra(.b), cycles: 8),
    Instruction(opcode: 0x29, operation: sra(.c), cycles: 8),
    Instruction(opcode: 0x2A, operation: sra(.d), cycles: 8),
    Instruction(opcode: 0x2B, operation: sra(.e), cycles: 8),
    Instruction(opcode: 0x2C, operation: sra(.h), cycles: 8),
    Instruction(opcode: 0x2D, operation: sra(.l), cycles: 8),
    Instruction(opcode: 0x2E, operation: sra(.hl), cycles: 16),
    Instruction(opcode: 0x2F, operation: sra(.a), cycles: 8),
    
    // 0x3n
    Instruction(opcode: 0x30, operation: swap_r(.b), cycles: 8),
    Instruction(opcode: 0x31, operation: swap_r(.c), cycles: 8),
    Instruction(opcode: 0x32, operation: swap_r(.d), cycles: 8),
    Instruction(opcode: 0x33, operation: swap_r(.e), cycles: 8),
    Instruction(opcode: 0x34, operation: swap_r(.h), cycles: 8),
    Instruction(opcode: 0x35, operation: swap_r(.l), cycles: 8),
    Instruction(opcode: 0x36, operation: swap_r(.hl), cycles: 16),
    Instruction(opcode: 0x37, operation: swap_r(.a), cycles: 8),
    Instruction(opcode: 0x38, operation: srl(.b), cycles: 8),
    Instruction(opcode: 0x39, operation: srl(.c), cycles: 8),
    Instruction(opcode: 0x3A, operation: srl(.d), cycles: 8),
    Instruction(opcode: 0x3B, operation: srl(.e), cycles: 8),
    Instruction(opcode: 0x3C, operation: srl(.h), cycles: 8),
    Instruction(opcode: 0x3D, operation: srl(.l), cycles: 8),
    Instruction(opcode: 0x3E, operation: srl(.hl), cycles: 16),
    Instruction(opcode: 0x3F, operation: srl(.a), cycles: 8),
    
    // 0x4n
    Instruction(opcode: 0x40, operation: bit(0, .b), cycles: 8),
    Instruction(opcode: 0x41, operation: bit(0, .c), cycles: 8),
    Instruction(opcode: 0x42, operation: bit(0, .d), cycles: 8),
    Instruction(opcode: 0x43, operation: bit(0, .e), cycles: 8),
    Instruction(opcode: 0x44, operation: bit(0, .h), cycles: 8),
    Instruction(opcode: 0x45, operation: bit(0, .l), cycles: 8),
    Instruction(opcode: 0x46, operation: bit(0, .hl), cycles: 16),
    Instruction(opcode: 0x47, operation: bit(0, .a), cycles: 8),
    Instruction(opcode: 0x48, operation: bit(1, .b), cycles: 8),
    Instruction(opcode: 0x49, operation: bit(1, .c), cycles: 8),
    Instruction(opcode: 0x4A, operation: bit(1, .d), cycles: 8),
    Instruction(opcode: 0x4B, operation: bit(1, .e), cycles: 8),
    Instruction(opcode: 0x4C, operation: bit(1, .h), cycles: 8),
    Instruction(opcode: 0x4D, operation: bit(1, .l), cycles: 8),
    Instruction(opcode: 0x4E, operation: bit(1, .hl), cycles: 16),
    Instruction(opcode: 0x4F, operation: bit(1, .a), cycles: 8),
    
    // 0x5n
    Instruction(opcode: 0x50, operation: bit(2, .b), cycles: 8),
    Instruction(opcode: 0x51, operation: bit(2, .c), cycles: 8),
    Instruction(opcode: 0x52, operation: bit(2, .d), cycles: 8),
    Instruction(opcode: 0x53, operation: bit(2, .e), cycles: 8),
    Instruction(opcode: 0x54, operation: bit(2, .h), cycles: 8),
    Instruction(opcode: 0x55, operation: bit(2, .l), cycles: 8),
    Instruction(opcode: 0x56, operation: bit(2, .hl), cycles: 16),
    Instruction(opcode: 0x57, operation: bit(2, .a), cycles: 8),
    Instruction(opcode: 0x58, operation: bit(3, .b), cycles: 8),
    Instruction(opcode: 0x59, operation: bit(3, .c), cycles: 8),
    Instruction(opcode: 0x5A, operation: bit(3, .d), cycles: 8),
    Instruction(opcode: 0x5B, operation: bit(3, .e), cycles: 8),
    Instruction(opcode: 0x5C, operation: bit(3, .h), cycles: 8),
    Instruction(opcode: 0x5D, operation: bit(3, .l), cycles: 8),
    Instruction(opcode: 0x5E, operation: bit(3, .hl), cycles: 16),
    Instruction(opcode: 0x5F, operation: bit(3, .a), cycles: 8),
    
    // 0x6n
    Instruction(opcode: 0x60, operation: bit(4, .b), cycles: 8),
    Instruction(opcode: 0x61, operation: bit(4, .c), cycles: 8),
    Instruction(opcode: 0x62, operation: bit(4, .d), cycles: 8),
    Instruction(opcode: 0x63, operation: bit(4, .e), cycles: 8),
    Instruction(opcode: 0x64, operation: bit(4, .h), cycles: 8),
    Instruction(opcode: 0x65, operation: bit(4, .l), cycles: 8),
    Instruction(opcode: 0x66, operation: bit(4, .hl), cycles: 16),
    Instruction(opcode: 0x67, operation: bit(4, .a), cycles: 8),
    Instruction(opcode: 0x68, operation: bit(5, .b), cycles: 8),
    Instruction(opcode: 0x69, operation: bit(5, .c), cycles: 8),
    Instruction(opcode: 0x6A, operation: bit(5, .d), cycles: 8),
    Instruction(opcode: 0x6B, operation: bit(5, .e), cycles: 8),
    Instruction(opcode: 0x6C, operation: bit(5, .h), cycles: 8),
    Instruction(opcode: 0x6D, operation: bit(5, .l), cycles: 8),
    Instruction(opcode: 0x6E, operation: bit(5, .hl), cycles: 16),
    Instruction(opcode: 0x6F, operation: bit(5, .a), cycles: 8),
    
    // 0x7n
    Instruction(opcode: 0x70, operation: bit(6, .b), cycles: 8),
    Instruction(opcode: 0x71, operation: bit(6, .c), cycles: 8),
    Instruction(opcode: 0x72, operation: bit(6, .d), cycles: 8),
    Instruction(opcode: 0x73, operation: bit(6, .e), cycles: 8),
    Instruction(opcode: 0x74, operation: bit(6, .h), cycles: 8),
    Instruction(opcode: 0x75, operation: bit(6, .l), cycles: 8),
    Instruction(opcode: 0x76, operation: bit(6, .hl), cycles: 16),
    Instruction(opcode: 0x77, operation: bit(6, .a), cycles: 8),
    Instruction(opcode: 0x78, operation: bit(7, .b), cycles: 8),
    Instruction(opcode: 0x79, operation: bit(7, .c), cycles: 8),
    Instruction(opcode: 0x7A, operation: bit(7, .d), cycles: 8),
    Instruction(opcode: 0x7B, operation: bit(7, .e), cycles: 8),
    Instruction(opcode: 0x7C, operation: bit(7, .h), cycles: 8),
    Instruction(opcode: 0x7D, operation: bit(7, .l), cycles: 8),
    Instruction(opcode: 0x7E, operation: bit(7, .hl), cycles: 16),
    Instruction(opcode: 0x7F, operation: bit(7, .a), cycles: 8),
    
    // 0x8n
    Instruction(opcode: 0x80, operation: res(0, .b), cycles: 8),
    Instruction(opcode: 0x81, operation: res(0, .c), cycles: 8),
    Instruction(opcode: 0x82, operation: res(0, .d), cycles: 8),
    Instruction(opcode: 0x83, operation: res(0, .e), cycles: 8),
    Instruction(opcode: 0x84, operation: res(0, .h), cycles: 8),
    Instruction(opcode: 0x85, operation: res(0, .l), cycles: 8),
    Instruction(opcode: 0x86, operation: res(0, .hl), cycles: 16),
    Instruction(opcode: 0x87, operation: res(0, .a), cycles: 8),
    Instruction(opcode: 0x88, operation: res(1, .b), cycles: 8),
    Instruction(opcode: 0x89, operation: res(1, .c), cycles: 8),
    Instruction(opcode: 0x8A, operation: res(1, .d), cycles: 8),
    Instruction(opcode: 0x8B, operation: res(1, .e), cycles: 8),
    Instruction(opcode: 0x8C, operation: res(1, .h), cycles: 8),
    Instruction(opcode: 0x8D, operation: res(1, .l), cycles: 8),
    Instruction(opcode: 0x8E, operation: res(1, .hl), cycles: 16),
    Instruction(opcode: 0x8F, operation: res(1, .a), cycles: 8),
    
    // 0x9n
    Instruction(opcode: 0x90, operation: res(2, .b), cycles: 8),
    Instruction(opcode: 0x91, operation: res(2, .c), cycles: 8),
    Instruction(opcode: 0x92, operation: res(2, .d), cycles: 8),
    Instruction(opcode: 0x93, operation: res(2, .e), cycles: 8),
    Instruction(opcode: 0x94, operation: res(2, .h), cycles: 8),
    Instruction(opcode: 0x95, operation: res(2, .l), cycles: 8),
    Instruction(opcode: 0x96, operation: res(2, .hl), cycles: 16),
    Instruction(opcode: 0x97, operation: res(2, .a), cycles: 8),
    Instruction(opcode: 0x98, operation: res(3, .b), cycles: 8),
    Instruction(opcode: 0x99, operation: res(3, .c), cycles: 8),
    Instruction(opcode: 0x9A, operation: res(3, .d), cycles: 8),
    Instruction(opcode: 0x9B, operation: res(3, .e), cycles: 8),
    Instruction(opcode: 0x9C, operation: res(3, .h), cycles: 8),
    Instruction(opcode: 0x9D, operation: res(3, .l), cycles: 8),
    Instruction(opcode: 0x9E, operation: res(3, .hl), cycles: 16),
    Instruction(opcode: 0x9F, operation: res(3, .a), cycles: 8),
    
    // 0xAn
    Instruction(opcode: 0xA0, operation: res(4, .b), cycles: 8),
    Instruction(opcode: 0xA1, operation: res(4, .c), cycles: 8),
    Instruction(opcode: 0xA2, operation: res(4, .d), cycles: 8),
    Instruction(opcode: 0xA3, operation: res(4, .e), cycles: 8),
    Instruction(opcode: 0xA4, operation: res(4, .h), cycles: 8),
    Instruction(opcode: 0xA5, operation: res(4, .l), cycles: 8),
    Instruction(opcode: 0xA6, operation: res(4, .hl), cycles: 16),
    Instruction(opcode: 0xA7, operation: res(4, .a), cycles: 8),
    Instruction(opcode: 0xA8, operation: res(5, .b), cycles: 8),
    Instruction(opcode: 0xA9, operation: res(5, .c), cycles: 8),
    Instruction(opcode: 0xAA, operation: res(5, .d), cycles: 8),
    Instruction(opcode: 0xAB, operation: res(5, .e), cycles: 8),
    Instruction(opcode: 0xAC, operation: res(5, .h), cycles: 8),
    Instruction(opcode: 0xAD, operation: res(5, .l), cycles: 8),
    Instruction(opcode: 0xAE, operation: res(5, .hl), cycles: 16),
    Instruction(opcode: 0xAF, operation: res(5, .a), cycles: 8),
    
    // 0xBn
    Instruction(opcode: 0xB0, operation: res(6, .b), cycles: 8),
    Instruction(opcode: 0xB1, operation: res(6, .c), cycles: 8),
    Instruction(opcode: 0xB2, operation: res(6, .d), cycles: 8),
    Instruction(opcode: 0xB3, operation: res(6, .e), cycles: 8),
    Instruction(opcode: 0xB4, operation: res(6, .h), cycles: 8),
    Instruction(opcode: 0xB5, operation: res(6, .l), cycles: 8),
    Instruction(opcode: 0xB6, operation: res(6, .hl), cycles: 16),
    Instruction(opcode: 0xB7, operation: res(6, .a), cycles: 8),
    Instruction(opcode: 0xB8, operation: res(7, .b), cycles: 8),
    Instruction(opcode: 0xB9, operation: res(7, .c), cycles: 8),
    Instruction(opcode: 0xBA, operation: res(7, .d), cycles: 8),
    Instruction(opcode: 0xBB, operation: res(7, .e), cycles: 8),
    Instruction(opcode: 0xBC, operation: res(7, .h), cycles: 8),
    Instruction(opcode: 0xBD, operation: res(7, .l), cycles: 8),
    Instruction(opcode: 0xBE, operation: res(7, .hl), cycles: 16),
    Instruction(opcode: 0xBF, operation: res(7, .a), cycles: 8),
    
    // 0xCn
    Instruction(opcode: 0xC0, operation: set(0, .b), cycles: 8),
    Instruction(opcode: 0xC1, operation: set(0, .c), cycles: 8),
    Instruction(opcode: 0xC2, operation: set(0, .d), cycles: 8),
    Instruction(opcode: 0xC3, operation: set(0, .e), cycles: 8),
    Instruction(opcode: 0xC4, operation: set(0, .h), cycles: 8),
    Instruction(opcode: 0xC5, operation: set(0, .l), cycles: 8),
    Instruction(opcode: 0xC6, operation: set(0, .hl), cycles: 16),
    Instruction(opcode: 0xC7, operation: set(0, .a), cycles: 8),
    Instruction(opcode: 0xC8, operation: set(1, .b), cycles: 8),
    Instruction(opcode: 0xC9, operation: set(1, .c), cycles: 8),
    Instruction(opcode: 0xCA, operation: set(1, .d), cycles: 8),
    Instruction(opcode: 0xCB, operation: set(1, .e), cycles: 8),
    Instruction(opcode: 0xCC, operation: set(1, .h), cycles: 8),
    Instruction(opcode: 0xCD, operation: set(1, .l), cycles: 8),
    Instruction(opcode: 0xCE, operation: set(1, .hl), cycles: 16),
    Instruction(opcode: 0xCF, operation: set(1, .a), cycles: 8),
    
    // 0xDn
    Instruction(opcode: 0xD0, operation: set(2, .b), cycles: 8),
    Instruction(opcode: 0xD1, operation: set(2, .c), cycles: 8),
    Instruction(opcode: 0xD2, operation: set(2, .d), cycles: 8),
    Instruction(opcode: 0xD3, operation: set(2, .e), cycles: 8),
    Instruction(opcode: 0xD4, operation: set(2, .h), cycles: 8),
    Instruction(opcode: 0xD5, operation: set(2, .l), cycles: 8),
    Instruction(opcode: 0xD6, operation: set(2, .hl), cycles: 16),
    Instruction(opcode: 0xD7, operation: set(2, .a), cycles: 8),
    Instruction(opcode: 0xD8, operation: set(3, .b), cycles: 8),
    Instruction(opcode: 0xD9, operation: set(3, .c), cycles: 8),
    Instruction(opcode: 0xDA, operation: set(3, .d), cycles: 8),
    Instruction(opcode: 0xDB, operation: set(3, .e), cycles: 8),
    Instruction(opcode: 0xDC, operation: set(3, .h), cycles: 8),
    Instruction(opcode: 0xDD, operation: set(3, .l), cycles: 8),
    Instruction(opcode: 0xDE, operation: set(3, .hl), cycles: 16),
    Instruction(opcode: 0xDF, operation: set(3, .a), cycles: 8),
    
    // 0xEn
    Instruction(opcode: 0xE0, operation: set(4, .b), cycles: 8),
    Instruction(opcode: 0xE1, operation: set(4, .c), cycles: 8),
    Instruction(opcode: 0xE2, operation: set(4, .d), cycles: 8),
    Instruction(opcode: 0xE3, operation: set(4, .e), cycles: 8),
    Instruction(opcode: 0xE4, operation: set(4, .h), cycles: 8),
    Instruction(opcode: 0xE5, operation: set(4, .l), cycles: 8),
    Instruction(opcode: 0xE6, operation: set(4, .hl), cycles: 16),
    Instruction(opcode: 0xE7, operation: set(4, .a), cycles: 8),
    Instruction(opcode: 0xE8, operation: set(5, .b), cycles: 8),
    Instruction(opcode: 0xE9, operation: set(5, .c), cycles: 8),
    Instruction(opcode: 0xEA, operation: set(5, .d), cycles: 8),
    Instruction(opcode: 0xEB, operation: set(5, .e), cycles: 8),
    Instruction(opcode: 0xEC, operation: set(5, .h), cycles: 8),
    Instruction(opcode: 0xED, operation: set(5, .l), cycles: 8),
    Instruction(opcode: 0xEE, operation: set(5, .hl), cycles: 16),
    Instruction(opcode: 0xEF, operation: set(5, .a), cycles: 8),
    
    // 0xFn
    Instruction(opcode: 0xF0, operation: set(6, .b), cycles: 8),
    Instruction(opcode: 0xF1, operation: set(6, .c), cycles: 8),
    Instruction(opcode: 0xF2, operation: set(6, .d), cycles: 8),
    Instruction(opcode: 0xF3, operation: set(6, .e), cycles: 8),
    Instruction(opcode: 0xF4, operation: set(6, .h), cycles: 8),
    Instruction(opcode: 0xF5, operation: set(6, .l), cycles: 8),
    Instruction(opcode: 0xF6, operation: set(6, .hl), cycles: 16),
    Instruction(opcode: 0xF7, operation: set(6, .a), cycles: 8),
    Instruction(opcode: 0xF8, operation: set(7, .b), cycles: 8),
    Instruction(opcode: 0xF9, operation: set(7, .c), cycles: 8),
    Instruction(opcode: 0xFA, operation: set(7, .d), cycles: 8),
    Instruction(opcode: 0xFB, operation: set(7, .e), cycles: 8),
    Instruction(opcode: 0xFC, operation: set(7, .h), cycles: 8),
    Instruction(opcode: 0xFD, operation: set(7, .l), cycles: 8),
    Instruction(opcode: 0xFE, operation: set(7, .hl), cycles: 16),
    Instruction(opcode: 0xFF, operation: set(7, .a), cycles: 8),
  ]
  
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
