import Foundation

public extension PPU {
  public enum Mode : UInt8 {
    case oamSearch = 2
    case vramSearch = 3
    case hBlank = 0
    case vBlank = 1
    
    var timing: Int {
      switch self {
      case .oamSearch: return 80
      case .vramSearch: return 172
      case .hBlank: return 456
      case .vBlank: return 4560
      }
    }
    
    func checkTimer(_ clock: Int) -> Bool {
      return clock >= timing
    }
  }
  
  public enum ObjBlockMode {
    case mode8
    case mode16
  }
  
  
  public struct Object {
    var x: UInt8
    var y: UInt8
    var chrCode: UInt8
    var attributes: UInt8
    
    var palette:UInt8 {
      return attributes.test(4).bit
    }
    
    var horizontalFlipFlag: Bool {
      return attributes.test(5)
    }
    
    var verticalFlipFlag: Bool {
      return attributes.test(6)
    }
    
    var bgPriorityFlag: Bool {
      return attributes.test(7)
    }
    
    init(mmu: MMU, startingAddress adr: UInt16) {
      self.init(memory:
        [
          mmu.read(adr),
          mmu.read(adr + 1),
          mmu.read(adr + 2),
          mmu.read(adr + 3)
        ]
      )
    }
    
    init(memory: [UInt8]) {
      y = memory[0]
      x = memory[1]
      chrCode = memory[2]
      attributes = memory[3]
    }
  }
}
