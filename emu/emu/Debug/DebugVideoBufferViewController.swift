import Cocoa

class DebugVideoBufferViewController: NSViewController {
  var queue: DispatchQueue = DispatchQueue(label: "Render")
  
  @IBOutlet weak var screenImage: NSImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DebugService.shared.debugScreen = self
  }
  
  override func viewDidDisappear() {
    super.viewDidDisappear()
    
    DebugService.shared.debugScreen = nil
  }
}

extension DebugVideoBufferViewController : Screen {
  func display(_ bitmap: PPU.BitMap) {
    queue.async {
      guard let cgImage = bitmap.makeImage() else {
        return
      }
      
      let image = NSImage(cgImage: cgImage, size: NSMakeSize(256, 256))
      
      DispatchQueue.main.async {
        self.screenImage.image = image
      }
    }
  }
}
