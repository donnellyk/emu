import Foundation

typealias Operation = (CPU) -> Void
typealias CycleCalculation = (CPU) -> Int


struct Instruction {
  var opcode: Int
  var cycles: CycleCalculation
  var operation: Operation
  
  init(opcode: Int, operation: @escaping Operation, cycles: Int = 4) {
    self.init(opcode: opcode, operation: operation, cycles: { _ in return cycles })
  }
  
  init(opcode: Int, operation: @escaping Operation, cycles: @escaping CycleCalculation) {
    self.opcode = opcode
    self.cycles = cycles
    self.operation = operation
  }
}

struct I {
  static let table: [Instruction] = [
    // 0x0n
    Instruction(opcode: 0x00, operation: { _ in }),
    Instruction(opcode: 0x01, operation: ldd_r_nn(.bc), cycles: 12),
    Instruction(opcode: 0x02, operation: ld_r_r(.bc, .a), cycles: 8),
    Instruction(opcode: 0x03, operation: inc(.bc), cycles: 8),
    Instruction(opcode: 0x04, operation: inc(.b)),
    Instruction(opcode: 0x05, operation: dec(.b)),
    Instruction(opcode: 0x06, operation: ld_r_nn(.b), cycles: 8),
    Instruction(opcode: 0x07, operation: rlc(.a)),
    Instruction(opcode: 0x08, operation: ldd_nn_sp(), cycles: 20),
    Instruction(opcode: 0x09, operation: add_hl(.bc), cycles: 8),
    Instruction(opcode: 0x0A, operation: ld_r_r(.a, .bc), cycles: 8),
    Instruction(opcode: 0x0B, operation: dec(.bc), cycles: 8),
    Instruction(opcode: 0x0C, operation: inc(.c)),
    Instruction(opcode: 0x0D, operation: dec(.c)),
    Instruction(opcode: 0x0E, operation: ld_r_nn(.c), cycles: 8),
    Instruction(opcode: 0x0F, operation: rrc(.a)),
    
    // 0x1n
    Instruction(opcode: 0x10, operation: { _ in /* TODO: STOP */ }),
    Instruction(opcode: 0x11, operation: ldd_r_nn(.de), cycles: 12),
    Instruction(opcode: 0x12, operation: ld_r_r(.de, .a), cycles: 8),
    Instruction(opcode: 0x13, operation: inc(.de), cycles: 8),
    Instruction(opcode: 0x14, operation: inc(.d)),
    Instruction(opcode: 0x15, operation: dec(.d)),
    Instruction(opcode: 0x16, operation: ld_r_nn(.d), cycles: 8),
    Instruction(opcode: 0x17, operation: rl(.a)),
    Instruction(opcode: 0x18, operation: jr(), cycles: 12),
    Instruction(opcode: 0x19, operation: add_hl(.de), cycles: 8),
    Instruction(opcode: 0x1A, operation: ld_r_r(.a, .de), cycles: 8),
    Instruction(opcode: 0x1B, operation: dec(.de), cycles: 8),
    Instruction(opcode: 0x1C, operation: inc(.e)),
    Instruction(opcode: 0x1D, operation: dec(.e)),
    Instruction(opcode: 0x1E, operation: ld_r_nn(.e), cycles: 8),
    Instruction(opcode: 0x1F, operation: rr(.a)),
    
    // 0x2n
    Instruction(opcode: 0x20, operation: jr(C.notZ), cycles: { C.notZ($0) ? 12 : 8 }),
    Instruction(opcode: 0x21, operation: ldd_r_nn(.hl), cycles: 12),
    Instruction(opcode: 0x22, operation: ld_hl_a_inc(), cycles: 8),
    Instruction(opcode: 0x23, operation: inc(.hl), cycles: 8),
    Instruction(opcode: 0x24, operation: inc(.h)),
    Instruction(opcode: 0x25, operation: dec(.h)),
    Instruction(opcode: 0x26, operation: ld_r_nn(.h), cycles: 8),
    Instruction(opcode: 0x27, operation: daa()),
    Instruction(opcode: 0x28, operation: jr(C.zSet), cycles: { C.zSet($0) ? 12 : 8 }),
    Instruction(opcode: 0x29, operation: add_hl(.hl), cycles: 8),
    Instruction(opcode: 0x2A, operation: ld_a_hl_inc(), cycles: 8),
    Instruction(opcode: 0x2B, operation: dec(.hl), cycles: 8),
    Instruction(opcode: 0x2C, operation: inc(.l)),
    Instruction(opcode: 0x2D, operation: dec(.l)),
    Instruction(opcode: 0x2E, operation: ld_r_nn(.e), cycles: 8),
    Instruction(opcode: 0x2F, operation: cpl()),
    
    // 0x3n
    Instruction(opcode: 0x30, operation: jr(C.notC), cycles: { C.notC($0) ? 12 : 8 }),
    Instruction(opcode: 0x31, operation: ldd_r_nn(.sp), cycles: 12),
    Instruction(opcode: 0x32, operation: ld_hl_a_dec(), cycles: 8),
    Instruction(opcode: 0x33, operation: inc(.sp), cycles: 8),
    Instruction(opcode: 0x34, operation: inc(.hl, true), cycles: 12),
    Instruction(opcode: 0x35, operation: dec(.hl, true), cycles: 12),
    Instruction(opcode: 0x36, operation: ld_r_nn(.hl), cycles: 12),
    Instruction(opcode: 0x37, operation: scf(), cycles: 4),
    Instruction(opcode: 0x38, operation: jr(C.cSet), cycles: { C.zSet($0) ? 12 : 8 }),
    Instruction(opcode: 0x39, operation: add_hl(.sp), cycles: 8),
    Instruction(opcode: 0x3A, operation: ld_a_hl_dec(), cycles: 8),
    Instruction(opcode: 0x3B, operation: dec(.sp), cycles: 8),
    Instruction(opcode: 0x3C, operation: inc(.a)),
    Instruction(opcode: 0x3D, operation: dec(.a)),
    Instruction(opcode: 0x3E, operation: ld_r_nn(.a), cycles: 8),
    Instruction(opcode: 0x3F, operation: ccf(), cycles: 4),
    
    // 0x4n
    Instruction(opcode: 0x40, operation: ld_r_r(.b, .b)),
    Instruction(opcode: 0x41, operation: ld_r_r(.b, .c)),
    Instruction(opcode: 0x42, operation: ld_r_r(.b, .d)),
    Instruction(opcode: 0x43, operation: ld_r_r(.b, .e)),
    Instruction(opcode: 0x44, operation: ld_r_r(.b, .h)),
    Instruction(opcode: 0x45, operation: ld_r_r(.b, .l)),
    Instruction(opcode: 0x46, operation: ld_r_r(.b, .hl), cycles: 8),
    Instruction(opcode: 0x47, operation: ld_r_r(.b, .a)),
    Instruction(opcode: 0x48, operation: ld_r_r(.c, .b)),
    Instruction(opcode: 0x49, operation: ld_r_r(.c, .c)),
    Instruction(opcode: 0x4A, operation: ld_r_r(.c, .d)),
    Instruction(opcode: 0x4B, operation: ld_r_r(.c, .e)),
    Instruction(opcode: 0x4C, operation: ld_r_r(.c, .h)),
    Instruction(opcode: 0x4D, operation: ld_r_r(.c, .l)),
    Instruction(opcode: 0x4E, operation: ld_r_r(.c, .hl), cycles: 8),
    Instruction(opcode: 0x4F, operation: ld_r_r(.c, .a)),
    
    // 0x5n
    Instruction(opcode: 0x50, operation: ld_r_r(.d, .b)),
    Instruction(opcode: 0x51, operation: ld_r_r(.d, .c)),
    Instruction(opcode: 0x52, operation: ld_r_r(.d, .d)),
    Instruction(opcode: 0x53, operation: ld_r_r(.d, .e)),
    Instruction(opcode: 0x54, operation: ld_r_r(.d, .h)),
    Instruction(opcode: 0x55, operation: ld_r_r(.d, .l)),
    Instruction(opcode: 0x56, operation: ld_r_r(.d, .hl), cycles: 8),
    Instruction(opcode: 0x57, operation: ld_r_r(.d, .a)),
    Instruction(opcode: 0x58, operation: ld_r_r(.e, .b)),
    Instruction(opcode: 0x59, operation: ld_r_r(.e, .c)),
    Instruction(opcode: 0x5A, operation: ld_r_r(.e, .d)),
    Instruction(opcode: 0x5B, operation: ld_r_r(.e, .e)),
    Instruction(opcode: 0x5C, operation: ld_r_r(.e, .h)),
    Instruction(opcode: 0x5D, operation: ld_r_r(.e, .l)),
    Instruction(opcode: 0x5E, operation: ld_r_r(.e, .hl), cycles: 8),
    Instruction(opcode: 0x5F, operation: ld_r_r(.e, .a)),
    
    // 0x6n
    Instruction(opcode: 0x60, operation: ld_r_r(.h, .b)),
    Instruction(opcode: 0x61, operation: ld_r_r(.h, .c)),
    Instruction(opcode: 0x62, operation: ld_r_r(.h, .d)),
    Instruction(opcode: 0x63, operation: ld_r_r(.h, .e)),
    Instruction(opcode: 0x64, operation: ld_r_r(.h, .h)),
    Instruction(opcode: 0x65, operation: ld_r_r(.h, .l)),
    Instruction(opcode: 0x66, operation: ld_r_r(.h, .hl), cycles: 8),
    Instruction(opcode: 0x67, operation: ld_r_r(.h, .a)),
    Instruction(opcode: 0x68, operation: ld_r_r(.l, .b)),
    Instruction(opcode: 0x69, operation: ld_r_r(.l, .c)),
    Instruction(opcode: 0x6A, operation: ld_r_r(.l, .d)),
    Instruction(opcode: 0x6B, operation: ld_r_r(.l, .e)),
    Instruction(opcode: 0x6C, operation: ld_r_r(.l, .h)),
    Instruction(opcode: 0x6D, operation: ld_r_r(.l, .l)),
    Instruction(opcode: 0x6E, operation: ld_r_r(.l, .hl), cycles: 8),
    Instruction(opcode: 0x6F, operation: ld_r_r(.l, .a)),
    
    // 0x7n
    Instruction(opcode: 0x70, operation: ld_r_r(.hl, .b)),
    Instruction(opcode: 0x71, operation: ld_r_r(.hl, .c)),
    Instruction(opcode: 0x72, operation: ld_r_r(.hl, .d)),
    Instruction(opcode: 0x73, operation: ld_r_r(.hl, .e)),
    Instruction(opcode: 0x74, operation: ld_r_r(.hl, .h)),
    Instruction(opcode: 0x75, operation: ld_r_r(.hl, .l)),
    Instruction(opcode: 0x76, operation: { _ in /* TODO: HALT */ }),
    Instruction(opcode: 0x77, operation: ld_r_r(.hl, .a)),
    Instruction(opcode: 0x78, operation: ld_r_r(.a, .b)),
    Instruction(opcode: 0x79, operation: ld_r_r(.a, .c)),
    Instruction(opcode: 0x7A, operation: ld_r_r(.a, .d)),
    Instruction(opcode: 0x7B, operation: ld_r_r(.a, .e)),
    Instruction(opcode: 0x7C, operation: ld_r_r(.a, .h)),
    Instruction(opcode: 0x7D, operation: ld_r_r(.a, .l)),
    Instruction(opcode: 0x7E, operation: ld_r_r(.a, .hl), cycles: 8),
    Instruction(opcode: 0x7F, operation: ld_r_r(.a, .a)),
    
    // 0x8n
    Instruction(opcode: 0x80, operation: add_a(.b)),
    Instruction(opcode: 0x81, operation: add_a(.c)),
    Instruction(opcode: 0x82, operation: add_a(.d)),
    Instruction(opcode: 0x83, operation: add_a(.e)),
    Instruction(opcode: 0x84, operation: add_a(.h)),
    Instruction(opcode: 0x85, operation: add_a(.l)),
    Instruction(opcode: 0x86, operation: add_a(.hl), cycles: 8),
    Instruction(opcode: 0x87, operation: add_a(.a)),
    Instruction(opcode: 0x88, operation: adc_a(.b)),
    Instruction(opcode: 0x89, operation: adc_a(.c)),
    Instruction(opcode: 0x8A, operation: adc_a(.d)),
    Instruction(opcode: 0x8B, operation: adc_a(.e)),
    Instruction(opcode: 0x8C, operation: adc_a(.h)),
    Instruction(opcode: 0x8D, operation: adc_a(.l)),
    Instruction(opcode: 0x8E, operation: adc_a(.hl), cycles: 8),
    Instruction(opcode: 0x8F, operation: adc_a(.a)),
    
    // 0x9n
    Instruction(opcode: 0x90, operation: sub_a(.b)),
    Instruction(opcode: 0x91, operation: sub_a(.c)),
    Instruction(opcode: 0x92, operation: sub_a(.d)),
    Instruction(opcode: 0x93, operation: sub_a(.e)),
    Instruction(opcode: 0x94, operation: sub_a(.h)),
    Instruction(opcode: 0x95, operation: sub_a(.l)),
    Instruction(opcode: 0x96, operation: sub_a(.hl), cycles: 8),
    Instruction(opcode: 0x97, operation: sub_a(.a)),
    Instruction(opcode: 0x98, operation: sbc_a(.b)),
    Instruction(opcode: 0x99, operation: sbc_a(.c)),
    Instruction(opcode: 0x9A, operation: sbc_a(.d)),
    Instruction(opcode: 0x9B, operation: sbc_a(.e)),
    Instruction(opcode: 0x9C, operation: sbc_a(.h)),
    Instruction(opcode: 0x9D, operation: sbc_a(.l)),
    Instruction(opcode: 0x9E, operation: sbc_a(.hl), cycles: 8),
    Instruction(opcode: 0x9F, operation: sbc_a(.a)),
    
    // 0xAn
    Instruction(opcode: 0xA0, operation: and_a(.b)),
    Instruction(opcode: 0xA1, operation: and_a(.c)),
    Instruction(opcode: 0xA2, operation: and_a(.d)),
    Instruction(opcode: 0xA3, operation: and_a(.e)),
    Instruction(opcode: 0xA4, operation: and_a(.h)),
    Instruction(opcode: 0xA5, operation: and_a(.l)),
    Instruction(opcode: 0xA6, operation: and_a(.hl), cycles: 8),
    Instruction(opcode: 0xA7, operation: and_a(.a)),
    Instruction(opcode: 0xA8, operation: xor_a(.b)),
    Instruction(opcode: 0xA9, operation: xor_a(.c)),
    Instruction(opcode: 0xAA, operation: xor_a(.d)),
    Instruction(opcode: 0xAB, operation: xor_a(.e)),
    Instruction(opcode: 0xAC, operation: xor_a(.h)),
    Instruction(opcode: 0xAD, operation: xor_a(.l)),
    Instruction(opcode: 0xAE, operation: xor_a(.hl), cycles: 8),
    Instruction(opcode: 0xAF, operation: xor_a(.a)),
    
    // 0xBn
    Instruction(opcode: 0xB0, operation: or_a(.b)),
    Instruction(opcode: 0xB1, operation: or_a(.c)),
    Instruction(opcode: 0xB2, operation: or_a(.d)),
    Instruction(opcode: 0xB3, operation: or_a(.e)),
    Instruction(opcode: 0xB4, operation: or_a(.h)),
    Instruction(opcode: 0xB5, operation: or_a(.l)),
    Instruction(opcode: 0xB6, operation: or_a(.hl), cycles: 8),
    Instruction(opcode: 0xB7, operation: or_a(.a)),
    Instruction(opcode: 0xB8, operation: cp_a(.b)),
    Instruction(opcode: 0xB9, operation: cp_a(.c)),
    Instruction(opcode: 0xBA, operation: cp_a(.d)),
    Instruction(opcode: 0xBB, operation: cp_a(.e)),
    Instruction(opcode: 0xBC, operation: cp_a(.h)),
    Instruction(opcode: 0xBD, operation: cp_a(.l)),
    Instruction(opcode: 0xBE, operation: cp_a(.hl), cycles: 8),
    Instruction(opcode: 0xBF, operation: cp_a(.a)),
    
    // 0xCn
    Instruction(opcode: 0xC0, operation: ret(C.notZ), cycles: { C.notZ($0) ? 20 : 8 }),
    Instruction(opcode: 0xC1, operation: pop(.bc), cycles: 12),
    Instruction(opcode: 0xC2, operation: jump(C.notZ), cycles: { C.notZ($0) ? 16 : 12 }),
    Instruction(opcode: 0xC3, operation: jump_nn(), cycles: 16),
    Instruction(opcode: 0xC4, operation: call(C.notZ), cycles: { C.notZ($0) ? 24 : 12 }),
    Instruction(opcode: 0xC5, operation: push(.bc), cycles: 16),
    Instruction(opcode: 0xC6, operation: add_a(), cycles: 8),
    Instruction(opcode: 0xC7, operation: restart(0), cycles: 16),
    Instruction(opcode: 0xC8, operation: ret(C.zSet), cycles: { C.zSet($0) ? 20 : 8 }),
    Instruction(opcode: 0xC9, operation: ret(), cycles: 16),
    Instruction(opcode: 0xCA, operation: jump(C.zSet), cycles: { C.zSet($0) ? 16 : 12 }),
    Instruction(opcode: 0xCB, operation: prefix(), cycles: 4),
    Instruction(opcode: 0xCC, operation: call(C.zSet), cycles: { C.zSet($0) ? 24 : 12 }),
    Instruction(opcode: 0xCD, operation: call_nn(), cycles: 24),
    Instruction(opcode: 0xCE, operation: adc_a_n(), cycles: 8),
    Instruction(opcode: 0xCF, operation: restart(8), cycles: 16),
    
    // 0xDn
    Instruction(opcode: 0xD0, operation: ret(C.notC), cycles: { C.notC($0) ? 20 : 8 }),
    Instruction(opcode: 0xD1, operation: pop(.de), cycles: 12),
    Instruction(opcode: 0xD2, operation: jump(C.notC), cycles: { C.notC($0) ? 16 : 12 }),
    Instruction(opcode: 0xD3, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xD4, operation: call(C.notC), cycles: { C.notC($0) ? 24 : 12 }),
    Instruction(opcode: 0xD5, operation: push(.de), cycles: 16),
    Instruction(opcode: 0xD6, operation: sub_a(), cycles: 8),
    Instruction(opcode: 0xD7, operation: restart(10), cycles: 16),
    Instruction(opcode: 0xD8, operation: ret(C.cSet), cycles: { C.cSet($0) ? 20 : 8 }),
    Instruction(opcode: 0xD9, operation: reti(), cycles: 16),
    Instruction(opcode: 0xDA, operation: jump(C.cSet), cycles: { C.cSet($0) ? 16 : 12 }),
    Instruction(opcode: 0xDB, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xDC, operation: call(C.cSet), cycles: { C.cSet($0) ? 24 : 12 }),
    Instruction(opcode: 0xDD, operation: { _ in assertionFailure() }, cycles: 0),
    Instruction(opcode: 0xDE, operation: sbc_a(), cycles: 8),
    Instruction(opcode: 0xDF, operation: restart(18), cycles: 16),
    
    // 0xEn
    Instruction(opcode: 0xE0, operation: ldh_n_a(), cycles: 12),
    Instruction(opcode: 0xE1, operation: pop(.hl), cycles: 12),
    Instruction(opcode: 0xE2, operation: ld_c_a(), cycles: 8),
    Instruction(opcode: 0xE3, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xE4, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xE5, operation: push(.hl), cycles: 16),
    Instruction(opcode: 0xE6, operation: and_a(), cycles: 8),
    Instruction(opcode: 0xE7, operation: restart(20), cycles: 16),
    Instruction(opcode: 0xE8, operation: add_sp(), cycles: 16),
    Instruction(opcode: 0xE9, operation: jp_hl(), cycles: 4),
    Instruction(opcode: 0xEA, operation: ldh_a_n(), cycles: 16),
    Instruction(opcode: 0xEB, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xEC, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xED, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xEE, operation: xor_a(), cycles: 8),
    Instruction(opcode: 0xEF, operation: restart(28), cycles: 16),
    
    // 0xFn
    Instruction(opcode: 0xF0, operation: ldh_a_n(), cycles: 12),
    Instruction(opcode: 0xF1, operation: pop(.af), cycles: 12),
    Instruction(opcode: 0xF2, operation: ld_a_c(), cycles: 8),
    Instruction(opcode: 0xF3, operation: { _ in /* TODO: DI */ }),
    Instruction(opcode: 0xF4, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xF5, operation: push(.af), cycles: 12),
    Instruction(opcode: 0xF6, operation: or_a(), cycles: 8),
    Instruction(opcode: 0xF7, operation: restart(30), cycles: 16),
    Instruction(opcode: 0xF8, operation: ldd_hl_sp_n(), cycles: 12),
    Instruction(opcode: 0xF9, operation: ldd_sp_hl(), cycles: 8),
    Instruction(opcode: 0xFA, operation: ldh_a_n(), cycles: 16),
    Instruction(opcode: 0xFB, operation: { _ in /* TODO: EI */ }),
    Instruction(opcode: 0xFC, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xFD, operation: { _ in assertionFailure() }),
    Instruction(opcode: 0xFE, operation: cp_a(), cycles: 8),
    Instruction(opcode: 0xFF, operation: restart(38), cycles: 16),
  ]
  
