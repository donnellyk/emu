import Foundation

public class Device {
  let cpu: CPU
  let gpu: PPU
  
  init(mmu: MMU = MMU()) {
    self.cpu = CPU(mmu: mmu)
    self.gpu = PPU(mmu: mmu)
  }
}

public extension Device {
  func boot(cartridge: Cartridge? = nil) {
    cpu.mmu = MMU(cart: cartridge)
    cpu.boot()
    gpu.boot()
    
    startRunLoop()
  }
  
  func startRunLoop() {
    
  }
  
  func step() {
    cpu.step()
    gpu.step(cycles: 0)
  }
}
