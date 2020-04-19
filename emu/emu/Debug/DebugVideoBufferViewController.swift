import Cocoa

class ImageViewController: NSViewController {
  var image: NSImage? {
    set {
      self.view.layer = CALayer()
      self.view.layer?.allowsEdgeAntialiasing = false
      self.view.layer?.contentsGravity = .resizeAspect
      self.view.layer?.contents = newValue
      self.view.wantsLayer = true
    }
    get {
      return nil
    }
  }
}

class DebugVideoBufferViewController: ImageViewController {
  var queue: DispatchQueue = DispatchQueue(label: "Render")
  
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
  func display(_ canvas: BitmapCanvas) {
    queue.async {
      let bitmap = canvas.bitmapImageRep
      let image = NSImage(cgImage: bitmap.cgImage!, size: bitmap.size)

      DispatchQueue.main.async {
        self.image = image
      }
    }
  }
  
  func display(_ bitmap: PPU.BitMap) {
    queue.async {
      guard let cgImage = bitmap.makeImage() else {
        return
      }
      
      let image = NSImage(cgImage: cgImage, size: NSMakeSize(256, 256))
      
      DispatchQueue.main.async {
        self.image = image
      }
    }
  }
}