  // MARK: - 8-Bit LOAD
  
  /// Sets value addressed at next byte of PC to register
  ///
  /// - Parameter register: <#register description#>
  /// - Returns: Block to execute for load
  static func ld_r_nn(_ register: Register) -> Operation {
    return {
      register.set($0.nextByte(), in: $0)
    }
  }
  
  static func ld_nn_r(_ register: Register) -> Operation {
    return {
      let address = $0.nextWord()
      let value = register.get8($0)
      
      $0.mmu.write(value, at: address)
    }
  }
  
  
  /// Load r2 into r1
  ///
  /// - Parameters:
  ///   - r1: Register to be written to
  ///   - r2: Reigster to be read
  /// - Returns: Block to execute for load
  /// - Discussion: If r2 is 16 bit register, value will be loaded from memory. If r1 is a 16-bit register, value will be written to memory address
  static func ld_r_r(_ r1: Register, _ r2: Register) -> Operation {
    return {
      let value: UInt8
      if r2.is8Bit {
        value = r2.get(from: $0)
      } else {
        let address = r2.get16($0)
        value = $0.mmu.read(address)
      }
      
      if r1.is8Bit {
        r1.set(value, in: $0)
      } else {
        let address = r1.get16($0)
        $0.mmu.write(value, at: address)
      }
    }
  }
  
