import Foundation

//$FFFF  Interrupt Enable Flag
//$FF80-$FFFE  Zero Page - 127 bytes
//$FF00-$FF7F  Hardware I/O Registers
//$FEA0-$FEFF  Unusable Memory
//$FE00-$FE9F  OAM - Object Attribute Memory
//$E000-$FDFF  Echo RAM - Reserved, Do Not Use
//$D000-$DFFF  Internal RAM - Bank 1-7 (switchable - CGB only)
//$C000-$CFFF  Internal RAM - Bank 0 (fixed)
//$A000-$BFFF  Cartridge RAM (If Available)
//$9C00-$9FFF  BG Map Data 2
//$9800-$9BFF  BG Map Data 1
//$8000-$97FF  Character RAM
//$4000-$7FFF  Cartridge ROM - Switchable Banks 1-xx
//$0150-$3FFF  Cartridge ROM - Bank 0 (fixed)
//$0100-$014F  Cartridge Header Area
//$0000-$00FF  Restart and Interrupt Vectors

public class MMU {
  class Registers {
    static let bios: UInt16 = 0xFF50
  }
  
  var cartridge: Cartridge?
  
  private var bios: Bios = Bios()
  private var memory: [UInt8] = []
  private var inBios: Bool {
    return (read(Registers.bios) as UInt8) == 1
  }
  
  init(cart: Cartridge? = nil) {
    self.cartridge = cart
  }
  
  public func read(_ address: UInt16) -> UInt8 {
    switch address {
    case 0x0000...0x00FF where inBios: // Bootstrap Bios
      return bios.read(address)
    case 0x0000...0x7FFF: // Cart ROM
      return cartridge?.read(address) ?? 0
    case 0x8000...0x9FFF: // VRAM
      return memory[address]
    case 0xA000...0xBFFF: // Cart RAM
      return cartridge?.read(address) ?? 0
    case 0xC000...0xDFFF: // Internal RAM
      return memory[address]
    case 0xE000...0xFDFF: // Echo RAM
      return memory[address-0x2000]
    case 0xFE00...0xFE9F: // OAM / Sprite
      return 0  // TODO: Fiddle with things from the cart
    case 0xFF00...0xFFFE:
      return memory[address]
      
    default:
      assertionFailure("Unaddressable memory at \(address.toHex)")
      return 0
    }
  }
  
  public func write(_ value: UInt8, at address: UInt16) {
    switch address {
    case 0x8000...0x9FFF: // VRAM
      memory[address] = value
    case 0xA000...0xBFFF: // Cart RAM
      cartridge?.write(value, at: address)
    case 0xC000...0xDFFF: // Internal RAM
      memory[address] = value
    case 0xE000...0xFDFF: // Echo RAM
      memory[address-0x2000] = value
    case 0xFE00...0xFE9F: // OAM / Sprite
      break // TODO: Fiddle with things from the cart
    case 0xFF00...0xFFFE:
      memory[address] = value
      
    default:
      assertionFailure("Unaddressable memory at \(address.toHex)")
    }
  }
  
  public func read(_ address: UInt16) -> UInt16 {
    return UInt16(high: read(address+1), low: read(address))
  }
  
  public func write(_ value: UInt16, at address: UInt16) {
    let (high, low) = value.split()
    
    write(low, at: address)
    write(high, at: address+1)
  }
}

public class Bios {
  let data: [UInt8]
  
  init() {
    let url = Bundle.main.url(forResource: "bios", withExtension: "bin")!
    let rawData = try! Data(contentsOf: url)
    
    data = [UInt8](rawData)
  }
  
  public func read(_ address: UInt16) -> UInt8 {
    return data[address]
  }
}
