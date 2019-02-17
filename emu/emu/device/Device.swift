import Foundation

protocol Screen : class {
  func display(_ bitmap: PPU.BitMap)
}

public class Device {
  let cpu: CPU
  let gpu: PPU
  
  weak var screen: Screen?
  
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

extension Device : PPUDelegate {
  func ppu(_ ppu: PPU, didDraw bitmap: PPU.BitMap) {
    screen?.display(bitmap)
  }
}
