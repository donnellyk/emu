import Cocoa

protocol DebugController: class {
  func updateProgramDisplay()
  func didPause()
}

class DebugViewController: NSViewController, DebugController {
  @IBOutlet weak var pauseButton: NSButton!
  @IBOutlet weak var toggleStepUpdateButton: NSButton!
  @IBOutlet weak var stepButton: NSButton!
  @IBOutlet weak var addressField: NSTextField!
  @IBOutlet weak var addressLabel: NSTextField!
  @IBOutlet var programField: NSTextView!
  @IBOutlet weak var registerLabel: NSTextField!
  @IBOutlet weak var flagLabels: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DebugService.shared.debugController = self
    
    resetButtons()
    updateProgramDisplay()
    
    addressLabel.stringValue = DebugService.shared.displayBreakpoint
  }
  
  // MARK: - ACTIONS
  @IBAction func setTapped(_ sender: Any) {
    defer {
      addressField.stringValue = ""
    }
    _ = DebugService.shared.setBreakpoint(addressField.stringValue)
    addressLabel.stringValue = DebugService.shared.displayBreakpoint
  }
  
  @IBAction func stepTapped(_ sender: Any) {
    DebugService.shared.step()
    updateProgramDisplay()
  }
  
  @IBAction func pauseTapped(_ sender: Any) {
    defer {
      resetButtons()
      updateProgramDisplay()
    }
    
    if DebugService.shared.isPaused {
      DebugService.shared.resume()
    } else {
      DebugService.shared.pause()
    }
  }
  
  @IBAction func everyStepTapped(_ sender: Any) {
    DebugService.shared.updateOnEveryStep = !DebugService.shared.updateOnEveryStep
    resetButtons()
  }
  
  @IBAction func vramDumpTapped(_ sender: Any) {
    DebugService.shared.vramDump()
  }
  
  func resetButtons() {
    if DebugService.shared.isPaused {
      pauseButton.title = "Resume"
      stepButton.isHidden = false
    } else {
      pauseButton.title = "Pause"
      stepButton.isHidden = true
    }
    
    if DebugService.shared.updateOnEveryStep {
      toggleStepUpdateButton.title = "Disable Every Step"
    } else {
      toggleStepUpdateButton.title = "Enable Every Step"
    }
  }
  
  func didPause() {
    resetButtons()
  }
  
  func updateProgramDisplay() {
    programField.string = DebugService.shared.generateProgram()
    
    registerLabel.stringValue = DebugService.shared.prettyRegisterValues
    flagLabels.stringValue = DebugService.shared.prettyHardwareRegisterValues
  }
  
  
}
