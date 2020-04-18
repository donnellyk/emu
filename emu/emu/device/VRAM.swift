import Foundation

class VRAM {
  private var vram: [UInt8]
  private var tiles: [Tile]
  
  var stringRepresentation: String {
    return tiles.map{ $0.stringRepresentation }.joined(separator: "\n\n")
  }
  
  var imageRepresentation: BitmapCanvas {
    let col = 16 * 8
    let row = (tiles.count / 16) * 8
    var canvas = BitmapCanvas(col, row)
    tiles.enumerated().forEach { (i, el) in
      let x = (i % 16) * 8
      let y = (i/16) * 8
      el.render(canvas: &canvas, offset: NSPoint(x: x, y: y))

      let bitmap = canvas.bitmapImageRep

    }
    
    return canvas
  }
  
  init() {
    vram = []
    tiles = []
    
    (0..<VRAM.size).forEach { _ in
      vram.append(0)
    }
  
    (0..<VRAM.tileLimit).forEach { _ in
      tiles.append(Tile())
    }
  }
  
  func write(address: UInt16, value: UInt8) {
    vram[address] = value
    
    guard address < 0x1800 else { return } /// Outside of tile map
    
    let normalizedIndex = address & 0xFFFE /// Normalized addressed of first tile byte: `12 & 0xFFFE == 12` and `13 & 0xFFFE == 12`
    
    let low = vram[normalizedIndex]
    let high = vram[normalizedIndex + 1]

    let tileIndex = address / VRAM.tileSize
    let rowIndex = (address % VRAM.tileSize) / 2 /// Every two bytes is a new row
    
    updateTile(tileIndex, row: rowIndex, low: low, high: high)
  }
}

extension VRAM {
  func updateTile(_ tile: UInt16, row: UInt16, low: UInt8, high: UInt8) {
    tiles[tile].updateRow(row, low: low, high: high)
  }
}
