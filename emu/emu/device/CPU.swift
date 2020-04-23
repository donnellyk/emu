import Foundation

typealias Cycles = Int

public class CPU {
  var masterInteruptFlag: Bool = false
  
  var mmu: MMU
  var registers = Registers()
  
  init(mmu:MMU) {
    self.mmu = mmu
  }
  
  func boot() {
    registers = Registers()
  }
  
  func step() -> Cycles {
    let programCounter = registers.pc
    
    let instruction = I.table[nextByte()]
    
    let summary = instruction.opCodeString(nextByte: lookAhead(), nextWord: lookAhead())
    DebugService.shared.performingInstruction(opSummary: summary, programCounter: programCounter)

    return execute(instruction)
  }
  
  /// Executes an instruction and incremented the cycle count
  ///
  /// - Parameter instruction: Instruction to be executed
  func execute(_ instruction: Instruction) -> Cycles {
    instruction.operation(self)
    return instruction.cycles(self)
  }
  
  func nextInstruction() -> String {
    let pc: UInt8 = lookAhead()
    let instruction = I.table[pc]
    return instruction.opCodeString(nextByte: lookAhead(), nextWord: lookAhead())
  }
  
  /// Reads 8-bit value from program counter address and increments counter
  ///
  /// - Returns: Value from memory
  func nextByte() -> UInt8 {
    defer {
      registers.pc += 1
    }
    
    return mmu.read(registers.pc)
  }
  
  // Reads the memory at the current program counter without incrementing the cycle count
  func lookAhead() -> UInt8 {
    return mmu.read(registers.pc)
  }
  
  func lookAhead() -> UInt16 {
    return mmu.read(registers.pc)
  }
  
  /// Reads 16-bit value from program counter address and increments counter appropriatly
  ///
  /// - Returns: Value from memory
  func nextWord() -> UInt16 {
    defer {
      registers.pc += 2
    }
    
    return mmu.read(registers.pc)
  }
  
  
  /// Push value onto stack and adjust stack pointer
  ///
  /// - Parameter value: Value to push onto stack
  func push(_ value: UInt16) {
    mmu.write(value, at: registers.sp-2)
    registers.sp -= 2
  }
  
  
  /// Pop value off stack and adjust stack pointer
  ///
  /// - Returns: Value popped off stack
  func pop() -> UInt16 {
    defer {
      registers.sp += 2
    }
    
    return mmu.read(registers.sp)
  }
}
