import Foundation

struct Instruction {
  var opcode: Int
  var cycles: Int
  var operation: Operation
  
  init(opcode: Int, operation: @escaping Operation, cycles: Int = 4) {
    self.opcode = opcode
    self.cycles = cycles
    self.operation = operation
  }
}

let instructionTable: [Instruction] = [
  Instruction(opcode: 0x0, operation: { _ in })
//  Instruction(opcode: 0x1, operation: ld_nn_n(.a))
]

typealias Operation = (CPU) -> Void


struct I {
  // MARK: - 8-Bit LOAD
  
  /// Sets memory addressed at next byte of PC to register
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
  
  static func dec(_ register: Register) -> Operation {
    return {
      if register.is8Bit {
        let c = $0.registers.flags.c
        
        let value = register.get8($0)
        subValue(in: register, a: value, b: 1)($0)
        
        $0.registers.flags.c = c
      } else {
        let value = register.get16($0)
        register.set(value-1, in: $0)
      }
    }
  }
  
  static func inc(_ register: Register) -> Operation {
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
  
  static func add_a(_ register: Register) -> Operation {
    return {
      let value: UInt8
      if register == .hl {
        value = $0.mmu.read(register.get16($0))
      } else {
        value = register.get8($0)
      }
      
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
  
  static func sbc_a(_ register: Register) -> Operation {
    return {
      let carry = $0.registers.flags.c.bit
      
      let value: UInt8
      if register == .hl {
        value = $0.mmu.read(register.get16($0))
      } else {
        value = register.get8($0)
      }
      
      subValue(in: .a, a: $0.registers.a, b: value)($0)
      subValue(in: .a, a: $0.registers.a, b: carry)($0)
    }
  }
  
  static func sbc_a_n() -> Operation {
    return {
      let carry = $0.registers.flags.c.bit
      let value = $0.nextByte()
      
      subValue(in: .a, a: $0.registers.a, b: value)($0)
      subValue(in: .a, a: $0.registers.a, b: carry)($0)
    }
  }

// MARK: - LOGICAL OPERATIONS
  
  static func and_a_n() -> Operation {
    return {
      and_a($0.nextByte())($0)
    }
  }
  
  static func and_a(_ register: Register) -> Operation {
    return {
      and_a(getValue(register, in: $0))($0)
    }
  }
  
  static func and_a(_ value: UInt8) -> Operation {
    return performLogicalOperationOnA(&, value: value)

  }
  
  static func or_a_n() -> Operation {
    return {
      or_a($0.nextByte())($0)
    }
  }
  
  static func or_a(_ register: Register) -> Operation {
    return {
      or_a(getValue(register, in: $0))($0)
    }
  }
  
  static func or_a(_ value: UInt8) -> Operation {
    return performLogicalOperationOnA(|, value: value)
  }
  
  static func xor_a_n() -> Operation {
    return {
      xor_a($0.nextByte())($0)
    }
  }
  
  static func xor_a(_ register: Register) -> Operation {
    return {
      xor_a(getValue(register, in: $0))($0)
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
  
  static func cp_a(_ register: Register) -> Operation {
    return {
      cp_a(getValue(register, in: $0))($0)
    }
  }
  
  static func cp_a_n() -> Operation {
    return {
      cp_a($0.nextByte())($0)
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
      let val = getValue(register, in: $0)
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
  
  static func DAA() -> Operation {
    return {
      var value = $0.registers.a
      let correction: UInt8 = 0
      
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
  
  static func CPL() -> Operation {
    return {
      $0.registers.a = ~$0.registers.a
      
      $0.registers.flags.n = true
      $0.registers.flags.h = true
    }
  }
  
  static func CCF() -> Operation {
    return {
      $0.registers.flags.c = !$0.registers.flags.c
      
      $0.registers.flags.n = false
      $0.registers.flags.h = false
    }
  }
  
  static func SCF() -> Operation {
    return {
      $0.registers.flags.c = true
      
      $0.registers.flags.n = false
      $0.registers.flags.h = false
    }
  }
  
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


/// Gets value from all 8-bit registers and HL
///
/// - Parameter register: Register to get value from
/// - Returns: UInt8 value from register
private func getValue(_ register: Register, in cpu: CPU) -> UInt8 {
  if register == .hl {
    return cpu.mmu.read(register.get16(cpu))
  } else {
    return register.get8(cpu)
  }
}
