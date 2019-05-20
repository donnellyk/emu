import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var device: Device! = nil

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    DebugService.shared.setBreakpoint("0x005b")
    
    device = Device()
    device.screen = (NSApplication.shared.mainWindow?.windowController?.contentViewController as? ViewController)

    device.boot(cartridge: Cartridge())
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

