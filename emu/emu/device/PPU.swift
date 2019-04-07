import Foundation

protocol PPUDelegate : class {
  func ppu(_ ppu: PPU, didDraw bitmap: PPU.BitMap)
}

public class PPU {
  weak var delegate: PPUDelegate?
  
  static let tileSize: UInt16 = 16
  static let tileIDSize: UInt16 = 8
  static let bgWidth: UInt16 = 32
  
  weak var mmu: MMU!

  var modeClock: Int = 0
  var mode: Mode {
    get {
      return mmu.stat.mode
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
  
  var bitmap = BitMap()
  
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
    
    if expired {
      modeClock = mode.resetClock(modeClock)
    }
    
    switch mode {
    case .oamSearch:
      if expired {
        mode = .vramSearch
      }
      
    case .vramSearch:
      if expired {
        mode = .hBlank
        
        renderScanline()
      }
      
    case .hBlank:
      if expired {
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
        line += 1
        
        if line > 153 {
          mode = .oamSearch
          line = 0
        }
      }
    }
  }
    
  func renderScanline() {
    guard mmu.lcdc.stopFlag else {
      return
    }
    
    var line = BitMap.Line()
    
    // Render Background
    if mmu.lcdc.bgDisplayFlag {
      for i in 0..<20 {
        let pixels = renderTile(bytes: fetchTileLine(index: i))
        line.addPixels(pixels)
      }
    }
    
    // Render Window
    if mmu.lcdc.windowFlag {
      
    }
    
    // Render Objects
    if mmu.lcdc.objFlag {
      
    }
    
    bitmap.addLine(line)
  }
  
  func fetchTileLine(index: Int) -> (UInt8, UInt8) {
    let bgChar = mmu.lcdc.bgCharArea
    
    // ((line + syc) % 8) = current "line" within a tile. * 2 to get address offset, since each pixel line is 2 bytes
    let tileLineOffset = UInt16(line &+ mmu.read(.scy)) % 8 * 2
    let id = UInt16(fetchTileID(index: UInt16(index)))
    
    let tileAddress = bgChar + (id * PPU.tileSize) // Address of beginning of the tile
    let lineAddress = tileAddress + tileLineOffset // Address for specific line of 8 pixels from tile
    
    return (mmu.read(lineAddress), mmu.read(lineAddress+1))
  }

  /// Reads the tile id for the given line and index
  ///
  /// - Parameter index: index of tile in the current line. Ex: First tile is 0, last is 19
  /// - Returns: The ID of the tile, to be read from `BGCHAR`
  /// - Discussion: The ID will be adjusted as necessary based on the BGCodeArea flag, with the necessary offsets applied to be a positive value. Use as is.
  func fetchTileID(index: UInt16) -> UInt16 {
    let x = UInt16(mmu.read(.scx)) / PPU.tileIDSize
    let y = UInt16(line &+ mmu.read(.scy)) / PPU.tileIDSize
    
    let coord = (y * PPU.bgWidth) + x
    let idAddress = mmu.lcdc.bgCodeArea + coord + UInt16(index)
    let bitPattern:UInt8 = mmu.read(idAddress)
    
    
    if mmu.lcdc.bgCharAreaFlag {
      let offset: Int16 = 128
      let signedValue = Int16(clamping: Int8(bitPattern: bitPattern))
      
      return UInt16(clamping: signedValue + offset)
    } else {
      return UInt16(clamping: bitPattern)
    }
  }
  
  func renderTile(bytes: (UInt8, UInt8)) -> [BitMap.Pixel] {
    return (0..<8).map { renderPixel(i: $0, bytes: bytes) }
  }
  
  func renderPixel(i index: Int, bytes: (UInt8, UInt8)) -> BitMap.Pixel {
    var bit = bytes.0.bit(index) << 1
    bit |= bytes.1.bit(index)
    
    let color = bgPalette.getColor(num: bit)
    return BitMap.Pixel(color: color)
  }
  
  func pushToScreen() {
    delegate?.ppu(self, didDraw: bitmap)
    bitmap = BitMap() //Reset bitmap
  }
}
