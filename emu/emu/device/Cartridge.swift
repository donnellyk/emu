import Foundation

public class Cartridge {
  let data: [UInt8]
  
  init() {
    let url = Bundle.main.url(forResource: "tetris", withExtension: "bin")!
    let rawData = try! Data(contentsOf: url)
    
    data = [UInt8](rawData)
  }
  
  public func read(_ address: UInt16) -> UInt8 {
    return data[address]
  }
  
  public func write(_ value: UInt8, at address: UInt16) {
    
  }
}
