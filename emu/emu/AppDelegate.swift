import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var device: Device! = nil

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    device = Device()
    device.boot()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