  static func ld_a_n(_ register: Register) -> Operation {
    return ld_r_r(.a, register)
  }
  
  static func ld_n_a(_ register: Register) -> Operation {
    return ld_r_r(register, .a)
  }
  
  static func ld_a_c() -> Operation {
    return {
      let address = 0xFF00 + Register.c.get16($0)
      let value: UInt8 = $0.mmu.read(address)
      
      Register.a.set(value, in: $0)
    }
  }
  
  static func ld_c_a() -> Operation {
    return {
      let address = 0xFF00 + Register.c.get16($0)
      let value: UInt8 = Register.a.get(from: $0)
      
      $0.mmu.write(value, at: address)
    }
  }
  
  static func ld_a_hl_dec() -> Operation {
    return {
      ld_r_r(.a, .hl)($0)
      dec(.hl)($0)
    }
  }
  
  static func ld_hl_a_dec() -> Operation {
    return {
      ld_r_r(.hl, .a)($0)
      dec(.hl)($0)
    }
  }
  
  static func ld_a_hl_inc() -> Operation {
    return {
      ld_r_r(.a, .hl)($0)
      inc(.hl)($0)
    }
  }
  
  static func ld_hl_a_inc() -> Operation {
    return {
      ld_r_r(.hl, .a)($0)
      inc(.hl)($0)
    }
  }
  
