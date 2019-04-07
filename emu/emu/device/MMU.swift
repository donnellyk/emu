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
  public enum RegisterAddress: UInt16 {
    case lcdc = 0xFF40
    case stat = 0xFF41
    case scy = 0xFF42
    case scx = 0xFF43
    case ly = 0xFF44
    case lyc = 0xFF45
    
    case bgPalette = 0xFF47
    case objPalette0 = 0xFF48
    case objPalette1 = 0xFF49
    
    case bios = 0xFF50
    
    case bcps = 0xFF68
    case bcpd = 0xFF69
    case ocps = 0xFF6A
    case ocpd = 0xFF6B
    
    case wy = 0xFF4A
    case wx = 0xFF4B
    
    case dmaTransfer = 0xFF46
    case oam = 0xFE00
  }
  
  var cartridge: Cartridge?
  
  private var bios: Bios = Bios()
  private var memory: [UInt8] = []
  private var inBios: Bool {
    return read(.bios) == 1
  }
  
  init(cart: Cartridge? = nil) {
    self.cartridge = cart
    (0..<0xFFFE).forEach { _ in
      memory.append(0)
    }
    
    write(true, at: .bios)
  }
  
  public func read(_ register: RegisterAddress) -> UInt8 {
    return read(register.rawValue)
  }
  
  public func write(_ value: Bool, at register: RegisterAddress) {
    return write(value.bit, at: register)
  }
  
  public func write(_ value: UInt8, at register: RegisterAddress) {
    return write(value, at: register.rawValue)
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
      return memory[address]
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
      memory[address] = value
    case 0xFF00...0xFFFE:
      let old = memory[address]
      memory[address] = value

      hardwareRegisterCheck(old: old, new: value, address: address)
      
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

extension MMU {
  func hardwareRegisterCheck(old: UInt8, new: UInt8, address: UInt16) {
    guard let register = RegisterAddress(rawValue: address) else {
      return
    }
    
    switch register {
    case .lcdc:
      if LCDC.checkStopFlag(old: old, new: new) {
        write(0, at: .ly)
      }
      
    case .lyc:
      var value = read(.stat)
      
      value.set(2, value: (new == read(.ly)))
      write(value, at: .stat)
      
    case .dmaTransfer:
      startDMATransfer(new)
      
    default:
      break
    }
  }
  
  func startDMATransfer(_ value: UInt8) {
    let address = UInt16(exactly: value)! << 8
    
    let range: Range<UInt16> = (0..<160)
    range.forEach { i in
      let value: UInt8 = read(address + i)
      write(value, at: RegisterAddress.oam.rawValue + i)
    }
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
