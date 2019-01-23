import Foundation

public class Cartridge {
//  let data: [UInt8] = []
  
  public func read(_ address: UInt16) -> UInt8 {
    return 0 //data[address]
  }
  
  public func write(_ value: UInt8, at address: UInt16) {
    
  }
}