  static func ldh_n_a() -> Operation {
    return {
      let value = Register.a.get8($0)
      let address = 0xFF00 + UInt16($0.nextByte())
      
      $0.mmu.write(value, at: address)
    }
  }
  
  static func ldh_a_n() -> Operation {
    return {
      let address = 0xFF00 + UInt16($0.nextByte())
      let value: UInt8 = $0.mmu.read(address)
      Register.a.set(value, in: $0)
    }
  }
  
  // MARK: - 16-Bit LOAD
  
  static func ldd_r_nn(_ register: Register) -> Operation {
    return {
      register.set($0.nextWord(), in: $0)
    }
  }
  
  static func ldd_sp_hl() -> Operation {
    return {
      $0.registers.sp = $0.registers.hl
    }
  }
  
  static func ldd_hl_sp_n() -> Operation {
    return {
      let n = Int8(bitPattern: $0.nextByte())
      $0.registers.hl = UInt16(truncatingIfNeeded: Int($0.registers.sp) + Int(n))
      
      $0.registers.flags.z = false
      $0.registers.flags.n = false
      
      if n >= 0 {
        $0.registers.flags.c = (Int($0.registers.sp & 0xFF) + Int(n)) > 0xFF
        $0.registers.flags.h = (Int($0.registers.sp & 0xF) + Int(n)) > 0xF
      } else {
        $0.registers.flags.c = Int($0.registers.hl & 0xFF) <= Int($0.registers.sp & 0xFF)
        $0.registers.flags.h = Int($0.registers.hl & 0xF) <= Int($0.registers.sp & 0xF)
      }
    }
  }
  
