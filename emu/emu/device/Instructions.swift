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


/// Sets memory addressed at next byte of PC to register
///
/// - Parameter register: <#register description#>
/// - Returns: Block to execute for load
func ld_r_nn(_ register: Register) -> Operation {
  return {
    register.set($0.nextByte(), in: $0)
  }
}

func ld_nn_r(_ register: Register) -> Operation {
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
func ld_r_r(_ r1: Register, _ r2: Register) -> Operation {
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

func ld_a_n(_ register: Register) -> Operation {
  return ld_r_r(.a, register)
}

func ld_n_a(_ register: Register) -> Operation {
  return ld_r_r(register, .a)
}

func ld_a_c() -> Operation {
  return {
    let address = 0xFF00 + Register.c.get16($0)
    let value: UInt8 = $0.mmu.read(address)
    
    Register.a.set(value, in: $0)
  }
}

func ld_c_a() -> Operation {
  return {
    let address = 0xFF00 + Register.c.get16($0)
    let value: UInt8 = Register.a.get(from: $0)
    
    $0.mmu.write(value, at: address)
  }
}

func ld_a_hl_dec() -> Operation {
  return {
    ld_r_r(.a, .hl)($0)
    dec(.hl)($0)
  }
}

func ld_hl_a_dec() -> Operation {
  return {
    ld_r_r(.hl, .a)($0)
    dec(.hl)($0)
  }
}

func ld_a_hl_inc() -> Operation {
  return {
    ld_r_r(.a, .hl)($0)
    inc(.hl)($0)
  }
}

func ld_hl_a_inc() -> Operation {
  return {
    ld_r_r(.hl, .a)($0)
    inc(.hl)($0)
  }
}

func ldh_n_a() -> Operation {
  return {
    let value = Register.a.get8($0)
    let address = 0xFF00 + UInt16($0.nextByte())
    
    $0.mmu.write(value, at: address)
  }
}

func ldh_a_n() -> Operation {
  return {
    let address = 0xFF00 + UInt16($0.nextByte())
    let value: UInt8 = $0.mmu.read(address)
    Register.a.set(value, in: $0)
  }
}

func ldd_r_nn(_ register: Register) -> Operation {
  return {
    register.set($0.nextWord(), in: $0)
  }
}

func ldd_sp_hl() -> Operation {
  return {
    $0.registers.sp = $0.registers.hl
  }
}

func ldd_hl_sp_n() -> Operation {
  return {
    let n = Int16($0.nextByte())
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

func ldd_nn_sp() -> Operation {
  return {
    $0.registers.sp = $0.nextWord()
  }
}

func push(_ register: Register) -> Operation {
  return {
    $0.push(register.get16($0))
  }
}

func pop(_ register: Register) -> Operation {
  return {
    register.set($0.pop(), in: $0)
  }
}


func dec(_ register: Register) -> Operation {
  return {
    if register.is8Bit {
      let value = register.get8($0)
      register.set(value-1, in: $0)
    } else {
      let value = register.get16($0)
      register.set(value-1, in: $0)
    }
  }
}

func inc(_ register: Register) -> Operation {
  return {
    if register.is8Bit {
      let value = register.get8($0)
      register.set(value + 1, in: $0)
    } else {
      let value = register.get16($0)
      register.set(value + 1, in: $0)
    }
  }
}

func add_a(_ register: Register) -> Operation {
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

func adc_a(_ register: Register) -> Operation {
  return {
    let carry = $0.registers.flags.c.bit
    
    add_a(register)($0)
    addValue(in: .a, a: $0.registers.a, b: carry)($0)
  }
}

func addValue(in register: Register, a: UInt8, b: UInt8) -> Operation {
  return {
    let val = a &+ b
   
    $0.registers.flags.z = (val == 0)
    $0.registers.flags.n = false
    $0.registers.flags.h = checkForHalfCarry(a, b)
    $0.registers.flags.c = checkForCarry(a, b)
    
    register.set(val, in: $0)
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
