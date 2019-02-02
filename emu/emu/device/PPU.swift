import Foundation

public class PPU {
  static let tileSize: UInt16 = 16
  static let tileIDSize: UInt16 = 8
  static let bgWidth: UInt16 = 32
  
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
        drawLine(fetchTileLine(index: i))
      }
    }
    
    // Render Window
    if mmu.lcdc.windowFlag {
      
    }
    
    // Render Objects
    if mmu.lcdc.objFlag {
      
    }
  }
  
  func fetchTileLine(index: Int) -> UInt16 {
    let bgChar = mmu.lcdc.bgCharArea
    
    // ((line + syc) % 8) = current "line" within a tile. * 2 to get address offset, since each pixel line is 2 bytes
    let tileLineOffset = UInt16(line &+ mmu.read(.scy)) % 8 * 2
    let id = UInt16(fetchTileID(index: UInt16(index)))
    
    let tileAddress = bgChar + (id * PPU.tileSize) + tileLineOffset
    
    return mmu.read(tileAddress)
  }


  /// Reads the tile id for the given line and index
  ///
  /// - Parameter index: index of tile in the current line. Ex: First tile is 0, last is 19
  /// - Returns: The ID of the tile, to be read from `BGCHAR`
  func fetchTileID(index: UInt16) -> UInt8 {
    let x = UInt16(mmu.read(.scx)) / PPU.tileIDSize
    let y = UInt16(line &+ mmu.read(.scy)) / PPU.tileIDSize
    
    let coord = (y * PPU.bgWidth) + x
    let idAddress = mmu.lcdc.bgCodeArea + coord + UInt16(index)
    return mmu.read(idAddress) &+ mmu.lcdc.bgTileIDOffset
  }
  
  func drawLine(_ line: UInt16) {
    
  }
  
  func pushToScreen() {
    // Might not be necessary, depending on the screen implementation
  }
}
