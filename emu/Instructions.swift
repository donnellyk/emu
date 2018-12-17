import Foundation

public class Instruction {
  let opcode: OpCode
  let operand: String
  
  init?(instruction: String) {
    guard
      let opcode = OpCode(instruction: instruction),
      let operand = instruction.split(separator: " ").last else {
        return nil
    }
    
    self.opcode = opcode
    self.operand = String(operand)
  }
}

public enum OpCode : String {
  // 8/16 Bit Loads
  case LD
  case LDD
  case LDI
  case LDH
  case PUSH
  case POP
  
  // Arithmetic
  case ADD
  case ADC
  case SUB
  case SBC
  case AND
  case OR
  case XOR
  case XP
  case INC
  case DEC
  
  // Misc
  case SWAP
  case DAA
  case CCF
  case SCF
  case NOP
  case HALT
  case STOP
  case DI
  case EI
  
  // Rotate / Shift
  case RLCA
  case RLA
  case RRCA
  case RRA
  case RLC
  case RL
  case RRC
  case RR
  case SLA
  case SRA
  case SRL
  
  // Bit
  case BIT
  case SET
  case RES
  
  // Jump
  case JP
  case JR
  
  // Call
  case CALL
  
  // Restart
  case RST
  
  // Return
  case RET
  case RETI
  
  init?(instruction: String) {
    guard let opcode = instruction.split(separator: " ").first else {
      return nil
    }
    
    self.init(rawValue: String(opcode))
  }
  
}
