import Foundation

public class CPU {
  let mmu: MMU
  let registers = Registers()
  
  init(mmu:MMU) {
    self.mmu = mmu
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
