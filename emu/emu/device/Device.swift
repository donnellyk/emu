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
    gpu.mmu = cpu.mmu
    
    cpu.boot()
    gpu.boot()
    
    startRunLoop()
  }
  
  func startRunLoop() {
    DispatchQueue.main.async {
      self.step()
    }
  }
  
  func step() {
    let cycles = cpu.step()
    gpu.step(cycles: cycles)
    DispatchQueue.main.async {
      self.step()
    }
  }
}

extension Device : PPUDelegate {
  func ppu(_ ppu: PPU, didDraw bitmap: PPU.BitMap) {
    screen?.display(bitmap)
  }
}
