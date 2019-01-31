import Foundation

public class PPU {
  weak var mmu: MMU!

  var modeClock: Int = 0
  var mode: Mode {
    get {
      let value = mmu.read(.stat)
      return PPU.Mode(rawValue: value & 0x02)!
    }
    set {
      let value = (mmu.read(.stat) & ~3) | newValue.rawValue
      mmu.write(value, at: .stat)
    }
  }
  
  var line: UInt8 {
    get {
      return mmu.read(.ly)
    }
    set {
      mmu.write(newValue, at: .ly)
    }
  }
  
  init(mmu: MMU) {
    self.mmu = mmu
  }
}

public extension PPU {
  func boot() {
    mode = .hBlank
    modeClock = 0
    line = 0
  }
  
  func step(cycles: Int) {
    modeClock += cycles
    let expired = mode.checkTimer(modeClock)
    
    switch mode {
    case .oamSearch:
      if expired {
        modeClock = 0
        mode = .vramSearch
      }
      
    case .vramSearch:
      if expired {
        modeClock = 0
        mode = .hBlank
        
        renderScanline()
      }
      
    case .hBlank:
      if expired {
        modeClock = 0
        line += 1
        
        if line == 143 {
          mode = .vBlank
          pushToScreen()
        } else {
          mode = .oamSearch
        }
      }
      
      break
    case .vBlank:
      if expired {
        modeClock = 0
        line += 1
        
        if line > 153 {
          mode = .oamSearch
          line = 0
        }
      }
    }
  }
    
  func renderScanline() {
    guard !(mmu.lcdc.stopFlag) else {
      return
    }
    
    // Render Background
    if mmu.lcdc.bgDisplayFlag {
      for i in 0..<20 {
        drawLine(fetchTile(indexOffset: i))
      }
    }
    
    // Render Window
    if mmu.lcdc.windowFlag {
      
    }
    
    // Render Objects
    if mmu.lcdc.objFlag {
      
    }
  }
  
//  func fetchTile() {
//
//  }
  
  func fetchTile(indexOffset: Int) -> UInt16 {
    let tileSize: UInt16 = 16
    let x = UInt16(mmu.read(.scx)) / 8
    let y = UInt16(line &+ mmu.read(.scy)) / 8
    let lineTileOffset = UInt16(line &+ mmu.read(.scy)) % 8 * 2
    
    let bgData = mmu.lcdc.bgCodeArea
    let bgChar = mmu.lcdc.bgCharArea
    let idOffset = mmu.lcdc.bgTileIDOffset
    
    let tileOffset = UInt16(indexOffset / 8)
    let idAddress = bgData + (y * 32) + x + tileOffset
    let tileID = UInt16(mmu.read(idAddress) as UInt8) &+ idOffset
    
    let tileAddress = bgChar + (tileID*tileSize) + lineTileOffset
    
    return mmu.read(tileAddress)
  }
  
  func drawLine(_ line: UInt16) {
    
  }
  
  func pushToScreen() {
    // Might not be necessary, depending on the screen implementation
  }
}