  static func ldd_nn_sp() -> Operation {
    return {
      $0.registers.sp = $0.nextWord()
    }
  }
  
  // MARK: - SP PUSH/POP
  
  static func push(_ register: Register) -> Operation {
    return {
      $0.push(register.get16($0))
    }
  }
  
  static func pop(_ register: Register) -> Operation {
    return {
      register.set($0.pop(), in: $0)
    }
  }
  
  
  // MARK: - 8-BIT ALU
  
  /// Decrements register
  ///
  /// - Parameters:
  ///   - register: Register to decrement
  ///   - resolve: If true, 16-bit registers are treated as addresses and the value is read/written from memory
  /// - Returns: Operation executing the decrement
  static func dec(_ register: Register, _ resolve: Bool = false) -> Operation {
    return {
      let c = $0.registers.flags.c
      let cpu = $0
      defer {
        cpu.registers.flags.c = c
      }
      
      if register.is8Bit || resolve {
        let value = register.get8($0)
        subValue(in: register, a: value, b: 1)($0)
      } else {
        register.set(register.get16($0)-1, in: $0)
      }
    }
  }
  
  /// Increments register
  ///
  /// - Parameters:
  ///   - register: Register to increment
  ///   - resolve: If true, 16-bit registers are treated as addresses and the value is read/written from memory
  /// - Returns: Operate to execute the increment
  static func inc(_ register: Register, _ resolve: Bool = false) -> Operation {
    return {
      if register.is8Bit {
        let c = $0.registers.flags.c
        
        let value = register.get8($0)
        addValue(in: register, a: value, b: 1)($0)
        
        $0.registers.flags.c = c
      } else {
        let value = register.get16($0)
        register.set(value + 1, in: $0)
      }
    }
  }
  
