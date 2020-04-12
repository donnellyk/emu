import Cocoa

extension NSNotification.Name {
  static let DebugServiceDidPause = NSNotification.Name("DebugServiceDidPause")
}

class DebugService {
  static var shared: DebugService = DebugService()
  weak var debugController: DebugController?
  
  private init() { }
  
  private(set) var pcBreakpoint: UInt16?
  private(set) var isPaused: Bool = false
  
  var updateOnEveryStep: Bool = false
  var consolePrintEnabled: Bool = false
  
  private var executionHistory = [String]() {
    didSet {
      if executionHistory.count > 100 {
        executionHistory.removeFirst()
      }
    }
  }
  
  weak var debugScreen: Screen? {
    didSet {
      renderVideoBuffer()
    }
  }
  
  weak var memoryMap: DebugMemoryViewController? {
    didSet {
      memoryMap?.setMemory(memory: device.cpu.mmu.copy())
    }
  }
  
  private var device: Device! {
    return (NSApplication.shared.delegate as! AppDelegate).device
  }
}

// MARK: - Device Interface
extension DebugService {
  func shouldStep() -> Bool {
    if !isPaused {
      checkForBreakpoint()
    }
    
    if isPaused {
      NotificationCenter.default.post(name: .DebugServiceDidPause, object: nil)
      debugController?.didPause()

      renderVideoBuffer()
      memoryMap?.setMemory(memory: device.cpu.mmu.copy())
      cPrint("---------- PAUSED - \(pcBreakpoint?.toHex ?? "") ----------", override: true)
    }
    
    return !isPaused
  }
  
  func performingInstruction(opSummary: String, programCounter: UInt16) {
    cPrint("Instruction Executed: \(opSummary); \(programCounter.toHex)")
    
    executionHistory.append(opSummary)
  }
  
  func didPushToScreen() {
    renderVideoBuffer()
  }
  
  func didStep() {
    if updateOnEveryStep {
      debugController?.updateProgramDisplay()
    }
  }
  
  func vramDump() {
    print(device.cpu.mmu.vram.stringRepresentation)
    (NSApplication.shared.delegate as! AppDelegate).launchTileMapController(canvas: device.cpu.mmu.vram.imageRepresentation)
  }
}

private extension DebugService {
  func checkForBreakpoint() {
    if shouldBreak() {
      isPaused = true
    }
  }
  
  func shouldBreak() -> Bool {
    return device.cpu.registers.pc == pcBreakpoint
  }
  
  func renderVideoBuffer() {
    guard let debugScreen = debugScreen else {
      return
    }
    
    let fullBuffer = device.gpu.renderEntireBuffer()
    debugScreen.display(fullBuffer)
  }
  
  func cPrint(_ text: String, override: Bool = false) {
    if override || consolePrintEnabled {
      print(text)
    }
  }
}

// MARK: - UI Interface
extension DebugService {
  var displayBreakpoint: String {
    return pcBreakpoint?.toHex ?? ""
  }
  
  
  /// Returns register value in a sane/readable format
  var prettyRegisterValues: String {
    return """
    \(device.cpu.registers.prettyPrint())
    """
  }
  
  /// Returns flags value in a sane/readable format
  var prettyHardwareRegisterValues: String {
    return """
    Hardware Register
    \(device.cpu.mmu.lcdc.prettyPrint())
    \(device.cpu.mmu.stat.prettyPrint())
    """
  }
  
  func step() {
    device.debugStep()
  }
  
  func pause() {
    isPaused = true
  }
  
  func resume() {
    isPaused = false
    device.debugResume()
  }
  
  func clearBreakpoint() {
    pcBreakpoint = nil
  }
  
  func setBreakpoint(_ adr: String) -> Bool {
    let formatedString = adr.replacingOccurrences(of: "0x", with: "")
    guard let intValue = UInt16(formatedString, radix: 16) else {
      pcBreakpoint = nil
      return false
    }
    
    pcBreakpoint = intValue
    return true
  }
  
  func generateProgram() -> String {
    return executionHistory.joined(separator: "\n")
  }
}
