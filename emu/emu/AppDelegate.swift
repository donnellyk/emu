import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  lazy private var mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
  
  var device: Device! = nil

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    _ = DebugService.shared.setBreakpoint("0x005b")
    
    device = Device()
    device.screen = (NSApplication.shared.mainWindow?.windowController?.contentViewController as? ViewController)
    
    device.boot(cartridge: Cartridge())
    
    let debugController: NSWindowController = mainStoryboard.instantiateController(identifier: "DebugWindowController")
    
    debugController.showWindow(self)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