  static func add_a(_ register: Register? = nil) -> Operation {
    return {
      let value = register?.get8($0) ?? $0.nextByte()
      
      addValue(in: .a, a: $0.registers.a, b: value)($0)
    }
  }
  
  static func adc_a(_ register: Register) -> Operation {
    return {
      let carry = $0.registers.flags.c.bit
      
      add_a(register)($0)
      addValue(in: .a, a: $0.registers.a, b: carry)($0)
    }
  }
  
  static func adc_a_n() -> Operation {
    return {
      let carry = $0.registers.flags.c.bit
      let value = $0.nextByte()
      
      addValue(in: .a, a: $0.registers.a, b: value)($0)
      addValue(in: .a, a: $0.registers.a, b: carry)($0)
    }
  }
  
  static func addValue(in register: Register, a: UInt8, b: UInt8) -> Operation {
    return {
      let val = a &+ b
      
      $0.registers.flags.z = (val == 0)
      $0.registers.flags.n = false
      $0.registers.flags.h = checkForHalfCarry(a, b)
      $0.registers.flags.c = checkForCarry(a, b)
      
      register.set(val, in: $0)
    }
  }
  
  static func subValue(in register: Register, a: UInt8, b: UInt8) -> Operation {
    return {
      let val = a &- b
      
      $0.registers.flags.z = (val == 0)
      $0.registers.flags.n = true
      $0.registers.flags.h = checkForHalfBorrow(a, b)
      $0.registers.flags.c = checkForBorrow(a, b)
      
      register.set(val, in: $0)
    }
  }
  
