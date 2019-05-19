import Foundation

// MARK: COMPUTED VARS
public extension PPU {
  var bgPalette: Palette {
    return Palette(value: mmu.read(.bgPalette))
  }
  
  var objPalette0: Palette {
    return Palette(value: mmu.read(.objPalette0))
  }
  
  var objPalette1: Palette {
    return Palette(value: mmu.read(.objPalette1))
  }
}

// MARK: DEFINITIONS
public extension PPU {
  enum Mode : UInt8 {
    case oamSearch = 2
    case vramSearch = 3
    case hBlank = 0
    case vBlank = 1
    
    var timing: Int {
      switch self {
      case .oamSearch: return 80
      case .vramSearch: return 172
      case .hBlank: return 456
      case .vBlank: return 4560
      }
    }
    
    func checkTimer(_ clock: Int) -> Bool {
      return clock >= timing
    }
    
    func resetClock(_ clock: Int) -> Int {
      return clock % timing
    }
    
    func prettyPrint() -> String {
      switch self {
      case .oamSearch: return "OAM Search"
      case .vramSearch: return "VRAM Search"
      case .hBlank: return "HBlank"
      case .vBlank: return "VBlank"
      }
    }
  }
  
  enum ObjBlockMode {
    case mode8
    case mode16
  }
  
  
  struct Object {
    var x: UInt8
    var y: UInt8
    var chrCode: UInt8
    var attributes: UInt8
    
    var palette:UInt8 {
      return attributes.test(4).bit
    }
    
    var horizontalFlipFlag: Bool {
      return attributes.test(5)
    }
    
    var verticalFlipFlag: Bool {
      return attributes.test(6)
    }
    
    var bgPriorityFlag: Bool {
      return attributes.test(7)
    }
    
    init(mmu: MMU, startingAddress adr: UInt16) {
      self.init(memory:
        [
          mmu.read(adr),
          mmu.read(adr + 1),
          mmu.read(adr + 2),
          mmu.read(adr + 3)
        ]
      )
    }
    
    init(memory: [UInt8]) {
      y = memory[0]
      x = memory[1]
      chrCode = memory[2]
      attributes = memory[3]
    }
  }
  
  struct Palette {
    enum PColor : UInt8 {
      case white, lightGrey, darkGrey, black
      
      var value: (r: UInt8, g: UInt8, b: UInt8) {
        switch self {
        case .white:
          return (0xFF, 0xFF, 0xFF)
        case .lightGrey:
          return (0xCC, 0xCC, 0xCC)
        case .darkGrey:
          return (0x77, 0x77, 0x77)
        case .black:
          return (0x00, 0x00, 0x00)
        }
      }
      
      var hexString: String {
        switch self {
        case .white:
          return "#FFFFFF"
        case .lightGrey:
          return "#CCCCCC"
        case .darkGrey:
          return "#777777"
        case .black:
          return "#000000"
        }
      }
    }
    
    let value: UInt8
    
    func getColor(num: UInt8) -> PColor {
      switch num {
      case 0b00:
        return PColor(rawValue: value.get(bits: 1, 0))!
      case 0b01:
        return PColor(rawValue: value.get(bits: 3, 2))!
      case 0b10:
        return PColor(rawValue: value.get(bits: 5, 4))!
      default:
        return PColor(rawValue: value.get(bits: 7, 6))!
      }
    }
  }

  
  struct BitMap {
    private(set) var canvas: BitmapCanvas
    var index = NSPoint(x: 0, y: 0)
    
    init(size: CGSize = CGSize(width: 160, height: 144)) {
      canvas = BitmapCanvas(Int(size.width), Int(size.height))
    }

    public struct Line {
      private(set) var pixels = [Pixel]()
      
      
      mutating func addPixels(_ pixels: [Pixel]) {
        self.pixels.append(contentsOf: pixels)
      }
    }
    
    public struct Pixel {
      let value: Palette.PColor
      
      init(color: Palette.PColor) {
        value = color
      }
    }
    
    
    mutating func addLine(_ line: Line) {
      line.pixels.forEach {
        canvas.setColor(index, color: $0.value.hexString)
        index.y += 1
      }
      
      index.x += 1
      index.y = 0
    }
    
    mutating func addDebugFrame(x: Int, y: Int) {
      canvas.rectangle(NSRect(x: x, y: y, width: 160, height: 144), stroke: "#FF0000", fill: nil)
    }
    
    func makeImage() -> CGImage? {
      return canvas.bitmapImageRep.cgImage
    }
  }
}
