import Foundation

public class Device {
  let cpu: CPU
  
  init(mmu: MMU = MMU()) {
    self.cpu = CPU(mmu: mmu)
  }
}

public extension Device {
  func boot(cartridge: Cartridge? = nil) {
    cpu.mmu = MMU(cart: cartridge)
    cpu.boot()
  }
}