  static func sub_a(_ register: Register? = nil) -> Operation {
    return {
      let value = register?.get8($0) ?? $0.nextByte()
      
      subValue(in: .a, a: $0.registers.a, b: value)($0)
    }
  }
  
  static func sbc_a(_ register: Register? = nil) -> Operation {
    return {
      let carry = $0.registers.flags.c.bit
      let value = register?.get8($0) ?? $0.nextByte()
      
      subValue(in: .a, a: $0.registers.a, b: value)($0)
      subValue(in: .a, a: $0.registers.a, b: carry)($0)
    }
  }

// MARK: - LOGICAL OPERATIONS
  
  static func and_a(_ register: Register? = nil) -> Operation {
    return {
      and_a(register?.get8($0) ?? $0.nextByte())($0)
    }
  }
  
  static func and_a(_ value: UInt8) -> Operation {
    return performLogicalOperationOnA(&, value: value)

  }
  
  static func or_a(_ register: Register? = nil) -> Operation {
    return {
      or_a(register?.get8($0) ?? $0.nextByte())($0)
    }
  }
  
  static func or_a(_ value: UInt8) -> Operation {
    return performLogicalOperationOnA(|, value: value)
  }

  
  static func xor_a(_ register: Register? = nil) -> Operation {
    return {
      xor_a(register?.get8($0) ?? $0.nextByte())($0)
    }
  }
  
  static func xor_a(_ value: UInt8) -> Operation {
    return performLogicalOperationOnA(^, value: value)
  }

  /// Performs an operation, setting the a register and flags
  ///
  /// - Parameters:
  ///   - logicalOp: Operation to perform: AND, OR, XOR
  ///   - value: Value to operate one
  /// - Returns: <#return value description#>
  /// - Discussion: Flags are set assuming a logical AND, OR, XOR. Flags will not be properly set for arthmetic operation.
  static func performLogicalOperationOnA(_ logicalOp: @escaping (UInt8, UInt8) -> UInt8, value: UInt8) -> Operation {
    return {
      $0.registers.a = logicalOp($0.registers.a, value)
      
      $0.registers.flags.z = ($0.registers.a == 0)
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = false
    }
  }
  
// MARK: - COMPARE
  
  static func cp_a(_ register: Register? = nil) -> Operation {
    return {
      cp_a(register?.get8($0) ?? $0.nextByte())($0)
    }
  }
  
  static func cp_a(_ value: UInt8) -> Operation {
    return {
      let oldVal = $0.registers.a
      subValue(in: .a, a: oldVal, b: value)($0)
      
      $0.registers.a = oldVal
    }
  }
  
  // MARK: - 16-bitt ALU
  static func add_hl(_ register: Register) -> Operation {
    return {
      let a = $0.registers.hl
      let b = register.get16($0)
      
      $0.registers.hl = a &+ b
      
      $0.registers.flags.n = false
      $0.registers.flags.h = checkForHalfCarry(a, b)
      $0.registers.flags.c = checkForCarry(a, b)
    }
  }
  
  static func add_sp() -> Operation {
    return {
      let a = $0.registers.sp
      let n = Int8(bitPattern: $0.nextByte())
      $0.registers.sp = UInt16(truncatingIfNeeded: Int(a) + Int(n))
      
      $0.registers.flags.z = false
      $0.registers.flags.n = false
      
      // TODO: See if this can be generalized better
      if n >= 0 {
        $0.registers.flags.c = (Int(a & 0xFF) + Int(n)) > 0xFF
        $0.registers.flags.h = (Int(a & 0xF) + Int(n)) > 0xF
      } else {
        $0.registers.flags.c = Int($0.registers.sp & 0xFF) <= Int(a & 0xFF)
        $0.registers.flags.h = Int($0.registers.sp & 0xF) <= Int(a & 0xF)
      }
    }
  }
  
// MARK: - MISC
  static func swap_r(_ register: Register) -> Operation {
    return {
      let val = register.get8($0)
      let upper = (val & 0xF0) >> 4
      let lower = (val & 0x0F) << 4
      
      let swapped = lower | upper
      
      register.set(swapped, in: $0)
      
      $0.registers.flags.z = swapped == 0
      $0.registers.flags.n = false
      $0.registers.flags.h = false
      $0.registers.flags.c = false
    }
  }
  
  static func daa() -> Operation {
    return {
      var value = $0.registers.a
      
      if $0.registers.flags.n { // subtraction
        if $0.registers.flags.c { value = value &- 0x60 }
        if $0.registers.flags.h { value = value &- 0x6 }
      } else { // addition
        if $0.registers.flags.c || value > 0x99 {
          value = value &+ 0x60
          $0.registers.flags.c = true
        }
        
        if $0.registers.flags.h || value > 0x09 {
          value = value &+ 0x6
        }
      }

      $0.registers.flags.z = $0.registers.a == 0
      $0.registers.flags.h = false
    }
  }
  
  static func cpl() -> Operation {
    return {
      $0.registers.a = ~$0.registers.a
      
      $0.registers.flags.n = true
      $0.registers.flags.h = true
    }
  }
  
  static func ccf() -> Operation {
    return {
      $0.registers.flags.c = !$0.registers.flags.c
      
      $0.registers.flags.n = false
      $0.registers.flags.h = false
    }
  }
  
  static func scf() -> Operation {
    return {
      $0.registers.flags.c = true
      
      $0.registers.flags.n = false
      $0.registers.flags.h = false
    }
  }
  
  // MARK: - Jumps
  static func jump_nn() -> Operation {
    return jump{ _ in true }
  }
  
  static func jump( _ condition: @escaping (CPU) -> Bool) -> Operation {
    return {
      guard condition($0) else {
        return
      }
      
      $0.registers.pc = $0.nextWord()
    }
  }
  
  static func jp_hl() -> Operation {
    return {
      $0.registers.pc = $0.registers.hl
    }
  }
  
  static func jr() -> Operation {
    return jr{ _ in true }
  }
  
  static func jr(_ condition: @escaping (CPU) -> Bool) -> Operation {
    return {
      let a = $0.registers.pc
      let n = Int8(bitPattern: $0.nextByte())

      guard condition($0) else {
        return
      }
      
      $0.registers.pc = UInt16(truncatingIfNeeded: Int(a) + Int(n))
    }
  }
  
  // MARK: Calls
  static func call_nn() -> Operation {
    return call{ _ in true }
  }
  
  static func call(_ condition: @escaping (CPU) -> Bool) -> Operation {
    return {
      guard condition($0) else {
        return
      }

      let jump = $0.nextWord()
      $0.push($0.registers.pc)
      $0.registers.pc = jump
    }
  }
  
  // MARK: Restart
  static func restart(_ value: UInt16) -> Operation {
    return {
      $0.push($0.registers.pc)
      $0.registers.pc = value
    }
  }
  
  // MARK: RETURN
  static func ret() -> Operation {
    return ret{ _ in true }
  }
  
  static func reti() -> Operation {
    return {
      ret{ _ in true }($0)
      $0.masterInteruptFlag = true
    }
  }
  
  static func ret(_ condition: @escaping (CPU) -> Bool) -> Operation {
    return {
      guard condition($0) else {
        return
      }
      
      $0.registers.pc = $0.pop()
    }
  }
  
  
  static func prefix() -> Operation {
    return {
      let instruction = I.extInstructions[Int($0.nextByte())]
      $0.execute(instruction)
    }
  }
}

// MARK: - Reused Flag conditionals
// (hence the C)
struct C {
  static var notZ: (CPU) -> Bool {
    return {
      return !self.zSet($0)
    }
  }
  
  static var zSet: (CPU) -> Bool {
    return {
      return $0.registers.flags.z
    }
  }
  
  static var notC: (CPU) -> Bool {
    return {
      return !self.cSet($0)
    }
  }
  
  static var cSet: (CPU) -> Bool {
    return {
      return $0.registers.flags.c
    }
  }
}

private func checkForHalfCarry(_ a: UInt16, _ b:UInt16) -> Bool {
  return ((a & 0xf) + (b & 0xf)) & 0x100 == 0x100
}

private func checkForHalfCarry(_ a: UInt8, _ b:UInt8) -> Bool {
  return ((a & 0xf) + (b & 0xf)) & 0x10 == 0x10
}

private func checkForCarry(_ a: UInt8, _ b:UInt8) -> Bool {
  let sum = UInt16(a) + UInt16(b)
  return (sum >> 8) == 0b1
}

private func checkForCarry(_ a: UInt16, _ b: UInt16) -> Bool {
  let sum = UInt32(a) + UInt32(b)
  return (sum >> 16) == 0b1
}

private func checkForHalfBorrow(_ a: UInt8, _ b:UInt8) -> Bool {
  return (a & 0xf) < (b & 0xf)
}

private func checkForBorrow(_ a: UInt8, _ b: UInt8) -> Bool {
  return a < a &- b
}
